# Get current script path and backup file path
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath
$backupFile = Join-Path $scriptDir "PowerSettingsBackup.txt"

if (-Not (Test-Path $backupFile)) {
    Write-Host "Backup file not found: $backupFile"
    exit
}

# Read the backup content
$content = Get-Content $backupFile

# Extract values using regex
$guid = ($content | Select-String "Active Scheme:").ToString() -replace "Active Scheme:\s*", ""
$displayAC = ($content | Select-String "AC \(Plugged In\):" | Where-Object { $_ -match "\[Display Timeout\]" -or $_ -match "AC \(Plugged In\):" })[0].ToString() -replace ".*AC \(Plugged In\):\s*", "" -replace " minutes", ""
$displayDC = ($content | Select-String "DC \(On Battery\):" | Where-Object { $_ -match "\[Display Timeout\]" -or $_ -match "DC \(On Battery\):" })[0].ToString() -replace ".*DC \(On Battery\):\s*", "" -replace " minutes", ""
$sleepAC = ($content | Select-String "AC \(Plugged In\):" | Where-Object { $_ -match "\[Sleep Timeout\]" -or $_ -match "AC \(Plugged In\):" })[1].ToString() -replace ".*AC \(Plugged In\):\s*", "" -replace " minutes", ""
$sleepDC = ($content | Select-String "DC \(On Battery\):" | Where-Object { $_ -match "\[Sleep Timeout\]" -or $_ -match "DC \(On Battery\):" })[1].ToString() -replace ".*DC \(On Battery\):\s*", "" -replace " minutes", ""

# Convert to seconds
$displayACsec = [int]$displayAC * 60
$displayDCsec = [int]$displayDC * 60
$sleepACsec = [int]$sleepAC * 60
$sleepDCsec = [int]$sleepDC * 60

# Restore settings
powercfg /change $guid /monitor-timeout-ac $displayAC
powercfg /change $guid /monitor-timeout-dc $displayDC
powercfg /change $guid /standby-timeout-ac $sleepAC
powercfg /change $guid /standby-timeout-dc $sleepDC

Write-Host "Power settings restored successfully."
