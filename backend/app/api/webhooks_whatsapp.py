import json
import logging

from fastapi import APIRouter, BackgroundTasks, HTTPException, Query, Request, Response

from app.config import settings
from app.database import SessionLocal
from app.services.whatsapp_service import WhatsAppService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/webhooks", tags=["webhooks"])
whatsapp_service = WhatsAppService()


async def _process_webhook_payload(payload: dict) -> None:
    db = SessionLocal()
    try:
        await whatsapp_service.handle_webhook(db, payload)
    except Exception as exc:
        logger.exception("WhatsApp webhook error: %s", exc)
    finally:
        db.close()


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
async def whatsapp_webhook(
    request: Request,
    background_tasks: BackgroundTasks,
):
    body = await request.body()
    signature = request.headers.get("X-Hub-Signature-256")
    logger.info("WhatsApp webhook POST received (%d bytes)", len(body))
    if not whatsapp_service.verify_signature(body, signature):
        logger.warning(
            "WhatsApp webhook rejected: invalid signature. "
            "Set WHATSAPP_APP_SECRET on Render to Meta App Secret, or leave empty to skip."
        )
        raise HTTPException(status_code=403, detail={"message": "Invalid signature"})

    try:
        payload = json.loads(body)
    except json.JSONDecodeError:
        logger.warning("WhatsApp webhook: invalid JSON body")
        raise HTTPException(status_code=400, detail={"message": "Invalid JSON"})

    # Return 200 immediately — Meta times out on cold start (Render free tier)
    background_tasks.add_task(_process_webhook_payload, payload)
    return {"status": "ok"}
