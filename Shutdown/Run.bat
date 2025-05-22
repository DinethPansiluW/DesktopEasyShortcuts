@echo off
title Shutdown Countdown
color 0A
setlocal enabledelayedexpansion
set "Time=10"
cls
powershell -Command "Write-Host 'Countdown Start to Shutdown' -ForegroundColor Cyan"
echo.
for /l %%i in (10,-1,1) do (
   echo Shutting down in %%i seconds...
   timeout /t 1 /nobreak >nul
)
shutdown /s /t 0
