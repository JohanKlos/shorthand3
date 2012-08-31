/*
This script tests a plugin (.ahk file) it receives as a parameter
If the script finds a plugin that doesn't work (comes back with an error) the plugin is moved to a folder, causing
it not to be loaded anymore (plugins\disabled)
*/
	#SingleInstance, ignore	; allow more than one instance
	#NoTrayIcon
	app_name	= script tester
	app_ver	= 0.02
	
	plugin 	= %1%
	disabled	= %2%
	
	if plugin =	; check for required parameter
	{
		outputdebug %app_name% %app_ver%: Required parameter missing (plugin path + plugin name eg: c:\shorthand\plugin\sh_timer.ahk).
		exitapp
	}
	ifNotExist %disabled%
	{
		outputdebug %app_name% %app_ver%: Required parameter missing (disabled plugin folder eg: c:\shorthand\plugin\disabled).
		exitapp
	}
	SplitPath, plugin, plugin_name
	outputdebug %app_name% %app_ver%: testing %plugin_name% (%plugin%)
	; check if the plugin has the required lines: 
	fileread, plugin_contents, %plugin%
	if ( plugin_contents not contains "#ErrorStdOut" ) or ( plugin_contents not contains "#NoTrayIcon" )
	{
		outputdebug %app_name% %app_ver%: Required parameter ("#ErrorStdOut" and/or "#NoTrayIcon") missing in plugin %plugin%.
		gosub failed
	}
	else
	{
		; first, start a timer that looks for OutputVarPID, and closing it after a second
		OutputVarPID :=
		settimer, check
		; this won't work when there's settimers involved, so we need to look in the auto-run section of the script and disable any settimers there
		fileread, plugin_contents, %plugin%
		Stringreplace, plugin_contents, plugin_contents, settimer, `;settimer,,ALL	; disable all settimers
		ifexist %A_Temp%\testplugin.ahk
			FileDelete %A_Temp%\testplugin.ahk
		FileAppend, %plugin_contents%, %A_Temp%\testplugin.ahk
		plugin_contents :=
		OutputVarPID :=
		RunWait "%A_Temp%\testplugin.ahk", %A_ScriptDir%,,OutputVarPID
		; because we use RunWait, if we get to the next line, the plugin is considered faulty, this is why the plugin needs the #persistent line
		settimer, check, off
		gosub failed
	}
return
failed:
	outputdebug %app_name% %app_ver%: %plugin_name% is faulty: move to %disabled% (error 2)`n(%plugin%)
	ifExist %disabled%
		FileMove, %plugin%, %disabled%\%plugin_name%
exitapp

check:
	if OutputVarPID !=
	{
		Process, Exist, %OutputVarPID%
		if ErrorLevel = 0	; just a extra test if the plugin "hangs"
		{
			outputdebug %app_name% %app_ver%: %plugin_name% is faulty: move to %disabled% (error 1)`n(%plugin%)
			ifExist %disabled%
				FileMove, %plugin%, %disabled%\%plugin_name%
			exitapp
		}
		else
		{
			outputdebug %app_name% %app_ver%: %plugin% is good, no action
			Process, Close, %OutputVarPID%
			OutputVarPID :=
			exitapp
		}
	}
return