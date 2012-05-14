; this file will have all the timers that are running on startup in the script

SetTimer, timer_load_custom, 1000 ; this checks the modified date/time of the custom_files and reloads them if they differ from the last load
SetTimer, timer_autohide, 1000
if check_for_updates = 1
	SetTimer, check_update_automatic, %update_interval%
