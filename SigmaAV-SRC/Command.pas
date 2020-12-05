unit Command;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, avKernel, StdCtrls, ExtCtrls, SUIMgr, SUIListBox, SUIButton,
  SUIEdit, SUIForm;

type
  TfrmCMD = class(TForm)
    suiThemeManager1: TsuiThemeManager;
    suiForm1: TsuiForm;
    edtcommand: TsuiEdit;
    cmdEnter: TsuiButton;
    Panel1: TPanel;
    command: TsuiListBox;
    procedure suitempcmdEnterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure suitempedtcommandKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCMD: TfrmCMD;

implementation

uses UMain;

{$R *.dfm}

procedure TfrmCMD.suitempcmdEnterClick(Sender: TObject);
var
  Output, Errors: TStringList;
begin
//------------------------------------------------------------------------------

Output := TStringList.Create;
Errors := TStringList.Create;

if GetConsoleOutput('CMD /C'+edtcommand.Text, Output, Errors) then
begin
Command.Items.Text := Output.Text;
edtcommand.Text := '';
end;

Errors.Destroy;
Output.Destroy;

//------------------------------------------------------------------------------
end;


procedure TfrmCMD.FormCreate(Sender: TObject);

var
  Output, Errors: TStringList;
begin
//------------------------------------------------------------------------------
output := TStringList.Create;
Errors := TStringList.Create;

if GetConsoleOutput('CMD'+edtcommand.Text, Output, Errors) then
begin
Command.Items.Text := Output.Text;
end;

Errors.Destroy;
Output.Destroy;

//------------------------------------------------------------------------------
end;


procedure TfrmCMD.suitempedtcommandKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    cmdEnter.Click;
end;

end.
