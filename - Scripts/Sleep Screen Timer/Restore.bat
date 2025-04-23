@echo off
setlocal enabledelayedexpansion

:: Check for admin rights silently
net session >nul 2>&1 || exit /b 1

:: Get script directory
set "scriptdir=%~dp0"

:: Function to restore settings
call :restore AC
call :restore BATTERY
exit /b 0

:restore
set "mode=%~1"
set "backupfile=%scriptdir%%mode%.txt"

if not exist "%backupfile%" exit /b 1

set "scr=Unknown"
set "slp=Unknown"

for /F "tokens=2 delims==" %%A in ('findstr /i "Screen" "%backupfile%"') do set "scr=%%A"
for /F "tokens=2 delims==" %%A in ('findstr /i "Sleep" "%backupfile%"') do set "slp=%%A"

echo %scr%|findstr /r "^[0-9][0-9]*$" >nul || set "scr=5"
echo %slp%|findstr /r "^[0-9][0-9]*$" >nul || set "slp=10"

if /i "%mode%"=="AC" (
    powercfg -change -monitor-timeout-ac %scr%
    powercfg -change -standby-timeout-ac %slp%
) else (
    powercfg -change -monitor-timeout-dc %scr%
    powercfg -change -standby-timeout-dc %slp%
)



exit /b 0
