from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import TaskListOut, TaskOut, TaskUpdateIn
from app.services.task_service import TaskService

router = APIRouter(prefix="/tasks", tags=["tasks"])
task_service = TaskService()


@router.get("", response_model=TaskListOut)
def list_tasks(
    search: str | None = None,
    status: str | None = None,
    priority: str | None = None,
    sortBy: str = Query(default="deadline"),
    order: str = Query(default="asc"),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    tasks, total, has_more = task_service.list_tasks(
        db,
        user,
        search=search,
        status=status,
        priority=priority,
        sort_by=sortBy,
        order=order,
        page=page,
        limit=limit,
    )
    return TaskListOut(
        tasks=[TaskOut.model_validate(t) for t in tasks],
        total=total,
        page=page,
        has_more=has_more,
    )


@router.get("/{task_id}", response_model=TaskOut)
def get_task(
    task_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    task = task_service.get_task(db, user, task_id)
    if not task:
        raise HTTPException(status_code=404, detail={"message": "Task not found"})
    return TaskOut.model_validate(task)


@router.patch("/{task_id}", response_model=TaskOut)
def update_task(
    task_id: str,
    body: TaskUpdateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    task = task_service.get_task(db, user, task_id)
    if not task:
        raise HTTPException(status_code=404, detail={"message": "Task not found"})
    try:
        updated = task_service.update_task(db, user, task, body.action, body.snooze_until)
        return TaskOut.model_validate(updated)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail={"message": str(exc)}) from exc
