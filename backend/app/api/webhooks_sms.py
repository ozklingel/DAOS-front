"""SMS inbound webhooks — Twilio form POST + generic JSON."""

from __future__ import annotations

import logging

from fastapi import APIRouter, BackgroundTasks, Header, HTTPException, Request, Response

from app.database import SessionLocal
from app.services.sms_service import SmsService

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/webhooks", tags=["webhooks"])
sms_service = SmsService()


async def _process_inbound(from_phone: str, text: str, message_id: str | None) -> None:
    db = SessionLocal()
    try:
        await sms_service.handle_inbound(
            db,
            from_phone=from_phone,
            text=text,
            message_id=message_id,
        )
    except Exception:
        logger.exception("SMS webhook processing failed")
    finally:
        db.close()


@router.post("/sms")
@router.post("/sms/twilio")
async def sms_webhook(
    request: Request,
    background_tasks: BackgroundTasks,
    x_twilio_signature: str | None = Header(default=None, alias="X-Twilio-Signature"),
    x_daos_sms_token: str | None = Header(default=None, alias="X-DAOS-SMS-Token"),
):
    """
    Inbound SMS webhook.

    Supports:
    - Twilio: application/x-www-form-urlencoded with From, Body, MessageSid
    - Generic JSON: { "from": "+972...", "text": "...", "message_id": "..." }
    """
    content_type = (request.headers.get("content-type") or "").lower()

    if "application/json" in content_type:
        if not sms_service.verify_shared_token(x_daos_sms_token):
            raise HTTPException(status_code=403, detail={"message": "Invalid SMS webhook token"})
        payload = await request.json()
        from_phone = str(payload.get("from") or payload.get("From") or "")
        text = str(payload.get("text") or payload.get("Body") or payload.get("body") or "")
        message_id = payload.get("message_id") or payload.get("MessageSid") or payload.get("id")
        message_id = str(message_id) if message_id else None
    else:
        form = await request.form()
        params = {k: str(v) for k, v in form.items()}
        # Reconstruct public URL for Twilio signature (prefer X-Forwarded headers on Render)
        forwarded_proto = request.headers.get("x-forwarded-proto")
        forwarded_host = request.headers.get("x-forwarded-host")
        if forwarded_proto and forwarded_host:
            url = f"{forwarded_proto}://{forwarded_host}{request.url.path}"
        else:
            url = str(request.url).split("?")[0]
        if not sms_service.verify_twilio_signature(
            url=url,
            params=params,
            signature=x_twilio_signature,
        ):
            raise HTTPException(status_code=403, detail={"message": "Invalid Twilio signature"})
        from_phone = params.get("From") or params.get("from") or ""
        text = params.get("Body") or params.get("body") or params.get("text") or ""
        message_id = params.get("MessageSid") or params.get("message_id")

    if not from_phone:
        raise HTTPException(status_code=400, detail={"message": "Missing from phone"})

    background_tasks.add_task(_process_inbound, from_phone, text, message_id)
    # Twilio expects 200 empty / TwiML — empty 204 is fine
    return Response(content="<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response></Response>", media_type="application/xml")
