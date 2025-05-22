@echo off
title Sleep Countdown
color 0A
setlocal enabledelayedexpansion
set "Time=10"
cls
powershell -Command "Write-Host 'Countdown Start to Sleep' -ForegroundColor Cyan"
echo.
for /l %%i in (10,-1,1) do (
   echo Sleeping in %%i seconds...
   echo.
   timeout /t 1 /nobreak >nul
)
rundll32.exe powrprof.dll,SetSuspendState 0,1,0
