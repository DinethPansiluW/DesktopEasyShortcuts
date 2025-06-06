@echo off
setlocal enabledelayedexpansion

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)


:: Colors
set "GREEN=[1;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[1;35m"
set "SKYBLUE=[96m"

echo.
echo %SKYBLUE%Sleep, Hibernate, Hard Disk and Screen OFF timeouts set to %PINK%Never%RESET%.
echo.

:: GUIDs
set "GUID_HIBERNATE=9d7815a6-7ee4-497e-8888-515a05f02364"
set "GUID_SLEEP=29f6c1db-86da-48c5-9fdb-f2b67b1f44da"
set "GUID_DISPLAY=3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"
set "SUB_DISPLAY=7516b95f-f776-4464-8c53-06167f40cc99"

set "BACKUP_FILE=%~dp0power_settings_backup.txt"

:: --- BACKUP original values ---
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT %SUB_DISPLAY% %GUID_DISPLAY% ^| findstr /C:"Current AC Power Setting Index"') do set "DISP_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT %SUB_DISPLAY% %GUID_DISPLAY% ^| findstr /C:"Current DC Power Setting Index"') do set "DISP_DC_SECS=%%A"
if "!DISP_AC_SECS!"=="0" (set "ac_scr_display=Never") else (set /a TMP=!DISP_AC_SECS!/60 & set "ac_scr_display=!TMP! min")
if "!DISP_DC_SECS!"=="0" (set "battery_scr_display=Never") else (set /a TMP=!DISP_DC_SECS!/60 & set "battery_scr_display=!TMP! min")

for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_SLEEP% ^| findstr "Current AC Power Setting Index"') do set "SLEEP_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_SLEEP% ^| findstr "Current DC Power Setting Index"') do set "SLEEP_DC_SECS=%%A"
if "!SLEEP_AC_SECS!"=="0" (set "ac_slp_display=Never") else (set /a TMP=!SLEEP_AC_SECS!/60 & set "ac_slp_display=!TMP! min")
if "!SLEEP_DC_SECS!"=="0" (set "battery_slp_display=Never") else (set /a TMP=!SLEEP_DC_SECS!/60 & set "battery_slp_display=!TMP! min")

for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr "Current AC Power Setting Index"') do set "AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr "Current DC Power Setting Index"') do set "DC_SECS=%%A"
if "!AC_SECS!"=="0" (set "ac_hib_display=Never") else (set /a TMP=!AC_SECS!/60 & set "ac_hib_display=!TMP! min")
if "!DC_SECS!"=="0" (set "battery_hib_display=Never") else (set /a TMP=!DC_SECS!/60 & set "battery_hib_display=!TMP! min")

for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_DISK 6738e2c4-e8a5-4a42-b16a-e040e769756e ^| findstr "Current AC Power Setting Index"') do set "HD_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_DISK 6738e2c4-e8a5-4a42-b16a-e040e769756e ^| findstr "Current DC Power Setting Index"') do set "HD_DC_SECS=%%A"
if "!HD_AC_SECS!"=="0" (set "ac_hd_display=Never") else (set /a TMP=!HD_AC_SECS!/60 & set "ac_hd_display=!TMP! min")
if "!HD_DC_SECS!"=="0" (set "battery_hd_display=Never") else (set /a TMP=!HD_DC_SECS!/60 & set "battery_hd_display=!TMP! min")

(
 echo Mode=AC
 echo Screen=%ac_scr_display%
 echo Sleep=%ac_slp_display%
 echo Hibernate=%ac_hib_display%
 echo HardDisk=%ac_hd_display%
 echo.
 echo Mode=BATTERY
 echo Screen=%battery_scr_display%
 echo Sleep=%battery_slp_display%
 echo Hibernate=%battery_hib_display%
 echo HardDisk=%battery_hd_display%
) > "%BACKUP_FILE%"


:: --- SET all timeouts to Never ---
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0

:WAIT_FOR_R
echo.
set /p key=%GREEN%Press %ORANGE%[R] %GREEN%to restore power timeout settings:%RESET%
if /i "%key%"=="R" (
    goto RESTORE
) else (
    echo Invalid input.
    goto WAIT_FOR_R
)

:RESTORE
set "BACKUP_FILE=%~dp0power_settings_backup.txt"
if not exist "%BACKUP_FILE%" (
    echo ERROR: Backup not found.
    timeout /t 2 >nul
    exit /b
)
set "TEMPENV=%temp%\restore_env.cmd"
> "%TEMPENV%" echo @echo off
set cnt=0
for /f "tokens=1,2 delims==" %%A in ('findstr /i "^Screen= ^Sleep= ^Hibernate= ^HardDisk=" "%BACKUP_FILE%"') do (
    set /a cnt+=1
    set "raw=%%B"
    if /i "!raw!"=="Never" (set "val=0") else (for /f "tokens=1" %%X in ("!raw!") do set "val=%%X")
    if !cnt! leq 4 (echo set ac_%%A=!val!>>"%TEMPENV%") else (echo set dc_%%A=!val!>>"%TEMPENV%")
)
call "%TEMPENV%"
del "%TEMPENV%"
endlocal & (
 set ac_scr=%ac_Screen% & set ac_slp=%ac_Sleep%
 set ac_hib=%ac_Hibernate% & set ac_hd=%ac_HardDisk%
 set dc_scr=%dc_Screen% & set dc_slp=%dc_Sleep%
 set dc_hib=%dc_Hibernate% & set dc_hd=%dc_HardDisk%
)
powercfg /change monitor-timeout-ac %ac_scr%
powercfg /change monitor-timeout-dc %dc_scr%
powercfg /change standby-timeout-ac %ac_slp%
powercfg /change standby-timeout-dc %dc_slp%
powercfg /change hibernate-timeout-ac %ac_hib%
powercfg /change hibernate-timeout-dc %dc_hib%
powercfg /change disk-timeout-ac %ac_hd%
powercfg /change disk-timeout-dc %dc_hd%
echo %ORANGE%Settings restored.
timeout /t 1 >nul
exit /b
