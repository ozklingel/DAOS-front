import logging

from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.services.whatsapp_service import WhatsAppService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/webhooks", tags=["webhooks"])
whatsapp_service = WhatsAppService()


@router.get("/whatsapp")
async def verify_whatsapp_webhook(
    hub_mode: str | None = Query(default=None, alias="hub.mode"),
    hub_verify_token: str | None = Query(default=None, alias="hub.verify_token"),
    hub_challenge: str | None = Query(default=None, alias="hub.challenge"),
):
    logger.info("WhatsApp webhook verify: mode=%s token_match=%s", hub_mode, hub_verify_token == settings.whatsapp_verify_token)
    if hub_mode == "subscribe" and hub_verify_token == settings.whatsapp_verify_token:
        return Response(content=hub_challenge or "", media_type="text/plain")
    raise HTTPException(status_code=403, detail={"message": "Verification failed"})


@router.post("/whatsapp")
async def whatsapp_webhook(request: Request, db: Session = Depends(get_db)):
    body = await request.body()
    signature = request.headers.get("X-Hub-Signature-256")
    logger.info("WhatsApp webhook POST received (%d bytes)", len(body))
    if not whatsapp_service.verify_signature(body, signature):
        logger.warning("WhatsApp webhook rejected: invalid signature")
        raise HTTPException(status_code=403, detail={"message": "Invalid signature"})

    payload = await request.json()
    try:
        await whatsapp_service.handle_webhook(db, payload)
    except Exception as exc:
        logger.exception("WhatsApp webhook error: %s", exc)
    return {"status": "ok"}
