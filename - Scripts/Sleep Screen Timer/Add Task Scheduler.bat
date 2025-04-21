@echo off
REM Run as Administrator check (improved method)
fltmc >nul 2>&1 || (
    echo Error: This script must be run as Administrator.
    pause
    exit /b 1
)

REM Get path to Restore.bat (handles spaces)
set "restorePath=%~dp0Restore.bat"
if not exist "%restorePath%" (
    echo Error: Restore.bat not found in script directory.
    pause
    exit /b 1
)

REM Delete existing task (if any)
schtasks /Delete /TN "Restore Task" /F >nul 2>&1

REM Create task with SYSTEM account (works even if no user is logged in)
schtasks /Create /TN "Restore Task" /TR "\"%restorePath%\"" /SC ONSTART /RU "SYSTEM" /RL HIGHEST /F /Z

if %errorLevel% equ 0 (
    echo Task created. Will run ONCE at next boot.
) else (
    echo Task creation failed. Check paths/permissions.
)

REM Optional: Show confirmation in Task Scheduler
timeout /t 5 >nul
taskschd.msc

pause