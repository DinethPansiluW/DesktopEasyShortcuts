@echo off
setlocal enabledelayedexpansion

:: Admin check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %GREEN%ERROR: Must run as Administrator!%RESET%
    pause
    exit /b 1
)

set "BACKUP_FILE=%~dp0backuos\power_settings_backup.txt"

type "%BACKUP_FILE%" || echo %GREEN%No backup file found%RESET%
set "POWFILE=%~dp0backups\power_backup.pow"
if not exist "%POWFILE%" (
    echo %RED%ERROR: No backup .pow file found.%RESET%
    timeout /t 2 >nul
    exit /b
)
rem — import the scheme (this creates a new GUID’d scheme, but we’ll make it active)
for /f "tokens=2 delims=:" %%G in ('powercfg /import "%POWFILE%" ^| findstr /i "GUID"') do set "NEWGUID=%%G"
if not defined NEWGUID (
    echo %RED%ERROR: Import failed.%RESET%
    timeout /t 2 >nul
    exit /b
)
set "NEWGUID=%NEWGUID: =%"
rem — set the newly imported scheme active
powercfg /setactive %NEWGUID%
echo.
echo %GREEN%Restored power settings from backup file.%RESET%
timeout /t 3 >nul
exit