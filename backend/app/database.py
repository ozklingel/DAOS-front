from collections.abc import Generator

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import Session, sessionmaker

from app.config import settings
from app.models import Base

connect_args = {"check_same_thread": False} if settings.database_url.startswith("sqlite") else {}
engine = create_engine(settings.database_url, connect_args=connect_args, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def _add_column_if_missing(table: str, column: str, ddl_type: str) -> None:
    inspector = inspect(engine)
    if table not in inspector.get_table_names():
        return
    columns = {col["name"] for col in inspector.get_columns(table)}
    if column in columns:
        return
    with engine.begin() as conn:
        conn.execute(text(f"ALTER TABLE {table} ADD COLUMN {column} {ddl_type}"))


def _ensure_unique_index(table: str, column: str, index_name: str) -> None:
    inspector = inspect(engine)
    if table not in inspector.get_table_names():
        return
    existing = {idx["name"] for idx in inspector.get_indexes(table)}
    if index_name in existing:
        return
    with engine.begin() as conn:
        conn.execute(
            text(f"CREATE UNIQUE INDEX IF NOT EXISTS {index_name} ON {table} ({column})")
        )


def _migrate_schema() -> None:
    """Add columns introduced after initial create_all (SQLite + Postgres)."""
    inspector = inspect(engine)
    tables = set(inspector.get_table_names())
    if "users" not in tables:
        return

    _add_column_if_missing("users", "google_access_token", "TEXT")
    _add_column_if_missing("users", "whatsapp_phone", "VARCHAR(20)")

    # Unique indexes for phone link columns (idempotent).
    try:
        _ensure_unique_index("users", "whatsapp_phone", "ix_users_whatsapp_phone")
    except Exception:
        # Index may already exist under another name; column presence is what matters.
        pass

    if "tasks" in tables:
        _add_column_if_missing("tasks", "category", "VARCHAR(20) DEFAULT 'general'")
        _add_column_if_missing("tasks", "energy_level", "VARCHAR(20) DEFAULT 'medium'")
        _add_column_if_missing("tasks", "whatsapp_message_id", "VARCHAR(512)")

    if "finance_transactions" in tables:
        _add_column_if_missing("finance_transactions", "bank_account_id", "VARCHAR(36)")
        _add_column_if_missing("finance_transactions", "external_id", "VARCHAR(128)")


def init_db() -> None:
    Base.metadata.create_all(bind=engine)
    _migrate_schema()


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
