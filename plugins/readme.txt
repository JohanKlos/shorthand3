This folder can contain .ahk files which will be included into shorthand, using the "#include *i" command.

Requirements for plugins:
- Format: 
	* the following lines MUST be present:
		a line with: "#ErrorStdOut"
		a line with: "#NoTrayIcon"
		a label with the name of the plugin, eg "sh_new_folder:"
	* the following lines give information about the plugin and are recommended:
		a line with: "; Name = "
		a line with: "; Category = "
		a line with: "; Version = "
		a line with: "; Description = "
		a line with: "; Author = "

- For correct functioning of the script, ALWAYS end the plugin script with a return
- For correct functioning of the script, do NOT use hotstrings, but rather use the hotkey functionality
- For correct functioning of the script, do NOT change any settings without returning them (like: DetectHiddenWindows and SetTitleMatchMode)