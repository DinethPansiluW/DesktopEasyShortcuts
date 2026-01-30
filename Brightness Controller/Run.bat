@echo off
setlocal EnableDelayedExpansion

set STATE=%~dp0brightness_state.txt

:: Create state file if missing
if not exist "%STATE%" (
    echo 100>"%STATE%"
)

set /p LAST=<"%STATE%"

if "%LAST%"=="100" (
    powershell -command "(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1,0)"
    echo 0>"%STATE%"
    echo Brightness set to 0%%
) else (
    powershell -command "(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1,100)"
    echo 100>"%STATE%"
    echo Brightness set to 100%%
)

exit
