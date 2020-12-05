unit update;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SUIProgressBar, SUIMgr, ExtCtrls, SUIForm, IniFiles, URLMon,
  SUIButton, ComCtrls;

type
  TfrmUpdate = class(TForm)
    suiForm1: TsuiForm;
    suiThemeManager1: TsuiThemeManager;
    Label1: TLabel;
    Label2: TLabel;
    status: TLabel;
    DownloadNewVersion1: TsuiButton;
    proses: TProgressBar;
    Image1: TImage;
     procedure DownLoadNewVersion1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
    winsc: TiniFile;
    old: Integer;
    vernfo: TIniFile;
  public
    { Public declarations }
  end;

var
  frmUpdate: TfrmUpdate;

implementation

{$R *.dfm}
Uses Umain;
function DownloadFile(Source, Dest: string): Boolean;
  { Function for Downloading the file found on the net }
begin
  try
    Result := UrlDownloadToFile(nil, PChar(Source), PChar(Dest), 0, nil) = 0;
  except
    Result := False;
  end;
end;

function GetPathPath: string;
  { Retrive app path }
begin
  Result := ExtractFilePath(Application.ExeName);
end;

procedure TfrmUpdate.DownLoadNewVersion1Click(Sender: TObject);
var
  apath: string;
  new: Integer;
begin
  downloadnewversion1.Enabled := False;
  apath           := GetPathPath;
  Proses.position := 0;
  //Proses.position := 20;
  Status.Caption  := 'Connecting to server...';
  if DownloadFile('http://h1.ripway.com/fcomputer/update.ini', PChar(apath) + '/update.tmp') then
  begin
    Proses.position := 50;
    Status.Caption := 'Checking for newer versions...';
    vernfo := TiniFile.Create(GetPathPath + '/update.tmp');
    new    := vernfo.ReadInteger('SIGMA', 'Version', 123);

    vernfo.Free;
    if (old >= new) then
    begin
      Status.Caption  := ' No new version detected';
      Proses.position := 100;
      downloadnewversion1.Enabled := True;
    end
  else
    if DownloadFile('http://h1.ripway.com/fcomputer/virdb.av',PCHAR(ExtractFilePath(Application.ExeName)) + 'Databases\virdb.av') then
    begin
      downloadnewversion1.Enabled := true;
      Status.Caption  := 'Update succeseful. Please restart the program.';
      Proses.position := 100;
      winsc           := TIniFile.Create(GetPathPath + '/update.ini');
      winsc.WriteInteger('Sigma', 'version', new);
      winsc.Free;
    end
    else
      MessageDlg('Failed to download database, please wait a minute and try again.',mtError, [mbOK], 0);
  end
  else
  begin
    Status.Caption  := 'Failed to connect to server.';
    Proses.position := 0;
    DownloadNewVersion1.Enabled := true;
  end;
  DeleteFile('Update.tmp');
end;

procedure TfrmUpdate.FormCreate(Sender: TObject);
begin
//App version
  winsc := TIniFile.Create (GetPathPath + '/update.ini');
  if not Winsc.SectionExists('SIGMA') then
    ShowMessage('Not valid update information file');
  try
    old :=winsc.ReadInteger('SIGMA', 'Version', 123);
  finally
    winsc.Free;
  end;
end;

end.
