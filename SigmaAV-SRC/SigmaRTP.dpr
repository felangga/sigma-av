program SigmaRTP;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  madCodeHook,
  madStrings,
  Windows,
  SysUtils,
  Forms,
  avKernel in 'avKernel.pas',
  avTypes in 'avTypes.pas',
  avScanner in 'avScanner.pas',
  avHex in 'avHex.pas',
  avDataBase in 'avDataBase.pas',
  avHash in 'avHash.pas',
  avExt in 'avExt.pas',
  avAPI in 'avAPI.pas',
  main in 'main.pas' {frmMain},
  VVirus in 'VVirus.pas' {frmVirus},
  block in 'block.pas' {frmBlock},
  antikill in 'antikill.pas';

{$R *.res}

function GetWindowsSysDir: string;
const
  (* The length of the directoy buffer. Usually 64 or even 32 is enough:)
  **
  ** Must be DWORD type.
  *)
  dwLength: DWORD = 255;
var
  pcSysDir: PChar;
begin
  GetMem(pcSysDir, dwLength);
  GetSystemDirectory(pcSysDir, dwLength);
  Result := string(pcSysDir);
  FreeMem(pcSysDir, dwLength);
end;


begin
  if FileExists(GetWindowsSysDir+'\madchook.dll') then begin
  if CreateIpcQueue(pchar('SigmaAntiKill' + IntToStr(GetCurrentSessionId)),
                    HandleProcessTerminationRequest) then begin
  if Inject(true) then
  begin
    // Hook Sigma Anti-Kill
    HookAPI('kernel32.dll', 'ExitProcess', @ExitProcessCallback, @ExitProcessNext);
    Application.Initialize;
    Application.Title := '?igma RTP';
    Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmVirus, frmVirus);
  Application.CreateForm(TfrmBlock, frmBlock);
  FrmMain.initsystem;
    Application.Run;
    UnhookAPI(@ExitProcessNext);
    Inject(false);
  end
 else
  MessageBox(0, 'FATAL ERROR : Failed to inject service process, may AntiKill.dll has been deleted or corrupted.','FATAL ERROR !', MB_ICONERROR);
 end
else
  MessageBox(0, 'SigmaRTP is already running.', 'Warning!', MB_ICONINFORMATION);
end
else
  MessageBox(0, 'File madCHook.dll not found in System32 windows folder.'+#13+'Please reinstall Sigma or you can download it from www.madshi.net','FATAL ERROR !', MB_ICONERROR);
end.
