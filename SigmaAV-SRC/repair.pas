unit repair;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  Tfrmrepair = class(TForm)
    prog: TProgressBar;
    Label1: TLabel;
    txtpath: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmrepair: Tfrmrepair;

implementation

{$R *.dfm}

end.
