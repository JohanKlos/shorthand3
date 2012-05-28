	; This file contains the autoexecute section of the script.
; #Warn All 
#Warn UseUnsetLocal, off		; doesn't warn when an unset LOCAL variable is used 

app_name			= Shorthand
app_version		= 3.00.012
app_author			= Johan "Maestr0" Klos
gen					:= Object()
gen.app_name		:= app_name
gen.app_version	:= app_version

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

icon_shorthand	= %A_ScriptDir%\img\icon_shorthand.ico
Menu, Tray, icon, %icon_shorthand%

if first_time_setup = 1
	return
	
if beta = ""
	IniWrite, %app_version%, %ini_file%, General, version