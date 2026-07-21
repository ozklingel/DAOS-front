"""Salt Edge Connect success/error callbacks (server-to-server)."""

from __future__ import annotations

import logging

from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.database import get_db
from app.services.bank_service import BankService

logger = logging.getLogger(__name__)
router = APIRouter(tags=["webhooks"])
bank_service = BankService()


@router.post("/webhooks/saltedge")
@router.post("/webhooks/saltedge/success")
@router.post("/webhooks/saltedge/error")
async def saltedge_webhook(request: Request, db: Session = Depends(get_db)):
    payload = await request.json()
    logger.info("Salt Edge webhook: %s", str(payload)[:400])
    try:
        result = bank_service.handle_saltedge_webhook(db, payload)
        return {"ok": True, "imported_transactions": result.get("imported_transactions", 0)}
    except ValueError as exc:
        logger.warning("Salt Edge webhook ignored: %s", exc)
        return {"ok": False, "message": str(exc)}
