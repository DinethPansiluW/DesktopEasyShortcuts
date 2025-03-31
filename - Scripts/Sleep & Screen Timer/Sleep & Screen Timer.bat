@echo off
:: Ultra-Robust Power Settings Manager with Single Backup File
:: Guaranteed to work in all scenarios
setlocal enabledelayedexpansion

:: Admin check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Must run as Administrator!
    pause
    exit /b 1
)

:: Self-healing parameter check
if "%~1"=="" (
    set "mode=AC"
) else (
    set "mode=%~1"
    if /i not "!mode!"=="AC" if /i not "!mode!"=="BATTERY" (
        echo Invalid parameter. Defaulting to AC mode.
        set "mode=AC"
    )
)

:: Get script location for backups
set "scriptdir=%~dp0"
if "%scriptdir:~-1%"=="\" set "scriptdir=%scriptdir:~0,-1%"

:: Create unique temp file name
set "tempfile=%temp%\powercfg_%random%.tmp"

:MAIN_LOOP
cls
:: Get current settings and store in temp file
powercfg /q > "%tempfile%"

:: Parse AC settings
set "ac_mon=Unknown"
set "ac_std=Unknown"
for /f "tokens=2 delims=:" %%A in ('findstr /i "monitor-timeout-ac" "%tempfile%"') do (
    set "ac_mon=%%A"
    set "ac_mon=!ac_mon: =!"
    if "!ac_mon!"=="0" set "ac_mon=Never"
)
for /f "tokens=2 delims=:" %%A in ('findstr /i "standby-timeout-ac" "%tempfile%"') do (
    set "ac_std=%%A"
    set "ac_std=!ac_std: =!"
    if "!ac_std!"=="0" set "ac_std=Never"
)

:: Parse DC settings
set "dc_mon=Unknown"
set "dc_std=Unknown"
for /f "tokens=2 delims=:" %%A in ('findstr /i "monitor-timeout-dc" "%tempfile%"') do (
    set "dc_mon=%%A"
    set "dc_mon=!dc_mon: =!"
    if "!dc_mon!"=="0" set "dc_mon=Never"
)
for /f "tokens=2 delims=:" %%A in ('findstr /i "standby-timeout-dc" "%tempfile%"') do (
    set "dc_std=%%A"
    set "dc_std=!dc_std: =!"
    if "!dc_std!"=="0" set "dc_std=Never"
)

:: Clean up temp file
del "%tempfile%" >nul 2>&1

echo.
echo ===== SUPER POWER SETTINGS MANAGER =====
echo Current Mode: [!mode!]
echo ======================================
echo.
echo [!mode!] Presets:
if /i "!mode!"=="AC" (
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
echo 5. Switch Mode (AC/Battery)
echo 0. Exit
echo.

:: Bulletproof input handling
set "valid_options=123450"
set "choice="
set /p "choice=Enter choice (0-5): "

:: Validate input exists
if "!choice!"=="" (
    echo Please enter a value
    timeout /t 1 >nul
    goto MAIN_LOOP
)

:: Validate input is number
echo !choice!|findstr /r "^[0-9]$" >nul
if errorlevel 1 (
    echo Numbers only please
    timeout /t 1 >nul
    goto MAIN_LOOP
)

:: Validate input in range
echo !valid_options!|findstr /c:"!choice!" >nul
if errorlevel 1 (
    echo Invalid option
    timeout /t 1 >nul
    goto MAIN_LOOP
)

:: Handle menu choices
if "!choice!"=="0" exit /b 0

if "!choice!"=="5" (
    if /i "!mode!"=="AC" (
        set "mode=BATTERY"
        call :SILENT_BACKUP
    ) else (
        set "mode=AC"
        call :SILENT_BACKUP
    )
    goto MAIN_LOOP
)

:: Handle power settings
if "!choice!"=="4" (
    call :CUSTOM_SETTINGS
    goto MAIN_LOOP
)

:: Apply presets
if /i "!mode!"=="AC" (
    if "!choice!"=="1" (
        powercfg -change -monitor-timeout-ac 5
        powercfg -change -standby-timeout-ac 10
        echo Set: Screen=5min, Sleep=10min
        call :SILENT_BACKUP
    ) else if "!choice!"=="2" (
        powercfg -change -monitor-timeout-ac 5
        powercfg -change -standby-timeout-ac 0
        echo Set: Screen=5min, Sleep=Never
        call :SILENT_BACKUP
    ) else if "!choice!"=="3" (
        powercfg -change -monitor-timeout-ac 0
        powercfg -change -standby-timeout-ac 0
        echo Set: Never timeout, Never sleep
        call :SILENT_BACKUP
    )
) else (
    if "!choice!"=="1" (
        powercfg -change -monitor-timeout-dc 2
        powercfg -change -standby-timeout-dc 3
        echo Set: Screen=2min, Sleep=3min
        call :SILENT_BACKUP
    ) else if "!choice!"=="2" (
        powercfg -change -monitor-timeout-dc 2
        powercfg -change -standby-timeout-dc 0
        echo Set: Screen=2min, Sleep=Never
        call :SILENT_BACKUP
    ) else if "!choice!"=="3" (
        powercfg -change -monitor-timeout-dc 0
        powercfg -change -standby-timeout-dc 0
        echo Set: Never timeout, Never sleep
        call :SILENT_BACKUP
    )
)

timeout /t 2 >nul
goto MAIN_LOOP

:SILENT_BACKUP
:: Create silent backup in script's location (overwrites existing)
powercfg /q > "%scriptdir%\powercfg_%mode%_backup.txt" 2>nul
goto :eof

:CUSTOM_SETTINGS
echo.
echo Enter custom !mode! settings (0=Never, 1-999=Minutes)
echo.

:GET_SCREEN
set "scr="
set /p "scr=Screen timeout (0-999): "
echo !scr!|findstr /r "^[0-9][0-9]*$" >nul || (
    echo Invalid. Numbers only.
    goto GET_SCREEN
)
if !scr! gtr 999 (
    echo Maximum is 999 minutes
    goto GET_SCREEN
)

:GET_SLEEP
set "slp="
set /p "slp=Sleep timeout (0-999): "
echo !slp!|findstr /r "^[0-9][0-9]*$" >nul || (
    echo Invalid.