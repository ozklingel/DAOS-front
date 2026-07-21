from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile
from sqlalchemy.orm import Session

from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import TaskListOut, TaskOut, TaskUpdateIn, VoiceTaskOut
from app.services.ai_service import AIService
from app.services.task_ingest_service import create_task_from_analysis
from app.services.task_service import TaskService

router = APIRouter(prefix="/tasks", tags=["tasks"])
task_service = TaskService()
ai_service = AIService()


@router.post("/from-voice", response_model=VoiceTaskOut)
async def create_task_from_voice(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    transcript: str | None = Form(default=None),
    audio: UploadFile | None = File(default=None),
):
    """Create a task from typed voice text and/or an uploaded audio clip (Whisper)."""
    text = (transcript or "").strip()
    if audio is not None:
        raw = await audio.read()
        if raw:
            spoken = ai_service.transcribe_audio(
                raw,
                filename=audio.filename or "voice.webm",
            )
            if spoken:
                text = f"{text} {spoken}".strip() if text else spoken

    if not text:
        raise HTTPException(
            status_code=400,
            detail={"message": "חסר טקסט או הקלטה. כתבו משימה או העלו קובץ אודיו."},
        )

    # Ensure the Hebrew task keyword so analysis accepts the message
    if "משימה" not in text:
        text = f"משימה: {text}"

    analysis, source = ai_service.analyze_voice_transcript(text)
    if not analysis:
        return VoiceTaskOut(
            created=False,
            transcript=text,
            message="לא זוהתה משימה מהטקסט.",
            analysis_source=source,
        )

    task = create_task_from_analysis(
        db,
        user,
        analysis,
        source_subject=text[:200],
        source_snippet=text[:2000],
        sender_name="Voice",
        source_label="voice",
    )
    if not task:
        return VoiceTaskOut(
            created=False,
            transcript=text,
            message="המשימה לא נוצרה.",
            analysis_source=source,
        )

    return VoiceTaskOut(
        created=True,
        task=TaskOut.model_validate(task),
        transcript=text,
        message=f"נוצרה משימה: {task.title}",
        analysis_source=source,
    )


@router.get("", response_model=TaskListOut)
def list_tasks(
    search: str | None = None,
    status: str | None = None,
    priority: str | None = None,
    category: str | None = None,
    energyLevel: str | None = None,
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
        category=category,
        energy_level=energyLevel,
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
