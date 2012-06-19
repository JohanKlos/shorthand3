; if lang = eng
; {

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

	error_findstr_not_found = Findstr.exe has not been found on your system.`n`nPlease get it and place it in %app_folder%. Searching inside files will not be possible until Findstr.exe is in %app_folder%.

	find_text1 = Searching for a file
	find_text2 = Searching inside files	
	cancel_text = (ctrl x to cancel)
	
	tray_starting = Starting
	
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
	info_GUI_statusbar = If checked`, this will add a statusbar in the main %app_name% window.
	info_GUI_autohide = If checked`, the main %app_name% window will hide as soon as it loses focus.
	info_GUI_hideafterrun = If checked`, the main %app_name% window will hide after a command is run.
	info_GUI_emptyafterrun = If checked`, the search text in the main %app_name% window will be cleared after a command is run.
	info_GUI_emptyafter30 = If chekced, the search text in the main %app_name% window will be cleared after 30 seconds of non-typing.
	info_filter_folders = If checked`, the folders will not show up in the results.
	info_filter_extensions = If checked`, only listed extensions will show up in the results. If folders are not filtered out, they will still show up.
	info_filter_ignores = Any file or folder which has one of the listed strings`, will not show up in the results.

	text_about = %app_name% is a program to make finding and running files easier.`n`nIt is similar to programs like FindAndRunRobot and Launchy.`n`n%App_name% uses Everything.exe / ES.exe (http://www.voidtools.com) for file searching and Findstr.exe (http://technet.microsoft.com/en-us/library/bb490907.aspx) for searching in files.`n`nYou can also bind hotkeys to certain files, folders and actions.`n`nAHK version: %A_AhkVersion%`n`n%App_name% build: %app_modtime%

	t_cmd_open = Open
	t_cmd_openwith = Open with...
	t_cmd_openwitharg = Open with arguments
	t_cmd_openadmin = Open as admin
	t_cmd_edit = Edit with bound editor 
	t_cmd_openwithapp = Open with
	t_cmd_del = Delete
	t_cmd_delfromcustom = Delete from custom file
	t_cmd_delfromhistory = Delete from history
	t_cmd_delfromignore = Delete from Ignore List

	t_copypath = CopyPath
	t_cmd_addignore = Add to ignore list
	t_cmd_properties = Properties
	t_cmd_browse = Browse folder

	t_alwaysontop = Always on top
	t_autohide = Autohide
	t_easymove = EasyMove
	t_statusbar = Status bar
	t_titlebar = Title bar
	
	t_checkupdate = Check for updates
	t_preferences = Preferences
	t_reload = Reload
	t_exit = Exit

	gui3_preferences = Select your preferences.`nThese preferences can later be changed.
	gui3_firstlist = Name|variable
	gui3_cancel = &Cancel
	gui3_back = &Back
	gui3_next = &Next
	gui3_finish = &Finish
	gui3_title = Setup wizard

	gui_advanced = advanc&ed
	gui_containing = &Containing
	gui_extensions = E&xtensions
	gui_hidefolders = Hide &Folders
	gui_ignorelist = &Ignore list
	gui_restrictedmode = &Restricted mode
	gui_hitlist = Name|ext|Path|Score|runas
	gui_statustext = Fill search field...

	gui2_p1 = Program Options
	gui2_p1c1 = Settings
	gui2_p1c1c1 = Results
	gui2_p1c1c2 = Custom
	gui2_p1c1c3 = Hotkeys
	gui2_p1c1c4 = Plugins
	gui2_p1c2 = About
	gui2_p2 = Troubleshooting Log

	gui2_information = Information
	gui2_checkforupdates = Check for updates
	gui2_reload = Reload
	ok_button = OK
	
	gui2_gen = General
	gui2_gen_autostart = Start &automatically when Windows starts
	gui2_gen_check = Check for &updates on startup
	gui2_gen_traytip = Show &TrayTip when performing an action
	gui2_gen_titlebar = Show Title&bar on the search window
	gui2_gen_easymove = EasyMove the search window by left clicking on the background
	
; }
