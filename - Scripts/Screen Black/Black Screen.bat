@echo off

:: Change directory to where the batch file is located
cd /d "%~dp0"

:: Check if the Add Task Scheduler.vbs exists
dir "..\Sleep Screen Timer"

:: Run the VBScript and handle any potential errors
cscript //nologo "..\Sleep Screen Timer\Add Task Scheduler.vbs"
echo VBScript executed with error code %errorlevel%

if %errorlevel% neq 0 (
    echo VBScript failed with error code %errorlevel%
    exit /b %errorlevel%
)

:: Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0Black Screen.ps1"
if %errorlevel% neq 0 (
    echo PowerShell script failed with error code %errorlevel%
    exit /b %errorlevel%
)

:: Exit the batch script
exit
