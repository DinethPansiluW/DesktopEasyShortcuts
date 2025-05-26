@echo off
setlocal enableextensions disabledelayedexpansion

:: Nuclear elevation method using PowerShell
whoami /groups | findstr /b /c:"Mandatory Label\High Mandatory Level" >nul
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit /b
)

:: Force 64-bit context detection
if exist "%windir%\Sysnative\reg.exe" (
    set "REGEXE=%windir%\Sysnative\reg.exe"
    set "SCTOOL=%windir%\Sysnative\sc.exe"
) else (
    set "REGEXE=reg.exe"
    set "SCTOOL=sc.exe"
)

set "KEY=HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection"

:main
cls
call :show_status
echo.
echo 1. Enable Defender
echo 2. Disable Defender (permanent)
echo 3. Disable Defender (until restart)
echo 4. Exit
echo.
set /p choice=Choose [1-4]:

if "%choice%"=="1" goto enable
if "%choice%"=="2" goto disable_perm
if "%choice%"=="3" goto disable_temp
if "%choice%"=="4" exit /b

echo Invalid choice.
pause>nul
goto main

:show_status
set "svc=Unknown"
for /f "tokens=3" %%A in ('"%SCTOOL%" query WinDefend ^| findstr /i "STATE"') do (
    if /i "%%A"=="RUNNING" (set "svc=Running") else (set "svc=Stopped")
)

set "rtp=Enabled"
for /f "tokens=3" %%B in ('"%REGEXE%" query "%KEY%" /v DisableRealtimeMonitoring 2^>nul') do (
    if %%B NEQ 0x0 (set "rtp=Disabled")
)
echo Service State       : %svc%
echo Real-Time Protection: %rtp%
goto :eof

:disable_perm
call :take_ownership
echo Disabling permanently...
"%REGEXE%" add "%KEY%" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f 2>&1 | findstr /i "error" && (
    echo [ERROR] Registry update failed. Possible causes:
    echo - Group Policy override
    echo - Antivirus interference
    call :check_group_policy
    pause
    goto main
)

"%SCTOOL%" stop WinDefend 2>&1 | findstr /i "failed" && (
    echo [ERROR] Failed to stop service. Trying force stop...
    taskkill /F /IM MsMpEng.exe /T >nul 2>&1
    timeout /t 2 /nobreak >nul
)

"%SCTOOL%" config WinDefend start= disabled 2>&1 | findstr /i "error" && (
    echo [ERROR] Failed to disable service. Trying registry method...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v Start /t REG_DWORD /d 4 /f
)
echo Done. Reboot to apply permanent changes.
pause>nul
goto main

:disable_temp
call :take_ownership
echo Disabling until restart...
"%REGEXE%" add "%KEY%" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f || (
    echo [ERROR] Registry update failed
    pause
    goto main
)

taskkill /F /IM MsMpEng.exe /T >nul 2>&1
"%SCTOOL%" config WinDefend start= demand
echo Done. Protection disabled until next reboot.
pause>nul
goto main

:enable
call :take_ownership
echo Enabling Defender...
"%REGEXE%" add "%KEY%" /v DisableRealtimeMonitoring /t REG_DWORD /d 0 /f || (
    echo [ERROR] Registry update failed
    pause
    goto main
)

"%SCTOOL%" config WinDefend start= auto
"%SCTOOL%" start WinDefend || (
    echo [WARNING] Service start failed. Trying manual start...
    net start WinDefend
)
echo Done. Check if real-time protection activates.
pause>nul
goto main

:take_ownership
:: Nuclear permission reset
echo Acquiring registry ownership...
takeown /f "%windir%\System32\MsMpEng.exe" >nul 2>&1
icacls "%windir%\System32\MsMpEng.exe" /grant Administrators:F >nul 2>&1

reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1

takeown /f "%KEY%" /a >nul 2>&1
icacls "%KEY%" /grant Administrators:F /t /c >nul 2>&1
goto :eof

:check_group_policy
echo Checking Group Policy override...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableRealtimeMonitoring 2>nul && (
    echo [CRITICAL] Group Policy override detected!
    echo You must edit Group Policy (gpedit.msc) at:
    echo Computer Configuration -> Administrative Templates
    echo -> Windows Components -> Windows Defender Antivirus
    echo -> Turn off real-time protection
)
goto :eof