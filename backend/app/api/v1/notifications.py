from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import DeviceRegisterIn
from app.services.support_services import NotificationService

router = APIRouter(prefix="/notifications", tags=["notifications"])
notification_service = NotificationService()


@router.post("/device", status_code=status.HTTP_204_NO_CONTENT)
def register_device(
    body: DeviceRegisterIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not body.fcm_token:
        raise HTTPException(status_code=400, detail={"message": "fcmToken is required"})
    notification_service.register_device(db, user.id, body.fcm_token, body.platform)
