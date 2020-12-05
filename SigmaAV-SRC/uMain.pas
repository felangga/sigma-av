unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Menus, ImgList, XPMan, avKernel, avTypes, ShellAPI, ShlObj,
  ToolWin, ActnMan, ActnCtrls, Buttons, URLMon, MMSystem, ComOBJ, FileCtrl,
  ActnColorMaps, avdatabase, tlHelp32, avScanner, repair, ShellCtrls, commctrl,
  SUIMainMenu, SUITitleBar, SUIMgr, SUIButton, SUIListView, SUIProgressBar,
  SUIDlg, SUIMemo, SUIPageControl, SUITabControl, SUIPopupMenu, SUIForm, avHex,
  SUISideChannel, SUIImagePanel, SUIURLLabel, procpath, CoolTrayIcon, Stealth,
  ShellNotify, KSpoold, proses, SUIToolBar, SUIScrollBar, CheckLst, Registry,
  ActnMenus, VirFound, ActiveX, QFileCtrls, FilesProcess, Gauges,
  madExceptVcl;

Const
  {$EXTERNALSYM PBS_MARQUEE}
  PBS_MARQUEE = 08;

  LWA_COLORKEY  = 1;
  LWA_ALPHA     = 2;
  RSPSIMPLESERVICE     = 1;
  RSPUNREGISTERSERVICE = 0;
   NIF_INFO = $10;
  NIF_MESSAGE = 1;
  NIF_ICON = 2;
  NOTIFYICON_VERSION = 3;
  NIF_TIP = 4;
  NIM_SETVERSION = $00000004;
  NIM_SETFOCUS = $00000003;
  NIIF_INFO = $00000001;
  NIIF_WARNING = $00000002;
  NIIF_ERROR = $00000003;

  NIN_BALLOONSHOW = WM_USER + 2;
  NIN_BALLOONHIDE = WM_USER + 3;
  NIN_BALLOONTIMEOUT = WM_USER + 4;
  NIN_BALLOONUSERCLICK = WM_USER + 5;
  NIN_SELECT = WM_USER + 0;
  NINF_KEY = $1;
  NIN_KEYSELECT = NIN_SELECT or NINF_KEY;

  {define the callback message}
  TRAY_CALLBACK = WM_USER + $7258;

  {new NotifyIconData structure definition}
type
  PNewNotifyIconData = ^TNewNotifyIconData;
  TDUMMYUNIONNAME    = record
    case Integer of
      0: (uTimeout: UINT);
      1: (uVersion: UINT);
  end;


  TNewNotifyIconData = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
   //Version 5.0 is 128 chars, old ver is 64 chars
    szTip: array [0..127] of Char;
    dwState: DWORD; //Version 5.0
    dwStateMask: DWORD; //Version 5.0
    szInfo: array [0..255] of Char; //Version 5.0
    DUMMYUNIONNAME: TDUMMYUNIONNAME;
    szInfoTitle: array [0..63] of Char; //Version 5.0
    dwInfoFlags: DWORD;   //Version 5.0
  end;

Type
 
   tAlphaPct = 0..100;

type
  TMainForm = class(TForm)
    Bevel: TBevel;
    ScanFile: TLabel;
    ImageList: TImageList;
    DrivesImg: TImageList;
    Addfolder1: TMenuItem;
    Delete1: TMenuItem;
    N1: TMenuItem;
    Reftesh1: TMenuItem;
    SaveDialog: TSaveDialog;
    Bevel2: TBevel;
    Del: TMenuItem;
    avirus: TMenuItem;
    Options1: TMenuItem;
    Help1: TMenuItem;
    Help2: TMenuItem;
    About1: TMenuItem;
    ools1: TMenuItem;
    RegistryEditor1: TMenuItem;
    ProcessKiller1: TMenuItem;
    Update1: TMenuItem;
    MenuImage: TImageList;
    Panel1: TPanel;
    VirusDatabase1: TMenuItem;
    N3: TMenuItem;
    txtFileScan: TLabel;
    txtVirusFound: TLabel;
    Plugins1: TMenuItem;
    QuarantineRoom: TMenuItem;
    PortInformation1: TMenuItem;
    suiThemeManager1: TsuiThemeManager;
    ScanBTN: TsuiButton;
    cmdDel: TsuiButton;
    cmdDelAll: TsuiButton;
    cmdQuar: TsuiButton;
    cmdQuarAll: TsuiButton;
    cmdRepair: TsuiButton;
    RepairMsg: TsuiMessageDialog;
    exitmsg: TsuiMessageDialog;
    suiForm1: TsuiForm;
    PathMenu: TsuiPopupMenu;
    DelMenu: TsuiPopupMenu;
    MainMenu1: TsuiMainMenu;
    MainPages: TsuiPageControl;
    ScanPathesTab: TsuiTabSheet;
    ScanningTab: TsuiTabSheet;
    ScanList: TsuiListView;
    chkSWC: TsuiCheckBox;
    ReportTab: TsuiTabSheet;
    ReportMemo: TsuiMemo;
    Panel4: TPanel;
    VirMsg: TsuiMessageDialog;
    MsgClean: TsuiMessageDialog;
    File1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    msgnf: TsuiMessageDialog;
    ScanFile1: TMenuItem;
    ListBox1: TListBox;
    Button1: TButton;
    Timer1: TTimer;
    lbljm: TLabel;
    PathList: TsuiListView;
    Button2: TButton;
    Alwaysontop1: TMenuItem;
    trayicon: TCoolTrayIcon;
    PopupMenu1: TPopupMenu;
    Exit2: TMenuItem;
    N4: TMenuItem;
    OpenSigmaAV1: TMenuItem;
    ImageList4: TImageList;
    ShellNotify1: TShellNotify;
    dlgmdins: TsuiMessageDialog;
    ListBox2: TListBox;
    RTP: TTimer;
    suspend: TListBox;
    N5: TMenuItem;
    N6: TMenuItem;
    Update2: TMenuItem;
    Label1: TLabel;
    logo: TImage;
    RichEdit1: TRichEdit;
    lblWarn: TLabel;
    Proses: TTimer;
    proseslist: TListBox;
    cmdRefresh: TButton;
    Button3: TButton;
    fastscan: TTimer;
    RunTimeProtection1: TMenuItem;
    tmrMarque: TTimer;
    suiImagePanel1: TsuiImagePanel;
    Ngetung: TFilesProcess;
    heuricon: TsuiImagePanel;
    prog: TGauge;
    suiMemo1: TsuiMemo;
    procedure ExitBTNClick(Sender: TObject);
    procedure suitempScanListDblClick(Sender: TObject);
    procedure ScanBTNClick(Sender: TObject);
    procedure InitScannerKernel;
    Procedure StartScan(Parametr: String);
    procedure ScanShowBTNClick(Sender: TObject);
    procedure ReportShowBTNClick(Sender: TObject);
    procedure SaveBTNClick(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Reftesh1Click(Sender: TObject);
    procedure OptionsShowBTNClick(Sender: TObject);
    procedure Addfolder1Click(Sender: TObject);
    function CreateDrivesList(ListView: TSuiListView): boolean;
    procedure AboutBTNClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure suitempDelMenuPopup(Sender: TObject);
    procedure DelClick(Sender: TObject);
    procedure Scan1Click(Sender: TObject);
    procedure Log1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure cmdDeleteClick(Sender: TObject);
    procedure RegistryEditor1Click(Sender: TObject);
    procedure ProcessKiller1Click(Sender: TObject);
    procedure Update1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure VirusDatabase1Click(Sender: TObject);
    procedure cmdDelClick(Sender: TObject);
    procedure suitempScanListClick(Sender: TObject);
    procedure cmdDelAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmdQuarClick(Sender: TObject);
    procedure Plugins1Click(Sender: TObject);
    procedure cmdRepairClick(Sender: TObject);
    procedure QuarantineRoomClick(Sender: TObject);
    procedure shcChange;
    function GetVersion : string;
    procedure suitempScanListCustomDraw(Sender: TCustomListView;
      const ARect: TRect; var DefaultDraw: Boolean);
    procedure PathListCustomDraw(Sender: TCustomListView;
      const ARect: TRect; var DefaultDraw: Boolean);
    procedure PortInformation1Click(Sender: TObject);
    procedure CMD1Click(Sender: TObject);
    procedure ScanFile1Click(Sender: TObject);
    procedure cmdQuarAllClick(Sender: TObject);
    function Encrypt(const s: String; CryptInt: Integer): String;
    function Decrypt(const s: String; CryptInt: Integer): String;
    procedure avirusClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Alwaysontop1Click(Sender: TObject);
    procedure suiForm1TitleBarCustomBtnsClick(Sender: TObject;
      ButtonIndex: Integer);
    procedure OpenSigmaAV1Click(Sender: TObject);
    procedure ShellNotify1Notify(Sender: TObject; Event: TShellNotifyEvent;
      Path1, Path2: String);
    procedure RxFolderMonitor1Change(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure RTPTimer(Sender: TObject);
    procedure Update2Click(Sender: TObject);
    procedure suiURLLabel1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure chkSWCClick(Sender: TObject);
    procedure trayiconDblClick(Sender: TObject);
    procedure logoClick(Sender: TObject);
    procedure UnivrsalNotify(Sender: TObject; Event: TShellNotifyEvent;
      Path1, Path2: String);
    procedure ProsesTimer(Sender: TObject);
    procedure cmdRefreshClick(Sender: TObject);
    procedure trayiconStartup(Sender: TObject; var ShowMainForm: Boolean);
    procedure trayiconBalloonHintClick(Sender: TObject);
    procedure fastscanTimer(Sender: TObject);
    procedure suiButton1Click(Sender: TObject);
    procedure RunTimeProtection1Click(Sender: TObject);
    procedure tmrMarqueTimer(Sender: TObject);
    procedure suiImagePanel1Click(Sender: TObject);
    function NgetungFileProcessCallback(Sender: TObject; FileName: String;
      Progress: Int64; var Abort: Boolean): Boolean;
    function NgetungFileCountProgressCallback(Sender: TObject;
      Progress: Int64; var Abort: Boolean): Boolean;
    procedure Shutdown1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    procedure Ear(var Message: TMessage); message WM_User+4242;
    procedure TrimWorkingSet;
  public
    FileCN        : Integer;
    fcancel       : boolean;
    FileInfected  : Integer;
    FileIgnored   : Integer;
    Dontexit      : boolean;
    Path          : String;
    FDBDir: String;
    FMain: String;
    FDaily: String;
    FMainURL: String;
    FDailyURL: String;
    { Public declarations }
    function GetTarget(const LinkFileName:String):String;
    procedure NgetungDhisik;
    //procedure lanjut;
    procedure SetAutoStart(AppName, AppTitle: string; register: boolean);
  end;

Procedure OnScanStart;
Procedure OnAddLocation(Infeksi, Location : String; ID : Integer; metode : integer);
function KillTask(ExeFileName: string): Integer;
function RenamewithCMD(Direktori, Asal, Tujuan : string) : string;
function GetShortName (const FileName: string): string;
procedure lanjut;

var SigmaVS : String;
    VirDetect : Integer;
    dipilih    : integer;
    MaxSize    : Longint;
    MinSize    : Longint;
    skipfile   : boolean;
    pateniuser : boolean;
    voice: OLEVariant;
    Check : String;
    dtk,mnt,jam : integer;
    ScanNama : string;
    ScanComplete : boolean;
    gagal,raono : boolean;
    GlobalJustSelFile : boolean;
    info : string;
    warn : integer;
    proc : PROCESSENTRY32;
    hSnap : HWND;
    Looper : BOOL;
    Diklik : boolean;
    TmpProcess: TStringList;
    dbaru : string;
    diSkip  : Boolean;
    aplikasi : TApplication;
    FilePenting : TextFile;

Const

        Init         = ' Init Environment...';
        LoadAPI         = ' Loading API...';
        LoadDB          = ' Loading Database...';
        CreateDrvList   = ' Loading Drive List...';
        OptFileNotFnd   = ' File not found!';
        LoadOptFile     = ' Loading options...';
        InitProcedures  = ' Initializing procedures';
        ErrorInit       = ' Error!';

        LogBevel        = '===============================================================================';

        DBKnowledge     = 'Virus known: ';
        SCNOBJ          = 'Object scanned: ';
        ScanExecute     = 'Start scan';
        ScanEnd         = 'Scan completed';
        FileIgnor       = 'Ignore files: ';
        FileIfect       = 'Infected : ';
        FileScanned     = 'Total : ';
        IGNORED         = 'ignore';
        INFECTED        = 'infected';
        STOPB           = 'Stop';
        RETURNB         = 'Back';
        SCANB           = 'Scan Now';
        SCNFILE         = ' >> SCANNING >> ';
        FileDel         = ' Delete file >> ';
        FileNotDel      = ' File not deleted >>';
        FileQuar        = ' File quarantine >>';
        FilenotQuar     = ' Failed to quarantine >>';
        PATHNOSEL       = 'Please select the path in the list!';
        SysMenu         = 'Scan with SigmaAV';


        DelDialog       = 'Do you want to delete this file?';
        DelError        = 'Access denied to delete this file!';
        HelpNOFound     = 'Help file not found!';


var
  MainForm      : TMainForm;
  inScan        : Boolean = False;
  NeedToReturn  : Boolean = False;
  memory        : boolean;
  shrtctlnk     : string;
  pisanwae      : string;
  dirc          : integer;
  ganti         : boolean;
  RTPResult     : String;
  JmlhAtt       : integer;
  FASTSCAN      : Boolean;
  UnivName,hasil: String;


implementation

uses uSelInfo, uOptions, uAddPath, AboutFrm, Math, regedit, tskmgr,
  VirDatabase, Plugin, Quarantine, Port, Command, scan1file, Upload,
  update, ScanMem, init;


{$R *.dfm}


function TMainForm.Encrypt(const s: String; CryptInt: Integer): String;
var
  i: integer;
  s2: string;
begin
  if not (Length(s) = 0) then
    for i := 1 to Length(s) do
      s2 := s2 + Chr(Ord(s[i]) + CrypTint);
  Result := s2;
end;

function TMainform.Decrypt(const s: String; CryptInt: Integer): String;
var
  i: integer;
  s2: string;
begin
  if not (Length(s) = 0) then
    for i := 1 to Length(s) do
      s2 := s2 + Chr(Ord(s[i]) - cryptint);
  Result := s2;
end;

procedure TMainForm.TrimWorkingSet;
// Digunakan untuk membatasi CPU Usage supaya tidak terlalu berlebihan
// dan dapat menyebabkan crash.
var
  MainHandle : THandle;
begin
  MainHandle := OpenProcess(PROCESS_ALL_ACCESS, FALSE, GetCurrentProcessID);
  SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF);
  CloseHandle(MainHandle);
end;

function TMainForm.GetTarget(const LinkFileName:String):String;
var
   psl  : IShellLink;
   ppf  : IPersistFile;
   WidePath  : Array[0..260] of WideChar;
   Info      : Array[0..MAX_PATH] of Char;
   wfs       : TWin32FindData;
begin
 if UpperCase(ExtractFileExt(LinkFileName)) <> '.LNK' Then
 begin
   Result:='NOT a shortuct by extension!';
   Exit;
 end;

 CoCreateInstance(CLSID_ShellLink,nil,CLSCTX_INPROC_SERVER,IShellLink,psl);
 if psl.QueryInterface(IPersistFile, ppf) = 0 then
 begin
   MultiByteToWideChar(CP_ACP,
                       MB_PRECOMPOSED,
                       PChar(LinkFileName),
                       -1,
                       @WidePath,
                       MAX_PATH);
   ppf.Load(WidePath, STGM_READ);
   psl.GetPath(@info,
               MAX_PATH,
               wfs,
               SLGP_UNCPRIORITY);
   Result := info;
 end
 else
   Result := '';
end;

Function GETParam(Str: String): String;
var
TMP,Str1,Str2 : String;
PS: integer;
begin
    TMP := STR;
    if TMP <> '' then
    if pos('=',TMP) <> 0 then begin
    ps := pos('=',TMP);
    Str1 := Copy(TMP,0,ps-1);
    Str2 := Copy(TMP,ps+1,length(Tmp));
    Result := Str2;
end;
end;

Function GETParamName(Str: String): String;
var
TMP,Str1,Str2 : String;
PS: integer;
begin
    TMP := STR;
    if TMP <> '' then
    if pos('=',TMP) <> 0 then begin
    ps := pos('=',TMP);
    Str1 := Copy(TMP,0,ps-1);
    Str2 := Copy(TMP,ps+1,length(Tmp));
    Result := Str1;
end;
end;

Procedure LoadOptions(FileName: String);
var
List: TStringList;
i: integer;
begin
OptionsForm.PathList.Clear;
OptionsForm.ExtList.Clear;

List := TStringList.Create;
List.LoadFromFile(FileName);
for i := 0 to List.Count-1 do begin

        if GETParamName(List[i]) = 'EXT' then
        begin
          with OptionsForm.ExtList.Items.Add do
          begin
            Caption := GetParam(List[i]);
            ImageIndex := 3;
          end;
        end;
        if GETParamName(List[i]) = 'PATH' then
        begin
        with OptionsForm.PathList.Items.Add do
          begin
            Caption := GetParam(List[i]);
            if DirectoryExists(Caption) then ImageIndex := 4 else
            begin
              ImageIndex := 5;
              MainForm.PathList.Canvas.Brush.Color := clRed;
            end;
          end;
        end;

        if GETParamName(List[i]) = 'Check' then
        if GetParam(List[i]) = 'NORMAL' then
          begin
            OptionsForm.chckNorm.Checked := true;
            Check := 'Normal';
            SetSecurity(2);
          end
        else
          begin
            OptionsForm.chckHigh.Checked := true;
            SetSecurity(3);
          end;

        if GETParamName(List[i]) = 'FASTSCAN' then
        if GetParam(List[i]) = 'YES' then
          begin
            OptionsForm.chkFast.Checked := true;
            Mainform.fastscan.Enabled := true;
            FastScan:=true;
          end
        else
          begin
            Mainform.fastscan.Enabled := false;
            FastScan:=false
          end;


        if GETParamName(List[i]) = 'STARTUP' then
        if GetParam(List[i]) = 'YES' then
          begin
            OptionsForm.chkstart.Checked := true;
            Mainform.SetAutoStart(ParamSTr(0)+' /hid','SigmaAV',true)
          end
        else
          if GetParam(List[i]) = 'NO' then
          begin
            OptionsForm.chkstart.Checked := false;
            Mainform.SetAutoStart(ParamSTr(0)+' /hid','SigmaAV',false)
          end;


        if GETParamName(List[i]) = 'SelFile' then
        if GetParam(List[i]) = 'YES' then
          begin
            OptionsForm.justscan.Checked := true;
            GlobalScan := False;
          end
        else
          if GetParam(List[i]) = 'NO' then
          begin
            OptionsForm.JustScan.Checked := false;
            GlobalScan := True;
          end;

        if GetParamName(List[i]) = 'max' then
        begin
         OptionsForm.maxsld.Value := (StrToInt(GetParam(List[i])) div 1024) div 1024;
         maxsize := StrToInt(GetParam(List[i]));
        end;

        if GetParamName(List[i]) = 'min' then
        begin
          OptionsForm.minsld.Value := (StrToInt(GetParam(List[i])) div 1024) div 1024;
          MinSize := StrToInt(GetParam(List[i]));
        end;


        if GETParamName(List[i]) = 'HEUR' then
        if GetParam(List[i]) = 'ON' then
          begin
            OptionsForm.chkHeur.Checked := true;
            SetHeur(TRUE);
          end
        else
          if GetParam(List[i]) = 'OFF' then
          begin
            OptionsForm.chkHeur.Checked := false;
            SetHeur(FALSE);
          end;

        if GETParamName(List[i]) = 'MEMSCAN' then
        if GetParam(List[i]) = 'YES' then
          begin
            OptionsForm.chkMemscan.Checked := true;
            AllowMEmScan := True;
          end
        else
          if GetParam(List[i]) = 'NO' then
          begin
            OptionsForm.chkMemScan.Checked := false;
            AllowMemScan := False;
          end;

        if GETParamName(List[i]) = 'REGISTERSYSMENU' then
        if GetParam(List[i]) = 'ON' then
          OptionsForm.RegisterSysMenu.Checked := true
        else
          OptionsForm.RegisterSysMenu.Checked := False;

        if GETParamName(List[i]) = 'CUSTOMSEARCH' then
        if GetParam(List[i]) = 'INACTIVE' then
          OptionsForm.chckCustom.Checked := False
        else
          OptionsForm.chckCustom.Checked := True;

        if GetParam(List[i]) = 'CRC32' then
        begin
          OptionsForm.cCRC.Checked := True;
          SelectScan(True, False, False);
        end;
        if GetParam(List[i]) = 'HEX' then
        begin
          OptionsForm.cHex.Checked := True;
          SelectScan(False, True, False);
        end;
        if GetParam(List[i]) = 'MD5' then
        begin
          OptionsForm.cMD5.Checked := True;
          SelectScan(False, False, True);
        end;
        if GetParam(List[i]) = 'CRC32, HEX' then
        begin
          OptionsForm.cCRC.Checked := True;
          OptionsForm.CHex.Checked := True;
          SelectScan(True, True, False);
        end;
        if GetParam(List[i]) = 'HEX, MD5' then
        begin
          OptionsForm.cHex.Checked := True;
          OptionsForm.CMD5.Checked := True;
          SelectScan(False, True, True);
        end;
        if GetParam(List[i]) = 'CRC32, MD5' then
        begin
          OptionsForm.cCRC.Checked := True;
          OptionsForm.CMD5.Checked := True;
          SelectScan(True, False, True);
        end;
        if GetParam(List[i]) = 'CRC32, HEX, MD5' then
        begin
          OptionsForm.cCRC.Checked := True;
          OptionsForm.CHex.Checked := true;
          OptionsForm.CMD5.Checked := True;
          SelectScan(True, True, True);
        end;

end;

List.Free;
end;

function GetHDDSerial(ADisk : char): dword;
var
  SerialNum : dword;
  a, b : dword;
  VolumeName : array [0..255] of char;
begin
  Result := 0;
  if GetVolumeInformation(PChar(ADisk + ':\'), VolumeName, SizeOf(VolumeName),
  @SerialNum, a, b, nil, 0) then
  Result := SerialNum;
end;

function TMainForm.CreateDrivesList(ListView: TSuiListView): boolean;
var
  Bufer : array[0..1024] of char;
  RealLen, i : integer;
  S : string;
begin
  ListView.Clear;
  RealLen := GetLogicalDriveStrings(SizeOf(Bufer),Bufer);
  i := 0; S := '';


  while i < RealLen do begin
    if Bufer[i] <> #0 then begin
    S := S + Bufer[i];
    inc(i);
    end else begin
    inc(i);
    with ListView.Items.Add do begin
      Caption := S;
      if GetDriveType(PChar(S)) = DRIVE_RAMDISK then ImageIndex := 3;
      if GetDriveType(PChar(S)) = DRIVE_FIXED then ImageIndex := 3;
      if GetDriveType(PChar(S)) = DRIVE_REMOTE then ImageIndex := 0;
      if GetDriveType(PChar(S)) = DRIVE_CDROM then ImageIndex := 1;
      if GetDriveType(PChar(S)) = DRIVE_REMOVABLE then ImageIndex := 2;
    end;
    S := '';
  end;
  end;

  For i := 0 to OptionsForm.PathList.Items.Count-1  do begin
    with ListView.Items.Add do begin
      Caption := OptionsForm.PathList.Items[i].Caption;
      ImageIndex := OptionsForm.PathList.Items.Item[i].ImageIndex;
    end;
  end;
  Result := ListView.items.Count > 0;
end;

procedure OnAddToLogStr(LogString: String; ID: integer);
var
TMP : String;

begin
  with MainForm.ScanList.Items.Add do begin
    if ID = -1 then
      Caption := LogString
    else begin
      //Caption := FormatDateTime('[hh:mm:ss]',now) + '  ' + LogString;
      MainForm.ReportMemo.Lines.Add(Caption);
      {}
      if ID = 2 then begin    // ID 2 Infected!!! Extract path...
        TMP := LogString;
        system.Delete(Tmp,1,pos(']',Tmp)+1);
        SubItems.Add(TMP);
        JmlhAtt := JmlhAtt + 1;
      end;

      if ID = 1 then
      begin
        JmlhAtt := JmlhAtt + 1;
      end;

      if ID = 11 then
      begin
        warn:= warn + 1;
        Mainform.lblWarn.Caption := 'Warning files : '+IntToStr(Warn);
      end;
      {}
      ImageIndex := ID;
    end;
    ImageIndex := ID;
  end;
end;

Procedure OnAddLocation(Infeksi, Location : String; ID : Integer; metode : integer);
begin
  with Mainform.ScanList.Items.Add do
  begin
    ImageIndex := ID;
    if ID = 11 then
      begin
        warn:= warn + 1;
        Mainform.lblWarn.Caption := 'Warning files : '+IntToStr(Warn);
      end;
    Caption := Infeksi;
    if metode = 0 then
      SubItems.Add('MD5')
  else
    if metode = 1 then
      SubItems.Add('HEX')
  else
    if metode = 2 then
      SubItems.Add('CRC32')
  else
    if metode = 3 then
      SubItems.Add('HEUR')
  else
    if metode = 4 then
      SubItems.Add('');
    SubItems.Add(Location);
  end;
end;

Procedure OnScanStart;
var
  i: integer;
begin
  ClearExtList;
  ScanComplete := false;
  VirDetect := 0;
  for i := 0 to OptionsForm.ExtList.Items.Count-1 do begin
    AddToExtList(ExtractFileExt(OptionsForm.ExtList.Items.Item[i].Caption));
  end;
  dtk := 0;
  Jmlh := 0;
  mnt := 0;
  jam := 0;
  MainForm.prog.Progress := 0;
  MainForm.ScanFile.Caption := 'Initializing...';
  MainForm.ScanningTab.Show;
  MainForm.ScanBTN.Caption := STOPB;
  MainForm.ScanList.Visible := true;
  MainForm.txtVirusFound.Caption := 'Virus Found : 0';
  Mainform.lblWarn.Caption := 'Warning files : 0';
  MainForm.txtFileScan.Caption := 'Total :';
  MainForm.ScanList.Clear;
  mainform.tmrMarque.Enabled := true;
  MainForm.FileCN       := 0;
  Etung                 := 0;
  MainForm.FileInfected := 0;
  MainForm.FileIgnored  := 0;
  SkipFile              := False;
  Mainform.fcancel              := False;
  Mainform.Timer1.Enabled       := true;
  Mainform.trayicon.CycleIcons  := true;
  inScan                        := True;
  NeedToReturn                  := False;
  DiSkip                        := False;
  //frmInit.Show;


  Sigma.Resume;

  Mainform.NgetungDhisik;
    //if memory then scanmemory;
end;

procedure OnProgress(FileScan: String; MessageInd: integer);
begin
  Mainform.ScanFile.caption := FileScan;
  Mainform.trayicon.hint := 'Scanning : '+Filescan;
  InScan := True;
end;

procedure OnReadError(FileName: String; MessageInd: integer);
begin
  //OnAddToLogStr('Skipped >> '+FileName,1);
  OnAddLocation('Skipped',FileName,1,4);
  MainForm.FileIgnored  := MainForm.FileIgnored + 1;
//  MainForm.FileCN := MainForm.FileCN + 1;
end;

procedure OnWarningHeur(FileName: String; Message:String);
begin
  //OnAddToLogStr(Message+' >> '+FileName,11);
  OnAddLocation(Message,FileName,11,3);
  MainForm.FileIgnored  := MainForm.FileIgnored + 1;
  MainForm.FileCN := MainForm.FileCN + 1;
end;

{
The following assembler Routines implement sound output via port access and work
therefore only with Win3.x and Win95/98.
Simply call Sound(hz) with hz as frequency in Hz, and stop the sound output with
NoSound().

If your application will run under Windows NT, you may use the operating system
routine:
Windows.Beep(Frequency, Duration);
}

procedure OnVirDetected(FileName,VirName: String;typedata : integer);
begin
  MainForm.ScanFile.caption  := FileName;
  //OnAddToLogStr(VirName,2);
  OnAddLocation(VirName,FileName,2,typedata);
  MainForm.FileInfected := MainForm.FileInfected + 1;
  Mainform.txtVirusFound.Caption := 'Virus Found : '+IntToStr(Mainform.FileInfected);
  VirDetect := VirDetect + 1;
end;

function Shutdown(RebootParam: Longword): Boolean;
var
  TTokenHd: THandle;
  TTokenPvg: TTokenPrivileges;
  cbtpPrevious: DWORD;
  rTTokenPvg: TTokenPrivileges;
  pcbtpPreviousRequired: DWORD;
  tpResult: Boolean;
const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    tpResult := OpenProcessToken(GetCurrentProcess(),
      TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
      TTokenHd);
    if tpResult then
    begin
      tpResult := LookupPrivilegeValue(nil,
        SE_SHUTDOWN_NAME,
        TTokenPvg.Privileges[0].Luid);
      TTokenPvg.PrivilegeCount := 1;
      TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      cbtpPrevious := SizeOf(rTTokenPvg);
      pcbtpPreviousRequired := 0;
      if tpResult then
        Windows.AdjustTokenPrivileges(TTokenHd,
          False,
          TTokenPvg,
          cbtpPrevious,
          rTTokenPvg,
          pcbtpPreviousRequired);
    end;
  end;
  Result := ExitWindowsEx(RebootParam, 0);
end;

procedure OnScanComplete;
begin
//  if not scancomplete then
  begin
  Mainform.tmrMarque.Enabled := False;
  if (MainForm.chkSWC.Checked = true) and not (pateniuser) then
  begin
    Mainform.cmdRepair.Click;
    ShutDown(EWX_POWEROFF or EWX_FORCE);
    MainForm.Close;
  end;
  DirC := 0;
  if fastscan then
    Mainform.fastscan.Enabled := false;
  MainForm.ScanBTN.Caption := RETURNB;
  NeedToReturn := True;
  inScan := False;
  MainForm.Path := '';
  Mainform.Timer1.Enabled := false;
  MessageBeep(MB_ICONASTERISK);
  //MainForm.SaveBTN.Enabled := true;
  Mainform.trayicon.CycleIcons := false;
  Mainform.fcancel := True;
  Mainform.trayicon.IconIndex := 0;
  MainForm.ScanFile.caption  := ScanEnd;
  MainForm.ReportMemo.Lines.Add(LogBevel);
  Mainform.trayicon.ShowBalloonHint('SigmaAV - Scan Complete','Here is the report :'+#13+#13+
                                    'File scanned : ' + inttostr(mainform.FileCN) +#13+
                                    'File ignored : ' + inttostr(mainform.FileIgnored) +#13+
                                    'File infected : ' +inttostr(mainform.FileInfected),bitinfo, 15);
//  Voice.Speak('Scan complete');
 // Sigma.Suspend;
//  MainForm.ReportMemo.Lines.SaveToFile('AttackReport.log');
  end;
end;

procedure TMainform.SetAutoStart(AppName, AppTitle: string; register: boolean);
const
   RegKey = '\Software\Microsoft\Windows\CurrentVersion\Run';
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey(RegKey, False) then
    begin
      if register = false then
        Registry.DeleteValue(AppTitle)
      else
        Registry.WriteString(AppTitle, AppName);
    end;
  finally
    Registry.Free;
  end;
end;

procedure TMainForm.InitScannerKernel;
var
i:integer;
menu : TMenuItem;
begin
try
  trayicon.ShowBalloonHint('SigmaAV - '+Getversion,'Initializing...',bitinfo, 10);

  Diklik := False;
  TmpProcess := TStringList.Create; // gawe proses notifikasi
  pisanwae := '';
  Dontexit := false;

  m_strm_dec:= TMemoryStream.Create;
  bm_dec:= TBitmap.Create;


  InitExtList;
  InitAvProc(OnProgress,OnVirDetected,OnWarningHeur,OnReadError,OnScanComplete,OnAddLocation,OnScanStart);
  if FileExists(ExtractFilePath(paramstr(0))+'Options.ini') then
    LoadOptions(ExtractFilePath(paramstr(0))+'Options.ini')
  else begin
  OptionsForm.SaveOptions(ExtractFilePath(paramstr(0))+'Options.ini');
  end;
  CreateDrivesList(PathList);
  trayicon.ShowBalloonHint('SigmaAV - '+Getversion,'Loading databases....',bitinfo, 10);
  LoadDataBases(ExtractFilePath(paramstr(0))+'DataBases\');
  Sigma := TAvScanner.Create(True);
  InitApi;
  LoadApiPlugins(ExtractFilePath(paramstr(0))+'Plugins\');

{Get API}
  for i := 0 to GetPluginAPICount do
  with frmPlugin.Apilist.Items.Add do
  begin
    ImageIndex := 12;
    Caption := GetPluginAPIName(i) + ' ('+ExtractFileName(GetPluginAPIPath(i))+')';
    SubItems.Add(GetPluginAPIAutor(i));
    SubItems.Add(GetPluginAPIInfo(i));
    SubItems.Add(GetPluginAPIPath(i));
  end;

  if ParamStr(1) = '/hid' then
  begin
    Trayicon.ShowBalloonHint('SigmaAV - '+Getversion,'Virus Known : '+IntToStr(Hitung)+#13+'Ready to protect...',bitinfo,10);
  end
else
  Trayicon.ShowBalloonHint('SigmaAV - '+Getversion,'Virus Known : '+IntToStr(Hitung)+#13+'Please wait...',bitinfo,10);

except
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+' '+ErrorInit);
end;
{}
if OptionsForm.RegisterSysMenu.Checked then begin
  OptionsForm.FileTAddAction('*','SigmaAV',SysMenu,ParamStr(0)+' %1');
  OptionsForm.FileTAddAction('Directory','SigmaAV',SysMenu,ParamStr(0)+' %1');
  OptionsForm.FileTAddAction('Drive','SigmaAV',SysMenu,ParamStr(0)+' %1');
end else begin
  OptionsForm.FileTDelAction('Drive','SigmaAV');
  OptionsForm.FileTDelAction('Directory','SigmaAV');
  OptionsForm.FileTDelAction('*','SigmaAV');
end;
end;
{}

Procedure TMainForm.StartScan(Parametr: String);
begin
  delete(parametr,1,1); // Pengaman
  if DirectoryExists(Parametr+'\') then
  begin
    Sigma.NeedForAPI := false;
    Sigma.AvAction := TScanDir;
    Sigma.DirName := Parametr+'\';
    OnScanStart;
  end
else
  ShowMessage('error');

  if FileExists(Parametr) then
  begin
    Sigma.NeedForAPI := false;
    Sigma.AvAction := TScanFile;
    Sigma.FileName := Parametr;
    OnScanStart;
  end;

  if Parametr = 'DRV' then
  begin
    Sigma.NeedForAPI := false;
    Sigma.AvAction := TScanDir;
    Sigma.DirName := ExtractFileDrive(ParamStr(0))+'\';
    OnScanStart;
  end;
end;

procedure TMainForm.ExitBTNClick(Sender: TObject);
begin
Close;
end;

procedure TMainForm.suitempScanListDblClick(Sender: TObject);
var pusat,filenama : string;
    poss  : integer;
begin
end;

Procedure TMainForm.Ngetungdhisik;
begin
  fcancel := false;
  try
    Ngetung.Path := IncludeTrailingPathDelimiter(Sigma.DirName);
    prog.maxvalue := Mainform.Ngetung.Count;
  finally
    fcancel := false;
  end;
end;

procedure TMainForm.ScanBTNClick(Sender: TObject);
var i : integer;
    rampung : boolean;
begin
  Skipfile := false;
  warn := 0;
  Etung := 0;
  pateniuser := false;
  if PathList.ItemIndex <> -1 then
    Path := PathList.Selected.Caption;
  timer1.Enabled := true;
  if rampung then begin
  if NeedToReturn = false then begin
  if inScan = False then
    begin
      if (PATH <> '') and (DirectoryExists(Path)) then
      begin
        Sigma := TAvScanner.Create(True);
        Sigma.NeedForAPI := true;
        Sigma.AvAction := TScanDir;
        memory := false;
        Sigma.DirName := Path;
        OnScanStart;
      end
    else
      begin
        MessageDlg(PATHNOSEL,mtError,[mbOk],0);
        PathList.SetFocus;
      end;
    end
  else
    begin
      scancomplete := false;
      if ScanBTN.Caption = STOPB then
        if MessageDlg('Sigma is scanning, do you want to stop??',mtInformation,[mbYes,mbNo],0) = mrYes then
        begin
          pateniuser := true;
          timer1.Enabled := false;
          cmdDel.Enabled := False;
          cmdRepair.enabled := False;
          cmdDelAll.Enabled := False;
          cmdQuarAll.Enabled := False;
          ScanComplete := true;
          try   { Pengaman }
            Sigma.Suspend;
          except
            Sigma.Resume;
          end;
          OnScanComplete;
        end;
    end;
end
  else
    begin
      ScanBTN.Caption := ScanB;
      //MainForm.SaveBTN.Enabled := False;
      cmdDel.Enabled := False;
      cmdRepair.enabled := False;
      cmdDelAll.Enabled := False;
      cmdQuarAll.enabled := False;
      cmdQuar.Enabled := False;
      NeedToReturn := False;
      ScanPathesTab.Show;
    end;
  end;
end;

procedure TMainForm.ScanShowBTNClick(Sender: TObject);
begin
if not inScan then
ScanPathesTab.Show;
end;

procedure TMainForm.ReportShowBTNClick(Sender: TObject);
begin
if not inScan then
ReportTab.Show;
end;

procedure TMainForm.SaveBTNClick(Sender: TObject);
var
Report: TStringList;
i: integer;
begin

if SaveDialog.Execute then begin
  Report:= TStringList.Create;
  For i := 0 to ScanList.Items.Count-1 do
  Report.Add(ScanList.Items.Item[i].Caption);
  Report.SaveToFile(SaveDialog.FileName);
  Report.Free;
end;
end;

procedure TMainForm.Delete1Click(Sender: TObject);
begin
try
if PathList.ItemIndex <> -1 then
if PathList.Selected.ImageIndex > 3 then begin
OptionsForm.PathList.Items.Delete((PathList.Items.Count-1) - PathList.ItemIndex);
PathList.DeleteSelected;
end;
OptionsForm.SaveOptions(ExtractFilePath(paramstr(0))+'Options.ini');
except
end;
end;

procedure TMainForm.Reftesh1Click(Sender: TObject);
begin
CreateDrivesList(PathList);
end;

procedure TMainForm.OptionsShowBTNClick(Sender: TObject);
begin
if not inScan then begin
LoadOptions(ExtractFilePath(paramstr(0))+'Options.ini');
OptionsForm.ShowModal;
end;
end;

procedure TMainForm.Addfolder1Click(Sender: TObject);
begin
AddUserPathForm.ShowModal;
end;

procedure TMainForm.AboutBTNClick(Sender: TObject);
begin
//AboutForm.Memo3.Clear;
//
//AboutForm.Memo3.Lines.Add(NfoSigma+SigmaVS);
//AboutForm.Memo3.Lines.Add(NfoAiDKernel+GetKernelVersion);
//AboutForm.Memo3.Lines.Add(NfoAiDBuild+GetKernelBuild);
//AboutForm.Memo3.Lines.Add(' '+DBKnowledge+IntToStr(GetDBRecCount));
AboutForm.ShowModal;
end;

function GetByte(Value : TColor; Shift : byte): byte;
begin
  Result := (Value and ($FF shl Shift)) shr Shift;
  //Byte an entsprechender Stelle maskieren und dann nach Rechts verschieben
end;
{------------------------------------------------------------------------------}

procedure ColorToRGB(Color : TColor; var R, G, B : byte);
begin
  R := GetByte(Color, 16); //zweites Byte aus Color (v.R.)
  G := GetByte(Color, 8);  //drittes Byte aus Color (v.R.)
  B := GetByte(Color, 0);  //viertes Byte aus Color (v.R.)
end;
{------------------------------------------------------------------------------}

function RGBToColor(R, G, B : byte): TColor;
begin
  Result := ((R and $FF) shl 16) +
    ((G and $FF) shl 8) + (B and $FF);
end;
{------------------------------------------------------------------------------}

function TransparencyColor(BGColor, FRColor : TColor; TranspValue : byte): TColor;
var
  BGR, BGG, BGB, FRR, FRG, FRB, ergR, ergG, ergB : byte;
  TrFact : real;
begin
  //Transparenzfaktor errechnen
  TrFact := TranspValue / 100;

  //Hinter- und Vordergrundfarbe in Rot-,Grün- und Blauwerte splitten
  ColorToRGB(BGColor, BGR, BGG, BGB);
  ColorToRGB(FRColor, FRR, FRG, FRB);

  //Ergebnisfarbwerte errechnen
  ergR := byte(Trunc(BGR * TrFact + FRR * (1 - TrFact)));
  ergG := byte(Trunc(BGG * TrFact + FRG * (1 - TrFact)));
  ergB := byte(Trunc(BGB * TrFact + FRB * (1 - TrFact)));

  //Rot-,Grün- und Blauwert zu TColor und zurückgeben
  Result := RGBToColor(ErgR, ergG, ergB);
end;

function TMainForm.GetVersion : String;
var
  VerInfoSize: DWord;
  VerInfo: Pointer;
  VerValueSize: DWord;
  VerValue: PVSFixedFileInfo;
  Dummy: DWord;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    result := IntTostr(dwFileVersionMS shr 16);
    result := result+'.'+   IntTostr(dwFileVersionMS and $FFFF);
    result := result+'.'+   IntTostr(dwFileVersionLS shr 16);
    result := result+'.'+   IntTostr(dwFileVersionLS and $FFFF);
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  region1, region2: hrgn;
  i : integer;
begin
  trayicon.HideBalloonHint;
  shellnotify1.Active := true;

  Randomize;
  i := Random(17050906);
  Application.Title := IntToStr(i);
  SuiForm1.Caption := 'SigmaAV '+Getversion;
  //('+DBKnowledge+IntToStr(Hitung)+')';

  {voice := CreateOLEObject('SAPI.SpVoice');
  try
    voice.Speak('Welcome to F-Computer Sigma A-V.', 0);
  except
    Exit;
  end; }
  cmdRefresh.Click;
  TrayIcon.IconVisible := true;

end;

procedure TMainform.Ear(var Message: TMessage);
var txt: string;
    virus : string;
begin
  try
   txt := PChar(Message.LParam);
  // showmessage(txt);
   virus := ScanFileBiasa(txt);
   if virus <> 'NONE' then
   begin
     frmVFound.lblNama.Caption := virus;
     frmVFound.lbllokasi.Text := txt;
     frmVFound.Show;
   end;
  except
    txt := '';
  end;
  Message.Result := 1;
end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 // MainForm.ReportMemo.Lines.SaveToFile('AttackReport.log');
  m_strm_dec.Free;
  bm_dec.Free;
end;

function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure TMainForm.suitempDelMenuPopup(Sender: TObject);
begin
  if inscan then begin
  if (ScanList.ItemIndex <> -1) and (ScanList.Selected.ImageIndex = 2) then
    Avirus.Checked := True
  else
    AVirus.Checked := False;

  if (ScanList.ItemIndex <> -1) and ((ScanList.Selected.ImageIndex = 2) or (ScanList.Selected.ImageIndex = 7)) then
  begin
    cmdDel.Enabled := True;
    Del.Visible := true;
    avirus.Visible := true;
    cmdDelall.Enabled := True;
    cmdQuarAll.Enabled := True;
  end
else
  begin
    Del.Visible := False;
    avirus.Visible := false;
    cmdDel.Enabled := False;
    cmdDelAll.Enabled := False;
    cmdQuarAll.Enabled := False;
  end;
 end;
end;

procedure TMainForm.DelClick(Sender: TObject);
var poss : Integer;
    filenama : string;
    namafile : string;
begin
if MessageDlg(DelDialog,mtInformation,[mbCancel]+[mbYes],0) = 6 then begin
try
  FileNama := ScanList.Selected.SubItems[1];
  NamaFile := EXtractfilename(filenama);
  if FileIsReadOnly(filenama) then
       FileSetReadOnly(Filenama,False);
  KillTask(namafile);
  //ShowMessage(FileNama);
  if DeleteFile(FileNama) then
  begin
     ScanList.Selected.ImageIndex := 4;
     //ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+FileDel+ScanList.Selected.SubItems[0]);
  end
  else
 begin
     //ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+FileNotDel+ScanList.Selected.SubItems[0]);
     MessageDlg(DelError,mtWarning,[mbOk],0);
  end;

except
end;
end;
end;

procedure TMainForm.Scan1Click(Sender: TObject);
begin
 ScanBTN.Click;
end;

procedure TMainForm.Log1Click(Sender: TObject);
begin
  if not inScan then
    ReportTab.Show;
end;

procedure TMainForm.Options1Click(Sender: TObject);
begin
if not inScan then begin
LoadOptions(ExtractFilePath(paramstr(0))+'Options.ini');
OptionsForm.ShowModal;
end;
end;

procedure TMainForm.Help2Click(Sender: TObject);
begin
  if FileExists(ExtractFilePath(paramstr(0))+'\readme.txt') then
      ShellExecute(0,'',PChar(ExtractFilePath(paramstr(0))+'\readme.txt'),nil,nil,1)
else
  MessageDlg(HelpNOFound,mtError,[mbOk],0);
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close
end;

procedure TMainForm.cmdDeleteClick(Sender: TObject);
begin
  if MessageDlg(DelDialog,mtInformation,[mbCancel]+[mbYes],0) = 6 then begin
try
  if DeleteFile(ScanList.Selected.SubItems[0]) then
  begin
     if FileIsReadOnly(ScanList.Selected.SubItems[0]) then
       FileSetReadOnly(Scanlist.Selected.SubItems[0],False);
     ScanList.Selected.ImageIndex := 4;
  end
else
  begin
     MessageDlg(DelError,mtWarning,[mbOk],0);
  end;
except
end;
end;
end;

procedure TMainForm.RegistryEditor1Click(Sender: TObject);
begin
  RegistryEditor.ShowModal;
end;

procedure TMainForm.ProcessKiller1Click(Sender: TObject);
begin
  ProcKiller.ShowModal;
end;

procedure TMainForm.Update1Click(Sender: TObject);
begin
  if MessageDlg('It will use the internet connection. Do you want to continue?',mtInformation,[mbYes]+[mbNo],0) = mrYes then
   shellexecute(handle,'open','http://sigmaupload.4shared.com',
               nil,nil,sw_show);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // Ask user if shutdown should occur.
  if (ExitMsg.ShowModal = ExitMsg.Button1ModalResult) then
  begin
  //  trayicon.IconVisible := false;
    CanClose := true   // Allow Windows to shut down.
  end
else
    CanClose := false; // Prevent Windows from shutting down.
end;

procedure TMainForm.VirusDatabase1Click(Sender: TObject);
begin
  frmVirusDatabase.ShowModal;
end;

procedure TMainForm.cmdDelClick(Sender: TObject);
begin
  Del.Click;
end;

procedure TMainForm.suitempScanListClick(Sender: TObject);
begin
  if (ScanList.ItemIndex <> -1) and ((ScanList.Selected.ImageIndex = 11) or (ScanList.Selected.ImageIndex = 2)) and (inScan = False) then
  begin
    cmdDel.Enabled := True;
    Del.Visible := true;
    cmdRepair.Enabled := True;
    cmdQuar.Enabled := True;
    if VirDetect > 1 then
    begin
      cmdDelall.Enabled := True;
      cmdQuarAll.Enabled := True;
    end;
  end
else
  begin
    Del.Visible := False;
    cmdDel.Enabled := False;
    cmdRepair.enabled := False;
    cmdDelAll.Enabled := False;
    cmdQuar.Enabled := False;
    cmdQuarAll.Enabled := False;
  end;
end;

procedure TMainForm.cmdDelAllClick(Sender: TObject);
var I,poss    : Integer;
    filenama  : string;
    tp        : TPoint;
    pusat,asli: string;
    suk,gag   : integer;
    namafile  :string;
begin
  suk := 0;
  gag := 0;
  Prog.Progress := 0;
  prog.maxvalue := ScanList.Items.Count;
  for I := 0 to ScanList.Items.Count-1 do
  begin
    try
      pusat := Scanlist.Items.Item[i].SubItems[1];
    except
      pusat := '';
    end;
    filenama := pusat;
    if (pusat <> '') and ((ScanList.Items.Item[i].ImageIndex = 2) or (Scanlist.Items.Item[i].ImageIndex = 8) or (Scanlist.Items.Item[i].ImageIndex = 11)) then
    begin
      if FileIsReadOnly(filenama) then
        FileSetReadOnly(Filenama,False);

      KillTask(NamaFile);

      if DeleteFile(FileNama) then
      begin
        suk := suk + 1;
        ScanList.Items.Item[i].ImageIndex := 4;
      end
    else
      begin
        gag := gag + 1;
        ScanList.Items.Item[i].ImageIndex := 5;
      end;
      prog.progress := i+1;
    end;
  end;
  MessageDlg(IntToStr(suk)+' files deleted and '+IntToStr(gag)+' failed to delete.',mtInformation,[mbOk],0);
end;

procedure ShellFileOperation(fromFile: string; toFile: string; Flags: Integer);
var
  shellinfo: TSHFileOpStructA;
begin
  with shellinfo do
  begin
    wnd   := Application.Handle;
    wFunc := Flags;
    pFrom := PChar(fromFile);
    pTo   := PChar(toFile);
  end;
  SHFileOperation(shellinfo);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var i : integer;
    TheYear,TheMonth,TheDay : Integer;
    MainThread: THandle;

begin
  MainThread := GetCurrentThread;
  SetThreadPriority(MainThread, THREAD_PRIORITY_HIGHEST);

  Diklik := False;
  TmpProcess := TStringList.Create; // gawe proses notifikasi
  pisanwae := '';
  Dontexit := false;
  
  m_strm_dec:= TMemoryStream.Create;
  bm_dec:= TBitmap.Create;

  ShowWindow(Application.Handle, SW_HIDE);

{  SetWindowLong(Application.Handle, GWL_EXSTYLE,
          GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);}
  TheYear  := 2009;
  TheMonth := 12;
  TheDay   := 25;

  if (Date >= EncodeDate(TheYear, TheMonth, TheDay)) then
  begin
    MessageDlg('Please take database update to get more protection.',mtInformation,[mbOk],0);
  end;

  HideProcess(GetCUrrentProcessID);
end;

procedure TMainForm.cmdQuarClick(Sender: TObject);
var f : file;
    poss : integer;
    filenama : string;
    Loc      : String;
    LB       : Longbool;
    NamaFile : String;
    Rec      : TDataRecord;
    Quar     : string;
begin
  FileNama := ScanList.Selected.SubItems[1];
  NamaFile := ExtractFileName(FileNama);
  Quar     := ScanList.Selected.Caption;
  //MessageDLG(FileNama + Quar,mtInformation,[mbOK],0);
  if FileIsReadOnly(filenama) then
       FileSetReadOnly(Filenama,False);

  if MoveToQuarantine(FileNama,Quar) then
    Scanlist.Selected.ImageIndex := 4
  else
    ScanList.Selected.ImageIndex := 5;
  BuildQuarantineList(frmQuar.CarList);
end;

procedure TMainForm.Plugins1Click(Sender: TObject);
begin
  frmPlugin.ShowModal;
end;

procedure TMainForm.cmdRepairClick(Sender: TObject);
var I,poss : Integer;
    filenama : string;
    Dest     : String;
    tp       : TPoint;
    ofn   : String;
    FDEPR: IDEPatternRecognizer;
    pusat : string;
    suk,gag : integer;
    asli    : string;
    namafile:string;
begin
  suk := 0;
  gag := 0;
  i := 0;
  raono := false;
  Prog.progress := 0;
  prog.maxvalue := Scanlist.Items.Count;
  for i := 0 to ScanList.Items.Count-1 do
  begin
    pusat := Scanlist.Items.Item[i].Caption;
    if (Pusat <> '') and (ScanList.Items.Item[i].ImageIndex = 2) then
    begin
      filenama := ScanList.Items.Item[i].SubItems[1];
      namafile := extractfilename(filenama);
      asli     := Filenama;
      raono := true;

      prog.progress := i+1;
      If Pos('AMBURADUL',UpperCase(pusat)) <> 0 then
      begin
        FileNama := Copy(FileNama,0,Pos('`',FileNama)-1);
        if (FileSetAttr(FileNama,not faHidden) = 0) and DeleteFile(asli) then
        begin
          ScanList.Items.Item[i].ImageIndex := 6;
          suk := suk + 1;
          gagal := false;
        end
      else
          begin
         //   MessageDlg(asli,mtError,[MBOK],0);
            ScanList.Items.Item[i].ImageIndex := 8;
            gag := gag + 1;
            gagal := true;
          end;
       end
      else
      If (Pos('converted',Lowercase(pusat)) <> 0) or (Pos('zulanick.bmp',lowercase(pusat)) <> 0) then
      begin
        bm_dec.LoadFromFile(asli);
        //MessageDLG(IntToSTR(zulDecryptFile(ofn, m_strm_dec, bm_dec, randseed_init)),mtwarning,[mbok],0);
        if (zulDecryptFile(ofn, m_strm_dec, bm_dec, randseed_init) <> 0) then
        begin
          // MessageDLG(asli,mtwarning,[mbok],0);
          m_strm_dec.Position:= 0;
          m_strm_dec.SaveToFile(ExtractFilePath(Asli)+ofn);
          ScanList.Items.Item[i].ImageIndex := 6;
          suk := suk + 1;
          gagal := false;
          bm_dec.Free;
          DeleteFile(fileNama);
        end
      else
          begin
           // MessageDlg('Failed to repair this file'+#13+'Take the Delete button (Recommended)',mtError,[MBOK],0);
            ScanList.Items.Item[i].ImageIndex := 8;
            gag := gag + 1;
            gagal := true;
          end;
       end
    else
      if (Pos('fected.kspoold',lowercase(pusat)) <> 0) then
      begin
        FDEPR:= TKSpoolInfPattern.Create;
        FDEPR.EnumSamples(Listbox2.Items);
        Dest:= ChangeFileExt(asli, '.unk');
        if FDEPR.RestoreInfectedFile(asli, Dest) = S_OK then
        begin
          //MessageDLG(ExtractFilePath(asli)+ofn,mtwarning,[mbok],0);
          ScanList.Items.Item[i].ImageIndex := 6;
          suk := suk + 1;
          FDEPR := nil;
          DeleteFile(Asli);
          gagal := false;
        end
      else
          begin
           // MessageDlg('Failed to repair this file'+#13+'Take the Delete button (Recommended)',mtError,[MBOK],0);
            ScanList.Items.Item[i].ImageIndex := 8;
            gag := gag + 1;
            FDEPR := nil;
            gagal := true;
          end;
       end
    else
      begin
        ScanList.Items.Item[i].ImageIndex := 8;
        gag := gag + 1;
        gagal := true;
        if ((raono) and (prog.progress = prog.maxvalue)) or (pateniuser) then
        begin
          //if MessageDlg('Files cannot be repaired, please submit the file into xtfcomp@gmail.com. Do you want to delete the files?',mtWarning,[mbYes,mbNo],0) = mrYes then
          if chkSWC.Checked then
            cmdQuarAll.Click;
        end;
      end;
    end;
  end;

  if (gag <> 0) or (pateniuser) then
    begin
      if chkSWC.Checked then
        cmdQuarAll.Click;

      //if MessageDlg('Some file cannot be repaired, please submit the file into xtfcomp@gmail.com. Do you want to delete the files?',mtWarning,[mbYes,mbNo],0) = mrYes then
      if RepairMsg.ShowModal = RepairMsg.Button1ModalResult then
       begin
        MainForm.cmddelall.click;
      end;
    end;


  MessageDlg(IntToStr(suk)+' files repaired successfully '+#13+IntToStr(gag)+' failed to repair.',mtInformation,[mbOk],0);
end;

procedure TMainForm.QuarantineRoomClick(Sender: TObject);
begin
  frmQuar.showmodal;
end;

procedure TMainForm.shcChange;
begin
  MessageDlg('Attention, SigmaAV detected a program that try to change the Security of WINDOWS system!'+#13+
             'Sorry, but the module is not implemented to detect the suspected program is, use the Process Killer to kill a courius task name.',mtWarning,[mbOk],0);
end;

procedure TMainForm.suitempScanListCustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
  SetBkMode(Canvas.Handle,TRANSPARENT);
  Perform(LVM_SETTEXTBKCOLOR,0,LongInt(CLR_NONE));
  ListView_SetBKColor(Handle,CLR_NONE);
end;

procedure TMainForm.PathListCustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
    SetBkMode(Canvas.Handle,TRANSPARENT);
    Perform(LVM_SETTEXTBKCOLOR,0,LongInt(CLR_NONE));
    ListView_SetBKColor(Handle,CLR_NONE);
end;

procedure TMainForm.PortInformation1Click(Sender: TObject);
begin
  frmPort.showmodal;
end;

procedure TMainForm.CMD1Click(Sender: TObject);
begin
  frmCMD.ShowModal;
end;

procedure TMainForm.ScanFile1Click(Sender: TObject);
begin
  if not inscan then
    frmScanFile.showmodal;
end;

procedure TMainForm.cmdQuarAllClick(Sender: TObject);
var I,poss    : Integer;
    filenama  : string;
    tp        : TPoint;
    pusat,asli: string;
    suk,gag   : integer;
    namafile  :string;
    Quar      : string;
begin
  suk := 0;
  gag := 0;
  prog.progress := 0;
  prog.maxvalue := ScanList.Items.Count;
  for I := 0 to ScanList.Items.Count-1 do
  begin
    try
      pusat := Scanlist.Items.Item[i].SubItems[1];
      Quar  := Scanlist.Items.Item[i].Caption;
    except
      pusat := '';
    end;
    filenama := pusat;
    if (pusat <> '') and ((ScanList.Items.Item[i].ImageIndex = 2) or (Scanlist.Items.Item[i].ImageIndex = 8) or (Scanlist.Items.Item[i].ImageIndex = 11)) then
    begin
      if FileIsReadOnly(filenama) then
        FileSetReadOnly(Filenama,False);
      KillTask(NamaFile);

      if MoveToQuarantine(FileNama, Quar) then
      begin
        suk := suk + 1;
        ScanList.Items.Item[i].ImageIndex := 4;
      end
    else
      begin
        gag := gag + 1;
        ScanList.Items.Item[i].ImageIndex := 5;
      end;
      prog.progress := i+1;
    end;
  end;
  MessageDlg(IntToStr(suk)+' files moved and '+IntToStr(gag)+' failed to move.',mtInformation,[mbOk],0);
  BuildQuarantineList(frmQuar.CarList);
end;

procedure TMainForm.avirusClick(Sender: TObject);
begin
  if avirus.Checked then
  begin
    ScanList.Selected.ImageIndex := 7;
    Avirus.Checked := False;
  end
 else
  begin
    Scanlist.Selected.ImageIndex := 2;
    AVirus.Checked := true;
  end;
  MainForm.ScanList.OnClick(Sender);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var time : tdatetime;
    sijiwae : integer;
begin
  inc(dtk);
  if dtk > 59 then
    begin
      inc(Mnt);
      dtk := 0;
    end;
  if mnt > 59 then
    begin
      inc(jam);
      mnt := 0;
    end;

  inc(sijiwae);
  lbljm.Caption := 'Elapsed Time : '+IntToStr(jam)+':'+IntTostr(mnt)+':'+IntToStr(dtk);

end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  ListBox1.Clear;
  RunningProcessesList(ListBox1.Items, True);
end;


procedure TMainForm.Alwaysontop1Click(Sender: TObject);
begin
  if Alwaysontop1.Checked then
  begin
    Alwaysontop1.Checked := false;
    SetWindowPos(Handle,HWND_NoTOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE)
  end
  else
  begin
    SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
    alwaysontop1.Checked := true;
  end;
end;

procedure TMainForm.suiForm1TitleBarCustomBtnsClick(Sender: TObject;
  ButtonIndex: Integer);
begin
  Application.Minimize;      // Will hide dialogs and popup windows as well (this demo has none)
  TrayIcon.HideMainForm;
end;

procedure TMainForm.OpenSigmaAV1Click(Sender: TObject);
begin
  TrayIcon.ShowMainForm;
end;

procedure TMainForm.ShellNotify1Notify(Sender: TObject;
  Event: TShellNotifyEvent; Path1, Path2: String);
var virus : string;
begin
  Case Event of
    neDriveAdd :
       begin
      //  SuspendProcess('explorer.exe');
        if fileexists(Path1+'autorun.inf') then
          if ScanFileBiasa(Path1+'autorun.inf') <> 'NONE' then
          begin
            if DeleteFile(Path1+'autorun.inf') then
            begin
        //      ResumeProcess('explorer.exe');
              trayicon.ShowBalloonHint('SigmaAV - '+Getversion,'Sigma has detected a virus autorun and successfully deleted.',bitinfo, 10);
           end
          else
            begin
          //    ResumeProcess('explorer.exe');
              trayicon.ShowBalloonHint('SigmaAV - '+Getversion,'Sigma has detected a virus autorun and failed to deleted.',biterror, 10);
              RenameFile('autorun.inf','autorun.vir');
            end;
          end;

        //ResumeProcess('explorer.exe');

        If Not inscan then
        begin
          if TrayIcon.ShowBalloonHint('SigmaAV - '+GetVersion,'New removable drive inserted, click here to scan this drive.',bitinfo,10) then
          Diklik := True;
          dbaru := path1;
        end;
        CreateDrivesList(PathList);
      end;

    neCreate : begin
                 virus := ScanFileBiasa(Path);
                 if virus <> 'NONE' then
                 begin
                   VirMsg.Text := 'Virus Found : '+virus+' what would you want to do?';
                   if VirMsg.ShowModal = VirMsg.Button2ModalResult then
                     DeleteFile(Path);
                   if VirMsg.ShowModal = VirMsg.Button3ModalResult then
                     MoveToQuarantine(Path,Virus);
                 end;
               end;

 end;
end;


procedure TMainForm.RxFolderMonitor1Change(Sender: TObject);
begin
  showmessage('Last access');
end;

procedure lanjut;
begin
  application.ProcessMessages;
end;

procedure TMainForm.Exit2Click(Sender: TObject);
begin
  close;
end;

procedure TMainForm.RTPTimer(Sender: TObject);
var
  i1, i2: Integer;
  s: string;

  HandleMAP,  // for win9X
  HandleCB,  // handle combobox
  HandleLV  :THandle;  // handle listview
  ProcessLV :Cardinal; // handle explorer process
  DatasLV   :PDatas;   // pointer to our info of...
  Datas     :TDatas;   // the item-captions itself
  ProcessID,
  N         : Cardinal;
  nama      : string;

  WindowsNT      :Boolean;  // win9X?
  VirtualAllocEx :TVirtualAllocEx;
  VirtualFreeEx  :TVirtualFreeEx;

begin
  if not inscan then
  begin
  HandleCB:= FindWindowEx(GetForeGroundWindow, 0, 'WorkerW'         , nil);
  if HandleCB= 0 then begin
    HandleLV:= FindWindowEx(0       , 0, 'ExploreWClass'   , Nil);
    HandleCB:= FindWindowEx(HandleLV, 0, 'WorkerW'         , nil);
  end else HandleLV:= GetForeGroundWindow;

  HandleCB:= FindWindowEx(HandleCB, 0, 'ReBarWindow32'   , nil);
  HandleCB:= FindWindowEx(HandleCB, 0, 'ComboBoxEx32'    , nil);  // we got the combobox
  if (HandleCB <> 0) then
  begin
    setlength(s, 300);  // reserve some space
    i1:= SendMessage(HandleCB, WM_GETTEXT, 300, longint(@s[1]));  // get combobox content
    setlength(s, i1);  // set string to the length we actually got
    if s[length(s)]<> '\' then
    s:= s+ '\';
    //showmessage(S);
    if (pisanwae <> s) then
    begin
      RTP.Enabled := False;
      if DirectoryExists(S) then
      begin
     //   Label1.Caption := 'Scanning : '+S;
        nama := RTPSCAN(s);
      end
     else
        nama := 'NONE';
      //ShowMessage(Nama);
      if nama <> 'NONE' then
      begin
        trayicon.ShowBalloonHint('SigmaAV - Real Time Protection','File name : '+S+#13+'Virus found : '+RTPResult,bitinfo, 10);
        pisanwae := S;
        sigma.Suspend;
      end
     else
      begin
        pisanwae := s;
        RTP.Enabled := true;
        exit;
      end;
       pisanwae := s;
       RTP.Enabled := true;
     end
  end;
  end;
end;

procedure TMainForm.Update2Click(Sender: TObject);
begin
  frmUpdate.Showmodal;
end;

procedure TMainForm.suiURLLabel1Click(Sender: TObject);
begin
  Skipfile := true;
end;

procedure TMainForm.Label1Click(Sender: TObject);
begin
  SkipFile := true;
end;

procedure TMainForm.chkSWCClick(Sender: TObject);
begin
  if chkSWC.Checked then
    MessageDlg('When scan is finished, it will automatically repair all detected files, if file cannot be repaired, it will be automatically move into Quarantine room.',mtInformation,[mbOK],0);
end;

procedure TMainForm.trayiconDblClick(Sender: TObject);
begin
  TrayIcon.ShowMainForm;
end;

procedure TMainForm.logoClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.UnivrsalNotify(Sender: TObject;
  Event: TShellNotifyEvent; Path1, Path2: String);
var virus : string;
begin
  case Event of
   neCreate : begin
                 IF (not inscan) and (path1 <> '') then
                 begin
                   virus := ScanFileBiasa(Path1);
                   if virus <> 'NONE' then
                   begin
                     frmVFound.lblNama.Caption := virus;
                     frmVFound.lbllokasi.Text := Path1;
                     frmVFound.Show;
                   end;
                 end;
                end;
   neRenameItem : begin
                    if (not inscan) and (path2 <> '') then
                    begin
                      virus := ScanFileBiasa(Path2);
                      if virus <> 'NONE' then
                      begin
                        frmVFound.lblNama.Caption := virus;
                        frmVFound.lbllokasi.Text := Path2;
                        frmVFound.Show;
                      end;
                    end;
                  end;
   neUpdateItem : begin
                    if (not inscan) and (path1 <> '') then
                    begin
                      virus := ScanFileBiasa(Path1);
                      if virus <> 'NONE' then
                      begin
                        frmVFound.lblNama.Caption := virus;
                        frmVFound.lbllokasi.Text := Path2;
                        frmVFound.Show;
                      end;
                    end;
                  end;
  end;
end;

procedure TMainForm.ProsesTimer(Sender: TObject);
var ExeName : String;
    uwis : boolean;
begin
  TmpProcess.Clear;//Clear ListBox
  proc.dwSize := SizeOf(Proc);//Give proc.dwSize the Size of bytes of PROCESSENTRY32
  hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPALL,0); // I got all this stuff comments on the kill process part no need to repeat eheh
  Looper := Process32First(hSnap,proc);
  while Integer(Looper) <> 0 do
  begin
  ExeName := ExtractFileName(proc.szExeFile);
  TmpProcess.Add(ExeName);
  Looper := Process32Next(hSnap,proc);
  end;
  CloseHandle(hSnap);

  if (TmpProcess.Count > ProsesList.Count) and (ProsesList.Items.Text <> TmpProcess.Text) then
  begin

    if (not uwis) then
    begin
      ShowMessage('Anyar '+PRocessFileName(GetProcessPID(ExeNAme)));
      Uwis := True;
    end;

  ProseSList.Items.Text := TmpProcess.Text;

  SendMessage(ProsesList.Handle, WM_VSCROLL, SB_BOTTOM, 0);

  end
else
  Uwis := False;
end;

procedure TMainForm.cmdRefreshClick(Sender: TObject);
var ExeName : String;
begin

ProsesList.Clear;//Clear ListBox
proc.dwSize := SizeOf(Proc);//Give proc.dwSize the Size of bytes of PROCESSENTRY32
hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPALL,0); // I got all this stuff comments on the kill process part no need to repeat eheh
Looper := Process32First(hSnap,proc);
while Integer(Looper) <> 0 do
begin
ExeName := ExtractFileName(proc.szExeFile);
ProsesList.Items.Add(ExeName);
Looper := Process32Next(hSnap,proc);
end;
CloseHandle(hSnap);
end;

function RenamewithCMD(Direktori, Asal, Tujuan : string) : string;
// Exclusive F_Computer
// Rename file use the Command Prompt command.
var
  Output, Errors: TStringList;
begin
  Output := TStringList.Create;
  Errors := TStringList.Create;
  SetCurrentDir(Direktori);

  if GetConsoleOutput('CMD /C'+' ren "'+asal+'" "'+tujuan+'"', Output, Errors) then
  begin
    Result := Errors.Text;
  end;

  //ShowMessage(Result);
  SetCurrentDir(ExtractFilePath(paramstr(0)));

  Errors.Destroy;
  Output.Destroy;
end;

function GetShortName (const FileName: string): string;
var aTmp: array[0..255] of char;
begin
  if not FileExists (FileName) then
    Result := ''
  else if GetShortPathName (PChar (FileName), aTmp, Sizeof (aTmp) - 1) = 0
  then
    Result:= FileName
  else
    Result:= StrPas (aTmp);
end;

procedure TMainForm.trayiconStartup(Sender: TObject;
  var ShowMainForm: Boolean);
begin
  if ParamStr(1) = '/hid' then
  begin
    ShowMainform := False;
  end;
end;

procedure TMainForm.trayiconBalloonHintClick(Sender: TObject);
begin
   if DiKlik then
   begin
     Sigma := TAvScanner.Create(True);
     Sigma.NeedForAPI := true;
     Sigma.AvAction := TScanDir;
     memory := false;
     Sigma.DirName := dbaru;
     OnScanStart;
   end;
end;

procedure TMainForm.fastscanTimer(Sender: TObject);
begin
  SkipFile:=true;
end;

procedure TMainForm.suiButton1Click(Sender: TObject);
begin
  RenameWithCMD('D:\Antivir\Other\15 September 2009\','New F?lder.exe','data');
end;

procedure TMainForm.RunTimeProtection1Click(Sender: TObject);
begin
//  Univrsal.Active := RunTimeProtection1.Checked;
  RuntimeProtection1.Checked := not Runtimeprotection1.Checked;
end;

procedure TMainForm.tmrMarqueTimer(Sender: TObject);
begin
 { Prog.Position := 0;
  SetWindowLong(Prog.Handle, GWL_STYLE,
    GetWindowLong(Prog.Handle, GWL_STYLE) or PBS_MARQUEE);
}end;

procedure TMainForm.suiImagePanel1Click(Sender: TObject);
begin
  ShowMessage('Special Thanks for U, Nduud :)');
end;

function TMainForm.NgetungFileProcessCallback(Sender: TObject;
  FileName: String; Progress: Int64; var Abort: Boolean): Boolean;
begin
  //SetWindowLong(Prog.Handle, GWL_STYLE,
    //GetWindowLong(Prog.Handle, GWL_STYLE));
  Application.ProcessMessages;
  Abort := FCancel;
end;

function TMainForm.NgetungFileCountProgressCallback(Sender: TObject;
  Progress: Int64; var Abort: Boolean): Boolean;
begin
  prog.maxvalue := Progress;
  Application.ProcessMessages;
  Abort := FCancel;
end;

procedure TMainForm.Shutdown1Click(Sender: TObject);
begin
  InitiateSystemShutdown(Pchar(0),Pchar(0),0,True,True);
end;

procedure TMainForm.Button4Click(Sender: TObject);
begin
  ShowMessage(IntToStr(Mainform.Handle));
end;

end.
