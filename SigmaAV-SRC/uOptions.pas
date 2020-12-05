unit uOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls, registry, Menus, avscanner,
  SUIMgr, SUIButton, SUIListView, SUIImagePanel, SUIGroupBox, SUIPopupMenu,
  SUIForm, ActnMan, ActnColorMaps, SUIEdit;

type
  TOptionsForm = class(TForm)
    Add1: TMenuItem;
    Delete1: TMenuItem;
    Edit1: TMenuItem;
    Label1: TLabel;
    suiForm1: TsuiForm;
    PopupMenu1: TsuiPopupMenu;
    ApplyBTN: TsuiButton;
    CancelBTN: TsuiButton;
    GroupBox1: TsuiGroupBox;
    ExtList: TsuiListView;
    RegisterSysMenu: TsuiCheckBox;
    GroupBox2: TsuiGroupBox;
    chckNorm: TsuiRadioButton;
    chckHigh: TsuiRadioButton;
    GroupBox3: TsuiGroupBox;
    PathList: TsuiListView;
    justscan: TsuiCheckBox;
    suiThemeManager1: TsuiThemeManager;
    chckCustom: TsuiRadioButton;
    cCRC: TsuiCheckBox;
    cHEX: TsuiCheckBox;
    cMD5: TsuiCheckBox;
    chkHeur: TsuiCheckBox;
    chkmemscan: TsuiCheckBox;
    maxsld: TsuiSpinEdit;
    suiGroupBox1: TsuiGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    minsld: TsuiSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    chkstart: TsuiCheckBox;
    chkfast: TsuiCheckBox;
    procedure suitempApplyBTNClick(Sender: TObject);
    Procedure SaveOptions(FileName: String);
    procedure suitempCancelBTNClick(Sender: TObject);
    procedure APIListDblClick(Sender: TObject);
    procedure FileTAddAction(key, name, display, action: String);
    procedure FileTDelAction(key, name: String);
    procedure CheckBox1Click(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure suitempExtListEnter(Sender: TObject);
    procedure suitempPathListEnter(Sender: TObject);
    procedure chckCustomClick(Sender: TObject);
    procedure chckHighClick(Sender: TObject);
    procedure chckNormClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure minsldChange(Sender: TObject);
    procedure maxsldChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;
  Endi       : String;


implementation

uses uPluginInfo, uAddPath, uMain;

{$R *.dfm}
procedure TOptionsForm.FileTDelAction(key, name: String);
var myReg: TRegistry;
begin
try
  myReg:=TRegistry.Create;
  myReg.RootKey:=HKEY_CLASSES_ROOT;
  if key[1] = '.' then
    key := copy(key,2,maxint)+'_auto_file';
  if key[Length(key)-1] <> '\' then
    key:=key+'\';
  myReg.OpenKey('\'+key+'shell\', true);
  if myReg.KeyExists(name) then
    myReg.DeleteKey(name);
  myReg.CloseKey;
  myReg.Free;
except
  end;
end;

procedure TOptionsForm.FileTAddAction(key, name, display, action: String);
var
myReg:TRegistry;
begin
try
  myReg:=Tregistry.Create;
  myReg.RootKey:=HKEY_CLASSES_ROOT;
  if name='' then name:=display;

  if key[1] = '.' then
    key:= copy(key,2,maxint)+'_auto_file';

  if key[Length(key)-1] <> '\' then
    key:=key+'\';
  if name[Length(name)-1] <> '\' then
    name:=name+'\';

  myReg.OpenKey(key+'Shell\'+name, true);
  myReg.WriteString('', display);
  MyReg.CloseKey;
  MyReg.OpenKey(key+'Shell\'+name+'Command\', true);
  MyReg.WriteString('', action);
  myReg.Free;
except
end;
end;

Procedure TOptionsForm.SaveOptions(FileName: String);
var
List: TStringList;
i:integer;
begin
        List:= TStringList.Create;
        if RegisterSysMenu.Checked then
          List.Add('REGISTERSYSMENU=ON')
        else
          List.Add('REGISTERSYSMENU=OFF');


        if chkHeur.Checked then
          List.Add('HEUR=ON')
        else
          List.Add('HEUR=OFF');

        if chkfast.Checked then
          List.Add('FASTSCAN=YES')
        else
          List.Add('FASTSCAN=NO');

        if chckNorm.Checked then
          List.Add('Check=NORMAL')
        else
          List.Add('Check=HIGH');

        if chkstart.Checked then
          List.Add('STARTUP=YES')
        else
          List.Add('STARTUP=NO');

        if Chkmemscan.Checked then
          List.Add('MEMSCAN=YES')
        else
          List.Add('MEMSCAN=NO');

        if JustScan.Checked then
          List.Add('SelFile=YES')
        else
          List.Add('SelFile=NO');

        List.Add('max='+IntTostr((maxsld.Value*1024)*1024));
        List.Add('min='+IntToStr((minsld.value*1024)*1024));

        if not chckCustom.Checked then
          List.Add('CUSTOMSEARCH=INACTIVE');
        if cCRC.Checked then
          List.Add('CUSTOMSEARCH=CRC32');
        if cHex.Checked then
          List.Add('CUSTOMSEARCH=HEX');
        if cMD5.Checked then
          List.Add('CUSTOMSEARCH=MD5');
        if cCRC.Checked and cHex.Checked then
          List.Add('CUSTOMSEARCH=CRC32, HEX');
        if cHex.Checked and cMD5.Checked then
          List.Add('CUSTOMSEARCH=HEX, MD5');
        if cCRC.Checked and cMD5.Checked then
          List.Add('CUSTOMSEARCH=CRC32, MD5');
         if cCRC.Checked and cHex.Checked and cMD5.Checked then
          List.Add('CUSTOMSEARCH=CRC32, HEX, MD5');

        for i := 0 to ExtList.Items.Count-1 do
          List.Add('EXT='+ExtList.Items.Item[i].Caption);

        for i := 0 to PathList.Items.Count-1 do
          List.Add('PATH='+PathList.Items.Item[i].Caption);
  List.SaveToFile(FileName);
  List.Free;
end;

procedure TOptionsForm.suitempApplyBTNClick(Sender: TObject);
begin
  SaveOptions(ExtractFilePath(paramstr(0))+'Options.ini');
  if chckNorm.Checked then
  begin
    setsecurity(2);
    dipilih := 1;
  end;

  MaxSize := (Maxsld.Value*1024)*1024;
  MinSize := (MinSld.Value*1024)*1024;

  if chckHigh.Checked then
  begin
    setsecurity(3);
    dipilih := 2;
  end;

  if chkHeur.Checked then
    setheur(true)
  else
    setheur(False);

  if chkmemscan.Checked then
    AllowMemScan := True
  else
    AllowMemScan := False;

  if chkstart.Checked then
     Mainform.SetAutoStart(ParamSTr(0)+' /hid','SigmaAV',true)
  else
     Mainform.SetAutoStart(ParamSTr(0)+' /hid','SigmaAV',false);


  Mainform.fastscan.Enabled := chkFast.Checked;
  FASTSCAN := ChkFast.Checked;

  if chckCustom.Checked then
  begin
    Dipilih := 3;
    if cCRC.Checked then
      selectScan(true, false,false);
    if cHEX.Checked then
      SelectScan(false,true,false);
    if cMD5.Checked then
      SelectScan(False,False,True);
    if cCRC.Checked and cHex.Checked then
      SelectScan(True,True,False);
    if cHex.Checked and cMd5.Checked then
      SelectScan(false,true,true);
    if cCRC.Checked and cMD5.Checked then
      SelectScan(True,false,true);
    if cCrc.Checked and cHex.Checked and cMd5.Checked then
      SelectScan(True, True, True);
  end;

  if JustScan.Checked then
    GlobalScan := False
  else
    GlobalScan := True;
  MainForm.CreateDrivesList(MainForm.PathList);
  if RegisterSysMenu.Checked then
  begin
    FileTAddAction('*','SigmaAV',SysMenu,ParamStr(0)+' %1');
    FileTAddAction('Directory','SigmaAV',SysMenu,ParamStr(0)+' %1');
    FileTAddAction('Drive','SigmaAV',SysMenu,ParamStr(0)+' %1');
  end
else
  begin
    FileTDelAction('Drive','SigmaAV');
    FileTDelAction('Directory','SigmaAV');
    FileTDelAction('*','SigmaAV');
  end;

  if chckCustom.Checked then
  begin
  if  (not cCrc.Checked) and (not cHex.Checked) and (not cMd5.Checked) then
     MessageDLG('Sorry, you must select the searching method!',mtError,[mbOK],0)
  else
    Close;
  end
 else
  Close;
end;

procedure TOptionsForm.suitempCancelBTNClick(Sender: TObject);
begin
Close;
end;

procedure TOptionsForm.APIListDblClick(Sender: TObject);
begin
{if APIList.ItemIndex <> -1 then begin
  PluginAPIForm.NameEdit.Text := APIList.Selected.Caption;
  PluginAPIForm.AutorEdit.Text := APIList.Selected.SubItems[0];
  PluginAPIForm.OtherMemo.Text := APIList.Selected.SubItems[1];
  PluginAPIForm.PathEdit.Text := APIList.Selected.SubItems[2];
  PluginAPIForm.ShowModal;
end;                            }
end;



procedure TOptionsForm.CheckBox1Click(Sender: TObject);
begin
  if justscan.Checked = true then
    ExtList.Enabled := True
  else
    ExtList.Enabled := False;
end;

procedure TOptionsForm.Add1Click(Sender: TObject);
begin
  If endi = 'Extensi' then
  begin
    with ExtList.Items.Add do
    begin
      Caption := '';
      ImageIndex := 3;
      EditCaption;
    end;
  end
else
  AddUserPathForm.Showmodal;

end;

procedure TOptionsForm.Delete1Click(Sender: TObject);
begin
  If endi = 'Extensi' then
  begin
    ExtList.DeleteSelected;
  end
else
  PathList.DeleteSelected;
end;

procedure TOptionsForm.Edit1Click(Sender: TObject);
begin
  If endi = 'Extensi' then
  begin
    ExtList.Selected.EditCaption;
  end
else
  if endi = 'recent' then
      PathList.Selected.EditCaption;
end;

procedure TOptionsForm.suitempExtListEnter(Sender: TObject);
begin
  Endi := 'Extensi';
  Edit1.Visible := True;
end;

procedure TOptionsForm.suitempPathListEnter(Sender: TObject);
begin
  Endi := 'Recent';
  Edit1.Visible := False;
end;

procedure TOptionsForm.chckCustomClick(Sender: TObject);
begin
  if ChckCustom.Checked then
    begin
      cCrc.Enabled := True;
      cHex.Enabled := True;
      cMD5.Enabled := True;
    end;
  dipilih := 3;
end;

procedure TOptionsForm.chckHighClick(Sender: TObject);
begin
  begin
    cCrc.Enabled := False;
    cCrc.Checked := false;
    cHex.Checked := false;
    cMD5.Enabled := False;
    cHex.Enabled := False;
    cMD5.Enabled := False;
    cMD5.Checked := False;
  end;
  dipilih := 2;
end;

procedure TOptionsForm.chckNormClick(Sender: TObject);
begin
  begin
    cCrc.Enabled := False;
    cHex.Enabled := False;
    cMD5.Enabled := False;
    cCrc.Checked := false;
    cHex.Checked := false;
    cMD5.Enabled := False;
    cMD5.Checked := False;
  end;
  dipilih := 1;
end;


procedure TOptionsForm.FormShow(Sender: TObject);
begin
  if dipilih = 2 then
    chckHigh.Checked := true
  else
  if dipilih = 1 then
    chckNorm.Checked := true
  else
  if dipilih = 3 then
    chckCustom.state := cbChecked;
  end;

procedure TOptionsForm.minsldChange(Sender: TObject);
begin
  minsld.MaxValue := maxsld.Value-1;
end;

procedure TOptionsForm.maxsldChange(Sender: TObject);
begin
  maxsld.MinValue := minsld.Value+1;
end;

end.
