@echo off
:: Ultra-Fast Display Toggler
:: Uses conditional execution for instant switching
:: No temporary files, uses registry for state tracking

:: Check current state and toggle
reg query "HKCU\Software\DisplayToggler" /v LastMode 2>nul | find "INTERNAL" >nul && (
    start "" /b DisplaySwitch.exe /extend
    reg add "HKCU\Software\DisplayToggler" /v LastMode /d "EXTENDED" /f >nul
) || (
    start "" /b DisplaySwitch.exe /internal
    reg add "HKCU\Software\DisplayToggler" /v LastMode /d "INTERNAL" /f >nul
)

:: Immediate exit without waiting
exit