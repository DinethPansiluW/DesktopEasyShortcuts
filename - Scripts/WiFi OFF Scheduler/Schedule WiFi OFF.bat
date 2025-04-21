@echo off
setlocal enabledelayedexpansion

:init
set "taskName=WiFi Disconnect Task"
set "timeFile=%~dp0time.txt"
set "defaultTime=2015"  :: 8:15 PM in HHMM format

:: Read saved time or use default
if exist "%timeFile%" (
    set /p scheduledTime=<"%timeFile%"
) else (
    set "scheduledTime=%defaultTime%"
)

:: Check task status
schtasks /query /tn "%taskName%" >nul 2>&1
if %errorlevel% equ 0 (set "taskStatus=[ACTIVE]") else set "taskStatus=[INACTIVE]"

:menu
cls
echo WiFi Disconnect Scheduler
echo ----------------------------
echo Scheduled Time: %scheduledTime%
echo Task Status:    %taskStatus%
echo ----------------------------
echo 1. Enable Daily Disconnect
echo 2. Remove Schedule
echo 3. Change Time
echo 4. Exit
echo ----------------------------
set /p choice=Choice: 

goto option%choice% 2>nul

:option1
set "taskTime=!scheduledTime:~0,2!:!scheduledTime:~2,2!"
schtasks /create /sc daily /st "%taskTime%" /tn "%taskName%" /tr "netsh wlan disconnect" /rl highest >nul 2>&1
if %errorlevel% equ 0 (
    echo Task created successfully!
) else (
    echo Failed to create task. Run as Administrator?
)
timeout /t 2 >nul
goto init

:option2
schtasks /delete /tn "%taskName%" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo Task removed successfully!
) else (
    echo No active task to remove
)
timeout /t 2 >nul
goto init

:option3
:retry_time
set "newTime="
set /p "newTime=Enter new time (HHMM 24h format): "

:: Validate input format
echo !newTime!| findstr /r "^[0-9][0-9][0-9][0-9]$" >nul
if errorlevel 1 (
    echo Invalid format. Use 4 digits (HHMM)
    timeout /t 2 >nul
    goto retry_time
)

:: Validate time components
set "hours=!newTime:~0,2!"
set "minutes=!newTime:~2,2!"

if !hours! geq 24 (
    echo Invalid hours (must be 00-23)
    timeout /t 2 >nul
    goto retry_time
)

if !minutes! geq 60 (
    echo Invalid minutes (must be 00-59)
    timeout /t 2 >nul
    goto retry_time
)

:: Update time
set "scheduledTime=!newTime!"
echo !newTime! > "%timeFile%"

:: Update task if exists
schtasks /query /tn "%taskName%" >nul 2>&1
if %errorlevel% equ 0 (
    schtasks /delete /tn "%taskName%" /f >nul
    set "taskTime=!scheduledTime:~0,2!:!scheduledTime:~2,2!"
    schtasks /create /sc daily /st "%taskTime%" /tn "%taskName%" /tr "netsh wlan disconnect" /rl highest >nul
)
echo Time updated successfully!
timeout /t 2 >nul
goto init

:option4
exit /b

:: Handle invalid choices
echo Invalid choice. Please select 1-4
timeout /t 2 >nul
goto init