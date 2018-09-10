program noiseremover;

{$mode objfpc}{$H+}
 {$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}
  cthreads,
  cwstring, {$ENDIF} 
  Interfaces, // this includes the LCL widgetset
  ctypes,
  Forms,
  main_nr { you can add units after this };

begin
  Application.Title := 'SimplePlayer';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.


