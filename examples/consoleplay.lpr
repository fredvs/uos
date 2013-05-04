program consoleplay;

/// Warning : Do not forget to uncoment {$DEFINE Console} in uos.pas !

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses
  {$IFDEF UNIX}
  cthreads, cwstring,
  {$ENDIF}
  Classes, SysUtils, CustApp, uos, ctypes
  { you can add units after this };

type

  { TUOSConsole }

  TUOSConsole = class(TCustomApplication)
  private
    procedure ConsolePlay;
     protected
    procedure doRun; override;
  public
    procedure Consoleclose;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
     end;


  var
  Init: TUOS_Init;
  Player1: TUOS_Player;
  index : integer;
  ordir, opath, res, sndfilename: string;

{ TUOSConsole }

procedure TUOSConsole.ConsolePlay;
  begin
       ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
        Init := TUOS_Init.Create;   //// Create Iibraries Loader-Init
         Init.Flag := LoadPA_MP;
         {$IFDEF Windows}
     {$if defined(cpu64)}
  Init.PA_FileName:= ordir + 'lib\LibPortaudio-64.dll';
{$else}
  Init.PA_FileName := ordir + 'lib\LibPortaudio-32.dll';
   {$endif}
  sndfilename := ordir + 'sound\test.mp3';
 {$ENDIF}

 {$IFDEF linux}
    {$if defined(cpu64)}
  Init.PA_FileName :=  ordir + 'lib/LibPortaudio-64.so';
{$else}
  Init.PA_FileName := ordir + 'lib/LibPortaudio-32.so';
{$endif}
    sndfilename := ordir + 'sound/test.mp3';
            {$ENDIF}

            {$IFDEF Darwin}
              opath := ordir;
              opath := copy(opath, 1, Pos('/UOS', opath) - 1);
              Init.PA_FileName := opath + '/lib/LibSndFile-32.dylib';
                sndfilename := opath + '/sound/test.mp3';
                        {$ENDIF}

    {$IFDEF Windows}
       {$if defined(cpu64)}
 Init.MP_FileName :=ordir + 'lib\LibMpg123-64.dll';
{$else}
  Init.MP_FileName := ordir + 'lib\LibMpg123-32.dll';
{$endif}
 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  Init.MP_FileName := opath + '/lib/LibMpg123-32.dylib';
            {$ENDIF}

   {$IFDEF linux}
      {$if defined(cpu64)}
  Init.MP_FileName := ordir + 'lib/LibMpg123-64.so';
{$else}
  Init.MP_FileName := ordir + 'lib/LibMpg123-32.so';
{$endif}

            {$ENDIF}
     res :=  inttostr(Init.LoadLib) ;
    writeln('Result of loading (if 0 = ok ) : ' + res) ;
         Player1 := TUOS_Player.Create(True,self); //// Create the player
       Player1.AddIntoDevOut();   //// add a Output into device with custom parameters
       Player1.AddFromFile(sndfilename);
        Player1.Play;
        sleep(2000);
       end;

procedure TUOSConsole.doRun;


begin
     inc(index);
     ConsolePlay;
  if index = 3 then Terminate;
end;

procedure TUOSConsole.ConsoleClose;

begin
   Terminate;
end;

constructor TUOSConsole.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TUOSConsole.Destroy;
begin
  inherited Destroy;
end;

var
  Application: TUOSConsole;
begin
  Application:=TUOSConsole.Create(nil);
  Application.Title:='Console Player';
  index := 0;
  Application.Run;
  Application.Free;
end.

