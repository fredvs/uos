program consolesynth;

///WARNING : if FPC version < 2.7.1 => Do not forget to uncoment {$DEFINE consoleapp} in define.inc !

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses
 {$IFDEF UNIX}
  cthreads,
    {$ENDIF}
  Classes,
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
  ordir, opath, PA_FileName: string;
  PlayerIndex1, inindex1: integer;

  { TuosConsole }

  procedure TuosConsole.ConsolePlay;
  begin
    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));

 {$IFDEF Windows}
     {$if defined(cpu64)}
    PA_FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
     {$else}
    PA_FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
     {$endif}
 {$ENDIF}

  {$if defined(cpu64) and  defined(linux) }
    PA_FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  {$ENDIF}

  {$if defined(cpu86) and defined(linux)}
    PA_FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  {$ENDIF}

  {$if defined(linux) and defined(cpuarm)}
    PA_FileName := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
  {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    {$else}
    PA_FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    {$endif}
  {$ENDIF}

 {$IFDEF Darwin}
  {$IFDEF CPU32}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    {$ENDIF}
  
   {$IFDEF CPU64}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
    {$ENDIF}  
 {$ENDIF}

    // Load the libraries (here only portaudio is needed)
    // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfilefilename:: PChar) : LongInt;

    res := uos_LoadLib(PChar(PA_FileName), nil, nil, nil, nil, nil);

    writeln('Result of loading (if 0 => ok ) : ' + IntToStr(res));

    writeln((uos_getinfolibraries()));

    if res = 0 then
    begin

      //// Create the player.
      //// PlayerIndex : from 0 to what your computer can do !
      //// If PlayerIndex exists already, it will be overwriten...

      PlayerIndex1 := 0;
      inindex1     := -1;

      if uos_CreatePlayer(PlayerIndex1) then inindex1 := 
   uos_AddFromSynth(PlayerIndex1, -1, -1, -1, 420, 420, -1, -1, -1, -1, -1, 0, -1, -1, -1);

{ function uos_AddFromSynth(PlayerIndex: cint32; Channels: integer; WaveTypeL, WaveTypeR: integer;
                           FrequencyL, FrequencyR: float; VolumeL, VolumeR: float;
                           duration : cint32; NbHarmonics: cint32; EvenHarmonics: cint32;
                           OutputIndex: cint32;  SampleFormat: cint32 ; 
                           SampleRate: cint32 ; FramesCount : cint32): cint32;

// Add a input from Synthesizer with custom parameters
// Channels: default: -1 (2) (1 = mono, 2 = stereo)
// WaveTypeL: default: -1 (0) (0 = sine-wave 1 = square-wave, used for mono and stereo) 
// WaveTypeR: default: -1 (0) (0 = sine-wave 1 = square-wave, used for stereo, ignored for mono) 
// FrequencyL: default: -1 (440 htz) (Left frequency, used for mono)
// FrequencyR: default: -1 (440 htz) (Right frequency, used for stereo, ignored for mono)
// VolumeL: default: -1 (= 1) (from 0 to 1) => volume left
// VolumeR: default: -1 (= 1) (from 0 to 1) => volume rigth (ignored for mono)
// Duration: default:  -1 (= 1000)  => duration in msec (0 = endless)
// NbHarmonics: default:  -1 (= 0) Number of Harmonics
// EvenHarmonics: default: -1 (= 0) (0 = all harmonics, 1 = Only even harmonics)
// OutputIndex: Output index of used output
            // -1: all output, -2: no output, other cint32 refer to 
            // a existing OutputIndex 
            // (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat: default : -1 (0: Float32) (0: Float32, 1:Int32, 2:Int16)
// SampleRate: delault : -1 (44100)
// FramesCount: -1 default : 1024
//  result:  Input Index in array  -1 = error
}

    {$if defined(cpuarm)} // needs lower latency
      if uos_AddIntoDevOut(PlayerIndex1,-1,0.3,-1,-1, 0,-1,-1) > - 1 then
       {$else}
      if uos_AddIntoDevOut(PlayerIndex1, -1, -1, -1, -1, 0, -1, -1) > -1 then
       {$endif}
        //// add a Output into device with custom parameters
        //////////// PlayerIndex : Index of a existing Player
        //  result : -1 nothing created, otherwise Output Index in array
      begin
        /////// everything is ready, here we are, lets play it...

        uos_Play(PlayerIndex1);

        sleep(150);

        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, 880, 880, -1, -1, 0, 0, -1, True);

{
       procedure InputSetSynth(InputIndex: cint32; WaveTypeL, WaveTypeR: integer;
       FrequencyL, FrequencyR: float; VolumeL, VolumeR: float; duration: cint32; 
       NbHarmonic: cint32; EvenHarmonics: cint32; Enable: boolean);
// InputIndex: one existing input index   
// WaveTypeL: do not change: -1 (0 = sine-wave 1 = square-wave, used for mono and stereo) 
// WaveTypeR: do not change: -1 (0 = sine-wave 1 = square-wave, used for stereo, ignored for mono) 
// FrequencyL: do not change: -1 (Left frequency, used for mono)
// FrequencyR: do not change: -1 (440 htz) (Right frequency, used for stereo, ignored for mono)
// VolumeL: do not change: -1 (= 1) (from 0 to 1) => volume left
// VolumeR: do not change: -1 (from 0 to 1) => volume rigth (ignored for mono)
// Duration: in msec (-1 = do not change)
// NbHarmonic: Number of Harmonics (-1 not change)
// EvenHarmonics: default: -1 (= 0) (0 = all harmonics, 1 = Only even harmonics)
// Enable: true or false ;
}

        sleep(175);

        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, 610, 610 * 0.99, -1, -1, -1, 0, -1, True);

        sleep(300);
        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, la3, la3 * 0.99, -1, -1, -1, 0, -1, True);

        sleep(150);
        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, 420, 420 * 0.99, -1, -1, -1, 0, -1, True);

        sleep(300);
        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, 320, 320 * 0.99, -1, -1, -1, 0, -1, True);

        sleep(150);
        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, 660, 660 * 0.99, -1, -1, -1, 0, -1, True);

        sleep(300);

        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, la3, la3 * 0.99, -1, -1, -1, 0, 1, True);

        sleep(300);
        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, la3, la3 * 1.01, -1, -1, -1, 0, 0, True);

        sleep(300);
        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, la3, la3 * 0.99, -1, -1, -1, 0, 1, True);

        sleep(300);
        uos_InputSetSynth(PlayerIndex1, inindex1, -1, -1, la3, la3 * 1.01, -1, -1, -1, 0, 0, True);

        sleep(1500);

        uos_stop(PlayerIndex1);
        
        writeln(inttostr(GetCPUCount()));

      end;
    end;
  end;

  procedure TuosConsole.doRun;
  begin
    ConsolePlay;
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
  Application       := TUOSConsole.Create(nil);
  Application.Title := 'Console Synthesizer';
  Application.Run;
  Application.Free;
end.

