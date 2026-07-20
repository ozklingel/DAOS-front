from email.utils import parseaddr

from google.auth.transport.requests import Request as GoogleRequest
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

from app.config import settings


class GmailService:
    def fetch_recent_emails(
        self,
        *,
        refresh_token: str | None = None,
        access_token: str | None = None,
        max_results: int = 25,
    ) -> list[dict]:
        if not settings.google_client_id or not settings.google_client_secret:
            raise ValueError("Google OAuth is not configured on the server")
        if settings.google_client_id.startswith("your-") or settings.google_client_secret.startswith(
            "your-"
        ):
            raise ValueError("Google OAuth is not configured on the server")

        credentials = self._build_credentials(
            refresh_token=refresh_token,
            access_token=access_token,
        )

        service = build("gmail", "v1", credentials=credentials, cache_discovery=False)
        list_response = (
            service.users()
            .messages()
            .list(
                userId="me",
                maxResults=max_results,
                q="newer_than:14d",
            )
            .execute()
        )

        messages = list_response.get("messages", [])
        emails: list[dict] = []

        for item in messages:
            msg_id = item["id"]
            msg = (
                service.users()
                .messages()
                .get(
                    userId="me",
                    id=msg_id,
                    format="metadata",
                    metadataHeaders=["From", "Subject"],
                )
                .execute()
            )

            headers = {h["name"].lower(): h["value"] for h in msg.get("payload", {}).get("headers", [])}
            from_header = headers.get("from", "")
            sender_name, sender_email = parseaddr(from_header)
            sender_display = from_header or sender_email or "Unknown"

            emails.append(
                {
                    "message_id": f"gmail-{msg_id}",
                    "subject": headers.get("subject") or "(No subject)",
                    "sender": sender_display,
                    "sender_name": sender_name or None,
                    "sender_email": sender_email or None,
                    "snippet": msg.get("snippet", ""),
                }
            )

        return emails

    def _build_credentials(
        self,
        *,
        refresh_token: str | None,
        access_token: str | None,
    ) -> Credentials:
        """Prefer refresh_token so expired access tokens can be renewed."""
        if refresh_token:
            credentials = Credentials(
                token=access_token,
                refresh_token=refresh_token,
                token_uri="https://oauth2.googleapis.com/token",
                client_id=settings.google_client_id,
                client_secret=settings.google_client_secret,
            )
            if not credentials.valid:
                credentials.refresh(GoogleRequest())
            return credentials

        if access_token:
            # Short-lived only — cannot refresh; used until Google returns 401.
            return Credentials(
                token=access_token,
                token_uri="https://oauth2.googleapis.com/token",
                client_id=settings.google_client_id,
                client_secret=settings.google_client_secret,
            )

        raise ValueError("Gmail credentials are missing")
