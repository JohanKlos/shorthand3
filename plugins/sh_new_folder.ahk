; Name = New Folder
; Category = Hotkey
; Version = 0.01
; Description = Make a new folder through a hotkey (WIN-N) instead of the explorer default CTRL-SHIFT-N
; Author = Maestr0
#persistent ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

sh_new_folder:
	outputdebug Shorthand plugin loaded: sh_new_folder version 0.01 
	hotkey,#N, new_folder
return

new_folder:
	Send ^+N
return