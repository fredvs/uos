{This unit is part of United Openlibraries of Sound (uos)}

{  License : modified LGPL.
  Fred van Stappen fiens@hotmail.com }

// This is the "Flat Layer" of uos => for universal procedures.

unit uos_flat;

{$mode objfpc}{$H+}

// for custom config =>  edit define.inc ( also if using fpGUI and fpc < 2.7 )
{$I define.inc}

interface

uses
  
   {$IF DEFINED(Java)}
   uos_jni,
   {$endif}

   {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
   fpg_base,
   {$ENDIF}

   Classes, ctypes, math, SysUtils, uos;
 

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
     Tcount_t    = cint64;          { used for file sizes          }
  {$else}
     Tcount_t    = cint;
  {$endif}

  type
  TuosF_Data = Tuos_Data;
  TuosF_FFT = Tuos_FFT ;

{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
  const
  MSG_CUSTOM1 = FPGM_USER + 1;
      {$ENDIF}

//////////// General public procedure/function (accessible for library uos too)

{$IF DEFINED(portaudio)}
procedure uos_GetInfoDevice();

function uos_GetInfoDeviceStr() : Pansichar ;
{$endif}

function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName: PChar) : LongInt;
         ////// load libraries... if libraryfilename = nil =>  do not load it...  You may load what and when you want...    
     // PortAudio => needed for dealing with audio-device
     // SndFile => needed for dealing with ogg, vorbis, flac and wav audio-files
     // Mpg123 => needed for dealing with mp* audio-files
     // Mp4ff and Faad => needed for dealing with acc, m4a audio-files

    // If some libraries are not needed, replace it by "nil", for example : uos_loadlib(PortAudioFileName, SndFileFileName, nil, nil, nil)

procedure uos_unloadlib();
        ////// Unload all libraries... Do not forget to call it before close application...

procedure uos_free;   
        /// Free uos;
        // To use when program terminate.

procedure uos_unloadlibCust(PortAudio, SndFile, Mpg123, AAC: boolean);
           ////// Custom Unload libraries... if true, then delete the library. You may unload what and when you want...

function uos_loadPlugin(PluginName, PluginFilename: PChar) : LongInt;
        ////// load plugin...
        
procedure uos_UnloadPlugin(PluginName: PChar);

{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
procedure uos_CreatePlayer(PlayerIndex: LongInt; AParent: TObject);
{$else}
procedure uos_CreatePlayer(PlayerIndex: LongInt);
{$endif}

{$IF DEFINED(portaudio)}
function uos_AddIntoDevOut(PlayerIndex: LongInt): LongInt;
        //// PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, soundcard, ...)
        //// If PlayerIndex already exists, it will be overwriten...

         ////// Add a Output into Device Output with custom parameters
function uos_AddIntoDevOut(PlayerIndex: LongInt; Device: LongInt; Latency: CDouble;
            SampleRate: LongInt; Channels: LongInt; SampleFormat: LongInt ; FramesCount: LongInt ): LongInt;
          ////// Add a Output into Device Output with default parameters
          //////////// PlayerIndex : Index of a existing Player
          //////////// Device ( -1 is default device )
          //////////// Latency  ( -1 is latency suggested ) )
          //////////// SampleRate : delault : -1 (44100)
          //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
          //////////// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
          //////////// FramesCount : default : -1 (= 65536)
          //  result : Output Index in array  , -1 = error
          /// example : OutputIndex1 := uos_AddIntoDevOut(0,-1,-1,-1,0,-1);
 {$endif}

function uos_AddFromFile(PlayerIndex: LongInt; Filename: PChar): LongInt;
            /////// Add a input from audio file with default parameters

function uos_AddFromFile(PlayerIndex: LongInt; Filename: PChar; OutputIndex: LongInt;
              SampleFormat: LongInt ; FramesCount: LongInt): LongInt;
            /////// Add a input from audio file with default parameters
            //////////// PlayerIndex : Index of a existing Player
            ////////// FileName : filename of audio file
            ////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
            //////////// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
            //////////// FramesCount : default : -1 (65536)
            //  result : Input Index in array  -1 = error
            //////////// example : InputIndex1 := uos_AddFromFile(0, edit5.Text,-1,0);

{$IF DEFINED(webstream)}
function uos_AddFromURL(PlayerIndex: LongInt; URL: PChar): LongInt;
          /////// Add a Input from Audio URL with default parameters

function uos_AddFromURL(PlayerIndex: LongInt; URL: PChar; OutputIndex: LongInt;
                       SampleFormat: LongInt ; FramesCount: LongInt): LongInt;
             /////// Add a Input from Audio URL with custom parameters
              ////////// URL : URL of audio file 
              ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
              ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
              //////////// FramesCount : default : -1 (1024)
              ////////// example : InputIndex := AddFromURL(0,'http://someserver/somesound.mp3',-1,-1,-1);
{$ENDIF}

function uos_AddIntoFile(PlayerIndex: cint32; Filename: PChar; SampleRate: cint32;
                 Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32): cint32;
               /////// Add a Output into audio wav file with custom parameters
               //////////// PlayerIndex : Index of a existing Player
               ////////// FileName : filename of saved audio wav file
               //////////// SampleRate : delault : -1 (44100)
               //////////// Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
               //////////// SampleFormat : default : -1 (2:Int16) (1:Int32, 2:Int16)
               //////////// FramesCount : default : -1 (= 65536)
               //  result :Output Index in array  -1 = error
               //////////// example : OutputIndex1 := uos_AddIntoFile(0,edit5.Text,-1,-1, 0, -1);

function uos_AddIntoFile(PlayerIndex: cint32; Filename: PChar): cint32;
               /////// Add a Output into audio wav file with Default parameters
              //////////// PlayerIndex : Index of a existing Player
              ////////// FileName : filename of saved audio wav file

{$IF DEFINED(portaudio)}
function uos_AddFromDevIn(PlayerIndex: cint32; Device: cint32; Latency: CDouble;
             SampleRate: cint32; OutputIndex: cint32;
             SampleFormat: cint32; FramesCount : cint32): cint32;
              ////// Add a Input from Device Input with custom parameters
              //////////// PlayerIndex : Index of a existing Player
               //////////// Device ( -1 is default Input device )
               //////////// Latency  ( -1 is latency suggested ) )
               //////////// SampleRate : delault : -1 (44100)
               //////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
               //////////// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
               //////////// FramesCount : default : -1 (65536)
               //  result :  Output Index in array
               /// example : OutputIndex1 := uos_AddFromDevIn(0,-1,-1,-1,-1,-1);

function uos_AddFromDevIn(PlayerIndex: cint32): cint32;
              ////// Add a Input from Device Input with default parameters
              ///////// PlayerIndex : Index of a existing Player

{$endif}


{$IF DEFINED(synthesizer)}
function uos_AddFromSynth(PlayerIndex: cint32; Frequency: float; VolumeL: float; VolumeR: float; OutputIndex: LongInt;
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
    //////////// example : InputIndex1 := AddFromSynth(0,880,-1,-1,-1,-1,-1,-1);
    
procedure uos_InputSetSynth(PlayerIndex: cint32; InputIndex: LongInt; Frequency: float; VolumeL: float; VolumeR: float; Enable : boolean);
     ////////// Frequency : in Hertz (-1 = do not change)
     ////////// VolumeL :  from 0 to 1 (-1 = do not change)
     ////////// VolumeR :  from 0 to 1 (-1 = do not change)
    //////////// Enabled : true or false ;
{$endif}
     
procedure uos_BeginProc(PlayerIndex: cint32; Proc: TProc);
            ///// Assign the procedure of object to execute  at begining, before loop
            //////////// PlayerIndex : Index of a existing Player
            //////////// InIndex : Index of a existing Input

procedure uos_EndProc(PlayerIndex: cint32; Proc: TProc);
            ///// Assign the procedure of object to execute  at end, after loop
            //////////// PlayerIndex : Index of a existing Player
            //////////// InIndex : Index of a existing Input

procedure uos_LoopBeginProc(PlayerIndex: cint32; Proc: TProc);
            ///// Assign the procedure of object to execute  at begin of loop
            //////////// PlayerIndex : Index of a existing Player
            //////////// InIndex : Index of a existing Input

procedure uos_LoopEndProc(PlayerIndex: cint32; Proc: TProc);
            ///// Assign the procedure of object to execute  at end of loop
            //////////// PlayerIndex : Index of a existing Player
            //////////// InIndex : Index of a existing Input

procedure uos_LoopProcIn(PlayerIndex: cint32; InIndex: cint32; Proc: TProc);
            ///// Assign the procedure of object to execute inside the loop
            //////////// PlayerIndex : Index of a existing Player
            //////////// InIndex : Index of a existing Input

procedure uos_LoopProcOut(PlayerIndex: cint32; OutIndex: cint32; Proc: TProc);
              ///// Assign the procedure of object to execute inside the loop
            //////////// PlayerIndex : Index of a existing Player
            //////////// OutIndex : Index of a existing Output

{$IF DEFINED(noiseremoval)}
procedure uos_AddDSPNoiseRemovalIn(PlayerIndex: cint32; InputIndex: LongInt);
      
procedure uos_SetDSPNoiseRemovalIn(PlayerIndex: cint32; InputIndex: LongInt; Enable: boolean);

procedure uos_AddDSPNoiseRemovalOut(PlayerIndex: cint32; OutputIndex: LongInt);
      
procedure uos_SetDSPNoiseRemovalOut(PlayerIndex: cint32; OutputIndex: LongInt; Enable: boolean);
{$endif}  

procedure uos_AddDSPVolumeIn(PlayerIndex: cint32; InputIndex: cint32; VolLeft: double;
                 VolRight: double) ;
               ///// DSP Volume changer
               //////////// PlayerIndex : Index of a existing Player
               ////////// InputIndex : InputIndex of a existing Input
               ////////// VolLeft : Left volume
               ////////// VolRight : Right volume
               ////////// example  uos_AddDSPVolumeIn(0,InputIndex1,1,1);

procedure uos_AddDSPVolumeOut(PlayerIndex: cint32; OutputIndex: cint32; VolLeft: double;
                 VolRight: double) ;
               ///// DSP Volume changer
               //////////// PlayerIndex : Index of a existing Player
               ////////// OutputIndex : OutputIndex of a existing Output
               ////////// VolLeft : Left volume
               ////////// VolRight : Right volume
               //  result : -1 nothing created, otherwise index of DSPIn in array
               ////////// example  DSPIndex1 := uos_AddDSPVolumeOut(o,oututIndex1,1,1);

procedure uos_SetDSPVolumeIn(PlayerIndex: cint32; InputIndex: cint32;
                 VolLeft: double; VolRight: double; Enable: boolean);
               ////////// InputIndex : InputIndex of a existing Input
               //////////// PlayerIndex : Index of a existing Player
               ////////// VolLeft : Left volume
               ////////// VolRight : Right volume
               ////////// Enable : Enabled
               ////////// example  uos_SetDSPVolumeIn(0,InputIndex1,DSPIndex1,1,0.8,True);
               
procedure uos_SetDSPVolumeOut(PlayerIndex: cint32; OutputIndex: cint32;
                 VolLeft: double; VolRight: double; Enable: boolean);
               ////////// OutputIndex : OutputIndex of a existing Output
               //////////// PlayerIndex : Index of a existing Player
               ////////// VolLeft : Left volume
               ////////// VolRight : Right volume
               ////////// Enable : Enabled
               ////////// example  uos_SetDSPVolumeOut(0,outputIndex1,DSPIndex1,1,0.8,True);

function uos_AddDSPin(PlayerIndex: cint32; InputIndex: cint32; BeforeFunc: TFunc;
                    AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: TProc): cint32;
                  ///// add a DSP procedure for input
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// InputIndex : Input Index of a existing input
                  ////////// BeforeFunc : Function to do before the buffer is filled
                  ////////// AfterFunc : Function to do after the buffer is filled
                  ////////// EndedFunc : Function to do at end of thread
                  ////////// LoopProc : external procedure of object to synchronize after DSP done
                  //  result : -1 nothing created, otherwise index of DSPin in array  (DSPinIndex)
                  ////////// example : DSPinIndex1 := uos_AddDSPin(0,InputIndex1,@beforereverse,@afterreverse,nil);

procedure uos_SetDSPin(PlayerIndex: cint32; InputIndex: cint32; DSPinIndex: cint32; Enable: boolean);
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// InputIndex : Input Index of a existing input
                  ////////// DSPIndexIn : DSP Index of a existing DSP In
                  ////////// Enable :  DSP enabled
                  ////////// example : uos_SetDSPin(0,InputIndex1,DSPinIndex1,True);

function uos_AddDSPout(PlayerIndex: cint32; OutputIndex: cint32; BeforeFunc: TFunc;
                    AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: TProc): cint32;   
                     //// usefull if multi output
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// OutputIndex : OutputIndex of a existing Output
                  ////////// BeforeFunc : Function to do before the buffer is filled
                  ////////// AfterFunc : Function to do after the buffer is filled just before to give to output
                  ////////// EndedFunc : Function to do at end of thread
                  ////////// LoopProc : external procedure of object to synchronize after DSP done
                  //  result : index of DSPout in array
                  ////////// example :DSPoutIndex1 := uos_AddDSPout(0,OutputIndex1,nil,@volumeproc,nil,nil);

procedure uos_SetDSPout(PlayerIndex: cint32; OutputIndex: cint32; DSPoutIndex: cint32; Enable: boolean);
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// OutputIndex : OutputIndex of a existing Output
                  ////////// DSPoutIndex : DSPoutIndex of existing DSPout
                  ////////// Enable :  DSP enabled
                  ////////// example : uos_SetDSPout(0,OutputIndex1,DSPoutIndex1,True);

function uos_AddFilterIn(PlayerIndex: cint32; InputIndex: cint32; LowFrequency: cint32;
                    HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
                    AlsoBuf: boolean; LoopProc: TProc): cint32 ;
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// InputIndex : InputIndex of a existing Input
                  ////////// LowFrequency : Lowest frequency of filter
                  ////////// HighFrequency : Highest frequency of filter
                  ////////// Gain : gain to apply to filter
                  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
                  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
                  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
                  ////////// LoopProc : External procedure to execute after DSP done
                  //  result : index of DSPIn in array   -1 = error
                  ////////// example :FilterInIndex1 := uos_AddFilterIn(0,InputIndex1,6000,16000,1,2,true,nil);

procedure uos_SetFilterIn(PlayerIndex: cint32; InputIndex: cint32; FilterIndex: cint32;
                    LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
                    TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// InputIndex : InputIndex of a existing Input
                  ////////// DSPInIndex : DSPInIndex of existing DSPIn
                  ////////// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
                  ////////// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
                  ////////// Gain : gain to apply to filter
                  ////////// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
                  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
                  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
                  ////////// LoopProc : External procedure to execute after DSP done
                  ////////// Enable :  Filter enabled
                  ////////// example : uos_SetFilterIn(0,InputIndex1,FilterInIndex1,-1,-1,-1,False,True,nil);

function uos_AddFilterOut(PlayerIndex: cint32; OutputIndex: cint32; LowFrequency: cint32;
                    HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
                    AlsoBuf: boolean; LoopProc: TProc): cint32;
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// OutputIndex : OutputIndex of a existing Output
                  ////////// LowFrequency : Lowest frequency of filter
                  ////////// HighFrequency : Highest frequency of filter
                  ////////// Gain : gain to apply to filter
                  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
                  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
                  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
                  ////////// LoopProc : External procedure to execute after DSP done
                  //  result : index of DSPOut in array  -1 = error
                  ////////// example :FilterOutIndex1 := uos_AddFilterOut(0,OutputIndex1,6000,16000,1,true,nil);

procedure uos_SetFilterOut(PlayerIndex: cint32; OutputIndex: cint32; FilterIndex: cint32;
                    LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
                    TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// OutputIndex : OutputIndex of a existing Output
                  ////////// FilterIndex : DSPOutIndex of existing DSPOut
                  ////////// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
                  ////////// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
                  ////////// Gain : gain to apply to filter
                  ////////// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
                  /// fBandPass = 3, fHighPass = 4, fLowPass = 5)
                  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
                  ////////// Enable :  Filter enabled
                  ////////// LoopProc : External procedure to execute after DSP done
                  ////////// example : uos_SetFilterOut(0,OutputIndex1,FilterOutIndex1,1000,1500,-1,True,True,nil);

function uos_AddPlugin(PlayerIndex: cint32; PlugName: PChar; SampleRate: cint32;
                       Channels: cint32): cint32 ;
                     /////// Add a plugin , result is PluginIndex
                     //////////// PlayerIndex : Index of a existing Player
                     //////////// SampleRate : delault : -1 (44100)
                     //////////// Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
                     ////// 'soundtouch' and 'bs2b' PlugName is registred.
{$IF DEFINED(soundtouch)}
procedure uos_SetPluginSoundTouch(PlayerIndex: cint32; PluginIndex: cint32; Tempo: cfloat;
                       Pitch: cfloat; Enable: boolean);
                     ////////// PluginIndex : PluginIndex Index of a existing Plugin.
                     //////////// PlayerIndex : Index of a existing Player
{$endif}

{$IF DEFINED(bs2b)}
procedure uos_SetPluginBs2b(PlayerIndex: cint32; PluginIndex: LongInt;
 level: CInt32; fcut: CInt32; feed: CInt32; Enable: boolean);
    ////////// PluginIndex : PluginIndex Index of a existing Plugin.
    //////////                
{$endif}

function uos_GetStatus(PlayerIndex: cint32) : cint32 ;
             /////// Get the status of the player : -1 => error,  0 => has stopped, 1 => is running, 2 => is paused.

procedure uos_Seek(PlayerIndex: cint32; InputIndex: cint32; pos: Tcount_t);
                     //// change position in sample

procedure uos_SeekSeconds(PlayerIndex: cint32; InputIndex: cint32; pos: cfloat);
                     //// change position in seconds

procedure uos_SeekTime(PlayerIndex: cint32; InputIndex: cint32; pos: TTime);
                     //// change position in time format

function uos_InputLength(PlayerIndex: cint32; InputIndex: cint32): cint32;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : Length of Input in samples

function uos_InputLengthSeconds(PlayerIndex: cint32; InputIndex: cint32): cfloat;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : Length of Input in seconds

function uos_InputLengthTime(PlayerIndex: cint32; InputIndex: cint32): TTime;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : Length of Input in time format

function uos_InputPosition(PlayerIndex: cint32; InputIndex: cint32): cint32;
                     ////////// InputIndex : InputIndex of existing input
                     ////// result : current postion in sample

procedure uos_InputSetFrameCount(PlayerIndex: cint32; InputIndex: cint32 ; framecount : cint32);
           ///////// set number of frames to be done. (usefull for recording and level precision)

procedure uos_InputSetLevelEnable(PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);
                 ///////// set level calculation (default is 0)
                  ////////// InputIndex : InputIndex of existing input
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

procedure uos_InputSetPositionEnable(PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);
                 ///////// set position calculation (default is 1)
                  ////////// InputIndex : InputIndex of existing input
                          // 0 => no calcul
                          // 1 => calcul position.

procedure uos_InputSetArrayLevelEnable(PlayerIndex: cint32; InputIndex: cint32 ; levelcalc : cint32);
                  ///////// set add level calculation in level-array (default is 0)
                         // 0 => no calcul
                         // 1 => calcul before all DSP procedures.
                         // 2 => calcul after all DSP procedures.

function uos_InputGetArrayLevel(PlayerIndex: cint32; InputIndex: LongInt) : TDArFloat;

function uos_InputGetLevelLeft(PlayerIndex: cint32; InputIndex: cint32): double;
                     ////////// InputIndex : InputIndex of existing input
                     ////// result : left level(volume) from 0 to 1

function uos_InputGetLevelRight(PlayerIndex: cint32; InputIndex: cint32): double;
                     ////////// InputIndex : InputIndex of existing input
                     ////// result : right level(volume) from 0 to 1

function uos_InputPositionSeconds(PlayerIndex: cint32; InputIndex: cint32): float;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : current postion of Input in seconds

function uos_InputPositionTime(PlayerIndex: cint32; InputIndex: cint32): TTime;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : current postion of Input in time format

function uos_InputGetSampleRate(PlayerIndex: cint32; InputIndex: cint32): cint32;
                   ////////// InputIndex : InputIndex of existing input
                  ////// result : default sample rate

function uos_InputGetChannels(PlayerIndex: cint32; InputIndex: cint32): cint32;
                  ///////// InputIndex : InputIndex of existing input
                  ////// result : default channels

procedure uos_Play(PlayerIndex: cint32) ;        ///// Start playing

Procedure uos_PlayNoFree(PlayerIndex: cint32) ;  ///// Start playing but do not free the player after stop

procedure uos_RePlay(PlayerIndex: cint32);                ///// Resume playing after pause

procedure uos_Stop(PlayerIndex: cint32);                  ///// Stop playing and free thread

procedure uos_Pause(PlayerIndex: cint32);                 ///// Pause playing

function uos_GetVersion() : cint32 ;             //// version of uos

var
  uosDeviceInfos: array of Tuos_DeviceInfos;
  uosLoadResult: Tuos_LoadResult;
  uosDeviceCount: cint32;
  uosDefaultDeviceIn: cint32;
  uosDefaultDeviceOut: cint32;
 
implementation

{$IF DEFINED(noiseremoval)}
procedure uos_AddDSPNoiseRemovalIn(PlayerIndex: cint32; InputIndex: LongInt);
begin
    if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
    uosPlayers[PlayerIndex].StreamIn[InputIndex].data.DSPNoiseIndex :=
    uosPlayers[PlayerIndex].AddDSPNoiseRemovalIn(InputIndex);
end;
      
procedure uos_SetDSPNoiseRemovalIn(PlayerIndex: cint32; InputIndex: LongInt; Enable: boolean);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].SetDSPNoiseRemovalIn(InputIndex, Enable);
end;

procedure uos_AddDSPNoiseRemovalOut(PlayerIndex: cint32; OutputIndex: LongInt);
begin
    if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
    uosPlayers[PlayerIndex].StreamOut[OutputIndex].data.DSPNoiseIndex :=
    uosPlayers[PlayerIndex].AddDSPNoiseRemovalOut(OutputIndex);
end;
      
procedure uos_SetDSPNoiseRemovalOut(PlayerIndex: cint32; OutputIndex: LongInt; Enable: boolean);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].SetDSPNoiseRemovalOut(OutputIndex, Enable);
end;
{$endif} 

procedure uos_AddDSPVolumeIn(PlayerIndex: cint32; InputIndex: cint32; VolLeft: double;
                 VolRight: double);
begin
    if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].StreamIn[InputIndex].Data.DSPVolumeIndex := uosPlayers[PlayerIndex].AddDSPVolumeIn(InputIndex, VolLeft, VolRight);
end;
               ///// DSP Volume changer
               //////////// PlayerIndex : Index of a existing Player
               ////////// InputIndex : InputIndex of a existing Input
               ////////// VolLeft : Left volume
               ////////// VolRight : Right volume
               //  result : -1 nothing created, otherwise index of DSPIn in array
               ////////// example  DSPIndex1 := uos_AddDSPVolumeIn(0,InputIndex1,1,1);

procedure uos_AddDSPVolumeOut(PlayerIndex: cint32; OutputIndex: cint32; VolLeft: double;
                 VolRight: double);
begin
    if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].StreamOut[OutputIndex].Data.DSPVolumeIndex := uosPlayers[PlayerIndex].AddDSPVolumeOut(OutputIndex, VolLeft, VolRight);
end;
               ///// DSP Volume changer
               //////////// PlayerIndex : Index of a existing Player
               ////////// OutputIndex : OutputIndex of a existing Output
               ////////// VolLeft : Left volume
               ////////// VolRight : Right volume
               //  result : -1 nothing created, otherwise index of DSPIn in array
               ////////// example  DSPIndex1 := uos_AddDSPVolumeOut(0,InputIndex1,1,1);

procedure uos_SetDSPVolumeIn(PlayerIndex: cint32; InputIndex: cint32;
                 VolLeft: double; VolRight: double; Enable: boolean);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].SetDSPVolumeIn(InputIndex,  uosPlayers[PlayerIndex].StreamIn[InputIndex].Data.DSPVolumeIndex, VolLeft, VolRight, Enable);
end;
               ////////// InputIndex : InputIndex of a existing Input
               //////////// PlayerIndex : Index of a existing Player
               ////////// VolLeft : Left volume
               ////////// VolRight : Right volume
               ////////// Enable : Enabled
               ////////// example  uos_SetDSPVolumeIn(0,InputIndex1,1,0.8,True);

procedure uos_SetDSPVolumeOut(PlayerIndex: cint32; OutputIndex: cint32;
                 VolLeft: double; VolRight: double; Enable: boolean);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].SetDSPVolumeOut(OutputIndex, uosPlayers[PlayerIndex].StreamOut[OutputIndex].Data.DSPVolumeIndex, VolLeft, VolRight, Enable);
end;
               ////////// OutputIndex : OutputIndex of a existing Output
               //////////// PlayerIndex : Index of a existing Player
               ////////// VolLeft : Left volume
               ////////// VolRight : Right volume
               ////////// Enable : Enabled
               ////////// example  uos_SetDSPVolumeOut(0,InputIndex1,1,0.8,True);

function uos_AddDSPin(PlayerIndex: cint32; InputIndex: cint32; BeforeFunc : TFunc;
                    AfterFunc: TFunc; EndedFunc: TFunc; LoopProc: TProc): cint32;
                  ///// add a DSP procedure for input
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// InputIndex : Input Index of a existing input
                  ////////// BeforeFunc : Function to do before the buffer is filled
                  ////////// AfterFunc : Function to do after the buffer is filled
                  ////////// EndedFunc : Function to do at end of thread
                  ////////// LoopProc : external procedure to do after the buffer is filled
                  //  result : index of DSPin in array  (DSPinIndex)
                 ////////// example : DSPinIndex1 := uos_AddDSPIn(0,InputIndex1,@beforereverse,@afterreverse,nil);
begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
result := uosPlayers[PlayerIndex].AddDSPin(InputIndex, BeforeFunc, AfterFunc, EndedFunc, LoopProc) ;
end;

procedure uos_SetDSPin(PlayerIndex: cint32; InputIndex: cint32; DSPinIndex: cint32; Enable: boolean);
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// InputIndex : Input Index of a existing input
                  ////////// DSPIndexIn : DSP Index of a existing DSP In
                  ////////// Enable :  DSP enabled
                  ////////// example : uos_SetDSPIn(0,InputIndex1,DSPinIndex1,True);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].SetDSPin(InputIndex, DSPinIndex, Enable) ;
end;

function uos_AddDSPout(PlayerIndex: cint32; OutputIndex: cint32; BeforeFunc: TFunc;
                    AfterFunc: TFunc; EndedFunc : TFunc; LoopProc: TProc): cint32;    //// usefull if multi output
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// OutputIndex : OutputIndex of a existing Output
                  ////////// BeforeFunc : Function to do before the buffer is filled
                  ////////// AfterFunc : Function to do after the buffer is filled just before to give to output
                  ////////// EndedFunc : Function to do at end of thread
                  ////////// LoopProc : external procedure to do after the buffer is filled
                  //  result :index of DSPout in array
                  ////////// example :DSPoutIndex1 := uos_AddDSPout(0,OutputIndex1,@volumeproc,nil,nil);
begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
result := uosPlayers[PlayerIndex].AddDSPout(OutputIndex, BeforeFunc, AfterFunc, EndedFunc, LoopProc) ;
end;

procedure uos_SetDSPout(PlayerIndex: cint32; OutputIndex: cint32; DSPoutIndex: cint32; Enable: boolean);
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// OutputIndex : OutputIndex of a existing Output
                  ////////// DSPoutIndex : DSPoutIndex of existing DSPout
                  ////////// Enable :  DSP enabled
                  ////////// example : uos_SetDSPIn(0,OutputIndex1,DSPoutIndex1,True);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].SetDSPout(OutputIndex, DSPoutIndex, Enable) ;
end;

function uos_AddFilterIn(PlayerIndex: cint32; InputIndex: cint32; LowFrequency: cint32;
                    HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
                    AlsoBuf: boolean; LoopProc: TProc): cint32;
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// InputIndex : InputIndex of a existing Input
                  ////////// LowFrequency : Lowest frequency of filter
                  ////////// HighFrequency : Highest frequency of filter
                  ////////// Gain : gain to apply to filter
                  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
                  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
                  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
                  ////////// LoopProc : External procedure to execute after DSP done
                  //  result :  index of DSPIn in array    -1 = error
                  ////////// example :FilterInIndex1 := uos_AddFilterIn(0,InputIndex1,6000,16000,1,2,true,nil);
begin
 result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
result := uosPlayers[PlayerIndex].AddFilterIn(InputIndex, LowFrequency, HighFrequency, Gain, TypeFilter,
                    AlsoBuf, LoopProc) ;
end;

procedure uos_SetFilterIn(PlayerIndex: cint32; InputIndex: cint32; FilterIndex: cint32;
                    LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
                    TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// InputIndex : InputIndex of a existing Input
                  ////////// DSPInIndex : DSPInIndex of existing DSPIn
                  ////////// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
                  ////////// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
                  ////////// Gain : gain to apply to filter
                  ////////// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
                  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
                  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
                  ////////// LoopProc : External procedure to execute after DSP done
                  ////////// Enable :  Filter enabled
                  ////////// example : uos_SetFilterIn(0,InputIndex1,FilterInIndex1,-1,-1,-1,False,True,nil);
begin
if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].SetFilterIn(InputIndex, FilterIndex, LowFrequency, HighFrequency, Gain,
                    TypeFilter, AlsoBuf, Enable, LoopProc);
end;

function uos_AddFilterOut(PlayerIndex: cint32; OutputIndex: cint32; LowFrequency: cint32;
                    HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
                    AlsoBuf: boolean; LoopProc: TProc): cint32;
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// OutputIndex : OutputIndex of a existing Output
                  ////////// LowFrequency : Lowest frequency of filter
                  ////////// HighFrequency : Highest frequency of filter
                  ////////// Gain : gain to apply to filter
                  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
                  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
                  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
                  ////////// LoopProc : External procedure to execute after DSP done
                  //  result : index of DSPOut in array
                  ////////// example :FilterOutIndex1 := uos_AddFilterOut(0,OutputIndex1,6000,16000,1,true,nil);
begin
 result := -1 ;
if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
result := uosPlayers[PlayerIndex].AddFilterout(OutputIndex, LowFrequency, HighFrequency, Gain, TypeFilter,
                    AlsoBuf, LoopProc) ;
end;

procedure uos_SetFilterOut(PlayerIndex: cint32; OutputIndex: cint32; FilterIndex: cint32;
                    LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
                    TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);
                  //////////// PlayerIndex : Index of a existing Player
                  ////////// OutputIndex : OutputIndex of a existing Output
                  ////////// FilterIndex : DSPOutIndex of existing DSPOut
                  ////////// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
                  ////////// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
                  ////////// Gain : gain to apply to filter
                  ////////// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
                  /// fBandPass = 3, fHighPass = 4, fLowPass = 5)
                  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
                  ////////// Enable :  Filter enabled
                  ////////// LoopProc : External procedure to execute after DSP done
                  ////////// example : uos_SetFilterOut(0,OutputIndex1,FilterOutIndex1,1000,1500,-1,True,True,nil);
begin
if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].SetFilterOut(OutputIndex, FilterIndex, LowFrequency, HighFrequency, Gain,
                    TypeFilter, AlsoBuf, Enable, LoopProc);
end;

{$IF DEFINED(portaudio)}
function uos_AddFromDevIn(PlayerIndex: cint32; Device: cint32; Latency: CDouble;
             SampleRate: cint32; OutputIndex: cint32;
             SampleFormat: cint32; FramesCount : cint32): cint32;
              ////// Add a Input from Device Input with custom parameters
              //////////// PlayerIndex : Index of a existing Player
               //////////// Device ( -1 is default Input device )
               //////////// Latency  ( -1 is latency suggested ) )
               //////////// SampleRate : delault : -1 (44100)
               //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
               //////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
               //////////// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
               //////////// FramesCount : default : -1 (65536)
               //  result : Output Index in array , -1 is error
               /// example : OutputIndex1 := uos_AddFromDevIn(0,-1,-1,-1,-1,-1,-1);
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  Result :=  uosPlayers[PlayerIndex].AddFromDevIn(Device, Latency, SampleRate, OutputIndex,
             SampleFormat, FramesCount) ;
end;

function uos_AddFromDevIn(PlayerIndex: cint32): cint32;
              ////// Add a Input from Device Input with custom parameters
              ///////// PlayerIndex : Index of a existing Player
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  Result :=  uosPlayers[PlayerIndex].AddFromDevIn(-1, -1, -1, -1, -1, -1) ;
end;
{$endif}

{$IF DEFINED(synthesizer)}
function uos_AddFromSynth(PlayerIndex: cint32; Frequency: float; VolumeL: float; VolumeR: float; OutputIndex: LongInt;
      SampleFormat: LongInt ; SampleRate: LongInt; FramesCount : LongInt): LongInt;
    /////// Add a input from Synthesizer with custom parameters
    ////////// Frequency : default : -1 (440 htz)
     ////////// VolumeL : default : -1 (= 1) (from 0 to 1) => volume left
     ////////// VolumeR : default : -1 (= 1) (from 0 to 1) => volume right
       ////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other LongInt refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
    //////////// SampleFormat : default : -1 (0: Float32) (0: Float32, 1:Int32, 2:Int16)
    //////////// SampleRate : delault : -1 (44100)
    //////////// FramesCount : -1 default : 1024
     //  result :   Input Index in array    -1 = error
    //////////// example : InputIndex1 := AddFromSynth(0,880,-1,-1,-1,-1,-1,-1);
 begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  Result :=  uosPlayers[PlayerIndex].AddFromSynth(Frequency, VolumeL, VolumeR, OutputIndex,
             SampleFormat, SampleRate,  FramesCount) ;
end;

procedure uos_InputSetSynth(PlayerIndex: cint32; InputIndex: LongInt; Frequency: float; VolumeL: float; VolumeR: float; Enable : boolean);
     ////////// Frequency : in Hertz (-1 = do not change)
     ////////// VolumeL :  from 0 to 1 (-1 = do not change)
     ////////// VolumeR :  from 0 to 1 (-1 = do not change)
    //////////// Enabled : true or false ;
  begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].InputSetSynth(InputIndex, Frequency, VolumeL, VolumeR, Enable) ;
end;
{$endif}

function uos_AddIntoFile(PlayerIndex: cint32; Filename: PChar; SampleRate: cint32;
                 Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32): cint32;
               /////// Add a Output into audio wav file with custom parameters
               //////////// PlayerIndex : Index of a existing Player
               ////////// FileName : filename of saved audio wav file
               //////////// SampleRate : delault : -1 (44100)
               //////////// Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
               //////////// SampleFormat : default : -1 (2:Int16) (1:Int32, 2:Int16)
               //////////// FramesCount : default : -1 (= 65536)
               //  result :  Output Index in array     -1 = error;
               //////////// example : OutputIndex1 := AddIntoFile(0,edit5.Text,-1,-1, 0, -1);
begin
   result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 Result :=  uosPlayers[PlayerIndex].AddIntoFile(Filename, SampleRate, Channels, SampleFormat, FramesCount);
end;

function uos_AddIntoFile(PlayerIndex: cint32;  Filename: PChar): cint32;
               /////// Add a Output into audio wav file with Default parameters
              //////////// PlayerIndex : Index of a existing Player
              ////////// FileName : filename of saved audio wav file
 begin
      if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
     if  uosPlayersStat[PlayerIndex] = 1 then
 Result :=  uosPlayers[PlayerIndex].AddIntoFile(Filename, -1, -1, -1, -1);
end;

{$IF DEFINED(portaudio)}
 function uos_AddIntoDevOut(PlayerIndex: cint32; Device: cint32; Latency: CDouble;
            SampleRate: cint32; Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ): cint32;
          ////// Add a Output into Device Output with custom parameters
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  Result :=  uosPlayers[PlayerIndex].AddIntoDevOut(Device, Latency, SampleRate, Channels, SampleFormat , FramesCount);
end;
          //////////// PlayerIndex : Index of a existing Player
          //////////// Device ( -1 is default device )
          //////////// Latency  ( -1 is latency suggested ) )
          //////////// SampleRate : delault : -1 (44100)
          //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
          //////////// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
          //////////// FramesCount : default : -1 (= 65536)
          //  result : -1 nothing created, otherwise Output Index in array
          /// example : OutputIndex1 := uos_AddIntoDevOut(0,-1,-1,-1,-1,0,-1);

function uos_AddIntoDevOut(PlayerIndex: cint32): cint32;
          ////// Add a Output into Device Output with default parameters
begin
  Result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  Result :=  uosPlayers[PlayerIndex].AddIntoDevOut(-1, -1, -1, -1, -1 ,-1);
end;
{$endif}

function uos_AddFromFile(PlayerIndex: cint32; Filename: PChar; OutputIndex: cint32;
              SampleFormat: cint32 ; FramesCount: cint32): cint32;
    /////// Add a input from audio file with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    ////////// FileName : filename of audio file
    ////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
    //////////// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (65536)
    //  result : Input Index in array    -1 = error
    //////////// example : InputIndex1 := AddFromFile(0, edit5.Text,-1,-1);
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
     if  uosPlayersStat[PlayerIndex] = 1 then
  Result := uosPlayers[PlayerIndex].AddFromFile(Filename, OutputIndex, SampleFormat, FramesCount);
end;

function uos_AddFromFile(PlayerIndex: cint32; Filename: PChar): cint32;
            /////// Add a input from audio file with default parameters
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  Result := uosPlayers[PlayerIndex].AddFromFile(Filename, -1, -1, -1);
end;

{$IF DEFINED(webstream)}
function uos_AddFromURL(PlayerIndex: LongInt; URL: PChar; OutputIndex: LongInt;
               SampleFormat: LongInt ; FramesCount: LongInt): LongInt;
            /////// Add a Input from Audio URL
              ////////// URL : URL of audio file (like  'http://someserver/somesound.mp3')
              ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
              ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
              //////////// FramesCount : default : -1 (65536)
              ////////// example : InputIndex := uos_AddFromURL('http://someserver/somesound.mp3',-1,-1,-1);
begin
   result := -1 ;
    if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
       if  uosPlayersStat[PlayerIndex] = 1 then
    Result := uosPlayers[PlayerIndex].AddFromURL(URL, OutputIndex, SampleFormat, FramesCount);
end;

function uos_AddFromURL(PlayerIndex: LongInt; URL: PChar): LongInt;
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  Result := uosPlayers[PlayerIndex].AddFromURL(URL, -1, -1, -1);
end;
{$ENDIF}

function uos_AddPlugin(PlayerIndex: cint32; PlugName: PChar; SampleRate: cint32;
                       Channels: cint32): cint32;
                     /////// Add a plugin , result is PluginIndex
                     //////////// PlayerIndex : Index of a existing Player
                     //////////// SampleRate : delault : -1 (44100)
                     //////////// Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
                     ////// 'soundtouch' and 'bs2b' PlugName are registred.
begin
  result := -1 ;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  Result := uosPlayers[PlayerIndex].AddPlugin(PlugName, SampleRate, Channels);
end;

{$IF DEFINED(soundtouch)}
procedure uos_SetPluginSoundTouch(PlayerIndex: cint32; PluginIndex: cint32; Tempo: cfloat;
                       Pitch: cfloat; Enable: boolean);
                     ////////// PluginIndex : PluginIndex Index of a existing Plugin.
                     //////////// PlayerIndex : Index of a existing Player
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 uosPlayers[PlayerIndex].SetPluginSoundTouch(PluginIndex, Tempo, Pitch, Enable);
end;
{$endif}

{$IF DEFINED(bs2b)}
    procedure uos_SetPluginBs2b(PlayerIndex: cint32; PluginIndex: LongInt; level: CInt32; fcut: CInt32; 
   feed: CInt32; Enable: boolean);
                     ////////// PluginIndex : PluginIndex Index of a existing Plugin.
                     //////////// PlayerIndex : Index of a existing Player
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 uosPlayers[PlayerIndex].SetPluginBs2b(PluginIndex, level, fcut, feed, Enable);
end;
{$endif}

procedure uos_Seek(PlayerIndex: cint32; InputIndex: cint32; pos: Tcount_t);
                     //// change position in sample
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].Seek(InputIndex, pos);
end;

function uos_GetStatus(PlayerIndex: cint32) : cint32 ;
                         /////// Get the status of the player : -1 => error, 0 => has stopped, 1 => is running, 2 => is paused.
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  begin
 if  uosPlayersStat[PlayerIndex] = 1 then
 result :=  uosPlayers[PlayerIndex].Status else result := -1 ;
 end else  result := -1 ;
end;

procedure uos_SeekSeconds(PlayerIndex: cint32; InputIndex: cint32; pos: cfloat);
                     //// change position in seconds
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].SeekSeconds(InputIndex, pos);
end;

procedure uos_SeekTime(PlayerIndex: cint32; InputIndex: cint32; pos: TTime);
                     //// change position in time format
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].SeekTime(InputIndex, pos);
end;

function uos_InputLength(PlayerIndex: cint32; InputIndex: cint32): cint32;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : Length of Input in samples
begin
  result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].InputLength(InputIndex) ;
end;

function uos_InputLengthSeconds(PlayerIndex: cint32; InputIndex: cint32): cfloat;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : Length of Input in seconds
begin
   result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].InputLengthSeconds(InputIndex) ;
end;

function uos_InputLengthTime(PlayerIndex: cint32; InputIndex: cint32): TTime;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : Length of Input in time format
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].InputLengthTime(InputIndex) ;
end;

function uos_InputPosition(PlayerIndex: cint32; InputIndex: cint32): cint32;
                     ////////// InputIndex : InputIndex of existing input
                     ////// result : current postion in sample
begin
   result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].InputPosition(InputIndex) ;
end;

procedure uos_InputSetFrameCount(PlayerIndex: cint32; InputIndex: cint32 ; framecount : cint32);
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].InputSetFrameCount(InputIndex, framecount) ;
end;

procedure uos_InputSetLevelEnable(PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);
                   ///////// set level calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].InputSetLevelEnable(InputIndex, enable) ;
end;

procedure uos_InputSetPositionEnable(PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);
                   ///////// set position calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul position.
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].InputSetPositionEnable(InputIndex, enable) ;
end;

procedure uos_InputSetArrayLevelEnable(PlayerIndex: cint32; InputIndex: cint32 ; levelcalc : cint32);
                  ///////// set add level calculation in level-array (default is 0)
                         // 0 => no calcul
                         // 1 => calcul before all DSP procedures.
                         // 2 => calcul after all DSP procedures.
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
  uosPlayers[PlayerIndex].InputSetArrayLevelEnable(InputIndex, levelcalc) ;
end;

function uos_InputGetArrayLevel(PlayerIndex: cint32; InputIndex: LongInt) : TDArFloat;
begin
   result :=  uosLevelArray[PlayerIndex][InputIndex] ;
 end;

function uos_InputGetLevelLeft(PlayerIndex: cint32; InputIndex: cint32): double;
                     ////////// InputIndex : InputIndex of existing input
                     ////// result : left level(volume) from 0 to 1
begin
   result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].InputGetLevelLeft(InputIndex) ;
end;

function uos_InputGetSampleRate(PlayerIndex: cint32; InputIndex: cint32): cint32;
                     ////////// InputIndex : InputIndex of existing input
                     ////// result : default sample rate
begin
   result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) and
  (length(uosPlayers[PlayerIndex].StreamIn) > 0) and (InputIndex +1 <= length(uosPlayers[PlayerIndex].StreamIn))
  then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].StreamIn[InputIndex].Data.SamplerateRoot;
end;

function uos_InputGetChannels(PlayerIndex: cint32; InputIndex: cint32): cint32;
                     ////////// InputIndex : InputIndex of existing input
                     ////// result : default channels
begin
   result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) and
  (length(uosPlayers[PlayerIndex].StreamIn) > 0) and (InputIndex +1 <= length(uosPlayers[PlayerIndex].StreamIn))
  then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].StreamIn[InputIndex].Data.Channels;
end;

function uos_InputGetLevelRight(PlayerIndex: cint32; InputIndex: cint32): double;
                     ////////// InputIndex : InputIndex of existing input
                     ////// result : right level(volume) from 0 to 1
begin
   result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].InputGetLevelRight(InputIndex) ;
end;

function uos_InputPositionSeconds(PlayerIndex: cint32; InputIndex: cint32): float;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : current postion of Input in seconds
begin
   result := 0;
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].InputPositionSeconds(InputIndex) ;
end;

function uos_InputPositionTime(PlayerIndex: cint32; InputIndex: cint32): TTime;
                     ////////// InputIndex : InputIndex of existing input
                     ///////  result : current postion of Input in time format
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
 result := uosPlayers[PlayerIndex].InputPositionTime(InputIndex) ;
end;

Procedure uos_Play(PlayerIndex: cint32) ;        ///// Start playing
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].Play() ;
end;

Procedure uos_PlayNoFree(PlayerIndex: cint32) ;        ///// Start playing but do not free the player after stop
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].PlayNoFree() ;
end;

procedure uos_RePlay(PlayerIndex: cint32);                ///// Resume playing after pause
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
  if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].RePlay() ;
end;

procedure uos_Stop(PlayerIndex: cint32);                  ///// Stop playing and free thread
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
uosPlayers[PlayerIndex].Stop() ;
end;

procedure uos_Pause(PlayerIndex: cint32);                 ///// Pause playing
begin
  if (length(uosPlayers) > 0) and (PlayerIndex +1 <= length(uosPlayers)) then
    if  uosPlayersStat[PlayerIndex] = 1 then
uosPlayers[PlayerIndex].Pause() ;
end;

procedure uos_BeginProc(PlayerIndex: cint32; Proc: TProc );
                 ///// Assign the procedure of object to execute at begin, before loop
                 //////////// PlayerIndex : Index of a existing Player
begin
  uosPlayers[PlayerIndex].BeginProc := Proc;
end;

procedure uos_EndProc(PlayerIndex: cint32; Proc: TProc );
                 ///// Assign the procedure of object to execute at end, after loop
                //////////// PlayerIndex : Index of a existing Player
                   //////////// InIndex : Index of a existing Input
begin
 uosPlayers[PlayerIndex].EndProc := Proc;
end;

procedure uos_LoopBeginProc(PlayerIndex: cint32; Proc: TProc );
                 ///// Assign the procedure of object to execute at begin, before loop
                 //////////// PlayerIndex : Index of a existing Player
begin
  uosPlayers[PlayerIndex].LoopBeginProc := Proc;
end;

procedure uos_LoopEndProc(PlayerIndex: cint32; Proc: TProc );
                 ///// Assign the procedure of object to execute at end, after loop
                //////////// PlayerIndex : Index of a existing Player
                   //////////// InIndex : Index of a existing Input
begin
 uosPlayers[PlayerIndex].LoopEndProc := Proc;
end;


procedure uos_LoopProcIn(PlayerIndex: cint32; InIndex: cint32; Proc: TProc );
                      ///// Assign the procedure of object to execute inside the loop
                      //////////// PlayerIndex : Index of a existing Player
                      //////////// InIndex : Index of a existing Input
begin
  uosPlayers[PlayerIndex].StreamIn[InIndex].LoopProc := Proc;
end;

procedure uos_LoopProcOut(PlayerIndex: cint32; OutIndex: cint32; Proc: TProc);
                       ///// Assign the procedure of object to execute inside the loop
                      //////////// PlayerIndex : Index of a existing Player
                      //////////// OutIndex : Index of a existing Output
begin
 uosPlayers[PlayerIndex].StreamOut[OutIndex].LoopProc := Proc;
end;

function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName: PChar) : LongInt;
  begin
   ifflat := true;
result := uos.uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName)  ;
//uosLoadResult:= uos.uosLoadResult;
  end;
  
function uos_loadPlugin(PluginName, PluginFilename: PChar) : LongInt;
        ////// load plugin...
begin
   ifflat := true;
result := uos.uos_loadPlugin(PluginName, PluginFilename)  ;
end;

function uos_GetVersion() : cint32 ;
begin
result := uos.uos_GetVersion() ;
end;

procedure uos_unloadlib() ;
  var
   x: cint32;
  begin
  if assigned(uosPlayers) then
  begin
     if (length(uosPlayers) > 0) then
      for x := 0 to high(uosPlayers) do
       if  uosPlayersStat[x] = 1 then
       begin
        if  uosPlayers[x].Status > 0 then
      begin
      uosPlayers[x].Stop();
      sleep(300) ;
      end;
      end;

     setlength(uosPlayers, 0) ;
     setlength(uosPlayersStat, 0) ;
     end;

 uos.uos_unloadlib() ;
end;

procedure uos_unloadlibCust(PortAudio, SndFile, Mpg123, AAC: boolean);
                    ////// Custom Unload libraries... if true, then delete the library. You may unload what and when you want...
begin
uos.uos_unloadlibcust(PortAudio, SndFile, Mpg123, AAC) ;
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

{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
procedure uos_CreatePlayer(PlayerIndex : cint32 ; AParent: TObject);
{$else}
procedure uos_CreatePlayer(PlayerIndex : cint32);
{$endif}
// Create the player , PlayerIndex1 : from 0 to what your computer can do !
//// If PlayerIndex exists already, it will be overwriten...

 var
x : cint32;
begin
if PlayerIndex + 1 > length(uosPlayers) then
begin
 setlength(uosPlayers,PlayerIndex + 1) ;
 setlength(uosPlayersStat,PlayerIndex + 1) ;
 setlength(uosLevelArray,PlayerIndex + 1) ;
end;
       if uosPlayers[PlayerIndex] <> nil then uosPlayers[PlayerIndex].Terminate;

       {$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
         uosPlayers[PlayerIndex] := Tuos_Player.Create(true,AParent);         //// for fpGUI
       {$else}
        uosPlayers[PlayerIndex] := Tuos_Player.Create(true);
       {$endif}

   uosPlayers[PlayerIndex].Index := PlayerIndex;
   uosPlayersStat[PlayerIndex] := 1 ;
   for x := 0 to length(uosPlayersStat) -1 do
if uosPlayersStat[x] <> 1 then
begin
uosPlayersStat[x] := -1 ;
uosPlayers[x] := nil ;
end;
end;

procedure uos_Free();
var
x : integer;
begin
if length(uosPlayers) > 0 then
 for x := 0 to length(uosPlayers) -1 do
  begin
  uosPlayers[x].destroy;
  end;
uos.uos_free();
end;

end.
