@echo off

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
set "GREENU=[4;32m"
set "RED=[91m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

call "%~dp0Wi-Fi ON OFF\WiFiRunCreate.bat"

:: Continue with original logic
set "SHORTCUT_DIR=%USERPROFILE%\Desktop"

echo.
echo.
if not exist "%SHORTCUT_DIR%\Additional" (
    mkdir "%SHORTCUT_DIR%\Additional"
    echo %RESET%'Additional' Folder created.
    echo %ORANGE%Some Scripts add to that folder%RESET%
) else (
    echo %RESET%'Additional' Folder already exists.
    echo %ORANGE%Some Scripts add to that folder%RESET%
)

echo.
echo %GREEN%Wait....

powershell -Command ^
$WshShell = New-Object -ComObject WScript.Shell; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Shutdown.lnk'); ^
$Shortcut.TargetPath = '%~dp0Shutdown\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Shutdown'; ^
$Shortcut.IconLocation = '%~dp0Shutdown\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Restart.lnk'); ^
$Shortcut.TargetPath = '%~dp0Restart\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Restart'; ^
$Shortcut.IconLocation = '%~dp0Restart\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Sleep.lnk'); ^
$Shortcut.TargetPath = '%~dp0Sleep\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Sleep'; ^
$Shortcut.IconLocation = '%~dp0Sleep\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Wi-Fi ON OFF.lnk'); ^
$Shortcut.TargetPath = '%~dp0Wi-Fi ON OFF\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Wi-Fi ON OFF'; ^
$Shortcut.IconLocation = '%~dp0Wi-Fi ON OFF\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Black Screen.lnk'); ^
$Shortcut.TargetPath = '%~dp0Black Screen\Run.vbs'; ^
$Shortcut.WorkingDirectory = '%~dp0Black Screen'; ^
$Shortcut.IconLocation = '%~dp0Black Screen\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Power Setting Manager.lnk'); ^
$Shortcut.TargetPath = '%~dp0Power Setting Manager\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Power Setting Manager'; ^
$Shortcut.IconLocation = '%~dp0Power Setting Manager\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Schedule Shutdown.lnk'); ^
$Shortcut.TargetPath = '%~dp0Schedule Shutdown\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Schedule Shutdown'; ^
$Shortcut.IconLocation = '%~dp0Schedule Shutdown\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Wi-Fi OFF Scheduler.lnk'); ^
$Shortcut.TargetPath = '%~dp0Wi-Fi OFF Scheduler\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Wi-Fi OFF Scheduler'; ^
$Shortcut.IconLocation = '%~dp0Wi-Fi OFF Scheduler\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Display Switch.lnk'); ^
$Shortcut.TargetPath = '%~dp0Display Switch\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Display Switch'; ^
$Shortcut.IconLocation = '%~dp0Display Switch\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Graphic Settings.lnk'); ^
$Shortcut.TargetPath = '%~dp0Graphic Settings\Run.vbs'; ^
$Shortcut.WorkingDirectory = '%~dp0Graphic Settings'; ^
$Shortcut.IconLocation = '%~dp0Graphic Settings\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\- Unwanted Services Manager.lnk'); ^
$Shortcut.TargetPath = '%~dp0Unwanted Services Manager\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Unwanted Services Manager'; ^
$Shortcut.IconLocation = '%~dp0Unwanted Services Manager\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\- Windows Update.lnk'); ^
$Shortcut.TargetPath = '%~dp0Windows Update\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Windows Update'; ^
$Shortcut.IconLocation = '%~dp0Windows Update\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\- MS Store Installed Apps.lnk'); ^
$Shortcut.TargetPath = '%~dp0MS Store Installed Apps\Run.vbs'; ^
$Shortcut.WorkingDirectory = '%~dp0MS Store Installed Apps'; ^
$Shortcut.IconLocation = '%~dp0MS Store Installed Apps\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\- Power Buttons Time Managerr.lnk'); ^
$Shortcut.TargetPath = '%~dp0Power Buttons Time Manager\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Power Buttons Time Manager'; ^
$Shortcut.IconLocation = '%~dp0Power Buttons Time Manager\Icon.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\- WiFi Name Change.lnk'); ^
$Shortcut.TargetPath = '%~dp0Wi-Fi ON OFF\WiFiNameChange.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Wi-Fi ON OFF'; ^
$Shortcut.IconLocation = '%~dp0Wi-Fi ON OFF\WiFiNameChange.ico'; ^
$Shortcut.Save(); ^
Start-Sleep -Milliseconds 500; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Additional\- Hibernate.lnk'); ^
$Shortcut.TargetPath = '%~dp0Hibernate\Run.bat'; ^
$Shortcut.WorkingDirectory = '%~dp0Hibernate'; ^
$Shortcut.IconLocation = '%~dp0Hibernate\Icon.ico'; ^
$Shortcut.Save();

echo.
echo %SKYBLUE%Shortcut created according to the recommended order.
echo.
echo %GREEN% Wait.....
echo.
echo %PINK%All Done

timeout /t 5 /nobreak >nul

powershell -command "(New-Object -ComObject Shell.Application).MinimizeAll()"

exit
