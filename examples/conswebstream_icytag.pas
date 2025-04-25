program conswebstream_icytag;

///WARNING : needs FPC version > 3.0.1

{$mode objfpc}{$H+}
{$DEFINE UseCThreads}
uses
 {$IFDEF UNIX}
  cthreads,
      {$ENDIF}
  Classes,
  SysUtils,
  CustApp,
  fpTimer,
  uos_flat;

type

  { TConsoleApp }
  TConsoleApp = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure geticy();
  end;

var
  ordir, opath, PA_FileName, MP_FileName, theurl: string;
  icystr: string;
  res, PlayerIndex1, InputIndex1, OutputIndex1, inctime: integer;


  procedure TConsoleApp.geticy();
  var
    aname, apicture, prefix: string;
    ares: integer;
    sicy: PChar;
  begin
    checksynchronize(uos_InputUpdateICY(PlayerIndex1, InputIndex1, sicy));
    if sicy <> nil then
    begin
      if icystr <> sicy then
      begin
        if system.Pos('StreamTitle=', sicy) > 0 then
        begin
          aname := Copy(sicy, system.pos('StreamTitle=', sicy) + 12, Length(sicy));
          aname := Copy(aname, 1, system.Pos(';', aname) - 1);
        end;

        if system.Pos('StreamUrl=', sicy) > 0 then
        begin
          apicture := Copy(sicy, system.pos('StreamUrl=', sicy) + 10, Length(sicy));
          apicture := Copy(apicture, 2, system.Pos(';', apicture) - 1);
          apicture := Copy(apicture, 1, system.Pos('''', apicture) - 1);
        end;
        writeln();
        writeln(aname);
        writeln(apicture);
        icystr := sicy;

      end;
    end
    else
      writeln('ticy is nil');

  end;

  procedure TConsoleApp.DoRun;
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

    res := uos_LoadLib(PChar(PA_FileName), nil, PChar(MP_FileName), nil, nil, nil, nil);
    writeln('');
    if res = 0 then
      writeln('===> Libraries are loaded.')
    else
      writeln('===> Libraries are NOT loaded.');

    PlayerIndex1 := 0;
    uos_CreatePlayer(PlayerIndex1); //// Create the player
    writeln('===> uos_CreatePlayer => ok');

    theurl := 'http://stream-uk1.radioparadise.com/mp3-128';

    writeln('Try to connect to ' + theurl);

    InputIndex1 := uos_AddFromURL(PlayerIndex1, PChar(theurl), -1, -1, -1, -1, True);
    ////////// URL : URL of audio file
    ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
    ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (1024)
    //////////// AudioFormat : default : -1 (auto-find) (0: mp3, 1: opus, 2:aac)
    ///////////// ICY data enabled 

    if InputIndex1 < 0 then
      writeln('===> uos_AddFromURL => NOT OK')
    else
    begin
      writeln('===> uos_AddFromURL => OK');

      //// add a Output  => change framecount => 1024

     {$if defined(cpuarm) or defined(cpuaarch64)}  // need a lower latency
      OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, -1, 0.3, uos_InputGetSampleRate(PlayerIndex1, res), -1, -1, 1024, -1);
      {$else}
      OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, res), -1, -1, 1024, -1);
     {$endif}

      ////// Add a Output into Device Output
      //////////// Device ( -1 is default device )
      //////////// Latency  ( -1 is latency suggested )
      //////////// SampleRate : delault : -1 (44100)
      //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
      //////////// SampleFormat : default : -1 (2:Int16) (0: Float32, 1:Int32, 2:Int16)
      //////////// FramesCount : default : -1 (= 4096)
      // ChunkCount : default : -1 (= 512)

      if OutputIndex1 <> -1 then
        writeln('===> uos_AddIntoDevOut => OK')
      else
        writeln('===> uos_AddIntoDevOut => NOT ok');

      if OutputIndex1 <> -1 then
      begin
        writeln('===> OK, let play it');
        sleep(1000);
        uos_Play(PlayerIndex1);
        geticy();
        inctime        := 0;

        while inctime < 8 do
        begin
          sleep(2000);
          geticy();
          CheckSynchronize;
          Inc(inctime);
        end;
      end;
      writeln();
      writeln('Bye bye...');
      uos_stop(PlayerIndex1);
      uos_free;
      Terminate;
    end;
  end;

  constructor TConsoleApp.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

  destructor TConsoleApp.Destroy;
  begin
    inherited Destroy;
  end;

var
  Application: TConsoleApp;
begin
  Application        := TConsoleApp.Create(nil);
  Application.Title  := 'ConsoleApp';
  Application.Run;
  Application.Free;
end.

