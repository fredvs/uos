program simpleplayer;

{$mode objfpc}{$H+}
 {$DEFINE UseCThreads}

uses
{$IFDEF UNIX}{$IFDEF UseCThreads}
  cmem,   // Yes or No ?
  cthreads,
{$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main_sp
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='SimplePlayer';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

