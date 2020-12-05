
unit avTypes;

Interface

uses windows;

const
  MES_NONE         = 0;
  API_OTHER        = 1000;
  API_SCAN         = 1001;
  API_SCANATRUN    = 1002;
  API_SCANFILE     = 1003;
  
  MES_SCANDIR      = 1101;
  MES_SCANFILE     = 1102;
  MES_PLUGINWAIT   = 1103;
  MES_PLUGINEXIT   = 1104;
  MES_EXITFROMWAIT = 1121;

type

  OnProgress       = Procedure(FileScan: String; MessageInd: integer);
  OnMessage        = Function: integer;
  OnVirFound       = Procedure(FileName,VirName: String; typedata:integer);
  OnWarningHeur    = Procedure(FileName:String; Message:String);
  OnScanComplete   = Procedure;
  OnScanExecute    = Procedure;
  OnReadError      = Procedure(FileName: String; MessageInd: integer);
  OnAddToLog       = Procedure(Infeksi, Location : String; ID : Integer; metode : integer);

type
  TAvAction        = (TScanFile,TScanDir,TRTPScan,TRekursiDir);

var
  OnProgressProc        : OnProgress;
  OnVirFoundProc        : OnVirFound;
  OnWarningHeurProc     : OnWarningHeur;
  OnReadErrorProc       : OnReadError;
  OnScanCompleteProc    : OnScanComplete;
  OnScanExecuteProc     : OnScanExecute;
  OnAddToLogProc        : OnAddToLog;

implementation

end.

