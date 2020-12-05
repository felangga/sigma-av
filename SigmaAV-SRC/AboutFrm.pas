unit AboutFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ShellAPI, ComCtrls, credits, ComOBJ;

type
  TAboutForm = class(TForm)
    Bevel2: TBevel;
    Label10: TLabel;
    Label5: TLabel;
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Bevel3: TBevel;
    Credits: TScrollingCredits;
    BitBtn1: TButton;
    procedure suitempBitBtn1Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;
  Voice    : OLEVariant;
implementation

uses uMain;

{$R *.dfm}

procedure TAboutForm.suitempBitBtn1Click(Sender: TObject);
begin
Close;
end;

procedure TAboutForm.Label5Click(Sender: TObject);
Const
  URL : String = 'http://xtfcomp@gmail.com';
begin
  ShellExecute(0,'',pChar('mailto:'+URL),NIL,NIL,SW_SHOWNORMAL);
end;
procedure TAboutForm.FormShow(Sender: TObject);
begin
  Credits.Animate := true;
  Label10.top := 54;
  Label10.Width := 265;
  Label10.Left := 8;
  Label10.Visible := true;
  Label10.Enabled := true;
  Label10.Caption := 'F_Computer && XTF_Computer Company';
end;

end.
