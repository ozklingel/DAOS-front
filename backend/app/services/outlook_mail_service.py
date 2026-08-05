import httpx

from app.config import settings


class OutlookMailService:
    TOKEN_URL = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
    GRAPH_ME_URL = "https://graph.microsoft.com/v1.0/me"
    GRAPH_INBOX_URL = "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messages"

    async def refresh_access_token(self, refresh_token: str) -> tuple[str, str | None]:
        client_id = (settings.microsoft_client_id or "").strip()
        if not client_id or client_id in {"your-azure-app-client-id", "YOUR_OUTLOOK_CLIENT_ID"}:
            raise ValueError("Microsoft OAuth is not configured on the server")

        payload = {
            "client_id": client_id,
            "grant_type": "refresh_token",
            "refresh_token": refresh_token,
            "scope": "openid profile email offline_access User.Read Mail.Read",
        }
        if settings.microsoft_client_secret:
            payload["client_secret"] = settings.microsoft_client_secret

        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.post(self.TOKEN_URL, data=payload)

        if response.status_code != 200:
            detail = response.text[:300]
            raise ValueError(f"Failed to refresh Outlook token: {detail}")

        data = response.json()
        access_token = data.get("access_token")
        if not access_token:
            raise ValueError("Outlook token refresh did not return an access token")
        return access_token, data.get("refresh_token")

    async def get_mailbox_email(self, access_token: str) -> str:
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.get(
                self.GRAPH_ME_URL,
                headers={"Authorization": f"Bearer {access_token}"},
            )
        if response.status_code != 200:
            detail = response.text[:200]
            raise ValueError(f"Could not read Outlook profile: {detail}")
        data = response.json()
        return data.get("mail") or data.get("userPrincipalName") or ""

    async def fetch_inbox_messages(
        self,
        access_token: str,
        *,
        max_results: int = 25,
    ) -> list[dict]:
        params = {
            "$top": max_results,
            "$select": "id,subject,from,bodyPreview,receivedDateTime",
            "$orderby": "receivedDateTime desc",
        }

        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.get(
                self.GRAPH_INBOX_URL,
                headers={"Authorization": f"Bearer {access_token}"},
                params=params,
            )

        if response.status_code != 200:
            detail = response.text[:300]
            raise ValueError(f"Failed to fetch Outlook inbox: {detail}")

        emails: list[dict] = []
        for message in response.json().get("value", []):
            from_data = message.get("from", {}).get("emailAddress", {})
            sender_name = from_data.get("name")
            sender_email = from_data.get("address")
            sender_display = (
                f"{sender_name} <{sender_email}>"
                if sender_name and sender_email
                else sender_email or sender_name or "Unknown"
            )

            emails.append(
                {
                    "message_id": f"outlook-{message['id']}",
                    "subject": message.get("subject") or "(No subject)",
                    "sender": sender_display,
                    "sender_name": sender_name,
                    "sender_email": sender_email,
                    "snippet": message.get("bodyPreview", ""),
                    "received_at": message.get("receivedDateTime"),
                }
            )
        return emails

    async def fetch_recent_emails(
        self,
        refresh_token: str,
        max_results: int = 25,
    ) -> tuple[list[dict], str | None]:
        access_token, new_refresh = await self.refresh_access_token(refresh_token)
        emails = await self.fetch_inbox_messages(access_token, max_results=max_results)
        return emails, new_refresh

    async def fetch_inbox_preview(
        self,
        refresh_token: str,
        *,
        max_results: int = 10,
    ) -> dict:
        access_token, new_refresh = await self.refresh_access_token(refresh_token)
        mailbox_email = await self.get_mailbox_email(access_token)
        emails = await self.fetch_inbox_messages(access_token, max_results=max_results)
        return {
            "mailbox_email": mailbox_email,
            "inbox_count": len(emails),
            "latest_inbox": emails[0] if emails else None,
            "messages": emails,
            "new_refresh_token": new_refresh,
        }
