program body;

{$mode objfpc}{$H+}
{$DEFINE UseCThreads}

uses
  {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads,
  cwstring, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main_mt, uos;

begin

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
