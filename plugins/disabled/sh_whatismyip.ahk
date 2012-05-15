; Name = What is my IP
; Category = Enhancement
; Version = 0.01
; Description = Get the external IP through http://ip.ahk4.me/ in a messagebox
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

sh_whatismyip:
	UrlDownloadToFile, http://ip.ahk4.me/, %tempfolder%\ip.ahk4.me
	FileRead, ExtIP, %tempfolder%\ip.ahk4.me
	MsgBox % ExtIP
return