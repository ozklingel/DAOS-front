# Production — Render + WhatsApp (כל יוזר, כל מספר)

אין תלות במספר ספציפי. כל יוזר מחבר **את המספר שלו** באפליקציה.

---

## שלב 1 — Deploy ל-Render

### URLs

| מה | URL |
|----|-----|
| Render Dashboard | https://dashboard.render.com |
| GitHub repo | https://github.com/ozklingel/DAOS-front |
| Meta Developers | https://developers.facebook.com/apps/ |

### פקודות (push ל-GitHub)

```powershell
cd "C:\Users\OZKL\OneDrive - AMDOCS\Backup Folders\Documents\projects\tasks"
git add render.yaml backend/
git commit -m "Render production deploy"
git push origin main
```

### ב-Render

1. https://dashboard.render.com → **New** → **Blueprint**
2. חבר repo → Render יקרא `render.yaml`
3. **daos-api** → **Environment** → הוסף (מה-`backend/.env`):

```
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
GOOGLE_ANDROID_CLIENT_ID=...
OPENAI_API_KEY=...
WHATSAPP_VERIFY_TOKEN=DAOS
WHATSAPP_ACCESS_TOKEN=...
WHATSAPP_PHONE_NUMBER_ID=...
WHATSAPP_APP_SECRET=...        ← App Secret אמיתי מ-Meta
WHATSAPP_GRAPH_API_VERSION=v25.0
```

4. **Manual Deploy**

### בדיקה

```powershell
Invoke-RestMethod https://daos-api.onrender.com/health
```

→ `status: ok`

**API production:** `https://daos-api.onrender.com/api/v1`

---

## שלב 2 — Meta Webhook

1. https://developers.facebook.com → האפליקציה → **WhatsApp** → **Configuration**

| שדה | ערך |
|-----|-----|
| Callback URL | `https://daos-api.onrender.com/webhooks/whatsapp` |
| Verify token | `DAOS` |

2. **Verify and save**
3. Subscribe: ✅ **messages**

### בדיקת webhook (PowerShell)

```powershell
Invoke-RestMethod "https://daos-api.onrender.com/webhooks/whatsapp?hub.mode=subscribe&hub.verify_token=DAOS&hub.challenge=test123"
```

→ `test123`

---

## שלב 3 — אפליקציה → Production API

```powershell
cd mobile
.\scripts\dev_web.ps1
```

**לפני זה** — ערוך `mobile/scripts/dev_web.ps1` שורת API (או הרץ ידנית):

```powershell
flutter run -d chrome `
  --web-port=5173 `
  --web-hostname=127.0.0.1 `
  --dart-define=API_BASE_URL=https://daos-api.onrender.com/api/v1 `
  --dart-define=GOOGLE_SERVER_CLIENT_ID=812104653331-ur4g34kfo6seil4f6h06igl08ks9ecmt.apps.googleusercontent.com
```

---

## שלב 4 — זרימת יוזר (כל מספר)

```
1. יוזר מתחבר Google באפליקציה
2. הגדרות → אינטגרציות → חבר WhatsApp → מזין את המספר שלו (למשל 0501234567)
3. יוזר שולח מהטלפון שלו הודעה למספר העסקי של Meta:
   "משימה: לשלוח דוח ללקוח"
4. משימה נוצרת בחשבון שלו
```

**אין מספר קבוע בקוד** — כל יוזר = מספר משלו ב-DB.

---

## Meta Development vs Live

| מצב Meta | מי יכול לשלוח הודעות |
|----------|----------------------|
| **Development** | רק מספרים שהוספת ב-API Setup → **Add phone number** |
| **Live** | כל מספר (אחרי אישור Meta) |

ל-production אמיתי: Meta → App → **Go Live** (דורש Privacy Policy + Business verification).

בינתיים (Development): כל יוזר שרוצה לבדוק — **הוסף את מספרו** ב-Meta API Setup.

---

## URLs סיכום

| | |
|--|--|
| Health | https://daos-api.onrender.com/health |
| API | https://daos-api.onrender.com/api/v1 |
| Webhook | https://daos-api.onrender.com/webhooks/whatsapp |
| Docs | https://daos-api.onrender.com/docs |
| Render logs | https://dashboard.render.com → daos-api → Logs |

---

## מה **לא** עובד ב-production

- `DEBUG=false` → `/whatsapp/dev-inbound` ו-`/whatsapp/simulate` **כבויים**
- רק WhatsApp אמיתי דרך webhook

---

## Dev מקומי (אופציונלי)

רק עם `DEBUG=true` על localhost:

```powershell
.\scripts\whatsapp_task_now.ps1 -Phone "0501234567"
```

המספר חייב להיות מחובר באפליקציה לאותו חשבון.
