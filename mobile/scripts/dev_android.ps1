# Run DAOS on a physical Android device/emulator.
$ErrorActionPreference = "Stop"
$MobileRoot = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $MobileRoot
Set-Location $MobileRoot

$Flutter = "C:\Users\OZKL\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat"
if (-not (Test-Path $Flutter)) {
    $Flutter = "flutter"
}

# Phone cannot reach 127.0.0.1 on your PC — use LAN IP.
$LanIp = (
    Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } |
    Select-Object -First 1 -ExpandProperty IPAddress
)
if (-not $LanIp) {
    Write-Error "Could not detect LAN IP. Set API_BASE_URL manually."
}
$ApiUrl = "http://${LanIp}:8080/api/v1"

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

Write-Host "Android dev — API: $ApiUrl" -ForegroundColor Cyan
Write-Host "Ensure backend listens on 0.0.0.0:8080 and phone is on same Wi‑Fi." -ForegroundColor Yellow

$Defines = @(
    "--dart-define=API_BASE_URL=$ApiUrl",
    "--dart-define=GOOGLE_SERVER_CLIENT_ID=$GoogleClientId"
)
if ($OutlookClientId -and $OutlookClientId -ne "your-azure-app-client-id") {
    $Defines += "--dart-define=OUTLOOK_CLIENT_ID=$OutlookClientId"
}

& $Flutter run @Defines
