fill_history(command)
{
	global
	f_dbgtime(gen,dbg,A_LineNumber,"fill_history","start",1)
	f_dbgoutput(gen,dbg,A_LineNumber,3,"fill_history: " use_history " adding " command)

	fileread, history, %log_history%
	history .= command . ","

	StringReplace, history , history , \., , , ALL			; gets rid of most ,, in there
	StringReplace, history , history , `,`, , `, , ALL		; gets rid of most ,, in there

	Sort, history , U D`,
	filedelete %log_history%
	fileappend, %history%,%log_history%
	score_history_read := history
	f_dbgtime(gen,dbg,A_LineNumber,"fill_history","stop",1)
	return history
}
parse_history()
{
	; this subroutine parses the history file
	if use_history = 1
	{
		history_list :=
		fileread, history, %log_history%
		loop , parse , history, `,
		{
			if A_LoopField <>
				history_list .= A_LoopField . ","
		}
		StringReplace, history_list , history_list , `r`n,,ALL
		history :=
	}
	return
}