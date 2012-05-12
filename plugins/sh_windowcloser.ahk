; Description = Window closer
; Version = 0.01
#ErrorStdOut ; this line needs to be in every plugin

sh_windowcloser:
	outputdebug Shorthand plugin loaded: sh_windowcloser version 0.01
	Settimer checkwindow ; looks for a certain window to open and then do a certain command
return

checkwindow:
	IfWinExist Sponsored session ahk_class #32770	; TeamViewer nag-screen
	{
		WinActivate
		ControlSend, Button4, {enter}, Sponsored session ahk_class #32770
	}
	IfWinExist TeamViewer 7 requires an update ahk_class #32770	; TeamViewer nag-screen
	{
		WinActivate
		ControlSend, Button4, {enter}, TeamViewer 7 requires an update ahk_class #32770
	}
	;IfWinNotExist, DebugView * ahk_class dbgviewClass ; the main window, if it exists, do not controlsend
	; {
		IfWinExist, DebugView Filter ahk_class #32770		; Sysinternals' Dbgview filter-screen
			ControlSend, Button3, {enter}, DebugView Filter ahk_class #32770
	; }
return
