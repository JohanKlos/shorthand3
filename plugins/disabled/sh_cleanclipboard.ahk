; Name = Clean Clipboard
; Category = Enhancement
; Version = 0.01
; Description = Cleans the clipboard of all formatting (if the clipboard contains text)
; Author = Maestr0
#persistent ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

sh_cleanclipboard:
	outputdebug Shorthand plugin loaded: sh_cleanclipboard version 0.01
		clipboardAll := clipboardAll
	hotkey, #w, sh_CleanClipboard
return

sh_CleanClipboard:
	if clipboard <> ""	; meaning the clipboard contains text and not just a picture
return
