import json
import logging

from sqlalchemy.orm import Session

from app.core.security import new_id
from app.models import DailyBrief, DeviceToken, Task, UserSettings

logger = logging.getLogger(__name__)


class SettingsService:
    def get_or_create(self, db, user_id: str) -> UserSettings:
        settings = db.get(UserSettings, user_id)
        if not settings:
            settings = UserSettings(user_id=user_id)
            db.add(settings)
            db.commit()
            db.refresh(settings)
        return settings

    def update(self, db, user_id: str, updates: dict) -> UserSettings:
        settings = self.get_or_create(db, user_id)
        for key, value in updates.items():
            if value is not None and hasattr(settings, key):
                setattr(settings, key, value)
        db.commit()
        db.refresh(settings)
        return settings


class NotificationService:
    def register_device(self, db, user_id: str, fcm_token: str, platform: str) -> None:
        existing = (
            db.query(DeviceToken)
            .filter(DeviceToken.user_id == user_id, DeviceToken.fcm_token == fcm_token)
            .one_or_none()
        )
        if existing:
            existing.platform = platform
        else:
            db.add(DeviceToken(id=new_id(), user_id=user_id, fcm_token=fcm_token, platform=platform))
        db.commit()

    def send_task_notification(self, db, user_id: str, task_id: str, title: str, body: str) -> None:
        try:
            import firebase_admin
            from firebase_admin import credentials, messaging

            from app.config import settings

            settings_row = db.get(UserSettings, user_id)
            if settings_row is not None and not settings_row.push_notifications_enabled:
                return

            if not firebase_admin._apps:
                if not settings.firebase_credentials_path:
                    logger.debug("FCM skipped: FIREBASE_CREDENTIALS_PATH not set")
                    return
                cred = credentials.Certificate(settings.firebase_credentials_path)
                firebase_admin.initialize_app(cred)

            tokens = db.query(DeviceToken).filter(DeviceToken.user_id == user_id).all()
            if not tokens:
                logger.debug("FCM skipped: no device tokens for user %s", user_id)
                return

            sent = 0
            for token in tokens:
                messaging.send(
                    messaging.Message(
                        notification=messaging.Notification(title=title, body=body),
                        data={"taskId": task_id},
                        token=token.fcm_token,
                    )
                )
                sent += 1
            logger.info("FCM sent task notification to %d device(s) for task %s", sent, task_id)
        except Exception as exc:
            logger.warning("FCM send failed for task %s: %s", task_id, exc)


class DailyBriefService:
    def get_latest(self, db, user_id: str) -> DailyBrief | None:
        return (
            db.query(DailyBrief)
            .filter(DailyBrief.user_id == user_id)
            .order_by(DailyBrief.generated_at.desc())
            .first()
        )

    def brief_to_response(self, db, brief: DailyBrief) -> dict:
        task_ids = json.loads(brief.highlighted_task_ids_json or "[]")
        tasks = db.query(Task).filter(Task.id.in_(task_ids)).all() if task_ids else []
        task_map = {t.id: t for t in tasks}
        highlighted = [task_map[tid] for tid in task_ids if tid in task_map]
        return {
            "id": brief.id,
            "summary": brief.summary,
            "content": brief.content,
            "generated_at": brief.generated_at,
            "highlighted_tasks": highlighted,
            "insights": json.loads(brief.insights_json or "[]"),
        }
