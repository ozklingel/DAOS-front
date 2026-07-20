import hashlib
import hmac
import io
import logging
import re
import uuid

import httpx
from sqlalchemy.orm import Session

from app.config import settings
from app.models import User, WhatsAppInboundLog
from app.services.ai_service import AIService
from app.services.task_ingest_service import create_task_from_analysis

logger = logging.getLogger(__name__)


class WhatsAppService:
    def __init__(self) -> None:
        self.ai = AIService()

    @property
    def graph_api_base(self) -> str:
        version = settings.whatsapp_graph_api_version.strip() or "v25.0"
        if not version.startswith("v"):
            version = f"v{version}"
        return f"https://graph.facebook.com/{version}"

    @property
    def enabled(self) -> bool:
        return bool(settings.whatsapp_access_token and settings.whatsapp_phone_number_id)

    @property
    def green_api_enabled(self) -> bool:
        return settings.green_api_enabled

    @property
    def messaging_enabled(self) -> bool:
        return self.green_api_enabled or self.enabled

    @property
    def green_api_base(self) -> str:
        base = settings.green_api_url.strip().rstrip("/")
        return base or "https://api.green-api.com"

    @staticmethod
    def phone_from_chat_id(chat_id: str) -> str:
        return (chat_id or "").split("@")[0].split(":")[0]

    def phone_to_chat_id(self, phone: str) -> str:
        return f"{self.normalize_phone(phone)}@c.us"

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

        if user.whatsapp_phone == normalized:
            return user

        other = (
            db.query(User)
            .filter(User.whatsapp_phone == normalized, User.id != user.id)
            .one_or_none()
        )
        if other:
            raise ValueError(
                "PHONE_ALREADY_LINKED: This number is linked to another account. "
                "Sign in with that account or disconnect WhatsApp there first."
            )

        user.whatsapp_phone = normalized
        db.commit()
        db.refresh(user)
        return user

    def unlink_phone(self, db: Session, user: User) -> User:
        user.whatsapp_phone = None
        db.commit()
        db.refresh(user)
        return user

    def find_user_by_phone(self, db: Session, phone: str) -> User | None:
        normalized = self.normalize_phone(phone)
        return db.query(User).filter(User.whatsapp_phone == normalized).one_or_none()

    def _inbound_logs_query(self, db: Session, user: User):
        q = db.query(WhatsAppInboundLog)
        if user.whatsapp_phone:
            q = q.filter(
                (WhatsAppInboundLog.user_id == user.id)
                | (WhatsAppInboundLog.from_phone == user.whatsapp_phone)
            )
        else:
            q = q.filter(WhatsAppInboundLog.user_id == user.id)
        return q.order_by(WhatsAppInboundLog.created_at.desc())

    def get_inbound_status(self, db: Session, user: User, *, recent_limit: int = 10) -> dict:
        q = self._inbound_logs_query(db, user)
        recent = q.limit(recent_limit).all()
        latest = recent[0] if recent else None
        return {
            "linked_phone": user.whatsapp_phone,
            "has_messages": bool(recent),
            "latest": latest,
            "recent": recent,
        }

    def _record_inbound(
        self,
        db: Session,
        *,
        from_phone: str,
        message_id: str | None,
        msg_type: str,
        body_text: str | None,
        user_id: str | None,
        task_id: str | None,
        bot_reply: str | None,
        status: str,
    ) -> WhatsAppInboundLog:
        log = WhatsAppInboundLog(
            id=str(uuid.uuid4()),
            user_id=user_id,
            from_phone=self.normalize_phone(from_phone),
            message_id=message_id or None,
            msg_type=msg_type or "unknown",
            body_text=body_text,
            task_id=task_id,
            bot_reply=bot_reply,
            status=status,
        )
        db.add(log)
        db.commit()
        db.refresh(log)
        return log

    def verify_signature(self, payload: bytes, signature: str | None) -> bool:
        secret = settings.whatsapp_app_secret_effective
        if not secret:
            if signature:
                logger.debug("WhatsApp webhook: skipping signature check (WHATSAPP_APP_SECRET not set)")
            return True
        if not signature or not signature.startswith("sha256="):
            return False
        expected = hmac.new(
            secret.encode(),
            payload,
            hashlib.sha256,
        ).hexdigest()
        return hmac.compare_digest(signature[7:], expected)

    async def handle_webhook(self, db: Session, payload: dict) -> None:
        obj = payload.get("object")
        entries = payload.get("entry", [])
        logger.info("WhatsApp webhook: object=%s entries=%d", obj, len(entries))
        if obj != "whatsapp_business_account":
            logger.warning("WhatsApp webhook ignored: unexpected object=%s", obj)
            return

        message_count = 0
        for entry in entries:
            for change in entry.get("changes", []):
                value = change.get("value", {})
                field = change.get("field", "")
                messages = value.get("messages", [])
                if not messages:
                    logger.info(
                        "WhatsApp webhook change field=%s (no messages — status/delivery?)",
                        field,
                    )
                    continue
                for message in messages:
                    message_count += 1
                    await self._handle_inbound_message(db, message)
        logger.info("WhatsApp webhook processed %d message(s)", message_count)

    def parse_green_inbound(self, payload: dict) -> dict | None:
        if payload.get("typeWebhook") != "incomingMessageReceived":
            return None

        sender_data = payload.get("senderData") or {}
        chat_id = sender_data.get("chatId") or ""
        if chat_id.endswith("@g.us"):
            logger.info("Green API: ignoring group chatId=%s", chat_id)
            return None

        sender = sender_data.get("sender") or chat_id
        phone = self.normalize_phone(self.phone_from_chat_id(sender))
        message_id = payload.get("idMessage") or f"green-{uuid.uuid4().hex[:12]}"
        message_data = payload.get("messageData") or {}
        type_message = message_data.get("typeMessage") or ""

        text = ""
        audio_url = None
        msg_type = "text"

        if type_message == "textMessage":
            text = (message_data.get("textMessageData") or {}).get("textMessage") or ""
        elif type_message == "extendedTextMessage":
            text = (message_data.get("extendedTextMessageData") or {}).get("text") or ""
        elif type_message == "quotedMessage":
            text = (message_data.get("extendedTextMessageData") or {}).get("text") or ""
        elif type_message == "audioMessage":
            msg_type = "audio"
            audio_url = (message_data.get("fileMessageData") or {}).get("downloadUrl")
        else:
            logger.info("Green API: unsupported typeMessage=%s", type_message)
            return {
                "from": phone,
                "id": message_id,
                "type": "unsupported",
                "text": "",
                "audio_url": None,
            }

        return {
            "from": phone,
            "id": message_id,
            "type": msg_type,
            "text": text.strip(),
            "audio_url": audio_url,
        }

    async def handle_green_webhook(self, db: Session, payload: dict) -> None:
        parsed = self.parse_green_inbound(payload)
        if not parsed:
            return

        message = {
            "from": parsed["from"],
            "id": parsed["id"],
            "type": parsed["type"],
        }
        if parsed["type"] == "text":
            message["text"] = {"body": parsed["text"]}
        elif parsed["type"] == "audio" and parsed["audio_url"]:
            message["audio_url"] = parsed["audio_url"]

        await self._handle_inbound_message(db, message)

    async def dev_inbound_message(self, db: Session, phone: str, text: str) -> dict:
        normalized = self.normalize_phone(phone)
        message = {
            "from": normalized,
            "id": f"dev-inbound-{uuid.uuid4().hex[:12]}",
            "type": "text",
            "text": {"body": text.strip()},
        }
        task, reply, _status = await self._handle_inbound_message(db, message)
        return {
            "created": task is not None,
            "task_id": task.id if task else None,
            "message": reply,
        }

    async def _handle_inbound_message(
        self, db: Session, message: dict
    ) -> tuple[object | None, str, str]:
        phone = message.get("from", "")
        message_id = message.get("id", "") or None
        msg_type = message.get("type", "") or "unknown"
        logger.info("WhatsApp inbound from=%s type=%s id=%s", phone, msg_type, message_id)

        user = self.find_user_by_phone(db, phone)
        if not user:
            logger.warning(
                "WhatsApp: no user linked for phone %s (normalized %s). "
                "Link this number in app: Settings -> Integrations -> WhatsApp",
                phone,
                self.normalize_phone(phone),
            )
            reply = "שלום! כדי ליצור משימות מ-WhatsApp, חברו את מספר הטלפון שלכם בהגדרות → אינטגרציות."
            await self.send_text(phone, reply)
            self._record_inbound(
                db,
                from_phone=phone,
                message_id=message_id,
                msg_type=msg_type,
                body_text=None,
                user_id=None,
                task_id=None,
                bot_reply=reply,
                status="no_user",
            )
            return None, reply, "no_user"

        transcript = ""
        if msg_type == "text":
            transcript = (message.get("text") or {}).get("body", "").strip()
        elif msg_type == "audio":
            audio_bytes = None
            if message.get("audio_url"):
                audio_bytes = await self._download_green_media(message["audio_url"])
            else:
                media_id = (message.get("audio") or {}).get("id")
                if media_id:
                    audio_bytes = await self._download_media(media_id)
            if audio_bytes:
                transcript = self.ai.transcribe_audio(audio_bytes) or ""
        else:
            reply = "שלחו הודעת קול או טקסט בעברית כדי ליצור משימה."
            await self.send_text(phone, reply)
            self._record_inbound(
                db,
                from_phone=phone,
                message_id=message_id,
                msg_type=msg_type,
                body_text=None,
                user_id=user.id,
                task_id=None,
                bot_reply=reply,
                status="unsupported_type",
            )
            return None, reply, "unsupported_type"

        if not transcript.strip():
            reply = "לא הצלחתי להבין את ההודעה. נסו שוב."
            await self.send_text(phone, reply)
            self._record_inbound(
                db,
                from_phone=phone,
                message_id=message_id,
                msg_type=msg_type,
                body_text=transcript or None,
                user_id=user.id,
                task_id=None,
                bot_reply=reply,
                status="empty_transcript",
            )
            return None, reply, "empty_transcript"

        task, reply, status = self._create_task_from_transcript(
            db, user, transcript, whatsapp_message_id=message_id
        )
        await self.send_text(phone, reply)
        self._record_inbound(
            db,
            from_phone=phone,
            message_id=message_id,
            msg_type=msg_type,
            body_text=transcript,
            user_id=user.id,
            task_id=task.id if task else None,
            bot_reply=reply,
            status=status,
        )
        return task, reply, status

    def _create_task_from_transcript(
        self,
        db: Session,
        user: User,
        transcript: str,
        *,
        whatsapp_message_id: str | None = None,
    ) -> tuple[object | None, str, str]:
        analysis, source = self.ai.analyze_voice_transcript(transcript)
        if not analysis:
            if source == "skipped_not_hebrew":
                return None, "רק הודעות בעברית נתמכות כרגע. שלחו משימה בעברית.", "not_hebrew"
            return (
                None,
                "לא זוהתה משימה בהודעה. נסו לנסח ברור יותר, למשל: \"משימה: לשלוח דוח\".",
                "no_task_detected",
            )

        task = create_task_from_analysis(
            db,
            user,
            analysis,
            source_subject=transcript[:200],
            source_snippet=transcript,
            whatsapp_message_id=whatsapp_message_id,
            sender_name="WhatsApp",
            source_label=f"whatsapp_{source}",
        )
        if not task:
            return None, "המשימה כבר קיימת.", "task_duplicate"

        title = task.title
        return task, f"✅ נוצרה משימה ({source}):\n{title}", "task_created"

    def simulate_voice_task(self, db: Session, user: User, transcript: str) -> dict:
        task, reply, _status = self._create_task_from_transcript(db, user, transcript)
        return {
            "created": task is not None,
            "task_id": task.id if task else None,
            "message": reply,
        }

    async def _download_green_media(self, url: str) -> bytes | None:
        if not url or url.startswith("{{"):
            return None
        try:
            async with httpx.AsyncClient(timeout=60) as client:
                response = await client.get(url)
                response.raise_for_status()
                return response.content
        except Exception as exc:
            logger.warning("Green API media download failed: %s", exc)
            return None

    async def _download_media(self, media_id: str) -> bytes | None:
        if not self.enabled:
            return None
        headers = {"Authorization": f"Bearer {settings.whatsapp_access_token}"}
        try:
            async with httpx.AsyncClient(timeout=30) as client:
                meta = await client.get(f"{self.graph_api_base}/{media_id}", headers=headers)
                meta.raise_for_status()
                url = meta.json().get("url")
                if not url:
                    return None
                media = await client.get(url, headers=headers)
                media.raise_for_status()
                return media.content
        except Exception as exc:
            logger.warning("WhatsApp media download failed: %s", exc)
            return None

    async def send_text(self, to_phone: str, body: str) -> None:
        if self.green_api_enabled:
            await self._green_send_text(to_phone, body)
            return
        if not self.enabled:
            logger.info("WhatsApp reply (not sent — not configured) to %s: %s", to_phone, body[:120])
            return

        url = f"{self.graph_api_base}/{settings.whatsapp_phone_number_id}/messages"
        headers = {
            "Authorization": f"Bearer {settings.whatsapp_access_token}",
            "Content-Type": "application/json",
        }
        payload = {
            "messaging_product": "whatsapp",
            "to": self.normalize_phone(to_phone),
            "type": "text",
            "text": {"body": body[:4096]},
        }
        try:
            async with httpx.AsyncClient(timeout=15) as client:
                response = await client.post(url, headers=headers, json=payload)
                response.raise_for_status()
                logger.info("WhatsApp text sent to %s", self.normalize_phone(to_phone))
        except httpx.HTTPStatusError as exc:
            detail = exc.response.text[:500] if exc.response is not None else str(exc)
            logger.warning(
                "WhatsApp send failed to %s (%s): %s",
                to_phone,
                exc.response.status_code if exc.response is not None else "?",
                detail,
            )
        except Exception as exc:
            logger.warning("WhatsApp send failed to %s: %s", to_phone, exc)

    async def _green_send_text(self, to_phone: str, body: str) -> None:
        instance_id = settings.green_api_id_instance.strip()
        token = settings.green_api_token.strip()
        url = f"{self.green_api_base}/waInstance{instance_id}/sendMessage/{token}"
        payload = {
            "chatId": self.phone_to_chat_id(to_phone),
            "message": body[:4096],
        }
        try:
            async with httpx.AsyncClient(timeout=15) as client:
                response = await client.post(url, json=payload)
                response.raise_for_status()
                logger.info("Green API text sent to %s", self.normalize_phone(to_phone))
        except httpx.HTTPStatusError as exc:
            detail = exc.response.text[:500] if exc.response is not None else str(exc)
            logger.warning(
                "Green API send failed to %s (%s): %s",
                to_phone,
                exc.response.status_code if exc.response is not None else "?",
                detail,
            )
        except Exception as exc:
            logger.warning("Green API send failed to %s: %s", to_phone, exc)
