@echo off
cd /d "%~dp0"
title Power Action Time Manager
setlocal enabledelayedexpansion

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

:: Define paths relative to script location
set "ShutdownPath=..\Shutdown"
set "RestartPath=..\Restart"
set "SleepPath=..\Sleep"
set "HibernatePath=..\Hibernate"



:refresh
:: Load times
for /f "usebackq delims=" %%A in ("%ShutdownPath%\time.txt") do set "ShutdownTime=%%A"
for /f "usebackq delims=" %%A in ("%RestartPath%\time.txt") do set "RestartTime=%%A"
for /f "usebackq delims=" %%A in ("%SleepPath%\time.txt") do set "SleepTime=%%A"
for /f "usebackq delims=" %%A in ("%HibernatePath%\time.txt") do set "HibernateTime=%%A"

:: Default values if not found
if not defined ShutdownTime set ShutdownTime=N/A
if not defined RestartTime set RestartTime=N/A
if not defined SleepTime set SleepTime=N/A
if not defined HibernateTime set HibernateTime=N/A

:menu
cls
echo %PINK%==========================================
echo        %SKYBLUE%Power Action Time Manager%RESET%
echo %PINK%==========================================%RESET%
echo.
echo %GREENU%Current Countdown Times:%RESET%
echo.
echo %GREEN%[1]%RESET% Shutdown    - %ORANGE%!ShutdownTime! seconds%RESET%
echo %GREEN%[2]%RESET% Restart     - %ORANGE%!RestartTime! seconds%RESET%
echo %GREEN%[3]%RESET% Sleep       - %ORANGE%!SleepTime! seconds%RESET%
echo %GREEN%[4]%RESET% Hibernate   - %ORANGE%!HibernateTime! seconds%RESET%
echo.
echo %GREENU%Change Countdown Time:%RESET%
echo.
echo %GREEN%[1]%RESET% Shutdown
echo %GREEN%[2]%RESET% Restart
echo %GREEN%[3]%RESET% Sleep
echo %GREEN%[4]%RESET% Hibernate
echo %RED%[5]%RESET% Exit
echo.
set /p choice=Select option [1-5]: %SKYBLUE%

if "%choice%"=="1" (
    pushd "%ShutdownPath%"
    call TimeChange.bat
    popd
    goto refresh
)
if "%choice%"=="2" (
    pushd "%RestartPath%"
    call TimeChange.bat
    popd
    goto refresh
)
if "%choice%"=="3" (
    pushd "%SleepPath%"
    call TimeChange.bat
    popd
    goto refresh
)
if "%choice%"=="4" (
    pushd "%HibernatePath%"
    call TimeChange.bat
    popd
    goto refresh
)
if "%choice%"=="5" exit /b

echo.
echo %RED%Invalid option. Press any key to try again...%RESET%
pause >nul
goto menu
