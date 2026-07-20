# Configure Green API instance webhook -> Render backend
param(
    [string]$WebhookUrl = "https://daos-api.onrender.com/webhooks/green-api",
    [string]$EnvFile = ""
)

$ErrorActionPreference = "Stop"
if (-not $EnvFile) {
    $EnvFile = Join-Path $PSScriptRoot "..\.env"
}

function Get-EnvValue($name) {
    $line = Get-Content $EnvFile | Where-Object { $_ -match "^\s*$name=" } | Select-Object -First 1
    if (-not $line) { throw "Missing $name in $EnvFile" }
    return ($line -split "=", 2)[1].Trim()
}

$base = Get-EnvValue "GREEN_API_URL"
$id = Get-EnvValue "GREEN_API_ID_INSTANCE"
$token = Get-EnvValue "GREEN_API_TOKEN"

Write-Host "Green API instance: $id" -ForegroundColor Cyan
Write-Host "State:" -ForegroundColor Yellow
(Invoke-RestMethod "$base/waInstance$id/getStateInstance/$token") | Format-List

Write-Host "Setting webhookUrl -> $WebhookUrl" -ForegroundColor Cyan
$body = @{
    webhookUrl = $WebhookUrl
    webhookUrlToken = ""
    incomingWebhook = "yes"
    stateWebhook = "yes"
} | ConvertTo-Json
$result = Invoke-RestMethod -Method POST -Uri "$base/waInstance$id/setSettings/$token" `
    -ContentType "application/json" -Body $body
Write-Host "saveSettings: $($result.saveSettings)" -ForegroundColor Green

Start-Sleep -Seconds 3
$settings = Invoke-RestMethod "$base/waInstance$id/getSettings/$token"
Write-Host "webhookUrl now: $($settings.webhookUrl)" -ForegroundColor Green
Write-Host ""
Write-Host "Also add to Render Environment and redeploy:" -ForegroundColor Yellow
Write-Host "  GREEN_API_URL=$base"
Write-Host "  GREEN_API_ID_INSTANCE=$id"
Write-Host "  GREEN_API_TOKEN=<from .env>"
Write-Host ""
Write-Host "Test: send FROM ANOTHER phone TO $($settings.wid -replace '@c.us','')" -ForegroundColor Yellow
