import httpx

from app.config import settings


class GoogleOAuthService:
    TOKEN_URL = "https://oauth2.googleapis.com/token"

    async def exchange_server_auth_code(self, code: str) -> dict:
        if not settings.google_client_id or not settings.google_client_secret:
            raise ValueError("Google OAuth server credentials are not configured")

        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.post(
                self.TOKEN_URL,
                data={
                    "code": code,
                    "client_id": settings.google_client_id,
                    "client_secret": settings.google_client_secret,
                    "grant_type": "authorization_code",
                },
            )

        if response.status_code != 200:
            detail = response.text[:200]
            raise ValueError(f"Failed to exchange Google auth code: {detail}")

        data = response.json()
        if not data.get("refresh_token"):
            raise ValueError(
                "Google did not return a refresh token. "
                "Revoke app access in your Google account and sign in again."
            )
        return data
