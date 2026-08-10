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
    OutlookInboxPreviewOut,
    OutlookInboxEmailPreviewOut,
)
from app.services.ai_service import AIService
from app.services.email_sync_service import EmailSyncService
from app.services.microsoft_oauth_service import build_admin_consent_url
from app.services.outlook_mail_service import OutlookMailService
from app.models import Task

router = APIRouter(prefix="/emails", tags=["emails"])
email_sync = EmailSyncService()
ai_service = AIService()
outlook_mail = OutlookMailService()


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


@router.get("/outlook/inbox-preview", response_model=OutlookInboxPreviewOut)
async def outlook_inbox_preview(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Prove Outlook inbox access: show mailbox + latest inbox message."""
    base = OutlookInboxPreviewOut(
        connected=bool(user.outlook_connected),
        has_refresh_token=bool(user.outlook_refresh_token),
        account_email=user.email,
        fetch_ok=False,
    )
    if not user.outlook_connected:
        return base.model_copy(update={"error": "Outlook is not connected for this account."})
    if not user.outlook_refresh_token:
        return base.model_copy(
            update={
                "error": "Missing Outlook refresh token — disconnect and reconnect Outlook.",
            }
        )

    try:
        preview = await outlook_mail.fetch_inbox_preview(user.outlook_refresh_token)
    except Exception as exc:
        return base.model_copy(update={"error": str(exc)})

    new_refresh = preview.get("new_refresh_token")
    if new_refresh:
        user.outlook_refresh_token = new_refresh
        db.commit()

    ingested_ids = {
        row[0]
        for row in db.query(Task.email_message_id)
        .filter(Task.user_id == user.id, Task.email_message_id.isnot(None))
        .all()
    }

    def _to_preview(email: dict) -> OutlookInboxEmailPreviewOut:
        subject = email["subject"]
        snippet = email["snippet"]
        message_id = email["message_id"]
        return OutlookInboxEmailPreviewOut(
            message_id=message_id,
            subject=subject,
            sender=email["sender"],
            snippet=snippet[:200],
            received_at=email.get("received_at"),
            is_hebrew=ai_service.is_hebrew_email(subject, snippet),
            has_task_signal=ai_service.looks_like_task_candidate(subject, snippet),
            already_ingested=message_id in ingested_ids,
        )

    emails = preview["messages"]
    messages = [_to_preview(email) for email in emails]
    latest_raw = preview.get("latest_inbox")
    latest = _to_preview(latest_raw) if latest_raw else None

    mailbox_email = preview.get("mailbox_email")
    mailbox_upn = preview.get("mailbox_upn")
    emails_match = None
    if mailbox_email:
        emails_match = user.email.lower() == mailbox_email.lower()
    elif mailbox_upn:
        emails_match = user.email.lower() == mailbox_upn.lower()

    error = preview.get("inbox_stats_error")
    if not error and mailbox_email and user.email.lower() not in {
        mailbox_email.lower(),
        (mailbox_upn or "").lower(),
    }:
        error = (
            f"DAOS account is {user.email}, but Outlook token reads {mailbox_email}. "
            "Sign in with that Outlook address or reconnect Outlook after picking the correct Microsoft account."
        )
    if not error and preview.get("mail_read_granted") is False:
        error = "Mail.Read permission missing — disconnect Outlook, reconnect, and accept mail access."
    admin_consent_url = None
    if preview.get("has_mail_read_scope") is False or preview.get("mail_read_granted") is False:
        admin_consent_url = build_admin_consent_url(
            account_email=user.email,
            client_id=settings.microsoft_client_id,
        )
    if not error and preview.get("has_mail_read_scope") is False:
        scopes = preview.get("token_scopes") or "(none)"
        error = (
            "Outlook token does not include Mail.Read. "
            f"Scopes: {scopes}. "
        )
        if admin_consent_url:
            error += (
                "Your organization may require IT admin approval — use the admin consent link below, "
                "then disconnect and reconnect Outlook."
            )
        else:
            error += "Disconnect Outlook, tap Connect again, and approve mail access."
    total_items = preview.get("inbox_total_items", 0)
    if not error and total_items > 0 and not latest:
        error = (
            f"Outlook reports {total_items} inbox messages but Graph returned none. "
            "Try disconnect/reconnect Outlook; if it persists, contact support."
        )

    return base.model_copy(
        update={
            "fetch_ok": True,
            "mailbox_email": mailbox_email,
            "mailbox_upn": mailbox_upn,
            "emails_match": emails_match,
            "mail_read_granted": preview.get("mail_read_granted"),
            "has_mail_read_scope": preview.get("has_mail_read_scope"),
            "token_scopes": preview.get("token_scopes"),
            "inbox_total_items": preview.get("inbox_total_items", 0),
            "inbox_unread_items": preview.get("inbox_unread_items", 0),
            "inbox_count": preview.get("inbox_count", 0),
            "latest_inbox": latest,
            "messages": messages,
            "admin_consent_url": admin_consent_url,
            "error": error,
        }
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
