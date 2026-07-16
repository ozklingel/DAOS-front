# TaskMail — Firebase setup helper (Windows)
# Prerequisites: Firebase Android app with package com.taskmail.taskmail
# and google-services.json downloaded to android/app/

$ErrorActionPreference = "Stop"
$MobileRoot = Split-Path -Parent $PSScriptRoot
Set-Location $MobileRoot

$FlutterBin = $env:FLUTTER_BIN
if (-not $FlutterBin) {
    $FlutterBin = "C:\Users\OZKL\flutter_windows_3.29.3-stable\flutter\bin"
}
$Dart = Join-Path $FlutterBin "dart.bat"
$Flutter = Join-Path $FlutterBin "flutter.bat"

if (-not (Test-Path $Dart)) {
    Write-Error "Flutter/Dart not found. Set FLUTTER_BIN or install Flutter."
}

$GoogleServices = Join-Path $MobileRoot "android\app\google-services.json"
if (-not (Test-Path $GoogleServices)) {
    Write-Host ""
    Write-Host "MISSING: android/app/google-services.json" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Open https://console.firebase.google.com/"
    Write-Host "2. Add Android app — package: com.taskmail.taskmail"
    Write-Host "3. Download google-services.json"
    Write-Host "4. Save to: $GoogleServices"
    Write-Host "5. Re-run this script"
    Write-Host ""
    exit 1
}

Write-Host "Installing FlutterFire CLI..." -ForegroundColor Cyan
& $Dart pub global activate flutterfire_cli

$PubCacheBin = Join-Path $env:LOCALAPPDATA "Pub\Cache\bin"
$FlutterFire = Join-Path $PubCacheBin "flutterfire.bat"
if (-not (Test-Path $FlutterFire)) {
    Write-Error "flutterfire not found at $FlutterFire"
}

Write-Host "Running flutterfire configure (select your Firebase project + Android)..." -ForegroundColor Cyan
& $FlutterFire configure --platforms=android

Write-Host "Fetching packages..." -ForegroundColor Cyan
& $Flutter pub get

Write-Host ""
Write-Host "Firebase setup complete. Rebuild the app (full restart, not hot reload):" -ForegroundColor Green
Write-Host "  flutter clean"
Write-Host "  flutter run --dart-define=API_BASE_URL=... --dart-define=GOOGLE_SERVER_CLIENT_ID=..."
