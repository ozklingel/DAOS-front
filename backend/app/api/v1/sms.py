from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import (
    SmsDevInboundIn,
    SmsInboundOut,
    SmsInboundStatusOut,
    SmsIngestIn,
    SmsIngestOut,
    SmsSimulateIn,
    SmsSimulateOut,
)
from app.services.sms_service import SmsService

router = APIRouter(prefix="/sms", tags=["sms"])
sms_service = SmsService()


@router.post("/ingest", response_model=SmsIngestOut)
def ingest_device_sms(
    body: SmsIngestIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Device → server: upload recent SMS; AI creates tasks. Returns created tasks."""
    result = sms_service.ingest_device_messages(
        db,
        user,
        [
            {
                "message_id": m.message_id,
                "body": m.body,
                "from_address": m.from_address,
                "received_at": m.received_at,
            }
            for m in body.messages
        ],
    )
    return SmsIngestOut(**result)


@router.post("/simulate", response_model=SmsSimulateOut)
def simulate_sms_task(
    body: SmsSimulateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not settings.debug:
        raise HTTPException(status_code=404, detail={"message": "Not found"})
    result = sms_service.simulate_task(db, user, body.transcript)
    return SmsSimulateOut(**result)


@router.post("/dev-inbound", response_model=SmsSimulateOut)
async def dev_inbound_sms(
    body: SmsDevInboundIn,
    db: Session = Depends(get_db),
):
    """DEBUG: mimic SMS webhook — finds user by linked sms_phone, creates task (no JWT)."""
    if not settings.debug:
        raise HTTPException(status_code=404, detail={"message": "Not found"})
    result = await sms_service.dev_inbound_message(db, body.phone, body.text)
    return SmsSimulateOut(**result)


@router.get("/inbound/latest", response_model=SmsInboundOut | None)
def get_latest_sms_inbound(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    status = sms_service.get_inbound_status(db, user, recent_limit=1)
    latest = status["latest"]
    if not latest:
        return None
    return SmsInboundOut.model_validate(latest)


@router.get("/inbound", response_model=SmsInboundStatusOut)
def get_sms_inbound_status(
    limit: int = 10,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    limit = max(1, min(limit, 50))
    raw = sms_service.get_inbound_status(db, user, recent_limit=limit)
    latest = raw["latest"]
    return SmsInboundStatusOut(
        linked_phone=raw["linked_phone"],
        has_messages=raw["has_messages"],
        latest=SmsInboundOut.model_validate(latest) if latest else None,
        recent=[SmsInboundOut.model_validate(row) for row in raw["recent"]],
    )
