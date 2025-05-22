@echo off
title Restart Countdown
color 0A
setlocal enabledelayedexpansion
set "Time=10"
cls
powershell -Command "Write-Host 'Countdown Start to Restart' -ForegroundColor Cyan"
echo.
for /l %%i in (10,-1,1) do (
   echo Restarting in %%i seconds...
   echo.
   timeout /t 1 /nobreak >nul
)
shutdown /r /t 0
