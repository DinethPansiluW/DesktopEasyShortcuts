@echo off
schtasks /Create /TN "DisableWiFiAt7AM" /TR "\"%~dp0disable_wifi.bat\"" /SC DAILY /ST 07:00 /RL HIGHEST /F
