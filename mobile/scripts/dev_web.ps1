# Fast UI dev — Chrome (hot reload, no adb, no mobile build)
$ErrorActionPreference = "Stop"
$MobileRoot = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $MobileRoot
Set-Location $MobileRoot

$Flutter = "C:\Users\OZKL\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat"
if (-not (Test-Path $Flutter)) {
    $Flutter = "flutter"
}

# Read GOOGLE_CLIENT_ID / MICROSOFT_CLIENT_ID from backend/.env
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
if (-not $GoogleClientId) {
    Write-Error "GOOGLE_CLIENT_ID not found in backend\.env"
}

# Avoid Windows/Hyper-V port conflicts (3508 etc.)
$WebPort = 5173

Write-Host "Starting TaskMail in Chrome on http://127.0.0.1:$WebPort ..." -ForegroundColor Cyan
Write-Host "Google client: $GoogleClientId" -ForegroundColor DarkGray
if ($OutlookClientId -and $OutlookClientId -ne "your-azure-app-client-id") {
    Write-Host "Outlook client: $OutlookClientId" -ForegroundColor DarkGray
    Write-Host "Add SPA redirect URI in Azure:" -ForegroundColor Yellow
    Write-Host "  http://127.0.0.1:$WebPort/oauth/outlook" -ForegroundColor Yellow
} else {
    Write-Host "Outlook: set MICROSOFT_CLIENT_ID in backend/.env (see OAUTH_SETUP.md)" -ForegroundColor DarkYellow
}
Write-Host "Add origins to THIS Web client in Google Cloud (see WEB_OAUTH_FIX.md):" -ForegroundColor Yellow
Write-Host "  http://127.0.0.1:$WebPort" -ForegroundColor Yellow
Write-Host "  http://localhost:$WebPort" -ForegroundColor Yellow
Write-Host "Backend: http://127.0.0.1:8080  |  Dev Login works without Google" -ForegroundColor Yellow
Write-Host ""

$Defines = @(
    "--dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1",
    "--dart-define=GOOGLE_SERVER_CLIENT_ID=$GoogleClientId"
)
if ($OutlookClientId -and $OutlookClientId -ne "your-azure-app-client-id") {
    $Defines += "--dart-define=OUTLOOK_CLIENT_ID=$OutlookClientId"
}

& $Flutter run -d chrome `
  --web-port=$WebPort `
  --web-hostname=127.0.0.1 `
  @Defines
