@echo off
:: Enable ANSI escape sequences on Windows 10+ (optional)
:: You can remove or comment out the following lines if not supported
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

:wificonfirm
echo.
echo.
set /p "wificonfirm=Do you have Wi-Fi? (y/n): %RED%"
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
echo %ORANGE%Enter the correct name of Wi-Fi. If it doesn't work or you want to change it, just run this script again.%RESET%
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
(
  echo @echo off
  echo call "%~dp0WiFiNameChange1.bat"
)>"%~dp0Run.bat"
goto :EOF

:create
(
    echo @echo off
    echo set WiFiName="%WiFiName%"
    echo.
    echo netsh interface show interface name^="Wi-Fi" ^| findstr /C:"Connected" ^>nul
    echo if %%errorlevel%%==0 ^(
    echo     netsh wlan disconnect
    echo ^) else ^(
    echo     netsh wlan connect name^="%WiFiName%"
    echo ^)
    echo exit
)>"%~dp0Run.bat"

echo.
echo %GREEN%Wi-Fi On OFF%RESET% Script Created successfully
goto :EOF

echo.
echo %ORANGE%Press any key to continue...
pause >nul
exit /b
