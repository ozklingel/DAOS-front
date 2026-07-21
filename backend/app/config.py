from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "TaskMail API"
    app_version: str = "1.0.0"
    debug: bool = False
    api_prefix: str = "/api/v1"

    database_url: str = "sqlite:///./taskmail.db"

    @field_validator("database_url", mode="before")
    @classmethod
    def normalize_database_url(cls, value: str) -> str:
        # Render Postgres uses postgres:// — SQLAlchemy expects postgresql://
        if isinstance(value, str) and value.startswith("postgres://"):
            return value.replace("postgres://", "postgresql://", 1)
        return value

    jwt_secret_key: str = "change-me-in-production-use-openssl-rand-hex-32"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60
    refresh_token_expire_days: int = 30

    # Web OAuth client (used for ID token verification + server auth code exchange)
    google_client_id: str = ""
    google_client_secret: str = ""
    # Optional Android OAuth client ID if ID tokens are issued for the mobile client
    google_android_client_id: str = ""
    microsoft_client_id: str = ""
    microsoft_client_secret: str = ""

    openai_api_key: str = ""
    openai_model: str = "gpt-4o-mini"

    firebase_credentials_path: str = ""

    cors_origins: str = "*"

    email_sync_interval_minutes: int = 15

    whatsapp_verify_token: str = ""
    whatsapp_access_token: str = ""
    whatsapp_phone_number_id: str = ""
    whatsapp_app_secret: str = ""
    whatsapp_graph_api_version: str = "v25.0"

    # Green API (https://green-api.com) — simpler WhatsApp without Meta dashboard
    green_api_url: str = "https://api.green-api.com"
    green_api_id_instance: str = ""
    green_api_token: str = ""

    # Salt Edge — Israeli Open Finance aggregator (https://www.saltedge.com / saltedge.co.il)
    salt_edge_app_id: str = ""
    salt_edge_secret: str = ""
    salt_edge_api_url: str = "https://www.saltedge.com"
    salt_edge_return_url: str = "http://localhost:5173/"
    salt_edge_api_prefix: str = "/api/v6"

    @property
    def green_api_enabled(self) -> bool:
        return bool(self.green_api_id_instance.strip() and self.green_api_token.strip())

    @property
    def salt_edge_enabled(self) -> bool:
        return bool(self.salt_edge_app_id.strip() and self.salt_edge_secret.strip())

    @property
    def whatsapp_app_secret_effective(self) -> str:
        value = self.whatsapp_app_secret.strip()
        if value in {"", "your-app-secret"}:
            return ""
        return value

    @property
    def cors_origin_list(self) -> list[str]:
        if self.cors_origins == "*":
            return ["*"]
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def google_client_id_list(self) -> list[str]:
        ids: list[str] = []
        for value in (self.google_client_id, self.google_android_client_id):
            if value and value not in ids:
                ids.append(value)
        return ids


settings = Settings()
