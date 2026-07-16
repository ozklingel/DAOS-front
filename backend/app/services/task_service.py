import json
from datetime import UTC, datetime

from sqlalchemy import asc, desc, func, or_
from sqlalchemy.orm import Session

from app.deps import start_of_week
from app.models import DailyBrief, EnergyLevel, Task, TaskCategory, TaskPriority, TaskStatus, User
from app.services.support_services import SettingsService
from app.services.task_classifier import DAILY_ENERGY_BUDGET, energy_cost

settings_service = SettingsService()


class TaskService:
    SORT_FIELDS = {
        "deadline": Task.deadline,
        "created_at": Task.created_at,
        "priority_score": Task.priority_score,
    }

    def refresh_overdue_status(self, db: Session, user_id: str) -> None:
        now = datetime.now(UTC)
        tasks = (
            db.query(Task)
            .filter(
                Task.user_id == user_id,
                Task.status == TaskStatus.open.value,
                Task.deadline.isnot(None),
                Task.deadline < now,
            )
            .all()
        )
        for task in tasks:
            task.status = TaskStatus.overdue.value
        if tasks:
            db.commit()

    def list_tasks(
        self,
        db: Session,
        user: User,
        *,
        search: str | None,
        status: str | None,
        priority: str | None,
        category: str | None,
        energy_level: str | None,
        sort_by: str,
        order: str,
        page: int,
        limit: int,
    ) -> tuple[list[Task], int]:
        self.refresh_overdue_status(db, user.id)
        query = db.query(Task).filter(Task.user_id == user.id)

        if search:
            pattern = f"%{search.lower()}%"
            query = query.filter(
                or_(
                    func.lower(Task.title).like(pattern),
                    func.lower(Task.description).like(pattern),
                    func.lower(Task.sender_name).like(pattern),
                    func.lower(Task.sender_email).like(pattern),
                    func.lower(Task.email_subject).like(pattern),
                )
            )
        if status:
            query = query.filter(Task.status == status)
        if priority:
            query = query.filter(Task.priority == priority)
        if category:
            query = query.filter(Task.category == category)
        if energy_level:
            query = query.filter(Task.energy_level == energy_level)

        total = query.count()
        sort_col = self.SORT_FIELDS.get(sort_by, Task.deadline)
        ordering = asc(sort_col) if order == "asc" else desc(sort_col)
        tasks = query.order_by(ordering).offset((page - 1) * limit).limit(limit).all()
        has_more = page * limit < total
        return tasks, total, has_more

    def get_task(self, db: Session, user: User, task_id: str) -> Task | None:
        self.refresh_overdue_status(db, user.id)
        return db.query(Task).filter(Task.user_id == user.id, Task.id == task_id).one_or_none()

    def update_task(self, db: Session, user: User, task: Task, action: str, snooze_until: datetime | None) -> Task:
        now = datetime.now(UTC)
        if action == "complete":
            task.status = TaskStatus.completed.value
            task.completed_at = now
            task.snoozed_until = None
        elif action == "snooze":
            if not snooze_until:
                raise ValueError("snoozeUntil is required for snooze action")
            task.status = TaskStatus.snoozed.value
            task.snoozed_until = snooze_until
        elif action == "dismiss":
            task.status = TaskStatus.dismissed.value
        else:
            raise ValueError(f"Unknown action: {action}")

        task.updated_at = now
        db.commit()
        db.refresh(task)
        return task

    def dashboard(self, db: Session, user: User) -> dict:
        self.refresh_overdue_status(db, user.id)
        week_start = start_of_week()

        critical_count = (
            db.query(func.count(Task.id))
            .filter(
                Task.user_id == user.id,
                Task.priority == TaskPriority.critical.value,
                Task.status.in_([TaskStatus.open.value, TaskStatus.overdue.value, TaskStatus.snoozed.value]),
            )
            .scalar()
            or 0
        )
        open_count = (
            db.query(func.count(Task.id))
            .filter(Task.user_id == user.id, Task.status == TaskStatus.open.value)
            .scalar()
            or 0
        )
        overdue_count = (
            db.query(func.count(Task.id))
            .filter(Task.user_id == user.id, Task.status == TaskStatus.overdue.value)
            .scalar()
            or 0
        )
        completed_this_week = (
            db.query(func.count(Task.id))
            .filter(
                Task.user_id == user.id,
                Task.status == TaskStatus.completed.value,
                Task.completed_at >= week_start,
            )
            .scalar()
            or 0
        )

        recent = (
            db.query(Task)
            .filter(
                Task.user_id == user.id,
                Task.priority.in_([TaskPriority.critical.value, TaskPriority.high.value]),
                Task.status.in_([TaskStatus.open.value, TaskStatus.overdue.value, TaskStatus.snoozed.value]),
            )
            .order_by(desc(Task.priority_score), asc(Task.deadline))
            .limit(5)
            .all()
        )

        brief = (
            db.query(DailyBrief)
            .filter(DailyBrief.user_id == user.id)
            .order_by(desc(DailyBrief.generated_at))
            .first()
        )
        user_settings = settings_service.get_or_create(db, user.id)
        if brief:
            brief_summary = brief.summary
        elif user_settings.language == "he":
            brief_summary = "סיכום ה-AI שלכם יופיע כאן לאחר סנכרון המיילים."
        else:
            brief_summary = "Your AI brief will appear here once emails are synced."

        active_statuses = [TaskStatus.open.value, TaskStatus.overdue.value, TaskStatus.snoozed.value]
        active_tasks = (
            db.query(Task)
            .filter(Task.user_id == user.id, Task.status.in_(active_statuses))
            .all()
        )

        used = sum(energy_cost(t.energy_level) for t in active_tasks)
        high_count = sum(1 for t in active_tasks if t.energy_level == EnergyLevel.high.value)
        medium_count = sum(1 for t in active_tasks if t.energy_level == EnergyLevel.medium.value)
        low_count = sum(1 for t in active_tasks if t.energy_level == EnergyLevel.low.value)
        work_count = sum(1 for t in active_tasks if t.category == TaskCategory.work.value)
        errands_count = sum(1 for t in active_tasks if t.category == TaskCategory.errands.value)
        health_count = sum(1 for t in active_tasks if t.category == TaskCategory.health.value)

        return {
            "stats": {
                "critical_count": critical_count,
                "open_count": open_count,
                "overdue_count": overdue_count,
                "completed_this_week": completed_this_week,
            },
            "brief_summary": brief_summary,
            "energy_meter": {
                "budget": DAILY_ENERGY_BUDGET,
                "used": used,
                "remaining": max(0, DAILY_ENERGY_BUDGET - used),
                "high_count": high_count,
                "medium_count": medium_count,
                "low_count": low_count,
                "work_count": work_count,
                "errands_count": errands_count,
                "health_count": health_count,
            },
            "recent_high_priority_tasks": recent,
        }
