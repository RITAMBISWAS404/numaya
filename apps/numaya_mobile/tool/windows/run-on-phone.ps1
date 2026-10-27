# Numaya: run the app on a USB-connected Android phone (Windows PowerShell).
#   powershell -ExecutionPolicy Bypass -File tool\windows\run-on-phone.ps1
# Optional: -Apk builds a debug APK instead of running.
param([switch]$Apk)

$ErrorActionPreference = "Stop"
$app = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $app

function Step($text) { Write-Host "`n==> $text" -ForegroundColor Magenta }

Step "Checking Flutter"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "Flutter isn't on PATH. Follow docs/mobile/GETTING_STARTED_WINDOWS.md, step 2." -ForegroundColor Red
  exit 1
}
flutter --version

Step "Checking the Android toolchain"
$doctor = flutter doctor 2>&1 | Out-String
if ($doctor -match "\[X\] Android toolchain" -or $doctor -match "\[!\] Android toolchain") {
  Write-Host $doctor
  Write-Host "Fix the Android toolchain first (steps 3 and 4 of the guide)." -ForegroundColor Yellow
  exit 1
}

Step "Getting packages"
flutter pub get

if ($Apk) {
  Step "Building a debug APK"
  flutter build apk --debug
  Write-Host "`nAPK: $app\build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor Green
  exit 0
}

Step "Looking for your phone"
$devices = flutter devices --machine | ConvertFrom-Json
$phone = $devices | Where-Object { $_.targetPlatform -like "android*" } | Select-Object -First 1
if (-not $phone) {
  Write-Host "No Android phone found. Check the cable, unlock the phone and allow USB debugging (guide step 6)." -ForegroundColor Yellow
  exit 1
}
Write-Host "Found: $($phone.name)"

Step "Running Numaya (press r to reload, q to quit)"
flutter run -d $phone.id
