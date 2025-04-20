@echo off
:: Ultra-Robust Power Settings Manager with Single Backup File
:: Optimized for stability and accurate mode handling
setlocal enabledelayedexpansion

:: Admin check
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Must run as Administrator!
    pause
    exit /b 1
)

:: Default mode handling: Accept only AC or DC (for Battery)
if /i "%~1"=="AC" (
    set "mode=AC"
) else if /i "%~1"=="DC" (
    set "mode=DC"
) else (
    if not "%~1%"=="" echo Invalid parameter. Defaulting to AC mode.
    set "mode=AC"
)

:: Get script directory (for backups)
set "scriptdir=%~dp0"
if "%scriptdir:~-1%"=="\" set "scriptdir=%scriptdir:~0,-1%"

:: Create unique temporary file name
set "tempfile=%temp%\powercfg_%random%.tmp"

:MAIN_LOOP
cls
powercfg /q > "%tempfile%" 2>nul

:: Parse AC and DC settings (for information purposes, can be extended)
for %%P in (AC DC) do (
    set "%%P_mon=Unknown"
    set "%%P_std=Unknown"
    for /f "tokens=2 delims=:" %%A in ('findstr /i "monitor-timeout-%%P" "%tempfile%"') do (
        set "%%P_mon=%%A"
        set "%%P_mon=!%%P_mon: =!"
        if "!%%P_mon!"=="0" set "%%P_mon=Never"
    )
    for /f "tokens=2 delims=:" %%A in ('findstr /i "standby-timeout-%%P" "%tempfile%"') do (
        set "%%P_std=%%A"
        set "%%P_std=!%%P_std: =!"
        if "!%%P_std!"=="0" set "%%P_std=Never"
    )
)

del "%tempfile%" >nul 2>&1

echo ======================================
if /i "%mode%"=="AC" (
    echo SUPER POWER SETTINGS MANAGER - AC (Plugged In)
) else (
    echo SUPER POWER SETTINGS MANAGER - DC (Battery)
)
echo ======================================
echo.

:: Display mode-specific presets
if /i "%mode%"=="AC" (
    echo 1. Balanced: Screen 5m, Sleep 10m
    echo 2. Screen Only: Screen 5m, Sleep Never
    echo 3. Never: Screen Never, Sleep Never
    echo 4. Custom Settings
) else (
    echo 1. Power Saver: Screen 2m, Sleep 3m
    echo 2. Screen Only: Screen 2m, Sleep Never
    echo 3. Never: Screen Never, Sleep Never
    echo 4. Custom Settings
)
echo.
echo 5. Switch Mode (AC/DC)
echo 0. Exit
echo.

:: Input validation: expect a single digit (0-5)
set /p "choice=Enter choice (0-5): "
if not defined choice goto MAIN_LOOP
echo %choice% | findstr /r "^[0-5]$" >nul || goto MAIN_LOOP

if "%choice%"=="0" exit /b 0

if "%choice%"=="5" (
    if /i "%mode%"=="AC" (
        set "mode=DC"
    ) else (
        set "mode=AC"
    )
    call :SILENT_BACKUP
    goto MAIN_LOOP
)

if "%choice%"=="4" (
    call :CUSTOM_SETTINGS
    goto MAIN_LOOP
)

:: Apply preset values based on mode
if /i "%mode%"=="AC" (
    if "%choice%"=="1" (
         powercfg -change -monitor-timeout-ac 5
         powercfg -change -standby-timeout-ac 10
         echo Set: Screen = 5min, Sleep = 10min
    ) else if "%choice%"=="2" (
         powercfg -change -monitor-timeout-ac 5
         powercfg -change -standby-timeout-ac 0
         echo Set: Screen = 5min, Sleep = Never
    ) else if "%choice%"=="3" (
         powercfg -change -monitor-timeout-ac 0
         powercfg -change -standby-timeout-ac 0
         echo Set: Never timeout, Never sleep
    )
) else if /i "%mode%"=="DC" (
    if "%choice%"=="1" (
         powercfg -change -monitor-timeout-dc 2
         powercfg -change -standby-timeout-dc 3
         echo Set: Screen = 2min, Sleep = 3min
    ) else if "%choice%"=="2" (
         powercfg -change -monitor-timeout-dc 2
         powercfg -change -standby-timeout-dc 0
         echo Set: Screen = 2min, Sleep = Never
    ) else if "%choice%"=="3" (
         powercfg -change -monitor-timeout-dc 0
         powercfg -change -standby-timeout-dc 0
         echo Set: Never timeout, Never sleep
    )
)
call :SILENT_BACKUP
timeout /t 2 >nul
goto MAIN_LOOP

:SILENT_BACKUP
:: Create silent backup of current power settings in the script's directory
powercfg /q > "%scriptdir%\powercfg_%mode%_backup.txt" 2>nul
goto :eof

:CUSTOM_SETTINGS
echo.
echo Enter custom [%mode%] settings (0 = Never, 1-999 = Minutes)
echo.

:GET_SCREEN
set /p "scr=Screen timeout (0-999): "
echo %scr% | findstr /r "^[0-9][0-9]*$" >nul || goto GET_SCREEN
if %scr% gtr 999 goto GET_SCREEN

:GET_SLEEP
set /p "slp=Sleep timeout (0-999): "
echo %slp% | findstr /r "^[0-9][0-9]*$" >nul || goto GET_SLEEP
if %slp% gtr 999 goto GET_SLEEP

if /i "%mode%"=="AC" (
    powercfg -change -monitor-timeout-ac %scr%
    powercfg -change -standby-timeout-ac %slp%
) else if /i "%mode%"=="DC" (
    powercfg -change -monitor-timeout-dc %scr%
    powercfg -change -standby-timeout-dc %slp%
)
echo Custom settings applied!
call :SILENT_BACKUP
timeout /t 2 >nul
goto MAIN_LOOP