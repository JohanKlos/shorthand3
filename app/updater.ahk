/*
	updater program
	- 
*/

source = %1%
current_ver = %2%
url = %3%
silent = %4%
logfile = %5%
ahk_pid = %6%

#Persistent
#SingleInstance Force
#NoEnv

app_name = Updater
app_version = 0.04

	if ahk_pid =
	{
;		MsgBox, , %app_name% %app_version%, You did not supply any arguments. Please use the following syntax:`n"Full path of app to update" "current version" "update URL" "Silent" "Logfile to append to" "PID of old version"`n`nfor example:`n%A_ScriptName% 0.01 http://www.microsoft.com/version.txt 1 "logfile.log" 7112
		MsgBox, , %app_name% %app_version%, You did not supply any arguments. See the supplied help file for more information.
		ExitApp
	}
	
	SplitPath , source , OutFileName, OutDir, OutExtension, name, OutDrive

	temp_folder = %OutDir%\temp\update
	ini_file = %temp_folder%\update.txt

	app_zip = %A_ScriptDir%\7za.exe

	ifnotexist %temp_folder%
		FileCreateDir %temp_folder%

	gosub Gui
return

gui:
	; progress bar
	Gui, Add, Progress, w515 h20 vMyProgress -Smooth section 
	; listview
	Gui, Add, ListView, xs w515 r10 nosort readonly, Time|Message

	Gui, Add, Button, xs+285 w100 vCancel gCancel, Cancel
	Gui, Add, Button, xs+400 yp w100 vOk gOk default, OK
	
	Gui, Show,, %app_name% %app_version%: updating %name%
	gosub check	; starts checking
return

Ok:
	Gui, hide
return
	
progress_add:
	i ++
	outputdebug update iteration: %i% 
	GuiControl,, MyProgress, +16
return
progress_finish:
	GuiControl,, MyProgress, 100
	GuiControl, hide, Cancel
	GuiControl,, Ok, Finish 
return

Check:
	; notify user of current step	
	FormatTime, Time,, yyyy-MM-dd HH:mm:ss
	LV_Add("",Time,"Checking for updates for " name " v" current_ver)
	LV_ModifyCol(1,120)	; autosize the columns
	LV_ModifyCol(2,375)	; autosize the columns
	gosub progress_add	

	; delete update text file, if it already exists
	ifExist %ini_file%
		FileDelete %ini_file%
		
	; download the file
	URLDownloadToFile, %url%, %ini_file%
	if errorlevel = 1	; if there's an error in the download
	{
		FormatTime, Time,, yyyy-MM-dd HH:mm:ss
		LV_Add("",Time,"There was an error checking for updates. Please try again later.")
		gosub progress_finish
		pause ;exitapp	; or maybe go to the GUI instead
	}
	
	; read the file (which should be in ini file format)
	FormatTime, Time,, yyyy-MM-dd HH:mm:ss
	IniRead, new_ver, %ini_file%, Information, version, 0
	if new_ver > %current_ver%
	{
		IniRead, date, %ini_file%, Information, date, 
		LV_Add("",Time,"A newer version was found: v" new_ver " (released: " date ")")
		if silent <> 1	; if not silent, then ask the user if they want to install the new version
		{
			MsgBox, 4, %app_name% %app_version%: updating %name%, A newer version has been found: v%new_ver%.`nWould you like to download and install this new version?
			IfMsgBox No
			{
				FormatTime, Time,, yyyy-MM-dd HH:mm:ss
				LV_Add("",Time,"A newer version has been found, but the user decided not to download it currently.")
				gosub progress_finish
				exitapp
			}
			else
				silent = 1
		}
		LV_Add("",Time,"Downloading update-file now.")
		gosub progress_add	
		IniRead, file, %ini_file%, Information, file, 0
		FileDelete %ini_file%
		
		ifexist %temp_folder%\update.zip
			FileDelete %temp_folder%\update.zip
		URLDownloadToFile, %file%, %temp_folder%\update.zip
		if errorlevel = 1	; if there's an error in the download
		{
			FormatTime, Time,, yyyy-MM-dd HH:mm:ss
			LV_Add("",Time,"There was an error downloading the update. Please try again later.")
			gosub progress_finish
			pause ;exitapp	; or maybe go to the GUI instead
		}
		ifexist %temp_folder%\update.zip
		{
			FormatTime, Time,, yyyy-MM-dd HH:mm:ss
			LV_Add("",Time,"Download successful. Now unpacking and updating.")
			gosub progress_add

			FormatTime, Time,, yyyy-MM-dd HH:mm:ss
			LV_Add("",Time,"Unpacking update files.")
			gosub progress_add	
			FormatTime, Time,, yyyy-MM-dd HH:mm:ss
			LV_Add("",Time,"Installing new version: v" new_ver ".")
			; do an ifexist and delete
			; when the runwait is working, make it minimised
			runwait, %app_zip% e -r -y "%temp_folder%\update.zip", %temp_folder%, hide
			gosub progress_add
			
			; clean the now unnecessary update file
			FileDelete %temp_folder%\update.zip

			FormatTime, Time,, yyyy-MM-dd HH:mm:ss
			LV_Add("",Time,"All update files unpacked successfully.")
			gosub progress_add	
			FormatTime, Time,, yyyy-MM-dd HH:mm:ss
			LV_Add("",Time,"Closing old version of " name ".")
			WinClose, ahk_pid %ahk_pid% 	; performs better than "process, close"
;RunWait %comspec% /c "TASKKILL /F /IM %ProcName%",, hide ; just an example.
;winkill?
;			if errorlevel = 1
;				MsgBox, , %app_name% %app_version%: updating %name%, There was a problem closing the old instance of %name% (PID: %ahk_pid%).`nPlease close it manually and press "OK".

			gosub progress_add	

			FormatTime, Time,, yyyy-MM-dd HH:mm:ss
			LV_Add("",Time,"Backing up old version.")
			ifexist backup_%OutFileName%
				FileDelete backup_%OutFileName%
			FileMove , %OutFileName% , backup_%OutFileName%
			gosub progress_add	
			
			FormatTime, Time,, yyyy-MM-dd HH:mm:ss
			LV_Add("",Time,"Installing updated files.")
			FileMove, %temp_folder%\*.*, %OutDir%\*.* , 1	; 1 means overwrite all
			FormatTime, Time,, yyyy-MM-dd HH:mm:ss
			LV_Add("",Time,"All updated files installed correctly.")
			gosub progress_add	
			LV_Add("",Time,"Now starting new version.")
			Run, %OutFileName%
			LV_Add("",Time,"Update finished. You can now close this window.")
			gosub progress_finish
			
			MsgBox, , %app_name% %app_version%: updating %name%, Update finished. You can now close this window.
			exitapp
			}	
	}
	else
	{
		LV_Add("",Time,"No newer version found. You have the most recent version.")
		MsgBox, , %app_name% %app_version%: updating %name%, No newer version found. You have the most recent version.
		gosub progress_finish
		exitapp
	}	
return

; add a logfile entry with information about what the updater did and found?
Cancel:
Exit:
	exitapp