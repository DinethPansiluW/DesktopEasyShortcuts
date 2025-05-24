@echo off
setlocal enabledelayedexpansion

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "SKYBLUE=[96m"

:: Ensure administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %ORANGE%Requesting administrator privileges...%RESET%
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b
)

:: Initialize mode variable
set "defender_mode="

:main_menu
cls
call :show_status
echo.
echo %GREEN%Windows Defender Control Panel%RESET%
echo ===============================
echo.
echo %GREEN%1.%RESET% Enable Windows Defender
echo %GREEN%2.%RESET% Disable Windows Defender (permanent until manually enabled)
echo %GREEN%3.%RESET% Disable Windows Defender until restart
echo %GREEN%4.%RESET% Exit
echo.
set /p choice=Select option [1-4]: 

if "%choice%"=="1" call :enable_defender
if "%choice%"=="2" call :disable_defender
if "%choice%"=="3" call :disable_until_restart
if "%choice%"=="4" exit
echo %RED%Invalid choice. Try again.%RESET%
pause
goto main_menu

:show_status
set "defender_status=Enabled"
set "defender_mode="

:: Check if Defender service is running
sc query WinDefend | findstr /i "RUNNING" >nul
if errorlevel 1 (
    set "defender_status=Stopped"
)

:: Check if Real-Time Protection is disabled in registry
for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring 2^>nul') do (
    if %%a neq 0x0 set "defender_status=Disabled"
)

:: Check service start mode to detect "disabled until restart" mode
for /f "tokens=3" %%s in ('sc qc WinDefend ^| findstr "START_TYPE"') do (
    if /i "%%s"=="DISABLED" (
        if "!defender_status!"=="Disabled" (
            set "defender_mode=Permanent Disable"
        ) else (
            set "defender_mode=Service Disabled"
        )
    ) else if /i "%%s"=="AUTO_START" (
        if "!defender_status!"=="Disabled" (
            set "defender_mode=Disabled until Restart"
        ) else (
            set "defender_mode=Running"
        )
    )
)

echo %SKYBLUE%Current Windows Defender Status:%RESET%
echo - Service Status: %ORANGE%!defender_status!%RESET%
if defined defender_mode echo - Mode: %ORANGE%!defender_mode!%RESET%
echo.

exit /b

:disable_defender
echo %RED%Disabling Windows Defender Real-Time Protection and Service permanently...%RESET%
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
sc stop WinDefend >nul 2>&1
sc config WinDefend start= disabled >nul 2>&1
echo %RED%Windows Defender Disabled permanently.%RESET%
pause
goto main_menu

:disable_until_restart
echo %ORANGE%Disabling Windows Defender Real-Time Protection and stopping Service until restart...%RESET%
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
sc stop WinDefend >nul 2>&1
sc config WinDefend start= auto >nul 2>&1
echo %ORANGE%Windows Defender Disabled until next restart.%RESET%
pause
goto main_menu

:enable_defender
echo %GREEN%Enabling Windows Defender Real-Time Protection and Service...%RESET%
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 0 /f >nul 2>&1
sc config WinDefend start= auto >nul 2>&1
sc start WinDefend >nul 2>&1
echo %GREEN%Windows Defender Enabled.%RESET%
pause
goto main_menu
