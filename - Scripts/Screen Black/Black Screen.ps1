# Ensure script runs as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Get script folder
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath

# Get active power scheme GUID
$guidLine = powercfg /getactivescheme | ForEach-Object { ($_ -split '\: ')[-1].Trim() }
$guid = $guidLine.Split(' ')[0].Trim()

# GUIDs for sleep and display timeout
$subSleep = "238C9FA8-0AAD-41ED-83F4-97BE242C8F20"
$standbySetting = "29F6C1DB-86DA-48C5-9FDB-F2B67B1F44DA"

$subDisplay = "7516B95F-F776-4464-8C53-06167F40CC99"
$displaySetting = "3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E"

# Get Display Timeout
$displayAC = powercfg /query $guid $subDisplay $displaySetting | Select-String "Power Setting Index" | Select-Object -First 1
$displayDC = powercfg /query $guid $subDisplay $displaySetting | Select-String "Power Setting Index" | Select-Object -Last 1

# Get Sleep Timeout
$sleepAC = powercfg /query $guid $subSleep $standbySetting | Select-String "Power Setting Index" | Select-Object -First 1
$sleepDC = powercfg /query $guid $subSleep $standbySetting | Select-String "Power Setting Index" | Select-Object -Last 1

# Convert hex to minutes
$toMinutes = {
    param($line)
    $hex = ($line -split ':')[-1].Trim()
    [int]$seconds = [Convert]::ToInt32($hex, 16)
    return [math]::Round($seconds / 60)
}

# Save backup
$backup = @"
Active Power Scheme: $guid

[Display Timeout]
AC (Plugged In): $(& $toMinutes $displayAC) minutes
DC (On Battery): $(& $toMinutes $displayDC) minutes

[Sleep Timeout]
AC (Plugged In): $(& $toMinutes $sleepAC) minutes
DC (On Battery): $(& $toMinutes $sleepDC) minutes
"@

$backupPath = Join-Path $scriptDir "PowerSettingsBackup.txt"
$backup | Out-File -Encoding UTF8 -FilePath $backupPath

# Set Sleep to NEVER (0 minutes)
powercfg /setacvalueindex $guid $subSleep $standbySetting 0
powercfg /setdcvalueindex $guid $subSleep $standbySetting 0

# Apply the modified scheme
powercfg /S $guid

# Turn off the display
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Display {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);
}
"@
$HWND_BROADCAST = [intptr]0xffff
$WM_SYSCOMMAND = 0x0112
$SC_MONITORPOWER = 0xF170
[Display]::SendMessage($HWND_BROADCAST, $WM_SYSCOMMAND, [intptr]$SC_MONITORPOWER, [intptr]2)
