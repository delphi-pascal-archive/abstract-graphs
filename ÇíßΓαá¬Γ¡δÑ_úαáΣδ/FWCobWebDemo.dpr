program FWCobWebDemo;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmCobwebDemo},
  FWCobweb in 'Components\FWCobweb.pas',
  FWHelpers in 'Components\FWHelpers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmCobwebDemo, frmCobwebDemo);
  Application.Run;
end.
