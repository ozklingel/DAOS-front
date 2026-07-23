from fastapi import APIRouter, Depends

from app.deps import get_current_user
from app.models import User
from app.schemas import OpenAIStatusOut
from app.services.ai_service import AIService

router = APIRouter(prefix="/system", tags=["system"])
ai_service = AIService()


@router.get("/openai-status", response_model=OpenAIStatusOut)
def openai_status(_user: User = Depends(get_current_user)):
    """
    Verify the backend OpenAI API key is configured and usable
    (not missing, revoked, or out of quota).
    """
    result = ai_service.check_openai_status()
    return OpenAIStatusOut(
        configured=result.get("configured", False),
        ok=result.get("ok", False),
        status=result.get("status", "error"),
        message=result.get("message", ""),
        model=result.get("model"),
        checked_at=result.get("checked_at"),
        error_type=result.get("error_type"),
    )
