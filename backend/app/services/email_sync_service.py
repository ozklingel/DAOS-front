import logging

from sqlalchemy.orm import Session

from app.models import Task, User
from app.services.ai_service import AIService
from app.services.gmail_service import GmailService
from app.services.outlook_mail_service import OutlookMailService

from app.services.task_ingest_service import create_task_from_analysis

logger = logging.getLogger(__name__)


class EmailSyncService:
    """Fetches recent emails and creates AI-derived tasks."""

    def __init__(self) -> None:
        self.ai = AIService()
        self.gmail = GmailService()
        self.outlook = OutlookMailService()

    async def sync_user_emails(self, db: Session, user: User) -> dict:
        emails = await self._fetch_emails(db, user)
        created = 0
        skipped_non_hebrew = 0
        for email in emails:
            exists = (
                db.query(Task)
                .filter(Task.user_id == user.id, Task.email_message_id == email["message_id"])
                .one_or_none()
            )
            if exists:
                continue

            if not self.ai.is_hebrew_email(email["subject"], email["snippet"]):
                skipped_non_hebrew += 1
                continue

            analysis, source = self.ai.analyze_email_detailed(
                subject=email["subject"],
                sender=email["sender"],
                snippet=email["snippet"],
            )
            if not analysis or not analysis.get("is_actionable", True):
                continue

            task = create_task_from_analysis(
                db,
                user,
                analysis,
                source_subject=email["subject"],
                source_snippet=email["snippet"],
                email_message_id=email["message_id"],
                sender_name=email.get("sender_name"),
                sender_email=email.get("sender_email"),
                source_label=source,
            )
            if task:
                created += 1
                logger.info(
                    "Created Hebrew task via %s for user %s: %r",
                    source,
                    user.id,
                    task.title[:120],
                )

        if created:
            db.commit()

        logger.info(
            "Email sync for user %s: scanned=%d created=%d skipped_non_hebrew=%d",
            user.id,
            len(emails),
            created,
            skipped_non_hebrew,
        )
        return {
            "created": created,
            "scanned": len(emails),
            "skipped_non_hebrew": skipped_non_hebrew,
        }

    async def _fetch_emails(self, db: Session, user: User) -> list[dict]:
        emails: list[dict] = []

        if user.gmail_connected and (user.google_refresh_token or user.google_access_token):
            try:
                emails.extend(
                    self.gmail.fetch_recent_emails(
                        refresh_token=user.google_refresh_token,
                        access_token=user.google_access_token,
                    )
                )
            except Exception as exc:
                logger.warning("Gmail fetch failed for user %s: %s", user.id, exc)
                if self._is_stale_google_token_error(exc):
                    logger.info(
                        "Clearing stale Gmail token for user %s — reconnect Gmail in settings",
                        user.id,
                    )
                    user.gmail_connected = False
                    user.google_refresh_token = None
                    user.google_access_token = None
                    db.commit()

        if user.outlook_connected and user.outlook_refresh_token:
            try:
                emails.extend(await self.outlook.fetch_recent_emails(user.outlook_refresh_token))
            except Exception as exc:
                logger.warning("Outlook fetch failed for user %s: %s", user.id, exc)

        return emails

    @staticmethod
    def _is_stale_google_token_error(exc: Exception) -> bool:
        text = str(exc).lower()
        stale_markers = (
            "unauthorized_client",
            "invalid_grant",
            "necessary fields",
            "refresh the access token",
            "invalid_client",
            "token has been expired",
            "token expired",
            "invalid credentials",
            "401",
        )
        if any(marker in text for marker in stale_markers):
            return True
        if isinstance(exc, tuple) and len(exc) >= 2 and isinstance(exc[1], dict):
            error = str(exc[1].get("error", "")).lower()
            return error in {"unauthorized_client", "invalid_grant", "invalid_client"}
        return False
