; Name = Elevate Window
; Category = Enhancement
; Version = 0.01
; Description = Elevates currently active window (meaning re-runs it as admin)
; Author = Maestr0
#persistent ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

sh_elevatewindow:
	outputdebug Shorthand plugin loaded: sh_elevatewindow version 0.01
	hotkey, #Y, Elevate
return

Elevate:
	winget, ppath, processpath, A
	if ppath =
		return
	winget, ppid, pid, A
	SplitPath, ppath, OutFileName, OutDir
	winclose, ahk_pid %ppid%
	winwaitclose, ahk_pid %ppid%
	run *runAs "%ppath%"  ; Requires v1.0.92.01+
return