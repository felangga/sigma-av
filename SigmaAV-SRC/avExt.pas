unit avExt;

Interface

uses Classes;

Var
  ExestensionList     : TStringList;
  APIExestensionList  : TStringList;
  QuarantineList      : TStringList;

Procedure InitExestensionList;
Procedure FreeExestensionList;
Procedure InitQuarantineList;
Procedure FreeQuarantineList;

implementation

Procedure InitExestensionList;
begin
  APIExestensionList  := TStringList.Create;
  ExestensionList     := TStringList.Create;
end;

Procedure InitQuarantineList;
begin
  QuarantineList := TStringList.Create;
end;

Procedure FreeExestensionList;
begin
  ExestensionList.Free;
  APIExestensionList.Free;
end;

Procedure FreeQuarantineList;
begin
  QuarantineList.Free;
end;

end.
