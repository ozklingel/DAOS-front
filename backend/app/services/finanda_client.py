"""Finanda Smart Aggregation (Israeli Open Banking OBaaS) client.

Docs (partner access): https://docs.finanda.com
Product: https://www.finanda.com/open-banking/

Finanda does not publish a public free API. After onboarding they provide a
base URL + credentials. Paths below match common OBaaS / Open Banking shapes
and are overridable via env if Finanda's docs differ for your tenant.
"""

from __future__ import annotations

import logging
from typing import Any

import httpx

from app.config import settings

logger = logging.getLogger(__name__)

# Israeli ASPSPs Finanda aggregates (UI codes → Finanda provider codes)
FINANDA_BANKS: list[dict[str, str]] = [
    {"code": "leumi", "name": "בנק לאומי", "name_en": "Bank Leumi", "finanda_code": "leumi"},
    {"code": "hapoalim", "name": "בנק הפועלים", "name_en": "Bank Hapoalim", "finanda_code": "poalim"},
    {"code": "discount", "name": "בנק דיסקונט", "name_en": "Discount Bank", "finanda_code": "discount"},
    {"code": "mizrahi", "name": "מזרחי טפחות", "name_en": "Mizrahi Tefahot", "finanda_code": "mizrahi"},
    {"code": "fibi", "name": "הבינלאומי / FIBI", "name_en": "First International / FIBI", "finanda_code": "fibi"},
    {"code": "yahav", "name": "בנק יהב", "name_en": "Bank Yahav", "finanda_code": "yahav"},
]


class FinandaClient:
    def enabled(self) -> bool:
        return settings.finanda_enabled

    def headers(self) -> dict[str, str]:
        h = {
            "Accept": "application/json",
            "Content-Type": "application/json",
        }
        if settings.finanda_api_key.strip():
            h["Authorization"] = f"Bearer {settings.finanda_api_key.strip()}"
        if settings.finanda_client_id.strip():
            h["X-Client-Id"] = settings.finanda_client_id.strip()
        if settings.finanda_client_secret.strip():
            h["X-Client-Secret"] = settings.finanda_client_secret.strip()
        return h

    def create_consent(
        self,
        *,
        provider_code: str,
        psu_id: str | None,
        return_url: str,
        custom_fields: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        """Start AIS consent → returns connect/authorize URL + consent id."""
        bank = self._bank(provider_code)
        finanda_code = bank["finanda_code"] if bank else provider_code
        path = settings.finanda_consent_path or "/v1/consents"
        payload: dict[str, Any] = {
            "provider": finanda_code,
            "aspsp": finanda_code,
            "redirectUri": return_url,
            "returnUrl": return_url,
            "buckets": ["accounts", "balances", "transactions"],
            "access": {
                "accounts": {},
                "balances": {},
                "transactions": {},
            },
            "customFields": custom_fields or {},
        }
        if psu_id:
            payload["psuId"] = psu_id
            payload["psu_id"] = psu_id

        data = self._post(path, payload)
        row = data.get("data") or data
        connect_url = (
            row.get("authorizeUrl")
            or row.get("authorizationUrl")
            or row.get("redirectUrl")
            or row.get("connect_url")
            or row.get("url")
        )
        consent_id = (
            row.get("consentId")
            or row.get("consent_id")
            or row.get("id")
        )
        if not connect_url:
            raise ValueError(
                "Finanda did not return an authorize URL. "
                "Check FINANDA_API_URL / path against docs.finanda.com for your tenant."
            )
        return {
            "consent_id": str(consent_id) if consent_id else None,
            "connect_url": str(connect_url),
            "raw": row,
        }

    def exchange_token(self, *, consent_id: str, code: str | None = None) -> dict[str, Any]:
        path = settings.finanda_token_path or "/v1/oauth/token"
        payload: dict[str, Any] = {"consentId": consent_id, "consent_id": consent_id}
        if code:
            payload["code"] = code
            payload["grant_type"] = "authorization_code"
        data = self._post(path, payload)
        return data.get("data") or data

    def list_accounts(self, *, consent_id: str, access_token: str | None = None) -> list[dict[str, Any]]:
        path = (settings.finanda_accounts_path or "/v1/accounts").format(consent_id=consent_id)
        params = {"consentId": consent_id, "consent_id": consent_id}
        data = self._get(path, params=params, access_token=access_token)
        rows = data.get("data") or data.get("accounts") or data
        return rows if isinstance(rows, list) else []

    def list_transactions(
        self,
        *,
        account_id: str,
        consent_id: str,
        access_token: str | None = None,
    ) -> list[dict[str, Any]]:
        path = (settings.finanda_transactions_path or "/v1/accounts/{account_id}/transactions").format(
            account_id=account_id,
            consent_id=consent_id,
        )
        params = {
            "consentId": consent_id,
            "consent_id": consent_id,
            "accountId": account_id,
        }
        data = self._get(path, params=params, access_token=access_token)
        rows = data.get("data") or data.get("transactions") or data
        return rows if isinstance(rows, list) else []

    def _bank(self, code: str) -> dict[str, str] | None:
        code_l = code.strip().lower()
        for b in FINANDA_BANKS:
            if b["code"] == code_l or b["finanda_code"] == code_l:
                return b
        return None

    def _url(self, path: str) -> str:
        base = settings.finanda_api_url.rstrip("/")
        if not base:
            raise ValueError(
                "FINANDA_API_URL is empty. Get it from Finanda after joining "
                "https://www.finanda.com/open-banking/ (docs: https://docs.finanda.com)."
            )
        if not path.startswith("/"):
            path = f"/{path}"
        return f"{base}{path}"

    def _post(self, path: str, payload: dict[str, Any]) -> dict[str, Any]:
        url = self._url(path)
        with httpx.Client(timeout=45.0) as client:
            resp = client.post(url, json=payload, headers=self.headers())
            if resp.status_code >= 400:
                logger.error("Finanda POST %s failed: %s", path, resp.text[:500])
            resp.raise_for_status()
            return resp.json() if resp.content else {}

    def _get(
        self,
        path: str,
        *,
        params: dict[str, Any] | None = None,
        access_token: str | None = None,
    ) -> dict[str, Any]:
        url = self._url(path)
        headers = self.headers()
        if access_token:
            headers["Authorization"] = f"Bearer {access_token}"
        with httpx.Client(timeout=45.0) as client:
            resp = client.get(url, params=params, headers=headers)
            if resp.status_code >= 400:
                logger.error("Finanda GET %s failed: %s", path, resp.text[:500])
            resp.raise_for_status()
            return resp.json() if resp.content else {}
