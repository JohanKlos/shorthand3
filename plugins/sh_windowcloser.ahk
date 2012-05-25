; Name = Window Closer
; Category = Enhancement
; Version = 0.02
; Description = Checks for and closes specified windows, in the main ini file, comma separated per window, WinTitle|control|keys
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin
DetectHiddenWindows ON
SetTitleMatchMode 3			; 3: A window's title must exactly match WinTitle to be a match.

sh_windowcloser:
	outputdebug Shorthand plugin loaded: sh_windowcloser version 0.02
	gosub checkini
	Settimer checkini, 60000 	; checks the ini for new windows every minute
	Settimer checkwindow 		; looks for a certain window to open and then do a certain command
return
checkini:
	ifExist %ini_file%
		IniRead, list_windows, %ini_file%, Plugins, sh_windowcloser, %A_Space% ; collects the list of windows to look for
return
checkwindow:
	if list_windows =	; no list, so nothing to look for, do nothing
		return
	loop, parse, list_windows, `,	; this will break up the line into windows
	{
		line := A_LoopField
		loop, parse, line, |			; this will break up the windows into parameters
		{
			if A_Index = 1
				WinTitle := A_LoopField
			if A_Index = 2
				control := A_LoopField
			if A_Index = 3
			{
				keys := A_LoopField
				if ( WinTitle = "" ) or ( control = "" ) or ( keys = "" )
					continue
				else
				{
					IfWinExist %WinTitle%
					{
						WinActivate
						ControlSend, %control%, %keys%, %WinTitle%
					}
				}
			}
		}
	}
return