from collections.abc import Generator

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import Session, sessionmaker

from app.config import settings
from app.models import Base

connect_args = {"check_same_thread": False} if settings.database_url.startswith("sqlite") else {}
engine = create_engine(settings.database_url, connect_args=connect_args, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def _migrate_sqlite() -> None:
    if not settings.database_url.startswith("sqlite"):
        return
    inspector = inspect(engine)
    if "users" not in inspector.get_table_names():
        return
    columns = {col["name"] for col in inspector.get_columns("users")}
    if "google_access_token" not in columns:
        with engine.begin() as conn:
            conn.execute(text("ALTER TABLE users ADD COLUMN google_access_token TEXT"))
    if "tasks" not in inspector.get_table_names():
        return
    task_columns = {col["name"] for col in inspector.get_columns("tasks")}
    if "category" not in task_columns:
        with engine.begin() as conn:
            conn.execute(
                text("ALTER TABLE tasks ADD COLUMN category VARCHAR(20) DEFAULT 'general'")
            )
    if "energy_level" not in task_columns:
        with engine.begin() as conn:
            conn.execute(
                text("ALTER TABLE tasks ADD COLUMN energy_level VARCHAR(20) DEFAULT 'medium'")
            )
    if "whatsapp_message_id" not in task_columns:
        with engine.begin() as conn:
            conn.execute(text("ALTER TABLE tasks ADD COLUMN whatsapp_message_id VARCHAR(512)"))
    user_columns = {col["name"] for col in inspector.get_columns("users")}
    if "whatsapp_phone" not in user_columns:
        with engine.begin() as conn:
            conn.execute(text("ALTER TABLE users ADD COLUMN whatsapp_phone VARCHAR(20)"))
    if "finance_transactions" in inspector.get_table_names():
        tx_columns = {col["name"] for col in inspector.get_columns("finance_transactions")}
        if "bank_account_id" not in tx_columns:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE finance_transactions ADD COLUMN bank_account_id VARCHAR(36)"))
        if "external_id" not in tx_columns:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE finance_transactions ADD COLUMN external_id VARCHAR(128)"))


def init_db() -> None:
    Base.metadata.create_all(bind=engine)
    _migrate_sqlite()


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
