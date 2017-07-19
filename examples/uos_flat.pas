{This unit is part of United Openlibraries of Sound (uos)}

{  License : modified LGPL.
  Fred van Stappen fiens@hotmail.com }

// This is the "Flat Layer" of uos => for universal methods.

unit uos_flat;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

// For custom configuration of directive to compiler --->  define.inc
{$I define.inc}

interface

uses

  {$IF DEFINED(Java)}
  uos_jni,
  {$endif}

  {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  fpg_base,
  {$ENDIF}

  ctypes, classes, math, SysUtils, uos;
 
  {$IF DEFINED(bs2b)}
  const
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

 type

  {$if DEFINED(java)}
 TProc = JMethodID ;
  {$else}
 TProc = procedure of object;
  {$endif}

 type
  {$if not defined(fs32bit)}
  Tcount_t  = cint64;  { used for file sizes  }
  {$else}
  Tcount_t  = cint;
  {$endif}

  type
  TuosF_Data = Tuos_Data;
  TuosF_FFT = Tuos_FFT ;
  TuosF_BufferInfos = Tuos_BufferInfos;

{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  const
  MSG_CUSTOM1 = FPGM_USER + 1;
  {$ENDIF}

// General public procedure/function (accessible for library uos too)

{$IF DEFINED(portaudio)}
procedure uos_GetInfoDevice();

function uos_GetInfoDeviceStr() : Pansichar ;
{$endif}

function uos_LoadLib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfileFileName: PChar) : cint32;
  // load libraries... if libraryfilename = nil =>  do not load it...  You may load what and when you want...  
  // PortAudio => needed for dealing with audio-device
  // SndFile => needed for dealing with ogg, vorbis, flac and wav audio-files
  // Mpg123 => needed for dealing with mp* audio-files
  // Mp4ff and Faad => needed for dealing with acc, m4a audio-files
  // opusfile => needed for dealing with opus audio-files

  // If some libraries are not needed, replace it by "nil", for example : uos_loadlib(PortAudioFileName, SndFileFileName, nil, nil, nil, nil, nil)

procedure uos_unloadlib();
  // Unload all libraries... Do not forget to call it before close application...

procedure uos_free;  
  // Free uos;
  // To use when program terminate.

procedure uos_unloadlibCust(PortAudio, SndFile, Mpg123, AAC, opus: boolean);
  // Custom Unload libraries... if true, then delete the library. You may unload what and when you want...

function uos_loadPlugin(PluginName, PluginFilename: PChar) : cint32;
  // load plugin...

{$IF DEFINED(shout)}
function uos_LoadServerLib(ShoutFileName, OpusFileName : PChar) : cint32; 
  // Shout => needed for dealing with IceCast server
  // Opus => needed for dealing with encoding opus stream
  
procedure uos_unloadServerLib();
  // Unload server libraries... Do not forget to call it before close application...
{$endif}  
  
procedure uos_UnloadPlugin(PluginName: PChar);

{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
function uos_CreatePlayer(PlayerIndex: cint32; AParent: TObject) : boolean;
{$else}
function uos_CreatePlayer(PlayerIndex: cint32): boolean;
{$endif}

{$IF DEFINED(portaudio)}
function uos_AddIntoDevOut(PlayerIndex: cint32): cint32;
  // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, soundcard, ...)
  // If PlayerIndex already exists, it will be overwriten...

  // Add a Output into Device Output with custom parameters
function uos_AddIntoDevOut(PlayerIndex: cint32; Device: cint32; Latency: CDouble;
  SampleRate: cint32; Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ): cint32;
  // Add a Output into Device Output with default parameters
  // PlayerIndex : Index of a existing Player
  // Device ( -1 is default device )
  // Latency  ( -1 is latency suggested ) )
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (= 65536)
  //  result : Output Index in array  , -1 = error
  // example : OutputIndex1 := uos_AddIntoDevOut(0,-1,-1,-1, -1, 0,-1);
 {$endif}
 
function uos_AddFromFile(PlayerIndex: cint32; Filename: PChar): cint32;
  // Add a input from audio file with default parameters

function uos_AddFromFile(PlayerIndex: cint32; Filename: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32): cint32;
  // Add a input from audio file with custom parameters
  // PlayerIndex : Index of a existing Player
  // FileName : filename of audio file
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (65536)
  //  result : Input Index in array  -1 = error
  // example : InputIndex1 := uos_AddFromFile(0, edit5.Text,-1,0);

function uos_AddIntoMemoryBuffer(PlayerIndex: cint32; outmemory: PDArFloat) : cint32;
  // Add a Output into memory buffer
  // outmemory : pointer of buffer to use to store memory.
  // example : OutputIndex1 := uos_AddIntoMemoryBuffer(0, pointer(bufmemory));

function uos_AddFromMemoryBuffer(PlayerIndex: cint32; MemoryBuffer: TDArFloat; Bufferinfos: Tuos_bufferinfos;
 OutputIndex: cint32; FramesCount: cint32): cint32;
  // Add a input from memory buffer with custom parameters
  // MemoryBuffer : the buffer
  // Bufferinfos : infos of the buffer
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')  // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)  // SampleRate : delault : -1 (44100)  // FramesCount : default : -1 (4096)
  //  result :  Input Index in array  -1 = error
  // example : InputIndex1 := AddFromMemoryBuffer(mybuffer, buffinfos,-1,1024); 

function uos_AddFromMemoryStream(PlayerIndex: cint32; MemoryStream: TMemoryStream; 
         TypeAudio: cint32; OutputIndex: cint32; SampleFormat: cint32 ; FramesCount: cint32): cint32;
  // MemoryStream : Memory stream of encoded audio.
  // TypeAudio : default : -1 --> 0 (0: flac, ogg, wav; 1: mp3; 2:opus)
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (4096)
  //  result :  Input Index in array  -1 = error
  // example : InputIndex1 := AddFromMemoryStream(0, mymemorystream,-1,-1,0,1024);

function uos_AddFromFileIntoMemory(PlayerIndex: cint32; Filename: PChar): cint32;
  // Add a input from audio file with default parameters
  
function uos_AddFromFileIntoMemory(PlayerIndex: cint32; Filename: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32): cint32;
  // Add a input from audio file and store it into memory with custom parameters
  // PlayerIndex : Index of a existing Player
  // FileName : filename of audio file
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (65536)
  //  result : Input Index in array  -1 = error
  // example : InputIndex1 := uos_AddFromFile(0, edit5.Text,-1,0);  

 {$IF DEFINED(shout)}
function uos_AddIntoIceServer(PlayerIndex: cint32; SampleRate : cint; Channels: cint; SampleFormat: cint;
 EncodeType: cint; Port: cint; Host: pchar; User: pchar; Password: pchar; MountFile :pchar): cint32;
  // Add a Output into a IceCast server for audio-web-streaming  // SampleRate : delault : -1 (48100)
  // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  // EncodeType : default : -1 (0:Music) (0: Music, 1:Voice)
  // SampleFormat : -1 default : float32 : (0:float32, 1:Int16)
  // Port : default : -1 (= 8000)
  // Host : default : 'def' (= '127.0.0.1')
  // User : default : 'def' (= 'source')
  // Password : default : 'def' (= 'hackme')
  // MountFile : default : 'def' (= '/example.opus')
  //  result :  Output Index in array  -1 = error
  {$endif}

{$IF DEFINED(webstream)}
function uos_AddFromURL(PlayerIndex: cint32; URL: PChar): cint32;
  // Add a Input from Audio URL with default parameters

function uos_AddFromURL(PlayerIndex: cint32; URL: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32; AudioFormat: cint32 ; ICYon : boolean): cint32;
  // Add a Input from Audio URL with custom parameters
  // URL : URL of audio file 
  // OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other cint32 : existing Output
  // SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (4096)
  // AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
  // example : InputIndex := AddFromURL(0,'http://someserver/somesound.mp3',-1,-1,-1,-1);
{$ENDIF}

function uos_AddIntoFile(PlayerIndex: cint32; Filename: PChar; SampleRate: cint32;
  Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ; FileFormat: cint32): cint32;
  // Add a Output into audio wav file with custom parameters from TFileStream
  // PlayerIndex : Index of a existing Player
  // FileName : filename of saved audio wav file
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
  // SampleFormat : default : -1 (2:Int16) (1:Int32, 2:Int16)
  // FramesCount : default : -1 (= 65536)
  // FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom);
  //  result :Output Index in array  -1 = error
  // example : OutputIndex1 := uos_AddIntoFile(0,edit5.Text,-1,-1, 0, 1);

function uos_AddIntoFile(PlayerIndex: cint32; Filename: PChar): cint32;
  // Add a Output into audio wav file with Default parameters from TFileStream
  // PlayerIndex : Index of a existing Player
  // FileName : filename of saved audio wav file

function uos_AddIntoFileFromMem(PlayerIndex: cint32; Filename: PChar; SampleRate: LongInt;  
      Channels: LongInt; SampleFormat: LongInt ; FramesCount: LongInt; FileFormat: cint32): LongInt;  
    // Add a Output into audio wav file with Custom parameters
  // FileName : filename of saved audio wav file
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
  //  SampleFormat : -1 default : Int16 : (1:Int32, 2:Int16)
  // FramesCount : -1 default : 65536 div channels
  // FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom);
  //  result :  Output Index in array    -1 = error
  // example : OutputIndex1 := AddIntoFileFromMem(0, edit5.Text,-1,-1,0, -1);

function uos_AddIntoFileFromMem(PlayerIndex: cint32; Filename: PChar): cint32;
  // Add a Output into audio wav file with Default parameters from TMemoryStream
  // PlayerIndex : Index of a existing Player
  // FileName : filename of saved audio wav file

{$IF DEFINED(portaudio)}
function uos_AddFromDevIn(PlayerIndex: cint32; Device: cint32; Latency: CDouble;
  SampleRate: cint32; OutputIndex: cint32;
  SampleFormat: cint32; FramesCount : cint32): cint32;
  // Add a Input from Device Input with custom parameters
  // PlayerIndex : Index of a existing Player
  // Device ( -1 is default Input device )
  // Latency  ( -1 is latency suggested ) )
  // SampleRate : delault : -1 (44100)
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (65536)
  //  result :  Output Index in array
  // example : OutputIndex1 := uos_AddFromDevIn(0,-1,-1,-1,-1,-1);

function uos_AddFromDevIn(PlayerIndex: cint32): cint32;
  // Add a Input from Device Input with default parameters
  // PlayerIndex : Index of a existing Player
{$endif}

function uos_AddFromEndlessMuted(PlayerIndex: cint32; Channels : cint32; FramesCount: cint32): cint32;
  // Add a input from Endless Muted dummy sine wav
  // FramesCount = FramesCount of input-to-follow 
  // Channels = Channels of input-to-follow.
 
{$IF DEFINED(synthesizer)}
function uos_AddFromSynth(PlayerIndex: cint32; Frequency: float; VolumeL: float; VolumeR: float;
Duration : cint32;  OutputIndex: cint32;
  SampleFormat: cint32 ; SampleRate: cint32 ; FramesCount : cint32): cint32;
  // Add a input from Synthesizer with custom parameters
  // Frequency : default : -1 (440 htz)
  // VolumeL : default : -1 (= 1) (from 0 to 1) => volume left
  // VolumeR : default : -1 (= 1) (from 0 to 1) => volume right
  // Duration : default :  -1 (= 1000)  => duration in msec (0 = endless)
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (0: Float32) (0: Float32, 1:Int32, 2:Int16)
  // SampleRate : delault : -1 (44100)
  // FramesCount : -1 default : 1024
  //  result :  Input Index in array  -1 = error
  // example : InputIndex1 := AddFromSynth(0,880,-1,-1,-1,-1,-1,-1);
  
procedure uos_InputSetSynth(PlayerIndex: cint32; InputIndex: cint32; Frequency: float;
 VolumeL: float; VolumeR: float; Duration: cint32; Enable : boolean);
  // Frequency : in Hertz (-1 = do not change)
  // VolumeL :  from 0 to 1 (-1 = do not change)
  // VolumeR :  from 0 to 1 (-1 = do not change)
  // Duration : in msec (-1 = do not change)
  // Enabled : true or false ;
{$endif}
  
procedure uos_BeginProc(PlayerIndex: cint32; Proc: TProc);
  // Assign the procedure of object to execute  at begining, before loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input

procedure uos_EndProc(PlayerIndex: cint32; Proc: TProc);
  // Assign the procedure of object to execute  at end, after loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input

procedure uos_EndProcOnly(PlayerIndex: cint32; Proc: TProconly);
  // Assign the procedure  (not of object) to execute  at end, after loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input

procedure uos_LoopBeginProc(PlayerIndex: cint32; Proc: TProc);
  // Assign the procedure of object to execute  at begin of loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input

procedure uos_LoopEndProc(PlayerIndex: cint32; Proc: TProc);
  // Assign the procedure of object to execute  at end of loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input

procedure uos_LoopProcIn(PlayerIndex: cint32; InIndex: cint32; Proc: TProc);
  // Assign the procedure of object to execute inside the loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input

procedure uos_LoopProcOut(PlayerIndex: cint32; OutIndex: cint32; Proc: TProc);
  // Assign the procedure of object to execute inside the loop
  // PlayerIndex : Index of a existing Player
  // OutIndex : Index of a existing Output

{$IF DEFINED(noiseremoval)}
procedure uos_InputAddDSPNoiseRemoval(PlayerIndex: cint32; InputIndex: cint32);
  
procedure uos_InputSetDSPNoiseRemoval(PlayerIndex: cint32; InputIndex: cint32; Enable: boolean);

procedure uos_OutputAddDSPNoiseRemoval(PlayerIndex: cint32; OutputIndex: cint32);
  
procedure uos_OutputSetDSPNoiseRemoval(PlayerIndex: cint32; OutputIndex: cint32; Enable: boolean);
{$endif} 

function uos_InputAddDSP1ChanTo2Chan(PlayerIndex: cint32; InputIndex: cint32): cint32;
  //  Convert mono 1 channel input to stereo 2 channels input.
  // Works only if the input is mono 1 channel othewise stereo 2 chan is keeped.
  // InputIndex : InputIndex of a existing Input
  //  result :  index of DSPIn in array
  // example  DSPIndex1 := InputAddDSP1ChanTo2Chan(InputIndex1);
  
function uos_InputAddDSPVolume(PlayerIndex: cint32; InputIndex: cint32; VolLeft: double;
  VolRight: double) : cint32 ;
  // DSP Volume changer
  // PlayerIndex : Index of a existing Player
  // InputIndex : InputIndex of a existing Input
  // VolLeft : Left volume
  // VolRight : Right volume
   //  result :  index of DSPIn in array
  // example  uos_InputAddDSPVolume(0,InputIndex1,1,1);

procedure uos_OutputAddDSPVolume(PlayerIndex: cint32; OutputIndex: cint32; VolLeft: double;
  VolRight: double) ;
  // DSP Volume changer
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // VolLeft : Left volume
  // VolRight : Right volume
  //  result : -1 nothing created, otherwise index of DSPIn in array
  // example  DSPIndex1 := uos_OutputAddDSPVolume(o,oututIndex1,1,1);

procedure uos_InputSetDSPVolume(PlayerIndex: cint32; InputIndex: cint32;
  VolLeft: double; VolRight: double; Enable: boolean);
  // InputIndex : InputIndex of a existing Input
  // PlayerIndex : Index of a existing Player
  // VolLeft : Left volume
  // VolRight : Right volume
  // Enable : Enabled
  // example  uos_InputSetDSPVolume(0,InputIndex1,DSPIndex1,1,0.8,True);
  
procedure uos_OutputSetDSPVolume(PlayerIndex: cint32; OutputIndex: cint32;
  VolLeft: double; VolRight: double; Enable: boolean);
  // OutputIndex : OutputIndex of a existing Output
  // PlayerIndex : Index of a existing Player
  // VolLeft : Left volume
  // VolRight : Right volume
  // Enable : Enabled
  // example  uos_OutputSetDSPVolume(0,outputIndex1,DSPIndex1,1,0.8,True);
  
function uos_InputAddDSP(PlayerIndex: cint32; InputIndex: cint32; BeforeFunc: TFunc;
  AfterFunc: TFunc; EndedFunc: TFunc; Proc: TProc): cint32;
  // add a DSP procedure for input
  // PlayerIndex : Index of a existing Player
  // InputIndex : Input Index of a existing input
  // BeforeFunc : Function to do before the buffer is filled
  // AfterFunc : Function to do after the buffer is filled
  // EndedFunc : Function to do at end of thread
  // LoopProc : external procedure of object to synchronize after DSP done
  //  result : -1 nothing created, otherwise index of DSPin in array  (DSPinIndex)
  // example : DSPinIndex1 := uos_InputAddDSP(0,InputIndex1,@beforereverse,@afterreverse,nil);

procedure uos_InputSetDSP(PlayerIndex: cint32; InputIndex: cint32; DSPinIndex: cint32; Enable: boolean);
  // PlayerIndex : Index of a existing Player
  // InputIndex : Input Index of a existing input
  // DSPIndexIn : DSP Index of a existing DSP In
  // Enable :  DSP enabled
  // example : uos_InputSetDSP(0,InputIndex1,DSPinIndex1,True);

function uos_OutputAddDSP(PlayerIndex: cint32; OutputIndex: cint32; BeforeFunc: TFunc;
  AfterFunc: TFunc; EndedFunc: TFunc; Proc: TProc): cint32;  
  // usefull if multi output
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // BeforeFunc : Function to do before the buffer is filled
  // AfterFunc : Function to do after the buffer is filled just before to give to output
  // EndedFunc : Function to do at end of thread
  // LoopProc : external procedure of object to synchronize after DSP done
  //  result : index of DSPout in array
  // example :DSPoutIndex1 := uos_OutputAddDSP(0,OutputIndex1,nil,@volumeproc,nil,nil);

procedure uos_OutputSetDSP(PlayerIndex: cint32; OutputIndex: cint32; DSPoutIndex: cint32; Enable: boolean);
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // DSPoutIndex : DSPoutIndex of existing DSPout
  // Enable :  DSP enabled
  // example : uos_OutputSetDSP(0,OutputIndex1,DSPoutIndex1,True);

function uos_InputAddFilter(PlayerIndex: cint32; InputIndex: cint32; LowFrequency: cint32;
  HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
  AlsoBuf: boolean; Proc: TProc): cint32 ;
  // PlayerIndex : Index of a existing Player
  // InputIndex : InputIndex of a existing Input
  // LowFrequency : Lowest frequency of filter
  // HighFrequency : Highest frequency of filter
  // Gain : gain to apply to filter
  // TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  // fBandPass = 3, fHighPass = 4, fLowPass = 5)
  // AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  // LoopProc : External procedure to execute after DSP done
  //  result : index of DSPIn in array  -1 = error
  // example :FilterInIndex1 := uos_InputAddFilter(0,InputIndex1,6000,16000,1,2,true,nil);

procedure uos_InputSetFilter(PlayerIndex: cint32; InputIndex: cint32; FilterIndex: cint32;
  LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
  TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; Proc: TProc);
  // PlayerIndex : Index of a existing Player
  // InputIndex : InputIndex of a existing Input
  // DSPInIndex : DSPInIndex of existing DSPIn
  // LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
  // HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
  // Gain : gain to apply to filter
  // TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  // fBandPass = 3, fHighPass = 4, fLowPass = 5)
  // AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  // LoopProc : External procedure to execute after DSP done
  // Enable :  Filter enabled
  // example : uos_InputSetFilter(0,InputIndex1,FilterInIndex1,-1,-1,-1,False,True,nil);

function uos_OutputAddFilter(PlayerIndex: cint32; OutputIndex: cint32; LowFrequency: cint32;
  HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
  AlsoBuf: boolean; Proc: TProc): cint32;
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // LowFrequency : Lowest frequency of filter
  // HighFrequency : Highest frequency of filter
  // Gain : gain to apply to filter
  // TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  // fBandPass = 3, fHighPass = 4, fLowPass = 5)
  // AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  // LoopProc : External procedure to execute after DSP done
  //  result : index of DSPOut in array  -1 = error
  // example :FilterOutIndex1 := uos_OutputAddFilter(0,OutputIndex1,6000,16000,1,true,nil);

procedure uos_OutputSetFilter(PlayerIndex: cint32; OutputIndex: cint32; FilterIndex: cint32;
  LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
  TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; Proc: TProc);
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // FilterIndex : DSPOutIndex of existing DSPOut
  // LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
  // HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
  // Gain : gain to apply to filter
  // TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  // fBandPass = 3, fHighPass = 4, fLowPass = 5)
  // AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  // Enable :  Filter enabled
  // LoopProc : External procedure to execute after DSP done
  // example : uos_OutputSetFilter(0,OutputIndex1,FilterOutIndex1,1000,1500,-1,True,True,nil);

function uos_AddPlugin(PlayerIndex: cint32; PlugName: PChar; SampleRate: cint32;
  Channels: cint32): cint32 ;
  // Add a plugin , result is PluginIndex
  // PlayerIndex : Index of a existing Player
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
  // 'soundtouch' and 'bs2b' PlugName is registred.

{$IF DEFINED(soundtouch)}
procedure uos_SetPluginSoundTouch(PlayerIndex: cint32; PluginIndex: cint32; Tempo: cfloat;
  Pitch: cfloat; Enable: boolean);
  // PluginIndex : PluginIndex Index of a existing Plugin.
  // PlayerIndex : Index of a existing Player
{$endif}

{$IF DEFINED(bs2b)}
procedure uos_SetPluginBs2b(PlayerIndex: cint32; PluginIndex: cint32;
 level: CInt32; fcut: CInt32; feed: CInt32; Enable: boolean);
  // PluginIndex : PluginIndex Index of a existing Plugin.
{$endif}

function uos_GetStatus(PlayerIndex: cint32) : cint32 ;
  // Get the status of the player : -1 => error,  0 => has stopped, 1 => is running, 2 => is paused.

procedure uos_InputSeek(PlayerIndex: cint32; InputIndex: cint32; pos: Tcount_t);
  // change position in sample

procedure uos_InputSeekSeconds(PlayerIndex: cint32; InputIndex: cint32; pos: cfloat);
  // change position in seconds

procedure uos_InputSeekTime(PlayerIndex: cint32; InputIndex: cint32; pos: TTime);
  // change position in time format

procedure uos_InputSetEnable(PlayerIndex: cint32; InputIndex: cint32; enabled: boolean);
  // set enable true or false (usefull for multi input)

procedure uos_OutputSetEnable(PlayerIndex: cint32; OutputIndex: cint32; enabled: boolean);
  // set enable true or false (usefull for multi outputput)

function uos_InputLength(PlayerIndex: cint32; InputIndex: cint32): cint32;
  // InputIndex : InputIndex of existing input
  //  result : Length of Input in samples

function uos_InputLengthSeconds(PlayerIndex: cint32; InputIndex: cint32): cfloat;
  // InputIndex : InputIndex of existing input
  //  result : Length of Input in seconds

function uos_InputLengthTime(PlayerIndex: cint32; InputIndex: cint32): TTime;
  // InputIndex : InputIndex of existing input
  //  result : Length of Input in time format

function uos_InputPosition(PlayerIndex: cint32; InputIndex: cint32): cint32;
  // InputIndex : InputIndex of existing input
  // result : current postion in sample

procedure uos_InputSetFrameCount(PlayerIndex: cint32; InputIndex: cint32 ; framecount : cint32);
  // set number of frames to be done. (usefull for recording and level precision)

procedure uos_InputSetLevelEnable(PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);
  // set level calculation (default is 0)
  // InputIndex : InputIndex of existing input
  // 0 => no calcul
  // 1 => calcul before all DSP procedures.
  // 2 => calcul after all DSP procedures.
  // 3 => calcul before and after all DSP procedures.

procedure uos_InputSetPositionEnable(PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);
  // set position calculation (default is 1)
  // InputIndex : InputIndex of existing input
  // 0 => no calcul
  // 1 => calcul position.

procedure uos_InputSetArrayLevelEnable(PlayerIndex: cint32; InputIndex: cint32 ; levelcalc : cint32);
  // set add level calculation in level-array (default is 0)
  // 0 => no calcul
  // 1 => calcul before all DSP procedures.
  // 2 => calcul after all DSP procedures.

function uos_InputGetArrayLevel(PlayerIndex: cint32; InputIndex: cint32) : TDArFloat;

function uos_InputGetLevelLeft(PlayerIndex: cint32; InputIndex: cint32): double;
  // InputIndex : InputIndex of existing input
  // result : left level(volume) from 0 to 1

function uos_InputGetLevelRight(PlayerIndex: cint32; InputIndex: cint32): double;
  // InputIndex : InputIndex of existing input
  // result : right level(volume) from 0 to 1

function uos_InputPositionSeconds(PlayerIndex: cint32; InputIndex: cint32): float;
  // InputIndex : InputIndex of existing input
  //  result : current postion of Input in seconds

function uos_InputPositionTime(PlayerIndex: cint32; InputIndex: cint32): TTime;
  // InputIndex : InputIndex of existing input
  //  result : current postion of Input in time format

function uos_InputUpdateTag(PlayerIndex: cint32;InputIndex: cint32): boolean;
// for mp3 and opus files only

{$IF DEFINED(webstream) and DEFINED(mpg123)}
function uos_InputUpdateICY(PlayerIndex: cint32; InputIndex: cint32; var icy_data : pchar): integer;
// for mp3 only
{$endif}

function uos_InputGetTagTitle(PlayerIndex: cint32; InputIndex: cint32): pchar;
function uos_InputGetTagArtist(PlayerIndex: cint32; InputIndex: cint32): pchar;
function uos_InputGetTagAlbum(PlayerIndex: cint32; InputIndex: cint32): pchar;
function uos_InputGetTagDate(PlayerIndex: cint32; InputIndex: cint32): pchar;
function uos_InputGetTagComment(PlayerIndex: cint32; InputIndex: cint32): pchar;
function uos_InputGetTagTag(PlayerIndex: cint32; InputIndex: cint32): pchar;
  // Tag infos

function uos_InputGetSampleRate(PlayerIndex: cint32; InputIndex: cint32): cint32;
  // InputIndex : InputIndex of existing input
  // result : default sample rate

function uos_InputGetChannels(PlayerIndex: cint32; InputIndex: cint32): cint32;
  // InputIndex : InputIndex of existing input
  // result : default channels

procedure uos_PlayEx(PlayerIndex: cint32; no_free: Boolean; nloop: Integer; paused: boolean= false); 
// Start playing with free at end as parameter and assign loop

procedure uos_Play(PlayerIndex: cint32; nloop: Integer = 0) ;  // Start playing

Procedure uos_PlayPaused(PlayerIndex: cint32; nloop: Integer = 0) ;  // Start play paused with loop

Procedure uos_PlayNoFree(PlayerIndex: cint32; nloop: Integer = 0) ;  // Start playing but do not free the player after stop

Procedure uos_PlayNoFreePaused(PlayerIndex: cint32; nloop: Integer = 0) ;  // Start play paused with loop but not free player at end
  
Procedure uos_FreePlayer(PlayerIndex: cint32) ;  // Works only when PlayNoFree() was used: free the player

procedure uos_RePlay(PlayerIndex: cint32);  // Resume playing after pause

procedure uos_Stop(PlayerIndex: cint32);  // Stop playing and free thread

procedure uos_Pause(PlayerIndex: cint32);  // Pause playing

function uos_GetVersion() : cint32 ;  // version of uos

function uos_SetGlobalEvent(PlayerIndex: cint32; isenabled : boolean) : boolean;
  // Set the RTL Events Global (will pause/start/replay all the players synchro with same rtl event)) 
  // result : true if set ok.

function uos_File2Buffer(Filename: Pchar; SampleFormat: cint32 ; outmemory: TDArFloat; var bufferinfos: Tuos_BufferInfos ): TDArFloat;
  // Create a memory buffer of a audio file.
  // FileName : filename of audio file  
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // Outmemory : the buffer to store data.
  // bufferinfos : the infos of the buffer.
  //  result :  The memory buffer
  // example : buffmem := uos_File2buffer(edit5.Text,0,buffmem, buffinfos);

procedure uos_File2File(FilenameIN: Pchar; FilenameOUT: Pchar; SampleFormat: cint32 ; typeout: cint32 );
  // Create a audio file from a audio file.
  // FileNameIN : filename of audio file IN (ogg, flac, wav, mp3, opus, aac,...)
  // FileNameOUT : filename of audio file OUT (wav, pcm, custom)
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // typeout : Type of out file (-1:default=wav, 0:wav, 1:pcm, 2:custom)  
  // example : InputIndex1 := uos_File2File(edit5.Text,0,buffmem); 

var
  uosDeviceInfos: array of Tuos_DeviceInfos;
  uosLoadResult: Tuos_LoadResult;
  uosDeviceCount: cint32;
  uosDefaultDeviceIn: cint32;
  uosDefaultDeviceOut: cint32;
 
implementation

function PlayersNotFree: Boolean; 
Var 
 i: Integer; 
begin 
 if uosPlayersStat <> nil then 
  for i:= 0 to Length(uosPlayersStat)-1 do 
   if uosPlayersStat[i] <> -1 then 
   begin 
    Result:= True; 
    Exit; 
   end; 
 Result:= False; 
end; 

function PlayerNotFree(indexplayer : integer): Boolean; 
begin 
 if uosPlayersStat <> nil then
  if uosPlayersStat[indexplayer] <> -1 then 
  begin
   Result:= True;
   Exit;
  end;
 Result:= False; 
end; 

{$IF DEFINED(noiseremoval)}
procedure uos_InputAddDSPNoiseRemoval(PlayerIndex: cint32; InputIndex: cint32);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].StreamIn[InputIndex].data.DSPNoiseIndex :=
  uosPlayers[PlayerIndex].InputAddDSPNoiseRemoval(InputIndex);
end;
  
procedure uos_InputSetDSPNoiseRemoval(PlayerIndex: cint32; InputIndex: cint32; Enable: boolean);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].InputSetDSPNoiseRemoval(InputIndex, Enable);
end;

procedure uos_OutputAddDSPNoiseRemoval(PlayerIndex: cint32; OutputIndex: cint32);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].StreamOut[OutputIndex].data.DSPNoiseIndex :=
  uosPlayers[PlayerIndex].OutputAddDSPNoiseRemoval(OutputIndex);
end;
  
procedure uos_OutputSetDSPNoiseRemoval(PlayerIndex: cint32; OutputIndex: cint32; Enable: boolean);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].OutputSetDSPNoiseRemoval(OutputIndex, Enable);
end;
{$endif} 

function uos_SetGlobalEvent(PlayerIndex: cint32; isenabled : boolean) : boolean;
  // Set the RTL Events Global (will pause/start/replay all the players synchro with same rtl event)) 
  // result : true if set ok.
begin
result := false;
if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].SetGlobalEvent(isenabled);
end;

function uos_InputAddDSPVolume(PlayerIndex: cint32; InputIndex: cint32; VolLeft: double;
  VolRight: double) : cint32;
begin
result:= -1;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  begin
  uosPlayers[PlayerIndex].StreamIn[InputIndex].Data.DSPVolumeIndex := uosPlayers[PlayerIndex].InputAddDSPVolume(InputIndex, VolLeft, VolRight);
  result := uosPlayers[PlayerIndex].StreamIn[InputIndex].Data.DSPVolumeIndex;
  end;
end;
  // DSP Volume changer
  // PlayerIndex : Index of a existing Player
  // InputIndex : InputIndex of a existing Input
  // VolLeft : Left volume
  // VolRight : Right volume
  //  result : -1 nothing created, otherwise index of DSPIn in array
  // example  DSPIndex1 := uos_InputAddDSPVolume(0,InputIndex1,1,1);

procedure uos_OutputAddDSPVolume(PlayerIndex: cint32; OutputIndex: cint32; VolLeft: double;
  VolRight: double);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].StreamOut[OutputIndex].Data.DSPVolumeIndex := uosPlayers[PlayerIndex].OutputAddDSPVolume(OutputIndex, VolLeft, VolRight);
end;
  // DSP Volume changer
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // VolLeft : Left volume
  // VolRight : Right volume
  //  result : -1 nothing created, otherwise index of DSPIn in array
  // example  DSPIndex1 := uos_OutputAddDSPVolume(0,InputIndex1,1,1);

procedure uos_InputSetDSPVolume(PlayerIndex: cint32; InputIndex: cint32;
  VolLeft: double; VolRight: double; Enable: boolean);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].InputSetDSPVolume(InputIndex,  uosPlayers[PlayerIndex].StreamIn[InputIndex].Data.DSPVolumeIndex, VolLeft, VolRight, Enable);
end;
  // InputIndex : InputIndex of a existing Input
  // PlayerIndex : Index of a existing Player
  // VolLeft : Left volume
  // VolRight : Right volume
  // Enable : Enabled
  // example  uos_InputSetDSPVolume(0,InputIndex1,1,0.8,True);

procedure uos_OutputSetDSPVolume(PlayerIndex: cint32; OutputIndex: cint32;
  VolLeft: double; VolRight: double; Enable: boolean);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].OutputSetDSPVolume(OutputIndex, uosPlayers[PlayerIndex].StreamOut[OutputIndex].Data.DSPVolumeIndex, VolLeft, VolRight, Enable);
end;
  // OutputIndex : OutputIndex of a existing Output
  // PlayerIndex : Index of a existing Player
  // VolLeft : Left volume
  // VolRight : Right volume
  // Enable : Enabled
  // example  uos_OutputSetDSPVolume(0,InputIndex1,1,0.8,True);

{$IF DEFINED(webstream) and DEFINED(mpg123)} 
function uos_InputUpdateICY(PlayerIndex: cint32; InputIndex: cint32; var icy_data : pchar): integer;
// for mp3 only
begin
 Result := -1;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputUpdateICY(InputIndex, icy_data) ;
 end; 
{$endif} 

function uos_InputUpdateTag(PlayerIndex: cint32;InputIndex: cint32): boolean;
// for mp3 and opus files only
 begin
 Result := false;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputUpdateTag(InputIndex) ;
 end;
  
function uos_InputGetTagTitle(PlayerIndex: cint32; InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputGetTagTitle(InputIndex) ;
 end;

function uos_InputGetTagArtist(PlayerIndex: cint32; InputIndex: cint32): pchar;
 begin
 Result :=nil;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputGetTagArtist(InputIndex) ;
 end;

function uos_InputGetTagAlbum(PlayerIndex: cint32; InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputGetTagAlbum(InputIndex) ;
 end;

function uos_InputGetTagComment(PlayerIndex: cint32; InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputGetTagComment(InputIndex) ;
 end;

function uos_InputGetTagTag(PlayerIndex: cint32; InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputGetTagTag(InputIndex) ;
 end;
 
function uos_InputGetTagDate(PlayerIndex: cint32; InputIndex: cint32): pchar;
 begin
 Result := nil;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputGetTagDate(InputIndex) ;
 end;

function uos_InputAddDSP(PlayerIndex: cint32; InputIndex: cint32; BeforeFunc : TFunc;
  AfterFunc: TFunc; EndedFunc: TFunc; Proc: TProc): cint32;
  // add a DSP procedure for input
  // PlayerIndex : Index of a existing Player
  // InputIndex : Input Index of a existing input
  // BeforeFunc : Function to do before the buffer is filled
  // AfterFunc : Function to do after the buffer is filled
  // EndedFunc : Function to do at end of thread
  // LoopProc : external procedure to do after the buffer is filled
  //  result : index of DSPin in array  (DSPinIndex)
  // example : DSPinIndex1 := uos_InputAddDSP(0,InputIndex1,@beforereverse,@afterreverse,nil);
begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputAddDSP(InputIndex, BeforeFunc, AfterFunc, EndedFunc, Proc) ;
end;

procedure uos_InputSetDSP(PlayerIndex: cint32; InputIndex: cint32; DSPinIndex: cint32; Enable: boolean);
  // PlayerIndex : Index of a existing Player
  // InputIndex : Input Index of a existing input
  // DSPIndexIn : DSP Index of a existing DSP In
  // Enable :  DSP enabled
  // example : uos_InputSetDSP(0,InputIndex1,DSPinIndex1,True);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].InputSetDSP(InputIndex, DSPinIndex, Enable) ;
end;

function uos_OutputAddDSP(PlayerIndex: cint32; OutputIndex: cint32; BeforeFunc: TFunc;
  AfterFunc: TFunc; EndedFunc : TFunc; Proc: TProc): cint32;  // usefull if multi output
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // BeforeFunc : Function to do before the buffer is filled
  // AfterFunc : Function to do after the buffer is filled just before to give to output
  // EndedFunc : Function to do at end of thread
  // LoopProc : external procedure to do after the buffer is filled
  //  result :index of DSPout in array
  // example :DSPoutIndex1 := uos_OutputAddDSP(0,OutputIndex1,@volumeproc,nil,nil);
begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].OutputAddDSP(OutputIndex, BeforeFunc, AfterFunc, EndedFunc, Proc) ;
end;

procedure uos_OutputSetDSP(PlayerIndex: cint32; OutputIndex: cint32; DSPoutIndex: cint32; Enable: boolean);
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // DSPoutIndex : DSPoutIndex of existing DSPout
  // Enable :  DSP enabled
  // example : uos_OutputSetDSP(0,OutputIndex1,DSPoutIndex1,True);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].OutputSetDSP(OutputIndex, DSPoutIndex, Enable) ;
end;

function uos_InputAddFilter(PlayerIndex: cint32; InputIndex: cint32; LowFrequency: cint32;
  HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
  AlsoBuf: boolean; Proc: TProc): cint32;
  // PlayerIndex : Index of a existing Player
  // InputIndex : InputIndex of a existing Input
  // LowFrequency : Lowest frequency of filter
  // HighFrequency : Highest frequency of filter
  // Gain : gain to apply to filter
  // TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  // fBandPass = 3, fHighPass = 4, fLowPass = 5)
  // AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  // LoopProc : External procedure to execute after DSP done
  //  result :  index of DSPIn in array  -1 = error
  // example :FilterInIndex1 := uos_InputAddFilter(0,InputIndex1,6000,16000,1,2,true,nil);
begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].InputAddFilter(InputIndex, LowFrequency, HighFrequency, Gain, TypeFilter,
  AlsoBuf, Proc) ;
end;

procedure uos_InputSetFilter(PlayerIndex: cint32; InputIndex: cint32; FilterIndex: cint32;
  LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
  TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; Proc: TProc);
  // PlayerIndex : Index of a existing Player
  // InputIndex : InputIndex of a existing Input
  // DSPInIndex : DSPInIndex of existing DSPIn
  // LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
  // HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
  // Gain : gain to apply to filter
  // TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  // fBandPass = 3, fHighPass = 4, fLowPass = 5)
  // AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  // LoopProc : External procedure to execute after DSP done
  // Enable :  Filter enabled
  // example : uos_InputSetFilter(0,InputIndex1,FilterInIndex1,-1,-1,-1,False,True,nil);
begin
if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSetFilter(InputIndex, FilterIndex, LowFrequency, HighFrequency, Gain,
  TypeFilter, AlsoBuf, Enable, Proc);
end;

function uos_OutputAddFilter(PlayerIndex: cint32; OutputIndex: cint32; LowFrequency: cint32;
  HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
  AlsoBuf: boolean; Proc: TProc): cint32;
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // LowFrequency : Lowest frequency of filter
  // HighFrequency : Highest frequency of filter
  // Gain : gain to apply to filter
  // TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  // fBandPass = 3, fHighPass = 4, fLowPass = 5)
  // AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  // LoopProc : External procedure to execute after DSP done
  //  result : index of DSPOut in array
  // example :FilterOutIndex1 := uos_OutputAddFilter(0,OutputIndex1,6000,16000,1,true,nil);
begin
 result := -1 ;
if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
result := uosPlayers[PlayerIndex].OutputAddFilter(OutputIndex, LowFrequency, HighFrequency, Gain, TypeFilter,
  AlsoBuf, Proc) ;
end;

procedure uos_OutputSetFilter(PlayerIndex: cint32; OutputIndex: cint32; FilterIndex: cint32;
  LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
  TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; Proc: TProc);
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of a existing Output
  // FilterIndex : DSPOutIndex of existing DSPOut
  // LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
  // HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
  // Gain : gain to apply to filter
  // TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  // fBandPass = 3, fHighPass = 4, fLowPass = 5)
  // AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  // Enable :  Filter enabled
  // LoopProc : External procedure to execute after DSP done
  // example : uos_OutputSetFilter(0,OutputIndex1,FilterOutIndex1,1000,1500,-1,True,True,nil);
begin
if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].OutputSetFilter(OutputIndex, FilterIndex, LowFrequency, HighFrequency, Gain,
  TypeFilter, AlsoBuf, Enable, Proc);
end;

{$IF DEFINED(portaudio)}
function uos_AddFromDevIn(PlayerIndex: cint32; Device: cint32; Latency: CDouble;
  SampleRate: cint32; OutputIndex: cint32;
  SampleFormat: cint32; FramesCount : cint32): cint32;
  // Add a Input from Device Input with custom parameters
  // PlayerIndex : Index of a existing Player
  // Device ( -1 is default Input device )
  // Latency  ( -1 is latency suggested ) )
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (65536)
  //  result : Output Index in array , -1 is error
  // example : OutputIndex1 := uos_AddFromDevIn(0,-1,-1,-1,-1,-1,-1);
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result :=  uosPlayers[PlayerIndex].AddFromDevIn(Device, Latency, SampleRate, OutputIndex,
  SampleFormat, FramesCount) ;
end;

function uos_AddFromDevIn(PlayerIndex: cint32): cint32;
  // Add a Input from Device Input with custom parameters
  // PlayerIndex : Index of a existing Player
begin
result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result :=  uosPlayers[PlayerIndex].AddFromDevIn(-1, -1, -1, -1, -1, -1) ;
end;
{$endif}

function uos_AddFromEndlessMuted(PlayerIndex: cint32; Channels : cint32; FramesCount: cint32): cint32;
  // Add a input from Endless Muted dummy sine wav
  // FramesCount = FramesCount of input-to-follow 
  // Channels = Channels of input-to-follow.
  begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result :=  uosPlayers[PlayerIndex].AddFromEndlessMuted(Channels, FramesCount) ;
end; 

{$IF DEFINED(synthesizer)}
function uos_AddFromSynth(PlayerIndex: cint32; Frequency: float; VolumeL: float; VolumeR: float;
Duration : cint32;  OutputIndex: cint32;
  SampleFormat: cint32 ; SampleRate: cint32 ; FramesCount : cint32): cint32;
  // Add a input from Synthesizer with custom parameters
  // Frequency : default : -1 (440 htz)
  // VolumeL : default : -1 (= 1) (from 0 to 1) => volume left
  // VolumeR : default : -1 (= 1) (from 0 to 1) => volume right
  // Duration : default :  -1 (= 1000)  => duration in msec (0 = endless)
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (0: Float32) (0: Float32, 1:Int32, 2:Int16)
  // SampleRate : delault : -1 (44100)
  // FramesCount : -1 default : 1024
  //  result :  Input Index in array  -1 = error
  // example : InputIndex1 := AddFromSynth(0,880,-1,-1,-1,-1,-1,-1);
 begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result :=  uosPlayers[PlayerIndex].AddFromSynth(Frequency, VolumeL, VolumeR, Duration, OutputIndex,
  SampleFormat, SampleRate,  FramesCount) ;
end;

procedure uos_InputSetSynth(PlayerIndex: cint32; InputIndex: cint32; Frequency: float;
 VolumeL: float; VolumeR: float; Duration: cint32; Enable : boolean);
  // Frequency : in Hertz (-1 = do not change)
  // VolumeL :  from 0 to 1 (-1 = do not change)
  // VolumeR :  from 0 to 1 (-1 = do not change)
  // Duration : in msec (-1 = do not change)
  // Enabled : true or false ;
  begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSetSynth(InputIndex, Frequency, VolumeL, VolumeR, Duration, Enable) ;
end;
{$endif}

function uos_AddIntoFile(PlayerIndex: cint32; Filename: PChar; SampleRate: cint32;
  Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ; FileFormat: cint32): cint32;
  // Add a Output into audio wav file with custom parameters
  // PlayerIndex : Index of a existing Player
  // FileName : filename of saved audio wav file
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
  // SampleFormat : default : -1 (2:Int16) (1:Int32, 2:Int16)
  // FramesCount : default : -1 (= 65536)
  // FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom);
  //  result :Output Index in array  -1 = error
  // example : OutputIndex1 := uos_AddIntoFile(0,edit5.Text,-1,-1, 0, 1);
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 Result :=  uosPlayers[PlayerIndex].AddIntoFile(Filename, SampleRate, Channels, SampleFormat, FramesCount, FileFormat);
end;

function uos_AddIntoFile(PlayerIndex: cint32;  Filename: PChar): cint32;
  // Add a Output into audio wav file with Default parameters
  // PlayerIndex : Index of a existing Player
  // FileName : filename of saved audio wav file
 begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 Result :=  uosPlayers[PlayerIndex].AddIntoFile(Filename, -1, -1, -1, -1, -1);
end;

function uos_AddIntoFileFromMem(PlayerIndex: cint32; Filename: PChar; SampleRate: LongInt;  
      Channels: LongInt; SampleFormat: LongInt ; FramesCount: LongInt; FileFormat: cint32): LongInt;  
  // Add a Output into audio wav file with Custom parameters
  // FileName : filename of saved audio wav file
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
  //  SampleFormat : -1 default : Int16 : (1:Int32, 2:Int16)
  // FramesCount : -1 default : 65536 div channels
  // FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom);
  //  result :  Output Index in array    -1 = error
  // example : OutputIndex1 := AddIntoFileFromMem(edit5.Text,-1,-1,0, -1,-1);
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 Result :=  uosPlayers[PlayerIndex].AddIntoFileFromMem(Filename, SampleRate, Channels, SampleFormat, FramesCount, FileFormat);
end;

function uos_AddIntoFileFromMem(PlayerIndex: cint32; Filename: PChar): cint32;
  // Add a Output into audio wav file with Default parameters from TMemoryStream
  // PlayerIndex : Index of a existing Player
  // FileName : filename of saved audio wav file
 begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 Result :=  uosPlayers[PlayerIndex].AddIntoFileFromMem(Filename, -1, -1, -1, -1, -1);
end;

 {$IF DEFINED(shout)}
function uos_AddIntoIceServer(PlayerIndex: cint32; SampleRate : cint; Channels: cint; SampleFormat: cint;
 EncodeType: cint; Port: cint; Host: pchar; User: pchar; Password: pchar; MountFile :pchar): cint32;
  // Add a Output into a IceCast server for audio-web-streaming  // SampleRate : delault : -1 (48100)
  // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  // EncodeType : default : -1 (0:Music) (0: Music, 1:Voice)
  // SampleFormat : -1 default : float32 : (0:float32, 1:Int16)
  // Port : default : -1 (= 8000)
  // Host : default : 'def' (= '127.0.0.1')
  // User : default : 'def' (= 'source')
  // Password : default : 'def' (= 'hackme')
  // MountFile : default : 'def' (= '/example.opus')
  //  result :  Output Index in array  -1 = error
 begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 Result :=  uosPlayers[PlayerIndex].AddIntoIceServer(SampleRate, Channels, SampleFormat, EncodeType, Port, 
 Host, User, Password, MountFile  );
end;
  {$endif}

{$IF DEFINED(portaudio)}
 function uos_AddIntoDevOut(PlayerIndex: cint32; Device: cint32; Latency: CDouble;
  SampleRate: cint32; Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ): cint32;
  // Add a Output into Device Output with custom parameters
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result :=  uosPlayers[PlayerIndex].AddIntoDevOut(Device, Latency, SampleRate, Channels, SampleFormat , FramesCount);
end;
  // PlayerIndex : Index of a existing Player
  // Device ( -1 is default device )
  // Latency  ( -1 is latency suggested ) )
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (= 65536)
  //  result : -1 nothing created, otherwise Output Index in array
  // example : OutputIndex1 := uos_AddIntoDevOut(0,-1,-1,-1,-1,0,-1);

function uos_AddIntoDevOut(PlayerIndex: cint32): cint32;
  // Add a Output into Device Output with default parameters
begin
  Result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result :=  uosPlayers[PlayerIndex].AddIntoDevOut(-1, -1, -1, -1, -1 ,-1);
end;
{$endif}

function uos_AddFromFile(PlayerIndex: cint32; Filename: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32): cint32;
  // Add a input from audio file with custom parameters
  // PlayerIndex : Index of a existing Player
  // FileName : filename of audio file
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (65536)
  //  result : Input Index in array  -1 = error
  // example : InputIndex1 := AddFromFile(0, edit5.Text,-1,-1);
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result := uosPlayers[PlayerIndex].AddFromFile(Filename, OutputIndex, SampleFormat, FramesCount);
end;

function uos_AddFromFile(PlayerIndex: cint32; Filename: PChar): cint32;
  // Add a input from audio file with default parameters
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result := uosPlayers[PlayerIndex].AddFromFile(Filename, -1, -1, -1);
end;

function uos_AddIntoMemoryBuffer(PlayerIndex: cint32; outmemory: PDArFloat) : cint32;
  // Add a Output into memory buffer
  // outmemory : pointer of buffer to use to store memory.
  // example : OutputIndex1 := uos_AddIntoMemoryBuffer(0, pointer(bufmemory));  
 begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result :=  uosPlayers[PlayerIndex].AddIntoMemoryBuffer(outmemory);
end;

function uos_AddFromMemoryBuffer(PlayerIndex: cint32; MemoryBuffer: TDArFloat; Bufferinfos: Tuos_bufferinfos;
 OutputIndex: cint32; FramesCount: cint32): cint32;
  // Add a input from memory buffer with custom parameters
  // MemoryBuffer : the buffer
  // Bufferinfos : infos of the buffer
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')  // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)  // SampleRate : delault : -1 (44100)  // FramesCount : default : -1 (4096)
  //  result :  Input Index in array  -1 = error
  // example : InputIndex1 := AddFromMemoryBuffer(mybuffer, buffinfos,-1,1024);
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result := uosPlayers[PlayerIndex].AddFromMemoryBuffer(MemoryBuffer, Bufferinfos, OutputIndex, FramesCount);
end;

function uos_AddFromMemoryStream(PlayerIndex: cint32; MemoryStream: TMemoryStream; 
         TypeAudio: cint32; OutputIndex: cint32; SampleFormat: cint32 ; FramesCount: cint32): cint32;
  // MemoryStream : Memory stream of encoded audio.
  // TypeAudio : default : -1 --> 0 (0: flac, ogg, wav; 1: mp3; 2:opus)
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (4096)
  //  result :  Input Index in array  -1 = error
  // example : InputIndex1 := AddFromMemoryStream(0, mymemorystream,-1,-1,0,1024);
begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result := uosPlayers[PlayerIndex].AddFromMemoryStream(MemoryStream, TypeAudio, OutputIndex, SampleFormat, FramesCount);
end;

function uos_AddFromFileIntoMemory(PlayerIndex: cint32; Filename: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32): cint32;
  // Add a input from audio file and store it into memory with custom parameters
  // PlayerIndex : Index of a existing Player
  // FileName : filename of audio file
  // OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (65536)
  //  result : Input Index in array  -1 = error
  // example : InputIndex1 := uos_AddFromFileIntoMemory(0, edit5.Text, -1, 0, -1);
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result := uosPlayers[PlayerIndex].AddFromFileIntoMemory(Filename, OutputIndex, SampleFormat, FramesCount);
end;

function uos_AddFromFileIntoMemory(PlayerIndex: cint32; Filename: PChar): cint32;
  // Add a input from audio file and store it into memory with default parameters
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result := uosPlayers[PlayerIndex].AddFromFileIntoMemory(Filename, -1, -1, -1);
end;

{$IF DEFINED(webstream)}
function uos_AddFromURL(PlayerIndex: cint32; URL: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32; AudioFormat: cint32 ; ICYon : boolean): cint32;
  // Add a Input from Audio URL
  // URL : URL of audio file
  // OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other cint32 : existing Output
  // SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (4096)
  // AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
  // ICYon : ICY data on/off  
  // Add a Input from Audio URL
  // URL : URL of audio file (like  'http://someserver/somesound.mp3')
  // OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other cint32 : existing Output
  // SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (65536)
  // AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
  // example : InputIndex := uos_AddFromURL('http://someserver/somesound.mp3',-1,-1,-1,-1, false);
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result := uosPlayers[PlayerIndex].AddFromURL(URL, OutputIndex, SampleFormat, FramesCount, AudioFormat , ICYon);
end;

function uos_AddFromURL(PlayerIndex: cint32; URL: PChar): cint32;
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result := uosPlayers[PlayerIndex].AddFromURL(URL, -1, -1, -1, -1, false);
end;
{$ENDIF}

function uos_AddPlugin(PlayerIndex: cint32; PlugName: PChar; SampleRate: cint32;
  Channels: cint32): cint32;
  // Add a plugin , result is PluginIndex
  // PlayerIndex : Index of a existing Player
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
  // 'soundtouch' and 'bs2b' PlugName are registred.
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  Result := uosPlayers[PlayerIndex].AddPlugin(PlugName, SampleRate, Channels);
end;

{$IF DEFINED(soundtouch)}
procedure uos_SetPluginSoundTouch(PlayerIndex: cint32; PluginIndex: cint32; Tempo: cfloat;
  Pitch: cfloat; Enable: boolean);
  // PluginIndex : PluginIndex Index of a existing Plugin.
  // PlayerIndex : Index of a existing Player
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
   uosPlayers[PlayerIndex].SetPluginSoundTouch(PluginIndex, Tempo, Pitch, Enable);
end;
{$endif}

{$IF DEFINED(bs2b)}
  procedure uos_SetPluginBs2b(PlayerIndex: cint32; PluginIndex: cint32; level: CInt32; fcut: CInt32; 
  feed: CInt32; Enable: boolean);
  // PluginIndex : PluginIndex Index of a existing Plugin.
  // PlayerIndex : Index of a existing Player
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 uosPlayers[PlayerIndex].SetPluginBs2b(PluginIndex, level, fcut, feed, Enable);
end;
{$endif}

procedure uos_InputSeek(PlayerIndex: cint32; InputIndex: cint32; pos: Tcount_t);
  // change position in sample
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSeek(InputIndex, pos);
end;

function uos_GetStatus(PlayerIndex: cint32) : cint32 ;
  // Get the status of the player : -1 => error, 0 => has stopped, 1 => is running, 2 => is paused.
begin
result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if assigned(uosPlayers[PlayerIndex]) then
   begin
 if  uosPlayersStat[PlayerIndex] = 1 then
 result :=  uosPlayers[PlayerIndex].Status else result := -1 ;
 end else  result := -1 ;
end;

procedure uos_InputSeekSeconds(PlayerIndex: cint32; InputIndex: cint32; pos: cfloat);
  // change position in seconds
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSeekSeconds(InputIndex, pos);
end;

procedure uos_InputSeekTime(PlayerIndex: cint32; InputIndex: cint32; pos: TTime);
  // change position in time format
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSeekTime(InputIndex, pos);
end;

function uos_InputLength(PlayerIndex: cint32; InputIndex: cint32): cint32;
  // InputIndex : InputIndex of existing input
  //  result : Length of Input in samples
begin
  result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].InputLength(InputIndex) ;
end;

function uos_InputLengthSeconds(PlayerIndex: cint32; InputIndex: cint32): cfloat;
  // InputIndex : InputIndex of existing input
  //  result : Length of Input in seconds
begin
  result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].InputLengthSeconds(InputIndex) ;
end;

function uos_InputLengthTime(PlayerIndex: cint32; InputIndex: cint32): TTime;
  // InputIndex : InputIndex of existing input
  //  result : Length of Input in time format
begin
Result := sysutils.EncodeTime(0, 0, 0, 0);
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].InputLengthTime(InputIndex) ;
end;

function uos_InputPosition(PlayerIndex: cint32; InputIndex: cint32): cint32;
  // InputIndex : InputIndex of existing input
  // result : current postion in sample
begin
  result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].InputPosition(InputIndex) ;
end;

procedure uos_InputSetFrameCount(PlayerIndex: cint32; InputIndex: cint32 ; framecount : cint32);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSetFrameCount(InputIndex, framecount) ;
end;

procedure uos_InputSetLevelEnable(PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);
  // set level calculation (default is 0)
  // 0 => no calcul
  // 1 => calcul before all DSP procedures.
  // 2 => calcul after all DSP procedures.
  // 3 => calcul before and after all DSP procedures.

begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSetLevelEnable(InputIndex, enable) ;
end;

procedure uos_InputSetEnable(PlayerIndex: cint32; InputIndex: cint32; enabled: boolean);
  // set enable true or false
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSetEnable(InputIndex, enabled) ;
end;

procedure uos_OutputSetEnable(PlayerIndex: cint32; OutputIndex: cint32; enabled: boolean);
  // set enable true or false (usefull for multi outputput)
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].OutputSetEnable(OutputIndex, enabled) ;
end;

procedure uos_InputSetPositionEnable(PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);
  // set position calculation (default is 0)
  // 0 => no calcul
  // 1 => calcul position.
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSetPositionEnable(InputIndex, enable) ;
end;

procedure uos_InputSetArrayLevelEnable(PlayerIndex: cint32; InputIndex: cint32 ; levelcalc : cint32);
  // set add level calculation in level-array (default is 0)
  // 0 => no calcul
  // 1 => calcul before all DSP procedures.
  // 2 => calcul after all DSP procedures.
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].InputSetArrayLevelEnable(InputIndex, levelcalc) ;
end;

function uos_InputGetArrayLevel(PlayerIndex: cint32; InputIndex: cint32) : TDArFloat;
begin
  result :=  uosLevelArray[PlayerIndex][InputIndex] ;
end;

function uos_InputGetLevelLeft(PlayerIndex: cint32; InputIndex: cint32): double;
  // InputIndex : InputIndex of existing input
  // result : left level(volume) from 0 to 1
begin
  result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].InputGetLevelLeft(InputIndex) ;
end;

function uos_InputGetSampleRate(PlayerIndex: cint32; InputIndex: cint32): cint32;
  // InputIndex : InputIndex of existing input
  // result : default sample rate
begin
  result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) and
  (length(uosPlayers[PlayerIndex].StreamIn) > 0) and (InputIndex +1 <= length(uosPlayers[PlayerIndex].StreamIn))
  then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].StreamIn[InputIndex].Data.SamplerateRoot;
end;

function uos_InputGetChannels(PlayerIndex: cint32; InputIndex: cint32): cint32;
  // InputIndex : InputIndex of existing input
  // result : default channels
begin
  result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) and
  (length(uosPlayers[PlayerIndex].StreamIn) > 0) and (InputIndex +1 <= length(uosPlayers[PlayerIndex].StreamIn))
  then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].StreamIn[InputIndex].Data.Channels;
end;

function uos_InputGetLevelRight(PlayerIndex: cint32; InputIndex: cint32): double;
  // InputIndex : InputIndex of existing input
  // result : right level(volume) from 0 to 1
begin
  result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].InputGetLevelRight(InputIndex) ;
end;

function uos_InputPositionSeconds(PlayerIndex: cint32; InputIndex: cint32): float;
  // InputIndex : InputIndex of existing input
  //  result : current postion of Input in seconds
begin
  result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].InputPositionSeconds(InputIndex) ;
end;

function uos_InputPositionTime(PlayerIndex: cint32; InputIndex: cint32): TTime;
  // InputIndex : InputIndex of existing input
  //  result : current postion of Input in time format
begin
Result := sysutils.EncodeTime(0, 0, 0, 0);
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].InputPositionTime(InputIndex) ;
end;

function uos_InputAddDSP1ChanTo2Chan(PlayerIndex: cint32; InputIndex: cint32): cint32;
//  Convert mono 1 channel input to stereo 2 channels input.
  // Works only if the input is mono 1 channel othewise stereo 2 chan is keeped.
  // InputIndex : InputIndex of a existing Input
  //  result :  index of DSPIn in array
  // example  DSPIndex1 := InputAddDSP1ChanTo2Chan(InputIndex1);
begin
Result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 result := uosPlayers[PlayerIndex].InputAddDSP1ChanTo2Chan(InputIndex) ;
end;

Procedure uos_PlayEx(PlayerIndex: cint32;
 no_free: Boolean; nloop: Integer; paused: boolean= false); // Start playing with free at end as parameter and assign loop

begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].PlayEx(no_free,nloop, paused ) ;
end;

Procedure uos_Play(PlayerIndex: cint32; nloop: Integer = 0) ;  // Start playing
begin
 if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uos_PlayEx(PlayerIndex, False,nloop);
end;

Procedure uos_PlayPaused(PlayerIndex: cint32; nloop: Integer = 0) ;  // Start playing paused
begin
 if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
  uos_PlayEx(PlayerIndex, False,nloop,true);
end;

Procedure uos_PlayNoFree(PlayerIndex: cint32; nloop: Integer = 0) ;  // Start playing but do not free the player after stop
begin
 if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 uos_PlayEx(PlayerIndex, True,nloop);
end;

Procedure uos_PlayNoFreePaused(PlayerIndex: cint32; nloop: Integer = 0) ;  // Start playing paused but do not free the player after stop
begin
 if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  if assigned(uosPlayers[PlayerIndex]) then
 uos_PlayEx(PlayerIndex, True,nloop, true);
end;

Procedure uos_FreePlayer(PlayerIndex: cint32) ;  
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
begin
uosPlayers[PlayerIndex].FreePlayer() ;
uosPlayers[PlayerIndex] := nil;
end;
end;

procedure uos_RePlay(PlayerIndex: cint32);  // Resume playing after pause
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].RePlay() ;
end;

procedure uos_Stop(PlayerIndex: cint32);  // Stop playing and if uos_Play() was used: free the player
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
   begin
uosPlayers[PlayerIndex].Stop();
{$IF DEFINED(mse)}
  freeandnil(uosPlayers[PlayerIndex]);
  uosPlayersStat[PlayerIndex] := -1 ;
{$endif}
end;
end;

procedure uos_Pause(PlayerIndex: cint32);  // Pause playing
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
uosPlayers[PlayerIndex].Pause() ;
end;

procedure uos_BeginProc(PlayerIndex: cint32; Proc: TProc );
  // Assign the procedure of object to execute at begin, before loop
  // PlayerIndex : Index of a existing Player
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].BeginProc := Proc;
end;

procedure uos_EndProc(PlayerIndex: cint32; Proc: TProc );
  // Assign the procedure of object to execute at end, after loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
 uosPlayers[PlayerIndex].EndProc := Proc;
end;

procedure uos_EndProcOnly(PlayerIndex: cint32; Proc: TProconly  );
  // Assign the procedure (not of object) to execute at end, after loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
 uosPlayers[PlayerIndex].EndProcOnly := Proc;
end;

procedure uos_LoopBeginProc(PlayerIndex: cint32; Proc: TProc );
  // Assign the procedure of object to execute at begin, before loop
  // PlayerIndex : Index of a existing Player
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].LoopBeginProc := Proc;
end;

procedure uos_LoopEndProc(PlayerIndex: cint32; Proc: TProc );
  // Assign the procedure of object to execute at end, after loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
 uosPlayers[PlayerIndex].LoopEndProc := Proc;
end;

procedure uos_LoopProcIn(PlayerIndex: cint32; InIndex: cint32; Proc: TProc );
  // Assign the procedure of object to execute inside the loop
  // PlayerIndex : Index of a existing Player
  // InIndex : Index of a existing Input
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
  uosPlayers[PlayerIndex].StreamIn[InIndex].LoopProc := Proc;
end;

procedure uos_LoopProcOut(PlayerIndex: cint32; OutIndex: cint32; Proc: TProc);
  // Assign the procedure of object to execute inside the loop
  // PlayerIndex : Index of a existing Player
  // OutIndex : Index of a existing Output
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
   if assigned(uosPlayers[PlayerIndex]) then
 uosPlayers[PlayerIndex].StreamOut[OutIndex].LoopProc := Proc;
end;

function uos_File2Buffer(Filename: Pchar; SampleFormat: cint32 ; outmemory: TDArFloat; var bufferinfos: Tuos_BufferInfos ): TDArFloat;
  // Create a memory buffer of a audio file.
  // FileName : filename of audio file  
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // Outmemory : the buffer to store data.
  // bufferinfos : the infos of the buffer.
  //  result :  The memory buffer
  // example : buffmem := uos_File2buffer(edit5.Text,0,buffmem, buffinfos);
 begin
  ifflat := true;
result := uos.uos_File2Buffer(Filename, SampleFormat, outmemory, bufferinfos)  ;
  end;
  
procedure uos_File2File(FilenameIN: Pchar; FilenameOUT: Pchar; SampleFormat: cint32 ; typeout: cint32 );
  // Create a audio file from a audio file.
  // FileNameIN : filename of audio file IN (ogg, flac, wav, mp3, opus, aac,...)
  // FileNameOUT : filename of audio file OUT (wav, pcm, custom)
  // SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
  // typeout : Type of out file (-1:default=wav, 0:wav, 1:pcm, 2:custom)  // example : InputIndex1 := uos_File2File(edit5.Text,0,buffmem);   
 begin
  ifflat := true;
  uos.uos_File2File(FilenameIN, FilenameOUT, SampleFormat, typeout);
  end;
  
function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfileFileName: PChar) : cint32;
  begin
  ifflat := true;
result := uos.uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfileFileName)  ;
  end;
  
function uos_loadPlugin(PluginName, PluginFilename: PChar) : cint32;
  // load plugin...
begin
result := -1;
  ifflat := true;
result := uos.uos_loadPlugin(PluginName, PluginFilename)  ;
end;

{$IF DEFINED(shout)}
function uos_LoadServerLib(ShoutFileName, OpusFileName : PChar) : cint32; 
  // Shout => needed for dealing with IceCast server
  // Opus => needed for dealing with encoding opus stream
begin
result := -1;
  ifflat := true;
result := uos.uos_LoadServerLib(ShoutFileName, OpusFileName)  ;
 end;
  
procedure uos_unloadServerLib();
  // Unload server libraries... Do not forget to call it before close application...
 begin
 ifflat := true;
 uos.uos_unloadServerLib()  ;
 end;  
{$endif}

function uos_GetVersion() : cint32 ;
begin
result := uos.uos_GetVersion() ;
end;

procedure uos_unloadlib() ;
  var
  x: cint32;
  nt : integer = 300;
  begin
  if assigned(uosPlayers) then
  begin
  if (length(uosPlayers) > 0) then
  for x := 0 to high(uosPlayers) do
  if  uosPlayersStat[x] = 1 then
  begin
  if  uosPlayers[x].Status > 0 then
  begin
  uosPlayers[x].nofree := false;
  uosPlayers[x].Stop();
  end;
  end;
  
  while (PlayersNotFree = true) and (nt > 0) do 
  begin 
  Sleep(10); 
  Dec(nt); 
  end; 

  setlength(uosPlayers, 0) ;
  setlength(uosPlayersStat, 0) ;
  end;

 uos.uos_unloadlib() ;
end;

procedure uos_unloadlibCust(PortAudio, SndFile, Mpg123, AAC, opus : boolean);
  // Custom Unload libraries... if true, then delete the library. You may unload what and when you want...
begin
uos.uos_unloadlibcust(PortAudio, SndFile, Mpg123, AAC, opus) ;
uosLoadResult:= uos.uosLoadResult;
end;

procedure uos_UnloadPlugin(PluginName: PChar);
begin
uos.uos_UnloadPlugin(PluginName) ;
uosLoadResult:= uos.uosLoadResult;
end;

{$IF DEFINED(portaudio)}
procedure uos_GetInfoDevice();
begin
uos.uos_GetInfoDevice();
setlength(uosDeviceInfos,length(uos.uosDeviceInfos));

uosDeviceInfos := uos.uosDeviceInfos;

uosDeviceCount:= uos.uosDeviceCount;
uosDefaultDeviceIn:= uos.uosDefaultDeviceIn;
uosDefaultDeviceOut:= uos.uosDefaultDeviceOut;
end;

function uos_GetInfoDeviceStr() : PChar ;
begin
result := uos.uos_GetInfoDeviceStr();
uosDeviceCount:= uos.uosDeviceCount;
uosDefaultDeviceIn:= uos.uosDefaultDeviceIn;
uosDefaultDeviceOut:= uos.uosDefaultDeviceOut;
end;
{$endif}


function uos_CreatePlayer(PlayerIndex : cint32): boolean;
// Create the player , PlayerIndex1 : from 0 to what your computer can do !
// If PlayerIndex exists already, it will be overwriten...
 var
x : cint32;
nt : integer = 200;
begin
result := false;

if PlayerIndex >= 0 then 
begin
if PlayerIndex + 1 > length(uosPlayers) then
begin
 setlength(uosPlayers,PlayerIndex + 1) ;
 uosPlayers[PlayerIndex] := nil;
 setlength(uosPlayersStat,PlayerIndex + 1) ;
 setlength(uosLevelArray,PlayerIndex + 1) ;
end;

 {$IF DEFINED(debug)}
 writeln('before uosPlayers[PlayerIndex] <> nil ');
 {$endif}  
  
  if (uosPlayers[PlayerIndex] <> nil) then
  begin
   uosPlayers[PlayerIndex].nofree := false;
   uosPlayers[PlayerIndex].Stop();
   Sleep(20); 
  while (PlayerNotFree(PlayerIndex) = true) and (nt > 0) do 
  begin 
  Sleep(10); 
  Dec(nt); 
  end;
  
  end;

{$IF DEFINED(debug)}
 writeln('after uosPlayers[PlayerIndex] <> nil ');
{$endif}  

   uosPlayers[PlayerIndex] := Tuos_Player.Create();
  
  if uosPlayers[PlayerIndex] <> nil then result := true
  else result := false; 

  uosPlayers[PlayerIndex].Index := PlayerIndex;
  uosPlayersStat[PlayerIndex] := 1 ;
 
  for x := 0 to length(uosPlayersStat) -1 do
  if uosPlayersStat[x] <> 1 then
   begin
   uosPlayersStat[x] := -1 ;
   uosPlayers[x] := nil ;
   end;

   end;
end;

procedure uos_Free();
var
x : integer;
nt : integer = 200;
begin

if assigned(uosPlayers) then
if length(uosPlayers) > 0 then
 for x := 0 to length(uosPlayers) -1 do
  begin
  if assigned(uosPlayers[x]) then
  begin
  uosPlayers[x].nofree := false;
  uos_stop(x);
  uos_freeplayer(x);
  end;
  end;

Sleep(40);

while (PlayersNotFree = true) and (nt > 0) do 
 begin 
  Sleep(10); 
  Dec(nt); 
 end; 
 sleep(20);
 uos.uos_free();
end;

end.
