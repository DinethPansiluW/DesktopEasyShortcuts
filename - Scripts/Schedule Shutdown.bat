@echo off
setlocal enabledelayedexpansion

:: Cancel any previous scheduled shutdown tasks
schtasks /delete /tn "ShutdownPC" /f >nul 2>&1
shutdown /a >nul 2>&1
cls

:: Set text color to green for "Previous shutdown schedule" message
color 0A
echo Previous shutdown schedule (if any) canceled.

:: Reset color back to default
color

:input
set "timeInput="
set /p "timeInput=Enter shutdown time (HHMM): "
if not "%timeInput%"=="" if "%timeInput:~0,4%"=="%timeInput%" (
    for /f "delims=0123456789" %%a in ("%timeInput%") do goto input_fail
    goto validate
)
:input_fail
echo Invalid input. Use 4 digits like 2230 for 10:30 PM.
goto input

:validate
:: Ensure time is numeric
set /a hour=1%timeInput:~0,2% - 100 >nul 2>nul || goto input_fail
set /a minute=1%timeInput:~2,2% - 100 >nul 2>nul || goto input_fail
if %hour% LSS 0 goto invalid_hour
if %hour% GTR 23 goto invalid_hour
if %minute% LSS 0 goto invalid_minute
if %minute% GTR 59 goto invalid_minute

:: Format time to HH:MM
if %hour% LSS 10 set "hour=0%hour%"
if %minute% LSS 10 set "minute=0%minute%"
set "formattedTime=%hour%:%minute%"

:: Get current system time
for /f "tokens=1-2 delims=:" %%A in ("%time%") do (
    set "currentHour=%%A"
    set "currentMinute=%%B"
)

:: Compare current time with scheduled shutdown time
set /a "inputTimeMinutes=(hour * 60) + minute"
set /a "currentTimeMinutes=(currentHour * 60) + currentMinute"

:: Adjust message for past time
set "scheduleMessage=Shutdown scheduled today at"
if %inputTimeMinutes% LEQ %currentTimeMinutes% (
    set "scheduleMessage=Shutdown scheduled tomorrow at"
)

:: Create helper shutdown script
> "%TEMP%\shutdown_now.bat" (
    echo @echo off
    echo shutdown /s /f /t 0
)

:: Schedule shutdown task silently (redirect output to nul)
schtasks /create /tn "ShutdownPC" /tr "\"%TEMP%\shutdown_now.bat\"" /sc once /st %formattedTime% /rl HIGHEST /f >nul 2>&1

:: Set text color to green for the "Shutdown scheduled" message
color 0A
set /a displayHour=%hour% %% 12
if %displayHour%==0 set displayHour=12
set "ampm=AM"
if %hour% GEQ 12 set ampm=PM
echo %scheduleMessage% %displayHour%:%minute% %ampm%.

:: Reset color back to default
color

:reschedule
echo.
set /p "newInput=Enter new shutdown time (HHMM) or 'exit': "
if /i "%newInput%"=="exit" (
    schtasks /delete /tn "ShutdownPC" /f >nul 2>&1
    shutdown /a >nul 2>&1
    del "%TEMP%\shutdown_now.bat" >nul 2>&1
    exit /b
)
set "timeInput=%newInput%"
goto validate

:invalid_hour
echo Invalid hour. Must be between 00–23.
goto input

:invalid_minute
echo Invalid minute. Must be between 00–59.
goto input