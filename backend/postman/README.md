# DAOS Postman API Tests

Import these files into Postman to test the backend.

## Files

| File | Purpose |
|------|---------|
| `DAOS.postman_collection.json` | All API requests (Auth, Tasks, Emails, Hub, Webhooks, …) |
| `DAOS.local.postman_environment.json` | Local backend (`http://127.0.0.1:8000`) |
| `DAOS.production.postman_environment.json` | Render (`https://daos-api.onrender.com`) |

## Import (Postman)

1. Open Postman → **Import**
2. Drag all three JSON files (or select the `postman` folder)
3. Select environment **DAOS Local** or **DAOS Production** (top-right dropdown)

## Quick test flow

1. Start backend locally:
   ```bash
   cd backend
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
2. **Health → Health Check** → expect `200` and `"status": "ok"`
3. **Auth → Dev Login** → saves `accessToken` automatically (collection script)
4. **Auth → Me** → verify user
5. **Tasks → Create Task** → saves `taskId`
6. **Emails → Sync Emails** → sync inbox (requires Gmail/Outlook connected)
7. **Hub → Info Hub** → list info categories and documents

## Auth

- **Dev Login** works when `DEBUG=true` (local `.env`)
- Production: use **Google Sign-In** or **Outlook Sign-In** with real tokens
- Collection-level Bearer auth uses `{{accessToken}}` after Dev Login

## Variables (auto-filled by tests)

| Variable | Set by |
|----------|--------|
| `accessToken` | Dev Login / Refresh Token |
| `refreshToken` | Dev Login / Refresh Token |
| `taskId` | Create Task |
| `connectionId` | Bank Connect |
| `documentId` | Upload Info Document |

## Swagger (alternative)

Interactive docs: `http://127.0.0.1:8000/docs`
