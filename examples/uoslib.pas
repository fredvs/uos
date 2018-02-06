{This unit is part of United Openlibraries of Sound (uos)
  This is the main uos unit.
  License : modified LGPL.
  Fred van Stappen fiens@hotmail.com }

library uoslib ;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

// for custom config =>  edit define.inc ( also if you want a java-compatible library )
{$I define.inc}

uses
 // cmem,// uncomment it if your programs use cmem...
 {$IFDEF UNIX}
 cthreads,
 cwstring,
 {$ENDIF}
  Classes,
  {$IF DEFINED(java)}
  uos,
  uos_jni,
  {$endif}
  ctypes, math, SysUtils, uos_flat;

 {$IF DEFINED(java)}
const
{$IF DEFINED(android)}
javappname = 'uos_demo1_';// use the same name as your android application
{$else} 
javappname = ''; 
{$ENDIF}
{$endif}

// General public procedure/function

procedure uos_checksynchro({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject {$endif}) ; cdecl;
begin
checksynchronize() ;
end;

{$IF DEFINED(java)}
procedure uos_initclass(PEnv: PJNIEnv; Obj: JObject; MClass : JString) ; cdecl;
var
MainClass : Pchar ;
begin
 MainClass :=  (PEnv^^).GetStringUTFChars(PEnv, MClass, nil);
 theclass := (PEnv^^).FindClass(PEnv,MainClass) ;
 (PEnv^^).ReleaseStringUTFChars(PEnv, MClass, nil);
end;
{$endif} 

function uos_GetVersion({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject {$endif}) : cint32 ; cdecl;
begin
result := uos_flat.uos_GetVersion() ;
end;

{$IF DEFINED(java)}
function uos_loadlib(PEnv: PJNIEnv; Obj: JObject; PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfileFileName: JString) : cint32 ; cdecl;
  begin
result := uos_flat.uos_loadlib((PEnv^^).GetStringUTFChars(PEnv, PortAudioFileName, nil),
                             (PEnv^^).GetStringUTFChars(PEnv, SndFileFileName, nil),
                             (PEnv^^).GetStringUTFChars(PEnv, Mpg123FileName, nil),
                             (PEnv^^).GetStringUTFChars(PEnv, Mp4ffFileName, nil),
                             (PEnv^^).GetStringUTFChars(PEnv, FaadFileName, nil),
                             (PEnv^^).GetStringUTFChars(PEnv, opusfileFileName, nil));
       {
      (PEnv^^).ReleaseStringUTFChars(PEnv, PortAudioFileName, nil);
      (PEnv^^).ReleaseStringUTFChars(PEnv, SndFileFileName, nil);
      (PEnv^^).ReleaseStringUTFChars(PEnv, Mpg123FileName, nil);
      (PEnv^^).ReleaseStringUTFChars(PEnv, Mp4ffFileName, nil);
      (PEnv^^).ReleaseStringUTFChars(PEnv, FaadFileName, nil);
      (PEnv^^).ReleaseStringUTFChars(PEnv, opusfileFileName, nil);
      }
 end;
{$else}
function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfileFileName: PChar) : cint32; cdecl;
// load libraries... if libraryfilename = '' or nil  =>  do not load it...
begin
 result := uos_flat.uos_loadlib(PortAudioFileName , SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfileFileName) ;
end;
{$endif}


{$IF DEFINED(java)}
function uos_loadPlugin(PEnv: PJNIEnv; Obj: JObject; PluginName, PluginFilename: JString) : cint32; cdecl;
// load plugin...
 begin
result := uos_flat.uos_loadPlugin((PEnv^^).GetStringUTFChars(PEnv, PluginName, nil),
                             (PEnv^^).GetStringUTFChars(PEnv, PluginFilename, nil));
      (PEnv^^).ReleaseStringUTFChars(PEnv, PluginName, nil);
      (PEnv^^).ReleaseStringUTFChars(PEnv, PluginFilename, nil);
     
 end;
{$else}
function uos_loadPlugin(PluginName, PluginFilename: PChar) : cint32; cdecl;
begin
 result := uos_flat.uos_loadPlugin(PluginName, PluginFilename) ;
end;
{$endif}

{$IF DEFINED(java)}        
procedure uos_UnloadPlugin(PEnv: PJNIEnv; Obj: JObject; PluginName: PChar); cdecl;
 begin
uos_flat.uos_UnloadPlugin((PEnv^^).GetStringUTFChars(PEnv, PluginName, nil));
      (PEnv^^).ReleaseStringUTFChars(PEnv, PluginName, nil);
end;
{$else}
procedure uos_UnloadPlugin(PluginName: PChar); cdecl;
begin
uos_flat.uos_UnloadPlugin(PluginName) ;
end;
{$endif}

procedure uos_unloadlib({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject {$endif}); cdecl;
// Unload all libraries and free everything...
begin
  uos_flat.uos_unloadlib();
end;

procedure uos_unloadlibCust({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PortAudio : boolean; SndFile: boolean; Mpg123: boolean; AAC: boolean ;  opus: boolean); cdecl;
// Custom Unload libraries... if true, then unload the library. You may unload what and when you want...
begin
uos_flat.uos_unloadlibCust(PortAudio, SndFile, Mpg123, AAC, opus);
end;

procedure uos_free({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject {$endif}); cdecl;
// Unload all libraries and free everything... Do not forget to call it before close application...
begin
  uos_flat.uos_free();
end;

{$IF DEFINED(java)}
function uos_GetInfoDeviceStr(PEnv: PJNIEnv; Obj: JObject) : Jstring ; cdecl;
var
infdev : PAnsiChar;
begin
infdev :=  uos_flat.uos_GetInfoDeviceStr();
result := JNI_StringToJString(PEnv, infdev) ;
end;
{$else}
function uos_GetInfoDeviceStr() : PChar ; cdecl;
begin
result :=  uos_flat.uos_GetInfoDeviceStr();
end;
{$endif}

{$IF DEFINED(java)}
function uos_GetInfoLibraries(PEnv: PJNIEnv; Obj: JObject) : Jstring ; cdecl;
var
infdev : PAnsiChar;
begin
infdev :=  uos_flat.uos_GetInfoLibraries();
result := JNI_StringToJString(PEnv, infdev) ;
end;
{$else}
function uos_GetInfoLibraries() : PChar ; cdecl;
begin
result :=  uos_flat.uos_GetInfoLibraries();
end;
{$endif}

function uos_CreatePlayer({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject ; {$endif}PlayerIndex: cint32) : cint32 ; cdecl;
// PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, soundcard, ...)
// If PlayerIndex already exists, it will be overwriten...
begin
result := -1;
if uos_flat.uos_CreatePlayer(PlayerIndex) then result := 0 else result := -1;
end;

function uos_AddIntoDevOut({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; Device: cint32; Latency: CDouble;
            SampleRate: cint32; Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32; ChunkCount: cint32 ): cint32;  cdecl;
// Add a Output into Device Output with default parameters
// PlayerIndex : Index of a existing Player
// Device ( -1 is default device )
// Latency  ( -1 is latency suggested ) )
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (= 65536)
// ChunkCount : default : -1 (= 512)
// example : OutputIndex1 := uos_AddIntoDevOut(0,-1,-1,-1,-1,-1, -1);
begin
 result :=  uos_flat.uos_AddIntoDevOut(PlayerIndex, Device, Latency, SampleRate, Channels, SampleFormat, FramesCount, ChunkCount) ;
end;

function uos_AddIntoDevOutDef({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject ; {$endif} PlayerIndex: cint32): cint32; cdecl;
// Add a Output into Device Output with default parameters
// PlayerIndex : Index of a existing Player
begin
 result :=  uos_flat.uos_AddIntoDevOut(PlayerIndex);
end;

{$IF DEFINED(java)}
function uos_AddFromFile(PEnv: PJNIEnv; Obj: JObject ; PlayerIndex: cint32; Filename: JString; OutputIndex: cint32;
              SampleFormat: shortint ; FramesCount: cint32): cint32;  cdecl;
// Add a input from audio file with default parameters
// PlayerIndex : Index of a existing Player
// FileName : filename of audio file
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (65536)
//  result : Input Index in array
begin
 result :=  uos_flat.uos_AddFromFile(PlayerIndex, (PEnv^^).GetStringUTFChars(PEnv, Filename, nil), OutputIndex, SampleFormat, FramesCount);
 (PEnv^^).ReleaseStringUTFChars(PEnv, Filename, nil);
end;
{$else}
function uos_AddFromFile(PlayerIndex: cint32; Filename: Pchar; OutputIndex: cint32;
              SampleFormat: shortint ; FramesCount: cint32): cint32;  cdecl;
 begin
 result :=  uos_flat.uos_AddFromFile(PlayerIndex, Filename, OutputIndex, SampleFormat, FramesCount);
end;
{$endif}

{$IF DEFINED(java)}
function uos_AddFromFileDef(PEnv: PJNIEnv; Obj: JObject ;PlayerIndex: cint32; Filename: JString): cint32; cdecl;
// Add a input from audio file with default parameters
// PlayerIndex : Index of a existing Player
// FileName : filename of audio file
//  result :  Input Index in array
begin
 result :=  uos_flat.uos_AddFromFile(PlayerIndex,  (PEnv^^).GetStringUTFChars(PEnv, Filename, nil));
  (PEnv^^).ReleaseStringUTFChars(PEnv, Filename, nil);
end;
{$else}
function uos_AddFromFileDef(PlayerIndex: cint32; Filename: Pchar): cint32; cdecl;
begin
 result :=  uos_flat.uos_AddFromFile(PlayerIndex, Filename);
end;
{$endif}


{$IF DEFINED(webstream)}

{$IF DEFINED(java)}
function uos_AddFromURLDef(PPEnv: PJNIEnv; Obj: JObject ; PlayerIndex: LongInt; URL: PChar): LongInt; cdecl;
// Add a Input from Audio URL
// URL : URL of audio file (like  'http://someserver/somesound.mp3')
    
begin
result :=  uos_flat.uos_AddFromURL(PlayerIndex, URL );
end;
{$else}
function uos_AddFromURLDef(PlayerIndex: cint32; URL: PChar): cint32; cdecl;
 begin
 result :=  uos_flat.uos_AddFromURL(PlayerIndex, URL);
 end;
{$ENDIF}

{$IF DEFINED(java)}
function uos_AddFromURL(PPEnv: PJNIEnv; Obj: JObject ; PlayerIndex: LongInt; URL: PChar ; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32; AudioFormat: cint32 ; ICYon : boolean): cint32; cdecl;
// Add a Input from Audio URL with custom parameters
// URL : URL of audio file 
// OutputIndex : OutputIndex of existing Output// -1: all output, -2: no output, other cint32 : existing Output
// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (4096)
// AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
// example : InputIndex := AddFromURL(0,'http://someserver/somesound.mp3',-1,-1,-1,-1);
begin
 result :=  uos_flat.uos_AddFromURL(PlayerIndex, URL, OutputIndex, SampleFormat, FramesCount, AudioFormat , ICYon );
end;
{$else}
function uos_AddFromURL(PlayerIndex: cint32; URL: PChar; OutputIndex: cint32;
  SampleFormat: cint32 ; FramesCount: cint32; AudioFormat: cint32 ; ICYon : boolean): cint32;  cdecl;
 begin
 result :=  uos_flat.uos_AddFromURL(PlayerIndex, URL, OutputIndex, SampleFormat, FramesCount, AudioFormat , ICYon );
 end;
{$ENDIF}

{$ENDIF}

{$IF DEFINED(java)}
function uos_AddIntoFile(PEnv: PJNIEnv; Obj: JObject ; PlayerIndex: cint32; Filename: JString; SampleRate: cint32;
                 Channels: cint32; SampleFormat: shortint ; FramesCount: cint32; FileFormat: cint32): cint32; cdecl;
// Add a Output into audio wav file with custom parameters
// PlayerIndex : Index of a existing Player
// FileName : filename of saved audio wav file
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (= 65536)
// FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom);
//  result :  Output Index in array
// example : OutputIndex1 := uos_AddIntoFile(0,edit5.Text,-1,-1, 0, -1, -1);
begin
 result :=  uos_flat.uos_AddIntoFile(PlayerIndex,  (PEnv^^).GetStringUTFChars(PEnv, Filename, nil), SampleRate, Channels, SampleFormat, FramesCount, FileFormat);
 (PEnv^^).ReleaseStringUTFChars(PEnv, Filename, nil);
end;
 {$else}
function uos_AddIntoFile(PlayerIndex: cint32; Filename: PChar; SampleRate: cint32;
  Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ; FileFormat: cint32): cint32;
begin
 result :=  uos_flat.uos_AddIntoFile(PlayerIndex, Filename, SampleRate, Channels, SampleFormat, FramesCount,  FileFormat);
end;
{$endif}

{$IF DEFINED(java)}
function uos_AddIntoFileDef(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; Filename: JString): cint32; cdecl;
// Add a Output into audio wav file with Default parameters
// PlayerIndex : Index of a existing Player
// FileName : filename of saved audio wav file
//  result : -1 nothing created, otherwise Output Index in array
begin
 result :=  uos_flat.uos_AddIntoFile(PlayerIndex,  (PEnv^^).GetStringUTFChars(PEnv, Filename, nil)) ;
  (PEnv^^).ReleaseStringUTFChars(PEnv, Filename, nil);
end;
{$else}
function uos_AddIntoFileDef(PlayerIndex: cint32; Filename: Pchar): cint32; cdecl;
begin
 result :=  uos_flat.uos_AddIntoFile(PlayerIndex, Filename) ;
end;
{$endif}


function uos_AddFromDevIn({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; Device: cint32; Latency: CDouble;
             SampleRate: cint32; OutputIndex: cint32;
             SampleFormat: shortint; FramesCount : cint32): cint32; cdecl;
// Add a Input from Device Input with custom parameters
// PlayerIndex : Index of a existing Player
// Device ( -1 is default Input device )
// Latency  ( -1 is latency suggested ) )
// SampleRate : delault : -1 (44100)
// OutputIndex : Output index of used output// -1: all output, -2: no output, other cint32 refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
// SampleFormat : default : -1 (1:Int16) (0: Float32, 1:Int32, 2:Int16)
// FramesCount : default : -1 (65536)
//  result : Output Index in array
// example : OutputIndex1 := uos_AddFromDevIn(-1,-1,-1,-1,-1,-1);
begin
 result :=  uos_flat.uos_AddFromDevIn(PlayerIndex, Device, Latency, SampleRate, OutputIndex,
               SampleFormat, FramesCount);
end;

function uos_AddFromDevInDef({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32): cint32 ; cdecl;
// Add a Input from Device Input with default parameters
// PlayerIndex : Index of a existing Player
 begin
  result :=  uos_flat.uos_AddFromDevIn(PlayerIndex);
 end;
 
 function uos_AddFromEndlessMuted({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif}PlayerIndex: cint32; Channels : cint32; FramesCount: cint32): cint32; cdecl;
// Add a input from Endless Muted dummy sine wav
// FramesCount = FramesCount of input-to-follow 
// Channels = Channels of input-to-follow.
 begin
  result :=  uos_flat.uos_AddFromEndlessMuted(PlayerIndex, Channels, FramesCount);
 end;  
  
{$IF DEFINED(synthesizer)}
function uos_AddFromSynth({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif}PlayerIndex: cint32; Frequency: cfloat; VolumeL: cfloat; VolumeR: cfloat;
Duration : cint32;  OutputIndex: cint32;
  SampleFormat: cint32 ; SampleRate: cint32 ; FramesCount : cint32): cint32; cdecl;
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
 result :=  uos_flat.uos_AddFromSynth(PlayerIndex, Frequency, VolumeL, VolumeR, Duration, OutputIndex, SampleFormat, SampleRate, FramesCount) ;
end;

procedure uos_InputSetSynth({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif}PlayerIndex: cint32; InputIndex: cint32; Frequency: float; 
 VolumeL: float; VolumeR: float; Duration: cint32; Enable : boolean); cdecl;
// Frequency : in Hertz (-1 = do not change)
// VolumeL :  from 0 to 1 (-1 = do not change)
// VolumeR :  from 0 to 1 (-1 = do not change)
// Duration : in msec (-1 = do not change)
// Enabled : true or false 
begin
 uos_flat.uos_InputSetSynth(PlayerIndex, InputIndex, Frequency, VolumeL, VolumeR, Duration, Enable) ;
end;  

  
{$endif}  

function uos_InputGetSampleRate({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): cint32; cdecl;
// InputIndex : InputIndex of existing input
// result : default sample rate
begin
 result :=  uos_flat.uos_InputGetSampleRate(PlayerIndex, InputIndex) ;
end;

function uos_InputGetChannels({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): cint32; cdecl;
// InputIndex : InputIndex of existing input
// result : default channels
begin
 result :=  uos_flat.uos_InputGetChannels(PlayerIndex, InputIndex) ;
end;


procedure uos_InputAddDSPVolume({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32; VolLeft: double;
                VolRight: double); cdecl;
// DSP Volume changer
// PlayerIndex : Index of a existing Player
// InputIndex : InputIndex of a existing Input
// VolLeft : Left volume
// VolRight : Right volume
// example  DSPIndex1 := uos_AddDSPVolumeIn(0,InputIndex1,1,1);
begin
uos_flat.uos_InputAddDSPVolume(PlayerIndex, InputIndex, VolLeft, VolRight) ;
end;

procedure uos_OutputAddDSPVolume({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; OutputIndex: cint32; VolLeft: double;
                 VolRight: double); cdecl;
// DSP Volume changer
// PlayerIndex : Index of a existing Player
// OutputIndex : OutputIndex of a existing Output
// VolLeft : Left volume
// VolRight : Right volume
// example  DSPIndex1 := uos_AddDSPVolumeOut(0,InputIndex1,1,1);
begin
uos_flat.uos_OutputAddDSPVolume(PlayerIndex, OutputIndex, VolLeft, VolRight) ;
end;

procedure uos_InputSetDSPVolume({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32;
                 VolLeft: double; VolRight: double; Enable: boolean); cdecl;
// InputIndex : InputIndex of a existing Input
// PlayerIndex : Index of a existing Player
// VolLeft : Left volume
// VolRight : Right volume
// Enable : Enabled
// example  uos_SetDSPVolumeIn(0,InputIndex1, 1,0.8,True);
begin
uos_flat.uos_InputSetDSPVolume(PlayerIndex, InputIndex, VolLeft, VolRight, Enable) ;
end;

procedure uos_OutputSetDSPVolume({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; OutputIndex: cint32;
                 VolLeft: double; VolRight: double; Enable: boolean); cdecl;
// OutputIndex : OutputIndex of a existing Output
// PlayerIndex : Index of a existing Player
// VolLeft : Left volume
// VolRight : Right volume
// Enable : Enabled
// example  uos_SetDSPVolumeOut(0,InputIndex1,1,0.8,True);
begin
uos_flat.uos_OutputSetDSPVolume(PlayerIndex, OutputIndex, VolLeft, VolRight, Enable) ;
end;

{$IF DEFINED(java)}
procedure uos_BeginProc(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; Proc: JString); cdecl;
// Assign the procedure of object to execute  at begining, before loop
// PlayerIndex : Index of a existing Player
// InIndex : Index of a existing Input
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 uosPlayers[PlayerIndex].BeginProc := (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V')  ;
end;
{$else}
procedure uos_BeginProc(PlayerIndex: cint32; Proc: TProc); cdecl;
// Assign the procedure of object to execute  at begining, before loop
// PlayerIndex : Index of a existing Player
// InIndex : Index of a existing Input
begin
 uos_flat.uos_BeginProc(PlayerIndex, proc);
end;
{$endif}

{$IF DEFINED(java)}
procedure uos_EndProc(PEnv: PJNIEnv; Obj: JObject;PlayerIndex: cint32; Proc: JString); cdecl;
// Assign the procedure of object to execute  at end, after loop
// PlayerIndex : Index of a existing Player
// InIndex : Index of a existing Input
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, Proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 uosPlayers[PlayerIndex].EndProc := (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V')  ;
end;
{$else}
procedure uos_EndProc(PlayerIndex: cint32; Proc: TProc); cdecl;
// Assign the procedure of object to execute  at end, after loop
// PlayerIndex : Index of a existing Player
// InIndex : Index of a existing Input
begin
 uos_flat.uos_EndProc(PlayerIndex, proc);
end;
{$endif}

{$IF DEFINED(java)}
procedure uos_LoopProcIn(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; InIndex: cint32; Proc: JString); cdecl;
// Assign the procedure of object to execute  at end, after loop
// PlayerIndex : Index of a existing Player
// InIndex : Index of a existing Input
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 uosPlayers[PlayerIndex].StreamIn[InIndex].LoopProc := (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V')  ;
end;
{$else}
procedure uos_LoopProcIn(PlayerIndex: cint32; InIndex: cint32; Proc: TProc); cdecl;
// Assign the procedure of object to execute inside the loop
// PlayerIndex : Index of a existing Player
// InIndex : Index of a existing Input
begin
uos_flat.uos_LoopProcIn(PlayerIndex, InIndex, Proc);
end;
{$endif}

{$IF DEFINED(java)}
procedure uos_LoopProcOut(PEnv: PJNIEnv; Obj: JObject;PlayerIndex: cint32; OutIndex: cint32; Proc: JString); cdecl;
// Assign the procedure of object to execute inside the loop
// PlayerIndex : Index of a existing Player
// OutIndex : Index of a existing Output
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 uosPlayers[PlayerIndex].StreamOut[OutIndex].LoopProc := (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V')  ;
end;
{$else}
procedure uos_LoopProcOut(PlayerIndex: cint32; OutIndex: cint32; Proc: TProc); cdecl;
// Assign the procedure of object to execute inside the loop
// PlayerIndex : Index of a existing Player
// OutIndex : Index of a existing Output
begin
 uos_flat.uos_LoopProcOut(PlayerIndex, OutIndex, Proc);
end;
{$endif}

{$IF DEFINED(java)}
procedure uos_LoopBeginProc(PEnv: PJNIEnv; Obj: JObject;PlayerIndex: cint32; Proc: JString); cdecl;
// Assign the procedure of object to execute inside the loop
// PlayerIndex : Index of a existing Player
// InIndex : Index of a existing Input
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 uosPlayers[PlayerIndex].LoopBeginProc := (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V')  ;
end;
{$else}
procedure uos_LoopBeginProc(PlayerIndex: cint32;  Proc: TProc); cdecl;
// Assign the procedure of object to execute inside the loop
// PlayerIndex : Index of a existing Player
// InIndex : Index of a existing Input
begin
uos_flat.uos_LoopBeginProc(PlayerIndex, Proc);
end;
{$endif}

{$IF DEFINED(java)}
procedure uos_LoopEndProc(PEnv: PJNIEnv; Obj: JObject;PlayerIndex: cint32; Proc: JString); cdecl;
// Assign the procedure of object to execute inside the loop
// PlayerIndex : Index of a existing Player
// InIndex : Index of a existing Input
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 uosPlayers[PlayerIndex].LoopEndProc := (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V')  ;
end;
{$else}
procedure uos_LoopEndProc(PlayerIndex: cint32; Proc: TProc); cdecl;
// Assign the procedure of object to execute inside the loop
// PlayerIndex : Index of a existing Player
// OutIndex : Index of a existing Output
begin
 uos_flat.uos_LoopEndProc(PlayerIndex, Proc);
end;
{$endif}

{ TODO
function uos_AddDSPin(PlayerIndex: cint32; InputIndex: cint32; BeforeProc: TFunc;
                    AfterProc: TFunc; LoopProc: TProc): cint32 ; cdecl;
// add a DSP procedure for input
// PlayerIndex : Index of a existing Player
// InputIndex : Input Index of a existing input
// BeforeProc : procedure to do before the buffer is filled
// AfterProc : procedure to do after the buffer is filled
// LoopProc : external procedure to do after the buffer is filled
//  result : -1 nothing created, otherwise index of DSPin in array  (DSPinIndex)
// example : DSPinIndex1 := uos_AddDSPin(0,InputIndex1,@beforereverse,@afterreverse,nil);
begin
result := uos_flat.uos_AddDSPin(PlayerIndex, InputIndex, BeforeProc, AfterProc, LoopProc);
end;

procedure uos_SetDSPin(PlayerIndex: cint32; InputIndex: cint32; DSPinIndex: cint32; Enable: boolean); cdecl;
// PlayerIndex : Index of a existing Player
// InputIndex : Input Index of a existing input
// DSPIndexIn : DSP Index of a existing DSP In
// Enable :  DSP enabled
// example : uos_SetDSPin(0,InputIndex1,DSPinIndex1,True);
begin
uos_flat.uos_SetDSPin(PlayerIndex, InputIndex, DSPinIndex, Enable);
end;

function uos_AddDSPout(PlayerIndex: cint32; OutputIndex: cint32; BeforeProc: TFunc;
                    AfterProc: TFunc; LoopProc: TProc): cint32; cdecl;// usefull if multi output
// PlayerIndex : Index of a existing Player
// OutputIndex : OutputIndex of a existing Output
// BeforeProc : procedure to do before the buffer is filled
// AfterProc : procedure to do after the buffer is filled just before to give to output
// LoopProc : external procedure to do after the buffer is filled
//  result : -1 nothing created, otherwise index of DSPout in array
// example :DSPoutIndex1 := uos_AddDSPout(0,OutputIndex1,@volumeproc,nil,nil);
begin
result := uos_flat.uos_AddDSPout(PlayerIndex, OutputIndex, BeforeProc, AfterProc, LoopProc);
end;

procedure uos_SetDSPout(PlayerIndex: cint32; OutputIndex: cint32; DSPoutIndex: cint32; Enable: boolean); cdecl;
// PlayerIndex : Index of a existing Player
// OutputIndex : OutputIndex of a existing Output
// DSPoutIndex : DSPoutIndex of existing DSPout
// Enable :  DSP enabled
// example : SetDSPIn(0,OutputIndex1,DSPoutIndex1,True);
begin
uos_flat.uos_SetDSPin(PlayerIndex, OutputIndex, DSPOutIndex, Enable);
end;
}

{$IF DEFINED(java)}
function uos_InputAddFilter(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; InputIndex: cint32; LowFrequency: cint32;
                   HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
                   AlsoBuf: boolean; proc: JString): cint32;  cdecl;
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 result := uosPlayers[PlayerIndex].InputAddFilter(InputIndex, LowFrequency, HighFrequency, Gain, TypeFilter, AlsoBuf, (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V'));
end;
{$else}
function uos_InputAddFilter(PlayerIndex: cint32; InputIndex: cint32; LowFrequency: cint32;
                    HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
                    AlsoBuf: boolean; LoopProc: TProc): cint32;  cdecl;
// PlayerIndex : Index of a existing Player
// InputIndex : InputIndex of a existing Input
// LowFrequency : Lowest frequency of filter
// HighFrequency : Highest frequency of filter
// Gain : gain to apply to filter
// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// LoopProc : External procedure to execute after DSP done
//  result : index of DSPIn in array
// example :FilterInIndex1 := uos_AddFilterIn(0,InputIndex1,6000,16000,1,2,true,nil);
begin
result := uos_flat.uos_InputAddFilter(PlayerIndex, InputIndex, LowFrequency, HighFrequency, Gain, TypeFilter, AlsoBuf, LoopProc);
end;
{$endif}

{$IF DEFINED(java)}
procedure uos_InputSetFilter(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; InputIndex: cint32; FilterIndex: cint32;
                    LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
                    TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; Proc: JString);  cdecl;
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 uosPlayers[PlayerIndex].InputSetFilter(InputIndex, FilterIndex, LowFrequency, HighFrequency, Gain, TypeFilter, AlsoBuf, enable,  (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V'));
end;
{$else}
procedure uos_InputSetFilter( PlayerIndex: cint32; InputIndex: cint32; FilterIndex: cint32;
                    LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
                    TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);  cdecl;
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
// example : SetFilterIn(0,InputIndex1,FilterInIndex1,-1,-1,-1,False,True,nil);
begin
uos_flat.uos_InputSetFilter(PlayerIndex, InputIndex, FilterIndex, LowFrequency, HighFrequency, Gain, TypeFilter, AlsoBuf, enable, LoopProc);
end;
{$endif}

{$IF DEFINED(java)}
function uos_OutputAddFilter(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; OutputIndex: cint32; LowFrequency: cint32;
                   HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
                   AlsoBuf: boolean; proc: JString): cint32;  cdecl;
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 result := uosPlayers[PlayerIndex].OutputAddFilter(OutputIndex, LowFrequency, HighFrequency, Gain, TypeFilter, AlsoBuf, (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V'));
end;
{$else}
function uos_OutputAddFilter(PlayerIndex: cint32; OutputIndex: cint32; LowFrequency: cint32;
                    HighFrequency: cint32; Gain: cfloat; TypeFilter: cint32;
                    AlsoBuf: boolean; LoopProc: TProc): cint32;  cdecl;
// PlayerIndex : Index of a existing Player
// OutputIndex : OutputIndex of a existing Output
// LowFrequency : Lowest frequency of filter
// HighFrequency : Highest frequency of filter
// Gain : gain to apply to filter
// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
// fBandPass = 3, fHighPass = 4, fLowPass = 5)
// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
// LoopProc : External procedure to execute after DSP done
//  result :index of DSPOut in array
// example :FilterOutIndex1 := uos_AddFilterOut(0,OutputIndex1,6000,16000,1,true,nil);
begin
result := uos_flat.uos_OutputAddFilter(PlayerIndex, OutputIndex, LowFrequency, HighFrequency, Gain, TypeFilter, AlsoBuf, LoopProc);
end;
{$endif}

{$IF DEFINED(java)}
procedure uos_OutputSetFilter(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; OutputIndex: cint32; FilterIndex: cint32;
                    LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
                    TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; Proc: JString);  cdecl;
var
theproc : pchar ;
begin
 theproc := (PEnv^^).GetStringUTFChars(PEnv, proc, nil);
 uosPlayers[PlayerIndex].PEnv := PEnv;
 uosPlayers[PlayerIndex].Obj:= Obj;
 uosPlayers[PlayerIndex].OutputSetFilter(OutputIndex, FilterIndex, LowFrequency, HighFrequency, Gain, TypeFilter, AlsoBuf, enable, (PEnv^^).GetStaticMethodID(PEnv,theclass,theproc,'()V'));
end;
{$else}
procedure uos_OutputSetFilter(PlayerIndex: cint32; OutputIndex: cint32; FilterIndex: cint32;
                    LowFrequency: cint32; HighFrequency: cint32; Gain: cfloat;
                    TypeFilter: cint32; AlsoBuf: boolean; Enable: boolean; LoopProc: TProc);  cdecl;
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
// example : SetFilterOut(0,OutputIndex1,FilterOutIndex1,1000,1500,-1,True,True,nil);
begin
uos_flat.uos_OutputSetFilter(PlayerIndex, OutputIndex, FilterIndex, LowFrequency, HighFrequency, Gain, TypeFilter, AlsoBuf, enable, LoopProc);
end;
{$endif}

{$IF DEFINED(java)}
function uos_AddPlugin(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; PlugName: JString; SampleRate: cint32;
                       Channels: cint32): cint32;  cdecl;
// Add a plugin , result is PluginIndex
// PlayerIndex : Index of a existing Player
// SampleRate : delault : -1 (44100)
// Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...)
// Till now, only 'soundtouch' PlugName is registred.
begin
result := uos_flat.uos_AddPlugin(PlayerIndex, (PEnv^^).GetStringUTFChars(PEnv, PlugName, nil), SampleRate, Channels);
(PEnv^^).ReleaseStringUTFChars(PEnv, PlugName, nil);
end;
{$else}
function uos_AddPlugin(PlayerIndex: cint32; PlugName: Pchar; SampleRate: cint32;
                         Channels: cint32): cint32;  cdecl;
begin
result := uos_flat.uos_AddPlugin(PlayerIndex, PlugName, SampleRate, Channels);
end;
{$endif}

{$IF DEFINED(soundtouch)}
procedure uos_SetPluginSoundTouch({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; PluginIndex: cint32; Tempo: cfloat;
                       Pitch: cfloat; Enable: boolean);  cdecl;
// PluginIndex : PluginIndex Index of a existing Plugin.
// PlayerIndex : Index of a existing Player
begin
uos_flat.uos_SetPluginSoundTouch(PlayerIndex, PluginIndex, Tempo, Pitch, Enable);
end;
{$endif}


function uos_GetStatus({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32) : cint32; cdecl;
// Get the status of the player :-1 => error,  0 => has stopped, 1 => is running, 2 => is paused.
begin
result := uos_flat.uos_GetStatus(PlayerIndex);
end;

procedure uos_InputSeek(PlayerIndex: cint32; InputIndex: cint32; pos: {$if defined(cpu64)} cint64 {$else} cint32 {$endif}); cdecl;
// change position in sample
begin
uos_flat.uos_InputSeek(PlayerIndex, InputIndex, pos);
end;

procedure uos_InputSeekSeconds({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32; pos: cfloat); cdecl;
// change position in seconds
begin
uos_flat.uos_InputSeekSeconds(PlayerIndex, InputIndex, pos);
end;

procedure uos_InputSeekTime({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32; pos: TTime); cdecl;
// change position in time format
begin
uos_flat.uos_InputSeekTime(PlayerIndex, InputIndex, pos);
end;

function uos_InputLength({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): {$if defined(cpu64)} cint64 {$else} cint32 {$endif};  cdecl;
// InputIndex : InputIndex of existing input
//  result : Length of Input in samples
begin
result := uos_flat.uos_InputLength(PlayerIndex, InputIndex);
end;

function uos_InputLengthSeconds({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): cfloat;  cdecl;
// InputIndex : InputIndex of existing input
//  result : Length of Input in seconds
begin
result := uos_flat.uos_InputLengthSeconds(PlayerIndex, InputIndex);
end;

function uos_InputLengthTime({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): TTime; cdecl;
// InputIndex : InputIndex of existing input
//  result : Length of Input in time format
begin
result := uos_flat.uos_InputLengthTime(PlayerIndex, InputIndex);
end;

function uos_InputPosition({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): cint32; cdecl;
// InputIndex : InputIndex of existing input
// result : current postion in sample
begin
result := uos_flat.uos_InputPosition(PlayerIndex, InputIndex);
end;

procedure uos_InputSetLevelEnable({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);  cdecl;
// set level calculation (default is 0)
// InputIndex : InputIndex of existing input
// 0 => no calcul
// 1 => calcul before all DSP procedures.
// 2 => calcul after all DSP procedures.
// 3 => calcul before and after all DSP procedures.
begin
uos_flat.uos_InputSetLevelEnable(PlayerIndex, InputIndex, enable);
end;

procedure uos_InputSetPositionEnable({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32 ; enable : cint32);  cdecl;
// set position calculation (default is 0)
// InputIndex : InputIndex of existing input
// 0 => no calcul
// 1 => calcul position.
begin
uos_flat.uos_InputSetPositionEnable(PlayerIndex, InputIndex, enable);
end;

procedure uos_InputSetArrayLevelEnable({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32 ; levelcalc : cint32);
// set add level calculation in level-array (default is 0)
// 0 => no calcul
// 1 => calcul before all DSP procedures.
// 2 => calcul after all DSP procedures.
begin
uos_flat.uos_InputSetArrayLevelEnable(PlayerIndex, InputIndex, levelcalc);
end;

// todo => function uos_InputGetLevelArray(PlayerIndex: cint32; InputIndex: LongInt) : TDArFloat;


function uos_InputGetLevelLeft({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): double; cdecl;
// InputIndex : InputIndex of existing input
// result : left volume from 0 to 1
begin
result := uos_flat.uos_InputGetLevelLeft(PlayerIndex, InputIndex);
end;

function uos_InputGetLevelRight({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): double; cdecl;
// InputIndex : InputIndex of existing input
// result : right volume from 0 to 1
begin
result := uos_flat.uos_InputGetLevelRight(PlayerIndex, InputIndex);
end;

function uos_InputPositionSeconds({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): cfloat; cdecl;
// InputIndex : InputIndex of existing input
//  result : current postion of Input in seconds
begin
result := uos_flat.uos_InputPositionSeconds(PlayerIndex, InputIndex);
end;

function uos_InputPositionTime({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32; InputIndex: cint32): TTime; cdecl;
// InputIndex : InputIndex of existing input
//  result : current postion of Input in time format
begin
result := uos_flat.uos_InputPositionTime(PlayerIndex, InputIndex);
end;

{$IF DEFINED(java)}
function uos_InputGetTagTitle(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; InputIndex: cint32 ) : Jstring ; cdecl;
var
infdev : PAnsiChar;
begin
infdev :=  uos_flat.uos_InputGetTagTitle(PlayerIndex, InputIndex );
result := JNI_StringToJString(PEnv, infdev) ;
end;
{$else}
function uos_InputGetTagTitle(PlayerIndex: cint32; InputIndex: cint32) : PChar ; cdecl;
begin
result := uos_flat.uos_InputGetTagTitle(PlayerIndex, InputIndex );
end;
{$endif}

{$IF DEFINED(java)}
function uos_InputGetTagArtist(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; InputIndex: cint32 ) : Jstring ; cdecl;
var
infdev : PAnsiChar;
begin
infdev :=  uos_flat.uos_InputGetTagArtist(PlayerIndex, InputIndex );
result := JNI_StringToJString(PEnv, infdev) ;
end;
{$else}
function uos_InputGetTagArtist(PlayerIndex: cint32; InputIndex: cint32) : PChar ; cdecl;
begin
result := uos_flat.uos_InputGetTagArtist(PlayerIndex, InputIndex );
end;
{$endif}

{$IF DEFINED(java)}
function uos_InputGetTagAlbum(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; InputIndex: cint32 ) : Jstring ; cdecl;
var
infdev : PAnsiChar;
begin
infdev :=  uos_flat.uos_InputGetTagAlbum(PlayerIndex, InputIndex );
result := JNI_StringToJString(PEnv, infdev) ;
end;
{$else}
function uos_InputGetTagAlbum(PlayerIndex: cint32; InputIndex: cint32) : PChar ; cdecl;
begin
result := uos_flat.uos_InputGetTagAlbum(PlayerIndex, InputIndex );
end;
{$endif}

{$IF DEFINED(java)}
function uos_InputGetTagDate(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; InputIndex: cint32 ) : Jstring ; cdecl;
var
infdev : PAnsiChar;
begin
infdev :=  uos_flat.uos_InputGetTagDate(PlayerIndex, InputIndex );
result := JNI_StringToJString(PEnv, infdev) ;
end;
{$else}
function uos_InputGetTagDate(PlayerIndex: cint32; InputIndex: cint32) : PChar ; cdecl;
begin
result := uos_flat.uos_InputGetTagDate(PlayerIndex, InputIndex );
end;
{$endif}

{$IF DEFINED(java)}
function uos_InputGetTagComment(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; InputIndex: cint32 ) : Jstring ; cdecl;
var
infdev : PAnsiChar;
begin
infdev :=  uos_flat.uos_InputGetTagComment(PlayerIndex, InputIndex );
result := JNI_StringToJString(PEnv, infdev) ;
end;
{$else}
function uos_InputGetTagComment(PlayerIndex: cint32; InputIndex: cint32) : PChar ; cdecl;
begin
result := uos_flat.uos_InputGetTagComment(PlayerIndex, InputIndex );
end;
{$endif}

{$IF DEFINED(java)}
function uos_InputGetTagTag(PEnv: PJNIEnv; Obj: JObject; PlayerIndex: cint32; InputIndex: cint32 ) : Jstring ; cdecl;
var
infdev : PAnsiChar;
begin
infdev :=  uos_flat.uos_InputGetTagTag(PlayerIndex, InputIndex );
result := JNI_StringToJString(PEnv, infdev) ;
end;
{$else}
function uos_InputGetTagTag(PlayerIndex: cint32; InputIndex: cint32) : PChar ; cdecl;
begin
result := uos_flat.uos_InputGetTagTag(PlayerIndex, InputIndex );
end;
{$endif}

procedure uos_Play({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32); cdecl;// Start playing
begin
uos_flat.uos_Play(PlayerIndex) ;
end;

procedure uos_RePlay({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32); cdecl;// Resume playing after pause
begin
uos_flat.uos_RePlay(PlayerIndex) ;
end;

procedure uos_Stop({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32); cdecl;// Stop playing and free thread
begin
uos_flat.uos_Stop(PlayerIndex) ;
end;

procedure uos_Pause({$IF DEFINED(java)}PEnv: PJNIEnv; Obj: JObject; {$endif} PlayerIndex: cint32); cdecl;// Pause playing
begin
uos_flat.uos_Pause(PlayerIndex) ;
end;

exports
{$IF DEFINED(java)}
uos_checksynchro name 'Java_' + javappname  + 'uos_checksynchro',
uos_loadlib name 'Java_' + javappname  + 'uos_loadlib',
uos_initclass name 'Java_' + javappname  + 'uos_initclass',
uos_unloadlib name 'Java_' + javappname  + 'uos_unloadlib',
uos_unloadlibcust name 'Java_' + javappname  + 'uos_unloadlibcust',
uos_free name 'Java_' + javappname  + 'uos_free',
uos_loadplugin name 'Java_' + javappname  + 'uos_loadplugin',
uos_unloadplugin name 'Java_' + javappname  + 'uos_unloadplugin',
uos_getinfodevicestr name 'Java_' + javappname  + 'uos_getinfodevicestr',
uos_createplayer name 'Java_' + javappname  + 'uos_createplayer',
uos_addintodevout name 'Java_' + javappname  + 'uos_addintodevout',
uos_addintodevoutdef name 'Java_' + javappname  + 'uos_addintodevoutdef',
{$IF DEFINED(webstream)}
uos_addfromurl name 'Java_' + javappname  + 'uos_addfromurl',
uos_addfromurldef name 'Java_' + javappname  + 'uos_addfromurldef',
{$ENDIF}
uos_addfromsynth name 'Java_' + javappname  + 'uos_addfromsynth',
uos_inputsetsynth name 'Java_' + javappname  + 'uos_inputsetsynth',
uos_addfromfile name 'Java_' + javappname  + 'uos_addfromfile',
uos_addfromfiledef name 'Java_' + javappname  + 'uos_addfromfiledef',
uos_addintofile name 'Java_' + javappname  + 'uos_addintofile',
uos_addintofiledef name 'Java_' + javappname  + 'uos_addintofiledef',
uos_addfromendlessmuted  name 'Java_' + javappname  + 'uos_addfromendlessmuted',
uos_addfromdevin name 'Java_' + javappname  + 'uos_addfromdevin',
uos_addfromdevindef name 'Java_' + javappname  + 'uos_addfromdevindef',
uos_beginproc name 'Java_' + javappname  + 'uos_beginproc',
uos_endproc name 'Java_' + javappname  + 'uos_endproc',
uos_loopprocin name 'Java_' + javappname  + 'uos_loopprocin',
uos_loopprocout name 'Java_' + javappname  + 'uos_loopprocout',
uos_loopbeginproc name 'Java_' + javappname  + 'uos_loopbeginproc',
uos_loopendproc name 'Java_' + javappname  + 'uos_loopendproc',
uos_inputadddspvolume name 'Java_' + javappname  + 'uos_inputadddspvolume',
uos_outputadddspvolume name 'Java_' + javappname  + 'uos_outputadddspvolume',
uos_outputsetdspvolume name 'Java_' + javappname  + 'uos_outputsetdspvolume',
uos_inputsetdspvolume name 'uos_inputsetdspvolume',

{ todo
uos_adddspin name 'Java_' + javappname  + 'uos_adddspin',
uos_adddspout name 'Java_' + javappname  + 'uos_adddspout',
uos_setdspin name 'Java_' + javappname  + 'uos_setdspin',
uos_setdspout name 'Java_' + javappname  + 'uos_setdspout',
}
uos_inputaddfilter name 'Java_' + javappname  + 'uos_inputaddfilter',
uos_outputaddfilter name 'Java_' + javappname  + 'uos_outputaddfilter',
uos_inputsetfilter name 'Java_' + javappname  + 'uos_inputsetfilter',
uos_outputsetfilter name 'Java_' + javappname  + 'uos_outputsetfilter',
uos_addplugin name 'Java_' + javappname  + 'uos_addplugin',
{$IF DEFINED(soundtouch)}
uos_setpluginsoundtouch name 'Java_' + javappname  + 'uos_setpluginsoundtouch',
{$endif}
uos_inputseek name 'Java_' + javappname  + 'uos_inputseek',
uos_inputseekseconds name 'Java_' + javappname  + 'uos_inputseekseconds',
uos_getstatus name 'Java_' + javappname  + 'uos_getstatus',
uos_inputseektime name 'Java_' + javappname  + 'uos_seektime',
uos_inputlength name 'Java_' + javappname  + 'uos_inputlength',
uos_inputlengthseconds name 'Java_' + javappname  + 'uos_inputlengthseconds',
uos_inputlengthtime name 'Java_' + javappname  + 'uos_inputlengthtime',
uos_inputposition name 'Java_' + javappname  + 'uos_inputposition',
uos_inputsetlevelenable name 'Java_' + javappname  + 'uos_inputsetlevelenable',
uos_inputsetpositionenable name 'Java_' + javappname  + 'uos_inputsetpositionenable',
uos_inputsetarraylevelenable name 'Java_' + javappname  + 'uos_inputsetarraylevelenable',
uos_inputgetlevelleft name 'Java_' + javappname  + 'uos_inputgetlevelleft',
uos_inputgetlevelright name 'Java_' + javappname  + 'uos_inputgetlevelright',
uos_inputpositionseconds name 'Java_' + javappname  + 'uos_inputpositionseconds',
uos_inputpositiontime name 'Java_' + javappname  + 'uos_inputpositiontime',
uos_inputgetsamplerate name 'Java_' + javappname  + 'uos_inputgetsamplerate',
uos_inputgetchannels name 'Java_' + javappname  + 'uos_inputgetchannels',
uos_inputgettagtitle name 'Java_' + javappname  + 'uos_inputgettagtitle',
uos_inputgettagartist name 'Java_' + javappname  + 'uos_inputgettagartist',
uos_inputgettagalbum name 'Java_' + javappname  + 'uos_inputgettagalbum',
uos_inputgettagdate name 'Java_' + javappname  + 'uos_inputgettagdate',
uos_inputgettagcomment name 'Java_' + javappname  + 'uos_inputgettagcomment',
uos_inputgettagtag name 'Java_' + javappname  + 'uos_inputgettagtag',
uos_play name 'Java_' + javappname  + 'uos_play',
uos_replay name 'Java_' + javappname  + 'uos_replay',
uos_stop name 'Java_' + javappname  + 'uos_stop',
uos_pause name 'Java_' + javappname  + 'uos_pause',
uos_getversion name 'Java_' + javappname  + 'uos_getversion';

{$else}
uos_loadlib name  'uos_loadlib',
uos_unloadlib name 'uos_unloadlib',
uos_loadplugin name 'uos_loadplugin',
uos_unloadplugin name 'uos_unloadplugin',
uos_checksynchro name 'uos_checksynchro',
uos_unloadlibcust name 'uos_unloadlibcust',
uos_free name 'uos_free',
uos_getinfodevicestr name 'uos_getinfodevicestr',
uos_createplayer name 'uos_createplayer',
uos_addintodevout name 'uos_addintodevout',
uos_addintodevoutdef name 'uos_addintodevoutdef',
uos_addfromfile name 'uos_addfromfile',
uos_addfromfiledef name 'uos_addfromfiledef',
uos_addintofile name 'uos_addintofile',
uos_addintofiledef name 'uos_addintofiledef',
{$IF DEFINED(webstream)}
uos_addfromurl name 'uos_addfromurl',
uos_addfromurldef name 'uos_addfromurldef',
{$ENDIF}
uos_addfromendlessmuted name 'uos_addfromendlessmuted',
uos_addfromdevin name 'uos_addfromdevin',
uos_addfromdevindef name 'uos_addfromdevindef',
uos_addfromsynth name 'Java_' + javappname  + 'uos_addfromsynth',
uos_inputsetsynth name 'Java_' + javappname  + 'uos_inputsetsynth',
uos_beginproc name 'uos_beginproc',
uos_endproc name 'uos_endproc',
uos_loopprocin name 'uos_loopprocin',
uos_loopprocout name 'uos_loopprocout',
uos_loopbeginproc name 'uos_loopbeginproc',
uos_loopendproc name 'uos_loopendproc',
uos_inputadddspvolume name 'uos_inputadddspvolume',
uos_outputadddspvolume name 'uos_outputadddspvolume',
uos_inputsetdspvolume name 'uos_inputsetdspvolume',
uos_outputsetdspvolume name 'uos_outputsetdspvolume',
{ todo
uos_adddspin name 'uos_adddspin',
uos_adddspout name 'uos_adddspout',
uos_setdspin name 'uos_setdspin',
uos_setdspout name 'uos_setdspout',
}
uos_inputaddfilter name 'uos_inputaddfilter',
uos_outputaddfilter name 'uos_outputaddfilter',
uos_inputsetfilter name 'uos_inputsetfilter',
uos_outputsetfilter name 'uos_outputsetfilter',
uos_addplugin name 'uos_addplugin',
{$IF DEFINED(soundtouch)}
uos_setpluginsoundtouch name 'uos_setpluginsoundtouch',
{$endif}
uos_inputseek name 'uos_inputseek',
uos_inputseekseconds name 'uos_inputseekseconds',
uos_getstatus name 'uos_getstatus',
uos_inputseektime name 'uos_inputseektime',
uos_inputlength name 'uos_inputlength',
uos_inputlengthseconds name 'uos_inputlengthseconds',
uos_inputlengthtime name 'uos_inputlengthtime',
uos_inputposition name 'uos_inputposition',
uos_inputsetlevelenable name 'uos_inputsetlevelenable',
uos_inputsetpositionenable name 'uos_inputsetpositionenable',
uos_inputsetarraylevelenable name 'uos_inputsetarraylevelenable',
uos_inputgetlevelleft name 'uos_inputgetlevelleft',
uos_inputgetlevelright name 'uos_inputgetlevelright',
uos_inputpositionseconds name 'uos_inputpositionseconds',
uos_inputpositiontime name 'uos_inputpositiontime',
uos_inputgetsamplerate name 'uos_inputgetsamplerate',
uos_inputgetchannels name 'uos_inputgetchannels',
uos_inputgettagtitle name 'uos_inputgettagtitle',
uos_inputgettagartist name 'uos_inputgettagartist',
uos_inputgettagalbum name 'uos_inputgettagalbum',
uos_inputgettagdate name 'uos_inputgettagdate',
uos_inputgettagcomment name 'uos_inputgettagcomment',
uos_inputgettagtag name 'uos_inputgettagtag',
uos_play name 'uos_play',
uos_replay name 'uos_replay',
uos_stop name 'uos_stop',
uos_pause name 'uos_pause',
uos_getversion name 'uos_getversion';
{$endif}

begin
end.
