unit avAPI;

Interface

uses Windows, Classes, SysUtils, avTypes, avExt, registry;

////////////////////////////////////////////////////////////////
type
// Procedure in API plugin
  TApiPluginGetType         = Function: Integer;
  TApiPluginGetName         = Function: PChar;
  TApiPluginGetAutor        = Function: PChar;
  TApiPluginGetInfo         = Function: PChar;
  TApiPluginInit            = Procedure(Owner: integer);
  TApiPluginInitOnScan      = Procedure;
  TApiPluginScanFile        = Function(FileName: PChar): integer;
  TApiPluginScanDir         = Function(DirName: PChar): integer;
  TApiSendInfectedFile      = Procedure(FileName: PChar);
  TApiPluginReturnMes       = Function: integer;
  TApiPluginGetFileForScan  = Function: PChar;
  TApiPluginGetDirForScan   = Function: PChar;
  TApiSetRegistryString     = Procedure(Root : DWORD; Alamat,reg : String; Value : Integer);
  TApiSetRegistryInteger    = Procedure(Root : DWORD; Alamat,reg : String; Value : Integer);
  TApiGetEngineVersion      = Function : integer;
  TApiRegistryDeleteKey     = Procedure (Root : DWORD; Alamat : String; Value : String);
  TApiRegistryDeleteValue   = Procedure (Root : DWORD; Alamat : String; Value : String);
  TApiKillTaskByName        = Function (Nama : String) : Boolean;
  TApiKillTaskByPID         = Function (PID : DWORD) : Boolean;

  // API Plugin Type's record
  TApiPlugin       = record

  ApiPlugPath      : String;
  ApiHandle        : integer;
  ApiPlugName      : ShortString;
  ApiPlugAutor     : ShortString;
  ApiPluginfo      : PChar;
  ApiPlugType      : Integer;
  ApiPlugHandle    : integer;

  ApiPlugInit           : TApiPluginInit;
  APIPlugInitOnScan     : TApiPluginInitOnScan;
  ApiPlugMessage        : TApiPluginReturnMes;
  ApiPlugScanDir        : TApiPluginScanDir;
  ApiPlugScanFile       : TApiPluginScanFile;
  ApiPlugGetScanFile    : TApiPluginGetFileForScan;
  ApiPlugGetScanDir     : TApiPluginGetDirForScan;
  ApiPlugSendInfected   : TApiSendInfectedFile;
  ApiSetRegistryString  : TApiSetRegistryString;
  ApiSetRegistryInteger : TApiSetRegistryInteger;
  ApiGetEngineVersion   : TApiGetEngineVersion;
  ApiRegistryDeleteKey  : TApiRegistryDeleteKey;
  ApiRegistryDeleteValue: TApiRegistryDeleteValue;
  ApiKillTaskByName     : TApiKillTaskByName;
  ApiKillTaskByPID      : TApiKillTaskByPID;
end;
// Plugin list
  PApiPlugin=^TApiPlugin;
  TApiPlugins=class(TList);
var
  ApiPlugins  :TApiPlugins;
  lib         :integer;
  ApiPlugin   :PApiPlugin;
////////////////////////////////////////////////////////////////
  Procedure InitializeApiPlugin;
  Procedure FreeApiPluginList;
  Procedure LoadApiPlugin(PluginName: String);
  Procedure LoadApi(ApiDir: String);

implementation
  uses avScanner, avKernel, uMain, proses;
////////////////////////////////////////////////////////////////

//////////////////// Kode ////////////////////////////////////////////////
function ApiKillTaskByName(Nama : String) : Boolean;
begin
  Result := KillByName(Nama);
end;

function ApiKillTaskByPID(PID:dword) : boolean;
begin
  Result := KillByPID(PID);
end;

Procedure ApiSetRegString(root : DWORD; Alamat, reg : string; value : string); far;
begin
  SetRegistryString(Root,Alamat,Reg,Value);
end;

function ApiGetEngineVersion : integer;
begin
  Result := 103;
end;

Procedure ApiSetRegInteger(Root : DWORD; Alamat,reg : String; Value : Integer); far;
begin
  SetRegistryInteger(root,alamat,reg,value);
end;

Procedure ApiRegistryDeleteKey(Root : DWORD; Alamat : String; Value : String); far
begin
  registrydeletekey(Root,Alamat,Value);
end;

Procedure ApiRegistryDeleteValue(Root : DWORD; Alamat : String; Value : String); far
begin
  registrydeletevalue(Root,Alamat,Value);
end;

Procedure ApiOnVirFound(FileName, VirName: PChar;Typedata:integer); far;
begin
  OnVirFoundProc(FileName,VirName,TypeData);
end;

Procedure ApiWarning (FileName:String; Message:String); far;
begin
  OnWarningHeurProc(FileName,Message);
end;

Procedure ApiOnReadError(FileName: String; ID: Integer); far;
begin
  OnReadErrorProc(FileName,1);
end;

Procedure ApiOnAddLog(Infeksi, Location : String; ID : Integer; metode : integer); far;
begin
  OnAddToLogProc(Infeksi,Location,ID,metode);
end;

Procedure ApiAddToExtList(Ext: PChar); far;
begin
  APIExestensionList.Add(Ext);
end;

Procedure ApiOnScanStart; far;
begin
  OnScanExecuteProc;
end;

Procedure ApiScanFile(FileName: PChar); far;
begin
  if FileName <> '' then
  begin
    Sigma := TAvScanner.Create(True);
    Sigma.NeedForAPI := true;
    Sigma.AvAction := TScanFile;
    Sigma.FileName := FileName;
    ApiOnScanStart;
  end;
end;

Procedure ApiScanDir(DirName: PChar); far;
begin
  if DirName <> '' then
  begin
    Sigma := TAvScanner.Create(True);
    Sigma.NeedForAPI := true;
    Sigma.AvAction := TScanDir;
    Sigma.DirName := DirName;
    ApiOnScanStart;
  end;
end;

Procedure ApiScanFileInThread(FileName: PChar); far;
begin
  ScanFile(FileName);
end;

Procedure ApiScanDirInThread(DirName: PChar); far;
begin
  ScanDir(DirName)
end;

Function ApiScanFileInPlugin(FileName: PChar; var VirName: PChar): Boolean; far;
var
VName: String;
begin
  VName := PChar(ScanFileBiasa(FileName));
  if VName = 'NONE' then begin
    Result := False;
  end else begin
    Result := True;
    VirName := PChar(VName);
  end;
end;

Procedure ExitWaitForPlugin; far;
begin
  Wait := False;
end;
////////////////////////////////////////////////////////////////
Procedure InitializeApiPlugin;
begin
  ApiPlugins:=TApiPlugins.Create;
end;

Procedure FreeApiPluginList;
begin
  ApiPlugins.Free;
end;

Procedure LoadApi(ApiDir: String);
Var
  SR:TSearchRec;
  FindRes:Integer;
  EX,tmp : String;
  MDHash : String;
  c: cardinal;
  Four: integer;
begin
  Four := 0;
  FindRes:=FindFirst(ApiDir+'*.*',faAnyFile,SR);
  While FindRes=0 do
   begin
    if ((SR.Attr and faDirectory)=faDirectory) and
    ((SR.Name='.')or(SR.Name='..')) then
      begin
      FindRes:=FindNext(SR);
      Continue;
      end;
    if ((SR.Attr and faDirectory)=faDirectory) then
      begin
      LoadApi(ApiDir+SR.Name+'\');
      FindRes:=FindNext(SR);
      Continue;
      end;
    Ex := ExtractFileExt(ApiDir+SR.Name);
    if  LowerCase(Ex) = LowerCase('.dll') then
      begin
      LoadApiPlugin(ApiDir+sr.Name);
      end;
    FindRes:=FindNext(SR);
  end;
  FindClose(SR);
end;

Procedure LoadApiPlugin(PluginName: String);
var
  PlugHnd,i  : integer;
  PlugType   : TApiPluginGetType;
  PlugName   : TAPiPluginGetName;
  PlugAutor  : TApiPluginGetAutor;
  PlugInfo   : TAPiPluginGetInfo;
  PlugInit   : TApiPluginInit;
begin
  PlugHnd := LoadLibrary(PChar(PluginName));
  @PlugInfo := GetProcAddress(PlugHnd,'ApiPluginGetInfo');
  if @PlugInfo = nil then FreeLibrary(PlugHnd)
  else
  begin
    try
    New(ApiPlugin);
    // Get Plugin Handle of Procedures & Functions:
    @PlugName         := GetProcAddress(PlugHnd,'ApiPluginGetName');
    @PlugAutor        := GetProcAddress(PlugHnd,'ApiPluginGetAutor');
    @PlugType         := GetProcAddress(PlugHnd,'ApiPluginGetType');

    ApiPlugin.ApiPlugName   := PlugName;
    ApiPlugin.ApiPlugAutor  := PlugAutor;
    ApiPlugin.ApiPluginfo   := PlugInfo;
    ApiPlugin.ApiPlugHandle := PlugHnd;
    ApiPlugin.ApiPlugType   := PlugType;

    ApiPlugin.ApiPlugMessage     := GetProcAddress(PlugHnd,'ApiPlugMessage');
    ApiPlugin.APIPlugInitOnScan  := GetProcAddress(PlugHnd,'APIPlugInitOnScan');
    ApiPlugin.ApiPlugScanDir     := GetProcAddress(PlugHnd,'ApiPlugScanDir');
    ApiPlugin.ApiPlugScanFile    := GetProcAddress(PlugHnd,'ApiPlugScanFile');
    ApiPlugin.ApiPlugGetScanFile := GetProcAddress(PlugHnd,'ApiPlugGetScanFile');
    ApiPlugin.ApiPlugGetScanDir  := GetProcAddress(PlugHnd,'ApiPlugGetScanDir');
    ApiPlugin.ApiPlugSendInfected:= GetProcAddress(PlugHnd,'ApiPlugSendInfected');
    ApiPlugin.ApiSetRegistryString := GetProcAddress(PlugHnd,'ApiPlugSetRegistryString');
    ApiPlugin.ApiSetRegistryInteger := GetProcAddress(PlugHnd,'ApiPlugSetRegistryInteger');
    //
    //
    {}
    ApiPlugin.ApiPlugPath := PluginName;
    //
    TApiPluginInit(GetProcAddress(PlugHnd, 'InitApiPlug'))(HInstance);
    //
    ApiPlugins.Add(Apiplugin);
    Apiplugin := ApiPlugins.Items[ApiPlugins.count-1];

except
end;
end;
end;
////////////////////////////////////////////////////////////////
exports ApiOnVirFound;
exports ApiWarning;
exports ApiOnAddLog;
exports ApiAddToExtList;
exports ApiScanFile;
exports ApiScanDir;
exports ApiOnScanStart;
exports ApiScanFileInPlugin;
exports ExitWaitForPlugin;
exports ApiScanDirInThread;
exports ApiScanFileInThread;
exports ApiOnReadError;
exports ApiSetRegString;
exports ApiSetRegInteger;
exports ApiGetEngineVersion;
exports ApiRegistryDeleteKey;
exports ApiRegistryDeleteValue;
exports ApiKillTaskByName;
exports ApiKillTaskByPID;
////////////////////////////////////////////////////////////////
end.
