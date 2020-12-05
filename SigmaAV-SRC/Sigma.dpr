program Sigma;

{%ToDo 'Sigma.todo'}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  avKernel in 'avKernel.pas',
  avTypes in 'avTypes.pas',
  avScanner in 'avScanner.pas',
  avHex in 'avHex.pas',
  avDataBase in 'avDataBase.pas',
  avHash in 'avHash.pas',
  avExt in 'avExt.pas',
  avAPI in 'avAPI.pas',
  uMain in 'uMain.pas' {MainForm},
  uOptions in 'uOptions.pas' {OptionsForm},
  uPluginInfo in 'uPluginInfo.pas' {PluginAPIForm},
  uAddPath in 'uAddPath.pas' {AddUserPathForm},
  AboutFrm in 'AboutFrm.pas' {AboutForm},
  Crc32 in 'Crc32.pas',
  regedit in 'regedit.pas' {RegistryEditor},
  tskmgr in 'tskmgr.pas' {ProcKiller},
  VirDatabase in 'VirDatabase.pas' {frmVirusDatabase},
  Plugin in 'Plugin.pas' {frmPlugin},
  Quarantine in 'Quarantine.pas' {frmQuar},
  Port in 'Port.pas' {frmPort},
  Command in 'Command.pas' {frmCMD},
  scan1file in 'scan1file.pas' {frmScanFile},
  NativeApi in 'NativeApi.pas',
  LDASM in 'LDASM.pas',
  procpath in 'procpath.pas',
  KSpoold in 'KSpoold.pas',
  update in 'update.pas' {frmUpdate},
  VirFound in 'VirFound.pas' {frmVFound},
  Stealth in 'Stealth.pas';

{$R *.res}

var i : integer;
    s,s2: string;

begin
  Application.Initialize;
  Application.Title := '';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TPluginAPIForm, PluginAPIForm);
  Application.CreateForm(TAddUserPathForm, AddUserPathForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TfrmVirusDatabase, frmVirusDatabase);
  Application.CreateForm(TRegistryEditor, RegistryEditor);
  Application.CreateForm(TProcKiller, ProcKiller);
  Application.CreateForm(TfrmPlugin, frmPlugin);
  Application.CreateForm(TfrmVFound, frmVFound);
  Application.CreateForm(TfrmQuar, frmQuar);
  Application.CreateForm(TfrmPort, frmPort);
  Application.CreateForm(TfrmScanFile, frmScanFile);
  Application.CreateForm(TfrmUpdate, frmUpdate);
  {}
  MainForm.InitScannerKernel;
  if (ParamStr(1) <> '') and (ParamStr(1) <> '/hid') then
  begin
    for i := 1 to ParamCount do
    begin
      s := ParamStr(i);
      s2:= S2+' '+S;
    end;
    MainForm.StartScan(s2);
  end;

  {}

  Application.Run;
end.
