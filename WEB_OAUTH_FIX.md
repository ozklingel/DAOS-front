# Fix Google Sign-In on Web — "no registered origin" / Error 401

## Root cause (fixed in repo)

The app must use the **same Web OAuth client ID** as `GOOGLE_CLIENT_ID` in `backend/.env`.

You switched to the **Firebase project** client:

```
812104653331-ur4g34kfo6seil4f6h06igl08ks9ecmt.apps.googleusercontent.com
```

The old ID (`45773018634-5cb346...`) was still in `dev_web.ps1` and `index.html` → **invalid_client**.

`dev_web.ps1` now reads `GOOGLE_CLIENT_ID` from `backend/.env` automatically.

---

## One-time Google Cloud setup

1. Open [Credentials — project daos-15254](https://console.cloud.google.com/apis/credentials?project=daos-15254)

2. Click the **Web client** whose ID is:
   `812104653331-ur4g34kfo6seil4f6h06igl08ks9ecmt.apps.googleusercontent.com`  
   (Firebase → Project settings → Your apps → Web app, or OAuth 2.0 Client IDs list)

3. **Authorized JavaScript origins** — add both:

   ```
   http://127.0.0.1:5173
   http://localhost:5173
   ```

4. **Authorized redirect URIs** — add the same two URLs.

5. **OAuth consent screen** → **Test users** → add `ozklingel@gmail.com`

6. **Save** → wait 2 minutes → stop app → run `.\scripts\dev_web.ps1` again (full restart, not hot reload)

7. **Enable APIs** (required for Google Sign-In + Gmail sync on project `daos-15254`):
   - [People API](https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=812104653331) — profile/email for web sign-in
   - [Gmail API](https://console.developers.google.com/apis/api/gmail.googleapis.com/overview?project=812104653331) — email sync

   Click **Enable** on each, wait ~2 minutes, then retry sign-in.

---

## `People API has not been used` / `SERVICE_DISABLED`

Google Sign-In on **web** calls People API for profile data. Enable it:

https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=812104653331

Also enable **Gmail API** for email sync:

https://console.developers.google.com/apis/api/gmail.googleapis.com/overview?project=812104653331

Wait 2 minutes after enabling, then restart the app and sign in again.

---

## Web sign-in succeeds but app exits / no id_token

On **web**, Google returns an `access_token` (not always an `id_token`). The app now sends `accessToken` to the backend for login.

The log line `gapi.client library is not loaded` is **harmless** — ignore it.

**Gmail sync on web:** refresh tokens are not available from web sign-in. Use **Android** for full Gmail email sync. Web Google login is fine for UI testing.

---

## Quick test without Google

Use **Dev Login (כניסת מפתח)** — works immediately if `DEBUG=true` in backend.  
Dev Login does **not** connect Gmail. For email sync you must use **Google Sign-In**.

---

## `unauthorized_client` on Gmail fetch

If backend logs:

```
Gmail fetch failed ... unauthorized_client: Unauthorized
```

The stored Gmail refresh token was issued for the **old** OAuth client. Fix:

1. In app: **Settings → disconnect Gmail** (or sign out)
2. Sign in again with **Google** (not Dev Login)
3. Approve Gmail access when prompted

The backend now auto-clears stale tokens when this error occurs.

---

## Open credentials in browser

```powershell
Start-Process "https://console.cloud.google.com/apis/credentials?project=daos-15254"
```

Or Firebase: https://console.firebase.google.com/project/daos-15254/settings/general
