unit Plugin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, SUIMgr, SUIListView, ExtCtrls, SUIForm, StdCtrls, SUIImagePanel;

type
  TfrmPlugin = class(TForm)
    suiForm1: TsuiForm;
    apilist: TsuiListView;
    suiThemeManager1: TsuiThemeManager;
    suiPanel1: TsuiPanel;
    Label1: TLabel;
    procedure apilistDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPlugin: TfrmPlugin;

implementation

{$R *.dfm}

uses umain, uPluginInfo;

procedure TfrmPlugin.apilistDblClick(Sender: TObject);
begin
  if Apilist.ItemIndex <> -1 then
  begin
    PluginAPIForm.NameEdit.Text := APIList.Selected.Caption;
    PluginAPIForm.AutorEdit.Text := APIList.Selected.SubItems[0];
    PluginAPIForm.OtherMemo.Text := APIList.Selected.SubItems[1];
    PluginAPIForm.PathEdit.Text := APIList.Selected.SubItems[2];
    PluginAPIForm.ShowModal;
  end;
end;

end.
