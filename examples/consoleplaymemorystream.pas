program consoleplaymemorystream;

///WARNING : if FPC version < 2.7.1 => Do not forget to uncoment {$DEFINE consoleapp} in uos_define.inc !

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses
 {$IFDEF UNIX}
  cthreads,
  cwstring,  {$ENDIF}
  Classes,
  ctypes,
  SysUtils,
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
  ordir, opath, SoundFilename, PA_FileName, SF_FileName, MP_FileName: string;
  PlayerIndex1, InputIndex1: integer;
  thememorystream1, thememorystream2: Tmemorystream;
 
  { TuosConsole }

  procedure TuosConsole.ConsolePlay;
  begin
    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));

 {$IFDEF Windows}
  {$if defined(cpu64)}
    PA_FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    SF_FileName := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
    MP_FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
    {$else}
    PA_FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    SF_FileName := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
    MP_FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
  {$endif}
    SoundFilename := ordir + 'sound\test.flac';
 {$ENDIF}

 {$IFDEF linux}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    SF_FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    MP_FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    {$else}
    PA_FileName   := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    SF_FileName   := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
    MP_FileName   := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    {$endif}
    SoundFilename := ordir + 'sound/test.flac';
    {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    SF_FileName := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    MP_FileName := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    {$else}
    PA_FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    SF_FileName := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    MP_FileName := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
    {$endif}
    SoundFilename := ordir + 'sound/test.flac';
 {$ENDIF}

  {$if defined(CPUAMD64) and defined(openbsd) }
  SF_FileName := ordir + 'lib/OpenBSD/64bit/LibSndFile-64.so';
  PA_FileName := ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so';
  MP_FileName := ordir + 'lib/OpenBSD/64bit/LibMpg123-64.so';
  SoundFilename := ordir + 'sound/test.flac';
 {$ENDIF}

{$IFDEF Darwin}
  {$IFDEF CPU32}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    SF_FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    MP_FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
    SoundFilename := ordir + '/sound/test.flac';
    {$ENDIF}
  
   {$IFDEF CPU64}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
    SF_FileName := opath + '/lib/Mac/64bit/LibSndFile-64.dylib';
    MP_FileName := opath + '/lib/Mac/64bit/LibMpg123-64.dylib';
    SoundFilename := ordir + '/sound/test.flac';
    {$ENDIF}  
 {$ENDIF}

{$if defined(CPUAMD64) and defined(linux) }
     // For Linux amd64, check libsndfile.so
  if (SF_FileName <> 'system') and  (SF_FileName <> '') then
  if uos_TestLoadLibrary(PChar(SF_FileName)) = false then
   SF_FileName := SF_FileName + '.2';
{$endif}

    // Load the libraries
   // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName,  opusfilefilename, libxmpfilename: PChar) : LongInt;
    res := uos_LoadLib(PChar(PA_FileName), PChar(SF_FileName), PChar(MP_FileName), nil, nil, nil, nil);

    writeln('Result of loading (if 0 => ok ) : ' + IntToStr(res));

    if res = 0 then
    begin
      InputIndex1  := -1;
      PlayerIndex1 := 0;

      //   Create a memory stream from a audio file wav, ogg, flac, mp3, opus.
      thememorystream1          := TMemoryStream.Create;
      thememorystream1.LoadFromFile(PChar(SoundFilename));
      thememorystream1.Position := 0;

      if uos_CreatePlayer(PlayerIndex1) then
      
      // Add a input from device mic with custom parameters
         // InputIndex1 :=  uos_AddFromDevIN(PlayerIndex1, -1, -1, -1, -1, 0, 1024 * 8, -1);
       
      InputIndex1 := uos_AddFromMemoryStream(PlayerIndex1, thememorystream1, -1, -1, 2, 1024 * 8);
      // Add a input from memory stream with custom parameters
      // MemoryStream : Memory stream of encoded audio.
      // TypeAudio : default : -1 --> 0 (0: flac, ogg, wav; 1: mp3; 2:opus)
      // OutputIndex : Output index of used output
              // -1: all output, -2: no output, other a existing OutputIndex 
               // (if multi-output then OutName = name of each output separeted by ';')
      // SampleFormat : default : -1 (2:Int16) (0: Float32, 1:Int32, 2:Int16)
      // FramesCount : default : -1 (4096)
      //  Result :  Input Index in array  -1 = error
      // example : InputIndex1 := uos_AddFromMemoryStream(mymemorystream,-1,-1,2,44100,0,1024);

      if InputIndex1 > -1 then
      begin

        writeln('uos_InputLength = ' + IntToStr(uos_inputlength(0, 0)));

      // add a Output into device with custom parameters
        {$if defined(cpuarm) or defined(cpuaarch64)}  // need a lower latency
       uos_AddIntoDevOut(PlayerIndex1, -1, 0,3, uos_inputgetSampleRate(PlayerIndex1,InputIndex1), 
       uos_inputgetChannels(PlayerIndex1,input1) , 0, 1024 * 8, -1);
       {$else}
       uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_inputgetSampleRate(PlayerIndex1, InputIndex1),
       uos_inputgetChannels(PlayerIndex1, InputIndex1), 2, 1024 * 8, -1);
       {$endif}

      // create a other memorystream from the first one encoding in ogg format.
       uos_AddIntoMemoryStream(PlayerIndex1, thememorystream2, -1, 2, 2, 1024 * 8, 1);

     /////// everything is ready, here we are, lets play it...
       uos_Play(PlayerIndex1);
       sleep(3000);
        
       uos_Stop(PlayerIndex1); // This if device mic was used
       sleep(500);

        // OK, let's use the new ogg-memorystream.
         
        PlayerIndex1 := 1;

        thememorystream2.Position := 0;

        // creata a new player
        if uos_CreatePlayer(PlayerIndex1) then

          uos_AddFromMemoryStream(PlayerIndex1, thememorystream2, -1, -1, 2, 1024 * 4);
        // Add a input from memory stream with custom parameters
        // MemoryStream : Memory stream of encoded audio.
        // TypeAudio : default : -1 --> 0 (0: flac, ogg, wav; 1: mp3; 2:opus)
        // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
        // SampleFormat : default : -1 (2:Int16) (0: Float32, 1:Int32, 2:Int16)
        // FramesCount : default : -1 (4096)
        //  result :  Input Index in array  -1 = error
        // example : InputIndex1 := uos_AddFromMemoryStream(mymemorystream,-1,-1,2,44100,0,1024);

        // add a Output into device with custom parameters
         uos_AddIntoDevOut(PlayerIndex1, -1, -1, -1, 2, 2, 1024 * 4, -1);
   
        /////// everything is ready, here we are, lets play it...
         uos_Play(PlayerIndex1);

         sleep(3000);

      end
      else
        writeln('uos_AddFromMemoryStream(...) did not work... ');

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
  Application       := TUOSConsole.Create(nil);
  Application.Title := 'Console Player from MemoryStream';
  Application.Run;
  Application.Free;
end.

begin
end.

