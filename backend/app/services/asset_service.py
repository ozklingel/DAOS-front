from datetime import UTC, date, datetime, time

from sqlalchemy.orm import Session

from app.models import AssetReminder, AssetType, User

CATEGORY_MAP = {
    AssetType.vehicle_test.value: ("רכב", "car"),
    AssetType.car_insurance.value: ("ביטוח רכב", "car"),
    AssetType.home_insurance.value: ("ביטוח דירה", "finance"),
    AssetType.document.value: ("מסמכים", "document"),
}


class AssetService:
    def list_reminders(self, db: Session, user: User) -> list[dict]:
        rows = (
            db.query(AssetReminder)
            .filter(AssetReminder.user_id == user.id)
            .order_by(AssetReminder.expiry_date.asc())
            .all()
        )
        return [self._to_dict(r) for r in rows]

    def get_info_hub(self, db: Session, user: User) -> dict:
        reminders = self.list_reminders(db, user)
        categories = self._build_categories(reminders)
        alert_count = sum(1 for r in reminders if r["status"] in {"overdue", "urgent", "warning"})
        return {
            "categories": categories,
            "reminders": reminders,
            "alerts_count": alert_count,
        }

    def calendar_events(self, db: Session, user: User, day: date) -> list[dict]:
        reminders = self.list_reminders(db, user)
        events = []
        for item in reminders:
            expiry = date.fromisoformat(item["expiry_date"])
            if expiry != day:
                continue
            category, _icon = CATEGORY_MAP.get(item["asset_type"], ("כללי", "task"))
            events.append(
                {
                    "id": item["id"],
                    "title": item["title"],
                    "subtitle": item.get("document_label") or item.get("notes") or "",
                    "category": category,
                    "start_time": "09:00",
                    "end_time": "10:00",
                    "icon": item["icon"],
                    "source": "reminder",
                }
            )
        return events

    def update_reminder(
        self,
        db: Session,
        user: User,
        reminder_id: str,
        *,
        title: str | None = None,
        expiry_date: date | None = None,
        notes: str | None = None,
    ) -> dict:
        row = (
            db.query(AssetReminder)
            .filter(AssetReminder.user_id == user.id, AssetReminder.id == reminder_id)
            .one_or_none()
        )
        if not row:
            raise ValueError("Reminder not found")
        if title is not None:
            row.title = title.strip()
        if expiry_date is not None:
            row.expiry_date = datetime.combine(expiry_date, time(hour=9), tzinfo=UTC)
        if notes is not None:
            row.notes = notes.strip() or None
        row.updated_at = datetime.now(UTC)
        db.commit()
        db.refresh(row)
        return self._to_dict(row)

    def _build_categories(self, reminders: list[dict]) -> list[dict]:
        grouped: dict[str, list[str]] = {
            "vehicle": [],
            "insurance": [],
            "documents": [],
        }
        for item in reminders:
            label = self._item_label(item)
            if item["asset_type"] == AssetType.vehicle_test.value:
                grouped["vehicle"].append(label)
            elif item["asset_type"] in {
                AssetType.car_insurance.value,
                AssetType.home_insurance.value,
            }:
                grouped["insurance"].append(label)
            elif item["asset_type"] == AssetType.document.value:
                grouped["documents"].append(label)

        return [
            {
                "id": "vehicle",
                "title": "רכב",
                "icon": "car",
                "items": grouped["vehicle"],
            },
            {
                "id": "insurance",
                "title": "ביטוח",
                "icon": "finance",
                "items": grouped["insurance"],
            },
            {
                "id": "documents",
                "title": "מסמכים",
                "icon": "document",
                "items": grouped["documents"],
            },
        ]

    @staticmethod
    def _item_label(item: dict) -> str:
        days = item["days_until"]
        if days < 0:
            suffix = f" — באיחור {abs(days)} י'"
        elif days == 0:
            suffix = " — היום"
        else:
            suffix = f" — בעוד {days} י'"
        return f"{item['title']}{suffix}"

    @staticmethod
    def _status(days_until: int) -> str:
        if days_until < 0:
            return "overdue"
        if days_until <= 7:
            return "urgent"
        if days_until <= 30:
            return "warning"
        return "ok"

    def _to_dict(self, row: AssetReminder) -> dict:
        expiry = row.expiry_date.date()
        days_until = (expiry - date.today()).days
        return {
            "id": row.id,
            "asset_type": row.asset_type,
            "title": row.title,
            "document_label": row.document_label,
            "expiry_date": expiry.isoformat(),
            "days_until": days_until,
            "status": self._status(days_until),
            "icon": row.icon,
            "notes": row.notes,
        }
