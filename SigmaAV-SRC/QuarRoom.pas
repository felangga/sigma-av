unit QuarRoom;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, avDatabase;

type
  TQRoom = class(TForm)
    ListQuar: TListView;
    cmdRestore: TButton;
    cmdRestoreTo: TButton;
    cmdDelete: TButton;
    cmdClose: TButton;
    procedure FormCreate(Sender: TObject);
    procedure cmdCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  QRoom: TQRoom;

implementation

{$R *.dfm}


procedure AddRecToList(Rec: TDataRecord);
begin
  with QRoom.ListQuar.Items.Add, Rec do
    begin
      SubItems.Add(FileName);
      SubItems.Add(OrigPath);
    end;
end;

procedure OpenDBFile(const sFileName: String;var DBFile: TDBFile);
var
  DBRec: TDataRecord;
  Loc : String;
begin
  Loc := 'C:\$SigmaVault$\';
  AssignFile(DBFile,Loc+'Quar.db');
  {$I-}
  Reset(DBFile);
  {$I+}
  while not EOF(DBFile) do
    begin
      Read(DBFile, DBRec);
      AddRecToList(DBRec);
    end;
end;

procedure TQRoom.FormCreate(Sender: TObject);
begin
  OpenDBFile('C:\$SigmaVault$\'+'Quar.db',DBFile)
end;

procedure TQRoom.cmdCloseClick(Sender: TObject);
begin
  Close;
end;

end.
