
@echo off
title Shutdown in 10 seconds...
color 0A
setlocal enabledelayedexpansion

echo Press Ctrl+C to cancel...
echo.

for /l %%i in (10,-1,1) do (
    echo Shutting down in %%i seconds...
    timeout /t 1 /nobreak >nul
)

shutdown /s /t 0
