@echo off
setlocal enabledelayedexpansion

:: GUIDs for power settings
set "GUID_HIBERNATE=9d7815a6-7ee4-497e-8888-515a05f02364"
set "GUID_SLEEP=29f6c1db-86da-48c5-9fdb-f2b67b1f44da"
set "GUID_DISPLAY=3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"
set "SUB_DISPLAY=7516b95f-f776-4464-8c53-06167f40cc99"

:: Backup file paths
set "BACKUP_FILE=%~dp0power_settings_backup.txt"

:: --- BACKUP POWER SETTINGS START ---

:: Screen timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT %SUB_DISPLAY% %GUID_DISPLAY% ^| findstr /C:"Current AC Power Setting Index"') do set "DISP_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT %SUB_DISPLAY% %GUID_DISPLAY% ^| findstr /C:"Current DC Power Setting Index"') do set "DISP_DC_SECS=%%A"
set /a DISP_AC_DEC=%DISP_AC_SECS%
set /a DISP_DC_DEC=%DISP_DC_SECS%
if "!DISP_AC_DEC!"=="0" (set "ac_scr_display=Never") else (set /a TMP=!DISP_AC_DEC!/60 & set "ac_scr_display=!TMP! min")
if "!DISP_DC_DEC!"=="0" (set "battery_scr_display=Never") else (set /a TMP=!DISP_DC_DEC!/60 & set "battery_scr_display=!TMP! min")

:: Sleep timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_SLEEP% ^| findstr /C:"Current AC Power Setting Index"') do set "SLEEP_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_SLEEP% ^| findstr /C:"Current DC Power Setting Index"') do set "SLEEP_DC_SECS=%%A"
set /a SLEEP_AC_DEC=%SLEEP_AC_SECS%
set /a SLEEP_DC_DEC=%SLEEP_DC_SECS%
if "!SLEEP_AC_DEC!"=="0" (set "ac_slp_display=Never") else (set /a TMP=!SLEEP_AC_DEC!/60 & set "ac_slp_display=!TMP! min")
if "!SLEEP_DC_DEC!"=="0" (set "battery_slp_display=Never") else (set /a TMP=!SLEEP_DC_DEC!/60 & set "battery_slp_display=!TMP! min")

:: Hibernate timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr /C:"Current AC Power Setting Index"') do set "AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr /C:"Current DC Power Setting Index"') do set "DC_SECS=%%A"
set /a AC_DEC=%AC_SECS%
set /a DC_DEC=%DC_SECS%
if "!AC_DEC!"=="0" (set "ac_hib_display=Never") else (set /a TMP=!AC_DEC!/60 & set "ac_hib_display=!TMP! min")
if "!DC_DEC!"=="0" (set "battery_hib_display=Never") else (set /a TMP=!DC_DEC!/60 & set "battery_hib_display=!TMP! min")

:: Hard Disk OFF timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_DISK 6738e2c4-e8a5-4a42-b16a-e040e769756e ^| findstr /C:"Current AC Power Setting Index"') do set "HD_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_DISK 6738e2c4-e8a5-4a42-b16a-e040e769756e ^| findstr /C:"Current DC Power Setting Index"') do set "HD_DC_SECS=%%A"
set /a HD_AC_DEC=%HD_AC_SECS%
set /a HD_DC_DEC=%HD_DC_SECS%
if "!HD_AC_DEC!"=="0" (set "ac_hd_display=Never") else (set /a TMP=!HD_AC_DEC!/60 & set "ac_hd_display=!TMP! min")
if "!HD_DC_DEC!"=="0" (set "battery_hd_display=Never") else (set /a TMP=!HD_DC_DEC!/60 & set "battery_hd_display=!TMP! min")

call :RESTORE_FROM_BACKUP

REM Rest of your script or exit
exit /b

:RESTORE_FROM_BACKUP
REM --- Paths
set "BACKUP_FILE=%~dp0power_settings_backup.txt"
set "TEMPENV=%temp%\restore_env.cmd"

REM --- Check backup exists
if not exist "%BACKUP_FILE%" (
    echo ERROR: No backup file at "%BACKUP_FILE%"
    timeout /t 2 >nul
    exit /b
)

REM --- Create temp env file
> "%TEMPENV%" echo @echo off
set cnt=0

REM --- Read and split into AC (first 4) and DC (next 4)
for /f "tokens=1,2 delims==" %%A in ('findstr /i /b "Screen= Sleep= Hibernate= HardDisk=" "%BACKUP_FILE%"') do (
    set /a cnt+=1
    set "raw=%%B"
    REM normalize Never -> 0, strip " min"
    if /i "!raw!"=="Never" (
        set "val=0"
    ) else (
        for /f "tokens=1 delims= " %%X in ("!raw!") do set "val=%%X"
    )
    REM decide AC vs DC
    if !cnt! leq 4 (
        echo set ac_%%A=!val!>> "%TEMPENV%"
    ) else (
        echo set dc_%%A=!val!>> "%TEMPENV%"
    )
)

REM --- Load variables
call "%TEMPENV%"
del "%TEMPENV%"
endlocal & (
    set "ac_scr=%ac_Screen%"
    set "ac_slp=%ac_Sleep%"
    set "ac_hib=%ac_Hibernate%"
    set "ac_hd=%ac_HardDisk%"
    set "dc_scr=%dc_Screen%"
    set "dc_slp=%dc_Sleep%"
    set "dc_hib=%dc_Hibernate%"
    set "dc_hd=%dc_HardDisk%"
)

REM --- Apply settings AC then DC
powercfg -change -monitor-timeout-ac %ac_scr%
powercfg -change -standby-timeout-ac %ac_slp%
powercfg -change -hibernate-timeout-ac %ac_hib%
powercfg -change -disk-timeout-ac %ac_hd%

powercfg -change -monitor-timeout-dc %dc_scr%
powercfg -change -standby-timeout-dc %dc_slp%
powercfg -change -hibernate-timeout-dc %dc_hib%
powercfg -change -disk-timeout-dc %dc_hd%


start "" /min cmd /c "RemoveTaskScheduler.bat"

timeout /t 2 >nul
exit /b

