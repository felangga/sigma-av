unit Port;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, avKernel, SUIMgr, SUIListBox, SUIButton, ExtCtrls,
  SUIForm, SUIScrollBar;

type
  TfrmPort = class(TForm)
    suiForm1: TsuiForm;
    cmdRefresh: TsuiButton;
    port: TsuiListBox;
    suiThemeManager1: TsuiThemeManager;
    suiScrollBar1: TsuiScrollBar;
    procedure suitempcmdRefreshClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPort: TfrmPort;

implementation

{$R *.dfm}
uses UMAin;

procedure TfrmPort.suitempcmdRefreshClick(Sender: TObject);
var
Output, Errors: TStringList;
begin
//------------------------------------------------------------------------------

Output := TStringList.Create;
Errors := TStringList.Create;

if GetConsoleOutput('netstat -a', Output, Errors) then
begin
Port.Items.Text := Output.Text;
end;

Errors.Destroy;
Output.Destroy;

//------------------------------------------------------------------------------
end;

procedure TfrmPort.FormCreate(Sender: TObject);
begin
  cmdRefresh.Click;
end;

end.
  