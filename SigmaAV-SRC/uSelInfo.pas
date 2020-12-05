unit uSelInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, SUIListBox, SUIMgr, SUIButton,
  SUIForm;

type
  TInformationForm = class(TForm)
    Virname: TLabel;
    suiForm1: TsuiForm;
    OkBTN: TsuiButton;
    suiThemeManager1: TsuiThemeManager;
    Label2: TLabel;
    Status: TLabel;
    lokasi: TMemo;
    procedure suitempOkBTNClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InformationForm: TInformationForm;

implementation


uses umain;
{$R *.dfm}

procedure TInformationForm.suitempOkBTNClick(Sender: TObject);
begin
Close;
end;

end.
