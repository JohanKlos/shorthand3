; Name = On Top
; Category = Hotkey 
; Version = 0.02
; Description = Add hotkeys (CTRL-ALT-up / down) to put the active window on top or vice versa or (CTRL-WIN-W) to remove the caption
#ErrorStdOut ; this line needs to be in every plugin

sh_ontop:
	outputdebug Shorthand plugin loaded: sh_ontop version 0.01 
	; make the selected window always on top
	hotkey,^!up,hotkey_ontop
	; make the selected window not always on top
	hotkey,^!down,hotkey_offtop
	; toggle the caption of the window
	hotkey,^#w,hotkey_togglecap
return

hotkey_ontop:		; a subroutine to allow the user to bind a hotkey to make a window "always on top"
	WinGet, active_id, ID, A
	WinSet, Alwaysontop, On, ahk_id %active_id%
	WinGetTitle, this_title, ahk_id %active_id%
	Tooltip, %this_title% now Always On Top.
	SetTimer, RemoveToolTip, 1000
return
hotkey_offtop:	; a subroutine to allow the user to bind a hotkey to make a window "NOT always on top"
	WinGet, active_id, ID, A
	WinSet, Alwaysontop, Off, ahk_id %active_id%
	Tooltip, %this_title% now NOT Always On Top.
	SetTimer, RemoveToolTip, 5000
return
hotkey_togglecap:
	cap := !cap
	if cap = 1
		WinSet,Style,-0xC00000,A
	else
		WinSet,Style,+0xC00000,A
	WinGetPos,,,,Height,A
	WinMove,A,,,,,% Height-1
	WinMove,A,,,,,% Height
	if cap = 1
		Tooltip, %this_title% now Captionless.
	else
		Tooltip, %this_title% now no longer Captionless.
	SetTimer, RemoveToolTip, 1000
return
RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return