"""LangGraph pipeline: task vs casual conversation, then field extraction."""

from __future__ import annotations

import json
import logging
from typing import Literal, TypedDict

from langgraph.graph import END, START, StateGraph
from openai import OpenAI

from app.services.date_extract import israel_now, israel_today

logger = logging.getLogger(__name__)

_graph = None


class TaskClassifierState(TypedDict, total=False):
    channel: str
    subject: str
    sender: str
    snippet: str
    is_actionable: bool
    confidence: float
    reasoning: str
    title: str | None
    description: str | None
    priority: str
    priority_score: float
    deadline: str | None
    verified: bool


def _channel_label(channel: str) -> str:
    return {
        "email": "מייל",
        "whatsapp": "הודעת WhatsApp",
        "voice": "הודעה קולית",
    }.get(channel, channel)


def _parse_json(content: str) -> dict:
    text = (content or "{}").strip()
    if text.startswith("```"):
        text = text.removeprefix("```json").removeprefix("```").removesuffix("```").strip()
    return json.loads(text or "{}")


def _classify_intent(state: TaskClassifierState, *, client: OpenAI, model: str) -> dict:
    today = israel_now().strftime("%Y-%m-%d")
    channel = _channel_label(state["channel"])
    prompt = f"""החלט אם ההודעה הבאה ({channel}) היא **משימה לביצוע** או **שיחה/מידע בלי פעולה**.

היום: {today}

משימה (is_actionable=true):
- בקשה לבצע משהו: לשלם, לבדוק, לשלוח, לאשר, לתאם, להתקשר, לטפל
- תזכורת, דדליין, "צריך", "בבקשה", "אל תשכח"
- המילה "משימה" או ניסוח משימתי ברור
- מייל ארגוני שדורש פעולה (תשלום, אישור, מסמך)

שיחה / לא משימה (is_actionable=false):
- צ'אט חברתי, תודה, "בסדר", "קיבלתי", אימוג'ים
- שאלה כללית בלי בקשה לביצוע
- ניוזלטר, OTP, פרסום, מידע ללא פעולה

From: {state["sender"]}
Subject: {state["subject"]}
Body: {state["snippet"]}

החזר JSON בלבד:
- is_actionable (boolean)
- confidence (0-1 — כמה אתה בטוח)
- reasoning (משפט קצר בעברית)
"""
    response = client.chat.completions.create(
        model=model,
        messages=[
            {
                "role": "system",
                "content": (
                    "You classify Hebrew messages as actionable tasks vs casual chat. "
                    "Return valid JSON only."
                ),
            },
            {"role": "user", "content": prompt},
        ],
        temperature=0.1,
        response_format={"type": "json_object"},
    )
    data = _parse_json(response.choices[0].message.content or "{}")
    return {
        "is_actionable": bool(data.get("is_actionable")),
        "confidence": float(data.get("confidence") or 0.5),
        "reasoning": str(data.get("reasoning") or "").strip(),
    }


def _verify_intent(state: TaskClassifierState, *, client: OpenAI, model: str) -> dict:
    prompt = f"""בדיקה שנייה — האם זו באמת משימה?

נימוק ראשון: {state.get("reasoning", "")}
From: {state["sender"]}
Subject: {state["subject"]}
Body: {state["snippet"]}

היה **strict**: רק אם יש פעולה ברורה — is_actionable=true.
החזר JSON: is_actionable, confidence, reasoning (עברית).
"""
    response = client.chat.completions.create(
        model=model,
        messages=[
            {
                "role": "system",
                "content": "Second-pass verifier for Hebrew task detection. JSON only.",
            },
            {"role": "user", "content": prompt},
        ],
        temperature=0.0,
        response_format={"type": "json_object"},
    )
    data = _parse_json(response.choices[0].message.content or "{}")
    return {
        "is_actionable": bool(data.get("is_actionable")),
        "confidence": float(data.get("confidence") or 0.5),
        "reasoning": str(data.get("reasoning") or state.get("reasoning") or "").strip(),
        "verified": True,
    }


def _extract_fields(state: TaskClassifierState, *, client: OpenAI, model: str) -> dict:
    weekday_names = ["שני", "שלישי", "רביעי", "חמישי", "שישי", "שבת", "ראשון"]
    weekday = weekday_names[israel_today().weekday()]
    today = israel_now().strftime("%Y-%m-%d")
    channel = _channel_label(state["channel"])

    prompt = f"""חלץ פרטי משימה מה{channel} הבא (כבר אושר שזו משימה).

היום: {today} ({weekday}). פרש תאריכים יחסיים (מחר, יום ראשון…) לפי היום.

From: {state["sender"]}
Subject: {state["subject"]}
Body: {state["snippet"]}

JSON בלבד:
- title (עברית קצרה — הפעולה)
- description (עברית או null)
- priority (critical|high|medium|low|none)
- priority_score (0-100)
- deadline (ISO8601+timezone או null)
"""
    response = client.chat.completions.create(
        model=model,
        messages=[
            {
                "role": "system",
                "content": "Extract Hebrew task fields. JSON only.",
            },
            {"role": "user", "content": prompt},
        ],
        temperature=0.1,
        response_format={"type": "json_object"},
    )
    data = _parse_json(response.choices[0].message.content or "{}")
    return {
        "title": (data.get("title") or state["subject"][:200] or "משימה חדשה").strip(),
        "description": data.get("description"),
        "priority": data.get("priority") or "medium",
        "priority_score": float(data.get("priority_score") or 55),
        "deadline": data.get("deadline"),
    }


def _build_graph(client: OpenAI, model: str):
    def classify_node(state: TaskClassifierState) -> dict:
        return _classify_intent(state, client=client, model=model)

    def verify_node(state: TaskClassifierState) -> dict:
        return _verify_intent(state, client=client, model=model)

    def extract_node(state: TaskClassifierState) -> dict:
        return _extract_fields(state, client=client, model=model)

    def after_classify(state: TaskClassifierState) -> Literal["verify_intent", "extract_fields", "__end__"]:
        if not state.get("is_actionable"):
            return END
        if state.get("confidence", 0) < 0.75:
            return "verify_intent"
        return "extract_fields"

    def after_verify(state: TaskClassifierState) -> Literal["extract_fields", "__end__"]:
        if state.get("is_actionable"):
            return "extract_fields"
        return END

    graph = StateGraph(TaskClassifierState)
    graph.add_node("classify_intent", classify_node)
    graph.add_node("verify_intent", verify_node)
    graph.add_node("extract_fields", extract_node)
    graph.add_edge(START, "classify_intent")
    graph.add_conditional_edges("classify_intent", after_classify)
    graph.add_conditional_edges("verify_intent", after_verify)
    graph.add_edge("extract_fields", END)
    return graph.compile()


def _get_graph(client: OpenAI, model: str):
    global _graph
    if _graph is None:
        _graph = _build_graph(client, model)
    return _graph


def classify_message_with_langgraph(
    *,
    subject: str,
    sender: str,
    snippet: str,
    channel: str,
    client: OpenAI,
    model: str,
) -> dict:
    """Run LangGraph: intent → optional verify → extract fields."""
    graph = _get_graph(client, model)
    result = graph.invoke(
        {
            "channel": channel,
            "subject": subject,
            "sender": sender,
            "snippet": snippet,
        }
    )
    is_actionable = bool(result.get("is_actionable"))
    out: dict = {
        "is_actionable": is_actionable,
        "confidence": float(result.get("confidence") or 0),
        "reasoning": result.get("reasoning"),
    }
    if is_actionable:
        out.update(
            {
                "title": result.get("title") or subject[:200] or "משימה חדשה",
                "description": result.get("description"),
                "priority": result.get("priority") or "medium",
                "priority_score": float(result.get("priority_score") or 55),
                "deadline": result.get("deadline"),
            }
        )
    logger.info(
        "LangGraph classify channel=%s actionable=%s confidence=%.2f reason=%r",
        channel,
        is_actionable,
        out.get("confidence", 0),
        (out.get("reasoning") or "")[:100],
    )
    return out
