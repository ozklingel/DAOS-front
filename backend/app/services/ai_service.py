import json
from datetime import UTC, datetime

from openai import OpenAI
from sqlalchemy.orm import Session

from app.config import settings
from app.core.security import new_id
from app.models import DailyBrief, Task, TaskPriority, TaskStatus, User


class AIService:
    def __init__(self) -> None:
        self.client = OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None

    def analyze_email(self, *, subject: str, sender: str, snippet: str) -> dict | None:
        if not self.client:
            return self._heuristic_analysis(subject, sender, snippet)

        prompt = f"""Analyze this email and decide if it contains an actionable task.
Return JSON only with keys:
- is_actionable (boolean)
- title (string, short action item)
- description (string)
- priority (critical|high|medium|low|none)
- priority_score (0-100 float)
- deadline (ISO8601 string or null)

Email:
From: {sender}
Subject: {subject}
Snippet: {snippet}
"""
        try:
            response = self.client.chat.completions.create(
                model=settings.openai_model,
                messages=[
                    {"role": "system", "content": "You extract actionable tasks from emails. Respond with valid JSON only."},
                    {"role": "user", "content": prompt},
                ],
                temperature=0.2,
            )
            content = response.choices[0].message.content or "{}"
            return json.loads(content)
        except Exception:
            return self._heuristic_analysis(subject, sender, snippet)

    def _heuristic_analysis(self, subject: str, sender: str, snippet: str) -> dict | None:
        text = f"{subject} {snippet}".lower()
        action_words = ["action required", "please review", "deadline", "urgent", "asap", "approve", "confirm", "follow up"]
        if not any(word in text for word in action_words):
            return None

        priority = TaskPriority.medium.value
        score = 55.0
        if any(w in text for w in ["urgent", "asap", "critical"]):
            priority = TaskPriority.critical.value
            score = 92.0
        elif "deadline" in text:
            priority = TaskPriority.high.value
            score = 78.0

        return {
            "is_actionable": True,
            "title": subject[:200] or "Review email",
            "description": snippet[:500],
            "priority": priority,
            "priority_score": score,
            "deadline": None,
        }

    def generate_daily_brief(self, db: Session, user: User, tasks: list[Task]) -> DailyBrief:
        open_tasks = [t for t in tasks if t.status in {TaskStatus.open.value, TaskStatus.overdue.value}]
        critical = [t for t in open_tasks if t.priority in {TaskPriority.critical.value, TaskPriority.high.value}]

        if self.client:
            task_lines = "\n".join(
                f"- [{t.priority}] {t.title} (deadline: {t.deadline})" for t in open_tasks[:20]
            )
            prompt = f"""Write a concise daily briefing for a busy professional.
Return JSON with keys: summary (one sentence), content (2-3 paragraphs), insights (array of 2-4 short strings).

Open tasks:
{task_lines or 'No open tasks.'}
"""
            try:
                response = self.client.chat.completions.create(
                    model=settings.openai_model,
                    messages=[
                        {"role": "system", "content": "You write productivity briefings. JSON only."},
                        {"role": "user", "content": prompt},
                    ],
                    temperature=0.4,
                )
                data = json.loads(response.choices[0].message.content or "{}")
                summary = data.get("summary", f"You have {len(critical)} urgent tasks.")
                content = data.get("content", summary)
                insights = data.get("insights", [])
            except Exception:
                summary, content, insights = self._fallback_brief(open_tasks, critical)
        else:
            summary, content, insights = self._fallback_brief(open_tasks, critical)

        brief = DailyBrief(
            id=new_id(),
            user_id=user.id,
            summary=summary,
            content=content,
            insights_json=json.dumps(insights),
            highlighted_task_ids_json=json.dumps([t.id for t in critical[:5]]),
            generated_at=datetime.now(UTC),
        )
        db.add(brief)
        db.commit()
        db.refresh(brief)
        return brief

    def _fallback_brief(self, open_tasks: list[Task], critical: list[Task]) -> tuple[str, str, list[str]]:
        summary = f"You have {len(critical)} urgent tasks that require attention."
        content = (
            f"There are {len(open_tasks)} open tasks in your inbox-derived queue. "
            f"Focus on the {len(critical)} high-priority items first to stay ahead of deadlines."
        )
        insights = [
            f"{len(critical)} critical or high-priority tasks need action today.",
            f"{len(open_tasks)} total open tasks remain in your queue.",
        ]
        return summary, content, insights
