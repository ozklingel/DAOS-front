from datetime import UTC, datetime, timedelta

from google.auth.transport import requests as google_requests
from google.oauth2 import id_token
from sqlalchemy.orm import Session

from app.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token_value,
    hash_token,
    new_id,
)
from app.models import RefreshToken, User, UserSettings
from app.services.google_oauth_service import GoogleOAuthService


class AuthService:
    def __init__(self) -> None:
        self.google_oauth = GoogleOAuthService()

    def verify_google_id_token(self, token: str) -> dict:
        client_ids = settings.google_client_id_list
        if not client_ids:
            raise ValueError("Google OAuth is not configured on the server")

        last_exc: Exception | None = None
        for client_id in client_ids:
            try:
                return id_token.verify_oauth2_token(
                    token, google_requests.Request(), client_id
                )
            except Exception as exc:
                last_exc = exc

        raise ValueError("Invalid Google ID token") from last_exc

    async def verify_outlook_access_token(self, access_token: str) -> dict:
        import httpx

        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.get(
                "https://graph.microsoft.com/v1.0/me",
                headers={"Authorization": f"Bearer {access_token}"},
            )
        if response.status_code != 200:
            raise ValueError("Invalid Outlook access token")
        data = response.json()
        return {
            "email": data.get("mail") or data.get("userPrincipalName"),
            "name": data.get("displayName"),
            "sub": data.get("id"),
        }

    def _get_or_create_user(
        self,
        db: Session,
        *,
        email: str,
        name: str | None,
        avatar_url: str | None,
        gmail_connected: bool = False,
        outlook_connected: bool = False,
    ) -> User:
        user = db.query(User).filter(User.email == email).one_or_none()
        if user:
            user.name = name or user.name
            user.avatar_url = avatar_url or user.avatar_url
            if gmail_connected:
                user.gmail_connected = True
            if outlook_connected:
                user.outlook_connected = True
        else:
            user = User(
                id=new_id(),
                email=email,
                name=name,
                avatar_url=avatar_url,
                gmail_connected=gmail_connected,
                outlook_connected=outlook_connected,
            )
            db.add(user)
            db.flush()
            db.add(UserSettings(user_id=user.id))
        return user

    def issue_tokens(self, db: Session, user: User) -> tuple[str, str]:
        access = create_access_token(user.id)
        refresh_value = create_refresh_token_value()
        refresh = RefreshToken(
            id=new_id(),
            user_id=user.id,
            token_hash=hash_token(refresh_value),
            expires_at=datetime.now(UTC) + timedelta(days=settings.refresh_token_expire_days),
        )
        db.add(refresh)
        db.commit()
        db.refresh(user)
        return access, refresh_value

    async def _store_google_refresh_token(
        self, user: User, server_auth_code: str | None
    ) -> None:
        if not server_auth_code:
            return
        tokens = await self.google_oauth.exchange_server_auth_code(server_auth_code)
        refresh_token = tokens.get("refresh_token")
        if refresh_token:
            user.google_refresh_token = refresh_token
            user.gmail_connected = True

    async def sign_in_google(
        self, db: Session, id_token_str: str, server_auth_code: str | None = None
    ) -> tuple[User, str, str]:
        info = self.verify_google_id_token(id_token_str)
        email = info.get("email")
        if not email:
            raise ValueError("Google account has no email")

        user = self._get_or_create_user(
            db,
            email=email,
            name=info.get("name"),
            avatar_url=info.get("picture"),
        )

        try:
            await self._store_google_refresh_token(user, server_auth_code)
        except ValueError:
            pass

        user.gmail_connected = bool(user.google_refresh_token)
        db.commit()
        db.refresh(user)
        return user, *self.issue_tokens(db, user)

    async def sign_in_outlook(
        self,
        db: Session,
        access_token: str,
        outlook_refresh_token: str | None = None,
    ) -> tuple[User, str, str]:
        info = await self.verify_outlook_access_token(access_token)
        email = info.get("email")
        if not email:
            raise ValueError("Outlook account has no email")

        user = self._get_or_create_user(
            db,
            email=email,
            name=info.get("name"),
            avatar_url=None,
        )

        if outlook_refresh_token:
            user.outlook_refresh_token = outlook_refresh_token
            user.outlook_connected = True
        elif not user.outlook_refresh_token:
            user.outlook_connected = False

        db.commit()
        db.refresh(user)
        return user, *self.issue_tokens(db, user)

    async def connect_google_mailbox(
        self,
        db: Session,
        user: User,
        id_token_str: str,
        server_auth_code: str | None,
    ) -> User:
        info = self.verify_google_id_token(id_token_str)
        email = info.get("email")
        if not email:
            raise ValueError("Google account has no email")
        if email.lower() != user.email.lower():
            raise ValueError("Google account email does not match your TaskMail account")

        await self._store_google_refresh_token(user, server_auth_code)
        if not user.google_refresh_token:
            raise ValueError("Gmail access was not granted. Please try again.")

        user.gmail_connected = True
        db.commit()
        db.refresh(user)
        return user

    async def connect_outlook_mailbox(
        self,
        db: Session,
        user: User,
        access_token: str,
        outlook_refresh_token: str | None,
    ) -> User:
        info = await self.verify_outlook_access_token(access_token)
        email = info.get("email")
        if not email:
            raise ValueError("Outlook account has no email")
        if email.lower() != user.email.lower():
            raise ValueError("Outlook account email does not match your TaskMail account")

        if not outlook_refresh_token:
            raise ValueError("Outlook refresh token is required for email sync")

        user.outlook_refresh_token = outlook_refresh_token
        user.outlook_connected = True
        db.commit()
        db.refresh(user)
        return user

    def disconnect_gmail(self, db: Session, user: User) -> User:
        user.gmail_connected = False
        user.google_refresh_token = None
        db.commit()
        db.refresh(user)
        return user

    def disconnect_outlook(self, db: Session, user: User) -> User:
        user.outlook_connected = False
        user.outlook_refresh_token = None
        db.commit()
        db.refresh(user)
        return user

    def refresh(self, db: Session, refresh_token: str) -> tuple[str, str]:
        token_hash = hash_token(refresh_token)
        stored = (
            db.query(RefreshToken)
            .filter(RefreshToken.token_hash == token_hash, RefreshToken.revoked.is_(False))
            .one_or_none()
        )
        if not stored or stored.expires_at < datetime.now(UTC):
            raise ValueError("Invalid or expired refresh token")

        stored.revoked = True
        user = db.get(User, stored.user_id)
        if not user:
            raise ValueError("User not found")
        return self.issue_tokens(db, user)

    def logout(self, db: Session, user: User) -> None:
        db.query(RefreshToken).filter(
            RefreshToken.user_id == user.id, RefreshToken.revoked.is_(False)
        ).update({"revoked": True})
        db.commit()

    def sign_in_dev(self, db: Session, email: str = "dev@taskmail.local") -> tuple[User, str, str]:
        user = self._get_or_create_user(
            db,
            email=email,
            name="Dev User",
            avatar_url=None,
            gmail_connected=False,
        )
        return user, *self.issue_tokens(db, user)
