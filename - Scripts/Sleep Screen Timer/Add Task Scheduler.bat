@echo off
:: Request admin rights
NET FILE >NUL 2>&1 || (
    powershell -Command "Start-Process '%~0' -Verb RunAs" >NUL 2>&1
    exit /b
)

:: Check if Restore.vbs exists
if not exist "%~dp0Restore.vbs" (
    echo Error: Restore.vbs file not found in the script's directory.
    pause
    exit /b
)

:: Create self-deleting startup task
schtasks /Create /TN "OneTimeRestore" /TR "cmd /c wscript.exe \"%~dp0Restore.vbs\" && schtasks /Delete /TN \"OneTimeRestore\" /F" /SC ONSTART /RL HIGHEST /F >NUL 2>&1

:: Verify task creation
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to create the scheduled task.
    pause
    exit /b
)

echo Task created successfully.
exit