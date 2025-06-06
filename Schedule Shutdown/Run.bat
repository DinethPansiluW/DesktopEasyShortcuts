combined that script and this script

@echo off
setlocal enabledelayedexpansion

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: Relaunch as administrator
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)

set "tempScript=%temp%\CancelSchedule.bat"
(
    echo @echo off
    echo schtasks /query /tn "Schedule Shutdown PC" 2^>nul 1^>nul ^&^& (
    echo     schtasks /delete /tn "Schedule Shutdown PC" /f
    echo )
    echo schtasks /delete /tn "Cancel Schedule Shutdown" /f 2^>nul 1^>nul
    echo del "%%~f0"
)>"%tempScript%"

schtasks /create /tn "Cancel Schedule Shutdown" /tr "\"%tempScript%\"" /sc ONSTART /ru SYSTEM /RL HIGHEST /F

:main
:: Cancel any previous scheduled shutdown tasks and clear screen
schtasks /delete /tn "Schedule Shutdown PC" /f >nul 2>&1
shutdown /a >nul 2>&1
cls

:: Set text color to green
color 0A

:: Initial prompt
set "mode=main"
echo Previous shutdown schedule (if any) canceled.
set /p "timeInput=Enter shutdown time (HHMM) : "
goto validate

:reschedule
echo.
set "mode=reschedule"
set /p "newInput=Enter new shutdown time (HHMM) or 'cancel' : "
if /i "%newInput%"=="cancel" (
    schtasks /delete /tn "Schedule Shutdown PC" /f >nul 2>&1
    shutdown /a >nul 2>&1
    del "%TEMP%\shutdown_now.bat" >nul 2>&1
    echo Previous shutdown schedule canceled.
    timeout /t 1 >nul
    cls
    goto main
)
set "timeInput=%newInput%"
goto validate

:validate
:: Validate format: exactly 4 digits, all numeric
if "%timeInput%"=="" (
    goto input_fail
)
if not "%timeInput:~0,4%"=="%timeInput%" (
    goto input_fail
)
for /f "delims=0123456789" %%a in ("%timeInput%") do goto input_fail

:: Parse hour and minute
set /a numHour=1%timeInput:~0,2% - 100 2>nul
set /a numMinute=1%timeInput:~2,2% - 100 2>nul
if %numHour% LSS 0   goto invalid_hour
if %numHour% GTR 23  goto invalid_hour
if %numMinute% LSS 0 goto invalid_minute
if %numMinute% GTR 59 goto invalid_minute

:: Format hour and minute as two digits
if %numHour% LSS 10 ( set "formattedHour=0%numHour%" ) else ( set "formattedHour=%numHour%" )
if %numMinute% LSS 10 ( set "formattedMinute=0%numMinute%" ) else ( set "formattedMinute=%numMinute%" )
set "formattedTime=%formattedHour%:%formattedMinute%"

:: Get current time (HH:MM)
for /f "tokens=1-2 delims=: " %%A in ("%time%") do (
    set "currentHour=%%A"
    set "currentMinute=%%B"
)
set "currentHour=%currentHour: =%"
set /a currentTimeMinutes=(currentHour * 60) + currentMinute
set /a inputTimeMinutes=(numHour * 60) + numMinute

:: Determine whether to schedule today or tomorrow
set "scheduleMessage=Shutdown scheduled today at"
if %inputTimeMinutes% LEQ %currentTimeMinutes% (
    set "scheduleMessage=Shutdown scheduled tomorrow at"
    for /f %%i in ('powershell -Command "(Get-Date).AddDays(1).ToString('MM/dd/yyyy')"') do set "startDate=%%i"
) else (
    for /f %%i in ('powershell -Command "Get-Date -Format 'MM/dd/yyyy'"') do set "startDate=%%i"
)

:: Create the one-shot shutdown script
> "%TEMP%\shutdown_now.bat" (
    echo @echo off
    echo shutdown /s /f /t 0
)

:: Schedule the task
schtasks /create /tn "Schedule Shutdown PC" /tr "\"%TEMP%\shutdown_now.bat\"" /sc once /st %formattedTime% /sd %startDate% /rl HIGHEST /f >nul 2>&1

:: Prepare display hour and AM/PM
set /a displayHour=numHour %% 12
if %displayHour%==0 set displayHour=12
set "ampm=AM"
if %numHour% GEQ 12 set ampm=PM

:: Show confirmation
echo %scheduleMessage% %displayHour%:%formattedMinute% %ampm%.
goto reschedule

:input_fail
echo Invalid input. Use 4 digits like 2230 for 10:30 PM.
if "%mode%"=="reschedule" (
    goto reschedule
) else (
    goto main
)

:invalid_hour
echo Invalid hour. Must be between 00-23.
if "%mode%"=="reschedule" (
    goto reschedule
) else (
    goto main
)

:invalid_minute
echo Invalid minute. Must be between 00-59.
if "%mode%"=="reschedule" (
    goto reschedule
) else (
    goto main
)
