; Name = Calendar
; Category = Utility 
; Version = 0.01
; Description = Shows a Month-calendar and today's date, nothing else yet.
; Author = Maestr0
#persistent ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin
#ErrorStdOut ; this line needs to be in every plugin

sh_calendar:
	outputdebug Shorthand plugin loaded: sh_calendar version 0.01
return

sh_calendar_gui:
	FormatTime, Today_longday, %A_Now%, dddddd
	FormatTime, Today_day, %A_Now%, d
	FormatTime, Today_monthyear, %A_Now%, MMMM yyyy

	Gui, sh_calendar:new
	Gui, sh_calendar:-caption +toolwindow
	Gui, sh_calendar:Add, MonthCal, vMyCalendar section
	Gui, sh_calendar:Add, Text, xs wp vToday_longday center, `n%Today_longday%
	Gui, sh_calendar:Font, s50
	Gui, sh_calendar:Add, Text, xs wp vToday_day center, %Today_day%
	Gui, sh_calendar:Font,
	Gui, sh_calendar:Add, Text, xs wp vToday_monthyear center, %Today_monthyear%`n
	Gui, sh_calendar:Show,, Shorthand Calendar
return