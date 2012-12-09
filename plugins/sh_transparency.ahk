; Name = Transparency
; Category = Enhancement
; Version = 0.01
; Description = Checks for the existence of certain windows and makes them transparent (a certain % of transparency, anyway)
; Author = Maestr0
#persistent ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

DetectHiddenWindows ON
SetTitleMatchMode 3			; 3: A window's title must exactly match WinTitle to be a match.

sh_transparency:
	outputdebug Shorthand plugin loaded: sh_transparency version 0.01
	gosub sh_transparency_checkini
	Settimer sh_transparency_checkini, 60000 	; checks the ini for new windows every minute
	Settimer sh_transparency_checkwindow 		; looks for a certain window to open and then do a certain command
return

/*
idea: Transparency
a shorthand plugin that checks for the existence of certain windows and makes them transparent (a certain % of transparency, anyway)
- transparency
- save in .ini file

- optional: only make a certain color transparent

to do:
- add gui
- optional: a hotkey to make a certain window transparent
- optional: a hotkey to make a certain color in a certain window transparent
- optional: make a certain section transparent (WinSet region)

problems:
x when set a certain color transparent, it disappears instead of setting a certain transparency level
*/

sh_transparency_checkini:
	ifExist %ini_file%
		IniRead, list_transp_windows, %ini_file%, Plugins, sh_transparency, %A_Space% ; collects the list of windows to look for
return
sh_transparency_checkwindow:
	if list_transp_windows =	; no list, so nothing to look for, do nothing
		return
	loop, parse, list_transp_windows, `,	; this will break up the line into windows
	{
		line := A_LoopField
		loop, parse, line, |			; this will break up the windows into parameters
		{
			if A_Index = 1
				WinTitle := A_LoopField
			if A_Index = 2
				transparency := A_LoopField
			if A_Index = 3
				TranspColor := A_LoopField
			if ( WinTitle = "" ) or ( transparency = "" )
				continue
			else
			{
				IfWinExist %WinTitle%
				{
					if TranspColor =
					{
						; get the current transparency setting
						WinGet, currTransparent, Transparent, %WinTitle%
						if currTransparent = %transparency%	; if it's already at the correct setting, skip it
							continue
							
						WinSet, Transparent, %transparency%, %WinTitle%
					}
					else
					{
						; get the current transcolor setting
						WinGet, currTransColor, TransColor, %WinTitle%
						if currTransColor = %TranspColor% ; if it's already at the correct setting, skip it
							continue

						WinSet, Transparent, OFF, %WinTitle%	; workaround to be able to change a window's existing TransColor
						WinSet, Transparent, 255, %WinTitle%	; to prevent flickering
						WinSet, TransColor, Off, %WinTitle%
						WinSet, TransColor, %TranspColor% %transparency%, %WinTitle%
					}
				}
			}
		}
	}
return