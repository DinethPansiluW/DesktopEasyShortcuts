@echo off
setlocal

:: Check for admin rights
>nul 2>&1 net session
if %errorLevel% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~f0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)

:: Full path to RestoreTimes.bat (update if it's not in the same folder)
set "RestoreScript=%~dp0RestoreTimes.bat"

:: Task name
set "TaskName=RestoreTimesAtStartup"

:: Create scheduled task to run at system startup
schtasks /create ^
  /tn "%TaskName%" ^
  /tr "\"%RestoreScript%\"" ^
  /sc onstart ^
  /ru "SYSTEM" ^
  /RL HIGHEST ^
  /F

echo Task "%TaskName%" has been created to run RestoreTimes.bat at startup.
exit
