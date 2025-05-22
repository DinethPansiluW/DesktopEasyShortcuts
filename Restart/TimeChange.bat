@echo off
title Restart Countdown Generator
:: Set ANSI color escape codes
set "ESC="
set "GREEN=%ESC%[1;32m"
set "ORANGE=%ESC%[33m"
set "RESET=%ESC%[0m"
setlocal enabledelayedexpansion

:: Prompt user to enter time in seconds
echo.
echo.
set /p Time=Enter countdown time in seconds:%GREEN% 

:: Save time to time.txt
echo %Time%>time.txt

:: Create Restart.bat with the countdown script
(
  echo @echo off
  echo title Restart Countdown
  echo color 0A
  echo setlocal enabledelayedexpansion
  echo set "Time=%Time%"
  echo cls
  echo powershell -Command "Write-Host 'Countdown Start to Restart' -ForegroundColor Cyan"
  echo echo.
  echo for /l %%%%i in ^(!Time!,-1,1^) do ^(
  echo    echo Restarting in %%%%i seconds...
  echo    timeout /t 1 /nobreak ^>nul
  echo ^)
  echo shutdown /r /t 0
)>Run.bat

echo.
echo Time Change to %Time% seconds.
echo.
echo %ORANGE%Press any key to continue...
pause >nul
exit /b
