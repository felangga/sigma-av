unit Scanmem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SUIButton, SUIProgressBar, ExtCtrls, SUIForm, uMain, avScanner, CoolTrayIcon,
  ComCtrls, StdCtrls;

type
  TfrmScanMem = class(TForm)
    ScanMem: TsuiForm;
    suiButton1: TsuiButton;
    progres: TProgressBar;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure suiButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmScanMem: TfrmScanMem;

implementation

{$R *.dfm}

function daptdir(input : string) : string;
var drive : integer;
begin
  drive := Pos (':\',input);
  if (Copy(input,drive-4,drive-3) <> '') then
    Result := Copy(input,drive-1,length(input))
  else
    Result := input;
end;

procedure TfrmScanMem.FormShow(Sender: TObject);
var i,persen : integer;

begin
  SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  Mainform.Button1.Click;
  Memory := true;
  progres.Max := Mainform.ListBox1.Count-4;
  with mainform.ListBox1.Items do
  for i := 5 to Mainform.ListBox1.Items.Count-1 do
    if (strings[i] <> ' ') and (Pos('\',Strings[i]) <> 0) and (Strings[i] <> '') and (Pos(':',strings[i]) <> 0) and (Pos('Sigma',strings[i]) = 0) then
    begin
      Label1.Caption := 'Path : '+DaptDir(Mainform.ListBox1.Items.Strings[i]);
      ScanFile(Daptdir(MainForm.Listbox1.Items.Strings[i]));
      Progres.Position := i;
     end;
  for i := 0 to Mainform.suspend.Items.Count-1 do
  begin
    KillTask(MainForm.suspend.Items.Strings [i]);
  end;
  if Progres.Position = i then
  begin
    Mainform.Show;
    Hide;
  end;
  Memory := False;
  InScan := False;
end;

procedure TfrmScanMem.suiButton1Click(Sender: TObject);
begin
  Mainform.Show;
  Hide;
end;

end.
