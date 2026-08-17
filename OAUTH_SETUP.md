# OAuth Setup — Real Gmail & Outlook Connection

DAOS needs OAuth credentials so the mobile app can sign in and the backend can sync email in the background.

## Overview

| Provider | Mobile needs | Backend needs |
|----------|--------------|---------------|
| **Google / Gmail** | Android OAuth client + Web client ID (`GOOGLE_SERVER_CLIENT_ID`) | Web client ID + secret, Gmail API enabled |
| **Outlook** | Azure app client ID (`OUTLOOK_CLIENT_ID`) | Same Azure app client ID (+ secret if confidential) |

---

## Google / Gmail

### 1. Google Cloud Console

1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select a project
3. Enable **Gmail API**: APIs & Services → Library → Gmail API → Enable
4. Configure **OAuth consent screen** (External is fine for testing; add test users)

### 2. Create OAuth clients

**Android client** (for mobile sign-in):

- APIs & Services → Credentials → Create Credentials → OAuth client ID
- Application type: **Android**
- Package name: `com.taskmail.taskmail`
- SHA-1: get from your debug keystore:

```bash
cd mobile/android
./gradlew signingReport
```

Copy the **SHA-1** under `Variant: debug` and paste it into the Android OAuth client.

**Web client** (for backend token exchange + Gmail sync):

- Create another OAuth client ID
- Application type: **Web application**
- No redirect URI required for mobile server auth code flow
- Copy the **Client ID** and **Client secret**

### 3. Backend `.env`

```env
GOOGLE_CLIENT_ID=<Web client ID>.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=<Web client secret>
GOOGLE_ANDROID_CLIENT_ID=<Android client ID>.apps.googleusercontent.com
```

### 4. Run the Flutter app

Pass the **Web client ID** as `GOOGLE_SERVER_CLIENT_ID` (same value as `GOOGLE_CLIENT_ID` on the backend),
**or** add it once to `mobile/android/local.properties`:

```properties
google.server.client.id=<Web client ID>.apps.googleusercontent.com
```

Then run (full restart required after changing OAuth config — hot reload is not enough):

```bash
flutter run \
  --dart-define=API_BASE_URL=http://192.168.1.205:8080/api/v1 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<Web client ID>.apps.googleusercontent.com
```

### 5. Sign in with Google

Use **Continue with Google** on the login screen. Login requests only `email` + `profile`
so new users are not blocked by unverified Gmail scopes (Google 403).

Gmail inbox access is requested later via **Settings → Integrations → Connect Gmail**
(`gmail.readonly`). Until Google verifies that scope, Connect Gmail may still show 403
for some accounts — but users can still sign in and use the rest of the app.

---

## Microsoft / Outlook

### 1. Azure App Registration

1. Open [Azure Portal](https://portal.azure.com/) → Microsoft Entra ID → App registrations → New registration
2. Name: `DAOS` (or `daos-1`)
3. Supported account types: **Accounts in any organizational directory and personal Microsoft accounts**
4. Redirect URIs — use **Web** (not SPA). The backend exchanges the auth code server-side:

   - **Web**: `http://127.0.0.1:5173/oauth/outlook`
   - **Web**: `http://localhost:5173/oauth/outlook`
   - **Web**: `https://ozklingel.github.io/DAOS-front/oauth/outlook`
   - **Mobile and desktop applications**: `com.taskmail://oauth/callback`

   Do **not** put the http(s) URIs under “Single-page application”. SPA + server-side token exchange causes `invalid_request` / AADSTS9002326.

5. Certificates & secrets → **New client secret** → copy the **Value** once (shown only at creation).

### 2. API permissions

Add delegated permissions:

- `openid`, `profile`, `email`
- `offline_access`
- `User.Read`
- `Mail.Read`

### Admin consent (work / school accounts)

Personal `@outlook.com` accounts can approve `Mail.Read` themselves. **Organizational tenants** (e.g. `@vikos-ltd.com`) often block delegated permissions until an **IT administrator** grants tenant-wide consent.

**Option A — Azure Portal:** App registration → API permissions → **Grant admin consent for &lt;tenant&gt;**

**Option B — Admin consent URL** (send to your Microsoft 365 admin):

```
https://login.microsoftonline.com/organizations/adminconsent?client_id={MICROSOFT_CLIENT_ID}
```

The admin signs in with their **work admin account**; Microsoft applies consent to **their** tenant.

> **Do not use the email domain** (e.g. `vikos-ltd.com`) in the URL — that causes  
> `AADSTS90002: Tenant not found`. The Azure tenant ID is a **GUID**, not your `@domain`.

Optional — if IT gives you the tenant GUID (Azure Portal → Microsoft Entra ID → Overview → **Tenant ID**):

```
https://login.microsoftonline.com/{TENANT_ID_GUID}/adminconsent?client_id={MICROSOFT_CLIENT_ID}
```

Set on the server: `MICROSOFT_TENANT_ID=<guid>` (optional; default link uses `organizations`).

**Option A (easiest for IT):** Azure Portal → App registrations → your app → API permissions → **Grant admin consent for Vikos**

After the admin approves:

1. In DAOS → Settings → Integrations → **Disconnect** Outlook  
2. **Connect** again and sign in with the work account  
3. Tap **Check Outlook inbox** — diagnostics should show `Mail.Read in token: yes`

The app also surfaces this link automatically when inbox preview detects missing `Mail.Read` on a work account.

### 3. Copy Client ID + secret

App registration → Overview → **Application (client) ID**

### 4. Backend `.env` + Render Environment

```env
MICROSOFT_CLIENT_ID=<Azure application client ID>
MICROSOFT_CLIENT_SECRET=<Azure client secret Value>
# Optional: Azure tenant GUID for admin consent URL (not the email domain)
MICROSOFT_TENANT_ID=
```

Set the **same two variables** in Render → `daos-api` → Environment, then wait for redeploy.

### 5. Run the Flutter app

**Web (Chrome):**

```powershell
cd mobile
.\scripts\dev_web.ps1
```

The script reads `MICROSOFT_CLIENT_ID` from `backend/.env` and passes `OUTLOOK_CLIENT_ID`.

**Mobile:**

```bash
flutter run \
  --dart-define=API_BASE_URL=http://192.168.1.205:8080/api/v1 \
  --dart-define=OUTLOOK_CLIENT_ID=<Azure client ID>
```

### 6. Connect Outlook

- Login screen → **Continue with Outlook**, or
- After Dev Login → Settings → Integrations → **Connect** next to Outlook

---

## Dev Login vs Real Email

- **Dev Login** (`DEBUG=true` on backend): signs you in without OAuth. No real email is synced.
- **Google / Outlook sign-in**: authenticates and connects email when refresh tokens are stored.
- **Settings → Email Connections**: connect or disconnect Gmail/Outlook after signing in (e.g. after Dev Login, use **Connect** for Gmail).

---

## Verify it works

1. Start backend: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8080`
2. Sign in with Google or Outlook (not Dev Login)
3. Check Settings — provider should show **Connected**
4. Open Tasks — real emails from the last 14 days should appear as AI-extracted tasks

If Gmail connects but no tasks appear, confirm `GOOGLE_CLIENT_SECRET` is set and the server auth code exchange succeeded (check backend logs).
