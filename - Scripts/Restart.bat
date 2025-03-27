@echo off
title Restart in 10 seconds...
color 0A
setlocal enabledelayedexpansion

:: Disable Ctrl+C prompt
break >nul

echo Press Ctrl+C to cancel (no confirmation)
echo.

for /l %%i in (10,-1,1) do (
    echo Restarting in %%i seconds...
    timeout /t 1 /nobreak >nul
)

shutdown /r /t 0 /f