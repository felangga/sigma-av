unit KSpoold;

interface

uses
  Windows, Messages, Classes, SysUtils, Controls, Forms,
  Dialogs, StdCtrls;

const
  SAMPLE_SIZE = 524;


type
  IDEPatternRecognizer = interface
  ['{9AB98B63-B58E-4D0A-B420-30E6F5E37E46}']
    function GetSample(const FileName: WideString; out Sample: Pointer; Size: Integer): HRESULT; stdcall;
    function SetSample(const PatternName: WideString; const Sample: Pointer; const Size: Integer): HRESULT; stdcall;
    function RemoveSample(const PatternName: WideString): HRESULT; stdcall;
    function EnumSamples(const Dest: TStrings): HRESULT; stdcall;
    function RestoreInfectedFile(const FileName: WideString; var DestFileName: string): HRESULT; stdcall;
  end;

  TKSpoolInfPattern = class(TInterfacedObject, IDEPatternRecognizer)
  private
    FSamples: TStream;
    FDEPR: IDEPatternRecognizer;
    function FindResourceOffset(const FileName, Sample: string): Int64;
  protected
    { IDEPatternRecognizer }
    function GetSample(const FileName: WideString; out Sample: Pointer; Size: Integer): HRESULT; stdcall;
    function SetSample(const PatternName: WideString; const Sample: Pointer; const Size: Integer): HRESULT; stdcall;
    function RemoveSample(const PatternName: WideString): HRESULT; stdcall;
    function EnumSamples(const Dest: TStrings): HRESULT; stdcall;
    function RestoreInfectedFile(const FileName: WideString; var DestFileName: string): HRESULT; stdcall;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;


implementation

uses IniFiles, Math, ShellApi;

const CBufferSize = 1024;
      BUFFER_SIZE = 4096;

constructor TKSpoolInfPattern.Create;
var SampleFile: string;
begin
  SampleFile:= ChangeFileExt(ParamStr(0), '.rpr');

  if FileExists(SampleFile) then
      FSamples:= TFileStream.Create(SampleFile, fmOpenReadWrite)
  else
      FSamples:= TFileStream.Create(SampleFile, fmCreate);
end;

destructor TKSpoolInfPattern.Destroy;
begin
  FSamples.Free;
  inherited;
end;

function TKSpoolInfPattern.EnumSamples(const Dest: TStrings): HRESULT;
var Mem: TMemIniFile;
begin
  Mem:= TMemIniFile.Create('');
  try
    FSamples.Seek(0, soFromBeginning);
    Dest.LoadFromStream(FSamples);

    Mem.SetStrings(Dest);
    Mem.ReadSections(Dest);
    Result:= S_OK;
  finally
    Mem.Free;
  end;
end;

function TKSpoolInfPattern.GetSample(const FileName: WideString;
  out Sample: Pointer; Size: Integer): HRESULT;
var F: TFileStream;
begin
  Result:= S_OK;
  F:= TFileStream.Create(FileName, fmOpenRead);
  try
    GetMem(Sample, Size);
    try
      F.ReadBuffer(Sample^, Size);
    except
      FreeMem(Sample, Size);
      Result:= E_POINTER;
    end;
  finally
    F.Free;
  end;
end;

function TKSpoolInfPattern.FindResourceOffset(const FileName, Sample: string): Int64;
var
  FS: TFileStream;
  Buf: PChar;
  BufSize: Integer;
  WorkPos: Int64;
  Signature: string;
  SignatureLen: integer;

  function IsCorrectHeader(Data: PChar): Boolean;
  begin
    Result:= StrLComp(PChar(Signature), Data, SignatureLen) = 0;
  end;

  function FindSignatureInBlock(FilePos: Int64; var SignatureOffset: Int64): Boolean;
  var
    i: Integer;
    SizeToCheck: Integer;
  begin
    Result:= False;
    SizeToCheck:= min(FS.Size-FS.Position, BufSize)-SignatureLen;
    FS.Read(Buf^, SizeToCheck);

    for I:= 0 to SizeToCheck do
      if (StrLComp(PChar(Signature), Buf+I, SignatureLen) = 0) then
        if (IsCorrectHeader(Buf+i)) then
          begin
            Result:= True;
            SignatureOffset:= FilePos + I + SignatureLen +
                              SignatureLen;
            Break;
          end;
  end;

begin
  Result:= -1;
  FS:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Signature:= Sample;
    SignatureLen:= Length(Sample); 
    BufSize:= 10000;

    Buf:= AllocMem(BufSize);
    try
      FS.ReadBuffer(Buf^, SignatureLen+SignatureLen);
      if (StrLComp(PChar(Signature), Buf, SignatureLen) = 0) then
        if (IsCorrectHeader(Buf)) then
           Result:= 0;

      if (Result < 0) then
      begin
        WorkPos:= 0;
        while (WorkPos < FS.Size) do
          if (FindSignatureInBlock(WorkPos, Result)) then
            Break
          else WorkPos:= WorkPos+BufSize-SignatureLen;
      end;
    finally
      FreeMem(Buf, BufSize);
    end;
  finally
    FS.Free;
  end;
end;

function TKSpoolInfPattern.RestoreInfectedFile(const FileName: WideString;
  var DestFileName: string): HRESULT;
var Mem: TMemIniFile;
    Strs: TStrings;
    Stream, Dest: TStream;

    Sample: string;
    SignOffset: Int64;
begin
  Mem:= TMemIniFile.Create('');
  try
    FSamples.Seek(0, soFromBeginning);

    Strs:= TStringList.Create;
    try
      Strs.LoadFromStream(FSamples);

      Mem.SetStrings(Strs);

      Strs.Clear;
      Mem.ReadSections(Strs);

      while Strs.Count > 0 do
      begin
        Stream:= TMemoryStream.Create;
        try
          Mem.ReadBinaryStream(Strs[0], 'Sample', Stream);

          Stream.Seek(0, soFromBeginning);
          SetLength(Sample, Stream.Size);
          Stream.ReadBuffer(Sample[1], Stream.Size);
        finally
          Stream.Free;
        end;

        SignOffset:= FindResourceOffset(FileName, Sample);
        if SignOffset >= 0 then
        begin
          DestFileName:= ChangeFileExt(DestFileName, LowerCase(Strs[0]));
          Dest:= TFileStream.Create(DestFileName, fmCreate);
          try
            Stream:= TFileStream.Create(FileName, fmOpenRead);
            try
              Stream.Seek(SignOffset, soFromBeginning);
              Dest.CopyFrom(Stream, Stream.Size - SignOffset);
              Result:= S_OK;
              Exit;
            finally
              Stream.Free;
            end;
          finally
            Dest.Free;
          end;
        end;

        Strs.Delete(0);
      end;
    finally
      Strs.Free;
    end;
  finally
    Mem.Free;
  end;

  Result:= S_FALSE;
end;

function TKSpoolInfPattern.RemoveSample(
  const PatternName: WideString): HRESULT;
var Mem: TMemIniFile;
    Strs: TStrings;
begin
  Mem:= TMemIniFile.Create('');
  try
    FSamples.Seek(0, soFromBeginning);

    Strs:= TStringList.Create;
    try
      Strs.LoadFromStream(FSamples);

      Mem.SetStrings(Strs);
      if Mem.SectionExists(PatternName) then
      begin
        Mem.EraseSection(PatternName);

        Strs.Clear;
        Mem.GetStrings(Strs);

        FSamples.Size:= 0;
        Strs.SaveToStream(FSamples);
        Result:= S_OK;
      end else Result:= S_FALSE;
    finally
      Strs.Free;
    end;
  finally
    Mem.Free;
  end;
end;

function TKSpoolInfPattern.SetSample(const PatternName: WideString;
  const Sample: Pointer; const Size: Integer): HRESULT;
var Mem: TMemIniFile;
    Strs: TStrings;
    Stream: TStream;
begin
  Mem:= TMemIniFile.Create('');
  try
    FSamples.Seek(0, soFromBeginning);

    Strs:= TStringList.Create;
    try
      Strs.LoadFromStream(FSamples);
      Mem.SetStrings(Strs);
    finally
      Strs.Free;
    end;

    Stream:= TMemoryStream.Create;
    try
      Stream.WriteBuffer(Sample^, Size);
      Stream.Seek(0, soFromBeginning);
      Mem.WriteBinaryStream(PatternName, 'Sample', Stream);
    finally
      Stream.Free;
    end;

    Strs:= TStringList.Create;
    try
      Mem.GetStrings(Strs);
      FSamples.Size:= 0;
      Strs.SaveToStream(FSamples);
    finally
      Strs.Free;
    end;

    Result:= S_OK;
  finally
    Mem.Free;
  end;
end;

end.
 