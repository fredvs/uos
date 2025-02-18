program conswebstream;

///WARNING : needs FPC version > 3.0.1

{$mode objfpc}{$H+}
{$DEFINE UseCThreads}
uses
  cmem,
 {$IFDEF UNIX}
  cthreads,
   {$ENDIF}
  Classes,
  // ctypes,
  SysUtils,
  //uos_opusurl,
  uos_flat;

var
  res, res2: integer;
  ordir, opath, PA_FileName, MP_FileName, OF_FileName, theurl: string;
  theicytag: PChar;
  PlayerIndex1: integer;

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

    {$if defined(CPUAMD64) and defined(linux) }
    PA_FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    MP_FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    OF_FileName := ordir + 'lib/Linux/64bit/LibOpusFile-64.so';
    {$endif}

    {$if defined(cpu86) and defined(linux)}
    PA_FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    MP_FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    {$endif}

  {$if defined(linux) and defined(cpuaarch64)}
  PA_FileName := ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so';
  MP_FileName := ordir + 'lib/Linux/aarch64_raspberrypi/libmpg123_aarch64.so';
  {$ENDIF}

  {$if defined(linux) and defined(cpuarm)}
    PA_FileName := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
    MP_FileName := ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so';
   {$ENDIF}

 {$if defined(CPUAMD64) and defined(openbsd) }
  SF_FileName := ordir + 'lib/OpenBSD/64bit/LibSndFile-64.so';
  MP_FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
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
  {$IFDEF CPU32}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    MP_FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
     {$ENDIF}
  
   {$IFDEF CPU64}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
    MP_FileName := opath + '/lib/Mac/64bit/LibMpg123-64.dylib';
    {$ENDIF}  
 {$ENDIF}

 // Load the libraries
   // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName,  opusfilefilename, libxmpfilename: PChar) : LongInt;
  // for web streaming => Mpg123 is needed

  res := uos_LoadLib(PChar(PA_FileName), nil, PChar(MP_FileName), nil, nil, PChar(OF_FileName), nil);
  writeln('');
  if res = 0 then
    writeln('===> Libraries are loaded.')
  else
    writeln('===> Libraries are NOT loaded.');

  PlayerIndex1 := 0;
  uos_CreatePlayer(PlayerIndex1); //// Create the player
  writeln('===> uos_CreatePlayer => ok');

  //  theurl := 'http://broadcast.infomaniak.net:80/alouette-high.mp3';
  // theurl := 'http://www.alouette.fr/alouette.m3u' ;
  // theurl := 'http://broadcast.infomaniak.net/start-latina-high.mp3' ;
  // theurl := 'http://www.hubharp.com/web_sound/BachGavotteShort.mp3' ;
  // theurl := 'http://www.jerryradio.com/downloads/BMB-64-03-06-MP3/jg1964-03-06t01.mp3' ;
  // theurl := 'https://sites.google.com/site/fredvsbinaries/willi.opus';
  theurl := 'http://stream-uk1.radioparadise.com/mp3-128';
  // for opus file, set AudioFormat = 1 in AddFromURL()
  //  theurl := 'https://sites.google.com/site/fredvsbinaries/guit_kungs.opus';

 {
 with TfpHttpClient.Create(nil) do
   try   WriteLn(Get(theurl));
    finally  Free;
   end;
   }

  writeln('Try to connect to ' + theurl);
  // res := uos_AddFromURL(PlayerIndex1,pchar(theurl)) ;
  res := uos_AddFromURL(PlayerIndex1, PChar(theurl), -1, -1, -1, -1, False);

  ////////// URL : URL of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
  ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (1024)
  //////////// AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
  ///////////// ICY data enabled 

  if res < 0 then
    writeln('===> uos_AddFromURL => NOT OK:' + IntToStr(res))
  else
  begin
    writeln('===> uos_AddFromURL => OK :' + IntToStr(res));

    //// add a Output  => change framecount => 1024

     {$if defined(cpuarm) or defined(cpuaarch64)}  // need a lower latency
      res2 := uos_AddIntoDevOut(PlayerIndex1, -1, 0.3, uos_InputGetSampleRate(PlayerIndex1, res), -1, -1, 1024, -1);
      {$else}
    res2 := uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, res), -1, -1, 1024, -1);
     {$endif}

    ////// Add a Output into Device Output
    //////////// Device ( -1 is default device )
    //////////// Latency  ( -1 is latency suggested )
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : default : -1 (2:Int16) (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (= 4096)
    // ChunkCount : default : -1 (= 512)

    if res2 <> -1 then
      writeln('===> uos_AddIntoDevOut => ok :' + IntToStr(res2))
    else

      writeln('===> uos_AddIntoDevOut => NOT ok');
    if res <> -1 then
    begin
      writeln('===> All ready to play.');
      writeln('Press a key to play...');
      writeln('After, press a key to exit...');

    end
    else
      writeln();
    readln;

    /// OK, let play it.
    if res <> -1 then
      uos_Play(PlayerIndex1);
 { 
    sleep(3000);
   uos_inputupdateicy(PlayerIndex1,0,theicytag);
   writeln('icy = ' + (theicytag));
   sleep(3000);
   uos_inputupdateicy(PlayerIndex1,0,theicytag);
   writeln('icy = ' + (theicytag));
// }

    writeln('Press a key to exit...');
  end;
  readln;
  uos_free;

end.

