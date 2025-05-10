@echo off
setlocal ENABLEDELAYEDEXPANSION

REM === Color definitions ===
set "GREEN=[92m"
set "RED=[91m"
set "ORANGE=[93m"
set "RESET=[0m"
set "PINK=[96m"


REM === Enable ANSI Escape Sequence Support (Virtual Terminal) ===
>nul 2>&1 reg query "HKCU\Console" || reg add "HKCU\Console" /f
reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

REM === Check for Administrator privileges ===
NET FILE 1>NUL 2>NUL
if not errorlevel 1 (
    echo %GREEN%Running with administrator privileges.%RESET%
) else (
    echo %ORANGE%Requesting administrator privileges...%RESET%
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

REM === Configuration ===
set "TaskWiFi=WiFiDisconnect"
set "TaskRenew=IPRenewal"
set "TimeFile=%~dp0scheduled_time.txt"

REM === Load saved time ===
if exist "%TimeFile%" (
    set /p SavedTime=<"%TimeFile%"
) else (
    set "SavedTime="
)

:MAIN
cls
REM === Check task statuses ===
call :CheckTask "%TaskWiFi%" TaskWiFiExists TaskWiFiEnabled
call :CheckTask "%TaskRenew%" TaskRenewExists TaskRenewEnabled

echo %PINK%================ Schedule Status ================%RESET%
if defined TaskWiFiExists (
    if defined TaskWiFiEnabled (
        echo %ORANGE%Wi-Fi OFF Task  :%RESET% %GREEN%ENABLED%RESET%
    ) else (
        echo %ORANGE%Wi-Fi OFF Task  :%RESET% %RED%DISABLED%RESET%
    )
) else (
    echo %ORANGE%Wi-Fi OFF Task  :%RESET% %RED%DISABLED%RESET%
)
if defined TaskRenewExists (
    if defined TaskRenewEnabled (
        echo %ORANGE%Daily Renewal   :%RESET% %GREEN%ENABLED%RESET%
    ) else (
        echo %ORANGE%Daily Renewal   :%RESET% %RED%DISABLED%RESET%
    )
) else (
    echo %ORANGE%Daily Renewal   :%RESET% %RED%DISABLED%RESET%
)
if defined SavedTime (
    echo %ORANGE%Scheduled Time  :%RESET% %SavedTime%
) else (
    echo %ORANGE%Scheduled Time  :%RESET% (not set)
)
echo %PINK%================================================%RESET%
echo.
echo %PINK%1.%RESET% Toggle %ORANGE%Wi-Fi OFF Schedule%RESET%
echo %PINK%2.%RESET% Toggle %ORANGE%Daily Renewal%RESET%
echo %PINK%3.%RESET% Change %ORANGE%Scheduled Time%RESET%
echo %PINK%0.%RESET% Exit
echo.
set /p Choice=Select [%PINK%0%RESET%-%PINK%3%RESET%]:

if "%Choice%"=="1" goto ToggleWiFi
if "%Choice%"=="2" goto ToggleRenew
if "%Choice%"=="3" goto ChangeTime
if "%Choice%"=="0" goto End
goto MAIN

:ToggleWiFi
if not defined SavedTime (
    echo %RED%You must set a scheduled time first.%RESET%
    pause
    goto MAIN
)
if defined TaskWiFiEnabled (
    echo %ORANGE%Disabling Wi-Fi OFF schedule...%RESET%
    schtasks /Delete /TN "%TaskWiFi%" /F >nul 2>&1
    if errorlevel 1 (
        echo %RED%ERROR:%RESET% Could not delete task. Ensure the task exists and you have permissions.
    ) else (
        echo %GREEN%Disabled.%RESET%
    )
) else (
    echo %ORANGE%Enabling Wi-Fi OFF schedule...%RESET%
    goto CreateWiFiTask
)
pause
goto MAIN

:CreateWiFiTask
call :To24Hour "%SavedTime%" HH24MM
schtasks /Create /TN "%TaskWiFi%" /TR "netsh wlan disconnect" /SC DAILY /ST %HH24MM% /RL HIGHEST /F >nul 2>&1
if errorlevel 1 (
    echo %RED%ERROR:%RESET% Could not create task. Check permissions.
) else (
    echo %GREEN%Enabled.%RESET%
)
pause
goto MAIN

:ToggleRenew
if not defined SavedTime (
    echo %RED%You must set a scheduled time first.%RESET%
    pause
    goto MAIN
)
if defined TaskRenewEnabled (
    echo %ORANGE%Disabling Daily Renewal...%RESET%
    schtasks /Delete /TN "%TaskRenew%" /F >nul 2>&1
    if errorlevel 1 (
        echo %RED%ERROR:%RESET% Could not delete task. Ensure the task exists and you have permissions.
    ) else (
        echo %GREEN%Disabled.%RESET%
    )
) else (
    echo %ORANGE%Enabling Daily Renewal...%RESET%
    goto CreateRenewTask
)
pause
goto MAIN

:CreateRenewTask
call :To24Hour "%SavedTime%" HH24MM
schtasks /Create /TN "%TaskRenew%" /TR "ipconfig /renew" /SC DAILY /ST %HH24MM% /RL HIGHEST /F >nul 2>&1
if errorlevel 1 (
    echo %RED%ERROR:%RESET% Could not create task. Check permissions.
) else (
    echo %GREEN%Enabled.%RESET%
)
pause
goto MAIN

:ChangeTime
echo.
echo Current time : %SavedTime%
echo Enter new time (HH:MM AM/PM), e.g. 02:45 PM
set /p NewTime=New time: 
echo %NewTime% | findstr /R "^[0-1][0-9]:[0-5][0-9] [AP]M$" >nul 2>&1
if errorlevel 1 (
    echo Invalid format. Use HH:MM AM or HH:MM PM.
    pause
    goto MAIN
)
echo %NewTime%>"%TimeFile%"
set "SavedTime=%NewTime%"
echo Time updated.

REM Update enabled tasks immediately
if defined TaskWiFiEnabled goto CreateWiFiTask
if defined TaskRenewEnabled goto CreateRenewTask
pause
goto MAIN

:CheckTask
REM %1=TaskName %2=out Exists flag %3=out Enabled flag
set "%2="
set "%3="
schtasks /query /TN "%~1" >nul 2>&1 && (
    set "%2=1"
    schtasks /query /TN "%~1" /fo LIST /v | findstr /C:"Disabled: Yes" >nul 2>&1 || (
        set "%3=1"
    )
)
exit /b

:To24Hour
REM %1 = "HH:MM AM/PM", %2 = out var name
setlocal
for /f "tokens=1,2 delims= " %%A in ("%~1") do (set hhmm=%%A & set ap=%%B)
for /f "tokens=1,2 delims=:" %%A in ("!hhmm!") do (set hh=%%A & set mm=%%B)
set /a H=1%hh% - 100, M=1%mm% - 100
if /i "%ap%"=="PM" if %H% LSS 12 set /a H+=12
if /i "%ap%"=="AM" if %H% EQU 12 set H=0
if %H% LSS 10 (set H=0%H%)
if %M% LSS 10 (set M=0%M%)
endlocal & set "%2=%H%:%M%" & exit /b 0

:End
endlocal
exit /b
