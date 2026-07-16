import logging
from datetime import UTC, datetime

from sqlalchemy.orm import Session

from app.core.security import new_id
from app.models import Task, User
from app.services.task_classifier import infer_category_and_energy

logger = logging.getLogger(__name__)


def create_task_from_analysis(
    db: Session,
    user: User,
    analysis: dict,
    *,
    source_subject: str,
    source_snippet: str,
    email_message_id: str | None = None,
    whatsapp_message_id: str | None = None,
    sender_name: str | None = None,
    sender_email: str | None = None,
    source_label: str = "ingest",
) -> Task | None:
    if not analysis.get("is_actionable", True):
        return None

    if whatsapp_message_id:
        exists = (
            db.query(Task)
            .filter(Task.user_id == user.id, Task.whatsapp_message_id == whatsapp_message_id)
            .one_or_none()
        )
        if exists:
            return None

    if email_message_id:
        exists = (
            db.query(Task)
            .filter(Task.user_id == user.id, Task.email_message_id == email_message_id)
            .one_or_none()
        )
        if exists:
            return None

    deadline = None
    if analysis.get("deadline"):
        try:
            deadline = datetime.fromisoformat(str(analysis["deadline"]).replace("Z", "+00:00"))
        except ValueError:
            deadline = None

    priority = analysis.get("priority", "medium")
    category, energy_level = infer_category_and_energy(
        subject=source_subject,
        snippet=source_snippet,
        priority=priority,
    )

    task = Task(
        id=new_id(),
        user_id=user.id,
        title=analysis.get("title") or source_subject[:200] or "משימה חדשה",
        description=analysis.get("description") or source_snippet[:500],
        status="open",
        priority=priority,
        priority_score=float(analysis.get("priority_score", 50)),
        category=category,
        energy_level=energy_level,
        sender_name=sender_name,
        sender_email=sender_email,
        email_subject=source_subject[:500] if email_message_id or whatsapp_message_id else None,
        email_snippet=source_snippet[:2000] if email_message_id or whatsapp_message_id else None,
        email_message_id=email_message_id,
        whatsapp_message_id=whatsapp_message_id,
        deadline=deadline,
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    logger.info(
        "Created task via %s for user %s: %r",
        source_label,
        user.id,
        task.title[:120],
    )
    return task
