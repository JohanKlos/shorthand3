Plugins:
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
plugin_tester:
	ifnotexist %A_ScriptDir%\inc\plugin_tester.ahk
		return
	
	Loop, %A_ScriptDir%\Plugins\*.ahk	; check the active plugins and timestamps
	{
		FileGetTime, LastModified, %A_LoopFileLongPath%
		if A_Index = 1
			plugins_active_new = %A_LoopFileName%|%LastModified%
		else
			plugins_active_new = %plugins_active_new%,%A_LoopFileName%|%LastModified%
	}
	IniRead, plugins_active_old, %ini_file%, Plugins, List,
	; see if there was any change in a plugin
	if ( plugins_active_old <> plugins_active_new	) ; this means there was a change
	{
		f_dbgoutput(gen,dbg,A_LineNumber,3,A_ThisLabel " new or modified plugins found")
		IniWrite, %plugins_active_new%, %ini_file%, Plugins, List
		; instead of all, let's check only the plugins that were changed
		if plugins_active_old = ""
		{
			; no known good list, so check all plugins
			Loop, %A_ScriptDir%\Plugins\*.ahk
				runwait, "%A_AhkPath%" "%A_ScriptDir%\inc\plugin_tester.ahk" "%A_LoopFileLongPath%" "%A_ScriptDir%\plugins\disabled\"
		}
		else
		{
			; see which plugin was changed and just check that plugin
			loop, parse, plugins_active_new, `,
			{
				if A_LoopField not in %plugins_active_old%
				{
					StringLeft, OutputVar, A_LoopField, % InStr(A_LoopField, "|") - 1	; gets the filename
					runwait, "%A_AhkPath%" "%A_ScriptDir%\inc\plugin_tester.ahk" "%A_ScriptDir%\Plugins\%OutputVar%" "%A_ScriptDir%\plugins\disabled\"
				}					
			}
		}
	}
	else
		f_dbgoutput(gen,dbg,A_LineNumber,3,A_ThisLabel " no new plugins found")
return
MainScript:
	FileDelete, %A_ScriptDir%\Plugins.ahk
Return
