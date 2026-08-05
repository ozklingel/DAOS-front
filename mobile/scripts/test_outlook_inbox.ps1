# Test Outlook inbox access for the logged-in DAOS user.
# Usage:
#   1. Log into DAOS (web or app)
#   2. Copy your access token (DevTools → Application → secure storage, or network tab Authorization header)
#   3. Run:
#        .\scripts\test_outlook_inbox.ps1 -AccessToken "eyJ..."
#
param(
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [string]$ApiBase = "https://daos-api.onrender.com/api/v1"
)

$ErrorActionPreference = "Stop"

$headers = @{
    Authorization = "Bearer $AccessToken"
    Accept        = "application/json"
}

Write-Host "Calling GET $ApiBase/emails/outlook/inbox-preview" -ForegroundColor Cyan
$response = Invoke-RestMethod -Uri "$ApiBase/emails/outlook/inbox-preview" -Headers $headers -Method Get

Write-Host ""
Write-Host "connected:          $($response.connected)" -ForegroundColor Yellow
Write-Host "has_refresh_token:  $($response.has_refresh_token)" -ForegroundColor Yellow
Write-Host "account_email:      $($response.account_email)" -ForegroundColor Yellow
Write-Host "fetch_ok:           $($response.fetch_ok)" -ForegroundColor Yellow
Write-Host "inbox_count:        $($response.inbox_count)" -ForegroundColor Yellow

if ($response.error) {
    Write-Host "error:              $($response.error)" -ForegroundColor Red
}

if ($response.messages -and $response.messages.Count -gt 0) {
    Write-Host ""
    Write-Host "Recent inbox messages:" -ForegroundColor Green
    foreach ($m in $response.messages) {
        $flags = @()
        if ($m.is_hebrew) { $flags += "Hebrew" }
        if ($m.has_task_signal) { $flags += "TaskSignal" }
        if ($m.already_ingested) { $flags += "AlreadyIngested" }
        $flagText = if ($flags.Count -gt 0) { " [" + ($flags -join ", ") + "]" } else { "" }
        Write-Host " - $($m.subject)$flagText"
        if ($m.sender) { Write-Host "   from: $($m.sender)" -ForegroundColor DarkGray }
    }
} elseif ($response.fetch_ok) {
    Write-Host "No messages returned from inbox." -ForegroundColor Red
}

Write-Host ""
Write-Host "If fetch_ok=false or inbox_count=0, Outlook is NOT really connected to inbox." -ForegroundColor Cyan
