"""Create and list Info hub documents from camera / uploads."""

from __future__ import annotations

import base64
import logging
from datetime import UTC, date, datetime, time

from sqlalchemy.orm import Session

from app.core.security import new_id
from app.models import AssetReminder, AssetType, InfoDocCategory, InfoDocument, User
from app.services.ai_service import AIService

logger = logging.getLogger(__name__)

MAX_IMAGE_BYTES = 8 * 1024 * 1024

INFO_CATEGORY_META: dict[str, tuple[str, str]] = {
    InfoDocCategory.personal_docs.value: ("מסמכים אישיים", "document"),
    InfoDocCategory.ideas.value: ("רעיונות ופרויקטים", "ideas"),
    InfoDocCategory.summaries.value: ("סיכומים ומחברות", "notebook"),
    InfoDocCategory.links.value: ("קישורים שימושיים", "link"),
    InfoDocCategory.archive.value: ("ארכיון", "archive"),
    InfoDocCategory.vehicle.value: ("רכב", "car"),
    InfoDocCategory.insurance.value: ("ביטוח", "finance"),
}


class InfoDocumentService:
    def __init__(self) -> None:
        self.ai = AIService()

    def create_from_image(
        self,
        db: Session,
        user: User,
        *,
        image_bytes: bytes,
        mime_type: str = "image/jpeg",
        filename: str | None = None,
    ) -> dict:
        if not image_bytes:
            raise ValueError("Empty image")
        if len(image_bytes) > MAX_IMAGE_BYTES:
            raise ValueError("Image too large (max 8MB)")

        mime = mime_type or "image/jpeg"
        if not mime.startswith("image/"):
            raise ValueError("Only image uploads are supported")

        analysis = self.ai.analyze_document_image(
            image_bytes=image_bytes,
            mime_type=mime,
            filename=filename,
        )

        expiry = self._parse_expiry(analysis.get("expiry_date"))
        # Always keep the photo so the Info page can show it
        image_data = base64.b64encode(image_bytes).decode("ascii")

        title = (analysis.get("title") or "").strip()
        if not title or title in {"מסמך", "מסמך שצולם"}:
            # Prefer a readable name from the original filename when AI gave a generic title
            if filename:
                stem = filename.rsplit(".", 1)[0].strip()
                if stem:
                    title = stem
            if not title:
                title = "מסמך שצולם"

        doc = InfoDocument(
            id=new_id(),
            user_id=user.id,
            category=analysis["category"],
            title=title[:255],
            summary=analysis.get("summary"),
            extracted_text=analysis.get("extracted_text"),
            mime_type=mime,
            image_data=image_data,
            expiry_date=expiry,
            confidence=float(analysis.get("confidence") or 0),
        )
        db.add(doc)

        # Also create an expiry reminder for vehicle/insurance/personal docs with a date
        if expiry and analysis["category"] in {
            InfoDocCategory.vehicle.value,
            InfoDocCategory.insurance.value,
            InfoDocCategory.personal_docs.value,
        }:
            self._maybe_create_asset_reminder(db, user, analysis, expiry)

        db.commit()
        db.refresh(doc)
        logger.info(
            "Created info document %s category=%s title=%r for user %s",
            doc.id,
            doc.category,
            doc.title[:80],
            user.id,
        )
        return self._to_dict(doc, include_image=True)

    def get_document(self, db: Session, user: User, document_id: str) -> dict:
        row = (
            db.query(InfoDocument)
            .filter(InfoDocument.user_id == user.id, InfoDocument.id == document_id)
            .one_or_none()
        )
        if not row:
            raise ValueError("Document not found")
        return self._to_dict(row, include_image=True)

    def delete_document(self, db: Session, user: User, document_id: str) -> None:
        row = (
            db.query(InfoDocument)
            .filter(InfoDocument.user_id == user.id, InfoDocument.id == document_id)
            .one_or_none()
        )
        if not row:
            raise ValueError("Document not found")
        db.delete(row)
        db.commit()
        logger.info("Deleted info document %s for user %s", document_id, user.id)

    def list_documents(self, db: Session, user: User) -> list[dict]:
        rows = (
            db.query(InfoDocument)
            .filter(InfoDocument.user_id == user.id)
            .order_by(InfoDocument.created_at.desc())
            .all()
        )
        # Include images so the Info UI can show the photo + name
        return [self._to_dict(r, include_image=True) for r in rows]

    def _maybe_create_asset_reminder(
        self, db: Session, user: User, analysis: dict, expiry: datetime
    ) -> None:
        category = analysis["category"]
        if category == InfoDocCategory.vehicle.value:
            asset_type = AssetType.vehicle_test.value
            icon = "car"
        elif category == InfoDocCategory.insurance.value:
            asset_type = AssetType.car_insurance.value
            icon = "finance"
        else:
            asset_type = AssetType.document.value
            icon = "document"

        reminder = AssetReminder(
            id=new_id(),
            user_id=user.id,
            asset_type=asset_type,
            title=analysis["title"][:255],
            document_label=analysis.get("summary"),
            expiry_date=expiry,
            notes=analysis.get("extracted_text"),
            icon=icon,
        )
        db.add(reminder)

    @staticmethod
    def _parse_expiry(value: object) -> datetime | None:
        if not value:
            return None
        try:
            day = date.fromisoformat(str(value)[:10])
            return datetime.combine(day, time(hour=9), tzinfo=UTC)
        except ValueError:
            return None

    @staticmethod
    def _to_dict(row: InfoDocument, *, include_image: bool = False) -> dict:
        meta = INFO_CATEGORY_META.get(row.category, ("ארכיון", "archive"))
        data = {
            "id": row.id,
            "category": row.category,
            "category_title": meta[0],
            "title": row.title or "מסמך ללא שם",
            "summary": row.summary,
            "extracted_text": row.extracted_text,
            "expiry_date": row.expiry_date.date().isoformat() if row.expiry_date else None,
            "confidence": row.confidence,
            "icon": meta[1],
            "has_image": bool(row.image_data),
            "mime_type": row.mime_type or "image/jpeg",
            "created_at": row.created_at.isoformat() if row.created_at else None,
            "image_data_url": None,
        }
        if include_image and row.image_data:
            mime = row.mime_type or "image/jpeg"
            data["image_data_url"] = f"data:{mime};base64,{row.image_data}"
        return data
