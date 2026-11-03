# Ruqyah Windows installer
$ErrorActionPreference = "Stop"
$repo = "https://raw.githubusercontent.com/fahmieabdrahim/ruqyah/main"
$appDir = Join-Path $env:LOCALAPPDATA "Ruqyah"
$playerPath = Join-Path $appDir "ruqyah.ps1"

if (-not $env:OS -or $env:OS -ne "Windows_NT") {
  throw "Installer ini hanya untuk Windows."
}

New-Item -ItemType Directory -Path $appDir -Force | Out-Null
Write-Host "Memuat turun pemain Ruqyah..."
Invoke-WebRequest -Uri "$repo/ruqyah.ps1" -OutFile $playerPath -UseBasicParsing

$powerShell = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$playerPath`""
$action = New-ScheduledTaskAction -Execute $powerShell -Argument $arguments
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew

$logonTrigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERNAME"
$dailyTrigger = New-ScheduledTaskTrigger -Daily -At "2:00PM"

Register-ScheduledTask -TaskName "Ruqyah-Logon" -Action $action -Trigger $logonTrigger -Principal $principal -Settings $settings -Description "Main Ruqyah ketika pengguna log masuk." -Force | Out-Null
Register-ScheduledTask -TaskName "Ruqyah-Daily-1400" -Action $action -Trigger $dailyTrigger -Principal $principal -Settings $settings -Description "Main Ruqyah setiap hari pada 2:00 petang." -Force | Out-Null

Write-Host ""
Write-Host "Ruqyah berjaya dipasang."
Write-Host "Auto-play: ketika log masuk dan setiap hari pada 2:00 petang."
Write-Host "Pemain akan bermula sekarang."
Start-Process -FilePath $powerShell -ArgumentList $arguments -WindowStyle Hidden
