////////////////////////////////////////////////////////////////////////////////
// Autor: BlackCash                                                           //
// Email: BlackCash2006@Yandex.ru                                             //
// Модуль экспорта функций движка из библиотеки 'Kernel.dll' и                //
// Описание типов движка.                                                     //
////////////////////////////////////////////////////////////////////////////////
unit avCore;

interface
uses Windows, SysUtils, Classes, ComCtrls, Graphics,dialogs;
Const
  DllName = 'avCore.dll';
Type TSystemPath=(Desktop,StartMenu,Programs,Startup,Personal, winroot, winsys);
Type TRegAction = (TAcsess, TRun, TControlPanel, TConsole);

TProgressEvent = Procedure(Current: integer);

type
    VRec = record
    VName: String[100];
    Vsign: String[200];
    VPos:  String[10];
    VType: Char;
end;

type
PMyRec = ^TMyRec;
TMyRec = record
   FName: String[100];
   LName: String[100];
   Count: String[10];
   Base : Array [0..1000000] of Vrec;
end;

type
  PInfoCallBack = ^TInfoCallBack;
  TInfoCallBack = record
    FAction      : Integer; // тип изменения (константы FILE_ACTION_XXX)
    FDrive       : string;  // диск, на котором было изменение
    FOldFileName : string;  // имя файла до переименования
    FNewFileName : string;  // имя файла после переименования
end;
TWatchFileSystemCallBack = procedure (pInfo: TInfoCallBack);

const
  FILE_LIST_DIRECTORY   = $0001;

type
  PFileNotifyInformation = ^TFileNotifyInformation;
  TFileNotifyInformation = record
    NextEntryOffset : DWORD;
    Action          : DWORD;
    FileNameLength  : DWORD;
    FileName        : array[0..0] of WideChar;
  end;

  WFSError = class(Exception);

  TWFS = class(TThread)
  private
    FName           : string;
    FFilter         : Cardinal;
    FSubTree        : boolean;
    FInfoCallBack   : TWatchFileSystemCallBack;
    FWatchHandle    : THandle;
    FWatchBuf       : array[0..4096] of Byte;
    FOverLapp       : TOverlapped;
    FPOverLapp      : POverlapped;
    FBytesWritte    : DWORD;
    FCompletionPort : THandle;
    FNumBytes       : Cardinal;
    FOldFileName    : string;
    function CreateDirHandle(aDir: string): THandle;
    procedure WatchEvent;
    procedure HandleEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(pName: string; pFilter: cardinal; pSubTree: boolean; pInfoCallBack: TWatchFileSystemCallBack);
    destructor Destroy; override;
  end;

var
  WFS: TWFS;
Function GetSize(FileN: PChar): PChar; stdcall; external DllName;
Function GetFileMd5Hash(FileName:String): PChar;stdcall; external DllName;
procedure NTReboot; stdcall; external DllName;
procedure ExitWinNT(AShutdown: Boolean); stdcall; external DllName;
Function isPortOpen(Prt: integer) : Boolean; stdcall; external DllName;
Function ShowVersion : PChar; stdcall; external DllName;
function PathGetShortName(const Path: PChar): PChar; stdcall; external DllName;
Function ShredFile(const FileName: PChar) : Boolean; stdcall; external DllName;
Function AddCarantinFiles(FileName: PChar; Index: Integer; Add: Boolean) :
Boolean; stdcall; external DllName;
Function FindVirSignat(VirSign : PChar;VSPOS : integer; FileScan : PChar):Boolean; stdcall; external DllName;
Function DeleteInfected(FileName : PChar) : Boolean; stdcall; external DllName;
Function GetRegOptions(Action: TRegAction) : Boolean; stdcall; external DllName;
Function GetKernelVersion: PChar; stdcall; external DllName;
Function FindHEXSignature(FileName,HexSign: String; Offset: integer): Boolean; stdcall; external
DllName;
Function GetSystemPath(SystemPath:TSystemPath):PChar; stdcall; external DllName;
Function FileMaxPercent(Path: PChar): integer; stdcall; external DllName;
Function ScanAI(FileName: String): Real; stdcall; external DllName;
function isBusy(FileName: PChar): boolean; stdcall; external DllName;
Function FindHEXSignatureAI(FileName,HexSign: PChar): Boolean; stdcall;
external DllName;
Procedure UnPakBaseToStream(Path: String;Var R: PMyRec); stdcall; external DllName;
Procedure PackBase(Path,OutPath: String); stdcall; external DllName;
Procedure UnPakBase(Path,PathOUT: PChar); stdcall; external DllName;
procedure StartWatch(pName: String; pFilter: cardinal; pSubTree: boolean; pInfoCallBack: TWatchFileSystemCallBack);
procedure StopWatch;
Function MoveToCarantine(FileName : String;VirName: String) : Boolean;
procedure BuildCarantineList(ListView1: TListView);
Procedure DelFromCarantine(ListIndex: integer);
Function RestoreCarFile(ListIndex: integer): boolean;
{------------------------------------------------------------------------------}
implementation

uses Math;
{Monitoring FileSystem--------------------------------------}
procedure StartWatch(pName: String; pFilter: cardinal; pSubTree: boolean; pInfoCallBack: TWatchFileSystemCallBack);
begin
 WFS:=TWFS.Create(pName, pFilter, pSubTree, pInfoCallBack);
end;

procedure StopWatch;
var
  Temp : TWFS;
begin
try
  if Assigned(WFS) then
  begin
   PostQueuedCompletionStatus(WFS.FCompletionPort, 0, 0, nil);
   Temp := WFS;
   WFS:=nil;
   Temp.Terminate;
  end;
except
end;
end;

constructor TWFS.Create(pName: string; pFilter: cardinal;
  pSubTree: boolean; pInfoCallBack: TWatchFileSystemCallBack);
begin
  inherited Create(True);
  FreeOnTerminate:=True;
  FName:=IncludeTrailingBackslash(pName);
  FFilter:=pFilter;
  FSubTree:=pSubTree;
  FOldFileName:=EmptyStr;
  ZeroMemory(@FOverLapp, SizeOf(TOverLapped));
  FPOverLapp:=@FOverLapp;
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  FInfoCallBack:=pInfoCallBack;
  Resume
end;


destructor TWFS.Destroy;
begin
  PostQueuedCompletionStatus(FCompletionPort, 0, 0, nil);
  CloseHandle(FWatchHandle);
  FWatchHandle:=0;
  CloseHandle(FCompletionPort);
  FCompletionPort:=0;
  inherited Destroy;
end;


function TWFS.CreateDirHandle(aDir: string): THandle;
begin
Result:=CreateFile(PChar(aDir), FILE_LIST_DIRECTORY, FILE_SHARE_READ+FILE_SHARE_DELETE+FILE_SHARE_WRITE,
                   nil,OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED, 0);
end;

procedure TWFS.Execute;
begin
  FWatchHandle:=CreateDirHandle(FName);
  WatchEvent;
end;

procedure TWFS.HandleEvent;
var
  FileNotifyInfo : PFileNotifyInformation;
  InfoCallBack   : TInfoCallBack;
  Offset         : Longint;
begin
  Pointer(FileNotifyInfo) := @FWatchBuf[0];
  repeat
  Offset:=FileNotifyInfo^.NextEntryOffset;
  InfoCallBack.FAction:=FileNotifyInfo^.Action;
  InfoCallBack.FDrive:=FName;
  SetString(InfoCallBack.FNewFileName,FileNotifyInfo^.FileName,
  FileNotifyInfo^.FileNameLength );
  InfoCallBack.FNewFileName:=Trim(InfoCallBack.FNewFileName);
  case FileNotifyInfo^.Action of
  FILE_ACTION_RENAMED_OLD_NAME: FOldFileName:=Trim(WideCharToString(@(FileNotifyInfo^.FileName[0])));
  FILE_ACTION_RENAMED_NEW_NAME: InfoCallBack.FOldFileName:=FOldFileName;
  end;

  FInfoCallBack(InfoCallBack);
  PChar(FileNotifyInfo):=PChar(FileNotifyInfo)+Offset;
  until (Offset=0) or Terminated;
end;

procedure TWFS.WatchEvent;
var
 CompletionKey: Cardinal;
begin
  FCompletionPort:=CreateIoCompletionPort(FWatchHandle, 0, Longint(pointer(self)), 0);
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  if not ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree,
  FFilter, @FBytesWritte,  @FOverLapp, 0) then
  begin
  raise WFSError.Create(SysErrorMessage(GetLastError));
  Terminate;
  end else
  begin
  while not Terminated do
  begin
  GetQueuedCompletionStatus(FCompletionPort, FNumBytes, CompletionKey, FPOverLapp, INFINITE);
  if CompletionKey<>0 then
  begin
  Synchronize(HandleEvent);
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  FBytesWritte:=0;
  ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree, FFilter,
  @FBytesWritte, @FOverLapp, 0);
  end else Terminate;
  end
  end
end;
{********************************************************************}
Function MoveToCarantine(FileName : String;VirName: String) : Boolean;
var
TempList : TStringList;
CarName : String;
begin
  TempList := TStringList.Create;

  If DirectoryExists(ExtractFilePath(ParamStr(0))+'Qurantine\') = false then begin
  MkDir(ExtractFilePath(ParamStr(0))+'Qurantine\');
  end;
  try
  if FileExists(ExtractFilePath(ParamStr(0))+'Qurantine\Files.ini') = True then
  TempList.LoadFromFile(ExtractFilePath(ParamStr(0))+'Qurantine\Files.ini');
  except
  end;

  Randomize;
  CarName := 'INFECTED('+IntToStr(Random(121121))+').Vir';
  Result := MoveFile(PChar(FileName),PChar(ExtractFilePath(ParamStr(0))+'Qurantine\'+CarName));
  if Result = True then begin
  TempList.Add(FileName);
  TempList.Add(CarName);
  TempList.Add(VirName);
  TempList.Add(FormatDateTime('hh:mm dd.mm.yy',Now));
  end;
TempList.SaveToFile('Qurantine\Files.ini');
TempList.Free;
end;

Procedure DelFromCarantine(ListIndex: integer);
var
i: integer;
NextREC: integer;
Count: integer;
TempList: TStringList;
begin
NextRec:=0;
TempList := TStringList.Create;
try
TempList.LoadFromFile(ExtractFilePath(ParamStr(0))+'Qurantine\Files.ini');

        NextREC := ListIndex * 4;

        TempList.Delete(NextREC+3);
        TempList.Delete(NextREC+2);
        TempList.Delete(NextREC+1);
        TempList.Delete(NextREC);

        TempList.SaveToFile(ExtractFilePath(ParamStr(0))+'Qurantine\Files.ini');

except
end;
TempList.Free;
end;

Function RestoreCarFile(ListIndex: integer): boolean;
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
TempList.LoadFromFile(ExtractFilePath(ParamStr(0))+'Qurantine\Files.ini');

        NextREC := ListIndex * 4;
        Path := TempList.Strings[nextrec+1];
        NewP := TempList.Strings[nextrec];

        if MoveFile(PChar(ExtractFilePath(ParamStr(0))+'Qurantine\'+Path),PChar(NewP)) = true then begin
                DelFromCarantine(i);
                Result := True;
        end else Result := False;

except
Result := False;
end;
TempList.Free;
end;

procedure BuildCarantineList(ListView1: TListView);
var
i: integer;
NextREC: integer;
Count: integer;
TempList: TStringList;
//
FileN : String;
CarName : String;
Virus : String;
Date : String;
//
begin
NextRec:=0;
TempList := TStringList.Create;
ListView1.Clear;
try
TempList.LoadFromFile(ExtractFilePath(ParamStr(0))+'Qurantine\Files.ini');
Count := (TempList.Count) div 4;
TempList.Insert(0,'');
if TempList.Count <> -1 then
For i := 1 to Count do begin

  NextREC := i*4;
  FileN := TempList.Strings[NextREC-3];
  CarName := TempList.Strings[NextREC-2];
  Virus := TempList.Strings[NextREC-1];
  Date := TempList.Strings[NextREC];
  with ListView1.Items.Add do begin

  if FileExists(ExtractFilePath(ParamStr(0))+'Qurantine\'+CarName) = False then begin
  Data :=Pointer(RGB(255,208,208));
  ImageIndex := 2;
  end
  else begin
  Data :=Pointer(clWhite);
  ImageIndex := 1;
  end;
  Caption := FileN;
  SubItems.Add(CarName);
  SubItems.Add(Virus);
  SubItems.Add(Date);
  end;
end;

except
end;

TempList.Free;
end;

end.
 