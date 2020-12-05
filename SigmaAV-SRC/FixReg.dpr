library FixReg;

uses
  ShareMem,
  SysUtils,
  Classes,
  windows,
  dialogs;

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
   OnVirFound = Procedure (FileName, VirName: PChar;typedata:integer);
   OnReadError = Procedure (FileName: String; ID: Integer);
   OnAddToLog = Procedure (Infeksi, Location : String; ID : Integer; metode : integer);
   ApiScanFileInThread = Procedure (FileName: PChar);
   ApiScanDirInThread = Procedure (DirName: PChar);
   ApiScanFile = function (FileName: PChar) : string;
   ApiScanDir = Procedure (DirName: PChar);
   ApiAddToExtList = Procedure (Ext: PChar);
   ApiOnScanStart = Procedure;
   ApiSetRegString = Procedure (root : DWORD; Alamat, reg : string; value : string);
   ApiSetRegInteger = Procedure (Root : DWORD; Alamat,reg : String; Value : Integer);
   ApiScanFileInPlugin = Function (FileName: PChar; var VirName: PChar): Boolean;
   ExitWaitForPlugin = Procedure;
   ApiGetEngineVersion = function : integer;

  var
  OwnerHDC: integer;

Procedure InitApiPlug (Owner: integer);
begin
  OwnerHDC := Owner;
  if ApiGetEngineVersion(GetProcAddress(OwnerHDC,'ApiGetEngineVersion')) < 103 then
    MessageDlg('Invalid Engine Version!, this Sigma version do not match with FixReg plugin, please uninstall it',mtError,[mbOK],0);
end;

Procedure APIPlugInitOnScan;
begin

  OnAddToLog (GetProcAddress (OwnerHDC, 'ApiOnAddLog'))('[PLUGIN] RegFixer '+VERSION,' ',-1,4);
  // Aktifkan Task Manager
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System','DisableTaskMgr',0);

  // Aktifkan Regedit
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableRegistryTools',0);

  // Aktifkan MsConfig
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableMSConfig',0);

  // Aktifkan SystemRestore
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_LOCAL_MACHINE,'\Software\Policies\Microsoft\WindowsNT\SystemRestore\','DisableSR',0);

  // Aktifkan file hidden
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\','Hidden',1);

  // Aktifkan File Extensi
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\','HideFileExt',0);

  // Aktifkan RUN
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoRun',0);

  // AKtifkan Find
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoFind',0);

  // Aktifkan Command Prompt
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SYSTEM\CurrentControlSet\Control\SafeBoot\','AlternateShell','cmd.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SYSTEM\ControlSet001\Control\SafeBoot\','AlternateShell','cmd.exe');
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SYSTEM\ControlSet002\Control\SafeBoot\','AlternateShell','cmd.exe');
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger')) (HKEY_CURRENT_USER,'\Software\Policies\Microsoft\Windows\System\','DisableCMD',0);

  // Aktifkan Control Panel
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoControlPanel',0);

  // Aktifkan Folder Options
  ApiSetRegInteger(GetProcAddress(OwnerHDC,'ApiSetRegInteger'))(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoFolderOptions',0);

  // Set Shell
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','Shell','Explorer.exe');
  // Set Userinit
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','Userinit','C:\WINDOWS\system32\Userinit.exe,');

  // Asosiasi batfile
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\batfile\shell\open\command','','"%1" %*');
  // Asosiasi regfile
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\regfile\shell\open\command','','regedit.exe %1');
  // Asosiasi exefile
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\exefile\shell\open\command','','"%1" %*');
  // Asosiasi comfile
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\comfile\shell\open\command','','"%1" %*');
  // Asosiasi piffile
  ApiSetRegString(GetProcAddress(OwnerHDC,'ApiSetRegString')) (HKEY_LOCAL_MACHINE,'\SOFTWARE\Classes\piffile\shell\open\command','','"%1" %*');

  OnAddToLog (GetProcAddress (OwnerHDC, 'ApiOnAddLog'))('[PLUGIN] RegFixer Finished.',' ',-1,4);
end;

Function ApiPluginGetType: integer;
begin
// Type of module
Result:= API_SCANATRUN;
end;

Function ApiPluginGetName: PChar;
begin
// Module name
Result:= 'Registry Fixer';
end;

Function ApiPluginGetInfo: PChar;
begin
// Information about the module
  Result:= 'Ini adalah sebuah Plug-in contoh yang dibuat untuk mengembalikan setting registry yang dirubah oleh malware. '+
           'Plug-in ini akan berjalan jika proses scanning dimulai. Hanya kompatibel pada Sigma 1.0.0.30, jika digunakan pada versi '+
           'dibawahnya, kemungkinan program tidak akan berjalan dengan baik';
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
