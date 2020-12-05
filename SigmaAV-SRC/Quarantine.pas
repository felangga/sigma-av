unit Quarantine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, avKernel, ImgList, SUIMgr, SUIButton,
  SUIListView, ExtCtrls, SUIForm, SUIImagePanel;

type
  TfrmQuar = class(TForm)
    ImageList1: TImageList;
    suiForm1: TsuiForm;
    CarList: TsuiListView;
    cmdDel: TsuiButton;
    cmdRestore: TsuiButton;
    cmdClose: TsuiButton;
    suiThemeManager1: TsuiThemeManager;
    suiPanel1: TsuiPanel;
    Label1: TLabel;
    procedure suitempcmdCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure suitempcmdRestoreClick(Sender: TObject);
    procedure suitempcmdDelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmQuar: TfrmQuar;

implementation

uses UMain;
{$R *.dfm}

procedure TfrmQuar.suitempcmdCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmQuar.FormCreate(Sender: TObject);
begin
  BuildQuarantineList(CarList);
end;

procedure TfrmQuar.suitempcmdRestoreClick(Sender: TObject);
begin
  if not RestoreQarFile(CarList.Selected.Index) then
    MessageDlg('Sorry, the quarantined file is not found or corrupted!',mtError,[mbOK],0)
  else
    MessageDlg('Quarantined file restore successfully!',mtInformation,[mbOK],0);
   BuildQuarantineList(CarList);
end;

procedure TfrmQuar.suitempcmdDelClick(Sender: TObject);
begin
  DelFromQuarantine(CarList.Selected.Index);
  BuildQuarantineList(CarList);
end;

end.
