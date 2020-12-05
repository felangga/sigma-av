unit avDataBase;

Interface

uses Windows, SysUtils;
{Struct of Data Base File**********************}
type
  TDataRecord = record
    VirName   : String[50];
    SignType  : LongWord;
    Signature : String[255];
    Pos       : String[255];
  end;

  TDBFile     = file of TDataRecord;

type
  TStreamDB   = record
    DBCount   : integer;
    DBViruses : array of TDataRecord;
  end;
{**********************************************}
Var
  StreamDB    : TStreamDB;   // MainDataBase
  DBCount     : Integer = 0; // MainDataBase
  DBFile      : TDBFile;
  Hitung      : Integer;
  
{**********************************************}
  procedure CreateDBFile(const sFileName: String;var DBFile: TDBFile);
  procedure LoadDBFile(const sFileName: String;var DBFile: TDBFile);
  Procedure AddRecToDBFile(var DBFile: TDBFile; Rec: TDataRecord);
  Procedure RecounDBStream;
  Procedure FindDataBases(Dir:String);
  function FindDBLocation(Dir:String) : string;
implementation

Procedure RecounDBStream;
begin
  DBCount := 0;
end;

Procedure AddRecToDBFile(var DBFile: TDBFile; Rec: TDataRecord);
begin
  Seek(DBFile, FileSize(DBFile));
  Write(DBFile, rec);
end;

Procedure AddToDBStream(DBRec: TDataRecord);
begin
  StreamDB.DBCount := DBCount;
  SetLength(StreamDB.DBViruses, DBCount+1);
  StreamDB.DBViruses[DBCount] := DBRec;
end;

Procedure LoadDBFile(const sFileName: String;var DBFile: TDBFile);
var
  DBRec: TDataRecord;
begin
  AssignFile(DBFile, sFileName);
  Reset(DBFile);

  while not EOF(DBFile) do
    begin
      Read(DBFile, DBRec);
      AddToDBStream(DBRec);
      inc(DBCount);
    end;
  Hitung := DBCount;
end;

Procedure CreateDBFile(const sFileName: String;var DBFile: TDBFile);
begin
  AssignFile(DBFile, sFileName);
  Rewrite(DBFile);
end;

Procedure FindDataBases(Dir:String);
Var
  SR:TSearchRec;
  FindRes:Integer;
  EX,tmp : String;
  Four: integer;
begin
  FindRes:=FindFirst(Dir+'*.*',faAnyFile,SR);
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
      FindDataBases(Dir+SR.Name+'\');
      FindRes:=FindNext(SR);
      Continue;
      end;

    Ex := ExtractFileExt(Dir+SR.Name);

    if  LowerCase(Ex) = LowerCase('.av') then
      begin
      LoadDBFile(Dir+Sr.Name,DBFile);
      end;

    FindRes:=FindNext(SR);
  end;
  FindClose(SR);
end;

function FindDBLocation(Dir:String) : string;
Var
  SR:TSearchRec;
  FindRes:Integer;
  EX : String;
  Four: integer;
begin
  FindRes:=FindFirst(Dir+'*.*',faAnyFile,SR);
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
      //FindDataBases(Dir+SR.Name+'\');
      FindRes:=FindNext(SR);
      Continue;
      end;

    Ex := ExtractFileExt(Dir+SR.Name);

    if  LowerCase(Ex) = LowerCase('.av') then
      begin
        //LoadDBFile(Dir+Sr.Name,DBFile);
        Result := Dir+Sr.Name;
      end;

    FindRes:=FindNext(SR);
  end;
  FindClose(SR);
end;

end.
