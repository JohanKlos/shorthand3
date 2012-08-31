; Name = Notepad Plus Plus run
; Category = Hotkey 
; Version = 0.01
; Description = Adds a hotkey Ctrl-1 to Notepad++ to execute the opened file
; Author = Maestr0
#persistent ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

sh_npprun:
	outputdebug Shorthand plugin loaded: sh_npprun version 0.01 
	; run the current file open in np++
	#IfWinActive,ahk_class Notepad++
		hotkey,^1,npp_run	
	#IfWinActive	; finish with this to make any hotkeys fire on every window by default
return

npp_run:
   Send ^s
   WinWaitNotActive,* ahk_class Notepad++,,2
   WinGetTitle,File,A
   File:=SubStr(File,1,InStr(File," - ")-1)
   Dir:=SubStr(File,1,InStr(File,"\","0","0"))
   File:=SubStr(File,InStr(File,"\","0","0")+1)
   run,% File,% Dir
return
