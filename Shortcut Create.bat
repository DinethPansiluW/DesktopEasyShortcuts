@echo off

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: Create a temporary VBScript to relaunch this script with admin rights
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    :: Run the VBScript silently and exit the current window
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[91m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

set "SHORTCUT_DIR=%USERPROFILE%\Desktop"

echo.
echo.
:: Create Additional folder if missing
if not exist "%SHORTCUT_DIR%\Additional" (
    mkdir "%USERPROFILE%\Desktop\Additional"
    echo %RESET%Folder created.
) else (
    echo Folder already exists.
)

echo.
echo %GREEN%Wait....

rem Use PowerShell to create each shortcut
powershell -Command ^
$WshShell = New-Object -ComObject WScript.Shell; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Shutdown.lnk'); ^
$Shortcut.TargetPath = '%~dp0Shutdown\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Shutdown\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Restart.lnk'); ^
$Shortcut.TargetPath = '%~dp0Restart\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Restart\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Sleep.lnk'); ^
$Shortcut.TargetPath = '%~dp0Sleep\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Sleep\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Wi-Fi ON OFF.lnk'); ^
$Shortcut.TargetPath = '%~dp0Wi-Fi ON OFF\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Wi-Fi ON OFF\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Black Screen.lnk'); ^
$Shortcut.TargetPath = '%~dp0Black Screen\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Black Screen\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Power Setting Manager.lnk'); ^
$Shortcut.TargetPath = '%~dp0Power Setting Manager\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Power Setting Manager\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Schedule Shutdown.lnk'); ^
$Shortcut.TargetPath = '%~dp0Schedule Shutdown\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Schedule Shutdown\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Wi-Fi OFF Scheduler.lnk'); ^
$Shortcut.TargetPath = '%~dp0Wi-Fi OFF Scheduler\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Wi-Fi OFF Scheduler\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Display Switch.lnk'); ^
$Shortcut.TargetPath = '%~dp0Display Switch\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Display Switch\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Graphic Settings.lnk'); ^
$Shortcut.TargetPath = '%~dp0Graphic Settings\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Graphic Settings\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\Unwanted System Services Manager.lnk'); ^
$Shortcut.TargetPath = '%~dp0Unwanted System Services Manager\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Unwanted System Services Manager\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\Windows Update.lnk'); ^
$Shortcut.TargetPath = '%~dp0Windows Update\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Windows Update\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\MS Store Installed Apps.lnk'); ^
$Shortcut.TargetPath = '%~dp0MS Store Installed Apps\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0MS Store Installed Apps\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\Hibernate.lnk'); ^
$Shortcut.TargetPath = '%~dp0Hibernate\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Hibernate\Icon.ico'; ^
$Shortcut.Save();

echo.
echo %SKYBLUE%Shortcut created according to the recommended order.
echo.
echo %ORANGE%Check Additional Folder for additional Scripts
echo.
echo %GREEN% Wait.....

timeout /t 5 /nobreak >nul

exit
