from datetime import UTC, date, datetime, time, timedelta

from sqlalchemy.orm import Session

from app.models import Task, User


class HubService:
    """Mock + task-derived data for DAOS hub pages (profile, calendar, finance, info)."""

    def get_profile(self, user: User) -> dict:
        username = user.email.split("@")[0] if user.email else "user"
        return {
            "id": user.id,
            "full_name": user.name or "משתמש DAOS",
            "email": user.email,
            "date_of_birth": "15.05.1990",
            "username": username,
            "two_factor_enabled": True,
            "subscription_plan": "פרימיום (שנתי)",
            "subscription_expires": "31.12.2026",
            "avatar_url": user.avatar_url,
        }

    def get_calendar(self, db: Session, user: User, day: date) -> dict:
        start = datetime.combine(day, time.min, tzinfo=UTC)
        end = start + timedelta(days=1)

        task_events = []
        tasks = (
            db.query(Task)
            .filter(
                Task.user_id == user.id,
                Task.status.in_(["open", "overdue", "snoozed"]),
                Task.deadline.isnot(None),
                Task.deadline >= start,
                Task.deadline < end,
            )
            .order_by(Task.deadline.asc())
            .all()
        )
        for task in tasks:
            deadline = task.deadline
            if deadline is None:
                continue
            start_at = deadline - timedelta(minutes=30)
            task_events.append(
                {
                    "id": task.id,
                    "title": task.title,
                    "subtitle": task.description or "",
                    "category": self._task_category(task.title),
                    "start_time": start_at.strftime("%H:%M"),
                    "end_time": deadline.strftime("%H:%M"),
                    "icon": self._category_icon(self._task_category(task.title)),
                    "source": "task",
                }
            )

        demo_events = self._demo_calendar_events(day)
        reminder_events = self._asset_events(db, user, day)
        events = sorted(demo_events + reminder_events + task_events, key=lambda e: e["start_time"])

        days = self._calendar_strip(day)
        return {
            "selected_date": day.isoformat(),
            "month_label": self._hebrew_month(day),
            "days": days,
            "events": events,
        }

    def get_finance(self, db: Session, user: User) -> dict:
        from app.services.budget_service import BudgetService

        return BudgetService().get_finance(db, user, selected_type="home")

    def get_info_hub(self, db: Session, user: User) -> dict:
        from app.services.asset_service import AssetService

        return AssetService().get_info_hub(db, user)

    def _asset_events(self, db: Session, user: User, day: date) -> list[dict]:
        from app.services.asset_service import AssetService

        return AssetService().calendar_events(db, user, day)

    def _calendar_strip(self, center: date) -> list[dict]:
        today = date.today()
        days = []
        for offset in range(-3, 4):
            d = center + timedelta(days=offset)
            days.append(
                {
                    "date": d.isoformat(),
                    "day_number": d.day,
                    "is_today": d == today,
                    "is_selected": d == center,
                    "label": "היום" if d == today else str(d.day),
                }
            )
        return days

    def _demo_calendar_events(self, day: date) -> list[dict]:
        if day != date.today():
            return []
        return [
            {
                "id": "demo-3",
                "title": "להתקשר ליוסי (קשרים) - שיחת עדכון",
                "subtitle": "",
                "category": "קשרים",
                "start_time": "12:00",
                "end_time": "13:00",
                "icon": "contacts",
                "source": "demo",
            },
            {
                "id": "demo-4",
                "title": "לתאם פגישה עם רו״ח (עבודה)",
                "subtitle": "",
                "category": "עבודה",
                "start_time": "15:00",
                "end_time": "16:30",
                "icon": "work",
                "source": "demo",
            },
            {
                "id": "demo-5",
                "title": "אימון כושר (בריאות) - חדר כושר",
                "subtitle": "",
                "category": "בריאות",
                "start_time": "17:30",
                "end_time": "19:00",
                "icon": "health",
                "source": "demo",
            },
        ]

    @staticmethod
    def _hebrew_month(d: date) -> str:
        months = [
            "ינואר",
            "פברואר",
            "מרץ",
            "אפריל",
            "מאי",
            "יוני",
            "יולי",
            "אוגוסט",
            "ספטמבר",
            "אוקטובר",
            "נובמבר",
            "דצמבר",
        ]
        return months[d.month - 1]

    @staticmethod
    def _task_category(title: str) -> str:
        lowered = title.lower()
        if any(w in title for w in ("ביטוח", "שכר", "תשלום", "חשבון")):
            return "פיננסי"
        if any(w in title for w in ("רכב", "מוסך", "טסט")):
            return "רכב"
        if any(w in title for w in ("להתקשר", "שיחה", "פגישה")):
            return "קשרים"
        if any(w in lowered for w in ("account", "work", "עבודה")):
            return "עבודה"
        return "כללי"

    @staticmethod
    def _category_icon(category: str) -> str:
        mapping = {
            "רכב": "car",
            "פיננסי": "finance",
            "קשרים": "contacts",
            "עבודה": "work",
            "בריאות": "health",
            "כללי": "task",
        }
        return mapping.get(category, "task")
