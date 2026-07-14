import httpx

from app.config import settings


class OutlookMailService:
    TOKEN_URL = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
    GRAPH_MESSAGES_URL = "https://graph.microsoft.com/v1.0/me/messages"

    async def _get_access_token(self, refresh_token: str) -> str:
        if not settings.microsoft_client_id:
            raise ValueError("Microsoft OAuth is not configured on the server")

        payload = {
            "client_id": settings.microsoft_client_id,
            "grant_type": "refresh_token",
            "refresh_token": refresh_token,
            "scope": "Mail.Read offline_access openid profile email",
        }
        if settings.microsoft_client_secret:
            payload["client_secret"] = settings.microsoft_client_secret

        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.post(self.TOKEN_URL, data=payload)

        if response.status_code != 200:
            detail = response.text[:200]
            raise ValueError(f"Failed to refresh Outlook token: {detail}")

        data = response.json()
        access_token = data.get("access_token")
        if not access_token:
            raise ValueError("Outlook token refresh did not return an access token")
        return access_token

    async def fetch_recent_emails(self, refresh_token: str, max_results: int = 25) -> list[dict]:
        access_token = await self._get_access_token(refresh_token)

        params = {
            "$top": max_results,
            "$select": "id,subject,from,bodyPreview,receivedDateTime",
            "$orderby": "receivedDateTime desc",
        }

        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.get(
                self.GRAPH_MESSAGES_URL,
                headers={"Authorization": f"Bearer {access_token}"},
                params=params,
            )

        if response.status_code != 200:
            detail = response.text[:200]
            raise ValueError(f"Failed to fetch Outlook messages: {detail}")

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
                }
            )

        return emails
