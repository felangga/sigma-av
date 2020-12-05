unit VirFound;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SUIButton, StdCtrls, ExtCtrls, SUIForm, ComOBJ, Proses;

type
  TfrmVFound = class(TForm)
    suiForm1: TsuiForm;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lblNama: TLabel;
    lbllokasi: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    suiButton1: TsuiButton;
    suiButton2: TsuiButton;
    suiButton3: TsuiButton;
    procedure suiButton2Click(Sender: TObject);
    procedure suiButton1Click(Sender: TObject);
    procedure suiButton3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVFound: TfrmVFound;
  voice: OLEVariant;
    
implementation

uses avScanner, avKernel, avTypes, main;


{$R *.dfm}

procedure TfrmVFound.suiButton2Click(Sender: TObject);
begin
  Jawaban := false;
  if FileIsReadOnly(lbllokasi.Text) then
       FileSetReadOnly(lbllokasi.Text,false);
  if not DeleteFile(lbllokasi.text) then
  begin
    MessageDlg('Failed to delete this virus, may be locked or still active in memory',mtError,[mbOK],0);
  end;
  close;
end;

procedure TfrmVFound.suiButton1Click(Sender: TObject);
begin
  jawaban := true;
  Close;
end;

procedure TfrmVFound.suiButton3Click(Sender: TObject);
begin
  Jawaban := False;
  if not MoveToQuarantine(lbllokasi.Text,lblNama.Caption) then
    MessageDlg('Failed to move this virus into the Quarantine room, access denied!',mtError,[mbOK],0);
  close;
end;

procedure TfrmVFound.FormShow(Sender: TObject);
begin
  SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  //SuspendProcess('explorer.exe');
  try
    voice := CreateOLEObject('SAPI.SpVoice');
    voice.Speak('Caution! A virus has been detected!', 0);
  except
    Exit;
  end;
end;

procedure TfrmVFound.FormHide(Sender: TObject);
begin
  ResumeProcess('explorer.exe');
end;

end.
