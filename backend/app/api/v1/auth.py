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
    RefreshTokenIn,
    UserOut,
)
from app.services.auth_service import AuthService
from app.services.email_sync_service import EmailSyncService

router = APIRouter(prefix="/auth", tags=["auth"])
auth_service = AuthService()
email_sync = EmailSyncService()


@router.post("/google", response_model=AuthTokensOut)
async def sign_in_google(body: GoogleAuthIn, db: Session = Depends(get_db)):
    if not body.id_token:
        raise HTTPException(status_code=400, detail={"message": "idToken is required"})
    try:
        user, access, refresh = await auth_service.sign_in_google(
            db, body.id_token, body.server_auth_code
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


@router.post("/google/connect", response_model=UserOut)
async def connect_google(
    body: GoogleAuthIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not body.id_token:
        raise HTTPException(status_code=400, detail={"message": "idToken is required"})
    try:
        user = await auth_service.connect_google_mailbox(
            db, user, body.id_token, body.server_auth_code
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
