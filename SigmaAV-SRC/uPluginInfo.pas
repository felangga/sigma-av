unit uPluginInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, SUIMgr, SUIMemo, SUIEdit, SUIButton, SUIForm;

type
  TPluginAPIForm = class(TForm)
    Bevel: TBevel;
    NameLabel: TLabel;
    AutorLabel: TLabel;
    OtherInfoLabel: TLabel;
    PathLabel: TLabel;
    suiForm1: TsuiForm;
    OkBTN: TsuiButton;
    PathEdit: TsuiEdit;
    NameEdit: TsuiEdit;
    AutorEdit: TsuiEdit;
    OtherMemo: TsuiMemo;
    suiThemeManager1: TsuiThemeManager;
    suiThemeManager2: TsuiThemeManager;
    procedure suitempOkBTNClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PluginAPIForm: TPluginAPIForm;

implementation

uses Umain;

{$R *.dfm}

procedure TPluginAPIForm.suitempOkBTNClick(Sender: TObject);
begin
Close;
end;

end.
