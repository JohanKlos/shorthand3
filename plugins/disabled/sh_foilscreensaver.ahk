; Name = Foil Screensaver
; Category = Enhancement
; Version = 0.03
; Description = Moves the mouse one pixel every 10 minutes, to keep the screensaver from engaging
#NoTrayIcon ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin

sh_foilscreensaver:
	SetTimer, timer_foilscreensaver, 1000
	outputdebug Shorthand plugin loaded: sh_foilscreensaver version 0.03
return

timer_foilscreensaver:
	if A_TimeIdle > 600000 	; -- every 10 minutes (60,000 Msec * 10)
	{
		MouseMove, 1, 0,,R
		MouseMove, -1, 0,,R
	}
return