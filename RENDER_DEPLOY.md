# Deploy Backend to Render

Stable HTTPS URL for WhatsApp webhooks (no ngrok).

## Option A — Blueprint (recommended)

1. Push this repo to GitHub
2. [Render Dashboard](https://dashboard.render.com) → **New** → **Blueprint**
3. Connect repo `DAOS-front` → Render detects `render.yaml`
4. After deploy, open **daos-api** → **Environment** → set secrets:

| Variable | Value |
|----------|--------|
| `GOOGLE_CLIENT_ID` | from `backend/.env` |
| `GOOGLE_CLIENT_SECRET` | from `backend/.env` |
| `GOOGLE_ANDROID_CLIENT_ID` | from `backend/.env` |
| `OPENAI_API_KEY` | from `backend/.env` |
| `WHATSAPP_VERIFY_TOKEN` | `DAOS` (same as Meta) |
| `WHATSAPP_ACCESS_TOKEN` | Meta EAA token |
| `WHATSAPP_PHONE_NUMBER_ID` | `1281218281733444` |
| `WHATSAPP_APP_SECRET` | Meta App Secret (Basic settings) |

5. **Redeploy** after saving env vars

Your API URL: `https://daos-api.onrender.com`

Health: `https://daos-api.onrender.com/health`

---

## Option B — Manual Web Service

1. **New** → **Web Service** → connect GitHub repo
2. Settings:

| Field | Value |
|-------|--------|
| Root Directory | `backend` |
| Runtime | **Docker** |
| Plan | Free |

3. **New** → **PostgreSQL** (free) → copy **Internal Database URL**
4. Web Service → **Environment** → add all vars from Option A +:
   - `DATABASE_URL` = Postgres connection string from step 3

---

## WhatsApp webhook on Render

1. Meta → WhatsApp → Configuration → Webhook:

```
Callback URL:  https://daos-api.onrender.com/webhooks/whatsapp
Verify token:  DAOS
```

2. **Verify and save** → subscribe to **`messages`**
3. Add test phone `+972549247616` in Meta API Setup
4. Link phone in app: Settings → Integrations → WhatsApp
5. Send from your phone **to** the business number:

```
משימה: בדיקה מ-Render
```

6. Render logs → should show:

```
POST /webhooks/whatsapp
WhatsApp webhook POST received
```

> Free tier sleeps after ~15 min idle. First webhook may take 30–60s (cold start).

---

## Flutter app → production API

```powershell
cd mobile
flutter run -d chrome `
  --web-port=5173 `
  --web-hostname=127.0.0.1 `
  --dart-define=API_BASE_URL=https://daos-api.onrender.com/api/v1 `
  --dart-define=GOOGLE_SERVER_CLIENT_ID=812104653331-ur4g34kfo6seil4f6h06igl08ks9ecmt.apps.googleusercontent.com
```

Add to Google Cloud **Authorized JavaScript origins** (if testing web against prod API — origins stay localhost for the Flutter app).

---

## Notes

- **Do not** commit `backend/.env` — set secrets only in Render Environment
- SQLite is **not** used on Render — Postgres from `render.yaml` is required
- `DEBUG=false` in production — `/whatsapp/simulate` and `/whatsapp/dev-inbound` are disabled
- Service name `daos-api` → URL `https://daos-api.onrender.com` (change name = change URL)
