program consolebpmdetect;

///WARNING : if FPC version < 2.7.1 => Do not forget to uncoment {$DEFINE consoleapp} in define.inc !

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses
{$IFDEF UNIX}
  cthreads,
  cwstring, {$ENDIF}
  Classes,
  ctypes,
  SysUtils,
  CustApp,
  uos_soundtouch,
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
  res, res2, i: integer;
  ordir, opath, st, SoundFilename, PA_FileName, SF_FileName, MP_FileName, ST_FileName: string;
  PlayerIndex1, input1 : integer;
 // BPMhandle, SThandle : THandle;
  thebuffer : array of cfloat;
  thebufferinfos : TuosF_BufferInfos;

  { TuosConsole }

  procedure TuosConsole.ConsolePlay;
  begin
    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));

 {$IFDEF Windows}
     {$if defined(cpu64)}
    PA_FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    SF_FileName := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
    MP_FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
  //  ST_FileName := ordir + 'lib\Windows\64bit\plugin\LibSoundTouch-64.dll';
     {$else}
    PA_FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    SF_FileName := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
  //  ST_FileName := ordir + 'lib\Windows\32bit\plugin\libSoundTouch-32.dll';
    MP_FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
     {$endif}
     
     // new soundtouch.dll not yet compiled for Windows
    SF_FileName := ''; 
    SoundFilename := ordir + 'sound\test.mp3';
 {$ENDIF}

 {$if defined(cpu64) and defined(linux) }
    PA_FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    SF_FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    ST_FileName := ordir + 'lib/Linux/64bit/plugin/LibSoundTouch-64.so';
    MP_FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    SoundFilename := ordir + 'sound/test.mp3';
   {$ENDIF}
   
  {$if defined(cpu86) and defined(linux)}
    PA_FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    SF_FileName := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
    MP_FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    ST_FileName := ordir + 'lib/Linux/32bit/plugin/LibSoundTouch-32.so';
    SoundFilename := ordir + 'sound/test.mp3';
 {$ENDIF}
 
  {$if defined(linux) and defined(cpuarm)}
    PA_FileName := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
    SF_FileName := ordir + 'lib/Linux/arm_raspberrypi/libsndfile-arm.so';
    MP_FileName := ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so';
    ST_FileName := ordir + 'lib/Linux/arm_raspberrypi/plugin/libsoundtouch-arm.so';
      SoundFilename := ordir + 'sound/test.mp3';
 {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    SF_FileName := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    ST_FileName := ordir + 'lib/FreeBSD/64bit/plugin/LibSoundTouch-64.so';
    MP_FileName := ordir + 'lib/FreeBSD/64bit/LibMpg123-64.so';
    {$else}
    PA_FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    SF_FileName := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    ST_FileName := ordir + 'lib/FreeBSD/32bit/plugin/LibSoundTouch-32.so';
    MP_FileName := ordir + 'lib/FreeBSD/32bit/LibMpg123-32.so';
    ST_FileName := '';
    {$endif}
    SoundFilename := ordir + 'sound/test.mp3';
 {$ENDIF}

 {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    SF_FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    MP_FileName := opath + '/lib/Mac/32bit/LibMpg123.dylib';
    ST_FileName := := opath + '/lib/Mac/32bit/plugin/libSoundTouch-32.dylib';
    SoundFilename := opath + '/sound/test.mp3';
 {$ENDIF}
 
     // Load the libraries
   // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName,  opusfilefilename: PChar) : LongInt;
   res := uos_LoadLib(Pchar(PA_FileName), Pchar(SF_FileName), Pchar(MP_FileName), nil, nil, nil) ;

    writeln('Result of loading libraries (if 0 => ok ) : ' + IntToStr(res));
        
    res2 := uos_LoadPlugin('soundtouch', Pchar(ST_FileName));
   
    writeln('Result of loading SoundTouch plugin (if 0 => ok ) : ' + IntToStr(res2));

   if (res = 0) and (res2 = 0) then begin

  writeln('soundtouch_getVersionId = ' + inttostr(soundtouch_getVersionId())); 

  writeln('soundtouch_getVersionString = ' + (soundtouch_getVersionString())); 

 
     // Create a memory buffer from a audio file from begining with 1024 frames.
    thebuffer := uos_File2Buffer(pchar(SoundFilename), 0, thebufferinfos, -1, 1024);
  
    writeln('length(thebuffer) = ' + inttostr(length(thebuffer))); 
    
   writeln('BPM = ' + floattostr(uos_GetBPM(thebuffer,thebufferinfos.channels,thebufferinfos.samplerate)));
 //  } 
    end else writeln('Libraries did not load... ;-(');

 end;

  procedure TuosConsole.doRun;
  begin
    ConsolePlay;
  //  writeln('Press a key to exit...');
  //  readln;
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
  Application.Title := 'Console BPM finder Buffer-Memory';
  Application.Run;
  Application.Free;
end.

begin
end.

