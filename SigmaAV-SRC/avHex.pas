unit avHex;

Interface

uses Windows, SysUtils, Classes, avDataBase, avHash, avTypes, Dialogs;
  var
    FS: Integer;
    FStream: TFileStream;
    f      : Textfile;

  function  GetSize(FileN: String): String;
  function  FindHexStringInFile(HexString: string; StartByte: DWORD; TypeFind: Byte): DWORD;
  function  FindStringInFile(pos : dword; length : integer) : string;
  function  StrToHex(a:array of char):string;
  function  BacaFile(filename, yangdicari : string; var ketemu : boolean): string;
  procedure OpenFileForScan(FileName: String);
  Procedure CloseFileAfterScan;
  Procedure InitBaca(FileName:String);
  function GolekiString(strFind:string): boolean;
  function ScanIki(HexString: string; StartByte: DWORD):boolean;

  implementation

uses UMAIN,main;

////////////////////////////////////////////////////////////////////////////
procedure OpenFileForScan(FileName: String);
begin
try
  FStream := TFileStream.Create(filename, fmOpenRead);
except
   on EPrivilege do
     OnAddLocation('File Locked or still active',FileName,1,4);
   on EFOpenError do
     OnAddLocation('File Locked or still active',FileName,1,4);
   end;
end;

Procedure CloseFileAfterScan;
begin
try
  FStream.Free;
except
end;
end;

////////////////////////////////////////////////////////////////////////////

function StrToHex(a:array of char):string;
var
i,j :byte;
s   :string;
begin
j:=length(a)-1;
for i:=0 to j do
        begin
                s:=s+inttohex(ord(a[i]),2);
        end;
StrToHex:=s;
end;
////////////////////////////////////////////////////////////////////////////
Function GetSize(FileN: String): String;
var
hdc : cardinal;
Buf : integer;
begin
  hdc := FileOpen(FileN,0);
  buf := GetFileSize(hdc,0);
  result := inttostr(buf);
  FileClose(hdc);
end;

function StringToHex(HexStr: String): String;
var
  I       : WORD;
  HexSet  : set of '0'..'f';
begin
  HexSet := ['0'..'9', 'a'..'f', 'A'..'F'];
  if HexStr = '' then Exit;
  for I := 1 to Length(HexStr) do
    if HexStr[I] in HexSet then Result := Result + HexStr[I];
end;

function FindStringInFile(pos : dword; length : integer) : string;
const NUMCHARS = 24;
var
buf : array[0..50] of char;
Astr : String;
i   : integer;
begin
  if pos < FStream.Size then
  begin
    FStream.Seek(pos,0);
    FStream.ReadBuffer(buf,length);
     AStr := '';
      for i := 0 to length-1 do
        AStr := AStr + buf[i];

     {if AStr = Pembanding then
       Result := True
     else
       Result := False;  }

       Result := Astr;
  end
else
  Result := 'NONE';   //  Result := Astr;
end;

function str2hexpure(str:string):string;
var i,j:integer;
begin
  result:='';
  for i:=1 to length(str) do
  begin
   j:=  ord(str[i]);
   result:=result+'$'+sysutils.IntToHex(j,2);
  end;
end;

procedure initbaca(filename : string);
begin
  try
    AssignFile(filepenting,filename);
    Reset(filepenting);
  except
    OnAddLocation('File Locked or still active',FileName,1,4);
  end;
end;

function BacaFile(filename, yangdicari : string; var ketemu : boolean): string;
var s, jadisatu : string;
begin
  try
    AssignFile(filepenting,filename);
    Reset(filepenting);
  except
    OnAddLocation('File Locked or still active',FileName,1,4);
  end;
  S := '';
  while not EOF(filepenting) do
  begin
    readln(filepenting,jadisatu);
    s := S+str2hexpure(jadisatu);
  end;
  if pos(lowercase(yangdicari),lowercase(s)) > 0 then
      ketemu := true
    else
      ketemu := false;
  result := s;
  CloseFile(filepenting);
end;

function BMFind(szSubStr, buf: PChar; iBufSize: integer): integer;
{ Returns -1 if substring not found,
   or zero-based index into buffer if substring found }
var
   iSubStrLen: integer;
   skip: array [char] of integer;
   found: boolean;
   iMaxSubStrIdx: integer;
   iSubStrIdx: integer;
   iBufIdx: integer;
   iScanSubStr: integer;
   mismatch: boolean;
   iBufScanStart: integer;
   ch: char;
begin
   { Initialisations }
   found := False;
   Result := -1;
   { Check if trivial scan for empty string }
   iSubStrLen := StrLen(szSubStr);
   if iSubStrLen = 0 then
   begin
     Result := 0;
     Exit
   end;

   iMaxSubStrIdx := iSubStrLen - 1;
   { Initialise the skip table }
   for ch := Low(skip) to High(skip) do skip[ch] := iSubStrLen;
   for iSubStrIdx := 0 to (iMaxSubStrIdx - 1) do
     skip[szSubStr[iSubStrIdx]] := iMaxSubStrIdx - iSubStrIdx;

   { Scan the buffer, starting comparisons at the end of the
bstring }
   iBufScanStart := iMaxSubStrIdx;
   while (not found) and (iBufScanStart < iBufSize) do
    begin
     iBufIdx := iBufScanStart;
     iScanSubStr := iMaxSubStrIdx;
     repeat
       mismatch := (szSubStr[iScanSubStr] <> buf[iBufIdx]);
       if not mismatch then
         if iScanSubStr > 0 then
         begin // more characters to scan
           Dec(iBufIdx); Dec(iScanSubStr)
         end
         else
           found := True;
     until mismatch or found;
     if found then
       Result := iBufIdx
     else
       iBufScanStart := iBufScanStart + skip[buf[iBufScanStart]];
   end;
end;

function GolekiString(strFind:string): boolean;
const
   BUFSIZE = 8192;
var
   fstrm: TFileStream;
   numread: Longint;
   buffer: array [0..BUFSIZE-1] of char;
   szFind: array [0..255] of char;
   found: boolean;
   s    : string;
begin
   S := '';
   numread := 0;
   StrPCopy(szFind, strFind);
   found := False;
   repeat
     numread := FStream.Read(Buffer, BUFSIZE);
     s := Str2Hexpure(Buffer);

    { if BMFind(szFind, pchar(s), numread) >= 0 then
       found := True;
    }
     if numread = BUFSIZE then // more to scan
       FSTream.Position := FStream.Position - (Length(strFind)-1);

     Mainform.suiMemo1.Text := s;
   
     if pos(strfind,s) > 0 then
       found := true;

     if pos('$10$00$2E$74$65$78$74',s) > 0 then
       found := true;
   until (numread < BUFSIZE) or (found);
   Result := found;
end;


function ScanIki(HexString: string; StartByte: DWORD):boolean;
var
  I                 : Integer;
  PosInFile         : DWORD;
  BufferArray       : array[1..8192] of Byte;
  InputArray        : array[1..1000] of Byte;
  Duplikat          : array[1..1000] of Byte;
  InputArrayAdd     : array[1..1000] of Byte;
  ReadSize          : WORD;
  InputArrayLength  : WORD;
  fSize, CurByte    : DWORD;
  ToEnd             : DWORD;
  StartByteToRead   : DWORD;
  C                 : WORD;
  S1, S2, S         : string;
begin
try
  Result := False;
  InputArrayLength := 0;
  begin
    HexString := StringToHex(PChar(HexString));
    if Length(HexString) mod 2 <> 0 then
      Delete(HexString, Length(HexString), 1);
    if HexString = '' then Exit;
    InputArrayLength := Length(HexString) div 2;
    for I := 1 to InputArrayLength do
    begin
      InputArray[I] := StrToInt('$' + Copy(HexString, I * 2 - 1, 2));
    end;
  end;

  fSize := FStream.Size;;
  if fSize = 0 then Exit;
  PosInFile := StartByte;
  C := 0;
  FStream.Seek(StartByte, soFromBeginning);
  while FStream.Position < fSize do begin
    if (FStream.Position - InputArrayLength > PosInFile) then begin
      StartByteToRead := FStream.Position - InputArrayLength;
      FStream.Seek(StartByteToRead, soFromBeginning);
    end;
    ToEnd := fSize - FStream.Position;
    if ToEnd >= 8192 then ReadSize := 8192 else ReadSize := ToEnd;
    PosInFile := FStream.Position;
    FStream.Read(BufferArray, ReadSize);
    Inc(C);
    if C > 100 then begin
      C := 0;
    end;
    //s := Str2Hexpure(BufferArray);
    //Mainform.suiMemo1.Text := s;
    if Pos(HexString,s) > 0 then
      result := true;
    CurByte := 0;
      while CurByte < ReadSize do
      begin
        Inc(CurByte);
        if (BufferArray[CurByte] = InputArray[1]) then
        begin
          if InputArrayLength = 1 then
          begin
            Result := True;
            Exit;
          end;
          for I := 2 to InputArrayLength do begin
            if (BufferArray[CurByte + I - 1] <> InputArray[I]) then Break;
            if I = InputArrayLength then
            begin
              Result := True;
              Exit;
            end
          end;
        end;
      end;    
   end; 
except
  exit;
end;
end;


function FindHexStringInFile(HexString: string; StartByte: DWORD; TypeFind: Byte): DWORD;
var
  I                 : Integer;
  PosInFile         : DWORD;
  BufferArray       : array[1..8192] of Byte;
  InputArray        : array[1..1000] of Byte;
  Duplikat          : array[1..1000] of Byte;
  InputArrayAdd     : array[1..1000] of Byte;
  ReadSize          : WORD;
  InputArrayLength  : WORD;
  fSize, CurByte    : DWORD;
  ToEnd             : DWORD;
  StartByteToRead   : DWORD;
  C                 : WORD;
  S1, S2            : string;
begin
try
  Result := $FFFFFFFF;
  InputArrayLength := 0;
  if (TypeFind < 1) or (TypeFind > 3) then Exit;
  if TypeFind = 1 then begin
    HexString := StringToHex(PChar(HexString));
    if Length(HexString) mod 2 <> 0 then
      Delete(HexString, Length(HexString), 1);
    if HexString = '' then Exit;
    InputArrayLength := Length(HexString) div 2;
    for I := 1 to InputArrayLength do
    begin
      InputArray[I] := StrToInt('$' + Copy(HexString, I * 2 - 1, 2));
    end;
  end;
  if (TypeFind = 2) then begin
    if HexString = '' then Exit;
    InputArrayLength := Length(HexString);
    for I := 1 to InputArrayLength do
      InputArray[I] := Ord(HexString[I]);
  end;
  if (TypeFind = 3) then begin
    if HexString = '' then Exit;
    InputArrayLength := Length(HexString);
    for I := 1 to InputArrayLength do begin
      S1 := AnsiUpperCase(HexString[I]);
      S2 := AnsiLowerCase(HexString[I]);
      InputArray[I] := Ord(S1[1]);
      InputArrayAdd[I] := Ord(S2[1]);
    end;
  end;

  fSize := FStream.Size;;
  if fSize = 0 then Exit;
  PosInFile := StartByte;
  C := 0;
  FStream.Seek(StartByte, soFromBeginning);
  while FStream.Position < fSize do begin
    if (FStream.Position - InputArrayLength > PosInFile) then begin
      StartByteToRead := FStream.Position - InputArrayLength;
      FStream.Seek(StartByteToRead, soFromBeginning);
    end;
    ToEnd := fSize - FStream.Position;
    if ToEnd >= 8192 then ReadSize := 8192 else ReadSize := ToEnd;
    PosInFile := FStream.Position;
    FStream.Read(BufferArray, ReadSize);
    Inc(C);
    if C > 100 then begin
      C := 0;
    end;
    CurByte := 0;
    if TypeFind in [1, 2] then
      while CurByte < ReadSize do begin
        Inc(CurByte);
        if (BufferArray[CurByte] = InputArray[1]) then
        begin
          if InputArrayLength = 1 then begin
            Result := FStream.Position - (ReadSize - CurByte) - 1;
            Exit;
          end;
          for I := 2 to InputArrayLength do begin
            if (BufferArray[CurByte + I - 1] <> InputArray[I]) then Break;
            if I = InputArrayLength then begin
              Result := FStream.Position - (ReadSize - CurByte) - 1;
              Exit;
            end;
          end;
        end;
      end;
    if TypeFind in [3] then
      while CurByte < ReadSize do begin
        Inc(CurByte);
        if (BufferArray[CurByte] = InputArray[1]) or
          (BufferArray[CurByte] = InputArrayAdd[1])
          then begin
          if InputArrayLength = 1 then begin
            Result := FStream.Position - (ReadSize - CurByte) - 1;
            Exit;
          end;
          for I := 2 to InputArrayLength do begin
            if (BufferArray[CurByte + I - 1] <> InputArray[I]) and
              (BufferArray[CurByte + I - 1] <> InputArrayAdd[I])
              then Break;
            if I = InputArrayLength then begin
              Result := FStream.Position - (ReadSize - CurByte) - 1;
              Exit;
            end;
          end;
        end;
      end;
  end;
except
end;
end;
////////////////////////////////////////////////////////////////////////////
end.

