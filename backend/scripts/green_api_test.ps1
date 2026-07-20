# Simulate Green API incomingMessageReceived webhook (local dev)
param(
    [Parameter(Mandatory = $true)]
    [string]$Phone,
    [string]$Text = "",
    [string]$BaseUrl = "http://127.0.0.1:8080"
)

$ErrorActionPreference = "Stop"

if (-not $Text) {
    $Text = [System.Text.Encoding]::UTF8.GetString(@(
        0xD7, 0x9E, 0xD7, 0xA9, 0xD7, 0x99, 0xD7, 0x9E, 0xD7, 0x94, 0x3A, 0x20,
        0xD7, 0x91, 0xD7, 0x93, 0xD7, 0x99, 0xD7, 0xA7, 0xD7, 0x94
    ))
}

$digits = $Phone -replace "\D", ""
if ($digits.StartsWith("0")) { $digits = "972" + $digits.Substring(1) }
elseif ($digits.Length -eq 9) { $digits = "972" + $digits }

$chatId = "$digits@c.us"
$payload = @{
    typeWebhook = "incomingMessageReceived"
    instanceData = @{
        idInstance = 0
        wid = "00000000000@c.us"
        typeInstance = "whatsapp"
    }
    timestamp = [int][double]::Parse((Get-Date -UFormat %s))
    idMessage = "test-green-" + [guid]::NewGuid().ToString("N").Substring(0, 10)
    senderData = @{
        chatId = $chatId
        sender = $chatId
        senderName = "Test"
    }
    messageData = @{
        typeMessage = "textMessage"
        textMessageData = @{ textMessage = $Text }
    }
} | ConvertTo-Json -Depth 6 -Compress

Write-Host "POST $BaseUrl/webhooks/green-api" -ForegroundColor Cyan
Write-Host "From: $digits  Text: $Text" -ForegroundColor Yellow

$bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
Invoke-RestMethod -Uri "$BaseUrl/webhooks/green-api" -Method POST `
    -ContentType "application/json; charset=utf-8" -Body $bytes

Write-Host "OK - check app for new task (phone must be linked in Integrations)" -ForegroundColor Green
