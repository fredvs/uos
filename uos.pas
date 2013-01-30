unit uos;

{*******************************************************************************
*                  United Openlibraries of Sound ( UOS )                       *
*                  --------------------------------------                      *
*                                                                              *
*          United procedures to access Open Sound (IN/OUT) libraries           *
*                                                                              *
*              With Big contributions of (in alphabetic order)                 *
*          BigChimp, Blaazen, KpjComp, Leledumbo, Lazarus forum, ...           *
*                                                                              *
*                 Fred van Stappen /  fiens@hotmail.com                        *
*                                                                              *
*                                                                              *
********************************************************************************
*  first changes:  2012-07-20   (first shot)                                   *
*  second changes: 2012-07-31   (mono thread, only one stream)                 *
*  3 th changes: 2012-11-13  (mono thread, multi streams)                      *
*  4 th changes: 2012-11-14  (multi threads, multi streams)                    *
*  5 th changes: 2012-11-27 (event pause, position, volume, reverse)           *
*  6 th changes: 2012-12-31 (Class/Oop look, DSP, multi IN/OUT)                *
*  7 th changes: 2013-01-12 (Float resolution for all, new DSP proc)           *
*  8 th changes: 2013-01-21 (Record, Direct Wire, Save to file, new DSP proc)  *
*  9 th changes: 2013-01-28 (FFT, Filters HighPass, LowPass, BandSelect,       *
*                                    BandReject, BandPass)                     *
*                                                                              *
********************************************************************************}

interface

uses
  Classes, ctypes, Math, SysUtils, Dialogs, LazDyn_PortAudio,
  LazDyn_LibSndFile, LazDyn_Mpg123;

type
  TArFloat = array[0..$ffff] of cfloat;
  TArShort = array[0..$ffff] of cInt16;
  TArLong = array[0..$ffff] of cInt32;
  PArFloat = ^TArFloat;
  PArShort = ^TArShort;
  PArLong = ^TArLong;

const
  ///// error
  noError = 0;
  FilePAError = 10;
  LoadPAError = 11;
  FileSFError = 20;
  LoadSFError = 21;
  FileMPError = 30;
  LoadMPError = 31;
  //////// UOS_load() flag
  LoadAll = 0;   // load all PortAudio + SndFile + MPG123
  LoadPA = 1;   // load only PortAudio
  LoadSF = 2;   // load only SndFile
  LoadMP = 3;   // load only MPG123
  LoadPA_SF = 4;   // load only PortAudio + SndFile
  LoadPA_MP = 5;   // load only PortAudio + MPG123
  LoadSF_MP = 6;   // load only SndFile + MPG123
  ///// UOS Audio
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

type
  TUOS_LoadResult = record
    PAloadError: shortint;
    SFloadError: shortint;
    MPloadError: shortint;
    PAinitError: integer;
    MPinitError: integer;
  end;

type
  TUOS_Init = class(TObject)
  private
    old8087cw: word;
  public
    PA_FileName: ansistring;
    SF_FileName: ansistring;
    MP_FileName: ansistring;
    flag: shortint;     ////// Default is 0 : load all ;
    LoadResult: TUOS_LoadResult;
    DefDevOut: PaDeviceIndex;
    DefDevOutInfo: PPaDeviceInfo;
    DefDevOutAPIInfo: PPaHostApiInfo;
    DefDevIn: PaDeviceIndex;
    DefDevInInfo: PPaDeviceInfo;
    DefDevInAPIInfo: PPaHostApiInfo;
    constructor Create;
    procedure LoadLib;
    procedure InitLib;
    procedure UnloadLib;
  end;

type
  TUOS_WaveHeaderChunk = packed record
    wFormatTag: smallint;
    wChannels: word;
    wSamplesPerSec: cardinal;
    wAvgBytesPerSec: cardinal;
    wBlockAlign: word;
    wBitsPerSample: word;
    wcbSize: word;
  end;

type
  TUOS_FileBuffer = record
    ERROR: word;
    wSamplesPerSec: cardinal;
    wBitsPerSample: word;
    wChannels: word;
    Data: TMemoryStream;
  end;

type
  TUOS_Data = record
    /////////////// common data
    Enabled: boolean;
    TypePut: shortint;    ////// -1 : nothing,  //// for Input : 0:from audio file, 1:from input device, 2:from other stream
                                                //// for Output : 0:into wav file, 1:into output device, 2:to other stream
    Seekable: boolean;
    Status: shortint;
    Buffer: TArFloat;
    VLeft, VRight: double;
     {$if defined(cpu64)}
    Wantframes: Tsf_count_t;
    OutFrames: Tsf_count_t;
    {$else}
    Wantframes: longint;
    OutFrames: longint;
    {$endif}
    SamplerateRoot: longword;
    SampleRate: longword;
    SampleFormat: shortint;
    Channels: integer;
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
    HDFormat: integer;
    Frames: Tsf_count_t;
    Sections: integer;
    Encoding: integer;
    Lengthst: integer;     ///////  in sample ;
    LibOpen: shortint;    //// -1 : nothing open, 0 : sndfile open, 1 : mpg123 open
    Ratio: shortint;      ////  if mpg123 then ratio := 2
    Position: longint;
    Poseek: longint;
    Output: integer;
    PAParam: PaStreamParameters;
    FileBuffer: TUOS_FileBuffer;

  end;

type
  TUOS_FFT = class(TObject)
  public
    TypeFilter: shortint;
    LowFrequency, HighFrequency: integer;
    AlsoBuf: Boolean;
    a3, a32: array[0..2] of cfloat;
    b2, x0, x1, y0, y1, b22, x02, x12, y02, y12: array[0..1] of cfloat;
    C, D, C2, D2, Gain, LeftResult, RightResult: cfloat;
  end;

type
  TProc = function(Data: TUOS_Data; FFT: TUOS_FFT): TArFloat;

type
  TUOS_InStream = class;
  TUOS_OutStream = class;

  TUOS_Player = class(TThread)
  protected
    evPause: PRTLEvent;  // for pausing
    procedure Execute; override;
  public
    Enabled: boolean;
    Status: shortint;
    BeginProc: procedure of object;  //// procedure to execute at begin of thread
    EndProc:  procedure of object;    //// procedure to execute at end of thread
    StreamIn: array of TUOS_InStream;
    StreamOut: array of TUOS_OutStream;
    constructor Create(CreateSuspended: boolean;
      const StackSize: SizeUInt = DefaultStackSize);
    destructor Destroy; override;
    
    /////////////////////Audio procedure
    procedure Play;                  ///// Start playing

    procedure RePlay;                ///// Resume playing after pause

    procedure Stop;                  ///// Stop playing and free thread

    procedure Pause;                 ///// Pause playing

    procedure Seek(InputIndex: integer; pos: Tsf_count_t);  //// change position

    function AddIntoDevOut(Device: integer; Latency: CDouble;
      SampleRate: integer; Channels: integer; SampleFormat: shortint): integer;   ////// Add a Output into Device Output with custom parameters
    function AddIntoDevOut: integer;                          ////// Add a Output into Device Output with default parameters
    //////////// Device ( -1 is default device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //  result : -1 nothing created, otherwise Output Index in array               
    /// example : OutputIndex1 := AddOutput(-1,-1,-1,-1,-1);

    function AddIntoFile(Filename: string; SampleRate: integer;
      Channels: integer; SampleFormat: shortint): integer;  /////// Add a Output into audio wav file with custom parameters
    function AddIntoFile(Filename: string): integer;        /////// Add a Output into audio wav file with default parameters
    ////////// FileName : filename of saved audio wav file
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //  result : -1 nothing created, otherwise Output Index in array     
    //////////// example : OutputIndex1 := AddIntoFile(edit5.Text,-1,-1,0);

    function AddFromDevIn(Device: integer; Latency: CDouble;
      SampleRate: integer; Channels: integer; OutputIndex: integer;
      SampleFormat: shortint): integer;    ////// Add a Input from Device Input with custom parameters
    function AddFromDevIn: integer;        ////// Add a Input from Device Input with default parameters
    //////////// Device ( -1 is default Input device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other integer refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //  result : -1 nothing created, otherwise Output Index in array               
    /// example : OutputIndex1 := AddFromDevice(-1,-1,-1,-1,-1,-1);

    function AddFromFile(Filename: string; OutputIndex: integer;
      SampleFormat: shortint): integer;                  /////// Add a input from audio file with custom parameters
    function AddFromFile(Filename: string): integer;     /////// Add a input from audio file with default parameters
    ////////// FileName : filename of audio file
    ////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other integer refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //  result : -1 nothing created, otherwise Input Index in array     
    //////////// example : InputIndex1 := AddFromFile(edit5.Text,-1,-1);

    function InputLength(InputIndex: integer): longint;
    ////////// InputIndex : InputIndex of existing input
    ///////  result : Lenght of Input in samples

    function InputPosition(InputIndex: integer): longint;
    ////////// InputIndex : InputIndex of existing input
    ////// result : current postion of sample 

    function AddDSPin(InputIndex: integer; BeforeProc: TProc; AfterProc: TProc): integer;
    ///// add a DSP procedure for input
    ////////// InputIndex : Input Index of a existing input
    ////////// BeforeProc : procedure to do before the buffer is filled
    ////////// AfterProc : procedure to do after the buffer is filled
    //  result : -1 nothing created, otherwise index of DSPin in array  (DSPinIndex)   
    ////////// example : DSPinIndex1 := AddDSPIn(InputIndex1,@beforereverse,@afterreverse);

    procedure SetDSPin(InputIndex: integer; DSPinIndex: integer; Enable: boolean);
    ////////// InputIndex : Input Index of a existing input
    ////////// DSPIndexIn : DSP Index of a existing DSP In
    ////////// Enable :  DSP enabled 
    ////////// example : SetDSPIn(InputIndex1,DSPinIndex1,True);

    function AddDSPout(OutputIndex: integer; BeforeProc: TProc;
      AfterProc: TProc): integer;    //// usefull if multi output
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// BeforeProc : procedure to do before the buffer is filled
    ////////// AfterProc : procedure to do after the buffer is filled just before to give to output
    //  result : -1 nothing created, otherwise index of DSPout in array    
    ////////// example :DSPoutIndex1 := AddDSPout(OutputIndex1,@volumeproc,nil);

    procedure SetDSPout(OutputIndex: integer; DSPoutIndex: integer; Enable: boolean);
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// DSPoutIndex : DSPoutIndex of existing DSPout
    ////////// Enable :  DSP enabled 
    ////////// example : SetDSPIn(OutputIndex1,DSPoutIndex1,True);

    function AddFilterIn(InputIndex: integer; LowFrequency: integer;
      HighFrequency: integer; Gain: cfloat; TypeFilter: integer; AlsoBuf: Boolean): integer;
    ////////// InputIndex : InputIndex of a existing Input
    ////////// LowFrequency : Lowest frequency of filter
    ////////// HighFrequency : Highest frequency of filter
    ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
    /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
    ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
    //  result : -1 nothing created, otherwise index of DSPIn in array    
    ////////// example :FilterInIndex1 := AddFilterIn(InputIndex1,6000,16000,1);

    procedure SetFilterIn(InputIndex: integer; FilterIndex: integer;
      LowFrequency: integer; HighFrequency: integer; Gain: cfloat;
      TypeFilter: integer; AlsoBuf: Boolean; Enable: boolean);
    ////////// InputIndex : InputIndex of a existing Input
    ////////// DSPInIndex : DSPInIndex of existing DSPIn
    ////////// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
    ////////// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
    ////////// Gain : gain to apply to filter
    ////////// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
    /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
    ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
    ////////// Enable :  Filter enabled 
    ////////// example : SetFilterIn(InputIndex1,FilterInIndex1,-1,-1,-1,False,True);

    function AddFilterOut(OutputIndex: integer; LowFrequency: integer;
      HighFrequency: integer; Gain: cfloat; TypeFilter: integer; AlsoBuf: Boolean): integer;
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// LowFrequency : Lowest frequency of filter
    ////////// HighFrequency : Highest frequency of filter
    ////////// Gain : gain to apply to filter
    ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
    /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
    ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
    //  result : -1 nothing created, otherwise index of DSPOut in array    
    ////////// example :FilterOutIndex1 := AddFilterOut(OutputIndex1,6000,16000,1,true);

    procedure SetFilterOut(OutputIndex: integer; FilterIndex: integer;
      LowFrequency: integer; HighFrequency: integer; Gain: cfloat;
      TypeFilter: integer;  AlsoBuf: Boolean; Enable: boolean);
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// FilterIndex : DSPOutIndex of existing DSPOut
    ////////// LowFrequency : Lowest frequency of filter ( -1 : current LowFrequency )
    ////////// HighFrequency : Highest frequency of filter ( -1 : current HighFrequency )
    ////////// Gain : gain to apply to filter
    ////////// TypeFilter: Type of filter : ( -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
    /// fBandPass = 3, fHighPass = 4, fLowPass = 5)
    ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
    ////////// Enable :  Filter enabled 
    ////////// example : SetFilterOut(OutputIndex1,FilterOutIndex1,1000,1500,-1,True,True);

    function AddDSPVolumeIn(InputIndex: integer; VolLeft: double;
      VolRight: double): integer;  ///// DSP Volume changer                               
    ////////// InputIndex : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    //  result : -1 nothing created, otherwise index of DSPIn in array    
    ////////// example  DSPIndex1 := AddDSPVolumeIn(InputIndex1,1,1);

    function AddDSPVolumeOut(OutputIndex: integer; VolLeft: double;
      VolRight: double): integer;  ///// DSP Volume changer                               
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    //  result : -1 nothing created, otherwise index of DSPIn in array    
    ////////// example  DSPIndex1 := AddDSPVolumeIn(InputIndex1,1,1);

    procedure SetDSPVolumeIn(InputIndex: integer; DSPVolIndex: integer;
      VolLeft: double; VolRight: double; Enable: boolean);
    ////////// InputIndex : InputIndex of a existing Input
    ////////// DSPIndex : DSPIndex of a existing DSP
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled
    ////////// example  SetDSPVolumeIn(InputIndex1,DSPIndex1,1,0.8,True);

    procedure SetDSPVolumeOut(OutputIndex: integer; DSPVolIndex: integer;
      VolLeft: double; VolRight: double; Enable: boolean);
    ////////// OutputIndex : OutputIndex of a existing Output
    ////////// DSPIndex : DSPIndex of a existing DSP
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled
    ////////// example  SetDSPVolumeOut(InputIndex1,DSPIndex1,1,0.8,True);

  end;

type
  TUOS_DSP = class(TObject)
  public
    Enabled: boolean;
    BefProc: TProc;     //// Procedure to load before buffer is filled
    AftProc: TProc;     //// Procedure to load after buffer is filled
    ////////////// for FFT
    fftdata: TUOS_FFT;
    destructor Destroy; override;
  end;

type
  TUOS_InStream = class(TObject)
  public
    Data: TUOS_Data;
    DSP: array of TUOS_DSP;
    destructor Destroy; override;
  end;

type
  TUOS_OutStream = class(TObject)
  public
    Data: TUOS_Data;
    DSP: array of TUOS_DSP;
    destructor Destroy; override;
  end;

var
  UOSLoadFlag: shortint;
  UOSLoadResult: TUOS_LoadResult;

implementation

function FormatBuf(Inbuf: TArFloat; format: shortint): TArFloat;
var
  x: integer;
  ps: PArShort;     //////// if input is Int16 format
  pl: PArLong;      //////// if input is Int32 format
  pf: PArFloat;     //////// if input is Float32 format
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

function CvFloat32ToInt16(Inbuf: TArFloat): TArFloat;
var
  x, i: integer;
  arfl: TArFloat;
begin
  for x := 0 to high(Inbuf) do
  begin
    i := round(Inbuf[x] * 32768);
    if i > 32767 then
      i := 32767
    else
    if i < -32768 then
      i := -32768;
    arfl[x] := i;
  end;
  Result := arfl;
end;

function CvInt16ToFloat32(Inbuf: TArFloat): TArFloat;
var
  x: integer;
  arfl: TArFloat;
  ps: PArShort;
begin
  ps := @inbuf;
  for x := 0 to high(Inbuf) do
    arfl[x] := ps^[x] / 32768;
  Result := arfl;
end;

function CvInt32ToFloat32(Inbuf: TArFloat): TArFloat;
var
  x: integer;
  arfl: TArFloat;
  pl: PArLong;
begin
  pl := @inbuf;
  for x := 0 to high(Inbuf) do
    arfl[x] := pl^[x] / 2147483647;
  Result := arfl;
end;

function WriteWave(FileName: ansistring; Data: TUOS_FileBuffer): word;
var
  f: TFileStream;
  wFileSize: cardinal;
  wChunkSize: cardinal;
  ID: array[0..3] of char;
  Header: TUOS_WaveHeaderChunk;
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

procedure TUOS_Player.Play;
var
  x: integer;
  err: shortint;
begin
  err := -1;

  for x := 0 to high(StreamOut) do
    if StreamOut[x].Data.HandleSt <> nil then
    begin
      err := Pa_StartStream(StreamOut[x].Data.HandleSt);
      if err <> 0 then
        MessageDlg(Pa_GetErrorText(err), mtWarning, [mbYes], 0);
    end;

  for x := 0 to high(StreamIn) do
    if (StreamIn[x].Data.HandleSt <> nil) and (StreamIn[x].Data.TypePut = 1) then
    begin
      err := Pa_StartStream(StreamIn[x].Data.HandleSt);
      sleep(200);
      if err <> 0 then
        MessageDlg(Pa_GetErrorText(err), mtWarning, [mbYes], 0);
    end;

  start;   // resume;  //  { if fpc version <= 2.4.4} 

  Enabled := True;
  Status := 1;
  RTLeventSetEvent(evPause);
end;

procedure TUOS_Player.RePlay;   /////// Resume Playing after Pause
begin
  if Enabled = True then
  begin
    Status := 1;
    RTLeventSetEvent(evPause);
  end;
end;

procedure TUOS_Player.Stop;
begin
  if Enabled = True then
  begin
    RTLeventSetEvent(evPause);
    Status := 0;
  end;
end;

procedure TUOS_Player.Pause;
begin
  if Enabled = True then
  begin
    RTLeventResetEvent(evPause);
    Status := 2;
  end;
end;

procedure TUOS_Player.Seek(InputIndex: integer; pos: Tsf_count_t);  //// change position
begin
  if (InputIndex > -1) and (InputIndex < length(StreamIn)) then
    StreamIn[InputIndex].Data.Poseek := pos;
end;

function TUOS_Player.InputPosition(InputIndex: integer): longint;  //// gives current position
begin
  Result := 0;
  if (InputIndex > -1) and (InputIndex < length(StreamIn)) then
    Result := StreamIn[InputIndex].Data.Position;
end;

function TUOS_Player.InputLength(InputIndex: integer): longint;    //// gives length in samples
begin
  Result := 0;
  if (InputIndex > -1) and (InputIndex < length(StreamIn)) then
    Result := StreamIn[InputIndex].Data.Lengthst;
end;

procedure TUOS_Player.SetDSPin(InputIndex: integer; DSPinIndex: integer;
  Enable: boolean);
begin
  if (InputIndex > -1) and (InputIndex < length(StreamIn)) then
    if (DSPinIndex > -1) and (DSPinIndex < length(StreamIn[InputIndex].DSP)) then
      StreamIn[InputIndex].DSP[DSPinIndex].Enabled := Enable;
end;

procedure TUOS_Player.SetDSPOut(OutputIndex: integer; DSPoutIndex: integer;
  Enable: boolean);
begin
  if (OutputIndex > -1) and (OutputIndex < length(StreamOut)) then
    if (DSPoutIndex > -1) and (DSPoutIndex < length(StreamOut[DSPoutIndex].DSP)) then
      StreamOut[OutputIndex].DSP[DSPoutIndex].Enabled := Enable;
end;

function TUOS_Player.AddDSPin(InputIndex: integer; BeforeProc: TProc;
  AfterProc: TProc): integer;
begin
  Result := -1;
  if (InputIndex > -1) and (InputIndex < length(StreamIn)) then
  begin
    SetLength(StreamIn[InputIndex].DSP, Length(StreamIn[InputIndex].DSP) + 1);
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1] := TUOS_DSP.Create();
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].BefProc := BeforeProc;
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].AftProc := AfterProc;
    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].Enabled := True;

    StreamIn[InputIndex].DSP[Length(StreamIn[InputIndex].DSP) - 1].fftdata :=
      TUOS_FFT.Create();

    Result := Length(StreamIn[InputIndex].DSP) - 1;
  end;
end;

function TUOS_Player.AddDSPout(OutputIndex: integer; BeforeProc: TProc;
  AfterProc: TProc): integer;
begin
  Result := -1;
  if (OutputIndex > -1) and (OutputIndex < length(StreamOut)) then
  begin
    SetLength(StreamOut[OutputIndex].DSP, Length(StreamOut[OutputIndex].DSP) + 1);
    StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1] :=
      TUOS_DSP.Create;
    StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1].BefProc :=
      BeforeProc;
    StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1].AftProc :=
      AfterProc;
    StreamOut[OutputIndex].DSP[Length(StreamOut[OutputIndex].DSP) - 1].Enabled := True;
    Result := Length(StreamOut[OutputIndex].DSP) - 1;
  end;
end;

procedure TUOS_Player.SetFilterIn(InputIndex: integer; FilterIndex: integer;
  LowFrequency: integer; HighFrequency: integer; Gain: cfloat;
  TypeFilter: integer; AlsoBuf: Boolean; Enable: boolean);
////////// InputIndex : InputIndex of a existing Input
////////// DSPInIndex : DSPInIndex of existing DSPIn
////////// LowFrequency : Lowest frequency of filter ( default = -1 : current LowFrequency )
////////// HighFrequency : Highest frequency of filter ( default = -1 : current HighFrequency )
////////// Gain   : Gain to apply ( -1 = current gain)  ( 0 = silence, 1 = no gain, < 1 = less gain, > 1 = more gain)
////////// TypeFilter: Type of filter : ( default = -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
/////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
////////// Enable :  Filter enabled 
////////// example : SetFilterIn(InputIndex1,FilterInIndex1,1000,1500,-1,True);
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
          Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamIn[InputIndex].Data.SampleRate);
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
          1 / Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamIn[InputIndex].Data.SampleRate);
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
          Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamIn[InputIndex].Data.SampleRate);
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
          1 / Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamIn[InputIndex].Data.SampleRate);
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
          1 / Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamIn[InputIndex].Data.SampleRate);
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
          Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamIn[InputIndex].Data.SampleRate);
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

procedure TUOS_Player.SetFilterOut(OutputIndex: integer; FilterIndex: integer;
  LowFrequency: integer; HighFrequency: integer; Gain: cfloat;
  TypeFilter: integer; AlsoBuf: boolean; Enable: boolean);
////////// OutputIndex : OutputIndex of a existing Output
////////// FilterIndex : DSPOutIndex of existing DSPOut
////////// LowFrequency : Lowest frequency of filter
////////// HighFrequency : Highest frequency of filter
////////// TypeFilter: Type of filter : default = -1 = actual filter (fBandAll = 0, fBandSelect = 1, fBandReject = 2
/////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
////////// Enable :  Filter enabled 
////////// example : SetFilterOut(OutputIndex1,FilterOutIndex1,1000,1500,-1,True);
begin
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.AlsoBuf := AlsoBuf;
  StreamOut[OutputIndex].DSP[FilterIndex].Enabled := Enable;
  StreamOut[OutputIndex].DSP[FilterIndex].fftdata.Gain := cfloat(Gain);;
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
        Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamOut[OutputIndex].Data.SampleRate);
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
        1 / Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamOut[OutputIndex].Data.SampleRate);
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
        Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamOut[OutputIndex].Data.SampleRate);
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
        1 / Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamOut[OutputIndex].Data.SampleRate);
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
        1 / Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamOut[OutputIndex].Data.SampleRate);
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
        Tan(Pi * (HighFrequency - LowFrequency + 1) / StreamOut[OutputIndex].Data.SampleRate);
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

function UOS_DSPVolume(Data: TUOS_Data; fft: TUOS_FFT): TArFloat;
var
  x, ratio: integer;
  vleft, vright: double;
  ps: PArShort;     //////// if input is Int16 format
  pl: PArLong;      //////// if input is Int32 format
  pf: PArFloat;     //////// if input is Float32 format
begin
  
  vleft := Data.VLeft;
  vright := Data.VRight;

  case Data.SampleFormat of
    2:
    begin
      ps := @Data.Buffer;
      for x := 0 to (Data.OutFrames) do
        if odd(x) then
          ps^[x] := trunc(ps^[x] * vright)
        else
          ps^[x] := trunc(ps^[x] * vleft);
    end;
    1:
    begin
      pl := @Data.Buffer;
      for x := 0 to (Data.OutFrames) do
        if odd(x) then
          pl^[x] := trunc(pl^[x] * vright)
        else
          pl^[x] := trunc(pl^[x] * vleft);
    end;
    0:
    begin
     case Data.LibOpen of
      0: ratio := 1;
      1: ratio := 2;
     end;
      pf := @Data.Buffer;
      for x := 0 to (Data.OutFrames div ratio) do
        if odd(x) then
          pf^[x] := pf^[x] * vright
        else
          pf^[x] := pf^[x] * vleft;
    end;
  end;
  Result := Data.Buffer;
end;

function UOS_BandFilter(Data: TUOS_Data; fft: TUOS_FFT): TArFloat;
var
  i, ratio: integer;
  ifbuf : boolean;
  arg, res, res2: cfloat;
  ps: PArShort;     //////// if input is Int16 format
  pl: PArLong;      //////// if input is Int32 format
  pf: PArFloat;     //////// if input is Float32 format
begin
 
 ratio := 1;
 ifbuf := fft.AlsoBuf;
  
  case Data.SampleFormat of
    2: ps := @Data.Buffer;
    1: pl := @Data.Buffer;
    0: begin
    case Data.LibOpen of
   0: ratio := 1;
   1: ratio := 2;
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

    res := fft.a3[0] * arg + fft.a3[1] * fft.x0[0] +
      fft.a3[2] * fft.x1[0] - fft.b2[0] * fft.y0[0] -
      fft.b2[1] * fft.y1[0];
    if fft.typefilter = 1 then
    begin
      res2 := fft.a32[0] * arg + fft.a32[1] * fft.x02[0] +
        fft.a32[2] * fft.x12[0] - fft.b22[0] * fft.y02[0] -
        fft.b22[1] * fft.y12[0];

      case Data.SampleFormat of
        2: begin
         fft.RightResult:= round((res * 1) + (res2 * fft.gain)) ;
          if ifbuf = true then  ps^[i] := round((res * 1) + (res2 * fft.gain));
        end;
        1: begin
          fft.RightResult:= round((res * 1) + (res2 * fft.gain)) ;
          if ifbuf = true then  pl^[i] := round((res * 1) + (res2 * fft.gain));
        end;
        0: begin
           fft.RightResult:= ((res * 1) + (res2 * fft.gain)) ;
          if ifbuf = true then  pf^[i] := ((res * 1) + (res2 * fft.gain));
        end;
      end;

    end
    else
      case Data.SampleFormat of
        2: begin
         fft.RightResult:= round(res * fft.gain);
          if ifbuf = true then  ps^[i] := round( (res * fft.gain));
        end;
        1: begin
          fft.RightResult:= round((res * fft.gain)) ;
          if ifbuf = true then  pl^[i] := round((res * fft.gain));
        end;
        0: begin
         fft.RightResult:= ((res * fft.gain)) ;
          if ifbuf = true then  pf^[i] := ((res * fft.gain));
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
      res := fft.a3[0] * arg + fft.a3[1] * fft.x0[1] +
        fft.a3[2] * fft.x1[1] - fft.b2[0] * fft.y0[1] -
        fft.b2[1] * fft.y1[1];

      if fft.typefilter = 1 then
      begin
        res2 := fft.a32[0] * arg + fft.a32[1] * fft.x02[1] +
          fft.a32[2] * fft.x12[1] - fft.b22[0] * fft.y02[1] -
          fft.b22[1] * fft.y12[1];

        case Data.SampleFormat of
           2: begin
          fft.LeftResult:= round((res * 1) + (res2 * fft.gain)) ;
          if ifbuf = true then  ps^[i] := round((res * 1) + (res2 * fft.gain));
        end;
         1: begin
            fft.LeftResult:= round((res * 1) + (res2 * fft.gain)) ;
          if ifbuf = true then  pl^[i] := round((res * 1) + (res2 * fft.gain));
        end;
         0: begin
            fft.LeftResult:= ((res * 1) + (res2 * fft.gain)) ;
          if ifbuf = true then  pf^[i] := ((res * 1) + (res2 * fft.gain));
        end;
        
        end;

      end
      else
        case Data.SampleFormat of
         2: begin
          fft.LeftResult:= round((res * fft.gain)) ;
          if ifbuf = true then  ps^[i] := round((res * fft.gain)) ;
        end;
         1: begin
            fft.LeftResult:= round((res * fft.gain)) ;
          if ifbuf = true then  pl^[i] := round((res * fft.gain)) ;
        end;
         0: begin
            fft.LeftResult:= ((res * fft.gain)) ;
          if ifbuf = true then  pf^[i] := ((res * fft.gain)) ;
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

function TUOS_Player.AddDSPVolumeIn(InputIndex: integer; VolLeft: double;
  VolRight: double): integer;  ///// DSP Volume changer                               
  ////////// InputIndex : InputIndex of a existing Input
  ////////// VolLeft : Left volume
  ////////// VolRight : Right volume
  //  result : -1 nothing created, otherwise index of DSPIn in array    
  ////////// example  DSPIndex1 := AddDSPVolumeIn(InputIndex1,1,1);
begin
  Result := AddDSPin(InputIndex, nil, @UOS_DSPVolume);
  StreamIn[InputIndex].Data.VLeft := VolLeft;
  StreamIn[InputIndex].Data.VRight := VolRight;
end;

function TUOS_Player.AddDSPVolumeOut(OutputIndex: integer; VolLeft: double;
  VolRight: double): integer;  ///// DSP Volume changer                               
  ////////// OutputIndex : OutputIndex of a existing Output
  ////////// VolLeft : Left volume ( 1 = max)
  ////////// VolRight : Right volume ( 1 = max)
  //  result : -1 nothing created, otherwise index of DSPIn in array    
  ////////// example  DSPIndex1 := AddDSPVolumeOut(OutputIndex1,1,1);
begin
  Result := AddDSPin(OutputIndex, nil, @UOS_DSPVolume);
  StreamOut[OutputIndex].Data.VLeft := VolLeft;
  StreamOut[OutputIndex].Data.VRight := VolRight;
end;

procedure TUOS_Player.SetDSPVolumeIn(InputIndex: integer; DSPVolIndex: integer;
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

procedure TUOS_Player.SetDSPVolumeOut(OutputIndex: integer;
  DSPVolIndex: integer; VolLeft: double; VolRight: double; Enable: boolean);
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

function TUOS_Player.AddFilterIn(InputIndex: integer; LowFrequency: integer;
  HighFrequency: integer; Gain: cfloat; TypeFilter: integer; AlsoBuf: Boolean): integer;
  ////////// InputIndex : InputIndex of a existing Input
  ////////// LowFrequency : Lowest frequency of filter
  ////////// HighFrequency : Highest frequency of filter
  ////////// Gain : gain to apply to filter ( 1 = no gain )
  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  //  result : -1 nothing created, otherwise index of DSPIn in array    
  ////////// example :FilterInIndex1 := AddFilterIn(InputIndex1,6000,16000,1,1,True);
var
  FilterIndex: integer;
begin
  FilterIndex := AddDSPin(InputIndex, nil, @UOS_BandFilter);
  if TypeFilter = -1 then
    TypeFilter := 1;
  SetFilterIn(InputIndex, FilterIndex, LowFrequency, HighFrequency,
    Gain, TypeFilter, AlsoBuf, True);

  Result := FilterIndex;

end;

function TUOS_Player.AddFilterOut(OutputIndex: integer; LowFrequency: integer;
  HighFrequency: integer; Gain: cfloat; TypeFilter: integer; AlsoBuf:Boolean): integer;
  ////////// OutputIndex : OutputIndex of a existing Output
  ////////// LowFrequency : Lowest frequency of filter
  ////////// HighFrequency : Highest frequency of filter
  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  //  result : -1 nothing created, otherwise index of DSPOut in array    
  ////////// example :FilterOutIndex1 := AddFilterOut(OutputIndex1,6000,16000,1,true);
var
  FilterIndex: integer;
begin
  FilterIndex := AddDSPOut(OutputIndex, nil, @UOS_BandFilter);
  if TypeFilter = -1 then
    TypeFilter := 1;
  SetFilterOut(OutputIndex, FilterIndex, LowFrequency, HighFrequency,
    Gain, TypeFilter, AlsoBuf, True);

  Result := FilterIndex;

end;



function TUOS_Player.AddFromDevIn(Device: integer; Latency: CDouble;
  SampleRate: integer; Channels: integer; OutputIndex: integer;
  SampleFormat: shortint): integer;
  /// Add Input from IN device with custom parameters
  //////////// Device ( -1 is default Input device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// OutputIndex : Output index of used output// -1: all output, -2: no output, other integer refer to a existing OutputIndex  (if multi-output then OutName = name of each output separeted by ';')
  //////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16) 
  //////////// example : AddFromDevice(-1,-1,-1,-1,-1);
var
  x, err: integer;
begin
  x := 0;
  Result := -1;
  err := -1;
  SetLength(StreamIn, Length(StreamIn) + 1);
  StreamIn[Length(StreamIn) - 1] := TUOS_InStream.Create();
  x := Length(StreamIn) - 1;
  StreamIn[x].Data.PAParam.HostApiSpecificStreamInfo := nil;

  if device = -1 then
    StreamIn[x].Data.PAParam.device :=
      Pa_GetDefaultInputDevice()
  else
    StreamIn[x].Data.PAParam.device := cint32(device);

  if SampleRate = -1 then
    StreamIn[x].Data.SampleRate := DefRate
  else
    StreamIn[x].Data.SampleRate := SampleRate;
  StreamIn[x].Data.PAParam.SuggestedLatency := CDouble(0);
  StreamIn[x].Data.PAParam.SampleFormat := paInt16;
  case SampleFormat of
    0: StreamIn[x].Data.PAParam.SampleFormat := paFloat32;
    1: StreamIn[x].Data.PAParam.SampleFormat := paInt32;
    2: StreamIn[x].Data.PAParam.SampleFormat := paInt16;
  end;
  if SampleFormat = -1 then
    StreamIn[x].Data.SampleFormat := 2
  else
    StreamIn[x].Data.SampleFormat := SampleFormat;
  if Channels = -1 then
    StreamIn[x].Data.PAParam.channelCount := CInt32(2)
  else
    StreamIn[x].Data.PAParam.channelCount := CInt32(Channels);

  StreamIn[x].Data.channels := StreamIn[x].Data.PAParam.channelCount;
  StreamIn[x].Data.Wantframes := 4096;
  //  length(StreamIn[x].Data.Buffer) div  StreamIn[x].Data.channels; // Too big ?
  StreamIn[x].Data.outframes := length(StreamIn[x].Data.Buffer);
  StreamIn[x].Data.Enabled := True;
  StreamIn[x].Data.Status := 1;
  StreamIn[x].Data.TypePut := 1;
  StreamIn[x].Data.ratio := 2;
  StreamIn[x].Data.Output := OutputIndex;
  StreamIn[x].Data.seekable := False;
  StreamIn[x].Data.LibOpen := 2;

  err := Pa_OpenStream(@StreamIn[x].Data.HandleSt, @StreamIn[x].Data.PAParam,
    nil, StreamIn[x].Data.SampleRate, 512, paClipOff, nil, nil);

  if err <> 0 then
    MessageDlg(Pa_GetErrorText(err), mtWarning, [mbYes], 0)
  else
    Result := x;
end;

function TUOS_Player.AddFromDevIn: integer;
  /// Add Input from IN device with Default parameters
begin
  Result := AddFromDevIn(-1, -1, -1, -1, -1, -1);
end;

function TUOS_Player.AddIntoFile(Filename: string; SampleRate: integer;
  Channels: integer; SampleFormat: shortint): integer;
  /////// Add a Output into audio wav file with Custom parameters
  ////////// FileName : filename of saved audio wav file
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //  result : -1 nothing created, otherwise Output Index in array     
  //////////// example : OutputIndex1 := AddIntoFile(edit5.Text,-1,-1,0);
var
  x, err: integer;
begin
  x := 0;
  Result := -1;
  err := -1;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := TUOS_OutStream.Create();
  x := Length(StreamOut) - 1;
  StreamOut[x].Data.FileBuffer.ERROR := 0;
  StreamOut[x].Data.Enabled := True;
  StreamOut[x].Data.Filename := filename;
  StreamOut[x].Data.TypePut := 0;
  FillChar(StreamOut[x].Data.FileBuffer, sizeof(StreamOut[x].Data.FileBuffer), 0);
  StreamOut[x].Data.FileBuffer.Data := TMemoryStream.Create;

  if (Channels = -1) then
    StreamOut[x].Data.FileBuffer.wChannels := 2
  else
    StreamOut[x].Data.FileBuffer.wChannels := Channels;
  StreamOut[x].Data.Channels := StreamOut[x].Data.FileBuffer.wChannels;

  if (SampleFormat = -1) or (SampleFormat = 2) then
  begin
    StreamOut[x].Data.FileBuffer.wBitsPerSample := 16;
    StreamOut[x].Data.SampleFormat := 2;
  end;

  if (SampleFormat = 0) then
  begin
    StreamOut[x].Data.FileBuffer.wBitsPerSample := 32;
    StreamOut[x].Data.SampleFormat := 0;
  end;

  if (SampleFormat = 1) then
  begin
    StreamOut[x].Data.FileBuffer.wBitsPerSample := 32;
    StreamOut[x].Data.SampleFormat := 1;
  end;

  if SampleRate = -1 then
    StreamOut[x].Data.FileBuffer.wSamplesPerSec := 44100
  else
    StreamOut[x].Data.FileBuffer.wSamplesPerSec := samplerate;
  StreamOut[x].Data.Samplerate := StreamOut[x].Data.FileBuffer.wSamplesPerSec;

end;

function TUOS_Player.AddIntoFile(Filename: string): integer;
  /////// Add a Output into audio wav file with default parameters
begin
  Result := AddIntoFile(Filename, -1, -1, -1);
end;

function TUOS_Player.AddIntoDevOut(Device: integer; Latency: CDouble;
  SampleRate: integer; Channels: integer; SampleFormat: shortint): integer;
  /////// Add a Output into OUT device with Custom parameters
  //////////// Device ( -1 is default device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16) 
  //////////// example : AddOutput(-1,-1,-1,-1,-1);
var
  x, err: integer;
begin
  x := 0;
  Result := -1;
  err := -1;
  SetLength(StreamOut, Length(StreamOut) + 1);
  StreamOut[Length(StreamOut) - 1] := TUOS_OutStream.Create();
  x := Length(StreamOut) - 1;
  StreamOut[x].Data.PAParam.hostApiSpecificStreamInfo := nil;
  if device = -1 then
    StreamOut[x].Data.PAParam.device := Pa_GetDefaultOutputDevice()
  else
    StreamOut[x].Data.PAParam.device := cint32(Device);
  ;

  if SampleRate = -1 then
    StreamOut[x].Data.SampleRate := DefRate
  else
    StreamOut[x].Data.SampleRate := SampleRate;

  if Latency = -1 then
    StreamOut[x].Data.PAParam.SuggestedLatency :=
      (Pa_GetDeviceInfo(StreamOut[x].Data.PAParam.device)^.defaultHighOutputLatency) * 1
  else
    StreamOut[x].Data.PAParam.SuggestedLatency := CDouble(Latency);

  StreamOut[x].Data.PAParam.SampleFormat := paInt16;
  case SampleFormat of
    0: StreamOut[x].Data.PAParam.SampleFormat := paFloat32;
    1: StreamOut[x].Data.PAParam.SampleFormat := paInt32;
    2: StreamOut[x].Data.PAParam.SampleFormat := paInt16;
  end;
  StreamOut[x].Data.SampleFormat := SampleFormat;
  if Channels = -1 then
    StreamOut[x].Data.PAParam.channelCount := CInt32(2)
  else
    StreamOut[x].Data.PAParam.channelCount := CInt32(Channels);
  StreamOut[x].Data.Channels := Channels;
  StreamOut[x].Data.TypePut := 1;
  StreamOut[x].Data.Wantframes :=
    length(StreamOut[x].Data.Buffer) div StreamOut[x].Data.channels;
  StreamOut[x].Data.Enabled := True;

  err := Pa_OpenStream(@StreamOut[x].Data.HandleSt, nil,
    @StreamOut[x].Data.PAParam, StreamOut[x].Data.SampleRate, 512, paClipOff, nil, nil);

  if err <> 0 then
    MessageDlg(Pa_GetErrorText(err), mtWarning, [mbYes], 0)
  else
    Result := x;
end;

function TUOS_Player.AddIntoDevOut: integer;
  /////// Add a Output into OUT device with Default parameters
begin
  Result := AddIntoDevOut(-1, -1, -1, -1, -1);
end;

function TUOS_Player.AddFromFile(Filename: string; OutputIndex: integer;
  /////// Add a Input from Audio file with Custom parameters
  SampleFormat: shortint): integer;
  ////////// FileName : filename of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other integer : existing Output
  ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  ////////// example : InputIndex := AddFromFile('/usr/home/test.ogg',-1,-1);
var
  x, err: integer;
  sfInfo: TSF_INFO;
  mpinfo: Tmpg123_frameinfo;
  mpid3v1: Tmpg123_id3v1;
begin
  Result := -1;
  if not fileexists(FileName) then
    MessageDlg(FileName + ' do not exists...', mtWarning, [mbYes], 0)
  else
  begin
    x := 0;
    err := -1;
    SetLength(StreamIn, Length(StreamIn) + 1);
    StreamIn[Length(StreamIn) - 1] := TUOS_InStream.Create;
    x := Length(StreamIn) - 1;
    err := -1;
    StreamIn[x].Data.LibOpen := -1;
    if (UOSloadresult.SFloadERROR = 0) and ((UOSloadflag = LoadAll) or
      (UOSloadflag = LoadSF) or (UOSloadflag = LoadPA_SF) or
      (UOSloadflag = LoadSF_MP)) then
    begin
      StreamIn[x].Data.HandleSt := sf_open(PChar(FileName), SFM_READ, sfInfo);
      (* try to open the file *)
      if StreamIn[x].Data.HandleSt = nil then
        StreamIn[x].Data.LibOpen := -1
      else
      begin
        StreamIn[x].Data.LibOpen := 0;
        StreamIn[x].Data.filename := FileName;
        StreamIn[x].Data.channels := SFinfo.channels;
        StreamIn[x].Data.hdformat := SFinfo.format;
        StreamIn[x].Data.frames := SFinfo.frames;
        StreamIn[x].Data.samplerate := SFinfo.samplerate;
        StreamIn[x].Data.samplerateroot := SFinfo.samplerate;
        StreamIn[x].Data.sections := SFinfo.sections;
        StreamIn[x].Data.Wantframes :=
          length(StreamIn[x].Data.Buffer) div StreamIn[x].Data.Channels;
        StreamIn[x].Data.copyright :=
          sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_COPYRIGHT);
        StreamIn[x].Data.software :=
          sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_SOFTWARE);
        StreamIn[x].Data.comment :=
          sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_COMMENT);
        StreamIn[x].Data.date := sf_get_string(StreamIn[x].Data.HandleSt, SF_STR_DATE);
        StreamIn[x].Data.Lengthst := sf_Seek(StreamIn[x].Data.HandleSt, 0, SEEK_END);
        sf_seek(StreamIn[x].Data.HandleSt, 0, SEEK_SET);
        StreamIn[x].Data.Enabled := False;
        err := 0;
      end;
    end;
    if ((StreamIn[x].Data.LibOpen = -1)) and (UOSLoadresult.MPloadERROR = 0) and
      ((UOSloadflag = LoadAll) or (UOSloadflag = LoadMP) or
      (UOSloadflag = LoadPA_MP) or (UOSloadflag = LoadSF_MP)) then
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
        StreamIn[x].Data.LibOpen := -1;
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
        mpg123_open(StreamIn[x].Data.HandleSt, PChar(FileName));
        mpg123_getformat(StreamIn[x].Data.HandleSt,
          StreamIn[x].Data.samplerate, StreamIn[x].Data.channels,
          StreamIn[x].Data.encoding);
        StreamIn[x].Data.filename := filename;
        StreamIn[x].Data.Wantframes :=
          length(StreamIn[x].Data.Buffer) div StreamIn[x].Data.channels;
        mpg123_info(StreamIn[x].Data.HandleSt, MPinfo);
        mpg123_id3(StreamIn[x].Data.HandleSt, @mpid3v1, nil);
        ////////////// to do : add id2v2
        StreamIn[x].Data.title := trim(mpid3v1.title);
        StreamIn[x].Data.artist := mpid3v1.artist;
        StreamIn[x].Data.album := mpid3v1.album;
        StreamIn[x].Data.date := mpid3v1.year;
        StreamIn[x].Data.comment := mpid3v1.comment;
        StreamIn[x].Data.tag := mpid3v1.tag;
        StreamIn[x].Data.genre := mpid3v1.genre;
        StreamIn[x].Data.samplerateroot := MPinfo.rate;
        StreamIn[x].Data.samplerate := MPinfo.rate;
        StreamIn[x].Data.hdformat := MPinfo.layer;
        StreamIn[x].Data.frames := MPinfo.framesize;
        StreamIn[x].Data.lengthst := mpg123_length(StreamIn[x].Data.HandleSt);
        StreamIn[x].Data.LibOpen := 1;
      end
      else
        StreamIn[x].Data.LibOpen := -1;
    end;
    if err <> 0 then
    begin
      MessageDlg('Cannot Open ' + FileName + '...', mtWarning, [mbYes], 0);
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
      if SampleFormat = -1 then
        StreamIn[x].Data.SampleFormat := 2
      else
        StreamIn[x].Data.SampleFormat := SampleFormat;

      case StreamIn[x].Data.LibOpen of
        0:
          StreamIn[x].Data.ratio := StreamIn[x].Data.Channels;
        1:
        begin
          if StreamIn[x].Data.SampleFormat = 2 then
            StreamIn[x].Data.ratio := streamIn[x].Data.Channels
          else
            StreamIn[x].Data.ratio := 2 * streamIn[x].Data.Channels;

          if StreamIn[x].Data.SampleFormat = 0 then
            mpg123_param(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Channels,
              MPG123_FORCE_FLOAT, 0);
        end;
      end;
    end;
  end;
end;

function TUOS_Player.AddFromFile(Filename: string): integer;
  /////// Add a Input from Audio file with Default parameters
  ////////// FileName : filename of audio file
  ////////// example : InputIndex := AddFromFile('/usr/home/test.ogg');
begin
  Result := AddFromFile(Filename, -1, -1);
end;

procedure TUOS_Player.Execute;
/////////////////////// The Loop Procedure ///////////////////////////////
var
  x, x2, x3: integer;
  err: PaError;
begin

  if BeginProc <> nil then
    synchronize(BeginProc); /////  Execute BeginProc procedure

  repeat

    for x := 0 to high(StreamIn) do
    begin
      RTLeventWaitFor(evPause);  ///// is there a pause waiting ?
      RTLeventSetEvent(evPause);

      if (StreamIn[x].Data.HandleSt <> nil) and (StreamIn[x].Data.Status = 1) and
        (StreamIn[x].Data.Enabled = True) then begin

        if (StreamIn[x].Data.Poseek > -1) and (StreamIn[x].Data.Seekable = True) then
        begin                    ////// is there a seek waiting ?
          case StreamIn[x].Data.LibOpen of
            0: sf_seek(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Poseek, SEEK_SET);
            1: mpg123_seek(StreamIn[x].Data.HandleSt, StreamIn[x].Data.Poseek, SEEK_SET);
          end;
          StreamIn[x].Data.Poseek := -1;
        end;

      if (StreamIn[x].Data.Seekable = True) then
        case StreamIn[x].Data.LibOpen of      ///// get current position
          0: StreamIn[x].Data.position :=
              sf_seek(StreamIn[x].Data.HandleSt, 0, SEEK_CUR);
          1: StreamIn[x].Data.position := mpg123_tell(StreamIn[x].Data.HandleSt);
        end;

      //////// DSPin BeforeBuffProc
      if (StreamIn[x].Data.Status = 1) and (length(StreamIn[x].DSP) > 0) then
        for x2 := 0 to high(StreamIn[x].DSP) do
          if (StreamIn[x].DSP[x2].Enabled = True) and
            (StreamIn[x].DSP[x2].BefProc <> nil) then
            StreamIn[x].DSP[x2].BefProc(StreamIn[x].Data, StreamIn[x].DSP[x2].fftdata);
      ///// end DSP BeforeBuffProc  

      RTLeventWaitFor(evPause);  ///// is there a pause waiting ?
      RTLeventSetEvent(evPause);

      case StreamIn[x].Data.TypePut of
        0:   ///// it is a input from audio file...
        begin

          case StreamIn[x].Data.LibOpen of
            //////////// Here we are, reading the data and store it in buffer
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
            1:
            begin
              mpg123_read(StreamIn[x].Data.HandleSt, @StreamIn[x].Data.Buffer[0],
                StreamIn[x].Data.wantframes, StreamIn[x].Data.outframes);
              StreamIn[x].Data.outframes :=
                StreamIn[x].Data.outframes div StreamIn[x].Data.Channels;
            end;
          end;

          if StreamIn[x].Data.OutFrames < 10 then
            StreamIn[x].Data.status := 0;  //////// no more data then close the stream
        end;

        1:   /////// for Input from device
        begin
          for x2 := 0 to StreamIn[x].Data.WantFrames do
            StreamIn[x].Data.Buffer[x2] := cfloat(0);      ////// clear input
          err := Pa_ReadStream(StreamIn[x].Data.HandleSt,
            @StreamIn[x].Data.Buffer[0], StreamIn[x].Data.WantFrames);
          StreamIn[x].Data.OutFrames := StreamIn[x].Data.WantFrames * 2;
          //  if err = 0 then StreamIn[x].Data.Status := 1 else StreamIn[x].Data.Status := 0;  /// if you want clean buffer
        end;
      end;

      x2 := 0;

      //////// DSPin AfterBuffProc      
      if (StreamIn[x].Data.Status = 1) and (length(StreamIn[x].DSP) > 0) then
        for x2 := 0 to high(StreamIn[x].DSP) do
          if (StreamIn[x].DSP[x2].Enabled = True) and
            (StreamIn[x].DSP[x2].AftProc <> nil) then
            StreamIn[x].Data.Buffer :=
              StreamIn[x].DSP[x2].AftProc(StreamIn[x].Data, StreamIn[x].DSP[x2].fftdata);
      ///// End DSPin AfterBuffProc 

    end; ///// End Input enabled

    end;
    ////////////////// Seeking if StreamIn is terminated
    if status > 0 then
    begin
      status := 0;
      for x := 0 to high(StreamIn) do
        if (StreamIn[x].Data.HandleSt <> nil) and (StreamIn[x].Data.Status = 1) then
          status := 1;
    end;

    RTLeventWaitFor(evPause);  ///// is there a pause waiting ?
    RTLeventSetEvent(evPause);

    //////////////////////// Give Buffer to Output
    if status = 1 then
      for x := 0 to high(StreamOut) do

        if ((StreamOut[x].Data.TypePut = 1) and (StreamOut[x].Data.HandleSt <> nil) and
          (StreamOut[x].Data.Enabled = True)) or
          ((StreamOut[x].Data.TypePut = 0) and (StreamOut[x].Data.Enabled = True))
        then
        begin
          for x2 := 0 to high(StreamOut[x].Data.Buffer) do
            StreamOut[x].Data.Buffer[x2] := cfloat(0);      ////// clear output

          for x2 := 0 to high(StreamIn) do
            if (StreamIn[x2].Data.HandleSt <> nil) and
              (StreamIn[x2].Data.Enabled = True) and
              ((StreamIn[x2].Data.Output = x) or (StreamIn[x2].Data.Output = -1)) then
              for x3 := 0 to high(StreamIn[x2].Data.Buffer) do
                StreamOut[x].Data.Buffer[x3] :=
                  cfloat(StreamOut[x].Data.Buffer[x3]) +
                  cfloat(StreamIn[x2].Data.Buffer[x3]); //////// copy buffer-in into buffer-out
         
          //////// DSPOut AfterBuffProc
          if (length(StreamOut[x].DSP) > 0) then
            for x3 := 0 to high(StreamOut[x].DSP) do
              if (StreamOut[x].DSP[x3].Enabled = True) and
                (StreamOut[x].DSP[x3].AftProc <> nil) then
                StreamOut[x].DSP[x3].AftProc(StreamOut[x].Data,
                  StreamOut[x].DSP[x3].fftdata);
          ///// end DSPOut AfterBuffProc

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
            1:     /////// Give to output device 
              err := Pa_WriteStream(StreamOut[x].Data.HandleSt,
                @StreamOut[x].Data.Buffer[0], StreamIn[x2].Data.outframes div
                StreamIn[x2].Data.ratio);
              // if err <> 0 then status := 0;   // if you want clean buffer ...

            0:     /////// Give to wav file
              StreamOut[x].Data.FileBuffer.Data.WriteBuffer(StreamOut[x].Data.Buffer[0],
                StreamIn[x2].Data.outframes * StreamIn[x2].Data.Channels);
          end;
        end;

  until status = 0;

  ////////////////////////////////////// End of Loop ////////////////////////////////////////

  ////////////////////////// Terminate Thread
  if status = 0 then
  begin
    if EndProc <> nil then
      synchronize(EndProc); /////  Execute EndProc procedure

    for x := 0 to high(StreamOut) do
    begin
      if (StreamOut[x].Data.HandleSt <> nil) and (StreamOut[x].Data.TypePut = 1) then
      begin
        Pa_StopStream(StreamOut[x].Data.HandleSt);
        Pa_CloseStream(StreamOut[x].Data.HandleSt);
      end;
      if (StreamOut[x].Data.TypePut = 0) then
      begin
        WriteWave(StreamOut[x].Data.Filename, StreamOut[x].Data.FileBuffer);
        sleep(200);
        StreamOut[x].Data.FileBuffer.Data.Free;
      end;
    end;

    for x := 0 to high(StreamIn) do
      if (StreamIn[x].Data.HandleSt <> nil) then
        case StreamIn[x].Data.TypePut of
          0: case StreamIn[x].Data.LibOpen of
              0: sf_close(StreamIn[x].Data.HandleSt);
              1:
              begin
                mpg123_close(StreamIn[x].Data.HandleSt);
                mpg123_delete(StreamIn[x].Data.HandleSt);
              end;
            end;
          1:
          begin
            Pa_StopStream(StreamIn[x].Data.HandleSt);
            Pa_CloseStream(StreamIn[x].Data.HandleSt);
          end;
        end;
    Terminate;
  end;
end;

constructor TUOS_Player.Create(CreateSuspended: boolean; const StackSize: SizeUInt);
begin
  inherited Create(CreateSuspended, StackSize);
  FreeOnTerminate := True;
  evPause := RTLEventCreate;
  Enabled := False;
  status := 2;
  BeginProc := nil;
  EndProc := nil;
end;

destructor TUOS_DSP.Destroy;
begin
  fftdata.Free;
end;

destructor TUOS_Player.Destroy;
var
  x: integer;
begin
  RTLeventdestroy(evPause);
  if length(StreamOut) > 0 then
    for x := 0 to high(StreamOut) do
      StreamOut[x].Free;
  if length(StreamIn) > 0 then
    for x := 0 to high(StreamIn) do
      StreamIn[x].Free;
  inherited Destroy;
end;

destructor TUOS_InStream.Destroy;
var
  x: integer;
begin
  if length(DSP) > 0 then
    for x := 0 to high(DSP) do
      DSP[x].Free;
  inherited Destroy;
end;

destructor TUOS_OutStream.Destroy;
var
  x: integer;
begin
  if length(DSP) > 0 then
    for x := 0 to high(DSP) do
      DSP[x].Free;
  inherited Destroy;
end;

procedure TUOS_Init.UnLoadLib();
begin
  Set8087CW(old8087cw);
  Sf_Unload();
  Mp_Unload();
  Pa_Unload();
end;

procedure TUOS_Init.InitLib();
begin
  if (LoadResult.MPloadERROR = 0) and ((flag = LoadAll) or (flag = LoadMP) or
    (flag = LoadPA_MP) or (flag = LoadSF_MP)) then
    if mpg123_init() = MPG123_OK then
      LoadResult.MPinitError := 0
    else
      LoadResult.MPinitError := 1;
  if (LoadResult.PAloadERROR = 0) and ((flag = LoadAll) or (flag = LoadPA) or
    (flag = LoadPA_SF) or (flag = LoadPA_MP)) then
  begin
    LoadResult.PAinitError := Pa_Initialize();
    if LoadResult.PAinitError = 0 then
    begin
      DefDevOut := Pa_GetDefaultOutputDevice();
      DefDevOutInfo := Pa_GetDeviceInfo(DefDevOut);
      DefDevOutAPIInfo := Pa_GetHostApiInfo(DefDevOutInfo^.hostApi);
      DefDevIn := Pa_GetDefaultInputDevice();
      DefDevInInfo := Pa_GetDeviceInfo(DefDevIn);
      DefDevInAPIInfo := Pa_GetHostApiInfo(DefDevInInfo^.hostApi);
    end;
  end;
end;

procedure TUOS_Init.LoadLib();
begin
  old8087cw := Get8087CW;
  Set8087CW($133f);
  case flag of
    LoadAll:
    begin
      if not fileexists(PA_FileName) then
        LoadResult.PAloadERROR := 1
      else
      if Pa_Load(PA_FileName) then
        LoadResult.PAloadERROR := 0
      else
        LoadResult.PAloadERROR := 2;
      if not fileexists(SF_FileName) then
        LoadResult.SFloadERROR := 1
      else
      if Sf_Load(SF_FileName) then
        LoadResult.SFloadERROR := 0
      else
        LoadResult.SFloadERROR := 2;
      if not fileexists(MP_FileName) then
        LoadResult.MPloadERROR := 1
      else
      if mp_Load(Mp_FileName) then
        LoadResult.MPloadERROR := 0
      else
        LoadResult.MPloadERROR := 2;
    end;

    LoadPA:
      if not fileexists(PA_FileName) then
        LoadResult.PAloadERROR := 1
      else
      if Pa_Load(PA_FileName) then
        LoadResult.PAloadERROR := 0
      else
        LoadResult.PAloadERROR := 2;

    LoadSF:
      if not fileexists(SF_FileName) then
        LoadResult.SFloadERROR := 1
      else
      if Sf_Load(SF_FileName) then
        LoadResult.SFloadERROR := 0
      else
        LoadResult.SFloadERROR := 2;

    LoadMP:
      if not fileexists(MP_FileName) then
        LoadResult.MPloadERROR := 1
      else
      if mp_Load(Mp_FileName) then
        LoadResult.MPloadERROR := 0
      else
        LoadResult.MPloadERROR := 2;

    LoadPA_SF:
    begin
      if not fileexists(PA_FileName) then
        LoadResult.PAloadERROR := 1
      else
      if Pa_Load(PA_FileName) then
        LoadResult.PAloadERROR := 0
      else
        LoadResult.PAloadERROR := 2;
      if not fileexists(SF_FileName) then
        LoadResult.SFloadERROR := 1
      else
      if Sf_Load(SF_FileName) then
        LoadResult.SFloadERROR := 0
      else
        LoadResult.SFloadERROR := 2;
    end;

    LoadPA_MP:
    begin
      if not fileexists(MP_FileName) then
        LoadResult.MPloadERROR := 1
      else
      if MP_Load(Mp_FileName) then
        LoadResult.MPloadERROR := 0
      else
        LoadResult.MPloadERROR := 2;
      if not fileexists(PA_FileName) then
        LoadResult.PAloadERROR := 1
      else
      if Pa_Load(PA_FileName) then
        LoadResult.PAloadERROR := 0
      else
        LoadResult.PAloadERROR := 2;
    end;

    LoadSF_MP:
    begin
      if not fileexists(SF_FileName) then
        LoadResult.SFloadERROR := 1
      else
      if SF_Load(SF_FileName) then
        LoadResult.SFloadERROR := 0
      else
        LoadResult.SFloadERROR := 2;
      if not fileexists(MP_FileName) then
        LoadResult.MPloadERROR := 1
      else
      if mp_Load(Mp_FileName) then
        LoadResult.MPloadERROR := 0
      else
        LoadResult.MPloadERROR := 2;
    end;
  end;
end;

constructor TUOS_Init.Create;
begin
  flag := 0;
  LoadResult.PAloadERROR := -1;
  LoadResult.SFloadERROR := -1;
  LoadResult.MPloadERROR := -1;
  LoadResult.PAinitError := -1;
  LoadResult.MPinitError := -1;
end;

end.
