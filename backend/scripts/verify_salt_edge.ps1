# Verify Salt Edge API keys from backend/.env (API v6)
$ErrorActionPreference = "Stop"
$backendRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $backendRoot ".env"

if (-not (Test-Path $envFile)) {
  Write-Error "Missing $envFile"
}

Get-Content $envFile | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }
  if ($_ -match '^(SALT_EDGE_APP_ID|SALT_EDGE_SECRET|SALT_EDGE_API_URL)=(.*)$') {
    $name = $matches[1]
    $value = $matches[2].Trim().Trim('"')
    $existing = [Environment]::GetEnvironmentVariable($name)
    if ([string]::IsNullOrWhiteSpace($existing) -and -not [string]::IsNullOrWhiteSpace($value)) {
      Set-Item -Path "Env:$name" -Value $value
    }
  }
}

if (-not $env:SALT_EDGE_APP_ID -or -not $env:SALT_EDGE_SECRET) {
  Write-Host ""
  Write-Host "Salt Edge keys are empty in backend/.env" -ForegroundColor Yellow
  Write-Host "1) Sign up: https://www.saltedge.com/clients/sign_up"
  Write-Host "2) Create Service API key in the dashboard"
  Write-Host "3) Set SALT_EDGE_APP_ID and SALT_EDGE_SECRET in backend/.env"
  Write-Host "4) Re-run this script"
  exit 1
}

$base = if ($env:SALT_EDGE_API_URL) { $env:SALT_EDGE_API_URL.TrimEnd('/') } else { "https://www.saltedge.com" }
$headers = @{
  "Accept"       = "application/json"
  "Content-Type" = "application/json"
  "App-id"       = $env:SALT_EDGE_APP_ID
  "Secret"       = $env:SALT_EDGE_SECRET
}

Write-Host "Testing Salt Edge v6 credentials against $base ..."
try {
  $resp = Invoke-RestMethod -Method GET -Uri "$base/api/v6/countries" -Headers $headers
  $il = @($resp.data) | Where-Object { $_.code -eq "IL" }
  Write-Host "OK - API keys work (v6)." -ForegroundColor Green
  if ($il) {
    Write-Host "Israel (IL) is listed in countries."
  } else {
    Write-Host "Israel not in country list yet (account may still be pending)." -ForegroundColor Yellow
  }
  Write-Host ""
  Write-Host "Next:"
  Write-Host "  - Restart backend"
  Write-Host "  - Finance -> Connect -> Fake Bank"
  Write-Host "  - Real Israeli bank needs Test Access approval from Salt Edge"
} catch {
  Write-Host "FAILED - check App-id / Secret" -ForegroundColor Red
  Write-Host $_.Exception.Message
  if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
  exit 1
}
