from app.models import EnergyLevel, TaskCategory, TaskPriority

ENERGY_COSTS = {
    EnergyLevel.high.value: 35,
    EnergyLevel.medium.value: 20,
    EnergyLevel.low.value: 10,
}

DAILY_ENERGY_BUDGET = 100


def infer_category_and_energy(
    *,
    subject: str,
    snippet: str,
    priority: str = TaskPriority.medium.value,
) -> tuple[str, str]:
    raw = f"{subject} {snippet}"

    category = TaskCategory.general.value
    work_words = ["עבודה", "פרויקט", "לקוח", "פגישה", "רו״ח", "רואה חשבון", "משרד", "דוח"]
    errand_words = ["סופר", "קניות", "דואר", "בנק", "שכר דירה", "תשלום", "חשבון חשמל", "סידורים"]
    health_words = ["כושר", "רופא", "בריאות", "אימון", "תרופ", "חדר כושר", "בדיקה"]

    if any(w in raw for w in work_words):
        category = TaskCategory.work.value
    elif any(w in raw for w in errand_words):
        category = TaskCategory.errands.value
    elif any(w in raw for w in health_words):
        category = TaskCategory.health.value

    energy = EnergyLevel.medium.value
    if priority in {TaskPriority.critical.value, TaskPriority.high.value} or any(
        w in raw for w in ["דחוף", "בהול", "חירום", "דחיפות"]
    ):
        energy = EnergyLevel.high.value
    elif priority == TaskPriority.low.value or any(w in raw for w in ["כשתוכל", "לא דחוף", "מתי ש"]):
        energy = EnergyLevel.low.value

    return category, energy


def energy_cost(level: str) -> int:
    return ENERGY_COSTS.get(level, ENERGY_COSTS[EnergyLevel.medium.value])
