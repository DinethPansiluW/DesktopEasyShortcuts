@echo off

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[91m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

set "SHORTCUT_DIR=%USERPROFILE%\Desktop"

rem Use PowerShell to create each shortcut
powershell -Command ^
$WshShell = New-Object -ComObject WScript.Shell; ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Shutdown.lnk'); ^
$Shortcut.TargetPath = '%~dp0Shutdown\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Shutdown\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Restart.lnk'); ^
$Shortcut.TargetPath = '%~dp0Restart\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Restart\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Hibernate.lnk'); ^
$Shortcut.TargetPath = '%~dp0Hibernate\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Hibernate\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Sleep.lnk'); ^
$Shortcut.TargetPath = '%~dp0Sleep\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Sleep\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Wi-Fi ON OFF.lnk'); ^
$Shortcut.TargetPath = '%~dp0Wi-Fi ON OFF\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Wi-Fi ON OFF\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Power Setting Manager.lnk'); ^
$Shortcut.TargetPath = '%~dp0Power Setting Manager\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Power Setting Manager\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Schedule Shutdown.lnk'); ^
$Shortcut.TargetPath = '%~dp0Schedule Shutdown\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Schedule Shutdown\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Display Switch.lnk'); ^
$Shortcut.TargetPath = '%~dp0Display Switch\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Display Switch\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Wi-Fi OFF Scheduler.lnk'); ^
$Shortcut.TargetPath = '%~dp0Wi-Fi OFF Scheduler\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Wi-Fi OFF Scheduler\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Graphic Settings.lnk'); ^
$Shortcut.TargetPath = '%~dp0Graphic Settings\Run.vbs'; ^
$Shortcut.IconLocation = '%~dp0Graphic Settings\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Black Screen.lnk'); ^
$Shortcut.TargetPath = '%~dp0Black Screen\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Black Screen\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Unwanted System Services Manager.lnk'); ^
$Shortcut.TargetPath = '%~dp0Unwanted System Services Manager\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Unwanted System Services Manager\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\Windows Update.lnk'); ^
$Shortcut.TargetPath = '%~dp0Windows Update\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0Windows Update\Icon.ico'; ^
$Shortcut.Save(); ^

$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_DIR%\MS Store Installed Apps.lnk'); ^
$Shortcut.TargetPath = '%~dp0MS Store Installed Apps\Run.bat'; ^
$Shortcut.IconLocation = '%~dp0MS Store Installed Apps\Icon.ico'; ^
$Shortcut.Save();

echo.
echo.
echo %SKYBLUE%Shortcut create completed
echo.
echo.
echo %GREEN% Wait....

timeout /t 3 /nobreak >nul


rem Minimize all windows
powershell -Command ^
  "(New-Object -ComObject Shell.Application).MinimizeAll()"

exit
