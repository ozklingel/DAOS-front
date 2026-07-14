from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "TaskMail API"
    app_version: str = "1.0.0"
    debug: bool = False
    api_prefix: str = "/api/v1"

    database_url: str = "sqlite:///./taskmail.db"

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
