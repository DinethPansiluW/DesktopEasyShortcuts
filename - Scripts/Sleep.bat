@echo off
title Sleep Countdown
color 0A
setlocal enabledelayedexpansion

:: Set the countdown time in seconds
set "Time=5"

:: Disable Ctrl+C prompt
break >nul

echo Press Ctrl+C to cancel (no confirmation)
echo.

for /l %%i in (!Time!,-1,1) do (
    echo Sleeping in %%i seconds...
    timeout /t 1 /nobreak >nul
)

:: Put computer to sleep
rundll32.exe powrprof.dll,SetSuspendState 0,1,0
