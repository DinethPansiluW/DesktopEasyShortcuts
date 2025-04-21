Set objShell = CreateObject("WScript.Shell")

' Run Black Screen.bat silently
objShell.Run "cmd.exe /c ""Black Screen.bat""", 0, True

' Run Add Task Scheduler.vbs (adjust path if needed)
objShell.Run "cscript //nologo ""Restore Time.vbs""", 0, True