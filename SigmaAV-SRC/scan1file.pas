unit scan1file;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SUIButton, StdCtrls, ComCtrls, ShellCtrls, SUIMgr, ExtCtrls,
  SUIForm, FileCtrl, SUIComboBox;

type
  TfrmScanFile = class(TForm)
    suiForm1: TsuiForm;
    suiThemeManager1: TsuiThemeManager;
    ShellTreeView1: TShellTreeView;
    suiButton1: TsuiButton;
    suiButton2: TsuiButton;
    ShellComboBox1: TShellComboBox;
    procedure suiButton2Click(Sender: TObject);
    procedure suiButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmScanFile: TfrmScanFile;

implementation

uses UMain, avScanner, avKernel, avTypes;

{$R *.dfm}

procedure TfrmScanFile.suiButton2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmScanFile.suiButton1Click(Sender: TObject);
var hasil : TModalResult;
begin
  MainForm.MainPages.ActivePageIndex := 3;
  if ScanFileBiasa(ShellTreeView1.Path) <> 'NONE' then
  begin
    MainForm.VirMsg.Text := 'This file contain '+ScanFileBiasa(ShellTreeView1.Path)+' what do you want to do?';
    Hasil := MainForm.VirMsg.ShowModal;
    begin
     if hasil = MainForm.VirMsg.Button2ModalResult then
     begin
       if FileIsReadOnly(ShellTreeView1.Path) then
       FileSetReadOnly(ShellTreeView1.path,False);

       if not DeleteFile(ShellTreeView1.Path) then
         MessageDlg('Failed to delete : '+ShelltreeView1.Path,mtError,[mbOK],0)
       else
         MessageDlg('Successfully deleted : '+ShelltreeView1.Path,mtInformation,[mbOK],0);
       exit;
     end;
    if Hasil = MainForm.VirMsg.Button3ModalResult then
      if not MovetoQuarantine(ShellTreeView1.Path,ScanFileBiasa(ShellTreeView1.Path)) then
        MessageDlg('Failed to move : '+ShelltreeView1.Path,mtError,[mbOK],0);
    Close;
    end
  end
 else
  begin
    MainForm.MsgClean.Text := 'This file is clean...';
    Mainform.MsgClean.ShowModal;
  end;
  Close;
  {Sigma := TAVScanner.Create(True);
  Sigma.AvAction := TScanFile;
  Sigma.FileName := ShellTreeView1.Path;
  SelectScan(True, True, True);
  OnScanStart;
  Close;}
end;

end.
