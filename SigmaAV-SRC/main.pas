unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SUIMgr, ExtCtrls, SUIForm, CoolTrayIcon, ImgList, avScanner, avKernel,
  avTypes, avDatabase, StdCtrls, madCodeHook, SUIButton, SUIMemo, antikill,
  madExceptVcl, SUIImagePanel, SUIGroupBox, SUITrackBar, blacklist, Menus, SUIPopupMenu, ComCtrls, ToolWin, SUIToolBar,
  SUIMainMenu, SUIScrollBar, ShellNotify, SUIListBox, SUIPageControl,
  SUITabControl, credits, SUIDlg;

type
  TfrmMain = class(TForm)
    ImageList1: TImageList;
    trayicon: TCoolTrayIcon;
    suiForm1: TsuiForm;
    suiThemeManager1: TsuiThemeManager;
    RTP: TTimer;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
    suiButton3: TsuiButton;
    chkAktif: TsuiRadioButton;
    chkMati: TsuiRadioButton;
    Log: TsuiMemo;
    MadExceptionHandler1: TMadExceptionHandler;
    suiFileTheme1: TsuiFileTheme;
    suiPopupMenu1: TsuiPopupMenu;
    Open1: TMenuItem;
    Run1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    suiScrollBar1: TsuiScrollBar;
    ShellNotify1: TShellNotify;
    Pagecontrol: TsuiPageControl;
    pgMain: TsuiTabSheet;
    pgLog: TsuiTabSheet;
    pgBlack: TsuiTabSheet;
    blacklist: TsuiListBox;
    Panel1: TPanel;
    tmbahfile: TOpenDialog;
    cmdadd: TsuiButton;
    cmdremove: TsuiButton;
    pgAbout: TsuiTabSheet;
    ScrollingCredits1: TScrollingCredits;
    chkOnTop: TsuiCheckBox;
    Bevel2: TBevel;
    msgblock: TsuiMessageDialog;
    procedure FormCreate(Sender: TObject);
    procedure RTPTimer(Sender: TObject);
    procedure initsystem;
    procedure FormDestroy(Sender: TObject);
    procedure chkAktifClick(Sender: TObject);
    procedure chkMatiClick(Sender: TObject);
    procedure suiButton3Click(Sender: TObject);
    function GetVersion : String;
    procedure Open1Click(Sender: TObject);
    procedure Run1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure ShellNotify1Notify(Sender: TObject; Event: TShellNotifyEvent;
      Path1, Path2: String);
    procedure cmdaddClick(Sender: TObject);
    procedure cmdremoveClick(Sender: TObject);
    procedure pgAboutClick(Sender: TObject);
    procedure chkOnTopClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function  scan(namafile : string) : boolean;
  end;

var jawaban : boolean;
    frmMain : TFrmMain;
    pisanwae: string;
    blokir  : boolean;
    ExitProcessNext : procedure (exitCode: dword); stdcall;


function Inject(inject: boolean) : boolean;
procedure ExitProcessCallback(exitCode: dword); stdcall;
procedure HandleProcessTerminationRequest(name       : pchar;
                                          messageBuf : pointer;
                                          messageLen : dword;
                                          answerBuf  : pointer;
                                          answerLen  : dword); stdcall;

implementation

uses VirFound, proses, VVirus, block;
{$R *.dfm}
Type
  TFileAccessRequest = record
    ParentProcess, FileName : array [0..MAX_PATH] of char;
  end;

type
  // this is the information record which our dll sends us
  TTerminationRequest = record
    system             : boolean;
    process1, process2 : array [0..MAX_PATH] of char;
  end;

procedure HandleProcessTerminationRequest(name       : pchar;
                                          messageBuf : pointer;
                                          messageLen : dword;
                                          answerBuf  : pointer;
                                          answerLen  : dword); stdcall;
// this function is called by the ipc message whenever our dll contacts us
var s1, s2, s3 : string;
begin
  if AmUsingInputDesktop then
  begin
    // our process is running in the current input desktop, so we ask the user
    with TTerminationRequest(messageBuf^) do
    begin
      // first extract the file names only
      s1 := ExtractFileName(process1);
      s2 := ExtractFileName(process2);
      // does the request come from a normal process or from a system process?
      if system then
           s3 := 'system process '
      else s3 := 'process ';
    end;
    // ask the user for confirmation and return the answer to our dll
    boolean(answerBuf^) := false;
  end
else
    // our process is *not* running in the current input desktop
    // if we would call MessageBox, it would not be visible to the user
    // so doing that makes no sense, it could even freeze up the whole OS
    boolean(answerBuf^) := true;
end;

// ***************************************************************

procedure HideMeFrom9xTaskList;
// quick hack which hides our process from task manager (works only in win9x)
var rsp : function (processID: cardinal; flags: integer) : integer; stdcall;
begin
  rsp := GetProcAddress(GetModuleHandle(kernel32), 'RegisterServiceProcess');
  if @rsp <> nil then
    rsp(0, 1);
end;

function WaitForService(serviceName: string) : boolean;
// when the PC boots up and your program is in the autostart
// it may happen that your program runs before the service is ready
// so this function makes sure that the service is up and running
const SERVICE_START               = $10;
      SERVICE_CONTROL_INTERROGATE = 4;
      SERVICE_STOPPED             = 1;
      SERVICE_START_PENDING       = 2;
      SERVICE_RUNNING             = 4;
var c1, c2 : dword;
    ss     : array [0..6] of dword;
    i1     : integer;
    dll    : dword;
    OpenSCManagerA     : function (machine, database: pchar; access: dword) : dword; stdcall;
    OpenServiceA       : function (scMan: dword; service: pchar; access: dword) : dword; stdcall;
    ControlService     : function (service, control: dword; status: pointer) : bool; stdcall;
    StartServiceA      : function (service: dword; argCnt: dword; args: pointer) : bool; stdcall;
    CloseServiceHandle : function (handle: dword) : bool; stdcall;
begin
  result := false;
  // dynamic advapi32 API linking
  dll := LoadLibrary('advapi32.dll');
  OpenSCManagerA     := GetProcAddress(dll, 'OpenSCManagerA');
  OpenServiceA       := GetProcAddress(dll, 'OpenServiceA');
  ControlService     := GetProcAddress(dll, 'ControlService');
  StartServiceA      := GetProcAddress(dll, 'StartServiceA');
  CloseServiceHandle := GetProcAddress(dll, 'CloseServiceHandle');
  if (@OpenSCManagerA     <> nil) and
     (@OpenServiceA       <> nil) and
     (@ControlService     <> nil) and
     (@StartServiceA      <> nil) and
     (@CloseServiceHandle <> nil) then begin
    // first we contact the service control manager
    c1 := OpenSCManagerA(nil, nil, 0);
    if c1 <> 0 then begin
      // okay, that worked, now we try to open our service
      c2 := OpenServiceA(c1, pchar(serviceName), GENERIC_READ or SERVICE_START);
      if c2 <> 0 then begin
        // that worked, too, let's check its state
        if ControlService(c2, SERVICE_CONTROL_INTERROGATE, @ss) then begin
          if ss[1] = SERVICE_STOPPED then
            // the service is stopped (for whatever reason), so let's start it
            StartServiceA(c2, 0, nil);
          // now we wait until the process is in a clear state (timeout 15 sec)
          for i1 := 1 to 300 do begin
            if (not ControlService(c2, SERVICE_CONTROL_INTERROGATE, @ss)) or
               (ss[1] <> SERVICE_START_PENDING) then
              break;
            Sleep(50);
          end;
          // is it finally running or not?
          result := ss[1] = SERVICE_RUNNING;
        end;
        CloseServiceHandle(c2);
      end;
      CloseServiceHandle(c1);
    end;
  end;
  FreeLibrary(dll);
end;

// ***************************************************************

type
  // this is the information record which we send to our injection service
  TDllInjectRequest = packed record
    inject  : bool;
    timeOut : dword;
    session : dword;
  end;

function Inject(inject: boolean) : boolean;
// (un)inject our dll system wide
var dir : TDllInjectRequest;
    res : bool;
begin
    // first let's try to inject the dlls without the help of the service
    if inject then
      result :=   InjectLibrary(CURRENT_SESSION or SYSTEM_PROCESSES, 'AntiKill.dll')
    else
      result := UninjectLibrary(CURRENT_SESSION or SYSTEM_PROCESSES, 'AntiKill.dll');
    if not result then
    begin
      // didn't work, so let's try to ask our service for help
      // first of all we wait until the service is ready to go
      WaitForService('SigmaInjectService');
      // then we prepare a dll injection request record
      dir.inject  := inject;
      dir.timeOut := 5000;
      dir.session := GetCurrentSessionId;
      // now we try to contact our injection service
      result := SendIpcMessage('SigmaInjectService', @dir, sizeOf(dir), @res, sizeOf(res), 15000, true) and res;
    end;
end;

// ***************************************************************

procedure ExitProcessCallback(exitCode: dword); stdcall;
begin
  // this can't be a proper shutdown
  // our demo can be closed with a simple button click
  // there's no reason to use bad tricks to close us
  SetLastError(ERROR_ACCESS_DENIED);
end;

function inlist(nama : string) : boolean;
var urut : integer;
begin
  for urut := 0 to frmMain.blacklist.Count-1 do
  begin
    if nama = frmMain.blacklist.Items.strings[urut] then
      result := true
    else
      result := false;
  end;
end;

function TFrmMain.scan(namafile : string) : boolean;
var temp : string;
begin
   if inlist(namafile) then
   begin
     //jawaban := false;
     blokir := true;
     //frmblock.lblnama.Caption := ExtractFileName(NamaFile);
     //frmBlock.ShowModal;
     if msgblock.ShowModal = msgblock.Button1ModalResult then
       jawaban := true
     else
       jawaban := false;
       
     if not jawaban then
       Log.Lines.Add('File access blocked.')
     else
       Log.Lines.Add('File access granted.');
   end
  else
   begin
   if fileexists(namafile) then
    begin
      temp := ScanFilebiasa(namafile);
      if Temp <> 'NONE' then
      begin
        frmVirus.txtvirusname.Caption := temp;
        frmVirus.txtviruslocation.Text := Namafile;
        frmvirus.ShowModal;
        frmMain.Log.Lines.Add('Virus detected : '+temp);
      end
    else
      begin
        frmMain.Log.Lines.Add('File clean.');
        jawaban := true;
      end;
    end
   else
    jawaban := true;
  end;
  result := jawaban;
end;


function TFrmMain.GetVersion : String;
var
  VerInfoSize: DWord;
  VerInfo: Pointer;
  VerValueSize: DWord;
  VerValue: PVSFixedFileInfo;
  Dummy: DWord;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    result := IntTostr(dwFileVersionMS shr 16);
    result := result+'.'+   IntTostr(dwFileVersionMS and $FFFF);
    result := result+'.'+   IntTostr(dwFileVersionLS shr 16);
    result := result+'.'+   IntTostr(dwFileVersionLS and $FFFF);
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

procedure HandleFileAccessRequest(name : pchar; messageBuf : pointer;
                                  messageLen : dword;answerBuf : pointer;
                                  answerLen : dword); stdcall;
var potong,temp,temp2 : string;
    pos1,pos2   : integer;
begin
  //with TFileAccessRequest(messageBuf^) do
  begin
    potong := String(TFileAccessRequest(MessageBuf^).ParentProcess);
    //Potong := Copy(Potong, 2, Length(Potong)-3);
   { if pos('"',Potong[Length(potong)-1]) > 0 then
      temp2 := Copy(ExtractFileName(Potong),0,length(extractfilename(potong))-1)
    else
      temp2 := Extractfilename(potong);
    }
    delete(Potong,Pos('"',potong),Pos('"',potong));
    delete(Potong,Pos('"',potong),Pos('"',potong));
    temp2 := Extractfilename(potong);
    potong := ExtractFilePath(potong)+temp2;
    pos1 := pos(':\',copy(potong,4,length(potong)));
    if pos1 > 0 then
    begin
      frmMain.Log.Lines.Add(copy(potong,pos1+2,length(potong)));
      boolean(answerBuf^) := FrmMain.Scan(copy(potong,pos1+2,length(potong))); // jika anda isi "false" maka program/prosess tdk akan berjalan
    end
  else
    begin
      frmMain.Log.Lines.Add(potong);
      boolean(answerBuf^) := FrmMain.Scan(potong);
    end;
  end;
end;

procedure OnProgress(FileScan: String; MessageInd: integer);
begin
end;

Procedure OnVirDetected(FileName,VirName: String;typedata:integer);
begin
end;

Procedure OnWarningHeur(FileName: String; Message:String);
begin
end;

Procedure OnReadError(FileName: String; MessageInd: integer);
begin
End;


Procedure OnScanComplete;
begin
end;

Procedure OnAddLocation(Infeksi, Location : String; ID : Integer; metode : integer);
begin
end;

Procedure OnScanStart;
begin

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  begin
    ShowWindow(Application.Handle, SW_HIDE);
    HideMefrom9xTaskList;
    SetWindowLong(Application.Handle, GWL_EXSTYLE,
      GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
    REsumeProcess('explorer.exe');
//  GetCPUUsage;
    trayicon.IconVisible := True;
    pisanwae := '';
    IsRTP := True;
    GlobalScan := True;
    Label1.Caption := 'SigmaAV RTP v.'+getversion+' [Beta Version]';
    CreateIpcQueueEx('17050906', HandleFileAccessRequest); // &lt;- disini sama nilainya sama dgn dll kita.
    if InjectLibrary((ALL_SESSIONS or SYSTEM_PROCESSES) and (not CURRENT_PROCESS), 'sigmahook.dll') then //uncomment untuk system wide
    begin
      Log.Lines.Add('Initialize hook.... OK');
      trayicon.ShowBalloonHint('SigmaAV - Real Time Protection','Your computer is fully protected.',bitinfo, 10);
    end
  else
    begin
      Log.Lines.Add('Initialize hook.... FAILED!');
      chkMati.Checked := true;
      chkAktif.Enabled := false;
      trayicon.ShowBalloonHint('SigmaAV - Real Time Protection','Failed to open sigmahook.dll, maybe deleted or corrupted.'+#13+'To repair this error, please re-install the application or contact F_Computer (xtfcomp@gmail.com)',biterror, 30);
    end;
  end
end;

procedure TfrmMain.InitSystem;
begin
  InitAvProc(OnProgress,OnVirDetected,OnWarningHeur,OnReadError,OnScanComplete,OnAddLocation,OnScanStart);
  LoadDataBases(ExtractFilePath(paramstr(0))+'DataBases\');
  Log.Lines.Add('Virus known : '+IntToStr(GetDBRecCount));
  Sigma := TAvScanner.Create(True);

  //InitAPI;
  //LoadApiPlugins(ExtractFilePath(paramstr(0))+'Plugins\');
end;

procedure TfrmMain.RTPTimer(Sender: TObject);
var
  i1, i2: Integer;
  s: string;

  HandleMAP,  // for win9X
  HandleCB,  // handle combobox
  HandleLV  :THandle;  // handle listview
  ProcessLV :Cardinal; // handle explorer process
  DatasLV   :PDatas;   // pointer to our info of...
  Datas     :TDatas;   // the item-captions itself
  ProcessID,
  N         : Cardinal;
  nama      : string;

  WindowsNT      :Boolean;  // win9X?
  VirtualAllocEx :TVirtualAllocEx;
  VirtualFreeEx  :TVirtualFreeEx;

begin
  HandleCB:= FindWindowEx(GetForeGroundWindow, 0, 'WorkerW'         , nil);
  if HandleCB= 0 then begin
    HandleLV:= FindWindowEx(0       , 0, 'ExploreWClass'   , Nil);
    HandleCB:= FindWindowEx(HandleLV, 0, 'WorkerW'         , nil);
  end else HandleLV:= GetForeGroundWindow;

  HandleCB:= FindWindowEx(HandleCB, 0, 'ReBarWindow32'   , nil);
  HandleCB:= FindWindowEx(HandleCB, 0, 'ComboBoxEx32'    , nil);  // we got the combobox
  if (HandleCB <> 0) then
  begin
    setlength(s, 300);  // reserve some space
    i1:= SendMessage(HandleCB, WM_GETTEXT, 300, longint(@s[1]));  // get combobox content
    setlength(s, i1);  // set string to the length we actually got
    if s[length(s)]<> '\' then
    s:= s+ '\';
    //showmessage(S);
    //if (pisanwae <> s) then
    begin
      RTP.Enabled := False;
  //    Sigma := TAvScanner.Create(True);
     // Sigma.AvAction := TRTPScan;
      //Sigma.DirName := S;
      if DirectoryExists(S) then
      begin
        Label1.Caption := 'Scanning : '+S;
        nama := RTPSCAN(s);
      end
     else
        nama := 'NONE';
      ShowMessage(Nama);
      if nama <> 'NONE' then
      begin
        trayicon.ShowBalloonHint('SigmaAV - Real Time Protection','File name : '+S+#13+'Virus found : '+RTPResult,bitinfo, 10);
        pisanwae := S;
        sigma.Suspend;
      end
     else
      begin
        pisanwae := s;
        RTP.Enabled := true;
        exit;
      end;
       pisanwae := s;
       RTP.Enabled := true;
     end
  end;

end;
procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  trayicon.Destroy;
  Pasangservis(false);
  UninjectLibrary(ALL_SESSIONS or SYSTEM_PROCESSES, 'sigmahook.dll'); //uncomment untuk system wide
  DestroyIpcQueue('17050906');
end;

procedure TfrmMain.chkAktifClick(Sender: TObject);
begin
  if chkaktif.Checked then
    if InjectLibrary((ALL_SESSIONS or SYSTEM_PROCESSES) and (not CURRENT_PROCESS), 'sigmahook.dll') then //uncomment untuk system wide
    begin
      Log.Lines.Add('Protection on.');
      trayicon.ShowBalloonHint('SigmaAV - Real Time Protection','Your computer is fully protected.',bitinfo, 10);
      Log.Lines.Add('Initialize hook.... OK');
      CreateIpcQueueEx('17050906', HandleFileAccessRequest); // &lt;- disini sama nilainya sama dgn dll kita.
      Log.Lines.Add('Protection on.');
    end
  else
    begin
     Log.Lines.Add('Initialize hook.... FAILED!');
     Log.Lines.Add('Unable to start RTP engine');
    end;
end;

procedure TfrmMain.chkMatiClick(Sender: TObject);
begin
  if chkMati.Checked then
  begin
    Log.Lines.Add('Protection off.');
    trayicon.ShowBalloonHint('SigmaAV - Real Time Protection','Your system is not protected.',biterror, 30);
    UninjectLibrary(ALL_SESSIONS or SYSTEM_PROCESSES, 'sigmahook.dll'); //uncomment untuk system wide
    DestroyIpcQueue('17050906');
  end;
end;

procedure TfrmMain.suiButton3Click(Sender: TObject);
begin
  trayicon.HideMainForm;
end;


procedure TfrmMain.Open1Click(Sender: TObject);
begin
  trayicon.ShowMainForm;
end;

procedure TfrmMain.Run1Click(Sender: TObject);
begin
  run1.Checked := not run1.Checked;
  chkAktif.Checked := run1.Checked;
  chkmati.Checked := not chkaktif.Checked;
end;

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  frmMain.Destroy;
end;

procedure TfrmMain.ShellNotify1Notify(Sender: TObject;
  Event: TShellNotifyEvent; Path1, Path2: String);
begin
  Case Event of
    neDriveAdd,neMediaInserted :
      begin
        SuspendProcess('explorer.exe');
        if fileexists(Path1+'autorun.inf') then
         begin
           Log.Lines.Add('Checking autorun file...');
          if ScanFileBiasa(Path1+'autorun.inf') <> 'NONE' then
          begin
            if DeleteFile(Path1+'autorun.inf') then
            begin
              ResumeProcess('explorer.exe');
              Log.Lines.Add('Drive is infected!');
              trayicon.ShowBalloonHint('SigmaAV - '+Getversion,'Sigma has detected a virus autorun and successfully deleted.',bitinfo, 10);
           end
          else
            begin
              ResumeProcess('explorer.exe');
              trayicon.ShowBalloonHint('SigmaAV - '+Getversion,'Sigma has detected a virus autorun and failed to deleted.',biterror, 10);
              RenameFile('autorun.inf','autorun.vir');
              Log.Lines.Add('Drive is infected, but failed to neutralize.');
            end;
          end
         else
          Log.Lines.Add('Drive clean.');

        ResumeProcess('explorer.exe');
      end;
    end;
 end;
end;

procedure TfrmMain.cmdaddClick(Sender: TObject);
begin
  if tmbahfile.Execute then
    blacklist.Items.Add(tmbahfile.FileName);
end;

procedure TfrmMain.cmdremoveClick(Sender: TObject);
begin
  blacklist.DeleteSelected;
end;

procedure TfrmMain.pgAboutClick(Sender: TObject);
begin
  ScrollingCredits1.Animate := true;
end;

procedure TfrmMain.chkOnTopClick(Sender: TObject);
begin
  if chkOnTop.Checked then
    SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE)
  else
    SetWindowPos(Handle,HWND_NoTOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE)
end;

end.
