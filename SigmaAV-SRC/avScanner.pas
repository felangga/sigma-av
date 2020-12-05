unit avScanner;

Interface

uses Windows, SysUtils, Classes, avHex, avDatabase, avTypes, avHash, avExt, QGraphics, avApi, CRC32,
     heurico, shellApi, Dialogs, ActiveX,ShlObj, ComObj, CommCtrl, FileCtrl, Proses;


Const
  // listview and item messages
  LVM_FIRST                        = $1000;
  LVM_GETITEMCOUNT                 = LVM_FIRST+ 4;
  LVM_GETITEM                      = LVM_FIRST+ 5;

  // item constants
  LVIF_TEXT                        = $0001;
  LVIF_STATE                       = $0008;

  // item states
  LVIS_FOCUSED                     = $0001;
  LVIS_SELECTED                    = $0002;

Type
  // item struct (i know nowadays this slightly differs, but this seems to work also)
  TLV_ITEM= Record
    mask        : Cardinal;
    iItem       : Integer;
    iSubItem    : Integer;
    state       : Cardinal;
    stateMask   : Cardinal;
    pszText     : Pointer;
    cchTextMax  : Integer;
    iImage      : Integer;
    _lParam     : LPARAM;
  End;

  // a custom extension to meet our needs :)
  PDatas= ^TDatas;
  TDatas= Record
    LV_ITEM  : TLV_ITEM;
    LV_TEXTE : Array[0..255] Of Char;
  End;

  // dynamic function use, so this also runs under win9X
  TVirtualAllocEx= Function(hProcess: THandle; lpAddress: Pointer; dwSize, flAllocationType: DWORD; flProtect: DWORD): Pointer; stdcall;
  TVirtualFreeEx= Function(hProcess: THandle; lpAddress: Pointer; dwSize, dwFreeType: DWORD): Pointer; stdcall;

Const
  TailleMap= SizeOf(TDatas);

var
  Wait      : Boolean = False;
  Security  : Integer;
  CRC32S, HEXS, MD5S : Boolean;
  heuristic : Boolean;
  RTPResult : string;
  IsRTP     : Boolean;

  procedure selectscan(crc, hex, md5 : boolean);
  procedure setheur(active : boolean);
  procedure setsecurity(grade : integer);
  function ScanFile(FileName: String): string;
  function ScanDir(Dir:String) : Boolean;
  function ScanFileBiasa(FileName: String): String;
  Function RTPScan(Dir:String) : string;
  function IsUnicode(data : string;tipe : integer) : boolean;
  procedure scanmemory;
  Function rekursidir(Dir:String) : boolean;


var GlobalScan : Boolean;
    Allowmemscan : boolean;
    uwez : boolean;
    Balikin : String;
    etung   : integer;

implementation

uses Umain,avkernel;

function IsUnicode(data : string;tipe : integer) : boolean;
// catatan : tipe 1 merupakan file unicode, tipe 2 merupakan keyboard default mapping.
var hasil : char;
    panjang : integer;
    gabungan : string;
begin
  Result := false;
  panjang := 1;
  gabungan := '';
  while panjang <> length(data)+1 do
  begin
    hasil := data[panjang];
    if tipe = 1 then
    begin
      if ((Hasil in['a'..'z']) or (Hasil in['A'..'Z']) or (Hasil in['0'..'9']) or (Hasil in['''','<','>','!','@','#','%','^','&','(',')','{','}','[',']',',','.','~','`',' ','-','_','+','='])) then
        result := false
      else
        result := true;
    end
  else
    if tipe = 2 then
    begin
      if ((Hasil in['a'..'z']) or (Hasil in['A'..'Z']) or (Hasil in['0'..'9']) or (Hasil in['''','!','@','#','%','^','&','(',')','{','}','[',']',',','.','~','`',' ','-','_','+','\','/',':','*','?','"','<','>','|','='])) then
        result := false
      else
        result := true;
    end;
    if result = true then exit;
    inc(panjang);
  end;
end;


function daptdir(input : string) : string;
var drive : integer;
begin
  drive := Pos (':\',input);
  if (Copy(input,drive-4,drive-3) <> '') then
    Result := Copy(input,drive-1,length(input))
  else
    Result := input;
end;


Procedure ScanMemory;
var i : integer;
begin
  i := 0;
  if allowmemscan then begin
  mainform.Button1.Click;
  OnAddLocation('Scanning memory...','',0,4);
  memory := true;
  with mainform.ListBox1.Items do
  begin
    for i := 5 to Mainform.ListBox1.Items.Count-1 do
    if (strings[i] <> ' ') and (Pos('\',Strings[i]) <> 0) and (Strings[i] <> '') and (Pos(':',strings[i]) <> 0) and (Pos('Sigma',strings[i]) = 0) then
    begin
      MainForm.FileCN := MainForm.FileCN + 1;
      Mainform.txtFileScan.Caption := 'Total : '+IntToStr(Mainform.FileCN)+' files';
      ScanFile(Daptdir(MainForm.Listbox1.Items.Strings[i]));
    end;
  end;
  i := 0;
  OnAddLocation('Scanning memory completed...','',0,4);
  for i := 0 to Mainform.suspend.Items.Count-1 do
  begin
    KillTask(MainForm.suspend.Items.Strings [i]);
  end;
  OnAddLocation('','',-1,4);
  memory := false;
  Mainform.trayicon.ShowMainForm;
  end;
end;

Procedure WaitForPlugin;
begin
While Wait = True do begin
  Sleep(100);
end;
end;

procedure setheur(active : boolean);
begin
  heuristic := active;
end;

Procedure SetSecurity(Grade : Integer);
begin
  Security := Grade;
  if Grade = 3 then
  begin
    CRC32S := True;
    HEXS := True;
    MD5S := True;
    Security := 3;
  end
else
  begin
    MD5S := False;
    Security := 2;
  end
end;

Procedure selectscan(crc, hex, md5 : boolean);
begin
  CRC32S := Crc;
  HEXS := Hex;
  MD5S := Md5;
end;

procedure oke(filename,namavirus : string);
begin
  OnWarningHeurProc(FileName,NamaVirus);
  uwez := true;
  exit;
end;

function GET_FILE_SIZE(sFileToExamine:string;bInKBytes:boolean):string;
{for some reason both methods of finding file size return
 a filesize that is slightly larger than what Windows File
 Explorer reports}
var
  FileHandle : THandle;
  FileSize   : LongWord;
  d1         : double;
begin
//a- Get file size
FileHandle := CreateFile(
  PCHAR(sFileToExamine),
  GENERIC_READ,
  0, {exclusive}
  nil, {security}
  OPEN_EXISTING,
  FILE_ATTRIBUTE_NORMAL,
  0);
FileSize := GetFileSize(FileHandle,nil);
result := INTTOSTR(FileSize);
CloseHandle(FileHandle);
//a- optionally report back in Kbytes
if bInKbytes = true then
  begin
  if length(result)> 3 then
    begin
    Insert('.',result,length(result)-2);
    d1 := strtofloat(result);
    result := inttostr(round(d1))+'KB';
    end
   else
    result := '1KB';
  end;
end;



function getexetype(Filename:string):string;
var
  BinaryType: DWORD;
begin
  If GetBinaryType(Pchar(Filename), Binarytype) Then
    case BinaryType of
      SCS_32BIT_BINARY: Result:= 'Win32';
      SCS_DOS_BINARY  : Result:= 'DOS';
      SCS_WOW_BINARY  : Result:= 'Win16';
      SCS_PIF_BINARY  : Result:= 'PIF';
      SCS_POSIX_BINARY: Result:= 'POSIX';
      SCS_OS216_BINARY: Result:= 'OS/2'
    else
      Result:= 'unknown'
    end
else
  Result:= 'not';
end;

function StringtoHex(Stringa: string): string;
var
  Lunghezza:   Integer;
  Conversione: string;
begin
  Conversione := '$';
  for Lunghezza := 1 to Length(Stringa) do
  begin
    Conversione := Conversione + IntToHex(Ord(Stringa[Lunghezza]), 2)+'$';
  end;
  Result := Copy(Conversione,0,Length(Conversione)-1);
end;


function StrToByte(const S: string): Byte;
var
  E: Integer;
begin
  Val(S, Result, E);
  //if E <> 0 then ConvertErrorFmt(@SInvalidInteger, [S]);
end;

function binarifile(file_name:string) : boolean;
var
  F: file;
  NumRead,len: Integer;
  Buf: array[0..1000] of Byte;
  i:integer;
  result_:boolean;
begin
  AssignFile(F, file_name);
  Reset(F, 1); { Record size = 1 }
  if (filesize(F)<1000) then
    len:=filesize(F)
  else
    len:=1000;
  BlockRead(F, Buf, len, NumRead);
  CloseFile(F);
  result_:=false;
  for i:=0 to len-10 do
    if (buf[i]=0) then
      result_:=true;
  result:=result_;
end;

function ScanFile(FileName: String) : string;
const NUMCHARS = 12;
      br = #13#10;
var
    i,p,r,r2   : integer;
    HASH    : String;
    HASHNS  : String; // MD5 tanpa size file
    CRC32,ICO   : String;
    SIGN    : String;
    Size    : String;
    WezKetemu,ktmu : boolean;
    handle  : THandle;
    ApiPlug : PApiPlugin;
    Result2  : integer;
    aStr    : String;
    Fl       : File Of Byte;
    testhnd,numberoficon : integer;
    CRCVal  : Cardinal;
    Total   : Int64;
    ErrorCRC: Word;
    jumlah : integer;
    isi,shrtct     : string;
    heururut : integer;
    signature: DWORD;
    acak : integer;
    dos_header: IMAGE_DOS_HEADER;
    pe_header: IMAGE_FILE_HEADER;
    opt_header: IMAGE_OPTIONAL_HEADER;
    s: string;
    namavirus: string;
    asl : TstringList;
    backup : string;
    dirubah : boolean;
    sebelum,test : string;
    icon : Cardinal;
    ikibinari,ketemu,westaudiskip : boolean;
begin
  //Plugins
   WezKetemu := True;
  try
    Result2 := MES_NONE;

  For p := 0 to ApiPlugins.Count-1 do begin
  ApiPlug := ApiPlugins.items[i];
  if (ApiPlug.ApiPlugType = API_SCAN) or (ApiPlug.ApiPlugType = API_SCANFILE) then begin
    Result2 := ApiPlug.ApiPlugScanFile(PChar(FileName));
    if result2 <> MES_NONE then begin
        case result2 of
          MES_SCANDIR    : ScanDir(ApiPlug.ApiPlugGetScanDir);
          MES_SCANFILE   : ScanFile(ApiPlug.ApiPlugGetScanFile);
          MES_PLUGINWAIT : WaitForPlugin; // Until wait   //
          MES_PLUGINEXIT : WaitForPlugin; // Wait and exit//
        end;
      end;
  end;
end;
  if Result2 = MES_PLUGINEXIT then Exit;
except
end;
  i:=0;
  r:=0;
  //OpenFileForScan(FileName);
  if (StrToByte(Get_File_Size(FileName, False)) > MaxSize) or (StrToByte(Get_File_size(FileName,False)) < MinSize) then
    Exit;

  Dirubah := False;

  acak := Random(1709);

  Sebelum := FileName;
  if IsUnicode(ExtractFileName(FileName),1) then
  begin
    Dirubah := True;
    if RenameWithCMD(ExtractFilePath(FileName),ExtractFileName(FileName),'susp'+IntToStr(Acak)+'.vir') = '' then
      FileName := ExtractFilePath(FileName)+'susp'+IntToStr(Acak)+'.vir'
    else
      FileName := Sebelum;
  end
else
  FileName := Sebelum;

  if (LowerCase(ExtractFileExt(FileNAme)) = '.iloveadelia') or (LowerCase(ExtractFileExt(FileName)) = '.dcracker') then
  begin
    OnVirFoundProc(filename,'Junk.Adelia',3);
    exit;
  end;

  heururut := -1;
  try
    { menggunakan CRC 32 }
    if CRC32S then
    begin
      HitungFileCRC32(FileName,CRCVAL,Total,errorCRC);
      CRC32   := IntToHex(CRCVAL,8);
    end;
    { Menggunakan MD5 }
    if MD5S then
    begin
      HASH    := MD5DigestToStr(MD5File(FileName));
      HASHNS  := HASH;
      SIZE    := GetSize(FileName);
      HASH    := HASH + ':' + SIZE;
    end;
    OpenFileForScan(FileName);

  except
    OnReadErrorProc(FileName,1);
    exit;
  end;

    if (lowercase(ExtractFileExt(FileName)) = '.lnk') then
    begin
      R := FindHexStringInFile('$74$00$68$00$75$00$6D$00$62$00$2E$00$64$00$62$00',0,1);
      R2:= FindHexStringInFile('$54$00$68$00$75$00$6D$00$62$00$73$00$2E$00$64$00$62$00$5C$00$73$00$76$00$63$00$68$00$6F$00$73$00$74$00$2E$00$76$00$62$00$73',0,1);
      if (R <> -1) or (R2 <> -1) then
      begin
        OnVirFoundProc(FileName,'Junk.VBS ',1);
        CloseFileAfterScan;
        Exit;
      end;
      CloseFileAfterScan;
      exit;
    end;


  if FASTSCAN then
    Mainform.fastscan.Enabled := true;

  if i < dBcount then begin
  While (i < DBCount) do begin
    wezketemu := false;

    if skipfile then
    begin
      westaudiskip := true;
      Skipfile := False;
      CloseFileAfterScan;
      Exit;
    end;

    if (StreamDB.DBViruses[i].SignType = 0) and (CRC32S) then
    begin
      if (LowerCase(StreamDB.DBViruses[i].Signature) = LowerCase(CRC32)) and (not scancomplete) then
       begin
         if not IsRTP then
           OnVirFoundProc(FileName,StreamDB.DBViruses[i].VirName,2)
         else
           Result := StreamDB.DBViruses[i].VirName;
         WezKetemu := True;

        if Memory then
          begin
            SuspendProcess(ExtractFileName(FileName));
            Mainform.suspend.Items.Add(ExtractFileName(FileName));
            OnAddLocation('Process Killed : ',ExtractFileName(FileName),8,2);
            CloseFileAfterScan;
            exit;
          end;
        try
          For p := 0 to ApiPlugins.Count-1 do begin
            ApiPlug := ApiPlugins.items[i];
            ApiPlug.ApiPlugSendInfected(PChar(FileName));
          end;
        except
          WezKetemu := False;
          CloseFileAfterScan;
          exit;
        end;
        CloseFileAfterScan;
        Exit;
      end;
    end;

    if (StreamDB.DBViruses[i].SignType = 1) and (Security = 3) and (MD5S) then
      if (LowerCase(StreamDB.DBViruses[i].Signature) = LowerCase(HASH)) or (LowerCase(StreamDB.DBViruses[i].Signature) = LowerCase(HASHNS))then
      begin
        if not IsRTP then
          OnVirFoundProc(FileName,StreamDB.DBViruses[i].VirName,0)
        else
          Result := StreamDB.DBViruses[i].VirName;
          Wezketemu := true;
        if Memory then
        begin
          SuspendProcess(ExtractFileName(FileName));
          Mainform.suspend.Items.Add(ExtractFileName(FileName));
          OnAddLocation('Process Killed : ',ExtractFileName(FileName),8,0);
          CloseFileAfterScan;
          exit;
        end;
        try
          For p := 0 to ApiPlugins.Count-1 do begin
            ApiPlug := ApiPlugins.items[i];
            ApiPlug.ApiPlugSendInfected(PChar(FileName));
          end;
        except
          CloseFileAfterScan;
          exit;
        end;
        WezKetemu := False;
        CloseFileAfterScan;
        exit;
      end;

    if (StreamDB.DBViruses[i].SignType = 2) and (HexS) then
    begin
      SIGN := StreamDB.DBViruses[i].Signature;
      //  R := FindHexStringInFile(SIGN,0,1);
        ketemu := ScanIki(Sign,1);
        if ketemu then
        begin
          if IsRTP then
          Result := StreamDB.DBViruses[i].VirName
        else
          OnVirFoundProc(FileName,StreamDB.DBViruses[i].VirName,1);
          WezKetemu := True;
          if Memory then
          begin
            SuspendProcess(ExtractFileName(FileName));
            Mainform.suspend.Items.Add(ExtractFileName(FileName));
            OnAddLocation('Process Killed : ',ExtractFileName(FileName),8,1);
            CloseFileAfterScan;
            exit;
          end;
          try
            For p := 0 to ApiPlugins.Count-1 do begin
              ApiPlug := ApiPlugins.items[i];
              ApiPlug.ApiPlugSendInfected(PChar(FileName));
            end;
          except
            CloseFileAfterScan;
            exit;
          end;
          CloseFileAfterScan;
          exit;
          WezKetemu := False;
        end;
     end;


    { Heuristic Scan }
    if (heuristic) and (StreamDB.DBViruses[i].SignType = 2) and (not wezketemu) then
    begin
      uwez := false;
      If (ExtractFileExt(FileName) = '.inf') then
      begin
        CLoseFileafterScan;
        try
          Mainform.RichEdit1.Lines.LoadFromFile(FileName);
        except
          exit;
        end;
        for r := 0 to Mainform.RichEdit1.Lines.Count do
        begin
          backup := Mainform.RichEdit1.Lines.Strings [r];;
          Backup := lowercase(backup);
          if pos('wscript',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.Inf[1]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('.vbs',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.Inf[2]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('.bat',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.Inf[3]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('.com',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.Inf[4]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('.scr',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.Inf[5]';
            Oke(FileName,NamaVirus);
          end
        else
          if pos('boot.exe',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.Inf[6]';
            Oke(FileName,NamaVirus);
          end
        else
          if pos('rundll32.exe',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.Inf[7]';
            Oke(FileName,NamaVirus);
          end;
      {  else
          if IsUnicode(backup,2) then
          begin
            NamaVirus := 'Suspected.Inf[Encrypted]';
            Oke(FileName,NamaVirus);
          end;  }
          if uwez then exit;
        end;
       exit
      end;

      If ExtractFileExt(FileName) = '.bat' then
      begin
        CLoseFileafterScan;
        try
          Mainform.RichEdit1.Lines.LoadFromFile(FileName);
        except
          exit;
        end;
        for r := 0 to Mainform.RichEdit1.Lines.Count do
        begin
          backup := Mainform.RichEdit1.Lines.Strings [r];;
          Backup := lowercase(backup);
          if pos('format ',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[1]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('reg ',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[2]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('%0',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[3]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('attrib ',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[4]';
            Oke(FileName,Namavirus);
          end
        else
       {   if pos('run',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[5]';
            Oke(FileName,NamaVirus);
          end
        else}
          if pos('hidden',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[6]';
            Oke(FileName,NamaVirus);
          end
        else
          if pos('disable',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[7]';
            Oke(FileName,NamaVirus);
          end
        else
          if pos('startup',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[8]';
            Oke(FileName,NamaVirus);
          end
        else
          if pos('NoFolderOptions',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[9]';
            Oke(FileName,NamaVirus);
          end
        else
          if pos('tskill ',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[10]';
            Oke(FileName,NamaVirus);
          end
        else
          if pos('HideFileExt',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.BAT[11]';
            Oke(FileName,NamaVirus);
          end;
          if uwez then exit;
        end;
       exit
      end;


      If (ExtractFileExt(FileName) = '.vbs') or (ExtractFileExt(FileName) = '.ini') then
      begin
        CLoseFileafterScan;
        try
          Mainform.RichEdit1.Lines.LoadFromFile(FileName);
        except
          exit;
        end;
        for r := 0 to Mainform.RichEdit1.Lines.Count do
        begin
          backup := Mainform.RichEdit1.Lines.Strings [r];
          //OnAddToLogStr(backup,7);
          Backup := lowercase(backup);

          if pos('scripting.filesystemobject',backup) > 0 then
          begin
            NamaVirus := 'Suspected.VBS[1]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('wscript.shell',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[2]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('wscript.scriptfullname',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[3]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('createobject',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[4]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('regsetvalue',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[5]';
            Oke(FileName,Namavirus);
          end
        else
          {if pos('copyfile',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[6]';
            Oke(FileName,Namavirus);
          end
        else   }
          if pos('exitwindowsex',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[7]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('persistmoniker=file:',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[8]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('runit',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[9]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('attachments.add',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[10]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('outlook.application',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[11]';
            Oke(FileName,Namavirus);
          end
        else
          if pos('ActiveDocument.Shapes.AddOLEObject',backup) <> 0 then
          begin
            NamaVirus := 'Suspected.VBS[12]';
            Oke(FileName,NamaVirus);
          end
        else
         if pos('ÿþo',backup) > 0 then
          begin
            NamaVirus := 'Suspected[A]';
            Oke(FileName,Namavirus);
          end;
          if uwez then exit;
        end;

        exit;
      end;
      if uwez then
        exit;
    end;


    inc(i);
  end;

  If (Heuristic) and (ExtractFileExt(FileName) = '.exe') then
    begin
      CloseFileAfterScan;
      try
        testhnd := extracticon(handle,pchar(FileName),0);
        //OnVirFoundProc(FileName,IntToStr(testhnd),3);
        if testhnd > 0 then
        begin
          Mainform.heuricon.Picture.Icon.Handle := testhnd;
          Mainform.heuricon.Picture.Icon.SaveToFile('C:\Windows\Temp\tmp.tmp');
          if FileExists('C:\Windows\Temp\tmp.tmp') then
          begin
            HitungFileCRC32('C:\Windows\Temp\tmp.tmp',ICON,Total,errorCRC);
            if (ICON = 3522178911) then
              heururut := 0
           else
            if (ICON = 1273855900) then
              heururut := 1
           else
            if (ICON = 3834829453) then
              heururut := 2
           else
            if (ICON = 3871141188) then
              heururut := 3
           else
            if (ICON = 2070081269) then
              heururut := 4
           else
            if (ICON = 2997089828) then
              heururut := 5
           else
            if (ICON = 1642214040) then
              heururut := 6
           else
            if (ICON = 3689375791) then
              heururut := 7
           else
            if (ICON = 3393933119) then
              heururut := 8
           else
            if (ICON = 8323049) then
              heururut := 9
           else
            if (ICON = 966489031) then
              heururut := 10
           else
            if (ICON = 1333677152) then
              heururut := 11
           else
            if (ICON = 1476939190) then
              heururut := 12
           else
            if (ICON = 3001174026) then
              heururut := 13
           else
            if (ICON = 380966686) then
              heururut := 14
           else
            if (ICON = 1982094540) then
              heururut := 15;

            if heururut <> -1 then
            begin
              //OnVirFoundProc(FileName,IntToStr(Icon),3);
              OnWarningHeurProc(FileName,'Worm/Suspected['+inttostr(heururut)+']');
              Exit;
            end;
            DeleteFile('C:\Windows\Temp\tmp.tmp');
            //Exit;
          end;
          Exit;
        end;
      except
        Exit;
      end;
    end;
   if not skipfile then CloseFileAfterScan;
   westaudiskip := false;
end
  else
  begin
    begin
      if FindStringInFile(438186,10) = 'zulkarnain' then
        OnVirFoundProc(FileName,'W32/Zulanick',1);
      if FindStringInFile(31830,11) = 'CommWarrior' then
        OnVirFoundProc(FileName,'Symbian.CommWarrior.C',1);
      if FindStringInFile(8837,10) = 'F+RM2I]r!x' then
        OnVirFoundProc(FileName,'W32/Kangen.B[2]',1);
      if FindStringInFile(28144,10) = 'XP8Qx@P9@?' then
        OnVirFoundProc(FileName,'W32/Kangen.B',1);
      if FindStringInFile(35006,10) = 'h>@`R\PH@M' then
        OnVirFoundProc(FileName,'W32/Kangen.C',1);
      if FindStringInFile(20396,10) = 'berharapXs' then
        OnVirFoundProc(FileName,'W32/Kangen.D',1);
      if FindStringInFile(3826,10) = 'ationPADDI' then
        OnVirFoundProc(FileName,'W32/Cih',1);
      if FindStringInFile(569,6) = 'SaTRio' then
        OnVirFoundProc(FileName,'W32/Satrio',1);
      if FindStringInFile(29923,7) = 'fection' then
        OnVirFoundProc(FileName,'W32/Vallium',1);
      if FindStringInFile(15230,7) = 'for you' then
        OnVirFoundProc(FileName,'W32/Valhala',1);
      if FindStringInFile(9828,10) = 'squito by ' then
        OnVirFoundProc(FileName,'W32/Nuhlit',1);
      if FindStringInFile(5203,10) = 'X-Y@5V<J=P' then
        OnVirFoundProc(FileName,'BAT/Batboy.A',1);
      if FindStringInFile(1120,16) = 'osa_ganteng_Proj' then
        OnVirFoundProc(FileName,'W32/Project.OSA',1);
      if FindStringInFile(11,12) = 'Rosurohearth' then
        OnVirFoundProc(FileName,'W32/Pesin',1);
      if FindStringInFile(3444,10) = 'erandum()n' then
        OnVirFoundProc(FileName,'VBS.NetLog',1);
      if FindStringInFile(54950,9) = 'ahaezedrn' then
        OnVirFoundProc(FileName,'Autorun.Conficker',1);
       if FindStringInFile(25986,9) = 'o initiali' then
        OnVirFoundProc(FileName,'W32/ICQAttack.Trojan',1);

        WezKetemu := True;
      try
        For p := 0 to ApiPlugins.Count-1 do begin
          ApiPlug := ApiPlugins.items[i];
          ApiPlug.ApiPlugSendInfected(PChar(FileName));
        end;
      except
        CloseFileAfterScan;
        exit;
      end;
    end;
  end;
  if dirubah then
  RenamewithCMD(ExtractFilePath(filename),'susp'+IntToStr(Acak)+'.vir',ExtractFileName(sebelum));

  OnProgressProc(FileName,0);
end;

function ScanFileBiasa(FileName: String) : string;
const NUMCHARS = 12;
      br = #13#10;
var
fs : TFileStream;
buf : array[0..50] of char;
i,p,r   : integer;
HASH    : String;
HASHNS  : String; // MD5 tanpa size file
CRC32   : String;
SIGN    : String;
Size    : String;
WezKetemu : boolean;
ApiPlug : PApiPlugin;
aStr    : String;
CRCVal  : Cardinal;
Total   : Int64;
ErrorCRC: Word;
jumlah : integer;
f       : TextFile;
isi     : string;
signature: DWORD;
dos_header: IMAGE_DOS_HEADER;
pe_header: IMAGE_FILE_HEADER;
opt_header: IMAGE_OPTIONAL_HEADER;
s: string;
acak: integer;
Sebelum : String;
Dirubah,ketemu : Boolean;
begin
//Plugins
  WezKetemu := false;
  Result := 'NONE';
{  try
Result2 := MES_NONE;

For p := 0 to ApiPlugins.Count-1 do begin
  ApiPlug := ApiPlugins.items[i];
  if (ApiPlug.ApiPlugType = API_SCAN) or (ApiPlug.ApiPlugType = API_SCANFILE) then begin
    Result2 := ApiPlug.ApiPlugScanFile(PChar(FileName));
    if result2 <> MES_NONE then begin
        case result2 of
          MES_SCANDIR    : ScanDir(ApiPlug.ApiPlugGetScanDir);
          MES_SCANFILE   : ScanFile(ApiPlug.ApiPlugGetScanFile);
          MES_PLUGINWAIT : WaitForPlugin; // Until wait   //
          MES_PLUGINEXIT : WaitForPlugin; // Wait and exit//
        end;
      end;
  end;
end;
  if Result2 = MES_PLUGINEXIT then Exit;
except
end;     }
  i:=0;
  Result := 'NONE';
  acak := Random(1709);

  Sebelum := FileName;
  {if IsUnicode(ExtractFileName(FileName),1) then
  begin
    Dirubah := True;
    if RenameWithCMD(ExtractFilePath(FileName),ExtractFileName(FileName),'susp'+IntToStr(Acak)+'.vir') = '' then
      FileName := ExtractFilePath(FileName)+'susp'+IntToStr(Acak)+'.vir'
    else
      FileName := Sebelum;
  end
else}
  FileName := Sebelum;

  try

    HitungFileCRC32(FileName,CRCVAL,Total,errorCRC);
    CRC32   := IntToHex(CRCVAL,8);

    {HASH    := MD5DigestToStr(MD5File(FileName));
    HASHNS  := HASH;
    SIZE    := GetSize(FileName);
    HASH    := HASH + ':' + SIZE;}
    OpenFileForScan(FileName);
//    Mainform.trayicon.Hint := 'Scanning : '+FileName;
  except
    OnReadErrorProc(FileName,1);
    exit;
  end;

    if (lowercase(ExtractFileExt(FileName)) = '.lnk') then
    begin
      R := FindHexStringInFile('$74$00$68$00$75$00$6D$00$62$00$2E$00$64$00$62$00',0,1);
      if (R <> -1) then
      begin
        OnVirFoundProc(FileName,'Junk.VBS ',1);
        CloseFileAfterScan;
        Exit;
      end;
      CloseFileAfterScan;
      exit;
    end;


  if i < dBcount then begin
  While i < DBCount do begin
    if (StreamDB.DBViruses[i].SignType = 2) then
    begin
      SIGN := StreamDB.DBViruses[i].Signature;
      try
        //try
        if scaniki(SIGN,1) then
        begin
          Result := StreamDB.DBViruses[i].VirName;
          WezKetemu := True;
          CloseFileAfterScan;
          exit;
        end;
      except
        ClosefileAfterScan;
        Exit;
      end;
    end;

   { if (StreamDB.DBViruses[i].SignType = 1) and (Security = 3) then
      if (LowerCase(StreamDB.DBViruses[i].Signature) = LowerCase(HASH)) or (LowerCase(StreamDB.DBViruses[i].Signature) = LowerCase(HASHNS))then
      begin
        Result := StreamDB.DBViruses[i].VirName;
        Wezketemu := true;
        if Memory then
        begin
          KillTask(ExtractFileName(FileName));
          CloseFileAfterScan;
          exit;
        end;
        WezKetemu := False;
        CloseFileAfterScan;
        exit;
      end;
    }
    if (StreamDB.DBViruses[i].SignType = 0) then
    begin
      if (LowerCase(StreamDB.DBViruses[i].Signature) = LowerCase(CRC32)) and (not scancomplete) then
       begin
         Result := StreamDB.DBViruses[i].VirName;
         WezKetemu := True;

      if Memory then
        begin
          KillTask(ExtractFileName(FileName));
  //        OnAddToLogStr('Process Killed : '+ExtractFileName(FileName),8);
          CloseFileAfterScan;
          exit;
        end;
      try
        For p := 0 to ApiPlugins.Count-1 do begin
          ApiPlug := ApiPlugins.items[i];
          ApiPlug.ApiPlugSendInfected(PChar(FileName));
        end;
      except
        WezKetemu := False;
        CloseFileAfterScan;
        exit;
    end;
    CloseFileAfterScan;
    Exit;
    end;
    end;
    inc(i);
  end;
  CloseFileAfterScan;
 end;
 if dirubah then
   RenamewithCMD(ExtractFilePath(filename),'susp'+IntToStr(Acak)+'.vir',ExtractFileName(sebelum));
end;

Function ScanDird(Dir:String) : Boolean;
Var
  SR:TSearchRec;
  FindRes,i:Integer;
  EX : String;
  EX1: String;
  jumlah : integer;
  fname : string;
begin
  //dirc := 0;
  if not scancomplete then
  begin
  Result := false;
  FindRes:= FindFirst(dir+'*.*',faAnyFile,SR);
  While (FindRes=0) and (not scancomplete) do
   begin
     if ((SR.Attr and faDirectory)=faDirectory) and
    ((SR.Name='.')or(SR.Name='..')) then
      begin
        FindRes:= FindNext(SR);
        Continue;
      end;

    if ((SR.Attr and faDirectory)=faDirectory) then
      begin
        dirc := dirc + 1;
        ScanDird(Dir+SR.Name+'\');
        FindRes:= FindNext(SR);
        Continue;
      end;

    // Scan for exestension
    if not GlobalScan then
    begin
      Ex := ExtractFileExt(Dir+SR.Name);
      for i := 0 to ExestensionList.Count-1 do
      if  LowerCase(Ex) = ExestensionList[i] then
      begin
        ScanFile(Dir+Sr.Name);
      end;
    end
   else
     if not ((LowerCase(ExtractFileExt(Dir+Sr.Name)) = '.mp3') or (LowerCase(ExtractFileExt(Dir+Sr.Name)) = '.rar') or (LowerCase(ExtractFileExt(Dir+Sr.Name)) = '.avi') or (LowerCase(ExtractFileExt(Dir+Sr.Name)) = '.pdf')) then
     begin
       ScanFile(Dir+Sr.Name)
     end;

    for i := 0 to APIExestensionList.Count-1 do
    if  LowerCase(Ex) = APIExestensionList[i] then
    begin
      ScanFile(Dir+Sr.Name);
    end;

    try
      MainForm.ScanFile.caption  := MinimizeName(Dir+Sr.Name,Mainform.Canvas, Mainform.ScanFile.Width);
    except
      Mainform.ScanFile.caption := Dir+Sr.Name;
    end;

    MainForm.FileCN := MainForm.FileCN + 1;
    Mainform.txtFileScan.Caption := 'Total : '+IntToStr(Dirc)+' directories, '+IntToSTr(mainform.FileCN)+' files.';
    if Mainform.prog.MaxValue > mainform.prog.progress then
       Mainform.prog.progress := Mainform.FileCN;

    FindRes:=FindNext(SR);
  end;
  FindClose(SR);
  Result := true;
  end;
end;

function ScanDir(Dir:String) : Boolean;
begin
  ScanMemory;
  Result := ScanDird(dir)
end;

Function RTPScan(Dir:String) : string;
Var
  SR:TSearchRec;
  OBJ : TObject;
  FindRes,i:Integer;
  jumlah : integer;
  EX : String;
begin
  IsRTP := True;
  Result := 'NONE';
  FindRes:=FindFirst(Dir+'*.*',faAnyFile,SR);
  While (FindRes=0) and (not ganti) do
   begin
     lanjut;
    {if ((SR.Attr and faDirectory)=faDirectory) and
    ((SR.Name='.')or(SR.Name='..')) then
      begin
        FindRes:=FindNext(SR);
        Continue;
      end;}

    if ((SR.Attr and faDirectory)=faDirectory) then
      begin
//        RTPScan(Dir+SR.Name+'\');
        FindRes:=FindNext(SR);
        Continue;
      end;

    RTPScan := ScanFileBiasa(Dir+Sr.Name);

    FindRes:=FindNext(SR);
    RTPResult := Result;
  end;
  FindClose(SR);
end;
{
Function RekursiDir(Dir:String) : boolean;
Var
  SR:TSearchRecW;
  FindRes,i:Integer;
  EX : String;
  EX1: String;
  jumlah : integer;
begin
  //dirc := 0;
  Result := False;
  if not scancomplete then begin
  FindRes:=WIDEFindFirst(Dir+'*.*',faAnyFile,SR);
  While (FindRes=0) do
   begin

     if ((SR.Attr and faDirectory)=faDirectory) and
    ((SR.Name='.')or(SR.Name='..')) then
      begin
        FindRes:=WIDEFindNext(SR);
        Continue;
      end;

    if ((SR.Attr and faDirectory)=faDirectory) then
      begin
        RekursiDir(Dir+SR.Name+'\');
        FindRes:=WIDEFindNext(SR);
        Continue;
      end;

    etung := etung + 1;

    if SkipFile then Exit;

    Mainform.prog.max := etung;
    FindRes:=WIDEFindNext(SR);
  end;
  WideFindClose(SR);
  Result := true;
 end;
end;               }

Function rekursiDir(Dir:String) : Boolean;
Var
  SR:TSearchRec;
  FindRes,i:Integer;
  EX : String;
  EX1: String;
  jumlah : integer;
begin
  //dirc := 0;
  if not scancomplete then begin
  Result := false;
  FindRes:= FindFirst(Dir+'*.*',faAnyFile,SR);
  While (FindRes=0) and (not scancomplete) do
   begin
     if ((SR.Attr and faDirectory)=faDirectory) and
    ((SR.Name='.')or(SR.Name='..')) then
      begin
        FindRes:=FindNext(SR);
        Continue;
      end;

    if ((SR.Attr and faDirectory)=faDirectory) then
      begin
        dirc := dirc + 1;
        RekursiDir(Dir+SR.Name+'\');
        FindRes:=FindNext(SR);
        Continue;
      end;

    // Scan for exestension
    if not GlobalScan then
    begin
      Ex := ExtractFileExt(Dir+SR.Name);
      for i := 0 to ExestensionList.Count-1 do
      if  LowerCase(Ex) = ExestensionList[i] then
      begin
        Inc(etung);
      end;
    end
   else
     begin
       inc(etung);
     end;

    for i := 0 to APIExestensionList.Count-1 do
    if  LowerCase(Ex) = APIExestensionList[i] then
    begin
      inc(etung);
    end;

    Inc(etung);
    Mainform.prog.MaxValue := Etung;

    FindRes:=FindNext(SR);
  end;
  FindClose(SR);
  Result := true;
  end;
end;



begin
  Security := 2;
  CRC32S := False;
  HEXS := False;
  Heuristic := False;
  memory := false;
  MD5S := False;
  IsRTP := false;
  Allowmemscan := True;
end.

