@echo off
title Hibernate Countdown
color 0A
setlocal enabledelayedexpansion
set "Time=10"
cls
powershell -Command "Write-Host 'Countdown Start to Hibernate' -ForegroundColor Cyan"
echo.
for /l %%i in (10,-1,1) do (
   echo Hibernating in %%i seconds...
   echo.
   timeout /t 1 /nobreak >nul
)
shutdown /h
