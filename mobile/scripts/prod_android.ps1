# Install / run DAOS Android against production Render API.
# SMS inbox → POST https://daos-api.onrender.com/api/v1/sms/ingest
$ErrorActionPreference = "Stop"
$MobileRoot = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $MobileRoot
Set-Location $MobileRoot

$Flutter = "C:\Users\OZKL\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat"
if (-not (Test-Path $Flutter)) {
    $Flutter = "flutter"
}

$ApiUrl = "https://daos-api.onrender.com/api/v1"

$GoogleClientId = ""
$OutlookClientId = ""
$EnvFile = Join-Path $RepoRoot "backend\.env"
if (Test-Path $EnvFile) {
    foreach ($line in Get-Content $EnvFile) {
        if ($line -match '^\s*GOOGLE_CLIENT_ID=(.+)$') {
            $GoogleClientId = $Matches[1].Trim()
        }
        if ($line -match '^\s*MICROSOFT_CLIENT_ID=(.+)$') {
            $OutlookClientId = $Matches[1].Trim()
        }
    }
}

Write-Host "Production Android → $ApiUrl" -ForegroundColor Cyan
Write-Host "After install: Settings → Integrations → SMS → Allow SMS & sync now" -ForegroundColor Yellow
Write-Host "Watch Render logs for: POST /api/v1/sms/ingest" -ForegroundColor Yellow

if (-not $OutlookClientId -or $OutlookClientId -eq "your-azure-app-client-id") {
    Write-Host "Outlook: MICROSOFT_CLIENT_ID missing/placeholder in backend/.env — Outlook login will fail." -ForegroundColor Red
    Write-Host "Also set the SAME value in Render Dashboard → daos-api → Environment." -ForegroundColor Red
} else {
    Write-Host "Outlook client: $OutlookClientId" -ForegroundColor DarkGray
    Write-Host "Azure must allow personal Microsoft accounts + redirect com.taskmail://oauth/callback" -ForegroundColor Yellow
}

$Defines = @(
    "--dart-define=API_BASE_URL=$ApiUrl"
)
if ($GoogleClientId -and $GoogleClientId -notlike "your-google*") {
    $Defines += "--dart-define=GOOGLE_SERVER_CLIENT_ID=$GoogleClientId"
}
if ($OutlookClientId -and $OutlookClientId -ne "your-azure-app-client-id") {
    $Defines += "--dart-define=OUTLOOK_CLIENT_ID=$OutlookClientId"
}

$Mode = $args[0]
if ($Mode -eq "apk") {
    & $Flutter build apk --release @Defines
    Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
} else {
    & $Flutter run --release @Defines
}
