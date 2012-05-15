This folder can contain .ahk files which will be included into shorthand, using the "#include *i" command.

Requirements for plugins:
- Format: Start first line with "; Name = "
- Format: Start second line with "; Category = "
- Format: Start third line with "; Version = "
- Format: Start third line with "; Description = "
- For correct functioning of the script, ALWAYS put the parts it needs to run on load in a label the same as the filename
- For correct functioning of the script, ALWAYS end the plugin script with a return
- For correct functioning of the script, do NOT use hotstrings, but rather use the hotkey functionality
- For correct functioning of the script, do NOT change any settings without returning them (like: DetectHiddenWindows and SetTitleMatchMode)