unit init;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, SUIForm, SUIButton;

type
  Tfrminit = class(TForm)
    frmLoading: TsuiForm;
    ProgressBar1: TProgressBar;
    cmdSkip: TsuiButton;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure cmdSkipClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure suiButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frminit: Tfrminit;
  SR:TSearchRec;
  OBJ : TObject;
  FindRes,i:Integer;

implementation

Uses UMain,avScanner,avKernel, avTypes;

{$R *.dfm}

procedure Tfrminit.cmdSkipClick(Sender: TObject);
begin
  SkipFile := True;
//  SetWindowLong(Mainform.Prog.Handle, GWL_STYLE,
  //  GetWindowLong(Mainform.Prog.Handle, GWL_STYLE) or PBS_MARQUEE);
  Close;
  Sigma.Resume;
  diSkip := True;
  Mainform.tmrMarque.Enabled := True;
end;

procedure Tfrminit.Timer1Timer(Sender: TObject);
begin
  SetWindowLong(FrmInit.ProgressBar1.Handle, GWL_STYLE,
    GetWindowLong(frmInit.ProgressBar1.Handle, GWL_STYLE) or PBS_MARQUEE);
end;

procedure jumlahkan(Dir : String);
begin
  if ((SR.Attr and faDirectory)=faDirectory) and
    ((SR.Name='.')or(SR.Name='..')) then
      begin
        FindRes:=FindNext(SR);
      end;

    etung := etung + 1;

    if SkipFile then Exit;

    Mainform.prog.MaxValue := etung;
    FindRes:=FindNext(SR);
end;

procedure Tfrminit.Timer2Timer(Sender: TObject);
begin
  FindRes:=FindFirst(Sigma.DirName+'*.jpg',faAnyFile,SR);
  if FindRes<>0 then
  begin
    frmInit.Timer2.Enabled := false;
    FindClose(SR);
    ShowMessage(IntToStr(Etung));
  end
 else
   Jumlahkan(Sigma.DirName);
   showmessage(inttostr(etung));

  { if ((SR.Attr and faDirectory)=faDirectory) then
    begin
      Jumlahkan(Sigma.DirName+SR.Name+'\');
      FindRes:=FindNext(SR);
    end;}
end;

procedure Tfrminit.suiButton1Click(Sender: TObject);
begin
  timer2.Enabled := true;
end;

end.
