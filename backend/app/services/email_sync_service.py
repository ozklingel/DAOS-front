import logging

from sqlalchemy.orm import Session

from app.models import Task, User
from app.services.ai_service import AIService
from app.services.gmail_service import GmailService
from app.services.info_document_service import InfoDocumentService
from app.services.outlook_mail_service import OutlookMailService

from app.services.task_ingest_service import create_task_from_analysis

logger = logging.getLogger(__name__)


class EmailSyncService:
    """Fetches recent emails and creates AI-derived tasks."""

    def __init__(self) -> None:
        self.ai = AIService()
        self.gmail = GmailService()
        self.outlook = OutlookMailService()
        self.info_docs = InfoDocumentService()

    async def sync_user_emails(self, db: Session, user: User) -> dict:
        emails, fetch_errors = await self._fetch_emails(db, user)
        created = 0
        info_created = 0
        skipped_non_hebrew = 0
        skipped_no_signal = 0
        skipped_not_actionable = 0
        for email in emails:
            task_exists = (
                db.query(Task)
                .filter(Task.user_id == user.id, Task.email_message_id == email["message_id"])
                .one_or_none()
            )
            if task_exists:
                continue

            if not self.ai.is_hebrew_email(email["subject"], email["snippet"]):
                skipped_non_hebrew += 1
                continue

            task_created = False
            if self.ai.looks_like_task_candidate(email["subject"], email["snippet"]):
                analysis, source = self.ai.analyze_email_detailed(
                    subject=email["subject"],
                    sender=email["sender"],
                    snippet=email["snippet"],
                    channel="email",
                )
                if analysis and analysis.get("is_actionable", True):
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
                        task_created = True
                        logger.info(
                            "Created Hebrew task via %s for user %s: %r",
                            source,
                            user.id,
                            task.title[:120],
                        )
                elif analysis is not None:
                    skipped_not_actionable += 1
            else:
                skipped_no_signal += 1

            if task_created:
                continue

            if self.ai.looks_like_info_candidate(email["subject"], email["snippet"]):
                info_analysis = self.ai.analyze_message_for_info(
                    subject=email["subject"],
                    sender=email["sender"],
                    snippet=email["snippet"],
                    channel="email",
                )
                if info_analysis:
                    doc = self.info_docs.create_from_message(
                        db,
                        user,
                        info_analysis,
                        source="email",
                        source_message_id=email["message_id"],
                        sender_label=email.get("sender_name") or email.get("sender"),
                    )
                    if doc:
                        info_created += 1

        if created or info_created:
            db.commit()

        logger.info(
            "Email sync for user %s: scanned=%d tasks=%d info_docs=%d skipped_non_hebrew=%d "
            "skipped_no_signal=%d skipped_not_actionable=%d",
            user.id,
            len(emails),
            created,
            info_created,
            skipped_non_hebrew,
            skipped_no_signal,
            skipped_not_actionable,
        )
        return {
            "created": created,
            "info_created": info_created,
            "scanned": len(emails),
            "skipped_non_hebrew": skipped_non_hebrew,
            "skipped_no_keyword": skipped_no_signal,
            "skipped_no_signal": skipped_no_signal,
            "skipped_not_actionable": skipped_not_actionable,
            "fetch_errors": fetch_errors,
        }

    async def _fetch_emails(self, db: Session, user: User) -> tuple[list[dict], list[str]]:
        emails: list[dict] = []
        fetch_errors: list[str] = []

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
                fetch_errors.append(f"Gmail: {exc}")
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
                outlook_emails, new_refresh = await self.outlook.fetch_recent_emails(
                    user.outlook_refresh_token
                )
                emails.extend(outlook_emails)
                if new_refresh:
                    user.outlook_refresh_token = new_refresh
                    db.commit()
            except Exception as exc:
                logger.warning("Outlook fetch failed for user %s: %s", user.id, exc)
                fetch_errors.append(f"Outlook: {exc}")
        elif user.outlook_connected and not user.outlook_refresh_token:
            fetch_errors.append(
                "Outlook: missing refresh token — disconnect and reconnect Outlook in Integrations"
            )

        return emails, fetch_errors

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
