from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import EmailSyncOut
from app.services.email_sync_service import EmailSyncService

router = APIRouter(prefix="/emails", tags=["emails"])
email_sync = EmailSyncService()


@router.post("/sync", response_model=EmailSyncOut)
async def sync_emails(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not user.gmail_connected and not user.outlook_connected:
        raise HTTPException(
            status_code=400,
            detail={"message": "Connect Gmail or Outlook before syncing emails."},
        )
    created = await email_sync.sync_user_emails(db, user)
    return EmailSyncOut(created=created)
