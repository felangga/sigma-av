unit splash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmSplash = class(TForm)
    Label1: TLabel;
    txtver: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSplash: TfrmSplash;
  waktu : integer;

implementation

uses Umain;

{$R *.dfm}

procedure TfrmSplash.FormCreate(Sender: TObject);
var i : integer;
begin
  waktu := 0;
  txtVer.Caption := 'V.'+Mainform.GetVersion;
  Sleep(5000);
  I := 200;
  while i > 0 do
  begin
    MainForm.SetLayeredWindowAttributes(Sender as tForm,0,LWA_ALPHA,i);
    dec(i,10);
  end;
  Close;

end;

procedure TfrmSplash.Timer1Timer(Sender: TObject);

begin
  waktu := waktu + 1;
  if waktu = 5 then
    Close;
end;

procedure TfrmSplash.FormClose(Sender: TObject; var Action: TCloseAction);
var i : integer;
begin
   Mainform.ShowModal;
end;

end.
