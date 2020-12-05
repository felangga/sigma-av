program debug;

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
  Crc32 in 'Crc32.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SigmaAV';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TInformationForm, InformationForm);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TPluginAPIForm, PluginAPIForm);
  Application.CreateForm(TAddUserPathForm, AddUserPathForm);
  Application.CreateForm(TAboutForm, AboutForm);
  MainForm.InitScannerKernel;
  {}
  if ParamStr(1) <> '' then
  MainForm.StartScan(ParamStr(1));
  {}
  Application.Run;
end.
