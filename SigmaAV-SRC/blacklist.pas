unit blacklist;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SUIButton, StdCtrls, SUIListBox, ExtCtrls, SUIForm, SUIMgr;

type
  Tfrmblacklist = class(TForm)
    suiForm1: TsuiForm;
    blacklist: TsuiListBox;
    cmdadd: TsuiButton;
    cmdremove: TsuiButton;
    tmbahfile: TOpenDialog;
    suiThemeManager1: TsuiThemeManager;
    procedure cmdaddClick(Sender: TObject);
    procedure cmdremoveClick(Sender: TObject);
    procedure blacklistMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmblacklist: Tfrmblacklist;

implementation

uses main;

{$R *.dfm}

procedure Tfrmblacklist.cmdaddClick(Sender: TObject);
begin
  if tmbahfile.Execute then
    blacklist.Items.Add(tmbahfile.FileName); 
end;

procedure Tfrmblacklist.cmdremoveClick(Sender: TObject);
begin
  blacklist.DeleteSelected; 
end;

procedure Tfrmblacklist.blacklistMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  blacklist.Hint := blacklist.Items.Text;
end;

end.
