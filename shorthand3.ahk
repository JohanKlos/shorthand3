#Persistent
; #Warn
#SingleInstance Force
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#MaxThreadsPerHotkey 1		; enable correction on accidental press of several hotkeys (only last pressed hotkey will fire)
OnExit, ExitSub				; when script exits, go to subroutine ExitSub
Process, Priority,, High 	; increase performance for Hotkeys, Clicks, or Sends while the CPU is under heavy load
SetBatchLines -1 				; maximum speed for loops
SetWorkingDir %A_ScriptDir%	; unconditionally use its own folder as its working directory
SetWinDelay,2					; for smooth resizing
; SendMode InputThenPlay 		; commented because it made the send not work all the time...
DetectHiddenWindows ON
SetTitleMatchMode 3			; 3: A window's title must exactly match WinTitle to be a match.

	#include %A_ScriptDir%\inc\debugging.ahk		; for debugging purposes
	#include %A_ScriptDir%\inc\Autoexec.ahk		; the autoexecute section
f_dbgtime(gen,dbg,A_LineNumber,"Bootup","start",0) ; sub_time shows in outputdebug how long a certain function/subroutine takes to run
	#include %A_ScriptDir%\inc\PortableCheck.ahk	; checks where the userfiles should go (portable or user_app)
	check_portable()	; this checks %A_ScriptDir%\portable.ini sets paths in the app_folder (=portable) or not (= not portable)
	#include %A_ScriptDir%\inc\globals.ahk			; the global variables
	#include %A_ScriptDir%\inc\history.ahk			; history functions for executed functions
	#include %A_ScriptDir%\inc\plugin.ahk			; sorts plugin checking and loading

	Plugins()
	read_ini()
	f_dbgoutput(gen,dbg,A_LineNumber,0,"portable = " portable)
	f_dbgoutput(gen,dbg,A_LineNumber,0,"ini_file = " ini_file)
	f_dbgoutput(gen,dbg,A_LineNumber,0,"app_find = " app_find)
	f_dbgoutput(gen,dbg,A_LineNumber,0,"app_findstr = " app_findstr)
	f_dbgoutput(gen,dbg,A_LineNumber,0,"logging = " logging)
	f_dbgoutput(gen,dbg,A_LineNumber,0,"debugging = " debugging)
	
	GoSub timer_load_custom ; needs to be before menu so menu populates correctly with (eventually, maybe) list of bound hotkeys and custom_files
	GoSub Menu
	GoSub Checks
	GoSub GUI
	use_everything := 1
	
f_dbgtime(gen,dbg,A_LineNumber,"Bootup","stop",0)
	
	#include %A_ScriptDir%\inc\Crypt.ahk			; required for encrypting and decrypting a string
	#include %A_ScriptDir%\inc\CryptFoos.ahk		; required for encrypting and decrypting a string
	#include %A_ScriptDir%\inc\CryptConst.ahk		; required for encrypting and decrypting a string
	#include %A_ScriptDir%\inc\PasswordGUI.ahk	; required for encrypting and decrypting a string

	#include %A_ScriptDir%\inc\MFT.ahk				; alternative to "everything.exe" and "es.exe"
Return
check_exist_folder(folder)
{
	ifnotexist %folder%
		FileCreateDir, %folder%
	return
}

timer_load_custom:	; loads the custom_files, in which user can use shorthand and/or hotkeys to execute commands like run/send/send password
	f_dbgtime(gen,dbg,A_LineNumber,"timer_load_custom","start",5)
	; first, see which custom files are specified in the %ini_file%, if there is none, a custom file will be made
	ini_file_modded :=
	FileGetTime, ini_file_modded, %ini_file%
	; check the modified timestamp against the previously loaded modified timestamp, if they're not the same, 
	if ini_file_modded <> %ini_file_modded_old%
	{
		empty_custom_number := 		; clear the variable so it will be filled anew in this subroutine
		ini_file_modded_old := ini_file_modded	; this is the new time to check against
		loop, %max_custom%	; there's a maximum of custom_files
		{
		; the ini_file does not need to be loaded if it hasn't changed since the last time
		; get the time the ini_file was modified 
			f_dbgoutput(gen,dbg,A_LineNumber,5,A_ThisLabel ": ini_file has changed so re-reading it")
			IniRead, custom_file_%A_Index%, %ini_file%, Files, custom_file_%A_Index%, %A_Space%
			if custom_file_%A_Index% =
			{
				; collect the first empty custom_file number we can later populate with a new file through GUI2
				if empty_custom_number =
					empty_custom_number := A_Index
				
				; will the reasoning for A_Index = 1 below hold up? It should only do this on install, not every time
				if A_Index = 1	; so there is no custom_file in actuality, so appoint one and write it to ini FileAppend
				{
					custom_file_1 = %ini_location%\shorthand_custom.txt
					IniWrite, %custom_file_1%, %ini_file%, Files, custom_file_1
					ifnotexist %custom_file_1%	; just to be sure not to overwrite a file
					{
						FileAppend, 
						(
`; in this file you can specify lines to start certain programs with a custom name or hotkey
`; the correct syntax is:

`; name|path or contents|hotkey|choice
`; - name can be anything
`; - contents is applicable when with choice "send" or "password" is chosen
`; - hotkey is the hotkey that will execute the path or contents, using CTRL, ALT, SHIFT, SPACE, and any letters or numbers
`; - choice can be either send, run, password

`; example:
`; np|C:\Windows\System32\notepad.exe|WIN+N|run

`; In the Preferences (section "Custom") you can Add and remove files similar to this one.
`; I'd suggest making a separate one for your passwords, should you choose to use this tool to deploy them.

shorthand_show|show|ALT+Space|send
shorthand_setting|settings|CTRL+ALT+Space|send
shorthand_reload|reload|WIN+C|send
						), %custom_file_1%
					}
				}
			}
			else
			{
				custom_files := A_Index	; the custom_file_A_Index that are not empty, so in effect the highest custom_file number
				f_dbgoutput(gen,dbg,A_LineNumber,5,A_ThisLabel "found " custom_file_%A_Index% " which is file number " A_Index)
			}
		}
	}
	; now, read through the list of custom_files
	Loop, %custom_files%
	{
		if custom_file_%A_Index% =
			continue	; ignore empty vars
		ifexist % custom_file_%A_Index%
		{
			; get the time the current custom_file was modified 
			FileGetTime, custom_file_%A_Index%_modded, % custom_file_%A_Index%
			; check the modified timestamp against the previously loaded modified timestamp, if they're not the same, 
			if % custom_file_%A_Index%_modded <> custom_file_%A_Index%_modded_old
			{
				custom_file_%A_Index%_modded_old := custom_file_%A_Index%_modded	; this is the new time to check against
				FileRead, custom, % custom_file_%A_Index%	; Add the content of each custom_file to the total_custom variable
				custom_content_%A_Index% := custom
				custom_file_updated = 1	; so the new total_custom gets parsed
			}
		}
		else
		{
			f_dbgoutput(gen,dbg,A_LineNumber,5,A_ThisLabel " " custom_file_%A_Index% " does not exist`, so skipped")
		}
	}
	if custom_file_updated = 1	; parsing is only needed if a custom_file was newly loaded or changed
	{
		total_custom :=
		Loop, %custom_files%
		{
			if custom_content_%A_Index% <>	; if the variable is not empty
			{
				total_custom .= "`n" custom_content_%A_Index%
			}
		}
		SORT, total_custom, U	; makes the variable only have unique lines, to minimise memory footprint
		list_hotkeys :=			; else an older command would still show up
		GoSub parse_custom		; parse the newly made variable
	}
	f_dbgtime(gen,dbg,A_LineNumber,"timer_load_custom","stop",5)
return
parse_custom:	; parse the lines in %total_custom% (containing the contents of each custom_file)
	f_dbgtime(gen,dbg,A_LineNumber,"parse_custom","start",1)
	j = 0
	lv_hotkeys_list :=
	Loop, parse, total_custom, `n		; the total file, hotkeys only in the total_custom var
	{
		line := A_LoopField	; for the lv_hotkeys_list variable
		if A_LoopField not contains |	; no | means it does not have the right format, so ignore it
			continue
		if A_LoopField contains `; ; ";" means the line is commented, so disregard it if it is in the start of the A_LoopField
		{
			; first, get rid of any spaces or tabs
			StringReplace, commented, A_LoopField, %A_Space%,, All
			StringReplace, commented, commented, %A_Tab%,, All
			if SubStr(commented,1,1) = "`;"
			{
				f_dbgoutput(gen,dbg,A_LineNumber,3,"skipped custom_file line = """ A_LoopField """ because of ""`;""")
				continue
			}
		}
		Loop, parse, A_LoopField, |
		{
			if A_Index = 1					; the second value should be the description or name
				c_name := A_LoopField
			if A_Index = 2					; the second value should be the path/command/text
			{
				c_command := A_LoopField
				if c_command =
					continue	; if there's no c_command, ignore the rest, it won't do anything anyway
			}
			if A_Index = 3					; the third value should be the hotkey
			{
				c_hotkey := A_LoopField
				if c_hotkey <>				; to disregard if no hotkey has been set
				{
					; change hotkey text modifiers to chars that autohotkey can use in a hotkey
					StringReplace,c_hotkey_expanded,c_hotkey,-,+,ALL
					StringReplace,c_hotkey_expanded,c_hotkey_expanded,ALT+,!,ALL
					StringReplace,c_hotkey_expanded,c_hotkey_expanded,CTRL+,^,ALL
					StringReplace,c_hotkey_expanded,c_hotkey_expanded,SHIFT+,+,ALL
					StringReplace,c_hotkey_expanded,c_hotkey_expanded,WIN+,#,ALL
					StringReplace,c_hotkey_expanded,c_hotkey_expanded,SPACE+,SPACE,ALL
					StringReplace,c_hotkey_expanded,c_hotkey_expanded,%A_Tab%,,ALL
					
					if c_command = show	; custom command to call a subroutine from a custom_file
					{
						Hotkey, %c_hotkey_expanded%, GUI
						c_hotkey_expanded :=	
					}
					if c_command = settings	; custom command to call a subroutine from a custom_file
					{
						Hotkey, %c_hotkey_expanded%, GUI2
						c_hotkey_expanded :=	
					}
					if c_command = reload	; custom command to call a subroutine from a custom_file
					{
						Hotkey, %c_hotkey_expanded%, sub_reload
						c_hotkey_expanded :=	
					}
				}
			}
			if A_Index = 4		; the fourth value should be the choice of command (run or send)
			{
				stringreplace, c_choice, A_LoopField, `r,, ALL	; for some reason, this is always needed for the last field in a line, else it'll Add what looks like a space at the end, messing up "if" statements
				if c_hotkey <>				; to disregard if no hotkey has been set
				{
					j += 1					; needs to be here so non-hotkeys don't take up hotkey lines
					Array%j%_2 := c_command_expanded
					Array%j%_3 := c_hotkey_expanded
					if c_choice <>
						Array%j%_4 := c_choice
					else
						Array%j%_4 := run
					if c_hotkey_expanded <>
					{
						if list_hotkeys =
						{
							list_hotkeys = %c_hotkey_expanded%|%c_command%|%c_choice%
							lv_hotkeys_list = %line%
						}
						else
						{
							list_hotkeys = %list_hotkeys%`n%c_hotkey_expanded%|%c_command%|%c_choice%
							lv_hotkeys_list = %lv_hotkeys_list%`n%line%
						}
						hotkey, %c_hotkey_expanded%, hotkey_run ;attach default subroutine
					}
				}
			}
		}
	}
	Sort, lv_hotkeys_list, u
	Sort, list_hotkeys, u
	; this would be where we could append all the hotkeys to a list in, say, the settings GUI
	f_dbgoutput(gen,dbg,A_LineNumber,4,"list_hotkeys = " list_hotkeys)

	; empty all the variables
	c_name					:=
	c_choice				:=
	c_hotkey 				:=
	c_hotkey_expanded		:=
	c_command 				:=
	c_command_expanded	:=
	
	custom_file_updated = 0	; so parsing does not start again until a new custom_file has been loaded or a current one has changed
	f_dbgtime(gen,dbg,A_LineNumber,"parse_custom","stop",1)
return

hotkey_run:	; this subroutine is fired when the user presses a hotkey, at which time the line it belongs to is found and the accompanying command is executed (run/send/password/whatever)
	f_dbgtime(gen,dbg,A_LineNumber,"hotkey_run","start",1)
	Loop, parse, list_hotkeys, `n		; the total file with all the hotkeys, hotkeys only in the total_custom var
	{
		Stringreplace, line, A_LoopField, `r`n,,all
		Loop, parse, line, |
		{
			; hotkey|path|choice
			if A_Index = 1
			{
				h_hotkey := A_LoopField
				if h_hotkey <> %A_ThisHotkey%	; only continue if the hotkey is found in the line
					break
			}
			else if A_Index = 2
				h_command := A_LoopField
			else if A_Index = 3
			{
				h_choice := A_LoopField
				if h_choice = run
				{
					Splitpath, h_command , , command_path, command_ext, command_name_noext
					StringReplace, pressed_hotkey,A_ThisHotkey,+,SHIFT%A_Space%
					StringReplace, pressed_hotkey,pressed_hotkey,^,CTRL%A_Space%
					StringReplace, pressed_hotkey,pressed_hotkey,!,ALT%A_Space%
					StringReplace, pressed_hotkey,pressed_hotkey,#,WIN%A_Space%					

					gosub sub_getextandrun
					pressed_hotkey :=	""
				}
				else if h_choice = password
					SendRaw %h_command%	; this will need to be updated when the encrypt/decrypt module is Added
				else if h_choice = sendraw
					SendRaw %h_command%
				else ; basically, this means "send"
					Send %h_command%
				f_dbgoutput(gen,dbg,A_LineNumber,2,"hotkey pressed: " h_hotkey " thereby executing """ h_command """ through " h_choice)
			}
		}
	}
	h_hotkey 	:= ""
	h_command 	:= ""
	h_choice 	:= ""
	f_dbgtime(gen,dbg,A_LineNumber,"hotkey_run","stop",1)
Return
sub_getextandrun:
	; check if there's a parameter (it will be after the extension)
	if command_ext contains %A_Space%
	{
		command_ext_split := Substr(command_ext,1,InStr(command_ext, A_Space))
		StringReplace, arguments, command_ext, %command_ext_split%,, ALL
	}
	else
		command_ext_split := command_ext

	run_command = %command_name_noext%.%command_ext_split%
	run_arguments = %arguments%
	if command_run_with <> 1
		selected_program := getprogram(command_ext_split)	; see if the extension in question is linked to a specified program
	if command_name_noext <>
	{
		; show a traytip
		if TrayTip = 1
		{
			if pressed_hotkey <>
				TrayTip, Hotkey pressed and Command executing, %pressed_hotkey% pressed`nStarting "%run_command%"`nin "%command_path%",%traytime%
			else
			{
				if selected_program =
					TrayTip, Command executed, Starting %run_command% %arguments%`nin %command_path%,%traytime%
				else
					TrayTip, Command executed, Starting %selected_program% %run_command% %arguments%`nin %command_path%,%traytime%
			}
		}
	}

	if command_name_noext =
	{
		msgbox , , %app_name% , Error %A_LastError%: %error_2%`n`nFile not found.
		f_dbgoutput(gen,dbg,A_LineNumber,2,"sub_getextandrun = " run_command " " arguments " in path " command_path)
	}
	else
	{
		if command_ext_split = lnk
			run %command_path%\%run_command%
		else if RunAsAdmin = 1
		{
			if selected_program <>
				run, *runAs "%selected_program%" "%run_command%" %arguments% , %command_path% , UseErrorLevel
			else
				run, *runAs "%run_command%" %arguments% , %command_path% , UseErrorLevel
		}
		else
		{
			RunAsUser(run_command, Arguments, command_path)
		}
		GoSub sub_errorlevel		; needed so the msgbox contains the right feedback to the user pertaining the error
		f_dbgoutput(gen,dbg,A_LineNumber,2,"sub_getextandrun = " run_command " " arguments " in path " command_path)
	}
	
	if ( use_history = 1 ) and ( pressed_hotkey = "" ) ; hotkeys don't need to be added to history
	{
		path_complete = %command_path%\%run_command%
		fill_history(path_complete)
	}
	gosub sub_clear
return
menu:
	f_dbgtime(gen,dbg,A_LineNumber,"Menu","start",1)
	; Menu, Tray, icon, %icon_shorthand%	; moved to as high in the script as possible, to prevent flickering
	Menu, Tray, NoStandard
	Menu, Tray, Tip, %app_name% %app_version% %beta%

	Menu, Tray, Add, %app_name% %app_version% %beta%, GUI
	Menu, Tray, Icon, %app_name% %app_version% %beta%, %icon_shorthand%
	Menu, Tray, default, %app_name% %app_version% %beta%
	Menu, Tray, Add, Check for updates, check_update_manual
	Menu, Tray, Add
	
	Menu, menu_files, Add, Open ini file, open_ini
	Menu, menu_files, Add, Open history file, open_history
	Menu, menu_files, Add
	Loop, %custom_files%
	{
		ifexist % custom_file_%A_Index%
			Menu, menu_files, Add, % "Open " . custom_file_%A_Index%, menu_open	; beware of the StringTrimLeft in menu_open !
	}
	Loop, %A_ScriptDir%\plugins\*.ahk
	{
		if A_LoopFileName = 
			break
		if A_Index = 1
		{
			Menu, plugins, Add, Enabled Plugins, menu_browse_plugins
		}
		Menu, plugins, Add, % "Open \plugins\" . A_LoopFileName, menu_open
	}
	Loop, %A_ScriptDir%\plugins\disabled\*.ahk
	{
		if A_LoopFileName = 
			break
		if A_Index = 1
		{
			Menu, plugins, Add
			Menu, plugins, Add, Disabled Plugins, menu_browse_plugins
		}
		Menu, plugins, Add, % "Open \plugins\disabled\" . A_LoopFileName, menu_open
	}
	Menu, plugins, Add
	; this is where any plugin menu's will appear
	Menu, Tray, Add, Files, :menu_files	; creates the subfolder "Files"
	Menu, Tray, Add, Plugins, :plugins	; creates the subsubfolder "plugins"
	Menu, Tray, Add
	if A_IsCompiled <> 1
	{
		Menu, Lists, Add, ListHotkeys, list_hotkeys
		Menu, Lists, Add, KeyHistory, list_KeyHistory
		Menu, Lists, Add, ListLines, list_lines
		Menu, Lists, Add, ListVars, list_vars
		Menu, Tray, Add, Lists, :lists	; creates the subsubfolder "Lists"

		loop, %A_ScriptDir%\inc\*.ahk
		{
			if A_LoopFileName <>
				Menu, Includes, Add, Open \inc\%A_LoopFileName%, menu_open
		}
		Menu, Tray, Add, Includes, :Includes	; creates the subsubfolder "Includes"
		Menu, Tray, Add
	}
	Menu, Tray, Add, Preferences, GUI2
	Menu, Tray, Icon, Preferences, %icon_settings%
	Menu, Tray, Add, Send feedback, feedback
	Menu, Tray, Add, About..., about
	Menu, Tray, Add
	Menu, Tray, Add, Reload, sub_reload
	Menu, Tray, Add, Exit, ExitSub
	f_dbgtime(gen,dbg,A_LineNumber,"Menu","stop",1)
Return
list_hotkeys:
	ListHotkeys
return
list_KeyHistory:
	KeyHistory
return
list_lines:
	ListLines
return
list_vars:
	ListVars
return
menu_browse_plugins:
	if A_ThisMenuItem = Disabled Plugins
		command_path = %A_ScriptDir%\plugins\disabled\
	else
		command_path = %A_ScriptDir%\plugins\
	ifexist %file_browser%
		run, "%file_browser%" "%command_path%", %command_path% , UseErrorLevel
	else
		run, explore "%command_path%", %command_path% , UseErrorLevel
	GoSub sub_errorlevel		; needed so the msgbox contains the right feedback to the user pertaining the error
return
menu_open:	; opens a certain file
	IniRead, text_editor, %ini_file%, programs, text_editor, %A_Space%
	file_open := SubStr(A_ThisMenuItem,6)
	if not Instr( file_open, ":" )	; if file_open contains a ":" it'll have a full path so don't add the script path
		file_open := A_ScriptDir . "\" . file_open
	; StringTrimLeft, file_open, A_ThisMenuItem, 5	; gets rid of "Open " of the menu item
	ifexist %text_editor%
		run, %text_editor% "%file_open%"
	else
		run, %file_open%
return
open_ini:
	IniRead, text_editor, %ini_file%, programs, text_editor, %A_Space%
	ifexist %text_editor%
		run, %text_editor% "%ini_file%"
	else
		run, %ini_file%
return
open_history:
	IniRead, text_editor, %ini_file%, programs, text_editor, %A_Space%
	ifexist %text_editor%
		run, %text_editor% "%log_history%"
	else
		run, %log_history%
return

checks:
	f_dbgtime(gen,dbg,A_LineNumber,"Checks","start",1)
	if use_everything = 1
	{
		ifnotexist %app_find%
		{
			msgbox , 4, %app_name% %app_version%, Essential file not found, click yes to download the necessary files (es.exe and everything.exe) to "%app_folder%\".
			ifmsgbox Yes
			{
				ifnotexist %app_folder%
					FileCreateDir %app_folder%
				ifnotexist %app_find%
					URLDownloadToFile , http://www.voidtools.com/es.exe , %app_find%
				ifnotexist %app_everything%
					URLDownloadToFile , http://www.voidtools.com/Everything-1.2.1.371.exe , %app_everything%
			}
			exitapp
		}
	}
	if check_for_updates_on_startup = 1
		GoSub check_update_automatic
	f_dbgtime(gen,dbg,A_LineNumber,"Checks","stop",1)
Return

GUI:
	f_dbgtime(gen,dbg,A_LineNumber,"GUI","start",1)
	GUI +MinSize
	; check for apps\Everything.db ?
;	if GUI_resize = 1
;		GUI +resize -MaximizeBox  ; +resize will activate the maximizebox, -MaximizeBox is to prevent that
	if GUI_autohide = 1
		SetTimer timer_autohide, 1000
	
	ifwinexist , %GUI_name%	; if the GUI already exists, just show it and do nothing else
	{
		GoSub GUI_show
		f_dbgtime(gen,dbg,A_LineNumber,"GUI","stop",1)
		return
	}
	
	; the two lines below are so the GUI does not flicker into a different spot before moving to it's saved position
	GUI +LastFound +ToolWindow	; to be able to set the transparency easily
	WinSet, Transparent, 0	; starting at 0 to prevent GUI flickering on start
	
	gui_w_edit 	:= 250
	gui_w_edit_s 	:= gui_w_edit + 30
	gui_w_edit2 	:= gui_w_edit + 37
	gui_w_hitlist	:= gui_w_edit + 135

	if gui_titlebar = 0
	{
		GUI -theme -sysmenu -caption +border
		GUI color,, %gui_scheme_control%
		GUI font, c%gui_scheme_font%
	}
	if gui_skin = 1
	{
		GUI Add, Picture, x4 y7 h28 w3 vgui_skin_left BackgroundTrans, %A_ScriptDir%\img\skin_left.png
		GUI Add, Picture, x285 yp hp wp vgui_skin_right BackgroundTrans, %A_ScriptDir%\img\skin_right.png
		GUI Add, Picture, x7 y8 h23 w%gui_w_edit_s% vgui_skin_back BackgroundTrans, %A_ScriptDir%\img\skin_back.png
		GUI Add, Picture, xp y5 h4 w%gui_w_edit_s% vgui_skin_top BackgroundTrans, %A_ScriptDir%\img\skin_top.png
		GUI Add, Picture, xp y29 h2 w%gui_w_edit_s% vgui_skin_bottom BackgroundTrans, %A_ScriptDir%\img\skin_bottom.png
		GUI Add, Picture, x9 y13 h16 w16 vtarget_icon gGUIContextMenu Icon1, %icon_shorthand%
		GUI Add, Edit, x30 y14 h12 w%gui_w_edit% -E0x200 vcommand_search gsearch section,
	}
	else
	{
		GUI Add, Picture, x7 y9 h16 w16 vtarget_icon gGUIContextMenu Icon1, %icon_shorthand%
		GUI Add, Edit, x30 y6 w%gui_w_edit% vcommand_search gsearch section r1,	
	}
	gui_xempty = 0
	if gui_xempty = 1
		GUI Add, Text, ys h17 w10 y8 vsub_clear ggui_xempty left , x	
	; row one of the main GUI (the simple portion, the command_search editbox, toggle simple/advanced and the settings)
	GUIControl, focus, command_search
	if advanced_border = 1
		GUI Add, Button, ys+1 h20 w72 vset_advanced gset_advanced border center, advanc&ed
	else
		GUI Add, button, ys+1 h21 w72 vset_advanced gset_advanced center, advanc&ed

	GUI Add, Picture, ys+3 h16 w16 vpreferences_icon gGUI2 Icon1, %icon_settings%	; this control to be moved through GUISize
	GUI Add, Button, ys-1 gcommand_run default hidden, OK

	; row two of the main GUI (the advanced portion, like the search_inside editbox)
	; needs to start shown, to get the coordinates for advanced/simple toggle
	GUI Add, Text, x30 h16 w60 vadvanced section, &Containing
	GUI Add, Edit, ys-3 w%gui_w_edit2% vsearch_inside gsearch section r1, %parameter% 	; the y of this control functions as the mark of the Y for the advanced section
	GUIControlGet, search_inside, Pos	; to determine what Y the advanced controls are at, needed for moving the controls
	
	; filter_extensions lets the user decide to filter the results based on extension
	GUI Add, Checkbox, x9 w16 h16 vfilter_extensions gset_filter_extensions Checked%filter_extensions% %advanced_status% section, 
	GUI Add, Text, x30 ys w60 r1 vfilter_extensions_text gset_filter_extensions_text %advanced_status%, E&xtensions 	; this control to be resized through GUISize
	GUI Add, Edit, ys-4 w%gui_w_edit2% r1 vlist_extensions gset_extensions right %advanced_status%, %list_extensions% 	; this control to be resized through GUISize

	; filter_folders lets the user decide to not show the folders
	GUI Add, Checkbox, xs w16 h16 vfilter_folders gset_filter_folders Checked%filter_folders% %advanced_status% section, 
	GUI Add, Text, x30 ys w60 r1 vfilter_folders_text gset_filter_folders_text %advanced_status%, Hide &Folders
	
	; filter_ignores lets the user decide to not show files with certain words
	GUI Add, Checkbox, ys w16 h16 vfilter_ignores gset_filter_ignores Checked%filter_ignores% %advanced_status% , 
	GUI Add, Text, ys w80 r1 vfilter_ignores_text gset_filter_ignores_text %advanced_status%, &Ignore list

	; restricted_mode lets the user only show hits in certain folder (pinned/startmenu/desktop)
	GUI Add, Checkbox, ys w16 h16 vrestricted_mode gset_restricted_mode Checked%restricted_mode% %advanced_status% , 
	GUI Add, Text, ys w80 r1 vrestricted_mode_text gset_restricted_mode_text %restricted_mode%, &Restricted mode
	
	; the listbox which will hold the results
	GUI Add, ListView, x7 r20 w%gui_w_hitlist% vhitlist gsub_lv_cmd AltSubmit -multi count%max_results% sort hidden, Name|ext|Path|Score
	GUIControlGet, hitlist, Pos		; to determine what Y the hitlist is at, needed for moving the controls
	GoSub select_hitlist
	if hide_extensions = 1	; hides the ext column
		LV_ModifyCol(2, 0)

	; the status line with information about the search time and selected file
	GUI Add, Text, x9 w%gui_w_hitlist% r1 vstatus_text hidden, Fill search field...
	GUIControlGet, status_text, Pos
	if GUI_statusbar = 0
		GUIControl, hide, status_text 
	; this next section hides/shows controls based on settings
	if search_advanced <> 1
		GoSub GUI_advanced_hide
	else
		GoSub GUI_advanced_show

	LV_ModifyCol(1,200) 	; resizes column 1
	GoSub sub_select			; takes care of the up/down when results are being shown

	GUI +MinSize ToolWindow +LastFound
	
	; make sure that the GUI is not out of bounds (for instance after resolution switch)
	GoSub GUI_check_bounds

	GUI Add, Picture, x5 y5 w1 h1 gMoveGui vBackground BackgroundTrans, ; %A_ScriptDir%\img\black.png ; black.png is for troubleshooting
	GoSub GUI_show
	; WinSet, TransColor, FF00FF, %GUI_Name%	; for the edges of the GUI
	f_dbgtime(gen,dbg,A_LineNumber,"GUI","stop",1)
return
MoveGui: ; berban : Allows for moving the GUI through the background image on the GUI
	if gui_easymove = 1
		PostMessage, 0xA1, 2,,, A ; berban
Return
GUI_hide:
	f_dbgtime(gen,dbg,A_LineNumber,"GUI_hide","start",3)
	CRITICAL ON		; critical so the fading is not interrupted by a hotkey starting the fadein
	if GUI_fade = 1
	{
		transparency = 255
		Loop 
		{
			GUI +LastFound
			transparency -= %transparency_step%
			WinSet, Transparent, %transparency%
			sleep 50
			if transparency <= 0
				break
		}
		transparency = 255
		WinSet, Transparent, %transparency%
	}
	GUI_hidden = 1
	GUI, hide
	CRITICAL OFF
	f_dbgtime(gen,dbg,A_LineNumber,"GUI_hide","stop",3)
return
gui_bg_resize:	; resizes the background label needed for easymove
	GuiControl, MoveDraw, Background, x0 y0 h1 w1 ; first, make the bg as small as possible
	GUI, Show, autosize	; then, autosize the GUI
	if GUIHeight <>
		GuiControl, MoveDraw, Background, % "x0 y0 h" GuiHeight " w" GuiWidth  ; resize the bg to the maximal size
return
GUISize:
	if A_GUIWidth =
		return
	GUIWidth := A_GUIWidth
	GUIHeight := A_GUIHeight
	gosub gui_bg_resize
return
GUI_show:
	f_dbgtime(gen,dbg,A_LineNumber,"GUI_show","start",3)
	CRITICAL ON		; critical so the fading is not interrupted by a hotkey starting the fadeout
	if GUI_hidden <> 0
	{
		ifwinexist, %GUI_name%
		{
			if GUI_fade = 1
				WinSet, Transparent, 0	; invisible to start
		}
	}
	if GUI_ontop = 1
		GUI +AlwaysOnTop
		
	GUI +MinSize445 ToolWindow ; +resize
	
	gosub gui_bg_resize
	GUI, Show, X%GUI_x% Y%GUI_y%, %GUI_name%

	OnMessage(0x200, "GUI_MOUSEOVER") ; makes it so mouseover controls in the GUI will show a tooltip

	if GUI_hidden <> 0
	{
		if GUI_fade = 1
		{
			GUI +LastFound	; to be able to set the transparency easily
			WinSet, Transparent, 0	; start at 0 : completely invisible
			transparency = 0
			Loop ; slowly loop until visibility is reached (default 255)
			{
				transparency += %transparency_step%
				WinSet, Transparent, %transparency%
				sleep 50
				if transparency >= 255
					break
			}
		}
		else
			WinSet, Transparent, 255
	}
	GUI_hidden = 0
	GUIControl, focus, command_search
	if gui_xempty = 1
		GUIControl,, sub_clear, x
	
	CRITICAL OFF
	f_dbgtime(gen,dbg,A_LineNumber,"GUI_show","stop",3)
return
GUI_save_pos:
	f_dbgtime(gen,dbg,A_LineNumber,"GUI_save_pos","start",3)
	if GUI_Hidden = 1	; to prevent the subroutine getting the pos while the GUI is hidden
		return
		
	; get position and dimensions of the GUI
	WinGetPos, GUI_x_new, GUI_y_new, GUI_w_new, GUI_h_new, %GUI_name%
	
	; if the location or dimension has not changed, we don't need to write the position
	if ( GUI_x_new <> %GUI_x% ) AND ( GUI_y_new <> %GUI_y% ) AND ( GUI_w_new <> %GUI_w% ) AND ( GUI_h_new <> %GUI_h% )
	{
		GUI_x := GUI_x_new
		GUI_y := GUI_y_new
		GUI_w := GUI_w_new
		GUI_h := GUI_h_new
		; make sure that the GUI is not out of bounds (for instance after resolution switch)
		GoSub GUI_check_bounds
		; write the position to the ini_file in case of restart
		IniWrite, %GUI_x%, %ini_file%, GUI, GUI_x
		IniWrite, %GUI_y%, %ini_file%, GUI, GUI_y
		IniWrite, %GUI_w%, %ini_file%, GUI, GUI_w
		IniWrite, %GUI_h%, %ini_file%, GUI, GUI_h
		f_dbgoutput(gen,dbg,A_LineNumber,3,A_ThisLabel "new position : x" GUI_x " y" GUI_y " w" GUI_w " h" GUI_h)
	}
	f_dbgtime(gen,dbg,A_LineNumber,"GUI_save_pos","stop",3)
return
GUI_check_bounds:
	f_dbgtime(gen,dbg,A_LineNumber,"GUI_check_bounds","start",3)
	; make sure that the GUI is not out of bounds (for instance after resolution switch)
	if GUI_x < 0
		GUI_x := 0
	if GUI_x + GUI_w > A_ScreenWidth
		GUI_x := A_ScreenWidth - GUI_w
	if GUI_y < 0
		GUI_y := 0
	if GUI_y + GUI_h > A_ScreenHeight
		GUI_y := A_ScreenHeight - GUI_h
	f_dbgtime(gen,dbg,A_LineNumber,"GUI_check_bounds","stop",3)
Return
GUI2:	; the GUI with the preferences and settings
	f_dbgtime(gen,dbg,A_LineNumber,"GUI2","start",1)
	GUI 2:destroy
	GUI 2:Default	 ; Default needed for the treeview
	GUI 2:+owner1  ; Will make it so preferences is always on top of the main GUI. This line has to be before any "GUI, 2:Add" is done, and after GUI 1: has been created.
	GUI 2:-alwaysontop
	
	ifwinexist , %GUI2_name%	; if the GUI already exists, just show it and do nothing else
	{
		GUI, 2:Show, AutoSize, %GUI2_name%
		f_dbgtime(gen,dbg,A_LineNumber,"GUI2","stop",1)
		return
	}
	; sort the menus in the preferences GUI
	GoSub GUI2menu
	; make the treeview
	GUI, 2:Add, TreeView, r25 w150 vpref_tree gpref_treesel section
	P1 := TV_Add("Program Options",0, "expand select")
	P1C1 := TV_Add("Settings", P1, "expand")  ; Specify P1 to be this item's parent.
	P1C1C1 := TV_Add("Results", P1C1)
	P1C1C2 := TV_Add("Custom", P1C1)
;	P1C1C3 := TV_Add("Hotkeys", P1C1)
	P1C1C4 := TV_Add("Plugins", P1C1)
	P1C2 := TV_Add("About", P1)
;	P2 := TV_Add("Troubleshooting Log", P2)
	GUIControlGet, pref_tree, Pos	; to determine what Y the top is
	
	; status bar which fills with text that are hopefully helpful to the user
	GUI, 2:Add, GroupBox, x10 w640 h35 section, Information
	GUI, 2:Add, Text, xs+10 yp+15 w620 r1 v2statusbar, %info_statusbar%
	OnMessage(0x200, "GUI2_MOUSEOVER") ; makes it so mouseover controls in the GUI will update the statusbar text
	
	GUI, 2:Add, Button, x300 yp-43 w100 vcheck_update_manual gcheck_update_manual, Check for updates
	GUI, 2:Add, Button, xp+135 YP w100 vGUI2_button_reload gsub_reload, Reload
	GUI, 2:Add, Button, xp+110 yp w100 default gGUI2_button_ok, OK	; default so it'll have focus, so an enter can just be pressed
		
	; get the selected tree item
	tree_sel_prev 		:= TV_GetSelection()
	TV_GetText(tree_sel_prev_text, tree_sel_prev)
	StringReplace, tree_sel_prev_text, tree_sel_prev_text, %A_Space%, _, ALL	; we'll be using the text  as a variable
	GroupBoxX := pref_treex + pref_treew + 10

	; "Program_Options" (shown at the start)
	GUI, 2:Add, GroupBox, x%GroupBoxX% y%pref_treey% vp1_1_general w480 r6 section, General
	
	GUI, 2:Add, Checkbox, xp+20 yp+20 vautostart gsub_autostart_toggle Checked%autostart%, %A_Space%%A_Space%Start &automatically when Windows starts
	GUI, 2:Add, Checkbox, xp yp+20 vcheck_for_updates_on_startup gGUI2_set_general Checked%check_for_updates_on_startup%, %A_Space%%A_Space%Check for &updates on startup
	GUI, 2:Add, Checkbox, xp yp+20 vtraytip gGUI2_set_general Checked%traytip%, %A_Space%%A_Space%Show &TrayTip when performing an action
	GUI, 2:Add, Checkbox, xp yp+20 vGUI_titlebar gGUI_titlebar Checked%GUI_titlebar%, %A_Space%%A_Space%Show &Titlebar on the search window
	GUI, 2:Add, Checkbox, xp yp+20 vGUI_easymove gGUI_easymove Checked%GUI_titlebar%, %A_Space%%A_Space%EasyMove the search window by left clicking on the background
	
	/*
	to Add:
	- open ini_file
	- portable (check for existing .ini file and ask user if they want to overwrite it with their current settings)
	- showing icon on taskbar "toolwindow" when active
	*/
	; programs to open with
	GUI 2:Add, GroupBox, xs w480 h200 vp1_1_progs, Programs
	
	GUI 2:Add, Text, xp+20 yp+25 w90 vbrowser_text section, Internet browser
	GUI 2:Add, Edit, xp+90 yp-3 vbrowser r1 w300 readonly, %browser%
	GUI 2:Add, Button, xp+305 yp-1 w50 vselect_browser gselect_browser, browse
	
	GUI 2:Add, Text, xs yp+35 w90 vtext_editor_text, Text editor
	GUI 2:Add, Edit, xp+90 yp-3 vtext_editor r1 w300 readonly, %text_editor%
	GUI 2:Add, Button, xp+305 yp-1 w50 vselect_text_editor gselect_text_editor, browse
	GUI 2:Add, Text, xs yp+28 w90 vtext_editor_text2, Use with
	GUI 2:Add, Edit, xp+90 yp-3 vtext_editor_ext r1 gGUI2_set w300, %text_editor_ext%
	
	GUI 2:Add, Text, xs yp+35 w90 vgraphics_editor_text, Graphics editor
	GUI 2:Add, Edit, xp+90 yp-3 vgraphics_editor r1 w300 readonly, %graphics_editor%
	GUI 2:Add, Button, xp+305 yp-1 w50 vselect_graphics_editor gselect_graphics_editor, browse
	GUI 2:Add, Text, xs yp+28 w90 vgraphics_editor_text2, Use with
	GUI 2:Add, Edit, xp+90 yp-3 vgraphics_editor_ext gGUI2_set r1 w300, %graphics_editor_ext%
	
	GUI 2:Add, Text, xs yp+35 w90 vfile_browser_text, File browser
	GUI 2:Add, Edit, xp+90 yp-3 vfile_browser r1 w300 readonly, %file_browser%
	GUI 2:Add, Button, xp+305 yp-1 w50 vselect_file_browser gselect_file_browser, browse
	
	; this is a list of all the variables on this treeview selection, need it to easily hide/show
	Program_Options = p1_1_general|autostart|traytip|GUI_titlebar|GUI_easymove|check_for_updates_on_startup|p1_1_progs|browser_text|browser|select_browser|text_editor_text|text_editor|select_text_editor|graphics_editor_text|graphics_editor|select_graphics_editor|file_browser_text|file_browser|select_file_browser|graphics_editor_text2|graphics_editor_ext|text_editor_text2|text_editor_ext	
	
	
	; "Settings"
	GUI, 2:Add, GroupBox, x%GroupBoxX% y%pref_treey% vp1c1_1 w480 h200 section hidden, Settings
	GUI, 2:Add, Checkbox, xp+20 yp+20 vGUI_ontop gGUI2_set Checked%GUI_ontop% hidden, %A_Space%%A_Space%Main window is &always on top
	GUI, 2:Add, Checkbox, xp yp+20 vGUI_fade gGUI2_set Checked%GUI_fade% hidden, %A_Space%%A_Space%&Fade the main window in and out
	GUI, 2:Add, Checkbox, xp yp+20 vGUI_statusbar gGUI2_set Checked%GUI_statusbar% hidden, %A_Space%%A_Space%&Status bar in the main window

	GUI, 2:Add, Checkbox, xp yp+20 vGUI_autohide gGUI2_set Checked%GUI_autohide% hidden, %A_Space%%A_Space%&Hide the main window when it loses focus
	GUI, 2:Add, Checkbox, xp yp+20 vGUI_hideafterrun gGUI2_set Checked%GUI_hideafterrun% hidden, %A_Space%%A_Space%H&ide the main window after running a command
	GUI, 2:Add, Checkbox, xp yp+20 vGUI_emptyafterrun gGUI2_set Checked%GUI_emptyafterrun% hidden, %A_Space%%A_Space%&Clear search text after running a command

	Settings = p1c1_1|GUI_ontop|GUI_autohide|GUI_fade|GUI_statusbar|GUI_hideafterrun|GUI_emptyafterrun
	
	
	; "Results"
	GUI, 2:Add, GroupBox, x%GroupBoxX% y%pref_treey% vp1c1c1_1 w480 h200 section hidden, Results
	GUI, 2:Add, Checkbox, xp+20 yp+20 vfilter_folders gGUI2_set Checked%filter_folders% hidden, %A_Space%%A_Space%Do not show folders in results
	;GUI, 2:Add, Checkbox, xp yp+20 vfilter_systemfiles gGUI2_set Checked%filter_systemfiles% hidden, %A_Space%%A_Space%Do not show system files in results
	;GUI, 2:Add, Checkbox, xp yp+20 vfilter_hiddenfiles gGUI2_set Checked%filter_hiddenfiles% hidden, %A_Space%%A_Space%Do not show hidden files in results
	GUI, 2:Add, Checkbox, xp yp+20 vfilter_extensions gGUI2_set Checked%filter_extensions% hidden, %A_Space%%A_Space%Only show certain extensions in the result (separate with `,)
	GUI, 2:Add, Edit, xp+20 yp+20 w420 vlist_extensions gGUI2_set_list r3 hidden, %list_extensions%
	GUI, 2:Add, Checkbox, xp-20 yp+55 vfilter_ignores gGUI2_set Checked%filter_ignores% hidden, %A_Space%%A_Space%Use ignore list for files and folders (separate with `,)
	GUI, 2:Add, Edit, xp+20 yp+20 w420 vlist_ignores gset_list_ignores r3 hidden, %list_ignores%
	GUI, 2:Add, Text, xp yp+3 vuse_history gGUI2_set Checked%use_history% hidden, use History

	; scoring

	GUI, 2:Add, GroupBox, x%GroupBoxX% ys+210 vp1c1c1_2 w480 h200 section hidden, Scoring
	GUI, 2:Add, Checkbox, xs+20 yp+20 vuse_score gGUI2_set Checked%use_score% hidden, %A_Space%%A_Space%Use scoring for files and folders (higher scores will be higher in the results list)
	GUI, 2:Add, Edit, xs+20 yp+20 vscore_history w40 number right hidden, %score_history%
	GUI, 2:Add, Text, xp+50 yp+3 vscore_history_text w250 hidden, History
	GUI, 2:Add, Edit, xs+20 yp+20 vscore_custom w40 number right hidden, %score_custom%
	GUI, 2:Add, Text, xp+50 yp+3 vscore_custom_text w250 hidden, Custom Files
	
	Results = p1c1c1_1|filter_folders|filter_systemfiles|filter_hiddenfiles|filter_extensions|list_extensions|filter_ignores|list_ignores|p1c1c1_2|use_score|score_history|score_history_text|score_custom|score_custom_text 
	
	; Custom
	GUI 2:Add, GroupBox, x%GroupBoxX% y%pref_treey% vp1c1c2_customfiles w480 h175 section hidden, Custom Files
	
	GUI 2:Add, ListView, xs+20 yp+20 r5 w440 vlv_custom_files glv_custom_file_click AltSubmit -multi hidden, Number|Path
	GoSub lv_custom_files_fill
	GUI 2:Add, Button, xp yp+120 w50 vlv_custom_file_add_existing glv_custom_file_add_existing hidden, Add
	GUI 2:Add, Button, xp+60 w50 vlv_custom_file_add_new glv_custom_file_add_new hidden, New
	GUI 2:Add, Button, xp+60 yp w50 vlv_custom_file_Edit glv_custom_file_Edit hidden, Edit
	GUI 2:Add, Button, xp+60 yp w50 vlv_custom_file_remove glv_custom_file_remove disabled hidden, Remove		; just removes the line, asks the user if the file needs to be deleted too
	
	Custom = p1c1c2_customfiles|lv_custom_files|lv_custom_file_add_existing|lv_custom_file_add_new|lv_custom_file_Edit|lv_custom_file_remove
	
	
	; Hotkeys
	GUI 2:Add, GroupBox, x%GroupBoxX% y%pref_treey% vp1c1c3_hotkeys w480 h360 section hidden, Hotkeys 
	
	GUI 2:Add, ListView, xs+20 yp+20 r8 w440 vlv_hotkeys glv_hotkeys_click AltSubmit -multi hidden, Name|Hotkey|Command|Mode
	GoSub lv_hotkeys_fill
	GUI 2:Add, Text, xp yp+180 w440 vhotkeys_text hidden, Enter or edit hotkey lines below.

	GUI 2:Add, Text, xp yp+25 w50 vc_name_text hidden , Name
	GUI 2:Add, Edit, xp+60 yp-3 w315 vc_name gc_update hidden, 
	GUI 2:Add, Button, xp+325 yp w50 vlv_hotkeys_Edit2 glv_hotkeys_Edit disabled hidden, Edit

	; look at shorthand2 for how to do this
	GUI 2:Add, Text, xs+20 yp+30 w50 vc_hotkey_text hidden, Hotkey
	GUI 2:Add, Hotkey, xp+60 yp-3 w315 vc_hotkey hidden uppercase, 
	GUI 2:Add, Button, xp+325 yp w50 vlv_hotkeys_add_new glv_hotkeys_add_new disabled hidden, Add
	GUI 2:Add, Checkbox, xs+80 yp+25 w60 vc_hotkey_mod_win hidden, %A_Space%%A_Space%WIN
	GUI 2:Add, Checkbox, xp+70 yp w60 vc_hotkey_mod_space hidden, %A_Space%%A_Space%SPACE

	GUI 2:Add, Text, xs+20 yp+30 w50 vc_path_text hidden, Command
	GUI 2:Add, Edit, xp+60 yp-3 w315 vc_path gc_update hidden,
	GUI 2:Add, Button, xp+325 yp w50 vc_path_browse gc_path_browse hidden, Browse

	; browse for path
	GUI 2:Add, Text, xs+20 yp+30 w50 vc_mode_text hidden, Mode
	GUI 2:Add, DropDownList, xp+60 yp-3 w315 vc_mode hidden, run|send|password
	GUI 2:Add, Button, xp+325 yp w50 vlv_hotkeys_remove glv_hotkeys_remove disabled hidden, Remove

	; add hotkey to which custom_file?
	; add button
	; clear button
	hotkeys = p1c1c3_hotkeys|lv_hotkeys|lv_hotkeys_add_new|lv_hotkeys_Edit|c_hotkey_mod_win|c_hotkey_mod_space|lv_hotkeys_remove|hotkeys_text|c_name|c_path|c_hotkey|c_mode|c_name_text|c_path_text|c_hotkey_text|c_mode_text|c_path_browse
	
	
	; "Plugins"
	GUI 2:Add, GroupBox, x%GroupBoxX% y%pref_treey% vp1c1c4_plugins w480 h370 section hidden, Plugins
	GUI 2:Add, ListView, xs+20 yp+20 r17 w440 vlv_plugins glv_plugins_click AltSubmit -multi checked hidden, Name|Version|Category|Description|Filename
	GoSub lv_plugins_fill
	GUI 2:Add, Button, xs+20 ys+340 w75 vlv_plugins_edit glv_plugins_edit hidden, Edit
	plugins = p1c1c4_plugins|lv_plugins|lv_plugins_edit

	
	; "Troubleshooting log"
	GUI, 2:Add, GroupBox, x%GroupBoxX% y%pref_treey% vp2 w480 h370 section hidden, Parsed log-file
	GUI, 2:Add, Button, xp+20 yp+20 w100 vlog_parse gsub_log_parse hidden, Show log file
	GUI, 2:Add, Button, xp+110 yp w100 vlog_export gsub_log_export hidden, Export log file
	GUI, 2:Add, Button, xp+110 yp w100 vlog_delete gsub_log_delete hidden, Delete log file

	GUI, 2:Add, Text, xs+20 yp+30 vlogging_text r1 hidden, Logging level:
	logging_level := logging+1	; so the right level is chosen in the dropdownlist below (which starts at 0, hence the +1)
	GUI, 2:Add, DropDownList, xp+70 yp-3 w40 vlogging gset_logging Choose%logging_level% hidden, 0|1|2|3|4|5|
	GoSub set_logging				; set the right logging level
	GUI, 2:Add, Text, xp+50 yp+3 w260 r1 vlogging_desc hidden, % logging_%logging%

	GUI, 2:Add, ListView, xs+20 yp+30 w440 h275 vloglistview hidden section, Time|Debug Print
	;GUI, 2:Add, TreeView, xs+20 yp+30 w440 h275 vlogtreeview hidden section
	;GUI, 2:TreeView, pref_tree		; tell the script to use the main treeview
	
	Troubleshooting_log = p2|log_parse|log_export|log_delete|logging_text|logging|logging_desc|loglistview
	
	GoSub get_treesel		; get current selected tree item
	
	GUI, 2:Show, AutoSize, %GUI2_name%
	f_dbgtime(gen,dbg,A_LineNumber,"GUI2","stop",1)
return
GUI2menu:
	Menu, FileMenu, Add, E&xit, GUI2Close
	Menu, HelpMenu, Add, &Check for updates, check_update_manual
	Menu, HelpMenu, Add, &Send Feedback, feedback
	Menu, HelpMenu, Add, &About..., about
	Menu, MyMenuBar, Add, &File, :FileMenu  ; Attach the two sub-menus that were created above.
	Menu, MyMenuBar, Add, &Help, :HelpMenu
	GUI, 2:Menu, MyMenuBar
return
GUI2Close:
	GUI 2:destroy
return
lv_hotkeys_click:
	f_dbgtime(gen,dbg,A_LineNumber,"lv_hotkeys_click","start",2)
	gosub lv_hotkeys_selected
	if A_GUIEvent = Normal
		GoSub lv_hotkey_edit	; fills the hotkey data into the right GUI controls for editing
	f_dbgtime(gen,dbg,A_LineNumber,"lv_hotkeys_click","stop",2)
return
lv_hotkeys_selected:
	; change the default GUI so the right listview is filled
	GUI, 2:Default
	; just to make sure we have the right listview, specify it here
	GUI, 2:ListView, lv_hotkeys
return
lv_plugins_selected:
	; change the default GUI so the right listview is filled
	GUI, 2:Default
	; just to make sure we have the right listview, specify it here
	GUI, 2:ListView, lv_plugins
return
lv_hotkey_edit:
    LV_GetText(c_name, A_EventInfo, 1)  ; Get the text from the row's first field.
    LV_GetText(c_hotkey, A_EventInfo, 2)  ; Get the text from the row's second field.
    LV_GetText(c_path, A_EventInfo, 3)  ; Get the text from the row's third field.
    LV_GetText(c_mode, A_EventInfo, 4)  ; Get the text from the row's fourth field.
	; fills the hotkey data from the lv_hotkey into the right GUI controls for editing
	GUIControl, 2:, c_name, %c_name%
	GUIControl, 2:, c_path, %c_path%

	if c_hotkey contains WIN
		GuiControl, 2:, c_hotkey_mod_win, 1
	else
		GuiControl, 2:, c_hotkey_mod_win, 0
	StringReplace, c_hotkey,c_hotkey,WIN,,		; gets rid of the WIN key, it's in a checkbox instead. not supported by the hotkey control

	if c_hotkey contains SPACE
		GuiControl, 2:, c_hotkey_mod_space, 1
	else
		GuiControl, 2:, c_hotkey_mod_space, 0
	StringReplace, c_hotkey,c_hotkey,SPACE,,	; gets rid of the spacebar key, it's in a checkbox instead. not supported by the hotkey control

	; because the GUI control for c_hotkey is a hotkey variant, it only accepts modifiers (^ (Control), ! (Alt), and + (Shift))
	StringReplace, c_hotkey,c_hotkey,-,,ALL	; gets rid of all the minuses in between modifiers
	StringReplace, c_hotkey,c_hotkey,+,,ALL	; gets rid of all the plusses in between modifiers
	StringReplace, c_hotkey,c_hotkey,SHIFT,+
	StringReplace, c_hotkey,c_hotkey,CTRL,^
	StringReplace, c_hotkey,c_hotkey,ALT,!

	GUIControl, 2:, c_hotkey, %c_hotkey%
	;GUIControl, 2:, c_mode, %c_mode%
	GuiControl, 2:ChooseString, c_mode, %c_mode%

	GuiControl, 2:enable, lv_hotkeys_Edit
	GuiControl, 2:enable, lv_hotkeys_remove
	GuiControl, 2:disable, lv_hotkeys_add_new
return
lv_hotkeys_add_new:
	GUI, 2:submit, nohide
	msgbox %c_name%`n%c_path%`n%c_hotkey%`n%c_mode%
return
lv_hotkeys_Edit:
return
lv_hotkeys_remove:
	GUI, 2:submit, nohide
	; need to convert the c_hotkey back... or will the c_name and c_path be sufficient?
	msgbox %c_name%|%c_path%|%c_hotkey%|%c_mode%
return
c_path_browse:
	FileSelectFile, c_path,3,, %app_name% : Select a file or folder
	if c_path <>
		GuiControl, 2:, c_path, %c_path%
return
c_update:
	GUI, 2:submit, nohide
	if ( c_path = "" ) or ( c_name = "" )
	{
		GuiControl, 2:disable, lv_hotkeys_Edit
		GuiControl, 2:disable, lv_hotkeys_remove
		GuiControl, 2:disable, lv_hotkeys_add_new
	}
	else
	{
		GuiControl, 2:enable, lv_hotkeys_Edit
		GuiControl, 2:enable, lv_hotkeys_remove
		GuiControl, 2:enable, lv_hotkeys_add_new
	}
return

lv_hotkeys_fill:
	f_dbgtime(gen,dbg,A_LineNumber,"lv_hotkeys_fill","start",2)
	critical on ; so the timer_load_custom does not interfere by making lv_hotkeys_list empty
	gosub lv_hotkeys_selected
	LV_Delete()
	; list_hotkeys
	Loop, parse, lv_hotkeys_list, `n, `r 
	{
		Loop , parse, A_LoopField , |
		{
			if A_Index = 1
				c_name := A_LoopField
			if A_Index = 2
				c_path := A_LoopField
			if A_Index = 3
				c_hotkey := A_LoopField
			if A_Index = 4
			{
				c_mode := A_LoopField
				StringUpper, c_hotkey, c_hotkey
				StringLower, c_mode, c_mode
				LV_Add("", c_name, c_hotkey, c_path, c_mode)	; Adds the results to the listview
			}
		}
	}
	; resize the columns, but no smaller than each header
	LV_ModifyCol(1,"AutoHdr")
	LV_ModifyCol(2,"AutoHdr")
	LV_ModifyCol(3,"AutoHdr")
	LV_ModifyCol(4,"AutoHdr")
	critical off
	f_dbgtime(gen,dbg,A_LineNumber,"lv_hotkeys_fill","stop",2)
return
lv_plugins_fill:
	gosub lv_plugins_selected
	loop, %A_ScriptDir%\plugins\*.ahk
	{
		if A_LoopFileName <>
		{
			GoSub sub_getplugindetails
			LV_Add("check", name, ver, cat, desc, A_LoopFileName)
		}
	}
	loop, %A_ScriptDir%\plugins\disabled\*.ahk
	{
		if A_LoopFileName <>
		{
			GoSub sub_getplugindetails
			LV_Add("uncheck", name, ver, cat, desc, A_LoopFileName)
		}
	}
	; name|version|category
	LV_ModifyCol(1,"Sort")	; to sort the active and disabled plugins alphabetically
	LV_ModifyCol(1,"AutoHdr")
	LV_ModifyCol(2,"AutoHdr")
	LV_ModifyCol(3,"AutoHdr")
	LV_ModifyCol(4,"AutoHdr")
	LV_ModifyCol(5,"AutoHdr")
return
lv_plugins_click:
	; get the name and state of the plugin (enabled or disabled)
	gosub lv_plugins_check	
	; check all plugins and check if they're in the right folder, if not, move them
	if selected_plugin in %checked_list%
	{
		IfNotExist %A_ScriptDir%\plugins\%plugin_name%
			FileMove, %A_ScriptDir%\plugins\disabled\%plugin_name%, %A_ScriptDir%\plugins\%plugin_name%
	}
	else
	{
		IfNotExist %A_ScriptDir%\plugins\disabled\%plugin_name%
			FileMove, %A_ScriptDir%\plugins\%plugin_name%, %A_ScriptDir%\plugins\disabled\%plugin_name%
	}
return
lv_plugins_check:
	ifWinNotExist %GUI2_name% ahk_class AutoHotkeyGUI
		return
	if A_GuiControl <> lv_plugins  ; Only do the following when there was a click inside the right ListView.
		return
	if A_GuiEvent <> I	; I means a row has changed by becoming checked/unchecked
		return
	gosub lv_plugins_selected
	selected_plugin := A_EventInfo
	LV_GetText(plugin_name, selected_plugin, 5)

	; check if the plugin is checked or unchecked
	RowNumber = 0  ; This causes the first loop iteration to start the search at the top of the list.
	Rows := LV_GetCount()	; get the total amount of rows
	checked_list :=
	Loop, %Rows%
	{
		RowNumber := LV_GetNext(RowNumber, "Checked")  ; Resume the search at the row after that found by the previous iteration.
		if not RowNumber  ; The above returned zero, so there are no more checked rows.
			break
		checked_list = %RowNumber%,%checked_list%
	}
	if selected_plugin = %old_selected_plugin%	; if it's the same one, don't bother continuing
		return
	old_selected_plugin := selected_plugin
return
lv_plugins_edit:
	gosub lv_plugins_check ; collect the name of the selected line, get the checked-state to determine the path.
	if selected_plugin in %checked_list%
		plugin_path = %A_ScriptDir%\plugins\
	else
		plugin_path = %A_ScriptDir%\plugins\disabled\
	; now open the plugin with the default text editor
	Run, "%text_editor%" "%plugin_path%%plugin_name%"
return
sub_getplugindetails:
; Name = Window Closer
; Category = Enhancement
; Version = 0.01
; Description = Checks for and closes specified windows, based on wintitle and ahk_class
	name = N/A
	cat = N/A
	ver = N/A
	desc = N/A
	Loop, 5	; read the first 5 lines of each plugin
	{
		FileReadLine, line, %A_LoopFileFullPath%, %A_Index%
		parse_plugin(line,"Name","Name")
		parse_plugin(line,"Version","ver")
		parse_plugin(line,"Category","cat")
		parse_plugin(line,"Description","desc")
	}
return
parse_plugin(line,descriptor,desc_short)
{
	if line contains %descriptor%%A_Space%=%A_Space%
		StringReplace, %desc_short%, line, `;%A_Space%%descriptor%%A_Space%=%A_Space%
}
lv_custom_files_fill:
	; fills the GUI2 listview with the custom_files
	; change the default GUI so the right listview is filled
	gosub lv_custom_selected
	GuiControl, -Redraw, lv_custom_files  ; disable redrawing
	LV_Delete()
	loop, %custom_files%
	{
		IniRead, custom_file_%A_Index%, %ini_file%, Files, custom_file_%A_Index%, %A_Space%
		if custom_file_%A_Index% =
			continue	; ignore empty vars
		else
		{
			Splitpath, custom_file_%A_Index% , command_name, command_path, command_ext	
			LV_Add("", "custom_file_" A_Index, custom_file_%A_Index%)	; Adds the results to the hitlist
		}
	}
	; resize the columns, but no smaller than each header
	LV_ModifyCol(1,"AutoHdr")
	LV_ModifyCol(2,"AutoHdr")
	GuiControl, +Redraw, lv_custom_files  ; Re-enable redrawing (it was disabled above).
return
lv_custom_file_click:
	f_dbgtime(gen,dbg,A_LineNumber,"lv_custom_file_click","start",2)
	gosub lv_custom_selected
	GUIControl, 2:enable, lv_custom_file_remove
	ifnotexist %command%
		GUIControl, 2:disable, lv_custom_file_Edit
	else
	{
		GUIControl, 2:enable, lv_custom_file_Edit
		if A_GUIEvent = DoubleClick
			GoSub lv_custom_file_edit
	}
	f_dbgtime(gen,dbg,A_LineNumber,"lv_custom_file_click","stop",2)
return
lv_custom_file_add_new:
	; adds a custom_file to the GUI2 listview and writes it to the ini_file	
	IniWrite, % custom_file_%empty_custom_number%, %ini_file%, Files, custom_file_%empty_custom_number%
	gosub lv_custom_files_fill	; repopulate the listview
return
lv_custom_file_add_existing:
	new_custom :=
	FileSelectFile, new_custom, 3, %A_ScriptDir%, %GUI_Name% : Select a new custom file (text file), *.txt
	ifexist %new_custom%
	{
		IniWrite, %new_custom%, %ini_file%, Files, custom_file_%empty_custom_number%
		gosub lv_custom_files_fill	; repopulate the listview
	}
return
lv_custom_file_edit:
	gosub lv_custom_selected
	if command =
		return
	if text_editor <>
		run, "%text_editor%" "%command%" , %command% , UseErrorLevel
	else
		run, edit "%command%" , %command% , UseErrorLevel	; this should use the system default
	GoSub sub_errorlevel		; needed so the msgbox contains the right feedback to the user pertaining the error
return
lv_custom_file_remove:
	; deletes the selected custom_file from the GUI2 listview and deletes it from the ini_file
	; first, get the selected row
	gosub lv_custom_selected
	if FileName = path	; which means no row is selected, but the header instead
	{
		msgbox,, %App_name%, First, you'll need to select a custom file in the list.
		return
	}
	; ask the user if the file needs to be deleted as well, but only if the file exists in the first place
	ifexist %command%
	{
		MsgBox, 259, %App_name%, Do you want to delete the old custom file?`n(%command%)	; 259 means it'll be a yes/no/cancel msgbox and the no button is selected by default
		IfMsgBox Yes
			FileRecycle, %command%
		IfMsgBox cancel
			return	; because inidelete is below this question, it does not get deleted from the ini_file if the user presses cancel
	}
	; find the custom_file number of the selected line
	loop, %custom_files%
	{
		IniRead, custom_file_%A_Index%, %ini_file%, Files, custom_file_%A_Index%, %A_Space%
		if custom_file_%A_Index% = %command%	; which custom_file is it?
		{
			; delete the line from the ini file
			IniDelete , %ini_file% , Files , %custom_key%
			break	; we found it, so the loop can be broken
		}
	}
	gosub lv_custom_files_fill	; repopulate the listview
return
lv_custom_selected:
	; change the default GUI so the right listview is filled
	GUI, 2:Default
	; just to make sure we have the right listview, specify it here
	GUI, 2:ListView, lv_custom_files
	FocusedRowNumber := LV_GetNext(0, "F") 		; Find the focused row.
	LV_GetText(custom_key,FocusedRowNumber,1)		; Get the key name in the first column.
	LV_GetText(command,FocusedRowNumber,2) 		; Get the text of the path in the second column.
return
sub_log_parse:
	GUI, 2:Default	; just to make sure we fill the right GUI
	GUI, 2:ListView, loglistview	; the listview to use in this subroutine
	GUIControl, 2:-Redraw, loglistview	; for performance filling entries
	ifexist %log_file%
	{
		LV_Delete() ; empty the listview
		Loop , read , %log_file%
		{
			Loop , parse, A_LoopReadLine , |
			{
				if A_LoopReadLine <>
				{
					; %A_Now%|%logging%|%loglevel%|finish|%name%`n, %log_file%
					; Add an iteration of the names?
					If A_Index = 1
					{
						StringReplace, date, A_LoopField, `r, , All	; needed?
						FormatTime 	, year, %date%, yyyy
						FormatTime 	, month, %date%, MM
						FormatTime 	, day, %date%, dd
						FormatTime 	, timestamp, %date%, yyyy-MM-dd HH:mm:ss
					}
					if A_Index = 2
						entry_logging := A_LoopField
					if A_Index = 3
						state := A_LoopField
					if A_Index = 4
						iteration := A_LoopField
					if A_Index = 5
						mode := A_LoopField
					if A_Index = 6
					{
						StringReplace, output, A_LoopField, `r, , All
						name = [%mode% - %iteration%] %output%
						LV_Add("",date,name)	; Adds the name to the day in question
					}
				}
			}
		}
	}
	GUIControl, 2:+Redraw, loglistview	; and back on
return
sub_log_delete:
	; this will delete the log file
	GUI, 2:Default	; just to make sure we fill the right GUI
	GUI, 2:ListView, loglistview	; the listview to use in this subroutine
	ifexist %log_file%
	{
		FileDelete %log_file%
	}
	LV_Delete() ; empty the listview
return
sub_log_export:
	; to basically ask the user to save the logfile (just do a filecopy)
return
sub_autostart_toggle:
	GUI, 2:submit, nohide
	GUI, 3:submit, nohide
	if autostart = 0
		GoSub sub_autostart_off
	Else
		GoSub sub_autostart_on
	IniWrite, %autostart%, %ini_file%, general, autostart
	; GoSub sub_checks ; to check menu and such
return
sub_autostart_on:
	; check if a lnk already exists
	IfExist %A_Startup%\%app_name%.lnk
	{
		; if yes:
		; Add something to check if the path is correct in the lnk
		FileGetShortcut, %A_Startup%\%app_name%.lnk , OutTarget
		if OutTarget <> %A_ScriptFullPath%
		{
			; the path is NOT correct:
			; ask user if he wants to replace the lnk with a newer version
			MsgBox, 4, %app_name% %app_version%,, A different startup lnk is detected (to %OutTarget%).`n`n Do you want to replace the link?
			IfMsgBox Yes
			{
				; if yes, delete and create
				FileDelete, %A_Startup%\%app_name%.lnk
				FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%app_name%.lnk
			}
			Else
			{
				; if no or cancel, Return
				Return
			}
		}
	}
	Else
	{
		; if no:
		; create a lnk 
		FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%app_name%.lnk
	}
	;check if the link has been made
	IfExist %A_Startup%\%app_name%.lnk
	{
		; lnk exists, get outTarget
		FileGetShortcut, %A_Startup%\%app_name%.lnk , OutTarget
		;if OutTarget = %A_ScriptFullPath%
		;	msgbox,, %app_name% %app_version%, Successfully Added %app_name% to the startup routine (%A_Startup%\%app_name%.lnk)
		autostart = 1
	}
	Else
	{
		; lnk does not exist, notify user
		msgbox,, %app_name% %app_version%, Failed to Add %app_name% to the startup routine (%A_Startup%\%app_name%.lnk)
	}
Return
sub_autostart_off:
	FileGetShortcut, %A_Startup%\%app_name%.lnk , OutTarget
	FileDelete, %A_Startup%\%app_name%.lnk
	IfNotExist %A_Startup%\%app_name%.lnk
	{
		if automatic <> 1
			msgbox,, %app_name% %app_version%, Successfully removed %app_name% from the startup routine (%A_Startup%\%app_name%.lnk)
		autostart = 0
	}
	Else
	{		
		if automatic <> 1
			msgbox,, %app_name% %app_version%, Failed to Remove %app_name% from the startup routine (%A_Startup%\%app_name%.lnk)
	}
Return

GUI_MOUSEOVER()
{
	static CurrControl, PrevControl, info_
	CurrControl := A_GUIControl
	If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
	{
        ToolTip  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 1000
        PrevControl := CurrControl
    }
    return

	DisplayToolTip:
		SetTimer, DisplayToolTip, Off
		ToolTip % info_%CurrControl%	; The leading percent sign tell it to use an expression.
		SetTimer, RemoveToolTip, 3000
	return

	RemoveToolTip:
		SetTimer, RemoveToolTip, Off
		ToolTip
	return
}

GUI2_MOUSEOVER()
{
	static CurrControl, PrevControl, info_
	CurrControl := A_GUIControl
	If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
	{
		;GUIControl,, 2statusbar, % "info_" CurrControl " : " info_%CurrControl%
		GUIControl,, 2statusbar, % info_%CurrControl%
		PrevControl := CurrControl
	}
	return
}
GUI2_button_ok:
	GUI, 2:Destroy
return
GUI2_set_general:
	; this subroutine writes the new variable to the ini_file
	GUI, 2:submit, nohide	; for some reason, otherwise the value doesn't get written right

	IniWrite, % %A_GUIControl%, %ini_file%, General, % A_GUIcontrol
	f_dbgoutput(gen,dbg,A_LineNumber,2,"gGUI2_set_general " A_GUIcontrol " = " %A_GUIcontrol%)
return
GUI2_set:
	; this subroutine writes the new variable to the ini_file
	GUI, submit, nohide		; else command_search will not be collected
	GUI, 2:submit, nohide	; for some reason, otherwise the value doesn't get written right

	GUIControl,1:, % A_GUIControl, % %A_GUIControl%	; change the checkboxes in the other GUI(s) as well
	if command_search <>
		GoSub search	; here be dragons! for some reason, "GoSub update_hitlist" or even "GoSub timer_execute_search" will not update the hitlist, so be it, this works ;)
	IniWrite, % %A_GUIControl%, %ini_file%, GUI, % A_GUIcontrol
	f_dbgoutput(gen,dbg,A_LineNumber,2,"gGUI2_set " A_GUIcontrol " = " %A_GUIcontrol%)
return
GUI2_set_list:
	if A_GUIEvent <> normal
		return
	GUI, 2:submit, nohide

	if command_search <>
		GoSub update_hitlist
	IniWrite, % %A_GUIControl%, %ini_file%, GUI, % A_GUIcontrol
	f_dbgoutput(gen,dbg,A_LineNumber,2,"gGUI2_set " A_GUIcontrol " = " %A_GUIcontrol%)
return
set_logging:
	; this subroutine sets the logging and updates the description
	GUI, 2:submit, nohide
	logging_level := logging
	if logging =
		IniRead, logging, %ini_file%, General, logging, 1
	GUIControl, 2:, logging_desc, % logging_%logging_level%
	IniWrite, %logging%, %ini_file%, General, logging
return
set_list_ignores:
	GUI, 2:submit, nohide
	; this subroutine saves the changes in the ignorelist to the ini_file
	stringreplace, list_ignores, list_ignores, `n,`,, ALL
	stringreplace, list_ignores, list_ignores, `,`, , `, , ALL	
	if command_search <>
		GoSub update_hitlist
	IniWrite, % %A_GUIControl%, %ini_file%, GUI, % A_GUIcontrol
	f_dbgoutput(gen,dbg,A_LineNumber,2,"gGUI2_set " A_GUIcontrol " = " %A_GUIcontrol%)
return
select_browser:
	FileSelectFile, browser,3, %browser%, %GUI_Name% : Select file
	ifexist %browser%
	{
		GUIControl, 2:, browser, %browser%
		IniWrite, %browser%, %ini_file%, programs, browser
	}
return
select_text_editor:
	FileSelectFile, text_editor,3, %text_editor%, %GUI_Name% : Select file
	ifexist %text_editor%
	{
		GUIControl, 2:, text_editor, %text_editor%
		IniWrite, %text_editor%, %ini_file%, programs, text_editor
	}
return
select_graphics_editor:
	FileSelectFile, graphics_editor,3, %graphics_editor%, %GUI_Name% : Select file
	ifexist %graphics_editor%
	{
		GUIControl, 2:, graphics_editor, %graphics_editor%
		IniWrite, %graphics_editor%, %ini_file%, programs, graphics_editor
	}
Return
select_file_browser:
	FileSelectFile, file_browser,3, %file_browser%, %GUI_Name% : Select file
	ifexist %file_browser%
	{
		GUIControl, 2:, file_browser, %file_browser%
		IniWrite, %file_browser%, %ini_file%, programs, file_browser
	}
return

get_treesel:
	tree_sel_curr := TV_GetSelection()
	TV_GetText(tree_sel_curr_text, tree_sel_curr)
	StringReplace, tree_sel_curr_text, tree_sel_curr_text, %A_Space%, _, ALL	; we'll be using the text as a variable
	; maybe Add an information text for these tree selections, too
return
pref_treesel:
	; this changes the options displayed of the preferences GUI, based on input in Treeview: pref_tree
	; TV_GetSelection(): Returns the selected item's ID number.
	if A_GUIEvent <> S  ; i.e. an event other than "select new tree item".
		return  ; Do nothing.

	GoSub get_treesel
	
	if ( tree_sel_curr_text = "" ) or ( tree_sel_prev_text = "")		; this variable will be empty when the subroutine gets run when the right GUI is not active
		return
		
	; first hide the options of the previously selected treeview item
	Loop, parse, %tree_sel_prev_text%, |
	{
		if A_LoopField = 
			break
		else
		{
			GUIControl, 2:hide, %A_LoopField%
			f_dbgoutput(gen,dbg,A_LineNumber,4,"hiding previous GUI control = " A_LoopField)
		}
	}
	
	; second, show the options of the currently selected treeview item
	Loop, parse, %tree_sel_curr_text%, |
	{
		if A_LoopField = 
			break
		else
		{
			GUIControl, 2:show, %A_LoopField%
			f_dbgoutput(gen,dbg,A_LineNumber,4,"showing current GUI control = " A_LoopField)
		}
	}

	; last, store current selection as previous, for future changes
	tree_sel_prev 		:= tree_sel_curr
	tree_sel_prev_text	:= tree_sel_curr_text
return
set_advanced:
	if search_advanced <> 1
	{
		search_advanced = 1
		GoSub GUI_advanced_show
	}
	else
	{
		search_advanced = 0
		GoSub GUI_advanced_hide
	}
	IniWrite, %search_advanced%, %ini_file%, GUI, search_advanced
return
GUI_advanced_show:
	GUIControl, show, advanced
	GUIControl, show, search_inside
	GUIControl, show, filter_extensions
	GUIControl, show, filter_extensions_text
	GUIControl, show, list_extensions
	GUIControl, show, filter_folders
	GUIControl, show, filter_folders_text
	GUIControl, show, filter_ignores
	GUIControl, show, filter_ignores_text
	GUIControl, show, restricted_mode
	GUIControl, show, restricted_mode_text
	
	; GUIControl,, filter_extensions_text, E&xtensions
	GUIControl,, set_advanced, simpl&e
	GUIControl, Move, hitlist, y%hitlisty%
	GUIControl, Move, status_text, y%status_texty%

	; gosub gui_bg_resize
	GUI, Show, AutoSize	; autosizes the GUI
return
GUI_advanced_hide:
	GUIControl, hide, advanced
	GUIControl, hide, search_inside
	GUIControl, hide, filter_extensions
	GUIControl, hide, filter_extensions_text
	GUIControl, hide, list_extensions
	GUIControl, hide, filter_folders
	GUIControl, hide, filter_folders_text
	GUIControl, hide, filter_ignores
	GUIControl, hide, filter_ignores_text
	GUIControl, hide, restricted_mode
	GUIControl, hide, restricted_mode_text
	
	GUIControl,, set_advanced, advanc&ed
	GUIControl, Move, hitlist, y%search_insidey%
	simple_status_y := search_insidey + hitlisth + 3
	GUIControl, Move, status_text, y%simple_status_y%

	; gosub gui_bg_resize
	GUI, Show, AutoSize	; autosizes the GUI
return
toggle_set_filter_extensions:
	filter_extensions := !filter_extensions
	GuiControl,, filter_extensions, %filter_extensions%
	gosub set_filter_extensions
return
set_filter_extensions_text:	; this can be optimised, like GUI2_set is
	GUI, submit, nohide
	filter_extensions := !filter_extensions
set_filter_extensions:
	GUI, submit, nohide
	GUIControl,2:, filter_extensions, %filter_extensions%
	if command_search <>
		GoSub update_hitlist
	IniWrite, %filter_extensions%, %ini_file%, GUI, filter_extensions
return
set_extensions:
	GUI, submit, nohide
	if command_search <>
		GoSub update_hitlist
	StringReplace, list_extensions, list_extensions, %A_Space%, `,, ALL
	IniWrite, %list_extensions%, %ini_file%, GUI, list_extensions
return
toggle_set_filter_folders:
	filter_folders := !filter_folders
	GuiControl,, filter_folders, %filter_folders%
	gosub set_filter_folders
return
set_filter_folders_text:
	GUI, submit, nohide
	filter_folders := !filter_folders
set_filter_folders:
	GUI, submit, nohide
	GUIControl,2:, filter_folders, %filter_folders%	
	if command_search <>
		GoSub update_hitlist
	IniWrite, %filter_folders%, %ini_file%, GUI, filter_folders
return
toggle_set_filter_ignores:
	filter_ignores := !filter_ignores
	GuiControl,, filter_ignores, %filter_ignores%
	gosub set_filter_ignores
return
set_filter_ignores_text:
	GUI, submit, nohide
	filter_ignores := !filter_ignores
set_filter_ignores:
	GUI, submit, nohide
	GUIControl,2:, filter_ignores, %filter_ignores%	
	if command_search <>
		GoSub update_hitlist
	IniWrite, %filter_ignores%, %ini_file%, GUI, filter_ignores
return
toggle_set_restricted:
	restricted_mode := !restricted_mode
	GuiControl,, restricted_mode, %restricted_mode%
	gosub set_restricted_mode
return
set_restricted_mode_text:
	GUI, submit, nohide
	restricted_mode := !restricted_mode
set_restricted_mode:
	GUI, submit, nohide
	GUIControl,2:, restricted_mode, %restricted_mode%	
	if command_search <>
		GoSub update_hitlist
	IniWrite, %restricted_mode%, %ini_file%, GUI, restricted_mode
return

sub_select:
	hotkey, IfWinActive, ahk_class AutoHotkeyGUI ;, % GUI_name		; so the hotkeys below only work when the script has focus (so does not interfere with normal up/down usage)
	hotkey, up, sub_up
	hotkey, down, sub_down
	hotkey, IfWinActive,
return
sub_up:	; fires when the users presses the up-arrow
	hasfocus :=
	GUIControlGet, hasfocus, FocusV ; retrieves the name of the focused control's associated variable.
	if hasfocus = search_inside ; if the hitlist or lower editbox is selected, tab to the command_search
	{
		GUIControl Focus, command_search
	}
	else if hasfocus = hitlist
	{
		FocusedRowNumber := LV_GetNext(0, "F") 			; Find the focused row.
		LV_GetText(FileName,FocusedRowNumber,col_name) 	; Get the text of the first field.
		if ( FocusedRowNumber = 1 ) or ( FocusedRowNumber = 0 )
		{
			if search_advanced = 1
				GUIControl Focus, search_inside
			else
				GUIControl Focus, command_search
		}
		else
		{
			Prev := FocusedRowNumber - 1
			LV_Modify(Prev, "Focus Select")
		}
	}
	f_dbgoutput(gen,dbg,A_LineNumber,3,A_ThisLabel " : " FocusedRowNumber filename)
return
sub_down:	; fires when the users presses the down-arrow
	GUI, submit, NoHide	; get the command_search variable
	if command_search =	; if it's empty, do nothing
		return

	hasfocus :=
	GUIControlGet, hasfocus, FocusV ; retrieves the name of the focused control's associated variable.
	if hasfocus = command_search ; if command_search has focus, go to search_inside editbox
	{
		if search_advanced = 1
			GUIControl Focus, search_inside
		else
		{
			GUIControl Focus, hitlist
			lv_focus = 1	; meaning the listview has focus
		}
	}
	else if hasfocus = search_inside ; if command_search has focus, go to search_inside editbox
	{
		GUIControl Focus, hitlist
		lv_focus = 1	; meaning the listview has focus
	}
	else if hasfocus = hitlist 
	{
		FocusedRowNumber := LV_GetNext(0, "F") 			; Find the focused row.
		LV_GetText(FileName,FocusedRowNumber,col_name) 	; Get the text of the first field.
		if FocusedRowNumber = 0
			FocusedRowNumber = 1	; to prevent the first row being selected twice
		Next := FocusedRowNumber + 1
		LV_Modify(Next, "Focus Select")
	}
	f_dbgoutput(gen,dbg,A_LineNumber,3,A_ThisLabel " : " FocusedRowNumber filename)
return

GUIContextMenu:
	f_dbgtime(gen,dbg,A_LineNumber,"GUIContextMenu","start",2)
	if A_EventInfo > 0	; the main window (GUI1) was right-clicked on a file, first give file-specific options
	{
		selected_row := A_EventInfo
		; collect data from which line was right-clicked
		LV_GetText(command_name,selected_row,1)
		LV_GetText(command,selected_row,3)
		Splitpath, command , , command_path, command_ext

		Menu, Context, Add, Open, command_run
		Menu, Context, Default, Open
		Menu, Context, Add, Open with..., command_run_with
		Menu, Context, Add, Open with arguments, command_run_args
		Menu, Context, Add, Open as admin, command_run_admin

		if text_editor <>
			Menu, Context, Add, Edit, GUI_edit
	
		Menu, Context, Add,
		Menu, Context, Add, Open with %text_editor_name%, GUI_def_edit
		Menu, Context, Add, Open with %graphics_editor_name%, GUI_def_gfx
		Menu, Context, Add, Open with %file_browser_name%, GUI_def_fbrowse

		Menu, Context, Add,
		Menu, Context, Add, Delete, GUI_Add_delete

		if command_name contains (custom)
			Menu, Context, Add, Delete from custom file, GUI_ADD_deletefromcustom	
		if use_history = 1
		{
			if command_name contains (history)
				Menu, Context, Add, Delete from history, GUI_ADD_deletefromhistory	
		}
		Menu, Context, Add,
		;Menu, Context, Add, Add Hotkey for %command%, GUI_Add_hotkey
		Menu, Context, Add, CopyPath, GUI_Add_copypath
		Menu, Context, Add,
		Menu, Context, Add, Properties, GUI_Add_properties
		Menu, Context, Add, Browse folder, GUI_Add_browse
		Menu, Context, Add,
	}

	Menu, Context, Add, Always on top, GUI_alwaysontop
	if GUI_ontop = 1
		Menu, Context, Check, Always on top	
	Menu, Context, Add, Autohide, GUI_autohide
	if GUI_autohide = 1
		Menu, Context, Check, Autohide
	Menu, Context, Add, Easymove, GUI_easymove
	if GUI_easymove = 1
		Menu, Context, Check, Easymove	
	Menu, Context, Add, Status bar, GUI_statusbar
	if GUI_statusbar = 1
		Menu, Context, Check, Status bar
	Menu, Context, Add, Title bar, GUI_titlebar
	if GUI_titlebar = 1
		Menu, Context, Check, Title bar

	Menu, Context, Add, 
	Menu, Context, Add, Check for updates, check_update_manual
	Menu, Context, Add, Preferences, GUI2
	Menu, Context, Icon, Preferences, %icon_settings%
	Menu, Context, Add, 
	Menu, Context, Add, Reload, sub_reload
	Menu, Context, Add, Exit, ExitSub
	Menu, Context, Show, %A_GUIX%, %A_GUIY%	
	Menu, Context, DeleteAll	; empties the context menu, else you'd get double entries
	f_dbgtime(gen,dbg,A_LineNumber,"GUIContextMenu","stop",2)
return
GUI_easymove:
	if GUI_easymove = 0
	{
		GUI_easymove = 1
		Menu, Context, Check, Always on top	
	}
	else
	{
		GUI_easymove = 0
		Menu, Context, Uncheck, Always on top
	}
	IniWrite, %GUI_easymove%, %ini_file%, GUI, GUI_easymove
return
GUI_alwaysontop:
	if GUI_ontop = 0
	{
		GUI_ontop = 1
		Menu, Context, Check, Always on top	
		GUI +AlwaysOnTop
	}
	else
	{
		GUI_ontop = 0
		Menu, Context, Uncheck, Always on top
		GUI -AlwaysOnTop
	}
	IniWrite, %GUI_ontop%, %ini_file%, GUI, GUI_ontop
return
GUI_autohide:
	if GUI_autohide = 0
	{
		GUI_autohide = 1
		Menu, Context, Check, Autohide
		SetTimer timer_autohide, 1000
	}
	else
	{
		GUI_autohide = 0
		Menu, Context, Uncheck, Autohide
		SetTimer timer_autohide, Off
	}
	IniWrite, %GUI_autohide%, %ini_file%, GUI, GUI_autohide
return
GUI_statusbar:
	if GUI_statusbar = 0
	{
		GUI_statusbar = 1
		Menu, Context, Check, Status bar
		GUIControl, show, status_text 
	}
	else
	{
		GUI_statusbar = 0
		Menu, Context, UnCheck, Status bar
		GUIControl, hide, status_text
	}
	GUI, Show, AutoSize, %GUI2_name%
	IniWrite, %GUI_statusbar%, %ini_file%, GUI, GUI_statusbar
return
GUI_titlebar:
	if GUI_titlebar = 0
	{
		GUI_titlebar = 1
		Menu, Context, Check, Title bar
		GUI +theme
		GUI +sysmenu 
		GUI +caption 
	}
	else
	{
		GUI_titlebar = 0
		Menu, Context, UnCheck, Title bar
		GUI -theme -sysmenu -caption +border
	}
	IniWrite, %GUI_titlebar%, %ini_file%, GUI, GUI_titlebar
return
GUI_edit:
	selected_program := getprogram(command_ext)
	if selected_program <>
		run, "%selected_program%" "%command%" , %command_path% , UseErrorLevel
	else
		run, edit "%command%" , %command_path% , UseErrorLevel
	GoSub sub_errorlevel		; needed so the msgbox contains the right feedback to the user pertaining the error
return
GUI_def_edit:
	run, "%text_editor%" "%command%" , %command_path% , UseErrorLevel
return
GUI_def_gfx:
	run, "%graphics_editor%" "%command%" , %command_path% , UseErrorLevel
return
GUI_def_fbrowse:
	run, "%file_browser%" "%command%" , %command_path% , UseErrorLevel
return
GUI_Add_copypath:
	clipboard = %command%
return
GUI_ADD_delete:
	FileRecycle, %command%
	LV_Delete(selected_row)
return
GUI_ADD_deletefromhistory:
	if history =
		fileread, history, %log_history%
	StringReplace, history, history, %command%`,,,ALL
	filedelete, %log_history%
	fileappend, %history%, %log_history%
	StringReplace, command_name, command_name, (history),,	; get rid of the (history) in the name
	LV_GetText(ext,selected_row,2) ; first, find the missing column information (the ext in the hidden column 2), the other info was already collected
	LV_GetText(score,selected_row,4)
	score -= score_history	; just in case the score was higher than just the score_history
	LV_Delete(selected_row)	; then, delete the row in question
	LV_Insert(selected_row, "", command_name, ext, command, score)	; finally, insert the row to replace the deleted row
return
GUI_ADD_deletefromcustom:
	StringReplace, command_name, command_name, (custom),,	; get rid of the (custom) in the name
	command_name := trim(command_name)	; trim any trailing spaces
	searchfor := command_name . "|" . command_path		; build the searchfor variable, making it unique
	; 1, see which custom file the line is in (FileRead > contains)
	Loop, %custom_files%
	{
		custom :=	; empty the variable
		if custom_file_%A_Index% =
			continue	; ignore empty vars
		ifexist % custom_file_%A_Index%
		{
			file := custom_file_%A_Index%
			FileRead, checkcustom, % file
			if checkcustom contains %searchfor%
			{
				loop, parse, checkcustom, `n
				{
					if A_LoopField not contains %searchfor%
						searchcontents .= A_LoopField "`n"
					; 2, omit the line in question
				}
				; 3, delete the custom file
				FileDelete, % file
				; 4, append the new contents
				FileAppend, % searchcontents, % file
				searchcontents :=	; 
				break	; end the loop
			}
		}
	}
	LV_GetText(ext,selected_row,2) ; first, find the missing column information (the ext in the hidden column 2), the other info was already collected
	LV_GetText(score,selected_row,4)
	score -= score_custom	; just in case the score was higher than just the score_history
	LV_Delete(selected_row)	; then, delete the row in question
	LV_Insert(selected_row, "", command_name, ext, command, score)	; finally, insert the row to replace the deleted row
return
GUI_Add_properties:
	run, properties "%command%", %command_path%, UseErrorLevel
return
GUI_Add_browse:
	ifexist %file_browser%
		run, "%file_browser%" "%command_path%", %command_path% , UseErrorLevel
	else
		run, explore "%command_path%", %command_path% , UseErrorLevel
	GoSub sub_errorlevel		; needed so the msgbox contains the right feedback to the user pertaining the error
return
search:
	SetTimer, timer_execute_search, -%search_delay% ; Delay after typing stops, to prevent the script from firing prematurely
	if gui_xempty = 1
		GUIControl,, sub_clear, x
return
sub_empty:
	GoSub select_hitlist	; makes sure we select the right listview to empty
	LV_Delete()	; empty the list to ready it for the results
	if command_search =
	{
		GUIControl, hide, hitlist
		GUIControl, hide, status_text
		if GUI_hidden <> 1	; only autosize when the GUI is shown
			GUI, show, autosize	; needed to resize the GUI
	}
	;GUIControl,, status_text, Fill search field...	; empty the status bar
return
gui_xempty:
	GUIControl,, command_search, 	; empties the command_search editbox
return
sub_clear:
	if GUI_hideafterrun = 1 			; hide the GUI after run
		GoSub GUIClose

	if GUI_emptyafterrun = 1 			; hide the GUI after run
		GUIControl,, command_search, 	; empties the command_search editbox

	command :=
	command_path :=
	command_ext :=
	command_noext :=
	command_ext_split :=
	arguments :=
return
timer_execute_search:
	Hotkey, ^x, find_interrupt
	; previously GUI_fill_results
	; this subroutine is where the script actually starts to search
	f_dbgtime(gen,dbg,A_LineNumber,"timer_execute_search","start",2)
	GUI, Submit, NoHide	; retrieve the variables from the GUI

	if command_search =	; no search entry, so no need to go further
	{
		GoSub sub_empty
		f_dbgtime(gen,dbg,A_LineNumber,"timer_execute_search","stop",2)
		return
	}
	if ( Substr(command_search,1,2) = "? " )
	{
		GoSub sub_empty
		f_dbgtime(gen,dbg,A_LineNumber,"timer_execute_search","stop",2)
		return
	}

	/*
	if command_search contains %command_search_old%	; no search entry, so no need to go further
	{
		command_search_old := command_search
		Loop % LV_GetCount()
		{
			LV_GetText(RetrievedText, A_Index, 1)
			LV_GetText(RetrievedText2, A_Index, 3)
			if RetrievedText not contains %command_search%
			{
				LV_delete(A_Index)  ; Select each row whose first field contains the filter-text.
				outputdebug Delete %A_Index% "%RetrievedText%" "%RetrievedText2%"
			}
		}
		f_dbgtime(gen,dbg,A_LineNumber,"timer_execute_search","stop",2)
		return
	}
	command_search_old := command_search
	*/

	newsearch = 1	; this variable is to keep track of the time spent searching
	search_time_start := A_TickCount
	
	if everythingPID = 0
	{
		run, %app_everything%,, hide , everythingPID
		sleep 500	; sleep 500 so everything.exe has time to start
	}
	
	; check if the temporary output file exists, if so, delete it
	ifexist %result_filename%
		FileDelete %result_filename%

	f_dbgoutput(gen,dbg,A_LineNumber,3,A_ThisLabel " : runwait " comspec " " debug " """ app_find """ " command_search """ -n " max_results " > " result_filename)
	f_dbgtime(gen,dbg,A_LineNumber,"app_find","start",2)
	; the actual search
	app_pid :=	; clear the variable before use
	find_text = Searching for a file

	if use_everything = 1
	{
		settimer, timer_check_find	; this timer sleeps 1 second and then starts checking for the existence of the %app_PID%
		runwait, %comspec% %debug% ""%app_find%" "%command_search%" -n %max_results% > "%result_filename%"" , %A_ScriptDir% , hide, app_PID
	}
	else
	{
		filelist:=ListMFTfiles(substr(command_search,1,2),substr(command_search,4),"|",true,num)
		fileappend, %filelist%, %result_filename%
	}
	
	f_dbgtime(gen,dbg,A_LineNumber,"app_find","stop",2)
			
	; only do this if the user typed something into the edit box to search inside the hits for
	if search_inside <> 
	{
		ifnotexist %app_findstr%
		{
			ifexist C:\WINDOWS\system32\findstr.exe
				FileCopy C:\WINDOWS\system32\findstr.exe, %app_findstr%
			else
				msgbox, , %app_name% %app_version%, Findstr.exe has not been found on your system.`n`nPlease get it and place it in %app_folder%. Searching inside files will not be possible until Findstr.exe is in %app_folder%.
		}
		; check if the temporary (filtered) output file exists, if so, delete it
		ifexist %result_filename2%
			FileDelete %result_filename2%

		f_dbgoutput(gen,dbg,A_LineNumber,3,comspec " " debug """" app_findstr """ /M /I /F:""" result_filename """ """ search_inside """ > """ result_filename2 """")
		f_dbgtime(gen,dbg,A_LineNumber,"app_findstr","start",2)
		; the search inside the search result files
		app_pid :=	; clear the variable before use
		find_text = Searching inside files
		settimer, timer_check_find	; this timer sleeps 1 second and then starts checking for the existence of the %app_PID%
		runwait, %comspec% %debug% ""%app_findstr%" /M /I /F:"%result_filename%" "%search_inside%" > "%result_filename2%"" , %A_ScriptDir% , hide, app_PID
		
		f_dbgtime(gen,dbg,A_LineNumber,"app_findstr","stop",2)
		FileDelete %result_filename%
		FileMove %result_filename2%, %result_filename%
	}
	
	; now read the (filtered) outputfile to a variable 
	; ifexist %result_filename%
	; {
		FileRead , results, %result_filename%
		Sort , results , U	; sort and make unique
		StringReplace, results , results , `r`n, `n, ALL	; needed for the listview
		f_dbgoutput(gen,dbg,A_LineNumber,3,A_ThisLabel " sorting results")
		GoSub update_hitlist		; this parses the results for the hitlist
	; }
	
	newsearch = 0
	f_dbgtime(gen,dbg,A_LineNumber,"timer_execute_search","stop",2)
return
timer_check_find:
	GUIControl,, status_text, %find_text% (ctrl x to cancel)
	loop
	{
		if app_pid =
			continue
		if hotkey <> 1
		{
			IfWinExist ahk_pid %app_PID%
				Hotkey, ^x, find_interrupt
			hotkey = 1
		}
		process, exist, %app_PID%
		if ( errorlevel == "0" ) ; search is done, break the loop
			break
	}
	hotkey = 0
	Hotkey, ^x, off
	SetTimer, timer_check_find, off
	GoSub update_status_text	; this updates the status_text	
return
find_interrupt:
	if ( app_PID == "" )
		return
	Hotkey, ^x, off
	WinKill, ahk_pid %app_PID%
	SetTimer, timer_check_find, off
	outputdebug %find_text% interrupted
	msgbox %find_text% (%app_PID%) killed!
	app_pid :=
return
update_hitlist:	; in a separate subroutine so we can call it when a filter is engaged/disengaged
	f_dbgtime(gen,dbg,A_LineNumber,"update_hitlist","start",2)
	GUIControl, 1:-Redraw, Hitlist
	GoSub sub_empty	; tidy up (hitlist and status-bar)

	hitcounter := 0	; for the hitcounter displayed on the status-bar
	misscounter := 0 ; for the filtered count displayed on the status-bar (the hits that are not shown because of extensions or hide folders)
	missfolders := 0
	missextensions := 0
	missignores	:= 0
	missrestricted := 0

	; search for hits in the custom_files (in the variable total_custom, that is)
	GoSub sub_command_guess_custom
	
	Loop , parse , results , `n	; Add the results from es.exe (ie: everything.exe)
	{
		if A_LoopField = Everything IPC service not running.
		{
			outputdebug Everything IPC service not running. Starting IPC service now`, please try again.
			run, %app_everything% -install_service
			break
		}
		command_path := A_LoopField
		SplitPath, command_path , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		if OutExtension contains %A_Space%
			OutExtension3 := SubStr(OutExtension,1,Instr(OutExtension,A_Space))
		if show_lnk = 0
		{
			if ( OutExtension = "lnk" ) OR ( OutExtension3 = "lnk" )
				FileGetShortcut, %command_path%, command_path, OutDir, OutArgs, OutDescription, OutIcon, OutIconNum, OutRunState
		}
		if OutFileName <>		; prevents empty lines
		{
			; first filter: if the user doesn't want folders to show up in his result
			if filter_folders = 1
			{
				if OutExtension =
				{
					if OutNameNoExt not contains .
					{
						missfolders += 1
						f_dbgoutput(gen,dbg,A_LineNumber,4,"update_hitlist: filter_folders is " filter_folders ": " OutNameNoExt " is not a file : no extension and no ""."" in the " OutNameNoExt )
						continue
					}
				}
			}
			; second filter: if the user only wants certain extensions (in %list_extensions%) to show up in his result
			if filter_extensions = 1
			{
				if OutExtension not in %list_extensions%
				{
					if filter_folders = 0
					{
						if OutExtension <>
						{
							missfolders += 1
							f_dbgoutput(gen,dbg,A_LineNumber,4,"update_hitlist: filter results is on, extension " OutExtension " is not in the list: " list_extensions )
							continue
						}
					}
					else
					{
						missextensions += 1
						f_dbgoutput(gen,dbg,A_LineNumber,4,"update_hitlist: filter results is on, extension " OutExtension " is not in the list: " list_extensions )
						continue
					}
				}
			}
			; third filter: any line with an ignored string in it needs to be skipped
			if filter_ignores = 1
			{
				if command_path contains %list_ignores% ; whenever Var contains one of the list items as a substring
				{
					missignores += 1
					f_dbgoutput(gen,dbg,A_LineNumber,4,"update_hitlist: filter ignores is on, a string of the list_ignores was found: " list_ignores )
					continue
				}
			}
			if restricted_mode = 1
			{
				if command_path not contains %restricted_list% ; whenever Var contains one of the list items as a substring
				{
					missrestricted += 1
					f_dbgoutput(gen,dbg,A_LineNumber,4,"update_hitlist: restricted mode is on, a string was found outside the restricted folders: " restricted_list )
					continue
				}
			}
			hitcounter += 1	; here for the filtered results, this subroutine only gets here if there is no filter applicable
			GoSub select_hitlist	; select the GUI and listview we want to fill
			if use_history = 1
			{
				ifexist %log_history%	; check if a history file exists, if not, no sense in doing the part below
				{
					; if history is empty, load it from the log
					if history =
						FileRead, history, %log_history%
					if InStr(history,OutDir . "\" . OutFileName) ; contains %command_search%
					{
						OutFileName = %OutFileName% (history)
						score := score_history
					}
				}
			}
			if not Instr(custom_list,command_path)		; to prevent doubles
				LV_Add("", OutFileName, OutExtension, command_path, score)	; Adds the results to the hitlist
			score :=
		}
	}	
	; outputdebug misscounter = 	%missfolders% folders + %missextensions% extensions + %missignores% ignored + %missrestricted% outside restricted
	misscounter += missfolders + missextensions + missignores + missrestricted

	if hitcounter > 0
	{
		GUIControl, show, hitlist
		GUIControl, show, status_text
	}
	else if misscounter > 0	; meaning, if hitcounter = 0
	{
		GUIControl, show, hitlist
		; do we want to hide the hitlist? If so, we need to move the status_text
		GUIControl, show, status_text
	}
	else	; both hitcounter and misscounter are 0, meaning nothing has been found
	{
		GUIControl, show, hitlist
		; move the status_text though
		GUIControl, show, status_text
	}
	
	if command_search =
	{
		GUIControl, hide, hitlist
		GUIControl, hide, status_text
	}
	gosub select_hitlist
	LV_ModifyCol(3,"AutoHdr") 	; resizes column 3
	if use_score = 1
	{
		LV_ModifyCol(4, "Integer")	; integers, so we can sort
		LV_ModifyCol(4, "SortDesc")	; sort on score, highest first
		LV_ModifyCol(4, "AutoHdr") 	; resizes column 4
	}

	GUI, Show, AutoSize
	GUIControl, 1:+Redraw, Hitlist
	
	GoSub update_status_text	; this updates the status_text
	OutFileName :=
	OutExtension :=
	command_path :=
	score := 

	f_dbgtime(gen,dbg,A_LineNumber,"update_hitlist","stop",2)
return
update_status_text:
	GoSub select_hitlist
	if hide_extensions = 1
		LV_ModifyCol(2, 0)
	else
		LV_ModifyCol(2) 			; resizes column 2
	LV_ModifyCol(3,"AutoHdr") 	; resizes column 3
	LV_Modify(1, "Select")	; select the first row

	; Adds search time information to the status bar
	if newsearch = 1
		elapsed_time := ROUND(( A_TickCount - search_time_start ) / 1000,3)
	if hitcounter = 1
		hits = hit
	else
		hits = hits
	if misscounter = 1
		misshits = hit is
	else
		misshits = hits are
	if elapsed_time = 1
		seconds = second
	else
		seconds = seconds
	if misscounter = 0
		text_search_time = Found %hitcounter% %hits% in %elapsed_time% %seconds%
	else
		text_search_time = Found %hitcounter% %hits% in %elapsed_time% %seconds% (%misscounter% %misshits% not shown)
	GUIControl,, status_text, %text_search_time%
return
select_hitlist:
	GUI, 1:Default	; just to make sure we fill the right GUI
	GUI, 1:ListView, Hitlist	; and the right listview in that GUI
return
sub_command_guess_custom:
	f_dbgtime(gen,dbg,A_LineNumber,"sub_command_guess_custom","start",2)
	custom_list :=	; do it here and not after, because we'll need the list to prevent doubles
	Loop, parse, total_custom, `n
	{
		if A_LoopField contains |run	; sends and passwords do not need to be listed in the hitlist
		{
			line := A_LoopField
			Loop, parse, A_LoopField, |
			{
				if A_Index = 1	; the name
				{
					If A_LoopField not contains %command_search% 	; -- so the parsing only takes place if the command_search is somewhere in the line
						break	; this breaks the last parsing loop, not the line by line loop of the total_custom variable
					name := A_LoopField
				}
				else if A_Index = 2	; the path
				{
					path := A_LoopField
					SplitPath, path , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
				}
				else if A_Index = 3	; the hotkey
				{
					hotkey := A_LoopField
				}
				else if A_Index = 4	; the c_choice
				{
					score += score_custom	; the score for being in a custom file 
					hitcounter += 1	; here for the filtered results, this subroutine only gets here if there is no filter applicable
					GoSub select_hitlist
					name := name " (custom)"
					LV_Add("", name, OutExtension, Path, Score)	; Adds the results to the hitlist	<<<< we need to add to this score for history, no? How will we solve this?
					custom_list .= path . ","
					score :=
				}
			}
		}
	}
	score :=
	line :=
	name :=
	hotkey :=
	path :=
	f_dbgtime(gen,dbg,A_LineNumber,"sub_command_guess_custom","stop",2)
return

sub_lv_cmd:
	f_dbgtime(gen,dbg,A_LineNumber,"sub_lv_cmd","start",3)
	GuiControlGet, Focused, FocusV	; determine if the hitlist has focus
	if A_GUIEvent = DoubleClick
		GoSub command_run
	else if GUI_statusbar = 1
	{
		if Focused = hitlist
		{
			GoSub select_hitlist	; to make sure the LV_GetText gets the information from the right listview
			FocusedRowNumber := LV_GetNext(0, "F") 			; Find the focused row.
			if FocusedRowNumber = 0
				FocusedRowNumber = 1
			LV_GetText(command_name,FocusedRowNumber,1)
			LV_GetText(command,FocusedRowNumber,3)
			if command_name <> name
			{
				FileGetSize, command_size , %command%, K
				if command_size <>
					text =  %command_size% KB
				FileGetTime, FileTime, %command%
				FormatTime, FileTime, %FileTime%   ; Since the last parameter is omitted, the long date and time are retrieved.
				text = %text% - Last Modified: %filetime%
			}
			else
				text = %text_search_time%
		}
		else
			text = %text_search_time%
		GUIControl, , status_text , %text%
	}
	f_dbgtime(gen,dbg,A_LineNumber,"sub_lv_cmd","stop",3)
return
getprogram(command_ext)
{
	global
	if command_ext in %text_editor_ext%
		selected_program := text_editor
	else if command_ext in %graphics_editor_ext%
		selected_program := graphics_editor
	return selected_program
}
command_run_args:
	InputBox, arguments, %app_name%: Run with arguments, Type the arguments you want to run the program with, , 400, 130, , , , , 
	gosub command_run
return
command_run_admin:
	RunAsAdmin = 1
	gosub command_run
	RunAsAdmin = 0
return
command_run_with:
	command_run_with = 1
	FileSelectFile, selected_program,3, , %GUI_Name% : Select file	to open with...
	gosub command_run
	command_run_with = 0
return
command_run:
	if command_search = "" ; needs to be here in case user presses enter on an empty search command
	{
		f_dbgtime(gen,dbg,A_LineNumber,"timer_execute_search","stop",3)
		return
	}
	else if ( SubStr(command_search,1,2) == "? " )
	{
		command_search := SubStr(command_search,3)
		; StringTrimLeft, command_search, command_search, 2
		StringReplace, command_search, command_search, %A_Space%, `%20, ALL
		run, https://www.google.com/#hl=en&output=search&sclient=psy-ab&q=%command_search%
		GoSub sub_clear
		f_dbgtime(gen,dbg,A_LineNumber,"timer_execute_search","stop",2)
		return
	}
	else if hitcounter = 0	; in some cases, a file cannot be found, but it can be run (like on Win7: regedit)
	{
		if TrayTip = 1
			TrayTip, Command executed, Starting %command_search%,%traytime%
		Splitpath, command_search , command_name, command_path, command_ext, command_name_noext
		RunAsUser(command_search, , command_path)
		f_dbgtime(gen,dbg,A_LineNumber,"timer_execute_search","stop",3)
		return
	}

	GoSub select_hitlist	; make sure the right listview has been selected
	FocusedRowNumber := LV_GetNext(0, "F") 	; Find the focused row.
	if FocusedRowNumber = 0		; no row was manually selected, so execute the first row
		FocusedRowNumber := 1

	LV_GetText(command, FocusedRowNumber, 3)
	
	Splitpath, command , command_name, command_path, command_ext, command_name_noext

	gosub sub_getextandrun	; this will see if there's arguments and split them off, it will also run the file with the arguments
return
timer_autohide:
	if GUI_autohide = 1
	{
		IfWinExist %GUI_name%
		{
			IniRead, logging, %ini_file%, General, logging, 1
			IfWinNotActive %GUI_name%
			{
				GoSub GUIClose	; this turns the timer off as well
				if timer_autohide <> 0
					f_dbgoutput(gen,dbg,A_LineNumber,4,"timer_autohide is inactive")
				timer_autohide = 0
			}		
			else	; so GUI exists and is active
			{
				if timer_autohide <> 1
					f_dbgoutput(gen,dbg,A_LineNumber,4,"timer_autohide is active")
				timer_autohide = 1
			}
		}
	}
return
sub_errorlevel:
	if A_LastError <> 0
	{
		if A_LastError = 2
			msgbox , , %app_name% , Error %A_LastError%: %error_2%`n`n"%command%" in "%command_path%"
		if A_LastError = 3
			msgbox , , %app_name% , Error %A_LastError%: %error_3%`n`n"%command%" in "%command_path%"
		if A_LastError = 4
			msgbox , , %app_name% , Error %A_LastError%: %error_4%`n`n"%command%" in "%command_path%"
		if A_LastError = 5
			msgbox , , %app_name% , Error %A_LastError%: %error_5%`n`n"%command%" in "%command_path%"
		if A_LastError = 15
			msgbox , , %app_name% , Error %A_LastError%: %error_15%`n`n"%command%" in "%command_path%"
		if A_LastError = 21
			msgbox , , %app_name% , Error %A_LastError%: %error_21%`n`n"%command%" in "%command_path%"
		if A_LastError = 25
			msgbox , , %app_name% , Error %A_LastError%: %error_25%`n`n"%command%" in "%command_path%"
		if A_LastError = 1155
			msgbox , , %app_name% , Error %A_LastError%: %error_1155%`n`n"%command%" in "%command_path%"
	}
return
check_update_manual:
/*
	name = %1%
	current_ver = %2%
	url = %3%
	silent = %4%
	logfile = %5%
	ahk_pid = %6%
*/
	; this fires when the users chooses to search for updates manually (it should notify the user even if there are no updates)
	run, "%app_updater%" "%A_ScriptFullPath%" %app_version% %update_url% 0 "%log_file%" %script_PID%

	IniWrite, %A_now%, %ini_file%, General, last_update
	f_dbgoutput(gen,dbg,A_LineNumber,3,"check_update_manual = last checked for update : " A_Now)
return
check_update_automatic:
	IniRead, last_update, %ini_file%, General, last_update,
	last_updated := A_Now - last_update	; the number of seconds since the last time the app checked for an update
	if last_updated < %update_interval%
	{
		f_dbgoutput(gen,dbg,A_LineNumber,1,"check_update_automatic = check for updates skipped`, last check " last_updated " seconds ago: updatecheck in " update_interval - last_updated " seconds")
		return
	}
	IniWrite, %A_Now%, %ini_file%, General, last_update
	f_dbgoutput(gen,dbg,A_LineNumber,1,"check_update_automatic = Checking for updates")
	; delete update text file, if it already exists
	ifExist %update_file%
		FileDelete %update_file%
		
	; download the file
	URLDownloadToFile, %update_url%, %update_file%
	; read the file (which should be in ini file format)
	IniRead, new_ver, %update_file%, Information, version, 0
	if new_ver > %app_version%
	{
		f_dbgoutput(gen,dbg,A_LineNumber,1,"check_update_automatic = new version found: " new_ver)
		MsgBox, 4, %app_name% %app_version%: updating %name%, A newer version is available: v%new_ver%.`nWould you like to download and install this new version?
		IfMsgBox Yes
			run, "%app_updater%" "%A_ScriptFullPath%" %app_version% %update_url% 1 "%log_file%" %script_PID%
	}
return
sub_reload:
	GoSub GUIESCAPE
	reload
return
feedback:
	Run, mailto:maestr0@gmx.net?subject=%app_name% %app_version% feedback
return
about:
	msgbox , , %app_name% %app_version%, %app_name% is a program to make finding and running files easier.`n`nIt is similar to programs like FindAndRunRobot and Launchy.`n`nYou can also bind hotkeys to certain files, folders and actions.`n`nAHK version: %A_AhkVersion%
return
first_time_gui:
	GUI, 3:Add, Text, section, Select your preferences.`nThese preferences can later be changed.
	GUI, 3:Add, Listview, ys vFirst_list h125 w275 Checked -Hdr, Name|variable
	GUI, 3:Add, Button, xs gfirst_time_cancel w75 section, &Cancel
	GUI, 3:Add, Button, x325 ys vfirst_time_back gfirst_time_back w75, < &Back 
	GUI, 3:Add, Button, x415 ys vfirst_time_next gfirst_time_next w75 default, &Next >
	GUI, 3:Add, Button, x415 ys vfirst_time_ok gfirst_time_ok w75 hidden, &Finish 
	gosub first_lv_1
	lv_page = 1
	GUI, 3:Show, autosize, %gui_name%: Setup wizard
return
first_lv_1:
	GUI, 3:Default	; just to make sure we fill the right GUI
	GUI, 3:ListView, First_list	; and the right listview in that GUI
	LV_ModifyCol(1, "270")
	LV_ModifyCol(2, "0")
	LV_Add("check", "Portable install", "portable")
	if portable = 0
		LV_Modify(1, "-Check")
	LV_Add("", "Start automatically when Windows starts", "autostart")
	if autostart = 0
		LV_Modify(2, "-Check")
	LV_Add("check", "Check for updates on startup", "check_for_updates_on_startup")
	if check_for_updates_on_startup = 0
		LV_Modify(3, "-Check")
	GUIControl, 3:Hide, first_time_back 
return
first_lv_2:
	GUI, 3:Default	; just to make sure we fill the right GUI
	GUI, 3:ListView, First_list	; and the right listview in that GUI
	LV_Add("check", "Main window is always on top", "gui_ontop")
	if gui_ontop = 0
		LV_Modify(1, "-Check")
	LV_Add("", "Fade the main window in and out", "gui_fade")
	if gui_fade = 0
		LV_Modify(2, "-Check")
	LV_Add("check", "Status bar in the main window", "gui_statusbar")
	if gui_statusbar = 0
		LV_Modify(3, "-Check")
	if portable = 0
	{
		LV_Add("check", "Create Program Group", "create_proggroup")
		if create_proggroup = 0
			LV_Modify(4, "-Check")
		LV_Add("", "Create Desktop Shortcut", "create_desktop")
		if create_desktop = 0
			LV_Modify(5, "-Check")
	}
return
first_lv_3:
	GUI, 3:Default	; just to make sure we fill the right GUI
	GUI, 3:ListView, First_list	; and the right listview in that GUI
	LV_Add("", "Show TrayTip when running a command", "TrayTip")
	if TrayTip = 0
		LV_Modify(1, "-Check")
	LV_Add("check", "Hide the main window when it loses focus", "gui_autohide")
	if gui_autohide = 0
		LV_Modify(2, "-Check")
	LV_Add("check", "Hide the main window after running a command", "GUI_hideafterrun")
	if gui_hideafterrun = 0
		LV_Modify(3, "-Check")
	LV_Add("check", "Clear search text after running a command", "gui_emptyafterrun")
	if gui_emptyafterrun = 0
		LV_Modify(4, "-Check")
	GUIControl, 3:Hide, first_time_next 
	GUIControl, 3:Show, first_time_ok
	GuiControl, 3:+Default, first_time_ok
return
first_time_info:	; gets the variables from each listview line, from the second column which is hidden
	GUI, 3:Default	; just to make sure we fill the right GUI
	GUI, 3:ListView, First_list	; and the right listview in that GUI
	Loop % LV_GetCount()
	{
		LV_GetText(RetrievedText, A_Index, 2)
		; the two lines below change the variable (in column 2) based on the checkbox
		SendMessage, 4140, A_Index - 1, 0xF000, SysListView321  ; 4140 is LVM_GETITEMSTATE.  0xF000 is LVIS_STATEIMAGEMASK.
		%RetrievedText% := (ErrorLevel >> 12) - 1
	}
return
first_time_back:
	gosub first_time_info	; get the info from the listview
	LV_Delete()	; empty the list to ready it for the new lines
	lv_page -= 1
	if lv_page = 0
		lv_page = 1
	GUIControl, 3:Hide, first_time_ok
	GUIControl, 3:Show, first_time_next
	GuiControl, 3:+Default, first_time_next
	gosub first_lv_%lv_page%
return
first_time_next:
	gosub first_time_info	; get the info from the listview
	LV_Delete()	; empty the list to ready it for the new lines
	lv_page += 1
	gosub first_lv_%lv_page%
	GUIControl, 3:Show, first_time_back 
return
first_time_cancel:
	IniWrite, %portable%, %A_ScriptDir%\portable.ini, General, portable
	first_time_setup = 0
	gosub sub_reload
return
first_time_ok:
	gosub first_time_info ; to retrieve the state of the checkboxes
	IniWrite, %portable%, %A_ScriptDir%\portable.ini, General, portable
	if portable = 1
	{
		ini_location	=	%A_ScriptDir%
		ini_file		=	%ini_location%\portable.ini
	}
	else	
	{
		ini_location	=	%A_AppData%\%app_name%
		ini_file		=	%ini_location%\%app_name%.ini
	}

	if create_proggroup = 1
	{
		ifnotexist %A_Programs%\%app_name%
			FileCreateDir %A_Programs%\%app_name%
		FileCreateShortcut, %A_ScriptFullPath%, %A_Programs%\%app_name%\%app_name%.lnk
	}
	if create_desktop = 1
		FileCreateShortcut, %A_ScriptFullPath%, %A_Desktop%\%app_name%.lnk

	IniWrite, %TrayTip%, %ini_file%, General, TrayTip
	IniWrite, %check_for_updates_on_startup%, %ini_file%, General, check_for_updates_on_startup
	IniWrite, %autostart%, %ini_file%, General, autostart
	if autostart = 1
		GoSub sub_autostart_on

	IniWrite, %GUI_ontop%, %ini_file%, GUI, GUI_ontop
	IniWrite, %GUI_fade%, %ini_file%, GUI, GUI_fade
	IniWrite, %GUI_statusbar%, %ini_file%, GUI, GUI_statusbar

	IniWrite, %GUI_autohide%, %ini_file%, GUI, GUI_autohide
	IniWrite, %GUI_hideafterrun%, %ini_file%, GUI, GUI_hideafterrun
	IniWrite, %GUI_emptyafterrun%, %ini_file%, GUI, GUI_emptyafterrun

	first_time_setup = 0
	gosub sub_reload
return
; http://www.autohotkey.com/forum/topic78053.html
RunAsUser(Target, Arguments="", WorkingDirectory="")
{
   static TASK_TRIGGER_REGISTRATION := 7   ; trigger on registration. 
   static TASK_ACTION_EXEC := 0  ; specifies an executable action. 
   static TASK_CREATE := 2
   static TASK_RUNLEVEL_LUA := 0
   static TASK_LOGON_INTERACTIVE_TOKEN := 3
   objService := ComObjCreate("Schedule.Service") 
   objService.Connect() 

   objFolder := objService.GetFolder("\") 
   objTaskDefinition := objService.NewTask(0) 

   principal := objTaskDefinition.Principal 
   principal.LogonType := TASK_LOGON_INTERACTIVE_TOKEN    ; Set the logon type to TASK_LOGON_PASSWORD 
   principal.RunLevel := TASK_RUNLEVEL_LUA  ; Tasks will be run with the least privileges. 

   colTasks := objTaskDefinition.Triggers
   objTrigger := colTasks.Create(TASK_TRIGGER_REGISTRATION) 
   endTime += 1, Minutes  ;end time = 1 minutes from now 
   FormatTime,endTime,%endTime%,yyyy-MM-ddTHH`:mm`:ss
   objTrigger.EndBoundary := endTime
   colActions := objTaskDefinition.Actions 
   objAction := colActions.Create(TASK_ACTION_EXEC) 
   objAction.ID := "7plus run"
   objAction.Path := Target
   objAction.Arguments := Arguments
   objAction.WorkingDirectory := WorkingDirectory ? WorkingDirectory : A_WorkingDir
   objInfo := objTaskDefinition.RegistrationInfo
   objInfo.Author := "7plus" 
   objInfo.Description := "Runs a program as non-elevated user" 
   objSettings := objTaskDefinition.Settings 
   objSettings.Enabled := True 
   objSettings.Hidden := False 
   objSettings.DeleteExpiredTaskAfter := "PT0S"
   objSettings.StartWhenAvailable := True 
   objSettings.ExecutionTimeLimit := "PT0S"
   objSettings.DisallowStartIfOnBatteries := False
   objSettings.StopIfGoingOnBatteries := False
   objFolder.RegisterTaskDefinition("", objTaskDefinition, TASK_CREATE , "", "", TASK_LOGON_INTERACTIVE_TOKEN ) 
}
GUICLOSE:
GUIESCAPE:
	GoSub GUI_save_pos	; saves the position and dimensions of the GUI
	GoSub GUI_hide
	SetTimer timer_autohide, off	; GUI has closed, so the autohide timer is no longer needed
return
ExitSub:
	GoSub GUI_save_pos	; saves the position and dimensions of the GUI
	FormatTime, TimeString,, yyyy-MM-dd HH:mm:ss
	f_dbgoutput(gen,dbg,A_LineNumber,0,"Closing " app_name " v" app_version " on " TimeString " " A_ExitReason )
	if ( A_ExitReason = "Exit" )	; everything does not have to closed on anything but exit
	{
		if everythingPID <>
			Process, Close, %everythingPID%
	}
	Process, Close, %PluginLoaderPID%
	exitapp