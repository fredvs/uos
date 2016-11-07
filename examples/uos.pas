{This unit is part of United Openlibraries of Sound (uos)}

{  License : modified LGPL.
  Fred van Stappen fiens@hotmail.com }

unit uos;

{$mode objfpc}{$H+}

// for custom config =>  edit define.inc
{$I define.inc}

interface

uses
{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
fpg_base, fpg_main, 
{$endif}

{$IF DEFINED(Java)}
uos_jni,
{$endif}

{$IF DEFINED(webstream)}
uos_httpgetthread, Pipes,
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

{$IF DEFINED(cdrom)}
uos_cdrom,
{$endif}

Classes, ctypes, Math, sysutils;

const
  uos_version : LongInt = 16161025 ;
  
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
const // musical note ==> frequency in hertz
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
{$if not defined(fs32bit)}
  Tcount_t    = cint64;          { used for file sizes }
{$else}
  Tcount_t    = longint;
{$endif}

type
  Tuos_LoadResult = record
    PAloadError: shortint;
    SFloadError: shortint;
    MPloadError: shortint;
    STloadError: shortint;
    BSloadError: shortint;
    AAloadError: shortint;
    PAinitError: shortint;
    MPinitError: shortint;
end;

type
  Tuos_Init = class(TObject)
  public
  constructor Create;
   private

    PA_FileName: pchar; // PortAudio
    SF_FileName: pchar; // SndFile
    MP_FileName: pchar; // Mpg123
    AA_FileName : PChar; // Faad
    M4_FileName : PChar; // Mp4ff

    Plug_ST_FileName: pchar; // Plugin SoundTouch
    Plug_BS_FileName: pchar; // Plugin bs2b

{$IF DEFINED(portaudio)}
    DefDevOut: PaDeviceIndex;
    DefDevOutInfo: PPaDeviceInfo;
    DefDevOutAPIInfo: PPaHostApiInfo;
    DefDevIn: PaDeviceIndex;
    DefDevInInfo: PPaDeviceInfo;
    DefDevInAPIInfo: PPaHostApiInfo;
{$endif}

    function loadlib: LongInt;
    procedure unloadlib;
    procedure unloadlibCust(PortAudio, SndFile, Mpg123, AAC: boolean);
    function InitLib: LongInt;
    procedure unloadPlugin(PluginName: Pchar);
  end;

type
  Tuos_DeviceInfos = record
    DeviceNum: LongInt;
    DeviceName: string;
    DeviceType: string;
    DefaultDevIn: boolean;
    DefaultDevOut: boolean;
    ChannelsIn: LongInt;
    ChannelsOut: LongInt;
    SampleRate: CDouble;
    LatencyHighIn: CDouble;
    LatencyLowIn: CDouble;
    LatencyHighOut: CDouble;
    LatencyLowOut: CDouble;
    HostAPIName: string;
  end;

type
  Tuos_WaveHeaderChunk = packed record
    wFormatTag: smallint;
    wChannels: word;
    wSamplesPerSec: LongInt;
    wAvgBytesPerSec: LongInt;
    wBlockAlign: word;
    wBitsPerSample: word;
    wcbSize: word;
  end;

type
  Tuos_FileBuffer = record
    ERROR: word;
    wSamplesPerSec: LongInt;
    wBitsPerSample: word;
    wChannels: word;
    Data: TMemoryStream;
  end;

type
  Tuos_Data = record  /////////////// common data
    Enabled: boolean;
    
    TypePut: integer;
    ////// -1 : nothing,  //// for Input  : 0:from audio file, 1:from input device (like mic), 2:from internet audio stream, 3:from Synthesizer)
                          //// for Output : 0:into wav file, 1:into output device, 2:to other stream
    Seekable: boolean;
    Status: integer;
    Buffer: TDArFloat;
    
    DSPVolumeIndex : LongInt;
    
    DSPNoiseIndex : LongInt;
        
    VLeft, VRight: double;

    PositionEnable : integer;
    LevelEnable : integer;
    LevelLeft, LevelRight: cfloat;
    levelArrayEnable : integer;
    
    freqsine: cfloat;
    lensine: longint;
    posLsine, posRsine: longint;
   
{$if defined(cpu64)}
    Wantframes: Tcount_t;
    OutFrames: Tcount_t;
{$else}
    Wantframes: longint;
    OutFrames: longint;
{$endif}
    
    SamplerateRoot: longword;
    SampleRate: longword;
    SampleFormat: LongInt;
    Channels: LongInt;
    
        /////////// audio file data
    HandleSt: pointer;
    Filename: string;
    Title: string;
    Copyright: string;
    Software: string;
    Artist: string;
    Comment: string;
    Date: string;
    Tag: array[0..2] of char;
    Album: string;
    Genre: byte;
    HDFormat: LongInt;
{$IF DEFINED(sndfile)}
   Frames: Tcount_t;
{$else}
   Frames: longint;
{$endif}

    Sections: LongInt;
    Encoding: LongInt;
    Lengthst: LongInt;     ///////  in sample ;
    LibOpen: integer;    //// -1: nothing open, 0: sndfile open, 1: mpg123 open, 2: aac open, 3: cdrom
    Ratio: integer;      ////  if mpg123 or aac then ratio := 2
   
    Output: LongInt;

{$if defined(cpu64)}   /// TO CHECK
    Position: LongInt;
    Poseek:  LongInt;
{$else}
    Position: LongInt;
    Poseek:  LongInt;
{$endif}

   end;

type
  Tuos_FFT = class(TObject)
  public
    TypeFilter: integer;
    LowFrequency, HighFrequency: LongInt;
    AlsoBuf: boolean;
    a3, a32: array[0..2] of cfloat;
    b2, x0, x1, y0, y1, b22, x02, x12, y02, y12: array[0..1] of cfloat;
    C, D, C2, D2, Gain, LeftResult, RightResult: cfloat;
 
{$IF DEFINED(noiseremoval)}
    FNoise : TuosNoiseRemoval;
{$endif} 
  end;

type
  TFunc = function(Data: Tuos_Data; FFT: Tuos_FFT): TDArFloat;

   {$if DEFINED(java)}
  TProc = JMethodID ;
    {$else}
  TProc = procedure of object;
    {$endif}

    {$IF DEFINED(bs2b)}
   TPlugFunc = function(bufferin: TDArFloat; plugHandle: THandle; Abs2bd : Tt_bs2bdp; inputData: Tuos_Data;
    param1: float; param2: float; param3: float; param4: float;
    param5: float; param6: float;  param7: float; param8: float): TDArFloat;
     {$endif}

type
  Tuos_DSP = class(TObject)
  public
    Enabled: boolean;
    BefFunc: TFunc;     //// function to execute before buffer is filled
    AftFunc: TFunc;     //// function to execute after buffer is filled
    EndFunc: TFunc;     //// function to execute at end of thread;
    
    LoopProc: TProc;     //// External Procedure of object to synchronize after buffer is filled 
   
    ////////////// for FFT
    fftdata: Tuos_FFT;

    {$IF DEFINED(Java)}
    procedure LoopProcjava;
        {$endif}
 
    destructor Destroy; override;

  end;

type
  Tuos_InStream = class(TObject)
  public
    Data: Tuos_Data;
    DSP: array of Tuos_DSP;

    {$IF DEFINED(neaac)}
    AACI: TAACInfo;
    {$endif}

    {$IF DEFINED(cdrom)}
    pCD: PCDROMInfo;
    {$endif}

    //////// for web streaming
    {$IF DEFINED(webstream)}
    httpget: TThreadHttpGetter;  // threaded http getter
     {$IF DEFINED(windows)}
     {$if defined(cpu64)}
     InHandle : Qword;
     OutHandle: Qword;
     {$else}
     InHandle : longword;
     OutHandle: longword;
         {$ENDIF}
    {$else}
    InHandle : LongInt;
    OutHandle: LongInt;
      {$endif}

    InPipe: TInputPipeStream;
    OutPipe: TOutputPipeStream;
   {$ENDIF}

    {$IF DEFINED(portaudio)}
    PAParam: PaStreamParameters;
   {$endif}
 
   LoopProc: TProc;    //// external procedure of object to synchronize in loop
       {$IF DEFINED(Java)}
    procedure LoopProcjava;
        {$endif}
    destructor Destroy; override;
  end;

type
  Tuos_OutStream = class(TObject)
  public
    Data: Tuos_Data;
    DSP: array of Tuos_DSP;
   {$IF DEFINED(portaudio)}
    PAParam: PaStreamParameters;
   {$endif}
    FileBuffer: Tuos_FileBuffer;
    LoopProc: TProc;    //// external procedure of object to synchronize in loop
       {$IF DEFINED(Java)}
    procedure LoopProcjava;
        {$endif}
    destructor Destroy; override;
  end;

  Tuos_Plugin = class(TObject)
  public
    Enabled: boolean;
    Name: string;
    PlugHandle: THandle;
    {$IF DEFINED(bs2b)}
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
  end;

type
   Tuos_Player = class(TThread)
  protected
    evPause: PRTLEvent;  // for pausing
    procedure Execute; override;
    procedure onTerminate;
  public
    isAssigned: boolean ;
    Status: LongInt;
    Index: LongInt;

    NoFree : boolean;

    BeginProc: TProc;
    //// external procedure to execute at begin of thread

    LoopBeginProc: TProc;
    //// external procedure to execute at each begin of loop

    LoopEndProc: TProc;
    //// external procedure to execute at each end of loop

    EndProc: TProc;
    //// procedure to execute at end of thread

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


      {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
     Refer: TObject;  //// for fpGUI
      constructor Create(CreateSuspended: boolean; AParent: TObject;
         const StackSize: SizeUInt = DefaultStackSize);
     {$else}
      constructor Create(CreateSuspended: boolean;
          const StackSize: SizeUInt = DefaultStackSize);
      {$endif}

    destructor Destroy; override;

    /////////////////////Audio procedure
    Procedure Play() ;        ///// Start playing

    Procedure PlayNoFree() ;        ///// Start playing but do not free the player after stop

    procedure RePlay();                ///// Resume playing after pause

    procedure Stop();                  ///// Stop playing and free thread

    procedure Pause();                 ///// Pause playing

   {$IF DEFINED(portaudio)}
     function AddIntoDevOut(Device: LongInt; Latency: CDouble;
      SampleRate: LongInt; Channels: LongInt; SampleFormat: LongInt ; FramesCount: LongInt ): LongInt;
     ////// Add a Output into Device Output
    //////////// Device ( -1 is default device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (= 4096)
    //  result :  Output Index in array    -1 = error
    /// example : OutputIndex1 := AddIntoDevOut(-1,-1,-1,-1,0);
   {$endif}

    function AddIntoFile(Filename: PChar; SampleRate: LongInt;
      Channels: LongInt; SampleFormat: LongInt ; FramesCount: LongInt): LongInt;
    /////// Add a Output into audio wav file with custom parameters
     ////////// FileName : filename of saved audio wav file
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : default : -1 (2:Int16) ( 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (= 4096)
    //  result : Output Index in array     -1 = error
    //////////// example : OutputIndex1 := AddIntoFile(edit5.Text,-1,-1, 0, -1);

    {$IF DEFINED(portaudio)}
    function AddFromDevIn(Device: LongInt; Latency: CDouble;
  SampleRate: LongInt; OutputIndex: LongInt;
  SampleFormat: LongInt; FramesCount : LongInt): LongInt;
   ////// Add a Input from Device Input with custom parameters
    //////////// Device ( -1 is default Input device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)
    //////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other LongInt refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
    //////////// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (4096)
    //  result :  otherwise Output Index in array   -1 = error
    /// example : OutputIndex1 := AddFromDevice(-1,-1,-1,-1,-1);
{$endif}

{$IF DEFINED(synthesizer)}
function AddFromSynth(Frequency: float; VolumeL: float; VolumeR: float; OutputIndex: LongInt;
      SampleFormat: LongInt ; SampleRate: LongInt ; FramesCount : LongInt): LongInt;
    /////// Add a input from Synthesizer with custom parameters
    ////////// Frequency : default : -1 (440 htz)
     ////////// VolumeL : default : -1 (= 1) (from 0 to 1) => volume left
     ////////// VolumeR : default : -1 (= 1) (from 0 to 1) => volume right
       ////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other LongInt refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
    //////////// SampleFormat : default : -1 (0: Float32) (0: Float32, 1:Int32, 2:Int16)
    //////////// SampleRate : delault : -1 (44100)
    //////////// FramesCount : -1 default : 1024
     //  result :   Input Index in array    -1 = error
    //////////// example : InputIndex1 := AddFromSynth(880,-1,-1,-1,-1,-1,-1);
    
procedure InputSetSynth(InputIndex: LongInt; Frequency: float; VolumeL: float; VolumeR: float; Enable : boolean);
     ////////// Frequency : in Hertz (-1 = do not change)
     ////////// VolumeL :  from 0 to 1 (-1 = do not change)
     ////////// VolumeR :  from 0 to 1 (-1 = do not change)
    //////////// Enable : true or false ;
{$endif}

function AddFromFile(Filename: Pchar; OutputIndex: LongInt;
      SampleFormat: LongInt ; FramesCount: LongInt): LongInt;
    /////// Add a input from audio file with custom parameters
    ////////// FileName : filename of audio file
    ////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other LongInt refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
    //////////// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (4096)
    //  result :   Input Index in array    -1 = error
    //////////// example : InputIndex1 := AddFromFile(edit5.Text,-1,0,-1);

{$IF DEFINED(webstream)}
function AddFromURL(URL: PChar; OutputIndex: LongInt;
   SampleFormat: LongInt ; FramesCount: LongInt ): LongInt;
  /////// Add a Input from Audio URL
  ////////// URL : URL of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
  ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (4096)
  ////////// example : InputIndex := AddFromURL('http://someserver/somesound.mp3',-1,-1,-1);
{$ENDIF}

function AddPlugin(PlugName: Pchar; SampleRate: LongInt;
      Channels: LongInt): LongInt;
    /////// Add a plugin , result is PluginIndex
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
    ////// 'soundtouch' and 'bs2b' PlugName are registred.

{$IF DEFINED(soundtouch)}
procedure SetPluginSoundTouch(PluginIndex: LongInt; Tempo: cfloat;
      Pitch: cfloat; Enable: boolean);
    ////////// PluginIndex : PluginIndex Index of a existing Plugin.
    //////////               
{$endif}
    
{$IF DEFINED(bs2b)}
procedure SetPluginBs2b(PluginIndex: LongInt; level: CInt32; fcut: CInt32; 
   feed: CInt32; Enable: boolean);
    ////////// PluginIndex : PluginIndex Index of a existing Plugin.
    //////////                
{$endif}

function GetStatus() : LongInt ;
    /////// Get the status of the player : 0 => has stopped, 1 => is running, 2 => is paused, -1 => error.

procedure Seek(InputIndex: LongInt; pos: Tcount_t);
    //// change position in sample

procedure SeekSeconds(InputIndex: LongInt; pos: cfloat);
    //// change position in seconds

procedure SeekTime(InputIndex: LongInt; pos: TTime);
    //// change position in time format

function InputLength(InputIndex: LongInt): longint;
    ////////// InputIndex : InputIndex of existing input
    ///////  result : Length of Input in samples

function InputLengthSeconds(InputIndex: LongInt): cfloat;
    ////////// InputIndex : InputIndex of existing input
    ///////  result : Length of Input in seconds
    
function InputLengthTime(InputIndex: LongInt): TTime;
    ////////// InputIndex : InputIndex of existing input
    ///////  result : Length of Input in time format

function InputPosition(InputIndex: LongInt): longint;
    ////////// InputIndex : InputIndex of existing input
    ////// result : current postion in sample

procedure InputSetFrameCount(InputIndex: LongInt ; framecount : longint);
                   ///////// set number of frames to be done. (usefull for recording and level precision)

procedure InputSetLevelEnable(InputIndex: LongInt ; levelcalc : longint);
                   ///////// set level calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

procedure InputSetPositionEnable(InputIndex: LongInt ; poscalc : longint);
                   ///////// set position calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul of position.

procedure InputSetArrayLevelEnable(InputIndex: LongInt ; levelcalc : longint);
                   ///////// set add level calculation in level-array (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.

function InputGetLevelLeft(InputIndex: LongInt): double;
    ////////// InputIndex : InputIndex of existing input
    ////// result : left level from 0 to 1

function InputGetLevelRight(InputIndex: LongInt): double;
    ////////// InputIndex : InputIndex of existing input
    ////// result : right level from 0 to 1

function InputPositionSeconds(InputIndex: LongInt): float;
    ////////// InputIndex : InputIndex of existing input
    ///////  result : current postion of Input in seconds

function InputPositionTime(InputIndex: LongInt): TTime;
    ////////// InputIndex : InputIndex of existing input
    ///////  result : current postion of Input in time format

function AddDSPin(InputIndex: LongInt; BeforeFunc: TFunc;
      AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: TProc): LongInt;
    ///// add a DSP procedure for input
    ////////// InputIndex d: Input Index of a existing input
    ////////// BeforeFunc : function to do before the buffer is filled
    ////////// AfterFunc : function to do after the buffer is filled
    ////////// EndedFunc : function to do after thread is finish
    ////////// LoopProc : external procedure of object to synchronize after the buffer is filled
    //  result :  index of DSPin in array  (DSPinIndex)
    ////////// example : DSPinIndex1 := AddDSPIn(InputIndex1,@beforereverse,@afterreverse,nil);

procedure SetDSPin(InputIndex: LongInt; DSPinIndex: LongInt; Enable: boolean);
    ////////// InputIndex : Input Index of a existing input
    ////////// DSPIndexIn : DSP Index of a existing DSP In
    ////////// Enable :  DSP enabled
    ////////// example : SetDSPIn(InputIndex1,DSPinIndex1,True);

function AddDSPout(OutputIndex: LongInt; BeforeFunc: TFunc;
      AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: TProc): LongInt;    //// usefull if multi output
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// BeforeFunc : function to do before the buffer is filled
    ////////// AfterFunc : function to do after the buffer is filled just before to give to output
    ////////// EndedFunc : function to do after thread is finish
    ////////// LoopProc : external procedure of object to synchronize after the buffer is filled
    //  result : index of DSPout in array
    ////////// example :DSPoutIndex1 := AddDSPout(OutputIndex1,@volumeproc,nil,nil);

procedure SetDSPout(OutputIndex: LongInt; DSPoutIndex: LongInt; Enable: boolean);
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// DSPoutIndex : DSPoutIndex of existing DSPout
    ////////// Enable :  DSP enabled
    ////////// example : SetDSPIn(OutputIndex1,DSPoutIndex1,True);

function AddFilterIn(InputIndex: LongInt; LowFrequency: LongInt;
      HighFrequency: LongInt; Gain: cfloat; TypeFilter: LongInt;
      AlsoBuf: boolean; LoopProc: TProc): LongInt;
    ////////// InputIndex : InputIndex of a existing Input
    ////////// LowFrequency : Lowest frequency of filter
    ////////// HighFrequency : Highest frequency of filter
    ////////// Gain : gain to apply to filter
    ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
    /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
    ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
    ////////// LoopProc : external procedure of object to synchronize after DSP done
    //  result :  otherwise index of DSPIn in array
    ////////// example :FilterInIndex1 := AddFilterIn(InputIndex1,6000,16000,1,2,true,nil);

procedure SetFilterIn(InputIndex: LongInt; FilterIndex: LongInt;
      LowFrequency: LongInt; HighFrequency: LongInt; Gain: cfloat;
      TypeFilter: LongInt; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);
    ////////// InputIndex : InputIndex of a existing Input
    ////////// DSPInIndex : DSPInIndex of existing DSPIn
    ////////// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
    ////////// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
    ////////// Gain : gain to apply to filter
    ////////// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
    /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
    ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
    ////////// LoopProc : external procedure of object to synchronize after DSP done
    ////////// Enable :  Filter enabled
    ////////// example : SetFilterIn(InputIndex1,FilterInIndex1,-1,-1,-1,False,True,nil);

function AddFilterOut(OutputIndex: LongInt; LowFrequency: LongInt;
      HighFrequency: LongInt; Gain: cfloat; TypeFilter: LongInt;
      AlsoBuf: boolean; LoopProc: TProc): LongInt;
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// LowFrequency : Lowest frequency of filter
    ////////// HighFrequency : Highest frequency of filter
    ////////// Gain : gain to apply to filter
    ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
    /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
    ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
    ////////// LoopProc : external procedure of object to synchronize after DSP done
    //  result : index of DSPOut in array
    ////////// example :FilterOutIndex1 := AddFilterOut(OutputIndex1,6000,16000,1,true,nil);

procedure SetFilterOut(OutputIndex: LongInt; FilterIndex: LongInt;
      LowFrequency: LongInt; HighFrequency: LongInt; Gain: cfloat;
      TypeFilter: LongInt; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// FilterIndex : DSPOutIndex of existing DSPOut
    ////////// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
    ////////// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
    ////////// Gain : gain to apply to filter
    ////////// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
    /// fBandPass = 3, fHighPass = 4, fLowPass = 5)
    ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
    ////////// Enable :  Filter enabled
    ////////// LoopProc : external procedure of object to synchronize after DSP done
    ////////// example : SetFilterOut(OutputIndex1,FilterOutIndex1,1000,1500,-1,True,True,nil);

function DSPLevel(Data: Tuos_Data): Tuos_Data;
    //////////// to get level of buffer (volume)

function AddDSPVolumeIn(InputIndex: LongInt; VolLeft: double;
      VolRight: double): LongInt;
    ///// DSP Volume changer
    ////////// InputIndex : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    //  result :  index of DSPIn in array
    ////////// example  DSPIndex1 := AddDSPVolumeIn(InputIndex1,1,1);

function AddDSPVolumeOut(OutputIndex: LongInt; VolLeft: double;
      VolRight: double): LongInt;
    ///// DSP Volume changer
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    //  result :  otherwise index of DSPIn in array
    ////////// example  DSPIndex1 := AddDSPVolumeIn(InputIndex1,1,1);
    
{$IF DEFINED(noiseremoval)}
function AddDSPNoiseRemovalIn(InputIndex: LongInt): LongInt;
    ///// DSP Noise Removal
    ////////// InputIndex : InputIndex of a existing Input
    //  result :  otherwise index of DSPIn in array
    ////////// example  DSPIndex1 := AddDSPNoiseRemovalIn(InputIndex1);
    
procedure SetDSPNoiseRemovalIn(InputIndex: LongInt; Enable: boolean);
    
function AddDSPNoiseRemovalOut(OutputIndex: LongInt): LongInt;
    ///// DSP Noise Removal
    ////////// InputIndex : OutputIndex of a existing Output
    //  result :  otherwise index of DSPOut in array
    ////////// example  DSPIndex1 := AddDSPNoiseRemovalOut(OutputIndex1);
    
procedure SetDSPNoiseRemovalOUT(OutputIndex: LongInt; Enable: boolean);
{$endif}  
    
procedure SetDSPVolumeIn(InputIndex: LongInt; DSPVolIndex: LongInt;
      VolLeft: double; VolRight: double; Enable: boolean);
    ////////// InputIndex : InputIndex of a existing Input
    ////////// DSPIndex : DSPIndex of a existing DSP
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled
    ////////// example  SetDSPVolumeIn(InputIndex1,DSPIndex1,1,0.8,True);

procedure SetDSPVolumeOut(OutputIndex: LongInt; DSPVolIndex: LongInt;
      VolLeft: double; VolRight: double; Enable: boolean);
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// DSPIndex : DSPIndex of a existing DSP
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled
    ////////// example  SetDSPVolumeOut(InputIndex1,DSPIndex1,1,0.8,True);

end;

//////////// General public procedure/function (accessible for library uos too)

   {$IF DEFINED(portaudio)}
procedure uos_GetInfoDevice();

function uos_GetInfoDeviceStr() : Pansichar ;
   {$endif}

function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName: PChar) : LongInt;
       ////// load libraries... if libraryfilename = '' =>  do not load it...  You may load what and when you want...
     // PortAudio => needed for dealing with audio-device
     // SndFile => needed for dealing with ogg, vorbis, flac and wav audio-files
     // Mpg123 => needed for dealing with mp* audio-files
     // Mp4ff and Faad => needed for dealing with acc, m4a audio-files

     // If some libraries are not needed, replace it by "nil", for example : uos_loadlib(PortAudioFileName, SndFileFileName, nil, nil, nil)

procedure uos_unloadlib();
        ////// Unload all libraries... Do not forget to call it before close application...

procedure uos_unloadlibCust(PortAudio, SndFile, Mpg123, AAC: boolean);
           ////// Custom Unload libraries... if true, then unload the library. You may unload what and when you want...

function uos_loadPlugin(PluginName, PluginFilename: PChar) : LongInt;
        ////// load plugin...
        
procedure uos_unloadPlugin(PluginName: PChar);
           ////// Unload Plugin...
           
procedure uos_Free();
     /// To call at end of application.
     //// If uos_flat.pas was used, it will free all the uos_player created.
           
function uos_GetVersion() : LongInt ;             //// version of uos

const
  ///// error
  noError = 0;
  FilePAError = 10;
  LoadPAError = 11;
  FileSFError = 20;
  LoadSFError = 21;
  FileMPError = 30;
  LoadMPError = 31;
  ///// uos Audio
  Stereo = 2;
  Mono = 1;
  DefRate = 44100;
  ////////////// Write wav file
  ReadError = 1;
  HeaderError = 2;
  DataError = 3;
  FileCorrupt = 4;
  IncorectFileFormat = 5;
  HeaderWriteError = 6;
  StreamError = 7;
  /////////////////// FFT Filters
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
  uosPlayers: array of Tuos_Player;
  uosPlayersStat : array of LongInt;
  uosLevelArray : TDArIARFloat ;
  ifflat : boolean = false;
  uosDeviceInfos: array of Tuos_DeviceInfos;
  uosLoadResult: Tuos_LoadResult;
  uosDeviceCount: LongInt;
  uosDefaultDeviceIn: LongInt;
  uosDefaultDeviceOut: LongInt;
  uosInit: Tuos_Init;

 {$IF DEFINED(windows)}
   old8087cw: word;
 {$endif}

   {$IF DEFINED(Java)}
  theclass : JClass;
    {$endif}

implementation

//uses
//uos_flat;

{$IF DEFINED(webstream)}
function mpg_read_stream(ahandle: Pointer; AData: Pointer; ACount: Integer): Integer; cdecl;
var
  Stream: TStream absolute ahandle;
begin
  Result := Stream.Read(AData^, ACount);
end;

function mpg_seek_stream(ahandle: Pointer; aoffset: Integer): Integer;
var
  Stream: TStream absolute ahandle;
begin
  // pipe streams are not seekable but memory and filestreams are
  Result := aoffset;
  try
    if aoffset <> 0 then
      Result := Stream.Seek(soFromCurrent, aoffset);

  except
    Result := 0;
  end;
end;

procedure mpg_close_stream(ahandle: Pointer);
begin
  TObject(ahandle).Free;
end;
{$endif}

function FormatBuf(Inbuf: TDArFloat; format: LongInt): TDArFloat;
var
  x: LongInt;
  ps: PDArShort;     //////// if input is Int16 format
  pl: PDArLong;      //////// if input is Int32 format
  pf: PDArFloat;     //////// if input is Float32 format
begin

  case format of
    2:
    begin
      ps := @inbuf;
      for x := 0 to high(inbuf) do
        ps^[x] := cint16(round(ps^[x]));
    end;
    1:
    begin
      pl := @inbuf;
      for x := 0 to high(inbuf) do
        pl^[x] := cint32(round(pl^[x]));
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
  x, i: LongInt;
  arsh: TDArShort;
begin
  SetLength(arsh, length(inbuf));
  for x := 0 to high(Inbuf) do
  begin
    i := round(Inbuf[x] * 32768);
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
   x : LongInt;
  arlo: TDArLong;
begin
  SetLength(arlo, length(inbuf));
  for x := 0 to high(Inbuf) do
  begin
    i := round(Inbuf[x] * 2147483647);
    if i > 2147483647 then
      i := 2147483647
    else
    if i < -2147483648 then
      i := -2147483648;
    arlo[x] := i;
  end;
  Result := arlo;
end;

function CvInt16ToFloat32(Inbuf: TDArFloat): TDArFloat;
var
  x: LongInt;
  arfl: TDArFloat;
  ps: PDArShort;
begin
    setlength(arfl,length(Inbuf));
  ps := @inbuf;
  for x := 0 to high(Inbuf) do
    arfl[x] := ps^[x] / 32768;
  Result := arfl;
end;

function CvSteroToMono(Inbuf: TDArFloat; len : longint): TDArFloat;
var
  x, y: LongInt;
  arsh: TDArFloat;
 begin

   if len > 0 then begin
    setlength(arsh, len);

   x := 0;
   y := 0;

     while x < (len * 2)-1 do
    begin
    /// TODO -> this takes only chan1, not (chan1+chan2)/2 -> it get bad noise dont know why ???...
    // arsh[y]   := round((Inbuf[x] + Inbuf[x+1])/ 2) ;

      arsh[y]   := Inbuf[x+1] ;

      inc(y);
     x := x + 2 ;
    end;

    Result := arsh;
   end else Result := Inbuf;
end;

function CvInt32ToFloat32(Inbuf: TDArFloat): TDArFloat;
var
  x: LongInt;
  arfl: TDArFloat;
  pl: PDArLong;
begin
   setlength(arfl,length(Inbuf));
  pl := @inbuf;
  for x := 0 to high(Inbuf) do
    arfl[x] := pl^[x] / 2147483647;
  Result := arfl;
end;

function WriteWave(FileName: ansistring; Data: Tuos_FileBuffer): word;
var
  f: TFileStream;
  wFileSize: LongInt;
  wChunkSize: LongInt;
  ID: array[0..3] of char;
  Header: Tuos_WaveHeaderChunk;
begin
  Result := noError;
  f := nil;
  try
    f := TFileStream.Create(FileName, fmCreate);
    f.Seek(0, soFromBeginning);
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
    wChunkSize := Data.Data.Size;
    f.WriteBuffer(wChunkSize, 4);
    Data.Data.Seek(0, soFromBeginning);
    f.CopyFrom(Data.Data, Data.Data.Size);
  except
    Result := StreamError;
  end;
  f.Seek(SizeOf(ID), soFromBeginning);
  wFileSize := f.Size - SizeOf(ID) - SizeOf(wFileSize);
  f.Write(wFileSize, 4);
  f.Free;
end;

function Tuos_Player.GetStatus() : LongInt ;
    /////// Get the status of the player : -1 => error, 0 => has stopped, 1 => is running, 2 => is paused.
begin
   if (isAssigned = True) then  result := Status else result := -1 ;
end;

procedure Tuos_Player.Play() ;
var
  x: LongInt;
 begin
  if (isAssigned = True) then
  begin
    NoFree := false;
{$IF DEFINED(portaudio)}
  for x := 0 to high(StreamOut) do
    if StreamOut[x].Data.HandleSt <> nil then
    begin
      Pa_StartStream(StreamOut[x].Data.HandleSt);
     end;

  for x := 0 to high(StreamIn) do
    if (StreamIn[x].Data.HandleSt <> nil) and (StreamIn[x].Data.TypePut = 1) then
    begin
     Pa_StartStream(StreamIn[x].Data.HandleSt);
    // if x > 0 then sleep(200);
     end;
{$endif}

  start;   // resume;  { if fpc version <= 2.4.4}
  Status := 1;
  RTLeventSetEvent(evPause);
end;

end;

procedure Tuos_Player.PlayNoFree() ;
var
  x: LongInt;
 begin
  if (isAssigned = True) then
  begin
     NoFree := true;

   {$IF DEFINED(portaudio)}
  for x := 0 to high(StreamOut) do
    if StreamOut[x].Data.HandleSt <> nil then
    begin
      Pa_StartStream(StreamOut[x].Data.HandleSt);
     end;

  for x := 0 to high(StreamIn) do
  begin
    Seek(x, 0);
    StreamIn[x].Data.status  := 1 ;
    if (StreamIn[x].Data.HandleSt <> nil) and (StreamIn[x].Data.TypePut = 1) then
    begin
       Pa_StartStream(StreamIn[x].Data.HandleSt);
     end;
    end;
    {$endif}
  Status := 1;
  start;   // resume;  { if fpc version <= 2.4.4}
  RTLeventSetEvent(evPause);
 end;

end;


procedure Tuos_Player.RePlay();   /////// Resume Playing after Pause
begin

  if  (Status > 0) and (isAssigned = True) then
  begin
    Status := 1;
    RTLeventSetEvent(evPause);
  end;
end;

procedure Tuos_Player.Stop();
begin
  if (Status > 0) and (isAssigned = True) then
  begin
    RTLeventSetEvent(evPause);
    Status := 0;
  end;
end;

procedure Tuos_Player.Pause();
begin
  if (Status > 0) and (isAssigned = True) then
  begin
    RTLeventResetEvent(evPause);
    Status := 2;
  end;
end;

procedure Tuos_Player.Seek(InputIndex:LongInt; pos: Tcount_t);
//// change position in samples
begin
   if (isAssigned = True) then StreamIn[InputIndex].Data.Poseek := pos;
end;

procedure Tuos_Player.SeekSeconds(InputIndex: LongInt; pos: cfloat);
//// change position in seconds
begin
    if  (isAssigned = True) then  StreamIn[InputIndex].Data.Poseek :=
      trunc(pos * StreamIn[InputIndex].Data.SampleRate);
end;

procedure Tuos_Player.SeekTime(InputIndex: LongInt; pos: TTime);
//// change position in time format
var
  ho, mi, se, ms, possample: word;
begin
    if (isAssigned = True) then begin
 sysutils.DecodeTime(pos, ho, mi, se, ms);

  possample := trunc(((ho * 3600) + (mi * 60) + se + (ms / 1000)) *
    StreamIn[InputIndex].Data.SampleRate);

   StreamIn[InputIndex].Data.Poseek := possample;
     end;
end;

function Tuos_Player.InputLength(InputIndex: LongInt): longint;
  //// gives length in samples
begin
   if (isAssigned = True) then Result := StreamIn[InputIndex].Data.Lengthst;
end;

function Tuos_Player.InputLengthSeconds(InputIndex: LongInt): cfloat;
begin
    if  (isAssigned = True) then Result := StreamIn[InputIndex].Data.Lengthst / StreamIn[InputIndex].Data.SampleRate;
end;

function Tuos_Player.InputLengthTime(InputIndex: LongInt): TTime;
var
  tmp: cfloat;
  h, m, s, ms: word;
begin

   if (Status > 0) and (isAssigned = True) then tmp := InputLengthSeconds(InputIndex);
    ms := trunc(frac(tmp) * 1000);
    h := trunc(tmp / 3600);
    m := trunc(tmp / 60 - h * 60);
    s := trunc(tmp - (h * 3600 + m * 60));
    Result := sysutils.EncodeTime(h, m, s, ms);
end;

function Tuos_Player.InputPosition(InputIndex: LongInt): longint;
  //// gives current position
begin
   if (isAssigned = True) then Result := StreamIn[InputIndex].Data.Position;
end;

procedure Tuos_Player.InputSetFrameCount(InputIndex: LongInt ; framecount : longint);
begin
    if (Status > 0) and (isAssigned = True) then

    case StreamIn[InputIndex].Data.LibOpen of
            0:
            StreamIn[InputIndex].Data.Wantframes:= (framecount * StreamIn[InputIndex].Data.Channels) ;

            1:
            StreamIn[InputIndex].Data.Wantframes:= (framecount * StreamIn[InputIndex].Data.Channels)  * 2  ;

            2:
            StreamIn[InputIndex].Data.Wantframes:= (framecount * StreamIn[InputIndex].Data.Channels) ;

            3:
            StreamIn[InputIndex].Data.Wantframes:= (framecount * StreamIn[InputIndex].Data.Channels) ;

end;

end;

procedure Tuos_Player.InputSetArrayLevelEnable(InputIndex: LongInt ; levelcalc : longint);
                  ///////// set add level calculation in level-array (default is 0)
                         // 0 => no calcul
                         // 1 => calcul before all DSP procedures.
                         // 2 => calcul after all DSP procedures.
begin
 if (Status > 0) and (isAssigned = True) then
 begin

if index + 1 > length(uosLevelArray) then
 setlength(uosLevelArray,index + 1) ;
 if InputIndex + 1 > length(uosLevelArray[index]) then
 setlength(uosLevelArray[index],InputIndex + 1) ;
  setlength(uosLevelArray[index][InputIndex],0) ;
 StreamIn[InputIndex].Data.levelArrayEnable := levelcalc;

end;
end;

procedure Tuos_Player.InputSetLevelEnable(InputIndex: LongInt ; levelcalc : longint);
                   ///////// set level calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

begin
    if (Status > 0) and (isAssigned = True) then
StreamIn[InputIndex].Data.levelEnable:= levelcalc;
end;

procedure Tuos_Player.InputSetPositionEnable(InputIndex: LongInt ; poscalc : longint);
                   ///////// set position calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul position procedures.
begin
    if (Status > 0) and (isAssigned = True) then
StreamIn[InputIndex].Data.PositionEnable:= poscalc;
end;

function Tuos_Player.InputGetLevelLeft(InputIndex: LongInt): double;
  ////////// InputIndex : InputIndex of existing input
  ////// result : left level(volume) from 0 to 1
begin
   if (Status > 0) and (isAssigned = True) then Result := StreamIn[InputIndex].Data.LevelLeft;
end;

function Tuos_Player.InputGetLevelRight(InputIndex: LongInt): double;
  ////////// InputIndex : InputIndex of existing input
  ////// result : right level(volume) from 0 to 1
begin
   if (isAssigned = True) then Result := StreamIn[InputIndex].Data.LevelRight;
end;

function Tuos_Player.InputPositionSeconds(InputIndex: LongInt): float;
begin
   if (isAssigned = True) then Result := StreamIn[InputIndex].Data.Position / StreamIn[InputIndex].Data.SampleRate;
end;

function Tuos_Player.InputPositionTime(InputIndex: LongInt): TTime;
var
  tmp: float;
  h, m, s, ms: word;
begin
   if (Status > 0) and (isAssigned = True) then tmp := InputPositionSeconds(InputIndex);
    ms := trunc(frac(tmp) * 1000);
    h := trunc(tmp / 3600);
    m := trunc(tmp / 60 - h * 60);
    s := trunc(tmp - (h * 3600 + m * 60));
    Result := sysutils.EncodeTime(h, m, s, ms);
end;

procedure Tuos_Player.SetDSPin(InputIndex: LongInt; DSPinIndex: LongInt;
  Enable: boolean);
begin
 StreamIn[InputIndex].DSP[DSPinIndex].Enabled := Enable;
end;

procedure Tuos_Player.SetDSPOut(OutputIndex: LongInt; DSPoutIndex: LongInt;
  Enable: boolean);
begin
 StreamOut[OutputIndex].DSP[DSPoutIndex].Enabled := Enable;
end;

function Tuos_Player.AddDSPin(InputIndex: LongInt; BeforeFunc: TFunc;
  AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: Tproc): LongInt;
begin
    SetLength(StreamIn[InputIndex].DSP, Length(StreamIn[InputIndex].DSP) + 1);
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1] := Tuos_DSP.Create();
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].BefFunc := BeforeFunc;
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].AftFunc := AfterFunc;
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].EndFunc := EndedFunc;
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].LoopProc := LoopProc;
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].Enabled := True;

    Result := Length(StreamIn[InputIndex].DSP) - 1;
 end;

function Tuos_Player.AddDSPout(OutputIndex: LongInt; BeforeFunc: TFunc;
  AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: Tproc): LongInt;
begin
    SetLength(StreamOut[OutputIndex].DSP, Length(StreamOut[OutputIndex].DSP) + 1);
    StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1] :=
      Tuos_DSP.Create;
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

procedure Tuos_Player.SetFilterIn(InputIndex: LongInt; FilterIndex: LongInt;
  LowFrequency: LongInt; HighFrequency: LongInt; Gain: cfloat;
  TypeFilter: LongInt; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);
////////// InputIndex : InputIndex of a existing Input
////////// DSPInIndex : DSPInIndex of existing DSPIn
////////// LowFrequency : Lowest frequency of filter ( default = -1 : current LowFrequency )
////////// HighFrequency : Highest frequency of filter ( default = -1 : current HighFrequency )
////////// Gain   : Gain to apply ( -1 = current gain)  ( 0 = silence, 1 = no gain, < 1 = less gain, > 1 = more gain)
////////// TypeFilter: Type of filter : ( default = -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
/////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
////////// LoopProc : external procedure of object to synchronize after DSP done
////////// Enable :  Filter enabled
////////// example : SetFilterIn(InputIndex1,FilterInIndex1,1000,1500,-1,True,nil);
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
      1:  /////////////////// DSPFFTBandSelect := DSPFFTBandReject + DSPFFTBandPass
      begin
        //////////////////////   DSPFFTBandReject
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
        /////////////////////  DSPFFTBandPass
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
        //////////////////
      end;

      2:  ///////////////////  DSPFFTBandReject
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

      3:    /////////////////////  DSPFFTBandPass
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

      4:    /////////////////////  DSPFFTLowPass
      begin
        StreamIn[InputIndex].DSP[FilterIndex].fftdata.C :=
          1 / Tan(Pi * (HighFrequency - LowFrequency + 1) /
          StreamIn[InputIndex].Data.SampleRate);
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

      5:    /////////////////////  DSPFFTHighPass
      begin
        StreamIn[InputIndex].DSP[FilterIndex].fftdata.C :=
          Tan(Pi * (HighFrequency - LowFrequency + 1) /
          StreamIn[InputIndex].Data.SampleRate);
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

procedure Tuos_Player.SetFilterOut(OutputIndex: LongInt; FilterIndex: LongInt;
  LowFrequency: LongInt; HighFrequency: LongInt; Gain: cfloat;
  TypeFilter: LongInt; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);
////////// OutputIndex : OutputIndex of a existing Output
////////// FilterIndex : DSPOutIndex of existing DSPOut
////////// LowFrequency : Lowest frequency of filter
////////// HighFrequency : Highest frequency of filter
////////// TypeFilter: Type of filter : default = -1 = actual filter (fBandAll = 0, fBandSelect = 1, fBandReject = 2
/////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
////////// Enable :  Filter enabled
////////// LoopProc : external procedure of object to synchronize after DSP done
////////// example : SetFilterOut(OutputIndex1,FilterOutIndex1,1000,1500,-1,True,nil);
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
    1:  /////////////////// DSPFFTBandSelect := DSPFFTBandReject + DSPFFTBandPass
    begin
      //////////////////////   DSPFFTBandReject
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
      /////////////////////  DSPFFTBandPass
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
      //////////////////
    end;

    2:  ///////////////////  DSPFFTBandReject
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

    3:    /////////////////////  DSPFFTBandPass
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

    4:    /////////////////////  DSPFFTLowPass
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

    5:    /////////////////////  DSPFFTHighPass
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
function SoundTouchPlug(bufferin: TDArFloat; plugHandle: THandle; notneeded :Tt_bs2bdp; inputData: Tuos_Data;
  notused1: float; notused2: float; notused3: float;  notused4: float;
  notused5: float; notused6: float; notused7: float;  notused8: float): TDArFloat;
var
  numoutbuf, x1, x2: LongInt;
  BufferplugFLTMP: TDArFloat;
  BufferplugFL: TDArFloat;
begin
  soundtouch_putSamples(plugHandle, pointer(bufferin),
    length(bufferin) div round(inputData.Channels * inputData.ratio));

  numoutbuf := 1;
  SetLength(BufferplugFL, 0);

   SetLength(BufferplugFLTMP, length(bufferin));

  if inputData.outframes > 0 then
    while numoutbuf > 0 do
    begin
      numoutbuf := soundtouch_receiveSamples(PlugHandle,
        pointer(BufferplugFLTMP), inputData.outframes);
      SetLength(BufferplugFL, length(BufferplugFL) + round(numoutbuf * inputData.Channels));
      x2 := Length(BufferplugFL) - round(numoutbuf * inputData.Channels);

      for x1 := 0 to round(numoutbuf * inputData.Channels) - 1 do
      begin
        BufferplugFL[x1 + x2] := BufferplugFLTMP[x1];
      end;
    end;
  // inputData.outframes := Length(BufferplugFL); 
  Result := BufferplugFL;
end;
{$endif}

{$IF DEFINED(bs2b)}
function bs2bPlug(bufferin: TDArFloat; notneeded: THandle; Abs2bd : Tt_bs2bdp; inputData: Tuos_Data;
 notused1: float; notused2: float; notused3: float;  notused4: float;
  notused5: float; notused6: float; notused7: float;  notused8: float): TDArFloat;
var
  x, x2: LongInt;
  Bufferplug: TDArFloat;
 begin
 
  if (inputData.libopen = 0) or (inputData.libopen = 2)  or (inputData.libopen = 3) then
  x2 := round(inputData.ratio * (inputData.outframes div round(inputData.channels))) ;
  
  if (inputData.libopen = 1)   then
  begin
  if inputData.SampleFormat < 2 then 
  x2 := round((inputData.outframes div round(inputData.channels)))
  else x2 := round(inputData.ratio * (inputData.outframes div round(inputData.channels))) ;
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

function Tuos_Player.AddPlugin(PlugName: PChar; SampleRate: LongInt;
  Channels: LongInt): LongInt;
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// Result is PluginIndex
var
  x: LongInt;
begin
x := -1 ;
 {$IF DEFINED(soundtouch)}
   if lowercase(PlugName) = 'soundtouch' then
  begin /// 
    SetLength(Plugin, Length(Plugin) + 1);
    Plugin[Length(Plugin) - 1] := Tuos_Plugin.Create();
    x := Length(Plugin) - 1;
    Plugin[x].Name := lowercase(PlugName);
    Plugin[x].Enabled := True;
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
    Result := x;
 end;

{$IF DEFINED(soundtouch)}
procedure Tuos_Player.SetPluginSoundTouch(PluginIndex: LongInt;
  Tempo: cfloat; Pitch: cfloat; Enable: boolean);
begin
  soundtouch_setRate(Plugin[PluginIndex].PlugHandle, Pitch);
  soundtouch_setTempo(Plugin[PluginIndex].PlugHandle, Tempo);
  Plugin[PluginIndex].Enabled := Enable;
  Plugin[PluginIndex].param1 := Tempo;
  Plugin[PluginIndex].param2 := Pitch;
end;
{$endif}

{$IF DEFINED(bs2b)}
procedure Tuos_Player.SetPluginBs2b(PluginIndex: LongInt;
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

function uos_InputGetArrayLevel(PlayerIndex: cint32; InputIndex: LongInt) : TDArFloat;
begin
   result :=  uosLevelArray[PlayerIndex][InputIndex] ;
  end;
  
 {$IF DEFINED(noiseremoval)}
 
function uos_NoiseRemoval(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;
var
 ratio, x: LongInt;
 Outfr : LongInt;
 tempr : PSingle;
 pf: TDArFloat;      
begin

    case Data.LibOpen of
        0: ratio := 1; // sndfile
        1: ratio := 2; // mpg123
        2: ratio := 1; // aac
        3: ratio := 1; // cdrom
      end;
      
if Data.SampleFormat = 0 then // TODO for Array of integer.
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
   
end else result := Data.Buffer; // TODO for Array of integer.
end;
 {$endif}

function uos_DSPVolume(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;
var
  x, ratio: LongInt;
  vleft, vright: double;

  ps: PDArShort;     //////// if input is Int16 format
  pl: PDArLong;      //////// if input is Int32 format
  pf: PDArFloat;     //////// if input is Float32 format
begin

  vleft := Data.VLeft;
  vright := Data.VRight;

  case Data.SampleFormat of
    2:      // int16
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
       /// This to avoid distortion
     if ps^[x] < (-32760) then ps^[x] := -32760 ;
     if ps^[x] > (32760) then ps^[x] := 32760 ;

       end;

    end;
    1:    /// int32
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

       /// This to avoid distortion
     if pl^[x] < (-2147000000) then pl^[x] := -2147000000 ;
     if pl^[x] > (2147000000) then pl^[x] := 2147000000 ;

       end;

    end;
    0:      /// float32
    begin
      case Data.LibOpen of
        0: ratio := 1; // sndfile
        1: ratio := 2; // mpg123
        2: ratio := 1; // aac
        3: ratio := 1; // cdrom
      end;

     pf := @Data.Buffer;
      for x := 0 to (Data.OutFrames div ratio) do
      begin
       if (Data.VLeft <> 1)  or (Data.Vright <> 1) then
       begin
        if odd(x) then
          pf^[x] := pf^[x] * vright
        else
          pf^[x] := pf^[x] * vleft;
       end;
         /// This to avoid distortion
          if pf^[x] < (-1) then pf^[x] := -1 ;
          if pf^[x] > 1 then pf^[x] := 1 ;

      end;

    end;
  end;

  Result := Data.Buffer;
end;

function Tuos_Player.DSPLevel(Data: Tuos_Data): Tuos_Data;
var
  x, ratio: LongInt;
  ps: PDArShort;     //////// if input is Int16 format
  pl: PDArLong;      //////// if input is Int32 format
  pf: PDArFloat;     //////// if input is Float32 format
  mins, maxs: array[0..1] of cInt16;    //////// if input is Int16 format
  minl, maxl: array[0..1] of cInt32;    //////// if input is Int32 format
  minf, maxf: array[0..1] of cfloat;    //////// if input is Float32 format
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
      while x < Data.OutFrames do
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
      while x < Data.OutFrames do
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
        0: ratio := 1; // sndfile
        1: ratio := 2; // mpg123
        2: ratio := 2; // aac
        3: ratio := 2; // cdrom
      end;

      minf[0] := 1;
      minf[1] := 1;
      maxf[0] := -1;
      maxf[1] := -1;
      pf := @Data.Buffer;
      x := 0;
      while x < (Data.OutFrames div ratio) do
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

function uos_BandFilter(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;
var
  i, ratio: LongInt;
  ifbuf: boolean;
  arg, res, res2: cfloat;
  ps: PDArShort;     //////// if input is Int16 format
  pl: PDArLong;      //////// if input is Int32 format
  pf: PDArFloat;     //////// if input is Float32 format
begin

  ratio := 1;
  ifbuf := fft.AlsoBuf;

  case Data.SampleFormat of
    2: ps := @Data.Buffer;
    1: pl := @Data.Buffer;
    0:
    begin
      case Data.LibOpen of
        0: ratio := 1; // sndfile
        1: ratio := 2; // mpg123
        2: ratio := 2; // aac
        3: ratio := 2; // cdrom
      end;
      pf := @Data.Buffer;
    end;
  end;
  i := 0;
  while i < (Data.OutFrames div ratio) do
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
          fft.RightResult := round((res * 1) + (res2 * fft.gain));
          if ifbuf = True then
            ps^[i] := round((res * 1) + (res2 * fft.gain));
        end;
        1:
        begin
          fft.RightResult := round((res * 1) + (res2 * fft.gain));
          if ifbuf = True then
            pl^[i] := round((res * 1) + (res2 * fft.gain));
        end;
        0:
        begin
          fft.RightResult := ((res * 1) + (res2 * fft.gain));
          if ifbuf = True then
            pf^[i] := ((res * 1) + (res2 * fft.gain));
        end;
      end;

    end
    else
      case Data.SampleFormat of
        2:
        begin
          fft.RightResult := round(res * fft.gain);
          if ifbuf = True then
            ps^[i] := round((res * fft.gain));
        end;
        1:
        begin
          fft.RightResult := round((res * fft.gain));
          if ifbuf = True then
            pl^[i] := round((res * fft.gain));
        end;
        0:
        begin
          fft.RightResult := ((res * fft.gain));
          if ifbuf = True then
            pf^[i] := ((res * fft.gain));
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
            fft.LeftResult := round((res * 1) + (res2 * fft.gain));

            if ifbuf = True then
              ps^[i] := round((res * 1) + (res2 * fft.gain));
          end;
          1:
          begin
            fft.LeftResult := round((res * 1) + (res2 * fft.gain));
            if ifbuf = True then
              pl^[i] := round((res * 1) + (res2 * fft.gain));
          end;
          0:
          begin
            fft.LeftResult := ((res * 1) + (res2 * fft.gain));
            if ifbuf = True then
              pf^[i] := ((res * 1) + (res2 * fft.gain));
          end;
       end;

      end
      else
        case Data.SampleFormat of
          2:
          begin
            fft.LeftResult := round((res * fft.gain));
            if ifbuf = True then
              ps^[i] := round((res * fft.gain));
          end;
          1:
          begin
            fft.LeftResult := round((res * fft.gain));
            if ifbuf = True then
              pl^[i] := round((res * fft.gain));
          end;
          0:
          begin
            fft.LeftResult := ((res * fft.gain));
            if ifbuf = True then
              pf^[i] := ((res * fft.gain));
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

  Result := Data.Buffer;

end;

  {$IF DEFINED(noiseremoval)}
    function Tuos_Player.AddDSPNoiseRemovalIn(InputIndex: LongInt): LongInt;
    ///// DSP Noise Removal
    ////////// InputIndex : InputIndex of a existing Input
    //  result :  otherwise index of DSPIn in array
    ////////// example  DSPIndex1 := AddDSPNoiseRemovalIn(InputIndex1);
    begin
    
 Result := AddDSPin(InputIndex, nil, @uos_NoiseRemoval, nil, nil);   
 
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
    
procedure Tuos_Player.SetDSPNoiseRemovalIn(InputIndex: LongInt; Enable: boolean);
      
 begin

StreamIn[InputIndex].DSP[StreamIn[InputIndex].data.DSPNoiseIndex].enabled := Enable ; 

 end;     
 
function Tuos_Player.AddDSPNoiseRemovalOut(OutputIndex: LongInt): LongInt;
    ///// DSP Noise Removal
    ////////// OutputIndex : OutputIndex of a existing Output
    //  result :  otherwise index of DSPInOut in array
    ////////// example  DSPIndex1 := AddDSPNoiseRemovalOut(OutputIndex1);
 begin
    
 Result := AddDSPOut(OutputIndex, nil, @uos_NoiseRemoval, nil, nil);   
 
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
    
procedure Tuos_Player.SetDSPNoiseRemovalOut(OutputIndex: LongInt; Enable: boolean);
      
 begin

StreamOut[OutputIndex].DSP[StreamOut[OutputIndex].data.DSPNoiseIndex].enabled := Enable ; 

 end;     
  
  {$endif}  

function Tuos_Player.AddDSPVolumeIn(InputIndex: LongInt; VolLeft: double;
  VolRight: double): LongInt;  ///// DSP Volume changer
  ////////// InputIndex : InputIndex of a existing Input
  ////////// VolLeft : Left volume
  ////////// VolRight : Right volume
  //  result : index of DSPIn in array
  ////////// example  DSPIndex1 := AddDSPVolumeIn(InputIndex1,1,1);
begin
  Result := AddDSPin(InputIndex, nil, @uos_DSPVolume, nil, nil);
  StreamIn[InputIndex].Data.VLeft := VolLeft;
  StreamIn[InputIndex].Data.VRight := VolRight;
end;

function Tuos_Player.AddDSPVolumeOut(OutputIndex: LongInt; VolLeft: double;
  VolRight: double): LongInt;  ///// DSP Volume changer
  ////////// OutputIndex : OutputIndex of a existing Output
  ////////// VolLeft : Left volume ( 1 = max)
  ////////// VolRight : Right volume ( 1 = max)
  //  result :  index of DSPIn in array
  ////////// example  DSPIndex1 := AddDSPVolumeOut(OutputIndex1,1,1);
begin
  Result := AddDSPin(OutputIndex, nil, @uos_DSPVolume, nil, nil);
  StreamOut[OutputIndex].Data.VLeft := VolLeft;
  StreamOut[OutputIndex].Data.VRight := VolRight;
end;

procedure Tuos_Player.SetDSPVolumeIn(InputIndex: LongInt; DSPVolIndex: LongInt;
  VolLeft: double; VolRight: double; Enable: boolean);
////////// InputIndex : InputIndex of a existing Input
////////// DSPIndex : DSPVolIndex of a existing DSPVolume
////////// VolLeft : Left volume ( -1 = do not change)
////////// VolRight : Right volume ( -1 = do not change)
////////// Enable : Enabled
////////// example  SetDSPVolumeIn(InputIndex1,DSPVolIndex1,1,0.8,True);
begin
  if VolLeft <> -1 then
    StreamIn[InputIndex].Data.VLeft := VolLeft;
  if VolRight <> -1 then
    StreamIn[InputIndex].Data.VRight := VolRight;
  StreamIn[InputIndex].DSP[DSPVolIndex].Enabled := Enable;
end;

procedure Tuos_Player.SetDSPVolumeOut(OutputIndex: LongInt;
  DSPVolIndex: LongInt; VolLeft: double; VolRight: double; Enable: boolean);
////////// OutputIndex : OutputIndex of a existing Output
////////// DSPIndex : DSPIndex of a existing DSP
////////// VolLeft : Left volume
////////// VolRight : Right volume
////////// Enable : Enabled
////////// example  SetDSPVolumeOut(InputIndex1,DSPIndex1,1,0.8,True);
begin
  if VolLeft <> -1 then
    StreamOut[OutputIndex].Data.VLeft := VolLeft;
  if VolRight <> -1 then
    StreamOut[OutputIndex].Data.VRight := VolRight;
  StreamOut[OutputIndex].DSP[DSPVolIndex].Enabled := Enable;
end;

function Tuos_Player.AddFilterIn(InputIndex: LongInt; LowFrequency: LongInt;
  HighFrequency: LongInt; Gain: cfloat; TypeFilter: LongInt; AlsoBuf: boolean;
  LoopProc: TProc): LongInt;
  ////////// InputIndex : InputIndex of a existing Input
  ////////// LowFrequency : Lowest frequency of filter
  ////////// HighFrequency : Highest frequency of filter
  ////////// Gain : gain to apply to filter ( 1 = no gain )
  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  ////////// LoopProc : external procedure of object to synchronize after DSP done
  //  result : index of DSPIn in array
  ////////// example :FilterInIndex1 := AddFilterIn(InputIndex1,6000,16000,1,1,True);
var
  FilterIndex: LongInt;
begin
  FilterIndex := AddDSPin(InputIndex, nil, @uos_BandFilter, nil, LoopProc);

   StreamIn[InputIndex].DSP[FilterIndex].fftdata :=
      Tuos_FFT.Create();
      
  if TypeFilter = -1 then
    TypeFilter := 1;
  SetFilterIn(InputIndex, FilterIndex, LowFrequency, HighFrequency,
    Gain, TypeFilter, AlsoBuf, True, LoopProc);

  Result := FilterIndex;
end;

function Tuos_Player.AddFilterOut(OutputIndex: LongInt; LowFrequency: LongInt;
  HighFrequency: LongInt; Gain: cfloat; TypeFilter: LongInt; AlsoBuf: boolean;
  LoopProc: TProc): LongInt;
  ////////// OutputIndex : OutputIndex of a existing Output
  ////////// LowFrequency : Lowest frequency of filter
  ////////// HighFrequency : Highest frequency of filter
  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  ////////// LoopProc : external procedure of object to synchronize after DSP done
  //  result :  index of DSPOut in array
  ////////// example :FilterOutIndex1 := AddFilterOut(OutputIndex1,6000,16000,1,true);
var
  FilterIndex: LongInt;
begin
  FilterIndex := AddDSPOut(OutputIndex, nil, @uos_BandFilter, nil, LoopProc);
  
    StreamOut[OutputIndex].DSP[FilterIndex].fftdata :=
      Tuos_FFT.Create();
      
  if TypeFilter = -1 then
    TypeFilter := 1;
  SetFilterOut(OutputIndex, FilterIndex, LowFrequency, HighFrequency,
    Gain, TypeFilter, AlsoBuf, True, LoopProc);

  Result := FilterIndex;

end;

{$IF DEFINED(portaudio)}
function Tuos_Player.AddFromDevIn(Device: LongInt; Latency: CDouble;
  SampleRate: LongInt; OutputIndex: LongInt;
  SampleFormat: LongInt; FramesCount : LongInt): LongInt;
  /// Add Input from IN device with custom parameters
  //////////// Device ( -1 is default Input device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other LongInt refer to a existing OutputIndex
                           // (if multi-output then OutName = name of each output separeted by ';')
  //////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : -1 default : 4096
  //////////// example : AddFromDevIn(-1,-1,-1,-1);
var
  x, err: LongInt;
begin
 result := -1 ;
  x := 0;
   err := -1;
  SetLength(StreamIn, Length(StreamIn) + 1);
  StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create();
  x := Length(StreamIn) - 1;
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

  SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes* StreamIn[x].Data.channels);

  StreamIn[x].Data.outframes := length(StreamIn[x].Data.Buffer);
  StreamIn[x].Data.Enabled := True;
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.TypePut := 1;
  StreamIn[x].Data.ratio := 2;
  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.seekable := False;
  StreamIn[x].Data.LibOpen := 2;
  StreamIn[x].LoopProc := nil;
  err := Pa_OpenStream(@StreamIn[x].Data.HandleSt, @StreamIn[x].PAParam,
    nil, StreamIn[x].Data.SampleRate, (512), paClipOff, nil, nil);

  if err <> 0 then
  else
    Result := x;
end;
{$endif}

{$IF DEFINED(synthesizer)}
function Tuos_Player.AddFromSynth(Frequency: float; VolumeL: float; VolumeR: float; OutputIndex: LongInt;
      SampleFormat: LongInt ; SampleRate: LongInt ; FramesCount : LongInt): LongInt;
    /////// Add a input from Synthesizer with custom parameters
    ////////// Frequency : default : -1 (440 htz)
     ////////// VolumeL : default : -1 (= 1) (from 0 to 1) => volume left
     ////////// VolumeR : default : -1 (= 1) (from 0 to 1) => volume right
       ////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other LongInt refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
    //////////// SampleFormat : default : -1 (0: Float32) (0: Float32, 1:Int32, 2:Int16)
    //////////// SampleRate : delault : -1 (44100)
    //////////// FramesCount : -1 default : 1024
     //  result :   Input Index in array    -1 = error
    //////////// example : InputIndex1 := AddFromSynth(880,-1,-1,-1,-1,-1,-1);
 
var
  x : LongInt;
begin
 result := -1 ;
  x := 0;

  SetLength(StreamIn, Length(StreamIn) + 1);
  StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create();
  x := Length(StreamIn) - 1;
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
  begin
   StreamIn[x].Data.freqsine := 440 ;
   StreamIn[x].Data.lensine :=  (StreamIn[x].Data.SampleRate div 440) ;
   end
    else
   begin
    StreamIn[x].Data.freqsine := Frequency ;
    StreamIn[x].Data.lensine := round(StreamIn[x].Data.SampleRate / Frequency) ;
   end;
   
   StreamIn[x].Data.posLsine := 0 ;
   StreamIn[x].Data.posRsine := 0 ;
     
 SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes* StreamIn[x].Data.channels);

  
   if SampleFormat = -1 then
    StreamIn[x].Data.SampleFormat := CInt32(0)
  else
    StreamIn[x].Data.SampleFormat := CInt32(SampleFormat);

  if VolumeL = -1 then StreamIn[x].Data.VLeft := 1 else
   StreamIn[x].Data.VLeft := VolumeL;
   
  if VolumeR = -1 then StreamIn[x].Data.Vright := 1 else
   StreamIn[x].Data.Vright := VolumeR;
 
  StreamIn[x].Data.Enabled := True;
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.TypePut := 3;
  StreamIn[x].Data.HandleSt := pchar('synth');
  StreamIn[x].Data.ratio := 2;
  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.seekable := False;
  StreamIn[x].Data.LibOpen := -1;
  StreamIn[x].LoopProc := nil;

    Result := x;
end;

procedure Tuos_Player.InputSetSynth(InputIndex: LongInt; Frequency: float; VolumeL: float; VolumeR: float; Enable : boolean);
     ////////// Frequency : in Hertz (-1 = do not change)
     ////////// VolumeL :  from 0 to 1 (-1 = do not change)
     ////////// VolumeR :  from 0 to 1 (-1 = do not change)
    //////////// Enabled : true or false ;

 var
  x2 : longint;
 begin
 if Frequency <> -1 then
 begin
 StreamIn[InputIndex].Data.Enabled := Enable;
 StreamIn[InputIndex].Data.freqsine := Frequency ;
 StreamIn[InputIndex].Data.lensine := round(StreamIn[InputIndex].Data.SampleRate / Frequency) ;
 end;
 if VolumeL <> -1 then StreamIn[InputIndex].Data.VLeft := VolumeL;
   
 if VolumeR <> -1 then StreamIn[InputIndex].Data.Vright := VolumeR;
end;
{$endif}

function Tuos_Player.AddIntoFile(Filename: PChar; SampleRate: LongInt;
  Channels: LongInt; SampleFormat: LongInt; FramesCount: LongInt): LongInt;
  /////// Add a Output into audio wav file with Custom parameters
  ////////// FileName : filename of saved audio wav file
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (1:Int32, 2:Int16)
   //////////// FramesCount : -1 default : 65536 div channels
  //  result :  Output Index in array    -1 = error
  //////////// example : OutputIndex1 := AddIntoFile(edit5.Text,-1,-1,0, -1);
var
  x: LongInt;
begin
  result := -1 ;
  x := 0;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := Tuos_OutStream.Create();
  x := Length(StreamOut) - 1;
  StreamOut[x].FileBuffer.ERROR := 0;
  StreamOut[x].Data.Enabled := True;
  StreamOut[x].Data.Filename := filename;
  StreamOut[x].Data.TypePut := 0;
    FillChar(StreamOut[x].FileBuffer, sizeof(StreamOut[x].FileBuffer), 0);
  StreamOut[x].FileBuffer.Data := TMemoryStream.Create;

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
end;

{$IF DEFINED(portaudio)}
 function Tuos_Player.AddIntoDevOut(Device: LongInt; Latency: CDouble;
  SampleRate: LongInt; Channels: LongInt; SampleFormat: LongInt; FramesCount: LongInt): LongInt;
  /////// Add a Output into OUT device with Custom parameters
  //////////// Device ( -1 is default device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536 div channels)
  //////////// example : AddInoDevOut(-1,-1,-1,-1,-1,-1);
var
  x, err: LongInt;
begin
  result := -1 ;
  x := 0;
   err := -1;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := Tuos_OutStream.Create();
  x := Length(StreamOut) - 1;
  StreamOut[x].PAParam.hostApiSpecificStreamInfo := nil;
  if device = -1 then
    StreamOut[x].PAParam.device := Pa_GetDefaultOutputDevice()
  else
    StreamOut[x].PAParam.device := device;
  if SampleRate = -1 then
    StreamOut[x].Data.SampleRate := DefRate
  else
    StreamOut[x].Data.SampleRate := SampleRate;
  if Latency = -1 then

    StreamOut[x].PAParam.SuggestedLatency :=
      ((Pa_GetDeviceInfo(StreamOut[x].PAParam.device)^.
      defaultHighOutputLatency)) * 1
  else
    StreamOut[x].PAParam.SuggestedLatency := CDouble(Latency);

  StreamOut[x].PAParam.SampleFormat := paInt16;
  case SampleFormat of
    0: StreamOut[x].PAParam.SampleFormat := paFloat32;
    1: StreamOut[x].PAParam.SampleFormat := paInt32;
    2: StreamOut[x].PAParam.SampleFormat := paInt16;
  end;
  StreamOut[x].Data.SampleFormat := SampleFormat;

   if Channels = -1 then
    StreamOut[x].PAParam.channelCount := CInt32(2)
  else
    StreamOut[x].PAParam.channelCount := CInt32(Channels);

   StreamOut[x].Data.Channels := StreamOut[x].PAParam.channelCount;

  if FramesCount = -1 then  StreamOut[x].Data.Wantframes :=
  65536 div StreamOut[x].Data.Channels else
  StreamOut[x].Data.Wantframes := FramesCount ;

  SetLength(StreamOut[x].Data.Buffer, StreamOut[x].Data.Wantframes*StreamOut[x].Data.Channels);

  StreamOut[x].Data.TypePut := 1;
  StreamOut[x].Data.Wantframes :=
    length(StreamOut[x].Data.Buffer) div StreamOut[x].Data.channels;
  StreamOut[x].Data.Enabled := True;

  err := Pa_OpenStream(@StreamOut[x].Data.HandleSt, nil,
    @StreamOut[x].PAParam, StreamOut[x].Data.SampleRate, 512, paClipOff, nil, nil);
  StreamOut[x].LoopProc := nil;
  if err <> 0 then
  else
    Result := x;
end;
 {$endif}

{$IF DEFINED(webstream)}
 function Tuos_Player.AddFromURL(URL: PChar; OutputIndex: LongInt;
   SampleFormat: LongInt ; FramesCount: LongInt): LongInt;
/////// Add a Input from Audio URL
  ////////// URL : URL of audio file (like  'http://someserver/somesound.mp3')
  ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
  ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (1024)
  ////////// example : InputIndex := AddFromURL('http://someserver/somesound.mp3',-1,-1,-1);
var
  x, err : LongInt;
  PipeBufferSize : cardinal;
  {$IF DEFINED(sndfile)}
//    sfInfo: TSF_INFO;
   {$endif}
  {$IF DEFINED(mpg123)}
  mpinfo: Tmpg123_frameinfo;
  mpid3v1: Tmpg123_id3v1;
  mpid3v2: Tmpg123_id3v2;
   {$endif}

begin
   result := -1 ;

   // code for internet streaming

  //////////// mpg123
  {$IF DEFINED(mpg123)}
     if (uosLoadResult.MPloadERROR = 0) then
     begin
        x := 0;
    err := -1;
    SetLength(StreamIn, Length(StreamIn) + 1);
    StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create;
    x := Length(StreamIn) - 1;
    err := -1;
    StreamIn[x].Data.LibOpen := -1;
    StreamIn[x].Data.levelEnable := 0;
    StreamIn[x].Data.positionEnable := 0;
    StreamIn[x].Data.levelArrayEnable := 0;

     if FramesCount= -1 then
     PipeBufferSize := $4000 else
     PipeBufferSize := FramesCount;

  CreatePipeHandles(StreamIn[x].InHandle, StreamIn[x].OutHandle, PipeBufferSize);
  StreamIn[x].InPipe := TInputPipeStream.Create(StreamIn[x].InHandle);
  StreamIn[x].OutPipe := TOutputPipeStream.Create(StreamIn[x].OutHandle);

  // this must be before mpg123 functions or it will block waiting for data when the http getter hasn't started yet
  StreamIn[x].httpget := TThreadHttpGetter.Create(url, StreamIn[x].OutPipe);

     Err := -1;

  StreamIn[x].Data.HandleSt := mpg123_new(nil, Err);

  // if err = 0 then writeln('===> mpg123_new => ok.') else writeln('===> mpg123_new NOT ok.') ;

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

      mpg123_replace_reader_handle(StreamIn[x].Data.HandleSt, @mpg_read_stream, @mpg_seek_stream, @mpg_close_stream);

      //   writeln('===> mpg123_replace_reader_handle => ok.');

       Err :=  mpg123_open_handle(StreamIn[x].Data.HandleSt, Pointer(StreamIn[x].InPipe));

   //      writeln('===> mpg123 InHandle = ' + inttostr(StreamIn[x].Data.httpget.InHandle) );
     ///    if err = 0 then writeln('===> mpg123_open_fd => ok.') else
      //    writeln('===> mpg123_open_fd => NOT ok.') ;

       end
       else
       begin
         StreamIn[x].Data.LibOpen := -1;
       end;
         // writeln('===> mpg123_open_fd all => ok.');
       if Err = 0 then

          StreamIn[x].Data.filename := URL ;

          StreamIn[x].Data.Channels := 2;

         if FramesCount = -1 then  StreamIn[x].Data.Wantframes :=   1024  else
         StreamIn[x].Data.Wantframes := FramesCount ;

         SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);

         StreamIn[x].Data.LibOpen := 1;
          // writeln('ok all');
       end
       else
       begin
         StreamIn[x].Data.LibOpen := -1;
        end;
   //  end;

    if err <> 0 then
     begin
       exit;
     end
     else
     begin
       Result := x;
       StreamIn[x].Data.Output := OutputIndex;
       StreamIn[x].Data.Status := 1;
       StreamIn[x].Data.Enabled := True;
       StreamIn[x].Data.Position := 0;
       StreamIn[x].Data.OutFrames := 0;
       StreamIn[x].Data.Poseek := -1;
       StreamIn[x].Data.TypePut := 2;
       StreamIn[x].Data.seekable := false;
       StreamIn[x].LoopProc := nil;

 //  StreamIn[x].Data.httpget.WantedURL(url);

          Err := mpg123_getformat(StreamIn[x].Data.HandleSt,
        StreamIn[x].Data.samplerate, StreamIn[x].Data.channels,
        StreamIn[x].Data.encoding);
         //   writeln('===> mpg123_getformat => ok');

   if err <> 0 then
   begin
      sleep(50);
      Err := mpg123_getformat(StreamIn[x].Data.HandleSt,
        StreamIn[x].Data.samplerate, StreamIn[x].Data.channels,
        StreamIn[x].Data.encoding);
         //   writeln('===> mpg123_getformat => ok');
            end;

       if SampleFormat = -1 then
         StreamIn[x].Data.SampleFormat := 2
       else
         StreamIn[x].Data.SampleFormat := SampleFormat;

         if StreamIn[x].Data.SampleFormat = 2 then
             StreamIn[x].Data.ratio := streamIn[x].Data.Channels
           else
             StreamIn[x].Data.ratio := 2 * streamIn[x].Data.Channels;

       // {
         mpg123_info(StreamIn[x].Data.HandleSt, MPinfo);
         mpg123_id3(StreamIn[x].Data.HandleSt, @mpid3v1, @mpid3v2);

         //  writeln('===> mpg123_infos => ok');
         ////////////// to do : add id3v2
         StreamIn[x].Data.title := trim(mpid3v1.title);
         StreamIn[x].Data.artist := mpid3v1.artist;
         StreamIn[x].Data.album := mpid3v1.album;
         StreamIn[x].Data.date := mpid3v1.year;
         StreamIn[x].Data.comment := mpid3v1.comment;
         StreamIn[x].Data.tag := mpid3v1.tag;
         StreamIn[x].Data.genre := mpid3v1.genre;
         StreamIn[x].Data.samplerateroot :=  StreamIn[x].Data.samplerate ;
         StreamIn[x].Data.hdformat := MPinfo.layer;
         StreamIn[x].Data.frames := MPinfo.framesize;
         StreamIn[x].Data.lengthst := mpg123_length(StreamIn[x].Data.HandleSt);
     //  }

          if StreamIn[x].Data.SampleFormat = 0 then
            mpg123_param(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Channels,
              MPG123_FORCE_FLOAT, 0);
    //  writeln('===> mpg123 all => ok');
         end;
    {$endif}
        end;
    {$ENDIF}

function Tuos_Player.AddFromFile(Filename: PChar; OutputIndex: LongInt;
   SampleFormat: LongInt ; FramesCount: LongInt ): LongInt;
/////// Add a Input from Audio file with Custom parameters
  ////////// FileName : filename of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
  ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536 div channels)
  ////////// example : InputIndex := AddFromFile('/usr/home/test.ogg',-1,-1,-1);
var
  x, err: LongInt;

  {$IF DEFINED(sndfile)}
   sfInfo: TSF_INFO;
   {$endif}

   {$IF DEFINED(mpg123)}
  mpinfo: Tmpg123_frameinfo;
  mpid3v1: Tmpg123_id3v1;
  mpid3v2: Tmpg123_id3v2;
  {$endif}

begin
  result := -1 ;
   if fileexists(filename) then
    begin
    x := 0;
    SetLength(StreamIn, Length(StreamIn) + 1);
    StreamIn[Length(StreamIn) - 1] := Tuos_InStream.Create;
    x := Length(StreamIn) - 1;
    err := -1;
    StreamIn[x].Data.LibOpen := -1;
    StreamIn[x].Data.levelEnable := 0;
    StreamIn[x].Data.positionEnable := 0;
    StreamIn[x].Data.levelArrayEnable := 0;

    {$IF DEFINED(sndfile)}
       if (uosLoadResult.SFloadERROR = 0) then
    begin

      StreamIn[x].Data.HandleSt := sf_open(FileName, SFM_READ, sfInfo);
      (* try to open the file *)
      if StreamIn[x].Data.HandleSt = nil then
      begin
        StreamIn[x].Data.LibOpen := -1;
      end
      else
      begin
        StreamIn[x].Data.LibOpen := 0;
        StreamIn[x].Data.filename := FileName;
        StreamIn[x].Data.channels := SFinfo.channels;
          if FramesCount = -1 then  StreamIn[x].Data.Wantframes := 65536 div StreamIn[x].Data.Channels  else
       StreamIn[x].Data.Wantframes := FramesCount ;

       SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes*StreamIn[x].Data.Channels);

        StreamIn[x].Data.hdformat := SFinfo.format;
        StreamIn[x].Data.frames := SFinfo.frames;
        StreamIn[x].Data.samplerate := SFinfo.samplerate;
        StreamIn[x].Data.samplerateroot := SFinfo.samplerate;
        StreamIn[x].Data.sections := SFinfo.sections;
        StreamIn[x].Data.copyright :=
          sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_COPYRIGHT);
        StreamIn[x].Data.software :=
          sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_SOFTWARE);
        StreamIn[x].Data.comment :=
          sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_COMMENT);
        StreamIn[x].Data.date := sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_DATE);
        StreamIn[x].Data.Lengthst := sfInfo.frames;
        StreamIn[x].Data.Enabled := False;
        err := 0;
      end;
    end;

   {$endif}

    {$IF DEFINED(mpg123)}
     //////////// mpg123
    if ((StreamIn[x].Data.LibOpen = -1)) and (uosLoadResult.MPloadERROR = 0) then
    begin
      Err := -1;

      StreamIn[x].Data.HandleSt := mpg123_new(nil, Err);

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
        mpg123_close(StreamIn[x].Data.HandleSt);
         //// Close handle and reload with forced resolution
        StreamIn[x].Data.HandleSt := nil;
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
        mpg123_id3(StreamIn[x].Data.HandleSt, @mpid3v1, @mpid3v2);
        ////////////// to do : add id2v2
        StreamIn[x].Data.title := trim(mpid3v1.title);
        StreamIn[x].Data.artist := mpid3v1.artist;
        StreamIn[x].Data.album := mpid3v1.album;
        StreamIn[x].Data.date := mpid3v1.year;
        StreamIn[x].Data.comment := mpid3v1.comment;
        StreamIn[x].Data.tag := mpid3v1.tag;
        StreamIn[x].Data.genre := mpid3v1.genre;
        StreamIn[x].Data.samplerateroot :=  StreamIn[x].Data.samplerate ;
        StreamIn[x].Data.hdformat := MPinfo.layer;
        StreamIn[x].Data.frames := MPinfo.framesize;
        StreamIn[x].Data.lengthst := mpg123_length(StreamIn[x].Data.HandleSt);
        StreamIn[x].Data.LibOpen := 1;
      end
      else
      begin
        StreamIn[x].Data.LibOpen := -1;
       end;
    end;
   {$endif}

   {$IF DEFINED(neaac)}
   if (StreamIn[x].Data.LibOpen = -1) and (uosLoadResult.AAloadERROR = 0) then
   begin
     Err:= -1;

     StreamIn[x].AACI:= TAACInfo.Create();

     Case SampleFormat of
       0 : StreamIn[x].AACI:= MP4OpenFile(FileName, FAAD_FMT_FLOAT);
       1 : StreamIn[x].AACI:= MP4OpenFile(FileName, FAAD_FMT_32BIT);
       2 : StreamIn[x].AACI:= MP4OpenFile(FileName, FAAD_FMT_16BIT);
     End;

     if StreamIn[x].AACI <> nil then
     Begin
       Case StreamIn[x].AACI.outputFormat of
          FAAD_FMT_16BIT : StreamIn[x].Data.SampleFormat := 2;
          //FAAD_FMT_24BIT : ;
          FAAD_FMT_32BIT : StreamIn[x].Data.SampleFormat := 1;
          FAAD_FMT_FLOAT : StreamIn[x].Data.SampleFormat := 0;
          //FAAD_FMT_DOUBLE: ;
        end;

       StreamIn[x].Data.filename     := FileName;

       StreamIn[x].Data.HandleSt     := StreamIn[x].AACI.hMP4;

       StreamIn[x].Data.samplerate   := StreamIn[x].AACI.SampleRate;
       StreamIn[x].Data.channels     := StreamIn[x].AACI.Channels;

       Case StreamIn[x].AACI.outputFormat of
          FAAD_FMT_16BIT : StreamIn[x].Data.encoding := MPG123_ENC_SIGNED_16;
          //FAAD_FMT_24BIT : ;
          FAAD_FMT_32BIT : StreamIn[x].Data.encoding := MPG123_ENC_SIGNED_32;
          FAAD_FMT_FLOAT : StreamIn[x].Data.encoding := MPG123_ENC_FLOAT_32;
          //FAAD_FMT_DOUBLE: ;
        end;

       if FramesCount = -1 then
         StreamIn[x].Data.Wantframes :=   65536 div StreamIn[x].Data.Channels
       else
         StreamIn[x].Data.Wantframes := FramesCount ;

       SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes * StreamIn[x].Data.Channels);

       StreamIn[x].Data.title          := StreamIn[x].AACI.Title;
       StreamIn[x].Data.artist         := StreamIn[x].AACI.Artist;
       StreamIn[x].Data.album          := StreamIn[x].AACI.Album;
       StreamIn[x].Data.date           := StreamIn[x].AACI.Date;
       StreamIn[x].Data.comment        := StreamIn[x].AACI.Comment;
       StreamIn[x].Data.tag[0]         := #0;
       StreamIn[x].Data.tag[1]         := #0;
       StreamIn[x].Data.tag[2]         := #0;
       StreamIn[x].Data.genre          := StrToIntDef(StreamIn[x].AACI.Genre, 0);
       StreamIn[x].Data.samplerateroot := StreamIn[x].AACI.SampleRate;
       StreamIn[x].Data.hdformat       := 0;
       StreamIn[x].Data.frames         := 0;
       StreamIn[x].Data.lengthst       := StreamIn[x].AACI.TotalSamples;

       StreamIn[x].Data.Seekable       := StreamIn[x].AACI.Size > 0;

        StreamIn[x].Data.LibOpen :=2 ;
       Err:= 0;
     End;
   end;
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

       StreamIn[x].Data.filename     := FileName;

       StreamIn[x].Data.HandleSt     := @StreamIn[x].pCD; // Uos requires an assigned pointer....

       StreamIn[x].Data.samplerate   := StreamIn[x].pCD^.SampleRate;
       StreamIn[x].Data.channels     := StreamIn[x].pCD^.Channels;

       Case StreamIn[x].pCD^.BitsPerSample of
          16 : StreamIn[x].Data.encoding := MPG123_ENC_SIGNED_16;
       end;

       if FramesCount = -1 then
         StreamIn[x].Data.Wantframes :=   65536 div StreamIn[x].Data.Channels
       else
         StreamIn[x].Data.Wantframes := FramesCount;

       SetLength(StreamIn[x].Data.Buffer, StreamIn[x].Data.Wantframes * StreamIn[x].Data.Channels);

       StreamIn[x].Data.title          := '';
       StreamIn[x].Data.artist         := '';
       StreamIn[x].Data.album          := '';
       StreamIn[x].Data.date           := '';
       StreamIn[x].Data.comment        := '';
       StreamIn[x].Data.tag[0]         := #0;
       StreamIn[x].Data.tag[1]         := #0;
       StreamIn[x].Data.tag[2]         := #0;
       StreamIn[x].Data.genre          := 0;
       StreamIn[x].Data.samplerateroot := StreamIn[x].pCD^.SampleRate;
       StreamIn[x].Data.hdformat       := 0;
       StreamIn[x].Data.frames         := 0;
       StreamIn[x].Data.lengthst       := StreamIn[x].pCD^.TotalSamples;

       StreamIn[x].Data.LibOpen := 3;
       Err:= 0;
     End;
   end;
   {$endif}

   if err <> 0 then
    begin
   result := -1 ;
    StreamIn[Length(StreamIn) - 1].Destroy;
        exit;
    end
    else
    begin
      Result := x;
      StreamIn[x].Data.Output := OutputIndex;
      StreamIn[x].Data.Status := 1;
      StreamIn[x].Data.Enabled := True;
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

      end;
    end;
  end;
end;

procedure Tuos_Player.Execute;
/////////////////////// The Loop Procedure ///////////////////////////////
var
  x, x2, x3, x4, statustemp, rat : LongInt;
  sinevarL, sinevarR : cfloat;
  plugenabled: boolean;
  curpos: cint64;
  BufferplugINFLTMP: TDArFloat;
  BufferplugFL: TDArFloat;

  Bufferst2mo: TDArFloat;

  BufferplugSH: TDArShort;
  BufferplugLO: TDArLong;
  // err: LongInt; // if you want clean buffer
 
  outBytes: longword; /// for AAC
 
  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  msg: TfpgMessageParams;  // for fpgui
    {$endif}

begin
  curpos := 0;

   {$IF not DEFINED(Library)}
     if BeginProc <> nil then
    /////  Execute BeginProc procedure
     {$IF FPC_FULLVERSION>=20701}
     queue(BeginProc);
        {$else}
     {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
   begin
    msg.user.Param1 := -2 ;  // it is the first proc
    fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
   end;
    {$else}
  synchronize(BeginProc);
    {$endif}
    {$endif}
      {$elseif not DEFINED(java)}
    if BeginProc <> nil then
      BeginProc;
       {$else}
    if BeginProc <> nil then
        {$IF FPC_FULLVERSION>=20701}
     queue(@BeginProcjava);
        {$else}
     synchronize(@BeginProcjava);
        {$endif}
      {$endif}
  repeat

   {$IF not DEFINED(Library)}
  if LoopBeginProc <> nil then
    /////  Execute BeginProc procedure
   {$IF FPC_FULLVERSION>=20701}
  queue(LoopBeginProc);
        {$else}
  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
   begin
    msg.user.Param1 := -2 ;  // it is the first proc
    fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
   end;
   {$else}
  synchronize(LoopBeginProc);
  {$endif}
  {$endif}
     {$elseif not DEFINED(java)}
    if loopBeginProc <> nil then
      loopBeginProc;
       {$else}
    if loopBeginProc <> nil then
        {$IF FPC_FULLVERSION>=20701}
     queue(@loopBeginProcjava);
        {$else}
     synchronize(@loopBeginProcjava);
        {$endif}
    {$endif}
   
   //////////// Dealing with input
    for x := 0 to high(StreamIn) do
    begin

      RTLeventWaitFor(evPause);  ///// is there a pause waiting ?
      RTLeventSetEvent(evPause);

      if (StreamIn[x].Data.HandleSt <> nil) and (StreamIn[x].Data.Status > 0) and
        (StreamIn[x].Data.Enabled = True) then
      begin

        if (StreamIn[x].Data.Poseek > -1) and  (StreamIn[x].Data.Seekable = True) then
         begin                    ////// is there a seek waiting ?
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
            3 :
           end;
           curpos := StreamIn[x].Data.Poseek;
           StreamIn[x].Data.Poseek := -1;
            end;

           if (StreamIn[x].Data.positionEnable = 1)  and (StreamIn[x].Data.Seekable = True) then
          StreamIn[x].Data.position := curpos;

        //////// DSPin BeforeBuffProc
        if (StreamIn[x].Data.Status = 1) and (length(StreamIn[x].DSP) > 0) then
          for x2 := 0 to high(StreamIn[x].DSP) do
            if (StreamIn[x].DSP[x2].Enabled = True) and
              (StreamIn[x].DSP[x2].BefFunc <> nil) then
              StreamIn[x].DSP[x2].BefFunc(StreamIn[x].Data, StreamIn[x].DSP[x2].fftdata);
        ///// end DSP BeforeBuffProc

        RTLeventWaitFor(evPause);  ///// Is there a pause waiting ?
        RTLeventSetEvent(evPause);
        
 case StreamIn[x].Data.TypePut of
 
   0:   ///// It is a input from audio file.
          begin
            case StreamIn[x].Data.LibOpen of
              //////////// Here we are, reading the data and store it in buffer
                {$IF DEFINED(sndfile)}
               0: case StreamIn[x].Data.SampleFormat of
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
                 {$endif}
               {$IF DEFINED(mpg123)}
              1:
              begin
                mpg123_read(StreamIn[x].Data.HandleSt, @StreamIn[x].Data.Buffer[0],
                  StreamIn[x].Data.wantframes, StreamIn[x].Data.outframes);
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
               StreamIn[x].Data.outframes := round(StreamIn[x].AACI.lwDataLen div (StreamIn[x].AACI.BitsPerSample div 8))
                else
                StreamIn[x].Data.outframes := 0;
              end;
             {$endif}
             {$IF DEFINED(cdrom)}
              3: 
          Begin
            StreamIn[x].pCD^.pDataLen:= 0;
            Case StreamIn[x].pCD^.BitsPerSample of
            16 : begin
                outBytes    := StreamIn[x].Data.Wantframes;
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
         99: // if nothing was defined
             end;

          end;

   {$IF DEFINED(portaudio)}
   1:   /////// for Input from device
          begin
             for x2 := 0 to StreamIn[x].Data.WantFrames -1 do
              StreamIn[x].Data.Buffer[x2] := cfloat(0.0);      ////// clear input
            Pa_ReadStream(StreamIn[x].Data.HandleSt,
              @StreamIn[x].Data.Buffer[0], StreamIn[x].Data.WantFrames);

           // err := // if you want clean buffer
            StreamIn[x].Data.OutFrames :=
              StreamIn[x].Data.WantFrames * StreamIn[x].Data.Channels;
           //  if err = 0 then StreamIn[x].Data.Status := 1 else StreamIn[x].Data.Status := 0;  /// if you want clean buffer
          end;
   {$endif}

   {$IF DEFINED(webstream)}
    2:  /////// for Input from Internet audio stream.
          begin
   {$IF DEFINED(mpg123)}
           // err := // if you want clear buffer
          mpg123_read(StreamIn[x].Data.HandleSt, @StreamIn[x].Data.Buffer[0],
          StreamIn[x].Data.wantframes, StreamIn[x].Data.outframes);
          //  writeln('===> mpg123_read error => ' + inttostr(err)) ;
          StreamIn[x].Data.outframes :=
          StreamIn[x].Data.outframes div StreamIn[x].Data.Channels;
   {$ENDIF}
         end;
   {$ENDIF}
   
   {$IF DEFINED(synthesizer)}
   3:   /////// for Input from Synthesizer
          begin
     
             x2 := 0 ;
            
             while x2 < StreamIn[x].Data.WantFrames * StreamIn[x].Data.Channels do
             
             begin
           
             if StreamIn[x].Data.Channels = 2 then
             begin
             StreamIn[x].Data.Buffer[x2] := StreamIn[x].Data.VLeft * CFloat((Sin( ( CFloat((x2 div 2)+ StreamIn[x].Data.posLsine)/CFloat( StreamIn[x].Data.lensine) ) * Pi * 2 )));
             StreamIn[x].Data.Buffer[x2+1] := StreamIn[x].Data.VRight * CFloat((Sin( ( CFloat((x2 div 2) + StreamIn[x].Data.posRsine)/CFloat( StreamIn[x].Data.lensine) ) * Pi * 2 )));
             
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
             
             StreamIn[x].Data.Buffer[x2] := StreamIn[x].Data.VLeft * CFloat((Sin( ( CFloat(x2+ StreamIn[x].Data.posLsine)/CFloat( StreamIn[x].Data.lensine) ) * Pi * 2 )));
        
             if StreamIn[x].Data.posLsine +1 > StreamIn[x].Data.lensine - 1  then
             StreamIn[x].Data.posLsine := 0 else
             StreamIn[x].Data.posLsine := StreamIn[x].Data.posLsine +1 ;
        
              inc(x2) ;
             end;
             end;
         
            StreamIn[x].Data.OutFrames :=  StreamIn[x].Data.WantFrames ;
          end;
{$endif}  
          
        end;

        // writeln('check if internet is stopped.');
        //// check if internet stream is stopped.
    {$IF DEFINED(webstream)}
     if (StreamIn[x].Data.TypePut = 2) then if StreamIn[x].httpget.IsRunning = false
     then  StreamIn[x].Data.status := 0; //////// no more data then close the stream
   {$ENDIF}

    if (StreamIn[x].Data.Seekable = True) then if StreamIn[x].Data.OutFrames < 100 then
     StreamIn[x].Data.status := 0;  //////// no more data then close the stream

      if  StreamIn[x].Data.status > 0 then
      begin
    // writeln('positionEnable = 1');
        if (StreamIn[x].Data.positionEnable = 1) then
        begin
        if (StreamIn[x].Data.LibOpen = 1) and (StreamIn[x].Data.SampleFormat < 2) then

          curpos := curpos + (StreamIn[x].Data.OutFrames div
            (StreamIn[x].Data.Channels * 2))
        //// strange outframes float 32 with Mpg123 ?
        else
          curpos := curpos + (StreamIn[x].Data.OutFrames div
            (StreamIn[x].Data.Channels));

        StreamIn[x].Data.position := curpos; // new position
       end;
       // writeln('Getting the level');
        //// Getting the level before DSP procedure
       if (StreamIn[x].Data.levelEnable = 1) or (StreamIn[x].Data.levelEnable = 3) then StreamIn[x].Data := DSPLevel(StreamIn[x].Data);

       //// Adding level in array-level  // ideal for pre-wave form
       if (StreamIn[x].Data.levelArrayEnable = 1) then
       begin
       if (StreamIn[x].Data.levelEnable = 0) or (StreamIn[x].Data.levelEnable = 3) then
       StreamIn[x].Data := DSPLevel(StreamIn[x].Data);

       setlength(uosLevelArray[index][x],length(uosLevelArray[index][x]) +1);
       uosLevelArray[index][x][length(uosLevelArray[index][x]) -1 ] := StreamIn[x].Data.LevelLeft;

       setlength(uosLevelArray[index][x],length(uosLevelArray[index][x]) +1);
       uosLevelArray[index][x][length(uosLevelArray[index][x]) -1 ] := StreamIn[x].Data.LevelRight;
       end;
        //writeln('DSPin AfterBuffProcbefore');
        //////// DSPin AfterBuffProc
        if (StreamIn[x].Data.Status = 1) and (length(StreamIn[x].DSP) > 0) then
          for x2 := 0 to high(StreamIn[x].DSP) do
            if (StreamIn[x].DSP[x2].Enabled = True) then
            begin
          //   writeln('DSPin AfterBuffProc 1');
              
              if (StreamIn[x].DSP[x2].AftFunc <> nil) then
                StreamIn[x].Data.Buffer :=
                  StreamIn[x].DSP[x2].AftFunc(StreamIn[x].Data,
                  StreamIn[x].DSP[x2].fftdata);
            // writeln('DSPin AfterBuffProc 2');
             
  {$IF not DEFINED(Library)}
              if (StreamIn[x].DSP[x2].LoopProc <> nil) then
  {$IF FPC_FULLVERSION>=20701}
          queue(StreamIn[x].DSP[x2].LoopProc);
  {$else}
  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  begin
    msg.user.Param1 := x2 ;   //// the index of the dsp
    msg.user.Param2 := 0;   ////  it is a In DSP
    fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
   end;
   {$else}
   synchronize(StreamIn[x].DSP[x2].LoopProc);
   {$endif}
   {$endif}
   {$elseif not DEFINED(java)}
     if (StreamIn[x].DSP[x2].LoopProc <> nil) then
        StreamIn[x].DSP[x2].LoopProc;
   {$else}
  if (StreamIn[x].DSP[x2].LoopProc <> nil) then
   {$IF FPC_FULLVERSION>=20701}
         queue(@Streamin[x].DSP[x2].LoopProcjava);
   {$else}
       synchronize(@Streamin[x].DSP[x2].LoopProcjava);
   {$endif}
   {$endif}

    end;

///// Ended DSPin AfterBuffProc
// writeln('the synchro main loop procedurebefore');
        ///////////// The synchro main loop procedure
  {$IF not DEFINED(Library)}
   if StreamIn[x].LoopProc <> nil then
   {$IF FPC_FULLVERSION>=20701}
   queue(StreamIn[x].LoopProc);
   {$else}
   {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
    begin
    msg.user.Param1 := -1 ;  //// it is the main loop procedure
    msg.user.Param2 := 0 ;////  it is a INput procedure
    fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
   end;
   {$else}
   synchronize(StreamIn[x].LoopProc);
   {$endif}
   {$endif}

    {$elseif not DEFINED(java)}
   if (StreamIn[x].LoopProc <> nil) then
   StreamIn[x].LoopProc;
    {$else}
   if (StreamIn[x].LoopProc <> nil) then
   {$IF FPC_FULLVERSION>=20701}
   queue(@Streamin[x].LoopProcjava);
   {$else}
   synchronize(@Streamin[x].LoopProcjava);
   {$endif}
   {$endif}

    //// Getting the level after DSP procedure
  if ((StreamIn[x].Data.levelEnable = 2) or (StreamIn[x].Data.levelEnable = 3)) then StreamIn[x].Data := DSPLevel(StreamIn[x].Data);

  //// Adding level in array-level
       if (StreamIn[x].Data.levelArrayEnable = 2) then
       begin
       if (StreamIn[x].Data.levelEnable = 0) or (StreamIn[x].Data.levelEnable = 1) then
       StreamIn[x].Data := DSPLevel(StreamIn[x].Data);

       setlength(uosLevelArray[index][x],length(uosLevelArray[index][x]) +1);
       uosLevelArray[index][x][length(uosLevelArray[index][x]) -1 ] := StreamIn[x].Data.LevelLeft;

       setlength(uosLevelArray[index][x],length(uosLevelArray[index][x]) +1);
       uosLevelArray[index][x][length(uosLevelArray[index][x]) -1 ] := StreamIn[x].Data.LevelRight;
       end;

      end;

   end;

  end;   //////////////// end for low(StreamIn[x]) to high(StreamIn[x])


 ////////////////// Seeking if StreamIn is terminated

   if status <> 0 then
   begin
    statustemp := 0 ;
    for x := 0 to high(StreamIn) do
    begin
    if (StreamIn[x].Data.TypePut <> 1) and (StreamIn[x].Data.Status <> 0)
    then statustemp := StreamIn[x].Data.Status else if
    (StreamIn[x].Data.TypePut = 1) then statustemp := status ;
    end ;
    if statustemp <> status then status := statustemp;
   end;

    RTLeventWaitFor(evPause);  ///// is there a pause waiting ?
    RTLeventSetEvent(evPause);

    //////////////////////// Give Buffer to Output
    if status <> 0 then
    begin

  for x := 0 to high(StreamOut) do

      if ((StreamOut[x].Data.TypePut = 1) and (StreamOut[x].Data.HandleSt <> nil) and
        (StreamOut[x].Data.Enabled = True)) or
        ( (StreamOut[x].Data.TypePut = 0)  and (StreamOut[x].Data.Enabled = True))
      then
      begin

        for x2 := 0 to high(StreamOut[x].Data.Buffer) do
          StreamOut[x].Data.Buffer[x2] := cfloat(0.0);      ////// clear output

        for x2 := 0 to high(StreamIn) do
          if  (StreamIn[x2].Data.status > 0) and (StreamIn[x2].Data.HandleSt <> nil) and
            (StreamIn[x2].Data.Enabled = True) and
            ((StreamIn[x2].Data.Output = x) or (StreamIn[x2].Data.Output = -1)) then
            begin
            for x3 := 0 to high(StreamIn[x2].Data.Buffer) do
              StreamOut[x].Data.Buffer[x3] :=
                cfloat(StreamOut[x].Data.Buffer[x3]) +
                cfloat(StreamIn[x2].Data.Buffer[x3]);
             
            case StreamIn[x2].Data.LibOpen of
            0:  StreamOut[x].Data.outframes := StreamIn[x2].Data.outframes ; // sndfile
            1:  StreamOut[x].Data.outframes := StreamIn[x2].Data.outframes div StreamIn[x2].Data.Channels; // mpg123
            2:  StreamOut[x].Data.outframes := StreamIn[x2].Data.outframes ; // aac
            3:  StreamOut[x].Data.outframes := StreamIn[x2].Data.outframes ; // CDRom
            end;  
            
            end;   
            
        //////// copy buffer-in into buffer-out

        //////// DSPOut AfterBuffProc
        if (length(StreamOut[x].DSP) > 0) then
          for x3 := 0 to high(StreamOut[x].DSP) do
            if (StreamOut[x].DSP[x3].Enabled = True) then
            begin
              if (StreamOut[x].DSP[x3].AftFunc <> nil) then
                StreamOut[x].Data.Buffer :=
                  StreamOut[x].DSP[x3].AftFunc(StreamOut[x].Data,
                  StreamOut[x].DSP[x3].fftdata);

                {$IF not DEFINED(Library)}
        if (StreamOut[x].DSP[x3].LoopProc <> nil) then
            {$IF FPC_FULLVERSION>=20701}
         queue(StreamOut[x].DSP[x3].LoopProc);
        {$else}
 {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
 begin
    msg.user.Param1 := x3 ;   //// the index of the dsp
    msg.user.Param2 := 1;   //// it is a OUT DSP
    fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
   end;
 {$else}
   synchronize(StreamOut[x].DSP[x3].LoopProc);
    {$endif}
    {$endif}

     {$elseif not DEFINED(java)}
     if (StreamOut[x].DSP[x3].LoopProc <> nil) then
        StreamOut[x].DSP[x3].LoopProc;
       {$else}
       if (StreamOut[x].DSP[x3].LoopProc <> nil) then
      {$IF FPC_FULLVERSION >= 20701}
         queue(@StreamOut[x].DSP[x3].LoopProcjava);
        {$else}
       synchronize(@StreamOut[x].DSP[x3].LoopProcjava);
       {$endif}
         {$endif}
    end;    ///// end DSPOut AfterBuffProc

        ///// apply plugin (ex: SoundTouch Library)

        plugenabled := False;

        if (length(Plugin) > 0) then
        begin
          for x3 := 0 to high(PlugIn) do
            if Plugin[x3].Enabled = True then
              plugenabled := True;
        end;

        if plugenabled = True then
        begin
          ////// convert buffer if needed
          case StreamOut[x].Data.SampleFormat of
            1: StreamOut[x].Data.Buffer :=
                CvInt32toFloat32(StreamOut[x].Data.Buffer);
            2: StreamOut[x].Data.Buffer :=
                CvInt16toFloat32(StreamOut[x].Data.Buffer);
          end;

          // transfer buffer out to temp
          SetLength(BufferplugINFLTMP, (StreamIn[x2].Data.outframes) *
            StreamIn[x2].Data.Channels);
          for x3 := 0 to length(BufferplugINFLTMP) - 1 do
            BufferplugINFLTMP[x3] := cfloat(StreamOut[x].Data.Buffer[x3]);

          //////////// dealing with input plugin
          for x3 := 0 to high(PlugIn) do
          begin
            if PlugIn[x3].Enabled = True then
            begin

            {$IF DEFINED(bs2b)}
               BufferplugFL := Plugin[x3].PlugFunc(BufferplugINFLTMP,
                Plugin[x3].PlugHandle, Plugin[x3].Abs2b, StreamIn[x2].Data,
                 Plugin[x3].param1, Plugin[x3].param2, Plugin[x3].param3, Plugin[x3].param4,
                 Plugin[x3].param5, Plugin[x3].param6, Plugin[x3].param7, Plugin[x3].param8);
              {$endif}

            if (length(PlugIn) > 1) then
            begin
            // TO CHECK : works only if SoundTouch is last or only plugin
               for x4 := 0 to length(BufferplugFL) - 1 do
             BufferplugINFLTMP[x4] := cfloat(BufferplugFL[x4]);
            end;
           end;        
            
            end;


        ///////////////////////////////////////////////////////////////////////////
        //   writeln('give the processed');
        ///// give the processed input to output

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
                  //
                  BufferplugSH := CvFloat32ToInt16(BufferplugFL);

                end;
              end;

              case StreamOut[x].Data.TypePut of

                 {$IF DEFINED(portaudio)}
                  1:     /////// Give to output device
                begin
                  case StreamOut[x].Data.SampleFormat of
                    0:
                    begin
                      Pa_WriteStream(StreamOut[x].Data.HandleSt,
                        @BufferplugFL[0], Length(BufferplugFL) div
                        StreamIn[x2].Data.Channels);
                    end;
                    1:
                    begin
                      BufferplugLO := CvFloat32ToInt32(BufferplugFL);
                     Pa_WriteStream(StreamOut[x].Data.HandleSt,
                        @BufferplugLO[0], Length(BufferplugLO) div
                        StreamIn[x2].Data.Channels);
                    end;
                    2:
                    begin
                      BufferplugSH := CvFloat32ToInt16(BufferplugFL);
                   
                   // err := // if you want clean buffer
                     Pa_WriteStream(StreamOut[x].Data.HandleSt,
                        @BufferplugSH[0], Length(BufferplugSH) div
                        StreamIn[x2].Data.Channels);
                    end;
                    
                  end;
                  // if err <> 0 then status := 0;   // if you want clean buffer ...
                end;
                {$endif}

                0:
                begin  /////// Give to wav file

                if (StreamOut[x].FileBuffer.wChannels = 1) and (StreamIn[x2].Data.Channels = 2) then
                begin
                 Bufferst2mo :=    CvSteroToMono(BufferplugFL, Length(BufferplugFL) div 2);
                 BufferplugSH := CvFloat32ToInt16(Bufferst2mo);
                  end else
                 begin
                  BufferplugSH := CvFloat32ToInt16(BufferplugFL);
                  end;
                 StreamOut[x].FileBuffer.Data.WriteBuffer(BufferplugSH[0],
                    Length(BufferplugSH));

                end;
              end;
           end;
           end
        else   /////////// No plugin

        begin
          //////// Convert Input format into Output format if needed:

          case StreamOut[x].Data.SampleFormat of
            0: case StreamIn[x2].Data.SampleFormat of
                1: StreamOut[x].Data.Buffer :=
                    CvInt32toFloat32(StreamOut[x].Data.Buffer);
                2: StreamOut[x].Data.Buffer :=
                    CvInt16toFloat32(StreamOut[x].Data.Buffer);
              end;
          end;
          /////// End convert.

          ///////// Finally give buffer to output
          case StreamOut[x].Data.TypePut of
         {$IF DEFINED(portaudio)}
          1:     /////// Give to output device
            begin
           
            // err := // if you want clean buffer

            if (StreamIn[x2].Data.TypePut <> 1) or
            ((StreamIn[x2].Data.TypePut = 1) and (StreamIn[x2].Data.Channels > 1)) then
              begin
              Pa_WriteStream(StreamOut[x].Data.HandleSt,
                @StreamOut[x].Data.Buffer[0], StreamIn[x2].Data.outframes div
                StreamIn[x2].Data.ratio);
              end else
             begin
              Pa_WriteStream(StreamOut[x].Data.HandleSt,
                @StreamOut[x].Data.Buffer[0], StreamIn[x2].Data.outframes);
              end;

          // if err <> 0 then status := 0;   // if you want clean buffer ...

             end;
          {$endif}

            0:     /////// Give to wav file
            begin

             case StreamOut[x].Data.SampleFormat of
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
        end;
       end;


    {$IF not DEFINED(Library)}
    if LoopEndProc <> nil then

    /////  Execute LoopEndProc procedure
    {$IF FPC_FULLVERSION>=20701}
     queue(LoopEndProc);
      {$else}
  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  begin
    msg.user.Param1 := -2 ;  // it is the first proc
    fpgPostMessage(self, refer, MSG_CUSTOM1, msg);
   end;
  {$else}
  synchronize(LoopEndProc);
    {$endif}
    {$endif}
       {$elseif not DEFINED(java)}
     if LoopEndProc <> nil then
      LoopEndProc;
       {$else}
       if LoopEndProc <> nil then

      {$IF FPC_FULLVERSION>=20701}
        queue(@endprocjava);
         {$else}
      synchronize(@endprocjava); /////  Execute EndProc procedure
            {$endif}

    {$endif}

   if length(StreamIn) > 1 then  ////// clear buffer for multi-input
   for x2 := 0 to high(StreamIn) do
   for x3 := 0 to high(StreamIn[x2].Data.Buffer) do
   StreamIn[x2].Data.Buffer[x3] := cfloat(0.0);

  if (nofree = true) and (status = 0)  then
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
      end;

        {$IF not DEFINED(Library)}
      if EndProc <> nil then
       {$IF FPC_FULLVERSION>=20701}
             queue(EndProc);
             {$else}
      synchronize(EndProc); /////  Execute EndProc procedure
            {$endif}

       {$elseif not DEFINED(java)}
     if (EndProc <> nil) then
        EndProc;
       {$else}
     if (EndProc <> nil) then
      {$IF FPC_FULLVERSION>=20701}
        queue(@endprocjava);
         {$else}
      synchronize(@endprocjava); /////  Execute EndProc procedure
         {$endif}

       {$endif}
     RTLeventResetEvent(evPause);
    Status := 2;
  end;

 until status = 0;

  ////////////////////////////////////// End of Loop ////////////////////////////////////////

  ////////////////////////// Terminate Thread
  if status = 0 then
  begin
      // writeln(' status = 0');
   
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
        {$endif}
       
        {$IF DEFINED(bs2b)}
        if Plugin[x].Name = 'bs2b' then
        begin
         bs2b_close(Plugin[x].Abs2b); 
        end;
       {$endif}
      end;
    end;
    
  //  writeln('x := 0 to high(StreamIn EndFunc)');
    // EndFunc of DSP In
   
    for x := 0 to high(StreamIn) do
    begin
      if (length(StreamIn[x].DSP) > 0) then
          for x2 := 0 to high(StreamIn[x].DSP) do
          if (StreamIn[x].DSP[x2].EndFunc <> nil) then
        StreamIn[x].DSP[x2].EndFunc(StreamIn[x].Data, StreamIn[x].DSP[x2].fftdata);
    end;
      
 //    writeln('x := 0 to high(StreamOut endfunc)');          
    // EndFunc of DSP Out
   
   
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
           99: // if nothing was defined
            end;
            
        {$IF DEFINED(portaudio)}
        1: begin
            Pa_StopStream(StreamIn[x].Data.HandleSt);
            Pa_CloseStream(StreamIn[x].Data.HandleSt);
          end;
        {$endif}
           
        {$IF DEFINED(webstream)}
        2: begin
            mpg123_close(StreamIn[x].Data.HandleSt);
            mpg123_delete(StreamIn[x].Data.HandleSt);
            StreamIn[x].httpget.Terminate;
            StreamIn[x].httpget.Free;
           end;
        {$ENDIF}
       
        end;

       for x := 0 to high(StreamOut) do
    begin
       {$IF DEFINED(portaudio)}
       if (StreamOut[x].Data.HandleSt <> nil) and (StreamOut[x].Data.TypePut = 1) then
      begin
       Pa_StopStream(StreamOut[x].Data.HandleSt);
       Pa_CloseStream(StreamOut[x].Data.HandleSt);
      end;
       {$endif}

      if (StreamOut[x].Data.TypePut = 0) then
      begin
        WriteWave(StreamOut[x].Data.Filename, StreamOut[x].FileBuffer);
        StreamOut[x].FileBuffer.Data.Free;
      end;
    end;
    
    //  writeln('EndProc---');

         {$IF not DEFINED(Library)}
      if EndProc <> nil then
       {$IF FPC_FULLVERSION>=20701}
       begin
       queue(EndProc);
       end;
         {$else}
      synchronize(EndProc); /////  Execute EndProc procedure
            {$endif}

       {$elseif not DEFINED(java)}
     if (EndProc <> nil) then
        EndProc;
       {$else}
     if (EndProc <> nil) then
      {$IF FPC_FULLVERSION>=20701}
        queue(@endprocjava);
         {$else}
      synchronize(@endprocjava); /////  Execute EndProc procedure
         {$endif}

       {$endif}
       isAssigned := false ;
      //   writeln('EndProc');
    end;
end;

procedure Tuos_Player.onTerminate() ;
begin
if ifflat = true then
  begin
  uosPlayers[Index].destroy;
uosPlayersStat[Index] := -1 ;
end else destroy;
end;

 
procedure Tuos_Init.unloadPlugin(PluginName: Pchar);
               ////// Unload Plugin... 
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
   {$IF DEFINED(windows)}
    Set8087CW(old8087cw);
    {$endif}
   
end;

function Tuos_Init.InitLib(): LongInt;
begin
  Result := -1;
  {$IF DEFINED(mpg123)}
  if (uosLoadResult.MPloadERROR = 0) then
    if mpg123_init() = MPG123_OK then
    begin
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
    if uosLoadResult.PAinitError = 0 then
    begin
      Result := 0;
      DefDevOut := Pa_GetDefaultOutputDevice();
      DefDevOutInfo := Pa_GetDeviceInfo(DefDevOut);
      DefDevOutAPIInfo := Pa_GetHostApiInfo(DefDevOutInfo^.hostApi);
      DefDevIn := Pa_GetDefaultInputDevice();
      if DefDevInInfo <> nil then
    DefDevInAPIInfo := Pa_GetHostApiInfo(DefDevInInfo^.hostApi);
        end;
  end;
    {$endif}

  if (Result = -1) and (uosLoadResult.SFloadERROR = 0) then
    Result := 0;
end;

function Tuos_Init.loadlib(): LongInt;
begin
  Result := 0;
  uosLoadResult.PAloadERROR := -1;
  uosLoadResult.SFloadERROR := -1;
  uosLoadResult.MPloadERROR := -1;
  uosLoadResult.AAloadError := -1;
  uosLoadResult.STloadERROR := -1;
  uosLoadResult.BSloadERROR := -1;
  
   {$IF DEFINED(portaudio)}
    if (PA_FileName <>  nil) and (PA_FileName <>  '') then
  begin
    if not fileexists(PA_FileName) then
      uosLoadResult.PAloadERROR := 1
    else
    if Pa_Load(PA_FileName) then
    begin
      Result := 0;
      uosLoadResult.PAloadERROR := 0;
      uosDefaultDeviceOut := Pa_GetDefaultOutPutDevice();
      uosDefaultDeviceIn := Pa_GetDefaultInPutDevice();
      uosDeviceCount := Pa_GetDeviceCount();
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
    if not fileexists(SF_FileName) then
    begin
      Result := -1;
      uosLoadResult.SFloadERROR := 1;
    end
    else
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
    if not fileexists(MP_FileName) then
    begin
      Result := -1;
      uosLoadResult.MPloadERROR := 1;
    end
    else
    begin
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
    end;
  end
  else
    uosLoadResult.MPloadERROR := -1;
   {$endif}

   {$IF DEFINED(neaac)}
     if (AA_FileName <> nil) and (AA_FileName <>  '') and (M4_FileName <> nil) and (M4_FileName <>  '') then
     begin
       if (not fileexists(AA_FileName)) or (not fileexists(M4_FileName)) then
       begin
         Result := -1;
         uosLoadResult.AAloadERROR := 1;
       end
       else
       begin
         if aa_load(AnsiString(M4_FileName), AnsiString(AA_FileName)) then
         begin
           uosLoadResult.AAloadERROR := 0;
           if (uosLoadResult.MPloadERROR = -1) and (uosLoadResult.PAloadERROR = -1) and
             (uosLoadResult.SFloadERROR = -1) And (uosLoadResult.STloadERROR = -1) then
             Result := 0;
         end
         else
         begin
           uosLoadResult.AAloadERROR := 2;
           Result := -1;
         end;
       end;
     end
     else
       uosLoadResult.AAloadERROR := -1;
   {$endif}

     if Result = 0 then
    Result := InitLib();
end;

function uos_loadPlugin(PluginName, PluginFilename: PChar) : LongInt;
  begin
 Result := -1; 
   {$IF DEFINED(soundtouch)}
  if (lowercase(PluginName) = 'soundtouch') and (PluginFileName <> nil) and (PluginFileName <>  '')  then
  begin
    if not fileexists(PluginFileName) then
    begin
      Result := -1;
      uosLoadResult.STloadERROR := 1;
    end
    else
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
  end
  else
    uosLoadResult.STloadERROR := -1;
   {$endif}
   
    {$IF DEFINED(bs2b)}
  if (lowercase(PluginName) = 'bs2b') and (PluginFileName <> nil) and (PluginFileName <>  '') then
  begin
    if not fileexists(PluginFileName) then
    begin
      Result := -1;
      uosLoadResult.BSloadERROR := 1;
    end
    else
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
  end
  else
    uosLoadResult.BSloadERROR := -1;
   {$endif}
  
end;
 
function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName: PChar) : LongInt;
  begin
   result := -1 ;
   if not assigned(uosInit) then begin

  {$IF DEFINED(windows)}
  old8087cw := Get8087CW;
  Set8087CW($133f);
    {$endif}

   uosInit := TUOS_Init.Create;   //// Create Libraries Loader-Init
   end;
   
   uosInit.PA_FileName := PortAudioFileName;
   uosInit.SF_FileName := SndFileFileName;
   uosInit.MP_FileName := Mpg123FileName;
   uosInit.AA_FileName:= FaadFileName;
   uosInit.M4_FileName:= Mp4ffFileName;
   
   result := uosInit.loadlib ;
  end;

function uos_GetVersion() : LongInt ;
begin
result := uos_version ;
end;

procedure uos_unloadlib() ;
begin
 if assigned(uosInit) then
  begin
 uosInit.unloadlib ;
 end;
end;

procedure uos_unloadlibCust(PortAudio, SndFile, Mpg123, AAC: boolean);
                    ////// Custom Unload libraries... if true, then unload the library. You may unload what and when you want...
begin
 uosInit.unloadlibcust(PortAudio, SndFile, Mpg123, AAC) ;
end;

procedure uos_UnloadPlugin(PluginName: PChar);
        ////// load plugin...
begin
 uosInit.unloadplugin(PluginName) ;
end;


{$IF DEFINED(portaudio)}
procedure uos_GetInfoDevice();
var
  x: LongInt;
  devinf: PPaDeviceInfo;
  apiinf: PPaHostApiInfo;
begin
  x := 0;

  SetLength(uosDeviceInfos, Pa_GetDeviceCount());
  uosDefaultDeviceOut := Pa_GetDefaultOutPutDevice();
  uosDefaultDeviceIn := Pa_GetDefaultInPutDevice();

   uosDeviceCount := Pa_GetDeviceCount();

//  {
  while x < Pa_GetDeviceCount()  do
  begin
    uosDeviceInfos[x].DeviceNum := x;

    devinf := Pa_GetDeviceInfo(x);
    apiinf := Pa_GetHostApiInfo(devinf^.hostApi);

    uosDeviceInfos[x].HostAPIName := apiinf^._name;
    uosDeviceInfos[x].DeviceName := devinf^._name;

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
 // }
end;

function uos_GetInfoDeviceStr() : PansiChar ;
var
  x : LongInt ;
devtmp , bool1, bool2 : string;
begin
 uos_GetInfoDevice() ;
  x := 0;
  devtmp := '';
 while   x < length(uosDeviceInfos) do
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
result := pansichar( devtmp + ' ' );
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
/// todo
end;

procedure Tuos_OutStream.LoopProcjava();
begin
/// todo
end;

{$endif}

constructor Tuos_Init.Create;
begin
  SetExceptionMask(GetExceptionMask + [exZeroDivide] + [exInvalidOp] +
    [exDenormalized] + [exOverflow] + [exPrecision]);
  uosLoadResult.PAloadERROR := -1;
  uosLoadResult.SFloadERROR := -1;
  uosLoadResult.BSloadERROR := -1;
  uosLoadResult.STloadERROR := -1;
  uosLoadResult.MPloadERROR := -1;
  uosLoadResult.AAloadERROR := -1;
  uosLoadResult.PAinitError := -1;
  uosLoadResult.MPinitError := -1;
  if ifflat = true then
  begin
  setlength(uosPlayers,0) ;
  setlength(uosPlayersStat,0) ;
  end;
  PA_FileName := nil; // PortAudio
  SF_FileName := nil; // SndFile
  MP_FileName := nil; // Mpg123
  AA_FileName := nil; // Faad
  M4_FileName := nil; // Mp4ff
  Plug_ST_FileName := nil; // Plugin SoundTouch
  Plug_BS_FileName := nil; // Plugin bs2b
end;

 {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
 constructor Tuos_Player.Create(CreateSuspended: boolean; AParent: TObject;
  const StackSize: SizeUInt);
    {$else}
  constructor Tuos_Player.Create(CreateSuspended: boolean;
  const StackSize: SizeUInt);
    {$endif}
begin
  inherited Create(CreateSuspended, StackSize);
  FreeOnTerminate := false;
  Priority :=  tpTimeCritical;
  evPause := RTLEventCreate;
    {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
   refer := aparent; //// for fpGUI
    {$endif}
   isAssigned := true ;
  status := 2;
  BeginProc := nil;
  EndProc := nil;
  loopBeginProc := nil;
  loopEndProc := nil;
end;

destructor Tuos_Player.Destroy;
var
  x: LongInt;
begin
  RTLeventdestroy(evPause);
 
  if length(StreamOut) > 0 then
    for x := 0 to high(StreamOut) do
     freeandnil(StreamOut[x]);
 //     StreamOut[x].Free;

//  { 
  if length(StreamIn) > 0 then
    for x := 0 to high(StreamIn) do
     freeandnil(StreamIn[x]);
  //    StreamIn[x].Free;
     
// }
  if length(Plugin) > 0 then
    for x := 0 to high(Plugin) do
      freeandnil(Plugin[x]);
    //  Plugin[x].Free;
   
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
  x: LongInt;
begin
   {$IF DEFINED(neaac)}
   if assigned(AACI) then
begin
 if assigned(AACI.fsStream) then
   begin
  // AACI.fsStream.Free;
   freeandnil(AACI.fsStream);
   sleep(100);
   end;
  // AACI.free;
   freeandnil(AACI);
   sleep(100);
end;
  {$endif}
 
  if length(DSP) > 0 then
    for x := 0 to high(DSP) do
      freeandnil(DSP[x]);
   
   inherited Destroy;
  
end;

destructor Tuos_OutStream.Destroy;
var
  x: LongInt;
begin
 if assigned(FileBuffer.Data) then 
 freeandnil(FileBuffer.Data);
 
 
  if length(DSP) > 0 then
    for x := 0 to high(DSP) do
     // DSP[x].Free;
      freeandnil(DSP[x]);
 
    inherited Destroy;
end;

procedure Tuos_Init.unloadlibCust(PortAudio, SndFile, Mpg123, AAc: boolean);
               ////// Custom Unload libraries... if true, then unload the library. You may unload what and when you want...
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
end;

procedure uos_Free();
var
x : integer;
begin
{
if ifflat = true then
begin
if length(uosPlayers) > 0 then
 for x := 0 to length(uosPlayers) -1 do
  begin
  uosPlayers[x].destroy;
  end;
end;
}
if assigned(uosInit) then freeandnil(uosInit);
 uos_unloadlib() ;
end;

end.
