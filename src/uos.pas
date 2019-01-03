{This unit is part of United Openlibraries of Sound (uos)
  This is the main uos unit.
  License : modified LGPL.3
  Fred van Stappen fiens@hotmail.com }

unit uos;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

// For custom configuration of directive to compiler --->  define.inc
{$I define.inc}

interface

uses

{$IF DEFINED(mse)}
 msegui, msethread, 
{$endif}

{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
fpg_base, fpg_main, 
{$endif}

{$IF DEFINED(Java)}
uos_jni,
{$endif}

{$IF DEFINED(webstream)}
uos_httpgetthread,  Pipes,
{$ENDIF}

{$IF DEFINED(portaudio)}
uos_portaudio,
{$endif}

{$IF DEFINED(sndfile)}
uos_LibSndFile,
{$endif}

{$IF DEFINED(mpg123)}
uos_Mpg123,
{$endif}

{$IF DEFINED(soundtouch)}
uos_soundtouch,
{$endif}
  
{$IF DEFINED(bs2b)}
uos_bs2b,
{$endif}
  
{$IF DEFINED(noiseremoval)}
uos_dsp_noiseremoval,
{$endif}

{$IF DEFINED(neaac)}
uos_aac,
{$endif}

{$IF DEFINED(opus)}
uos_opusfile,
{$endif}

{$IF DEFINED(shout)}
uos_shout, uos_opus,
{$endif}

{$IF DEFINED(cdrom)}
uos_cdrom,
{$endif}

Classes, ctypes, Math, sysutils;

const
  uos_version : cint32 = 2181218;
  
{$IF DEFINED(bs2b)}
  BS2B_HIGH_CLEVEL = (CInt32(700)) or ((CInt32(30)) shl 16);
  BS2B_MIDDLE_CLEVEL = (CInt32(500)) or ((CInt32(45)) shl 16);
  BS2B_LOW_CLEVEL = (CInt32(360)) or ((CInt32(60)) shl 16);
  { Easy crossfeed levels (Obsolete)  }
  BS2B_HIGH_ECLEVEL = (CInt32(700)) or ((CInt32(60)) shl 16);
  BS2B_MIDDLE_ECLEVEL = (CInt32(500)) or ((CInt32(72)) shl 16);
  BS2B_LOW_ECLEVEL = (CInt32(360)) or ((CInt32(84)) shl 16);
  BS2B_DEFAULT_CLEVEL = (CInt32(700)) or ((CInt32(45)) shl 16);
  BS2B_CMOY_CLEVEL =(CInt32(700)) or ((CInt32(60)) shl 16);
  BS2B_JMEIER_CLEVEL = (CInt32(650)) or ((CInt32(95)) shl 16);
{$endif}

{$IF DEFINED(synthesizer)}
const// musical note ==> frequency in hertz
la0  = 55.0; 
la0_d = 58.3;
si0 = 61.7;
do0 =  65.4;
do0_d = 69.3;
re0 = 73.4;
re0_d =77.8;
mi0  =82.4;
fa0  = 87.3; 
fa0_d = 92.5;
sol0 = 98.0;
sol0_d = 103.8;
la1  = 110.0; 
la1_d = 116.5;
si1 = 123.5;
do1 =  130.8;
do1_d = 138.6;
re1 = 146.8;
re1_d =155.6;
mi1  =164.8;
fa1  = 174.6; 
fa1_d = 185.0;
sol1 = 196.0;
sol1_d = 207.7;
la2 = 220.0; 
la2_d = 233.1;
si2 = 2246.9;
do2 =  261.6;
do2_d = 277.2;
re2 = 293.7;
re2_d =311.1;
mi2  =329.6;
fa2  = 349.2; 
fa2_d = 370.0;
sol2 = 392.0;
sol2_d = 415.3;
la3  = 440.0;
la3_d = 466.2;
si3 = 493.9;
do3 =  523.3;
do3_d = 554.4;
re3 = 587.3;
re3_d = 622.3;
mi3 = 659.3;
fa3  = 698.5;
fa3_d = 740.0;
sol3 = 784.0;
sol3_d = 830.6;
la4 = 880.0;
la4_d = 932.4;
si4 = 987.8;
do4 =  1046.6;
do4_d = 1108.8;
re4 = 1174.6;
re4_d = 1244.6;
mi4 = 1318.6;
fa4  = 1397.0;
fa4_d = 1480.0;
sol4 = 1568.0;
sol4_d = 1661.2;
la5 = 1760.0;
{$endif}

{$IF DEFINED(shout)}
  cFRAME_SIZE = 960;
  cSAMPLE_RATE = 48000;
  cAPPLICATION = OPUS_APPLICATION_AUDIO;
  cBITRATE = 64000;
  cMAX_FRAME_SIZE = 6 * 960;
  cMAX_PACKET_SIZE = 3 * 1276;
{$endif}

type
   TDummyThread = Class(TThread)
   protected
   procedure execute; override;
   end;

{$IF DEFINED(mse)}  
{$else}
type
   TuosThread = Class(TThread)
   protected
   procedure execute; override;
   public
   theparent : Tobject;
   constructor Create(CreateSuspended: boolean; AParent: TObject;
   const StackSize: SizeUInt = DefaultStackSize); overload; virtual;
   procedure DoTerminate; override;
  end;   
{$endif}
  
type
  TDArFloat = array of cfloat;
  TDArShort = array of cInt16;
  TDArLong = array of cInt32;

  TDArPARFloat = array of TDArFloat;
  TDArIARFloat = array of TDArPARFloat;

  PDArFloat = ^TDArFloat;
  PDArShort = ^TDArShort;
  PDArLong = ^TDArLong;
  
  {$IF not DEFINED(windows)}
  THandle = pointer;
  TArray = single;
{$endif}

type
  Tuos_BufferInfos = record
  SampleRate: longword;
  SampleRateRoot: longword;
  SampleFormat: cint32;
  Channels: cint32;
  Filename: UTF8String;
  Title: UTF8String;
  Copyright: UTF8String;
  Software: UTF8String;
  Artist: UTF8String;
  Comment: UTF8String;
  Date: string;
  Tag: array[0..2] of char;
  Album: UTF8String;
  Genre: byte;
  HDFormat: cint32;
  Sections: cint32;
  Encoding: cint32;
  bitrate: cint32;
  Length: cint32;//  length samples total ;
  LibOpen: integer; 
  Ratio: integer;  
end;  


type
{$if not defined(fs32bit)}
  Tcount_t  = cint64;  { used for file sizes }
{$else}
  Tcount_t  = cint32;
{$endif}

type
  Tuos_LoadResult = record
  PAloadError: shortint;
  SFloadError: shortint;
  MPloadError: shortint;
  PCloadError: shortint;
  STloadError: shortint;
  BSloadError: shortint;
  AAloadError: shortint;
  OPloadError: shortint;
  PAinitError: shortint;
  MPinitError: shortint;
end;

type
  Tuos_Init = class(TObject)
  public
  evGlobalPause: PRTLEvent;// for global pausing
  constructor Create;
  private

  PA_FileName: pchar;// PortAudio
  SF_FileName: pchar;// SndFile
  MP_FileName: pchar;// Mpg123
  AA_FileName : PChar;// Faad
  M4_FileName : PChar;// Mp4ff
  OF_FileName : PChar;// opusfile

  Plug_ST_FileName: pchar;// Plugin SoundTouch + GetBMP
  Plug_BS_FileName: pchar;// Plugin bs2b

{$IF DEFINED(portaudio)}
  DefDevOut: PaDeviceIndex;
  DefDevOutInfo: PPaDeviceInfo;
  DefDevOutAPIInfo: PPaHostApiInfo;
  DefDevIn: PaDeviceIndex;
  DefDevInInfo: PPaDeviceInfo;
  DefDevInAPIInfo: PPaHostApiInfo;
{$endif}

  function loadlib: cint32;
  procedure unloadlib;
  procedure unloadlibCust(PortAudio, SndFile, Mpg123, AAC, opus: boolean);
  function InitLib: cint32;
  procedure unloadPlugin(PluginName: Pchar);
  end;

type
  Tuos_DeviceInfos = record
  DeviceNum: cint32;
  DeviceName: UTF8String;
  DeviceType: UTF8String;
  DefaultDevIn: boolean;
  DefaultDevOut: boolean;
  ChannelsIn: cint32;
  ChannelsOut: cint32;
  SampleRate: CDouble;
  LatencyHighIn: CDouble;
  LatencyLowIn: CDouble;
  LatencyHighOut: CDouble;
  LatencyLowOut: CDouble;
  HostAPIName: UTF8String;
  end;

type
  Tuos_WaveHeaderChunk = packed record
  wFormatTag: smallint;
  wChannels: word;
  wSamplesPerSec: cint32;
  wAvgBytesPerSec: cint32;
  wBlockAlign: word;
  wBitsPerSample: word;
  wcbSize: word;
  end;

type
  Tuos_FileBuffer = record
  ERROR: word;
  wSamplesPerSec: cint32;
  wBitsPerSample: word;
  wChannels: word;
  FileFormat: integer;
  Data: TFileStream;
  DataMS: TMemoryStream;
  end;

type
  Tuos_Data = record// Global data
  Enabled: boolean;
  
  TypePut: integer;
// -1 : nothing. 
// for Input  : 0: from audio encoded file, 1: from input device (like mic),
//              2: from internet audio stream, 3: from Synthesizer, 4: from memory buffer,
//              5: from endless-muted, 6: from decoded memorystream
// for Output : 0: into wav file from filestream, 1: into output device Portaudio, 2: into stream server,
//              3: into memory buffer, 4: into wav file from memorystream, 5: into memorystream
    
  Seekable: boolean;
  Status: integer;
  
  Buffer: TDArFloat;
  MemoryBuffer: TDArFloat;
  MemoryStream : Tmemorystream;
  
  posmem : longint;
 
  {$IF DEFINED(opus)}
  BufferTMP: tbytes;
  {$endif}
  
  DSPVolumeIndex : cint32;
  
  DSPNoiseIndex : cint32;
  
  VLeft, VRight: double;
  
  hasfilters : boolean;
  
  nbfilters : cint32;
  incfilters : cint32;
  
  levelfilters : string;
  
  levelfiltersar : TDArFloat;

  PositionEnable : integer;
  LevelEnable : integer;
  LevelLeft, LevelRight: cfloat;
  levelArrayEnable : integer;
  
  lensine: cfloat;
   
  freqsine: cfloat;
  dursine, posdursine: cint32;
  posLsine, posRsine: cint32;
  
{$if defined(cpu64)}
  Wantframes: Tcount_t;
  OutFrames: Tcount_t;
{$else}
  Wantframes: cint32;
  OutFrames: cint32;
{$endif}
  
  SamplerateRoot: longword;
  SampleRate: longword;
  SampleFormat: cint32;
  Channels: cint32;
  
// audio file data
  HandleSt: pointer;
  {$IF DEFINED(opus)}
  HandleOP: TOpusFile;
  {$endif}
  Filename: UTF8String;
  Title: UTF8String;
  Copyright: UTF8String;
  Software: UTF8String;
  Artist: UTF8String;
  Comment: UTF8String;
  Date: string;
  Tag: array[0..2] of char;
  Album: UTF8String;
  Genre: byte;
  HDFormat: cint32;
  {$IF DEFINED(sndfile)}
  Frames: Tcount_t;
  {$else}
  Frames: cint32;
  {$endif}
  Sections: cint32;
  Encoding: cint32;
  bitrate: cint32;
  Length: cint32;//  length samples total 
  LibOpen: integer;// -1: nothing open, 0: sndfile open, 1: mpg123 open, 2: aac open, 3: cdrom, 4: opus
  Ratio: integer;//  if mpg123 or aac then ratio := 2
  
  BPM : cfloat;
  
  numbuf : integer;
  
  Output: cint32;

  {$if defined(cpu64)}// TO CHECK
  Position: cint32;
  Poseek:  cint32;
  {$else}
  Position: cint32;
  Poseek:  cint32;
  {$endif}

   end;

type
  TArray01 = array[0..1] of cfloat;
  
  Tuos_FFT = class(TObject)
  public
  TypeFilter: integer;
  LowFrequency, HighFrequency: cint32;
  AlsoBuf: boolean;
  a3, a32: array[0..2] of cfloat;
  b2, x0, x1, y0, y1, b22, x02, x12, y02, y12: TArray01;
  C, D, C2, D2, Gain, Leftlevel, Rightlevel: cfloat;
  VirtualBuffer: TDArFloat;
  levelstring : string;
   
  {$IF DEFINED(noiseremoval)}
  FNoise : TuosNoiseRemoval;
  {$endif} 
  constructor Create;
  end;

type
  TFunc = function(var Data: Tuos_Data; var FFT: Tuos_FFT): TDArFloat;

  {$if DEFINED(java)}
  TProc = JMethodID ;
  {$else}
  TProc = procedure of object;
  {$endif}

  TProcOnly = procedure;

  {$IF DEFINED(bs2b) or  DEFINED(soundtouch)}
  TPlugFunc = function(bufferin: TDArFloat; plugHandle: THandle; Abs2bd : Tt_bs2bdp; var inputData: Tuos_Data;
  param1: float; param2: float; param3: float; param4: float;
  param5: float; param6: float;  param7: float; param8: float): TDArFloat;
  {$endif}

type
  Tuos_DSP = class(TObject)
  public
  Enabled: boolean;
  BefFunc: TFunc;// function to execute before buffer is filled
  AftFunc: TFunc;// function to execute after buffer is filled
  EndFunc: TFunc;// function to execute at end of thread;
  
 LoopProc: TProc;// External Procedure of object to synchronize after buffer is filled 
  
// for FFT
  fftdata: Tuos_FFT;

  {$IF DEFINED(Java)}
  procedure LoopProcjava;
  {$endif}
 
  constructor Create;
  destructor Destroy; override;

  end;
  
type
  Tuos_InStream = class(TObject)
  {$IF DEFINED(webstream)}
  private
  procedure UpdateIcyMetaInterval; 
  {$endif}
  public
  Data: Tuos_Data;
  DSP: array of Tuos_DSP;
  
  MemoryStreamDec : TMemoryStream;
  
  {$IF DEFINED(neaac)}
  AACI: TAACInfo;
  {$endif}

  {$IF DEFINED(cdrom)}
  pCD: PCDROMInfo;
  {$endif}

// for web streaming
  {$IF DEFINED(webstream)}
  httpget: TThreadHttpGetter;// threaded http getter
  {$IF DEFINED(windows)}
  {$if defined(cpu64)}
  InHandle : Qword;
  OutHandle: Qword;
  {$else}
  InHandle : longword;
  OutHandle: longword;
  {$ENDIF}
  {$else}
  InHandle : cint32;
  OutHandle: cint32;
  {$endif}
  InPipe: TInputPipeStream;
  OutPipe: TOutputPipeStream;
  {$ENDIF}
  {$IF DEFINED(portaudio)}
  PAParam: PaStreamParameters;
  {$endif}
 LoopProc: TProc;// External Procedure of object to synchronize after buffer is filled 
 
  {$IF DEFINED(Java)}
  procedure LoopProcjava;
  {$endif}
  constructor Create;
  destructor Destroy; override;
  end;

type
  Tuos_OutStream = class(TObject)
  public
  Data: Tuos_Data;
  BufferOut: PDArFloat;
  MemorySteamOut: TMemoryStream;
  DSP: array of Tuos_DSP;
  {$IF DEFINED(portaudio)}
  PAParam: PaStreamParameters;
  {$endif}
  {$IF DEFINED(shout)}
  encoder: TOpusEncoder;
  cbits: array [0..cMAX_PACKET_SIZE - 1] of Byte;
// cbits: tbytes;
  {$endif}
  FileBuffer: Tuos_FileBuffer;
  LoopProc: TProc;// External Procedure of object to synchronize after buffer is filled 
  {$IF DEFINED(Java)}
  procedure LoopProcjava;
  {$endif}
  constructor Create;
  destructor Destroy; override;
  end;

  Tuos_Plugin = class(TObject)
  public
  Enabled: boolean;
  Name: string;
  PlugHandle: THandle;
  
  {$IF DEFINED(bs2b) or DEFINED(soundtouch)}
  Abs2b : Tt_bs2bdp;
  PlugFunc: TPlugFunc;
  {$endif}
  param1: float;
  param2: float;
  param3: float;
  param4: float;
  param5: float;
  param6: float;
  param7: float;
  param8: float;
  Buffer: TDArFloat;
  constructor Create;
  end;

type
  Tuos_Player = class(tobject)
   protected
   {$IF DEFINED(mse)}
   thethread : tmsethread; 
   {$else}
   thethread : TuosThread;
   {$endif} 
  evPause: PRTLEvent;// for pausing
  procedure ReadFile(x : integer); 
  {$IF DEFINED(webstream)}
  procedure ReadUrl(x : integer); 
  {$endif}
  {$IF DEFINED(synthesizer)}
  procedure ReadSynth(x : integer); 
  {$endif}
  procedure ReadEndless(x : integer); 
  procedure ReadMem(x : integer); 
  procedure ReadMemDec(x : integer); 
  {$IF DEFINED(portaudio)}
  procedure ReadDevice(x : integer); 
  {$endif}
  procedure WriteOutPlug(x:integer;  x2 : integer);  
  procedure WriteOut(x:integer;  x2 : integer); 
  Procedure CheckIfPaused ;  
  procedure DoBeginMethods;  
  procedure DoLoopBeginMethods;  
  procedure DoLoopEndMethods;  
  procedure DoArrayLevel(x: integer);  
  procedure DoSeek(x: integer); 
  procedure DoDSPinBeforeBufProc(x: integer); 
  procedure DoDSPinAfterBufProc(x: integer); 
  procedure DoDSPOutAfterBufProc(x: integer);
  procedure DoMainLoopProc(x: integer);
  procedure SeekIfTerminated;
  procedure DoTerminateNoFreePlayer;
  procedure DoTerminatePlayer;
  procedure DoEndProc;
 
  {$IF DEFINED(mse)}
  function execute(thread: tmsethread): integer;
  {$endif}
  
  public
  isAssigned: boolean ;
  isGlobalPause: boolean ;
  Status: cint32;
  
//if use -1 value (default) -> not alterate uosPlayers[],..
  Index: cint32;
     
  intobuf :boolean;// to check, needed for filetobuf

  NLooped : Integer;// -1 infinite loop; 0 no loop; > 0 n-loop

  NoFree : boolean;
// Do not free the player at end of thread.
  
  BeginProc: TProc ;
// External procedure of object to execute at begin of thread

  LoopBeginProc: TProc;
// External procedure of object to execute at each begin of loop

  LoopEndProc: TProc;
// External procedure of object to execute at each end of loop

  EndProc: TProc;
// Procedure of object to execute at end of thread
 
  EndProcOnly: TProcOnly ;
// Procedure to execute at end of thread (not of object)

  StreamIn: array of Tuos_InStream;
  StreamOut: array of Tuos_OutStream;
  PlugIn: array of Tuos_Plugin;

  {$IF DEFINED(Java)}
  PEnv : PJNIEnv;
  Obj:JObject;
  procedure beginprocjava;
  procedure endprocjava;
  procedure LoopBeginProcjava;
  procedure LoopEndProcjava;
  {$endif}
 
  constructor create(); 

  destructor Destroy; override;
  
  function IsLooped: Boolean;  
  
   function SetGlobalEvent(isenabled : boolean) : boolean;
// Set the RTL Events Global (will pause/start/replay all the players synchro with same rtl event)) 
// result : true if set ok. 
   
// Audio methods
  
  procedure PlayEx(no_free: Boolean; nloop: Integer; paused: boolean= false);// Start playing with free at end as parameter and assign loop

  Procedure Play(nloop: Integer = 0) ;// Start playing with loop
  
  Procedure PlayPaused(nloop: Integer = 0) ;// Start play paused with loop

  procedure RePlay();// Resume playing after pause

  procedure Stop();// Stop playing and free thread

  procedure Pause();// Pause playing
  
  Procedure PlayNoFree(nloop: Integer = 0) ;// Starting but do not free the player after stop with loop
  
  Procedure PlayNoFreePaused(nloop: Integer = 0) ;// Start play paused with loop but not free player at end
  
  Procedure FreePlayer() ;// Free the player: works only when PlayNoFree() was called.

  {$IF DEFINED(portaudio)}
  function AddIntoDevOut(Device: cint32; Latency: CDouble;
  SampleRate: cint32; Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ; ChunkCount: cint32 ): cint32;
// Add a Output into Device Output
// Device ( -1 is default device )
// Latency  ( -1 is latency suggested )
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (= 65536)
// ChunkCount : default : -1 (= 512)
//  result :  Output Index in array  -1 = error
// example : OutputIndex1 := AddIntoDevOut(-1,-1,-1,-1,0,-1,-1);
  
 {$endif}

  function AddIntoFile(Filename: PChar; SampleRate: cint32;
  Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ; FileFormat: cint32): cint32;
// Add a Output into audio wav file with custom parameters from TFileStream
// FileName : filename of saved audio wav file
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// SampleFormat : default : -1 (2:Int16) ( 1:Int32, 2:Int16)
// FramesCount : default : -1 (= 4096)
// FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom);
//  result : Output Index in array  -1 = error
// example : OutputIndex1 := AddIntoFile(edit5.Text,-1,-1, 0, -1, -1);

  function AddIntoFileFromMem(Filename: PChar; SampleRate: LongInt;  
      Channels: LongInt; SampleFormat: LongInt ; FramesCount: LongInt; FileFormat: cint32): LongInt;  
// Add a Output into audio wav file with custom parameters from TMemoryStream
/// FileName : filename of saved audio wav file
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// SampleFormat : default : -1 (2:Int16) ( 1:Int32, 2:Int16)
// FramesCount : default : -1 (= 4096)
// FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom);
//  result : Output Index in array     -1 = error
// example : OutputIndex1 := AddIntoFileFromBuf(edit5.Text,-1,-1, 0, -1);
  
  function AddIntoMemoryBuffer(outmemory: PDArFloat) : cint32;
// Add a Output into memory buffer
// outmemory : pointer of buffer to use to store memory.
// example : OutputIndex1 := AddIntoMemoryBuffer(bufmemory);

  function  AddIntoMemoryBuffer(outmemory: PDArFloat; SampleRate: LongInt;  SampleFormat: LongInt;
      Channels: LongInt; FramesCount: LongInt): LongInt;  
// Add a Output into TMemoryStream
// outmemory : pointer of buffer to use to store memory.
// SampleRate : delault : -1 (44100)
// SampleFormat : default : -1 (2:Int16) ( 1:Int32, 2:Int16)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// FramesCount : default : -1 (= 1024 * 2) 

  function AddIntoMemoryStream(var MemoryStream: TMemoryStream; SampleRate: LongInt; 
       SampleFormat: LongInt ; Channels: LongInt; FramesCount: LongInt): LongInt;  
// Add a Output into TMemoryStream
// MemoryStream : the TMemoryStream to use to store memory.
// SampleRate : delault : -1 (44100)
// SampleFormat : default : -1 (2:Int16) ( 1:Int32, 2:Int16)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// FramesCount : default : -1 (= 4096)

 {$IF DEFINED(shout)}
  function AddIntoIceServer(SampleRate : cint; Channels: cint; SampleFormat: cint;
  EncodeType: cint; Port: cint; Host: pchar; User: pchar; Password: pchar; MountFile :pchar): cint32;
// Add a Output into a IceCast server for audio-web-streaming 
// SampleRate : delault : -1 (48000)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// SampleFormat : -1 default : float32 : (0:float32, 1:Int16)
// EncodeType : default : -1 (0:Music) (0: Music, 1:Voice)
// Port : default : -1 (= 8000)
// Host : default : 'def' (= '127.0.0.1')
// User : default : 'def' (= 'source')
// Password : default : 'def' (= 'hackme')
// MountFile : default : 'def' (= '/example.opus')
//  result :  Output Index in array  -1 = error
 {$endif}

 {$IF DEFINED(portaudio)}
  function AddFromDevIn(Device: cint32; Latency: CDouble;
  SampleRate: cint32; OutputIndex: cint32;
  SampleFormat: cint32; FramesCount : cint32 ; ChunkCount: cint32): cint32;
// Add a Input from Device Input with custom parameters
// Device ( -1 is default Input device )
// Latency  ( -1 is latency suggested ) )
// SampleRate : delault : -1 (44100)
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
// ChunkCount : default : -1 (= 512)
//  result :  otherwise Output Index in array  -1 = error
// example : OutputIndex1 := AddFromDevice(-1,-1,-1,-1,-1, -1);
{$endif}

function AddFromEndlessMuted(Channels : cint32; FramesCount: cint32): cint32;
// Add a input from Endless Muted dummy sine wav
// FramesCount = FramesCount of input-to-follow 
// Channels = Channels of input-to-follow.

{$IF DEFINED(synthesizer)}
function AddFromSynth(Frequency: float; VolumeL: float; VolumeR: float; Duration: cint32; OutputIndex: cint32;
  SampleFormat: cint32 ; SampleRate: cint32 ; FramesCount : cint32): cint32;
// Add a input from Synthesizer with custom parameters
// Frequency : default : -1 (440 htz)
// VolumeL : default : -1 (= 1) (from 0 to 1) => volume left
// VolumeR : default : -1 (= 1) (from 0 to 1) => volume rigth
// Duration : default :  -1 (= 1000)  => duration in msec (0 = endless)
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (0: Float32) (0: Float32, 1:Int32, 2:Int16)
// SampleRate : delault : -1 (44100)
// FramesCount : -1 default : 1024
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := AddFromSynth(880,-1,-1,-1,-1,-1,-1, -1);
  
procedure InputSetSynth(InputIndex: cint32; Frequency: float; VolumeL: float; VolumeR: float;  Duration: cint32; Enable : boolean);
// Frequency : in Hertz (-1 = do not change)
// VolumeL :  from 0 to 1 (-1 = do not change)
// VolumeR :  from 0 to 1 (-1 = do not change)
// Duration : in msec (-1 = do not change)
// Enable : true or false ;
{$endif}

function AddFromFile(Filename: Pchar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32): cint32;
// Add a input from audio file with custom parameters
// FileName : filename of audio file
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := AddFromFile(edit5.Text,-1,0,-1);
  
function AddFromFileIntoMemory(Filename: Pchar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32 ; numbuf : cint): cint32;
// Add a input from audio file and store it into memory with custom parameters
// FileName : filename of audio file
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
// numbuf : number of buffer to add to outmemory (default : -1 = all, otherwise number max of buffers) 
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := AddFromFileIntoMemory(edit5.Text,-1,0,-1, -1);
 
function AddFromMemoryBuffer(var MemoryBuffer: TDArFloat; var Bufferinfos: Tuos_bufferinfos;
 OutputIndex: cint32; FramesCount: cint32): cint32;
// Add a input from memory buffer with custom parameters
// MemoryBuffer : the buffer
// Bufferinfos : infos of the buffer
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)// SampleRate : delault : -1 (44100)// FramesCount : default : -1 (4096)
// FramesCount : default : -1 (65536 div Channels)
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := AddFromMemoryBuffer(mybuffer, buffinfos,-1,1024);
  
function AddFromMemoryStream(var MemoryStream: TMemoryStream; 
         TypeAudio: cint32; OutputIndex: cint32; SampleFormat: cint32 ; FramesCount: cint32): cint32;   
// MemoryStream : Memory stream of encoded audio.
// TypeAudio : default : -1 --> 0 (0: flac, ogg, wav; 1: mp3; 2:opus)
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := AddFromMemoryStream(mymemorystream,-1,-1,0,1024);

function AddFromMemoryStreamDec(var MemoryStream: TMemoryStream; var Bufferinfos: Tuos_bufferinfos;
 OutputIndex: cint32; FramesCount: cint32): cint32;
// MemoryStream : Memory-stream of decoded audio (like created by AddIntoMemoryStream)
// Bufferinfos : infos of the Memory-stream
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// FramesCount : default : -1 (4096)
//  result :  Input Index in array  -1 = error

{$IF DEFINED(webstream)}
function AddFromURL(URL: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32 ; AudioFormat: cint32 ; ICYon : boolean): cint32;
// Add a Input from Audio URL
// URL : URL of audio file
// OutputIndex : OutputIndex of existing Output// -1: all output, -2: no output, other cint32 : existing Output
// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
// AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
// ICYon : ICY data on/off
// Add a Input from Audio URL
// URL : URL of audio file
// OutputIndex : OutputIndex of existing Output// -1: all output, -2: no output, other cint32 : existing Output
// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
// AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
// example : InputIndex := AddFromURL('http://someserver/somesound.mp3',-1,-1,-1,-1,false);
{$ENDIF}

function AddPlugin(PlugName: Pchar; SampleRate: cint32;
  Channels: cint32): cint32;
// Add a plugin , result is PluginIndex
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
// 'soundtouch' 'getbpm' and 'bs2b' PlugName are registred.

{$IF DEFINED(soundtouch)}
procedure SetPluginSoundTouch(PluginIndex: cint32; Tempo: cfloat;
  Pitch: cfloat; Enable: boolean);
// PluginIndex : PluginIndex Index of a existing Plugin.
  
procedure SetPluginGetBPM(PluginIndex: cint32; numofframes: integer; loop : boolean;
   Enable: boolean);
// PluginIndex : PluginIndex Index of a existing Plugin.  
// numofframes: number of frames to analyse (-1 = 512 x frames)
// loop: do new detection after previous.
{$endif}
  
{$IF DEFINED(bs2b)}
procedure SetPluginBs2b(PluginIndex: cint32; level: CInt32; fcut: CInt32; 
  feed: CInt32; Enable: boolean);
// PluginIndex : PluginIndex Index of a existing Plugin.
{$endif}

function GetStatus() : cint32 ;
// Get the status of the player : 0 => has stopped, 1 => is running, 2 => is paused, 
// -1 => error or not yet played, only created.

procedure InputSeek(InputIndex: cint32; pos: Tcount_t);
// change position in sample

procedure InputSeekSeconds(InputIndex: cint32; pos: cfloat);
// change position in seconds

procedure InputSeekTime(InputIndex: cint32; pos: TTime);
// change position in time format

procedure InputSetEnable(InputIndex: cint32; enabled: boolean);
// set enable true or false

function InputLength(InputIndex: cint32): cint32;
// InputIndex : InputIndex of existing input
//  result : Length of Input in samples

function InputLengthSeconds(InputIndex: cint32): cfloat;
// InputIndex : InputIndex of existing input
//  result : Length of Input in seconds
  
function InputLengthTime(InputIndex: cint32): TTime;
// InputIndex : InputIndex of existing input
//  result : Length of Input in time format

function InputPosition(InputIndex: cint32): cint32;
// InputIndex : InputIndex of existing input
// result : current postion in sample

procedure InputSetFrameCount(InputIndex: cint32 ; framecount : cint32);
// set number of frames to be done. (usefull for recording and level precision)

procedure InputSetLevelEnable(InputIndex: cint32 ; levelcalc : cint32);
// set level calculation (default is 0)
// 0 => no calcul
// 1 => calcul before all DSP procedures.
// 2 => calcul after all DSP procedures.
// 3 => calcul before and after all DSP procedures.

procedure InputSetPositionEnable(InputIndex: cint32 ; poscalc : cint32);
// set position calculation (default is 0)
// 0 => no calcul
// 1 => calcul of position.

procedure InputSetLevelArrayEnable(InputIndex: cint32 ; levelcalc : cint32);
// set add level calculation in level-array (default is 0)
// 0 => no calcul
// 1 => calcul before all DSP procedures.
// 2 => calcul after all DSP procedures.

function InputGetLevelLeft(InputIndex: cint32): double;
// InputIndex : InputIndex of existing input
// result : left level from 0 to 1
  
function InputGetLevelRight(InputIndex: cint32): double;
// InputIndex : InputIndex of existing input
// result : right level from 0 to 1

function InputFiltersGetLevelString(InputIndex: cint32): string;
// InputIndex : InputIndex of existing input
// filterIndex : Filterindex of existing filter
// result : list of left|right levels separed by $ character

function InputFiltersGetLevelArray(InputIndex: cint32): TDArFloat;
// InputIndex : InputIndex of existing input
// result : array of float of each filter. 
         //in format levelfilter0left,levelfilter0right,levelfilter1left,levelfilter2right,...
 
{$IF DEFINED(soundtouch)}
function InputGetBPM(InputIndex: cint32): float;
// InputIndex : InputIndex of existing input
// result : left level from 0 to 1
{$endif}   

function InputPositionSeconds(InputIndex: cint32): float;
// InputIndex : InputIndex of existing input
//  result : current postion of Input in seconds

function InputPositionTime(InputIndex: cint32): TTime;
// InputIndex : InputIndex of existing input
//  result : current postion of Input in time format

function InputUpdateTag(InputIndex: cint32): boolean;

{$IF DEFINED(webstream) and DEFINED(mpg123)}
function InputUpdateICY(InputIndex: cint32; var icy_data : pchar): integer;
{$endif}

function InputGetTagTitle(InputIndex: cint32): pchar;
function InputGetTagArtist(InputIndex: cint32): pchar;
function InputGetTagAlbum(InputIndex: cint32): pchar;
function InputGetTagDate(InputIndex: cint32): pchar;
function InputGetTagComment(InputIndex: cint32): pchar;
function InputGetTagTag(InputIndex: cint32): pchar;
// Tag infos

function InputAddDSP(InputIndex: cint32; BeforeFunc: TFunc;
  AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: TProc ): cint32;
// add a DSP procedure for input
// InputIndex d: Input Index of a existing input
// BeforeFunc : function to do before the buffer is filled
// AfterFunc : function to do after the buffer is filled
// EndedFunc : function to do after thread is finish
// LoopProc : external procedure of object to synchronize after the buffer is filled
//  result :  index of DSPin in array  (DSPinIndex)
// example : DSPinIndex1 := InputAddDSP(InputIndex1,@beforereverse,@afterreverse,nil);

procedure InputSetDSP(InputIndex: cint32; DSPinIndex: cint32; Enable: boolean);
// InputIndex : Input Index of a existing input
// DSPIndexIn : DSP Index of a existing DSP In
// Enable :  DSP enabled
// example : InputSetDSP(InputIndex1,DSPinIndex1,True);

procedure OutputSetEnable(OutputIndex: cint32; enabled: boolean);
// set enable true or false

function OutputAddDSP(OutputIndex: cint32; BeforeFunc: TFunc;
  AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: TProc): cint32;// usefull if multi output
// OutputIndex : OutputIndex of a existing Output
// BeforeFunc : function to do before the buffer is filled
// AfterFunc : function to do after the buffer is filled just before to give to output
// EndedFunc : function to do after thread is finish
// LoopProc : external procedure of object to synchronize after the buffer is filled
//  result : index of DSPout in array
// example :DSPoutIndex1 := OutputAddDSP(OutputIndex1,@volumeproc,nil,nil);

procedure OutPutSetDSP(OutputIndex: cint32; DSPoutIndex: cint32; Enable: boolean);
// OutputIndex : OutputIndex of a existing Output
// DSPoutIndex : DSPoutIndex of existing DSPout
// Enable :  DSP enabled
// example : OutPutSetDSP(OutputIndex1,DSPoutIndex1,True);

function InputAddFilter(InputIndex: cint32; LowFrequency: cint32;
  HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
  AlsoBuf: boolean; LoopProc: TProc): cint32;
// InputIndex : InputIndex of a existing Input
// LowFrequency : Lowest frequency of filter
// HighFrequency : Highest frequency of filter
// Gain : gain to apply to filter
// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// LoopProc : external procedure of object to synchronize after DSP done
//  result :  otherwise index of DSPIn in array
// example :FilterInIndex1 := InputAddFilter(InputIndex1,6000,16000,1,2,true,nil);

procedure InputSetFilter(InputIndex: cint32; FilterIndex: cint32;
  LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
  TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc );
// InputIndex : InputIndex of a existing Input
// DSPInIndex : DSPInIndex of existing DSPIn
// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
// Gain : gain to apply to filter
// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// LoopProc : external procedure of object to synchronize after DSP done
// Enable :  Filter enabled
// example : InputSetFilter(InputIndex1,FilterInIndex1,-1,-1,-1,False,True,nil);

function OutputAddFilter(OutputIndex: cint32; LowFrequency: cint32;
  HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
  AlsoBuf: boolean; LoopProc: TProc ): cint32;
// OutputIndex : OutputIndex of a existing Output
// LowFrequency : Lowest frequency of filter
// HighFrequency : Highest frequency of filter
// Gain : gain to apply to filter
// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// LoopProc : external procedure of object to synchronize after DSP done
//  result : index of DSPOut in array
// example :FilterOutIndex1 := OutputAddFilter(OutputIndex1,6000,16000,1,true,nil);

procedure OutputSetFilter(OutputIndex: cint32; FilterIndex: cint32;
  LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
  TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean;LoopProc: TProc );
// OutputIndex : OutputIndex of a existing Output
// FilterIndex : DSPOutIndex of existing DSPOut
// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
// Gain : gain to apply to filter
// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// Enable :  Filter enabled
// LoopProc : external procedure of object to synchronize after DSP done
// example : OutputSetFilter(OutputIndex1,FilterOutIndex1,1000,1500,-1,True,True,nil);

function DSPLevel(Data: Tuos_Data): Tuos_Data;
// to get level of buffer (volume)
  
function InputAddDSP1ChanTo2Chan(InputIndex: cint32): cint32;
//  Convert mono 1 channel input to stereo 2 channels input.
// Works only if the input is mono 1 channel othewise stereo 2 chan is keeped.
// InputIndex : InputIndex of a existing Input
//  result :  index of DSPIn in array
// example  DSPIndex1 := InputAddDSP1ChanTo2Chan(InputIndex1);

function InputAddDSPVolume(InputIndex: cint32; VolLeft: double;
  VolRight: double): cint32;
// DSP Volume changer
// InputIndex : InputIndex of a existing Input
// VolLeft : Left volume
// VolRight : Right volume
//  result :  index of DSPIn in array
// example  DSPIndex1 := InputAddDSPVolume(InputIndex1,1,1);

function OutputAddDSPVolume(OutputIndex: cint32; VolLeft: double;
  VolRight: double): cint32;
// DSP Volume changer
// OutputIndex : OutputIndex of a existing Output
// VolLeft : Left volume
// VolRight : Right volume
//  result :  otherwise index of DSPIn in array
// example  DSPIndex1 := OutputAddDSPVolume(InputIndex1,1,1);
  
{$IF DEFINED(noiseremoval)}
function InputAddDSPNoiseRemoval(InputIndex: cint32): cint32;
// DSP Noise Removal
// InputIndex : InputIndex of a existing Input
//  result :  otherwise index of DSPIn in array
// example  DSPIndex1 := InputAddDSPNoiseRemoval(InputIndex1);
  
procedure InputSetDSPNoiseRemoval(InputIndex: cint32; Enable: boolean);
  
function OutputAddDSPNoiseRemoval(OutputIndex: cint32): cint32;
// DSP Noise Removal
// InputIndex : OutputIndex of a existing Output
//  result :  otherwise index of DSPOut in array
// example  DSPIndex1 := OutputAddDSPNoiseRemoval(OutputIndex1);
  
procedure OutputSetDSPNoiseRemoval(OutputIndex: cint32; Enable: boolean);
{$endif}  
  
procedure InputSetDSPVolume(InputIndex: cint32; DSPVolIndex: cint32;
  VolLeft: double; VolRight: double; Enable: boolean);
// InputIndex : InputIndex of a existing Input
// DSPIndex : DSPIndex of a existing DSP
// VolLeft : Left volume
// VolRight : Right volume
// Enable : Enabled
// example  InputSetDSPVolume(InputIndex1,DSPIndex1,1,0.8,True);

procedure OutputSetDSPVolume(OutputIndex: cint32; DSPVolIndex: cint32;
  VolLeft: double; VolRight: double; Enable: boolean);
// OutputIndex : OutputIndex of a existing Output
// DSPIndex : DSPIndex of a existing DSP
// VolLeft : Left volume
// VolRight : Right volume
// Enable : Enabled
// example  OutputSetDSPVolume(InputIndex1,DSPIndex1,1,0.8,True);

end;

// General public procedure/function (accessible for library uos too)

function uos_GetInfoLibraries() : Pansichar ;

 {$IF DEFINED(portaudio)}
procedure uos_GetInfoDevice();

function uos_GetInfoDeviceStr() : Pansichar ;
  {$endif}

function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfileFileName : PChar) : cint32;
// load libraries... if libraryfilename = '' =>  do not load it...  You may load what and when you want...
// PortAudio => needed for dealing with audio-device
// SndFile => needed for dealing with ogg, vorbis, flac and wav audio-files
// Mpg123 => needed for dealing with mp* audio-files
// Mp4ff and Faad => needed for dealing with acc, m4a audio-files
// opusfile => needed for dealing with opus audio-files
  
// If you want to load libraries from system, replace it by "'system'"
// If some libraries are not needed, replace it by "nil", 
 
// for example : uos_loadlib('system', SndFileFileName, 'system', nil, nil, nil, OpusFileFileName)

procedure uos_unloadlib();
// Unload all libraries... Do not forget to call it before close application...

{$IF DEFINED(shout)}
function uos_LoadServerLib(ShoutFileName, OpusFileName : PChar) : cint32;
// Shout => needed for dealing with IceCast server
// Opus => needed for dealing with encoding opus stream
  
procedure uos_unloadServerLib();
// Unload server libraries... Do not forget to call it before close application...
{$endif}

procedure uos_unloadlibCust(PortAudio, SndFile, Mpg123, AAC, opus: boolean);
// Custom Unload libraries... if true, then unload the library. You may unload what and when you want...

function uos_loadPlugin(PluginName, PluginFilename: PChar) : cint32;
// load plugin...

{$IF DEFINED(soundtouch)}
function uos_GetBPM(TheBuffer: TDArFloat;  Channels: cint32; SampleRate: cint32) : cfloat;
// From SoundTouch plugin
{$endif}  
  
procedure uos_unloadPlugin(PluginName: PChar);
// Unload Plugin...
  
procedure uos_Free();
// To call at end of application.
// If uos_flat.pas was used, it will free all the uos_player created.
  
function uos_GetVersion() : cint32 ;// version of uos

function uos_File2Buffer(Filename: Pchar; SampleFormat: cint32 ; var bufferinfos: Tuos_BufferInfos ; frompos : cint; numbuf : cint ): TDArFloat;
// Create a memory buffer of a audio file.
// FileName : filename of audio file  
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// bufferinfos : the infos of the buffer.
// frompos : from position (default : -1 = from begining, otherwise position in song) 
// numbuf : number of frames to add to outmemory (default : -1 = all, otherwise number max of frames) 
//  result :  The memory buffer
// example : buffmem := uos_File2buffer(edit5.Text,0,buffmem, buffinfos, -1, -1);
  
function uos_Stream2Buffer(AudioFile: TMemoryStream; SampleFormat: int32 ; var outmemory: TDArFloat;
 var bufferinfos: Tuos_BufferInfos ; frompos : cint; numbuf : cint): TDArFloat;
// Create a memory buffer of a audio file.
// FileName : filename of audio file
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// Outmemory : the buffer to store data.
// bufferinfos : the infos of the buffer.
// frompos : from position (default : -1 = from begining, otherwise position in song) 
// numbuf : number of buffer to add to outmemory (default : -1 = all, otherwise number max of buffers)
//  result :  The memory buffer
// example : buffmem := uos__Stream2Buffer(edit5.Text,0,buffmem, buffinfos, -1, -1);

procedure uos_File2File(FilenameIN: Pchar; FilenameOUT: Pchar; SampleFormat: cint32 ; typeout: cint32 );
// Create a audio file from a audio file.
// FileNameIN : filename of audio file IN (ogg, flac, wav, mp3, opus, aac,...)
// FileNameOUT : filename of audio file OUT (wav, pcm, custom)
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// typeout : Type of out file (-1:default=wav, 0:wav, 1:pcm, 2:custom)
// example : InputIndex1 := uos_File2File(edit5.Text,0,buffmem);

procedure uos_MemStream2Wavfile(FileName: UTF8String; Data: TMemoryStream; BitsPerSample, chan, samplerate : integer);
// Create a audio wav file from a TMemoryStream.
// FileName : filename of wav saved file
// data : the memorystream
// BitsPerSample : 16 or 32 (bit)
// chan : number of channels
// samplerate : sample rate

procedure uos_CustBufferInfos(var bufferinfos: Tuos_BufferInfos; SampleRate: longword; SampleFormat : cint32; Channels: cint32 ; Length: cint32);
// to initialize a custom bufferinfos: needed for AddFromMemoryBuffer() if no bufferinfos was created.
// all infos refer to the buffer used ---> length = length of the buffer div channels.

const
// error
  noError = 0;
  FilePAError = 10;
  LoadPAError = 11;
  FileSFError = 20;
  LoadSFError = 21;
  FileMPError = 30;
  LoadMPError = 31;
  LoadOPError = 41;
  FileOPError = 50;
// uos Audio
  Stereo = 2;
  Mono = 1;

  {$IF DEFINED(android)}
  DefRate = 48000;
  {$else}
  DefRate = 44100;
  {$endif}

// Write wav file
  ReadError = 1;
  HeaderError = 2;
  DataError = 3;
  FileCorrupt = 4;
  IncorectFileFormat = 5;
  HeaderWriteError = 6;
  StreamError = 7;
// FFT Filters
  fBandAll = 0;
  fBandSelect = 1;
  fBandReject = 2;
  fBandPass = 3;
  fHighPass = 4;
  fLowPass = 5;
  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  MSG_CUSTOM1 = FPGM_USER + 1;
  {$endif}

var
  theinc : integer = 0;
  theincbpm : integer = 0;
  tempload : boolean = false;
  paversion : UTF8String = '';
  sfversion : UTF8String = '';
  mpversion : UTF8String = '';
  tempSamplerate, tempSampleFormat, tempchan, tempratio, tempLibOpen, tempLength : cint32; 
  tempoutmemory: TDArFloat;
  uosPlayers: array of Tuos_Player;
  uosPlayersStat : array of cint32;
  uosLevelArray : TDArIARFloat ;
  uosDeviceInfos: array of Tuos_DeviceInfos;
  uosLoadResult: Tuos_LoadResult;
  uosDeviceCount: cint32 = 0;
  uosDefaultDeviceIn: cint32 = -1;
  uosDefaultDeviceOut: cint32 = -1;
  uosInit: Tuos_Init = nil;
  uosisactif : boolean = true;

 {$IF DEFINED(windows)}
  old8087cw: word;
 {$endif}

  {$IF DEFINED(Java)}
  theclass : JClass;
  {$endif}

implementation

procedure TDummyThread.Execute;
begin
   FreeOnTerminate:=True;
   Terminate;
end;

function FormatBuf(Inbuf: TDArFloat; format: cint32): TDArFloat;
var
  x: cint32;
  ps: PDArShort;// if input is Int16 format
  pl: PDArLong;// if input is Int32 format
  pf: PDArFloat;// if input is Float32 format
begin

  case format of
  2:
  begin
  ps := @inbuf;
  for x := 0 to high(inbuf) do
  ps^[x] := cint16(trunc(ps^[x]));
  end;
  1:
  begin
  pl := @inbuf;
  for x := 0 to high(inbuf) do
  pl^[x] := cint32(trunc(pl^[x]));
  end;
  0:
  begin
  pf := @inbuf;
  for x := 0 to high(inbuf) do
  pf^[x] := cfloat(pf^[x]);
  end;
  end;
  Result := Inbuf;
end;

function CvFloat32ToInt16(Inbuf: TDArFloat): TDArShort;
var
  x, i: cint32;
  arsh: TDArShort;
begin
  SetLength(arsh, length(inbuf));
  for x := 0 to high(Inbuf) do
  begin
  i := trunc(Inbuf[x] * 32768);
  if i > 32767 then
  i := 32767
  else
  if i < -32768 then
  i := -32768;
  arsh[x] := i;
  end;
  Result := arsh;
end;

function CvFloat32ToInt32(Inbuf: TDArFloat): TDArLong;
var
  i: int64;
  x : cint32;
  arlo: TDArLong;
begin
  SetLength(arlo, length(inbuf));
  for x := 0 to high(Inbuf) do
  begin
  i := trunc(Inbuf[x] * 2147483647);
  if i > 2147483647 then
  i := 2147483647
  else
  if i < -2147483648 then
  i := -2147483648;
  arlo[x] := i;
  end;
  Result := arlo;
end;

function CvFloat32ToInt32fl(Inbuf: TDArFloat; nb:integer): TDArFloat;
var
  x : cint32;
  pl2: PDArLong;// if input is Int32 format
  pf: PDArfloat;
  buffer2 : TDArFloat;
  
begin
 pf := @Inbuf;
 pl2 := @Buffer2;
 
 setlength(buffer2,nb);
  
  for x := 0 to nb -1 do
  begin
  pl2^[x] := trunc((pf^[x]) * 2147483647);
  end;
  Result := buffer2;
end;

function CvInt16ToFloat32(Inbuf: TDArFloat): TDArFloat;
var
  x: cint32;
  arfl: TDArFloat;
  ps: PDArShort;
begin
  setlength(arfl,length(Inbuf));
  ps := @inbuf;
  for x := 0 to high(Inbuf) do
  arfl[x] := ps^[x] / 32768;
  Result := arfl;
end;

function CvSteroToMono(Inbuf: TDArFloat; len : cint32): TDArFloat;
var
  x, y: cint32;
  arsh: TDArFloat;
 begin

  if len > 0 then begin
  setlength(arsh, len);

  x := 0;
  y := 0;

  while x < (len * 2)-1 do
  begin
// TODO -> this takes only chan1, not (chan1+chan2)/2 -> it get bad noise dont know why ???...
// arsh[y]  := trunc((Inbuf[x] + Inbuf[x+1])/ 2) ;

  arsh[y]  := Inbuf[x+1] ;

  inc(y);
  x := x + 2 ;
  end;

  Result := arsh;
  end else Result := Inbuf;
end;

function CvInt32ToFloat32(Inbuf: TDArFloat): TDArFloat;
var
  x: cint32;
  arfl: TDArFloat;
  pl: PDArLong;
begin
  setlength(arfl,length(Inbuf));
  pl := @inbuf;
  for x := 0 to high(Inbuf) do
  arfl[x] := pl^[x] / 2147483647;
  Result := arfl;
end;

// convert a Tmemory stream into a wav file.
procedure uos_MemStream2Wavfile(FileName: UTF8String; Data: TMemoryStream; BitsPerSample, chan, samplerate : integer);
var
  f: TFileStream;
  wFileSize: LongInt;
  wChunkSize: LongInt;
  ID: array[0..3] of char;
  Header: Tuos_WaveHeaderChunk;
begin
  f := nil;
  f := TFileStream.Create(FileName, fmCreate);
  f.Seek(0, soFromBeginning);
    try
    ID := 'RIFF';
    f.WriteBuffer(ID, 4);
    wFileSize := 0;
    f.WriteBuffer(wFileSize, 4);
    ID := 'WAVE';
    f.WriteBuffer(ID, 4);
    ID := 'fmt ';
    f.WriteBuffer(ID, 4);
    wChunkSize := SizeOf(Header);
    f.WriteBuffer(wChunkSize, 4);
    Header.wFormatTag := 1;

    Header.wChannels := chan;

    Header.wSamplesPerSec := samplerate;
    
    Header.wBitsPerSample := BitsPerSample;

    Header.wBlockAlign := chan * (BitsPerSample div 8);
    
    Header.wAvgBytesPerSec := samplerate * Header.wBlockAlign;
  
    Header.wcbSize := 0;
    f.WriteBuffer(Header, SizeOf(Header));
  except
  
  end;
  try
    ID := 'data';
    f.WriteBuffer(ID, 4);
    wChunkSize := Data.Size;
    f.WriteBuffer(wChunkSize, 4);
  except
  end;
  
  Data.Seek(0, soFromBeginning);
    f.CopyFrom(Data, Data.Size);
  f.Seek(SizeOf(ID), soFromBeginning);
  wFileSize := f.Size - SizeOf(ID) - SizeOf(wFileSize);
  f.Write(wFileSize, 4);
  f.Free;
end;

function WriteWaveFromMem(FileName: UTF8String; Data: Tuos_FileBuffer): word;
var
  f: TFileStream;
  wFileSize: LongInt;
  wChunkSize: LongInt;
  ID: array[0..3] of char;
  Header: Tuos_WaveHeaderChunk;
begin
  Result := noError;
  f := nil;
  f := TFileStream.Create(FileName, fmCreate);
  f.Seek(0, soFromBeginning);
    if Data.FileFormat = 0 then 
  begin// wav file
    try
    ID := 'RIFF';
    f.WriteBuffer(ID, 4);
    wFileSize := 0;
    f.WriteBuffer(wFileSize, 4);
    ID := 'WAVE';
    f.WriteBuffer(ID, 4);
    ID := 'fmt ';
    f.WriteBuffer(ID, 4);
    wChunkSize := SizeOf(Header);
    f.WriteBuffer(wChunkSize, 4);
    Header.wFormatTag := 1;

    Header.wChannels := Data.wChannels;

    Header.wSamplesPerSec := Data.wSamplesPerSec;

    Header.wBlockAlign := Data.wChannels * (Data.wBitsPerSample div 8);

    Header.wAvgBytesPerSec := Data.wSamplesPerSec * Header.wBlockAlign;
    Header.wBitsPerSample := Data.wBitsPerSample;
    Header.wcbSize := 0;
    f.WriteBuffer(Header, SizeOf(Header));
  except
    Result := HeaderWriteError;
  end;
  try
    ID := 'data';
    f.WriteBuffer(ID, 4);
    wChunkSize := Data.DataMS.Size;
    f.WriteBuffer(wChunkSize, 4);
  except
    Result := StreamError;
  end;
  
  end;

  Data.DataMS.Seek(0, soFromBeginning);
    f.CopyFrom(Data.DataMS, Data.DataMS.Size);
  f.Seek(SizeOf(ID), soFromBeginning);
  wFileSize := f.Size - SizeOf(ID) - SizeOf(wFileSize);
  f.Write(wFileSize, 4);
  f.Free;
end;


procedure WriteWave(FileName: UTF8String; Data: Tuos_FileBuffer);
var
  wFileSize: cint32;
  ID: array[0..3] of char;
begin
  Data.data.Position:= 42;//(after 'data')
  Data.data.Write(Data.data.Size, 4);
  ID := 'RIFF';
  Data.data.Seek(SizeOf(ID), soFromBeginning);
  wFileSize := Data.data.Size - SizeOf(ID) - SizeOf(wFileSize);
  Data.data.Write(wFileSize, 4);
  Data.data.Free;
end;

{$IF DEFINED(portaudio) or DEFINED(sndfile)}
function mpg_read_stream(ahandle: Pointer; AData: Pointer; ACount: Integer): Integer; cdecl;
var
  Stream: TStream absolute ahandle;
begin
  Result := Stream.Read(AData^, ACount);
end;

function mpg_seek_stream(ahandle: Pointer; offset: Integer; 
 whence: Integer): Integer; cdecl; 
var 
 Stream: TStream absolute ahandle; 
begin 
 try 
  case whence of 
   SEEK_SET  : Result:= Stream.Seek(offset, soFromBeginning); 
   SEEK_CUR  : Result:= Stream.Seek(offset, soFromCurrent); 
   SEEK_END  : Result:= Stream.Seek(offset, soFromEnd); 
   else 
    Result:= 0; 
  end; 
 except 
  Result := 0; 
 end; 
end; 

procedure mpg_close_stream(ahandle: Pointer);// not used, uos does it...
begin
  TObject(ahandle).Free;
end;
{$endif}

{$IF DEFINED(webstream)}
// should use this for pipes vs memorystream ?
function mpg_seek_url(ahandle: Pointer; aoffset: Integer): Integer; cdecl; 
var
  Stream: TStream absolute ahandle;
begin
// pipe streams are not seekable but memory and filestreams are
  Result := 0;
  try
    if aoffset > 0 then
      Result := Stream.Seek(aoffset, soFromCurrent);
  except
    Result := 0;
  end;
end;
{$endif}

function Filetobuffer(Filename: Pchar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32; var outmemory: TDArFloat;
   var bufferinfos: Tuos_BufferInfos; frompos: cint; numbuf : cint ): TDArFloat;
// Add a input from audio file with custom parameters
// FileName : filename of audio file
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
// Outmemory : the buffer to store data.
// bufferinfos : the infos of the buffer
// frompos : from position (default : -1 = from begining, otherwise position in song) 
// numbuf : number of buffer to add to outmemory (default : -1 = all, otherwise number max of buffers) 
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := Filetobuffer(edit5.Text,-1,0,-1, buffmem, buffinfos, -1);
  var
  theplayer : Tuos_Player;
  in1 : cint32; 
  begin
  theplayer := Tuos_Player.Create();
   
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('begin Filetobuffer');
  {$endif}
  
  In1 := theplayer.AddFromFile( pchar(Filename), OutputIndex, SampleFormat, FramesCount) ;
  if in1 > -1 then 
  begin
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('in1 = ' + inttostr(in1));
  writeln('theplayer.InputLength(In1) = ' + inttostr(theplayer.InputLength(In1)));
  {$endif}

  SetLength(outmemory, 0);
 
  tempchan := theplayer.StreamIn[in1].Data.Channels; 
  tempratio := theplayer.StreamIn[in1].Data.ratio;
  tempSampleFormat := theplayer.StreamIn[in1].Data.SampleFormat; 
  tempSamplerate := theplayer.StreamIn[in1].Data.Samplerate; 
  templength := theplayer.StreamIn[in1].Data.Length;
 
  bufferinfos.SampleRate := theplayer.StreamIn[in1].Data.Samplerate; 
  bufferinfos.SampleRateRoot := theplayer.StreamIn[in1].Data.Samplerate;
  bufferinfos.SampleFormat := theplayer.StreamIn[in1].Data.SampleFormat;
  bufferinfos.Channels := theplayer.StreamIn[in1].Data.Channels;
  bufferinfos.Filename := theplayer.StreamIn[in1].Data.Filename;
  bufferinfos.Title := theplayer.StreamIn[in1].Data.Title;
  bufferinfos.Copyright := theplayer.StreamIn[in1].Data.Copyright;
  bufferinfos.Software := theplayer.StreamIn[in1].Data.Software;
  bufferinfos.Artist := theplayer.StreamIn[in1].Data.Artist;
  bufferinfos.Comment := theplayer.StreamIn[in1].Data.Comment;
  bufferinfos.Date := theplayer.StreamIn[in1].Data.Date;
  bufferinfos.Tag := theplayer.StreamIn[in1].Data.Tag;
  bufferinfos.Album := theplayer.StreamIn[in1].Data.Album;
  bufferinfos.Genre := theplayer.StreamIn[in1].Data.Genre;
  bufferinfos.HDFormat := theplayer.StreamIn[in1].Data.HDFormat;
  bufferinfos.Sections := theplayer.StreamIn[in1].Data.Sections;
  bufferinfos.Encoding := theplayer.StreamIn[in1].Data.Encoding;
  bufferinfos.bitrate := theplayer.StreamIn[in1].Data.bitrate;
  bufferinfos.Length := theplayer.StreamIn[in1].Data.Length;
  bufferinfos.LibOpen := 0;
  bufferinfos.Ratio := 2 ;
  
  theplayer.StreamIn[in1].Data.numbuf := numbuf;
  
  theplayer.AddIntoMemoryBuffer( @outmemory );
  theplayer.Play(0); 
  
   if frompos > 0 then theplayer.inputseek(in1,frompos);
  
  while (theplayer.getstatus > 0)  do 
   sleep(100);
 
 end;
 
  {$IF DEFINED(mse)}
  theplayer.destroy; 
  {$endif}
  result := outmemory;
 end; 
 
 {$IF DEFINED(soundtouch)}
function uos_GetBPM(TheBuffer: TDArFloat;  Channels: cint32; SampleRate: cint32) : cfloat;
// From SoundTouch plugin
  var
   BPMhandle : THandle;
    sr, ch : cint32;
  begin
  
  if SampleRate = -1 then sr := 44100 else sr := SampleRate;
  if Channels = -1 then ch := 2 else ch := Channels;
  
    BPMhandle := bpm_createInstance(ch,sr);
   
// writeln('BPMhandle = ok'); 
  
   bpm_putSamples(BPMhandle,  pcfloat(thebuffer),  length(thebuffer) div Channels);
   
   result := bpm_getBpm(BPMhandle); 
  
// writeln('Detected BPM = ' + inttostr(round(result)));  
  
   bpm_destroyInstance(BPMhandle);
  
  end;
 {$endif}
 
function uos_File2Buffer(Filename: Pchar; SampleFormat: cint32 ; var bufferinfos: Tuos_BufferInfos ; frompos : cint; numbuf : cint ): TDArFloat;
// Create a memory buffer of a audio file.
// FileName : filename of audio file  
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// bufferinfos : the infos of the buffer.
// frompos : from position (default : -1 = from begining, otherwise position in song) 
// numbuf : number of frames to add to outmemory (default : -1 = all, otherwise number max of frames) 
//  result :  The memory buffer
// example : buffmem := uos_File2buffer(edit5.Text,0,buffmem, buffinfos, -1, -1);
   {$IF DEFINED(debug) and DEFINED(unix)} 
  var
  i : integer;
  st : string;
   {$endif}
  begin
    
 result :=  Filetobuffer(Filename,-1, SampleFormat, 1024, result, bufferinfos, frompos, numbuf);
 
// writeln('tempoutmemory = '+ inttostr(length(tempoutmemory)));
 
  {$IF DEFINED(debug) and DEFINED(unix)} 
  writeln('After Filetobuffer');
  writeln('length(result) =' +inttostr(length(result)));
  st := '';
  for i := 0 to length(result) -1 do
  st := st + '|' + inttostr(i) + '=' + floattostr(result[i]);  
  WriteLn('OUTPUT DATA into portaudio------------------------------');
  WriteLn(st);
  {$endif}

// result := tempoutmemory;
  end;

function Streamtobuffer(AudioFile:TMemoryStream; OutputIndex: cint32;SampleFormat: cint32 ; FramesCount: cint32;
var outmemory: TDArFloat; var bufferinfos: Tuos_BufferInfos; frompos: cint; numbuf : cint): TDArFloat;
// Add a input from audio file with custom parameters
// FileName : filename of audio file
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
// Outmemory : the buffer to store data.
// bufferinfos : the infos of the buffer
// frompos : from position (default : -1 = from begining, otherwise position in song) 
// numbuf : number of buffer to add to outmemory (default : -1 = all, otherwise number max of buffers)
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := streamtobuffer(edit5.Text,-1,0,-1, buffmem, buffinfos, -1);
 
  var theplayer : Tuos_Player;
      in1 : cint32;
     
     begin
   theplayer := Tuos_Player.Create();
   {$IF DEFINED(debug) and DEFINED(unix)}
   writeln('begin Filetobuffer');
   {$endif}

//In1 := theplayer.AddFromFile( pchar(Filename), OutputIndex, SampleFormat, FramesCount) ;
   In1 := theplayer.AddFromMemoryStream( AudioFile,-1, OutputIndex, SampleFormat, FramesCount) ;

   if in1 > -1 then begin
      {$IF DEFINED(debug) and DEFINED(unix)}
      writeln('in1 = ' + inttostr(in1));
      writeln('theplayer.InputLength(In1) = ' + inttostr(theplayer.InputLength(In1)));
      {$endif}
     
      SetLength(outmemory, 0);
    
      tempchan := theplayer.StreamIn[in1].Data.Channels;
      tempratio := theplayer.StreamIn[in1].Data.ratio;
      tempSampleFormat := theplayer.StreamIn[in1].Data.SampleFormat;
      tempSamplerate := theplayer.StreamIn[in1].Data.Samplerate;
      templength := theplayer.StreamIn[in1].Data.Length;

      bufferinfos.SampleRate := theplayer.StreamIn[in1].Data.Samplerate;
      bufferinfos.SampleRateRoot := theplayer.StreamIn[in1].Data.Samplerate;
      bufferinfos.SampleFormat := theplayer.StreamIn[in1].Data.SampleFormat;
      bufferinfos.Channels := theplayer.StreamIn[in1].Data.Channels;
      bufferinfos.Filename := theplayer.StreamIn[in1].Data.Filename;
      bufferinfos.Title := theplayer.StreamIn[in1].Data.Title;
      bufferinfos.Copyright := theplayer.StreamIn[in1].Data.Copyright;
      bufferinfos.Software := theplayer.StreamIn[in1].Data.Software;
      bufferinfos.Artist := theplayer.StreamIn[in1].Data.Artist;
      bufferinfos.Comment := theplayer.StreamIn[in1].Data.Comment;
      bufferinfos.Date := theplayer.StreamIn[in1].Data.Date;
      bufferinfos.Tag := theplayer.StreamIn[in1].Data.Tag;
      bufferinfos.Album := theplayer.StreamIn[in1].Data.Album;
      bufferinfos.Genre := theplayer.StreamIn[in1].Data.Genre;
      bufferinfos.HDFormat := theplayer.StreamIn[in1].Data.HDFormat;
      bufferinfos.Sections := theplayer.StreamIn[in1].Data.Sections;
      bufferinfos.Encoding := theplayer.StreamIn[in1].Data.Encoding;
      bufferinfos.bitrate := theplayer.StreamIn[in1].Data.bitrate;
      bufferinfos.Length := theplayer.StreamIn[in1].Data.Length;
      bufferinfos.LibOpen := 0;
      bufferinfos.Ratio := 2 ;

      theplayer.StreamIn[in1].Data.numbuf := numbuf;

      theplayer.AddIntoMemoryBuffer( @outmemory );
      theplayer.Play(0);
       if frompos > 0 then theplayer.inputseek(in1,frompos);
  
     while (theplayer.getstatus > 0) do  sleep(100);
    
   end;
  {$IF DEFINED(mse)}
  theplayer.destroy; 
  {$endif}
   result := outmemory;
end;

function uos_Stream2Buffer(AudioFile: TMemoryStream; SampleFormat: int32 ;
 var outmemory: TDArFloat; var bufferinfos: Tuos_BufferInfos ; frompos:cint;  numbuf : cint): TDArFloat;
// Create a memory buffer of a audio file.
// FileName : filename of audio file
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// Outmemory : the buffer to store data.
// bufferinfos : the infos of the buffer.
// frompos : from position (default : -1 = from begining, otherwise position in song) 
// numbuf : number of buffer to add to outmemory (default : -1 = all, otherwise number max of buffers)
//  result :  The memory buffer
// example : buffmem := uos_File2buffer(edit5.Text,0,buffmem, buffinfos, -1);
 begin
   result := Streamtobuffer(AudioFile,-1, SampleFormat, -1, outmemory, bufferinfos, frompos, numbuf);
end;

procedure uos_File2File(FilenameIN: Pchar; FilenameOUT: Pchar; SampleFormat: cint32 ; typeout: cint32 );
// Create a audio file from a audio file.
// FileNameIN : filename of audio file IN (ogg, flac, wav, mp3, opus, aac,...)
// FileNameOUT : filename of audio file OUT (wav, pcm, custom)
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// typeout : Type of out file (-1:default=wav, 0:wav, 1:pcm, 2:custom)// example : InputIndex1 := uos_File2File(edit5.Text,0,buffmem); 
var
  theplayer : Tuos_Player;
  in1 : cint32; 
  begin
  
   theplayer := Tuos_Player.Create();
    
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('begin File2file');
  {$endif}
  In1 := theplayer.AddFromFile( pchar(FilenameIN), -1, SampleFormat, -1) ;
  if in1 > -1 then 
  begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('in1 = ' + inttostr(in1));
  writeln('theplayer.InputLength(In1) = ' + inttostr(theplayer.InputLength(In1)));
  {$endif}
     
  theplayer.AddIntoFile(FilenameOUT, theplayer.StreamIn[0].data.samplerate, 
  theplayer.StreamIn[0].data.channels, SampleFormat, -1 , typeout);
  
    theplayer.Play(0); 
    
      while (theplayer.getstatus > 0) do sleep(100);
   end;
  {$IF DEFINED(mse)}
  theplayer.destroy; 
  {$endif}
  end;  
  
   {$IF DEFINED(mse)}
    {$else}
 constructor TuosThread.Create(CreateSuspended: boolean; AParent: TObject;
  const StackSize: SizeUInt);
begin
  theparent := AParent;
  FreeOnTerminate := true;
  inherited Create(CreateSuspended, StackSize);
  Priority :=  tpTimeCritical;
end;  
 {$endif}
  
function Tuos_Player.GetStatus() : cint32 ;
// Get the status of the player : -1 => error or not yet played, 0 => has stopped, 1 => is running, 2 => is paused.
begin
result := -1 ;
  if (isAssigned = True) then  result := Status else result := -1 ;
end;

function Tuos_Player.IsLooped: Boolean;
begin
 Result:= (NLooped <> 0) and
          (NLooped <> 1);
end;

procedure Tuos_Player.PlayEx(no_free: Boolean; nloop: Integer; paused: boolean= false);
var
  x: cint32;
 begin
  if (isAssigned = True) and (not IsLooped) then 
  begin
  NLooped:= nloop;
  NoFree:= no_free;
   
  {$IF DEFINED(portaudio)}
  for x := 0 to high(StreamOut) do
  if StreamOut[x].Data.HandleSt <> nil then
   Pa_StartStream(StreamOut[x].Data.HandleSt);
  {$endif}
  
  for x := 0 to high(StreamIn) do
  begin
  {$IF DEFINED(portaudio)}
   if (StreamIn[x].Data.HandleSt <> nil) and (StreamIn[x].Data.TypePut = 1) then
  Pa_StartStream(StreamIn[x].Data.HandleSt);
  {$endif}
  
   if (no_free = true) and (StreamIn[x].Data.HandleSt <> nil) 
  and (StreamIn[x].Data.TypePut = 4) then
      StreamIn[x].Data.posmem := 0;
   
   if (no_free = true) and (StreamIn[x].Data.HandleSt <> nil) 
  and ((StreamIn[x].Data.TypePut = 0) or (StreamIn[x].Data.TypePut = 4)) then
      InputSeek(x, 0); 
  
   StreamIn[x].Data.status  := 1 ;
  
  end;
  
   
  Status := 1;
  
  if isGlobalPause = true then
  RTLeventSetEvent(uosInit.evGlobalPause) else   
  RTLeventSetEvent(evPause);
  
 if  paused = true then
 begin
   if isGlobalPause = true then
  RTLeventReSetEvent(uosInit.evGlobalPause) else   
  RTLeventResetEvent(evPause);
 end;
  
//protect from multiple instances of thread
 if thethread = nil then
 begin
  {$IF DEFINED(mse)}
  thethread:= tmsethread.create(@execute);
  {$else}
  thethread:= tuosthread.Create(false,self);
  {$endif}
  end;
 end;  
end;     

Procedure Tuos_Player.PlayPaused(nloop: Integer = 0) ;// Start play paused with loop
begin
 PlayEx(False,nloop,true);
end;

Procedure Tuos_Player.PlayNoFreePaused(nloop: Integer = 0) ;// Start play paused with loop and not free player at end
begin
 PlayEx(true,nloop,true);
end;

procedure Tuos_Player.Play(nloop: Integer = 0) ;
begin
 PlayEx(False,nloop);
end;    

procedure Tuos_Player.PlayNoFree(nloop: Integer = 0) ;
begin
 PlayEx(True,nloop);
end; 

procedure Tuos_Player.FreePlayer();// Works only when PlayNoFree() was used: free the player
begin
  if isAssigned then
  begin
    NLooped := 0;
    NoFree := False;
//if it has never been put into play (= there is no thread for free)..
    if thethread = nil then
      Play();
    Stop;
  end;
end; 

procedure Tuos_Player.RePlay();// Resume Playing after Pause
begin
   if  (Status > 0) and (isAssigned = True) and
      (not IsLooped) then 
  begin
  Status := 1;
  if isGlobalPause = true then
  RTLeventSetEvent(uosInit.evGlobalPause) else   
  RTLeventSetEvent(evPause);
  end;
end;

procedure Tuos_Player.Stop();
begin
//writeln(inttostr(Status));
  if (Status <> 0) and (isAssigned = True) then
  begin
    if status < 0 then playpaused;
  NLooped:= 0;
  if isGlobalPause = true then
  RTLeventSetEvent(uosInit.evGlobalPause) else   
  RTLeventSetEvent(evPause);
  Status := 0;
  end;
end;

procedure Tuos_Player.Pause();
begin
  if (Status > 0) and (isAssigned = True) then
  begin
  if isGlobalPause = true then
  RTLeventReSetEvent(uosInit.evGlobalPause) else   
  RTLeventResetEvent(evPause);
  Status := 2;
  end;
end;

procedure Tuos_Player.InputSeek(InputIndex:cint32; pos: Tcount_t);
// change position in samples
begin
  if (isAssigned = True) then StreamIn[InputIndex].Data.Poseek := pos;
end;

procedure Tuos_Player.InputSeekSeconds(InputIndex: cint32; pos: cfloat);
// change position in seconds
begin
  if  (isAssigned = True) then  StreamIn[InputIndex].Data.Poseek :=
  trunc(pos * StreamIn[InputIndex].Data.SampleRate);
end;

procedure Tuos_Player.InputSeekTime(InputIndex: cint32; pos: TTime);
// change position in time format
var
  ho, mi, se, ms: word;
  possample : cint32;
begin
  if (isAssigned = True) then begin
 sysutils.DecodeTime(pos, ho, mi, se, ms);

  possample := trunc(((ho * 3600) + (mi * 60) + se + (ms / 1000)) *
  StreamIn[InputIndex].Data.SampleRate);

  StreamIn[InputIndex].Data.Poseek := possample;
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('TTime: '+ timetostr(pos));
  WriteLn('SeekTime() : Data.Poseek: '+ inttostr(possample));
 {$endif}
  end;
end;

procedure Tuos_Player.InputSetEnable(InputIndex: cint32; enabled: boolean);
// set enable true or false
begin
StreamIn[InputIndex].data.Enabled := enabled;
end;

function Tuos_Player.InputLength(InputIndex: cint32): cint32;
// gives length in samples
begin
result := 0;
  if (isAssigned = True) then Result := StreamIn[InputIndex].Data.Length;
end;

function Tuos_Player.InputLengthSeconds(InputIndex: cint32): cfloat;
begin
result := 0;
  if  (isAssigned = True) then Result := StreamIn[InputIndex].Data.Length / StreamIn[InputIndex].Data.SampleRate;
end;

function Tuos_Player.InputLengthTime(InputIndex: cint32): TTime;
var
  tmp: cfloat;
  h, m, s, ms: word;
begin
 Result := sysutils.EncodeTime(0, 0, 0, 0);
  if (isAssigned = True) then tmp := InputLengthSeconds(InputIndex);
  ms := trunc(frac(tmp) * 1000);
  h := trunc(tmp / 3600);
  m := trunc(tmp / 60 - h * 60);
  s := trunc(tmp - (h * 3600 + m * 60));
  Result := sysutils.EncodeTime(h, m, s, ms);
end;

function Tuos_Player.InputPosition(InputIndex: cint32): cint32;
// gives current position
begin
 Result := 0;
  if (isAssigned = True) then Result := StreamIn[InputIndex].Data.Position;
end;

procedure Tuos_Player.InputSetFrameCount(InputIndex: cint32 ; framecount : cint32);
begin
  if (isAssigned = True) then

  case StreamIn[InputIndex].Data.LibOpen of
  0:
  StreamIn[InputIndex].Data.Wantframes:= (framecount * StreamIn[InputIndex].Data.Channels) ;

  1:
  StreamIn[InputIndex].Data.Wantframes:= (framecount * StreamIn[InputIndex].Data.Channels)  * 2  ;

  2:
  StreamIn[InputIndex].Data.Wantframes:= (framecount * StreamIn[InputIndex].Data.Channels) ;

  3:
  StreamIn[InputIndex].Data.Wantframes:= (framecount * StreamIn[InputIndex].Data.Channels) ;
  
  4:
  StreamIn[InputIndex].Data.Wantframes:= (framecount * StreamIn[InputIndex].Data.Channels) ;

end;

end;

procedure Tuos_Player.InputSetLevelArrayEnable(InputIndex: cint32 ; levelcalc : cint32);
// set add level calculation in level-array (default is 0)
// 0 => no calcul
// 1 => calcul before all DSP procedures.
// 2 => calcul after all DSP procedures.
begin
 if (isAssigned = True) then
 begin
 if index + 1 > length(uosLevelArray) then
 setlength(uosLevelArray,index + 1) ;
 if InputIndex + 1 > length(uosLevelArray[index]) then
 setlength(uosLevelArray[index],InputIndex + 1) ;
  setlength(uosLevelArray[index][InputIndex],0) ;
 StreamIn[InputIndex].Data.levelArrayEnable := levelcalc;
end;
end;

procedure Tuos_Player.InputSetLevelEnable(InputIndex: cint32 ; levelcalc : cint32);
// set level calculation (default is 0)
// 0 => no calcul
// 1 => calcul before all DSP procedures.
// 2 => calcul after all DSP procedures.
// 3 => calcul before and after all DSP procedures.

begin
  if (isAssigned = True) then
StreamIn[InputIndex].Data.levelEnable:= levelcalc;
end;

procedure Tuos_Player.InputSetPositionEnable(InputIndex: cint32 ; poscalc : cint32);
// set position calculation (default is 0)
// 0 => no calcul
// 1 => calcul position procedures.
begin
  if (isAssigned = True) then
StreamIn[InputIndex].Data.PositionEnable:= poscalc;
end;

function Tuos_Player.InputGetLevelLeft(InputIndex: cint32): double;
// InputIndex : InputIndex of existing input
// result : left level(volume) from 0 to 1
begin
Result := 0;
  if (isAssigned = True) then Result := StreamIn[InputIndex].Data.LevelLeft;
end;

function Tuos_Player.InputGetLevelRight(InputIndex: cint32): double;
// InputIndex : InputIndex of existing input
// result : right level(volume) from 0 to 1
begin
Result := 0;
  if (isAssigned = True) then Result := StreamIn[InputIndex].Data.LevelRight;
end;

function Tuos_Player.InputFiltersGetLevelString(InputIndex: cint32): string;
// InputIndex : InputIndex of existing input
// result : list of left|right levels separed by $ character
 begin
Result := '';
  if (isAssigned = True) then Result := StreamIn[InputIndex].data.Levelfilters;
end;

function Tuos_Player.InputFiltersGetLevelArray(InputIndex: cint32): TDArFloat;
// InputIndex : InputIndex of existing input
// result : array of float of each filter. 
         //in format levelfilter0left,levelfilter0right,levelfilter1left,levelfilter2right,...
 begin
  if (isAssigned = True) then Result := StreamIn[InputIndex].data.Levelfiltersar;
end;
 
{$IF DEFINED(soundtouch)}
function Tuos_Player.InputGetBPM(InputIndex: cint32): float;
// InputIndex : InputIndex of existing input
// result : Beat per minuts
  begin
Result := 0;
  if (isAssigned = True) then Result := StreamIn[InputIndex].Data.BPM;
end;
{$endif}   

function Tuos_Player.InputPositionSeconds(InputIndex: cint32): float;
begin
Result := 0;
  if (isAssigned = True) then Result := StreamIn[InputIndex].Data.Position / StreamIn[InputIndex].Data.SampleRate;
end;

function Tuos_Player.InputPositionTime(InputIndex: cint32): TTime; 
var 
  tmp: float=0.0;                
  h:word=0;                      
  m:word=0;    
  s:word=0;    
  ms:word=0;  
  
  begin 
  Result := sysutils.EncodeTime(0, 0, 0, 0); 
  if (isAssigned = True) then 
  begin 
     tmp := InputPositionSeconds(InputIndex); 
     {$IF DEFINED(debug) and DEFINED(unix)} 
     WriteLn('InputPositionTime(): InputPositionSeconds: '+ floattostr(tmp)); 
     {$endif} 
     ms := trunc(frac(tmp) * 1000); 
     h := trunc(tmp / 3600); 
     m := trunc(tmp / 60 - h * 60); 
     s := trunc(tmp - (h * 3600 + m * 60)); 
     Result := sysutils.EncodeTime(h, m, s, ms);  
  end; 
 {$IF DEFINED(debug) and DEFINED(unix)} 
  WriteLn('EncodeTime(): '+ timetostr(Result)); 
  {$endif}   
end;  


// for mp3 and opus files only
function Tuos_Player.InputUpdateTag(InputIndex: cint32): boolean;

{$IF DEFINED(mpg123) or DEFINED(opus) }
 var
 {$endif}
 
 {$IF DEFINED(mpg123)}
  mpinfo: Tmpg123_frameinfo;
  BufferTag: array[1..128] of char; 
  F: file; 
// problems with mpg123 
// mpid3v2: Tmpg123_id3v2;
  {$endif}
  
  {$IF DEFINED(opus)}
  s: UTF8String;
  j: Integer;
  OpusTag: POpusTags;
  LComment: PPAnsiChar;
  LcommentLength: PInteger;
  {$endif}
  
  begin

 Result := false;
  if (isAssigned = True) then
 begin
 {$IF DEFINED(mpg123)}
if StreamIn[InputIndex].Data.LibOpen = 1 then// mp3
begin
 mpg123_info(StreamIn[InputIndex].Data.HandleSt, MPinfo);
// custom code for reading ID3Tag ---> problems with  mpg123_id3() 

   AssignFile(F, StreamIn[InputIndex].Data.Filename); 
   FileMode:=fmOpenRead + fmShareDenyNone;
   Reset(F, 1); 
   Seek(F, FileSize(F) - 128); 
   BlockRead(F, BufferTag, SizeOf(BufferTag)); 
   CloseFile(F); 

  StreamIn[InputIndex].Data.title := copy(BufferTag, 4, 30); 
  StreamIn[InputIndex].Data.artist := copy(BufferTag, 34, 30); 
  StreamIn[InputIndex].Data.album := copy(BufferTag, 64, 30); 
  StreamIn[InputIndex].Data.date :=  copy(BufferTag, 94, 4);
  StreamIn[InputIndex].Data.comment := copy(BufferTag, 98, 30); 
  StreamIn[InputIndex].Data.tag :=  copy(BufferTag, 1, 3); 
  StreamIn[InputIndex].Data.genre := ord(BufferTag[128]);
  
  Result := true;
// ?  freeandnil(MPinfo);
end;
{$endif}

{$IF DEFINED(opus)}
if StreamIn[InputIndex].Data.LibOpen = 4 then// opus
begin
 OpusTag := op_tags(StreamIn[InputIndex].Data.HandleOP, nil);
  
  if OpusTag<>nil
  
  then begin
  
  if OpusTag^.comments>0
  then begin

  LComment := OpusTag^.user_comments;
  LcommentLength := OpusTag^.comment_lengths;
  for j := 0 to OpusTag^.comments - 1 do
  begin
  SetLength(s, LcommentLength^);
  move(Pointer(LComment^)^, Pointer(s)^, LcommentLength^);
 
  if j = 1 then StreamIn[InputIndex].Data.title := s;
  if j = 2 then StreamIn[InputIndex].Data.artist := s;
  if j = 3 then StreamIn[InputIndex].Data.album := s;
  if j = 4 then StreamIn[InputIndex].Data.date := s;
  if j = 5 then StreamIn[InputIndex].Data.comment := s;
  if j = 6 then StreamIn[InputIndex].Data.tag := s;
  
  inc(LComment);
  inc(LcommentLength);
  end;
  result := true;
  end;
  end;
 end;
 {$endif}
 end;
 end;

{$IF DEFINED(webstream)}
// for mp3 files only
function Tuos_Player.InputUpdateICY(InputIndex: cint32; var icy_data : pchar): integer;
begin
Result := -1;
  if (isAssigned = True) then
 begin
if StreamIn[InputIndex].Data.LibOpen = 1 then// mp3
if assigned(StreamIn[InputIndex].httpget) then
if StreamIn[InputIndex].httpget.ICYenabled = true then
begin
 {$IF DEFINED(mpg123)}
Result := mpg123_icy(StreamIn[InputIndex].Data.HandleSt, icy_data); 
 {$endif}
end;
end;
end; 
{$ENDIF}

function Tuos_Player.InputGetTagTitle(InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (isAssigned = True) then Result := pchar(StreamIn[InputIndex].Data.title);
 end;

function Tuos_Player.InputGetTagArtist(InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (isAssigned = True) then Result := pchar(StreamIn[InputIndex].Data.Artist);
 end;

function Tuos_Player.InputGetTagAlbum(InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (isAssigned = True) then Result := pchar(StreamIn[InputIndex].Data.album);
 end;

function Tuos_Player.InputGetTagComment(InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (isAssigned = True) then Result := pchar(StreamIn[InputIndex].Data.comment);
 end;

function Tuos_Player.InputGetTagTag(InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (isAssigned = True) then Result := pchar(StreamIn[InputIndex].Data.tag);
 end;
 
function Tuos_Player.InputGetTagDate(InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (isAssigned = True) then Result := pchar(StreamIn[InputIndex].Data.date);
 end;

procedure Tuos_Player.InputSetDSP(InputIndex: cint32; DSPinIndex: cint32;
  Enable: boolean);
begin
 StreamIn[InputIndex].DSP[DSPinIndex].Enabled := Enable;
end;

procedure Tuos_Player.OutputSetDSP(OutputIndex: cint32; DSPoutIndex: cint32;
  Enable: boolean);
begin
 StreamOut[OutputIndex].DSP[DSPoutIndex].Enabled := Enable;
end;

function Tuos_Player.InputAddDSP(InputIndex: cint32; BeforeFunc: TFunc;
  AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: TProc ): cint32;
begin
  SetLength(StreamIn[InputIndex].DSP, Length(StreamIn[InputIndex].DSP) + 1);
  StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1] := Tuos_DSP.Create();
  StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].Enabled := false;
  StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].BefFunc := BeforeFunc;
  StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].AftFunc := AfterFunc;
  StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].EndFunc := EndedFunc;
  StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].LoopProc := LoopProc;
  StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].Enabled := True;

  Result := Length(StreamIn[InputIndex].DSP) - 1;
 end;

procedure Tuos_Player.OutputSetEnable(OutputIndex: cint32; enabled: boolean);
// set enable true or false
begin
StreamOut[OutputIndex].data.Enabled := enabled;
end;

function Tuos_Player.OutputAddDSP(OutputIndex: cint32; BeforeFunc: TFunc;
  AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: TProc): cint32;
begin
  SetLength(StreamOut[OutputIndex].DSP, Length(StreamOut[OutputIndex].DSP) + 1);
  StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1] :=
  Tuos_DSP.Create;
  StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1].Enabled := false;
  StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1].BefFunc :=
  BeforeFunc;
  StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1].AftFunc :=
  AfterFunc;
  StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1].EndFunc :=
  EndedFunc;
  StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1].LoopProc :=
  LoopProc;
  StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1].Enabled := True;
  Result := Length(StreamOut[OutputIndex].DSP) - 1;
 end;

procedure Tuos_Player.InputSetFilter(InputIndex: cint32; FilterIndex: cint32;
  LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
  TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc );
// InputIndex : InputIndex of a existing Input
// DSPInIndex : DSPInIndex of existing DSPIn
// LowFrequency : Lowest frequency of filter ( default = -1 : current LowFrequency )
// HighFrequency : Highest frequency of filter ( default = -1 : current HighFrequency )
// Gain  : Gain to apply ( -1 = current gain)  ( 0 = silence, 1 = no gain, < 1 = less gain, > 1 = more gain)
// TypeFilter: Type of filter : ( default = -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// LoopProc : external procedure of object to synchronize after DSP done
// Enable :  Filter enabled
// example : InputSetFilter(InputIndex1,FilterInIndex1,1000,1500,-1,True,nil);
begin
if isAssigned = true then
begin
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.AlsoBuf := AlsoBuf;
  if LowFrequency = -1 then
  LowFrequency := StreamIn[InputIndex].DSP[FilterIndex].fftdata.LowFrequency;
  if HighFrequency = -1 then
  HighFrequency := StreamIn[InputIndex].DSP[FilterIndex].fftdata.HighFrequency;
  StreamIn[InputIndex].DSP[FilterIndex].Enabled := Enable;
  if Gain <> -1 then
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.Gain := cfloat(Gain);

  if TypeFilter <> -1 then
  begin
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.typefilter := TypeFilter;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.D := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[1] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[2] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[0] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[1] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C2 := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.D2 := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a32[0] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a32[1] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a32[2] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b22[0] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b22[1] := 0.0;

  case TypeFilter of
  1:// DSPFFTBandSelect := DSPFFTBandReject + DSPFFTBandPass
  begin
//  DSPFFTBandReject
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C :=
  Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamIn[InputIndex].Data.SampleRate);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.D :=
  2 * Cos(2 * Pi * ((HighFrequency + LowFrequency) shr 1) /
  StreamIn[InputIndex].Data.SampleRate);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + StreamIn[InputIndex].DSP[FilterIndex].fftdata.C);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[1] :=
  -StreamIn[InputIndex].DSP[FilterIndex].fftdata.D *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[1];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (1 - StreamIn[InputIndex].DSP[FilterIndex].fftdata.C) *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
//  DSPFFTBandPass
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C2 :=
  1 / Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamIn[InputIndex].Data.SampleRate);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.D2 :=
  2 * Cos(2 * Pi * ((HighFrequency + LowFrequency) shr 1) /
  StreamIn[InputIndex].Data.SampleRate);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a32[0] :=
  1 / (1 + StreamIn[InputIndex].DSP[FilterIndex].fftdata.C2);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a32[1] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a32[2] :=
  -StreamIn[InputIndex].DSP[FilterIndex].fftdata.a32[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b22[0] :=
  -StreamIn[InputIndex].DSP[FilterIndex].fftdata.C2 *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.D2 *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a32[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b22[1] :=
  (StreamIn[InputIndex].DSP[FilterIndex].fftdata.C2 - 1) *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a32[0];
//
  end;

  2://  DSPFFTBandReject
  begin
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C :=
  Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamIn[InputIndex].Data.SampleRate);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.D :=
  2 * Cos(2 * Pi * ((HighFrequency + LowFrequency) shr 1) /
  StreamIn[InputIndex].Data.SampleRate);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + StreamIn[InputIndex].DSP[FilterIndex].fftdata.C);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[1] :=
  -StreamIn[InputIndex].DSP[FilterIndex].fftdata.D *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[1];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (1 - StreamIn[InputIndex].DSP[FilterIndex].fftdata.C) *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  end;

  3://  DSPFFTBandPass
  begin
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C :=
  1 / Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamIn[InputIndex].Data.SampleRate);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.D :=
  2 * Cos(2 * Pi * ((HighFrequency + LowFrequency) shr 1) /
  StreamIn[InputIndex].Data.SampleRate);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + StreamIn[InputIndex].DSP[FilterIndex].fftdata.C);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[1] := 0.0;
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  -StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  -StreamIn[InputIndex].DSP[FilterIndex].fftdata.C *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.D *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (StreamIn[InputIndex].DSP[FilterIndex].fftdata.C - 1) *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  end;

  4://  DSPFFTLowPass
  begin
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C :=
  1 / Tan(Pi * HighFrequency / StreamIn[InputIndex].Data.SampleRate);
  
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + Sqrt(2) * StreamIn[InputIndex].DSP[FilterIndex].fftdata.C +
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[1] :=
  2 * StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  2 * (1 - StreamIn[InputIndex].DSP[FilterIndex].fftdata.C *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C) *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (1 - Sqrt(2) * StreamIn[InputIndex].DSP[FilterIndex].fftdata.C +
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C) *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  end;

  5://  DSPFFTHighPass
  begin
   StreamIn[InputIndex].DSP[FilterIndex].fftdata.C :=
   Tan(Pi * LowFrequency / StreamIn[InputIndex].Data.SampleRate);
  
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + Sqrt(2) * StreamIn[InputIndex].DSP[FilterIndex].fftdata.C +
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C);
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[1] :=

  -2 * StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  2 * (StreamIn[InputIndex].DSP[FilterIndex].fftdata.C *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C - 1) *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (1 - Sqrt(2) * StreamIn[InputIndex].DSP[FilterIndex].fftdata.C +
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.C) *
  StreamIn[InputIndex].DSP[FilterIndex].fftdata.a3[0];
  end;
  end;
  end;
end;

end;

procedure Tuos_Player.OutputSetFilter(OutputIndex: cint32; FilterIndex: cint32;
  LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
  TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);
// OutputIndex : OutputIndex of a existing Output
// FilterIndex : DSPOutIndex of existing DSPOut
// LowFrequency : Lowest frequency of filter
// HighFrequency : Highest frequency of filter
// TypeFilter: Type of filter : default = -1 = actual filter (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// Enable :  Filter enabled
// LoopProc : external procedure of object to synchronize after DSP done
// example : OutputSetFilter(OutputIndex1,FilterOutIndex1,1000,1500,-1,True,nil);
begin
if isAssigned = true then
begin
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.AlsoBuf := AlsoBuf;
  StreamOut[OutputIndex].DSP[FilterIndex].Enabled := Enable;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.Gain := cfloat(Gain);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.typefilter := TypeFilter;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[1] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[2] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[0] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[1] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C2 := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D2 := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a32[0] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a32[1] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a32[2] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b22[0] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b22[1] := 0.0;

  case TypeFilter of
  1:// DSPFFTBandSelect := DSPFFTBandReject + DSPFFTBandPass
  begin
//  DSPFFTBandReject
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C :=
  Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D :=
  2 * Cos(2 * Pi * ((HighFrequency + LowFrequency) shr 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[1] :=
  -StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[1];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (1 - StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C) *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
//  DSPFFTBandPass
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C2 :=
  1 / Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D2 :=
  2 * Cos(2 * Pi * ((HighFrequency + LowFrequency) shr 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a32[0] :=
  1 / (1 + StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C2);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a32[1] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a32[2] :=
  -StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a32[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b22[0] :=
  -StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C2 *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D2 *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a32[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b22[1] :=
  (StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C2 - 1) *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a32[0];
//
  end;

  2://  DSPFFTBandReject
  begin
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C :=
  Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D :=
  2 * Cos(2 * Pi * ((HighFrequency + LowFrequency) shr 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[1] :=
  -StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[1];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (1 - StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C) *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  end;

  3://  DSPFFTBandPass
  begin
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C :=
  1 / Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D :=
  2 * Cos(2 * Pi * ((HighFrequency + LowFrequency) shr 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[1] := 0.0;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  -StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  -StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.D *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C - 1) *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  end;

  4://  DSPFFTLowPass
  begin
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C :=
  1 / Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + Sqrt(2) * StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C +
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[1] :=
  2 * StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  2 * (1 - StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C) *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (1 - Sqrt(2) * StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C +
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C) *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  end;

  5://  DSPFFTHighPass
  begin
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C :=
  Tan(Pi * (HighFrequency - LowFrequency + 1) /
  StreamOut[OutputIndex].Data.SampleRate);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0] :=
  1 / (1 + Sqrt(2) * StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C +
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C);
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[1] :=
  -2 * StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[2] :=
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[0] :=
  2 * (StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C - 1) *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.b2[1] :=
  (1 - Sqrt(2) * StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C +
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.C) *
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.a3[0];
  end;
  end;
end;

end;

{$IF DEFINED(soundtouch)}
function SoundTouchPlug(bufferin: TDArFloat; plugHandle: THandle; notneeded :Tt_bs2bdp; var inputData: Tuos_Data;
  notused1: float; notused2: float; notused3: float;  notused4: float;
  notused5: float; notused6: float; notused7: float;  notused8: float): TDArFloat;
var
 ratio : integer;
 numoutbuf, x1, x2: cint32;
  BufferplugFLTMP: TDArFloat;
  BufferplugFL: TDArFloat;
 begin
 
 case inputData.LibOpen of
  0: ratio := 1;// sndfile
  1:begin// mpg123
  case inputData.SampleFormat of
  0: ratio := 2;// float32
  1: ratio := 2;// int32
  2: ratio := 1;// int16
  end;  
  end;
  2: ratio := 1;
  3: ratio := 1;// cdrom
  4: ratio := 1;// opus
  end;
  
  if inputData.LibOpen <> 4 then//not working yet for opus files
  begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln(); 
  writeln('_____Begin Sound touch_____'); 
  writeln('soundtouch_putSamples: Length(bufferin)  = ' + inttostr(length(bufferin))); 
  writeln('outframes  = ' + inttostr(inputData.outframes)+
  ' ratio  = ' + inttostr(ratio)+' channels  = ' + inttostr(inputData.Channels)); 
  {$endif}
  
  if inputData.outframes > 0 then
  begin 
  soundtouch_putSamples(plugHandle, pcfloat(bufferin),
  inputData.outframes div cint(inputData.Channels * ratio));
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('inputData.outframes div trunc(inputData.Channels * ratio) = '
  + inttostr(inputData.outframes div inputData.Channels * ratio)); 
  {$endif}
  
  SetLength(BufferplugFL, 0);
  SetLength(BufferplugFLTMP, 0);
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('Length(BufferplugFL) = '
  + inttostr(Length(BufferplugFL))); 
   writeln('Length(Bufferin) = '
  + inttostr(Length(Bufferin))); 
   writeln('Length(BufferplugFLTMP) = '
  + inttostr(Length(BufferplugFLTMP))); 
  {$endif} 

  SetLength(BufferplugFLTMP,(Length(Bufferin)));
{  
  x2 := 0 ;
while x2 < Length(BufferplugFLTMP) do 
begin
BufferplugFLTMP[x2] := 0.0 ;
inc(x2);
end;
}  
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('2_Length(BufferplugFLTMP) = '
  + inttostr(Length(BufferplugFLTMP))); 
  {$endif} 
  
  numoutbuf := 1;
  
  while numoutbuf > 0 do
  begin
  
  numoutbuf := soundtouch_receiveSamples(PlugHandle,
  pcfloat(BufferplugFLTMP), inputData.outframes); 
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('numoutbuf = '  + inttostr(numoutbuf)); 
  {$endif}
  
  if numoutbuf > 0 then begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('SetLength(BufferplugFL) = '  + inttostr(length(BufferplugFL) + trunc(numoutbuf * inputData.Channels))); 
  {$endif}
  
  SetLength(BufferplugFL, length(BufferplugFL) + trunc(numoutbuf * inputData.Channels));
  // works only with 2 channels.
  
  x2 := Length(BufferplugFL) - (numoutbuf * inputData.Channels);

  for x1 := 0 to trunc(numoutbuf * inputData.Channels) -1 do
  begin
  BufferplugFL[x1 + x2] := BufferplugFLTMP[x1];
  end;
  end;
  end;
  end;
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('inputData.outframes = Length(BufferplugFL) = ' + inttostr(inputData.outframes)); 
  writeln('_____End Sound touch_____'); 
  {$endif}
 
  inputData.outframes := Length(BufferplugFL) div inputData.Channels;
 
  Result := BufferplugFL;
  end
  else 
  begin
  SetLength(bufferin, inputData.outframes);
  Result := bufferin; 
end;
end;

function GetBPMPlug(bufferin: TDArFloat; plugHandle: THandle; notneeded :Tt_bs2bdp; var inputData: Tuos_Data;
  numframes: float; loop: float; notused3: float;  notused4: float;
  notused5: float; notused6: float; notused7: float;  notused8: float): TDArFloat;
var
 ratio : integer;
 begin
 
 case inputData.LibOpen of
  0: ratio := 1;// sndfile
  1:begin// mpg123
  case inputData.SampleFormat of
  0: ratio := 2;// float32
  1: ratio := 2;// int32
  2: ratio := 1;// int16
  end;  
  end;
  2: ratio := 1;
  3: ratio := 1;// cdrom
  4: ratio := 1;// opus
  end;
  
  if inputData.LibOpen <> 4 then//not working yet for opus files
  begin
// writeln('getBPM init ');
  if (theincbpm < numframes) and (theincbpm > -1) then  
  begin
  bpm_putSamples(plugHandle,  pcfloat(bufferin),  length(bufferin) div inputData.channels);
   end else
  begin
  if theincbpm > -1 then
  begin
   inputData.BPM := bpm_getBpm(plugHandle); 
//  writeln('inputData.BPM := ' + floattostr(inputData.BPM));
   if loop = 1 then theincbpm := 0 else theincbpm := -1;
  
  end;
  end;
  
  if theincbpm > -1 then inc(theincbpm);
 
 SetLength(bufferin, inputData.outframes div ratio);
  Result := bufferin; 
end;
end;


{$endif}

{$IF DEFINED(bs2b)}
function bs2bPlug(bufferin: TDArFloat; notneeded: THandle; Abs2bd : Tt_bs2bdp; var inputData: Tuos_Data;
 notused1: float; notused2: float; notused3: float;  notused4: float;
  notused5: float; notused6: float; notused7: float;  notused8: float): TDArFloat;
var
  x, x2: cint32;
  Bufferplug: TDArFloat;
 begin
 
  if (inputData.libopen = 0) or (inputData.libopen = 2)  or (inputData.libopen = 3) or (inputData.libopen = 4) then
  x2 := trunc(inputData.ratio * (inputData.outframes div trunc(inputData.channels))) ;
  
  if (inputData.libopen = 1)  then
  begin
  if inputData.SampleFormat < 2 then 
  x2 := trunc((inputData.outframes div trunc(inputData.channels)))
  else x2 := trunc(inputData.ratio * (inputData.outframes div trunc(inputData.channels))) ;
  end;
  
  SetLength(Bufferplug,x2);
  
  x := 0;
  
  while x < x2  do
  begin
  
  Bufferplug[x] := bufferin[x] ;
  Bufferplug[x+1] := bufferin[x+1] ;
  bs2b_cross_feed_f(Abs2bd,Bufferplug[x],1); 
  bs2b_cross_feed_f(Abs2bd,Bufferplug[x+1],2);  
  x := x +2;
  end;
  Result :=  Bufferplug;
end;
{$endif}

function Tuos_Player.AddPlugin(PlugName: PChar; SampleRate: cint32;
  Channels: cint32): cint32;
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// Result is PluginIndex
var
  x: cint32;
  chan, sr : integer;
begin
x := -1 ;
 {$IF DEFINED(soundtouch)}
  if lowercase(PlugName) = 'soundtouch' then
  begin// 
  SetLength(Plugin, Length(Plugin) + 1);
  x := Length(Plugin) - 1;
  Plugin[x] := Tuos_Plugin.Create();
  Plugin[x].Enabled := false;
  Plugin[x].Name := lowercase(PlugName);
  Plugin[x].param1 := -1;
  Plugin[x].param2 := -1;
  Plugin[x].param3 := -1;
  Plugin[x].param4 := -1;
  Plugin[x].param5 := -1;
  Plugin[x].param6 := -1;
  Plugin[x].param7 := -1;
  Plugin[x].param8 := -1;
  Plugin[x].PlugHandle := soundtouch_createInstance();
  if SampleRate = -1 then
  soundtouch_setSampleRate(Plugin[x].PlugHandle, 44100)
  else
  soundtouch_setSampleRate(Plugin[x].PlugHandle, SampleRate);
  if Channels = -1 then
  soundtouch_setChannels(Plugin[x].PlugHandle, 2)
  else
  soundtouch_setChannels(Plugin[x].PlugHandle, Channels);
  soundtouch_setRate(Plugin[x].PlugHandle, 1);
  soundtouch_setTempo(Plugin[x].PlugHandle, 1);
  soundtouch_clear(Plugin[x].PlugHandle);
  Plugin[x].PlugFunc := @soundtouchplug;
  end;
  
   if lowercase(PlugName) = 'getbpm' then
  begin// 
  SetLength(Plugin, Length(Plugin) + 1);
  x := Length(Plugin) - 1;
  Plugin[x] := Tuos_Plugin.Create();
  Plugin[x].Enabled := true;
  Plugin[x].Name := lowercase(PlugName);
  Plugin[x].param1 := -1;
  Plugin[x].param2 := -1;
  Plugin[x].param3 := -1;
  Plugin[x].param4 := -1;
  Plugin[x].param5 := -1;
  Plugin[x].param6 := -1;
  Plugin[x].param7 := -1;
  Plugin[x].param8 := -1;
  
   if SampleRate = -1 then
  sr := 44100
  else
  sr := SampleRate;
  if Channels = -1 then
  chan := 2
  else
  chan := Channels;
  
  Plugin[x].PlugHandle := bpm_createInstance(chan,sr);
  
  Plugin[x].PlugFunc := @getbpmplug;
  end;
  {$endif}
  
 {$IF DEFINED(bs2b)}
  if lowercase(PlugName) = 'bs2b' then
  begin 
  SetLength(Plugin, Length(Plugin) + 1);
  Plugin[Length(Plugin) - 1] := Tuos_Plugin.Create();
  x := Length(Plugin) - 1;
  Plugin[x].Name := lowercase(PlugName);
  Plugin[x].Enabled := true;
  if assigned(Plugin[x].Abs2b) then bs2b_close(Plugin[x].Abs2b) ;
  Plugin[x].Abs2b := bs2b_open() ;
  
  if SampleRate = -1 then
  bs2b_set_srate(Plugin[x].Abs2b, 44100)
  else
  bs2b_set_srate(Plugin[x].Abs2b, SampleRate);
  
  Plugin[x].param1 := -1;
  Plugin[x].param2 := -1;
  Plugin[x].param3 := -1;
  Plugin[x].param4 := -1;
  Plugin[x].param5 := -1;
  Plugin[x].param6 := -1; 
  Plugin[x].param7 := -1;
  Plugin[x].param8 := -1;  
  Plugin[x].PlugFunc := @bs2bplug;
  end;
  {$endif}  
  Plugin[x].Enabled := true;
  Result := x;
 end;

{$IF DEFINED(soundtouch)}
procedure Tuos_Player.SetPluginSoundTouch(PluginIndex: cint32;
  Tempo: cfloat; Pitch: cfloat; Enable: boolean);
begin
  soundtouch_setRate(Plugin[PluginIndex].PlugHandle, Pitch);
  soundtouch_setTempo(Plugin[PluginIndex].PlugHandle, Tempo);
  Plugin[PluginIndex].Enabled := Enable;
  Plugin[PluginIndex].param1 := Tempo;
  Plugin[PluginIndex].param2 := Pitch;
end;

procedure Tuos_Player.SetPluginGetBPM(PluginIndex: cint32; numofframes: integer; loop : boolean;
   Enable: boolean);
// PluginIndex : PluginIndex Index of a existing Plugin.  
// numofframes: number of frames to analyse (-1 = 512 frames)
// loop: do new detection after previous.
begin

  Plugin[PluginIndex].Enabled := Enable;
  
  Plugin[PluginIndex].param1 := numofframes;
  
  if (loop = true) then
  Plugin[PluginIndex].param2 := 1 else Plugin[PluginIndex].param2 := 0; ;
end;
{$endif}

{$IF DEFINED(bs2b)}
procedure Tuos_Player.SetPluginBs2b(PluginIndex: cint32;
  level: CInt32; fcut: CInt32; feed: CInt32; Enable: boolean);
begin
 
  Plugin[PluginIndex].Enabled := Enable;
 
  if level > -1 then begin
  bs2b_set_level(Plugin[PluginIndex].Abs2b,level);
  Plugin[PluginIndex].param1 := level;
  end;
  
  if fcut > -1 then begin
  bs2b_set_level_fcut(Plugin[PluginIndex].Abs2b,fcut);
  Plugin[PluginIndex].param2 := fcut;
  end;
  
  if feed > -1 then begin
  bs2b_set_level_feed(Plugin[PluginIndex].Abs2b,feed);
  Plugin[PluginIndex].param3 := feed;
  end;
  
end;
{$endif}

function uos_InputGetLevelArray(PlayerIndex: cint32; InputIndex: cint32) : TDArFloat;
begin
   result :=  uosLevelArray[PlayerIndex][InputIndex] ;
end;
  
{$IF DEFINED(noiseremoval)}
function uos_NoiseRemoval(var Data: Tuos_Data; var fft: Tuos_FFT): TDArFloat;
var
 ratio, x: cint32;
 Outfr : cint32;
 tempr : PSingle;
 pf: TDArFloat;  
begin

  case Data.LibOpen of
  0: ratio := 1;// sndfile
  1: ratio := 2;// mpg123
  2: ratio := 1;// aac
  3: ratio := 1;// cdrom
  4: ratio := 1;// opus
  end;
  
if Data.SampleFormat = 0 then// TODO for Array of integer.
begin

 tempr := fft.FNoise.FilterNoise(pointer(Data.Buffer) ,
  (Data.OutFrames div ratio) , Outfr);
  
 setlength(pf,length(Data.Buffer));
 
 for x := 0 to length(pf) -1 do
  begin
  if x < Outfr then
  pf[x] := tempr[x] 
 else pf[x] := 0.0;
  end;

  result := pf ; 
  
end else result := Data.Buffer;// TODO for Array of integer.
end;
 {$endif}

function uos_DSPVolumeIn(var Data: Tuos_Data;var fft: Tuos_FFT): TDArFloat;
var
  x, ratio: cint32;
  vleft, vright: cfloat;
  
// volumearray : array of double;

  ps: PDArShort;// if input is Int16 format
  pl: PDArLong;// if input is Int32 format
  pf: PDArFloat;// if input is Float32 format
begin
//setlength(volumearray,Data.channels);
  vleft := Data.VLeft;
  vright := Data.VRight;

  case Data.SampleFormat of
  2:// int16
  begin
  ps := @Data.Buffer;
  for x := 0 to (Data.OutFrames -1) do
  begin
  if (Data.VLeft <> 1)  or (Data.Vright <> 1) then
  begin
  if odd(x) then
  ps^[x] := trunc(ps^[x] * vright)
  else
  ps^[x] := trunc(ps^[x] * vleft);
  end;
// This to avoid distortion
   if ps^[x] < (-32760) then ps^[x] := -32760 ;
   if ps^[x] > (32760) then ps^[x] := 32760 ;

  end;

  end;
  1:// int32
  begin
  pl := @Data.Buffer;
  for x := 0 to (Data.OutFrames -1) do
  begin
  if (Data.VLeft <> 1)  or (Data.Vright <> 1) then
  begin
  if odd(x) then
  pl^[x] := trunc(pl^[x] * vright)
  else
  pl^[x] := trunc(pl^[x] * vleft);
  end;

// This to avoid distortion
  if pl^[x] < (-2147000000) then pl^[x] := -2147000000 ;
  if pl^[x] > (2147000000) then pl^[x] := 2147000000 ;

  end;

  end;
  0:// float32
  begin
  case Data.LibOpen of
  0: ratio := 1;// sndfile
  1: ratio := 2;// mpg123
  2: ratio := 1;// aac
  3: ratio := 1;// cdrom
  4: ratio := 1;// opus
  end;

  pf := @Data.Buffer;
   
  for x := 0 to (Data.OutFrames div ratio) -1 do
  begin
  if (Data.VLeft <> 1)  or (Data.Vright <> 1) then
  begin
  if odd(x) then
  pf^[x] := pf^[x] * vright
  else
  pf^[x] := pf^[x] * vleft;
  end;

// This to avoid distortion
   if pf^[x] < -1 then pf^[x] := -1;
   if pf^[x] > 1 then pf^[x] := 1 ;

  end;

  end;
  end;

  Result := Data.Buffer;
end;

function uos_DSPVolumeOut(var Data: Tuos_Data;var fft: Tuos_FFT): TDArFloat;
var
  x: cint32;
  vleft, vright: cfloat;
  ps: PDArShort;// if output is Int16 format
  pl: PDArLong;// if output is Int32 format
  pf: PDArFloat;// if output is Float32 format
begin

  vleft := Data.VLeft;
  vright := Data.VRight;
  
   case Data.SampleFormat of
  2:// int16
  begin
  ps := @Data.Buffer;
  for x := 0 to (length(Data.Buffer) -1) do
  begin
  if (Data.VLeft <> 1)  or (Data.Vright <> 1) then
  begin
  if odd(x) then
  ps^[x] := trunc(ps^[x] * vright)
  else
  ps^[x] := trunc(ps^[x] * vleft);
  end;
// This to avoid distortion
   if ps^[x] < (-32760) then ps^[x] := -32760 ;
   if ps^[x] > (32760) then ps^[x] := 32760 ;

  end;

  end;
  1:// int32
  begin
  pl := @Data.Buffer;
  for x := 0 to (length(Data.Buffer) -1) do
  begin
  if (Data.VLeft <> 1)  or (Data.Vright <> 1) then
  begin
  if odd(x) then
  pl^[x] := trunc(pl^[x] * vright)
  else
  pl^[x] := trunc(pl^[x] * vleft);
  end;

// This to avoid distortion
  if pl^[x] < (-2147000000) then pl^[x] := -2147000000 ;
  if pl^[x] > (2147000000) then pl^[x] := 2147000000 ;

  end;

  end;
  0:// float32
  begin
  
  pf := @Data.Buffer;
   
  for x := 0 to (length(Data.Buffer)) -1 do
  begin
  if (Data.VLeft <> 1)  or (Data.Vright <> 1) then
  begin
  if odd(x) then
  pf^[x] := pf^[x] * vright
  else
  pf^[x] := pf^[x] * vleft;
  end;

// This to avoid distortion
   if pf^[x] < -1 then pf^[x] := -1;
   if pf^[x] > 1 then pf^[x] := 1 ;

  end;

  end;
  end;

  Result := Data.Buffer;
end;

function Tuos_Player.DSPLevel(Data: Tuos_Data): Tuos_Data;
var
  x, ratio: cint32;
  ps: PDArShort;// if input is Int16 format
  pl: PDArLong;// if input is Int32 format
  pf: PDArFloat;// if input is Float32 format
  mins, maxs: array[0..1] of cInt16;// if input is Int16 format
  minl, maxl: array[0..1] of cInt32;// if input is Int32 format
  minf, maxf: array[0..1] of cfloat;// if input is Float32 format
begin

  case Data.SampleFormat of
  2:
  begin
  mins[0] := 32767;
  mins[1] := 32767;
  maxs[0] := -32768;
  maxs[1] := -32768;
  ps := @Data.Buffer;
  x := 0;
  while x < Data.OutFrames -1 do
  begin
  if ps^[x] < mins[0] then
  mins[0] := ps^[x];
  if ps^[x] > maxs[0] then
  maxs[0] := ps^[x];

  Inc(x, 1);

  if ps^[x] < mins[1] then
  mins[1] := ps^[x];
  if ps^[x] > maxs[1] then
  maxs[1] := ps^[x];

  Inc(x, 1);
  end;

  if Abs(mins[0]) > Abs(maxs[0]) then
  Data.LevelLeft := Sqrt(Abs(mins[0]) / 32768)
  else
  Data.LevelLeft := Sqrt(Abs(maxs[0]) / 32768);

  if Abs(mins[1]) > Abs(maxs[1]) then
  Data.Levelright := Sqrt(Abs(mins[1]) / 32768)
  else
  Data.Levelright := Sqrt(Abs(maxs[1]) / 32768);

  end;

  1:
  begin
  minl[0] := 2147483647;
  minl[1] := 2147483647;
  maxl[0] := -2147483648;
  maxl[1] := -2147483648;
  pl := @Data.Buffer;
  x := 0;
  while x < Data.OutFrames -1 do
  begin
  if pl^[x] < minl[0] then
  minl[0] := pl^[x];
  if pl^[x] > maxl[0] then
  maxl[0] := pl^[x];

  Inc(x, 1);

  if pl^[x] < minl[1] then
  minl[1] := pl^[x];
  if pl^[x] > maxl[1] then
  maxl[1] := pl^[x];

  Inc(x, 1);
  end;

  if Abs(minl[0]) > Abs(maxl[0]) then
  Data.LevelLeft := Sqrt(Abs(minl[0]) / 2147483648)
  else
  Data.LevelLeft := Sqrt(Abs(maxl[0]) / 2147483648);

  if Abs(minl[1]) > Abs(maxl[1]) then
  Data.Levelright := Sqrt(Abs(minl[1]) / 2147483648)
  else
  Data.Levelright := Sqrt(Abs(maxl[1]) / 2147483648);
  end;

  0:
  begin
  case Data.LibOpen of
  0: ratio := 1;// sndfile
  1: ratio := 2;// mpg123
  2: ratio := 2;// aac
  3: ratio := 2;// cdrom
  4: ratio := 2;// opus
  end;

  minf[0] := 1;
  minf[1] := 1;
  maxf[0] := -1;
  maxf[1] := -1;
  pf := @Data.Buffer;
  x := 0;
  while x < (Data.OutFrames div ratio)-1 do
  begin
  if pf^[x] < minf[0] then
  minf[0] := pf^[x];
  if pf^[x] > maxf[0] then
  maxf[0] := pf^[x];

  Inc(x, 1);

  if pf^[x] < minf[1] then
  minf[1] := pf^[x];
  if pf^[x] > maxf[1] then
  maxf[1] := pf^[x];

  Inc(x, 1);
  end;

  if Abs(minf[0]) > Abs(maxf[0]) then
  Data.LevelLeft := Sqrt(Abs(minf[0]))
  else
  Data.LevelLeft := Sqrt(Abs(maxf[0]));

  if Abs(minf[1]) > Abs(maxf[1]) then
  Data.Levelright := Sqrt(Abs(minf[1]))
  else
  Data.Levelright := Sqrt(Abs(maxf[1]));
  end;
  end;

  Result := Data;
end;

function DSPLevelString(Buffer: TDArFloat; SampleFormat, Ratio : cint32; var resfloatleft : cfloat; var resfloatright : cfloat): string;
var
  x, OutFrames: cint32;
  ps: PDArShort;// if input is Int16 format
  pl: PDArLong;// if input is Int32 format
  pf: PDArFloat;// if input is Float32 format
  mins, maxs: array[0..1] of cInt16;// if input is Int16 format
  minl, maxl: array[0..1] of cInt32;// if input is Int32 format
  minf, maxf: array[0..1] of cfloat;// if input is Float32 format
begin

OutFrames := length(buffer);

  case SampleFormat of
  2:
  begin
  mins[0] := 32767;
  mins[1] := 32767;
  maxs[0] := -32768;
  maxs[1] := -32768;
  ps := @Buffer;
  x := 0;
  while x < OutFrames -1 do
  begin
  if ps^[x] < mins[0] then
  mins[0] := ps^[x];
  if ps^[x] > maxs[0] then
  maxs[0] := ps^[x];

  Inc(x, 1);

  if ps^[x] < mins[1] then
  mins[1] := ps^[x];
  if ps^[x] > maxs[1] then
  maxs[1] := ps^[x];

  Inc(x, 1);
  end;

  if Abs(mins[0]) > Abs(maxs[0]) then
  resfloatLeft := Sqrt(Abs(mins[0]) / 32768)
  else
  resfloatLeft := Sqrt(Abs(maxs[0]) / 32768);

  if Abs(mins[1]) > Abs(maxs[1]) then
  resfloatright := Sqrt(Abs(mins[1]) / 32768)
  else
  resfloatright := Sqrt(Abs(maxs[1]) / 32768);

  end;

  1:
  begin
  minl[0] := 2147483647;
  minl[1] := 2147483647;
  maxl[0] := -2147483648;
  maxl[1] := -2147483648;
  pl := @Buffer;
  x := 0;
  while x < OutFrames -1 do
  begin
  if pl^[x] < minl[0] then
  minl[0] := pl^[x];
  if pl^[x] > maxl[0] then
  maxl[0] := pl^[x];

  Inc(x, 1);

  if pl^[x] < minl[1] then
  minl[1] := pl^[x];
  if pl^[x] > maxl[1] then
  maxl[1] := pl^[x];

  Inc(x, 1);
  end;

  if Abs(minl[0]) > Abs(maxl[0]) then
  resfloatLeft := Sqrt(Abs(minl[0]) / 2147483648)
  else
  resfloatLeft := Sqrt(Abs(maxl[0]) / 2147483648);

  if Abs(minl[1]) > Abs(maxl[1]) then
  resfloatright := Sqrt(Abs(minl[1]) / 2147483648)
  else
  resfloatright := Sqrt(Abs(maxl[1]) / 2147483648);
  end;

  0:
  begin
  
  minf[0] := 1;
  minf[1] := 1;
  maxf[0] := -1;
  maxf[1] := -1;
  pf := @Buffer;
  x := 0;
  while x < (OutFrames div ratio) -1 do
  begin
  if pf^[x] < minf[0] then
  minf[0] := pf^[x];
  if pf^[x] > maxf[0] then
  maxf[0] := pf^[x];

  Inc(x, 1);

  if pf^[x] < minf[1] then
  minf[1] := pf^[x];
  if pf^[x] > maxf[1] then
  maxf[1] := pf^[x];

  Inc(x, 1);
  end;

  if Abs(minf[0]) > Abs(maxf[0]) then
  resfloatLeft := Sqrt(Abs(minf[0]))
  else
  resfloatLeft := Sqrt(Abs(maxf[0]));

  if Abs(minf[1]) > Abs(maxf[1]) then
  resfloatright := Sqrt(Abs(minf[1]))
  else
  resfloatright := Sqrt(Abs(maxf[1]));
  end;
  end;
  Result := floattostr(resfloatleft) + '|' + floattostr(resfloatright);
end;


function uos_BandFilter(var Data: Tuos_Data; var fft: Tuos_FFT): TDArFloat;
var
  i, ratio: cint32;
  ifbuf: boolean;
  arg, res, res2: cfloat;
  ps, ps2: PDArShort;// if input is Int16 format
  pl, pl2: PDArLong;// if input is Int32 format
  pf, pf2: PDArFloat;// if input is Float32 format
begin

  ratio := 1;
  ifbuf := fft.AlsoBuf;

  case Data.SampleFormat of
  2:
  begin
  ps := @Data.Buffer;
  ps2 := @fft.VirtualBuffer;
  end;  
  1:
  begin
  pl := @Data.Buffer;
  pl2 := @fft.VirtualBuffer;
  end;
  0:
  begin
  case Data.LibOpen of
  0: ratio := 1;// sndfile
  1: ratio := 2;// mpg123
  2: ratio := 2;// aac
  3: ratio := 2;// cdrom
  4: ratio := 2;// opus
  end;
  pf := @Data.Buffer;
  pf2 := @fft.VirtualBuffer;
  end;
  end;
  i := 0;
  while i < (Data.OutFrames div ratio) -1 do
  begin

  case Data.SampleFormat of
  2: arg := ps^[i];
  1: arg := pl^[i];
  0: arg := pf^[i];
  end;

  res := fft.a3[0] * arg + fft.a3[1] * fft.x0[0] + fft.a3[2] *
  fft.x1[0] - fft.b2[0] * fft.y0[0] - fft.b2[1] * fft.y1[0];
 
  if fft.typefilter = 1 then
  begin
  res2 := fft.a32[0] * arg + fft.a32[1] * fft.x02[0] + fft.a32[2] *
  fft.x12[0] - fft.b22[0] * fft.y02[0] - fft.b22[1] * fft.y12[0];

  case Data.SampleFormat of
  2:
  begin
  if ifbuf = True then
  ps^[i] := trunc((res * 1) + (res2 * fft.gain)) else
  ps2^[i] := trunc((res * 1) + (res2 * fft.gain));
  end;
  1:
  begin
  if ifbuf = True then
  pl^[i] := trunc((res * 1) + (res2 * fft.gain)) else
  pl2^[i] := trunc((res * 1) + (res2 * fft.gain));
  end;
  0:
  begin
  
  if ifbuf = True then
  pf^[i] := ((res * 1) + (res2 * fft.gain)) else
  pf2^[i] := ((res * 1) + (res2 * fft.gain));
  end;
  end;

  end
  else
  case Data.SampleFormat of
  2:
  begin
  
  if ifbuf = True then
  ps^[i] := trunc((res * fft.gain)) else
  ps2^[i] := trunc(res * fft.gain);
  end;
  1:
  begin
  if ifbuf = True then
  pl^[i] := trunc((res * fft.gain)) else
  pl2^[i] := trunc(res * fft.gain);
  end;
  0:
  begin
  if ifbuf = True then
  pf^[i] := ((res * fft.gain)) else
  pf2^[i] := ((res * fft.gain));
  end;
  end;

  fft.x1[0] := fft.x0[0];
  fft.x0[0] := arg;
  fft.y1[0] := fft.y0[0];
  fft.y0[0] := res;

  if fft.typefilter = 1 then
  begin
  fft.x12[0] := fft.x02[0];
  fft.x02[0] := arg;
  fft.y12[0] := fft.y02[0];
  fft.y02[0] := res2;
  end;

  if Data.Channels = 2 then
  begin
  Inc(i);
  case Data.SampleFormat of
  2: arg := ps^[i];
  1: arg := pl^[i];
  0: arg := pf^[i];
  end;
  res := fft.a3[0] * arg + fft.a3[1] * fft.x0[1] + fft.a3[2] *
  fft.x1[1] - fft.b2[0] * fft.y0[1] - fft.b2[1] * fft.y1[1];

  if fft.typefilter = 1 then
  begin
  res2 := fft.a32[0] * arg + fft.a32[1] * fft.x02[1] +
  fft.a32[2] * fft.x12[1] - fft.b22[0] * fft.y02[1] -
  fft.b22[1] * fft.y12[1];

  case Data.SampleFormat of
  2:
  begin
  if ifbuf = True then
  ps^[i] := trunc((res * 1) + (res2 * fft.gain)) else
  ps2^[i] := trunc((res * 1) + (res2 * fft.gain));
  end;
  1:
  begin
  if ifbuf = True then
  pl^[i] := trunc((res * 1) + (res2 * fft.gain)) else
  pl2^[i] := trunc((res * 1) + (res2 * fft.gain));
  end;
  0:
  begin
  if ifbuf = True then
  pf^[i] := ((res * 1) + (res2 * fft.gain)) else
  pf2^[i] := ((res * 1) + (res2 * fft.gain));
  end;
  end;

  end
  else
  case Data.SampleFormat of
  2:
  begin
  if ifbuf = True then
  ps^[i] := trunc((res * fft.gain)) else
  ps2^[i] := trunc((res * fft.gain));
  end;
  1:
  begin
  if ifbuf = True then
  pl^[i] := trunc((res * fft.gain)) else
  pl2^[i] := trunc((res * fft.gain));
  end;
  0:
  begin
  if ifbuf = True then
  pf^[i] := ((res * fft.gain)) else
  pf2^[i] := ((res * fft.gain));
  end;
  end;

  fft.x1[1] := fft.x0[1];
  fft.x0[1] := arg;
  fft.y1[1] := fft.y0[1];
  fft.y0[1] := res;

  if fft.typefilter = 1 then
  begin
  fft.x12[1] := fft.x02[1];
  fft.x02[1] := arg;
  fft.y12[1] := fft.y02[1];
  fft.y02[1] := res2;
  end;

  end;
  Inc(i);
  end;
  
  if ifbuf = false then
  begin
  data.levelfilters  := data.levelfilters + '%'+ DSPLevelString(fft.VirtualBuffer, Data.SampleFormat, data.Ratio, data.levelleft, data.levelright) ;
  inc(Data.incfilters);
  Data.levelfiltersar[Data.incfilters-1] := data.levelleft;
  inc(Data.incfilters);
  Data.levelfiltersar[Data.incfilters-1] := data.levelright;
  end;
 
  Result := Data.Buffer;

end;

function uos_InputAddDSP1ChanTo2Chan(var Data: Tuos_Data; var fft: Tuos_FFT): TDArFloat;
//  Convert mono 1 chan input into stereo 2 channels input.
// Works only if the input is mono 1 channel othewise stereo 2 chan is keeped.
// InputIndex : InputIndex of a existing Input
//  result :  index of DSPIn in array
// example  DSPIndex1 := InputAdd1ChanTo2Chan(InputIndex1);
var
  x, x2: integer ;
  
  ps, ps2: PDArShort;// if input is Int16 format
  pl, pl2: PDArLong;// if input is Int32 format
  pf, pf2: PDArFloat;// if input is Float32 format

  buffer2 : TDArFloat;
  
  begin
  if (Data.channels = 1) then  
  begin
  setlength(Buffer2, Data.OutFrames);
  x:= 0 ;
  x2:= 0 ;
  
  case Data.SampleFormat of
  2:
  begin
  ps := @Data.Buffer;
  ps2 := @Buffer2;
  while x < Data.OutFrames -1 do
  begin  
  ps2^[x2] := (ps^[x]);
  ps2^[x2+1] := (ps^[x]);
  x := x + 1;
  x2 := x2 + 2;
  end;
  end;
  
  1:
  begin
  pl := @Data.Buffer;
  pl2 := @Buffer2;
  while x < Data.OutFrames -1  do
  begin  
  pl2^[x2] := (pl^[x]);
  pl2^[x2+1] := (pl^[x]);
  x := x + 1;
  x2 := x2 + 2;
  end;
  end;
  
  0:
  begin
  pf := @Data.Buffer;
  pf2 := @Buffer2;
  while x < Data.OutFrames -1  do
  begin  
  pf2^[x2] := (pf^[x]);
  pf2^[x2+1] := (pf^[x]);
  x := x + 1;
  x2 := x2 + 2;
  end;
  end;
  end;
  data.outframes := length(buffer2); 
  Result := Buffer2;; 
  end 
  else 
  begin
  Result := data.Buffer; 
  end;
  
  end;
  
function ConvertSampleFormat(Data: Tuos_Data): TDArFloat;
  var
  x : integer ;
  
  ps, ps2: PDArShort;// if input is Int16 format
  pl, pl2: PDArLong;// if input is Int32 format
  buffer2 : TDArFloat;
  
  begin
  if (Data.SampleFormat > 0) then  
  begin
  setlength(Buffer2, Data.OutFrames);
  x:= 0 ;

  case Data.SampleFormat of
  2:
  begin
  ps := @Data.Buffer;
  ps2 := @Buffer2;
  while x < Data.OutFrames  do
  begin  
  ps2^[x] := (ps^[x]);
  x := x + 1;
  end;
  end;
  
  1:
  begin
  pl := @Data.Buffer;
  pl2 := @Buffer2;
  while x < Data.OutFrames  do
  begin  
  pl2^[x] := (pl^[x]);
  x := x + 1;
  end;
  end;
  end;
  Result := Buffer2;
  end 
  else 
  begin
  Result := data.Buffer; 
  end;
  
  end;

  {$IF DEFINED(noiseremoval)}
  function Tuos_Player.InputAddDSPNoiseRemoval(InputIndex: cint32): cint32;
// DSP Noise Removal
// InputIndex : InputIndex of a existing Input
//  result :  otherwise index of DSPIn in array
// example  DSPIndex1 := InputAddDSPNoiseRemoval(InputIndex1);
  begin
  
 Result := InputAddDSP(InputIndex, nil, @uos_NoiseRemoval, nil, nil);  
 
 StreamIn[InputIndex].data.DSPNoiseIndex := Result ;
 
 StreamIn[InputIndex].DSP[result].fftdata := Tuos_FFT.Create();
  
 StreamIn[InputIndex].DSP[result].fftdata.FNoise:= 
 TuosNoiseRemoval.Create(StreamIn[InputIndex].data.Channels,StreamIn[InputIndex].data.SampleRate);
 
StreamIn[InputIndex].DSP[result].fftdata.FNoise.samprate :=
StreamIn[InputIndex].data.SampleRate;

StreamIn[InputIndex].DSP[result].fftdata.FNoise.WriteProc:=
@StreamIn[InputIndex].DSP[result].fftdata.FNoise.WriteData; 

StreamIn[InputIndex].DSP[result].fftdata.FNoise.isprofiled := false;
 
end;
  
procedure Tuos_Player.InputSetDSPNoiseRemoval(InputIndex: cint32; Enable: boolean);
  
begin
StreamIn[InputIndex].DSP[StreamIn[InputIndex].data.DSPNoiseIndex].enabled := Enable ; 
 end;  
 
function Tuos_Player.OutputAddDSPNoiseRemoval(OutputIndex: cint32): cint32;
// DSP Noise Removal
// OutputIndex : OutputIndex of a existing Output
//  result :  otherwise index of DSPInOut in array
// example  DSPIndex1 := OutputAddDSPNoiseRemoval(OutputIndex1);
 begin
  
 Result := OutputAddDSP(OutputIndex, nil, @uos_NoiseRemoval, nil, nil);  
 
 StreamOut[OutputIndex].data.DSPNoiseIndex := Result ;
 
 StreamOut[OutputIndex].DSP[result].fftdata :=  Tuos_FFT.Create();
  
 StreamOut[OutputIndex].DSP[result].fftdata.FNoise:= 
 TuosNoiseRemoval.Create(StreamOut[OutputIndex].data.Channels,StreamOut[OutputIndex].data.SampleRate);

StreamOut[OutputIndex].DSP[result].fftdata.FNoise.samprate :=
StreamOut[OutputIndex].data.SampleRate;

StreamOut[OutputIndex].DSP[result].fftdata.FNoise.WriteProc:=
@StreamOut[OutputIndex].DSP[result].fftdata.FNoise.WriteData; 

StreamOut[OutputIndex].DSP[result].fftdata.FNoise.isprofiled := false;
 
end;
  
procedure Tuos_Player.OutputSetDSPNoiseRemoval(OutputIndex: cint32; Enable: boolean);
 begin
 StreamOut[OutputIndex].DSP[StreamOut[OutputIndex].data.DSPNoiseIndex].enabled := Enable ; 
 end;  
  
  {$endif}  

function Tuos_Player.InputAddDSPVolume(InputIndex: cint32; VolLeft: double;
  VolRight: double): cint32;  
// DSP Volume changer
// InputIndex : InputIndex of a existing Input
// VolLeft : Left volume
// VolRight : Right volume
//  result : index of DSPIn in array
// example  DSPIndex1 := InputAddDSPVolume(InputIndex1,1,1);
begin
  Result := InputAddDSP(InputIndex, nil, @uos_DSPVolumeIn, nil, nil);
  StreamIn[InputIndex].Data.VLeft := VolLeft;
  StreamIn[InputIndex].Data.VRight := VolRight;
end;

function Tuos_Player.InputAddDSP1ChanTo2Chan(InputIndex: cint32): cint32;
//  Convert mono 1 channel input to stereo 2 channels input.
// Works only if the input is mono 1 channel othewise stereo 2 chan is keeped.
// InputIndex : InputIndex of a existing Input
//  result :  index of DSPIn in array
// example  DSPIndex1 := InputAddDSP1ChanTo2Chan(InputIndex1);
 begin
  Result := InputAddDSP(InputIndex, nil, @uos_InputAddDSP1ChanTo2Chan, nil, nil);
 end;

function Tuos_Player.OutputAddDSPVolume(OutputIndex: cint32; VolLeft: double;
  VolRight: double): cint32;// DSP Volume changer
// OutputIndex : OutputIndex of a existing Output
// VolLeft : Left volume ( 1 = max)
// VolRight : Right volume ( 1 = max)
//  result :  index of DSPIn in array
// example  DSPIndex1 := OutputAddDSPVolume(OutputIndex1,1,1);
begin
  Result := OutputAddDSP(OutputIndex, nil, @uos_DSPVolumeOut, nil, nil);
  StreamOut[OutputIndex].Data.VLeft := VolLeft;
  StreamOut[OutputIndex].Data.VRight := VolRight;
end;

procedure Tuos_Player.InputSetDSPVolume(InputIndex: cint32; DSPVolIndex: cint32;
  VolLeft: double; VolRight: double; Enable: boolean);
// InputIndex : InputIndex of a existing Input
// DSPIndex : DSPVolIndex of a existing DSPVolume
// VolLeft : Left volume ( -1 = do not change)
// VolRight : Right volume ( -1 = do not change)
// Enable : Enabled
// example  InputSetDSPVolume(InputIndex1,DSPVolIndex1,1,0.8,True);
begin
  if VolLeft <> -1 then
  StreamIn[InputIndex].Data.VLeft := VolLeft;
  if VolRight <> -1 then
  StreamIn[InputIndex].Data.VRight := VolRight;
  StreamIn[InputIndex].DSP[DSPVolIndex].Enabled := Enable;
end;

procedure Tuos_Player.OutputSetDSPVolume(OutputIndex: cint32;
  DSPVolIndex: cint32; VolLeft: double; VolRight: double; Enable: boolean);
// OutputIndex : OutputIndex of a existing Output
// DSPIndex : DSPIndex of a existing DSP
// VolLeft : Left volume
// VolRight : Right volume
// Enable : Enabled
// example  OutputSetDSPVolume(InputIndex1,DSPIndex1,1,0.8,True);
begin
  if VolLeft <> -1 then
  StreamOut[OutputIndex].Data.VLeft := VolLeft;
  if VolRight <> -1 then
  StreamOut[OutputIndex].Data.VRight := VolRight;
  StreamOut[OutputIndex].DSP[DSPVolIndex].Enabled := Enable;
end;

function Tuos_Player.InputAddFilter(InputIndex: cint32; LowFrequency: cint32;
  HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32; AlsoBuf: boolean;
  LoopProc: TProc ): cint32;
// InputIndex : InputIndex of a existing Input
// LowFrequency : Lowest frequency of filter
// HighFrequency : Highest frequency of filter
// Gain : gain to apply to filter ( 1 = no gain )
// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// LoopProc : external procedure of object to synchronize after DSP done
//  result : index of DSPIn in array
// example :FilterInIndex1 := InputAddFilter(InputIndex1,6000,16000,1,1,True,nil);
var
  FilterIndex: cint32;
begin
  FilterIndex := InputAddDSP(InputIndex, nil, @uos_BandFilter, nil, LoopProc);
  
 if alsobuf = false then
 begin
  StreamIn[InputIndex].data.hasfilters := true;
   inc(StreamIn[InputIndex].data.nbfilters);
 end;
 
  StreamIn[InputIndex].DSP[FilterIndex].fftdata :=
  Tuos_FFT.Create();
  
  setlength(StreamIn[InputIndex].DSP[FilterIndex].fftdata.Virtualbuffer, length(StreamIn[InputIndex].data.buffer));
   
  if TypeFilter = -1 then  TypeFilter := 1;
  InputSetFilter(InputIndex, FilterIndex, LowFrequency, HighFrequency,
  Gain, TypeFilter, AlsoBuf, True, LoopProc);

  Result := FilterIndex;
end;

function Tuos_Player.OutputAddFilter(OutputIndex: cint32; LowFrequency: cint32;
  HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32; AlsoBuf: boolean;
 LoopProc: TProc): cint32;
// OutputIndex : OutputIndex of a existing Output
// LowFrequency : Lowest frequency of filter
// HighFrequency : Highest frequency of filter
// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// LoopProc : external procedure of object to synchronize after DSP done
//  result :  index of DSPOut in array
// example :FilterOutIndex1 := OutputAddFilter(OutputIndex1,6000,16000,1,true);
var
  FilterIndex: cint32;
begin
  FilterIndex := OutputAddDSP(OutputIndex, nil, @uos_BandFilter, nil, LoopProc);
  
   if alsobuf = false then
 begin
  StreamIn[OutputIndex].data.hasfilters := true;  
   inc(StreamIn[OutputIndex].data.nbfilters);
 end;
  
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata :=
  Tuos_FFT.Create();
  
  if TypeFilter = -1 then  TypeFilter := 1;
  
  OutputSetFilter(OutputIndex, FilterIndex, LowFrequency, HighFrequency,
  Gain, TypeFilter, AlsoBuf, True, LoopProc);

  Result := FilterIndex;
end;

{$IF DEFINED(portaudio)}
function Tuos_Player.AddFromDevIn(Device: cint32; Latency: CDouble;
  SampleRate: cint32; OutputIndex: cint32;
  SampleFormat: cint32; FramesCount : cint32; ChunkCount: cint32): cint32;
// Add Input from IN device with custom parameters
// Device ( -1 is default Input device )
// Latency  ( -1 is latency suggested ) )
// SampleRate : delault : -1 (44100)
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex
// (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
// FramesCount : -1 default : 4096
// ChunkCount : default : -1 (= 512)
// example : AddFromDevIn(-1,-1,-1,-1);
var
  x, err: cint32;
begin
 result := -1 ;
  x := 0;
  err := -1;
  SetLength(StreamIn, Length(StreamIn) + 1);
  StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create();
  x := Length(StreamIn) - 1;
  StreamIn[x].Data.Enabled := false;
  StreamIn[x].Data.levelEnable := 0;
  StreamIn[x].Data.PositionEnable := 0;
  StreamIn[x].Data.levelArrayEnable := 0;

  StreamIn[x].PAParam.HostApiSpecificStreamInfo := nil;

  if device = -1 then
  StreamIn[x].PAParam.device :=
  Pa_GetDefaultInputDevice()
  else
  StreamIn[x].PAParam.device := cint32(device);

  if SampleRate = -1 then
  StreamIn[x].Data.SampleRate := DefRate
  else
  StreamIn[x].Data.SampleRate := SampleRate;

  StreamIn[x].PAParam.SuggestedLatency := CDouble(0);

  StreamIn[x].PAParam.SampleFormat := paInt16;

  case SampleFormat of
  0: StreamIn[x].PAParam.SampleFormat := paFloat32;
  1: StreamIn[x].PAParam.SampleFormat := paInt32;
  2: StreamIn[x].PAParam.SampleFormat := paInt16;
  end;

  if SampleFormat = -1 then
  StreamIn[x].Data.SampleFormat := CInt32(2)
  else
  StreamIn[x].Data.SampleFormat := CInt32(SampleFormat);

  if  ((Pa_GetDeviceInfo(StreamIn[x].PAParam.device)^.
  maxInputChannels)) > 1 then
  StreamIn[x].PAParam.channelCount := CInt32(2) else
  StreamIn[x].PAParam.channelCount := CInt32(1) ;

  StreamIn[x].data.channels := StreamIn[x].PAParam.channelCount;

  if FramesCount = -1 then  StreamIn[x].Data.Wantframes :=  4096 else
  StreamIn[x].Data.Wantframes := (FramesCount) ;
  
   if ChunkCount = -1 then  ChunkCount := 512;

  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes* StreamIn[x].Data.channels);

// StreamIn[x].Data.outframes := length(StreamIn[x].Data.Buffer);
  StreamIn[x].Data.outframes := 0;
  
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.TypePut := 1;
  StreamIn[x].Data.ratio := 2;
  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.seekable := False;
  StreamIn[x].Data.LibOpen := 2;
  StreamIn[x].LoopProc := nil;
  
  err := Pa_OpenStream(@StreamIn[x].Data.HandleSt, @StreamIn[x].PAParam,
  nil, CDouble(StreamIn[x].Data.SampleRate), CULong(ChunkCount), paClipOff, nil, nil);

  if err <> 0 then
  else
  begin
  StreamIn[x].Data.Enabled := True;
  Result := x;
  end;
end;
{$endif}

function Tuos_Player.AddFromEndlessMuted(Channels : cint32; FramesCount: cint32): cint32;
// Add a input from Endless Muted dummy sine wav
// FramesCountByChan = FramesCount of input-to-follow div channels of input-to-follow.
var
  x, i : cint32;
begin
 result := -1 ;
  x := 0;

  SetLength(StreamIn, Length(StreamIn) + 1);
  StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create();
  x := Length(StreamIn) - 1;
  StreamIn[x].Data.Enabled := false;
  StreamIn[x].Data.levelEnable := 0;
  StreamIn[x].Data.PositionEnable := 0;
  StreamIn[x].Data.levelArrayEnable := 0;

 if channels = -1 then
 StreamIn[x].data.channels := 2 else
  StreamIn[x].data.channels := Channels;
  
  StreamIn[x].Data.SampleRate := DefRate;
  
  if FramesCount = -1 then  StreamIn[x].Data.Wantframes :=  trunc(1024 * 2 div StreamIn[x].Data.channels)
  else
  StreamIn[x].Data.Wantframes := FramesCount * 2 div channels  ;
 
  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes* StreamIn[x].Data.channels);
  
   StreamIn[x].Data.OutFrames :=  StreamIn[x].Data.WantFrames ;
  
   for i := 0 to length(StreamIn[x].Data.Buffer) -1 do
  StreamIn[x].Data.Buffer[i] := 0.0;
  
  StreamIn[x].Data.SampleFormat := CInt32(0);
 
  StreamIn[x].Data.VLeft := 0;
  
  StreamIn[x].Data.Vright := 0;
 
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.TypePut := 5;
  StreamIn[x].Data.HandleSt := pchar('endless');
  StreamIn[x].Data.ratio := 2;
  StreamIn[x].Data.Output := -1;
  StreamIn[x].Data.seekable := False;
  StreamIn[x].Data.LibOpen := -1;
  StreamIn[x].LoopProc := nil;
  StreamIn[x].Data.Enabled := True;
  Result := x;
end;

{$IF DEFINED(synthesizer)}
function Tuos_Player.AddFromSynth(Frequency: float; VolumeL: float; VolumeR: float; duration : cint32; OutputIndex: cint32;
  SampleFormat: cint32 ; SampleRate: cint32 ; FramesCount : cint32): cint32;
// Add a input from Synthesizer with custom parameters
// Frequency : default : -1 (440 htz)
// VolumeL : default : -1 (= 1) (from 0 to 1) => volume left
// VolumeR : default : -1 (= 1) (from 0 to 1) => volume rigth
// Duration : default :  -1 (= 1000)  => duration in msec (0 = endless)
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (0: Float32) (0: Float32, 1:Int32, 2:Int16)
// SampleRate : delault : -1 (44100)
// FramesCount : -1 default : 1024
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := AddFromSynth(880,-1,-1,-1,-1,-1,-1);
 
var
  x : cint32;
begin
 result := -1 ;
  x := 0;

  SetLength(StreamIn, Length(StreamIn) + 1);
  StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create();
  x := Length(StreamIn) - 1;
  StreamIn[x].Data.Enabled := false;
  StreamIn[x].Data.levelEnable := 0;
  StreamIn[x].Data.PositionEnable := 0;
  StreamIn[x].Data.levelArrayEnable := 0;

  StreamIn[x].data.channels := 2;
  
  if SampleRate = -1 then
  StreamIn[x].Data.SampleRate := DefRate
  else
  StreamIn[x].Data.SampleRate := SampleRate;
  
  if FramesCount = -1 then  StreamIn[x].Data.Wantframes :=  1024 else
  StreamIn[x].Data.Wantframes := FramesCount ;
 
  if Frequency = -1 then 
  StreamIn[x].Data.freqsine := 440  else
  StreamIn[x].Data.freqsine := Frequency ;

  StreamIn[x].Data.lensine := StreamIn[x].Data.SampleRate / StreamIn[x].Data.freqsine*2 ;

  StreamIn[x].Data.posLsine := 0 ;
  StreamIn[x].Data.posRsine := 0 ;
  
 
  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes* StreamIn[x].Data.channels);
  
  StreamIn[x].Data.posdursine := 0 ;
  
  if duration = -1 then duration := 1000;
  StreamIn[x].Data.dursine := trunc( StreamIn[x].Data.SampleRate * duration / 1000);  
  
  if SampleFormat = -1 then
  StreamIn[x].Data.SampleFormat := CInt32(0)
  else
  StreamIn[x].Data.SampleFormat := CInt32(SampleFormat);

  if VolumeL = -1 then StreamIn[x].Data.VLeft := 1 else
  StreamIn[x].Data.VLeft := VolumeL;
  
  if VolumeR = -1 then StreamIn[x].Data.Vright := 1 else
  StreamIn[x].Data.Vright := VolumeR;
 
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.TypePut := 3;
  StreamIn[x].Data.HandleSt := pchar('synth');
  StreamIn[x].Data.ratio := 2;
  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.seekable := False;
  StreamIn[x].Data.LibOpen := -1;
  StreamIn[x].LoopProc := nil;
  StreamIn[x].Data.Enabled := True;
  Result := x;
end;

procedure Tuos_Player.InputSetSynth(InputIndex: cint32; Frequency: float; VolumeL: float; VolumeR: float;  Duration: cint32; Enable : boolean);
// Frequency : in Hertz (-1 = do not change)
// VolumeL :  from 0 to 1 (-1 = do not change)
// VolumeR :  from 0 to 1 (-1 = do not change)
// Duration : in msec (-1 = do not change)
// Enable : true or false ;

begin
 if Frequency <> -1 then
 begin
 StreamIn[InputIndex].Data.Enabled := Enable;
 StreamIn[InputIndex].Data.freqsine := Frequency ;
 StreamIn[InputIndex].Data.lensine := (StreamIn[InputIndex].Data.SampleRate / Frequency*2) ;
 end;
 if VolumeL <> -1 then StreamIn[InputIndex].Data.VLeft := VolumeL;
  
 if VolumeR <> -1 then StreamIn[InputIndex].Data.Vright := VolumeR;
 
 if Duration <> -1 then  StreamIn[InputIndex].Data.dursine := trunc( StreamIn[InputIndex].Data.SampleRate * duration / 1000);  
end;
{$endif}

{$IF DEFINED(shout)}
function Tuos_Player.AddIntoIceServer(SampleRate : cint; Channels: cint; SampleFormat: cint;
 EncodeType: cint; Port: cint; Host: pchar; User: pchar; Password: pchar; MountFile :pchar): cint32;
// Add a Output into a IceCast server for audio-web-streaming 
// SampleRate : delault : -1 (48100)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// SampleFormat : -1 default : float32 : (0:float32, 1:Int16)
// EncodeType : default : -1 (0:Music) (0: Music, 1:Voice)
// Port : default : -1 (= 8000)
// Host : default : 'def' (= '127.0.0.1')
// User : default : 'def' (= 'source')
// Password : default : 'def' (= 'hackme')
// MountFile : default : 'def' (= '/example.opus')
//  result :  Output Index in array  -1 = error

var
  x, typeenc : cint32;
  err : integer = -1;
 
 begin
 
 result := -1 ;
  x := 0;
  err := -1;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := Tuos_OutStream.Create();
  x := Length(StreamOut) - 1;
  
   StreamOut[x].Data.Enabled := false;
  
  if (EncodeType = -1) or (EncodeType = 0)  then typeenc := OPUS_APPLICATION_AUDIO else
  typeenc := OPUS_APPLICATION_VOIP ; 

  if SampleRate = -1 then StreamOut[x].Data.SampleRate := 48000 else
  StreamOut[x].Data.SampleRate := SampleRate;
  
  if Channels = -1 then StreamOut[x].Data.Channels := 2 else
  StreamOut[x].Data.Channels := Channels;
  
  if SampleFormat = -1 then StreamOut[x].Data.SampleFormat := 0 else
  StreamOut[x].Data.SampleFormat := SampleFormat;
 
  StreamOut[x].Data.TypePut := 2 ;
 
  setlength(StreamOut[x].Data.Buffer,1024 *2); 
  
//  setlength(StreamOut[x].Data.Buffer,960); 
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('before opus_encoder_create ' );
  {$endif}

// opus encoder
  StreamOut[x].encoder := opus_encoder_create(StreamOut[x].Data.SampleRate,
  StreamOut[x].Data.Channels, typeenc, err);

 {$IF DEFINED(debug) and DEFINED(unix)}
  if (err<0)
  then begin
  WriteLn(Format('failed to create an encoder: %s', [opus_strerror(err)]));
  end; 
  {$endif}  
// if (err=0) then
//  err := opus_encoder_ctl(StreamOut[x].encoder , OPUS_SET_BITRATE(cBITRATE));
  {$IF DEFINED(debug) and DEFINED(unix)}
  if (err<0)
  then begin
  WriteLn(Format('failed opus_encoder_ctl: %s', [opus_strerror(err)]));
  end; 
  {$endif}

if err =0 then begin

 StreamOut[x].Data.HandleSt := nil; 
 
  shout_init();

  StreamOut[x].Data.HandleSt := shout_new();

  if assigned(StreamOut[x].Data.HandleSt) then
  begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('shhandle assigned');
  {$endif}
  err := shout_set_host( StreamOut[x].Data.HandleSt, pchar(Host));
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = SHOUTERR_SUCCESS then
  WriteLn('shout_set_host ok ' + inttostr(err)) else
  WriteLn('shout_set_host error: ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  {$endif}
  err := shout_set_protocol(StreamOut[x].Data.HandleSt, SHOUT_PROTOCOL_HTTP);
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = SHOUTERR_SUCCESS then
  WriteLn('shout_set_protocol ' + inttostr(err)) else
  WriteLn('shout_set_protocol error: ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  {$endif}
  err := shout_set_port(StreamOut[x].Data.HandleSt, Port);
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = SHOUTERR_SUCCESS then
  WriteLn('shout_set_port ok ' + inttostr(err)) else
  WriteLn('shout_set_port error: ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  {$endif}
  err := shout_set_password(StreamOut[x].Data.HandleSt, pchar(Password));
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = SHOUTERR_SUCCESS then
  WriteLn('set_password ok ' + inttostr(err)) else
  WriteLn('set_password error: ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  {$endif}
  err := shout_set_mount(StreamOut[x].Data.HandleSt, pchar(MountFile));
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = SHOUTERR_SUCCESS then
  WriteLn('shout_set_mount ok ' + inttostr(err)) else
  WriteLn('shout_set_mount error: ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  {$endif}
  err := shout_set_user(StreamOut[x].Data.HandleSt, pchar(user));
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = SHOUTERR_SUCCESS then
  WriteLn('shout_set_user ok ' + inttostr(err)) else
  WriteLn('shout_set_user error: ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  {$endif}
  err := shout_set_format(StreamOut[x].Data.HandleSt,  SHOUT_FORMAT_OGG);
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = SHOUTERR_SUCCESS then
  WriteLn('shout_set_format ok ' + inttostr(err)) else
  WriteLn('shout_set_format error: ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  {$endif}
  err := shout_open(StreamOut[x].Data.HandleSt);
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = SHOUTERR_SUCCESS then
  WriteLn('shout_open ok ' + inttostr(err)) else
  WriteLn('shout_open error: ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  {$endif}
  
  if err = SHOUTERR_SUCCESS then 
  begin
   StreamOut[x].Data.Enabled := True;
  result := x 
  end else
  begin
  shout_free(StreamOut[x].Data.HandleSt);
  StreamOut[Length(StreamOut) - 1].Destroy;
  setlength(StreamOut, Length(StreamOut) - 1);
  end;
  end else
  begin
  StreamOut[Length(StreamOut) - 1].Destroy;
  setlength(StreamOut, Length(StreamOut) - 1);
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('shhandle not assigned')  {$endif} ;
 end;
 end;
 end; 
 {$endif}
 
procedure uos_CustBufferInfos(var bufferinfos: Tuos_BufferInfos; SampleRate: longword; SampleFormat : cint32; Channels: cint32 ; Length: cint32);
begin
  bufferinfos.SampleRate := Samplerate; 
  bufferinfos.SampleRateRoot := Samplerate;
  bufferinfos.SampleFormat := SampleFormat;
  bufferinfos.Channels := Channels;
  bufferinfos.Length := Length;
  bufferinfos.LibOpen := 0;
  bufferinfos.Ratio := 2 ;
end; 


function Tuos_Player.AddIntoFileFromMem(Filename: PChar; SampleRate: LongInt;
  Channels: LongInt; SampleFormat: LongInt; FramesCount: LongInt; FileFormat: cint32): LongInt;
// Add a Output into audio wav file with Custom parameters
// FileName : filename of saved audio wav file
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
//  SampleFormat : -1 default : Int16 : (1:Int32, 2:Int16)
// FramesCount : -1 default : 65536 div channels
// FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom);
//  result :  Output Index in array    -1 = error
// example : OutputIndex1 := AddIntoFileFromMem(edit5.Text,-1,-1,0, -1);
var
  x: LongInt;
begin
  result := -1 ;
  x := 0;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := Tuos_OutStream.Create();
  x := Length(StreamOut) - 1;
   StreamOut[x].Data.Enabled := false;
  StreamOut[x].FileBuffer.ERROR := 0;
  StreamOut[x].Data.Filename := filename;
  if (FileFormat = -1) or (FileFormat = 0) then 
  StreamOut[x].FileBuffer.FileFormat := 0 else StreamOut[x].FileBuffer.FileFormat := FileFormat;
  StreamOut[x].Data.TypePut := 4;
    FillChar(StreamOut[x].FileBuffer, sizeof(StreamOut[x].FileBuffer), 0);
  StreamOut[x].FileBuffer.DataMS := TMemoryStream.Create;

   result := x;

   if (Channels = -1) then
    StreamOut[x].FileBuffer.wChannels := 2
  else
    StreamOut[x].FileBuffer.wChannels := Channels;

   StreamOut[x].Data.Channels := StreamOut[x].FileBuffer.wChannels;

    if FramesCount = -1 then  StreamOut[x].Data.Wantframes :=  65536 div StreamOut[x].Data.Channels else
  StreamOut[x].Data.Wantframes := FramesCount ;

  SetLength(StreamOut[x].Data.Buffer, StreamOut[x].Data.Wantframes*StreamOut[x].Data.Channels);

    if (SampleFormat = -1) or (SampleFormat = 2) then
  begin
    StreamOut[x].FileBuffer.wBitsPerSample := 16;
    StreamOut[x].Data.SampleFormat := 2;
  end;

  if (SampleFormat = 1) then
  begin
    StreamOut[x].FileBuffer.wBitsPerSample := 32;
    StreamOut[x].Data.SampleFormat := 1;
  end;

  if SampleRate = -1 then
    StreamOut[x].FileBuffer.wSamplesPerSec := 44100
  else
    StreamOut[x].FileBuffer.wSamplesPerSec := samplerate;
    
  StreamOut[x].Data.Samplerate := StreamOut[x].FileBuffer.wSamplesPerSec;
  StreamOut[x].LoopProc := nil;
  StreamOut[x].Data.Enabled := True;
end;

function Tuos_Player.AddIntoFile(Filename: PChar; SampleRate: cint32;
  Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ; FileFormat: cint32): cint32;
// Add a Output into audio wav file with custom parameters
// FileName : filename of saved audio wav file
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// SampleFormat : default : -1 (2:Int16) ( 1:Int32, 2:Int16)
// FramesCount : default : -1 (= 4096)
// FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom);
//  result : Output Index in array  -1 = error
// example : OutputIndex1 := AddIntoFile(edit5.Text,-1,-1, 0, -1, -1);
var
  x: cint32;
  wChunkSize: cint32;
  wFileSize: cint32;
  IDwav: array[0..3] of char;
  Header: Tuos_WaveHeaderChunk;

begin
  result := -1 ;
  x := 0;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := Tuos_OutStream.Create();
  x := Length(StreamOut) - 1;
   StreamOut[x].Data.Enabled := false;
  StreamOut[x].FileBuffer.ERROR := 0;
  StreamOut[x].Data.TypePut := 0 ;
  StreamOut[x].Data.Filename := filename;
  if (FileFormat = -1) or (FileFormat = 0) then 
  StreamOut[x].FileBuffer.FileFormat := 0 else StreamOut[x].FileBuffer.FileFormat := FileFormat;
  
  FillChar(StreamOut[x].FileBuffer, sizeof(StreamOut[x].FileBuffer), 0);

  result := x;

  if (Channels = -1) then
  StreamOut[x].FileBuffer.wChannels := 2
  else
  StreamOut[x].FileBuffer.wChannels := Channels;

  StreamOut[x].Data.Channels := StreamOut[x].FileBuffer.wChannels;

  if FramesCount = -1 then  StreamOut[x].Data.Wantframes :=  65536 div StreamOut[x].Data.Channels else
  StreamOut[x].Data.Wantframes := FramesCount ;

  SetLength(StreamOut[x].Data.Buffer, StreamOut[x].Data.Wantframes*StreamOut[x].Data.Channels);

  if (SampleFormat = -1) or (SampleFormat = 2) then
  begin
  StreamOut[x].FileBuffer.wBitsPerSample := 16;
  StreamOut[x].Data.SampleFormat := 2;
  end;

  if (SampleFormat = 1) then
  begin
  StreamOut[x].FileBuffer.wBitsPerSample := 32;
  StreamOut[x].Data.SampleFormat := 1;
  end;
  
  if (SampleFormat = 0) then
  begin
  StreamOut[x].FileBuffer.wBitsPerSample := 32;
  StreamOut[x].Data.SampleFormat := 0;
  end;

  if SampleRate = -1 then
  StreamOut[x].FileBuffer.wSamplesPerSec := 44100
  else
  StreamOut[x].FileBuffer.wSamplesPerSec := samplerate;
  
  StreamOut[x].Data.Samplerate := StreamOut[x].FileBuffer.wSamplesPerSec;
  StreamOut[x].LoopProc := nil;

  try
  StreamOut[x].FileBuffer.Data := TFileStream.Create(filename,fmCreate);
  StreamOut[x].FileBuffer.Data.Seek(0, soFromBeginning);
  
  if StreamOut[x].FileBuffer.FileFormat = 0 then 
  begin// wav file
  IDwav := 'RIFF';
  StreamOut[x].FileBuffer.Data.WriteBuffer(IDwav, 4);
  wFileSize := 0;
  StreamOut[x].FileBuffer.Data.WriteBuffer(wFileSize, 4);
  IDwav := 'WAVE';
  StreamOut[x].FileBuffer.Data.WriteBuffer(IDwav, 4);
  IDwav := 'fmt ';
  StreamOut[x].FileBuffer.Data.WriteBuffer(IDwav, 4);
  wChunkSize := SizeOf(Header);
  StreamOut[x].FileBuffer.Data.WriteBuffer(wChunkSize, 4);
  Header.wFormatTag := 1;

  Header.wChannels := StreamOut[x].FileBuffer.wChannels;

  Header.wSamplesPerSec := StreamOut[x].FileBuffer.wSamplesPerSec;

  Header.wBlockAlign := StreamOut[x].FileBuffer.wChannels * (StreamOut[x].FileBuffer.wBitsPerSample div 8);

  Header.wAvgBytesPerSec := StreamOut[x].FileBuffer.wSamplesPerSec * Header.wBlockAlign;
  Header.wBitsPerSample := StreamOut[x].FileBuffer.wBitsPerSample;
  Header.wcbSize := 0;
  StreamOut[x].FileBuffer.Data.WriteBuffer(Header, SizeOf(Header));
  IDwav := 'data';
  StreamOut[x].FileBuffer.Data.WriteBuffer(IDwav, 4);
  wChunkSize:= 0;
  StreamOut[x].FileBuffer.Data.WriteBuffer(wChunkSize, 4);
  StreamOut[x].Data.Enabled := True;
  end;
  
  except
//  Result := HeaderWriteError;
  end;
 end;
 
 function  Tuos_Player.AddIntoMemoryBuffer(outmemory: PDArFloat): cint32;
// Add a Output into memory-bufffer
// outmemory : buffer to use to store memory buffer
// example : OutputIndex1 := AddIntoMemoryBuffer(bufmemory);
 
var
  x: integer;
  begin
  result := -1 ;
  x := 0;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := Tuos_OutStream.Create();
  x := Length(StreamOut) - 1;
  StreamOut[x].Data.Enabled := false;
  StreamOut[x].Data.TypePut := 3;
  Streamout[x].Data.posmem := 0;
  Streamout[x].BufferOut := outmemory;
  StreamOut[x].Data.Wantframes := 1024*2 ;
  StreamOut[x].Data.SampleRate := 44100 ;
  SetLength(StreamOut[x].Data.Buffer,1024*4);
  intobuf := true;// to check, why ?
  result := x;
   StreamOut[x].Data.Enabled := True;
  end;
 
function  Tuos_Player.AddIntoMemoryBuffer(outmemory: PDArFloat; SampleRate: LongInt;  SampleFormat: LongInt;
      Channels: LongInt; FramesCount: LongInt): LongInt;  
// Add a Output into TMemoryStream
// outmemory : pointer of buffer to use to store memory.
// SampleRate : delault : -1 (44100)
// SampleFormat : default : -1 (2:Int16) ( 1:Int32, 2:Int16)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// FramesCount : default : -1 (= 1024 * 2) 

  var
  x, ch, sr, sf, fr: integer;
  begin
  result := -1 ;
  x := 0;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := Tuos_OutStream.Create();
  x := Length(StreamOut) - 1;
  StreamOut[x].Data.Enabled := false;
  StreamOut[x].Data.TypePut := 3;
  Streamout[x].Data.posmem := 0;
  Streamout[x].BufferOut := outmemory;
  if channels = -1 then ch := 2 else ch := channels;
  StreamOut[x].Data.channels := ch;
  if SampleFormat = -1 then sf := 2 else sf := SampleFormat;
  StreamOut[x].Data.SampleFormat := sf;
  if FramesCount = -1 then fr := 1024 *2  else fr := FramesCount;
  StreamOut[x].Data.Wantframes := fr ;
  if SampleRate = -1 then sr := 44100  else sr := SampleRate;
  StreamOut[x].Data.SampleRate := sr ;
  
  SetLength(StreamOut[x].Data.Buffer,fr*ch);
  intobuf := true;// to check, why ?
  result := x;
  StreamOut[x].Data.Enabled := True;
  end;
  
function Tuos_Player.AddIntoMemoryStream(var MemoryStream: TMemoryStream; SampleRate: LongInt; 
       SampleFormat: LongInt ; Channels: LongInt; FramesCount: LongInt): LongInt;  
// Add a Output into TMemoryStream
// MemoryStream : the TMemoryStream to use to store memory.
// SampleRate : delault : -1 (44100)
// SampleFormat : default : -1 (2:Int16) ( 1:Int32, 2:Int16)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// FramesCount : default : -1 (= 4096)
 var
  x, ch, sr, sf, fr: integer;
  begin
  result := -1 ;
  x := 0;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := Tuos_OutStream.Create();
  x := Length(StreamOut) - 1;
  StreamOut[x].Data.Enabled := false;
  StreamOut[x].Data.TypePut := 5;
   if channels = -1 then ch := 2 else ch := channels;
  StreamOut[x].Data.channels := ch;
  if SampleFormat = -1 then sf := 2 else sf := SampleFormat;
  StreamOut[x].Data.SampleFormat := sf;
  if FramesCount = -1 then fr := 1024 *2  else fr := FramesCount;
  StreamOut[x].Data.Wantframes := fr ;
  if SampleRate = -1 then sr := 44100  else sr := SampleRate;
  StreamOut[x].Data.SampleRate := sr ;
  
  Streamout[x].Data.posmem := 0;
  
// if MemoryStream = nil then
// MemoryStream := Tmemorystream.create;
  
  Streamout[x].MemorySteamOut := MemoryStream;
  
   SetLength(StreamOut[x].Data.Buffer, StreamOut[x].Data.Wantframes*StreamOut[x].Data.Channels);
   result := x;
   StreamOut[x].Data.Enabled := True;
  end;

 {$IF DEFINED(portaudio)}
  function Tuos_Player.AddIntoDevOut(Device: cint32; Latency: CDouble;
  SampleRate: cint32; Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ; ChunkCount: cint32): cint32;
// Add a Output into Device Output
// Device ( -1 is default device )
// Latency  ( -1 is latency suggested )
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (= 65536)
// ChunkCount : default : -1 (= 512)
//  result :  Output Index in array  -1 = error
// example : OutputIndex1 := AddIntoDevOut(-1,-1,-1,-1,0,-1,-1);
var
  x, x2, err: cint32;
  
begin
  result := -1 ;
  x := 0;
  err := -1;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := Tuos_OutStream.Create();
  x := Length(StreamOut) - 1;
  
   StreamOut[x].Data.Enabled := false;
   
   {$IF DEFINED(portaudio)}
   StreamOut[x].PAParam.hostApiSpecificStreamInfo := nil;
  if device = -1 then
  StreamOut[x].PAParam.device := Pa_GetDefaultOutputDevice()
  else
  StreamOut[x].PAParam.device := device;
  {$endif} 
  
  if SampleRate = -1 then
  StreamOut[x].Data.SampleRate := DefRate
  else
  StreamOut[x].Data.SampleRate := SampleRate;

 {$IF DEFINED(portaudio)}
  
  if Latency = -1 then
    StreamOut[x].PAParam.SuggestedLatency :=    CDouble((Pa_GetDeviceInfo(StreamOut[x].PAParam.device)^.   defaultHighOutputLatency)) * 1
 else   StreamOut[x].PAParam.SuggestedLatency := CDouble(Latency);

 
  {$IF DEFINED(android)}
  StreamOut[x].PAParam.SampleFormat := paFloat32;
  {$else}
  StreamOut[x].PAParam.SampleFormat := paInt16;
  {$endif}

  case SampleFormat of
  0: StreamOut[x].PAParam.SampleFormat := paFloat32;
  1: StreamOut[x].PAParam.SampleFormat := paInt32;
  2: StreamOut[x].PAParam.SampleFormat := paInt16;
  end;
 {$endif} 

 if SampleFormat = -1 then
  StreamOut[x].Data.SampleFormat := 2 else
  StreamOut[x].Data.SampleFormat := SampleFormat;

  if Channels = -1 then
  begin
  {$IF DEFINED(portaudio)}
   StreamOut[x].PAParam.channelCount := 2  ;
  {$endif} 
   StreamOut[x].Data.Channels := 2  ;
  end
  else
  begin
   {$IF DEFINED(portaudio)}
  StreamOut[x].PAParam.channelCount := CInt32(Channels);
   {$endif} 
   StreamOut[x].Data.Channels := CInt32(Channels);
  end;

  if FramesCount = -1 then  StreamOut[x].Data.Wantframes :=

  {$IF DEFINED(android)}
  1024 * 64 else
  {$else}
  65536 div StreamOut[x].Data.Channels else
  {$endif}
  StreamOut[x].Data.Wantframes := FramesCount ;

  if ChunkCount = -1 then  ChunkCount := 512;

  SetLength(StreamOut[x].Data.Buffer, StreamOut[x].Data.Wantframes*StreamOut[x].Data.Channels);

x2 := 0 ;
while x2 < Length(StreamOut[x].Data.Buffer) do 
begin
StreamOut[x].Data.Buffer[x2] := 0.0 ;
inc(x2);
end;

  StreamOut[x].Data.TypePut := 1;
  
  {$IF DEFINED(portaudio)}
  err := Pa_OpenStream(@StreamOut[x].Data.HandleSt, nil, @StreamOut[x].PAParam, CDouble(StreamOut[x].Data.SampleRate), CULong(ChunkCount), paClipOff, nil, nil);
 //   err := Pa_OpenDefaultStream(@StreamOut[x].Data.HandleSt, 2, 2, paFloat32, DefRate, 512, nil, nil);
  {$endif}

  StreamOut[x].LoopProc := nil;
  if err <> 0 then Result := -1
  else
  begin
  StreamOut[x].Data.Enabled := True;
  Result := x;
  end;
end;

 {$endif}

{$IF DEFINED(webstream)}

function Tuos_Player.AddFromURL(URL: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32 ; AudioFormat: cint32 ; ICYon : boolean): cint32;
// Add a Input from Audio URL
// URL : URL of audio file
// OutputIndex : OutputIndex of existing Output// -1: all output, -2: no output, other cint32 : existing Output
// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
// AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
// ICYon : ICY data on/off
// example : InputIndex := AddFromURL('http://someserver/somesound.mp3',-1,-1,-1,-1,-1, false);
 
 var
  x, err, len, len2, i : cint32;
  PipeBufferSize, totsamples : integer;
  buffadd : tbytes;
  
   {$IF DEFINED(sndfile)}
//  sfInfo: TSF_INFO;
  {$endif}
  
  {$IF DEFINED(mpg123)}
  mpinfo: Tmpg123_frameinfo;
// BufferTag: array[1..128] of char; 
// F: file; 
// mpid3v2: Tmpg123_id3v2;
  {$endif}
  
  {$IF DEFINED(opus)}
  s: UTF8String;
  j: Integer;
  OpusTag: POpusTags;
  LComment: PPAnsiChar;
  LcommentLength: PInteger;
  {$endif}
  
 begin
  result := -1 ;
  x := 0;
  err := -1;

  SetLength(StreamIn, Length(StreamIn) + 1);
  
  StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create;
  x := Length(StreamIn) - 1;
  
  StreamIn[x].Data.Enabled := false;
  
  StreamIn[x].Data.LibOpen := -1;
  StreamIn[x].Data.levelEnable := 0;
  StreamIn[x].Data.positionEnable := 0;
  StreamIn[x].Data.levelArrayEnable := 0;
  
  {$IF DEFINED(opus)}
  if  (AudioFormat = 1)
// or (AudioFormat = -1)
  then
  begin
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('Begin opus test');
  {$endif}
  
  if FramesCount= -1 then
  totsamples := 4096  else
  totsamples := FramesCount;
  
  PipeBufferSize := totsamples * sizeOf(Single);// * 2
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('totsamples: ' + inttostr(totsamples));
  WriteLn('PipeBufferSize: ' + inttostr(PipeBufferSize));
  {$endif}

  CreatePipeHandles(StreamIn[x].InHandle, StreamIn[x].OutHandle, PipeBufferSize);
  StreamIn[x].InPipe := TInputPipeStream.Create(StreamIn[x].InHandle);
  StreamIn[x].OutPipe := TOutputPipeStream.Create(StreamIn[x].OutHandle);

  StreamIn[x].httpget := TThreadHttpGetter.Create(url, StreamIn[x].OutPipe);
  
  StreamIn[x].httpget.ICYenabled := false;// TODO
  
  StreamIn[x].httpget.FIsRunning:=True;

  StreamIn[x].httpget.Start; 
//  WriteLn('StreamIn[x].httpget.Start');
  
  len := 1 ;
  len2 := 0 ;
  
  setlength(buffadd, PipeBufferSize);
  setlength(StreamIn[x].data.BufferTMP, PipeBufferSize);
    
  while (len2 < PipeBufferSize) and (len > 0) do
  begin
 len := StreamIn[x].InPipe.Read(buffadd[0],PipeBufferSize-len2);
  if len > 0 then  for i := 0 to len -1 do
  StreamIn[x].data.BufferTMP[i+len2] := buffadd[i] ;
  len2 := len2 + len;
  end;
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('PipeBufferSize = ' + inttostr(PipeBufferSize));
  WriteLn('InPipe.Read = ' + inttostr(len2));
  WriteLn('----------------------------------');
//writeln(tencoding.utf8.getstring(StreamIn[x].data.BufferTMP));
  {$endif}

  StreamIn[x].Data.HandleSt := pchar('opusurl');
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('StreamIn[x].Data.HandleSt url assisgned');
  {$endif}
  
 StreamIn[x].Data.HandleOP :=
// op_open_callbacks(StreamIn[x].InPipe, uos_callbacks, StreamIn[x].data.BufferTMP[0], PipeBufferSize, err); 
 op_test_callbacks(StreamIn[x].InPipe, uos_callbacks, StreamIn[x].data.BufferTMP[0], PipeBufferSize, err); 
//  op_test_memory(StreamIn[x].data.BufferTMP[0],PipeBufferSize, Err);
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('error: op_test_*: ' + inttostr(err));
 {$endif}
  
  if Err=0
  then begin
  Err := op_test_open(StreamIn[x].Data.HandleOP);
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('error: op_test_open: ' + inttostr(err));  
 {$endif}
  
  if (Err=0) and (op_link_count(StreamIn[x].Data.HandleOP)=1)
  then begin  
 
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('OK open');  
 {$endif}
 
  if SampleFormat = -1 then
  StreamIn[x].Data.SampleFormat := 2
  else
  StreamIn[x].Data.SampleFormat := SampleFormat;  
  
//tag  
  
  OpusTag := op_tags(StreamIn[x].Data.HandleOP, nil);
  
  if OpusTag<>nil
  
  then begin
  
  if OpusTag^.comments>0
  then begin
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn((Format('OpusTag.comments = %d', [OpusTag^.comments])));  
 {$endif}
  LComment := OpusTag^.user_comments;
  LcommentLength := OpusTag^.comment_lengths; 
  
  for j := 0 to OpusTag^.comments - 1 do
  begin
  SetLength(s, LcommentLength^);
  move(Pointer(LComment^)^, Pointer(s)^, LcommentLength^);

 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn(s);  
 {$endif}  
  if j = 1 then StreamIn[x].Data.title := s;
  if j = 2 then StreamIn[x].Data.artist := s;
  if j = 3 then StreamIn[x].Data.album := s;
  if j = 4 then StreamIn[x].Data.date := s;
  if j = 5 then StreamIn[x].Data.comment := s;
  if j = 6 then StreamIn[x].Data.tag := s;
  if j > 6 then StreamIn[x].Data.comment := StreamIn[x].Data.comment + ' ' + s;
  
  inc(LComment);
  inc(LcommentLength);
  end;
  end;
  end;
  
  StreamIn[x].Data.Length := op_pcm_total(StreamIn[x].Data.HandleOP, nil);
  StreamIn[x].Data.filename := url;
  StreamIn[x].Data.channels := op_channel_count(StreamIn[x].Data.HandleOP, nil);
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn((Format('op_bitrate = %d', [op_bitrate(StreamIn[x].Data.HandleOP, nil)])));  
  WriteLn('Length ' + inttostr(StreamIn[x].Data.Length));  
  WriteLn('Data.Channels ' + inttostr(StreamIn[x].Data.channels));  
  {$endif}
  
  StreamIn[x].Data.samplerate :=  48000 ;
  StreamIn[x].Data.samplerateroot :=  StreamIn[x].Data.samplerate ;
  StreamIn[x].Data.Wantframes := totsamples ;
  
  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes);
  
  StreamIn[x].Data.LibOpen := 4;
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.Position := 0;
  StreamIn[x].Data.OutFrames := 0;
  StreamIn[x].Data.Poseek := -1;
  StreamIn[x].Data.TypePut := 2;
  StreamIn[x].Data.ratio := 1;
  StreamIn[x].Data.seekable := false;
  StreamIn[x].LoopProc := nil;
  StreamIn[x].Data.Enabled := True;
 
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('End opus');  
  {$endif}  

  end;
  end;
  end;
  {$endif}
  
  {$IF DEFINED(mpg123)}
  if (StreamIn[x].Data.LibOpen = -1) and ((AudioFormat = 0) or (AudioFormat = -1)) then
  begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('Begin mpg123');  
 {$endif} 
  
  if FramesCount= -1 then
  totsamples := $4000  else
  totsamples := FramesCount;
  
  PipeBufferSize := totsamples ;

  CreatePipeHandles(StreamIn[x].InHandle, StreamIn[x].OutHandle, PipeBufferSize);

  StreamIn[x].InPipe := TInputPipeStream.Create(StreamIn[x].InHandle);
  StreamIn[x].OutPipe := TOutputPipeStream.Create(StreamIn[x].OutHandle);

  StreamIn[x].httpget := TThreadHttpGetter.Create(url, StreamIn[x].OutPipe);
  
   StreamIn[x].httpget.ICYenabled := ICYon;
  
  StreamIn[x].Data.HandleSt := mpg123_new(nil, Err);

 {$IF DEFINED(debug) and DEFINED(unix)}
 if err = 0 then writeln('===> mpg123_new => ok.') else writeln('===> mpg123_new NOT ok.') ;
 {$endif}

  if Err = 0 then
  begin
  if SampleFormat = -1 then
  StreamIn[x].Data.SampleFormat := 2
  else
  StreamIn[x].Data.SampleFormat := SampleFormat;
  
    mpg123_format_none(StreamIn[x].Data.HandleSt);
  case StreamIn[x].Data.SampleFormat of
  0: mpg123_format(StreamIn[x].Data.HandleSt, DefRate, Stereo,
  MPG123_ENC_FLOAT_32);
  1: mpg123_format(StreamIn[x].Data.HandleSt, DefRate, Stereo,
  MPG123_ENC_SIGNED_32);
  2: mpg123_format(StreamIn[x].Data.HandleSt, DefRate, Stereo,
  MPG123_ENC_SIGNED_16);
  end;

// mpg123_replace_reader_handle(StreamIn[x].Data.HandleSt, @mpg_read_stream, @mpg_seek_url, @mpg_close_stream);
  mpg123_replace_reader_handle(StreamIn[x].Data.HandleSt,
  @mpg_read_stream, @mpg_seek_url, nil);
    
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = 0 then writeln('===> mpg123_replace_reader_handle => ok.') ;
  {$endif}
  
  if StreamIn[x].httpget.ICYenabled = true then
   StreamIn[x].UpdateIcyMetaInterval ;

 
  StreamIn[x].httpget.FIsRunning:=True; 
  StreamIn[x].httpget.Start; 
  
  if StreamIn[x].httpget.ICYenabled = true then
   CheckSynchronize(10000); 
  
 
  Err :=  mpg123_open_handle(StreamIn[x].Data.HandleSt, Pointer(StreamIn[x].InPipe));
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = 0 then writeln('===> mpg123_open_handle => ok.') else
  writeln('===> mpg123_open_handle => NOT ok.') ;
  {$endif}
 
  sleep(10);
  end;
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = 0 then
  writeln('===> mpg123_open_handle all => ok.') else
  writeln('===> mpg123_open_handle all => NOT ok.');
  {$endif}
  
  if err = 0 then
  begin
  StreamIn[x].Data.filename := URL ;
  
  if FramesCount = -1 then  StreamIn[x].Data.Wantframes :=  1024  else
  StreamIn[x].Data.Wantframes := FramesCount ;
  
// StreamIn[x].Data.Wantframes := totsamples;

  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.Position := 0;
  StreamIn[x].Data.OutFrames := 0;
  StreamIn[x].Data.Poseek := -1;
  StreamIn[x].Data.TypePut := 2;
  StreamIn[x].Data.seekable := false;
  StreamIn[x].LoopProc := nil;

  Err := mpg123_getformat(StreamIn[x].Data.HandleSt,
  StreamIn[x].Data.samplerate, StreamIn[x].Data.channels,
  StreamIn[x].Data.encoding);
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  if err = 0 then
  writeln('===> mpg123_getformat => ok.') else
  writeln('===> mpg123_getformat => NOT ok.');
  {$endif}
  
  if err <> 0 then
  begin
  sleep(50);
  Err := mpg123_getformat(StreamIn[x].Data.HandleSt,
  StreamIn[x].Data.samplerate, StreamIn[x].Data.channels,
  StreamIn[x].Data.encoding);
  
  end;  
  if err = 0 then
  begin
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('===> mpg123_getformat => ok');
  {$endif}
  
  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);

  StreamIn[x].Data.LibOpen := 1;
  
  if SampleFormat = -1 then
  StreamIn[x].Data.SampleFormat := 2
  else
  StreamIn[x].Data.SampleFormat := SampleFormat;

  if StreamIn[x].Data.SampleFormat = 2 then
  StreamIn[x].Data.ratio := sizeof(int16)
  else
  StreamIn[x].Data.ratio := sizeof(int32);

  mpg123_info(StreamIn[x].Data.HandleSt, MPinfo);
  
// problems with mpg123 
// mpg123_id3(StreamIn[x].Data.HandleSt, mpid3v1, @mpid3v2);
// mpg123_icy(StreamIn[x].Data.HandleSt, pointer(icytext));
   
  StreamIn[x].Data.samplerateroot :=  StreamIn[x].Data.samplerate ;
  StreamIn[x].Data.hdformat := MPinfo.layer;
  StreamIn[x].Data.frames := MPinfo.framesize;
  StreamIn[x].Data.Length := mpg123_length(StreamIn[x].Data.HandleSt);
  
  if StreamIn[x].Data.SampleFormat = 0 then
  mpg123_param(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Channels,
  MPG123_FORCE_FLOAT, 0);
  
  StreamIn[x].Data.Enabled := True;
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('===> mpg123_infos end => ok');
  {$endif}  
  
  end;
  end;
  end;
  {$endif}
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('Before result ' + inttostr(result));
  WriteLn('error ' + inttostr(err));
  WriteLn('StreamIn[x].Data.LibOpen ' + inttostr(StreamIn[x].Data.LibOpen));
  WriteLn('Before Length(StreamIn) ' + inttostr(Length(StreamIn)));
  {$endif}
  sleep(10);  
  if StreamIn[x].Data.LibOpen = -1 then
  begin
  if err <> -133 then 
  begin
  StreamIn[Length(StreamIn) - 1].Destroy;
  setlength(StreamIn, Length(StreamIn) - 1);
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('After Length(StreamIn) ' + inttostr(Length(StreamIn)));  
  WriteLn('Result: ' + inttostr(result));
  {$endif}
  end;
  
  result := -1
  end else
  begin
  StreamIn[x].Data.Enabled := True;
   result := x ;
  end; 
  end;
  {$ENDIF}

function Tuos_Player.AddFromMemoryBuffer(var MemoryBuffer: TDArFloat; var Bufferinfos: Tuos_bufferinfos;
 OutputIndex: cint32; FramesCount: cint32): cint32;
// Add a input from memory buffer with custom parameters
// MemoryBuffer : the buffer
// Bufferinfos : infos of the buffer
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)// SampleRate : delault : -1 (44100)
// FramesCount : default : -1 (65536 div Channels)
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := AddFromMemoryBuffer(mybuffer, buffinfos,-1,1024);
 
var
  x : cint32; 
  {$IF DEFINED(debug) and DEFINED(unix)}
  st: string;
  i : cint32; 
  {$endif} 
  begin
  
 result := -1 ;

 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('AddFromMemoryBuffer Before all.');  
  writeln('length(MemoryBuffer) =' +inttostr(length(MemoryBuffer)));
  st := '';
  for i := 0 to length(MemoryBuffer) -1 do
  st := st + '|' + inttostr(i) + '=' + floattostr(MemoryBuffer[i]);  
  WriteLn(st);
 {$endif} 
 
//  writeln('length(MemoryBuffer) =' +inttostr(length(MemoryBuffer)));
  
  SetLength(StreamIn, Length(StreamIn) + 1);
  StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create;
  x := Length(StreamIn) - 1;
  
  StreamIn[x].Data.Enabled := false;
  StreamIn[x].Data.levelEnable := 0;
  StreamIn[x].Data.typeput := 4;
  StreamIn[x].Data.positionEnable := 0;
  StreamIn[x].Data.levelArrayEnable := 0;
  
   {  
  setlength(StreamIn[x].Data.memorybuffer, length(MemoryBuffer));
  
   writeln('length(Data.memorybuffer) =' +inttostr(length(StreamIn[x].Data.memorybuffer)));
   
  for i := 0 to length(MemoryBuffer) -1 do
  StreamIn[x].Data.memorybuffer[i] := MemoryBuffer[i];
 }
  
   StreamIn[x].Data.memorybuffer := MemoryBuffer;
  
  sleep(50);//TODO: it is necessary?
   
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('AddFromMemoryBuffer Before all.');  
  writeln('length(MemoryBuffer) =' +inttostr(length(MemoryBuffer)));
  st := '';
  for i := 0 to length(MemoryBuffer) -1 do
  st := st + '|' + inttostr(i) + '=' + floattostr(StreamIn[x].Data.memorybuffer[i]);  
  WriteLn(st);
 {$endif} 
  
  StreamIn[x].Data.Length := length(MemoryBuffer);
  StreamIn[x].Data.LibOpen := 0;
 
  StreamIn[x].Data.Channels := Bufferinfos.Channels;
   
 if FramesCount = -1 then
  StreamIn[x].Data.Wantframes :=  4096
  else
  StreamIn[x].Data.Wantframes := FramesCount;

  StreamIn[x].Data.Samplerate := bufferinfos.SampleRate; 
  StreamIn[x].Data.SampleRateRoot := Bufferinfos.Samplerate;
  StreamIn[x].Data.SampleFormat := Bufferinfos.SampleFormat;
  StreamIn[x].Data.Filename := BufferInfos.Filename;
  StreamIn[x].Data.Title := BufferInfos.Title;
  StreamIn[x].Data.Copyright := BufferInfos.Copyright;
  StreamIn[x].Data.Software := BufferInfos.Software;
  StreamIn[x].Data.Artist := BufferInfos.Artist;
  StreamIn[x].Data.Comment := BufferInfos.Comment;
  StreamIn[x].Data.Date := BufferInfos.Date;
  StreamIn[x].Data.Tag := BufferInfos.Tag;
  StreamIn[x].Data.Album := BufferInfos.Album;
  StreamIn[x].Data.Genre := BufferInfos.Genre;
  StreamIn[x].Data.HDFormat := BufferInfos.HDFormat;
  StreamIn[x].Data.Sections := BufferInfos.Sections;
  StreamIn[x].Data.Encoding := BufferInfos.Encoding;
  StreamIn[x].Data.bitrate := BufferInfos.bitrate;
//StreamIn[x].Data.Length := BufferInfos.Length;
  StreamIn[x].Data.LibOpen := 0;
  StreamIn[x].Data.ratio := StreamIn[x].Data.Channels;  
  
  StreamIn[x].Data.posmem := 0;
  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.Position := 0;
  StreamIn[x].Data.OutFrames := 0;
  StreamIn[x].Data.Poseek := -1;
  StreamIn[x].Data.seekable := true;
  StreamIn[x].LoopProc := nil;
  setlength(StreamIn[x].Data.buffer,StreamIn[x].Data.wantframes*StreamIn[x].Data.Channels);
  StreamIn[x].Data.Enabled := True;
  result := x; 
  end; 
  
function Tuos_Player.AddFromFileIntoMemory(Filename: Pchar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32; numbuf : cint): cint32;
// Add a input from audio file and store it into memory with custom parameters
// FileName : filename of audio file
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := AddFromFileIntoMemory(edit5.Text,-1,0,-1);
  var
  x,i : cint32; 
  bufferinfos: Tuos_bufferinfos;
 
  {$IF DEFINED(debug) and DEFINED(unix)}
   st: string;
  {$endif}
 
  begin
  result := -1 ;
 
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('AddFromFileIntoMemory Before all.');  
 {$endif}
 
  if fileexists(filename) then
  begin
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('Before setlength.');  
 {$endif}  
 
  SetLength(StreamIn, Length(StreamIn) + 1);
  StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create;
  x := Length(StreamIn) - 1;
  StreamIn[x].Data.Enabled := false;
  StreamIn[x].Data.levelEnable := 0;
  StreamIn[x].Data.typeput := 4;
  StreamIn[x].Data.positionEnable := 0;
  StreamIn[x].Data.levelArrayEnable := 0;
// StreamIn[x].Data.wantframes := FramesCount;
 
  {$IF DEFINED(debug) and DEFINED(unix)} 
  writeln('Before Filetobuffer');
  {$endif}
  
  for i := 0 to length(tempoutmemory) -1 do
  tempoutmemory[i] := 0.0;
  
  setlength(tempoutmemory, 0);
  
  Filetobuffer(Filename, -1, SampleFormat, FramesCount, tempoutmemory, bufferinfos, -1, numbuf);
  sleep(50);

  setlength(StreamIn[x].Data.memorybuffer, length(tempoutmemory));
  for i := 0 to length(tempoutmemory) -1 do
  StreamIn[x].Data.memorybuffer[i] := tempoutmemory [i];

  {$IF DEFINED(debug) and DEFINED(unix)} 
  writeln('After Filetobuffer');
  writeln('length(tempoutmemory) =' +inttostr(length(tempoutmemory)));
  st := '';
  for i := 0 to length(tempoutmemory) -1 do
  st := st + '|' + inttostr(i) + '=' + floattostr(tempoutmemory[i]);  
  WriteLn('OUTPUT DATA into portaudio------------------------------');
  WriteLn(st);
  {$endif}
  
  StreamIn[x].Data.Length := tempLength;
  StreamIn[x].Data.Samplerate := tempSamplerate;
  StreamIn[x].Data.SampleFormat := tempSampleFormat;
  StreamIn[x].Data.LibOpen := tempLibOpen;
  StreamIn[x].Data.Channels := tempchan;
  
  if FramesCount = -1 then  StreamIn[x].Data.Wantframes := 65536 div  StreamIn[x].Data.Channels  else
  StreamIn[x].Data.Wantframes := FramesCount ; 
  
  StreamIn[x].Data.ratio := tempratio;
  StreamIn[x].Data.posmem := 0;
  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.Position := 0;
  StreamIn[x].Data.OutFrames := 0;
  StreamIn[x].Data.Poseek := -1;
  StreamIn[x].Data.seekable := true;
  StreamIn[x].LoopProc := nil;
  StreamIn[x].Data.Samplerate := bufferinfos.SampleRate;
  StreamIn[x].Data.SampleRateRoot := Bufferinfos.Samplerate;
  StreamIn[x].Data.SampleFormat := Bufferinfos.SampleFormat;
  StreamIn[x].Data.Filename := BufferInfos.Filename;
  StreamIn[x].Data.Title := BufferInfos.Title;
  StreamIn[x].Data.Copyright := BufferInfos.Copyright;
  StreamIn[x].Data.Software := BufferInfos.Software;
  StreamIn[x].Data.Artist := BufferInfos.Artist;
  StreamIn[x].Data.Comment := BufferInfos.Comment;
  StreamIn[x].Data.Date := BufferInfos.Date;
  StreamIn[x].Data.Tag := BufferInfos.Tag;
  StreamIn[x].Data.Album := BufferInfos.Album;
  StreamIn[x].Data.Genre := BufferInfos.Genre;
  StreamIn[x].Data.HDFormat := BufferInfos.HDFormat;
  StreamIn[x].Data.Sections := BufferInfos.Sections;
  StreamIn[x].Data.Encoding := BufferInfos.Encoding;
  StreamIn[x].Data.bitrate := BufferInfos.bitrate;
  StreamIn[x].Data.Length := BufferInfos.Length;
  StreamIn[x].Data.LibOpen := 0;
  StreamIn[x].Data.Ratio := 2 ; 
  
  setlength(StreamIn[x].Data.buffer,StreamIn[x].Data.wantframes*StreamIn[x].Data.Channels);
  StreamIn[x].Data.Enabled := True;
  result := x; 
  end else  result := -2;  
   
  end; 

{$IF DEFINED(portaudio) or DEFINED(sndfile)}  
  function m_get_filelen(pms: PMemoryStream): tuos_count_t; cdecl; 
begin
 Result:= pms^.Size;
end;
 
function m_seek(offset: tuos_count_t; whence: cint32; pms: PMemoryStream): tuos_count_t; cdecl; 
Const
 SEEK_SET = 0;
 SEEK_CUR = 1;
 SEEK_END = 2;
begin
Result:= 0 ;
 case whence of
  SEEK_SET: Result:= pms^.Seek(offset, soFromBeginning);
  SEEK_CUR: Result:= pms^.Seek(offset, soFromCurrent);
  SEEK_END: Result:= pms^.Seek(offset, soFromEnd);
 end;

end;
 
function m_read(const buf: Pointer; count: Tuos_count_t; pms: PMemoryStream): Tuos_count_t; cdecl; 

begin
Result := pms^.Read(buf^,count);
end;
 
function m_write(const buf: Pointer; count: Tuos_count_t; pms: PMemoryStream): Tuos_count_t; cdecl; 
begin
 Result:= pms^.Write(buf^,count);
end;
 
function m_tell(pms: PMemoryStream): Tuos_count_t; cdecl; 
begin
 Result:= pms^.Position;
end;
{$endif}

function Tuos_Player.AddFromMemoryStreamDec(var MemoryStream: TMemoryStream; var Bufferinfos: Tuos_bufferinfos;
 OutputIndex: cint32; FramesCount: cint32): cint32;
// MemoryStream : Memory-stream of decoded audio (like created by AddIntoMemoryStream)
// Bufferinfos : infos of the Memory-stream
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// FramesCount : default : -1 (4096)
//  result :  Input Index in array  -1 = error
var
x : integer;
begin
 result := -1 ;

   {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('Before all.');
   {$endif}

   if assigned(MemoryStream) then begin
      x := 0;
      MemoryStream.Position:= 0;

      {$IF DEFINED(debug) and DEFINED(unix)}
      WriteLn('Before setlength.');
      {$endif}

      SetLength(StreamIn, Length(StreamIn) + 1);
      StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create;
      x := Length(StreamIn) - 1;
     
      StreamIn[x].Data.LibOpen := -1;
      StreamIn[x].Data.levelEnable := 0;
      StreamIn[x].Data.Output := OutputIndex;
         StreamIn[x].Data.Status := 1;
         StreamIn[x].Data.Position := 0;
         StreamIn[x].Data.OutFrames := 0;
         StreamIn[x].Data.Poseek := -1;
         StreamIn[x].Data.TypePut := 6;
         StreamIn[x].Data.seekable := True;
         StreamIn[x].LoopProc := nil;
       
  StreamIn[x].Data.Channels := Bufferinfos.Channels;
   
 if FramesCount = -1 then
  StreamIn[x].Data.Wantframes :=  4096
  else
  StreamIn[x].Data.Wantframes := FramesCount;

  StreamIn[x].Data.Samplerate := bufferinfos.SampleRate; 
  StreamIn[x].Data.SampleRateRoot := Bufferinfos.Samplerate;
  StreamIn[x].Data.SampleFormat := Bufferinfos.SampleFormat;
  StreamIn[x].Data.Filename := BufferInfos.Filename;
  StreamIn[x].Data.Title := BufferInfos.Title;
  StreamIn[x].Data.Copyright := BufferInfos.Copyright;
  StreamIn[x].Data.Software := BufferInfos.Software;
  StreamIn[x].Data.Artist := BufferInfos.Artist;
  StreamIn[x].Data.Comment := BufferInfos.Comment;
  StreamIn[x].Data.Date := BufferInfos.Date;
  StreamIn[x].Data.Tag := BufferInfos.Tag;
  StreamIn[x].Data.Album := BufferInfos.Album;
  StreamIn[x].Data.Genre := BufferInfos.Genre;
  StreamIn[x].Data.HDFormat := BufferInfos.HDFormat;
  StreamIn[x].Data.Sections := BufferInfos.Sections;
  StreamIn[x].Data.Encoding := BufferInfos.Encoding;
  StreamIn[x].Data.bitrate := BufferInfos.bitrate;
//StreamIn[x].Data.Length := BufferInfos.Length;
  StreamIn[x].Data.LibOpen := -1;
  StreamIn[x].Data.ratio := StreamIn[x].Data.Channels;  
  
  StreamIn[x].Data.posmem := 0;
  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.Position := 0;
  StreamIn[x].Data.OutFrames := 0;
  StreamIn[x].Data.Poseek := -1;
  StreamIn[x].Data.seekable := false;
  StreamIn[x].LoopProc := nil;
  streamIn[x].Data.ratio := StreamIn[x].Data.Channels;
  StreamIn[x].Data.positionEnable := 0;
  StreamIn[x].Data.levelArrayEnable := 0;
  StreamIn[x].MemoryStreamDec := MemoryStream;
  
    
  StreamIn[x].MemoryStreamDec.Position:= 0;
  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);

  StreamIn[x].Data.Enabled := true;
       result := x; 
      {$IF DEFINED(debug) and DEFINED(unix)}
      writeln('length(StreamIn[x].MemoryStreamDec) = '+inttostr(StreamIn[x].MemoryStreamDec.size)) ;
      writeln('length(MemoryStream) = '+inttostr(MemoryStream.size)) ;
      WriteLn('Length(StreamIn) = '+ inttostr(x));
      {$endif}
end else result := -1;

end;
  
function Tuos_Player.AddFromMemoryStream(var MemoryStream: TMemoryStream; 
         TypeAudio: cint32; OutputIndex: cint32; SampleFormat: cint32 ; FramesCount: cint32): cint32;
// MemoryStream : Memory stream of encoded audio file.
// TypeAudio : default : -1 --> 0 (0: flac, ogg, wav; 1: mp3; 2:opus ; 3:decoded Tmemory-stream)
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
//  result :  Input Index in array  -1 = error
// example : InputIndex1 := AddFromMemoryStream(mymemorystream,-1,-1,0,1024);

  var x, err, len, len2, i : cint32;
      PipeBufferSize, totsamples : integer;
      buffadd : tbytes;

      {$IF DEFINED(sndfile)}
      sfInfo: TSF_INFO;
      sfVirtual: TSF_VIRTUAL;
      {$endif}
  
      {$IF DEFINED(opus)}
      s: UTF8String;
      j: Integer;
      OpusTag: POpusTags;
      LComment: PPAnsiChar;
      LcommentLength: PInteger;
      {$endif}
  
      {$IF DEFINED(mpg123)}
      mpinfo: Tmpg123_frameinfo;
  // problems with mpg123
  // mpid3v1: PPmpg123_id3v1;
  // refmpid3v1: Tmpg123_id3v1;
  // mpid3v2: Tmpg123_id3v2;
      {$endif}

begin
   result := -1 ;

   {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('Before all.');
   {$endif}

   if assigned(MemoryStream) then begin
      x := 0;
      MemoryStream.Position:= 0;

      {$IF DEFINED(debug) and DEFINED(unix)}
      WriteLn('Before setlength.');
      {$endif}

      SetLength(StreamIn, Length(StreamIn) + 1);
      StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create;
      x := Length(StreamIn) - 1;
      err := -1;
      StreamIn[x].Data.Enabled := false;
      StreamIn[x].Data.LibOpen := -1;
      StreamIn[x].Data.levelEnable := 0;
      StreamIn[x].Data.positionEnable := 0;
      StreamIn[x].Data.levelArrayEnable := 0;
      StreamIn[x].data.MemoryStream := MemoryStream;
      StreamIn[x].data.MemoryStream.Position:= 0;

      {$IF DEFINED(debug) and DEFINED(unix)}
      WriteLn('Length(StreamIn) = '+ inttostr(x));
      {$endif}

      {$IF DEFINED(sndfile)}
      if ((TypeAudio = -1) or (TypeAudio = 0)) and (uosLoadResult.SFloadERROR = 0) then begin
         with sfVirtual do begin
            sf_vio_get_filelen  := @m_get_filelen;
            seek  := @m_seek;
            read  := @m_read;
            write := @m_write;
            tell  := @m_tell;
         end;

         try
            Streamin [x] .Data.HandleSt := sf_open_virtual(@sfVirtual, SFM_READ, @sfInfo, @StreamIn[x].Data.MemoryStream);
         except
            StreamIn[x].Data.HandleSt := nil;
         end;
         (* try to open the file *)
         if StreamIn[x].Data.HandleSt = nil then begin
            StreamIn[x].Data.LibOpen := -1;
            {$IF DEFINED(debug) and DEFINED(unix)}
            WriteLn('sf_open_virtual NOT OK');
            {$endif}
         end else begin
            {$IF DEFINED(debug) and DEFINED(unix)}
            WriteLn('sf_open_virtual OK');
            {$endif}
            StreamIn[x].Data.LibOpen := 0;
            StreamIn[x].Data.channels := SFinfo.channels;
            if FramesCount = -1 then
               StreamIn[x].Data.Wantframes := 65536 div StreamIn[x].Data.Channels
            else StreamIn[x].Data.Wantframes := FramesCount ;

            SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);

            StreamIn[x].Data.hdformat := SFinfo.format;
            StreamIn[x].Data.frames := SFinfo.frames;
            StreamIn[x].Data.samplerate := SFinfo.samplerate;
            StreamIn[x].Data.samplerateroot := SFinfo.samplerate;
            StreamIn[x].Data.sections := SFinfo.sections;
            StreamIn[x].Data.copyright := sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_COPYRIGHT);
            StreamIn[x].Data.software := sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_SOFTWARE);
            StreamIn[x].Data.comment := sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_COMMENT);
            StreamIn[x].Data.artist := sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_ARTIST);
            StreamIn[x].Data.title := sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_TITLE);
            StreamIn[x].Data.date := sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_DATE);
            StreamIn[x].Data.Length := sfInfo.frames;
            err := 0;
            {$IF DEFINED(debug) and DEFINED(unix)}
            WriteLn('sf_open END OK');
            {$endif}
         end;
      end;
      {$endif}

      {$IF DEFINED(mpg123)}
  // mpg123
      if ((StreamIn[x].Data.LibOpen = -1)) then if (((TypeAudio=-1) and (err=-1) ) or ((TypeAudio = 1) and (StreamIn[x].Data.LibOpen = -1) and (uosLoadResult.MPloadERROR = 0))) then begin
         Err := -1;
         StreamIn[x].Data.HandleSt := mpg123_new(nil, Err);

         if Err = 0 then begin
            {$IF DEFINED(debug) and DEFINED(unix)}
            WriteLn('mpg123_new OK');
            {$endif}

            if SampleFormat = -1 then
               StreamIn[x].Data.SampleFormat := 2
            else StreamIn[x].Data.SampleFormat := SampleFormat;
            mpg123_format_none(StreamIn[x].Data.HandleSt);

            case StreamIn[x].Data.SampleFormat of
               0: mpg123_format(StreamIn[x].Data.HandleSt, DefRate, Stereo, MPG123_ENC_FLOAT_32);
               1: mpg123_format(StreamIn[x].Data.HandleSt, DefRate, Stereo, MPG123_ENC_SIGNED_32);
               2: mpg123_format(StreamIn[x].Data.HandleSt, DefRate, Stereo, MPG123_ENC_SIGNED_16);
            end;

            err := mpg123_replace_reader_handle(StreamIn[x].Data.HandleSt, @mpg_read_stream, @mpg_seek_stream, nil);

            {$IF DEFINED(debug) and DEFINED(unix)}
            if err = 0 then
               writeln('===> mpg123_replace_reader_handle => ok.')
            else writeln('===> mpg123_replace_reader_handle => NOT OK.');
            {$endif}

            Err :=  mpg123_open_handle(StreamIn[x].Data.HandleSt, pointer(StreamIn[x].Data.MemoryStream));

            {$IF DEFINED(debug) and DEFINED(unix)}
            if err = 0 then
               writeln('===> mpg123_open_handle => ok.') else
            writeln('===> mpg123_open_handle => NOT ok.') ;
            {$endif}

            sleep(10);
         end else begin
            StreamIn[x].Data.LibOpen := -1;
         end;

         if Err = 0 then Err := mpg123_getformat(StreamIn[x].Data.HandleSt,
         StreamIn[x].Data.samplerate, StreamIn[x].Data.channels,
         StreamIn[x].Data.encoding);

         {$IF DEFINED(debug) and DEFINED(unix)}
         if err = 0 then
            writeln('===> mpg123_getformat => ok.')
         else writeln('===> mpg123_getformat => NOT ok.') ;
         {$endif}

         if Err = 0 then begin
            mpg123_close(StreamIn[x].Data.HandleSt);
            mpg123_delete(StreamIn[x].Data.HandleSt);
        // Close handle and reload with forced resolution
            StreamIn[x].Data.HandleSt := mpg123_new(nil, Err);

            {$IF DEFINED(debug) and DEFINED(unix)}
            if err = 0 then
               writeln('===> mpg123_open_handle => ok.')
            else writeln('===> mpg123_open_handle => NOT ok.') ;
            {$endif}
            StreamIn[x].Data.HandleSt := nil;
            StreamIn[x].Data.HandleSt := mpg123_new(nil, Err);

            mpg123_format_none(StreamIn[x].Data.HandleSt);
            case StreamIn[x].Data.SampleFormat of
               0: mpg123_format(StreamIn[x].Data.HandleSt, StreamIn[x].Data.samplerate, StreamIn[x].Data.channels, StreamIn[x].Data.encoding);
               1: mpg123_format(StreamIn[x].Data.HandleSt, StreamIn[x].Data.samplerate, StreamIn[x].Data.channels, StreamIn[x].Data.encoding);
               2: mpg123_format(StreamIn[x].Data.HandleSt, StreamIn[x].Data.samplerate, StreamIn[x].Data.channels, StreamIn[x].Data.encoding);
            end;

            err := mpg123_replace_reader_handle(StreamIn[x].Data.HandleSt, @mpg_read_stream, @mpg_seek_stream, nil);

            {$IF DEFINED(debug) and DEFINED(unix)}
            if err = 0 then
               writeln('===> mpg123_replace_reader_handle => ok.')
            else writeln('===> mpg123_replace_reader_handle => NOT OK.');
            {$endif}

            Err :=  mpg123_open_handle(StreamIn[x].Data.HandleSt, pointer(StreamIn[x].Data.MemoryStream));

            mpg123_getformat(StreamIn[x].Data.HandleSt, StreamIn[x].Data.samplerate, StreamIn[x].Data.channels, StreamIn[x].Data.encoding);

            if FramesCount = -1 then
               StreamIn[x].Data.Wantframes := 65536 div StreamIn[x].Data.Channels
            else StreamIn[x].Data.Wantframes := FramesCount ;

            SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);
            mpg123_info(StreamIn[x].Data.HandleSt, MPinfo);

            {// problems with mpg123 library
            mpg123_id3(StreamIn[x].Data.HandleSt, mpid3v1, @mpid3v2);
        // to do : add id2v2
            if (mpid3v1 <> nil) and  (mpid3v1^ <> nil)  then begin
               refmpid3v1 := mpid3v1^^;
               StreamIn[x].Data.title := trim(refmpid3v1.title);
               StreamIn[x].Data.artist := refmpid3v1.artist;
               StreamIn[x].Data.album := refmpid3v1.album;
               StreamIn[x].Data.date := refmpid3v1.year;
               StreamIn[x].Data.comment := refmpid3v1.comment;
               StreamIn[x].Data.tag := refmpid3v1.tag;
               StreamIn[x].Data.genre := refmpid3v1.genre;
            end;
            }

            StreamIn[x].Data.samplerateroot :=  StreamIn[x].Data.samplerate ;
            StreamIn[x].Data.hdformat := MPinfo.layer;
            StreamIn[x].Data.frames := MPinfo.framesize;

            if StreamIn[x].Data.SampleFormat = 0 then
               mpg123_param(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Channels, MPG123_FORCE_FLOAT, 0);

            StreamIn[x].Data.LibOpen := 1;
            StreamIn[x].Data.Length := mpg123_length(StreamIn[x].Data.HandleSt);

            {$IF DEFINED(debug) and DEFINED(unix)}
            writeln('StreamIn[x].Data.Length = ' + inttostr(mpg123_length(StreamIn[x].Data.HandleSt)));
            writeln('StreamIn[x].Data.frames = ' + inttostr(StreamIn[x].Data.frames));
            writeln('END StreamIn[x].Data.samplerate = ' + inttostr(StreamIn[x].Data.samplerate));
            writeln('END StreamIn[x].Data.channels = ' + inttostr(StreamIn[x].Data.channels));
            {$endif}
         end else begin
            StreamIn[x].Data.LibOpen := -1;
         end;
      end;
      {$endif}

      {$IF DEFINED(opus)}
      if (((TypeAudio=-1) and (err=-1) ) or (TypeAudio = 2) and (StreamIn[x].Data.LibOpen = -1) and (uosLoadResult.OPloadERROR = 0)) then begin
         Err := -1;

         {$IF DEFINED(debug) and DEFINED(unix)}
         WriteLn('Before Opus');
         {$endif}

         StreamIn[x].Data.HandleSt := pchar('opus');

         if FramesCount= -1 then
            totsamples := 4096
         else totsamples := FramesCount;

     // PipeBufferSize := totsamples * sizeOf(Single);// * 2
         PipeBufferSize := StreamIn[x].Data.MemoryStream.size;

         {$IF DEFINED(debug) and DEFINED(unix)}
         WriteLn('totsamples: ' + inttostr(totsamples));
         WriteLn('PipeBufferSize: ' + inttostr(PipeBufferSize));
         {$endif}

         len := 1 ;
         len2 := 0 ;

         setlength(buffadd, PipeBufferSize);
         setlength(StreamIn[x].data.BufferTMP, PipeBufferSize);

         while (len2 < PipeBufferSize) and (len > 0) do begin
            len := StreamIn[x].Data.MemoryStream.Read(buffadd[0],PipeBufferSize-len2);

            if len > 0 then
               for i := 0 to len -1 do
                  StreamIn[x].data.BufferTMP[i+len2] := buffadd[i] ;
            len2 := len2 + len;
         end;

     // memory stream not needed anymore ---> converted into buffer
         freeandnil(StreamIn[x].Data.MemoryStream);

         {$IF DEFINED(debug) and DEFINED(unix)}
         WriteLn('PipeBufferSize = ' + inttostr(PipeBufferSize));
         WriteLn('Data.MemoryStream.Read = ' + inttostr(len2));
         WriteLn('----------------------------------');
     //writeln(tencoding.utf8.getstring(StreamIn[x].data.BufferTMP));
         {$endif}

         StreamIn[x].Data.HandleSt := pchar('opusstream');

         {$IF DEFINED(debug) and DEFINED(unix)}
         WriteLn('StreamIn[x].Data.HandleSt assisgned');
         {$endif}

     // Can not make work...
     // StreamIn[x].Data.HandleOP := op_test_callbacks(StreamIn[x].data.MemoryStream, uos_callbacksms, StreamIn[x].data.BufferTMP[0], PipeBufferSize, err);

     // this is a memorystream converted into a buffer, it works...
         StreamIn[x].Data.HandleOP := op_test_memory(StreamIn[x].data.BufferTMP[0],PipeBufferSize, Err);

         {$IF DEFINED(debug) and DEFINED(unix)}
         WriteLn('op_test_file error = '+ inttostr(Err));
         {$endif}

         if Err=0 then begin
            Err := op_test_open(StreamIn[x].Data.HandleOP);
            if (Err=0) and (op_link_count(StreamIn[x].Data.HandleOP)=1) then begin
               if SampleFormat = -1 then
                  StreamIn[x].Data.SampleFormat := 2
               else StreamIn[x].Data.SampleFormat := SampleFormat;

           //tag
               OpusTag := op_tags(StreamIn[x].Data.HandleOP, nil);

               if OpusTag<>nil then begin
                  if OpusTag^.comments>0 then begin
                     {$IF DEFINED(debug) and DEFINED(unix)}
                     WriteLn((Format('OpusTag.comments = %d', [OpusTag^.comments])));
                     {$endif}
                     LComment := OpusTag^.user_comments;
                     LcommentLength := OpusTag^.comment_lengths;
                     for j := 0 to OpusTag^.comments - 1 do begin
                        SetLength(s, LcommentLength^);
                        move(Pointer(LComment^)^, Pointer(s)^, LcommentLength^);

                        {$IF DEFINED(debug) and DEFINED(unix)}
                    // WriteLn(s);
                        {$endif}

                        if j = 1 then StreamIn[x].Data.title := s;
                        if j = 2 then StreamIn[x].Data.artist := s;
                        if j = 3 then StreamIn[x].Data.album := s;
                        if j = 4 then StreamIn[x].Data.date := s;
                        if j = 5 then StreamIn[x].Data.comment := s;
                        if j = 6 then StreamIn[x].Data.tag := s;

                        inc(LComment);
                        inc(LcommentLength);
                     end;
                  end;
               end;

           //  WriteLn((Format('op_bitrate = %d', [op_bitrate(StreamIn[x].Data.HandleOP, nil)])));

               StreamIn[x].Data.Length := op_pcm_total(StreamIn[x].Data.HandleOP, nil);
               StreamIn[x].Data.channels := op_channel_count(StreamIn[x].Data.HandleOP, nil);
               StreamIn[x].Data.bitrate := op_bitrate(StreamIn[x].Data.HandleOP, nil);

           // opus use constant sample rate 48k
               StreamIn[x].Data.samplerate :=  48000 ;
               StreamIn[x].Data.samplerateroot :=  StreamIn[x].Data.samplerate ;
               StreamIn[x].Data.Seekable  := true;

               if FramesCount = -1 then
                  StreamIn[x].Data.Wantframes := 4096 * StreamIn[x].Data.Channels
               else StreamIn[x].Data.Wantframes := FramesCount ;

               SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);

               StreamIn[x].Data.LibOpen := 4;
            end else begin
               StreamIn[x].Data.LibOpen := -1;
            end;
         end;
      end;
      {$endif}

      {$IF DEFINED(neaac)}
      if (1 =2) and (StreamIn[x].Data.LibOpen = -1) and (uosLoadResult.AAloadERROR = 0) then begin
         Err:= -1;

         StreamIn[x].AACI:= TAACInfo.Create();

         {$IF DEFINED(debug) and DEFINED(unix)}
         WriteLn('TAACInfo.Create() = ok');
         {$endif}

         {
         Case SampleFormat of
            0 : StreamIn[x].AACI:= MP4OpenFile(FileName, FAAD_FMT_FLOAT);
            1 : StreamIn[x].AACI:= MP4OpenFile(FileName, FAAD_FMT_32BIT);
            2 : StreamIn[x].AACI:= MP4OpenFile(FileName, FAAD_FMT_16BIT);
         End;
         }
         if StreamIn[x].AACI <> nil then Begin
            {$IF DEFINED(debug) and DEFINED(unix)}
            WriteLn('MP4OpenFile() = ok');
            {$endif}

            Case StreamIn[x].AACI.outputFormat of
               FAAD_FMT_16BIT : StreamIn[x].Data.SampleFormat := 2;
           //FAAD_FMT_24BIT : ;
               FAAD_FMT_32BIT : StreamIn[x].Data.SampleFormat := 1;
               FAAD_FMT_FLOAT : StreamIn[x].Data.SampleFormat := 0;
           //FAAD_FMT_DOUBLE: ;
            end;

        // StreamIn[x].Data.filename  := FileName;

            StreamIn[x].Data.HandleSt  := StreamIn[x].AACI.hMP4;

            StreamIn[x].Data.samplerate  := StreamIn[x].AACI.SampleRate;
            StreamIn[x].Data.channels  := StreamIn[x].AACI.Channels;

            Case StreamIn[x].AACI.outputFormat of
               FAAD_FMT_16BIT : StreamIn[x].Data.encoding := MPG123_ENC_SIGNED_16;
           //FAAD_FMT_24BIT : ;
               FAAD_FMT_32BIT : StreamIn[x].Data.encoding := MPG123_ENC_SIGNED_32;
               FAAD_FMT_FLOAT : StreamIn[x].Data.encoding := MPG123_ENC_FLOAT_32;
           //FAAD_FMT_DOUBLE: ;
            end;

            if FramesCount = -1 then
               StreamIn[x].Data.Wantframes :=  65536 div StreamIn[x].Data.Channels
            else StreamIn[x].Data.Wantframes := FramesCount ;

            SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes * StreamIn[x].Data.Channels);

            StreamIn[x].Data.title  := StreamIn[x].AACI.Title;
            StreamIn[x].Data.artist  := StreamIn[x].AACI.Artist;
            StreamIn[x].Data.album  := StreamIn[x].AACI.Album;
            StreamIn[x].Data.date  := StreamIn[x].AACI.Date;
            StreamIn[x].Data.comment  := StreamIn[x].AACI.Comment;
            StreamIn[x].Data.tag[0]  := #0;
            StreamIn[x].Data.tag[1]  := #0;
            StreamIn[x].Data.tag[2]  := #0;
            StreamIn[x].Data.genre  := StrToIntDef(StreamIn[x].AACI.Genre, 0);
            StreamIn[x].Data.samplerateroot := StreamIn[x].AACI.SampleRate;
            StreamIn[x].Data.hdformat  := 0;
            StreamIn[x].Data.frames  := 0;
            StreamIn[x].Data.Length  := StreamIn[x].AACI.TotalSamples;

            StreamIn[x].Data.Seekable  := StreamIn[x].AACI.Size > 0;

            StreamIn[x].Data.LibOpen :=2 ;
            Err:= 0;
         End else begin
            {$IF DEFINED(debug) and DEFINED(unix)}
            WriteLn('MP4OpenFile() NOT ok');
            {$endif}
         end;

      end;
      {$endif}

      {$IF DEFINED(cdrom)}
      if (1 =2) and (StreamIn[x].Data.LibOpen = -1) then begin
         Err:= -1;
         StreamIn[x].pCD := nil;

         Case SampleFormat of
            2 : StreamIn[x].pCD:= CDROM_OpenFile(StreamIn[x].Data.FileName);
         End;

         if StreamIn[x].pCD <> nil then Begin
            Case StreamIn[x].pCD^.BitsPerSample of
               16 : StreamIn[x].Data.SampleFormat := 2;
            end;

            StreamIn[x].Data.HandleSt  := @StreamIn[x].pCD;// Uos requires an assigned pointer....

            StreamIn[x].Data.samplerate  := StreamIn[x].pCD^.SampleRate;
            StreamIn[x].Data.channels  := StreamIn[x].pCD^.Channels;

            Case StreamIn[x].pCD^.BitsPerSample of
               16 : StreamIn[x].Data.encoding := MPG123_ENC_SIGNED_16;
            end;

            if FramesCount = -1 then
               StreamIn[x].Data.Wantframes :=  65536 div StreamIn[x].Data.Channels
            else StreamIn[x].Data.Wantframes := FramesCount;

            SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes * StreamIn[x].Data.Channels);

            StreamIn[x].Data.title  := '';
            StreamIn[x].Data.artist  := '';
            StreamIn[x].Data.album  := '';
            StreamIn[x].Data.date  := '';
            StreamIn[x].Data.comment  := '';
            StreamIn[x].Data.tag[0]  := #0;
            StreamIn[x].Data.tag[1]  := #0;
            StreamIn[x].Data.tag[2]  := #0;
            StreamIn[x].Data.genre  := 0;
            StreamIn[x].Data.samplerateroot := StreamIn[x].pCD^.SampleRate;
            StreamIn[x].Data.hdformat  := 0;
            StreamIn[x].Data.frames  := 0;
            StreamIn[x].Data.Length  := StreamIn[x].pCD^.TotalSamples;

            StreamIn[x].Data.LibOpen := 3;
            Err:= 0;
         End;
      end;
      {$endif}

      if err <> 0 then begin
         result := -1 ;
         StreamIn[Length(StreamIn) - 1].Destroy;
         setlength(StreamIn, Length(StreamIn) - 1);
      end else begin
         {$IF DEFINED(debug) and DEFINED(unix)}
         WriteLn('addfromfile OK');
         {$endif}
         Result := x;
         StreamIn[x].Data.Output := OutputIndex;
         StreamIn[x].Data.Status := 1;
         StreamIn[x].Data.Position := 0;
         StreamIn[x].Data.OutFrames := 0;
         StreamIn[x].Data.Poseek := -1;
         StreamIn[x].Data.TypePut := 0;
         StreamIn[x].Data.seekable := True;
         StreamIn[x].LoopProc := nil;
         if SampleFormat = -1 then
            StreamIn[x].Data.SampleFormat := 2
         else StreamIn[x].Data.SampleFormat := SampleFormat;

         case StreamIn[x].Data.LibOpen of
            {$IF DEFINED(sndfile)}
            0:  StreamIn[x].Data.ratio := StreamIn[x].Data.Channels;
            {$endif}
            {$IF DEFINED(mpg123)}
            1: begin
                  if StreamIn[x].Data.SampleFormat = 2 then
                     StreamIn[x].Data.ratio := streamIn[x].Data.Channels
                  else StreamIn[x].Data.ratio := 2 * streamIn[x].Data.Channels;

                  if StreamIn[x].Data.SampleFormat = 0 then
                     mpg123_param(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Channels, MPG123_FORCE_FLOAT, 0);
            end;
            {$endif}
            {$IF DEFINED(neaac)}
            2 : StreamIn[x].Data.ratio := streamIn[x].AACI.Channels;
            {$endif}
            {$IF DEFINED(cdrom)}
            3 : StreamIn[x].Data.ratio := streamIn[x].pCD^.Channels;
            {$endif}
            {$IF DEFINED(opus)}
            4 : StreamIn[x].Data.ratio :=  streamIn[x].Data.Channels;
            {$endif}
         end;
         StreamIn[x].Data.Enabled := True;
      end;
   end;
end;

function Tuos_Player.AddFromFile(Filename: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32 ): cint32;
// Add a Input from Audio file with Custom parameters
// FileName : filename of audio file
// OutputIndex : OutputIndex of existing Output// -1: all output, -2: no output, other cint32 : existing Output
// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (65536 div channels)
// example : InputIndex := AddFromFile('/usr/home/test.ogg',-1,-1,-1);
var
  x, x2, err: cint32;

  {$IF DEFINED(sndfile)}
  sfInfo: TSF_INFO;
  {$endif}
  
  {$IF DEFINED(opus)}
  s: UTF8String;
  j: Integer;
  OpusTag: POpusTags;
  LComment: PPAnsiChar;
  LcommentLength: PInteger;
  {$endif}
  
  {$IF DEFINED(mpg123)}
  mpinfo: Tmpg123_frameinfo;
  BufferTag: array[1..128] of char; 
  F: file; 
// problems with mpg123  
//  mpid3v2: Tmpg123_id3v2;
  {$endif}

begin
  result := -1 ;
 
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('Before all.');  
 {$endif}
 
  if fileexists(filename) then
  begin
  x := 0;
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('Before setlength.');  
 {$endif}  
  
  SetLength(StreamIn, Length(StreamIn) + 1);
  StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create;
  x := Length(StreamIn) - 1;
  err := -1;
  StreamIn[x].Data.Enabled := false;
  StreamIn[x].Data.LibOpen := -1;
  StreamIn[x].Data.levelEnable := 0;
  StreamIn[x].Data.positionEnable := 0;
  StreamIn[x].Data.levelArrayEnable := 0;

 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('Length(StreamIn) = '+ inttostr(x));  
 {$endif}  
 
  {$IF DEFINED(sndfile)}
  if (uosLoadResult.SFloadERROR = 0) then
  begin

  StreamIn[x].Data.HandleSt := sf_open(FileName, SFM_READ, sfInfo);
  
  (* try to open the file *)
  if StreamIn[x].Data.HandleSt = nil then
  begin
  StreamIn[x].Data.LibOpen := -1;
  err := -1;
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('sf_open NOT OK');  
  {$endif}  
  end
  else
  begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('sf_open OK');  
  {$endif}  
  StreamIn[x].Data.LibOpen := 0;
  StreamIn[x].Data.filename := FileName;
  StreamIn[x].Data.channels := SFinfo.channels;
 
  if FramesCount = -1 then  StreamIn[x].Data.Wantframes := 65536 div StreamIn[x].Data.Channels  else
  StreamIn[x].Data.Wantframes := FramesCount ;

  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);
  x2 := 0 ;
  while x2 < Length(Streamin[x].Data.Buffer) do 
  begin
  Streamin[x].Data.Buffer[x2] := 0.0 ;
  inc(x2);
   end;
   
  StreamIn[x].Data.hdformat := SFinfo.format;
  StreamIn[x].Data.frames := SFinfo.frames;
  StreamIn[x].Data.samplerate := SFinfo.samplerate;
  StreamIn[x].Data.samplerateroot := SFinfo.samplerate;
  StreamIn[x].Data.sections := SFinfo.sections;
    StreamIn[x].Data.title :=
  sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_TITLE);
  StreamIn[x].Data.copyright :=
  sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_COPYRIGHT);
  StreamIn[x].Data.software :=
  sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_SOFTWARE);
  StreamIn[x].Data.comment :=
  sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_COMMENT);
    StreamIn[x].Data.artist :=
  sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_ARTIST);
  StreamIn[x].Data.date := sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_DATE);
  StreamIn[x].Data.Length := sfInfo.frames;
  err := 0;
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('sf_open END OK');  
  {$endif} 
  end;
  end;

  {$endif}

 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('sf StreamIn[x].Data.LibOpen = ' + inttostr(StreamIn[x].Data.LibOpen));  
  WriteLn('sf err = ' + inttostr(err)); 
 {$endif}  
 
  {$IF DEFINED(mpg123)}
   if ((StreamIn[x].Data.LibOpen = -1)) and (uosLoadResult.MPloadERROR = 0) then
  begin
  Err := -1;

  StreamIn[x].Data.HandleSt := mpg123_new(nil, Err);

  if Err = 0 then
  begin
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('mpg123_new OK');  
  {$endif} 
  
  if SampleFormat = -1 then
  StreamIn[x].Data.SampleFormat := 2
  else
  StreamIn[x].Data.SampleFormat := SampleFormat;
  mpg123_format_none(StreamIn[x].Data.HandleSt);
  case StreamIn[x].Data.SampleFormat of
  0: mpg123_format(StreamIn[x].Data.HandleSt, DefRate, Stereo,
  MPG123_ENC_FLOAT_32);
  1: mpg123_format(StreamIn[x].Data.HandleSt, DefRate, Stereo,
  MPG123_ENC_SIGNED_32);
  2: mpg123_format(StreamIn[x].Data.HandleSt, DefRate, Stereo,
  MPG123_ENC_SIGNED_16);
  end;

  Err := mpg123_open(StreamIn[x].Data.HandleSt, PChar(FileName));
  end
  else
  begin
  StreamIn[x].Data.LibOpen := -1;
  end;

  if Err = 0 then
  Err := mpg123_getformat(StreamIn[x].Data.HandleSt,
  StreamIn[x].Data.samplerate, StreamIn[x].Data.channels,
  StreamIn[x].Data.encoding);
  
  if Err = 0 then
  begin
// Close handle and reload with forced resolution
  mpg123_close(StreamIn[x].Data.HandleSt);
  mpg123_delete(StreamIn[x].Data.HandleSt);
  StreamIn[x].Data.HandleSt := mpg123_new(nil, Err);

  mpg123_format_none(StreamIn[x].Data.HandleSt);
  case StreamIn[x].Data.SampleFormat of
  0: mpg123_format(StreamIn[x].Data.HandleSt, StreamIn[x].Data.samplerate,
  StreamIn[x].Data.channels, StreamIn[x].Data.encoding);
  1: mpg123_format(StreamIn[x].Data.HandleSt, StreamIn[x].Data.samplerate,
  StreamIn[x].Data.channels, StreamIn[x].Data.encoding);
  2: mpg123_format(StreamIn[x].Data.HandleSt, StreamIn[x].Data.samplerate,
  StreamIn[x].Data.channels, StreamIn[x].Data.encoding);
  end;
  mpg123_open(StreamIn[x].Data.HandleSt, (PChar(FileName)));
  mpg123_getformat(StreamIn[x].Data.HandleSt,
  StreamIn[x].Data.samplerate, StreamIn[x].Data.channels,
  StreamIn[x].Data.encoding);
  StreamIn[x].Data.filename := filename;

  if FramesCount = -1 then  StreamIn[x].Data.Wantframes :=
  65536 div StreamIn[x].Data.Channels  else
  StreamIn[x].Data.Wantframes := FramesCount ;

  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);

  mpg123_info(StreamIn[x].Data.HandleSt, MPinfo);
  
// custom code for reading ID3Tag ---> problems with  mpg123_id3() 

   AssignFile(F, Filename); 
   
   FileMode:=fmOpenRead + fmShareDenyNone;
   
   Reset(F, 1); 
   Seek(F, FileSize(F) - 128); 
   BlockRead(F, BufferTag, SizeOf(BufferTag)); 
   CloseFile(F); 

  StreamIn[x].Data.title := copy(BufferTag, 4, 30); 
  StreamIn[x].Data.artist := copy(BufferTag, 34, 30); 
  StreamIn[x].Data.album := copy(BufferTag, 64, 30); 
  StreamIn[x].Data.date :=  copy(BufferTag, 94, 4);
  StreamIn[x].Data.comment := copy(BufferTag, 98, 30); 
  StreamIn[x].Data.tag := copy(BufferTag, 1, 3); 
  StreamIn[x].Data.genre := ord(BufferTag[128]);

  StreamIn[x].Data.samplerateroot :=  StreamIn[x].Data.samplerate ;
  StreamIn[x].Data.hdformat := MPinfo.layer;
  StreamIn[x].Data.frames := MPinfo.framesize;
  StreamIn[x].Data.Length := mpg123_length(StreamIn[x].Data.HandleSt);
  StreamIn[x].Data.LibOpen := 1;
  end
  else
  begin
  StreamIn[x].Data.LibOpen := -1;
  end;
  end;

  {$endif}
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('mp StreamIn[x].Data.LibOpen = ' + inttostr(StreamIn[x].Data.LibOpen));  
  WriteLn('mp err = ' + inttostr(err)); 
 {$endif} 
  
  {$IF DEFINED(opus)}
  if (StreamIn[x].Data.LibOpen = -1) and (uosLoadResult.OPloadERROR = 0) then
  begin
  Err := -1;
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('Before Opus');  
 {$endif}  
  
  StreamIn[x].Data.HandleSt := pchar('opus');
  StreamIn[x].Data.HandleOP := op_test_file(PChar(FileName), Err);
 
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('op_test_file error = '+ inttostr(Err));  
 {$endif} 
  
  if Err=0
  then begin
  Err := op_test_open(StreamIn[x].Data.HandleOP);
  if (Err=0) and (op_link_count(StreamIn[x].Data.HandleOP)=1)
  then begin
  
  if SampleFormat = -1 then
  StreamIn[x].Data.SampleFormat := 2
  else
  StreamIn[x].Data.SampleFormat := SampleFormat;  
  
//tag  
  
  OpusTag := op_tags(StreamIn[x].Data.HandleOP, nil);
  
  if OpusTag<>nil
  
  then begin
  
  if OpusTag^.comments>0
  then begin

 {$IF DEFINED(debug) and DEFINED(unix)}
 WriteLn((Format('OpusTag.comments = %d', [OpusTag^.comments])));
 {$endif}  
  LComment := OpusTag^.user_comments;
  LcommentLength := OpusTag^.comment_lengths;
  for j := 0 to OpusTag^.comments - 1 do
  begin
  SetLength(s, LcommentLength^);
  move(Pointer(LComment^)^, Pointer(s)^, LcommentLength^);

 {$IF DEFINED(debug) and DEFINED(unix)}
// WriteLn(s);
 {$endif}  
 
  if j = 1 then StreamIn[x].Data.title := s;
  if j = 2 then StreamIn[x].Data.artist := s;
  if j = 3 then StreamIn[x].Data.album := s;
  if j = 4 then StreamIn[x].Data.date := s;
  if j = 5 then StreamIn[x].Data.comment := s;
  if j = 6 then StreamIn[x].Data.tag := s;
  
  inc(LComment);
  inc(LcommentLength);
  end;
  end;
  end;
  
//  WriteLn((Format('op_bitrate = %d', [op_bitrate(StreamIn[x].Data.HandleOP, nil)])));  
  
  StreamIn[x].Data.Length := op_pcm_total(StreamIn[x].Data.HandleOP, nil);
  StreamIn[x].Data.filename := FileName;
  StreamIn[x].Data.channels := op_channel_count(StreamIn[x].Data.HandleOP, nil);
  
// opus use constant sample rate 48k
  StreamIn[x].Data.samplerate :=  48000 ;
  StreamIn[x].Data.samplerateroot :=  StreamIn[x].Data.samplerate ;
  StreamIn[x].Data.Seekable  := true;
  
  if FramesCount = -1 then  StreamIn[x].Data.Wantframes := 4096 * StreamIn[x].Data.Channels else
  StreamIn[x].Data.Wantframes := FramesCount ;
  
  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);

  StreamIn[x].Data.LibOpen := 4;
  
  end
  else
  begin
  StreamIn[x].Data.LibOpen := -1;
  end;
  end;
  end;
{$endif}

 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('op StreamIn[x].Data.LibOpen = ' + inttostr(StreamIn[x].Data.LibOpen));  
  WriteLn('op err = ' + inttostr(err)); 
 {$endif} 

  {$IF DEFINED(neaac)}
  if (StreamIn[x].Data.LibOpen = -1) and (uosLoadResult.AAloadERROR = 0) then
  begin
  Err:= -1;

  StreamIn[x].AACI:= TAACInfo.Create();
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('TAACInfo.Create() = ok');  
  {$endif} 

  Case SampleFormat of
  0 : StreamIn[x].AACI:= MP4OpenFile(FileName, FAAD_FMT_FLOAT);
  1 : StreamIn[x].AACI:= MP4OpenFile(FileName, FAAD_FMT_32BIT);
  2 : StreamIn[x].AACI:= MP4OpenFile(FileName, FAAD_FMT_16BIT);
  End;
  
  if StreamIn[x].AACI <> nil then
  Begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('MP4OpenFile() = ok');  
  {$endif}  

  Case StreamIn[x].AACI.outputFormat of
  FAAD_FMT_16BIT : StreamIn[x].Data.SampleFormat := 2;
//FAAD_FMT_24BIT : ;
  FAAD_FMT_32BIT : StreamIn[x].Data.SampleFormat := 1;
  FAAD_FMT_FLOAT : StreamIn[x].Data.SampleFormat := 0;
//FAAD_FMT_DOUBLE: ;
  end;
  
  StreamIn[x].Data.filename  := FileName;

  StreamIn[x].Data.HandleSt  := StreamIn[x].AACI.hMP4;

  StreamIn[x].Data.samplerate  := StreamIn[x].AACI.SampleRate;
  StreamIn[x].Data.channels  := StreamIn[x].AACI.Channels;

  Case StreamIn[x].AACI.outputFormat of
  FAAD_FMT_16BIT : StreamIn[x].Data.encoding := MPG123_ENC_SIGNED_16;
//FAAD_FMT_24BIT : ;
  FAAD_FMT_32BIT : StreamIn[x].Data.encoding := MPG123_ENC_SIGNED_32;
  FAAD_FMT_FLOAT : StreamIn[x].Data.encoding := MPG123_ENC_FLOAT_32;
//FAAD_FMT_DOUBLE: ;
  end;

  if FramesCount = -1 then
  StreamIn[x].Data.Wantframes :=  65536 div StreamIn[x].Data.Channels
  else
  StreamIn[x].Data.Wantframes := FramesCount ;

  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes * StreamIn[x].Data.Channels);

  StreamIn[x].Data.title  := StreamIn[x].AACI.Title;
  StreamIn[x].Data.artist  := StreamIn[x].AACI.Artist;
  StreamIn[x].Data.album  := StreamIn[x].AACI.Album;
  StreamIn[x].Data.date  := StreamIn[x].AACI.Date;
  StreamIn[x].Data.comment  := StreamIn[x].AACI.Comment;
  StreamIn[x].Data.tag[0]  := #0;
  StreamIn[x].Data.tag[1]  := #0;
  StreamIn[x].Data.tag[2]  := #0;
  StreamIn[x].Data.genre  := StrToIntDef(StreamIn[x].AACI.Genre, 0);
  StreamIn[x].Data.samplerateroot := StreamIn[x].AACI.SampleRate;
  StreamIn[x].Data.hdformat  := 0;
  StreamIn[x].Data.frames  := 0;
  StreamIn[x].Data.Length  := StreamIn[x].AACI.TotalSamples;

  StreamIn[x].Data.Seekable  := StreamIn[x].AACI.Size > 0;

  StreamIn[x].Data.LibOpen :=2 ;
  Err:= 0;
  End else
  begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('MP4OpenFile() NOT ok');  
  {$endif} 
  end;  

  end;
  {$endif}
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('ac StreamIn[x].Data.LibOpen = ' + inttostr(StreamIn[x].Data.LibOpen));  
  WriteLn('ac err = ' + inttostr(err)); 
 {$endif} 
  
  {$IF DEFINED(cdrom)}
  if (StreamIn[x].Data.LibOpen = -1) then
  begin
  Err:= -1;
  StreamIn[x].pCD := nil;

  Case SampleFormat of
  2 : StreamIn[x].pCD:= CDROM_OpenFile(FileName);
  End;

  if StreamIn[x].pCD <> nil then
  Begin
  Case StreamIn[x].pCD^.BitsPerSample of
  16 : StreamIn[x].Data.SampleFormat := 2;
  end;

  StreamIn[x].Data.filename  := FileName;

  StreamIn[x].Data.HandleSt  := @StreamIn[x].pCD;// Uos requires an assigned pointer....

  StreamIn[x].Data.samplerate  := StreamIn[x].pCD^.SampleRate;
  StreamIn[x].Data.channels  := StreamIn[x].pCD^.Channels;

  Case StreamIn[x].pCD^.BitsPerSample of
  16 : StreamIn[x].Data.encoding := MPG123_ENC_SIGNED_16;
  end;

  if FramesCount = -1 then
  StreamIn[x].Data.Wantframes :=  65536 div StreamIn[x].Data.Channels
  else
  StreamIn[x].Data.Wantframes := FramesCount;

  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes * StreamIn[x].Data.Channels);

  StreamIn[x].Data.title  := '';
  StreamIn[x].Data.artist  := '';
  StreamIn[x].Data.album  := '';
  StreamIn[x].Data.date  := '';
  StreamIn[x].Data.comment  := '';
  StreamIn[x].Data.tag[0]  := #0;
  StreamIn[x].Data.tag[1]  := #0;
  StreamIn[x].Data.tag[2]  := #0;
  StreamIn[x].Data.genre  := 0;
  StreamIn[x].Data.samplerateroot := StreamIn[x].pCD^.SampleRate;
  StreamIn[x].Data.hdformat  := 0;
  StreamIn[x].Data.frames  := 0;
  StreamIn[x].Data.Length  := StreamIn[x].pCD^.TotalSamples;

  StreamIn[x].Data.LibOpen := 3;
  Err:= 0;
  End;
  end;
  {$endif}
  
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('cd StreamIn[x].Data.LibOpen = ' + inttostr(StreamIn[x].Data.LibOpen));  
  WriteLn('cd err = ' + inttostr(err)); 
 {$endif} 
   
   if (err <> 0) or (StreamIn[x].Data.LibOpen = -1) then
  begin
   {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('not ok StreamIn[x].Data.LibOpen = -1');  
  WriteLn('not ok cd err = ' + inttostr(err)); 
   {$endif} 
  
  result := -1 ;
  StreamIn[Length(StreamIn) - 1].Destroy;
  setlength(StreamIn, Length(StreamIn) - 1);
  end
  else
  begin
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('addfromfile OK');  
  {$endif} 
  Result := x;
  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.Position := 0;
  StreamIn[x].Data.OutFrames := 0;
  StreamIn[x].Data.Poseek := -1;
  StreamIn[x].Data.TypePut := 0;
  StreamIn[x].Data.seekable := True;
  StreamIn[x].LoopProc := nil;
  if SampleFormat = -1 then
  StreamIn[x].Data.SampleFormat := 2
  else
  StreamIn[x].Data.SampleFormat := SampleFormat;

  case StreamIn[x].Data.LibOpen of

  0:  StreamIn[x].Data.ratio := StreamIn[x].Data.Channels;

  {$IF DEFINED(mpg123)}
  1: begin
  if StreamIn[x].Data.SampleFormat = 2 then
  StreamIn[x].Data.ratio := streamIn[x].Data.Channels
  else
  StreamIn[x].Data.ratio := 2 * streamIn[x].Data.Channels;

  if StreamIn[x].Data.SampleFormat = 0 then
  mpg123_param(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Channels,
  MPG123_FORCE_FLOAT, 0);
  end;
  {$endif}
  {$IF DEFINED(neaac)}
  2 : StreamIn[x].Data.ratio := streamIn[x].AACI.Channels;
  {$endif}
  {$IF DEFINED(cdrom)}
  3 : StreamIn[x].Data.ratio := streamIn[x].pCD^.Channels;
  {$endif}
  {$IF DEFINED(opus)}
  4 : StreamIn[x].Data.ratio :=  streamIn[x].Data.Channels;
  {$endif}
  end;
  StreamIn[x].Data.Enabled := True;
  end;
  end else result := -2;
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('result = ' + inttostr(result));  
  WriteLn('cd err = ' + inttostr(err)); 
  {$endif} 
end;

procedure Tuos_Player.ReadEndless(x : integer);
  begin
{ 
 Nothing to do: all is done with AddFromEndlessMuted.
  }
  
  end;
 
{$IF DEFINED(synthesizer)}
procedure Tuos_Player.ReadSynth(x :integer);  
var
x2 : integer;
sf1, sf2 : cfloat;
ps: PDArShort;// if input is Int16 format
pl: PDArLong;// if input is Int32 format
pf: PDArFloat;// if input is Float32 format

  begin
  
  if StreamIn[x].Data.SampleFormat =  2 then ps := @StreamIn[x].Data.Buffer else
  if StreamIn[x].Data.SampleFormat =  1 then pl := @StreamIn[x].Data.Buffer else
  if StreamIn[x].Data.SampleFormat =  0 then pf := @StreamIn[x].Data.Buffer;

  x2 := 0 ;

   StreamIn[x].Data.posdursine := StreamIn[x].Data.posdursine + (StreamIn[x].Data.WantFrames div StreamIn[x].Data.Channels);

    if (StreamIn[x].Data.posdursine <= StreamIn[x].Data.dursine) or (StreamIn[x].Data.dursine = 0) then
  
  begin

  while x2 < (StreamIn[x].Data.WantFrames * StreamIn[x].Data.Channels) - (StreamIn[x].Data.Channels -1)  do

  begin

  if StreamIn[x].Data.Channels = 2 then
  begin
  sf1 := StreamIn[x].Data.VLeft * CFloat((Sin( ( CFloat((x2 div 2)+ StreamIn[x].Data.posLsine)/CFloat( StreamIn[x].Data.lensine) ) * Pi * 2 )));
  sf2 := StreamIn[x].Data.VRight * CFloat((Sin( ( CFloat((x2 div 2) + StreamIn[x].Data.posRsine)/CFloat( StreamIn[x].Data.lensine) ) * Pi * 2 )));
  case StreamIn[x].Data.SampleFormat of
  2:// int16
  begin
  ps^[x2] := trunc(sf1 * 32768);
  ps^[x2+1] := trunc(sf2 * 32768);
  end;
  1:// int32
  begin
  pl^[x2] := trunc(sf1 * 2147483648);
  pl^[x2+1] := trunc(sf2 * 2147483648);
  end;
  0:// float32
  begin
  pf^[x2] := sf1;
  pf^[x2+1] := sf2 ;
  end;
  end;  
   if StreamIn[x].Data.posLsine +1 > StreamIn[x].Data.lensine -1 then
  StreamIn[x].Data.posLsine := 0 else
  StreamIn[x].Data.posLsine := StreamIn[x].Data.posLsine +1 ;

  if StreamIn[x].Data.posRsine +1 > StreamIn[x].Data.lensine -1 then
  StreamIn[x].Data.posRsine := 0 else
  StreamIn[x].Data.posRsine := StreamIn[x].Data.posRsine +1 ;

  x2 := x2 + 2 ;
  end;

  if StreamIn[x].Data.Channels = 1 then
  begin
   sf1 := StreamIn[x].Data.VLeft * CFloat((Sin( ( CFloat(x2+ StreamIn[x].Data.posLsine)/CFloat( StreamIn[x].Data.lensine) ) * Pi * 2 )));
  case StreamIn[x].Data.SampleFormat of
  2:// int16
  begin
  ps^[x2] := trunc(sf1 * 32768);
   end;
  1:// int32
  begin
  pl^[x2] := trunc(sf1 * 2147483648);
  end;
  0:// float32
  begin
  pf^[x2] := sf1;
  end;
  end;  
  
  if StreamIn[x].Data.posLsine +1 > StreamIn[x].Data.lensine - 1  then
  StreamIn[x].Data.posLsine := 0 else
  StreamIn[x].Data.posLsine := StreamIn[x].Data.posLsine +1 ;

  inc(x2) ;
  end;
  end;

  StreamIn[x].Data.OutFrames :=  StreamIn[x].Data.WantFrames;
  end else StreamIn[x].Data.OutFrames :=  0 ;
  
  end;
  {$endif}

procedure Tuos_Player.ReadMem(X : integer);  
var
x2, wantframestemp : integer;
{$IF DEFINED(debug) and DEFINED(unix)}
i : integer;
 st : string;
{$endif}
begin
 if length(StreamIn[x].Data.memorybuffer) - StreamIn[x].Data.posmem - (StreamIn[x].Data.WantFrames

* StreamIn[x].Data.Channels) >= 0 then wantframestemp := (StreamIn[x].Data.WantFrames
* StreamIn[x].Data.Channels) else
 wantframestemp := length(StreamIn[x].Data.memorybuffer) - StreamIn[x].Data.posmem;

{$IF DEFINED(debug) and DEFINED(unix)}
writeln('length(StreamIn[x].Data.MemoryBuffer) = '+inttostr(length(StreamIn[x].Data.MemoryBuffer))) ;
writeln('StreamIn[x].Data.posmem = '+inttostr(StreamIn[x].Data.posmem)) ;
writeln('wantframestemp = '+inttostr(wantframestemp)) ;
{$endif}

for x2 := 0 to wantframestemp -1 do

StreamIn[x].Data.Buffer[x2] := (StreamIn[x].Data.memorybuffer[StreamIn[x].Data.posmem + x2]);

StreamIn[x].Data.posmem := StreamIn[x].Data.posmem + wantframestemp;

StreamIn[x].Data.OutFrames := wantframestemp;

if StreamIn[x].Data.SampleFormat > 0 then
StreamIn[x].Data.Buffer := ConvertSampleFormat(StreamIn[x].Data);

{$IF DEFINED(debug) and DEFINED(unix)}
writeln('StreamIn[x].Data.posmem after = '+inttostr(StreamIn[x].Data.posmem)) ;
writeln('StreamIn[x].Data.OutFrames = '+ inttostr(wantframestemp)) ;
st := '';
for i := 0 to length(StreamIn[x].data.Buffer) -1 do
st := st + '|' + inttostr(i) + '=' + floattostr(StreamIn[x].data.Buffer[i]);
WriteLn('OUTPUT DATA AFTER Input from memory ------------------------------');
WriteLn(st);
{$endif}
end;

procedure Tuos_Player.ReadMemDec(X : integer);  
var
x2, wantframestemp : integer;
{$IF DEFINED(debug) and DEFINED(unix)}
i : integer;
 st : string;
{$endif}
begin
 {
 if length(StreamIn[x].Data.MemoryStream) - StreamIn[x].Data.posmem - (StreamIn[x].Data.WantFrames

* StreamIn[x].Data.Channels) >= 0 then wantframestemp := (StreamIn[x].Data.WantFrames
* StreamIn[x].Data.Channels) else
 wantframestemp := length(StreamIn[x].Data.MemoryStream) - StreamIn[x].Data.posmem;
}


wantframestemp := (StreamIn[x].Data.WantFrames * StreamIn[x].Data.channels);

{$IF DEFINED(debug) and DEFINED(unix)}
writeln('length(StreamIn[x].MemoryStreamDec) = '+inttostr(StreamIn[x].MemoryStreamDec.size)) ;
writeln('StreamIn[x].Data.posmem = '+inttostr(StreamIn[x].Data.posmem)) ;
writeln('wantframestemp = '+inttostr(wantframestemp)) ;
{$endif}


StreamIn[x].Data.OutFrames := StreamIn[x].MemoryStreamDec.Read(StreamIn[x].Data.Buffer[0] ,wantframestemp);

StreamIn[x].Data.OutFrames := StreamIn[x].Data.OutFrames div StreamIn[x].Data.channels;

StreamIn[x].Data.posmem := StreamIn[x].Data.posmem + wantframestemp;

// StreamIn[x].Data.OutFrames := wantframestemp;

if StreamIn[x].Data.SampleFormat > 0 then
StreamIn[x].Data.Buffer := ConvertSampleFormat(StreamIn[x].Data);

{$IF DEFINED(debug) and DEFINED(unix)}
writeln('StreamIn[x].Data.posmem after = '+inttostr(StreamIn[x].Data.posmem)) ;
writeln('StreamIn[x].Data.OutFrames = '+ inttostr(wantframestemp)) ;
st := '';
for i := 0 to length(StreamIn[x].data.Buffer) -1 do
st := st + '|' + inttostr(i) + '=' + floattostr(StreamIn[x].data.Buffer[i]);
WriteLn('OUTPUT DATA AFTER Input from memory ------------------------------');
WriteLn(st);
{$endif}
end;

procedure Tuos_Player.DoSeek( x : integer);  
begin
 if StreamIn[x].Data.TypePut = 4 then
  StreamIn[x].Data.posmem := 0
  else

  case StreamIn[x].Data.LibOpen of
  {$IF DEFINED(sndfile)}
  0: sf_seek(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Poseek, 0);
  {$endif}
  {$IF DEFINED(mpg123)}
  1: mpg123_seek(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Poseek, 0);
  {$endif}
  {$IF DEFINED(neaac)}
  2 : MP4Seek(StreamIn[x].AACI, StreamIn[x].Data.Poseek);
  {$endif}
  {$IF DEFINED(cdrom)}
  3 : ;
  {$endif}
  {$IF DEFINED(opus)}
  4 : op_pcm_seek(StreamIn[x].Data.HandleOP, StreamIn[x].Data.Poseek);
  {$endif}
  end;
end;

procedure Tuos_Player.DoDSPOutAfterBufProc(x: integer);  
var
x3 : integer;
{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
msg: TfpgMessageParams;// for fpgui
 {$endif}
begin

  for x3 := 0 to high(StreamOut[x].DSP) do
  if (StreamOut[x].DSP[x3].Enabled = True) then
  begin
  if (StreamOut[x].DSP[x3].AftFunc <> nil) then
  StreamOut[x].Data.Buffer :=
  StreamOut[x].DSP[x3].AftFunc(StreamOut[x].Data,
  StreamOut[x].DSP[x3].fftdata);
  
  {$IF DEFINED(mse)}
    if (StreamOut[x].DSP[x3].LoopProc <> nil) then
   begin
     application.queueasynccall(StreamOut[x].DSP[x3].LoopProc);
     end;
   {$else}
 
  {$IF not DEFINED(Library)}
  if (StreamOut[x].DSP[x3].LoopProc <> nil) then
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,StreamOut[x].DSP[x3].LoopProc);
  {$else}
 {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
 begin
  msg.user.Param1 := x3 ;// the index of the dsp
  msg.user.Param2 := 1;// it is a OUT DSP
  fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
  end;
 {$else}
  thethread.synchronize(thethread,StreamOut[x].DSP[x3].LoopProc);
  {$endif}
  {$endif}

  {$elseif not DEFINED(java)}
  if (StreamOut[x].DSP[x3].LoopProc <> nil) then
  StreamOut[x].DSP[x3].LoopProc;
  {$else}
  if (StreamOut[x].DSP[x3].LoopProc <> nil) then
  {$IF FPC_FULLVERSION >= 20701}
  thethread.synchronize(thethread,@StreamOut[x].DSP[x3].LoopProcjava);
  {$else}
  thethread.synchronize(thethread,@StreamOut[x].DSP[x3].LoopProcjava);
  {$endif}
  {$endif}
  
   {$endif}
  end;
end;

procedure Tuos_Player.DoArrayLevel(x: integer);
begin
 setlength(uosLevelArray[index][x],length(uosLevelArray[index][x]) +1);
 uosLevelArray[index][x][length(uosLevelArray[index][x]) -1 ] := StreamIn[x].Data.LevelLeft;

 setlength(uosLevelArray[index][x],length(uosLevelArray[index][x]) +1);
 uosLevelArray[index][x][length(uosLevelArray[index][x]) -1 ] := StreamIn[x].Data.LevelRight;

// writeln('array length = ' + inttostr(length(uosLevelArray[index][x])));
end;

procedure Tuos_Player.ReadDevice(x : integer);  
var
x2 : integer;
begin
  for x2 := 0 to StreamIn[x].Data.WantFrames -1 do
   StreamIn[x].Data.Buffer[x2] := cfloat(0.0);// clear input
   Pa_ReadStream(StreamIn[x].Data.HandleSt,
   @StreamIn[x].Data.Buffer[0], StreamIn[x].Data.WantFrames);

// err :=// if you want clean buffer
   StreamIn[x].Data.OutFrames :=
   StreamIn[x].Data.WantFrames * StreamIn[x].Data.Channels;
//  if err = 0 then StreamIn[x].Data.Status := 1 else StreamIn[x].Data.Status := 0;// if you want clean buffer
end;

procedure Tuos_Player.DoDSPinBeforeBufProc(x: integer);  
var
x2 : integer;
begin
  for x2 := 0 to high(StreamIn[x].DSP) do
  if (StreamIn[x].DSP[x2].Enabled = True) and
  (StreamIn[x].DSP[x2].BefFunc <> nil) then
  StreamIn[x].DSP[x2].BefFunc(StreamIn[x].Data, StreamIn[x].DSP[x2].fftdata);
end;

procedure Tuos_Player.DoDSPinAfterBufProc(x: integer);  
var
x2 : integer;
{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
msg: TfpgMessageParams;// for fpgui
 {$endif}
begin
  for x2 := 0 to high(StreamIn[x].DSP) do
  if (StreamIn[x].DSP[x2].Enabled = True) then
  begin

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('DSPin AfterBuffProc 1.');
 {$endif}
  if (StreamIn[x].DSP[x2].AftFunc <> nil) then
  StreamIn[x].Data.Buffer :=
  StreamIn[x].DSP[x2].AftFunc(StreamIn[x].Data,
  StreamIn[x].DSP[x2].fftdata);

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('DSPin AfterBuffProc 2.');
 {$endif}

  {$IF DEFINED(mse)}
    if (StreamIn[x].DSP[x2].LoopProc <> nil) then
   begin
   application.queueasynccall(StreamIn[x].DSP[x2].LoopProc) ;
   end;
   {$else}
 
    {$IF not DEFINED(Library)}
  if (StreamIn[x].DSP[x2].LoopProc <> nil) then
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,StreamIn[x].DSP[x2].LoopProc);
  {$else}
  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  begin
  msg.user.Param1 := x2 ;// the index of the dsp
  msg.user.Param2 := 0;//  it is a In DSP
  fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
  end;
  {$else}
  thethread.synchronize(thethread,StreamIn[x].DSP[x2].LoopProc);
  {$endif}
  {$endif}
  {$elseif not DEFINED(java)}
  if (StreamIn[x].DSP[x2].LoopProc <> nil) then
  StreamIn[x].DSP[x2].LoopProc;
  {$else}
  if (StreamIn[x].DSP[x2].LoopProc <> nil) then
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,@Streamin[x].DSP[x2].LoopProcjava);
  {$else}
  thethread.synchronize(thethread,@Streamin[x].DSP[x2].LoopProcjava);
  {$endif}
  {$endif}
  {$endif}
  end;
end;

procedure Tuos_Player.SeekIfTerminated;
var
x, statustemp : integer;
begin
 
  statustemp := 0 ;
  for x := 0 to high(StreamIn) do
  begin
   if (StreamIn[x].Data.enabled = true)
  then begin
   
  if (StreamIn[x].Data.TypePut <> 1)
  then
  begin
  if StreamIn[x].Data.Status = 1 then
  statustemp := StreamIn[x].Data.Status;
  if (StreamIn[x].Data.Status = 2) and (statustemp = 0) then
  statustemp := StreamIn[x].Data.Status;
  end else
  if
  (StreamIn[x].Data.TypePut = 1) then statustemp := status ;
  end ;
  end;
  
  if statustemp <> status then status := statustemp;

  if (status = 0) and IsLooped then
  begin
   for x:= 0 to high(StreamIn) do
   begin
    InputSeek(x, 0);
    if StreamIn[x].Data.TypePut = 4 then
     StreamIn[x].Data.posmem:= 0;
    StreamIn[x].Data.status:= 1;
   end;

   Status:= 1;

   {$IF DEFINED(debug) and DEFINED(unix)}
    WriteLn('Loop (NLooped: '+IntToStr(NLooped)+')----');
   {$endif}

   if NLooped > 0 then
    Dec(NLooped);
  end;

end;

procedure Tuos_Player.DoLoopEndMethods;
begin
{$IF DEFINED(mse)}
    if LoopEndProc <> nil then
   begin
   application.queueasynccall(LoopEndProc);
   end;
     {$else}

 {$IF not DEFINED(Library)}
   if LoopEndProc <> nil then

//  Execute LoopEndProc procedure
   {$IF FPC_FULLVERSION>=20701}
   thethread.synchronize(thethread,LoopEndProc);
   {$else}
   {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
   begin
   msg.user.Param1 := -2 ;// it is the first proc
   fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
   end;
   {$else}
   thethread.synchronize(thethread,LoopEndProc);
   {$endif}
   {$endif}
   {$elseif not DEFINED(java)}
   if LoopEndProc <> nil then
   LoopEndProc;
   {$else}
   if LoopEndProc <> nil then

   {$IF FPC_FULLVERSION>=20701}
   thethread.synchronize(thethread,@endprocjava);
   {$else}
   thethread.synchronize(thethread,@endprocjava);//  Execute EndProc procedure
   {$endif}
   {$endif}
   {$endif}
end;

procedure Tuos_Player.DoEndProc;
begin
{$IF DEFINED(mse)}
 if EndProc <> nil then
     application.queueasynccall(EndProc);
 {$else}

 {$IF not DEFINED(Library)}
  if EndProc <> nil then
  // thethread.synchronize(thethread,EndProc);//  Execute EndProc procedure

 thethread.queue(thethread,EndProc);//  Execute EndProc procedure

  {$elseif not DEFINED(java)}
  if (EndProc <> nil) then
  EndProc;
  {$else}
  if (EndProc <> nil) then
  thethread.synchronize(thethread,@endprocjava);//  Execute EndProc procedure
 
  {$endif}

  {$endif}
end;

procedure Tuos_Player.DoTerminateNoFreePlayer;
var
x, x2 : integer;
begin

  for x := 0 to high(StreamIn) do
  begin
  if (length(StreamIn[x].DSP) > 0) then
  for x2 := 0 to high(StreamIn[x].DSP) do
  if (StreamIn[x].DSP[x2].EndFunc <> nil) then
  StreamIn[x].DSP[x2].EndFunc(StreamIn[x].Data, StreamIn[x].DSP[x2].fftdata);
  end;

  for x := 0 to high(StreamOut) do
  begin
  if (length(StreamOut[x].DSP) > 0) then
  for x2 := 0 to high(StreamOut[x].DSP) do
  if (StreamOut[x].DSP[x2].EndFunc <> nil) then
  StreamOut[x].DSP[x2].EndFunc(StreamOut[x].Data, StreamOut[x].DSP[x2].fftdata);
  end;

  if (StreamOut[x].Data.TypePut = 0) then
  begin
  WriteWave(StreamOut[x].Data.Filename, StreamOut[x].FileBuffer);
// StreamOut[x].FileBuffer.Data.Free;
  end;

  if (StreamOut[x].Data.TypePut = 4) then
  begin
  WriteWaveFromMem(StreamOut[x].Data.Filename, StreamOut[x].FileBuffer);
// StreamOut[x].FileBuffer.Data.Free;
  end;
  
 {$IF DEFINED(mse)}
 if EndProc <> nil then
   begin
   application.queueasynccall(EndProc);
   end;
     {$else}
 
  {$IF not DEFINED(Library)}
  if EndProc <> nil then
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,EndProc);
  {$else}
  thethread.synchronize(thethread,EndProc);//  Execute EndProc procedure
  {$endif}

  {$elseif not DEFINED(java)}
  if (EndProc <> nil) then
  EndProc;
  {$else}
  if (EndProc <> nil) then
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,@endprocjava);
  {$else}
  thethread.synchronize(thethread,@endprocjava);//  Execute EndProc procedure
  {$endif}

  {$endif}
   {$endif}
  
   {$IF DEFINED(portaudio)} 
   for x := 0 to high(StreamOut) do 
    if (StreamOut[x].Data.HandleSt <> nil) and 
       (StreamOut[x].Data.TypePut = 1) then 
     Pa_StopStream(StreamOut[x].Data.HandleSt); 
   {$ENDIF}   

   if EndProcOnly <> nil then EndProcOnly;
      
   StreamIn[x].Data.Poseek := 0;// set to begin
   doseek(x);
   
   Status := 2;

    if isGlobalPause = true then
  begin
  RTLeventReSetEvent(uosInit.evGlobalPause)
  end
   else
  begin
  RTLeventReSetEvent(evPause);
  end;

end;

procedure Tuos_Player.DoTerminatePlayer;
var
 x, x2 : integer;
begin
      
  if length(PlugIn) > 0 then
   begin
   for x := 0 to high(PlugIn) do
   begin
   {$IF DEFINED(soundtouch)}
   if Plugin[x].Name = 'soundtouch' then
   begin
   soundtouch_clear(Plugin[x].PlugHandle);
   soundtouch_destroyInstance(Plugin[x].PlugHandle);
   end;
   
   if Plugin[x].Name = 'getbpm' then
   begin
   bpm_destroyInstance(Plugin[x].PlugHandle);
   end;
   {$endif}

   {$IF DEFINED(bs2b)}
   if Plugin[x].Name = 'bs2b' then
   begin
   bs2b_close(Plugin[x].Abs2b);
   end;
   {$endif}
   end;
   end;

  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('Destroy DSP In');
  {$endif}

   for x := 0 to high(StreamIn) do
   begin
   if (length(StreamIn[x].DSP) > 0) then
   for x2 := 0 to high(StreamIn[x].DSP) do
   if (StreamIn[x].DSP[x2].EndFunc <> nil) then
   StreamIn[x].DSP[x2].EndFunc(StreamIn[x].Data, StreamIn[x].DSP[x2].fftdata);
   end;

  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('Destroy DSP Out');
  {$endif}

   for x := 0 to high(StreamOut) do
   begin
   if (assigned(StreamOut[x].DSP)) and  (assigned(StreamOut[x]))  then if  (length(StreamOut[x].DSP) > 0) then
   for x2 := 0 to high(StreamOut[x].DSP) do
   if (StreamOut[x].DSP[x2].EndFunc <> nil) then
   StreamOut[x].DSP[x2].EndFunc(StreamOut[x].Data, StreamOut[x].DSP[x2].fftdata);
   end;

   for x := 0 to high(StreamIn) do
   if assigned(StreamIn[x].Data.HandleSt) then if (StreamIn[x].Data.HandleSt <> nil) then
   case StreamIn[x].Data.TypePut of
   0: case StreamIn[x].Data.LibOpen of
   {$IF DEFINED(sndfile)}
   0: sf_close(StreamIn[x].Data.HandleSt);
   {$endif}
   {$IF DEFINED(mpg123)}
   1: begin
   mpg123_close(StreamIn[x].Data.HandleSt);
   mpg123_delete(StreamIn[x].Data.HandleSt);
   end;
   {$ENDIF}
   {$IF DEFINED(neaac)}
   2 :Begin
   MP4CloseFile(StreamIn[x].AACI);
   End;
   {$endif}
   {$IF DEFINED(cdrom)}
   3: Begin
   CDROM_Close(StreamIn[x].pCD);
   End;
   {$endif}
   {$IF DEFINED(opus)}
   4: begin
   op_free(StreamIn[x].Data.HandleOP);
   sleep(50);// needed ?
   end;
   {$ENDIF}

   99:// if nothing was defined

   end;

   {$IF DEFINED(portaudio)}
   1: begin
   Pa_StopStream(StreamIn[x].Data.HandleSt);
   Pa_CloseStream(StreamIn[x].Data.HandleSt);
   end;
   {$endif}
   
   {$IF DEFINED(webstream)}
   2: begin
   StreamIn[x].httpget.Terminate;
   sleep(100);
   StreamIn[x].httpget.Free;

   case StreamIn[x].Data.LibOpen of
   {$IF DEFINED(mpg123)}
   1: begin
   mpg123_close(StreamIn[x].Data.HandleSt);
   mpg123_delete(StreamIn[x].Data.HandleSt);
   end;
   {$ENDIF}
   {$IF DEFINED(opus)}
   4: begin
   op_free(StreamIn[x].Data.HandleOP);
   sleep(50);// needed ?
   end;
   {$ENDIF}
   end;
   end;
   {$ENDIF}

   end;

   for x := 0 to high(StreamOut) do
   begin
   {$IF DEFINED(portaudio)}
   if (StreamOut[x].Data.HandleSt <> nil) and
   (StreamOut[x].Data.TypePut = 1) then
   begin
    Pa_StopStream(StreamOut[x].Data.HandleSt);
    Pa_CloseStream(StreamOut[x].Data.HandleSt);
   end;
   {$ENDIF}
   
   {$IF DEFINED(shout)}
   if  (StreamOut[x].Data.TypePut = 2) then
   begin
//  freeandnil(StreamOut[x].encoder) ;
   shout_free(StreamOut[x].Data.HandleSt);

   end;
   {$endif}

   if (StreamOut[x].Data.TypePut = 0) then
   begin
   WriteWave(StreamOut[x].Data.Filename, StreamOut[x].FileBuffer);
//  StreamOut[x].FileBuffer.Data.Free;
   end;

   if (StreamOut[x].Data.TypePut = 4) then
   begin
   WriteWaveFromMem(StreamOut[x].Data.Filename, StreamOut[x].FileBuffer);
    StreamOut[x].FileBuffer.Data.Free;
   end;


   end;
   
     
end;

procedure Tuos_Player.DoMainLoopProc(x: integer);
{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
var
msg: TfpgMessageParams;// for fpgui
 {$endif}
begin

 {$IF DEFINED(mse)}
 if StreamIn[x].LoopProc <> nil then
   begin
   application.queueasynccall(StreamIn[x].LoopProc);
   end;
     {$else}

// The synchro main loop procedure
  {$IF not DEFINED(Library)}
  if StreamIn[x].LoopProc <> nil then
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,StreamIn[x].LoopProc);
  {$else}
  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  begin
  msg.user.Param1 := -1 ;// it is the main loop procedure
  msg.user.Param2 := 0 ;//  it is a INput procedure
  fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
  end;
  {$else}
  thethread.synchronize(thethread,StreamIn[x].LoopProc);
  {$endif}
  {$endif}

  {$elseif not DEFINED(java)}
  if (StreamIn[x].LoopProc <> nil) then
  StreamIn[x].LoopProc;
  {$else}
  if (StreamIn[x].LoopProc <> nil) then
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,@Streamin[x].LoopProcjava);
  {$else}
  thethread.synchronize(thethread,@Streamin[x].LoopProcjava);
  {$endif}
  {$endif}
   {$endif}
end;

procedure Tuos_Player.DoBeginMethods;
{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
var
msg: TfpgMessageParams;// for fpgui
 {$endif}
begin
{$IF DEFINED(mse)}
 if BeginProc <> nil then
   begin
   application.queueasynccall(BeginProc);
   end;
 {$else}
     
 {$IF not DEFINED(Library)}
  if BeginProc <> nil then
//  Execute BeginProc procedure
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,BeginProc);
  {$else}
  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  begin
  msg.user.Param1 := -2 ;// it is the first proc
  fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
  end;
  {$else}
  thethread.synchronize(thethread,BeginProc);
  {$endif}
  {$endif}
  {$elseif not DEFINED(java)}
  if BeginProc <> nil then
  BeginProc;
  {$else}
  if BeginProc <> nil then
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,@BeginProcjava);
  {$else}
  thethread.synchronize(thethread,@BeginProcjava);
  {$endif}
  {$endif}
  {$endif}
 end;

 procedure Tuos_Player.DoLoopBeginMethods;
{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
 var
 msg: TfpgMessageParams;// for fpgui
 {$endif}
begin
{$IF DEFINED(mse)}
 if LoopBeginProc <> nil then
   begin
   application.queueasynccall(LoopBeginProc);
   end;
 {$else}
  {$IF not DEFINED(Library)}
  if LoopBeginProc <> nil then
//  Execute BeginProc procedure
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,LoopBeginProc);
  {$else}
  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  begin
  msg.user.Param1 := -2 ;// it is the first proc
  fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
  end;
  {$else}
  thethread.synchronize(thethread,LoopBeginProc);
  {$endif}
  {$endif}
  {$elseif not DEFINED(java)}
  if loopBeginProc <> nil then
  loopBeginProc;
  {$else}
  if loopBeginProc <> nil then
  {$IF FPC_FULLVERSION>=20701}
  thethread.synchronize(thethread,@loopBeginProcjava);
  {$else}
  thethread.synchronize(thethread,@loopBeginProcjava);
  {$endif}
  {$endif}
  {$endif}
end;

procedure Tuos_Player.WriteOut(x:integer;  x2 : integer);  
 var
 err, rat, wantframestemp: integer;
 
{$IF DEFINED(debug) and DEFINED(unix)}
 st : string;
 i : integer;
{$endif}
  Bufferst2mo: TDArFloat;
begin
// Convert Input format into Output format if needed:
 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Convert Input format into Output');
 {$endif}
  case StreamOut[x].Data.SampleFormat of
  0: case StreamIn[x2].Data.SampleFormat of
  1: StreamOut[x].Data.Buffer :=
  CvInt32toFloat32(StreamOut[x].Data.Buffer);
  2: StreamOut[x].Data.Buffer :=
  CvInt16toFloat32(StreamOut[x].Data.Buffer);
  end;
  end;
// End convert.
 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Finally give buffer to output');
 {$endif}
// Finally give buffer to output
  case StreamOut[x].Data.TypePut of
  {$IF DEFINED(portaudio)}
  1:// Give to output device using portaudio
  begin

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Give to output device');
 writeln('length(StreamOut[x].Data.Buffer) =' + inttostr(length(StreamOut[x].Data.Buffer)));
 {$endif}
 
  if (StreamIn[x2].Data.TypePut <> 1) or
  ((StreamIn[x2].Data.TypePut = 1) and (StreamIn[x2].Data.Channels > 1)) then
  begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  st := '';
  for i := 0 to length(StreamOut[x].Data.Buffer) -1 do
  st := st + '|' + inttostr(i) + '=' + floattostr(StreamOut[x].Data.Buffer[i]);
  WriteLn('OUTPUT DATA into portaudio------------------------------');
//WriteLn(st);
  {$endif}

//  err :=// if you want clean buffer

 if assigned(StreamOut[x].Data.HandleSt) then
   Pa_WriteStream(StreamOut[x].Data.HandleSt,
  @StreamOut[x].Data.Buffer[0], StreamIn[x2].Data.outframes div StreamIn[x2].Data.ratio);

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('give to output device 1');
{$endif}
  end else
  begin
// err :=// if you want clean buffer
    Pa_WriteStream(StreamOut[x].Data.HandleSt,
  @StreamOut[x].Data.Buffer[0], StreamIn[x2].Data.outframes);
  end;
// if err <> 0 then status := 0;// if you want clean buffer ...
{$IF DEFINED(debug) and DEFINED(unix)}
 writeln('End give to output device 2');
{$endif}
  end;
  {$endif}
  

  {$IF DEFINED(shout)}
  2:// Give to IceCast server
  begin

{$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Give to output IceCast server');
 {$endif}

 case StreamOut[x].Data.SampleFormat of
  0:
  begin
  err := opus_encode_float(StreamOut[x].encoder,  @StreamOut[x].Data.Buffer[0], cFRAME_SIZE*3, StreamOut[x].cbits, cMAX_PACKET_SIZE);
  end;
  1:
  begin
  err := opus_encode(StreamOut[x].encoder,  @StreamOut[x].Data.Buffer[0], cFRAME_SIZE*3, StreamOut[x].cbits, cMAX_PACKET_SIZE);
  end;
  2:
  begin
  err := opus_encode(StreamOut[x].encoder, @StreamOut[x].Data.Buffer[0], cFRAME_SIZE*3, StreamOut[x].cbits, cMAX_PACKET_SIZE);
  end;
 end;

  StreamOut[x].data.outframes := err;

{$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('opus_encode outframes =' + inttostr(err));
  WriteLn('----------------------------------');
//  writeln(tencoding.utf8.getstring(StreamOut[x].cbits));
  {$endif}

if err > 0 then

 err := shout_send_raw(StreamOut[x].Data.HandleSt, StreamOut[x].cbits, StreamOut[x].data.outframes);

{$IF DEFINED(debug) and DEFINED(unix)}
		 if err = SHOUTERR_SUCCESS then
  WriteLn('shout_send ok ' + inttostr(err)) else
  WriteLn('shout_send error: '+ inttostr(err) + ' ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  writeln('End give output to IceCast server');
 {$endif}

  shout_sync(StreamOut[x].Data.HandleSt);
  end;
  {$endif}

  3:
  begin// Give to memory buffer

   wantframestemp := StreamIn[x2].Data.outframes ;

  {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('Before Give to memory ------------------------------');
   st := '';
  for i := 0 to wantframestemp -1 do
  st := st + '|' + inttostr(i) + '=' + floattostr(StreamOut[x].Data.Buffer[i]);
  WriteLn(st);
  WriteLn('OUTPUT DATA AFTER5 ------------------------------');
  writeln('Streamout[x].Data.posmem before = '+inttostr( Streamout[x].Data.posmem)) ;

  writeln('StreamIn[x2].Data.outframes * StreamIn[x2].Data.channels = '+inttostr( StreamIn[x2].Data.outframes * StreamIn[x2].Data.channels)) ;
  writeln('length(tempoutmemory) = '+ inttostr(length(tempoutmemory)));
  writeln('Begin Give to memory buffer');
  writeln('(StreamIn[x2].Data.outframes ) -1 = ' +
  inttostr((StreamIn[x2].Data.outframes) -1));
 {$endif}
  
  if StreamIn[x2].Data.numbuf > -1 then
  begin
// writeln('theinc = ' +  inttostr(theinc));
  inc(theinc);
  if theinc > StreamIn[x2].Data.numbuf then status := 0 ;
  end;

   SetLength(Streamout[x].BufferOut^,length(Streamout[x].BufferOut^) + wantframestemp );

  for x2 := 0 to (wantframestemp) -1 do begin
   Streamout[x].BufferOut^[Streamout[x].Data.posmem + x2] := StreamOut[x].Data.Buffer[x2];
  end;
  Streamout[x].Data.posmem := Streamout[x].Data.posmem + (wantframestemp);

//  if Streamout[x].Data.SampleFormat > 0 then
//StreamOut[x].Data.Buffer := ConvertSampleFormat(StreamOut[x].Data);

 {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('Streamout[x].Data.posmem after = '+inttostr( Streamout[x].Data.posmem)) ;
  st := '';
  for i := 0 to length(tempoutmemory) -1 do
  st := st + '|' + inttostr(i) + '=' + floattostr(tempoutmemory[i]);
  WriteLn('OUTPUT DATA AFTER5 ------------------------------');
//WriteLn(st);
 {$endif}

  end;

  4:// Give to wav file from TMemoryStream
  begin

  case StreamOut[x].Data.SampleFormat of
  0: rat := 2 ;
  1: rat := 2 ;
  2: rat := 1 ;
  end;

  if (StreamOut[x].FileBuffer.wChannels = 1) and (StreamIn[x2].Data.Channels = 2) then
  begin

  Bufferst2mo  := CvSteroToMono(StreamOut[x].Data.Buffer, StreamIn[x2].Data.outframes);

  StreamOut[x].FileBuffer.DataMS.WriteBuffer(
  Bufferst2mo[0],
  StreamIn[x2].Data.outframes * rat);
  end else
  if (StreamOut[x].FileBuffer.wChannels = 1) and (StreamIn[x2].Data.Channels = 1) then
  begin
  StreamOut[x].FileBuffer.DataMS.WriteBuffer(
  StreamOut[x].Data.Buffer[0],  StreamIn[x2].Data.outframes * StreamIn[x2].Data.ratio * rat);
  end else

  StreamOut[x].FileBuffer.DataMS.WriteBuffer(
  StreamOut[x].Data.Buffer[0],  StreamIn[x2].Data.outframes * StreamIn[x2].Data.Channels * rat);
  end;

   5:// Give to MemoryStream
  begin
 
  case StreamOut[x].Data.SampleFormat of
  0: rat := 2 ;
  1: rat := 2 ;
  2: rat := 1 ;
  end;
  
 if assigned(StreamOut[x].MemorySteamOut) then
  StreamOut[x].MemorySteamOut.WriteBuffer(
  StreamOut[x].Data.Buffer[0],  StreamIn[x2].Data.outframes * StreamIn[x2].Data.Channels * rat);
   
  end;

  0:// Give to wav file from TFileStream
  begin

  case StreamOut[x].Data.SampleFormat of
  0: rat := 2 ;
  1: rat := 2 ;
  2: rat := 1 ;
  end;

  if (StreamOut[x].FileBuffer.wChannels = 1) and (StreamIn[x2].Data.Channels = 2) then
  begin

  Bufferst2mo  := CvSteroToMono(StreamOut[x].Data.Buffer, StreamIn[x2].Data.outframes);

  StreamOut[x].FileBuffer.Data.WriteBuffer(
  Bufferst2mo[0],
  StreamIn[x2].Data.outframes * rat);
  end else
  if (StreamOut[x].FileBuffer.wChannels = 1) and (StreamIn[x2].Data.Channels = 1) then
  begin
  StreamOut[x].FileBuffer.Data.WriteBuffer(
  StreamOut[x].Data.Buffer[0],  StreamIn[x2].Data.outframes * StreamIn[x2].Data.ratio * rat);
  end else

  StreamOut[x].FileBuffer.Data.WriteBuffer(
  StreamOut[x].Data.Buffer[0],  StreamIn[x2].Data.outframes * StreamIn[x2].Data.Channels * rat);
  end;

  end;
end;

procedure Tuos_Player.WriteOutPlug(x:integer;  x2 : integer);  
 var
 x3, x4, err, wantframestemp: integer;
  {$IF DEFINED(debug) and DEFINED(unix)}
 st : string;
 i : integer;
 {$endif}
  BufferplugINFLTMP: TDArFloat;
  BufferplugFL: TDArFloat;
  BufferplugSH: TDArShort;
  BufferplugLO: TDArLong;
  Bufferst2mo: TDArFloat;
begin
// convert buffer if needed
  case StreamOut[x].Data.SampleFormat of
  1: StreamOut[x].Data.Buffer :=
  CvInt32toFloat32(StreamOut[x].Data.Buffer);
  2: StreamOut[x].Data.Buffer :=
  CvInt16toFloat32(StreamOut[x].Data.Buffer);
  end;

// transfer buffer out to temp
  SetLength(BufferplugINFLTMP, (StreamIn[x2].Data.outframes) *
  StreamIn[x2].Data.Channels);

  if length(BufferplugINFLTMP) > 2 then
  for x3 := 0 to (length(BufferplugINFLTMP) div 2) - 1 do
  BufferplugINFLTMP[x3] := cfloat(StreamOut[x].Data.Buffer[x3]);

// dealing with input plugin
  for x3 := 0 to high(PlugIn) do
  begin
  if PlugIn[x3].Enabled = True then
  begin
  {$IF DEFINED(bs2b) or DEFINED(soundtouch) or DEFINED(noiseremoval)}
  BufferplugFL := Plugin[x3].PlugFunc(BufferplugINFLTMP,
  Plugin[x3].PlugHandle, Plugin[x3].Abs2b, StreamIn[x2].Data,
  Plugin[x3].param1, Plugin[x3].param2, Plugin[x3].param3, Plugin[x3].param4,
  Plugin[x3].param5, Plugin[x3].param6, Plugin[x3].param7, Plugin[x3].param8);
  {$endif}

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('PlugFunc: Length(BufferplugINFLTMP,BufferplugFL) = ' +
  inttostr(Length(BufferplugINFLTMP)) + ' , ' + inttostr(Length(BufferplugFL)));
 {$endif}

  if (length(PlugIn) > 1) then
  begin
// TO CHECK : works only if SoundTouch is last or only plugin
  for x4 := 0 to length(BufferplugFL) - 1 do
  BufferplugINFLTMP[x4] := cfloat(BufferplugFL[x4]);
  end;
  end;

 {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('2-PlugFunc: Length(BufferplugINFLTMP,BufferplugFL) = ' +
  inttostr(Length(BufferplugINFLTMP)) + ' , ' + inttostr(Length(BufferplugFL)));
 {$endif}
  end;

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Give the processed input to output.');
 writeln('Length(BufferplugFL) = ' + inttostr(Length(BufferplugFL)));
 {$endif}
  if Length(BufferplugFL) > 0 then
  begin

  case StreamOut[x].Data.SampleFormat of
  1:
  begin
  SetLength(BufferplugLO, length(BufferplugFL));
  BufferplugLO := CvFloat32ToInt32(BufferplugFL);
  end;
  2:
  begin
  SetLength(BufferplugSH, length(BufferplugFL));
  BufferplugSH := CvFloat32ToInt16(BufferplugFL);

  end;
  end;

  case StreamOut[x].Data.TypePut of

  {$IF DEFINED(portaudio)}
  1:// Give to output device
  begin

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Before Pa_WriteStream: Length(BufferplugFL) = ' + inttostr(Length(BufferplugFL)));
 {$endif}
  case StreamOut[x].Data.SampleFormat of
  0:
  begin
  err :=
  Pa_WriteStream(StreamOut[x].Data.HandleSt,
  @BufferplugFL[0], Length(BufferplugFL) div
  StreamIn[x2].Data.Channels);
  end;
  1:
  begin
  BufferplugLO := CvFloat32ToInt32(BufferplugFL);
  err :=
  Pa_WriteStream(StreamOut[x].Data.HandleSt,
  @BufferplugLO[0], Length(BufferplugLO) div
  StreamIn[x2].Data.Channels);
  end;
  2:
  begin
  BufferplugSH := CvFloat32ToInt16(BufferplugFL);

  err :=
  Pa_WriteStream(StreamOut[x].Data.HandleSt,
  @BufferplugSH[0], Length(BufferplugSH) div
  StreamIn[x2].Data.Channels);
  end;
  end;
// if err <> 0 then status := 0;// if you want clean buffer ...

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Pa_WriteStream error = '+ inttostr(err));
 {$endif}
  end;
  {$endif}
  
  {$IF DEFINED(shout)}
  2:// Give to IceCast server
  begin

{$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Give to output IceCast server');
 {$endif}

 case StreamOut[x].Data.SampleFormat of
  0:
  begin
  err := opus_encode_float(StreamOut[x].encoder, @BufferplugFL[0], cFRAME_SIZE, StreamOut[x].cbits, cMAX_PACKET_SIZE);
  end;
  1:
  begin
  err := opus_encode(StreamOut[x].encoder, @BufferplugLO[0], cFRAME_SIZE, StreamOut[x].cbits, cMAX_PACKET_SIZE);
  end;
  2:
  begin
  err := opus_encode(StreamOut[x].encoder, @BufferplugSH[0], cFRAME_SIZE, StreamOut[x].cbits, cMAX_PACKET_SIZE);
  end;
 end;

  StreamOut[x].data.outframes  := err ;

{$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('opus_encode outframes =' + inttostr(err));
  WriteLn('----------------------------------');
//  writeln(tencoding.utf8.getstring(StreamOut[x].cbits));
  {$endif}

if err > 0 then

 err := shout_send(StreamOut[x].Data.HandleSt, StreamOut[x].cbits, StreamOut[x].data.outframes);

{$IF DEFINED(debug) and DEFINED(unix)}
		 if err = SHOUTERR_SUCCESS then
  WriteLn('shout_send ok ' + inttostr(err)) else
  WriteLn('shout_send error: '+ inttostr(err) + ' ' + pchar(shout_get_error(StreamOut[x].Data.HandleSt)));
  writeln('End give output to IceCast server');
 {$endif}

  shout_sync(StreamOut[x].Data.HandleSt);// ?

  end;
  {$endif}

  0:
  begin// Give to wav file from TFileStream

  if (StreamOut[x].FileBuffer.wChannels = 1) and (StreamIn[x2].Data.Channels = 2) then
  begin
  Bufferst2mo :=  CvSteroToMono(BufferplugFL, Length(BufferplugFL) div 2);
  BufferplugSH := CvFloat32ToInt16(Bufferst2mo);
  end else
  begin
  BufferplugSH := CvFloat32ToInt16(BufferplugFL);
  end;
  StreamOut[x].FileBuffer.Data.WriteBuffer(BufferplugSH[0],
  Length(BufferplugSH));

  end;

  4:
  begin// Give to wav file from TMemoryStream

  if (StreamOut[x].FileBuffer.wChannels = 1) and (StreamIn[x2].Data.Channels = 2) then
  begin
  Bufferst2mo :=  CvSteroToMono(BufferplugFL, Length(BufferplugFL) div 2);
  BufferplugSH := CvFloat32ToInt16(Bufferst2mo);
  end else
  begin
  BufferplugSH := CvFloat32ToInt16(BufferplugFL);
  end;
  StreamOut[x].FileBuffer.DataMS.WriteBuffer(BufferplugSH[0],
  Length(BufferplugSH));

  end;
  
  5:// Give to MemoryStream
  begin

   case StreamOut[x].Data.SampleFormat of
  0:  StreamOut[x].MemorySteamOut.WriteBuffer(BufferplugFL[0],
  Length(BufferplugFL));
  
  1:  StreamOut[x].MemorySteamOut.WriteBuffer(BufferplugLO[0],
  Length(BufferplugLO));
  
  2:  StreamOut[x].MemorySteamOut.WriteBuffer(BufferplugSH[0],
  Length(BufferplugSH));
 
  end;
  end;


  3:
  begin// Give to memory buffer
  wantframestemp := Length(BufferplugFL) ;
  SetLength(Streamout[x].BufferOut^,length(Streamout[x].BufferOut^) + wantframestemp );

  for x2 := 0 to wantframestemp -1 do
  Streamout[x].BufferOut^[Streamout[x].Data.posmem + x2] := BufferplugFL[x2];
 
  Streamout[x].Data.posmem := Streamout[x].Data.posmem + wantframestemp;

  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('Streamout[x].Data.posmem = '+inttostr( Streamout[x].Data.posmem)) ;
  st := '';
  for i := 0 to length(tempoutmemory) -1 do
  st := st + '|' + inttostr(i) + '|' + floattostr(tempoutmemory[i]);
  WriteLn('OUTPUT DATA AFTER4 ------------------------------');
  WriteLn(st);
  {$endif}
  end;

  end;
  end;
end;

{$IF DEFINED(webstream)}
procedure Tuos_Player.ReadUrl(x : integer);  
var
err : integer;
{$IF DEFINED(debug) and DEFINED(unix)}
i : integer;
 st : string;
{$endif}
begin
case StreamIn[x].Data.LibOpen of
1 : begin
{$IF DEFINED(mpg123)}

{$IF DEFINED(debug) and DEFINED(unix)}
writeln('===> Before mpg123_read') ;
{$endif}
err :=
mpg123_read(StreamIn[x].Data.HandleSt, @StreamIn[x].Data.Buffer[0],
StreamIn[x].Data.wantframes, StreamIn[x].Data.outframes);

{$IF DEFINED(debug) and DEFINED(unix)}
writeln('===> mpg123_read error => ' + inttostr(err)) ;
{$endif}
StreamIn[x].Data.outframes :=
StreamIn[x].Data.outframes div StreamIn[x].Data.Channels;
{$ENDIF}
end;
4 : begin
{$IF DEFINED(opus)}

{$IF DEFINED(debug) and DEFINED(unix)}
writeln('===> Before op_read_x.') ;
{$endif}

case StreamIn[x].Data.SampleFormat of
0: begin
StreamIn[x].Data.outframes := cint(op_read_float(StreamIn[x].Data.HandleOP,
@StreamIn[x].Data.Buffer[0], cint(StreamIn[x].Data.Wantframes
div StreamIn[x].Data.channels) , nil));
end;
1: begin
StreamIn[x].Data.outframes := cint(op_read_float(StreamIn[x].Data.HandleOP,
@StreamIn[x].Data.Buffer[0], cint(StreamIn[x].Data.Wantframes
div StreamIn[x].Data.channels), nil));

// no int32 format with opus => need a conversion from float32 to int32.
StreamIn[x].Data.Buffer := Cvfloat32ToInt32fl( StreamIn[x].Data.Buffer,
StreamIn[x].Data.outframes * StreamIn[x].Data.Channels );
end;
2: begin

StreamIn[x].Data.outframes :=cint( op_read(StreamIn[x].Data.HandleOP,
@StreamIn[x].Data.Buffer[0], cint(StreamIn[x].Data.Wantframes
div StreamIn[x].Data.channels), nil));

end;
end;

setlength(StreamIn[x].data.Buffer, StreamIn[x].Data.outframes * StreamIn[x].Data.Channels);

{$IF DEFINED(debug) and DEFINED(unix)}
writeln('Seek outframes = '+inttostr(StreamIn[x].Data.outframes)) ;
st := '';
for i := 0 to length(StreamIn[x].data.Buffer) -1 do
st := st + '|' + inttostr(i) + '|' + floattostr(StreamIn[x].data.Buffer[i]);
WriteLn('OUTPUT DATA AFTER1 ------------------------------');
//  WriteLn(st);
writeln(' StreamIn[x].Data.outframes = '+inttostr(StreamIn[x].Data.outframes * StreamIn[x].Data.Channels)) ;
{$endif}

if StreamIn[x].Data.outframes < 0 then StreamIn[x].Data.outframes := 0 ;

{$ENDIF}
end;
end;

  if (StreamIn[x].Data.TypePut = 2) and ((StreamIn[x].Data.LibOpen = 1 ) or (StreamIn[x].Data.LibOpen = 4 )) then
  begin
  if StreamIn[x].httpget.IsRunning = false then  StreamIn[x].Data.status := 0;// no more data then close the stream
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('Check if internet is stopped.');
  {$endif}
  end;

end;
{$endif}

procedure Tuos_Player.ReadFile(x : integer);  
{$IF DEFINED(neaac) or DEFINED(debug)}
var
{$endif}
{$IF DEFINED(neaac)}
outBytes: longword;
{$endif}
{$IF DEFINED(debug) and DEFINED(unix)}
i : integer;
 st : string;
{$endif}
begin
 if length(StreamIn[x].Data.Buffer) <> StreamIn[x].Data.Wantframes then
 setlength(StreamIn[x].Data.Buffer,StreamIn[x].Data.Wantframes);

 case StreamIn[x].Data.LibOpen of
// Here we are, reading the data and store it in buffer
 {$IF DEFINED(sndfile)}
 0: begin
 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('Before sf_read ' + inttostr(StreamIn[x].Data.Wantframes) + ' length(StreamIn[x].Data.Buffer ' +
  inttostr(length(StreamIn[x].Data.Buffer)));
 {$endif}
 case StreamIn[x].Data.SampleFormat of
 0: StreamIn[x].Data.OutFrames :=
 sf_read_float(StreamIn[x].Data.HandleSt,
 @StreamIn[x].Data.Buffer[0], StreamIn[x].Data.Wantframes);
 1: StreamIn[x].Data.OutFrames :=
 sf_read_int(StreamIn[x].Data.HandleSt,
 @StreamIn[x].Data.Buffer[0], StreamIn[x].Data.Wantframes);
 2: StreamIn[x].Data.OutFrames :=
 sf_read_short(StreamIn[x].Data.HandleSt,
 @StreamIn[x].Data.Buffer[0], StreamIn[x].Data.Wantframes);
 end;

 {$IF DEFINED(debug) and DEFINED(unix)}
  WriteLn('after sf_read');
 {$endif}
 if  StreamIn[x].Data.outframes < 0 then  StreamIn[x].Data.outframes := 0 ;
 setlength(StreamIn[x].data.Buffer,StreamIn[x].Data.outframes);

 {$IF DEFINED(debug) and DEFINED(unix)}
 st := '';
 for i := 0 to length(StreamIn[x].data.Buffer) -1 do
 case StreamIn[x].Data.SampleFormat of
 0: st := st + '|' + inttostr(i) + '=' + floattostr(StreamIn[x].data.Buffer[i]);
 1: st := st + '|' + inttostr(i) + '=' + inttostr(cint32(StreamIn[x].data.Buffer[i]));
 2: st := st + '|' + inttostr(i) + '=' + inttostr(cint16(cint32(StreamIn[x].data.Buffer[i])));
 end;
 WriteLn('OUTPUT DATA sf_read_() ---------------------------');
 WriteLn('StreamIn[x].Data.outframes = ' + inttostr(StreamIn[x].Data.outframes));
// WriteLn(st);
 {$endif}

 end;
 {$endif}
 {$IF DEFINED(mpg123)}
 1:
 begin

 mpg123_read(StreamIn[x].Data.HandleSt, @StreamIn[x].Data.Buffer[0],
 StreamIn[x].Data.wantframes, StreamIn[x].Data.outframes);

 if  StreamIn[x].Data.outframes < 0 then  StreamIn[x].Data.outframes := 0 ;

 setlength(StreamIn[x].data.Buffer,StreamIn[x].Data.outframes div
 (StreamIn[x].Data.channels) );

 {$IF DEFINED(debug) and DEFINED(unix)}
 st := '';
 for i := 0 to length(StreamIn[x].data.Buffer) -1 do
 case StreamIn[x].Data.SampleFormat of
 0: st := st + '|' + floattostr(StreamIn[x].data.Buffer[i]);
 1: st := st + '|' + inttostr(cint32(StreamIn[x].data.Buffer[i]));
 2: st := st + '|' + inttostr(cint16(cint32(StreamIn[x].data.Buffer[i])));
 end;
 WriteLn('OUTPUT DATA mpg123_read_() ---------------------------');
// WriteLn(st);
 {$endif}

 StreamIn[x].Data.outframes :=
 StreamIn[x].Data.outframes div StreamIn[x].Data.Channels;
 end;
 {$endif}

 {$IF DEFINED(neaac)}
 2 :
 begin
 StreamIn[x].AACI.lwDataLen:= 0;
 Case StreamIn[x].AACI.outputFormat of
 FAAD_FMT_16BIT, FAAD_FMT_32BIT, FAAD_FMT_FLOAT :
 begin
 outBytes := StreamIn[x].Data.Wantframes;
 MP4GetData(StreamIn[x].AACI, StreamIn[x].AACI.pData, outBytes);
 Move(StreamIn[x].AACI.pData^, StreamIn[x].Data.Buffer[0], outBytes);
 StreamIn[x].AACI.lwDataLen:= outBytes;
 end;
 End;
 if StreamIn[x].AACI.lwDataLen > (StreamIn[x].AACI.BitsPerSample div 8) then
 StreamIn[x].Data.outframes := trunc(StreamIn[x].AACI.lwDataLen div (StreamIn[x].AACI.BitsPerSample div 8))
 else
 StreamIn[x].Data.outframes := 0;

 if  StreamIn[x].Data.outframes < 0 then  StreamIn[x].Data.outframes := 0 ;
//  setlength(StreamIn[x].data.Buffer,StreamIn[x].Data.outframes * StreamIn[x].Data.channels );

 {$IF DEFINED(debug) and DEFINED(unix)}
 st := '';
 for i := 0 to length(StreamIn[x].data.Buffer) -1 do
 case StreamIn[x].Data.SampleFormat of
 0: st := st + '|' + floattostr(StreamIn[x].data.Buffer[i]);
 1: st := st + '|' + inttostr(cint32(StreamIn[x].data.Buffer[i]));
 2: st := st + '|' + inttostr(cint16(cint32(StreamIn[x].data.Buffer[i])));
 end;
 WriteLn('OUTPUT DATA MP4GetData() ---------------------------');
// WriteLn(st);
 {$endif}

 end;
 {$endif}

 {$IF DEFINED(cdrom)}
 3:
 Begin
 StreamIn[x].pCD^.pDataLen:= 0;
 Case StreamIn[x].pCD^.BitsPerSample of
 16 : begin
 outBytes  := StreamIn[x].Data.Wantframes;
 CDROM_GetData(StreamIn[x].pCD, StreamIn[x].pCD^.pData, outBytes);
 Move(StreamIn[x].pCD^.pData^, StreamIn[x].Data.Buffer[0], outBytes);
 StreamIn[x].pCD^.pDataLen:= outBytes;
 end;
 End;

 if StreamIn[x].pCD^.pDataLen > (StreamIn[x].pCD^.BitsPerSample div 8) then
 StreamIn[x].Data.outframes := StreamIn[x].pCD^.pDataLen div (StreamIn[x].pCD^.BitsPerSample div 8)
 else
 StreamIn[x].Data.outframes := 0;

 end;
 {$endif}

 {$IF DEFINED(opus)}
 4: begin

 case StreamIn[x].Data.SampleFormat of
 0: StreamIn[x].Data.outframes := op_read_float(StreamIn[x].Data.HandleOP,
 @StreamIn[x].Data.Buffer[0], cint(StreamIn[x].Data.Wantframes div StreamIn[x].Data.channels), nil);
 1: begin
 StreamIn[x].Data.outframes := op_read_float(StreamIn[x].Data.HandleOP,
 @StreamIn[x].Data.Buffer[0],cint(StreamIn[x].Data.Wantframes  div StreamIn[x].Data.channels), nil);

// no int32 format with opus => needs a conversion from float32 to int32.
 StreamIn[x].Data.Buffer := Cvfloat32ToInt32fl( StreamIn[x].Data.Buffer,
 StreamIn[x].Data.outframes * StreamIn[x].Data.Channels );
 end;
 2: begin
 StreamIn[x].Data.outframes := op_read(StreamIn[x].Data.HandleOP,
 @StreamIn[x].Data.Buffer[0], cint(StreamIn[x].Data.Wantframes), nil);
 end;

 end;

 setlength(StreamIn[x].data.Buffer,int32(StreamIn[x].Data.outframes * StreamIn[x].Data.Channels));

 {$IF DEFINED(debug) and DEFINED(unix)}
 st := '';
 for i := 0 to length(StreamIn[x].data.Buffer) -1 do
 case StreamIn[x].Data.SampleFormat of
 0: st := st + '|' + floattostr(StreamIn[x].data.Buffer[i]);
 1: st := st + '|' + inttostr(cint32(StreamIn[x].data.Buffer[i]));
 2: st := st + '|' + inttostr(cint16(cint32(StreamIn[x].data.Buffer[i])));
 end;
 WriteLn('OUTPUT DATA op_read_ ---------------------------');
// WriteLn(st);
 {$endif}

 if  StreamIn[x].Data.outframes < 0 then  StreamIn[x].Data.outframes := 0 ;

 StreamIn[x].Data.outframes :=  StreamIn[x].Data.outframes * StreamIn[x].Data.Channels ;

 end;
 {$endif}

 99:// if nothing was defined
 end;

 SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.outframes);
end;

Procedure Tuos_Player.CheckIfPaused ;
begin
   if isGlobalPause = true then
  begin
  RTLeventWaitFor(uosInit.evGlobalPause);
  RTLeventSetEvent(uosInit.evGlobalPause);
  end
   else
  begin
  RTLeventWaitFor(evPause);// is there a pause waiting ?
  RTLeventSetEvent(evPause);
  end;
end;

{$IF DEFINED(mse)}
function Tuos_Player.execute(thread: tmsethread): integer;
// The Main Loop Procedure
  {$else}
 procedure TuosThread.Execute;
// The Main Loop Procedure
  {$endif}
var
  x, x2, x3 : cint32;
  plugenabled: boolean;
  curpos: cint64 = 0;
  {$IF DEFINED(debug) and DEFINED(unix)}
  st : string;
  i : integer;
   {$endif}
  
begin

theinc := 0;


{$IF DEFINED(mse)}
 {$else}
with  Tuos_Player(theparent) do
begin
 {$endif}
 
   CheckIfPaused ;// is there a pause waiting ?

  DoBeginMethods();
   
  CheckIfPaused ;// is there a pause waiting ?

 repeat

  if uosisactif then DoLoopBeginMethods else nofree := false;
 
   CheckIfPaused ;// is there a pause waiting ?
// Dealing with input
  for x := 0 to high(StreamIn) do
  begin
 
  if (StreamIn[x].data.hasfilters) and uosisactif then
  begin
  setlength(StreamIn[x].Data.levelfiltersar,StreamIn[x].Data.nbfilters * StreamIn[x].Data.channels );
  StreamIn[x].Data.incfilters := 0;
  end;
   
  {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('Before for x := 0 to high(StreamIn)');
  {$endif}

  CheckIfPaused ;// is there a pause waiting ?
  
    if (StreamIn[x].Data.Status > 0) and
  (StreamIn[x].Data.Enabled = True) then
  begin
  
  StreamIn[x].Data.levelfilters := '';
  
  {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('Before StreamIn[x].Data.Seekable = True');
  {$endif}
  if (StreamIn[x].Data.Poseek > -1) and (StreamIn[x].Data.Seekable = True) and uosisactif then
  begin// there is a seek waiting

  DoSeek(x);

  curpos := StreamIn[x].Data.Poseek;
  StreamIn[x].Data.Poseek := -1;
  end;

  if (StreamIn[x].Data.positionEnable = 1)  and (StreamIn[x].Data.Seekable = True) then
  StreamIn[x].Data.position := curpos;

 {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('DSPin BeforeBufProc 1');
 {$endif}
  if (StreamIn[x].Data.Status = 1) and (length(StreamIn[x].DSP) > 0) then
  DoDSPinBeforeBufProc(x);// Procedure in DSP to execute before fill buffer.
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('DSPin BeforeBufProc 2');
  {$endif}   

 if uosisactif then
  begin
  CheckIfPaused ;// is there a pause waiting ?
  case StreamIn[x].Data.TypePut of
 
  0:// It is a input from audio file.
  ReadFile(x);

  {$IF DEFINED(portaudio)}
  1:// for Input from device
  ReadDevice(x);
  {$endif}
  
  {$IF DEFINED(webstream)}
  2:// for Input from Internet audio stream.
  ReadUrl(x);
  {$ENDIF}
  
  {$IF DEFINED(synthesizer)}
  3:// for Input from Synthesizer
  ReadSynth(x);
  {$endif}
  
  4:// for Input from memory
  ReadMem(x);
  
  5:// for Input from endless muted
  ReadEndless(x);
  
  6:// for Input from decoded memory-stream
  ReadMemDec(x);

  end;//case StreamIn[x].Data.TypePut of
  
  end else StreamIn[x].Data.OutFrames := 0;
  
  if StreamIn[x].Data.OutFrames = 0 then StreamIn[x].Data.status := 0;

  if (StreamIn[x].Data.Seekable = True) then if StreamIn[x].Data.OutFrames < 100 then
  StreamIn[x].Data.status := 0;// no more data then close the stream
  
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('StreamIn[x].Data.status = ' + inttostr(StreamIn[x].Data.status));
 {$endif}  

  if  StreamIn[x].Data.status > 0 then// still working
  begin
  
  if (StreamIn[x].Data.positionEnable = 1) then
  begin
  if (StreamIn[x].Data.LibOpen = 1) and (StreamIn[x].Data.SampleFormat < 2) then

  curpos := curpos + (StreamIn[x].Data.OutFrames div
  (StreamIn[x].Data.Channels * 2))
// strange outframes float 32 with Mpg123 ?
  else
  curpos := curpos + (StreamIn[x].Data.OutFrames div
  (StreamIn[x].Data.Channels));

  StreamIn[x].Data.position := curpos;// new position
  end;

 {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('Getting the level before DSP procedure');
 {$endif}
 
  if (StreamIn[x].Data.levelEnable = 1) or (StreamIn[x].Data.levelEnable = 3) then StreamIn[x].Data := DSPLevel(StreamIn[x].Data);

// Adding level in array-level// ideal for pre-wave form
  if (StreamIn[x].Data.levelArrayEnable = 1) then
  begin
  if (StreamIn[x].Data.levelEnable = 0) or (StreamIn[x].Data.levelEnable = 3) then
  StreamIn[x].Data := DSPLevel(StreamIn[x].Data);
  DoArrayLevel(x);
  end;
  
 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('DSPin AfterBuffProcBefore');
 {$endif}

  if (StreamIn[x].Data.Status = 1) and (length(StreamIn[x].DSP) > 0) then
   DoDSPinAfterBufProc(x) ;
 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('DSPin AfterBuffProcAfter');
 {$endif}

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('The synchro main loop procedurebefore');
 {$endif}
 DoMainLoopProc(x);

  {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Getting the level after DSP procedure');
 {$endif}

// Getting the level after DSP procedure
  if ((StreamIn[x].Data.levelEnable = 2) or (StreamIn[x].Data.levelEnable = 3)) then StreamIn[x].Data := DSPLevel(StreamIn[x].Data);

// Adding level in array-level
  if (StreamIn[x].Data.levelArrayEnable = 2) then
  begin
  if (StreamIn[x].Data.levelEnable = 0) or (StreamIn[x].Data.levelEnable = 1) then
  StreamIn[x].Data := DSPLevel(StreamIn[x].Data);
  DoArrayLevel(x);
  end;

  {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('End level after DSP procedure');
 {$endif}
 
  end;//if  StreamIn[x].Data.status > 0 then

  end;//if (StreamIn[x].Data.Status > 0) and (StreamIn[x].Data.Enabled = True) then

  end;// end for low(StreamIn[x]) to high(StreamIn[x])

// Seeking if StreamIn is terminated
 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Seeking if StreamIn is terminated');
 {$endif}

 if status <> 0 then SeekIfTerminated;

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('status = ' +inttostr(status));
 {$endif}
 
  CheckIfPaused ;// is there a pause waiting ?
  
// Give Buffer to Output
  if status = 1 then
  begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('Give Buffer to Output');
  {$endif}
 
  if uosisactif then for x := 0 to high(StreamOut) do

  if (StreamOut[x].Data.Enabled = True)
  then
  begin
  
   if StreamOut[x].data.hasfilters then
  begin
  setlength(StreamOut[x].Data.levelfiltersar,StreamOut[x].Data.nbfilters * StreamOut[x].Data.channels );
  StreamOut[x].Data.incfilters := 0;
  end;

  for x2 := 0 to high(StreamOut[x].Data.Buffer) do
  StreamOut[x].Data.Buffer[x2] := cfloat(0.0);// clear output
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('Buffer[x2] := cfloat(0.0)');
  {$endif}
  for x2 := 0 to high(StreamIn) do
  if  (StreamIn[x2].Data.status > 0)  and
  (StreamIn[x2].Data.Enabled = True) 
   and  ((StreamIn[x2].Data.Output = x) or (StreamIn[x2].Data.Output = -1))
  then
  begin
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('length(StreamIn[x2].Data.Buffer) = ' +inttostr(length(StreamIn[x2].Data.Buffer)));
  writeln('length(StreamOut[x].Data.Buffer) = ' +inttostr(length(StreamOut[x].Data.Buffer)));
  writeln('for x3 := 0 to high(StreamIn[x2].Data.Buffer) do');
  writeln('high(StreamIn[x2].Data.Buffer) = '+ inttostr(high(StreamIn[x2].Data.Buffer)));
  {$endif}
 
  for x3 := 0 to high(StreamIn[x2].Data.Buffer) do
  begin
  if x3 < high(StreamOut[x].Data.Buffer) + 1 then
  StreamOut[x].Data.Buffer[x3] :=
  cfloat(StreamOut[x].Data.Buffer[x3]) +
  cfloat(StreamIn[x2].Data.Buffer[x3]);
 
  end;
  
   {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('StreamOut[x].Data.Buffer ------------------------------');
   st := '';
   for i := 0 to length(StreamOut[0].Data.Buffer) -1 do
   st := st + '|' + inttostr(i) + '=' + floattostr(Streamout[0].Data.Buffer[i]); 
// WriteLn(st); 
    writeln('for x3 := 0 to high(StreamIn[x2].Data.Buffer) done');
   {$endif}
   
  case StreamIn[x2].Data.LibOpen of
  0:  StreamOut[x].Data.outframes := StreamIn[x2].Data.outframes ;// sndfile
  1:  StreamOut[x].Data.outframes := StreamIn[x2].Data.outframes div StreamIn[x2].Data.Channels;// mpg123
  2:  StreamOut[x].Data.outframes := StreamIn[x2].Data.outframes ;// aac
  3:  StreamOut[x].Data.outframes := StreamIn[x2].Data.outframes ;// CDRom
  4:  StreamOut[x].Data.outframes := StreamIn[x2].Data.outframes ;// opus
  end;  
  
  end;  
  
// copy buffer-in into buffer-out
  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln('copy buffer-in into buffer-out');
  {$endif}
 
// DSPOut AfterBuffProc
  if (length(StreamOut[x].DSP) > 0) and uosisactif then

  DoDSPOutAfterBufProc(x) ;

// apply plugin (ex: SoundTouch Library)
  plugenabled := False;

  {$IF DEFINED(debug) and DEFINED(unix)}
  writeln(' if (length(Plugin) > 0) then');
  {$endif}

  if (length(Plugin) > 0) then
  begin
  for x3 := 0 to high(PlugIn) do
  if Plugin[x3].Enabled = True then
  plugenabled := True;
  end;
//
 
 if uosisactif then begin
  if plugenabled = True then
  WriteOutPlug(x, x2)
  else// No plugin
  WriteOut(x, x2);
  end;
  
  end;
  end;
 
   {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('Before LoopEndProc ------------------------------');
  {$endif}

 if uosisactif then DoLoopEndMethods;

  if length(StreamIn) > 1 then// clear buffer for multi-input
  for x2 := 0 to high(StreamIn) do
  for x3 := 0 to high(StreamIn[x2].Data.Buffer) do
  StreamIn[x2].Data.Buffer[x3] := cfloat(0.0);
  
   {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('Before if (nofree = true) and (status = 0)-----');
  {$endif}

  if (nofree = true) and (status = 0)  then

  DoTerminateNoFreePlayer ;

    {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('Before until status = 0;----');
  {$endif}

 until status = 0;

// End of Loop ---
  
  {$IF DEFINED(debug) and DEFINED(unix)}
   WriteLn('Before Terminate Thread---');
  {$endif}

// Terminate Thread
  if status = 0 then
  begin

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('Status = 0');
 {$endif}

  DoTerminatePlayer;

 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('EndProc---');
 {$endif}

 if uosisactif then  DoEndProc;

if uosisactif then if EndProcOnly <> nil then EndProcOnly;
         
  isAssigned := false ;
  
  {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('EndProc All');
 {$endif}
  end;
  
 {$IF DEFINED(debug) and DEFINED(unix)}
 writeln('This is the end...');
 {$endif}  
 
 {$IF DEFINED(mse)} 

  {$else}
// FreeOnTerminate:=True;
// terminate();
  end;
 {$endif}
end;

procedure Tuos_Init.unloadPlugin(PluginName: Pchar);
// Unload Plugin... 
begin
  
 {$IF DEFINED(soundtouch)}
 if lowercase(PluginName) = 'soundtouch' then  st_Unload();
 {$endif}
  {$IF DEFINED(bs2b)}
 if lowercase(PluginName) = 'bs2b' then bs_Unload();
 {$endif}

end;

procedure Tuos_Init.unloadlib;
begin
  {$IF DEFINED(sndfile)}
  Sf_Unload();
  {$endif}
  {$IF DEFINED(mpg123)}
  Mp_Unload();
  {$endif}
  {$IF DEFINED(portaudio)}
  Pa_Unload();
  {$endif}
  {$IF DEFINED(neaac)}
  Aa_Unload;
  {$endif}
  {$IF DEFINED(opus)}
//op_Unload;
  of_Unload;
  {$endif}
  {$IF DEFINED(windows)}
  Set8087CW(old8087cw);
  {$endif}
end;

function Tuos_Init.InitLib(): cint32;
begin
  Result := -1;
  {$IF DEFINED(mpg123)}
  if (uosLoadResult.MPloadERROR = 0) then
  if mpg123_init() = MPG123_OK then
  begin
  mpversion := UTF8Decode(mpg123_decoders()^);
  uosLoadResult.MPinitError := 0;
  Result := 0;
  end
  else
  begin
  Result := -2;
  uosLoadResult.MPinitError := 1;
  end;
  {$endif}

  {$IF DEFINED(portaudio)}
  if (uosLoadResult.PAloadERROR = 0) then
  begin
  uosLoadResult.PAinitError := Pa_Initialize();
  paversion := UTF8Decode(Pa_GetVersionText());
  if uosLoadResult.PAinitError = 0 then
  begin
  Result := 0;
  DefDevInInfo := nil ;
  DefDevOutInfo := nil ;

  DefDevOut := Pa_GetDefaultOutputDevice();
  if DefDevOut >= 0  then
  DefDevOutInfo := Pa_GetDeviceInfo(DefDevOut);
  if DefDevOutInfo <> nil then
  DefDevOutAPIInfo := Pa_GetHostApiInfo(DefDevOutInfo^.hostApi);

  DefDevIn := Pa_GetDefaultInputDevice();
   if DefDevIn >= 0  then
  DefDevInInfo := Pa_GetDeviceInfo(DefDevIn);
   if DefDevInInfo <> nil then
  DefDevInAPIInfo := Pa_GetHostApiInfo(DefDevInInfo^.hostApi);
  end;

  end;
  {$endif}
    
   {$IF DEFINED(sndfile)}
  if (uosLoadResult.SFloadERROR = 0) then sfversion := UTF8Decode(sf_version_string());
   {$endif}
   
   if (Result = -1) and (uosLoadResult.SFloadERROR = 0) then
  begin
  Result := 0;
  end;
  
end;

function Tuos_Init.loadlib(): cint32;
begin
  Result := -1;
  uosLoadResult.PAloadERROR := -1;
  uosLoadResult.SFloadERROR := -1;
  uosLoadResult.MPloadERROR := -1;
  uosLoadResult.AAloadError := -1;
  uosLoadResult.OPloadERROR := -1;
  uosLoadResult.STloadERROR := -1;
  uosLoadResult.BSloadERROR := -1;
  
  {$IF DEFINED(portaudio)}
  if (PA_FileName <>  nil) and (PA_FileName <>  '') then
  begin
  if PA_FileName =  'system' then PA_FileName :=  '' ;
  if Pa_Load(PA_FileName) then
  begin
     //  {
  Result := 0;
  uosLoadResult.PAloadERROR := 0;
  uosDefaultDeviceOut := Pa_GetDefaultOutPutDevice();
  uosDefaultDeviceIn := Pa_GetDefaultInPutDevice();
  uosDeviceCount := Pa_GetDeviceCount();
// }
  end
  else
  uosLoadResult.PAloadERROR := 2;
  end
  else
  uosLoadResult.PAloadERROR := -1;
  {$endif}

  {$IF DEFINED(sndfile)}
  if (SF_FileName <> nil) and (SF_FileName <>  '') then
  begin
  if Sf_FileName =  'system' then sf_FileName :=  '' ;
  if Sf_Load(SF_FileName) then
  begin
  uosLoadResult.SFloadERROR := 0;
  if uosLoadResult.PAloadERROR = -1 then
  Result := 0;
  end
  else
  begin
  uosLoadResult.SFloadERROR := 2;
  Result := -1;
  end;
  end
  else
  uosLoadResult.SFloadERROR := -1;
  {$endif}
  
  {$IF DEFINED(mpg123)}
  if (MP_FileName <> nil) and (MP_FileName <>  '') then
  begin
  if mp_FileName =  'system' then mp_FileName :=  '' ;
  if mp_Load(Mp_FileName) then
  begin
  uosLoadResult.MPloadERROR := 0;
  if (uosLoadResult.PAloadERROR = -1) and (uosLoadResult.SFloadERROR = -1) then
  Result := 0;
  end
  else
  begin
  uosLoadResult.MPloadERROR := 2;
  Result := -1;
  end;
  end
  else
  uosLoadResult.MPloadERROR := -1;
  {$endif}

  {$IF DEFINED(neaac)}
  if (AA_FileName <> nil) and (AA_FileName <>  '') and (M4_FileName <> nil) and (M4_FileName <>  '') then
  begin
  if m4_FileName =  'system' then m4_FileName :=  '' ;
  if aa_FileName =  'system' then aa_FileName :=  '' ;
  
  if aa_load(UTF8String(M4_FileName), UTF8String(AA_FileName)) then
  begin
  uosLoadResult.AAloadERROR := 0;
  if (uosLoadResult.MPloadERROR = -1) and (uosLoadResult.PAloadERROR = -1) and
  (uosLoadResult.SFloadERROR = -1)  then
  Result := 0;
  end
  else
  begin
  uosLoadResult.AAloadERROR := 2;
  Result := -1;
  end;
  end
  else
  uosLoadResult.AAloadERROR := -1;
  {$endif}
  
  {$IF DEFINED(opus)}
  if (OF_FileName <> nil) and (OF_FileName <>  '') then
  begin
  if of_FileName =  'system' then of_FileName :=  '' ;
  if (of_load(UTF8String(OF_FileName)))  then
  begin
  uosLoadResult.OPloadERROR := 0;
  if (uosLoadResult.MPloadERROR = -1) and (uosLoadResult.PAloadERROR = -1) and
  (uosLoadResult.SFloadERROR = -1) And (uosLoadResult.AAloadERROR = -1)
  then
  Result := 0;
  end
  else
  begin
  uosLoadResult.OPloadERROR := 2;
  Result := -1;
  end;
  end
  else
  uosLoadResult.OPloadERROR := -1;
  {$endif}
  
   if Result = 0 then  Result := InitLib();
end;


function uos_loadPlugin(PluginName, PluginFilename: PChar) : cint32;
  begin
 Result := -1; 
  {$IF DEFINED(soundtouch)}
  if ((lowercase(PluginName) = 'soundtouch') or (lowercase(PluginName) = 'getbpm')) and (PluginFileName <> nil) and (PluginFileName <>  '')  then
  begin
  if PluginFileName =  'system' then PluginFileName :=  '' ;
  if ST_Load(PluginFileName) then
  begin
  Result := 0;
  uosLoadResult.STloadERROR := 0;
  uosInit.Plug_ST_FileName := PluginFileName;
  end
  else
  begin
  uosLoadResult.STloadERROR := 2;
  Result := -1;
  end;
  end;
  
  {$endif}
  
  {$IF DEFINED(bs2b)}
  if (lowercase(PluginName) = 'bs2b') and (PluginFileName <> nil) and (PluginFileName <>  '') then
  begin
  if PluginFileName =  'system' then PluginFileName :=  '' ;
  if BS_Load(PluginFileName) then
  begin
  Result := 0;
  uosLoadResult.BSloadERROR := 0;
  uosInit.Plug_BS_FileName := PluginFileName;
  end
  else
  begin
  uosLoadResult.BSloadERROR := 2;
  Result := -1;
  end;
  end;
  {$endif}
  end;


{$IF DEFINED(shout)}
function uos_LoadServerLib(ShoutFileName, OpusFileName : PChar) : cint32; 
// Shout => needed for dealing with IceCast server
// Opus => needed for dealing with encoding opus stream
begin
Result := -1;
 if not fileexists(ShoutFileName) then
  else
  if sh_Load(UTF8String(ShoutFileName)) then
  Result := 0;
  
  if result = 0 then
  if not fileexists(OpusFileName) then
  Result := -2  else
  if op_Load(UTF8String(OpusFileName)) then
  Result := 0 else Result := -1 ;
 end;
  
procedure uos_unloadServerLib();
// Unload server libraries... Do not forget to call it before close application...
 begin
shout_shutdown;
sh_unload;
op_unload;
 end;  
{$endif}
 
function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfileFileName: PChar) : cint32;
  begin
  result := -1 ;
  if not assigned(uosInit) then begin

  {$IF DEFINED(windows)}
  old8087cw := Get8087CW;
  Set8087CW($133f);
  {$endif}

  uosInit := TUOS_Init.Create;// Create Libraries Loader-Init
  end;
  
  uosInit.PA_FileName := PortAudioFileName;
  uosInit.SF_FileName := SndFileFileName;
  uosInit.MP_FileName := Mpg123FileName;
  uosInit.AA_FileName:= FaadFileName;
  uosInit.M4_FileName:= Mp4ffFileName;
  uosInit.OF_FileName:= opusfileFileName;
  
  result := uosInit.loadlib ;
  end;
  
function uos_GetVersion() : cint32 ;
begin
result := uos_version ;
end;

function Tuos_Player.SetGlobalEvent(isenabled : boolean) : boolean;
// Set the RTL Events Global (will pause/start/replay all the players synchro with same rtl event)) 
// result : true if set ok.
begin
result := false;
 if (isAssigned = True) then
  begin
  isGlobalPause := isenabled;
  result := true;
  end;
end;   

procedure uos_unloadlib() ;
begin
 if assigned(uosInit) then
  begin
 uosInit.unloadlib ;
 end;
end;

procedure uos_unloadlibCust(PortAudio, SndFile, Mpg123, AAC, opus: boolean);
// Custom Unload libraries... if true, then unload the library. You may unload what and when you want...
begin
 uosInit.unloadlibcust(PortAudio, SndFile, Mpg123, AAC, opus) ;
end;

procedure uos_UnloadPlugin(PluginName: PChar);
// load plugin...
begin
 uosInit.unloadplugin(PluginName);
end;

function uos_GetInfoLibraries() : PansiChar ;
begin
 result := pchar(paversion  + ' | Sndfile: ' + sfversion  + ' | Mpg123: ' + mpversion);
end; 

{$IF DEFINED(portaudio)}
procedure uos_GetInfoDevice();
var
  x: cint32;
  devinf: PPaDeviceInfo;
  apiinf: PPaHostApiInfo;
begin
   x := 0;
  uosDeviceCount := 0;
   SetLength(uosDeviceInfos, 0);

    if Pa_GetDeviceCount() > 0 then
    begin
   uosDeviceCount := Pa_GetDeviceCount();

  SetLength(uosDeviceInfos, uosDeviceCount);
  uosDefaultDeviceOut := Pa_GetDefaultOutPutDevice();
  uosDefaultDeviceIn := Pa_GetDefaultInPutDevice();

  while x < uosDeviceCount  do
  begin
  uosDeviceInfos[x].DeviceNum := x;

  devinf := Pa_GetDeviceInfo(x);
  apiinf := Pa_GetHostApiInfo(devinf^.hostApi);

  uosDeviceInfos[x].DeviceName := UTF8Decode(devinf^._name);
  uosDeviceInfos[x].HostAPIName := UTF8Decode(apiinf^._name);

  if x = uosDefaultDeviceIn then
  uosDeviceInfos[x].DefaultDevIn := True
  else
  uosDeviceInfos[x].DefaultDevIn := False;

  if x = uosDefaultDeviceOut then
  uosDeviceInfos[x].DefaultDevOut := True
  else
  uosDeviceInfos[x].DefaultDevOut := False;

  uosDeviceInfos[x].ChannelsIn := devinf^.maxInputChannels;
  uosDeviceInfos[x].ChannelsOut := devinf^.maxOutPutChannels;
  uosDeviceInfos[x].SampleRate := devinf^.defaultSampleRate;
  uosDeviceInfos[x].LatencyHighIn := devinf^.defaultHighInputLatency;
  uosDeviceInfos[x].LatencyLowIn := devinf^.defaultLowInputLatency;
  uosDeviceInfos[x].LatencyHighOut := devinf^.defaultHighOutputLatency;
  uosDeviceInfos[x].LatencyLowOut := devinf^.defaultLowOutputLatency;

  if uosDeviceInfos[x].ChannelsIn = 0 then
  begin
  if uosDeviceInfos[x].ChannelsOut = 0 then
  uosDeviceInfos[x].DeviceType:= 'None' else  uosDeviceInfos[x].DeviceType:= 'Out' ;
  end  else
  begin
  if uosDeviceInfos[x].ChannelsOut = 0 then
  uosDeviceInfos[x].DeviceType:= 'In' else  uosDeviceInfos[x].DeviceType:= 'In/Out' ;
  end ;
  Inc(x);
  end;
 end;
end;

function uos_GetInfoDeviceStr() : PansiChar ;
var
  x : cint32 ;
devtmp , bool1, bool2 : UTF8String;
begin

  uos_GetInfoDevice() ;

  x := 0;
  devtmp := '';

  while  x < length(uosDeviceInfos) do
 begin
 if uosDeviceInfos[x].DefaultDevIn then bool1 := 'Yes' else bool1 := 'No';
 if uosDeviceInfos[x].DefaultDevOut then bool2 := 'Yes' else bool2 := 'No';

 devtmp := devtmp +

 'DeviceNum: ' + inttostr(uosDeviceInfos[x].DeviceNum) + ' |' +
 ' Name: ' + uosDeviceInfos[x].DeviceName +  ' |' +
 ' Type: ' + uosDeviceInfos[x].DeviceType + ' |' +
 ' DefIn: ' + bool1 + ' |' +
 ' DefOut: ' + bool2 + ' |' +
 ' ChanIn: ' +  IntToStr(uosDeviceInfos[x ].ChannelsIn)+ ' |' +
 ' ChanOut: ' +  IntToStr(uosDeviceInfos[x].ChannelsOut) + ' |' +
 ' SampleRate: ' +  floattostrf(uosDeviceInfos[x].SampleRate, ffFixed, 15, 0) + ' |' +
 ' LatencyHighIn: ' + floattostrf(uosDeviceInfos[x].LatencyHighIn, ffFixed, 15, 8) + ' |' +
 ' LatencyHighOut: ' + floattostrf(uosDeviceInfos[x].LatencyHighOut, ffFixed, 15, 8)+ ' |' +
 ' LatencyLowIn: ' + floattostrf(uosDeviceInfos[x].LatencyLowIn, ffFixed, 15, 8)+ ' |' +
 ' LatencyLowOut: ' + floattostrf(uosDeviceInfos[x].LatencyLowOut, ffFixed, 15, 8)+ ' |' +
 ' HostAPI: ' + uosDeviceInfos[x].HostAPIName ;
 if x < length(uosDeviceInfos)-1 then  devtmp := devtmp +  #13#10 ;
 Inc(x);
 end;
result :=  pansichar( devtmp + ' ' );

// }
end;
{$endif}

{$IF DEFINED(Java)}
procedure Tuos_Player.beginprocjava();
begin
(PEnv^^).CallVoidMethod(PEnv,Obj,BeginProc)  ;
end;

procedure Tuos_Player.endprocjava();
begin
(PEnv^^).CallVoidMethod(PEnv,Obj,EndProc)  ;
end;

procedure Tuos_Player.LoopBeginProcjava();
begin
(PEnv^^).CallVoidMethod(PEnv,Obj,LoopBeginProc)  ;
end;

procedure Tuos_Player.LoopEndProcjava();
begin
(PEnv^^).CallVoidMethod(PEnv,Obj,LoopEndProc)  ;
end;

procedure Tuos_DSP.LoopProcjava();
begin
// todo
end;

procedure Tuos_InStream.LoopProcjava();
begin
// todo
end;

procedure Tuos_OutStream.LoopProcjava();
begin
// todo
end;

{$endif}

{$IF DEFINED(webstream)}
procedure Tuos_InStream.UpdateIcyMetaInterval; 
begin 
  if Data.HandleSt<>nil then 
    mpg123_param(Data.HandleSt, MPG123_ICY_INTERVAL, httpget.IcyMetaInt, 0); 
end;
{$endif}

function AssignDefaultForUOSData: Tuos_Data;
var
  i: Integer;
begin
 with Result do
 begin
  Enabled:= False;
  TypePut:= -1;//nothing
  Seekable:= False;
  Status:= 0;// no data

  
  SetLength(Buffer,0);
  SetLength(MemoryBuffer,0);
  MemoryStream:= nil;
  posmem:= 0;

  {$IF DEFINED(opus)}
  SetLength(BufferTMP,0);
  {$endif}

  DSPVolumeIndex:= -1;
  DSPNoiseIndex:= -1;
  VLeft:= 0;
  
  VRight:= 0;
  
  hasfilters := false;
  
  nbfilters := 0;
  
  incfilters := 0;
  
  PositionEnable:= 0;
  LevelEnable:= 0;
  LevelLeft:= 0;
  LevelRight:= 0;
  levelArrayEnable:= 0;

//----------------------------//
  SampleRate:= 44100;
  freqsine:= 440;
  lensine:= SampleRate / freqsine *2;
  dursine:= SampleRate;
  posdursine:= 0;
  posLsine:= 0;
  posRsine:= 0;
  SamplerateRoot:= SampleRate;
//----------------------------//

  Wantframes:= 0;
  OutFrames:= 0;

  SampleFormat:= -1;// default
  Channels:= -1;// default

  HandleSt:= nil;
  {$IF DEFINED(opus)}
  HandleOP:= nil;
  {$endif}

  Filename:= '';
  Title:= '';
  Copyright:= '';
  Software:= '';
  Artist:= '';
  Comment:= '';
  Date:= '';
  for i:= 0 to High(Tag) do
   Tag[i]:= #0;
  Album:= '';
  Genre:= 0;
  HDFormat:= 0;
  Frames:= 0;
  Sections:= 0;
  Encoding:= -1;// unknow
  bitrate:= -1;// unknow
  Length:= 0;
  LibOpen:= -1;// nothing open
  Ratio:= 0;

  BPM:= 0;

  numbuf:= -1;//default

  Output:= -1;//error

  Position:= 0;
  Poseek:= 0;
 end;
end;   

constructor Tuos_FFT.Create;
var
  i: Integer;
begin
  inherited;

  TypeFilter:= 0;
  LowFrequency:= 0;
  HighFrequency:= 0;
  AlsoBuf:= False;

  for i:= 0 to High(a3) do
    a3[i]:= 0;
  for i:= 0 to High(a32) do
    a32[i]:= 0;

  for i:= 0 to High(TArray01) do
  begin
    b2[i]:= 0;
    x0[i]:= 0;
    x1[i]:= 0;
    y0[i]:= 0;
    y1[i]:= 0;
    b22[i]:= 0;
    x02[i]:= 0;
    x12[i]:= 0;
    y02[i]:= 0;
    y12[i]:= 0;
  end;

  C:= 0;
  D:= 0;
  C2:= 0;
  D2:= 0;
  Gain:= 0;
  
  levelstring := '';
 
  {$IF DEFINED(noiseremoval)}
  FNoise:= nil;
  {$endif}
end;        

constructor Tuos_DSP.Create;
begin
  inherited;

  Enabled:= False;
  BefFunc:= nil;
  AftFunc:= nil;
  EndFunc:= nil;
  LoopProc:= nil;
  fftdata:= nil;
end;       

constructor Tuos_InStream.Create;
begin
  inherited;

  Data:= AssignDefaultForUOSData;
  SetLength(DSP,0);

  {$IF DEFINED(neaac)}
  AACI:= nil;
  {$endif}

  {$IF DEFINED(cdrom)}
  pCD:= nil;
  {$endif}

  {$IF DEFINED(webstream)}
    httpget:= nil;

    InHandle:= 0;
    OutHandle:= 0;   

    InPipe:= nil;
    OutPipe:= nil;
  {$ENDIF}

  {$IF DEFINED(portaudio)}
  with PAParam do
  begin
   device:= 0;
   channelCount:= 0;
   sampleFormat:= nil;
   suggestedLatency:= 0;
   hostApiSpecificStreamInfo:= nil;
  end;
  {$endif}

  LoopProc:= nil;
end;    

constructor Tuos_OutStream.Create;
{$IF DEFINED(shout)}
var
  i: integer;
{$endif}
begin
  inherited;

  Data:= AssignDefaultForUOSData;
  BufferOut:= nil;
  SetLength(DSP,0);

  {$IF DEFINED(portaudio)}
  with PAParam do
  begin
//TODO: check if the default settings are ok
   device:= 0;
   channelCount:= 0;
   sampleFormat:= nil;
   suggestedLatency:= 0;
   hostApiSpecificStreamInfo:= nil;
  end;
  {$endif}

  {$IF DEFINED(shout)}
  encoder:= nil;
  for i:= 0 to High(cbits) do
   cbits[i]:= 0;//byte
  {$endif}
  
  

  with FileBuffer do
  begin
   ERROR:= 0;
   wSamplesPerSec:= 44100;
   wBitsPerSample:= 32;
   wChannels:= 2;
   FileFormat:= -1;
   Data:= nil;
   DataMS:= nil;
  end;
  LoopProc:= nil;
  
  MemorySteamOut := nil;

  {$IF DEFINED(Java)}
//  procedure LoopProcjava;
  {$endif}
end; 

constructor Tuos_Plugin.Create;
begin
  inherited;

  Enabled:= False;
  Name:= '';

  {$IF DEFINED(windows)}
  PlugHandle:= 0;
  {$else}
  PlugHandle:= nil;
  {$endif}

  {$IF DEFINED(bs2b) or DEFINED(soundtouch)}
  Abs2b:= nil;
  PlugFunc:= nil;
  {$endif}
  param1:= -1;
  param2:= -1;
  param3:= -1;
  param4:= -1;
  param5:= -1;
  param6:= -1;
  param7:= -1;
  param8:= -1;

  SetLength(Buffer,0);
end;  

constructor Tuos_Init.Create;
begin
  {$IF DEFINED(portaudio)}
  DefDevOut:= -1;
  DefDevOutInfo:= nil;
  DefDevOutAPIInfo:= nil;
  DefDevIn:= -1;
  DefDevInInfo:= nil;
  DefDevInAPIInfo:= nil;
  {$endif} 
  
  TDummyThread.Create(false);
  evGlobalPause := RTLEventCreate;

  SetExceptionMask(GetExceptionMask + [exZeroDivide] + [exInvalidOp] +
  [exDenormalized] + [exOverflow] + [exUnderflow] + [exPrecision]);
  uosLoadResult.PAloadERROR := -1;
  uosLoadResult.PCloadERROR := -1;
  uosLoadResult.SFloadERROR := -1;
  uosLoadResult.BSloadERROR := -1;
  uosLoadResult.STloadERROR := -1;
  uosLoadResult.MPloadERROR := -1;
  uosLoadResult.AAloadERROR := -1;
  uosLoadResult.OPloadERROR := -1;
  uosLoadResult.PAinitError := -1;
  uosLoadResult.MPinitError := -1;
  
  PA_FileName := nil;// PortAudio
  SF_FileName := nil;// SndFile
  MP_FileName := nil;// Mpg123
  AA_FileName := nil;// Faad
  M4_FileName := nil;// Mp4ff
  OF_FileName := nil;// opusfile
  Plug_ST_FileName := nil;// Plugin SoundTouch
  Plug_BS_FileName := nil;// Plugin bs2b
end;

 constructor Tuos_Player.create();
begin
  evPause := RTLEventCreate;
  
  Index:= -1;//default for independent instance
   
  isAssigned := true; 
  isGlobalPause := false;
  intobuf := false;
  NLooped:= 0; 
  NoFree:= False;
  status := -1;
  BeginProc := nil;
  EndProc := nil;
  EndProcOnly := nil;
  loopBeginProc := nil;
  loopEndProc := nil;
  
  thethread:= nil;
  SetLength(StreamIn,0);
  SetLength(StreamOut,0);
  SetLength(PlugIn,0);
  
  {$IF DEFINED(Java)}
  PEnv:= nil;
  Obj:= nil;
  {$endif} 
 end;

{$IF DEFINED(mse)}
{$else}
procedure TuosThread.DoTerminate;
begin
 {$IF FPC_FULLVERSION>=20701}
//Terminate the thread the calls places into the queuelist will be removed
 RemoveQueuedEvents(Self);
 {$ENDIF}  
//notice that is no longer valid (for safe destroy event of theparent)
 Tuos_Player(theparent).thethread:= nil;
//execute player destroy
 FreeAndNil(theparent);
end;
 {$endif}

destructor Tuos_Player.Destroy;
var
  x: cint32;
begin

if thethread <> nil then begin
   {$ifdef mse}
    thethread.terminate();
   application.waitforthread(thethread);
//calls unlockall()/relockall in order to avoid possible deadlock
    thethread.destroy();
  {$endif}
    
  end;

  if assigned(evPause) then RTLeventdestroy(evPause);

  if length(StreamOut) > 0 then
  for x := 0 to high(StreamOut) do
  freeandnil(StreamOut[x]);
 
  if length(StreamIn) > 0 then
  for x := 0 to high(StreamIn) do
  freeandnil(StreamIn[x]);
 
  if length(Plugin) > 0 then
  for x := 0 to high(Plugin) do
  freeandnil(Plugin[x]);
  
//Note: if Index = -1 is a independent instance
  if Index <> -1 then
  begin
//now notice that player is really free
   uosPlayersStat[Index] := -1 ;
   uosPlayers[Index] := nil;
  end; 
 
  inherited Destroy;

end;

destructor Tuos_DSP.Destroy;
  begin
  if assigned(fftdata) then
  begin
  {$IF DEFINED(noiseremoval)}
  if assigned(fftdata.FNoise) then FreeAndNil(fftdata.FNoise);
  {$endif}
  FreeandNil(fftdata);
  end;
  
  inherited Destroy;
  end;

destructor Tuos_InStream.Destroy;
var
  x: cint32;
begin
  {$IF DEFINED(neaac)}
  if assigned(AACI) then
begin
 if assigned(AACI.fsStream) then
  begin
  freeandnil(AACI.fsStream);
  sleep(100);
  end;
  freeandnil(AACI);
  sleep(100);
end;
  {$endif}
 if assigned(Data.MemoryStream) then
   freeandnil(Data.MemoryStream);
 
  if length(DSP) > 0 then
  for x := 0 to high(DSP) do
  freeandnil(DSP[x]);
  
  inherited Destroy;
  
end;

destructor Tuos_OutStream.Destroy;
var
  x: cint32;
begin
 if length(DSP) > 0 then
  for x := 0 to high(DSP) do
  freeandnil(DSP[x]);
 
  inherited Destroy;
end;

procedure Tuos_Init.unloadlibCust(PortAudio, SndFile, Mpg123, AAc, opus: boolean);
// Custom Unload libraries... if true, then unload the library. You may unload what and when you want...
begin
  {$IF DEFINED(portaudio)}
  if PortAudio = true then  Pa_Unload();
  {$endif}
  {$IF DEFINED(sndfile)}
  if SndFile = true then  sf_Unload();
  {$endif}
  {$IF DEFINED(mpg123)}
  if Mpg123 = true then  mp_Unload();
  {$endif}
  {$IF DEFINED(neaac)}
  if AAC = True then aa_Unload();
  {$endif}
  {$IF DEFINED(opus)}
  if opus = True then
  begin
  of_Unload();
// op_Unload();
  end;
  {$endif}
end;

procedure uos_Free();
begin
 uos_unloadlib() ;

 if assigned(uosInit) then
 begin
  if assigned(uosInit.evGlobalPause) then
  RTLeventdestroy(uosInit.evGlobalPause);
  freeandnil(uosInit);
  end;
end;

initialization
  SetLength(tempoutmemory,0);
  SetLength(uosPlayers,0);
  SetLength(uosPlayersStat,0);
  SetLength(uosLevelArray,0);
  SetLength(uosDeviceInfos,0);
  uosInit:= nil;
  
end.
