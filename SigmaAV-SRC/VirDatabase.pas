unit VirDatabase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, avDatabase, avKernel, SUIMgr,
  SUIListView, SUIButton, ExtCtrls, SUIForm, SUIEdit;

type
  TfrmVirusDatabase = class(TForm)
    ImageList1: TImageList;
    suiForm1: TsuiForm;
    Button1: TsuiButton;
    VView: TsuiListView;
    suiThemeManager1: TsuiThemeManager;
    txtsrc: TsuiEdit;
    cmdSearch: TsuiButton;
    procedure suitempButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmdSearchClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVirusDatabase: TfrmVirusDatabase;

implementation

uses uMain;

{$R *.dfm}

procedure AddRecToList(Rec: TDataRecord);
begin
  with frmVirusDatabase.VView.Items.Add, Rec do
    begin
      Caption := VirName;
    end;
  if frmVirusDatabase.VView.Items.Count = 0 then
  begin
    frmVirusDatabase.txtsrc.Enabled := false;
    frmVirusDatabase.cmdSearch.Enabled := false;
  end;
end;

procedure OpenDBFile(const sFileName: String;var DBFile: TDBFile);
var
  DBRec: TDataRecord;
  s    : String;
begin
  GetDir(4,S);
  {$I-}
  AssignFile(DBFile, ExtractFilePath(paramstr(0))+'Databases\VirDB.av');
  Reset(DBFile);
  {$I+}
  if IOResult <> 0 then
    MainForm.msgnf.ShowModal
  else
  while not EOF(DBFile) do
    begin
      Read(DBFile, DBRec);
      AddRecToList(DBRec);
    end;
end;


// To search for a list view subitem (also for items), use this function:

{
  Search for text in a listview item
  @Param lv is the listview, supposed to be in vaReport mode
  @Param S is the text to search for
  @Param column is the column index for the column to search , 0-based
  @Returns the found listview item, or Nil if none was found
  @Precondition  lv  nil, lv in report mode if column  0, S not empty
  @Desc The search is case-insensitive and will only match on the
  complete column content. Use AnsiContainsText instead of AnsiCompareText
  to match on a substring in the columns content.
  Created 14.10.2001 by P. Below
}

function FindListViewItem(lv: TSuiListView; const S: string; column: Integer): TListItem;
var
  i: Integer;
  found: Boolean;
begin
  Assert(Assigned(lv));
  Assert((lv.viewstyle = vsReport) or (column = 0));
  Assert(S <> '');
  for i := 0 to lv.Items.Count - 1 do
  begin
    Result := lv.Items[i];
    if column = 0 then
      found := AnsiCompareText(Result.Caption, S) = 0
    else if column > 0 then
      found := AnsiCompareText(Result.SubItems[column - 1], S) = 0
    else
      found := False;
    if found then
      Exit;
  end;
  // No hit if we get here
  Result := nil;
end;



// Function to search items and select if found

procedure LV_FindAndSelectItems(lv: TSuiListView; const S: string; column: Integer);
var
  i: Integer;
  found: Boolean;
  lvItem: TListItem;
begin
  Assert(Assigned(lv));
  Assert((lv.ViewStyle = vsReport) or (column = 0));
  Assert(S <> '');
  for i := 0 to lv.Items.Count - 1 do
  begin
    lvItem := lv.Items[i];
    if column = 0 then
      found := AnsiCompareText(lvItem.Caption, S) = 0
    else if column > 0 then
    begin
      if lvItem.SubItems.Count >= Column then
        found := AnsiCompareText(lvItem.SubItems[column - 1], S) = 0
      else
        found := False;
    end
    else
      found := False;
    if found then
    begin
      lv.Selected := lvItem;
    end;
  end;
end;

procedure TfrmVirusDatabase.suitempButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmVirusDatabase.FormCreate(Sender: TObject);
begin
  OpenDbFile('',DBFile);
  SuiForm1.Caption := 'Virus Database (Virus known : '+IntToStr(VView.Items.Count)+')';
end;

procedure TfrmVirusDatabase.cmdSearchClick(Sender: TObject);
var
  lvItem: TListItem;
begin
  LV_FindAndSelectItems(VView, txtSrc.Text, 0);
  VView.SetFocus;
  // MessageDLG('Virus not found in database!',mtInformation,[mbok],0);
end;

end.
