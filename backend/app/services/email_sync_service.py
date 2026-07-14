from datetime import UTC, datetime

from sqlalchemy.orm import Session

from app.core.security import new_id
from app.models import Task, User
from app.services.ai_service import AIService
from app.services.gmail_service import GmailService
from app.services.outlook_mail_service import OutlookMailService

logger = logging.getLogger(__name__)


class EmailSyncService:
    """Fetches recent emails and creates AI-derived tasks."""

    def __init__(self) -> None:
        self.ai = AIService()
        self.gmail = GmailService()
        self.outlook = OutlookMailService()

    async def sync_user_emails(self, db: Session, user: User) -> int:
        emails = await self._fetch_emails(user)
        created = 0
        for email in emails:
            exists = (
                db.query(Task)
                .filter(Task.user_id == user.id, Task.email_message_id == email["message_id"])
                .one_or_none()
            )
            if exists:
                continue

            analysis = self.ai.analyze_email(
                subject=email["subject"],
                sender=email["sender"],
                snippet=email["snippet"],
            )
            if not analysis or not analysis.get("is_actionable", True):
                continue

            deadline = None
            if analysis.get("deadline"):
                try:
                    deadline = datetime.fromisoformat(analysis["deadline"].replace("Z", "+00:00"))
                except ValueError:
                    deadline = None

            task = Task(
                id=new_id(),
                user_id=user.id,
                title=analysis.get("title") or email["subject"],
                description=analysis.get("description"),
                status="open",
                priority=analysis.get("priority", "medium"),
                priority_score=float(analysis.get("priority_score", 50)),
                sender_name=email.get("sender_name"),
                sender_email=email.get("sender_email"),
                email_subject=email["subject"],
                email_snippet=email["snippet"],
                email_message_id=email["message_id"],
                deadline=deadline,
            )
            db.add(task)
            created += 1

        if created:
            db.commit()
        return created

    async def _fetch_emails(self, user: User) -> list[dict]:
        emails: list[dict] = []

        if user.gmail_connected and user.google_refresh_token:
            try:
                emails.extend(self.gmail.fetch_recent_emails(user.google_refresh_token))
            except Exception as exc:
                logger.warning("Gmail fetch failed for user %s: %s", user.id, exc)

        if user.outlook_connected and user.outlook_refresh_token:
            try:
                emails.extend(await self.outlook.fetch_recent_emails(user.outlook_refresh_token))
            except Exception as exc:
                logger.warning("Outlook fetch failed for user %s: %s", user.id, exc)

        return emails
