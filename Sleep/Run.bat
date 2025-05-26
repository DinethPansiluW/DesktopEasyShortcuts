@echo off
title Sleep Countdown
setlocal enabledelayedexpansion

:: ANSI color escape codes (only skyblue)
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

:: Determine script folder & saved time file
set "ScriptDir=%~dp0"
set "TimeFile=%ScriptDir%last_time.txt"

:: Load saved time or default to 10
if exist "%TimeFile%" (
    set /p Time=<"%TimeFile%"
) else (
    set "Time=10"
)

:countdown_loop
cls
echo.

for /L %%i in (!Time!,-1,1) do (
    cls
    echo.
    echo.
    echo.
    echo.
    echo %GREEN%Sleeping in %%i seconds...%RESET%
    echo.
    echo %SKYBLUE%Press E to edit the countdown time.%RESET%

    choice /C EN /N /T 1 /D N >nul
    if errorlevel 2 (
        rem timeout or N – continue
    ) else (
        call :TimeChange
        goto :countdown_loop
    )
)

echo.
echo %SKYBLUE%Entering sleep now...%RESET%

:: Disable hibernation so it actually sleeps
powercfg -h off

:: Invoke sleep
rundll32.exe powrprof.dll,SetSuspendState 0,1,0

:: Re-enable hibernation
powercfg -h on

exit /B

:TimeChange
setlocal
set /p NewTime="%RESET%Enter new countdown time (seconds): %ORANGE%"
if not "%NewTime%"=="" (
    endlocal & set "Time=%NewTime%"
    >"%TimeFile%" echo %NewTime%
) else (
    endlocal
)
exit /B
