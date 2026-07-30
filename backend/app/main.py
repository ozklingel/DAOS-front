from contextlib import asynccontextmanager

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.v1 import auth, dashboard, emails, hub, notifications, system, tasks, whatsapp
from app.api import webhooks_green_api, webhooks_saltedge, webhooks_whatsapp
from app.config import settings
from app.database import SessionLocal, init_db
from app.models import User
from app.services.ai_service import AIService
from app.services.email_sync_service import EmailSyncService

scheduler = AsyncIOScheduler()
email_sync = EmailSyncService()
ai_service = AIService()


async def scheduled_email_sync() -> None:
    db = SessionLocal()
    try:
        users = db.query(User).filter(
            (User.gmail_connected.is_(True)) | (User.outlook_connected.is_(True))
        ).all()
        for user in users:
            settings_row = user.settings
            if settings_row and not settings_row.email_sync_enabled:
                continue
            await email_sync.sync_user_emails(db, user)
    finally:
        db.close()


async def scheduled_daily_briefs() -> None:
    db = SessionLocal()
    try:
        users = db.query(User).all()
        for user in users:
            settings_row = user.settings
            if settings_row and not settings_row.daily_brief_enabled:
                continue
            tasks = [t for t in user.tasks]
            language = settings_row.language if settings_row else "en"
            ai_service.generate_daily_brief(db, user, tasks, language)
    finally:
        db.close()


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    scheduler.add_job(scheduled_email_sync, "interval", minutes=settings.email_sync_interval_minutes)
    scheduler.add_job(scheduled_daily_briefs, "cron", hour=6, minute=0)
    scheduler.start()
    yield
    scheduler.shutdown(wait=False)


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={"message": "Invalid request.", "error": str(exc.errors())},
    )


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    if settings.debug:
        raise exc
    return JSONResponse(
        status_code=500,
        content={"message": "Something went wrong. Please try again.", "error": "server_error"},
    )


api_prefix = settings.api_prefix
app.include_router(auth.router, prefix=api_prefix)
app.include_router(emails.router, prefix=api_prefix)
app.include_router(hub.router, prefix=api_prefix)
app.include_router(tasks.router, prefix=api_prefix)
app.include_router(dashboard.router, prefix=api_prefix)
app.include_router(notifications.router, prefix=api_prefix)
app.include_router(whatsapp.router, prefix=api_prefix)
app.include_router(system.router, prefix=api_prefix)
app.include_router(webhooks_whatsapp.router)
app.include_router(webhooks_green_api.router)
app.include_router(webhooks_saltedge.router)


@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": settings.app_name,
        "version": settings.app_version,
        "openai_configured": bool((settings.openai_api_key or "").strip()),
    }
