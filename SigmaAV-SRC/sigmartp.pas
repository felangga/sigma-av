unit sigmartp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Menus, ImgList, XPMan, avKernel, avTypes, ShellAPI, ShlObj;

type
  Tmain = class(TForm)
    TopPanel: TPanel;
    LogoImage: TImage;
    BackImage: TImage;
    NameLabel1: TLabel;
    NameLabel2: TLabel;
    NameLabel3: TLabel;
    CopyRightLabel: TLabel;
    VersionLabel: TLabel;
    Bevel: TBevel;
    MainPages: TPageControl;
    ScanPathesTab: TTabSheet;
    ScanningTab: TTabSheet;
    ReportTab: TTabSheet;
    BottomPanel: TPanel;
    ScanBTN: TButton;
    SaveBTN: TButton;
    ExitBTN: TButton;
    PathList: TListView;
    ScanFile: TLabel;
    Bevel1: TBevel;
    ScanList: TListView;
    ReportMemo: TMemo;
    ImageList: TImageList;
    DrivesImg: TImageList;
    PathMenu: TPopupMenu;
    Addfolder1: TMenuItem;
    Delete1: TMenuItem;
    N1: TMenuItem;
    Reftesh1: TMenuItem;
    SaveDialog: TSaveDialog;
    ToolsPanel: TPanel;
    BackImage1: TImage;
    ScanShowBTN: TLabel;
    ReportShowBTN: TLabel;
    OptionsShowBTN: TLabel;
    HelpBTN: TLabel;
    AboutBTN: TLabel;
    Bevel2: TBevel;
    XPManifest: TXPManifest;
    Bevel4: TBevel;
    DelMenu: TPopupMenu;
    Del: TMenuItem;
    procedure ExitBTNClick(Sender: TObject);
    procedure ScanListDblClick(Sender: TObject);
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
    function CreateDrivesList(ListView: TListView): boolean;
    procedure AboutBTNClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HelpBTNClick(Sender: TObject);
    procedure DelMenuPopup(Sender: TObject);
    procedure DelClick(Sender: TObject);
  private
    { Private declarations }
  public
    FileCN        : Integer;
    FileInfected  : Integer;
    FileIgnored   : Integer;
    Path          : String;
    { Public declarations }
  end;

Const
        SigmaVS    = 'v0.2'; 

        AiDInit         = 'Инициализация сканера...';
        LoadAPI         = ' Загрузка API модулей.';
        LoadDB          = ' Загрузка базы данных.';
        CreateDrvList   = ' Создание списка устройств.';
        OptFileNotFnd   = ' Файл конфигураци не наиден!';
        LoadOptFile     = ' Загрузка файла конфигурации.';
        InitProcedures  = ' Инициализация процедур сканирования.';
        ErrorInit       = 'При инициализации сканера произошла ошибка!';

        LogBevel        = '===============================================================================';

        DBKnowledge     = 'Размер базы данных: ';
        SCNOBJ          = 'Объект сканирования: ';
        ScanExecute     = 'Сканирование запущено';
        ScanEnd         = 'Сканирование завершено';
        FileIgnor       = 'Файлов пропущено: ';
        FileIfect       = 'Файлов заражено: ';
        FileScanned     = 'Файлов проверено: ';
        IGNORED         = 'Пропущен';
        INFECTED        = 'Заражен';
        STOPB           = 'Остановить';
        RETURNB         = 'Назад';
        SCANB           = 'Сканировать';
        SCNFILE         = ' >> Проверка файла >> ';
        FileDel         = ' Удален пользователем >> ';
        FileNotDel      = ' Ошибка при удалении >>';
        PATHNOSEL       = 'Область сканирования не выбранна, '+#13+'или указанного пути не существует!';

        SysMenu         = 'Сканировать в AiD Scanner...';

        NfoSigma   = ' Версия AiD Scanner: ';
        NfoAiDKernel    = ' Версия ядра AiD: ';
        NfoAiDBuild     = ' Версия сборки: ';

        DelDialog       = 'Вы уверены что хотите удалить этот файл?';
        DelError        = 'Произошла ошибка при удалении файла! Возможно файл занят другим процессом или программой.';
        HelpNOFound     = 'Файл помощи не наиден!';


var
  main: Tmain;
  inScan : Boolean = False;
  NeedToReturn : Boolean = False;
implementation

uses uSelInfo, uOptions, uAddPath, AboutFrm, Math;

{$R *.dfm}
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

        if GETParamName(List[i]) = 'EXT' then begin
        with OptionsForm.ExtList.Items.Add do begin
                Caption := GetParam(List[i]);
                ImageIndex := 3;
        end;
        end;
        if GETParamName(List[i]) = 'PATH' then begin
        with OptionsForm.PathList.Items.Add do begin
                Caption := GetParam(List[i]);
                if DirectoryExists(Caption) then ImageIndex := 4 else ImageIndex := 5;
        end;
        end;

        if GETParamName(List[i]) = 'AUTOSAVEREPORT' then
        if GetParam(List[i]) = 'ON' then OptionsForm.AutoSaveReport.Checked := true else
        OptionsForm.AutoSaveReport.Checked := False;

        if GETParamName(List[i]) = 'DISPLAYSCANFILES' then
        if GetParam(List[i]) = 'ON' then OptionsForm.DisplayScnFiles.Checked := true else
        OptionsForm.DisplayScnFiles.Checked := False;

        if GETParamName(List[i]) = 'REGISTERSYSMENU' then
        if GetParam(List[i]) = 'ON' then OptionsForm.RegisterSysMenu.Checked := true else
        OptionsForm.RegisterSysMenu.Checked := False;

        if GETParamName(List[i]) = 'AUTOSAVEREPORTTO' then OptionsForm.ReportSavePath.Text := GETParam(List[i]);
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

function Tmain.CreateDrivesList(ListView: TListView): boolean;
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
      Caption := FormatDateTime('[hh:mm:ss]',now) + '  ' + LogString;
      MainForm.ReportMemo.Lines.Add(Caption);
      {}
      if ID = 2 then begin    // ID 2 Infected!!! Extract path...
        TMP := LogString;
        system.Delete(Tmp,1,pos(']',Tmp)+1);
        SubItems.Add(TMP);
      end;
      {}
      ImageIndex := ID;
    end;
    ImageIndex := ID;
  end;
end;

Procedure OnScanStart;
var
i: integer;
begin
ClearExtList;

for i := 0 to OptionsForm.ExtList.Items.Count-1 do begin
AddToExtList(ExtractFileExt(OptionsForm.ExtList.Items.Item[i].Caption));
end;

MainForm.ScanBTN.Caption := STOPB;
MainForm.SaveBTN.Enabled := False;

MainForm.ScanList.Clear;
MainForm.ScanningTab.Show;

MainForm.FileCN       := 0;
MainForm.FileInfected := 0;
MainForm.FileIgnored  := 0;

inScan := True;
NeedToReturn := False;

OnAddToLogStr(ScanExecute,0);

if Sigma.AvAction = TScanDir then
OnAddToLogStr(SCNOBJ+Sigma.DirName,0) else
OnAddToLogStr(SCNOBJ+Sigma.FileName,0);

OnAddToLogStr('',-1);

Sigma.Resume;
end;

procedure OnProgress(FileScan: String; MessageInd: integer);
begin
  MainForm.FileCN := MainForm.FileCN + 1;
  MainForm.ScanFile.caption  := ExtractFileName(FileScan);

  if OptionsForm.DisplayScnFiles.Checked then MainForm.ReportMemo.Lines.Add(SCNFILE + FileScan);
end;

procedure OnReadError(FileName: String; MessageInd: integer);
begin
  OnAddToLogStr('['+IGNORED+'] '+FileName,1);
  MainForm.FileIgnored  := MainForm.FileIgnored + 1;
end;

procedure OnVirDetected(FileName,VirName: String);
begin
  OnAddToLogStr('['+INFECTED+' - '+VirName+' ] '+FileName,2);
  MainForm.FileInfected := MainForm.FileInfected + 1;
end;

procedure OnScanComplete;
begin
  MainForm.ScanBTN.Caption := RETURNB;
  NeedToReturn := True;
  inScan := False;
  MainForm.Path := '';
  MessageBeep(MB_ICONASTERISK);
  MainForm.SaveBTN.Enabled := true;
  MainForm.ScanFile.caption  := ScanEnd;
  OnAddToLogStr('',-1);
  OnAddToLogStr(ScanEnd,0);
  OnAddToLogStr('',-1);
  OnAddToLogStr(FileScanned+inttostr(MainForm.FileCN),0);
  OnAddToLogStr(FileIgnor+inttostr(MainForm.FileIgnored),0);
  OnAddToLogStr(FileIfect+inttostr(MainForm.FileInfected),0);
  MainForm.ReportMemo.Lines.Add(LogBevel);

  if OptionsForm.AutoSaveReport.Checked then begin
    MainForm.ReportMemo.Lines.SaveToFile(OptionsForm.ReportSavePath.Text);
  end;
end;

procedure OnWarningHeur(FileName: String; Message:String);
begin
end;

procedure Tmain.InitScannerKernel;
var
i:integer;
begin
try
  if FileExists(OptionsForm.ReportSavePath.Text) then
  ReportMemo.Lines.LoadFromFile(OptionsForm.ReportSavePath.Text);

  ReportMemo.Lines.Add(LogBevel);
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+' '+AiDInit);{}

  InitExtList;
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+InitProcedures);
  InitAvProc(OnProgress,OnVirDetected,OnWarningHeur,OnReadError,OnScanComplete,OnAddToLogStr,OnScanStart);
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+LoadOptFile);
  if FileExists(ExtractFilePath(paramstr(0))+'Options.ini') then
    LoadOptions(ExtractFilePath(paramstr(0))+'Options.ini')
  else begin
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+OptFileNotFnd);
  OptionsForm.SaveOptions(ExtractFilePath(paramstr(0))+'Options.ini');
  end;
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+CreateDrvList);
  CreateDrivesList(PathList);
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+LoadDB);
  LoadDataBases(ExtractFilePath(paramstr(0))+'DataBases\');
  Sigma := TAvScanner.Create(True);
  InitApi;
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+LoadAPI);
  LoadApiPlugins(ExtractFilePath(paramstr(0))+'ModulesAPI\');
{Get API}
for i := 0 to GetPluginAPICount do
with OptionsForm.APIList.Items.Add do begin
  Caption := GetPluginAPIName(i) + ' ('+ExtractFileName(GetPluginAPIPath(i))+')';
  SubItems.Add(GetPluginAPIAutor(i));
  SubItems.Add(GetPluginAPIInfo(i));
  SubItems.Add(GetPluginAPIPath(i));
end;

except
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+' '+ErrorInit);
end;
{}
  ReportMemo.Lines.Add('');
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+ NfoSigma +SigmaVS);
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+ NfoAiDKernel +GetKernelVersion);
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+ NfoAiDBuild +GetKernelBuild);
  ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+' '+DBKnowledge+IntToStr(GetDBRecCount));
{}
  ReportMemo.Lines.Add(LogBevel);
  ReportMemo.Lines.Add('');
{}
if OptionsForm.RegisterSysMenu.Checked then begin
  OptionsForm.FileTAddAction('*','AiD.Scan',SysMenu,ParamStr(0)+' %1');
  OptionsForm.FileTAddAction('Directory','AiD.Scan',SysMenu,ParamStr(0)+' %1');
  OptionsForm.FileTAddAction('Drive','AiD.Scan',SysMenu,ParamStr(0)+' %1');
end else begin
  OptionsForm.FileTDelAction('Drive','AiD.Scan');
  OptionsForm.FileTDelAction('Directory','AiD.Scan');
  OptionsForm.FileTDelAction('*','AiD.Scan');
end;
end;
{}

Procedure Tmain.StartScan(Parametr: String);
begin
  if DirectoryExists(Parametr+'\') then begin
  Sigma.NeedForAPI := false;
  Sigma.AvAction := TScanDir;
  Sigma.DirName := Parametr+'\';
  OnScanStart;
  end;
  if FileExists(Parametr) then begin
  Sigma.NeedForAPI := false;
  Sigma.AvAction := TScanFile;
  Sigma.FileName := Parametr;
  OnScanStart;
  end;

  if Parametr = 'DRV' then begin
  Sigma.NeedForAPI := false;
  Sigma.AvAction := TScanDir;
  Sigma.DirName := ExtractFileDrive(ParamStr(0))+'\';
  OnScanStart;
  end;

end;

procedure Tmain.ExitBTNClick(Sender: TObject);
begin
Close;
end;

procedure Tmain.ScanListDblClick(Sender: TObject);
begin
if ScanList.ItemIndex <> -1 then begin
        InformationForm.InfoMemo.Text := ScanList.Selected.Caption;
        InformationForm.ShowModal;
end;
end;

procedure Tmain.ScanBTNClick(Sender: TObject);
begin
if PathList.ItemIndex <> -1 then
Path := PathList.Selected.Caption;

if NeedToReturn = false then begin
if inScan = False then begin
        if (PATH <> '') and (DirectoryExists(Path)) then begin
        Sigma := TAvScanner.Create(True);
        Sigma.NeedForAPI := true;
        Sigma.AvAction := TScanDir;
        Sigma.DirName := Path;
        OnScanStart;
        end else begin
        MessageDlg(PATHNOSEL,mtError,[mbOk],0);
        end;
end else begin
        Sigma.Suspend;
        OnScanComplete;
end;
end else begin
        ScanBTN.Caption := ScanB;
        MainForm.SaveBTN.Enabled := False;
        NeedToReturn := False;
        ScanPathesTab.Show;
end;
end;

procedure Tmain.ScanShowBTNClick(Sender: TObject);
begin
if not inScan then
ScanPathesTab.Show;
end;

procedure Tmain.ReportShowBTNClick(Sender: TObject);
begin
if not inScan then
ReportTab.Show;
end;

procedure Tmain.SaveBTNClick(Sender: TObject);
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

procedure Tmain.Delete1Click(Sender: TObject);
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

procedure Tmain.Reftesh1Click(Sender: TObject);
begin
CreateDrivesList(PathList);
end;

procedure Tmain.OptionsShowBTNClick(Sender: TObject);
begin
if not inScan then begin
LoadOptions(ExtractFilePath(paramstr(0))+'Options.ini');
OptionsForm.ShowModal;
end;
end;

procedure Tmain.Addfolder1Click(Sender: TObject);
begin
AddUserPathForm.ShowModal;
end;

procedure Tmain.AboutBTNClick(Sender: TObject);
begin
AboutForm.Memo3.Clear;
AboutForm.Label1.Caption := SigmaVS;
AboutForm.Memo3.Lines.Add(NfoSigma+SigmaVS);
AboutForm.Memo3.Lines.Add(NfoAiDKernel+GetKernelVersion);
AboutForm.Memo3.Lines.Add(NfoAiDBuild+GetKernelBuild);
AboutForm.Memo3.Lines.Add(' '+DBKnowledge+IntToStr(GetDBRecCount));
AboutForm.ShowModal;
end;

procedure Tmain.FormShow(Sender: TObject);
begin
VersionLabel.Caption := SigmaVS;
end;

procedure Tmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if OptionsForm.AutoSaveReport.Checked then begin
    MainForm.ReportMemo.Lines.SaveToFile(OptionsForm.ReportSavePath.Text);
  end;
end;

procedure Tmain.HelpBTNClick(Sender: TObject);
begin
if FileExists(ExtractFilePath(paramstr(0))+'\Help.htm') then
ShellExecute(0,'',PChar(ExtractFilePath(paramstr(0))+'\Help.htm'),nil,nil,1)
else MessageDlg(HelpNOFound,mtError,[mbOk],0);
end;

procedure Tmain.DelMenuPopup(Sender: TObject);
begin
if (ScanList.ItemIndex <> -1) and (ScanList.Selected.ImageIndex = 2) and (inScan = False) then
begin
 Del.Visible := true;
end else Del.Visible := False;
end;

procedure Tmain.DelClick(Sender: TObject);
begin
if MessageDlg(DelDialog,mtInformation,[mbCancel]+[mbYes],0) = 6 then begin
try
  if DeleteFile(ScanList.Selected.SubItems[0]) then begin
     ScanList.Selected.ImageIndex := 4;
     ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+FileDel+ScanList.Selected.SubItems[0]);
  end
  else begin
     ReportMemo.Lines.Add(FormatDateTime('[hh:mm:ss]',now)+FileNotDel+ScanList.Selected.SubItems[0]);
     MessageDlg(DelError,mtWarning,[mbOk],0);
  end;

except
end;
end;
end;

end.
