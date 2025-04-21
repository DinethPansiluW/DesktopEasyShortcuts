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

# Close the script after execution
exit
