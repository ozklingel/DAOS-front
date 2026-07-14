# TaskMail Mobile

Production-ready Flutter application for an AI-powered email task reminder system.

## Tech Stack

- Flutter (stable)
- Riverpod — state management
- GoRouter — navigation
- Dio — HTTP client with JWT refresh
- Freezed + Json Serializable — immutable models
- Flutter Secure Storage — token persistence
- Firebase Messaging + Analytics
- Flutter Local Notifications

## Architecture

Clean Architecture with three layers per feature:

```
lib/
├── core/           # Network, errors, constants, DI
├── theme/          # Design system
├── routes/         # GoRouter configuration
├── services/       # Cross-cutting services
├── shared/         # Shared widgets & enums
└── features/
    ├── auth/
    ├── dashboard/
    ├── tasks/
    ├── daily_brief/
    ├── notifications/
    ├── settings/
    └── splash/
```

Each feature follows:

- `domain/` — entities, repository interfaces
- `data/` — models, datasources, repository implementations
- `presentation/` — screens, widgets, Riverpod providers

## Getting Started

```bash
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Configuration

Set environment variables at build time:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-api.com/api/v1 \
  --dart-define=OUTLOOK_CLIENT_ID=your-client-id \
  --dart-define=OUTLOOK_REDIRECT_URI=com.taskmail://oauth/callback
```

## Firebase Setup

1. Create a Firebase project
2. Add iOS and Android apps with bundle ID `com.taskmail.taskmail`
3. Download `google-services.json` → `android/app/`
4. Download `GoogleService-Info.plist` → `ios/Runner/`
5. Run `flutterfire configure` (optional)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/google` | Sign in with Google ID token |
| POST | `/auth/outlook` | Sign in with Outlook access token |
| POST | `/auth/refresh` | Refresh JWT |
| GET | `/auth/me` | Current user |
| POST | `/auth/logout` | Sign out |
| GET | `/tasks` | List tasks (search, filter, sort) |
| GET | `/tasks/:id` | Task details |
| PATCH | `/tasks/:id` | Complete, snooze, or dismiss |
| GET | `/dashboard` | Dashboard stats + brief |
| GET | `/daily-brief` | Full daily AI brief |
| GET/PATCH | `/settings` | User preferences |
| POST | `/notifications/device` | Register FCM token |

## Screens

1. **Splash** — JWT validation, auto-navigation
2. **Login** — Google & Outlook OAuth
3. **Dashboard** — Stats cards, AI brief, high-priority tasks
4. **Tasks** — Search, filter, sort
5. **Task Details** — Full context, complete/snooze/dismiss
6. **Daily Brief** — AI-generated summary
7. **Settings** — Connections, notifications, sign out

## OAuth Notes

- **Google**: Configure OAuth client in Google Cloud Console; add SHA-1 for Android
- **Outlook**: Register app in Azure AD; set redirect URI `com.taskmail://oauth/callback`
- Add URL scheme to `ios/Runner/Info.plist` and Android intent filter

## License

Proprietary
