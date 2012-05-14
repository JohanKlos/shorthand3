; this function will check if the script should run in portable or in installed made
check_portable()
{
	global
	ifexist %A_ScriptDir%\portable.ini
	{
		IniRead, portable, %A_ScriptDir%\portable.ini, General, portable, 0	; portable 0 means not portable, so ini_location will be in the users A_Appdata 
		first_time_setup = 0
	}
	else
	{
		first_time_setup = 1
		gosub first_time_gui
		IniWrite, 0, %A_ScriptDir%\portable.ini, General, portable
	}
		
	if portable = 1
	{
		ini_location	=	%A_ScriptDir%
		ini_file		=	%ini_location%\portable.ini
		tempfolder 	= 	%A_ScriptDir%\temp
	}
	else	
	{
		tempfolder 	=	%A_Temp%\shorthand
			
		ifnotexist %A_AppData%\%app_name%
		{
			FileCreateDir %A_AppData%\%app_name%
			if ErrorLevel = 1
			{
				ini_location = %tempfolder%\%app_name%
				msgbox, , %app_name% %app_version%, There was a problem creating a required folder: "%A_AppData%\%app_name%". All files will now be stored in "%ini_location%".
				FileCreateDir %ini_location%
			}
		}
		else
			ini_location	=	%A_AppData%\%app_name%
		ini_file	=	%ini_location%\%app_name%.ini
	}
	ifnotexist %tempfolder%
		FileCreateDir %tempfolder%
	plugin_folder = %ini_location%\plugins
	plugin_folder_disabled = 	%A_ScriptDir%\plugins\disabled
return
}