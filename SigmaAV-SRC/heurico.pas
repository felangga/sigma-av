unit heurico;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, tlHelp32, SUIMgr, SUIEdit, SUIButton,
  SUIForm;

type
  Theur = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    ico: TImage;
    suiForm1: TsuiForm;
    cmdIgn: TsuiButton;
    cmdDelete: TsuiButton;
    edtpath: TsuiEdit;
    suiThemeManager1: TsuiThemeManager;
    procedure suitempcmdIgnClick(Sender: TObject);
    procedure suitempcmdDeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  heur: Theur;

implementation

{$R *.dfm}

uses umain;

procedure Theur.suitempcmdIgnClick(Sender: TObject);
begin
  Close;
end;

function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure Theur.suitempcmdDeleteClick(Sender: TObject);
begin
  if FileIsReadOnly(edtpath.Text) then
    FileSetReadOnly(edtpath.Text,False);

  KillTask(edtpath.Text);
  if not DeleteFile(edtpath.Text) then
    MessageDlg('Failed to delete this file',mtError,[mbOk],0);
end;

end.
