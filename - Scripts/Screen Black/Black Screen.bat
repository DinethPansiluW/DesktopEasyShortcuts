@echo off

:: Change directory to where the batch file is located
cd /d "%~dp0" >NUL 2>&1

:: Run the PowerShell script without showing a window
start "" /B powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0Black Screen.ps1" >NUL 2>&1

:: Exit the batch script
exit /b 0