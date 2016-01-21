program JsonFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitJsonFmx in 'UnitJsonFmx.pas' {Form1},
  XSuperJSON in 'x-superobject-master\XSuperJSON.pas',
  XSuperObject in 'x-superobject-master\XSuperObject.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown:= True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
