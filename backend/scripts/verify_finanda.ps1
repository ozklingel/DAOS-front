# Check Finanda env + (optional) ping API base
$ErrorActionPreference = "Stop"
$backendRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $backendRoot ".env"

if (-not (Test-Path $envFile)) { Write-Error "Missing $envFile" }

Get-Content $envFile | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }
  if ($_ -match '^(FINANDA_API_URL|FINANDA_API_KEY|FINANDA_CLIENT_ID|FINANDA_CLIENT_SECRET)=(.*)$') {
    $name = $matches[1]
    $value = $matches[2].Trim().Trim('"')
    $existing = [Environment]::GetEnvironmentVariable($name)
    if ([string]::IsNullOrWhiteSpace($existing) -and -not [string]::IsNullOrWhiteSpace($value)) {
      Set-Item -Path "Env:$name" -Value $value
    }
  }
}

Write-Host "Finanda Open Banking setup"
Write-Host "  Product: https://www.finanda.com/open-banking/"
Write-Host "  Docs:    https://docs.finanda.com"
Write-Host ""

if (-not $env:FINANDA_API_URL) {
  Write-Host "FINANDA_API_URL is empty." -ForegroundColor Yellow
  Write-Host "1) Join Finanda waitlist / contact sales"
  Write-Host "2) Get tenant API base URL + keys from docs.finanda.com"
  Write-Host "3) Set FINANDA_API_URL and FINANDA_API_KEY (or CLIENT_ID+SECRET) in backend/.env"
  exit 1
}

$hasAuth = $env:FINANDA_API_KEY -or ($env:FINANDA_CLIENT_ID -and $env:FINANDA_CLIENT_SECRET)
if (-not $hasAuth) {
  Write-Host "API URL set, but no FINANDA_API_KEY / CLIENT credentials." -ForegroundColor Yellow
  exit 1
}

Write-Host "OK - Finanda env looks configured." -ForegroundColor Green
Write-Host "  API: $($env:FINANDA_API_URL)"
Write-Host "Restart backend, then Finance -> Connect Israeli bank."
