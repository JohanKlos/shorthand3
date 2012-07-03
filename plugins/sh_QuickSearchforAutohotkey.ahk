; Name = Quick Search AHK Forums
; Author = SinkFaze
; Category = Enhancement
; Version = 0.01
; Description = Adds a hotkey (alt-h) to search in the Autohotkey forums from an inputbox
; URL = http://www.autohotkey.com/community/viewtopic.php?p=196070#196070
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

/*
source: http://www.autohotkey.com/community/viewtopic.php?p=296656#296656
The purpose of this script is to provide a quick and easy way to search the forum for information. 
You can use this script as a standalone utility or incorporate it into an existing script for easier use. 
Type in your search parameters and click "Search" to use the site's search itself, or click "Google It!" 
to do a custom search of the site using Google. 
The utility is assigned to a default hotkey (Alt+H), as are the search functions 
(Alt+F to search the site, Alt+G to search the site via Google).
*/
sh_QuickSearchforAutohotkey:
	outputdebug Shorthand plugin loaded: sh_QuickSearchforAutohotkey version 0.01
	hotkey, !h, searchahk
return
searchahk:
	Gui, 99:Destroy
	Gui, 99:Add, Text, x16 y10 w310 h20 , Search Autohotkey's site documentation or search from Google:
	Gui, 99:Add, Edit, x16 y30 w310 h20 vSearch,
	Gui, 99:Add, Button, x165 y59 w77 h26 gfSearch default, &Search
	Gui, 99:Add, Button, x250 y59 w77 h26 ggSearch, &Google It!
	Gui, 99:Show, x334 y312 h99 w342, Quick Search for Autohotkey
Return
fSearch:
	Gui, 99:Submit
	Gui, 99:Destroy
	Run
	, % "http://www.autohotkey.com/search/search.php?site=0&path=&result_page=search.php&query_string=" 
	. RegExReplace(RegExReplace(Search,"#","`%23"),A_Space,"`%20")
	. "&option=start&search=Search"
return
gSearch:
	Gui, 99:Submit
	Gui, 99:Destroy
	Run, http://www.google.com/search?q=%Search%+site:autohotkey.com
return
