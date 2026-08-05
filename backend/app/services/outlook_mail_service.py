import httpx

from app.config import settings


class OutlookMailService:
    TOKEN_URL = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
    GRAPH_ME_URL = "https://graph.microsoft.com/v1.0/me"
    GRAPH_FOLDER_URL = "https://graph.microsoft.com/v1.0/me/mailFolders/{folder}/messages"

    _FOLDERS = ("inbox", "sentitems", "junkemail")

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

    async def _fetch_folder_messages(
        self,
        access_token: str,
        folder: str,
        *,
        max_results: int,
    ) -> list[dict]:
        params = {
            "$top": max_results,
            "$select": "id,subject,from,bodyPreview,receivedDateTime",
            "$orderby": "receivedDateTime desc",
        }
        url = self.GRAPH_FOLDER_URL.format(folder=folder)

        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.get(
                url,
                headers={"Authorization": f"Bearer {access_token}"},
                params=params,
            )

        if response.status_code != 200:
            detail = response.text[:300]
            raise ValueError(f"Failed to fetch Outlook {folder}: {detail}")

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
                    "graph_id": message["id"],
                    "folder": folder,
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
        """Fetch recent mail from inbox + sent (self-sent tests often land in Sent Items)."""
        access_token, new_refresh = await self.refresh_access_token(refresh_token)

        per_folder = max(10, max_results // 2)
        merged: dict[str, dict] = {}
        for folder in ("inbox", "sentitems"):
            for email in await self._fetch_folder_messages(
                access_token, folder, max_results=per_folder
            ):
                merged[email["graph_id"]] = email

        emails = sorted(
            merged.values(),
            key=lambda item: item.get("received_at") or "",
            reverse=True,
        )[:max_results]
        return emails, new_refresh

    async def fetch_mailbox_snapshot(
        self,
        refresh_token: str,
        *,
        per_folder: int = 10,
    ) -> dict:
        access_token, new_refresh = await self.refresh_access_token(refresh_token)
        mailbox_email = await self.get_mailbox_email(access_token)

        folder_counts: dict[str, int] = {}
        merged: dict[str, dict] = {}
        for folder in self._FOLDERS:
            emails = await self._fetch_folder_messages(
                access_token, folder, max_results=per_folder
            )
            folder_counts[folder] = len(emails)
            for email in emails:
                merged[email["graph_id"]] = email

        messages = sorted(
            merged.values(),
            key=lambda item: item.get("received_at") or "",
            reverse=True,
        )
        return {
            "mailbox_email": mailbox_email,
            "inbox_count": folder_counts.get("inbox", 0),
            "sent_count": folder_counts.get("sentitems", 0),
            "junk_count": folder_counts.get("junkemail", 0),
            "messages": messages,
            "new_refresh_token": new_refresh,
        }
