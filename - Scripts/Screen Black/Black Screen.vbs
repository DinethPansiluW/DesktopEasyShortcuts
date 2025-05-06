Set objShell = CreateObject("WScript.Shell")


' Run Black Screen.bat in visible mode (no "0")
objShell.Run "cmd.exe /c ""D:\- Scripts\Screen Black\Black Screen.bat""", 0, True