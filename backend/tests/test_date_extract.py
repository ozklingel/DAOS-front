from datetime import date

from app.services.date_extract import extract_deadline


def test_extract_tomorrow():
    ref = date(2026, 7, 21)
    deadline = extract_deadline("משימה: לשלם חשבון מחר", reference=ref)
    assert deadline is not None
    assert deadline.date() == date(2026, 7, 22)
    assert str(deadline.tzinfo) == "Asia/Jerusalem"


def test_extract_numeric_date():
    ref = date(2026, 7, 21)
    deadline = extract_deadline("משימה לטפל עד 25/07", reference=ref)
    assert deadline is not None
    assert deadline.date() == date(2026, 7, 25)


def test_extract_hebrew_month():
    ref = date(2026, 7, 21)
    deadline = extract_deadline("משימה: להגיש דוח עד 30 ביולי", reference=ref)
    assert deadline is not None
    assert deadline.date() == date(2026, 7, 30)


def test_extract_weekday():
    ref = date(2026, 7, 21)  # Tuesday
    deadline = extract_deadline("משימה: לתאם פגישה ביום שישי", reference=ref)
    assert deadline is not None
    assert deadline.date() == date(2026, 7, 24)


def test_extract_day_after_tomorrow():
    ref = date(2026, 7, 21)
    deadline = extract_deadline("משימה דחופה מחרתיים", reference=ref)
    assert deadline is not None
    assert deadline.date() == date(2026, 7, 23)
