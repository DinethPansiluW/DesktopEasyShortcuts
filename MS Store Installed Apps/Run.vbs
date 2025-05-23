Set objShell = CreateObject("WScript.Shell")

' Run Black Screen.bat silently
objShell.Run "cmd.exe /c ""MS Store Installed Apps.bat""", 0, True

