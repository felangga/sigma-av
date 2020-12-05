unit Upload;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw;

type
  TfrmUpload = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmUpload: TfrmUpload;

implementation

{$R *.dfm}

procedure TfrmUpload.FormCreate(Sender: TObject);
begin
  Webbrowser1.Navigate('sigmaupload.4shared.com');
end;

end.
