from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import (
    UserOut,
    WhatsAppDevInboundIn,
    WhatsAppInboundOut,
    WhatsAppInboundStatusOut,
    WhatsAppLinkIn,
    WhatsAppSimulateIn,
    WhatsAppSimulateOut,
)
from app.services.whatsapp_service import WhatsAppService

router = APIRouter(prefix="/whatsapp", tags=["whatsapp"])
whatsapp_service = WhatsAppService()


@router.post("/simulate", response_model=WhatsAppSimulateOut)
def simulate_whatsapp_voice(
    body: WhatsAppSimulateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not settings.debug:
        raise HTTPException(status_code=404, detail={"message": "Not found"})
    result = whatsapp_service.simulate_voice_task(db, user, body.transcript)
    return WhatsAppSimulateOut(**result)


@router.post("/dev-inbound", response_model=WhatsAppSimulateOut)
async def dev_inbound_whatsapp(
    body: WhatsAppDevInboundIn,
    db: Session = Depends(get_db),
):
    """DEBUG: mimic Meta webhook — finds user by linked phone, creates task (no JWT)."""
    if not settings.debug:
        raise HTTPException(status_code=404, detail={"message": "Not found"})
    result = await whatsapp_service.dev_inbound_message(db, body.phone, body.text)
    return WhatsAppSimulateOut(**result)


def _inbound_status_response(db: Session, user: User, recent_limit: int) -> WhatsAppInboundStatusOut:
    raw = whatsapp_service.get_inbound_status(db, user, recent_limit=recent_limit)
    latest = raw["latest"]
    return WhatsAppInboundStatusOut(
        linked_phone=raw["linked_phone"],
        has_messages=raw["has_messages"],
        latest=WhatsAppInboundOut.model_validate(latest) if latest else None,
        recent=[WhatsAppInboundOut.model_validate(row) for row in raw["recent"]],
    )


@router.get("/inbound/latest", response_model=WhatsAppInboundOut | None)
def get_latest_whatsapp_inbound(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Last inbound WhatsApp message received from your linked phone."""
    status = whatsapp_service.get_inbound_status(db, user, recent_limit=1)
    latest = status["latest"]
    if not latest:
        return None
    return WhatsAppInboundOut.model_validate(latest)


@router.get("/inbound", response_model=WhatsAppInboundStatusOut)
def get_whatsapp_inbound_status(
    limit: int = 10,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Inbound WhatsApp debug: linked phone, latest message, and recent history."""
    limit = max(1, min(limit, 50))
    return _inbound_status_response(db, user, limit)
