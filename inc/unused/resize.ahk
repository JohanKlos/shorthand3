ResizeGUI() {
	; based on Easy Window Dragging -- KDE style (requires XP/2k/NT) -- by Jonny
	; http://www.autohotkey.com/docs/scripts/EasyWindowDrag_(KDE).htm
	; Get the initial mouse position and window id, and
	; abort if the window is maximized.
	MouseGetPos,KDE_X1,KDE_Y1,KDE_id
	WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
	If KDE_Win
		return
	; Get the initial window position and size.
	WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
	; Define the window region the mouse is currently in.
	; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
	If (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
	   KDE_WinLeft := 1
	Else
	   KDE_WinLeft := -1
	If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
	   KDE_WinUp := 1
	Else
	   KDE_WinUp := -1
	Loop
	{
		; if A_GuiControl = v_left or v_right, only horizontal
		; if A_GuiControl = v_bottom, only vertical
		; if A_GuiControl = v_corner1-4, diagonal
		GetKeyState,KDE_Button,LButton,P ; Break if button has been released.
		If KDE_Button = U
			break
		MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
		; Get the current window position and size.
		WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
		KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
		KDE_Y2 -= KDE_Y1
		; if A_GuiControl = v_left || v_right || v_diag1 || v_diag2 || v_diag3 || v_diag4
			; KDE_X2 := KDE_X0
		; if A_GuiControl = v_bottom || v_diag1 || v_diag2 || v_diag3 || v_diag4
			; KDE_Y2 := KDE_Y0
		; Then, act according to the defined region.
		WinMove,ahk_id %KDE_id%,, KDE_WinX1 + (KDE_WinLeft+1)/2*KDE_X2  ; X of resized window
								, KDE_WinY1 +   (KDE_WinUp+1)/2*KDE_Y2  ; Y of resized window
								, KDE_WinW  -     KDE_WinLeft  *KDE_X2  ; W of resized window
								, KDE_WinH  -       KDE_WinUp  *KDE_Y2  ; H of resized window
		KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
		KDE_Y1 := (KDE_Y2 + KDE_Y1)
	}
}