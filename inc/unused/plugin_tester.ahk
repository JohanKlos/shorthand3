/*
This script tests a plugin (.ahk file) it receives as a parameter
If the script finds a plugin that doesn't work (comes back with an error) the plugin is moved to a folder, causing
it not to be loaded anymore (plugins\disabled)
*/
	#SingleInstance, ignore	; allow more than one instance
	#NoTrayIcon
	app_name	= script tester
	app_ver	= 0.01
	
	plugin 	= %1%
	disabled	= %2%
	
	if plugin =	; check for required parameter
	{
		outputdebug %app_name% %app_ver%: Required parameter (plugin path\name.ahk) missing.
		exitapp
	}
	outputdebug %app_name% %app_ver%: testing %plugin%
	SplitPath, plugin, plugin_name
	
	; first, start a timer that looks for OutputVarPID, and closing it after a second
	settimer, check, 1000
	OutputVarPID :=
	RunWait "%plugin%", %A_ScriptDir%,,OutputVarPID
	; because we use RunWait, if we get to the next line within a second, the plugin is faulty
	outputdebug %app_name% %app_ver%: %plugin% is faulty `n move to %disabled%
	ifExist %disabled%\
		outputdebug FileMove, %plugin%, %disabled%\%plugin_name%
exitapp

check:
	if OutputVarPID =
		return
	Process, Exist, %OutputVarPID%
	if ErrorLevel = 0	; just a extra test if the plugin "hangs"
	{
		outputdebug %app_name% %app_ver%: %plugin% is faulty `n move to %disabled%
		ifExist %disabled%\
			outputdebug FileMove, %plugin%, %disabled%\%plugin_name%
	}
	else
	{
		outputdebug %app_name% %app_ver%: %plugin% is good, append to load-list
		FileAppend, `n%plugin%, %A_ScriptDir%\plugin_list.txt
		Process, Close, %OutputVarPID%
		OutputVarPID :=
		exitapp
	}
return