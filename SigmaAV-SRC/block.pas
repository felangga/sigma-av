unit block;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SUIImagePanel, SUIButton, StdCtrls, ExtCtrls, SUIForm, SUIMgr;

type
  TfrmBlock = class(TForm)
    suiThemeManager1: TsuiThemeManager;
    suiForm1: TsuiForm;
    Label1: TLabel;
    cmdAllow: TsuiButton;
    cmdDeny: TsuiButton;
    suiImagePanel1: TsuiImagePanel;
    lblnama: TLabel;
    Label3: TLabel;
    procedure cmdAllowClick(Sender: TObject);
    procedure cmdDenyClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBlock: TfrmBlock;

implementation

uses main;

{$R *.dfm}

procedure TfrmBlock.cmdAllowClick(Sender: TObject);
begin
  Jawaban := True;
  Close;
end;

procedure TfrmBlock.cmdDenyClick(Sender: TObject);
begin
  Jawaban := false;
  Close;
end;

procedure TfrmBlock.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  close;
end;

procedure TfrmBlock.FormShow(Sender: TObject);
begin
  SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

end.
