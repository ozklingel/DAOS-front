from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import (
    EmailAiStatusOut,
    EmailAnalyzePreviewIn,
    EmailAnalyzePreviewOut,
    EmailSyncOut,
)
from app.services.ai_service import AIService
from app.services.email_sync_service import EmailSyncService

router = APIRouter(prefix="/emails", tags=["emails"])
email_sync = EmailSyncService()
ai_service = AIService()


@router.get("/ai-status", response_model=EmailAiStatusOut)
def email_ai_status():
    return EmailAiStatusOut(
        ai_enabled=ai_service.ai_enabled,
        model=settings.openai_model if ai_service.ai_enabled else "",
    )


@router.post("/analyze-preview", response_model=EmailAnalyzePreviewOut)
def analyze_email_preview(body: EmailAnalyzePreviewIn):
    if not settings.debug:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail={"message": "Not found"})

    is_hebrew = ai_service.is_hebrew_email(body.subject, body.snippet)
    analysis, source = ai_service.analyze_email_detailed(
        subject=body.subject,
        sender=body.sender,
        snippet=body.snippet,
    )
    return EmailAnalyzePreviewOut(
        ai_enabled=ai_service.ai_enabled,
        is_hebrew=is_hebrew,
        source=source,
        analysis=analysis,
    )


@router.post("/sync", response_model=EmailSyncOut)
async def sync_emails(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not user.gmail_connected and not user.outlook_connected:
        raise HTTPException(
            status_code=400,
            detail={"message": "Connect Gmail or Outlook before syncing emails."},
        )
    result = await email_sync.sync_user_emails(db, user)
    return EmailSyncOut(**result)
