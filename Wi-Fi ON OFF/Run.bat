@echo off
set WiFiName="Dialog 77"

netsh interface show interface name="Wi-Fi" | findstr /C:"Connected" >nul
if %errorlevel%==0 (
    netsh wlan disconnect
) else (
    netsh wlan connect name="Dialog 77"
)
exit
