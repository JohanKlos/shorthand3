; Name = Process Path
; Category = Hotkey 
; Version = 0.01
; Description = Browse path of current process (CTRL-ALT-LEFT)
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

sh_processpath:
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
