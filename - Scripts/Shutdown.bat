@echo off
title Shutdown Countdown
set /a countdown=10

echo Computer will shutdown in %countdown% seconds...
echo.

:countdown
if %countdown% LEQ 0 goto shutdown
echo Shutting down in %countdown%...
timeout /t 1 /nobreak >nul
set /a countdown-=1
goto countdown

:shutdown
shutdown /s /t 0