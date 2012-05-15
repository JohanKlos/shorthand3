; Name = Script Usage CPUs
; Category = Enhancement
; Version = 0.01
; Description = Get the CPU and Memory usage of the current script
#ErrorStdOut ; this line needs to be in every plugin
#NoTrayIcon ; this line needs to be in every plugin

sh_scriptusage:
	outputdebug Shorthand plugin loaded: sh_scriptusage version 0.01 
	SetTimer, CPUTimes, 100 ; 1000ms
return
	
CPUTimes:
	ToolTip, % "CPU :" A_Tab . GetProcessTimes(script_PID) "`nMEM : " A_Tab . GetProcessMemoryInfo(script_PID) " KB"
Return

GetProcessTimes(pid)    ; Thanks to Sean  http://www.autohotkey.com/forum/viewtopic.php?p=119695#119695
{
   Static oldKrnlTime, oldUserTime
   Static newKrnlTime, newUserTime

   oldKrnlTime := newKrnlTime
   oldUserTime := newUserTime

   hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", pid)
   DllCall("GetProcessTimes", "Uint", hProc, "int64P", CreationTime, "int64P", ExitTime, "int64P", newKrnlTime, "int64P", newUserTime)
   DllCall("CloseHandle", "Uint", hProc)
   Return (newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)/10000000 * 100   ; 1sec: 10**7
}

; http://www.autohotkey.com/forum/viewtopic.php?p=223061#223061
GetProcessMemoryInfo( pid )
{
  ; get process handle
  hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

  ; get memory info
  VarSetCapacity( memCounters, 40, 0 )
  DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, 40 )
  DllCall( "CloseHandle", UInt, hProcess )

  list = cb,PageFaultCount,PeakWorkingSetSize,WorkingSetSize,QuotaPeakPagedPoolUsage 
  ,QuotaPagedPoolUsage,QuotaPeakNonPagedPoolUsage,QuotaNonPagedPoolUsage 
  ,PagefileUsage,PeakPagefileUsage

  /*
  cb := NumGet( memCounters, 0, "UInt" )
  PageFaultCount := NumGet( memCounters, 4, "UInt" )
  PeakWorkingSetSize := NumGet( memCounters, 8, "UInt" )
  WorkingSetSize := NumGet( memCounters, 12, "UInt" )
  QuotaPeakPagedPoolUsage := NumGet( memCounters, 16, "UInt" )
  QuotaPagedPoolUsage := NumGet( memCounters, 20, "UInt" )
  QuotaPeakNonPagedPoolUsage := NumGet( memCounters, 24, "UInt" )
  QuotaNonPagedPoolUsage := NumGet( memCounters, 28, "UInt" )
  PagefileUsage := NumGet( memCounters, 32, "UInt" )
  PeakPagefileUsage := NumGet( memCounters, 36, "UInt" )
  */

  n=0 
  Loop, Parse, list, `,
  {
    n+=4
    SetFormat, Float, 0.0 ; round up K
    this := A_Loopfield
    this := NumGet( memCounters, (A_Index = 1 ? 0 : n-4), "UInt") / 1024

    ; omit cb
    If A_Index != 1
      info .= A_Loopfield . ": " . this . " K" . ( A_Loopfield != "" ? "`n" : "" )
  }

  ; Return "[" . pid . "] " . pname . "`n`n" . info ; for everything
  ; Return WorkingSetSize := NumGet( memCounters, 12, "UInt" ) / 1024 . " K" ; what Task Manager shows
  Return PagefileUsage := NumGet( memCounters, 32, "UInt" ) / 1024 ; what Task Manager shows
}