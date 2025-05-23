@echo off
title Hibernate Countdown Generator
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

:: Create Hibernate.bat with the countdown script
(
  echo @echo off
  echo title Hibernate Countdown
  echo color 0A
  echo setlocal enabledelayedexpansion
  echo set "Time=%Time%"
  echo cls
  echo powershell -Command "Write-Host 'Countdown Start to Hibernate' -ForegroundColor Cyan"
  echo echo.
  echo for /l %%%%i in ^(!Time!,-1,1^) do ^(
  echo    echo Hibernating in %%%%i seconds...
  echo    echo.
  echo    timeout /t 1 /nobreak ^>nul
  echo ^)
  echo shutdown /h
)>Run.bat

echo.
echo Time Change to %Time% seconds.
echo.
echo %ORANGE%Press any key to continue...
pause >nul
exit /b
