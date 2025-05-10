Set objShell = CreateObject("WScript.Shell")

' Run Black Screen.bat silently
objShell.Run "cmd.exe /c ""Graphic Settings.bat""", 0, True

