; Name = Process Path
; Category = Hotkey 
; Version = 0.01
; Description = Browse path of current process (CTRL-ALT-LEFT)
; Author = Maestr0
#persistent ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

sh_processpath:
	outputdebug Shorthand plugin loaded: sh_processpath version 0.01
	hotkey,^!left,hotkey_getprocesspath
return
hotkey_getprocesspath:
	ppath :=
	winget, ppath, processpath, A
	if ppath =
		return
	SplitPath, ppath, OutFileName, OutDir
	; outputdebug ppath %ppath% , %outdir% , %active_id%
	run, explore "%OutDir%", %OutDir% , UseErrorLevel
return
