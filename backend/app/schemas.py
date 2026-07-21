from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, computed_field, model_validator


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
    whatsapp_phone: str | None = None

    @computed_field
    @property
    def whatsapp_connected(self) -> bool:
        return bool(self.whatsapp_phone)


class WhatsAppLinkIn(APIModel):
    phone: str


class WhatsAppSimulateIn(APIModel):
    transcript: str


class WhatsAppSimulateOut(APIModel):
    created: bool
    task_id: str | None = None
    message: str


class WhatsAppDevInboundIn(APIModel):
    phone: str
    text: str


class WhatsAppInboundOut(APIModel):
    id: str
    from_phone: str
    message_id: str | None = None
    msg_type: str
    body_text: str | None = None
    task_id: str | None = None
    bot_reply: str | None = None
    status: str
    created_at: datetime


class WhatsAppInboundStatusOut(APIModel):
    linked_phone: str | None = None
    has_messages: bool
    latest: WhatsAppInboundOut | None = None
    recent: list[WhatsAppInboundOut] = Field(default_factory=list)


class AuthTokensOut(APIModel):
    access_token: str
    refresh_token: str
    user: UserOut | None = None


class GoogleAuthIn(APIModel):
    id_token: str | None = Field(default=None, alias="idToken")
    access_token: str | None = Field(default=None, alias="accessToken")
    server_auth_code: str | None = Field(default=None, alias="serverAuthCode")

    @model_validator(mode="before")
    @classmethod
    def accept_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict):
            if "id_token" not in data and "idToken" in data:
                data["id_token"] = data["idToken"]
            if "access_token" not in data and "accessToken" in data:
                data["access_token"] = data["accessToken"]
            if "server_auth_code" not in data and "serverAuthCode" in data:
                data["server_auth_code"] = data["serverAuthCode"]
        return data

    @model_validator(mode="after")
    def require_google_token(self) -> "GoogleAuthIn":
        if not self.id_token and not self.access_token:
            raise ValueError("idToken or accessToken is required")
        return self


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
    category: str = "general"
    energy_level: str = "medium"
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


class EnergyMeterOut(APIModel):
    budget: int = 100
    used: int = 0
    remaining: int = 100
    high_count: int = 0
    medium_count: int = 0
    low_count: int = 0
    work_count: int = 0
    errands_count: int = 0
    health_count: int = 0


class DashboardOut(APIModel):
    stats: DashboardStatsOut
    brief_summary: str
    energy_meter: EnergyMeterOut
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
    scanned: int = 0
    skipped_non_hebrew: int = 0


class EmailAiStatusOut(APIModel):
    ai_enabled: bool
    model: str
    hebrew_only: bool = True
    fallback: str = "hebrew_heuristics"


class EmailAnalyzePreviewIn(APIModel):
    subject: str
    sender: str = "test@example.com"
    snippet: str = ""


class EmailAnalyzePreviewOut(APIModel):
    ai_enabled: bool
    is_hebrew: bool
    source: str
    analysis: dict | None = None


class SettingsOut(APIModel):
    push_notifications_enabled: bool = True
    daily_brief_enabled: bool = True
    email_sync_enabled: bool = True
    daily_brief_time: str = "09:00"
    language: str = "he"


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


class ProfileOut(APIModel):
    id: str
    full_name: str
    email: str
    date_of_birth: str
    username: str
    two_factor_enabled: bool
    subscription_plan: str
    subscription_expires: str
    avatar_url: str | None = None


class CalendarDayOut(APIModel):
    date: str
    day_number: int
    is_today: bool
    is_selected: bool
    label: str


class CalendarEventOut(APIModel):
    id: str
    title: str
    subtitle: str = ""
    category: str
    start_time: str
    end_time: str
    icon: str
    source: str = "task"


class CalendarOut(APIModel):
    selected_date: str
    month_label: str
    days: list[CalendarDayOut]
    events: list[CalendarEventOut]


class FinanceTransactionOut(APIModel):
    id: str
    title: str
    time: str
    amount: float
    icon: str
    budget_type: str = "home"
    category: str = "general"
    tx_type: str = "expense"


class BudgetSummaryOut(APIModel):
    budget_type: str
    income: float
    expenses: float
    balance: float
    expense_budget: float
    budget_remaining: float
    savings_target: float
    savings_saved: float
    savings_progress: float


class BankAccountOut(APIModel):
    id: str
    connection_id: str
    provider_code: str
    provider_name: str
    name: str
    account_type: str = "checking"
    currency: str = "ILS"
    balance: float = 0.0
    iban_masked: str | None = None
    budget_type: str = "home"


class BankConnectionOut(APIModel):
    id: str
    provider_code: str
    provider_name: str
    status: str
    mode: str = "demo"
    consent_expires_at: str | None = None
    last_synced_at: str | None = None
    account_count: int = 0


class BankProviderOut(APIModel):
    code: str
    name: str
    name_en: str


class BankProvidersOut(APIModel):
    country: str = "IL"
    currency: str = "ILS"
    mode: str = "demo"
    providers: list[BankProviderOut]
    hint: str | None = None


class BankConnectIn(APIModel):
    provider_code: str
    budget_type: str = "home"
    return_url: str | None = None
    psu_id: str | None = None


class BankConnectOut(APIModel):
    status: str
    mode: str
    connection: BankConnectionOut
    accounts: list[BankAccountOut] = []
    connect_url: str | None = None
    imported_transactions: int = 0


class BankSyncOut(APIModel):
    connection: BankConnectionOut
    accounts: list[BankAccountOut] = []
    imported_transactions: int = 0


class BankSaltEdgeCallbackIn(APIModel):
    connection_id: str
    external_connection_id: str


class BankFinandaCallbackIn(APIModel):
    connection_id: str
    consent_id: str | None = None
    code: str | None = None


class FinanceOut(APIModel):
    currency: str = "ILS"
    month: str
    month_label: str
    selected_type: str = "home"
    total_balance: float
    bank_total_balance: float = 0.0
    income: float
    expenses: float
    home: BudgetSummaryOut
    business: BudgetSummaryOut
    summary: BudgetSummaryOut
    transactions: list[FinanceTransactionOut]
    bank_accounts: list[BankAccountOut] = []


class FinanceTransactionIn(APIModel):
    budget_type: str
    title: str
    amount: float
    tx_type: str
    category: str = "general"
    icon: str = "payment"


class InfoCategoryOut(APIModel):
    id: str
    title: str
    icon: str
    items: list[str]


class AssetReminderOut(APIModel):
    id: str
    asset_type: str
    title: str
    document_label: str | None = None
    expiry_date: str
    days_until: int
    status: str
    icon: str = "document"
    notes: str | None = None


class AssetReminderUpdateIn(APIModel):
    title: str | None = None
    expiry_date: str | None = None
    notes: str | None = None


class InfoHubOut(APIModel):
    categories: list[InfoCategoryOut]
    reminders: list[AssetReminderOut] = Field(default_factory=list)
    documents: list["InfoDocumentOut"] = Field(default_factory=list)
    alerts_count: int = 0


class InfoDocumentOut(APIModel):
    id: str
    category: str
    category_title: str
    title: str
    summary: str | None = None
    extracted_text: str | None = None
    expiry_date: str | None = None
    confidence: float = 0.0
    icon: str = "document"
    has_image: bool = False
    mime_type: str | None = None
    image_data_url: str | None = None
    created_at: str | None = None


class InfoDocumentUploadOut(APIModel):
    document: InfoDocumentOut
    message: str = "Document saved"
