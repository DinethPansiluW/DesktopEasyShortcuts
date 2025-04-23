@echo off
title Sleep Countdown
color 0A
setlocal enabledelayedexpansion

:: Default countdown time
set "Time=5"

:choose
cls
echo Press [C] to change countdown time or any other key to continue with %Time% seconds...
choice /c C0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ /n /t 5 /d . >nul
if errorlevel 3 goto startCountdown
if errorlevel 2 goto startCountdown
if errorlevel 1 (
    set /p Time=Enter new countdown time in seconds: 
)

:startCountdown
cls
echo Starting countdown for %Time% seconds...
echo (Press Ctrl+C to cancel this script)
echo.

for /l %%i in (!Time!,-1,1) do (
    echo Sleeping in %%i seconds...
    timeout /t 1 /nobreak >nul
)

:: Start shutdown
start "" "Shutdown.vbs"
