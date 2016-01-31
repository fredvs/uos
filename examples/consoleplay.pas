program consoleplay;

///WARNING : if FPC version < 2.7.1 => Do not forget to uncoment {$DEFINE ConsoleApp} in uos.pas and in uos_flat.pas !

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses {$IFDEF UNIX}
  cthreads,
  cwstring, {$ENDIF}
  Classes,
  SysUtils,
  CustApp,
  uos_flat,
  ctypes { you can add units after this };

type

  { TUOSConsole }

  TuosConsole = class(TCustomApplication)
  private
    procedure ConsolePlay;
  protected
    procedure doRun; override;
  public
    procedure Consoleclose;
    constructor Create(TheOwner: TComponent); override;
  end;


var
  res: integer;
  ordir, opath, sndfilename, PA_FileName, SF_FileName: string;
  PlayerIndex1: cardinal;
  In1Index : integer;

  { TuosConsole }

  procedure TuosConsole.ConsolePlay;
  begin
    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));

          {$IFDEF Windows}
     {$if defined(cpu64)}
    PA_FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    SF_FileName := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
{$else}
    PA_FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    SF_FileName := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
   {$endif}
    sndfilename := ordir + 'sound\test.flac';
 {$ENDIF}

 {$IFDEF linux}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    SF_FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    {$else}
    PA_FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    SF_FileName := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
{$endif}
    sndfilename := ordir + 'sound/test.flac';
 {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/freeBSD/64bit/libportaudio-64.so';
    SF_FileName := ordir + 'lib/freeBSD/64bit/libsndfile-64.so';
    {$else}
    PA_FileName := ordir + 'lib/freeBSD/32bit/libportaudio-32.so';
    SF_FileName := ordir + 'lib/freeBSD/32bit/libsndfile-32.so';
{$endif}
    sndfilename := ordir + 'sound/test.flac';
 {$ENDIF}


            {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    SF_FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    sndfilename := opath + '/sound/test.flac';
             {$ENDIF}
    PlayerIndex1 := 0;

    // Load the libraries
    // function uos_LoadLib(PortAudioFileName: Pchar; SndFileFileName: Pchar; Mpg123FileName: Pchar) : integer;

   res := uos_LoadLib(Pchar(PA_FileName), Pchar(SF_FileName), nil) ;

    writeln('Result of loading (if 0 => ok ) : ' + IntToStr(res));

   if res = 0 then begin
   uos_CreatePlayer(PlayerIndex1); //// Create the player

  In1Index := uos_AddFromFile(PlayerIndex1,(pchar(sndfilename)));

    uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, In1Index), -1, -1, -1);

    uos_Play(PlayerIndex1);
   end;

     end;

  procedure TuosConsole.doRun;
  begin
    ConsolePlay;
    writeln('Press a key to exit...');
      readln;
      uos_unloadLib();
      Terminate;
    end;

  procedure TuosConsole.ConsoleClose;
  begin
    Terminate;
  end;

  constructor TuosConsole.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

var
  Application: TUOSConsole;
begin
  Application := TUOSConsole.Create(nil);
  Application.Title := 'Console Player';
    Application.Run;
  Application.Free;
end.
