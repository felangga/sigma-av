unit VVirus;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, SUIButton, StdCtrls, SUIEdit, SUIForm, BlackList,
  SUIMgr;

type
  TfrmVirus = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    txtvirusname: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    suiForm1: TsuiForm;
    txtviruslocation: TsuiEdit;
    cmdSkip: TsuiButton;
    cmdDelete: TsuiButton;
    cmdrepair: TsuiButton;
    cmdQuar: TsuiButton;
    Bevel4: TBevel;
    suiButton1: TsuiButton;
    Label3: TLabel;
    suiThemeManager1: TsuiThemeManager;
    procedure suitempcmdSkipClick(Sender: TObject);
    procedure suitempcmdDeleteClick(Sender: TObject);
    procedure suitempcmdQuarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure suiButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVirus: TfrmVirus;

implementation

uses avScanner, avKernel, avTypes, main;

{$R *.dfm}

procedure TfrmVirus.suitempcmdSkipClick(Sender: TObject);
begin
  Jawaban := True;
  Close;
end;

procedure TfrmVirus.suitempcmdDeleteClick(Sender: TObject);
begin
  Jawaban := false;
  if FileIsReadOnly(txtviruslocation.Text) then
       FileSetReadOnly(txtviruslocation.Text,false);
  if not DeleteFile(txtviruslocation.text) then
  begin
    MessageDlg('Failed to delete this virus, may be locked or still active in memory.',mtError,[mbOK],0);
  end;
  close;
end;

procedure TfrmVirus.suitempcmdQuarClick(Sender: TObject);
begin
  Jawaban := False;
  if not MoveToQuarantine(txtviruslocation.Text, txtvirusname.Caption) then
    MessageDlg('Failed to move this virus into the Quarantine room, access denied!',mtError,[mbOK],0);
  close;
end;

procedure TfrmVirus.FormShow(Sender: TObject);
begin
  SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  with frmvirus do
  begin
    top := 271;
    left := 337;
  end;
end;

procedure TfrmVirus.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Close;
end;

procedure TfrmVirus.suiButton1Click(Sender: TObject);
begin
  frmMain.blacklist.Items.Add(txtviruslocation.Text);
  jawaban := false;
  Close;
end;

end.
