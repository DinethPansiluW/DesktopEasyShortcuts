@echo off
setlocal enabledelayedexpansion

:: Set green color escape code
set "GREEN=[32m"
set "RESET=[0m"

:: Admin check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %GREEN%ERROR: Must run as Administrator!%RESET%
    pause
    exit /b 1
)

:: Determine mode (AC/Battery)
if "%~1"=="" (set "mode=AC") else (
    set "mode=%~1"
    if /i not "%mode%"=="AC" if /i not "%mode%"=="BATTERY" (
        echo %GREEN%Invalid parameter. Defaulting to AC mode.%RESET%
        set "mode=AC"
    )
)

:: Set script directory
set "scriptdir=%~dp0"
set "scriptdir=%scriptdir:~0,-1%"

:: Initialize default values
set "balanced_scr=5"
set "balanced_slp=10"
set "battery_scr=2"
set "battery_slp=3"

:MAIN_LOOP
:: Reload settings each loop
call :LOAD_SETTINGS

cls
:: Center the header text
set "header=SUPER POWER SETTINGS MANAGER"
set "width=80"
set /a "spaces=(width - 23) / 2"
set "spacer="
for /l %%i in (1,1,%spaces%) do set "spacer=!spacer! "

echo %GREEN%!spacer!========== SUPER POWER SETTINGS MANAGER ==========
echo.
:: Display mode and settings
if /i "%mode%"=="AC" (
    echo !spacer!AC : Current Mode        ^|     BATTERY
) else (
    echo !spacer!AC                       ^|     BATTERY : Current Mode
)

echo !spacer!Screen OFF  - %ac_scr_display% min      ^|     Screen OFF - %battery_scr_display% min
echo !spacer!Sleep       - %ac_slp_display% min     ^|     Sleep      - %battery_slp_display% min
echo.
echo !spacer!==================================================%RESET%
echo.

:: Display presets
if /i "%mode%"=="AC" (
    echo %GREEN%1. Recommended: Screen %balanced_scr%m, Sleep %balanced_slp%m
    echo 2. Screen OFF Never, Sleep Never
    echo 3. Custom Settings%RESET%
) else (
    echo %GREEN%1. Power Saver: Screen %battery_scr%m, Sleep %battery_slp%m
    echo 2. Screen OFF Never, Sleep Never
    echo 3. Custom Settings%RESET%
)

echo.
echo %GREEN%4. Switch Mode (AC/Battery)
echo 5. Restore Settings from Backup
echo 6. Change Recommended Times
echo.
echo 0. Exit%RESET%
echo.

:: Get user choice
set /p "choice=%GREEN%Enter choice (0-6): %RESET%"
if "%choice%"=="0" exit /b 0

if "%choice%"=="4" (
    if /i "%mode%"=="AC" (set "mode=BATTERY") else (set "mode=AC")
    goto MAIN_LOOP
)

if "%choice%"=="6" (call :CHANGE_PRESETS & goto MAIN_LOOP)

:: Apply settings
if /i "%mode%"=="AC" (
    if "%choice%"=="1" (
        set "scr=!balanced_scr!" & set "slp=!balanced_slp!"
    ) else if "%choice%"=="2" (
        set "scr=0" & set "slp=0"
    ) else if "%choice%"=="3" (call :CUSTOM_SETTINGS)
    if "%choice%"=="5" (call :RESTORE_AC)
) else (
    if "%choice%"=="1" (
        set "scr=!battery_scr!" & set "slp=!battery_slp!"
    ) else if "%choice%"=="2" (
        set "scr=0" & set "slp=0"
    ) else if "%choice%"=="3" (call :CUSTOM_SETTINGS)
    if "%choice%"=="5" (call :RESTORE_BATTERY)
)

if "%choice%"=="5" (goto MAIN_LOOP)

:: Apply power settings
if /i "%mode%"=="AC" (
    powercfg -change -monitor-timeout-ac %scr%
    powercfg -change -standby-timeout-ac %slp%
    (
        echo Screen=%scr%
        echo Sleep=%slp%
    ) > "%scriptdir%\AC_settings.txt"
) else (
    powercfg -change -monitor-timeout-dc %scr%
    powercfg -change -standby-timeout-dc %slp%
    (
        echo Screen=%scr%
        echo Sleep=%slp%
    ) > "%scriptdir%\battery_settings.txt"
)

timeout /t 2 >nul
goto MAIN_LOOP

:LOAD_SETTINGS
:: Load settings for both modes
set "ac_scr=5" & set "ac_slp=10"
set "battery_scr=2" & set "battery_slp=3"

if exist "%scriptdir%\AC_settings.txt" (
    for /F "tokens=2 delims==" %%A in ('findstr /i "Screen" "%scriptdir%\AC_settings.txt"') do set "ac_scr=%%A"
    for /F "tokens=2 delims==" %%A in ('findstr /i "Sleep" "%scriptdir%\AC_settings.txt"') do set "ac_slp=%%A"
)

if exist "%scriptdir%\battery_settings.txt" (
    for /F "tokens=2 delims==" %%A in ('findstr /i "Screen" "%scriptdir%\battery_settings.txt"') do set "battery_scr=%%A"
    for /F "tokens=2 delims==" %%A in ('findstr /i "Sleep" "%scriptdir%\battery_settings.txt"') do set "battery_slp=%%A"
)

:: Create display values
set "ac_scr_display=%ac_scr%" & if "%ac_scr%"=="0" set "ac_scr_display=Never"
set "ac_slp_display=%ac_slp%" & if "%ac_slp%"=="0" set "ac_slp_display=Never"
set "battery_scr_display=%battery_scr%" & if "%battery_scr%"=="0" set "battery_scr_display=Never"
set "battery_slp_display=%battery_slp%" & if "%battery_slp%"=="0" set "battery_slp_display=Never"
goto :eof

:CHANGE_PRESETS
echo.
echo %GREEN%Change Recommended Times%RESET%
echo.
echo %GREEN%AC Mode (Balanced)%RESET%
set /p "balanced_scr=New Screen timeout (current: %balanced_scr%m): "
set /p "balanced_slp=New Sleep timeout (current: %balanced_slp%m): "

echo.
echo %GREEN%Battery Mode (Power Saver)%RESET%
set /p "battery_scr=New Screen timeout (current: %battery_scr%m): "
set /p "battery_slp=New Sleep timeout (current: %battery_slp%m): "

echo %GREEN%Recommended times updated!%RESET%
timeout /t 2 >nul
goto :eof

:RESTORE_AC
if exist "%scriptdir%\AC_settings.txt" (
    for /F "tokens=2 delims==" %%A in ('findstr /i "Screen" "%scriptdir%\AC_settings.txt"') do set "scr=%%A"
    for /F "tokens=2 delims==" %%A in ('findstr /i "Sleep" "%scriptdir%\AC_settings.txt"') do set "slp=%%A"
    echo %GREEN%AC settings restored%RESET%
) else echo %GREEN%No AC backup found%RESET%
goto :eof

:RESTORE_BATTERY
if exist "%scriptdir%\battery_settings.txt" (
    for /F "tokens=2 delims==" %%A in ('findstr /i "Screen" "%scriptdir%\battery_settings.txt"') do set "scr=%%A"
    for /F "tokens=2 delims==" %%A in ('findstr /i "Sleep" "%scriptdir%\battery_settings.txt"') do set "slp=%%A"
    echo %GREEN%Battery settings restored%RESET%
) else echo %GREEN%No Battery backup found%RESET%
goto :eof

:CUSTOM_SETTINGS
echo.
echo %GREEN%Enter custom settings for %mode% mode%RESET%
set /p "scr=Screen timeout (minutes, 0=Never): "
set /p "slp=Sleep timeout (minutes, 0=Never): "
if "%scr%"=="" set "scr=0"
if "%slp%"=="" set "slp=0"
goto :eof