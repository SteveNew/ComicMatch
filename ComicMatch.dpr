program ComicMatch;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {mainForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Tablet Light');
  Application.Title := 'ComicMatch';
  Application.CreateForm(TmainForm, mainForm);
  Application.Run;
end.
