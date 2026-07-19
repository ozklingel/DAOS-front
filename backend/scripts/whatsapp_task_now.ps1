# Create a task NOW — mimics inbound WhatsApp (DEBUG=true, phone must be linked in app)
param(
    [string]$Phone = "0549247616",
    [string]$Text = ""
)

$ErrorActionPreference = "Stop"
$Base = "http://127.0.0.1:8080/api/v1"

# Default Hebrew text (UTF-8 bytes) — avoids PowerShell encoding issues in .ps1 files
if (-not $Text) {
    $Text = [System.Text.Encoding]::UTF8.GetString(@(
        0xD7, 0x9E, 0xD7, 0xA9, 0xD7, 0x99, 0xD7, 0x9E, 0xD7, 0x94, 0x3A, 0x20,
        0xD7, 0x91, 0xD7, 0x93, 0xD7, 0x99, 0xD7, 0xA7, 0xD7, 0x94, 0x20,
        0xD7, 0x9E, 0xD7, 0x94, 0xD7, 0x99, 0xD7, 0xA8, 0xD7, 0x94, 0x20,
        0xD7, 0x9E, 0xD7, 0x94, 0xD7, 0xA9, 0xD7, 0xA8, 0xD7, 0xAA
    ))
}

Write-Host "Link phone in app first: Settings -> Integrations -> WhatsApp -> $Phone" -ForegroundColor Yellow
Write-Host ""

$body = @{ phone = $Phone; text = $Text } | ConvertTo-Json -Compress
$result = Invoke-RestMethod -Uri "$Base/whatsapp/dev-inbound" -Method POST `
    -ContentType "application/json; charset=utf-8" -Body ([System.Text.Encoding]::UTF8.GetBytes($body))

Write-Host "created: $($result.created)" -ForegroundColor $(if ($result.created) { "Green" } else { "Red" })
Write-Host "task_id: $($result.task_id)"
Write-Host "message: $($result.message)"
