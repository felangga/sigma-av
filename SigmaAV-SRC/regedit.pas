unit regedit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, Registry, SUIMgr, SUIButton, ComOBJ, ShellApi,
  SUICheckListBox, ExtCtrls, SUIForm;

type
  TRegistryEditor = class(TForm)
    Label1: TLabel;
    suiForm1: TsuiForm;
    ListCheck: TsuiCheckListBox;
    Button2: TsuiButton;
    suiThemeManager1: TsuiThemeManager;
    suiButton1: TsuiButton;
    procedure suitempListCheckClick(Sender: TObject);
    procedure suitempButton2Click(Sender: TObject);
    procedure suiButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RegistryEditor: TRegistryEditor;

implementation

uses UMain, avKernel;

{$R *.dfm}

function GetRegistryString(ROOT : DWORD;KeyName,Reg: string): Integer;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create(KEY_READ);
  try
    Registry.RootKey := ROOT;
    // False because we do not want to create it if it doesn't exist
    Registry.OpenKey(KeyName, False);
    if not Registry.ValueExists(Reg) then
      Result := 0
    else
      Result := Registry.ReadInteger(Reg);
  finally
    Registry.Free;
  end;
end;

Procedure setregistrystring(root : DWORD; Alamat, reg : string; value : string);
var regis : TRegistry;
begin
   Regis := TRegistry.Create;
  try
    Regis.RootKey := ROOT;
    if Regis.OpenKey(Alamat,True) then
    begin
      Regis.WriteString(Reg,Value);
      Regis.CloseKey;
    end;
  finally
    Regis.Free;
  end;
end;

procedure setregistry(Root : DWORD; Alamat,reg : String; Value : Integer);
var Regis : TRegistry;
begin
  Regis := TRegistry.Create;
  try
    Regis.RootKey := Root;
    if Regis.OpenKey(Alamat, True) then
      Regis.WriteInteger(Reg,Value);
  finally
    Regis.CloseKey;
    Regis.Free;
  end;
end;

procedure TRegistryEditor.suitempListCheckClick(Sender: TObject);
var Reg : TRegistry;
begin
  with listcheck do
  begin
    { Task Manager }
    if Checked[0] = true then
    begin
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System','DisableTaskMgr',0);
    end
   else
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System','DisableTaskMgr',1);

    { Registry Editor }
    if Checked[1] = true then
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableRegistryTools',0)
    else
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableRegistryTools',1);

    { MSConfig }
    if Checked[2] = true then
      SetRegistry(HKEY_CURRENT_USER,'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableMSConfig',0)
    else
      SetRegistry(HKEY_CURRENT_USER,'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableMSConfig',1);

    { System Restore }
    if Checked [3] = true then
      SetRegistry(HKEY_LOCAL_MACHINE,'\Software\Policies\Microsoft\WindowsNT\SystemRestore\','DisableSR',0)
    else
      SetRegistry(HKEY_LOCAL_MACHINE,'\Software\Policies\Microsoft\WindowsNT\SystemRestore\','DisableSR',1);

    { Command Prompt }
    if Checked [4] = true then
     begin
      { kembalikan asosiasi shell cmd }
      SetRegistryString(HKEY_LOCAL_MACHINE,'\SYSTEM\ControlSet001\Control\SafeBoot\','AlternateShell','cmd.exe');
      SetRegistryString(HKEY_LOCAL_MACHINE,'\SYSTEM\ControlSet002\Control\SafeBoot\','AlternateShell','cmd.exe');
      SetRegistryString(HKEY_LOCAL_MACHINE,'\SYSTEM\CurrentControlSet\Control\SafeBoot\','AlternateShell','cmd.exe');

      SetRegistry(HKEY_CURRENT_USER,'\Software\Policies\Microsoft\Windows\System\','DisableCMD',0)
     end
    else
      SetRegistry(HKEY_CURRENT_USER,'\Software\Policies\Microsoft\Windows\System\','DisableCMD',1);

    { Show Hidden }
    if Checked [5] = true then
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\','Hidden',1)
    else
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\','Hidden',0);

    { Show Hide File Ext }
    if Checked [6] = true then
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\','HideFileExt',0)
    else
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\','HideFileExt',1);

     { Show Run }
    if Checked [7] = true then
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoRun',0)
    else
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoRun',1);

    { Show Find }
    if Checked [8] = true then
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoFind',0)
    else
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoFind',1);

    { Show Control Panel }
    if Checked [9] = true then
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoControlPanel',0)
    else
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoControlPanel',1);

    { Show FolderOptions }
    if Checked [10] = true then
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoFolderOptions',0)
    else
      SetRegistry(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoFolderOptions',1);

    { Protect Flash }
    if Checked [11] = true then
      SetRegistry(HKEY_LOCAL_MACHINE,'\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies','WriteProtect',1)
    else
      RegistryDeleteValue(HKEY_LOCAL_MACHINE,'\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies','WriteProtect')
     end;
end;

procedure TRegistryEditor.suitempButton2Click(Sender: TObject);
begin
  Close;
end;

procedure TRegistryEditor.suiButton1Click(Sender: TObject);
var AppName : PChar;
begin
  AppName := Pchar('C:\Windows\explorer.exe');
  ShellExecute(Handle,'open', AppName, nil, nil, SW_SHOWNORMAL);
  KillTask('explorer.exe');
end;

procedure TRegistryEditor.FormShow(Sender: TObject);
begin
  if GetRegistryString(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableTaskMGR') = 0 then
    ListCheck.Checked [0] := tRue;
   if GetRegistryString(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableRegistryTools') = 0 then
    ListCheck.Checked [1] := True;
   if GetRegistryString(HKEY_CURRENT_USER,'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\','DisableMSConfig') = 0 then
    ListCheck.Checked [2] := true;
   if GetRegistryString(HKEY_LOCAL_MACHINE,'\Software\Policies\Microsoft\WindowsNT\SystemRestore\','DisableSR') = 0 then
    ListCheck.Checked [3] := true;
   if GetRegistryString(HKEY_CURRENT_USER,'\Software\Policies\Microsoft\Windows\System\','DisableCMD') = 0 THEN
    ListCheck.Checked [4] := true;
   if GetRegistryString(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\','Hidden') = 1 then
    ListCheck.Checked [5] := true;
   if GetRegistryString(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\','HideFileExt') = 0 then
    ListCheck.Checked [6] := true;
   if GetRegistryString(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoRun') = 0 then
    ListCheck.Checked [7] := True;
   if GetRegistryString(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoFind') = 0 then
    ListCheck.Checked [8] := True;
   if GetRegistryString(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoControlPanel') = 0 then
    ListCheck.Checked [9] := True;
   if GetRegistryString(HKEY_CURRENT_USER,'\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\','NoFolderOptions') = 0 then
    ListCheck.Checked [10] := True;
   if GetRegistryString(HKEY_LOCAL_MACHINE,'\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies','WriteProtect') = 0 then
    ListCheck.Checked [11] := False;

end;

end.
