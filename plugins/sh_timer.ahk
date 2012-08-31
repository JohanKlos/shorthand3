; Name = Timer
; Category = Utility 
; Version = 0.01
; Description = Add a timer to the menu that allows for setting a timed alarm/sleep/shutdown/lock.
; Author = Maestr0
#persistent ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin

sh_timer:
	outputdebug Shorthand plugin loaded: sh_timer version 0.01 
return
sh_timer_menu:
	Menu, plugins, Add, Timer, sh_timer_gui	
return
sh_timer_gui:
	Gui, sh_timer:new
	Gui, sh_timer:Add, DropDownList, w110 vsh_t_action gsh_t_action_result Choose1 section, Popup|Start Program|Lock Computer|Shutdown Computer
	Gui, sh_timer:Add, Edit, w30 ys vsh_t_time number right, 1
	Gui, sh_timer:Add, DropDownList, w75 ys vsh_t_units Choose1, minutes|hours|days|weeks
	Gui, sh_timer:Add, Button, ys-1 wp gsh_t_ok Default, &OK
	Gui, sh_timer:Show, , Shorthand Timer
	GuiControl, focus, sh_t_time
return
sh_t_action_result:
	; this will activate/deactive gui controls based on the selected action
return
sh_t_ok:
	Gui, sh_timer:submit, nohide
	Finish :=
	if sh_t_units = weeks
		Finish += % sh_t_time * 7, %sh_t_units%
	else
		Finish += % sh_t_time, seconds ;  %sh_t_units%
	
	alert .= Finish . "," . sh_t_action . "|"
	settimer, timer_alert	; this timer runs as long as there are timers (count > 0), parses %alert% and executes the action
	
	FormatTime, Finish, %Finish%, yyyy-MM-dd HH:mm:ss
	outputdebug % sh_t_action . " in " . sh_t_time . " " . sh_t_units . " = " . Finish
return

timer_alert:
	if alert
	{
		loop, parse, alert, |
		{
			if A_LoopField	; only continue if A_LoopField is not empty
				alert := alert(A_LoopField,alert)
		}
	}
	else
		settimer, timer_alert, off
return
alert(line,alert)
{
	loop, parse, line, `,
	{
		if A_Index = 1	; the finish time
			finish := A_LoopField
		else if A_Index = 2	; the action
		{
			action := A_LoopField
			if ( A_Now >= finish )
			{
				StringReplace, alert, alert, % finish . "," . action . "|",, ALL
				if ( action = "popup" )
					msgbox Alert!
				else if ( action = "Start Program" )
					msgbox Start program
				else if ( action = "Lock Computer" )
					msgbox Lock Computer
				else if ( action = "Shutdown Computer" )
					msgbox Shutdown Computer
				outputdebug action > %finish% : %action%	; this will point to the action
			}
		}
	}
	return alert
}
