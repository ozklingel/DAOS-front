# Flutter web → Production API on Render
$ErrorActionPreference = "Stop"
$MobileRoot = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $MobileRoot
Set-Location $MobileRoot

$Flutter = "C:\Users\OZKL\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat"
if (-not (Test-Path $Flutter)) { $Flutter = "flutter" }

$EnvFile = Join-Path $RepoRoot "backend\.env"
$GoogleClientId = ""
if (Test-Path $EnvFile) {
    foreach ($line in Get-Content $EnvFile) {
        if ($line -match '^\s*GOOGLE_CLIENT_ID=(.+)$') {
            $GoogleClientId = $Matches[1].Trim()
            break
        }
    }
}

$ApiUrl = "https://daos-api.onrender.com/api/v1"
$WebPort = 5173

Write-Host "Production API: $ApiUrl" -ForegroundColor Cyan
Write-Host "After login: Settings -> Integrations -> Link YOUR WhatsApp number" -ForegroundColor Yellow
Write-Host ""

& $Flutter run -d chrome `
  --web-port=$WebPort `
  --web-hostname=127.0.0.1 `
  --dart-define=API_BASE_URL=$ApiUrl `
  --dart-define=GOOGLE_SERVER_CLIENT_ID=$GoogleClientId
