@echo off
set WiFiName="Hemis WiFi"

netsh interface show interface name="Wi-Fi" | findstr /C:"Connected" >nul
if %errorlevel%==0 (
    netsh wlan disconnect
) else (
    netsh wlan connect name="Hemis WiFi"
)
exit
