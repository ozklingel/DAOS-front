from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import (
    AuthTokensOut,
    GoogleAuthIn,
    OutlookAuthIn,
    OutlookAuthorizeUrlIn,
    OutlookAuthorizeUrlOut,
    OutlookExchangeIn,
    OutlookExchangeOut,
    RefreshTokenIn,
    UserOut,
    WhatsAppLinkIn,
)
from app.services.auth_service import AuthService
from app.services.email_sync_service import EmailSyncService
from app.services.microsoft_oauth_service import MicrosoftOAuthService
from app.services.whatsapp_service import WhatsAppService

router = APIRouter(prefix="/auth", tags=["auth"])
auth_service = AuthService()
email_sync = EmailSyncService()
whatsapp_service = WhatsAppService()
microsoft_oauth = MicrosoftOAuthService()


@router.post("/google", response_model=AuthTokensOut)
async def sign_in_google(body: GoogleAuthIn, db: Session = Depends(get_db)):
    try:
        user, access, refresh = await auth_service.sign_in_google(
            db,
            id_token_str=body.id_token,
            access_token_str=body.access_token,
            server_auth_code=body.server_auth_code,
        )
        await email_sync.sync_user_emails(db, user)
        return AuthTokensOut(
            access_token=access,
            refresh_token=refresh,
            user=UserOut.model_validate(user),
        )
    except ValueError as exc:
        raise HTTPException(status_code=401, detail={"message": str(exc)}) from exc


@router.post("/outlook", response_model=AuthTokensOut)
async def sign_in_outlook(body: OutlookAuthIn, db: Session = Depends(get_db)):
    if not body.access_token:
        raise HTTPException(status_code=400, detail={"message": "accessToken is required"})
    try:
        user, access, refresh = await auth_service.sign_in_outlook(
            db, body.access_token, body.refresh_token
        )
        await email_sync.sync_user_emails(db, user)
        return AuthTokensOut(
            access_token=access,
            refresh_token=refresh,
            user=UserOut.model_validate(user),
        )
    except ValueError as exc:
        raise HTTPException(status_code=401, detail={"message": str(exc)}) from exc


@router.post("/outlook/authorize-url", response_model=OutlookAuthorizeUrlOut)
def outlook_authorize_url(body: OutlookAuthorizeUrlIn):
    try:
        url = microsoft_oauth.build_authorize_url(
            redirect_uri=body.redirect_uri,
            state=body.state,
            code_challenge=body.code_challenge,
        )
        return OutlookAuthorizeUrlOut(url=url)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail={"message": str(exc)}) from exc


@router.post("/outlook/exchange", response_model=OutlookExchangeOut)
async def outlook_exchange(body: OutlookExchangeIn):
    try:
        tokens = await microsoft_oauth.exchange_code(
            code=body.code,
            redirect_uri=body.redirect_uri,
            code_verifier=body.code_verifier,
        )
        return OutlookExchangeOut(
            access_token=tokens["access_token"],
            refresh_token=tokens.get("refresh_token") or None,
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail={"message": str(exc)}) from exc


@router.post("/google/connect", response_model=UserOut)
async def connect_google(
    body: GoogleAuthIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        user = await auth_service.connect_google_mailbox(
            db,
            user,
            id_token_str=body.id_token,
            access_token_str=body.access_token,
            server_auth_code=body.server_auth_code,
        )
        await email_sync.sync_user_emails(db, user)
        return UserOut.model_validate(user)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail={"message": str(exc)}) from exc


@router.post("/outlook/connect", response_model=UserOut)
async def connect_outlook(
    body: OutlookAuthIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not body.access_token:
        raise HTTPException(status_code=400, detail={"message": "accessToken is required"})
    try:
        user = await auth_service.connect_outlook_mailbox(
            db, user, body.access_token, body.refresh_token
        )
        await email_sync.sync_user_emails(db, user)
        return UserOut.model_validate(user)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail={"message": str(exc)}) from exc


@router.post("/google/disconnect", response_model=UserOut)
def disconnect_google(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    user = auth_service.disconnect_gmail(db, user)
    return UserOut.model_validate(user)


@router.post("/outlook/disconnect", response_model=UserOut)
def disconnect_outlook(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    user = auth_service.disconnect_outlook(db, user)
    return UserOut.model_validate(user)


@router.post("/whatsapp/link", response_model=UserOut)
def link_whatsapp(
    body: WhatsAppLinkIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        user = whatsapp_service.link_phone(db, user, body.phone)
        return UserOut.model_validate(user)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail={"message": str(exc)}) from exc


@router.post("/whatsapp/disconnect", response_model=UserOut)
def disconnect_whatsapp(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    user = whatsapp_service.unlink_phone(db, user)
    return UserOut.model_validate(user)


@router.post("/dev", response_model=AuthTokensOut)
async def sign_in_dev(db: Session = Depends(get_db)):
    if not settings.debug:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail={"message": "Not found"})
    user, access, refresh = auth_service.sign_in_dev(db)
    return AuthTokensOut(
        access_token=access,
        refresh_token=refresh,
        user=UserOut.model_validate(user),
    )


@router.post("/refresh", response_model=AuthTokensOut)
def refresh_token(body: RefreshTokenIn, db: Session = Depends(get_db)):
    try:
        access, refresh = auth_service.refresh(db, body.refresh_token)
        return AuthTokensOut(access_token=access, refresh_token=refresh)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"message": str(exc)},
        ) from exc


@router.get("/me", response_model=UserOut)
def get_me(user: User = Depends(get_current_user)):
    return UserOut.model_validate(user)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    auth_service.logout(db, user)

