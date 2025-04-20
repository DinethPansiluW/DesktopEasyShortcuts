@echo off
setlocal EnableDelayedExpansion
set flagFile=%~dp0wifi_task_flag.txt

:: Clear screen
cls

:: Define message area
set "space=                                         "

:: Setup color (0A = black background, light green text)
color 0A

if exist "%flagFile%" (
    >nul 2>&1 call "%~dp0remove_wifi_disable_task.bat"
    set "msg=WiFi off scheduler removed"
    del "%flagFile%"
) else (
    >nul 2>&1 call "%~dp0add_wifi_disable_task.bat"
    set "msg=WiFi off at 7a.m"
    echo flag > "%flagFile%"
)

:: Display big centered green message
echo.
echo %space%%msg%
echo.
timeout /t 3 >nul
color 07
cls
