"""Extract task deadlines from Hebrew/English date phrases in message text."""

from __future__ import annotations

import re
from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo

ISRAEL_TZ = ZoneInfo("Asia/Jerusalem")

HEBREW_MONTHS: dict[str, int] = {
    "ינואר": 1,
    "פברואר": 2,
    "מרץ": 3,
    "מרס": 3,
    "אפריל": 4,
    "מאי": 5,
    "יוני": 6,
    "יולי": 7,
    "אוגוסט": 8,
    "ספטמבר": 9,
    "אוקטובר": 10,
    "נובמבר": 11,
    "דצמבר": 12,
}

HEBREW_WEEKDAY_TO_PYTHON: dict[str, int] = {
    "ראשון": 6,
    "שני": 0,
    "שלישי": 1,
    "רביעי": 2,
    "חמישי": 3,
    "שישי": 4,
    "שבת": 5,
}

ENGLISH_MONTHS: dict[str, int] = {
    "january": 1,
    "february": 2,
    "march": 3,
    "april": 4,
    "may": 5,
    "june": 6,
    "july": 7,
    "august": 8,
    "september": 9,
    "october": 10,
    "november": 11,
    "december": 12,
}


def israel_now() -> datetime:
    return datetime.now(ISRAEL_TZ)


def israel_today() -> date:
    return israel_now().date()


def deadline_at_end_of_day(day: date, hour: int = 17) -> datetime:
    return datetime.combine(day, time(hour, 0), tzinfo=ISRAEL_TZ)


def deadline_to_iso(deadline: datetime) -> str:
    return deadline.isoformat()


def _resolve_year(month: int, day: int, reference: date) -> int:
    year = reference.year
    try:
        candidate = date(year, month, day)
    except ValueError:
        return year
    if candidate < reference - timedelta(days=1):
        return year + 1
    return year


def _next_weekday(reference: date, weekday: int) -> date:
    days_ahead = (weekday - reference.weekday()) % 7
    return reference + timedelta(days=days_ahead)


def _parse_numeric_date(match: re.Match[str], reference: date) -> date | None:
    day = int(match.group(1))
    month = int(match.group(2))
    year_group = match.group(3)
    if year_group:
        year = int(year_group)
        if year < 100:
            year += 2000
    else:
        year = _resolve_year(month, day, reference)
    try:
        return date(year, month, day)
    except ValueError:
        return None


def extract_deadline(text: str, reference: date | None = None) -> datetime | None:
    """Return a timezone-aware deadline parsed from free-form Hebrew/English text."""
    if not text or not text.strip():
        return None

    ref = reference or israel_today()
    normalized = " ".join(text.split())

    if re.search(r"\bמחרתיים\b", normalized):
        return deadline_at_end_of_day(ref + timedelta(days=2))
    if re.search(r"\bמחר\b", normalized):
        return deadline_at_end_of_day(ref + timedelta(days=1))
    if re.search(r"\bהיום\b", normalized):
        return deadline_at_end_of_day(ref)

    in_days = re.search(r"בעוד\s+(\d{1,3})\s+י(?:מ)?(?:ים)?", normalized)
    if in_days:
        return deadline_at_end_of_day(ref + timedelta(days=int(in_days.group(1))))

    weekday_match = re.search(
        r"(?:ביום|יום)\s+(ראשון|שני|שלישי|רביעי|חמישי|שישי|שבת)\b",
        normalized,
    )
    if weekday_match:
        weekday = HEBREW_WEEKDAY_TO_PYTHON[weekday_match.group(1)]
        return deadline_at_end_of_day(_next_weekday(ref, weekday))

    hebrew_month_match = re.search(
        r"(\d{1,2})\s*ב(?:חודש\s+)?(" + "|".join(HEBREW_MONTHS) + r")\b",
        normalized,
    )
    if hebrew_month_match:
        day = int(hebrew_month_match.group(1))
        month = HEBREW_MONTHS[hebrew_month_match.group(2)]
        year = _resolve_year(month, day, ref)
        try:
            return deadline_at_end_of_day(date(year, month, day))
        except ValueError:
            pass

    english_month_match = re.search(
        r"\b(\d{1,2})\s+(january|february|march|april|may|june|july|august|september|october|november|december)\b",
        normalized,
        flags=re.IGNORECASE,
    )
    if english_month_match:
        day = int(english_month_match.group(1))
        month = ENGLISH_MONTHS[english_month_match.group(2).lower()]
        year = _resolve_year(month, day, ref)
        try:
            return deadline_at_end_of_day(date(year, month, day))
        except ValueError:
            pass

    for pattern in (
        r"(?:עד(?:\s+ל|\s+ה)?|לתאריך|בתאריך|תאריך)\s*(\d{1,2})[./-](\d{1,2})(?:[./-](\d{2,4}))?",
        r"\b(\d{1,2})[./-](\d{1,2})(?:[./-](\d{2,4}))?\b",
    ):
        match = re.search(pattern, normalized)
        if match:
            parsed = _parse_numeric_date(match, ref)
            if parsed:
                return deadline_at_end_of_day(parsed)

    return None


def extract_deadline_iso(text: str, reference: date | None = None) -> str | None:
    deadline = extract_deadline(text, reference=reference)
    return deadline_to_iso(deadline) if deadline else None
