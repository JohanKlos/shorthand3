; Description = Add hotkeys to put the active window on top or vice versa
; Version = 0.01
#ErrorStdOut ; this line needs to be in every plugin

sh_ontop:
	outputdebug Shorthand plugin loaded: sh_ontop version 0.01 
	; make the selected window always on top
	hotkey,^!up,hotkey_ontop
	; make the selected window not always on top
	hotkey,^!down,hotkey_offtop
return

hotkey_ontop:		; a subroutine to allow the user to bind a hotkey to make a window "always on top"
	WinGet, active_id, ID, A
	WinSet, Alwaysontop, On, ahk_id %active_id%
return
hotkey_offtop:	; a subroutine to allow the user to bind a hotkey to make a window "NOT always on top"
	WinGet, active_id, ID, A
	WinSet, Alwaysontop, Off, ahk_id %active_id%
return
