; debugging object and variables
dbg 			:= Object()		; create object
dbg.tabs 		:=
dbg.tabcount 	:=

; dbg.name		:=		; do we need to init this? it's only used in f_dbgtime
; dbg.state		:=		; do we need to init this? it's only used in f_dbgtime
dbg.count		:= 0
dbg.line		:=

f_dbgtime(ByRef gen, ByRef dbg,line,name,state,loglevel=1)
{
	static TimeArray := Object()
	IniRead, logging, dbg.ini_file, General, logging, 1
	line := get_line(line)
	if ( logging < loglevel )
		return
	tabs := f_dbgtabcount(dbg,state)
	if state = start
	{
		TimeArray[name] := A_TickCount	; starts the time measuring for this name
		outputdebug % gen.app_name " " gen.app_version " (" line ") " tabs name " : " state
	} 
	else 
	{
		time := A_TickCount - TimeArray[name]
		outputdebug % gen.app_name " " gen.app_version " (" line ") " tabs name " : " state " (" time " MSec)"
	}
;	outputdebug % gen.app_name " " gen.app_version " (" line ") " dbg.tabs name " : " state ((time) ? " (" time " MSec)" : "")
	return
}
f_dbgoutput(ByRef gen, ByRef dbg,line,loglevel=1,message="")
{
	IniRead, logging, dbg.ini_file, General, logging, 1
	line := get_line(line)
	tabs := f_dbgtabcount(dbg,"",1) ; so the state is empty, keeping the tabcount in place
	if ( logging >= loglevel )
		outputdebug % gen.app_name " " gen.app_version " (" line ") " tabs message
}
f_dbgtabcount(ByRef dbg,state,modifier=0) ; sorts the indentation of the outputdebug by adding __
{
	static tabcount:=0
	if state = start
		tabcount ++
	Loop, % tabcount + modifier
		tabs := "__" tabs
	if state = stop	; needs to be after the loop, to prevent the tab to be added/deleted prematurely
		tabcount --
	return tabs
}
get_line(line) ; adds preceding 0's to the linenumbers
{
	Length := StrLen(line)
	if Length < 5
	{
		loop, 5
		{
			line = 0%line%
			Length := StrLen(line)
			if Length >= 5
				break
		}
	}
	return line
}
