; Description = Move the active window to the mousecursor with a hotkey
; Version = 0.01
#ErrorStdOut ; this line needs to be in every plugin

sh_winmove:
	outputdebug Shorthand plugin loaded: sh_winmove version 0.01 

	hotkey,#g,hotkey_winmove
return

hotkey_winmove:
	CoordMode, Mouse, Screen
	MouseGetPos, xpos, ypos 
	WinGet, active_id, ID, A
	WinGet, minmax_id, minmax, A
	if minmax_id <> 0	; 1 = maximised; -1 = minimised; 0 = normal
		WinRestore, A ; Unminimizes or unmaximizes the specified window if it is minimized or maximized.
	
	olddelay := A_WinDelay 
	SetWinDelay, -1	; to prevent the max/restore button to fail to update
	WinMove, ahk_id %active_id%,, %xpos%, %ypos%
	SetWinDelay , %olddelay% := A_WinDelay 
return
