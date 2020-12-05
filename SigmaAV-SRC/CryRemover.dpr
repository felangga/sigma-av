library CryRemover;

uses
  ShareMem,
  SysUtils,
  Classes,
  windows,
  dialogs,
  tlhelp32,CommCtrl,PsAPI,StdCtrls;

const
   MES_NONE = 0;
   MES_SCANDIR = 1101;
   MES_SCANFILE = 1102;
   MES_PLUGINWAIT = 1103;
   MES_PLUGINEXIT = 1104;
   MES_EXITFROMWAIT = 1121;
   API_OTHER = 1000;
   API_SCAN = 1001;
   API_SCANATRUN = 1002;
   API_SCANFILE = 1003;
   VERSION = '1.0.0';

   type
   OnVirFound               = Procedure (FileName, VirName: PChar;typedata:integer);
   OnReadError              = Procedure (FileName: String; ID: Integer);
   OnAddToLog               = Procedure (Infeksi, Location : String; ID : Integer; metode : integer);
   ApiScanFileInThread      = Procedure (FileName: PChar);
   ApiScanDirInThread       = Procedure (DirName: PChar);
   ApiScanFile              = function (FileName: PChar) : string;
   ApiScanDir               = Procedure (DirName: PChar);
   ApiAddToExtList          = Procedure (Ext: PChar);
   ApiOnScanStart           = Procedure;
   ApiSetRegString          = Procedure (root : DWORD; Alamat, reg : string; value : string);
   ApiSetRegInteger         = Procedure (Root : DWORD; Alamat,reg : String; Value : Integer);
   ApiScanFileInPlugin      = Function (FileName: PChar; var VirName: PChar): Boolean;
   ExitWaitForPlugin        = Procedure;
   ApiGetEngineVersion      = function : integer;
   ApiRegDelValue           = procedure (Root : DWORD; Alamat : String; Value : String);
   ApiRegDelKey             = procedure (Root : DWORD; Alamat : String; Value : String);
   ApiKillTaskByName        = function (nama : string) : boolean;

  var
  OwnerHDC: integer;

Procedure InitApiPlug (Owner: integer);
begin
  OwnerHDC := Owner;
  if ApiGetEngineVersion(GetProcAddress(OwnerHDC,'ApiGetEngineVersion')) < 103 then
    MessageDlg('Invalid Engine Version!, this Sigma version do not match with FixReg plugin, please uninstall it',mtError,[mbOK],0);
end;

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


Procedure APIPlugInitOnScan;
begin
  OnAddToLog (GetProcAddress (OwnerHDC, 'ApiOnAddLog'))('[PLUGIN] CryRemover '+VERSION,' ',12,4);
 // if not ApiKillTaskByName(GetProcAddress(OwnerHDC, 'ApiKillTaskByName')) ('taskmgr.exe') then
   // ShowMessage('Failed to kill WScript.exe, please take manually kill in the process killer menu');
  KillByName('wscript.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\','RegisteredOrganization','admin');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\','RegisteredOwner','admin');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\VBSFile\','FriendlyTypeName','@%SystemRoot%\System32\wshext.dll,-4802');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\VBSFile\DefaultIcon','','%SystemRoot%\system32\WScript.exe,2');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','Shell','Explorer.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','Userinit','C:\WINDOWS\system32\Userinit.exe,');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SYSTEM\CurrentControlSet\Control\SafeBoot\','AlternateShell','cmd.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SYSTEM\ControlSet001\Control\SafeBoot\','AlternateShell','cmd.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SYSTEM\ControlSet002\Control\SafeBoot\','AlternateShell','cmd.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\Inkfile','','Shortcut');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Explorer\','Logon User Name','user');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_CURRENT_USER,'\Software\Microsoft\Windows NT\CurrentVersion\WinLogon\','Logon User Name','user');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\inffile\shell\Install\command','','%SystemRoot%\System32\rundll32.exe setupapi,InstallHinfSection DefaultInstall 132 %1');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\VBSFile\Shell\Edit\Command\','','%SystemRoot%\system32\NOTEPAD.EXE %1');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\regedit\shell\open\','','');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\regedit\shell\open\command\','','regedit.exe "%1"');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_CLASSES_ROOT,'\regfile\shell\open\command','','regedit.exe %1');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\regfile\shell\edit\command','','%SystemRoot%\system32\NOTEPAD.EXE %1');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\regfile\shell\open\command','','regedit.exe %1');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_CURRENT_USER,'\Software\Microsoft\Internet Explorer\Main','Start Page','about:blank');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\Software\Classes\scxfile','','SCX file');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\Software\Classes\scxfile\shell\open\command\','','');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\Software\Classes\dlsfile\','','DLS file');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\Software\Classes\dlsfile\shell\open\command','','');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CMD.exe','Debugger','');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msconfig.exe','Debugger','');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\regedit.exe','Debugger','');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\regedt32.exe','Debugger','');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TaskMgr.exe','Debugger','');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SYSTEM\ControlSet001\Control\Session Manager\Environment','ComSpec','%SystemRoot%\system32\cmd.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SYSTEM\ControlSet002\Control\Session Manager\Environment','ComSpec','%SystemRoot%\system32\cmd.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SYSTEM\CurrentControlSet\Control\Session Manager\Environment','ComSpec','%SystemRoot%\system32\cmd.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_CURRENT_USER,'\Control Panel\Desktop\','SCREENSAVE.EXE','C:\WINDOWS\System32\logon.scr');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','viremover.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','winupdtsys.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','tasklist.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','setup.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','PCMAV.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','nerochkup.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','PCMAV-CLN.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','PCMAV-RTP.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','PCMAV-SExe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','qbtask.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','install.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','integrator.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','ise32.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','Launcher.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','a.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','ansav.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','ansavgd.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','appsys.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','autorun.exe');
  ApiRegDelKey(GetProcAddress(OwnerHDC,'ApiRegistryDeleteKey')) (HKEY_LOCAL_MACHINE,'\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\','PCMAV-CLN.exe');
  ApiRegDelValue(GetProcAddress(OwnerHDC,'ApiRegistryDeleteValue')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\','ACDsee');
  ApiRegDelValue(GetProcAddress(OwnerHDC,'ApiRegistryDeleteValue')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\','CorelSetup');
  ApiRegDelValue(GetProcAddress(OwnerHDC,'ApiRegistryDeleteValue')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\','updtsystem');
  ApiRegDelValue(GetProcAddress(OwnerHDC,'ApiRegistryDeleteValue')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\','VGAdriver');
  ApiRegDelValue(GetProcAddress(OwnerHDC,'ApiRegistryDeleteValue')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\','VirtualCD Task');
  ApiRegDelValue(GetProcAddress(OwnerHDC,'ApiRegistryDeleteValue')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\','WinSystem');
  ApiRegDelValue(GetProcAddress(OwnerHDC,'ApiRegistryDeleteValue')) (HKEY_CURRENT_USER,'\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\','NeroFilterCheck');
  ApiRegDelValue(GetProcAddress(OwnerHDC,'ApiRegistryDeleteValue')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\','WinSystem');

  DeleteFile('C:\Windows\Help.html');
  DeleteFile('C:\Windows\windows.html');
  DeleteFile('C:\Windows\appsys.exe');
  DeleteFile('C:\Windows\winupdt.scx');
  DeleteFile('C:\Windows\appopen.scx');
  DeleteFile('C:\Windows\WindowsOpen.mht');
  DeleteFile('C:\Windows\Regedit.exe.lnk');
  DeleteFile('C:\Windows\System\svchost.exe');
  DeleteFile('C:\Windows\System32\Svchost.dls');
  DeleteFile('C:\Windows\System32\CorelSetup.scx');
  DeleteFile('C:\Windows\System32\Appsys.dls');
  DeleteFile('C:\Windows\System32\Kernel32.dls');
  DeleteFile('C:\Windows\System32\Taskmgr.exe.lnk');
  DeleteFile('C:\Windows\System32\Winupdtsys.exe');
  DeleteFile('C:\Windows\System32\ssmarque.scr');
  DeleteFile('C:\Program Files\Far Stone\qbtask.exe');
  DeleteFile('C:\Program Files\ACDsee\Launcher.exe');
  DeleteFile('C:\Program Files\Common Files\NeroChkup.exe');
  DeleteFile('C:\Documents and Settings\Elvina\Desktop\Local Disk (C).dls');

  // Aktifkan Task Manager
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System','DisableTaskMgr',0);

  // Aktifkan Regedit
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableRegistryTools',0);

  // Aktifkan MsConfig
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableMSConfig',0);

  OnAddToLog (GetProcAddress (OwnerHDC, 'ApiOnAddLog'))('[PLUGIN] CryRemover Finished.',' ',12,4);
end;

Function ApiPluginGetType: integer;
begin
// Type of module
Result:= API_SCANATRUN;
end;

Function ApiPluginGetName: PChar;
begin
// Module name
Result:= 'CryRemover';
end;

Function ApiPluginGetInfo: PChar;
begin
// Information about the module
  Result:= 'Plug-in untuk mengembalikan semua setting yang telah dirubah oleh virus VBS/Cry. ';
end;

Function ApiPluginGetAutor: PChar;
begin
  // Author Module
  Result:= 'F_Computer & XTF_Computer';
end;

//------------------------------------------------ ---//
//(Export plugin functions)
exports InitApiPlug;
exports APIPlugInitOnScan;
exports ApiPluginGetAutor;
exports ApiPluginGetName;
exports ApiPluginGetType;
exports ApiPluginGetInfo;


end.
