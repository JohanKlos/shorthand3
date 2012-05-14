/*
This script basically loads all the plugins after they've been vetted by the main script.
The main script will check all plugins and put move any non-working ones into a subfolder called "plugins\disabled".
Because plugins may contain a "return", a list of #includes will not work, as it will stop after the first #include.

Berbans' method overcomes this by first doing a gosub label before including the files....
*/
#Persistent
#SingleInstance Force
#ErrorStdOut				; to prevent errors annoying the users
#NoTrayIcon
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
#include *i %A_ScriptDir%\plugin_list.ahk
return

/*
LoadM:
	; thanks to Berban for this one!
	FileGetSize, Plugins, %A_ScriptDir%\Plugins.ahk
	If !Plugins {
		Plugins =
		Loop, %A_ScriptDir%\Plugins\*.ahk
		{
			Plugins .= "|" SubStr(A_LoopFileName, 1, -1 - StrLen(A_LoopFileExt)), Includes .= "`n#Include, *i %A_ScriptDir%\Plugins\" A_LoopFileName
		}
		StringReplace, Plugins, Plugins, %A_Space%, _, All
		StringTrimLeft, Plugins, Plugins, 1
		Plugins = Plugins = %Plugins%`nLoop, Parse, Plugins, |`n`tIf IsLabel(A_LoopField)`n`t`tGosub `%A_LoopField`%`nGoto MainScript%Includes%
		FileAppend, %Plugins%, %A_ScriptDir%\Plugins.ahk
		Reload
		ExitApp
	} 
	Else 
	{
		FileDelete, %A_ScriptDir%\Plugins.ahk
		FileAppend, , %A_ScriptDir%\Plugins.ahk
		FileSetAttrib, +H, %A_ScriptDir%\Plugins.ahk
	}
Return
MainScript:
	FileDelete, %A_ScriptDir%\Plugins.ahk
Return
*/