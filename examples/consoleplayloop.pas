program consoleplayloop;

///WARNING : if FPC version < 2.7.1 => Do not forget to uncoment {$DEFINE consoleapp} in uos_define.inc !

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses
{$IFDEF UNIX}
  cthreads, 
  cwstring, {$ENDIF}
  Classes,
  SysUtils,
  CustApp,
  uos_flat;

type

  { TUOSConsole }

  TuosConsole = class(TCustomApplication)
  private
    procedure consoleplay;
  protected
    procedure doRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
  end;

var
  res: integer;
  ordir, opath, SoundFilename, PA_FileName, SF_FileName: string;
  PlayerIndex1 : integer;
  
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
    SoundFilename := ordir + 'sound\test.flac';
 {$ENDIF}

  {$if defined(CPUAMD64) and defined(linux) }
    PA_FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    SF_FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    SoundFilename := ordir + 'sound/test.flac';
   {$ENDIF}
   
  {$if defined(cpu86) and defined(linux)}
    PA_FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    SF_FileName := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
   SoundFilename := ordir + 'sound/test.flac';
 {$ENDIF}

  {$if defined(CPUAMD64) and defined(openbsd) }
  SF_FileName := ordir + 'lib/OpenBSD/64bit/LibSndFile-64.so';
  PA_FileName := ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so';
  SoundFilename := ordir + 'sound/test.flac';
 {$ENDIF}
 
  {$if defined(linux) and defined(cpuaarch64)}
  PA_FileName := ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so';
  SF_FileName := ordir + 'lib/Linux/aarch64_raspberrypi/libsndfile_aarch64.so';
  SoundFilename := ordir + 'sound/test.flac';
  {$ENDIF}
 
  {$if defined(linux) and defined(cpuarm)}
    PA_FileName := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
    SF_FileName := ordir + ordir + 'lib/Linux/arm_raspberrypi/libsndfile-arm.so';
      SoundFilename := ordir + 'sound/test.flac';
 {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    SF_FileName := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    {$else}
    PA_FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    SF_FileName := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    {$endif}
    SoundFilename := ordir + 'sound/test.flac';
 {$ENDIF}

 {$IFDEF Darwin}
  {$IFDEF CPU32}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    SF_FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    SoundFilename := ordir + '/sound/test.flac';
    {$ENDIF}
  
   {$IFDEF CPU64}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
    SF_FileName := opath + '/lib/Mac/64bit/LibSndFile-64.dylib';
    SoundFilename := ordir + '/sound/test.flac';
    {$ENDIF}  
 {$ENDIF}
 
 {$if defined(CPUAMD64) and defined(linux) }
     // For Linux amd64, check libsndfile.so
  if SF_FileName <> 'system' then
  if uos_TestLoadLibrary(PChar(SF_FileName)) = false then
   SF_FileName := SF_FileName + '.2';
{$endif}
 
    // Load the libraries
   // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName,  opusfilefilename, libxmpfilename: PChar) : LongInt;

   res := uos_LoadLib(Pchar(PA_FileName), Pchar(SF_FileName), nil, nil, nil, nil, nil) ;

    writeln('Result of loading (if 0 => ok ) : ' + IntToStr(res));

   if res = 0 then begin

    //// Create the player.
    //// PlayerIndex : from 0 to what your computer can do !
    //// If PlayerIndex exists already, it will be overwriten...
  
   PlayerIndex1 := 0;
  if uos_CreatePlayer(PlayerIndex1) then

    //// add a Input from audio-file with default parameters
    //////////// PlayerIndex : Index of a existing Player
    ////////// FileName : filename of audio file
    //  result : -1 nothing created, otherwise Input Index in array
    
   if uos_AddFromFile(PlayerIndex1,(pchar(SoundFilename))) > -1 then

    //// add a Output into device with default parameters
    //////////// PlayerIndex : Index of a existing Player
    //  result : -1 nothing created, otherwise Output Index in array
    
      {$if defined(cpuarm) or defined(cpuaarch64)}  // need a lower latency
     if uos_AddIntoDevOut(PlayerIndex1, -1, 0.3, -1, -1, -1, -1, -1) > -1 then
       {$else}
        if uos_AddIntoDevOut(PlayerIndex1) > -1 then
       {$endif}

      /////// everything is ready, here we are, lets play it 3 times...
    uos_Play(PlayerIndex1, 3);
   
    sleep(5000);
   end;

 end;

  procedure TuosConsole.doRun;
  begin
    ConsolePlay;
    uos_free();
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
