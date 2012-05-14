; Description = Browse path of process (CTRL-ALT-LEFT)
; Version = 0.01
; #ErrorStdOut ; this line needs to be in every plugin

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
