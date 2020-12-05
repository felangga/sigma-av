program SigmaNT;

{%ToDo 'SigmaNT.todo'}

uses
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
  uSelInfo in 'uSelInfo.pas' {InformationForm},
  uOptions in 'uOptions.pas' {OptionsForm},
  uPluginInfo in 'uPluginInfo.pas' {PluginAPIForm},
  uAddPath in 'uAddPath.pas' {AddUserPathForm},
  AboutFrm in 'AboutFrm.pas' {AboutForm},
  Crc32 in 'Crc32.pas',
  regedit in 'regedit.pas' {RegistryEditor},
  tskmgr in 'tskmgr.pas' {ProcKiller},
  VirDatabase in 'VirDatabase.pas' {frmVirusDatabase},
  heurico in 'heurico.pas' {heur},
  Plugin in 'Plugin.pas' {frmPlugin},
  repair in 'repair.pas' {frmrepair},
  Quarantine in 'Quarantine.pas' {frmQuar},
  Port in 'Port.pas' {frmPort},
  Command in 'Command.pas' {frmCMD},
  scan1file in 'scan1file.pas' {frmScanFile},
  Upload in 'Upload.pas' {frmUpload},
  NativeApi in 'NativeApi.pas',
  LDASM in 'LDASM.pas',
  procpath in 'procpath.pas',
  KSpoold in 'KSpoold.pas',
  update in 'update.pas' {frmUpdate};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TInformationForm, InformationForm);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TPluginAPIForm, PluginAPIForm);
  Application.CreateForm(TAddUserPathForm, AddUserPathForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TfrmVirusDatabase, frmVirusDatabase);
  Application.CreateForm(TRegistryEditor, RegistryEditor);
  Application.CreateForm(TProcKiller, ProcKiller);
  Application.CreateForm(Theur, heur);
  Application.CreateForm(TfrmPlugin, frmPlugin);
  Application.CreateForm(Tfrmrepair, frmrepair);
  Application.CreateForm(TfrmQuar, frmQuar);
  Application.CreateForm(TfrmPort, frmPort);
  Application.CreateForm(TfrmCMD, frmCMD);
  Application.CreateForm(TfrmScanFile, frmScanFile);
  Application.CreateForm(TfrmUpdate, frmUpdate);
  //  Application.CreateForm(TfrmUpload, frmUpload);
  //Application.CreateForm(TfrmSplash, frmSplash);
  MainForm.InitScannerKernel;
  {}
  if ParamStr(1) <> '' then
  MainForm.StartScan(ParamStr(1));
  {}
  Application.Run;
end.
