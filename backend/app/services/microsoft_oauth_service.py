"""Microsoft / Outlook OAuth helpers (authorization-code + PKCE exchange)."""

from __future__ import annotations

import logging
from urllib.parse import urlencode

import httpx

from app.config import settings

logger = logging.getLogger(__name__)

AUTHORIZE_URL = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize"
TOKEN_URL = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
SCOPES = "openid profile email offline_access User.Read Mail.Read"

_PERSONAL_EMAIL_DOMAINS = frozenset(
    {"outlook.com", "hotmail.com", "live.com", "msn.com", "gmail.com"}
)


def build_admin_consent_url(
    *,
    account_email: str,
    client_id: str,
    tenant_id: str | None = None,
) -> str | None:
    """Tenant admin consent URL for work/school accounts (Option B for IT).

    Uses MICROSOFT_TENANT_ID (GUID) when set. Otherwise ``organizations`` so the
    admin signs into their own tenant — never guess from email domain (AADSTS90002).
    """
    cid = (client_id or "").strip()
    if not cid or cid in {"your-azure-app-client-id", "YOUR_OUTLOOK_CLIENT_ID"}:
        return None
    email = (account_email or "").strip().lower()
    if "@" not in email:
        return None
    domain = email.rsplit("@", 1)[-1]
    if not domain or domain in _PERSONAL_EMAIL_DOMAINS:
        return None

    tenant = (tenant_id or "").strip()
    if not tenant:
        tenant = "organizations"
    return f"https://login.microsoftonline.com/{tenant}/adminconsent?client_id={cid}"


class MicrosoftOAuthService:
    def is_configured(self) -> bool:
        client_id = (settings.microsoft_client_id or "").strip()
        return bool(client_id) and client_id not in {
            "your-azure-app-client-id",
            "YOUR_OUTLOOK_CLIENT_ID",
        }

    def build_authorize_url(
        self,
        *,
        redirect_uri: str,
        state: str,
        code_challenge: str,
        prompt: str = "select_account",
    ) -> str:
        if not self.is_configured():
            raise ValueError(
                "Microsoft OAuth is not configured. Set MICROSOFT_CLIENT_ID in backend/.env"
            )
        params = {
            "client_id": settings.microsoft_client_id.strip(),
            "response_type": "code",
            "redirect_uri": redirect_uri,
            "response_mode": "query",
            "scope": SCOPES,
            "state": state,
            "code_challenge": code_challenge,
            "code_challenge_method": "S256",
            "prompt": prompt,
        }
        return f"{AUTHORIZE_URL}?{urlencode(params)}"

    async def exchange_code(
        self,
        *,
        code: str,
        redirect_uri: str,
        code_verifier: str,
    ) -> dict[str, str]:
        if not self.is_configured():
            raise ValueError(
                "Microsoft OAuth is not configured. Set MICROSOFT_CLIENT_ID in backend/.env"
            )

        payload: dict[str, str] = {
            "client_id": settings.microsoft_client_id.strip(),
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirect_uri,
            "code_verifier": code_verifier,
            "scope": SCOPES,
        }
        secret = (settings.microsoft_client_secret or "").strip()
        if secret:
            payload["client_secret"] = secret

        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(TOKEN_URL, data=payload)

        if response.status_code != 200:
            detail = response.text[:300]
            logger.warning("Outlook token exchange failed: %s", detail)
            raise ValueError(f"Outlook token exchange failed: {detail}")

        data = response.json()
        access_token = data.get("access_token")
        if not access_token:
            raise ValueError("Outlook token exchange did not return an access token")

        return {
            "access_token": access_token,
            "refresh_token": data.get("refresh_token") or "",
            "id_token": data.get("id_token") or "",
            "expires_in": str(data.get("expires_in") or ""),
        }
