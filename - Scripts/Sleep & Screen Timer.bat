@echo off
title Screen Timeout and Sleep Control (AC Power Only)
color 0A

:menu
cls
echo Screen Timeout and Sleep Control (AC Power Only)
echo ================================================
echo 1. Screen Timeout: 5 min, Sleep: 10 min (AC)
echo 2. Screen Timeout only - no sleep (AC)
echo 3. Never time out, never sleep (AC)
echo 4. Custom settings (AC)
echo Q. Quit
echo.

choice /c 1234Q /n /m "Select option: "
if errorlevel 5 exit /b
if errorlevel 4 goto option4
if errorlevel 3 goto option3
if errorlevel 2 goto option2
if errorlevel 1 goto option1

:option1
powercfg /change monitor-timeout-ac 300
powercfg /change standby-timeout-ac 600
exit /b

:option2
powercfg /change monitor-timeout-ac 300
powercfg /change standby-timeout-ac 0
exit /b

:option3
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0
exit /b

:option4
cls
set /p screenInput=Enter screen timeout in minutes (0 for never): 
set /p sleepInput=Enter sleep timeout in minutes (0 for never): 

set /a screenTimeout=%screenInput%*60
set /a sleepTimeout=%sleepInput%*60

powercfg /change monitor-timeout-ac %screenTimeout%
powercfg /change standby-timeout-ac %sleepTimeout%

echo Settings applied. Press any key to exit...
pause >nul
exit /b