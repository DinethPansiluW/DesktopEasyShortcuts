@echo off
:: Enable ANSI escape sequences on Windows 10+ (optional)
reg query HKCU\Console | findstr VirtualTerminalLevel >nul 2>&1
if errorlevel 1 (
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul
    cls
)

:: Set ANSI color escape codes
set "ESC="
set "GREEN=%ESC%[1;32m"
set "GREENU=%ESC%[3;32m"
set "RED=%ESC%[91m"
set "ORANGE=%ESC%[33m"
set "RESET=%ESC%[0m"
set "PINK=%ESC%[3;35m"
set "SKYBLUE=%ESC%[96m"

:: Load saved Wi-Fi name if exists
set "WiFiNameFile=%~dp0wifi_name.txt"
if exist "%WiFiNameFile%" (
    set /p "SavedWiFiName="<"%WiFiNameFile%"
) else (
    set "SavedWiFiName=Not Set"
)

cls
echo.
echo %GREEN%Welcome to the Wi-Fi Toggle Script%RESET%
echo.
echo Current Saved Wi-Fi Name: %SKYBLUE%%SavedWiFiName%%RESET%
echo.

:wificonfirm
set /p "wificonfirm=%ORANGE%Do you want to change or set the Wi-Fi name? (y/n): %GREEN%"
if /I "%wificonfirm%"=="y" goto input
if /I "%wificonfirm%"=="n" goto createonwifi
echo %RESET%Invalid input. Please type 'y' or 'n'.
goto wificonfirm

:input
cls
echo.
echo.
echo %GREEN%This script is 100%% safe and will help make your work easier.%RESET%
echo.
echo --------------%RED% ! IMPORTANT ! %RESET%--------------
echo %SKYBLUE%The script is 100%% safe and does not use your Wi-Fi or any of its resources.%RESET%
echo.
set /p "WiFiName=Enter WiFi Name (SSID): %GREEN%"
echo.
echo %RESET%You entered: %GREENU%"%WiFiName%"%RESET%
goto confirm

:confirm
set /p "confirm=Is this correct? (y/n): %RED%"
if /I "%confirm%"=="y" goto create
if /I "%confirm%"=="n" goto input
echo %RESET%Invalid input. Please type 'y' or 'n'.
goto confirm

:createonwifi
exit

:create
:: Save WiFi name to file
echo %WiFiName%>"%WiFiNameFile%"

echo.
echo %GREEN%Wi-Fi On OFF Script Created successfully
echo.
echo %RESET%Wait...
timeout /t 3 >nul
echo.
echo %SKYBLUE%Done
timeout /t 1 >nul


(
    echo @echo off
    echo set "WiFiName=%WiFiName%"
    echo.
    echo netsh interface show interface name^="Wi-Fi" ^| findstr /C:"Connected" ^>nul
    echo if %%errorlevel%%==0 ^(
    echo     netsh wlan disconnect
    echo ^) else ^(
    echo     netsh wlan connect name^="%%WiFiName%%"
    echo ^)
    echo exit
)>"%~dp0Run.bat"
goto :EOF

echo.
echo %ORANGE%Press any key to continue...
pause >nul
exit /b
