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
    fetch_errors = result.get("fetch_errors") or []
    # If mail providers failed and nothing was scanned, surface the real error.
    if fetch_errors and result.get("scanned", 0) == 0:
        raise HTTPException(
            status_code=502,
            detail={
                "message": fetch_errors[0],
                "fetch_errors": fetch_errors,
            },
        )
    return EmailSyncOut(
        created=result.get("created", 0),
        scanned=result.get("scanned", 0),
        skipped_non_hebrew=result.get("skipped_non_hebrew", 0),
        skipped_no_signal=result.get("skipped_no_signal", 0),
        skipped_not_actionable=result.get("skipped_not_actionable", 0),
    )
