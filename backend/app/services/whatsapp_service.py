import hashlib
import hmac
import io
import logging
import re
import uuid

import httpx
from sqlalchemy.orm import Session

from app.config import settings
from app.models import User, WhatsAppInboundLog, WhatsAppSyncedChat
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
        db.query(WhatsAppSyncedChat).filter(WhatsAppSyncedChat.user_id == user.id).delete()
        db.commit()
        db.refresh(user)
        return user

    def list_synced_chats(self, db: Session, user: User) -> list[WhatsAppSyncedChat]:
        return (
            db.query(WhatsAppSyncedChat)
            .filter(WhatsAppSyncedChat.user_id == user.id)
            .order_by(WhatsAppSyncedChat.display_name.asc())
            .all()
        )

    async def fetch_green_chats(self) -> list[dict]:
        if not self.green_api_enabled:
            return []
        instance_id = settings.green_api_id_instance.strip()
        token = settings.green_api_token.strip()
        url = f"{self.green_api_base}/waInstance{instance_id}/getChats/{token}"
        try:
            async with httpx.AsyncClient(timeout=30) as client:
                response = await client.get(url)
                response.raise_for_status()
                data = response.json()
        except Exception as exc:
            logger.warning("Green API getChats failed: %s", exc)
            raise ValueError("Could not load WhatsApp chats. Check Green API configuration.") from exc

        rows = data if isinstance(data, list) else []
        chats: list[dict] = []
        for item in rows:
            if not isinstance(item, dict):
                continue
            chat_id = (item.get("id") or "").strip()
            if not chat_id:
                continue
            name = (
                item.get("name")
                or item.get("contactName")
                or item.get("chatName")
                or self.phone_from_chat_id(chat_id)
            )
            chat_type = "group" if chat_id.endswith("@g.us") else "direct"
            chats.append(
                {
                    "chat_id": chat_id,
                    "display_name": str(name).strip()[:255] or chat_id,
                    "chat_type": chat_type,
                }
            )
        chats.sort(key=lambda row: row["display_name"].lower())
        return chats

    async def list_chats_for_user(self, db: Session, user: User) -> dict:
        synced_rows = {
            row.chat_id: row for row in self.list_synced_chats(db, user)
        }
        synced_count = sum(1 for row in synced_rows.values() if row.sync_enabled)

        if not self.green_api_enabled:
            return {
                "chat_sync_available": False,
                "synced_count": synced_count,
                "chats": [
                    {
                        "chat_id": row.chat_id,
                        "display_name": row.display_name or row.chat_id,
                        "chat_type": row.chat_type,
                        "sync_enabled": row.sync_enabled,
                    }
                    for row in synced_rows.values()
                ],
            }

        available = await self.fetch_green_chats()
        merged: list[dict] = []
        seen: set[str] = set()
        for chat in available:
            seen.add(chat["chat_id"])
            synced = synced_rows.get(chat["chat_id"])
            merged.append(
                {
                    "chat_id": chat["chat_id"],
                    "display_name": chat["display_name"],
                    "chat_type": chat["chat_type"],
                    "sync_enabled": bool(synced and synced.sync_enabled),
                }
            )
        for chat_id, row in synced_rows.items():
            if chat_id in seen:
                continue
            merged.append(
                {
                    "chat_id": row.chat_id,
                    "display_name": row.display_name or row.chat_id,
                    "chat_type": row.chat_type,
                    "sync_enabled": row.sync_enabled,
                }
            )
        merged.sort(key=lambda row: row["display_name"].lower())
        synced_count = sum(1 for row in merged if row["sync_enabled"])
        return {
            "chat_sync_available": True,
            "synced_count": synced_count,
            "chats": merged,
        }

    def update_synced_chats(self, db: Session, user: User, selections: list[dict]) -> dict:
        existing = {
            row.chat_id: row
            for row in db.query(WhatsAppSyncedChat)
            .filter(WhatsAppSyncedChat.user_id == user.id)
            .all()
        }
        touched: set[str] = set()
        for sel in selections:
            chat_id = (sel.get("chat_id") or "").strip()
            if not chat_id:
                continue
            touched.add(chat_id)
            display_name = (sel.get("display_name") or chat_id).strip()[:255]
            chat_type = (sel.get("chat_type") or "direct").strip()[:20] or "direct"
            sync_enabled = bool(sel.get("sync_enabled", True))
            row = existing.get(chat_id)
            if row:
                row.display_name = display_name
                row.chat_type = chat_type
                row.sync_enabled = sync_enabled
            else:
                db.add(
                    WhatsAppSyncedChat(
                        id=str(uuid.uuid4()),
                        user_id=user.id,
                        chat_id=chat_id,
                        chat_type=chat_type,
                        display_name=display_name,
                        sync_enabled=sync_enabled,
                    )
                )
        for chat_id, row in existing.items():
            if chat_id not in touched:
                row.sync_enabled = False
        db.commit()
        synced_count = (
            db.query(WhatsAppSyncedChat)
            .filter(
                WhatsAppSyncedChat.user_id == user.id,
                WhatsAppSyncedChat.sync_enabled.is_(True),
            )
            .count()
        )
        rows = self.list_synced_chats(db, user)
        return {
            "chat_sync_available": self.green_api_enabled,
            "synced_count": synced_count,
            "chats": [
                {
                    "chat_id": row.chat_id,
                    "display_name": row.display_name or row.chat_id,
                    "chat_type": row.chat_type,
                    "sync_enabled": row.sync_enabled,
                }
                for row in rows
                if row.sync_enabled or row.chat_id in touched
            ],
        }

    def resolve_inbound_user(
        self, db: Session, *, phone: str, chat_id: str | None = None
    ) -> User | None:
        if chat_id:
            rows = (
                db.query(WhatsAppSyncedChat)
                .filter(
                    WhatsAppSyncedChat.chat_id == chat_id,
                    WhatsAppSyncedChat.sync_enabled.is_(True),
                )
                .all()
            )
            if len(rows) == 1:
                return rows[0].user
            if len(rows) > 1:
                logger.warning("WhatsApp: chat %s synced by multiple users — skipping", chat_id)
                return None

        user = self.find_user_by_phone(db, phone)
        if not user:
            return None

        synced_ids = {
            row.chat_id
            for row in db.query(WhatsAppSyncedChat)
            .filter(
                WhatsAppSyncedChat.user_id == user.id,
                WhatsAppSyncedChat.sync_enabled.is_(True),
            )
            .all()
        }
        if synced_ids and chat_id and chat_id not in synced_ids:
            return None
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
        chat_id: str | None = None,
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
            chat_id=chat_id,
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
        if not chat_id:
            return None

        sender = sender_data.get("sender") or chat_id
        phone = self.normalize_phone(self.phone_from_chat_id(sender))
        message_id = payload.get("idMessage") or f"green-{uuid.uuid4().hex[:12]}"
        message_data = payload.get("messageData") or {}
        type_message = message_data.get("typeMessage") or ""
        chat_name = (
            sender_data.get("chatName")
            or sender_data.get("senderName")
            or sender_data.get("senderContactName")
            or ""
        ).strip()
        is_group = chat_id.endswith("@g.us")

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
                "chat_id": chat_id,
                "chat_name": chat_name,
                "is_group": is_group,
            }

        return {
            "from": phone,
            "id": message_id,
            "type": msg_type,
            "text": text.strip(),
            "audio_url": audio_url,
            "chat_id": chat_id,
            "chat_name": chat_name,
            "is_group": is_group,
        }

    async def handle_green_webhook(self, db: Session, payload: dict) -> None:
        parsed = self.parse_green_inbound(payload)
        if not parsed:
            return

        message = {
            "from": parsed["from"],
            "id": parsed["id"],
            "type": parsed["type"],
            "chat_id": parsed.get("chat_id"),
            "chat_name": parsed.get("chat_name"),
            "is_group": parsed.get("is_group", False),
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
        chat_id = message.get("chat_id") or None
        chat_name = (message.get("chat_name") or "").strip()
        is_group = bool(message.get("is_group"))
        logger.info(
            "WhatsApp inbound from=%s chat=%s type=%s id=%s",
            phone,
            chat_id,
            msg_type,
            message_id,
        )

        user = self.resolve_inbound_user(db, phone=phone, chat_id=chat_id)
        if not user:
            if chat_id:
                status = "chat_not_synced"
                logger.warning(
                    "WhatsApp: no synced user for chat %s from %s. "
                    "Select this chat in Settings -> Integrations -> WhatsApp.",
                    chat_id,
                    self.normalize_phone(phone),
                )
            else:
                status = "no_user"
                logger.warning(
                    "WhatsApp: ignoring message from unregistered phone %s (normalized %s). "
                    "No reply sent. Link number in app: Settings -> Integrations -> WhatsApp",
                    phone,
                    self.normalize_phone(phone),
                )
            self._record_inbound(
                db,
                from_phone=phone,
                chat_id=chat_id,
                message_id=message_id,
                msg_type=msg_type,
                body_text=None,
                user_id=None,
                task_id=None,
                bot_reply=None,
                status=status,
            )
            return None, "", status

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
            logger.info("WhatsApp: unsupported type=%s — no reply", msg_type)
            self._record_inbound(
                db,
                from_phone=phone,
                chat_id=chat_id,
                message_id=message_id,
                msg_type=msg_type,
                body_text=None,
                user_id=user.id,
                task_id=None,
                bot_reply=None,
                status="unsupported_type",
            )
            return None, "", "unsupported_type"

        if not transcript.strip():
            logger.info("WhatsApp: empty transcript — no reply")
            self._record_inbound(
                db,
                from_phone=phone,
                chat_id=chat_id,
                message_id=message_id,
                msg_type=msg_type,
                body_text=None,
                user_id=user.id,
                task_id=None,
                bot_reply=None,
                status="empty_transcript",
            )
            return None, "", "empty_transcript"

        if is_group and chat_name:
            transcript = f"[{chat_name}] {transcript}"

        task, reply, status = self._create_task_from_transcript(
            db,
            user,
            transcript,
            whatsapp_message_id=message_id,
            sender_name=f"WhatsApp · {chat_name}" if chat_name else "WhatsApp",
        )
        # Outbound only when registered user + keyword משימה + task actually created
        send_reply = status == "task_created" and bool(reply.strip())
        if send_reply:
            await self.send_text(phone, reply)
        else:
            logger.info(
                "WhatsApp: no outbound reply (status=%s) for %s",
                status,
                self.normalize_phone(phone),
            )
        self._record_inbound(
            db,
            from_phone=phone,
            chat_id=chat_id,
            message_id=message_id,
            msg_type=msg_type,
            body_text=transcript,
            user_id=user.id,
            task_id=task.id if task else None,
            bot_reply=reply if send_reply else None,
            status=status,
        )
        return task, reply if send_reply else "", status

    def _create_task_from_transcript(
        self,
        db: Session,
        user: User,
        transcript: str,
        *,
        whatsapp_message_id: str | None = None,
        sender_name: str = "WhatsApp",
    ) -> tuple[object | None, str, str]:
        analysis, source = self.ai.analyze_whatsapp_transcript(transcript)
        if not analysis:
            if source == "skipped_not_hebrew":
                return None, "רק הודעות בעברית נתמכות כרגע. שלחו משימה בעברית.", "not_hebrew"
            if source in {"openai_not_actionable", "no_task_detected", "skipped_no_task_signal"}:
                return (
                    None,
                    "",
                    "no_task_detected",
                )
            return (
                None,
                "לא זוהתה משימה בהודעה. נסו לנסח ברור יותר, למשל: \"תשלח את הדוח עד מחר\".",
                "no_task_detected",
            )

        task = create_task_from_analysis(
            db,
            user,
            analysis,
            source_subject=transcript[:200],
            source_snippet=transcript,
            whatsapp_message_id=whatsapp_message_id,
            sender_name=sender_name,
            source_label=f"whatsapp_{source}",
        )
        if not task:
            return None, "המשימה כבר קיימת.", "task_duplicate"

        return task, self._format_task_created_reply(task), "task_created"

    def _format_task_created_reply(self, task: object) -> str:
        priority_he = {
            "critical": "קריטי",
            "high": "גבוהה",
            "medium": "בינונית",
            "low": "נמוכה",
            "none": "ללא",
        }
        category_he = {
            "work": "עבודה",
            "errands": "סידורים",
            "health": "בריאות",
            "general": "כללי",
        }

        lines = [
            "✅ נוצרה משימה",
            f"כותרת: {task.title}",
        ]
        if getattr(task, "description", None):
            desc = str(task.description).strip()
            if desc and desc != task.title:
                lines.append(f"תיאור: {desc[:300]}")

        priority = getattr(task, "priority", None) or "none"
        lines.append(f"עדיפות: {priority_he.get(priority, priority)}")

        category = getattr(task, "category", None) or "general"
        lines.append(f"קטגוריה: {category_he.get(category, category)}")

        deadline = getattr(task, "deadline", None)
        if deadline:
            try:
                lines.append(f"תאריך יעד: {deadline.strftime('%d/%m/%Y %H:%M')}")
            except Exception:
                lines.append(f"תאריך יעד: {deadline}")

        task_id = getattr(task, "id", None)
        if task_id:
            lines.append(f"מזהה: {task_id}")

        return "\n".join(lines)

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
