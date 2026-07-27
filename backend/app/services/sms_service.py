"""Inbound SMS → AI task creation (Twilio-compatible + generic JSON webhook)."""

from __future__ import annotations

import base64
import hashlib
import hmac
import logging
import re

import httpx
from sqlalchemy.orm import Session

from app.config import settings
from app.core.security import new_id
from app.models import SmsInboundLog, User
from app.services.ai_service import AIService
from app.services.task_ingest_service import create_task_from_analysis

logger = logging.getLogger(__name__)


class SmsService:
    def __init__(self) -> None:
        self.ai = AIService()

    @property
    def twilio_enabled(self) -> bool:
        return settings.twilio_enabled

    @staticmethod
    def normalize_phone(raw: str) -> str:
        digits = re.sub(r"\D", "", raw or "")
        if digits.startswith("0"):
            digits = f"972{digits[1:]}"
        elif len(digits) == 9:
            digits = f"972{digits}"
        return digits

    def link_phone(self, db: Session, user: User, phone: str) -> User:
        normalized = self.normalize_phone(phone)
        if len(normalized) < 10:
            raise ValueError("Invalid phone number")

        if user.sms_phone == normalized:
            return user

        other = (
            db.query(User)
            .filter(User.sms_phone == normalized, User.id != user.id)
            .one_or_none()
        )
        if other:
            raise ValueError(
                "PHONE_ALREADY_LINKED: This number is linked to another account. "
                "Sign in with that account or disconnect SMS there first."
            )

        user.sms_phone = normalized
        db.commit()
        db.refresh(user)
        return user

    def unlink_phone(self, db: Session, user: User) -> User:
        user.sms_phone = None
        db.commit()
        db.refresh(user)
        return user

    def find_user_by_phone(self, db: Session, phone: str) -> User | None:
        normalized = self.normalize_phone(phone)
        user = db.query(User).filter(User.sms_phone == normalized).one_or_none()
        if user:
            return user
        # Allow WhatsApp-linked number to receive SMS webhooks too
        return db.query(User).filter(User.whatsapp_phone == normalized).one_or_none()

    def _inbound_logs_query(self, db: Session, user: User):
        q = db.query(SmsInboundLog)
        if user.sms_phone:
            q = q.filter(
                (SmsInboundLog.user_id == user.id) | (SmsInboundLog.from_phone == user.sms_phone)
            )
        else:
            q = q.filter(SmsInboundLog.user_id == user.id)
        return q.order_by(SmsInboundLog.created_at.desc())

    def get_inbound_status(self, db: Session, user: User, recent_limit: int = 10) -> dict:
        rows = self._inbound_logs_query(db, user).limit(recent_limit).all()
        latest = rows[0] if rows else None

        def _row(log: SmsInboundLog) -> dict:
            return {
                "id": log.id,
                "from_phone": log.from_phone,
                "message_id": log.message_id,
                "body_text": log.body_text,
                "task_id": log.task_id,
                "bot_reply": log.bot_reply,
                "status": log.status,
                "created_at": log.created_at,
            }

        return {
            "linked_phone": user.sms_phone,
            "has_messages": bool(rows),
            "latest": _row(latest) if latest else None,
            "recent": [_row(r) for r in rows],
        }

    def _record_inbound(
        self,
        db: Session,
        *,
        from_phone: str,
        message_id: str | None,
        body_text: str | None,
        user_id: str | None,
        task_id: str | None,
        bot_reply: str | None,
        status: str,
    ) -> None:
        db.add(
            SmsInboundLog(
                id=new_id(),
                user_id=user_id,
                from_phone=self.normalize_phone(from_phone),
                message_id=message_id,
                body_text=body_text,
                task_id=task_id,
                bot_reply=bot_reply,
                status=status,
            )
        )
        db.commit()

    def verify_twilio_signature(
        self,
        *,
        url: str,
        params: dict[str, str],
        signature: str | None,
    ) -> bool:
        token = (settings.twilio_auth_token or "").strip()
        if not token:
            # No token configured — allow (dev) but log.
            logger.warning("Twilio auth token empty — skipping signature check")
            return True
        if not signature:
            return False
        # Twilio: Base64(HMAC-SHA1(url + sorted params))
        data = url
        for key in sorted(params.keys()):
            data += key + (params.get(key) or "")
        digest = hmac.new(token.encode("utf-8"), data.encode("utf-8"), hashlib.sha1).digest()
        expected = base64.b64encode(digest).decode("utf-8")
        return hmac.compare_digest(expected, signature)

    def verify_shared_token(self, header_token: str | None) -> bool:
        expected = (settings.sms_webhook_token or "").strip()
        if not expected:
            return True
        return bool(header_token) and hmac.compare_digest(expected, header_token)

    async def handle_inbound(
        self,
        db: Session,
        *,
        from_phone: str,
        text: str,
        message_id: str | None = None,
    ) -> tuple[object | None, str, str]:
        phone = self.normalize_phone(from_phone)
        body = (text or "").strip()
        user = self.find_user_by_phone(db, phone)

        if not user:
            logger.info("SMS: no user for phone %s", phone)
            self._record_inbound(
                db,
                from_phone=phone,
                message_id=message_id,
                body_text=body or None,
                user_id=None,
                task_id=None,
                bot_reply=None,
                status="no_user",
            )
            return None, "", "no_user"

        if not body:
            self._record_inbound(
                db,
                from_phone=phone,
                message_id=message_id,
                body_text=None,
                user_id=user.id,
                task_id=None,
                bot_reply=None,
                status="empty",
            )
            return None, "", "empty"

        task, reply, status = self._create_task_from_text(
            db, user, body, sms_message_id=message_id
        )
        send_reply = status == "task_created" and bool(reply.strip())
        if send_reply:
            await self.send_text(phone, reply)
        self._record_inbound(
            db,
            from_phone=phone,
            message_id=message_id,
            body_text=body,
            user_id=user.id,
            task_id=task.id if task else None,
            bot_reply=reply if send_reply else None,
            status=status,
        )
        return task, reply if send_reply else "", status

    def _create_task_from_text(
        self,
        db: Session,
        user: User,
        transcript: str,
        *,
        sms_message_id: str | None = None,
        sender_name: str | None = None,
    ) -> tuple[object | None, str, str]:
        analysis, source = self.ai.analyze_sms_transcript(transcript)
        if not analysis:
            if source == "skipped_not_hebrew":
                return None, "רק הודעות בעברית נתמכות כרגע.", "not_hebrew"
            return None, "", "no_task_detected"

        task = create_task_from_analysis(
            db,
            user,
            analysis,
            source_subject=transcript[:200],
            source_snippet=transcript,
            sms_message_id=sms_message_id,
            sender_name=(sender_name or "SMS")[:200],
            source_label=f"sms_{source}",
        )
        if not task:
            return None, "המשימה כבר קיימת.", "task_duplicate"

        return task, self._format_task_created_reply(task), "task_created"

    def ingest_device_messages(
        self,
        db: Session,
        user: User,
        messages: list[dict],
    ) -> dict:
        """JWT user uploads recent SMS from their device; create tasks where AI detects them."""
        created: list[dict] = []
        skipped: list[dict] = []
        # Cap batch size to keep AI cost / latency bounded (mobile batches if larger)
        batch = list(messages)[:100]

        for raw in batch:
            message_id = str(raw.get("message_id") or "").strip()
            body = str(raw.get("body") or "").strip()
            from_address = str(raw.get("from_address") or "").strip() or None

            if not message_id:
                skipped.append({"message_id": "", "reason": "missing_message_id"})
                continue
            if not body:
                skipped.append({"message_id": message_id, "reason": "empty"})
                continue

            task, _reply, status = self._create_task_from_text(
                db,
                user,
                body,
                sms_message_id=message_id,
                sender_name=from_address or "SMS",
            )

            if from_address:
                phone_for_log = self.normalize_phone(from_address)[:20] or from_address[:20]
            else:
                phone_for_log = (user.sms_phone or "device")[:20]

            if status == "task_created" and task is not None:
                created.append(
                    {
                        "task_id": task.id,
                        "message_id": message_id,
                        "title": task.title,
                    }
                )
                self._record_inbound(
                    db,
                    from_phone=phone_for_log[:20],
                    message_id=message_id,
                    body_text=body,
                    user_id=user.id,
                    task_id=task.id,
                    bot_reply=None,
                    status="task_created",
                )
            else:
                reason = status or "no_task_detected"
                skipped.append({"message_id": message_id, "reason": reason})
                if reason not in {"task_duplicate"}:
                    self._record_inbound(
                        db,
                        from_phone=phone_for_log[:20],
                        message_id=message_id,
                        body_text=body,
                        user_id=user.id,
                        task_id=None,
                        bot_reply=None,
                        status=reason[:30],
                    )

        return {
            "processed": len(batch),
            "created_count": len(created),
            "created": created,
            "skipped": skipped,
        }

    def _format_task_created_reply(self, task: object) -> str:
        lines = ["✅ נוצרה משימה מ-SMS", f"כותרת: {task.title}"]
        if getattr(task, "deadline", None):
            lines.append(f"מועד: {task.deadline}")
        return "\n".join(lines)

    def simulate_task(self, db: Session, user: User, transcript: str) -> dict:
        task, reply, _status = self._create_task_from_text(db, user, transcript)
        return {
            "created": task is not None,
            "task_id": task.id if task else None,
            "message": reply or ("לא זוהתה משימה" if task is None else ""),
        }

    async def dev_inbound_message(self, db: Session, phone: str, text: str) -> dict:
        task, reply, status = await self.handle_inbound(
            db,
            from_phone=phone,
            text=text,
            message_id=f"dev-sms-{new_id()[:8]}",
        )
        return {
            "created": task is not None,
            "task_id": task.id if task else None,
            "message": reply or status,
        }

    async def send_text(self, to_phone: str, body: str) -> bool:
        if not self.twilio_enabled or not body.strip():
            return False
        to = self.normalize_phone(to_phone)
        if not to.startswith("+"):
            to = f"+{to}"
        from_number = settings.twilio_from_number.strip()
        url = (
            f"https://api.twilio.com/2010-04-01/Accounts/"
            f"{settings.twilio_account_sid.strip()}/Messages.json"
        )
        try:
            async with httpx.AsyncClient(timeout=30) as client:
                response = await client.post(
                    url,
                    data={"To": to, "From": from_number, "Body": body},
                    auth=(settings.twilio_account_sid.strip(), settings.twilio_auth_token.strip()),
                )
                if response.status_code >= 400:
                    logger.warning("Twilio SMS send failed: %s %s", response.status_code, response.text[:300])
                    return False
                return True
        except Exception as exc:
            logger.warning("Twilio SMS send error: %s", exc)
            return False
