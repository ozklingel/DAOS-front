# DAOS — פקודות הרצה

## ⚡ פיתוח UI מהיר (מומלץ) — Chrome

אין build לאנדרoid, hot reload מהיר, אין adb.

**טרמינל 1 — backend:**
```powershell
cd backend
.\.venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

**טרמינל 2 — אפליקציה ב-Chrome:**
```powershell
cd mobile
.\scripts\dev_web.ps1
```

(`dev_web.ps1` reads `GOOGLE_CLIENT_ID` from `backend/.env` automatically.)

→ התחבר עם **Dev Login** (כפתור כחול) — **לא** Google.

> Google Sign-In ב-Web דורש הגדרה ב-Google Cloud Console. לעיצוב מסכים Dev Login מספיק.

---

## Android מול Render (SMS)

```powershell
cd mobile
.\scripts\prod_android.ps1
# או APK:
.\scripts\prod_android.ps1 apk
```

אחרי התקנה: **הגדרות → אינטגרציות → SMS → אשר SMS וסנכרן עכשיו**

---

## בדיקת AI לזיהוי משימות ממיילים (עברית בלבד)

**1. האם AI פעיל?**
```powershell
curl http://127.0.0.1:8080/api/v1/emails/ai-status
```
`ai_enabled: true` = משתמש ב-OpenAI (`OPENAI_API_KEY` ב-`backend/.env`).

**2. בדיקת מייל לדוגמה (DEBUG=true):**
```powershell
curl -X POST http://127.0.0.1:8080/api/v1/emails/analyze-preview `
  -H "Content-Type: application/json" `
  -d "{\"subject\":\"דחוף: נא לאשר את החוזה\",\"snippet\":\"נדרש אישורך עד יום ראשון\",\"sender\":\"boss@co.il\"}"
```
בתשובה: `source` = `openai` | `heuristic` | `skipped_not_hebrew` | `no_match`

**3. סנכרון מיילים אמיתי** (אחרי התחברות + Gmail מחובר):
```powershell
curl -X POST http://127.0.0.1:8080/api/v1/emails/sync -H "Authorization: Bearer YOUR_TOKEN"
```

> רק מיילים עם טקסט **עברי** בנושא/תקציר יהפכו למשימות.

---

## טיפים לעיצוב מהיר

| פעולה | קיצור |
|--------|--------|
| Hot reload (אחרי שינוי UI) | `r` בטרמינל |
| Hot restart | `R` |
| פתיחת DevTools | `F12` בדפדפן |

עצב מסכים ב-Chrome — העלה למובייל רק כשצריך לבדוק OAuth / push / SMS / RTL על מכשיר.
