@echo off
setlocal enabledelayedexpansion

:: Set ANSI color escape codes
set "GREEN=[32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[1;35m"

:: Admin check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %GREEN%ERROR: Must run as Administrator!%RESET%
    pause
    exit /b 1
)

:: Enable ANSI escape codes
reg query HKCU\Console /v VirtualTerminalLevel 2>nul | find "0x1" >nul || (
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)

:: Get ESC
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

:: default to AC mode on load
if not defined mode set "mode=AC"

:: Elevate if needed
NET FILE 1>nul 2>nul || (
    powershell -Command "Start-Process cmd -ArgumentList '/c "%~f0"' -Verb RunAs"
    exit /b
)

:: GUIDs for power settings
set "GUID_HIBERNATE=9d7815a6-7ee4-497e-8888-515a05f02364"
set "GUID_SLEEP=29f6c1db-86da-48c5-9fdb-f2b67b1f44da"
set "GUID_DISPLAY=3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"
set "SUB_DISPLAY=7516b95f-f776-4464-8c53-06167f40cc99"

:: Backup file paths
set "BACKUP_FILE=%~dp0power_settings_backup.txt"
set "RECOMMEND_BACKUP_FILE=%~dp0recommended_presets_backup.txt"

:: Initialize recommended presets
set "balanced_scr=10"
set "balanced_slp=15"
set "balanced_hib=60"
set "battery_scr=5"
set "battery_slp=10"
set "battery_hib=30"

:: Load recommended presets from backup if exists
if exist "%RECOMMEND_BACKUP_FILE%" (
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "balanced_scr" "%RECOMMEND_BACKUP_FILE%"') do set "balanced_scr=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "balanced_slp" "%RECOMMEND_BACKUP_FILE%"') do set "balanced_slp=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "balanced_hib" "%RECOMMEND_BACKUP_FILE%"') do set "balanced_hib=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "battery_scr" "%RECOMMEND_BACKUP_FILE%"') do set "battery_scr=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "battery_slp" "%RECOMMEND_BACKUP_FILE%"') do set "battery_slp=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "battery_hib" "%RECOMMEND_BACKUP_FILE%"') do set "battery_hib=%%B"
)

:MAIN_LOOP
call :LOAD_SETTINGS
cls
:: Center header
set "width=80"
set /a "spaces=(width - 23) / 2"
set "spacer="
for /l %%i in (1,1,!spaces!) do set "spacer=!spacer! "

echo %GREEN%!spacer!=========== SUPER POWER SETTINGS MANAGER ===========%RESET%

echo.
echo !spacer!                    %RED%Mode: %ORANGE%!mode!%RESET%
echo.
echo !spacer!          %GREEN%AC             %RESET%^|           %GREEN%BATTERY%RESET%

echo !spacer!Screen OFF - %ORANGE%!ac_scr_display!%RESET%      ^|     Screen OFF - %ORANGE%!battery_scr_display!%RESET%
echo !spacer!Sleep      - %ORANGE%!ac_slp_display!%RESET%      ^|     Sleep      - %ORANGE%!battery_slp_display!%RESET%
echo.
echo !spacer!Hibernate  - %ORANGE%!ac_hib_display!%RESET%      ^|     Hibernate  - %ORANGE%!battery_hib_display!%RESET%

echo.
echo !spacer!===================================================

echo.
if /i "%mode%"=="AC" (
    echo 1. Recommended Settings ^(Screen %ORANGE%!balanced_scr!%RESET%m, Sleep %ORANGE%!balanced_slp!%RESET%m, Hibernate %ORANGE%!balanced_hib!%RESET%m^)
) else (
    echo 1. Recommended Settings ^(Screen %ORANGE%!battery_scr!%RESET%m, Sleep %ORANGE%!battery_slp!%RESET%m, Hibernate %ORANGE%!battery_hib!%RESET%m^)
)

echo 2. Never (Screen OFF, Sleep, Hibernate)
echo 3. Change Screen OFF time only
echo 4. Change Sleep time only
echo 5. Custom Settings All
echo 6. Switch Mode (AC/Battery)
echo.
echo %GREEN%7. Backup Times
echo 8. Restore Settings from Backup
echo 9. Info Backup
echo %PINK%A. Go to Hibernate Manager
echo B. Go to Hybrid Sleep Manager
echo %RESET%0. Change Recommended Times (Current Mode)

echo.
set /p "choice=%RESET%Enter choice: %ORANGE%"

:: Handle menu
if "%choice%"=="1" call :APPLY_RECOMMENDED
if "%choice%"=="2" set "scr=0" & set "slp=0" & set "hib=0" & goto APPLY
if "%choice%"=="3" call :CHANGE_SCREEN_ONLY
if "%choice%"=="4" call :CHANGE_SLEEP_ONLY
if "%choice%"=="5" call :CUSTOM_SETTINGS & goto APPLY
if "%choice%"=="6" (if /i "%mode%"=="AC" (set "mode=BATTERY") else (set "mode=AC")) & goto MAIN_LOOP
if "%choice%"=="7" (call :BACKUP_TIMES & call :BACKUP_TIMES_POW & goto MAIN_LOOP)
if "%choice%"=="8" call :RESTORE_FROM_BACKUP & goto MAIN_LOOP
if "%choice%"=="9" call :INFO_BACKUP & pause & goto MAIN_LOOP
if /i "%choice%"=="a" call Hybernate.bat
if /i "%choice%"=="b" call HybridSleep.bat
if "%choice%"=="0" call :CHANGE_PRESETS & goto MAIN_LOOP

goto MAIN_LOOP

:APPLY_RECOMMENDED
if /i "%mode%"=="AC" (
    set "scr=!balanced_scr!" & set "slp=!balanced_slp!" & set "hib=!balanced_hib!"
) else (
    set "scr=!battery_scr!" & set "slp=!battery_slp!" & set "hib=!battery_hib!"
)
goto APPLY

:APPLY
:: Apply power settings
if /i "%mode%"=="AC" (
    powercfg -change -monitor-timeout-ac %scr%
    powercfg -change -standby-timeout-ac %slp%
    powercfg -change -hibernate-timeout-ac %hib%
) else (
    powercfg -change -monitor-timeout-dc %scr%
    powercfg -change -standby-timeout-dc %slp%
    powercfg -change -hibernate-timeout-dc %hib%
)
timeout /t 2 >nul
goto MAIN_LOOP

:CHANGE_PRESETS
echo.
echo %GREEN%Change Recommended Times for %mode% Mode%RESET%
echo.
if /i "%mode%"=="AC" (
    echo AC Mode (Balanced)
    set /p "balanced_scr=New Screen timeout (current: %balanced_scr%m): "
    set /p "balanced_slp=New Sleep timeout (current: %balanced_slp%m): "
    set /p "balanced_hib=New Hibernate timeout (current: %balanced_hib%m): "
) else (
    echo Battery Mode (Power Saver)
    set /p "battery_scr=New Screen timeout (current: %battery_scr%m): "
    set /p "battery_slp=New Sleep timeout (current: %battery_slp%m): "
    set /p "battery_hib=New Hibernate timeout (current: %battery_hib%m): "
)
:: Save all presets to backup
(
    echo balanced_scr=%balanced_scr%
    echo balanced_slp=%balanced_slp%
    echo balanced_hib=%balanced_hib%
    echo battery_scr=%battery_scr%
    echo battery_slp=%battery_slp%
    echo battery_hib=%battery_hib%
) > "%RECOMMEND_BACKUP_FILE%"
echo Recommended times for %mode% updated and backed up!
timeout /t 2 >nul
exit /b

:CHANGE_SCREEN_ONLY
echo.
echo %GREEN%Changing Screen OFF Time Only%RESET%
echo.
set /p "new_scr=Enter new Screen OFF time in minutes (0 for Never): "
if /i "%mode%"=="AC" (
    powercfg -change -monitor-timeout-ac %new_scr%
) else (
    powercfg -change -monitor-timeout-dc %new_scr%
)
goto MAIN_LOOP

:CHANGE_SLEEP_ONLY
echo.
echo %GREEN%Changing Sleep Time Only%RESET%
echo.
set /p "new_slp=Enter new Sleep time in minutes (0 for Never): "
if /i "%mode%"=="AC" (
    powercfg -change -standby-timeout-ac %new_slp%
) else (
    powercfg -change -standby-timeout-dc %new_slp%
)
goto MAIN_LOOP

:CUSTOM_SETTINGS
echo.
echo %GREEN%Custom Settings%RESET%
set /p "scr=Enter Screen OFF in minutes: "
set /p "slp=Enter Sleep timeout in minutes: "
set /p "hib=Enter Hibernate timeout in minutes: "
exit /b

:LOAD_SETTINGS
:: Read and convert current AC/DC display timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT %SUB_DISPLAY% %GUID_DISPLAY% ^| findstr /C:"Current AC Power Setting Index"') do set "DISP_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT %SUB_DISPLAY% %GUID_DISPLAY% ^| findstr /C:"Current DC Power Setting Index"') do set "DISP_DC_SECS=%%A"
set /a DISP_AC_DEC=%DISP_AC_SECS%
set /a DISP_DC_DEC=%DISP_DC_SECS%
if "!DISP_AC_DEC!"=="0" (set "ac_scr_display=Never") else (set /a TMP=!DISP_AC_DEC!/60 & set "ac_scr_display=!TMP! min")
if "!DISP_DC_DEC!"=="0" (set "battery_scr_display=Never") else (set /a TMP=!DISP_DC_DEC!/60 & set "battery_scr_display=!TMP! min")

:: Read and convert current AC/DC sleep timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_SLEEP% ^| findstr /C:"Current AC Power Setting Index"') do set "SLEEP_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_SLEEP% ^| findstr /C:"Current DC Power Setting Index"') do set "SLEEP_DC_SECS=%%A"
set /a SLEEP_AC_DEC=%SLEEP_AC_SECS%
set /a SLEEP_DC_DEC=%SLEEP_DC_SECS%
if "!SLEEP_AC_DEC!"=="0" (set "ac_slp_display=Never") else (set /a TMP=!SLEEP_AC_DEC!/60 & set "ac_slp_display=!TMP! min")
if "!SLEEP_DC_DEC!"=="0" (set "battery_slp_display=Never") else (set /a TMP=!SLEEP_DC_DEC!/60 & set "battery_slp_display=!TMP! min")

:: Read and convert current AC/DC hibernate timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr /C:"Current AC Power Setting Index"') do set "AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr /C:"Current DC Power Setting Index"') do set "DC_SECS=%%A"
set /a AC_DEC=%AC_SECS%
set /a DC_DEC=%DC_SECS%
if "!AC_DEC!"=="0" (set "ac_hib_display=Never") else (set /a TMP=!AC_DEC!/60 & set "ac_hib_display=!TMP! min")
if "!DC_DEC!"=="0" (set "battery_hib_display=Never") else (set /a TMP=!DC_DEC!/60 & set "battery_hib_display=!TMP! min")

goto :eof

:BACKUP_TIMES
:: Backup current actual settings to BACKUP_FILE
echo Mode=AC > "%BACKUP_FILE%"
echo Screen=%ac_scr_display% >> "%BACKUP_FILE%"
echo Sleep=%ac_slp_display% >> "%BACKUP_FILE%"
echo Hibernate=%ac_hib_display% >> "%BACKUP_FILE%"
echo. >> "%BACKUP_FILE%"
echo Mode=BATTERY >> "%BACKUP_FILE%"
echo Screen=%battery_scr_display% >> "%BACKUP_FILE%"
echo Sleep=%battery_slp_display% >> "%BACKUP_FILE%"
echo Hibernate=%battery_hib_display% >> "%BACKUP_FILE%"
echo %GREEN%Current settings backed up to %BACKUP_FILE% %RESET%
timeout /t 2 >nul
exit /b

:BACKUP_TIMES_POW
set "POWFILE=%~dp0power_backup.pow"
powercfg /export "%POWFILE%" SCHEME_CURRENT
if %errorlevel% neq 0 (
    echo %RED%ERROR: Failed to export power scheme.%RESET%
) else (
    echo %GREEN%Power scheme exported to %POWFILE% %RESET%
)
timeout /t 2 >nul
exit /b

:RESTORE_FROM_BACKUP
set "POWFILE=%~dp0power_backup.pow"
if not exist "%POWFILE%" (
    echo %RED%ERROR: No backup .pow file found.%RESET%
    timeout /t 2 >nul
    exit /b
)
for /f "tokens=2 delims=:" %%G in ('powercfg /import "%POWFILE%" ^| findstr /i "GUID"') do set "NEWGUID=%%G"
if not defined NEWGUID (
    echo %RED%ERROR: Import failed.%RESET%
    timeout /t 2 >nul
    exit /b
)
set "NEWGUID=%NEWGUID: =%"
powercfg /setactive %NEWGUID%
echo %GREEN%Restored power settings from backup file.%RESET%
timeout /t 2 >nul
goto MAIN_LOOP

:INFO_BACKUP
type "%BACKUP_FILE%" || echo %GREEN%No backup file found%RESET%
goto :eof