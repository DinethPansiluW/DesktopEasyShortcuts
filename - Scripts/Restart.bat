@echo off
title Restart Countdown
set /a countdown=10

echo Computer will RESTART in %countdown% seconds...
echo Press Ctrl+C to cancel
echo.

:countdown
if %countdown% LEQ 0 goto restart
echo Restarting in %countdown%...
timeout /t 1 /nobreak >nul
set /a countdown-=1
goto countdown

:restart
shutdown /r /t 0