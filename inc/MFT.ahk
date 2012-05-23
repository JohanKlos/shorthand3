ListMFTfiles( drive, regex="", delim="`n", showprogress=true, byref num=0, debugging="1" )
{
	if debugging
		outputdebug % "drive: " drive . "`nregex: " . regex . "`ndelim: " . delim . "`nshowprogress: " . showprogress . "`nnum: " . num
;=== get root folder ("\") refnumber
   SHARE_RW:=3 ;FILE_SHARE_READ | FILE_SHARE_WRITE
   hRoot:=dllCall("CreateFileW",wstr,"\\.\" drive "\", uint,0, uint,SHARE_RW, uint,0, uint,OPEN_EXISTING:=3, uint,FILE_FLAG_BACKUP_SEMANTICS:=0x2000000, uint,0)
	if debugging
		outputdebug % "hroot: " hroot
   ifEqual,hRoot,-1, return
   ;BY_HANDLE_FILE_INFORMATION
   ;   0   DWORD dwFileAttributes;
   ;   4   FILETIME ftCreationTime;
   ;   12   FILETIME ftLastAccessTime;
   ;   20   FILETIME ftLastWriteTime;
   ;   28   DWORD dwVolumeSerialNumber;
   ;   32   DWORD nFileSizeHigh;
   ;   36   DWORD nFileSizeLow;
   ;   40   DWORD nNumberOfLinks;
   ;   44   DWORD nFileIndexHigh;
   ;   48   DWORD nFileIndexLow;
   VarSetCapacity(fi,52,0)
   ok:=dllCall("GetFileInformationByHandle", uint,hRoot, uint,&fi), dllCall("CloseHandle", uint,hRoot)
  	if debugging
		outputdebug % "ok: " ok
   ifEqual,ok,0, return
   dirdict:={}
   rootDirKey:="" ((numget(fi,44)<<32)+numget(fi,48))
   dirdict[rootDirKey]:={"name":drive, "parent":"0"}
  	if debugging
		outputdebug % "rootdirkey: " rootdirkey

;=== open USN journal
   GENERIC_RW:=0xC0000000 ;GENERIC_READ | GENERIC_WRITE
   hJRoot:=dllCall("CreateFileW", wstr,"\\.\" drive, uint,GENERIC_RW, uint,SHARE_RW, uint,0, uint,OPEN_EXISTING:=3, uint,0, uint,0)
  	if debugging
		outputdebug % "hJRoot: " hJRoot
   ifEqual,hJRoot,-1, return
   cb:=0
   VarSetCapacity(cujd,16) ;CREATE_USN_JOURNAL_DATA
   numput(0x800000,cujd,0,"uint64")
   numput(0x100000,cujd,8,"uint64")
   if( dllCall("DeviceIoControl", uint,hJRoot, uint,FSCTL_CREATE_USN_JOURNAL:=0x000900e7, uint,&cujd, uint,16, uint,0, uint,0, uintp,cb, uint,0)=0 )
   {
      dllCall("CloseHandle", uint,hJRoot)
		if debugging
			outputdebug % "USN Journal not created"
      return
   }
   else
   {
  		if debugging
			outputdebug % "USN Journal created"
	}


;=== prepare data to query USN journal
   ;USN_JOURNAL_DATA
   ;   0   DWORDLONG UsnJournalID;
   ;   8   USN FirstUsn;
   ;   16   USN NextUsn;
   ;   24   USN LowestValidUsn;
   ;   32   USN MaxUsn;
   ;   40   DWORDLONG MaximumSize;
   ;   48   DWORDLONG AllocationDelta;
   VarSetCapacity(ujd,56,0)
   if( dllCall("DeviceIoControl", uint,hJRoot, uint,FSCTL_QUERY_USN_JOURNAL:=0x000900f4, uint,0, uint,0, uint,&ujd, uint,56, uintp,cb, uint,0)=0 )
   {
		if debugging
			outputdebug % "Problem preparing data to query USN journal, closing Handle"
	   dllCall("CloseHandle", uint,hJRoot)
      return
   }
   JournalMaxSize:=numget(ujd,40,"uint64")+numget(ujd,48,"uint64") ;USN_JOURNAL_DATA.MaximumSize + USN_JOURNAL_DATA.AllocationDelta
  	if debugging
		outputdebug % "JournalMaxSize: " JournalMaxSize

;=== enumerate USN journal
   cb:=0
   filedict:={}
   filedict.SetCapacity(JournalMaxSize//(128*10))
   dirdict.SetCapacity(JournalMaxSize//(128*10))
   JournalChunkSize:=0x100000
   VarSetCapacity(pData,8+JournalChunkSize,0)
   ;MFT_ENUM_DATA
   ;   0   DWORDLONG StartFileReferenceNumber;
   ;   8   USN LowUsn;
   ;   16   USN HighUsn;
   VarSetCapacity(med,24,0)
   numput(numget(ujd,16,"uint64"),med,16,"uint64") ;med.HighUsn=ujd.NextUsn

   if showprogress
      Progress,b p0
   while dllCall("DeviceIoControl", uint,hJRoot, uint,FSCTL_ENUM_USN_DATA:=0x000900b3, uint,&med, uint,24, uint,&pData, uint,8+JournalChunkSize, uintp,cb, uint,0)
   {
      pUSN:=&pData+8
      ;USN_RECORD
      ;   0   DWORD RecordLength;
      ;   4   WORD   MajorVersion;
      ;   6   WORD   MinorVersion;
      ;   8   DWORDLONG FileReferenceNumber;
      ;   16   DWORDLONG ParentFileReferenceNumber;
      ;   24   USN Usn;
      ;   32   LARGE_INTEGER TimeStamp;
      ;   40   DWORD Reason;
      ;   44   DWORD SourceInfo;
      ;   48   DWORD SecurityId;
      ;   52   DWORD FileAttributes;
      ;   56   WORD   FileNameLength;
      ;   58   WORD   FileNameOffset;
      ;   60   WCHAR FileName[1];
      while cb>60
      {
         fn:=strget(pUSN+60,numget(pUSN+56,"ushort")//2,"UTF-16") ;USN.FileName
         if( numget(pUSN+52) & 0x10 ) ;USN.FileAttributes & FILE_ATTRIBUTE_DIRECTORY
         {
            ref:="" numget(pUSN+8,"uint64") ;USN.FileReferenceNumber
            refparent:="" numget(pUSN+16,"uint64") ;USN.ParentFileReferenceNumber
            dirdict[ref]:={"name":fn, "parent":refparent}
         }
         else
            if( regex="" || regExMatch(fn,regex) )
            {
               ref:="" numget(pUSN+8,"uint64") ;USN.FileReferenceNumber
               refparent:="" numget(pUSN+16,"uint64") ;USN.ParentFileReferenceNumber
               filedict[ref]:={"name":fn, "parent":refparent}
            }
         i:=numget(pUSN+0) ;USN.RecordLength
         pUSN += i
         cb -= i
      }
      numput(numget(pData,"uint64"),med,"uint64")
      if showprogress
         Progress,% round(A_index*JournalChunkSize/JournalMaxSize*90)
   }
  	if debugging
		outputdebug % "i: " i
   dllCall("CloseHandle", uint,hJRoot)

;=== connect files to parent folders
   if showprogress
      Progress,90
   VarSetCapacity(filelist,filedict.getCapacity()*128)
   num:=0
   for k,v in filedict
   {
      filelist.=resolveFolder(dirdict,v.parent) v.name delim
      num++
   }
   if showprogress
      Progress,95
   VarSetCapacity(filelist,-1)
  	if debugging
		outputdebug % "filelist generated, " . i . " hits"
   Sort,filelist,D%delim%
   if showprogress
      Progress,OFF
   return filelist
}

resolveFolder( dirdict,ddref )
{
   p:=dirdict[ddref], pd:=p.dir
   return pd ? pd : (p.dir:=(p.parent ? resolveFolder(dirdict,p.parent) : "") p.name "\")
}