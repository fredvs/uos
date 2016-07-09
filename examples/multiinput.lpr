program multiinput;

{$mode objfpc}{$H+}
 {$DEFINE UseCThreads}

uses
  {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads,
  cwstring, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  main_mi { you can add units after this };

 {$R *.res}
begin
  Application.Title := 'MultiInput';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.


