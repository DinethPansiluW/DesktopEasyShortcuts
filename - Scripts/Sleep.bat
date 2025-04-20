@echo off
title Sleep in 5 seconds...
color 0A
setlocal enabledelayedexpansion

:: Disable Ctrl+C prompt
break >nul

echo Press Ctrl+C to cancel (no confirmation)
echo.

for /l %%i in (5,-1,1) do (
    echo Sleeping in %%i seconds...
    timeout /t 1 /nobreak >nul
)

:: Put computer to sleep
rundll32.exe powrprof.dll,SetSuspendState 0,1,0