; Name = Replace Clipboard
; Category = Enhancement
; Version = 0.01
; Description = Replaces certain characters in the the clipboard and deletes them or substitutes them with others.
; Author = Maestr0
#persistent ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

sh_replace:
	outputdebug Shorthand plugin loaded: sh_replace version 0.01
	gosub sh_replace_gui
return

sh_replace_gui:
	; gui with two input boxes: find / replace
	; gui with two buttons: cancel / ok
	; show / hide with clipboard before / after
return

sh_replace_find:
	StringReplace, clipboard, clipboard_new, %t_find%, %t_replace%
return

sh_replace_replace:
return

sh_ok:
	clipboard = %clipboard_new%
return
