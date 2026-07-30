from datetime import datetime
from enum import Enum

from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class TaskStatus(str, Enum):
    open = "open"
    completed = "completed"
    snoozed = "snoozed"
    dismissed = "dismissed"
    overdue = "overdue"


class TaskPriority(str, Enum):
    critical = "critical"
    high = "high"
    medium = "medium"
    low = "low"
    none = "none"


class TaskCategory(str, Enum):
    work = "work"
    errands = "errands"
    health = "health"
    general = "general"


class EnergyLevel(str, Enum):
    high = "high"
    medium = "medium"
    low = "low"


class AssetType(str, Enum):
    vehicle_test = "vehicle_test"
    car_insurance = "car_insurance"
    home_insurance = "home_insurance"
    document = "document"


class InfoDocCategory(str, Enum):
    personal_docs = "personal_docs"
    ideas = "ideas"
    summaries = "summaries"
    links = "links"
    archive = "archive"
    vehicle = "vehicle"
    insurance = "insurance"


class BudgetType(str, Enum):
    home = "home"
    business = "business"


class TransactionType(str, Enum):
    income = "income"
    expense = "expense"


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    avatar_url: Mapped[str | None] = mapped_column(String(2048), nullable=True)
    gmail_connected: Mapped[bool] = mapped_column(Boolean, default=False)
    outlook_connected: Mapped[bool] = mapped_column(Boolean, default=False)
    google_refresh_token: Mapped[str | None] = mapped_column(Text, nullable=True)
    google_access_token: Mapped[str | None] = mapped_column(Text, nullable=True)
    outlook_refresh_token: Mapped[str | None] = mapped_column(Text, nullable=True)
    whatsapp_phone: Mapped[str | None] = mapped_column(String(20), nullable=True, unique=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    refresh_tokens: Mapped[list["RefreshToken"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    tasks: Mapped[list["Task"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    settings: Mapped["UserSettings | None"] = relationship(back_populates="user", cascade="all, delete-orphan", uselist=False)
    device_tokens: Mapped[list["DeviceToken"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    daily_briefs: Mapped[list["DailyBrief"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    budget_plans: Mapped[list["BudgetPlan"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    finance_transactions: Mapped[list["FinanceTransaction"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    bank_connections: Mapped[list["BankConnection"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    bank_accounts: Mapped[list["BankAccount"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    asset_reminders: Mapped[list["AssetReminder"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    info_documents: Mapped[list["InfoDocument"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    whatsapp_inbound_logs: Mapped[list["WhatsAppInboundLog"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )


class WhatsAppInboundLog(Base):
    __tablename__ = "whatsapp_inbound_logs"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"), index=True, nullable=True)
    from_phone: Mapped[str] = mapped_column(String(20), index=True)
    message_id: Mapped[str | None] = mapped_column(String(128), nullable=True, index=True)
    msg_type: Mapped[str] = mapped_column(String(20), default="text")
    body_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    task_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    bot_reply: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(String(30), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), index=True)

    user: Mapped[User | None] = relationship(back_populates="whatsapp_inbound_logs")


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    token_hash: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revoked: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user: Mapped[User] = relationship(back_populates="refresh_tokens")


class Task(Base):
    __tablename__ = "tasks"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    title: Mapped[str] = mapped_column(String(500))
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(String(20), default=TaskStatus.open.value, index=True)
    priority: Mapped[str] = mapped_column(String(20), default=TaskPriority.none.value, index=True)
    priority_score: Mapped[float] = mapped_column(Float, default=0.0)
    category: Mapped[str] = mapped_column(String(20), default=TaskCategory.general.value, index=True)
    energy_level: Mapped[str] = mapped_column(String(20), default=EnergyLevel.medium.value, index=True)
    sender_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    sender_email: Mapped[str | None] = mapped_column(String(320), nullable=True)
    email_subject: Mapped[str | None] = mapped_column(String(500), nullable=True)
    email_snippet: Mapped[str | None] = mapped_column(Text, nullable=True)
    email_message_id: Mapped[str | None] = mapped_column(String(512), nullable=True, index=True)
    whatsapp_message_id: Mapped[str | None] = mapped_column(String(512), nullable=True, index=True)
    deadline: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    snoozed_until: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped[User] = relationship(back_populates="tasks")


class UserSettings(Base):
    __tablename__ = "user_settings"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    push_notifications_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    daily_brief_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    email_sync_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    daily_brief_time: Mapped[str] = mapped_column(String(5), default="09:00")
    language: Mapped[str] = mapped_column(String(10), default="he")

    user: Mapped[User] = relationship(back_populates="settings")


class DeviceToken(Base):
    __tablename__ = "device_tokens"
    __table_args__ = (UniqueConstraint("user_id", "fcm_token", name="uq_user_fcm_token"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    fcm_token: Mapped[str] = mapped_column(String(512))
    platform: Mapped[str] = mapped_column(String(20))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped[User] = relationship(back_populates="device_tokens")


class DailyBrief(Base):
    __tablename__ = "daily_briefs"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    summary: Mapped[str] = mapped_column(String(500))
    content: Mapped[str] = mapped_column(Text)
    insights_json: Mapped[str] = mapped_column(Text, default="[]")
    highlighted_task_ids_json: Mapped[str] = mapped_column(Text, default="[]")
    generated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user: Mapped[User] = relationship(back_populates="daily_briefs")


class BudgetPlan(Base):
    __tablename__ = "budget_plans"
    __table_args__ = (UniqueConstraint("user_id", "budget_type", "month", name="uq_user_budget_month"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    budget_type: Mapped[str] = mapped_column(String(20), index=True)
    month: Mapped[str] = mapped_column(String(7), index=True)
    expense_budget: Mapped[float] = mapped_column(Float, default=0.0)
    savings_target: Mapped[float] = mapped_column(Float, default=0.0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped[User] = relationship(back_populates="budget_plans")


class FinanceTransaction(Base):
    __tablename__ = "finance_transactions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    budget_type: Mapped[str] = mapped_column(String(20), index=True)
    title: Mapped[str] = mapped_column(String(255))
    amount: Mapped[float] = mapped_column(Float)
    tx_type: Mapped[str] = mapped_column(String(20), index=True)
    category: Mapped[str] = mapped_column(String(50), default="general")
    icon: Mapped[str] = mapped_column(String(30), default="payment")
    bank_account_id: Mapped[str | None] = mapped_column(
        ForeignKey("bank_accounts.id", ondelete="SET NULL"), nullable=True, index=True
    )
    external_id: Mapped[str | None] = mapped_column(String(128), nullable=True, index=True)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user: Mapped[User] = relationship(back_populates="finance_transactions")


class BankConnection(Base):
    __tablename__ = "bank_connections"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    provider_code: Mapped[str] = mapped_column(String(50), index=True)
    provider_name: Mapped[str] = mapped_column(String(120))
    status: Mapped[str] = mapped_column(String(30), default="active", index=True)
    mode: Mapped[str] = mapped_column(String(20), default="demo")  # demo | saltedge
    external_customer_id: Mapped[str | None] = mapped_column(String(128), nullable=True)
    external_connection_id: Mapped[str | None] = mapped_column(String(128), nullable=True, index=True)
    consent_expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    last_synced_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped[User] = relationship(back_populates="bank_connections")
    accounts: Mapped[list["BankAccount"]] = relationship(
        back_populates="connection", cascade="all, delete-orphan"
    )


class BankAccount(Base):
    __tablename__ = "bank_accounts"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    connection_id: Mapped[str] = mapped_column(
        ForeignKey("bank_connections.id", ondelete="CASCADE"), index=True
    )
    provider_code: Mapped[str] = mapped_column(String(50), index=True)
    provider_name: Mapped[str] = mapped_column(String(120))
    name: Mapped[str] = mapped_column(String(120))
    account_type: Mapped[str] = mapped_column(String(40), default="checking")
    currency: Mapped[str] = mapped_column(String(8), default="ILS")
    balance: Mapped[float] = mapped_column(Float, default=0.0)
    iban_masked: Mapped[str | None] = mapped_column(String(40), nullable=True)
    external_account_id: Mapped[str | None] = mapped_column(String(128), nullable=True, index=True)
    budget_type: Mapped[str] = mapped_column(String(20), default="home", index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped[User] = relationship(back_populates="bank_accounts")
    connection: Mapped[BankConnection] = relationship(back_populates="accounts")


class AssetReminder(Base):
    __tablename__ = "asset_reminders"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    asset_type: Mapped[str] = mapped_column(String(30), index=True)
    title: Mapped[str] = mapped_column(String(255))
    document_label: Mapped[str | None] = mapped_column(String(255), nullable=True)
    expiry_date: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    icon: Mapped[str] = mapped_column(String(30), default="document")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped[User] = relationship(back_populates="asset_reminders")


class InfoDocument(Base):
    __tablename__ = "info_documents"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    category: Mapped[str] = mapped_column(String(40), index=True)
    title: Mapped[str] = mapped_column(String(255))
    summary: Mapped[str | None] = mapped_column(Text, nullable=True)
    extracted_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    mime_type: Mapped[str | None] = mapped_column(String(80), nullable=True)
    image_data: Mapped[str | None] = mapped_column(Text, nullable=True)
    expiry_date: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    confidence: Mapped[float] = mapped_column(Float, default=0.0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped[User] = relationship(back_populates="info_documents")
