import json
import logging
import re
from datetime import UTC, datetime
from app.services.date_extract import extract_deadline_iso, israel_now, israel_today

from openai import OpenAI
from sqlalchemy.orm import Session

from app.config import settings
from app.core.security import new_id
from app.models import DailyBrief, InfoDocCategory, Task, TaskPriority, TaskStatus, User

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

        # Only process when the Hebrew word משימה appears (emails + WhatsApp transcripts)
        if not self.has_task_keyword(subject, snippet):
            logger.debug("Skipping email without keyword '%s': %r", TASK_KEYWORD, subject[:120])
            return None, "skipped_no_task_keyword"

        if self.client:
            try:
                analysis = self._openai_analysis(subject, sender, snippet)
                analysis = self._apply_task_keyword_override(subject, snippet, analysis)
                analysis = self._enrich_deadline(subject, snippet, analysis)
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
            analysis = self._enrich_deadline(subject, snippet, analysis)
            logger.info(
                "Email task detected via Hebrew heuristics: %r",
                analysis.get("title", subject)[:120],
            )
            return analysis, "heuristic"

        analysis = self._task_keyword_fallback(subject, snippet)
        analysis = self._enrich_deadline(subject, snippet, analysis)
        logger.info("Email task detected via keyword '%s': %r", TASK_KEYWORD, subject[:120])
        return analysis, "task_keyword"

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

    def analyze_document_image(
        self,
        *,
        image_bytes: bytes,
        mime_type: str = "image/jpeg",
        filename: str | None = None,
    ) -> dict:
        """Classify a document photo into an Info hub category."""
        if self.client and image_bytes:
            try:
                return self._openai_document_analysis(image_bytes, mime_type)
            except Exception as exc:
                logger.warning("OpenAI document analysis failed, using heuristics: %s", exc)
        return self._heuristic_document_analysis(filename=filename)

    def _openai_document_analysis(self, image_bytes: bytes, mime_type: str) -> dict:
        import base64

        b64 = base64.b64encode(image_bytes).decode("ascii")
        data_url = f"data:{mime_type};base64,{b64}"
        prompt = """Analyze this document photo for a Hebrew personal info hub.
Return JSON only with keys:
- category: one of personal_docs | ideas | summaries | links | archive | vehicle | insurance
- title: short Hebrew title (e.g. דרכון, תעודת זהות, רשימת קניות)
- summary: 1 short Hebrew sentence describing the document
- extracted_text: key text visible on the document (Hebrew/English), or empty string
- expiry_date: YYYY-MM-DD if an expiry/due date is visible, else null
- confidence: 0-1 float

Category rules:
- passport, ID card, license, contract, certificate → personal_docs
- shopping list, project notes, ideas, sketches → ideas
- book notes, meeting notes, summaries, notebooks → summaries
- screenshot with URL, QR, article link → links
- vehicle test / רשיון רכב / טסט → vehicle
- insurance policy / ביטוח → insurance
- unclear / old / misc → archive

Respond with valid JSON only."""
        response = self.client.chat.completions.create(
            model=settings.openai_model,
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You classify personal documents from photos. "
                        "Respond with valid JSON only. Titles and summaries in Hebrew."
                    ),
                },
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {"type": "image_url", "image_url": {"url": data_url}},
                    ],
                },
            ],
            temperature=0.1,
            max_tokens=800,
        )
        content = response.choices[0].message.content or "{}"
        # Strip markdown fences if the model wraps JSON
        content = content.strip()
        if content.startswith("```"):
            content = re.sub(r"^```(?:json)?\s*", "", content)
            content = re.sub(r"\s*```$", "", content)
        data = json.loads(content)
        return self._normalize_document_analysis(data)

    def _heuristic_document_analysis(self, *, filename: str | None = None) -> dict:
        name = (filename or "").lower()
        category = InfoDocCategory.personal_docs.value
        title = "מסמך שצולם"
        if any(w in name for w in ("passport", "דרכון", "id", "זהות")):
            category = InfoDocCategory.personal_docs.value
            title = "מסמך אישי"
        elif any(w in name for w in ("idea", "רעיון", "shopping", "קניות")):
            category = InfoDocCategory.ideas.value
            title = "רעיון / פרויקט"
        elif any(w in name for w in ("note", "summary", "סיכום")):
            category = InfoDocCategory.summaries.value
            title = "סיכום"
        elif any(w in name for w in ("link", "url", "קישור")):
            category = InfoDocCategory.links.value
            title = "קישור"
        elif any(w in name for w in ("insurance", "ביטוח")):
            category = InfoDocCategory.insurance.value
            title = "ביטוח"
        elif any(w in name for w in ("car", "vehicle", "טסט", "רכב")):
            category = InfoDocCategory.vehicle.value
            title = "רכב"
        return {
            "category": category,
            "title": title,
            "summary": "מסמך שנוסף מצילום (ניתוח בסיסי ללא AI).",
            "extracted_text": "",
            "expiry_date": None,
            "confidence": 0.35,
        }

    @staticmethod
    def _normalize_document_analysis(data: dict) -> dict:
        allowed = {c.value for c in InfoDocCategory}
        category = str(data.get("category") or InfoDocCategory.archive.value)
        if category not in allowed:
            category = InfoDocCategory.archive.value
        confidence = data.get("confidence", 0.7)
        try:
            confidence = float(confidence)
        except (TypeError, ValueError):
            confidence = 0.5
        return {
            "category": category,
            "title": (str(data.get("title") or "מסמך").strip()[:255] or "מסמך"),
            "summary": (str(data.get("summary") or "").strip() or None),
            "extracted_text": (str(data.get("extracted_text") or "").strip() or None),
            "expiry_date": data.get("expiry_date") or None,
            "confidence": max(0.0, min(1.0, confidence)),
        }

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

    def _enrich_deadline(self, subject: str, snippet: str, analysis: dict) -> dict:
        text = f"{subject} {snippet}"
        if not analysis.get("deadline"):
            extracted = extract_deadline_iso(text, reference=israel_today())
            if extracted:
                analysis["deadline"] = extracted
                logger.info("Extracted task deadline from text: %s", extracted)
            return analysis

        try:
            parsed = datetime.fromisoformat(str(analysis["deadline"]).replace("Z", "+00:00"))
            if parsed.tzinfo is None:
                parsed = parsed.replace(tzinfo=UTC)
            analysis["deadline"] = parsed.isoformat()
        except ValueError:
            extracted = extract_deadline_iso(text, reference=israel_today())
            analysis["deadline"] = extracted
        return analysis

    def _openai_analysis(self, subject: str, sender: str, snippet: str) -> dict:
        today = israel_now().strftime("%Y-%m-%d")
        weekday_names = ["שני", "שלישי", "רביעי", "חמישי", "שישי", "שבת", "ראשון"]
        weekday = weekday_names[israel_today().weekday()]
        prompt = f"""Analyze this Hebrew email and extract an actionable task.
The email already contains the word "משימה" — always set is_actionable to true.
Write title and description in Hebrew only.
Today's date in Israel is {today} ({weekday}). Resolve relative dates like "מחר", "יום שישי", "21/07" against this date.
Return JSON only with keys:
- is_actionable (boolean)
- title (string, short action item in Hebrew)
- description (string in Hebrew)
- priority (critical|high|medium|low|none)
- priority_score (0-100 float)
- deadline (ISO8601 string with timezone, or null if no date mentioned)

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
