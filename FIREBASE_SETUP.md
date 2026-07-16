# Firebase Setup for TaskMail

Firebase powers **push notifications (FCM)** and **analytics** in the mobile app. The app works without Firebase for local development, but you need it for production push notifications.

## Quick fix (already done in code)

Task actions (Complete / Dismiss / Snooze) no longer crash when Firebase is missing. You can keep developing without Firebase.

To enable Firebase fully, follow the steps below.

---

## Step 1: Create / use a Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/)
2. **Add project** (or reuse the same Google Cloud project you used for Gmail OAuth)
3. Name it e.g. `TaskMail`

---

## Step 2: Add Android app

1. Firebase Console → **Project settings** → **Your apps** → **Add app** → **Android**
2. **Android package name:** `com.taskmail.taskmail` (must match exactly)
3. **Debug signing certificate SHA-1** (required for Google Sign-In + FCM on dev builds):

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA1** line into Firebase when registering the Android app.

4. Download **`google-services.json`**
5. Copy it to:

```
mobile/android/app/google-services.json
```

---

## Step 3: Run setup script (Windows)

From the repo root:

```powershell
cd mobile
.\scripts\setup_firebase.ps1
```

This checks for `google-services.json`, installs FlutterFire CLI, and runs `flutterfire configure` for Android (generates `lib/firebase_options.dart`).

**Or manually:**

```powershell
dart pub global activate flutterfire_cli
cd mobile
flutterfire configure
```

- Select your Firebase project
- Select **Android** (and iOS later if needed)
- This overwrites `lib/firebase_options.dart` with real values

---

## Step 4: Rebuild the app

```powershell
cd mobile
flutter clean
flutter pub get
flutter run `
  --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1 `
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<your-web-client-id>
```

**Full restart required** — not hot reload.

---

## Step 5: Backend push notifications (optional)

For the server to send push notifications:

1. Firebase Console → **Project settings** → **Service accounts**
2. **Generate new private key** → save JSON file
3. Add to `backend/.env`:

```env
FIREBASE_CREDENTIALS_PATH=C:/path/to/taskmail-firebase-adminsdk.json
```

4. Restart the backend

---

## Verify Firebase works

After setup, check the debug console on app start:

```
Firebase initialized
```

Instead of:

```
Firebase not configured (optional for local dev)
```

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `[core/no-app] No Firebase App '[DEFAULT]'` | Add `google-services.json` + run `flutterfire configure` + full rebuild |
| `google_app_id missing` in logs | Same — `google-services.json` not in `android/app/` |
| Analytics warnings only | Harmless — app works; complete Firebase setup to remove them |

---

## File checklist

- [ ] `mobile/android/app/google-services.json`
- [ ] `mobile/lib/firebase_options.dart` (from `flutterfire configure`)
- [ ] `backend/.env` → `FIREBASE_CREDENTIALS_PATH` (for server push only)
