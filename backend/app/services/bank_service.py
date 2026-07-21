"""Israeli bank linking via Salt Edge Account Information API (v5) or local demo.

Without SALT_EDGE_APP_ID + SALT_EDGE_SECRET → demo balances only.
With keys (new accounts): Fake Bank works immediately; real Israeli banks need
Salt Edge Test/Live approval (Request Test Access + Israel sales).
"""

from __future__ import annotations

import logging
from datetime import UTC, datetime, timedelta
from typing import Any

import httpx
from sqlalchemy.orm import Session

from app.config import settings
from app.core.security import new_id
from app.models import BankAccount, BankConnection, FinanceTransaction, TransactionType, User
from app.services.budget_service import BudgetService

logger = logging.getLogger(__name__)

# Curated UI list for demo mode (not Salt Edge provider codes)
ISRAELI_BANKS: list[dict[str, str]] = [
    {"code": "leumi", "name": "בנק לאומי", "name_en": "Bank Leumi"},
    {"code": "hapoalim", "name": "בנק הפועלים", "name_en": "Bank Hapoalim"},
    {"code": "discount", "name": "בנק דיסקונט", "name_en": "Discount Bank"},
    {"code": "mizrahi", "name": "מזרחי טפחות", "name_en": "Mizrahi Tefahot"},
    {"code": "yahav", "name": "בנק יהב", "name_en": "Bank Yahav"},
    {"code": "fi", "name": "FI (פייבוקס)", "name_en": "FI / PayBox"},
    {"code": "max", "name": "MAX", "name_en": "MAX"},
    {"code": "isracard", "name": "ישראכרט", "name_en": "Isracard"},
]

# Always available once Salt Edge keys exist (pending / test accounts)
SALTEDGE_TEST_BANKS: list[dict[str, str]] = [
    {
        "code": "fakebank_simple_xf",
        "name": "Fake Bank (בדיקת Salt Edge)",
        "name_en": "Fake Bank Simple — use username/secret from screen",
    },
    {
        "code": "saltedge_pick",
        "name": "בחירה במסך Salt Edge (ישראל)",
        "name_en": "Pick any bank in Salt Edge Connect (IL when approved)",
    },
]

_DEMO_BALANCES: dict[str, list[dict[str, Any]]] = {
    "leumi": [
        {"name": "עו\"ש שקלי", "account_type": "checking", "balance": 18420.50, "iban_masked": "IL** **** 0312"},
        {"name": "חיסכון", "account_type": "savings", "balance": 52000.00, "iban_masked": "IL** **** 8841"},
    ],
    "hapoalim": [
        {"name": "חשבון עו\"ש", "account_type": "checking", "balance": 9320.00, "iban_masked": "IL** **** 1102"},
    ],
    "discount": [
        {"name": "עו\"ש", "account_type": "checking", "balance": 4105.75, "iban_masked": "IL** **** 5560"},
    ],
    "mizrahi": [
        {"name": "חשבון שוטף", "account_type": "checking", "balance": 15780.20, "iban_masked": "IL** **** 7723"},
    ],
    "yahav": [
        {"name": "עו\"ש", "account_type": "checking", "balance": 6230.00, "iban_masked": "IL** **** 2290"},
    ],
    "fi": [
        {"name": "ארנק דיגיטלי", "account_type": "wallet", "balance": 890.40, "iban_masked": None},
    ],
    "max": [
        {"name": "כרטיס אשראי", "account_type": "credit", "balance": -2450.00, "iban_masked": None},
    ],
    "isracard": [
        {"name": "כרטיס אשראי", "account_type": "credit", "balance": -1180.00, "iban_masked": None},
    ],
}

_DEMO_TX: list[dict[str, Any]] = [
    {"title": "משכורת", "amount": 14500.0, "tx_type": "income", "category": "salary", "icon": "work"},
    {"title": "סופרמרקט", "amount": 312.40, "tx_type": "expense", "category": "groceries", "icon": "cart"},
    {"title": "דלק", "amount": 280.00, "tx_type": "expense", "category": "transport", "icon": "car"},
    {"title": "חשמל", "amount": 420.00, "tx_type": "expense", "category": "utilities", "icon": "home"},
    {"title": "העברה מפייבוקס", "amount": 150.00, "tx_type": "income", "category": "transfer", "icon": "payment"},
]


class BankService:
    def providers(self) -> dict[str, Any]:
        if settings.salt_edge_enabled:
            providers = list(SALTEDGE_TEST_BANKS)
            try:
                providers.extend(self._fetch_saltedge_il_providers())
            except Exception:
                logger.exception("Could not list Salt Edge IL providers")
            return {
                "country": "IL",
                "currency": "ILS",
                "mode": "saltedge",
                "providers": providers,
                "hint": (
                    "New Salt Edge accounts can only connect Fake Bank until "
                    "Test Access is approved for Israeli banks."
                ),
            }
        return {
            "country": "IL",
            "currency": "ILS",
            "mode": "demo",
            "providers": [
                {"code": b["code"], "name": b["name"], "name_en": b["name_en"]}
                for b in ISRAELI_BANKS
            ],
            "hint": "Configure SALT_EDGE_APP_ID and SALT_EDGE_SECRET for live Open Finance.",
        }

    def list_accounts(self, db: Session, user: User) -> list[dict[str, Any]]:
        rows = (
            db.query(BankAccount)
            .filter(BankAccount.user_id == user.id)
            .order_by(BankAccount.provider_name, BankAccount.name)
            .all()
        )
        return [self._account_to_dict(a) for a in rows]

    def list_connections(self, db: Session, user: User) -> list[dict[str, Any]]:
        rows = (
            db.query(BankConnection)
            .filter(BankConnection.user_id == user.id)
            .order_by(BankConnection.created_at.desc())
            .all()
        )
        return [self._connection_to_dict(c) for c in rows]

    def connect(
        self,
        db: Session,
        user: User,
        *,
        provider_code: str,
        budget_type: str = "home",
        return_url: str | None = None,
    ) -> dict[str, Any]:
        if budget_type not in {"home", "business"}:
            budget_type = "home"

        code = provider_code.strip().lower()

        if settings.salt_edge_enabled:
            bank = self._resolve_saltedge_bank(code)
            return self._start_saltedge_connect(
                db, user, bank=bank, budget_type=budget_type, return_url=return_url
            )

        bank = self._find_demo_bank(code)
        if not bank:
            raise ValueError("Unknown Israeli bank provider")

        existing = (
            db.query(BankConnection)
            .filter(
                BankConnection.user_id == user.id,
                BankConnection.provider_code == bank["code"],
                BankConnection.status == "active",
            )
            .first()
        )
        if existing:
            return {
                "status": "already_connected",
                "mode": existing.mode,
                "connection": self._connection_to_dict(existing),
                "accounts": [self._account_to_dict(a) for a in existing.accounts],
                "connect_url": None,
                "imported_transactions": 0,
            }
        return self._demo_connect(db, user, bank=bank, budget_type=budget_type)

    def sync_connection(self, db: Session, user: User, connection_id: str) -> dict[str, Any]:
        conn = (
            db.query(BankConnection)
            .filter(BankConnection.id == connection_id, BankConnection.user_id == user.id)
            .first()
        )
        if not conn:
            raise ValueError("Bank connection not found")

        if conn.mode == "saltedge" and settings.salt_edge_enabled:
            if not conn.external_connection_id:
                # Try to discover connection from Salt Edge by customer
                discovered = self._discover_external_connection(conn)
                if discovered:
                    conn.external_connection_id = discovered
                    db.commit()
            imported = self._sync_saltedge(db, user, conn)
        else:
            imported = self._sync_demo(db, user, conn)

        conn.last_synced_at = datetime.now(UTC)
        db.commit()
        db.refresh(conn)
        return {
            "connection": self._connection_to_dict(conn),
            "accounts": [self._account_to_dict(a) for a in conn.accounts],
            "imported_transactions": imported,
        }

    def disconnect(self, db: Session, user: User, connection_id: str) -> None:
        conn = (
            db.query(BankConnection)
            .filter(BankConnection.id == connection_id, BankConnection.user_id == user.id)
            .first()
        )
        if not conn:
            raise ValueError("Bank connection not found")
        db.delete(conn)
        db.commit()

    def complete_saltedge_callback(
        self,
        db: Session,
        user: User | None,
        *,
        connection_id: str | None,
        external_connection_id: str,
        custom_fields: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        custom_fields = custom_fields or {}
        daos_id = connection_id or custom_fields.get("daos_connection_id")
        query = db.query(BankConnection).filter(
            BankConnection.external_connection_id == external_connection_id
        )
        conn = None
        if daos_id:
            conn = db.query(BankConnection).filter(BankConnection.id == str(daos_id)).first()
        if not conn:
            conn = query.first()
        if not conn and user is not None:
            conn = (
                db.query(BankConnection)
                .filter(
                    BankConnection.user_id == user.id,
                    BankConnection.mode == "saltedge",
                    BankConnection.status.in_(["pending", "active", "error"]),
                )
                .order_by(BankConnection.created_at.desc())
                .first()
            )
        if not conn:
            raise ValueError("Bank connection not found for Salt Edge callback")

        if user is not None and conn.user_id != user.id:
            raise ValueError("Bank connection does not belong to user")

        conn.external_connection_id = str(external_connection_id)
        conn.status = "active"
        db.commit()
        owner = user or db.query(User).filter(User.id == conn.user_id).first()
        if not owner:
            raise ValueError("User not found for bank connection")
        return self.sync_connection(db, owner, conn.id)

    def handle_saltedge_webhook(self, db: Session, payload: dict[str, Any]) -> dict[str, Any]:
        data = payload.get("data") or payload
        external_id = data.get("connection_id")
        if not external_id:
            raise ValueError("Missing connection_id in Salt Edge webhook")
        custom = data.get("custom_fields") or {}
        return self.complete_saltedge_callback(
            db,
            None,
            connection_id=custom.get("daos_connection_id"),
            external_connection_id=str(external_id),
            custom_fields=custom,
        )

    def _resolve_saltedge_bank(self, code: str) -> dict[str, str]:
        for b in SALTEDGE_TEST_BANKS:
            if b["code"] == code:
                return b
        for b in self._fetch_saltedge_il_providers():
            if b["code"] == code:
                return b
        # Allow raw Salt Edge provider codes (e.g. after Test Access)
        return {
            "code": code if code != "saltedge_pick" else "saltedge_pick",
            "name": code,
            "name_en": code,
        }

    def _fetch_saltedge_il_providers(self) -> list[dict[str, str]]:
        if not settings.salt_edge_enabled:
            return []
        data = self._saltedge_get(
            "/providers",
            params={"country_code": "IL", "include_sandboxes": "true"},
        )
        out: list[dict[str, str]] = []
        for item in data.get("data", []):
            code = str(item.get("code") or "")
            if not code:
                continue
            out.append(
                {
                    "code": code,
                    "name": str(item.get("name") or code),
                    "name_en": str(item.get("name") or code),
                }
            )
        return out[:40]

    def _demo_connect(
        self, db: Session, user: User, *, bank: dict[str, str], budget_type: str
    ) -> dict[str, Any]:
        now = datetime.now(UTC)
        conn = BankConnection(
            id=new_id(),
            user_id=user.id,
            provider_code=bank["code"],
            provider_name=bank["name"],
            status="active",
            mode="demo",
            consent_expires_at=now + timedelta(days=180),
            last_synced_at=now,
        )
        db.add(conn)
        db.flush()

        accounts: list[BankAccount] = []
        for sample in _DEMO_BALANCES.get(bank["code"], _DEMO_BALANCES["leumi"]):
            acc = BankAccount(
                id=new_id(),
                user_id=user.id,
                connection_id=conn.id,
                provider_code=bank["code"],
                provider_name=bank["name"],
                name=sample["name"],
                account_type=sample["account_type"],
                currency="ILS",
                balance=float(sample["balance"]),
                iban_masked=sample.get("iban_masked"),
                external_account_id=f"demo-{bank['code']}-{new_id()[:8]}",
                budget_type=budget_type,
            )
            db.add(acc)
            accounts.append(acc)

        db.commit()
        for acc in accounts:
            db.refresh(acc)
        db.refresh(conn)

        imported = self._sync_demo(db, user, conn)
        return {
            "status": "connected",
            "mode": "demo",
            "connection": self._connection_to_dict(conn),
            "accounts": [self._account_to_dict(a) for a in accounts],
            "imported_transactions": imported,
            "connect_url": None,
        }

    def _sync_demo(self, db: Session, user: User, conn: BankConnection) -> int:
        checking = next(
            (a for a in conn.accounts if a.account_type in {"checking", "wallet", "savings"}),
            conn.accounts[0] if conn.accounts else None,
        )
        if not checking:
            return 0

        budget = BudgetService()
        imported = 0
        for i, sample in enumerate(_DEMO_TX):
            external_id = f"demo-{conn.id}-{i}"
            exists = (
                db.query(FinanceTransaction)
                .filter(
                    FinanceTransaction.user_id == user.id,
                    FinanceTransaction.external_id == external_id,
                )
                .first()
            )
            if exists:
                continue
            budget.create_transaction(
                db,
                user,
                budget_type=checking.budget_type,
                title=f"{sample['title']} ({conn.provider_name})",
                amount=float(sample["amount"]),
                tx_type=sample["tx_type"],
                category=sample["category"],
                icon=sample["icon"],
                occurred_at=datetime.now(UTC) - timedelta(days=i + 1),
                bank_account_id=checking.id,
                external_id=external_id,
            )
            imported += 1
        return imported

    def _start_saltedge_connect(
        self,
        db: Session,
        user: User,
        *,
        bank: dict[str, str],
        budget_type: str,
        return_url: str | None,
    ) -> dict[str, Any]:
        customer_id = self._ensure_saltedge_customer(user)
        conn = BankConnection(
            id=new_id(),
            user_id=user.id,
            provider_code=bank["code"],
            provider_name=bank["name"],
            status="pending",
            mode="saltedge",
            external_customer_id=str(customer_id),
            consent_expires_at=datetime.now(UTC) + timedelta(days=180),
        )
        db.add(conn)
        db.commit()
        db.refresh(conn)

        callback = self._safe_return_url(return_url or settings.salt_edge_return_url)
        sep = "&" if "?" in callback else "?"
        return_to = f"{callback}{sep}daos_connection_id={conn.id}"

        data_payload: dict[str, Any] = {
            "customer_id": customer_id,
            "consent": {
                "scopes": ["accounts", "transactions"],
                "from_date": (datetime.now(UTC) - timedelta(days=90)).date().isoformat(),
            },
            "attempt": {
                "fetch_scopes": ["accounts", "transactions"],
                "return_to": return_to,
                "locale": "he",
                "custom_fields": {
                    "daos_connection_id": conn.id,
                    "budget_type": budget_type,
                    "provider_code": bank["code"],
                },
            },
            "widget": {
                "allowed_countries": ["XF", "IL"],
                "popular_providers_country": "IL",
            },
            "provider": {"include_sandboxes": True},
            "return_connection_id": True,
            "return_error_class": True,
        }
        if bank["code"] not in {"saltedge_pick", ""}:
            data_payload["provider"]["code"] = bank["code"]
            if bank["code"].startswith("fake") or bank["code"].endswith("_xf"):
                data_payload["widget"]["popular_providers_country"] = "XF"
                data_payload["widget"]["allowed_countries"] = ["XF"]

        try:
            data = self._saltedge_post("/connections/connect", {"data": data_payload})
            connect_url = data.get("data", {}).get("connect_url")
        except Exception as exc:
            logger.exception("Salt Edge connect session failed")
            conn.status = "error"
            db.commit()
            raise ValueError(f"Salt Edge connect failed: {exc}") from exc

        return {
            "status": "pending",
            "mode": "saltedge",
            "connection": self._connection_to_dict(conn),
            "accounts": [],
            "connect_url": connect_url,
            "imported_transactions": 0,
        }

    def _discover_external_connection(self, conn: BankConnection) -> str | None:
        if not conn.external_customer_id:
            return None
        try:
            data = self._saltedge_get(
                "/connections",
                params={"customer_id": conn.external_customer_id},
            )
        except Exception:
            logger.exception("Failed to list Salt Edge connections")
            return None
        rows = data.get("data") or []
        if not rows:
            return None
        rows = sorted(
            rows,
            key=lambda r: r.get("updated_at") or r.get("created_at") or "",
            reverse=True,
        )
        for row in rows:
            rid = row.get("id") or row.get("connection_id")
            if rid:
                return str(rid)
        return None

    def _sync_saltedge(self, db: Session, user: User, conn: BankConnection) -> int:
        if not conn.external_connection_id:
            raise ValueError(
                "Salt Edge connection not completed yet — finish the bank login, then tap Sync"
            )

        accounts_data = self._saltedge_get(
            "/accounts", params={"connection_id": conn.external_connection_id}
        )
        budget = BudgetService()
        imported = 0
        existing_by_ext = {
            a.external_account_id: a for a in conn.accounts if a.external_account_id
        }

        for item in accounts_data.get("data", []):
            ext_id = str(item.get("id") or item.get("account_id"))
            balance = float(item.get("balance") or 0)
            name = item.get("name") or item.get("extra", {}).get("account_name") or "חשבון"
            acc = existing_by_ext.get(ext_id)
            if not acc:
                acc = BankAccount(
                    id=new_id(),
                    user_id=user.id,
                    connection_id=conn.id,
                    provider_code=conn.provider_code,
                    provider_name=conn.provider_name,
                    name=name,
                    account_type=str(item.get("nature") or "checking"),
                    currency=str(item.get("currency_code") or "ILS"),
                    balance=balance,
                    iban_masked=self._mask_iban((item.get("extra") or {}).get("iban")),
                    external_account_id=ext_id,
                    budget_type="home",
                )
                db.add(acc)
                db.flush()
            else:
                acc.balance = balance
                acc.name = name

            tx_data = self._saltedge_get("/transactions", params={"account_id": ext_id})
            for tx in tx_data.get("data", []):
                ext_tx = str(tx.get("id") or tx.get("transaction_id"))
                exists = (
                    db.query(FinanceTransaction)
                    .filter(
                        FinanceTransaction.user_id == user.id,
                        FinanceTransaction.external_id == ext_tx,
                    )
                    .first()
                )
                if exists:
                    continue
                raw_amount = float(tx.get("amount") or 0)
                amount = abs(raw_amount)
                if amount <= 0:
                    continue
                made_on = tx.get("made_on")
                occurred = (
                    datetime.fromisoformat(f"{made_on}T12:00:00+00:00")
                    if made_on
                    else datetime.now(UTC)
                )
                tx_type = (
                    TransactionType.income.value if raw_amount >= 0 else TransactionType.expense.value
                )
                budget.create_transaction(
                    db,
                    user,
                    budget_type=acc.budget_type,
                    title=str(tx.get("description") or "תנועה בנקאית")[:255],
                    amount=amount,
                    tx_type=tx_type,
                    category="bank",
                    icon="account_balance",
                    occurred_at=occurred,
                    bank_account_id=acc.id,
                    external_id=ext_tx,
                )
                imported += 1

        conn.status = "active"
        db.commit()
        return imported

    def _ensure_saltedge_customer(self, user: User) -> str:
        identifier = f"daos-{user.id}"
        payload = {"data": {"identifier": identifier}}
        try:
            data = self._saltedge_post("/customers", payload)
            row = data.get("data") or {}
            return str(row.get("customer_id") or row.get("id"))
        except httpx.HTTPStatusError as exc:
            if exc.response is not None and exc.response.status_code in {400, 409, 422}:
                listed = self._saltedge_get("/customers")
                for item in listed.get("data", []):
                    if item.get("identifier") == identifier:
                        return str(item.get("customer_id") or item.get("id"))
            raise
        except Exception:
            listed = self._saltedge_get("/customers")
            for item in listed.get("data", []):
                if item.get("identifier") == identifier:
                    return str(item.get("customer_id") or item.get("id"))
            raise

    def _api_path(self, path: str) -> str:
        prefix = settings.salt_edge_api_prefix.rstrip("/") or "/api/v6"
        if not path.startswith("/"):
            path = f"/{path}"
        return f"{prefix}{path}"

    @staticmethod
    def _safe_return_url(url: str) -> str:
        # Salt Edge edge WAF returns HTML 403 for return_to with 127.0.0.1
        return url.replace("127.0.0.1", "localhost").strip() or "http://localhost:5173/"

    def _saltedge_headers(self) -> dict[str, str]:
        return {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "App-id": settings.salt_edge_app_id.strip(),
            "Secret": settings.salt_edge_secret.strip(),
        }

    def _saltedge_post(self, path: str, payload: dict[str, Any]) -> dict[str, Any]:
        url = f"{settings.salt_edge_api_url.rstrip('/')}{self._api_path(path)}"
        with httpx.Client(timeout=45.0) as client:
            resp = client.post(url, json=payload, headers=self._saltedge_headers())
            if resp.status_code >= 400:
                logger.error("Salt Edge POST %s failed: %s", path, resp.text[:500])
            resp.raise_for_status()
            return resp.json()

    def _saltedge_get(self, path: str, params: dict[str, Any] | None = None) -> dict[str, Any]:
        url = f"{settings.salt_edge_api_url.rstrip('/')}{self._api_path(path)}"
        with httpx.Client(timeout=45.0) as client:
            resp = client.get(url, params=params, headers=self._saltedge_headers())
            if resp.status_code >= 400:
                logger.error("Salt Edge GET %s failed: %s", path, resp.text[:500])
            resp.raise_for_status()
            return resp.json()

    @staticmethod
    def _find_demo_bank(code: str) -> dict[str, str] | None:
        for bank in ISRAELI_BANKS:
            if bank["code"] == code:
                return bank
        return None

    @staticmethod
    def _mask_iban(iban: str | None) -> str | None:
        if not iban or len(iban) < 8:
            return iban
        return f"{iban[:4]} **** {iban[-4:]}"

    @staticmethod
    def _account_to_dict(acc: BankAccount) -> dict[str, Any]:
        return {
            "id": acc.id,
            "connection_id": acc.connection_id,
            "provider_code": acc.provider_code,
            "provider_name": acc.provider_name,
            "name": acc.name,
            "account_type": acc.account_type,
            "currency": acc.currency,
            "balance": acc.balance,
            "iban_masked": acc.iban_masked,
            "budget_type": acc.budget_type,
        }

    @staticmethod
    def _connection_to_dict(conn: BankConnection) -> dict[str, Any]:
        return {
            "id": conn.id,
            "provider_code": conn.provider_code,
            "provider_name": conn.provider_name,
            "status": conn.status,
            "mode": conn.mode,
            "consent_expires_at": conn.consent_expires_at.isoformat() if conn.consent_expires_at else None,
            "last_synced_at": conn.last_synced_at.isoformat() if conn.last_synced_at else None,
            "account_count": len(conn.accounts) if conn.accounts is not None else 0,
        }
