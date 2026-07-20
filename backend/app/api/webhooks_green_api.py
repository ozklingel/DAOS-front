import json
import logging

from fastapi import APIRouter, BackgroundTasks, Request

from app.config import settings
from app.database import SessionLocal
from app.services.whatsapp_service import WhatsAppService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/webhooks", tags=["webhooks"])
whatsapp_service = WhatsAppService()


async def _process_green_payload(payload: dict) -> None:
    db = SessionLocal()
    try:
        await whatsapp_service.handle_green_webhook(db, payload)
    except Exception as exc:
        logger.exception("Green API webhook error: %s", exc)
    finally:
        db.close()


@router.post("/green-api")
async def green_api_webhook(request: Request, background_tasks: BackgroundTasks):
    """Green API incomingMessageReceived webhook."""
    if not settings.green_api_enabled:
        logger.warning("Green API webhook received but GREEN_API_* not configured")
        return {"status": "ignored"}

    body = await request.body()
    logger.info("Green API webhook POST (%d bytes)", len(body))

    try:
        payload = json.loads(body)
    except json.JSONDecodeError:
        logger.warning("Green API webhook: invalid JSON")
        return {"status": "invalid_json"}

    webhook_type = payload.get("typeWebhook", "")
    if webhook_type != "incomingMessageReceived":
        logger.debug("Green API webhook ignored: type=%s", webhook_type)
        return {"status": "ignored"}

    background_tasks.add_task(_process_green_payload, payload)
    return {"status": "ok"}
