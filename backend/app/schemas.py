from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, model_validator


def to_camel(string: str) -> str:
    parts = string.split("_")
    return parts[0] + "".join(word.capitalize() for word in parts[1:])


class APIModel(BaseModel):
    model_config = ConfigDict(populate_by_name=True, from_attributes=True)


class UserOut(APIModel):
    id: str
    email: str
    name: str | None = None
    avatar_url: str | None = None
    gmail_connected: bool = False
    outlook_connected: bool = False


class AuthTokensOut(APIModel):
    access_token: str
    refresh_token: str
    user: UserOut | None = None


class GoogleAuthIn(APIModel):
    id_token: str | None = Field(default=None, alias="idToken")
    server_auth_code: str | None = Field(default=None, alias="serverAuthCode")

    @model_validator(mode="before")
    @classmethod
    def accept_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict):
            if "id_token" not in data and "idToken" in data:
                data["id_token"] = data["idToken"]
            if "server_auth_code" not in data and "serverAuthCode" in data:
                data["server_auth_code"] = data["serverAuthCode"]
        return data


class OutlookAuthIn(APIModel):
    access_token: str | None = Field(default=None, alias="accessToken")
    refresh_token: str | None = Field(default=None, alias="refreshToken")

    @model_validator(mode="before")
    @classmethod
    def accept_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict):
            if "access_token" not in data and "accessToken" in data:
                data["access_token"] = data["accessToken"]
            if "refresh_token" not in data and "refreshToken" in data:
                data["refresh_token"] = data["refreshToken"]
        return data


class RefreshTokenIn(APIModel):
    refresh_token: str


class TaskOut(APIModel):
    id: str
    title: str
    status: str
    priority: str
    priority_score: float
    description: str | None = None
    sender_name: str | None = None
    sender_email: str | None = None
    email_subject: str | None = None
    email_snippet: str | None = None
    deadline: datetime | None = None
    snoozed_until: datetime | None = None
    completed_at: datetime | None = None
    created_at: datetime
    updated_at: datetime


class TaskListOut(APIModel):
    tasks: list[TaskOut]
    total: int
    page: int
    has_more: bool


class TaskUpdateIn(APIModel):
    action: str
    snooze_until: datetime | None = Field(default=None, alias="snoozeUntil")

    @model_validator(mode="before")
    @classmethod
    def accept_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict) and "snooze_until" not in data and "snoozeUntil" in data:
            data["snooze_until"] = data["snoozeUntil"]
        return data


class DashboardStatsOut(APIModel):
    critical_count: int = 0
    open_count: int = 0
    overdue_count: int = 0
    completed_this_week: int = 0


class DashboardOut(APIModel):
    stats: DashboardStatsOut
    brief_summary: str
    recent_high_priority_tasks: list[TaskOut] = Field(default_factory=list)


class DailyBriefOut(APIModel):
    id: str
    summary: str
    content: str
    generated_at: datetime
    highlighted_tasks: list[TaskOut] = Field(default_factory=list)
    insights: list[str] = Field(default_factory=list)


class EmailSyncOut(APIModel):
    created: int = 0


class SettingsOut(APIModel):
    push_notifications_enabled: bool = True
    daily_brief_enabled: bool = True
    email_sync_enabled: bool = True
    daily_brief_time: str = "09:00"
    language: str = "en"


class SettingsUpdateIn(APIModel):
    push_notifications_enabled: bool | None = Field(default=None, alias="pushNotificationsEnabled")
    daily_brief_enabled: bool | None = Field(default=None, alias="dailyBriefEnabled")
    email_sync_enabled: bool | None = Field(default=None, alias="emailSyncEnabled")
    daily_brief_time: str | None = Field(default=None, alias="dailyBriefTime")
    language: str | None = None

    @model_validator(mode="before")
    @classmethod
    def accept_aliases(cls, data: Any) -> Any:
        if not isinstance(data, dict):
            return data
        mapping = {
            "pushNotificationsEnabled": "push_notifications_enabled",
            "dailyBriefEnabled": "daily_brief_enabled",
            "emailSyncEnabled": "email_sync_enabled",
            "dailyBriefTime": "daily_brief_time",
        }
        for src, dst in mapping.items():
            if src in data and dst not in data:
                data[dst] = data[src]
        return data


class DeviceRegisterIn(APIModel):
    fcm_token: str | None = Field(default=None, alias="fcmToken")
    platform: str

    @model_validator(mode="before")
    @classmethod
    def accept_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict) and "fcm_token" not in data and "fcmToken" in data:
            data["fcm_token"] = data["fcmToken"]
        return data


class ErrorOut(APIModel):
    message: str
    error: str | None = None
