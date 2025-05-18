@echo off
setlocal enabledelayedexpansion

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: Create a temporary VBScript to relaunch this script with admin rights
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    :: Run the VBScript silently and exit the current window
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)

:: Cancel any previous scheduled shutdown tasks
schtasks /delete /tn "ShutdownPC" /f >nul 2>&1
shutdown /a >nul 2>&1
cls

:: Set text color to green
color 0A

:main
:: Display initial message with input prompt
echo Previous shutdown schedule (if any) canceled.                                                                    
set /p "timeInput=Enter shutdown time (HHMM) : "

:: Handle cancel command immediately
if /i "%timeInput%"=="cancel" (
    schtasks /delete /tn "ShutdownPC" /f >nul 2>&1
    shutdown /a >nul 2>&1
    del "%TEMP%\shutdown_now.bat" >nul 2>&1
    echo Previous shutdown schedule canceled.
    timeout /t 1 >nul
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
if %hour% LSS 10 set "hour=0%hour%"
if %minute% LSS 10 set "minute=0%minute%"
set "formattedTime=%hour%:%minute%"

for /f "tokens=1-2 delims=:" %%A in ("%time%") do (
    set "currentHour=%%A"
    set "currentMinute=%%B"
)
set "currentHour=%currentHour: =%"

set /a "inputTimeMinutes=(hour * 60) + minute"
set /a "currentTimeMinutes=(currentHour * 60) + currentMinute"

set "scheduleMessage=Shutdown scheduled today at"
if %inputTimeMinutes% LEQ %currentTimeMinutes% (
    set "scheduleMessage=Shutdown scheduled tomorrow at"
    for /f %%i in ('powershell -Command "(Get-Date).AddDays(1).ToString('MM/dd/yyyy')"') do set "startDate=%%i"
) else (
    for /f %%i in ('powershell -Command "Get-Date -Format 'MM/dd/yyyy'"') do set "startDate=%%i"
)

:: Create shutdown script
> "%TEMP%\shutdown_now.bat" (
    echo @echo off
    echo shutdown /s /f /t 0
)

:: Schedule task
schtasks /create /tn "ShutdownPC" /tr "\"%TEMP%\shutdown_now.bat\"" /sc once /st %formattedTime% /sd %startDate% /rl HIGHEST /f >nul 2>&1

:: Display confirmation
set /a displayHour=hour %% 12
if %displayHour%==0 set displayHour=12
set "ampm=AM"
if %hour% GEQ 12 set ampm=PM
echo %scheduleMessage% %displayHour%:%minute% %ampm%.

:reschedule
echo.
set /p "newInput=Enter new shutdown time (HHMM) or 'cancel' : "

:: Handle cancel command
if /i "%newInput%"=="cancel" (
    schtasks /delete /tn "ShutdownPC" /f >nul 2>&1
    shutdown /a >nul 2>&1
    del "%TEMP%\shutdown_now.bat" >nul 2>&1
    echo Previous shutdown schedule canceled.
    timeout /t 1 >nul
    cls
    goto main
)

:: Validate new input
set "timeInput=%newInput%"
goto validate

:invalid_hour
echo Invalid hour. Must be between 00–23.
goto main

:invalid_minute
echo Invalid minute. Must be between 00–59.
goto main