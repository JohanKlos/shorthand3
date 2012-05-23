; general object and global variables
gen					:= Object()
gen.app_name		:= app_name
gen.app_version	:= app_version
gen.ini_location	:=	A_ScriptDir
gen.ini_file		:=	gen.ini_location "\portable.ini"
gen.tempfolder 	:= 	A_ScriptDir "\temp"

GUI_name			= %app_name% %app_version% %beta%
GUI2_name			= %app_name% : Preferences

app_folder			= %A_ScriptDir%\app
check_exist_folder(app_folder)

app_find 			= %app_folder%\es.exe			; commandline utility for everything.exe
app_everything	= %app_folder%\Everything.exe	; needs to be resident for es.exe to work
app_findstr		= %app_folder%\findstr.exe		; windows standard tool to search inside files
app_updater		= %app_folder%\updater.exe		; updater executable
plugin_loader 	= %A_ScriptDir%\plugin_loader.ahk

img_folder			= %A_ScriptDir%\img
check_exist_folder(img_folder)
; icon_shorthand	= %img_folder%\icon_shorthand.ico	; moved to as high in the script as possible, to prevent flickering
icon_settings		= %img_folder%\icon_shorthand_settings.ico

log_folder			= %A_ScriptDir%\log
check_exist_folder(log_folder)
log_file			= %log_folder%\%app_name%_%A_UserName%.log
log_history		= %log_folder%\history_%A_UserName%.log
; or in tempfolder?

result_filename 	= %tempfolder%\output_everything.txt
result_filename2	= %tempfolder%\output_findstr.txt
update_file		= %tempfolder%\update.txt

error_1155 		= No application is associated with the specified file for this operation. 
error_15 			= The system cannot find the drive specified. 
error_2 			= The system cannot find the file specified. 
error_21 			= The device is not ready. 
error_25 			= Windows cannot find the network path.`nVerify that the network path is correct and the destination computer is not busy or turned off.`nIf Windows still cannot find the network path, contact your network administrator.
error_3 			= The system cannot find the path specified. 
error_4 			= The system cannot open the file. 
error_5 			= Access is denied.

logging_0		 	= no logging
logging_1		 	= normal logging (settings)
logging_2		 	= extended logging (each function, start and stop, except timers)
logging_3 			= extended logging (also steps inside each function)
logging_4 			= extended logging (also steps inside each function)
logging_5 			= timer logging

info_target_icon = Click this icon for some quick settings.
info_set_advanced = (Alt-E) Click this to toggle between simple and advanced interface.
info_command_search = (Alt-Space) Type your search entry here`, the list below will be populated with the hits.
info_preferences_icon = Preferences and settings for %app_name%.

info_statusbar = Help information about options will appear here when you mouse-over each option.
info_autostart = If checked`, %app_name% will put a shortcut in your Start menu startup folder.
info_check_for_updates_on_startup = If checked`, %app_name% will check online for updates`, every time %app_name% is started.
info_check_update_manual = This will immediately check online for updates for %app_name%.
info_traytip = This will show a tray tip (near your clock in your taskbar) with the started program.
info_GUI_titlebar = This will show or hide the Titlebar on the main search window.
info_GUI_easymove = This will allow to move the main search window by left clicking and dragging.
info_logging = Meant for debugging purposes. This changes the messages that show up in a debugger (like Sysinternals' dbgview.exe).
info_browser = This program will be used to open certain files opened through %app_name%.
info_text_editor = This program will be used to open certain files opened through %app_name%.
info_graphics_editor = This program will be used to open certain files opened through %app_name%.
info_file_browser = This program will be used to open certain files opened through %app_name%.	
info_GUI_ontop = The main %app_name% window will stay on top of all other windows.
info_GUI_fade = The main %app_name% window will fade in and out of sight. Note: takes slightly longer to show and hide the main window.
info_GUI_statusbar = If checked`, Adds a statusbar underneath the results in the main %app_name% window.
info_GUI_autohide = If checked`, the main %app_name% window will hide as soon as it loses focus.
info_GUI_hideafterrun = If checked`, the main %app_name% window will hide after a command is run.
info_GUI_emptyafterrun = If checked`, the search text in the main %app_name% window will be cleared after a command is run.
info_filter_folders = If checked`, the folders will not show up in the results.
info_filter_extensions = If checked`, only listed extensions will show up in the results. If folders are not filtered out, they will still show up.
info_filter_ignores = Any file or folder which has one of the listed strings`, will not show up in the results.

read_ini()
{
	global
Read_ini:	
	f_dbgtime(gen,dbg,A_LineNumber,"Read_ini","start",1)

	IniRead, logging, %ini_file%, General, logging, 1						; logging determines which outputdebugs can be seen (with dbgview for instance: http://technet.microsoft.com/en-us/sysinternals/bb896647 )
	IniRead, append_to_logfile, %ini_file%, General, append_to_logfile, 0	; if 1, it'll add debugging to a logfile
	IniRead, debugging, %ini_file%, General, debugging, 0					; Adds /k in command prompts, pausing them before continuing
	if debugging	=	1
		debug		=	/k
	else
		debug		=	/c
	IniRead, TrayTip, %ini_file%, General, TrayTip, 0						; if 1 a traytip is shown when performing a command (send/run)

	IniRead, empty_delay, %ini_file%, General, empty_delay, 60				; *PLACEHOLDER* delay to empty the search field after x seconds of being idle

	IniRead, last_update, %ini_file%, General, last_update, %A_Space%		; the time when last was checked for an update
	IniRead, check_for_updates_on_startup, %ini_file%, General, check_for_updates_on_startup, 1	; automatically check for updates on startup
	IniRead, check_for_updates, %ini_file%, General, check_for_updates, 1	; automatically check for updates at %update_interval% intervals
	IniRead, update_interval, %ini_file%, General, update_interval, 600000 ; how often to scan for updates (default: every hour)
	IniRead, autostart, %ini_file%, General, autostart, 0					; places a link in the startup menu of the current user
	IniRead, max_custom, %ini_file%, General, max_custom, 20				; the maximum number of custom_files it'll look for

	IniRead, GUI_x, %ini_file%, GUI, GUI_x, 0									; x position for the main GUI
	IniRead, GUI_y, %ini_file%, GUI, GUI_y, 0									; y position for the main GUI
	IniRead, GUI_w, %ini_file%, GUI, GUI_w, 447								; width for the main GUI
	IniRead, GUI_h, %ini_file%, GUI, GUI_h, 127								; height for the main GUI

	IniRead, search_delay, %ini_file%, GUI, search_delay, 250				; delay before searching to prevent searching at every keystroke

	IniRead, use_history, %ini_file%, GUI, use_history, 1					; 1 : keep track of what is opened/run with shorthand, allows scoring and combobox in GUI
	IniRead, use_score, %ini_file%, GUI, use_score, 0						; 1 : use scoring to change the hitlist
	IniRead, score_history, %ini_file%, Score, score_history, 100			; files in log_history appear at the top of the hitlist
	IniRead, score_custom, %ini_file%, Score, score_custom, 75				; "run" files in a custom_file

	IniRead, text_editor_ext, %ini_file%, GUI, text_editor_ext, %A_Space%	; list of extensions to open with the specified text editor
	if text_editor_ext =
		text_editor_ext = txt,rtf,ini,log
		
	IniRead, graphics_editor_ext, %ini_file%, GUI, graphics_editor_ext, %A_Space%	; list of extensions to open with the specified graphics editor
	if graphics_editor_ext =
		graphics_editor_ext = jpg,png,gif,bmp,tiff

	IniRead, max_results, %ini_file%, GUI, max_results, 10000				; maximum results to show, too large a number will make it slower

	IniRead, filter_extensions, %ini_file%, GUI, filter_extensions, 0		; filters the results based on extensions in a comma separated list (%list_extensions%)
	IniRead, list_extensions, %ini_file%, GUI, list_extensions, %A_Space%	; list of extensions to show
	if list_extensions =
		list_extensions = exe,bat,doc,docx,xls,xlsx,txt,rtf,lnk,zip,rar,html
	IniRead, hide_extensions, %ini_file%, GUI, hide_extensions, 1			; 1 means the column with the extension is hidden
	IniRead, filter_folders, %ini_file%, GUI, filter_folders, 0				; 1 : no folders will be shown in the results
	IniRead, filter_ignores, %ini_file%, GUI, filter_ignores, 0				; hits with any of the ignored strings in it will not show up in results
	IniRead, list_ignores, %ini_file%, GUI, list_ignores, %A_Space%		; ignored strings
	if list_ignores =
		list_ignores = prefetch,cache

	IniRead, show_lnk, %ini_file%, GUI, show_lnk, 0							; when 0, the results will show the path to the actual file, instead of the .lnk filename

	IniRead, restricted_mode, %ini_file%, GUI, restricted_mode, 1			; 1 means it'll only show hits in one of the restricted folders
	A_TaskbarPinned = %AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar
	restricted_list = %A_Desktop%,%A_DesktopCommon%,%A_StartMenu%,%A_StartMenuCommon%,%A_TaskbarPinned%
		
	IniRead, GUI_ontop, %ini_file%, GUI, GUI_ontop, 1						; if 1 the search window will be always on top when not hidden
	IniRead, GUI_fade, %ini_file%, GUI, GUI_fade, 0							; if 1 fades the search window in and out
	IniRead, transparency_step, %ini_file%, GUI, transparency_step, 50		; steps, the higher the number, the faster the fade
	IniRead, GUI_statusbar, %ini_file%, GUI, GUI_statusbar, 1				; if 1 shows statusbar under hitlist
	IniRead, search_advanced, %ini_file%, GUI, search_advanced, 1			; if 1 show advanced options

	IniRead, GUI_autohide, %ini_file%, GUI, GUI_autohide, 1					; if 1 the search window autohides when it doesn't have focus
	IniRead, GUI_hideafterrun, %ini_file%, GUI, GUI_hideafterrun, 1		; if 1 the search window hides after a run
	IniRead, GUI_emptyafterrun, %ini_file%, GUI, GUI_emptyafterrun, 1		; if 1 the command_search empties after a run
	
	IniRead, GUI_resize, %ini_file%, GUI, GUI_resize, 0						; if 1 the main window can be manually resized
	IniRead, GUI_easymove, %ini_file%, GUI, GUI_easymove, 1					; if 1, the GUI can be moved by clicking anywhere
	IniRead, gui_titlebar, %ini_file%, GUI, gui_titlebar, 1					; if 0, the main GUI can be skinned and will not have a titlebar
	IniRead, gui_scheme, %ini_file%, GUI, gui_scheme, light					; light or dark

	if gui_scheme = dark		; this will set variables based on selected scheme
	{
		gui_border				= FFFFFF
		gui_scheme_control 	= 000000
		gui_scheme_font	 	= FFFFFF
	}
	else
	{
		gui_border				= 000000
		gui_scheme_control 	= FFFFFF
		gui_scheme_font 		= 000000
	}

	IniRead, browser, %ini_file%, programs, browser, iexplore.exe
	IniRead, text_editor, %ini_file%, programs, text_editor, notepad.exe
	SplitPath, text_editor , text_editor_name
	IniRead, graphics_editor, %ini_file%, programs, graphics_editor, mspaint.exe
	SplitPath, graphics_editor , graphics_editor_name
	IniRead, file_browser, %ini_file%, programs, file_browser, explorer.exe
	SplitPath, file_browser , file_browser_name

	f_dbgtime(gen,dbg,A_LineNumber,"Read_ini","stop",1)
	return
}