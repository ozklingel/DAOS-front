from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.schemas import (
    AssetReminderOut,
    AssetReminderUpdateIn,
    CalendarOut,
    FinanceOut,
    FinanceTransactionIn,
    FinanceTransactionOut,
    InfoHubOut,
    ProfileOut,
)
from app.services.asset_service import AssetService
from app.services.budget_service import BudgetService
from app.services.hub_service import HubService

router = APIRouter(tags=["hub"])
hub_service = HubService()
budget_service = BudgetService()
asset_service = AssetService()


@router.get("/profile", response_model=ProfileOut)
def get_profile(user: User = Depends(get_current_user)):
    return ProfileOut.model_validate(hub_service.get_profile(user))


@router.get("/calendar", response_model=CalendarOut)
def get_calendar(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    date_str: str | None = Query(default=None, alias="date"),
):
    day = date.fromisoformat(date_str) if date_str else date.today()
    return CalendarOut.model_validate(hub_service.get_calendar(db, user, day))


@router.get("/finance", response_model=FinanceOut)
def get_finance(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    budget_type: str = Query(default="home", alias="type"),
):
    selected = budget_type if budget_type in {"home", "business"} else "home"
    return FinanceOut.model_validate(budget_service.get_finance(db, user, selected_type=selected))


@router.post("/finance/transactions", response_model=FinanceTransactionOut)
def create_finance_transaction(
    body: FinanceTransactionIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        tx = budget_service.create_transaction(
            db,
            user,
            budget_type=body.budget_type,
            title=body.title,
            amount=body.amount,
            tx_type=body.tx_type,
            category=body.category,
            icon=body.icon,
        )
        return FinanceTransactionOut.model_validate(budget_service._tx_to_dict(tx))
    except ValueError as exc:
        raise HTTPException(status_code=400, detail={"message": str(exc)}) from exc


@router.get("/info", response_model=InfoHubOut)
def get_info_hub(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return InfoHubOut.model_validate(hub_service.get_info_hub(db, user))


@router.get("/assets", response_model=list[AssetReminderOut])
def list_assets(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return [AssetReminderOut.model_validate(r) for r in asset_service.list_reminders(db, user)]


@router.patch("/assets/{asset_id}", response_model=AssetReminderOut)
def update_asset(
    asset_id: str,
    body: AssetReminderUpdateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        expiry = date.fromisoformat(body.expiry_date) if body.expiry_date else None
        updated = asset_service.update_reminder(
            db,
            user,
            asset_id,
            title=body.title,
            expiry_date=expiry,
            notes=body.notes,
        )
        return AssetReminderOut.model_validate(updated)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail={"message": str(exc)}) from exc
