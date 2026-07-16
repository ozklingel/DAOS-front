import json
import logging
import re
from datetime import UTC, datetime

from openai import OpenAI
from sqlalchemy.orm import Session

from app.config import settings
from app.core.security import new_id
from app.models import DailyBrief, Task, TaskPriority, TaskStatus, User

logger = logging.getLogger(__name__)

HEBREW_CHAR_RE = re.compile(r"[\u0590-\u05FF]")
TASK_KEYWORD = "משימה"


class AIService:
    def __init__(self) -> None:
        self.client = OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None

    @property
    def ai_enabled(self) -> bool:
        return self.client is not None

    @staticmethod
    def is_hebrew_email(subject: str, snippet: str) -> bool:
        """True when subject or snippet contains Hebrew letters."""
        return bool(HEBREW_CHAR_RE.search(f"{subject} {snippet}"))

    @staticmethod
    def has_task_keyword(subject: str, snippet: str) -> bool:
        return TASK_KEYWORD in f"{subject} {snippet}"

    def analyze_email(self, *, subject: str, sender: str, snippet: str) -> dict | None:
        analysis, _source = self.analyze_email_detailed(
            subject=subject, sender=sender, snippet=snippet
        )
        return analysis

    def analyze_email_detailed(
        self, *, subject: str, sender: str, snippet: str
    ) -> tuple[dict | None, str]:
        if not self.is_hebrew_email(subject, snippet):
            logger.debug("Skipping non-Hebrew email: %r", subject[:120])
            return None, "skipped_not_hebrew"

        if self.client:
            try:
                analysis = self._openai_analysis(subject, sender, snippet)
                analysis = self._apply_task_keyword_override(subject, snippet, analysis)
                if analysis.get("is_actionable", True):
                    logger.info(
                        "Email task detected via OpenAI (%s): %r",
                        settings.openai_model,
                        analysis.get("title", subject)[:120],
                    )
                    return analysis, "openai"
            except Exception as exc:
                logger.warning("OpenAI analysis failed, using Hebrew heuristics: %s", exc)

        analysis = self._heuristic_analysis(subject, sender, snippet)
        if analysis:
            logger.info(
                "Email task detected via Hebrew heuristics: %r",
                analysis.get("title", subject)[:120],
            )
            return analysis, "heuristic"

        if self.has_task_keyword(subject, snippet):
            analysis = self._task_keyword_fallback(subject, snippet)
            logger.info("Email task detected via keyword '%s': %r", TASK_KEYWORD, subject[:120])
            return analysis, "task_keyword"

        logger.debug("No Hebrew task detected in email: %r", subject[:120])
        return None, "no_match"

    def analyze_voice_transcript(self, transcript: str) -> tuple[dict | None, str]:
        text = transcript.strip()
        if not text:
            return None, "empty"
        return self.analyze_email_detailed(
            subject=text[:200],
            sender="WhatsApp",
            snippet=text,
        )

    def transcribe_audio(self, audio_bytes: bytes, filename: str = "voice.ogg") -> str | None:
        if not self.client or not audio_bytes:
            return None
        try:
            import io

            buffer = io.BytesIO(audio_bytes)
            buffer.name = filename
            response = self.client.audio.transcriptions.create(
                model="whisper-1",
                file=buffer,
                language="he",
            )
            text = (response.text or "").strip()
            logger.info("Whisper transcript (%d chars): %r", len(text), text[:120])
            return text or None
        except Exception as exc:
            logger.warning("Whisper transcription failed: %s", exc)
            return None

    def _apply_task_keyword_override(
        self, subject: str, snippet: str, analysis: dict
    ) -> dict:
        if not self.has_task_keyword(subject, snippet):
            return analysis
        analysis["is_actionable"] = True
        if not analysis.get("title"):
            analysis["title"] = subject[:200] or "משימה חדשה"
        if not analysis.get("description"):
            analysis["description"] = snippet[:500]
        return analysis

    def _task_keyword_fallback(self, subject: str, snippet: str) -> dict:
        return {
            "is_actionable": True,
            "title": subject[:200] or "משימה חדשה",
            "description": snippet[:500],
            "priority": TaskPriority.medium.value,
            "priority_score": 60.0,
            "deadline": None,
        }

    def _openai_analysis(self, subject: str, sender: str, snippet: str) -> dict:
        prompt = f"""Analyze this Hebrew email and decide if it contains an actionable task.
Only treat emails as actionable when they clearly ask the recipient to do something.
If the email contains the word "משימה", always set is_actionable to true.
Write title and description in Hebrew only.
Return JSON only with keys:
- is_actionable (boolean)
- title (string, short action item in Hebrew)
- description (string in Hebrew)
- priority (critical|high|medium|low|none)
- priority_score (0-100 float)
- deadline (ISO8601 string or null)

Email:
From: {sender}
Subject: {subject}
Snippet: {snippet}
"""
        response = self.client.chat.completions.create(
            model=settings.openai_model,
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You extract actionable tasks from Hebrew emails only. "
                        "Respond with valid JSON only. Title and description must be in Hebrew."
                    ),
                },
                {"role": "user", "content": prompt},
            ],
            temperature=0.2,
        )
        content = response.choices[0].message.content or "{}"
        return json.loads(content)

    def _heuristic_analysis(self, subject: str, sender: str, snippet: str) -> dict | None:
        raw = f"{subject} {snippet}"
        if not self.is_hebrew_email(subject, snippet):
            return None

        hebrew_words = [
            "דחוף",
            "דחיפות",
            "בהול",
            "חירום",
            "נדרש",
            "נדרשת",
            "נדרשים",
            "פעולה נדרשת",
            "נדרשת פעולה",
            "נדרש טיפול",
            "אישור",
            "אשר",
            "אנא",
            "בבקשה",
            "מועד אחרון",
            "תאריך יעד",
            "עד ל",
            "עד ה",
            "חשוב",
            "תזכורת",
            "להשיב",
            "לענות",
            "לבדוק",
            "לטפל",
            "לעדכן",
            "לאשר",
            "לחדש",
            "לתאם",
            "להתקשר",
            "לשלם",
            "להגיש",
            "דדליין",
            "משימה",
            "טיפול",
            "פעולה",
        ]

        matched = any(w in raw for w in hebrew_words)
        if not matched:
            matched = bool(
                re.search(
                    r"(לחדש|לטפל|להתקשר|לתאם|לעדכן|לבדוק|לאשר|לשלם|להגיש|להשיב|לענות|נא)\b",
                    raw,
                )
            )
        if not matched:
            return None

        priority = TaskPriority.medium.value
        score = 55.0
        urgent_markers = ["דחוף", "בהול", "חירום", "דחיפות"]
        if any(m in raw for m in urgent_markers):
            priority = TaskPriority.critical.value
            score = 92.0
        elif "מועד" in raw or "תאריך יעד" in raw or "עד ל" in raw:
            priority = TaskPriority.high.value
            score = 78.0

        return {
            "is_actionable": True,
            "title": subject[:200] or "בדוק מייל",
            "description": snippet[:500],
            "priority": priority,
            "priority_score": score,
            "deadline": None,
        }

    def generate_daily_brief(
        self, db: Session, user: User, tasks: list[Task], language: str = "en"
    ) -> DailyBrief:
        open_tasks = [t for t in tasks if t.status in {TaskStatus.open.value, TaskStatus.overdue.value}]
        critical = [t for t in open_tasks if t.priority in {TaskPriority.critical.value, TaskPriority.high.value}]
        lang_note = "Write all text in Hebrew." if language == "he" else "Write in English."

        if self.client:
            task_lines = "\n".join(
                f"- [{t.priority}] {t.title} (deadline: {t.deadline})" for t in open_tasks[:20]
            )
            prompt = f"""Write a concise daily briefing for a busy professional.
{lang_note}
Return JSON with keys: summary (one sentence), content (2-3 paragraphs), insights (array of 2-4 short strings).

Open tasks:
{task_lines or 'No open tasks.'}
"""
            try:
                response = self.client.chat.completions.create(
                    model=settings.openai_model,
                    messages=[
                        {
                            "role": "system",
                            "content": f"You write productivity briefings. JSON only. {lang_note}",
                        },
                        {"role": "user", "content": prompt},
                    ],
                    temperature=0.4,
                )
                data = json.loads(response.choices[0].message.content or "{}")
                summary = data.get("summary", self._fallback_brief(open_tasks, critical, language)[0])
                content = data.get("content", summary)
                insights = data.get("insights", [])
            except Exception:
                summary, content, insights = self._fallback_brief(open_tasks, critical, language)
        else:
            summary, content, insights = self._fallback_brief(open_tasks, critical, language)

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

    def _fallback_brief(
        self, open_tasks: list[Task], critical: list[Task], language: str = "en"
    ) -> tuple[str, str, list[str]]:
        if language == "he":
            summary = f"יש לך {len(critical)} משימות דחופות שדורשות טיפול."
            content = (
                f"יש {len(open_tasks)} משימות פתוחות בתור שנוצר מהמיילים שלך. "
                f"התמקד/י ב-{len(critical)} פריטים בעדיפות גבוהה כדי לעמוד ביעדים."
            )
            insights = [
                f"{len(critical)} משימות קריטיות או בעדיפות גבוהה דורשות פעולה היום.",
                f"נותרו {len(open_tasks)} משימות פתוחות בסך הכל.",
            ]
            return summary, content, insights

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
