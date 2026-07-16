from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.deps import get_current_user
from app.models import Task, User
from app.schemas import DailyBriefOut, DashboardOut, SettingsOut, SettingsUpdateIn, TaskOut
from app.services.ai_service import AIService
from app.services.support_services import DailyBriefService, SettingsService
from app.services.task_service import TaskService

router = APIRouter(tags=["dashboard"])
task_service = TaskService()
brief_service = DailyBriefService()
settings_service = SettingsService()
ai_service = AIService()


@router.get("/dashboard", response_model=DashboardOut)
def get_dashboard(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    data = task_service.dashboard(db, user)
    return DashboardOut(
        stats=data["stats"],
        brief_summary=data["brief_summary"],
        energy_meter=data["energy_meter"],
        recent_high_priority_tasks=[TaskOut.model_validate(t) for t in data["recent_high_priority_tasks"]],
    )


@router.get("/daily-brief", response_model=DailyBriefOut)
def get_daily_brief(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    brief = brief_service.get_latest(db, user.id)
    if not brief:
        tasks = db.query(Task).filter(Task.user_id == user.id).all()
        user_settings = settings_service.get_or_create(db, user.id)
        brief = ai_service.generate_daily_brief(db, user, tasks, user_settings.language)
    payload = brief_service.brief_to_response(db, brief)
    return DailyBriefOut(
        id=payload["id"],
        summary=payload["summary"],
        content=payload["content"],
        generated_at=payload["generated_at"],
        highlighted_tasks=[TaskOut.model_validate(t) for t in payload["highlighted_tasks"]],
        insights=payload["insights"],
    )


@router.get("/settings", response_model=SettingsOut)
def get_settings(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    settings = settings_service.get_or_create(db, user.id)
    return SettingsOut.model_validate(settings)


@router.patch("/settings", response_model=SettingsOut)
def update_settings(
    body: SettingsUpdateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    updates = body.model_dump(exclude_unset=True)
    settings = settings_service.update(db, user.id, updates)
    return SettingsOut.model_validate(settings)
