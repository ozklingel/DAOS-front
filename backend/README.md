# TaskMail Backend

Production-ready REST API for the TaskMail Flutter mobile app.

## Stack

- **FastAPI** — REST API
- **SQLAlchemy 2** — ORM (SQLite dev / PostgreSQL prod)
- **JWT** — Access + refresh tokens
- **OpenAI** — AI email analysis & daily briefs (optional)
- **APScheduler** — Background email sync & brief generation
- **Firebase Admin** — Push notifications (optional)

## Quick Start

```bash
cd backend
python -m venv .venv

# Windows
.venv\Scripts\activate

pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API docs: http://localhost:8000/docs

Health check: http://localhost:8000/health

## Connect Flutter App

Run the mobile app pointing at your local backend:

```bash
cd mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Use `http://localhost:8000/api/v1` for iOS simulator or `http://<your-lan-ip>:8000/api/v1` for a physical device.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/google` | Sign in with Google ID token |
| POST | `/api/v1/auth/outlook` | Sign in with Outlook access token |
| POST | `/api/v1/auth/refresh` | Refresh JWT |
| GET | `/api/v1/auth/me` | Current user |
| POST | `/api/v1/auth/logout` | Sign out |
| GET | `/api/v1/tasks` | List tasks (search, filter, sort) |
| GET | `/api/v1/tasks/{id}` | Task details |
| PATCH | `/api/v1/tasks/{id}` | Complete / snooze / dismiss |
| GET | `/api/v1/dashboard` | Dashboard stats + brief |
| GET | `/api/v1/daily-brief` | Full AI daily brief |
| GET/PATCH | `/api/v1/settings` | User preferences |
| POST | `/api/v1/notifications/device` | Register FCM token |

## Docker

```bash
docker compose up --build
```

## Configuration

See `.env.example` for all environment variables.

Required for production OAuth:
- `GOOGLE_CLIENT_ID` — must match the mobile Google OAuth client
- `MICROSOFT_CLIENT_ID` — must match the Azure app registration

Optional:
- `OPENAI_API_KEY` — enables AI task extraction and briefs (heuristic fallback without it)
- `FIREBASE_CREDENTIALS_PATH` — path to Firebase service account JSON for push notifications

## Architecture

```
backend/
├── app/
│   ├── main.py              # FastAPI app + scheduler
│   ├── config.py            # Settings
│   ├── models.py            # SQLAlchemy models
│   ├── schemas.py           # Pydantic request/response DTOs
│   ├── database.py          # DB session
│   ├── deps.py              # Auth dependencies
│   ├── api/v1/              # Route handlers
│   └── services/            # Business logic
│       ├── auth_service.py
│       ├── task_service.py
│       ├── ai_service.py
│       ├── email_sync_service.py
│       └── support_services.py
├── requirements.txt
├── docker-compose.yml
└── Dockerfile
```

## Email Sync

On sign-in and every 15 minutes (configurable), the backend syncs emails and creates AI-derived tasks. Demo sample emails are seeded when Gmail/Outlook is connected. Production Gmail/Graph API integration can be wired through stored OAuth refresh tokens on the `User` model.

## License

Proprietary
