@echo off
setlocal enabledelayedexpansion

:: Cancel any previous scheduled shutdown tasks
schtasks /delete /tn "ShutdownPC" /f >nul 2>&1
shutdown /a >nul 2>&1
cls

:: Set text color to green
color 0A

:main
:: Display initial message with input prompt
echo Previous shutdown schedule (if any) canceled.
echo.
set /p "timeInput=Enter shutdown time (HHMM) or 'cancel': "

:: Handle cancel command immediately
if /i "%timeInput%"=="cancel" (
    schtasks /delete /tn "ShutdownPC" /f >nul 2>&1
    shutdown /a >nul 2>&1
    echo Previous shutdown schedule canceled.
    timeout /t 2 >nul
    cls
    goto main
)

:validate
:: Input validation
if not "%timeInput%"=="" if "%timeInput:~0,4%"=="%timeInput%" (
    for /f "delims=0123456789" %%a in ("%timeInput%") do goto input_fail
    goto check_time
)
:input_fail
echo Invalid input. Use 4 digits like 2230 for 10:30 PM.
timeout /t 2 >nul
cls
goto main

:check_time
:: Time validation
set /a hour=1%timeInput:~0,2% - 100 >nul 2>nul || goto input_fail
set /a minute=1%timeInput:~2,2% - 100 >nul 2>nul || goto input_fail
if %hour% LSS 0 goto invalid_hour
if %hour% GTR 23 goto invalid_hour
if %minute% LSS 0 goto invalid_minute
if %minute% GTR 59 goto invalid_minute

:: Format time and calculate schedule
if %hour% LSS 10 (set "hour=0%hour%") else (set "hour=%hour%")
if %minute% LSS 10 (set "minute=0%minute%") else (set "minute=%minute%")

:: Get current time in minutes since midnight
for /f "tokens=1-2 delims=: " %%A in ('powershell -Command "Get-Date -Format 'HH:mm'"') do (
    set "currentHour=%%A"
    set "currentMinute=%%B"
)

set /a "inputTime=(hour * 60) + minute"
set /a "currentTime=(currentHour * 60) + currentMinute"

:: Calculate schedule date
set "scheduleMessage=Shutdown scheduled today at"
set "days=0"
if %inputTime% LEQ %currentTime% (
    set "scheduleMessage=Shutdown scheduled tomorrow at"
    set "days=1"
)

:: Create scheduled task using ISO date format
for /f %%d in ('powershell -Command "(Get-Date).AddDays(%days%).ToString('yyyy-MM-dd')"') do set "schedDate=%%d"

:: Create XML task file for enhanced compatibility
echo ^<?xml version="1.0" encoding="UTF-16"?^> > "%TEMP%\ShutdownTask.xml"
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^> >> "%TEMP%\ShutdownTask.xml"
echo ^<Settings^> >> "%TEMP%\ShutdownTask.xml"
echo ^<WakeToRun^>true^</WakeToRun^> >> "%TEMP%\ShutdownTask.xml"
echo ^<ExecutionTimeLimit^>PT5M^</ExecutionTimeLimit^> >> "%TEMP%\ShutdownTask.xml"
echo ^</Settings^> >> "%TEMP%\ShutdownTask.xml"
echo ^<Actions Context="Author"^> >> "%TEMP%\ShutdownTask.xml"
echo ^<Exec^> >> "%TEMP%\ShutdownTask.xml"
echo ^<Command^>shutdown.exe^</Command^> >> "%TEMP%\ShutdownTask.xml"
echo ^<Arguments^>/s /f /t 0^</Arguments^> >> "%TEMP%\ShutdownTask.xml"
echo ^</Exec^> >> "%TEMP%\ShutdownTask.xml"
echo ^</Actions^> >> "%TEMP%\ShutdownTask.xml"
echo ^<Triggers^> >> "%TEMP%\ShutdownTask.xml"
echo ^<TimeTrigger^> >> "%TEMP%\ShutdownTask.xml"
echo ^<StartBoundary^>%schedDate%T%hour%:%minute%:00^</StartBoundary^> >> "%TEMP%\ShutdownTask.xml"
echo ^<Enabled^>true^</Enabled^> >> "%TEMP%\ShutdownTask.xml"
echo ^</TimeTrigger^> >> "%TEMP%\ShutdownTask.xml"
echo ^</Triggers^> >> "%TEMP%\ShutdownTask.xml"
echo ^</Task^> >> "%TEMP%\ShutdownTask.xml"

:: Register task using XML definition
schtasks /create /tn "ShutdownPC" /xml "%TEMP%\ShutdownTask.xml" /f >nul 2>&1

:: Cleanup XML file
del "%TEMP%\ShutdownTask.xml" >nul 2>&1

:: Display confirmation
set /a displayHour=hour %% 12
if %displayHour%==0 set displayHour=12
set "ampm=AM"
if %hour% GEQ 12 set ampm=PM
echo.
echo %scheduleMessage% %displayHour%:%minute% %ampm%.
echo.

:reschedule
set /p "newInput=Enter new time (HHMM) or 'cancel': "

if /i "%newInput%"=="cancel" (
    schtasks /delete /tn "ShutdownPC" /f >nul 2>&1
    shutdown /a >nul 2>&1
    echo Shutdown canceled.
    timeout /t 2 >nul
    cls
    goto main
)

set "timeInput=%newInput%"
goto validate

:invalid_hour
echo Invalid hour. Must be between 00–23.
timeout /t 2 >nul
cls
goto main

:invalid_minute
echo Invalid minute. Must be between 00–59.
timeout /t 2 >nul
cls
goto main