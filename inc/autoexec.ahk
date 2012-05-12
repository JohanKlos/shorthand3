	; This file contains the autoexecute section of the script.
; #Warn All 
#Warn UseUnsetLocal, off		; doesn't warn when an unset LOCAL variable is used 

app_name			= Shorthand
app_version		= 3.00.012
app_author			= Johan "Maestr0" Klos
if A_IsCompiled <> 1 ; when not compiled, assume it's a beta
{
	beta			= beta
	update_url		= http://www.famklos.nl/shorthand/version_beta.txt
}
else
	update_url		= http://www.famklos.nl/shorthand/version.txt

FormatTime, TimeString,, yyyy-MM-dd HH:mm:ss
f_dbgoutput(gen,dbg,A_LineNumber,0,"Starting " app_name " v" app_version " on " TimeString)

; for correct functioning of shorthand (to be able to run the extra apps), the script/app needs to be run as admin
if not A_IsAdmin
{
 	run *runAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
	ExitApp
}

#Persistent
#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#MaxThreadsPerHotkey 1		; enable correction on accidental press of several hotkeys (only last pressed hotkey will fire)
OnExit, ExitSub				; when script exits, go to subroutine ExitSub
Process, Priority,, High 	; increase performance for Hotkeys, Clicks, or Sends while the CPU is under heavy load
SetBatchLines -1 				; maximum speed for loops
SetWorkingDir %A_ScriptDir%	; unconditionally use its own folder as its working directory
SetWinDelay,2					; for smooth resizing
SendMode InputThenPlay 		; Recommended for new scripts due to its superior speed and reliability
DetectHiddenWindows ON
SetTitleMatchMode 3			; 3: A window's title must exactly match WinTitle to be a match.

script_PID := DllCall("GetCurrentProcessId")	; needed for the updater (to waitclose the pid)

GUI_name			= %app_name% %app_version% %beta%
GUI2_name			= %app_name% : Preferences

	f_dbgtime(gen,dbg,A_LineNumber,"Bootup","start",0) ; sub_time shows in outputdebug how long a certain function/subroutine takes to run
	GoSub check_portable	; this checks %A_ScriptDir%\portable.ini sets paths in the app_folder (=portable) or not (= not portable)
	if first_time_setup = 1
		return
		
	if beta = ""
		IniWrite, %app_version%, %ini_file%, General, version

	GoSub Read_variables
	GoSub Read_ini
	GoSub Plugins
	GoSub plugin_tester

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
	
	SetTimer, timer_load_custom, 1000 ; this checks the modified date/time of the custom_files and reloads them if they differ from the last load
	SetTimer, timer_autohide, 1000
	if check_for_updates = 1
		SetTimer, check_update_automatic, %update_interval%
	
	Hotkey, IfWinActive, ahk_pid %script_PID%
		Hotkey, !E, set_advanced
		Hotkey, !F, toggle_set_filter_folders
		Hotkey, !X, toggle_set_filter_extensions
		Hotkey, !I, toggle_set_filter_ignores
		Hotkey, !R, toggle_set_restricted
	Hotkey, IfWinActive
	#include %A_ScriptDir%\inc\debugging_f.ahk	; for debugging purposes

	#include *i %A_ScriptDir%\plugins		; make it so all includes will automatically look in this folder
	#include *i %A_ScriptDir%\Plugins.ahk	; this file is empty but filled by the label "plugins"
	f_dbgtime(gen,dbg,A_LineNumber,"Bootup","stop",0)
