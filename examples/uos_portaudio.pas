{This unit is part of United Openlibraries of Sound (uos)}

{This is the Dynamic loading version of PortAudio Pascal Wrapper.
 Load library with pa_load() and release with pa_unload().
 License : modified LGPL. 
 Fred van Stappen / fiens@hotmail.com 
 Reference counting added by Max Karpushin / homeplaner@yandex.ru} 

unit uos_portaudio;

{$IFDEF FPC}
   {$mode objfpc}{$H+}
   {$PACKRECORDS C}
{$else}
   {$MINENUMSIZE 4} (* use 4-byte enums *)
{$endif}

interface
{$IFNDEF FPC}
   uses classes, sysutils, windows, DELPHIctypes;
{$else}
   uses dynlibs, CTypes;
{$endif}
  
const
libpa=
 {$IFDEF unix}
{$IFDEF darwin}
 'libportaudio.2.dylib';
  {$ELSE}
 'libportaudio.so.2';
  {$ENDIF}    
   {$ELSE}
 'portaudio.dll';
  {$ENDIF} 

type
  PaError = CInt32;
  PaErrorCode =(
    paNotInitialized = -10000,
    paUnanticipatedHostError,
    paInvalidChannelCount,
    paInvalidSampleRate,
    paInvalidDevice,
    paInvalidFlag,
    paSampleFormatNotSupported,
    paBadIODeviceCombination,
    paInsufficientMemory,
    paBufferTooBig,
    paBufferTooSmall,
    paNullCallback,
    paBadStreamPtr,
    paTimedOut,
    paInternalError,
    paDeviceUnavailable,
    paIncompatibleHostApiSpecificStreamInfo,
    paStreamIsStopped,
    paStreamIsNotStopped,
    paInputOverflowed,
    paOutputUnderflowed,
    paHostApiNotFound,
    paInvalidHostApi,
    paCanNotReadFromACallbackStream,
    paCanNotWriteToACallbackStream,
    paCanNotReadFromAnOutputOnlyStream,
    paCanNotWriteToAnInputOnlyStream,
    paIncompatibleStreamHostApi,
    paBadBufferPtr,
    paNoError = 0
  );

  PaDeviceIndex = CInt32;
  
  PaHostApiIndex = CInt32;
  
  PaHostApiTypeId =(paInDevelopment = 0,
    paDirectSound = 1,
    paMME = 2,
    paASIO = 3,
    paSoundManager = 4,
    paCoreAudio = 5,
    paOSS = 7,
    paALSA = 8,
    paAL = 9,
    paBeOS = 10,
    paWDMKS = 11,
    paJACK = 12,
    paWASAPI = 13,
    paAudioScienceHPI = 14
  );

  PaHostApiInfo = record
    structVersion : CInt32;
    _type : PaHostApiTypeId ;
    _name : Pchar;
    deviceCount : CInt32;
    defaultInputDevice : PaDeviceIndex;
    defaultOutputDevice : PaDeviceIndex;
  end;
  PPaHostApiInfo = ^PaHostApiInfo;

  PaHostErrorInfo = record
    hostApiType : PaHostApiTypeId;
    errorCode : CLong;
    errorText : PChar;
  end;
  PPaHostErrorInfo = ^PaHostErrorInfo;

  PaTime = CDouble;

  PaSampleFormat = pCULongLong;

  PaDeviceInfo = record
    structVersion : CInt32;
    _name : PChar;
    hostApi : PaHostApiIndex;
    maxInputChannels : CInt32;
    maxOutputChannels : CInt32;
    defaultLowInputLatency : PaTime;
    defaultLowOutputLatency : PaTime;
    defaultHighInputLatency : PaTime;
    defaultHighOutputLatency : PaTime;
    defaultSampleRate : CDouble;
  end;
  PPaDeviceInfo = ^PaDeviceInfo;

  PaStreamParameters = record
    device : PaDeviceIndex;
    channelCount : CInt32;
    sampleFormat : PaSampleFormat;
    suggestedLatency : PaTime;
    hostApiSpecificStreamInfo : Pointer;
  end;
  PPaStreamParameters = ^PaStreamParameters;

  // ************************* Streaming types *************************

  PaStream = Pointer;
  PPaStream = ^PaStream;
  PPPaStream = ^PPaStream;

  PaStreamFlags = CULong;

  PaStreamCallbackTimeInfo = record
    inputBufferAdcTime : PaTime;
    currentTime : PaTime;
    outputBufferDacTime : PaTime;
  end;
  PPaStreamCallbackTimeInfo = ^PaStreamCallbackTimeInfo;

  PaStreamCallbackFlags = CULong;

  PaStreamCallbackResult =(
    paContinue = 0,
    paComplete = 1,
    paAbort = 2);

  PaStreamCallback = function(
    input : Pointer;
    output : Pointer;
    frameCount : CULong;
    timeInfo : PPaStreamCallbackTimeInfo;
    statusFlags : PaStreamCallbackFlags;
    userData : Pointer) : CInt32;
  PPaStreamCallback = ^PaStreamCallback;

  PaStreamFinishedCallback = procedure(userData : Pointer); cdecl;
  PPaStreamFinishedCallback = ^PaStreamFinishedCallback;

  PaStreamInfo = record
    structVersion : CInt32;
    inputLatency : PaTime;
    outputLatency : PaTime;
    sampleRate : CDouble;
  end;
  PPaStreamInfo = ^PaStreamInfo;

    const
  paFormatIsSupported = 0;
  paFramesPerBufferUnspecified = 0;
  paNoDevice = PaDeviceIndex(-1);
  paUseHostApiSpecificDeviceSpecification = PaDeviceIndex(-2);
  paFloat32 = PaSampleFormat($00000001);
  paInt32 = PaSampleFormat($00000002);
  paInt24 = PaSampleFormat($00000004);
  paInt16 = PaSampleFormat($00000008);
  paInt8 = PaSampleFormat($00000010);
  paUInt8 = PaSampleFormat($00000020);
  paCustomFormat = PaSampleFormat($00010000);
  paNonInterleaved = PaSampleFormat($80000000);
  paNoFlag = PaStreamFlags(0);
  paClipOff = PaStreamFlags($00000001);
  paDitherOff = PaStreamFlags($00000002);
  paNeverDropInput = PaStreamFlags($00000004);
  paPrimeOutputBuffersUsingStreamCallback = PaStreamFlags($00000008);
  paPlatformSpecificFlags = PaStreamFlags($FFFF0000);
  paInputUnderflow = PaStreamCallbackFlags($00000001);
  paInputOverflow = PaStreamCallbackFlags($00000002);
  paOutputUnderflow = PaStreamCallbackFlags($00000004);
  paOutputOverflow = PaStreamCallbackFlags($00000008);
  paPrimingOutput = PaStreamCallbackFlags($00000010);

  ////// Dynamic load : Vars that will hold our dynamically loaded functions...

// *************************** functions *******************************

    var Pa_GetVersion: function():CInt32 ; cdecl;

    var Pa_GetVersionText: function():PChar ; cdecl;

    var Pa_GetErrorText: function(errorCode : PaError):PChar ; cdecl;

    var Pa_Initialize: function():PaError ; cdecl;

    var Pa_Terminate: function():PaError ; cdecl;

    var Pa_GetHostApiCount: function():PaHostApiIndex ; cdecl;

    var Pa_GetDefaultHostApi: function():PaHostApiIndex ; cdecl;

    var Pa_GetHostApiInfo: function(hostApi : PaHostApiIndex):PPaHostApiInfo ; cdecl;

    var Pa_HostApiTypeIdToHostApiIndex: function(_type : PaHostApiTypeId):PaHostApiIndex ; cdecl;

    var Pa_HostApiDeviceIndexToDeviceIndex: function(hostApi : PaHostApiIndex;hostApiDeviceIndex : CInt32):PaDeviceIndex ; cdecl;

    var Pa_GetLastHostErrorInfo: function():PPaHostErrorInfo ; cdecl;

// ************** Device enumeration and capabilities ******************

    var Pa_GetDeviceCount: function:PaDeviceIndex ; cdecl;

    var Pa_GetDefaultInputDevice: function:PaDeviceIndex ; cdecl;

    var Pa_GetDefaultOutputDevice: function:PaDeviceIndex ; cdecl;

    var Pa_GetDeviceInfo: function(device : PaDeviceIndex):PPaDeviceInfo ; cdecl;

    var Pa_IsFormatSupported: function(inputParameters,outputParameters : PPaStreamParameters; sampleRate : CDouble):PaError ; cdecl;

// *********************** Stream function *****************************

    var Pa_OpenStream: function(stream : PPPaStream;
  inputParameters : PPaStreamParameters;
  outputParameters : PPaStreamParameters;
  sampleRate : CDouble;
  framesPerBuffer : CULong;
  streamFlags : PaStreamFlags;
  streamCallback : PPaStreamCallback;
  userData : Pointer):PaError ; cdecl;

    var Pa_OpenDefaultStream: function(stream : PPPaStream;
  numInputChannels : CInt32;
  numOutputChannels : CInt32;
  sampleFormat : PaSampleFormat;
  sampleRate : CDouble;
  framesPerBuffer : CULong;
  streamCallback : PaStreamCallback;
  userData : Pointer):PaError ; cdecl;

    var Pa_CloseStream: function(stream : PPaStream):PaError ; cdecl;

    var Pa_SetStreamFinishedCallback: function(stream : PPaStream;
  streamFinishedCallback : PaStreamFinishedCallback):PaError ; cdecl;

    var Pa_StartStream: function(stream : PPaStream):PaError ; cdecl;

    var Pa_StopStream: function(stream : PPaStream):PaError ; cdecl;

    var Pa_AbortStream: function(stream : PPaStream):PaError ; cdecl;

    var Pa_IsStreamStopped: function(stream : PPaStream):PaError ; cdecl;

    var Pa_IsStreamActive: function(stream : PPaStream):PaError ; cdecl;

    var Pa_GetStreamInfo: function(stream : PPaStream):PPaStreamInfo ; cdecl;

    var Pa_GetStreamTime: function(stream : PPaStream):Patime ; cdecl;

    var Pa_GetStreamCpuLoad: function(stream : PPaStream):CDouble ; cdecl;

    var Pa_ReadStream: function(stream : PPaStream; buffer : pcfloat ;frames : CULong):PaError ; cdecl;

    var Pa_WriteStream: function(stream : PPaStream; buffer : pcfloat ;frames : CULong):PaError ; cdecl;

    var Pa_GetStreamReadAvailable: function(stream : PPaStream):CSLong ; cdecl;

    var Pa_GetStreamWriteAvailable: function(stream : PPaStream):CSLong ; cdecl;

// ****************** Miscellaneous utilities **************************

    var Pa_GetSampleSize: function(format : PaSampleFormat):PaError ; cdecl;

    var Pa_Sleep: function(msec : CLong) : integer; cdecl;

  ///////////////////////////////////////////////

       {Special function for dynamic loading of lib ...}
  {$IFDEF FPC}
    var Pa_Handle:TLibHandle=dynlibs.NilHandle; // this will hold our handle for the lib; it functions nicely as a mutli-lib prevention unit as well...
  {$ELSE}
  var Pa_Handle:THandle=0;
  {$ENDIF FPC}

    var ReferenceCounter : cardinal = 0;  // Reference counter
         
    function Pa_IsLoaded : boolean; inline;

    Function Pa_Load(const libfilename:string) :boolean; // load the lib

    Procedure Pa_Unload(); // unload and frees the lib from memory : do not forget to call it before close application.

       /////////////////////////////////////////////////////////////////////////////////////////////////

implementation

function Pa_IsLoaded: boolean;
begin
   {$IFNDEF FPC}
   Result := (Pa_Handle <> 0);
   {$else}
   Result := (Pa_Handle <> dynlibs.NilHandle);
   {$endif}
end;

Function Pa_Load (const libfilename:string) :boolean;
var
thelib: string; 
begin
  Result := False;
  if Pa_Handle<>0 then
  begin
   Inc(ReferenceCounter);
   result:=true {is it already there ?}
  end
  else begin {go & load the library}
      if Length(libfilename) = 0
      then thelib := libpa
      else thelib := libfilename;
  {$IFNDEF FPC}
  Pa_Handle:=SafeLoadLibrary(thelib); // obtain the handle we want
  {$else}
  Pa_Handle:=DynLibs.SafeLoadLibrary(thelib); // obtain the handle we want
  {$endif}
      {$IFNDEF FPC}
      if Pa_Handle <> 0 then
      begin {now we tie the functions to the VARs from above}
      @Pa_GetVersion := GetProcAddress(PA_Handle,('Pa_GetVersion'));
      @Pa_GetVersionText:=GetProcAddress(PA_Handle,('Pa_GetVersionText'));
      @Pa_GetErrorText:=GetProcAddress(PA_Handle,('Pa_GetErrorText'));
      @Pa_Initialize:=GetProcAddress(PA_Handle,('Pa_Initialize'));
      @Pa_Terminate:=GetProcAddress(PA_Handle,('Pa_Terminate'));
      @Pa_GetHostApiCount:=GetProcAddress(PA_Handle,('Pa_GetHostApiCount'));
      @Pa_GetDefaultHostApi:=GetProcAddress(PA_Handle,('Pa_GetDefaultHostApi'));
      @Pa_GetHostApiInfo:=GetProcAddress(PA_Handle,('Pa_GetHostApiInfo'));
      @Pa_HostApiTypeIdToHostApiIndex:=GetProcAddress(PA_Handle,('Pa_HostApiTypeIdToHostApiIndex'));
      @Pa_HostApiDeviceIndexToDeviceIndex:=GetProcAddress(PA_Handle,('Pa_HostApiDeviceIndexToDeviceIndex'));
      @Pa_GetLastHostErrorInfo:=GetProcAddress(PA_Handle,('Pa_GetLastHostErrorInfo'));
       //////////////////
      @Pa_GetDeviceCount:=GetProcAddress(PA_Handle,('Pa_GetDeviceCount'));
      @Pa_GetDefaultInputDevice:=GetProcAddress(PA_Handle,('Pa_GetDefaultInputDevice'));
      @Pa_GetDefaultOutputDevice:=GetProcAddress(PA_Handle,('Pa_GetDefaultOutputDevice'));
      @Pa_GetDeviceInfo:=GetProcAddress(PA_Handle,('Pa_GetDeviceInfo'));
      @Pa_IsFormatSupported:=GetProcAddress(PA_Handle,('Pa_IsFormatSupported'));
       //////////////////////
       @Pa_OpenStream:=GetProcAddress(PA_Handle,('Pa_OpenStream'));
      @Pa_OpenDefaultStream:=GetProcAddress(PA_Handle,('Pa_OpenDefaultStream'));
      @Pa_CloseStream:=GetProcAddress(PA_Handle,('Pa_CloseStream'));
      @Pa_SetStreamFinishedCallback:=GetProcAddress(PA_Handle,('Pa_SetStreamFinishedCallback'));
      @Pa_StartStream:=GetProcAddress(PA_Handle,('Pa_StartStream'));
      @Pa_StopStream:=GetProcAddress(PA_Handle,('Pa_StopStream'));
      @Pa_AbortStream:=GetProcAddress(PA_Handle,('Pa_AbortStream'));
      @Pa_IsStreamStopped:=GetProcAddress(PA_Handle,('Pa_IsStreamStopped'));
      @Pa_IsStreamActive:=GetProcAddress(PA_Handle,('Pa_IsStreamActive'));
      @Pa_GetStreamInfo:=GetProcAddress(PA_Handle,('Pa_GetStreamInfo'));
      @Pa_GetStreamTime:=GetProcAddress(PA_Handle,('Pa_GetStreamTime'));
      @Pa_GetStreamCpuLoad:=GetProcAddress(PA_Handle,('Pa_GetStreamCpuLoad'));
      @Pa_ReadStream:=GetProcAddress(PA_Handle,('Pa_ReadStream'));
      @Pa_WriteStream:=GetProcAddress(PA_Handle,('Pa_WriteStream'));
      @Pa_GetStreamReadAvailable:=GetProcAddress(PA_Handle,('Pa_GetStreamReadAvailable'));
      @Pa_GetStreamWriteAvailable:=GetProcAddress(PA_Handle,('Pa_GetStreamWriteAvailable'));
      @Pa_GetSampleSize:=GetProcAddress(PA_Handle,('Pa_GetSampleSize'));
      @Pa_Sleep:=GetProcAddress(PA_Handle,('Pa_Sleep'));
      end;
      {$else}
  	  if Pa_Handle <> DynLibs.NilHandle then
      begin {now we tie the functions to the VARs from above}

      Pointer(Pa_GetVersion):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetVersion'));
      Pointer(Pa_GetVersionText):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetVersionText'));
      Pointer(Pa_GetErrorText):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetErrorText'));
      Pointer(Pa_Initialize):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_Initialize'));
      Pointer(Pa_Terminate):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_Terminate'));
      Pointer(Pa_GetHostApiCount):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetHostApiCount'));
      Pointer(Pa_GetDefaultHostApi):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetDefaultHostApi'));
      Pointer(Pa_GetHostApiInfo):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetHostApiInfo'));
      Pointer(Pa_HostApiTypeIdToHostApiIndex):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_HostApiTypeIdToHostApiIndex'));
      Pointer(Pa_HostApiDeviceIndexToDeviceIndex):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_HostApiDeviceIndexToDeviceIndex'));
      Pointer(Pa_GetLastHostErrorInfo):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetLastHostErrorInfo'));
      //////////////////
      Pointer(Pa_GetDeviceCount):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetDeviceCount'));
      Pointer(Pa_GetDefaultInputDevice):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetDefaultInputDevice'));
      Pointer(Pa_GetDefaultOutputDevice):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetDefaultOutputDevice'));
      Pointer(Pa_GetDeviceInfo):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetDeviceInfo'));
      Pointer(Pa_IsFormatSupported):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_IsFormatSupported'));
      //////////////////////
      Pointer(Pa_OpenStream):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_OpenStream'));
      Pointer(Pa_OpenDefaultStream):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_OpenDefaultStream'));
      Pointer(Pa_CloseStream):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_CloseStream'));
      Pointer(Pa_SetStreamFinishedCallback):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_SetStreamFinishedCallback'));
      Pointer(Pa_StartStream):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_StartStream'));
      Pointer(Pa_StopStream):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_StopStream'));
      Pointer(Pa_AbortStream):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_AbortStream'));
      Pointer(Pa_IsStreamStopped):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_IsStreamStopped'));
      Pointer(Pa_IsStreamActive):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_IsStreamActive'));
      Pointer(Pa_GetStreamInfo):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetStreamInfo'));
      Pointer(Pa_GetStreamTime):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetStreamTime'));
      Pointer(Pa_GetStreamCpuLoad):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetStreamCpuLoad'));
      Pointer(Pa_ReadStream):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_ReadStream'));
      Pointer(Pa_WriteStream):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_WriteStream'));
      Pointer(Pa_GetStreamReadAvailable):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetStreamReadAvailable'));
      Pointer(Pa_GetStreamWriteAvailable):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetStreamWriteAvailable'));
      Pointer(Pa_GetSampleSize):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_GetSampleSize'));
      Pointer(Pa_Sleep):=DynLibs.GetProcedureAddress(PA_Handle,PChar('Pa_Sleep'));
      end;
      {$endif}
   Result := Pa_IsLoaded;
   ReferenceCounter:=1;   
end;

end;

Procedure Pa_Unload;
begin
// < Reference counting
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >
      {$IFNDEF FPC}
      FreeLibrary(Pa_Handle);
      Pa_Handle:=0;
      {$else}
      DynLibs.UnloadLibrary(Pa_Handle);
      Pa_Handle:=DynLibs.NilHandle;
      {$endif}
end;

end.

