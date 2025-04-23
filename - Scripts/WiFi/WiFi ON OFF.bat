@echo off
netsh interface show interface name="Wi-Fi" | findstr /C:"Connected" >nul
if %errorlevel%==0 (
    start "" "WiFi OFF.lnk"
) else (
    start "" "WiFi ON.lnk"
)
exit
