unit MainUnit;

interface

{ KSpoold Disinfector 1.0 - Freeware
  Copyright © Indra Gunawan, 2ind@mail.com
  www.delphiexpert.wordpress.com

  LICENSE
  ---------------------------------------------------------------------------
  Use and distribution of the library is permitted provided that all of
  the following terms are accepted:

  The software is provided "as-is," without any express or implied warranty.
  In no event shall the Author be held liable for any damages arising from
  the use of the Software.

  All redistributions of the library files must be in their original,
  unmodified form. Distributions of modified versions of the files is
  permitted with express written permission of the Indra.
  All redistributions of the library files must retain all
  copyright notices and web site addresses that are currently in place,
  and must include this list of conditions without modification.

  None of the library may be redistributed for profit or as part of
  another software package without express written permission of the Indra.
  Redistribution of any of the component files in object form
  (including but not limited to .PAS, .DCU and .OBJ formats)
  is strictly prohibited without express written permission of the Indra.
  ---------------------------------------------------------------------------
}

uses
  Windows, Messages, Classes, SysUtils, Controls, Forms,
  Dialogs, StdCtrls;

const
  SAMPLE_SIZE = 524;
  
  { Microsoft Word & Excel using the same file header at the first 512,
    so we get unique header at the first 12 byte after 512 offset
    512 + 12 = 524 --> it's my lucky number :D

    You can download sample of infected file by KSpoold here:
    http://delphi-id.org/dpr/Downloads-index-req-viewdownloaddetails-lid-180.pas
  }

type
  IDEPatternRecognizer = interface
  ['{9AB98B63-B58E-4D0A-B420-30E6F5E37E46}']
    function GetSample(const FileName: WideString; out Sample: Pointer; Size: Integer): HRESULT; stdcall;
    function SetSample(const PatternName: WideString; const Sample: Pointer; const Size: Integer): HRESULT; stdcall;
    function RemoveSample(const PatternName: WideString): HRESULT; stdcall;
    function EnumSamples(const Dest: TStrings): HRESULT; stdcall;
    function RestoreInfectedFile(const FileName: WideString; var DestFileName: string): HRESULT; stdcall;
  end;

  TMainForm = class(TForm)
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    FDEPR: IDEPatternRecognizer;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TKSpoolInfPattern = class(TInterfacedObject, IDEPatternRecognizer)
  private
    FSamples: TStream;
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

var
  MainForm: TMainForm;

implementation

uses IniFiles, Math, ShellApi;

{$R *.dfm}

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  FDEPR:= TKSpoolInfPattern.Create;
  FDEPR.EnumSamples(ListBox1.Items);
end;

destructor TMainForm.Destroy;
begin
  FDEPR:= nil;
  inherited;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var Dlg: TOpenDialog;
    Buf: Pointer;
    PattName: string;
begin
  Dlg:= TOpenDialog.Create(nil);
  try
    Dlg.Filter:= 'Microsoft Office Files (*.doc; *.xls)|*.doc;*.xls';
    if Dlg.Execute then
      if FDEPR.GetSample(Dlg.FileName, Buf, SAMPLE_SIZE) = S_OK then
      begin
        PattName:= UpperCase(ExtractFileExt(Dlg.FileName));
        FDEPR.SetSample(PattName, Buf, SAMPLE_SIZE);
        FreeMem(Buf);

        ListBox1.Items.Add(PattName);
      end;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  if MessageBox(Handle, 'Are you sure?', 'Confirm', MB_ICONWARNING or MB_YESNO) = mrYes then
  begin
    if FDEPR.RemoveSample(ListBox1.Items[ListBox1.ItemIndex]) = S_OK then
    begin
      ListBox1.DeleteSelected;
      ListBox1.OnClick(nil);
    end else MessageBox(Handle, 'Unable delete sample!', 'Failed', MB_ICONWARNING or MB_OK);
  end;
end;

procedure TMainForm.ListBox1Click(Sender: TObject);
begin
  Button2.Enabled:= ListBox1.ItemIndex >= 0;
end;

procedure TMainForm.Button3Click(Sender: TObject);
var Dlg: TOpenDialog;
    Dest: string;
begin
  Dlg:= TOpenDialog.Create(nil);
  try
    Dlg.Filter:= 'Infected File (*.exe)|*.exe';
    if Dlg.Execute then
    begin
      Dest:= ChangeFileExt(Dlg.FileName, '.clean.unk');
      if FDEPR.RestoreInfectedFile(Dlg.FileName, Dest) = S_OK then
      begin
        if MessageBox(Handle, 'Succesully disinfecting the file. Open the file now?', 'Success', MB_ICONINFORMATION or MB_YESNO) = mrYes then
          ShellExecute(0, 'open', PAnsiChar(Dest), '', '', SW_SHOW);
      end else MessageBox(Handle, 'Unable disinfecting file!', 'Failed', MB_ICONWARNING or MB_OK);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.Button4Click(Sender: TObject);
begin
  MessageBox(Handle, 'KSpoold Disinfector 1.0 - Freeware'#13#10#13#10'Copyright © Indra Gunawan, 2ind@mail.com'#13#10'www.delphiexpert.wordpress.com',
  'About Disinfecter', MB_ICONINFORMATION or MB_OK);
end;

{ TKSpoolRestore }

const CBufferSize = 1024;
      BUFFER_SIZE = 4096;

constructor TKSpoolInfPattern.Create;
var SampleFile: string;
begin
  SampleFile:= ChangeFileExt(ParamStr(0), '.samples.bin');

  if FileExists(SampleFile) then
    FSamples:= TFileStream.Create(SampleFile, fmOpenReadWrite)
  else FSamples:= TFileStream.Create(SampleFile, fmCreate);
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
