@echo off
set "WiFiName=SLT 4G 5"

netsh interface show interface name="Wi-Fi" | findstr /C:"Connected" >nul
if %errorlevel%==0 (
    netsh wlan disconnect
) else (
    netsh wlan connect name="%WiFiName%"
)
exit
