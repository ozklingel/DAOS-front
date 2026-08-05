import httpx

from app.config import settings


class OutlookMailService:
    TOKEN_URL = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
    GRAPH_ME_URL = "https://graph.microsoft.com/v1.0/me"
    GRAPH_INBOX_URL = "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messages"
    GRAPH_INBOX_META_URL = "https://graph.microsoft.com/v1.0/me/mailFolders/inbox"

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

    async def get_mailbox_profile(self, access_token: str) -> dict:
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.get(
                self.GRAPH_ME_URL,
                headers={"Authorization": f"Bearer {access_token}"},
            )
        if response.status_code != 200:
            detail = response.text[:200]
            raise ValueError(f"Could not read Outlook profile: {detail}")
        data = response.json()
        return {
            "email": data.get("mail") or data.get("userPrincipalName") or "",
            "display_name": data.get("displayName") or "",
            "user_principal_name": data.get("userPrincipalName") or "",
        }

    async def get_mailbox_email(self, access_token: str) -> str:
        profile = await self.get_mailbox_profile(access_token)
        return profile["email"]

    async def get_inbox_stats(self, access_token: str) -> dict:
        params = {"$select": "displayName,totalItemCount,unreadItemCount"}
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.get(
                self.GRAPH_INBOX_META_URL,
                headers={"Authorization": f"Bearer {access_token}"},
                params=params,
            )
        if response.status_code == 403:
            return {
                "mail_read_granted": False,
                "total_item_count": 0,
                "unread_item_count": 0,
                "error": "Mail.Read permission missing — reconnect Outlook and accept mail access.",
            }
        if response.status_code != 200:
            detail = response.text[:200]
            raise ValueError(f"Could not read Outlook inbox stats: {detail}")
        data = response.json()
        return {
            "mail_read_granted": True,
            "total_item_count": int(data.get("totalItemCount") or 0),
            "unread_item_count": int(data.get("unreadItemCount") or 0),
            "display_name": data.get("displayName") or "Inbox",
        }

    @staticmethod
    def _parse_messages(raw_messages: list[dict]) -> list[dict]:
        emails: list[dict] = []
        for message in raw_messages:
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

    @staticmethod
    def _sort_newest_first(emails: list[dict]) -> list[dict]:
        return sorted(emails, key=lambda item: item.get("received_at") or "", reverse=True)

    async def _get_json(
        self,
        access_token: str,
        url: str,
        *,
        params: dict | None = None,
        error_label: str = "Outlook request",
    ) -> dict:
        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.get(
                url,
                headers={"Authorization": f"Bearer {access_token}"},
                params=params or {},
            )
        if response.status_code != 200:
            detail = response.text[:300]
            raise ValueError(f"{error_label} failed: {detail}")
        return response.json()

    async def fetch_inbox_messages(
        self,
        access_token: str,
        *,
        max_results: int = 25,
    ) -> tuple[list[dict], str]:
        """Return inbox messages newest-first.

        Do NOT pass $orderby to Graph — on some Outlook accounts it returns value=[]
        even when the inbox is full (known Graph quirk). Sort locally instead.
        """
        params = {
            "$top": max(max_results, 25),
            "$select": "id,subject,from,bodyPreview,receivedDateTime",
        }
        payload = await self._get_json(
            access_token,
            self.GRAPH_INBOX_URL,
            params=params,
            error_label="Fetch Outlook inbox",
        )
        emails = self._sort_newest_first(self._parse_messages(payload.get("value", [])))
        if emails:
            return emails[:max_results], "inbox_no_orderby"

        # Fallback: resolve inbox folder id explicitly (rare locale / folder edge cases).
        folders = await self._get_json(
            access_token,
            "https://graph.microsoft.com/v1.0/me/mailFolders",
            params={
                "$filter": "wellKnownName eq 'inbox'",
                "$select": "id,displayName,totalItemCount",
                "$top": 1,
            },
            error_label="Resolve Outlook inbox folder",
        )
        folder = (folders.get("value") or [None])[0]
        if folder and folder.get("id"):
            folder_url = (
                f"https://graph.microsoft.com/v1.0/me/mailFolders/{folder['id']}/messages"
            )
            payload = await self._get_json(
                access_token,
                folder_url,
                params=params,
                error_label="Fetch Outlook inbox by folder id",
            )
            emails = self._sort_newest_first(self._parse_messages(payload.get("value", [])))
            if emails:
                return emails[:max_results], "inbox_folder_id"

        return [], "empty"

    async def fetch_recent_emails(
        self,
        refresh_token: str,
        max_results: int = 25,
    ) -> tuple[list[dict], str | None]:
        access_token, new_refresh = await self.refresh_access_token(refresh_token)
        emails, _source = await self.fetch_inbox_messages(access_token, max_results=max_results)
        return emails, new_refresh

    async def fetch_inbox_preview(
        self,
        refresh_token: str,
        *,
        max_results: int = 10,
    ) -> dict:
        access_token, new_refresh = await self.refresh_access_token(refresh_token)
        profile = await self.get_mailbox_profile(access_token)
        inbox_stats = await self.get_inbox_stats(access_token)
        emails, fetch_source = await self.fetch_inbox_messages(
            access_token, max_results=max_results
        )
        return {
            "mailbox_email": profile["email"],
            "mailbox_upn": profile["user_principal_name"],
            "mailbox_display_name": profile["display_name"],
            "mail_read_granted": inbox_stats.get("mail_read_granted", False),
            "inbox_total_items": inbox_stats.get("total_item_count", 0),
            "inbox_unread_items": inbox_stats.get("unread_item_count", 0),
            "inbox_stats_error": inbox_stats.get("error"),
            "inbox_count": len(emails),
            "fetch_source": fetch_source,
            "latest_inbox": emails[0] if emails else None,
            "messages": emails,
            "new_refresh_token": new_refresh,
        }
