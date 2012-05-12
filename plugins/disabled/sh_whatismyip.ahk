; Description = Get the external IP through http://ip.ahk4.me/ in a messagebox
; Version = 0.01

sh_whatismyip:
	UrlDownloadToFile, http://ip.ahk4.me/, %tempfolder%\ip.ahk4.me
	FileRead, ExtIP, %tempfolder%\ip.ahk4.me
	MsgBox % ExtIP
return