; general object and global variables
script_PID := DllCall("GetCurrentProcessId")	; needed for the updater (to waitclose the pid)

gen					:= Object()
gen.app_name		:= app_name
gen.app_version	:= app_version
gen.ini_location	:= ini_location
gen.ini_file		:= gen.ini_location "\portable.ini"
gen.tempfolder 	:= gen.ini_location "\temp"
IniWrite, %ini_location%\temp, %ini_file%, General, tempfolder

GUI_name			= %app_name% %app_version% %beta%
GUI2_name			= %app_name% : Preferences

app_folder			= %A_ScriptDir%\app
check_exist_folder(app_folder)

app_find 			= %app_folder%\es.exe			; commandline utility for everything.exe
app_everything	= %app_folder%\Everything.exe	; needs to be resident for es.exe to work
app_findstr		= %app_folder%\findstr.exe		; windows standard tool to search inside files
app_updater		= %app_folder%\updater.exe		; updater executable
plugin_loader 	= %A_ScriptDir%\plugin_loader.ahk

if everythingPID =
{
	Process , exist , everything.exe	; check if the everything process is running in the background
	everythingPID := Errorlevel
	if everythingPID = 0
		run, %app_everything%,, hide, everythingPID
}	

img_folder			= %A_ScriptDir%\img
check_exist_folder(img_folder)
; icon_shorthand	= %img_folder%\icon_shorthand.ico	; moved to as high in the script as possible, to prevent flickering
icon_settings		= %img_folder%\icon_shorthand_settings.ico
icon_formula		= %img_folder%\icon_shorthand_formula.ico
icon_search		= %img_folder%\icon_shorthand_search.ico
icon_send			= %img_folder%\icon_shorthand_send.ico

log_folder			= %A_ScriptDir%\log
check_exist_folder(log_folder)
log_file			= %log_folder%\%app_name%_%A_UserName%.log
log_history		= %log_folder%\history_%A_UserName%.log
; or in tempfolder?

result_filename 	= %tempfolder%\output_everything.txt
result_filename2	= %tempfolder%\output_findstr.txt
update_file		= %tempfolder%\update.txt

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
	IniRead, use_copypath, %ini_file%, General, use_copypath, 1				; if 1, the registry will be edited so CopyPath gets added to context menu of all files and folders
	
	IniRead, search_engine_default, %ini_file%, General, search_engine_default, 	; the default short search engine, if the input is unclear, this is what it defaults to
	if search_engine_default = ERROR
		IniWrite, g, %ini_file%, General, search_engine_default
	IniRead, search_engines, %ini_file%, General, search_engines			; search engines, become available when user types: "?g " for Google, etc.
	if search_engines = ERROR
	{
		search_engines = g|Google|https://www.google.com/#hl=en&output=search&sclient=psy-ab&q=`,w|Wikipedia|http://en.wikipedia.org/wiki/`,i|IMdb|http://www.imdb.com/find?hl=en&q=`,a|Amazon.com|http://www.amazon.com/s/ref=nb_sb_noss_2/185-9406354-8142815?url=search-alias`%3Daps&field-keywords=					
		IniWrite, %search_engines%, %ini_file%, General, search_engines
	}

	IniRead, GUI_x, %ini_file%, GUI, GUI_x, 0								; default x position for the main GUI
	IniRead, GUI_y, %ini_file%, GUI, GUI_y, 0								; default y position for the main GUI
	IniRead, GUI_w, %ini_file%, GUI, GUI_w, 447								; width for the main GUI
	IniRead, GUI_h, %ini_file%, GUI, GUI_h, 127								; height for the main GUI

	IniRead, search_delay, %ini_file%, GUI, search_delay, 250				; delay before searching to prevent searching at every keystroke

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

	IniRead, use_history, %ini_file%, GUI, use_history, 1					; 1 : keep track of what is opened/run with shorthand, allows scoring and combobox in GUI
	IniRead, use_score, %ini_file%, GUI, use_score, 1						; 1 : use scoring to change the sorting of the hitlist
	IniRead, score_restricted, %ini_file%, Score, score_restricted, 50		; "run" files in a start menu or desktop 
	IniRead, score_history, %ini_file%, Score, score_history, 100			; files in log_history get (by default) 100 score points (hitlist shows in descending order)
	IniRead, score_custom, %ini_file%, Score, score_custom, 150				; "run" files in a custom_file

	IniRead, show_lnk, %ini_file%, GUI, show_lnk, 1							; when 0, the results will show the path to the actual file, instead of the .lnk filename

	IniRead, restricted_mode, %ini_file%, GUI, restricted_mode, 1			; 1 means it'll only show hits in one of the restricted folders
	A_TaskbarPinned = %A_AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar
	list_restricted = %A_Desktop%,%A_DesktopCommon%,%A_StartMenu%,%A_StartMenuCommon%,%A_TaskbarPinned%
	
	IniRead, GUI_ontop, %ini_file%, GUI, GUI_ontop, 1						; if 1 the search window will be always on top when not hidden
	IniRead, GUI_fade, %ini_file%, GUI, GUI_fade, 0							; if 1 fades the search window in and out
	IniRead, transparency_step, %ini_file%, GUI, transparency_step, 50		; steps, the higher the number, the faster the fade
	IniRead, GUI_statusbar, %ini_file%, GUI, GUI_statusbar, 1				; if 1 shows statusbar under hitlist
	IniRead, search_advanced, %ini_file%, GUI, search_advanced, 1			; if 1 show advanced options

	IniRead, GUI_autohide, %ini_file%, GUI, GUI_autohide, 1					; if 1 the search window autohides when it doesn't have focus
	IniRead, GUI_hideafterrun, %ini_file%, GUI, GUI_hideafterrun, 1		; if 1 the search window hides after a run
	IniRead, GUI_emptyafterrun, %ini_file%, GUI, GUI_emptyafterrun, 1		; if 1 the command_search empties after a run
	IniRead, GUI_emptyafter30, %ini_file%, GUI, GUI_emptyafter30, 1		; if 1 the command_search empties after 30 seconds
	
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