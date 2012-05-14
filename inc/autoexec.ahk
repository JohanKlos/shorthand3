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

GUI_name			= %app_name% %app_version% %beta%
GUI2_name			= %app_name% : Preferences
icon_shorthand	= %A_ScriptDir%\img\icon_shorthand.ico
Menu, Tray, icon, %icon_shorthand%

	f_dbgtime(gen,dbg,A_LineNumber,"Bootup","start",0) ; sub_time shows in outputdebug how long a certain function/subroutine takes to run
	if first_time_setup = 1
		return
		
	if beta = ""
		IniWrite, %app_version%, %ini_file%, General, version
		
	Hotkey, IfWinActive, ahk_pid %script_PID%
		Hotkey, !E, set_advanced
		Hotkey, !F, toggle_set_filter_folders
		Hotkey, !X, toggle_set_filter_extensions
		Hotkey, !I, toggle_set_filter_ignores
		Hotkey, !R, toggle_set_restricted
	Hotkey, IfWinActive

	f_dbgtime(gen,dbg,A_LineNumber,"Bootup","stop",0)