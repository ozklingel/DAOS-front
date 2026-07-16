# WhatsApp Bot — Voice/Text → Task (MVP #4)

Hebrew voice or text messages on WhatsApp create tasks in TaskMail.

## Flow

1. **Link phone** — Settings → Integrations → WhatsApp → enter mobile number (972…)
2. **Send message** — Voice note or text in Hebrew to your WhatsApp Business number
3. **Bot replies** — Confirmation in Hebrew; task appears in the app

## Meta Cloud API setup

1. Create app at [developers.facebook.com](https://developers.facebook.com)
2. Add **WhatsApp** product → get **Phone number ID** and **Access token**
3. Set webhook URL (requires HTTPS):
   ```
   https://YOUR_DOMAIN/webhooks/whatsapp
   ```
4. Verify token: same as `WHATSAPP_VERIFY_TOKEN` in `backend/.env`
5. Subscribe to: `messages`

## Backend `.env`

```env
WHATSAPP_VERIFY_TOKEN=my-secret-verify-token
WHATSAPP_ACCESS_TOKEN=EAAxxxxx
WHATSAPP_PHONE_NUMBER_ID=123456789012345
WHATSAPP_APP_SECRET=your-app-secret
OPENAI_API_KEY=sk-...   # required for Whisper + AI analysis
```

## Local dev (no Meta)

With `DEBUG=true` in `backend/.env`:

**Step 1 — get a JWT** (app login token, **not** `WHATSAPP_ACCESS_TOKEN`):

```powershell
$auth = Invoke-RestMethod -Uri http://127.0.0.1:8080/api/v1/auth/dev -Method POST
$token = $auth.access_token
$token
```

Or sign in via the app (Dev Login / Google) and copy the access token from network logs.

**Step 2 — simulate a WhatsApp voice transcript:**

```powershell
Invoke-RestMethod -Uri http://127.0.0.1:8080/api/v1/whatsapp/simulate `
  -Method POST `
  -Headers @{ Authorization = "Bearer $token" } `
  -ContentType "application/json; charset=utf-8" `
  -Body '{"transcript":"משימה: לשלוח דוח ללקוח עד מחר"}'
```

Expected: `created: true` and a new task in the app.

> **401 Unauthorized?** You used the wrong token. `WHATSAPP_ACCESS_TOKEN` is only for Meta Graph API outbound messages. `/whatsapp/simulate` needs the **JWT** from `/auth/dev` or Google sign-in.

## Test outbound send (Meta Graph API)

Your `.env` values must match the working curl:

```env
WHATSAPP_ACCESS_TOKEN=EAAxxxxx
WHATSAPP_PHONE_NUMBER_ID=1281218281733444
WHATSAPP_GRAPH_API_VERSION=v25.0
```

**Template message** (works anytime — Meta-approved template):

```powershell
$token = $env:WHATSAPP_ACCESS_TOKEN   # from backend/.env
$phoneId = $env:WHATSAPP_PHONE_NUMBER_ID

curl.exe -i -X POST "https://graph.facebook.com/v25.0/$phoneId/messages" `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{\"messaging_product\":\"whatsapp\",\"to\":\"972549247616\",\"type\":\"template\",\"template\":{\"name\":\"YOUR_TEMPLATE\",\"language\":{\"code\":\"en_US\"}}}'
```

**Free-text reply** (bot uses this after a user messages you — only within Meta’s 24-hour session window):

```powershell
curl.exe -i -X POST "https://graph.facebook.com/v25.0/$phoneId/messages" `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{\"messaging_product\":\"whatsapp\",\"to\":\"972549247616\",\"type\":\"text\",\"text\":{\"body\":\"שלום! נוצרה משימה.\"}}'
```

| Type | When it works |
|------|----------------|
| `template` | Anytime (must be approved in Meta Business Manager) |
| `text` | Only after the user sent you a message in the last 24h |

The backend bot replies with **`type: text`** when processing inbound webhook messages (user already wrote first → session is open).

## ngrok — חובה כדי ש-Meta יגיע לבקאנד

Meta **לא יכולה** לשלוח webhook ל-`http://127.0.0.1:8080`. חייבים URL ציבורי ב-HTTPS.

**1. הרץ ngrok** (טרמינל נפרד, בזמן שה-backend רץ):

```powershell
ngrok http 8080
```

העתק את ה-URL, למשל: `https://abc123.ngrok-free.app`

**2. Meta Developers → WhatsApp → Configuration → Webhook**

| שדה | ערך |
|-----|-----|
| Callback URL | `https://abc123.ngrok-free.app/webhooks/whatsapp` |
| Verify token | `my-secret-verify-token` (זהה ל-`WHATSAPP_VERIFY_TOKEN` ב-`.env`) |

לחץ **Verify and save** — בטרמinal של uvicorn אמור להופיע:
```
WhatsApp webhook verify: mode=subscribe token_match=True
```

**3. Subscribe to field:** סמן **`messages`**

**4. שלח הודעה שוב** מהטלפון — בטרמinal אמור להופיע:
```
WhatsApp webhook POST received (...)
```

> **אין שום לוג `/webhooks/whatsapp`?** ה-webhook לא מוגדר ב-Meta, או ngrok לא רץ, או URL שגוי.

> **`WHATSAPP_APP_SECRET`:** אם עדיין `your-app-secret` — אימות חתימה מדולג (dev). ב-production שים את ה-App Secret האמיתי מ-Meta → App settings → Basic.

## API

| Method | Path | Auth |
|--------|------|------|
| GET | `/webhooks/whatsapp` | Meta verify |
| POST | `/webhooks/whatsapp` | Meta signature |
| POST | `/api/v1/auth/whatsapp/link` | JWT `{ "phone": "0501234567" }` |
| POST | `/api/v1/auth/whatsapp/disconnect` | JWT |
| POST | `/api/v1/whatsapp/simulate` | JWT + DEBUG |

## Supported messages

- **Text** — Hebrew task description
- **Voice** — Transcribed via OpenAI Whisper (`language=he`)
- Keyword **משימה** always creates a task (same as email)

## Notes

- Only **Hebrew** messages create tasks
- Phone must be linked before inbound messages work
- One phone per account; duplicate numbers rejected
