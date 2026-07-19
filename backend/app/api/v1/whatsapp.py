from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import UserOut, WhatsAppDevInboundIn, WhatsAppLinkIn, WhatsAppSimulateIn, WhatsAppSimulateOut
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
