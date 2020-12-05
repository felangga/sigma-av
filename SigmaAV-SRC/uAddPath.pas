unit uAddPath;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ShellCtrls, SUIMgr, SUIButton, TntSysUtils,
  SUIForm;

type
  TAddUserPathForm = class(TForm)
    Bevel: TBevel;
    TopPanel: TPanel;
    ShellTreeView: TShellTreeView;
    Label1: TLabel;
    suiForm1: TsuiForm;
    ApplyBTN: TsuiButton;
    CanselBTN: TsuiButton;
    suiThemeManager1: TsuiThemeManager;
    procedure suitempCanselBTNClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShellTreeViewClick(Sender: TObject);
    procedure suitempApplyBTNClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddUserPathForm: TAddUserPathForm;

implementation

uses uMain, uOptions, uSelInfo;

{$R *.dfm}

procedure TAddUserPathForm.suitempCanselBTNClick(Sender: TObject);
begin
Close;
end;

procedure TAddUserPathForm.FormShow(Sender: TObject);
begin
ApplyBTN.Enabled := false;
end;

procedure TAddUserPathForm.ShellTreeViewClick(Sender: TObject);
begin
if WideDirectoryExists(ShellTreeView.Path+'\') then
ApplyBTN.Enabled := True else
ApplyBTN.Enabled := False;
end;

procedure TAddUserPathForm.suitempApplyBTNClick(Sender: TObject);
begin
with OptionsForm.PathList.Items.Add do begin
        Caption := ShellTreeView.Path+'\';
        if WideDirectoryExists(Caption) then ImageIndex := 4 else ImageIndex := 5;
end;
  OptionsForm.SaveOptions(WideExtractFilePath(paramstr(0))+'Options.ini');
  MainForm.CreateDrivesList(MainForm.PathList);
  Close;
end;

end.
