program formspectrum;

{$mode objfpc}{$H+}

uses

  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, formspectrum_unit
  { you can add units after this };

{$R *.res}

begin
//  RequireDerivedFormResource:=True;
//  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

