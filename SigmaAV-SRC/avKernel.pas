unit avKernel;

Interface

uses Windows, Classes, avTypes, avScanner, avDataBase, avExt, avAPI, SysUtils,
     ComCtrls, Graphics,dialogs, SuiListView,registry;

type
  TAvScanner = class(TThread)
  private
    Procedure AvScanFile(security : integer);
    Procedure AvScanDir(security : integer);
    Procedure AvRTPScan;
    Procedure AvRekursiDir;
  protected
    procedure Execute; override;
  public
    FileName, DirName,InScan  : String;
    NeedForAPI         : Boolean;
    SecurityGrade      : Integer;
    //---------------------------------------//
    AvAction           : TAvAction;
    //---------------------------------------//
  end;

  var m_strm_dec: TMemoryStream;
      bm_dec: TBitmap;
  Const
    randseed_init = 5;
    magic_header: String = 'kifmesoft';

  Function InitApiPlugin(ApiPlugIn: String): Boolean;
  Function GetDBRecCount: integer;
  Function GetPluginAPICount: integer;
  Function GetPluginAPIAutor(ID: integer): String;
  Function GetPluginAPIName(ID: integer): String;
  Function GetPluginAPIInfo(ID: integer): String;
  Function GetPluginAPIPath(ID: integer): String;
  Function GetKernelBuild: String;
  Function GetKernelVersion: String;
  function GetConsoleOutput(const Command: String; var Output, Errors: TStringList): Boolean;
  {---------------- Quarantine ----------------------}
  procedure BuildQuarantineList(ListView1: TSuiListView);
  Function RestoreQarFile(ListIndex: integer): boolean;
  Function MoveToQuarantine(FileName : String;VirName: String) : Boolean;
  Procedure DelFromQuarantine(ListIndex: integer);

  {---------------- Fungsi Registry -----------------}
  Procedure RegistryDeleteKey(Root : DWORD; Alamat : String; Value : string);
  Procedure RegistryDeleteValue(Root : DWORD; Alamat : String; Value : string);
  Procedure SetRegistryInteger(Root : DWORD; Alamat,reg : String; Value : Integer);
  Procedure SetRegistryString(Root : DWORD; Alamat,reg : String; Value : string);

  {--------------------------------------------------}

  function FindFile(const filespec: TFileName; attributes: integer
   = faReadOnly Or faHidden Or faSysFile Or faArchive): Integer;
  {-------------------- Repair File -----------------}
  Function ZulDecryptFile(var FileName: String; Stream: TMemoryStream; Bitmap: TBitmap;
                     Key: Integer): Integer;
  {--------------------------------------------------}

  Procedure LoadApiPlugins(ApiPath: String);
  Procedure ClearExtList;
  Procedure InitExtList;
  Procedure FreeExtList;
  Procedure AddToExtList(Ext: String);
  Procedure LoadDataBases(DirName: String);
  Procedure InitApi;
  Procedure FreeApi;
  Procedure InitAvProc(AvProgressProc       : OnProgress;
                     AvVirFoundProc         : OnVirFound;
                     AvWarningProc          : OnWarningHeur;
                     AvReadErrorProc        : OnReadError;
                     AvScanCompleteProc     : OnScanComplete;
                     AvOnAddToLogProc       : OnAddToLog;
                     AvOnScanExecuteProc    : OnScanExecute);
var
  Sigma     : TAvScanner;
  Jmlh      : integer;

implementation

Procedure TAvScanner.AvScanFile(security : integer);
begin
  ScanFile(FileName);
end;

Procedure TAvScanner.AvScanDir(security : integer);
begin
  ScanDir(DirName);
end;

Procedure TAvScanner.AvRTPScan;
begin
  RTPScan(DirName);
end;

Procedure TAVScanner.AvRekursiDir;
begin
  REkursiDir(DirName);
end;

Procedure TAvScanner.Execute;
var
  i : integer;
begin

  if NeedForAPI then
  for i := 0 to ApiPlugins.Count-1 do begin
    ApiPlugin := ApiPlugins.Items[i];
    if ApiPlugin.ApiPlugType = API_SCANATRUN then ApiPlugin.APIPlugInitOnScan;
  end;

  if AvAction = TRekursiDir then AvRekursiDir;
  if AvAction = TScanFile then AvScanFile(SecurityGrade);
  if AvAction = TScanDir  then AvScanDir(SecurityGrade);
  if AvAction = TRTPScan  then AvRTPScan;

  OnScanCompleteProc;
end;

Function GetKernelVersion: String;
begin
  Result := 'v0.10';
end;

Function GetKernelBuild: String;
begin
  Result := '25 September 2009';
end;

Procedure InitAvProc(AvProgressProc         : OnProgress;
                     AvVirFoundProc         : OnVirFound;
                     AvWarningProc          : OnWarningHeur;
                     AvReadErrorProc        : OnReadError;
                     AvScanCompleteProc     : OnScanComplete;
                     AvOnAddToLogProc       : OnAddToLog;
                     AvOnScanExecuteProc    : OnScanExecute);
begin
  OnProgressProc        :=  AvProgressProc;
  OnVirFoundProc        :=  AvVirFoundProc;
  OnWarningHeurProc     :=  AvWarningProc;
  OnReadErrorProc       :=  AvReadErrorProc;
  OnScanCompleteProc    :=  AvScanCompleteProc;
  OnAddToLogProc        :=  AvOnAddToLogProc;
  OnScanExecuteProc     :=  AvOnScanExecuteProc;
end;

Function InitApiPlugin(ApiPlugIn: String): Boolean;
begin
  try
  LoadApiPlugin(ApiPlugIn);
  Result := True;
  except
  Result := False;
  end;
end;

function GetConsoleOutput(const Command: String; var Output, Errors: TStringList): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  PipeOutputRead: THandle;
  PipeOutputWrite: THandle;
  PipeErrorsRead: THandle;
  PipeErrorsWrite: THandle;
  Succeed: Boolean;
  Buffer: array [0..255] of Char;
  NumberOfBytesRead: DWORD;
  Stream: TMemoryStream;
begin
//------------------------------------------------------------------------------

  FillChar(ProcessInfo, SizeOf(TProcessInformation), 0);

  FillChar(SecurityAttr, SizeOf(TSecurityAttributes), 0);
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.bInheritHandle := true;
  SecurityAttr.lpSecurityDescriptor := nil;

  CreatePipe(PipeOutputRead, PipeOutputWrite, @SecurityAttr, 0);
  CreatePipe(PipeErrorsRead, PipeErrorsWrite, @SecurityAttr, 0);

  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb:=SizeOf(StartupInfo);
  StartupInfo.hStdInput := 0;
  StartupInfo.hStdOutput := PipeOutputWrite;
  StartupInfo.hStdError := PipeErrorsWrite;
  StartupInfo.wShowWindow := sw_Hide;
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;

  if  CreateProcess(nil, PChar(command), nil, nil, true,
  CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil,
  StartupInfo, ProcessInfo) then begin
    result:=true;

    CloseHandle(PipeOutputWrite);
    CloseHandle(PipeErrorsWrite);

    Stream := TMemoryStream.Create;
    try
      while true do begin
        succeed := ReadFile(PipeOutputRead, Buffer, 255, NumberOfBytesRead, nil);
        if not succeed then break;
        Stream.Write(Buffer, NumberOfBytesRead);
      end;
      Stream.Position := 0;
      Output.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
    CloseHandle(PipeOutputRead);

    Stream := TMemoryStream.Create;
    try
      while true do begin
        succeed := ReadFile(PipeErrorsRead, Buffer, 255, NumberOfBytesRead, nil);
        if not succeed then break;
        Stream.Write(Buffer, NumberOfBytesRead);
      end;
      Stream.Position := 0;
      Errors.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
    CloseHandle(PipeErrorsRead);

    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    CloseHandle(ProcessInfo.hProcess);
  end
  else begin
    result:=false;
    CloseHandle(PipeOutputRead);
    CloseHandle(PipeOutputWrite);
    CloseHandle(PipeErrorsRead);
    CloseHandle(PipeErrorsWrite);
  end;

//------------------------------------------------------------------------------
end;


Procedure LoadApiPlugins(ApiPath: String);
begin
try
  LoadApi(ApiPath);
except
end;
end;

Procedure InitApi;
begin
  InitializeApiPlugin;
end;

Procedure FreeApi;
begin
  FreeApiPluginList;
end;

Function GetPluginAPICount: integer;
begin
  Result := ApiPlugins.Count-1;
end;

Function GetPluginAPIAutor(ID: integer): String;
begin
  ApiPlugin := ApiPlugins[ID];
  Result    := ApiPlugin.ApiPlugAutor;
end;

Function GetPluginAPIName(ID: integer): String;
begin
  ApiPlugin := ApiPlugins[ID];
  Result    := ApiPlugin.ApiPlugName;
end;

Function GetPluginAPIInfo(ID: integer): String;
begin
  ApiPlugin := ApiPlugins[ID];
  Result    := ApiPlugin.ApiPluginfo;
end;

Function GetPluginAPIPath(ID: integer): String;
begin
  ApiPlugin := ApiPlugins[ID];
  Result    := ApiPlugin.ApiPlugPath;
end;

Procedure InitExtList;
begin
  InitExestensionList;
end;

Procedure FreeExtList;
begin
  FreeExestensionList;
end;

Procedure AddToExtList(Ext: String);
begin
  ExestensionList.Add(Ext);
end;

Procedure ClearExtList;
begin
  ExestensionList.Clear;
end;

Procedure LoadDataBases(DirName: String);
begin
  FindDataBases(DirName);
end;

Function GetDBRecCount: integer;
begin
  Result := DBCount;
end;

Function MoveToQuarantine(FileName : String;VirName: String) : Boolean;
var
TempList : TStringList;
CarName : String;
f       : file;
begin

  TempList := TStringList.Create;

  If DirectoryExists(ExtractFilePath(ParamStr(0))+'Quarantine\') = false then begin
  MkDir(ExtractFilePath(ParamStr(0))+'Quarantine\');
  end;
  try
  if FileExists(ExtractFilePath(ParamStr(0))+'Quarantine\Files.ini') = True then
  TempList.LoadFromFile(ExtractFilePath(ParamStr(0))+'Quarantine\Files.ini');
  except
  end;

  Randomize;
  CarName := 'INFECTED('+IntToStr(Random(1212))+').Vir';
  Result := MoveFile(PChar(FileName),PChar(ExtractFilePath(ParamStr(0))+'Quarantine\'+CarName));
  Assign(F,ExtractFilePath(ParamStr(0))+'Quarantine\'+CarName);
  Reset(F);

  if Result = True then
  begin
    TempList.Add(FileName);
    TempList.Add(IntToStr(FileSize(f)));
    TempList.Add(CarName);
    TempList.Add(VirName);
    TempList.Add(FormatDateTime('hh:mm dd.mm.yy',Now));
  end;
TempList.SaveToFile('Quarantine\Files.ini');
TempList.Free;
Closefile(F);
end;

Procedure DelFromQuarantine(ListIndex: integer);
var
NextREC: integer;
TempList: TStringList;
begin
NextRec:=0;
TempList := TStringList.Create;
try
TempList.LoadFromFile(ExtractFilePath(ParamStr(0))+'Quarantine\Files.ini');

        NextREC := ListIndex * 5;
        TempList.Delete(NextRec+4);
        TempList.Delete(NextREC+3);
        TempList.Delete(NextREC+2);
        TempList.Delete(NextREC+1);
        TempList.Delete(NextREC);

        TempList.SaveToFile(ExtractFilePath(ParamStr(0))+'Quarantine\Files.ini');

except
end;
TempList.Free;
end;

Function RestoreQarFile(ListIndex: integer): boolean;
var
  i: integer;
  NextREC: integer;
  Path : String;
  NewP : String;
  TempList: TStringList;
begin
  NextRec:=0;
  TempList := TStringList.Create;
  try
    i := ListIndex;
    TempList.LoadFromFile(ExtractFilePath(ParamStr(0))+'Quarantine\Files.ini');
    NextREC := ListIndex * 5;
    Path := TempList.Strings[nextrec+2];
    NewP := TempList.Strings[nextrec];
    if MoveFile(PChar(ExtractFilePath(ParamStr(0))+'Quarantine\'+Path),PChar(NewP)) = true then
    begin
      DelFromQuarantine(i);
      Result := True;
    end
  else
    Result := False;

  except
    Result := False;
  end;
  TempList.Free;
end;

procedure BuildQuarantineList(ListView1: TSuiListView);
var
i: integer;
NextREC: integer;
Count: integer;
TempList: TStringList;
//
FileN : String;
CarName : String;
Size : String;
Virus : String;
Date : String;
f : textfile;
//
begin
  NextRec:=0;
  TempList := TStringList.Create;
  ListView1.Clear;
  try
  TempList.LoadFromFile(ExtractFilePath(ParamStr(0))+'Quarantine\Files.ini');
  Count := (TempList.Count) div 4;
  TempList.Insert(0,'');
  if TempList.Count <> -1 then
  For i := 1 to Count do
  begin
    NextREC := i*5;
    FileN := TempList.Strings[NextREC-4];
    Size  := TempList.Strings[NextRec-3];
    CarName := TempList.Strings[NextREC-2];
    Virus := TempList.Strings[NextREC-1];
    Date := TempList.Strings[NextREC];
    with ListView1.Items.Add do
    begin
      if FileExists(ExtractFilePath(ParamStr(0))+'Quarantine\'+CarName) = False then begin
      Data :=Pointer(RGB(255,208,208));
      ImageIndex := 0;
    end
  else
    begin
      Data :=Pointer(clWhite);
      ImageIndex := 0;
    end;
    Caption := FileN;
    SubItems.Add(Size);
    SubItems.Add(CarName);
    SubItems.Add(Virus);
    SubItems.Add(Date);
  end;
end;

except
  if not FileExists(ExtractFilePath(ParamStr(0))+'Quarantine\Files.ini') then
  begin
  {$I-}
  Assign(f,ExtractFilePath(ParamStr(0))+'Quarantine\Files.ini');
  rewrite(f);
  {$I+}
  Close(f);
  end;
end;

TempList.Free;
end;

Function ZulDecryptFile(var FileName: String;
                     Stream: TMemoryStream; Bitmap: TBitmap;
                     Key: Integer): Integer;
Var
  mh_length, sf_length, hdr_len: Integer;
  i1, i2, i3, i4, i5: Integer;
  c, i, w: Integer;
  p, pm: PByteArray;
  mh: String;
Begin
  Result:= 0;
  FileName:= '';
  If Bitmap = Nil Then Exit;
  Bitmap.PixelFormat:= pf24bit;
  If Bitmap.Empty Or
     ((Bitmap.Width * 3) < Length(magic_header)) Then
    Exit;
  RandSeed:= Key;
  p:= Bitmap.ScanLine[0];
  i1:= 0;
  mh_length:= Integer(Pointer(@p[i1])^);
  If mh_length <> Length(magic_header) Then
  Begin
    ShowMessage('Repair Failed : Invalid virus header..!! Maybe a false alarm and this file not contain a virus.');
    Exit;
  End;
  i2:= SizeOf(Integer);
  i3:= i2 + mh_length;
  sf_length:= Integer(Pointer(@p[i3])^);
  i4:= i3 + SizeOf(Integer);
  i5:= i4 + sf_length;
  hdr_len:= i5 + SizeOf(Integer);
  If (Bitmap.Width * 3) < hdr_len Then
    Exit;
  mh:= '';
  For i:= 1 To mh_length Do
    mh:= mh + Chr(p[i2 + i - 1] Xor Random(256));
  // *** cek magic_header
  If mh <> magic_header Then
  Begin
    ShowMessage('Repair Failed : Invalid Header..!!');
    Exit;
  End;
  // *** ambil FileName
  For i:= 1 To sf_length Do
    FileName:= FileName + Chr(p[i4 + i - 1] Xor
                          Random(256));
  Stream.Size:= Integer(Pointer(@p[i5])^);
  pm:= Stream.Memory;

  w:= Bitmap.Width * 3;
  c:= w * Bitmap.Height;

  If c < (hdr_len + Stream.Size) Then
    Exit;

  // *** Decrypt Data File
  For i:= hdr_len To c - 1 Do
  Begin
    p:= Bitmap.ScanLine[i Div w];
    If (i - hdr_len) < Stream.Size Then
      pm[i - hdr_len]:= p[i Mod w] Xor Random(256)
    Else Break;
  End;
  Result:= Stream.Size;
End;

function FindFile(const filespec: TFileName; attributes: integer): Integer;
var
  spec: string;
  list: TStringList;
  etung : Integer;

procedure RFindFile(const folder: TFileName);
var
  SearchRec: TSearchRec;
begin
  // Locate all matching files in the current
  // folder and add their names to the list
  if FindFirst(folder + spec, attributes, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Attr and faDirectory = 0) or
           (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          //list.Add(folder + SearchRec.Name);
           jmlh := jmlh + 1;
        until FindNext(SearchRec) <> 0;
    except
      FindClose(SearchRec);
      raise;
    end;
    FindClose(SearchRec);
  end;
  // Now search the subfolders
  if FindFirst(folder + '*', attributes Or faDirectory, SearchRec) = 0 then
  begin
    try
      repeat
        if ((SearchRec.Attr and faDirectory) <> 0) and
           (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          RFindFile(folder + SearchRec.Name + '\');
      until FindNext(SearchRec) <> 0;
    except
      FindClose(SearchRec);
      raise;
    end;
    FindClose(SearchRec);
  end;
end; // procedure RFindFile inside of FindFile

begin // function FindFile
  try
    spec:=(ExtractFileName(FileSpec));
    RFindFile(ExtractFilePath(filespec));
    Result := jmlh;
   except
    raise;
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

procedure setregistryinteger(Root : DWORD; Alamat,reg : String; Value : Integer);
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

procedure registrydeletekey(Root : DWORD; Alamat : String; Value : string);
var Regis : TRegistry;
begin
  Regis := TRegistry.Create;
  try
    Regis.RootKey := Root;
    if Regis.OpenKey(Alamat, True) then
      Regis.DeleteKey(Value);
  finally
    Regis.CloseKey;
    Regis.Free;
  end;
end;

procedure registrydeletevalue(Root : DWORD; Alamat : String; Value : string);
var Regis : TRegistry;
begin
  Regis := TRegistry.Create;
  try
    Regis.RootKey := Root;
    if Regis.OpenKey(Alamat, True) then
      Regis.DeleteValue(Value);
  finally
    Regis.CloseKey;
    Regis.Free;
  end;
end;

end.

