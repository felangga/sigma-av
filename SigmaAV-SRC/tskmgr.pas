unit tskmgr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,tlhelp32, SUIMgr, SUIButton,  psAPI,
  SUIListView, SUIForm, Menus, SUIPopupMenu, Proses;

type
  P_TokenUser = ^User;
  User = record
    Userinfo: TSidAndAttributes;
  end;
  tUser = User;


type
  TProcKiller = class(TForm)
    Panel1: TPanel;
    suiForm1: TsuiForm;
    ProcList: TsuiListView;
    cmdKill: TsuiButton;
    cmdRefresh: TsuiButton;
    suiThemeManager1: TsuiThemeManager;
    Timer1: TTimer;
    chkauto: TsuiCheckBox;
    pilihan: TsuiPopupMenu;
    KillProcess1: TMenuItem;
    SuspendProcess1: TMenuItem;
    procedure RefreshTimer(Sender: TObject);
    procedure suitempcmdKillClick(Sender: TObject);
    procedure suitempcmdRefreshClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure chkautoClick(Sender: TObject);
    procedure KillProcess1Click(Sender: TObject);
    procedure SuspendProcess1Click(Sender: TObject);
  private
    { Private declarations }
    procedure listproses;
    function TutupProsesID(ID:THandle):boolean;
  public
    { Public declarations }
  end;

var
  ProcKiller: TProcKiller;
  lvi:TListitem;

implementation

{$R *.dfm}
uses UMain;

function TProcKiller.TutupProsesID(ID:THandle) : boolean;
//Disini kode untuk menututu proses
procedure TerminateProcessById(AID: Cardinal);
var
  HndProcess,ExCode : THandle;
begin
  //Baca Proses ID-nya
  HndProcess := OpenProcess(PROCESS_ALL_ACCESS,True,AID);
  GetExitCodeProcess(HndProcess,ExCode); {Dapatkan kode untuk menutupnya}
  TerminateProcess(HndProcess,ExCode) {Tutup prosess sekarang..!};
  CloseHandle(HndProcess); {Fresh Memory}
end;
{
 Nah ini kode untuk dapat mengakses proses service yang biasanya tidak bisa
 di terminate dengan kode biasa, untuk itu diperlukan kode tambahan
 berikut kodenya :
}
function SetPrivilege(aPrivilegeName: string; aEnabled: boolean): boolean;
var
  TP : TTokenPrivileges;
  TPPrev : TTokenPrivileges;
  Token : THandle;
  dwRetLen : DWord;
begin
  Result := False; //Nilai default
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, Token);
  TP.PrivilegeCount := 1;
  if (LookupPrivilegeValue(nil, PChar(aPrivilegeName), TP.Privileges[0].LUID)) then begin
    if (aEnabled) then
      TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
    else
      TP.Privileges[0].Attributes := 0;
    dwRetLen := 0;
    Result := AdjustTokenPrivileges(Token, False, TP, SizeOf(TPPrev), TPPrev, dwRetLen);
  end;
  CloseHandle(Token);
end;

function KillProcessByPID(pid: cardinal): boolean;
var
  hProc : THandle;
begin
  Result := False;
  //Untuk mematikan proses dibutuhkan kode privilege
  if not SetPrivilege('SeDebugPrivilege', True) then exit;
  hProc := OpenProcess(STANDARD_RIGHTS_REQUIRED or PROCESS_TERMINATE, False, pid);
  try
    if hProc > 0 then begin
      Result := TerminateProcess(hProc, 1);
    end;
  finally
    CloseHandle(hProc);
    SetPrivilege('SeDebugPrivilege', False);
  end;
end;

Begin
  Result := KillProcessByPID(ID); //Tutup proses ID sekarang juga...!
End;

Procedure TProcKiller.ListProses;
var
  User, Domain,Usage,Created: string;
  proc: TProcessEntry32; snap: THandle;
  mCreationTime,mExitTime,mKernelTime, mUserTime:_FILETIME;
  item:Tlistitem;
  HToken: THandle;
  rLength: Cardinal;
  ProcUser: P_Tokenuser;
  snu: SID_NAME_USE;
  ProcessHandle: THandle;
  UserSize, DomainSize: DWORD;
  bSuccess: Boolean;
  pmc: TProcessMemoryCounters;
begin
  pmc.cb := SizeOf(pmc) ;
   snap := CreateToolHelp32SnapShot(TH32CS_SNAPALL,0);
       proc.dwSize := SizeOf(TProcessEntry32);

       try
       Process32First(snap, proc);
        repeat
              ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, proc.th32ProcessID);
              if ProcessHandle <> 0 then
              begin

              if GetProcessMemoryInfo(Processhandle, @pmc, SizeOf(pmc)) then
              begin
                Usage := floatTostr(pmc.WorkingSetSize div 1024) + ' KB';
              end
            else
              begin
                Usage := '0';
              end;


              if OpenProcessToken(ProcessHandle, TOKEN_QUERY, hToken) then
              begin  bSuccess := GetTokenInformation(hToken, TokenUser, nil, 0, rLength);
              ProcUser  := nil;
              while (not bSuccess) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) do
              begin ReallocMem(ProcUser,rLength);bSuccess:=GetTokenInformation(hToken,TokenUser,ProcUser,rLength,rLength);end;

              CloseHandle(hToken);

              if not bSuccess then
              begin Exit; end;
              UserSize := 0;
              DomainSize := 0;
              LookupAccountSid(nil, ProcUser.Userinfo.Sid, nil, UserSize, nil, DomainSize, snu);
              if (UserSize <> 0) and (DomainSize <> 0) then
              begin
             SetLength(User, UserSize);
             SetLength(Domain, DomainSize);
             if LookupAccountSid(nil, ProcUser.Userinfo.Sid, PChar(User), UserSize,
             PChar(Domain), DomainSize, snu) then
             begin
              User :=PChar(User);
              Domain :=PChar(Domain);
             end;
             end;

            if bSuccess then
             begin
             FreeMem(ProcUser);
             end;
             end;
             CloseHandle(ProcessHandle);
             end;
             Item := proclist.Items.Add;
             Item.Caption := proc.szExeFile;
             item.SubItems.Add(User);
             item.SubItems.Add(domain);
             item.SubItems.Add(inttostr(proc.th32ProcessID));
             item.SubItems.Add(Usage);
             //item.SubItems.Add(created);
    until not Process32Next(snap, proc);
    finally
    CloseHandle(snap);
 end;

end;



procedure TProcKiller.RefreshTimer(Sender: TObject);
var
  hSnap:Cardinal;
  pe32:TProcessEntry32;
  s:String;
begin
  //Buat dahulu snapshootnya di mulai dari proses desktop
  hsnap:=CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS,0);
  if hSnap = INVALID_HANDLE_VALUE then
    exit;
  FillChar(pe32, sizeof(pe32),0);
  pe32.dwSize:=Sizeof(pe32);
  if not Process32First(hsnap, pe32) then
    exit;
  ProcList.Clear; //hapus seluruh list
  //tambahkan seluruh list dengan nama dan PID proses..
  repeat
    lvi:=ProcList.Items.Add;
    s:=IntToStr(pe32.th32ProcessID);
    lvi.caption := pe32.szExeFile;
    lvi.subitems.Add(s);
  until not Process32Next(hsnap, pe32);
  CloseHandle(hSnap);
end;

procedure TProcKiller.suitempcmdKillClick(Sender: TObject);
begin
  if MessageDlg('Do you want to kill '+ProcList.Selected.Caption+' process?',mtInformation,[mbYes]+[mbNo],0) = mrYes then
  if not TutupProsesID(strtoint(ProcList.Selected.SubItems[2])) then
    Messagedlg('Failed to close '+ProcList.Selected.Caption+' process.',mtError,[mbok],0);
  cmdRefresh.Click;
end;

procedure TProcKiller.suitempcmdRefreshClick(Sender: TObject);
var
  hSnap:Cardinal;
  pe32:TProcessEntry32;
  s:String;
begin
{  //Buat dahulu snapshootnya di mulai dari proses desktop
  hsnap:=CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS,0);
  if hSnap = INVALID_HANDLE_VALUE then
    exit;
  FillChar(pe32, sizeof(pe32),0);
  pe32.dwSize:=Sizeof(pe32);
  if not Process32First(hsnap, pe32) then
    exit;
  ProcList.Clear; //hapus seluruh list
  //tambahkan seluruh list dengan nama dan PID proses..
  repeat
    lvi:=ProcList.Items.Add;
    s:=IntToStr(pe32.th32ProcessID);
    lvi.caption := pe32.szExeFile;
    lvi.subitems.Add(s);
  until not Process32Next(hsnap, pe32);
  CloseHandle(hSnap);}
  ProcList.Clear;
  Listproses;
end;

procedure TProcKiller.FormShow(Sender: TObject);
begin
  cmdRefresh.Click;
end;

procedure TProcKiller.Timer1Timer(Sender: TObject);
begin
  ProcList.Clear;
  Listproses;
end;

procedure TProcKiller.chkautoClick(Sender: TObject);
begin
  Timer1.Enabled := chkAuto.Checked;
end;

procedure TProcKiller.KillProcess1Click(Sender: TObject);
begin
  cmdKill.Click;
end;

procedure TProcKiller.SuspendProcess1Click(Sender: TObject);
begin
  if MessageDlg('Do you want to suspend '+ProcList.Selected.Caption+' process?',mtInformation,[mbYes]+[mbNo],0) = mrYes then
    if SuspendProcess(ProcList.Selected.Caption) then
      ProcList.Selected.Caption := ProcList.Selected.Caption + ' [suspended]'
    else
      ShowMessage('Failed to suspend '+ProcList.Selected.Caption+' process.');
  cmdRefresh.Click;
end;

end.
