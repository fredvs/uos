
program simplewebplayer;

{$mode objfpc}{$H+}
 {$DEFINE UseCThreads}

uses
  cmem,
  {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads,
  cwstring, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  main_wsp { you can add units after this };

begin
  Application.Title:='SimpleWebPlayer';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.


