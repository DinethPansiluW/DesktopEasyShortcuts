@echo off
:: Launch silently as administrator
powershell -WindowStyle Hidden -Command "Start-Process '%~dp0run.exe' -Verb RunAs"
exit
