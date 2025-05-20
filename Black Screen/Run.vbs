Set objShell = CreateObject("WScript.Shell")

' Run Black Screen.bat in Invisible mode
objShell.Run "cmd.exe /c ""D:\- Scripts\Black Screen\StartupRestore.bat""", 0, True

' Run Black Screen.bat in Visible mode
objShell.Run "cmd.exe /c ""D:\- Scripts\Black Screen\Black Screen.bat""", 1, True
