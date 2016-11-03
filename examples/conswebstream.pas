program conswebstream;

///WARNING : needs FPC version > 2.7.1

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses
 {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  ctypes,
  SysUtils,
  Math,
  CustApp,
  uos_flat;

type

  { TUOSConsole }

  TuosConsole = class(TCustomApplication)
  private
    procedure ConsolePlay;
  protected
    procedure doRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
  end;

var
  res: integer;
  ordir, opath, PA_FileName, MP_FileName, theurl : string;
  PlayerIndex1: cardinal;

   { TuosConsole }

  procedure TuosConsole.ConsolePlay;
  begin

  ordir := (ExtractFilePath(ParamStr(0)));

 {$IFDEF Windows}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    MP_FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
    {$else}
    PA_FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    MP_FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
    {$endif}
 {$ENDIF}

 {$IFDEF linux}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    MP_FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    {$else}
    PA_FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    MP_FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    {$endif}
 {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    MP_FileName := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    {$else}
    PA_FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    MP_FileName := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
    {$endif}
 {$ENDIF}

 {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    MP_FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
 {$ENDIF}
    
    // Load the libraries
    // function uos_LoadLib(PortAudioFileName: Pchar; SndFileFileName: Pchar; Mpg123FileName: Pchar) : integer;
    // for web streaming => Mpg123 is needed

    res := uos_LoadLib(Pchar(PA_FileName), nil, Pchar(MP_FileName), nil, nil) ;
    if res = 0 then  writeln('===> Libraries are loaded.') else
       writeln('===> Libraries are NOT loaded.') ;
     
     PlayerIndex1 := 0;
     uos_CreatePlayer(PlayerIndex1); //// Create the player
     writeln('===> uos_CreatePlayer => ok');

    theurl := 'http://broadcast.infomaniak.net:80/alouette-high.mp3';
 // theurl := 'http://www.alouette.fr/alouette.m3u' ;
 // theurl := 'http://broadcast.infomaniak.net/start-latina-high.mp3' ;
 // theurl := 'http://www.hubharp.com/web_sound/BachGavotteShort.mp3' ;
 // theurl := 'http://www.jerryradio.com/downloads/BMB-64-03-06-MP3/jg1964-03-06t01.mp3' ;

   {
 with TfpHttpClient.Create(nil) do
   try   WriteLn(Get(theurl));
    finally  Free;
   end;
  // }

   uos_AddFromURL(PlayerIndex1,pchar(theurl)) ;

     writeln('===> uos_AddFromURL => ok');

      //// add a Output  => change framecount => 1024
     uos_AddIntoDevOut(PlayerIndex1, -1, -1, -1, -1, -1, 1024);
     writeln('===> uos_AddIntoDevOut => ok');
     writeln('===> All ready to play.');
     writeln('Press a key to play...');
     readln;
     
     /// OK, let play it.
         
     uos_Play(PlayerIndex1);
 
  end;

  procedure TuosConsole.doRun;
  begin
    ConsolePlay;
    writeln('Press a key to exit...');
      readln;
      uos_unloadLib();
      uos_free;
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
  Application.Title := 'Console Web Player';
    Application.Run;
  Application.Free;
end.
