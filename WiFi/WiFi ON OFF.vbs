' Save this as RunWiFiSilent.vbs in the same folder as "WiFi ON OFF.bat"
Dim objShell, objFSO, batchPath
Set objShell = CreateObject("WScript.Shell")
Set objFSO   = CreateObject("Scripting.FileSystemObject")

' build full path to the .bat
batchPath = objFSO.GetParentFolderName(WScript.ScriptFullName) & "\WiFi ON OFF.bat"

' ensure working directory is the script folder
objShell.CurrentDirectory = objFSO.GetParentFolderName(WScript.ScriptFullName)

' run the batch hidden (0 = hide window), don't wait for completion (False)
objShell.Run "cmd.exe /c """ & batchPath & """", 0, False
