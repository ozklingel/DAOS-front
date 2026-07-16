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

With `DEBUG=true`:

```powershell
# Link phone first (via app Settings, or API with JWT)
Invoke-RestMethod -Uri http://127.0.0.1:8080/api/v1/whatsapp/simulate `
  -Method POST `
  -Headers @{ Authorization = "Bearer YOUR_ACCESS_TOKEN" } `
  -ContentType "application/json; charset=utf-8" `
  -Body '{"transcript":"משימה: לשלוח דוח ללקוח עד מחר"}'
```

## ngrok (real WhatsApp locally)

```powershell
ngrok http 8080
# Use https://xxxx.ngrok.io/webhooks/whatsapp in Meta dashboard
```

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
