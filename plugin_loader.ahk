/*
	This script loads all the plugins after they've been vetted by plugin.ahk.
	The main script will check all plugins and put move any non-working ones into a subfolder called "plugins\disabled".
	Because plugins may contain a "return", a list of #includes will not work, as it will stop after the first #include.
*/
#Persistent				; this script is persistent and will be automatically closed by plugin.ahk
#SingleInstance Force
#ErrorStdOut				; to prevent errors annoying the users
#NoTrayIcon				; no icon needed, plugin.ahk will close the script when needed
#NoEnv  					; Recommended for performance and compatibility with future AutoHotkey releases.

ini_file = %1%
if ini_file =
	return

IniRead, Plugins, %ini_file%, Plugins, LoadList,	; collect the previously checked variable from the ini file

Loop, Parse, Plugins, |
{
	if A_LoopField =
		break
	Gosub %A_LoopField%
}
#include *i %A_ScriptDir%\plugin_list.ahk		; *i to prevent errors if the file does not exist for some reason
return
