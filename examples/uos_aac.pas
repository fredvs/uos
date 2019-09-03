{This unit is part of United Openlibraries of Sound (uos)}

{This is the Dynamic loading version of FAAD2 Pascal Wrapper.
       mcwNeAACDec.pas, mcwMP4FF.pas, mcwAAC.pas
           By Franklyn A. Harlow Feb 2016
             License : modified LGPL.
 mcw* merged into uos_aac by Fred van Stappen / fiens@hotmail.com }

unit uos_aac;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

interface

uses
  Classes, SysUtils, ctypes, math,
  dynlibs;
  
const

 {$IFDEF unix}
{$IFDEF darwin}
libaa= 'libfaad.2.dylib';
libm4= 'libmp4ff.0.dylib';
  {$ELSE}
libaa= 'libfaad.so.2';
libm4= 'libmp4ff.so.0.0.0';
  {$ENDIF}    
  {$ELSE}
libaa= 'Faad2.dll';
libm4= 'mp4ff.dll';
  {$ENDIF} 
  
//////////// from mcwMP4FF.pas By Franklyn A. Harlow
type

  ArSingle        =  array of Single;
  PArSingle       =  ^ArSingle;    
  
  read_callback_t     = function(user_data : Pointer; buffer : pcfloat; length : LongWord) : LongWord; cdecl;
  write_callback_t    = function(user_data : Pointer; buffer : pcfloat; length : LongWord) : LongWord; cdecl;
  seek_callback_t     = function(user_data : Pointer; Position : cInt64) : LongWord; cdecl;
  truncate_callback_t = function(user_data : Pointer) : LongWord; cdecl;

  mp4ff_callback_t = record
    read      : read_callback_t;
    write     : write_callback_t;
    seek      : seek_callback_t;
    truncate  : truncate_callback_t;
    user_data : Pointer;
  end;
  p_mp4ff_callback_t = ^mp4ff_callback_t;

  mp4ff_t  = pointer;
  int32_t  = LongInt;
  int64_t  = cInt64;
  uint32_t = LongWord;

var
  mp4ff_open_read            : function(f : p_mp4ff_callback_t) : mp4ff_t; cdecl;
  mp4ff_open_read_metaonly   : function(f : p_mp4ff_callback_t) : mp4ff_t; cdecl;
  mp4ff_close               : procedure(f : mp4ff_t); cdecl;
  mp4ff_get_sample_duration  : function(f : mp4ff_t; track, sample : int32_t) : int32_t; cdecl;
  mp4ff_get_sample_duration_use_offsets : function(f : mp4ff_t; track, sample : int32_t) : int32_t; cdecl;
  mp4ff_get_sample_position  : function(f : mp4ff_t; track, sample : int32_t) : int64_t; cdecl;
  mp4ff_get_sample_offset    : function(f : mp4ff_t; track, sample : int32_t) : int32_t; cdecl;
  mp4ff_find_sample          : function(f : mp4ff_t; track : int32_t;  offset : int64_t; var toskip : int32_t) : int32_t; cdecl;
  mp4ff_find_sample_use_offsets : function(f : mp4ff_t; track : int32_t; offset : int64_t; var toskip : int32_t) : int32_t; cdecl;
  mp4ff_set_sample_position  : function(f : mp4ff_t; track : int32_t; sample : int64_t) : int32_t; cdecl;
  mp4ff_read_sample          : function(f : mp4ff_t; track, sample  : int32_t; var audio_buffer : pcfloat; var bytes : LongWord) : int32_t; cdecl;
  mp4ff_read_sample_v2       : function(f : mp4ff_t; track, sample : int32_t; buffer : pcfloat): int32_t; cdecl; //returns 0 on error, number of bytes read on success, use mp4ff_read_sample_getsize_t = function() to check buffer size needed
  mp4ff_read_sample_getsize  : function(f : mp4ff_t; track, sample : Integer) : int32_t; cdecl; //returns 0 on error, buffer size needed for mp4ff_read_sample_v2_t = function() on success
  mp4ff_get_decoder_config   : function(f : mp4ff_t; track : Integer; var ppBuf : pcfloat; var pBufSize : LongWord) : int32_t; cdecl;
  mp4ff_free_decoder_config  : procedure(Buf : pcfloat); cdecl;
  mp4ff_get_track_type       : function(f : mp4ff_t; const track : Integer) : int32_t; cdecl;
  mp4ff_total_tracks         : function(f : mp4ff_t) : int32_t; cdecl;
  mp4ff_num_samples         : function(f : mp4ff_t; track : Integer) : int32_t; cdecl;
  mp4ff_time_scale           : function(f : mp4ff_t; track : Integer) : int32_t; cdecl;
  mp4ff_get_avg_bitrate      : function(f : mp4ff_t; track : int32_t) : uint32_t; cdecl;
  mp4ff_get_max_bitrate      : function(f : mp4ff_t; track : int32_t) : uint32_t; cdecl;
  mp4ff_get_track_duration   : function(f : mp4ff_t; track : int32_t) : int64_t; cdecl; //returns _t = function(-1) if unknown
  mp4ff_get_track_duration_use_offsets : function(f : mp4ff_t; track : int32_t) : Integer; cdecl;  //returns _t = function(-1) if unknown
  mp4ff_get_sample_rate      : function(f : mp4ff_t; track : int32_t) : uint32_t; cdecl;
  mp4ff_get_channel_count    : function(f : mp4ff_t; track : int32_t) : uint32_t; cdecl;
  mp4ff_get_audio_type       : function(f : mp4ff_t; track : int32_t) : uint32_t; cdecl;
  mp4ff_meta_get_num_items   : function(f : mp4ff_t) : Integer; cdecl;
  mp4ff_meta_get_by_index    : function(f : mp4ff_t; index : LongWord; var item, value : PChar) : Integer; cdecl;
  mp4ff_meta_get_title      : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_artist      : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_writer      : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_album       : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_date        : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_tool        : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_comment     : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_genre       : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_track       : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_disc        : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_totaltracks : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_totaldiscs  : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_compilation : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_tempo       : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;
  mp4ff_meta_get_coverart    : function(f : mp4ff_t; var value : PChar) : Integer; cdecl;

function GetAACTrack(infile : mp4ff_t) : Integer;
procedure Loadmp4ff(mp4ff : AnsiString);
procedure UnLoadMp4ff;
Function isMp4ffLoaded : Boolean; 

 //////////// from mcwNeAACDec.pas by Franklyn A. Harlow 
 Const
  { object types for AAC  }
    MAIN = 1;
    LC = 2;
    SSR = 3;
    LTP = 4;
    HE_AAC = 5;
    ER_LC = 17;
    ER_LTP = 19;
    LD = 23;
  { special object type for DRM  }
    DRM_ER_LC = 27;
  { header types  }
    RAW = 0;
    ADIF = 1;
    ADTS = 2;
    LATM = 3;
  { SBR signalling  }
    NO_SBR = 0;
    SBR_UPSAMPLED = 1;
    SBR_DOWNSAMPLED = 2;
    NO_SBR_UPSAMPLED = 3;
  { library output formats  }
    FAAD_FMT_16BIT = 1;
    FAAD_FMT_24BIT = 2;
    FAAD_FMT_32BIT = 3;
    FAAD_FMT_FLOAT = 4;
    FAAD_FMT_FIXED = FAAD_FMT_FLOAT;
    FAAD_FMT_DOUBLE = 5;
  { Capabilities  }
  { Can decode LC  }
    LC_DEC_CAP = 1 shl 0;
  { Can decode MAIN  }
    MAIN_DEC_CAP = 1 shl 1;
  { Can decode LTP  }
    LTP_DEC_CAP = 1 shl 2;
  { Can decode LD  }
    LD_DEC_CAP = 1 shl 3;
  { Can decode ER  }
    ERROR_RESILIENCE_CAP = 1 shl 4;
  { Fixed point  }
    FIXED_POINT_CAP = 1 shl 5;
  { Channel definitions  }
    FRONT_CHANNEL_CENTER = 1;
    FRONT_CHANNEL_LEFT = 2;
    FRONT_CHANNEL_RIGHT = 3;
    SIDE_CHANNEL_LEFT = 4;
    SIDE_CHANNEL_RIGHT = 5;
    BACK_CHANNEL_LEFT = 6;
    BACK_CHANNEL_RIGHT = 7;
    BACK_CHANNEL_CENTER = 8;
    LFE_CHANNEL = 9;
    UNKNOWN_CHANNEL = 0;
  { DRM channel definitions  }
    DRMCH_MONO = 1;
    DRMCH_STEREO = 2;
    DRMCH_SBR_MONO = 3;
    DRMCH_SBR_STEREO = 4;
    DRMCH_SBR_PS_STEREO = 5;
  { A decode call can eat up to FAAD_MIN_STREAMSIZE bytes per decoded channel,
     so at least so much bytes per channel should be available in this stream  }
  { 6144 bits/channel  }
    FAAD_MIN_STREAMSIZE = 768;

Type
  PNeAACDec = Pointer;

  NeAAC_byte     = {$IFDEF FPC}{$IFDEF CPU64}cuint32    {$ELSE}Byte    {$ENDIF}{$ELSE}Byte    {$ENDIF};
  NeAAC_word     = {$IFDEF FPC}{$IFDEF CPU64}cuint64{$ELSE}Word    {$ENDIF}{$ELSE}Word    {$ENDIF};
  NeAAC_longword = {$IFDEF FPC}{$IFDEF CPU64}culong    {$ELSE}LongWord{$ENDIF}{$ELSE}LongWord{$ENDIF};

  NeAACDecConfiguration = record
    defObjectType           : NeAAC_byte;
    defSampleRate           : NeAAC_longword;
    outputFormat            : NeAAC_byte;
    downMatrix              : NeAAC_byte;
    useOldADTSFormat        : NeAAC_byte;
    dontUpSampleImplicitSBR : NeAAC_byte;
  end;
  TNeAACDecConfiguration = NeAACDecConfiguration;
  PNeAACDecConfiguration = ^NeAACDecConfiguration;

  NeAACDecFrameInfo = record
    bytesconsumed      : NeAAC_longword;
    samples            : NeAAC_longword;
    channels           : NeAAC_byte;
    error              : NeAAC_byte;
    samplerate         : NeAAC_longword;
    sbr                : NeAAC_byte;     //* SBR: 0: off, 1: on; upsample, 2: on; downsampled, 3: off; upsampled */
    object_type        : NeAAC_byte;     //* MPEG-4 ObjectType */
    header_type        : NeAAC_byte;     //* AAC header type; MP4 will be signalled as RAW also */
    num_front_channels : NeAAC_byte;     //* multichannel configuration */
    num_side_channels  : NeAAC_byte;
    num_back_channels  : NeAAC_byte;
    num_lfe_channels   : NeAAC_byte;
    channel_position   : array[0..63] of NeAAC_byte;
    ps                 : NeAAC_byte;    //* PS: 0: off, 1: on */
  end;
  TNeAACDecFrameInfo = NeAACDecFrameInfo;
  PNeAACDecFrameInfo = ^NeAACDecFrameInfo;

  mp4AudioSpecificConfig = record
    objectTypeIndex                  : NeAAC_byte;
    samplingFrequencyIndex           : NeAAC_byte;
    samplingFrequency                : NeAAC_longword;
    channelsConfiguration            : NeAAC_byte;
    frameLengthFlag                  : NeAAC_byte;  //* GA Specific Info */
    dependsOnCoreCoder               : NeAAC_byte;
    coreCoderDelay                   : NeAAC_word;
    extensionFlag                    : NeAAC_byte;
    aacSectionDataResilienceFlag     : NeAAC_byte;
    aacScalefactorDataResilienceFlag : NeAAC_byte;
    aacSpectralDataResilienceFlag    : NeAAC_byte;
    epConfig                         : NeAAC_byte;
    sbr_present_flag                 : NeAAC_byte;
    forceUpSampling                  : NeAAC_byte;
    downSampledSBR                   : NeAAC_byte;
  end;
  Tmp4AudioSpecificConfig = mp4AudioSpecificConfig;
  Pmp4AudioSpecificConfig = ^mp4AudioSpecificConfig;

  var
  NeAACDecGetErrorMessage         : function(ErrorCode : Byte) : PChar; cdecl;
  NeAACDecGetCapabilities         : function : LongWord; cdecl;
  NeAACDecOpen                    : function : PNeAACDec; cdecl;
  NeAACDecGetCurrentConfiguration : function( hDecoder : PNeAACDec) : PNeAACDecConfiguration; cdecl;
  NeAACDecSetConfiguration        : function( hDecoder : PNeAACDec; pConfig : PNeAACDecConfiguration) : Byte; cdecl;
  NeAACDecInit                    : function( hDecoder : PNeAACDec; pBuffer : pcfloat; lwBufferLength : LongWord; var lwSampleRate : LongWord; var Channels : Byte) : LongInt; cdecl;
  NeAACDecInit2                   : function( hDecoder : PNeAACDec; pBuffer : pcfloat; SizeOfDecoderSpecificInfo : LongWord; var lwSampleRate : LongWord; var Channels : Byte) : Byte; cdecl;
  NeAACDecPostSeekReset           : procedure(hDecoder : PNeAACDec; Frame : LongInt); cdecl;
  NeAACDecClose                   : procedure(hDecoder : PNeAACDec); cdecl;
  NeAACDecDecode                  : function( hDecoder : PNeAACDec; hInfo : PNeAACDecFrameInfo; pBuffer : pcfloat; lwBufferLength : LongWord) : Pointer; cdecl;
  NeAACDecDecode2                 : function( hDecoder : PNeAACDec; hInfo : PNeAACDecFrameInfo; pBuffer : pcfloat; lwBufferLength : LongWord; var pSampleBuf : Pointer; lwSampleBufSize : LongWord) : Pointer; cdecl;
  NeAACDecAudioSpecificConfig     : function( pBuffer : pcfloat; lwBufferLength : LongWord; var mp4ASC : mp4AudioSpecificConfig) : Byte;  cdecl;

  procedure LoadNeAAC(NeAAC : AnsiString);
  Procedure UnLoadNeAAC;
  Function Is_NeAAC_Loaded : Boolean;
  
//////////////////

// from mcwAAC.pas from Franklyn A. Harlow 
Const
  kNeAAC_OK   = 1;
  kNeAAC_FAIL = 0;

Type

 TAACIdata = array[0..2024*1024-1] of byte;

  TAACInfo = class(TObject)
  public
    // libfaad control interface...
    fsStream      : TFileStream;
    pDecoder      : PNeAACDec;
    hMP4          : mp4ff_t;

    // output interface setup...
    Channels      : longword;  // stereo = 2
    BitsPerSample : longword;  // ie short/smallint = 16
    SampleRate    : longword;  // Frequency = 44100
    outputFormat  : byte;      // See FAAD_FMT_16BIT etc...

    Bitrate       : longword;  // 256000 = 256

    TotalTime     : double;    // Length in Seconds

    {$if not defined(fs32bit)}
     TotalSamples  : cint64;
     Size          : cint64;     // in frames
     Position      : cint64;     // in frames
    {$else}
     TotalSamples  : cint;
     Size          : cint;     // in frames
     Position      : cint;     // in frames
    {$endif}
   
    // UoS interface
    pData         : pcfloat;
    lwDataLen     : longword;

    // tag info...
    Artist        : AnsiString;
    AlbumArtist   : AnsiString;
    Album         : AnsiString;
    Title         : AnsiString;
    Date          : AnsiString;
    Genre         : AnsiString;
    Track         : AnsiString;
    Comment       : AnsiString;

    // internal data...
    cbs           : mp4ff_callback_t;
    _Buf          : TAACIdata;
    BufTmp        : TAACIdata;
    fTrack        : longint;
    fTimescale    : longword; // Not actually used

    fBufStart     : longword;
    fBufEnd       : longword;
  End;

  Function aa_load(mp4ff, NeAAC: AnsiString): Boolean;
  Procedure aa_Unload;
  Function isLibAACLoaded : Boolean;

  Function MP4OpenFile(fName : String; OutputFormat : Byte) : TAACInfo;
  Procedure MP4CloseFile(var AACI: TAACInfo);
  procedure MP4GetData(var AACI: TAACInfo; var Buffer: pcfloat; var Bytes: longword);
  function MP4Seek(var AACI: TAACInfo; var SampleNum: longint) : Boolean;

implementation

var
 // hNeAAC: {$IFDEF MSWINDOWS}longword{$ELSE}{$IFDEF CPU32}longword{$ELSE}PtrInt{$ENDIF}{$ENDIF};
  hNeAAC:TLibHandle=dynlibs.NilHandle;
  NeAACLoaded : Boolean;
  Mp4ffLoaded : Boolean = False;
  hMp4ff:TLibHandle=dynlibs.NilHandle; 

//////////// from mcwNeAACDec.pas By Franklyn A. Harlow

function CBMP4Read(user_data : Pointer; buffer : pcfloat; length : LongWord) : LongWord; cdecl;
begin
  try
   Result := LongWord(TAACInfo(user_data).fsStream.Read(buffer^, Integer(length)));
  except
    Result := 0;
  end;
end;

function CBMP4Write(user_data : Pointer; buffer : pcfloat; length : LongWord) : LongWord; cdecl;
begin
  try
    Result := LongWord(TAACInfo(user_data).fsStream.Write(buffer^, Integer(length)));
    TAACInfo(user_data).fsStream.Position:=0;
  except
    Result := 0;
  end;
end;

function CBMP4Seek(user_data : Pointer; Position : Int64) : LongWord; cdecl;
begin
  try
    Result := LongWord(TAACInfo(user_data).fsStream.Seek(Position, soBeginning));
  except
    Result := 0;
  end;
end;

function CBMP4Truncate(user_data : Pointer) : LongWord; cdecl;
begin
    Result := 0;
end;

//////////// from mcwAAC.pas By Franklyn A. Harlow

Function aa_load(mp4ff, NeAAC: AnsiString): Boolean;
Begin
  // Safe To Call Multiple times, actual load of Lib checks to see if it is already loaded &
  // returns true if it is...
  LoadNeAAC(NeAAC);
 
  Loadmp4ff(mp4ff);
 
  Result:= Is_NeAAC_Loaded And isMp4ffLoaded;
End;

Procedure aa_Unload;
Begin
  UnLoadNeAAC();
  UnLoadMp4ff();
End;

Function isLibAACLoaded : Boolean;
Begin
  Result:= Is_NeAAC_Loaded And isMp4ffLoaded;
end;

Function isFileAAC(fName : AnsiString): Boolean;
Begin
  Result:= LowerCase(ExtractFileExt(fName)) = '.m4a';
end;

Function MP4OpenFile(fName : String; OutputFormat : Byte) : TAACInfo;
Var
  pConfig      : PNeAACDecConfiguration;
  mp4ASC       : mp4AudioSpecificConfig;

  pBuf         : pcfloat;
  lwBufSize    : longword;
  lwBufSize2   : longword;
  lwSampleRate : longword;
  bChannels    : byte;

  bRet         : Byte;
  iRet         : LongInt;
  pID3         : PAnsiChar;
  f            : Double;
Begin
  Result:= nil;
  if not FileExists(fName) then
    Exit;
  if Not isFileAAC(fName) then
    Exit;
  //  writeln('MP4OpenFileBegin');
  
  Result:= TAACInfo.Create;
    //  writeln('MP4OpenFile3');

  Result.fsStream:= TFileStream.Create(fName, fmOpenRead or fmShareDenyWrite);
 
  sleep(1);
  
     //    writeln('MP4OpenFile4');
  Result.cbs.read      := @CBMP4Read;
  Result.cbs.write     := @CBMP4Write;
  Result.cbs.seek      := @CBMP4Seek;
  Result.cbs.truncate  := @CBMP4Truncate;
  Result.cbs.user_data := Pointer(Result);
     //   writeln('MP4OpenFile5');
  
  Result.pDecoder := NeAACDecOpen();
     //   writeln('MP4OpenFile6');

  pConfig := NeAACDecGetCurrentConfiguration(Result.pDecoder);
        //    writeln('MP4OpenFile7');
  pConfig^.defObjectType           := LC;
  pConfig^.defSampleRate           := 44100;
  pConfig^.outputFormat            := OutputFormat; // FAAD_FMT_FLOAT  FAAD_FMT_16BIT  FAAD_FMT_32BIT
  pConfig^.downMatrix              := 1;
  pConfig^.dontUpSampleImplicitSBR := 0;
  
  NeAACDecSetConfiguration(Result.pDecoder, pConfig) ;
  
  pConfig := NeAACDecGetCurrentConfiguration(Result.pDecoder);
  //     writeln('MP4OpenFile9');

  case pConfig^.outputFormat of
   FAAD_FMT_16BIT : Result.BitsPerSample := 16;
   FAAD_FMT_24BIT : Result.BitsPerSample := 24;
   FAAD_FMT_32BIT : Result.BitsPerSample := 32;
   FAAD_FMT_FLOAT : Result.BitsPerSample := 32;
   FAAD_FMT_DOUBLE: Result.BitsPerSample := 64;
  end;
      //   writeln('MP4OpenFile10');
  Result.outputFormat:= pConfig^.outputFormat;
       
  Result.hMP4 := mp4ff_open_read(@Result.cbs);
  //    writeln('MP4OpenFile11');
      
  Result.fTrack := GetAACTrack(Result.hMP4);
  //  writeln('MP4OpenFile12');

  pBuf:= nil;
  iRet:= mp4ff_get_decoder_config(Result.hMP4, Result.fTrack, pBuf, lwBufSize);
  //  writeln('MP4OpenFile13');

  lwBufSize2:= lwBufSize;
  //   writeln('MP4OpenFile14');
 
  bRet:= NeAACDecInit2(Result.pDecoder, pBuf, lwBufSize, lwSampleRate, bChannels);
  //   writeln('MP4OpenFile15');
 
  Result.SampleRate := mp4ff_get_sample_rate(Result.hMP4, Result.fTrack);
  Result.Channels   := mp4ff_get_channel_count(Result.hMP4, Result.fTrack);
  Result.fTimescale := mp4ff_time_scale(Result.hMP4, Result.fTrack);
  Result.Bitrate    := mp4ff_get_avg_bitrate(Result.hMP4, Result.fTrack);
  Result.Size       := mp4ff_num_samples(Result.hMP4, Result.fTrack);
    //   writeln('MP4OpenFile16');
  
  if pBuf <> nil then
  begin
    bRet:= NeAACDecAudioSpecificConfig(pBuf, lwBufSize2, mp4ASC);
    //    writeln('MP4OpenFile17');

    if bRet <> 0 then
    Begin
      // unix x64, NeAACDecAudioSpecificConfig Fails correct read,
      // But if both previous SampleRates match, we'll use them...
      {$IFDEF unix}{$IFDEF CPU64}
      if Result.SampleRate = lwSampleRate then
      Begin
        mp4ASC.sbr_present_flag  := 0;
        mp4ASC.samplingFrequency := lwSampleRate;
      End;
      {$ENDIF}{$ENDIF}
      End;
     //   writeln('MP4OpenFile18');
    mp4ff_free_decoder_config(pBuf);
    //    writeln('MP4OpenFile19');
    end;
  
    f := 1024.0;
    if mp4ASC.sbr_present_flag = 1 then
      f := f * 2.0;
    Result.TotalTime    := Result.Size * (f-1.0) / mp4ASC.samplingFrequency;
  { ...End}
  Result.TotalSamples := Trunc(Result.TotalTime * mp4ASC.samplingFrequency);
    //   writeln('MP4OpenFile20');
  if mp4ASC.samplingFrequency > Result.SampleRate then
    Result.SampleRate:= mp4ASC.samplingFrequency;

  Result.Artist:= '';
  iRet:= mp4ff_meta_get_writer(Result.hMP4,  pID3);
  if iRet = 1 then
    Result.Artist:= pID3;

  Result.AlbumArtist:= '';
  iRet:= mp4ff_meta_get_artist(Result.hMP4,  pID3);
  if iRet = 1 then
    Result.AlbumArtist:= pID3;

  Result.Album:= '';
  iRet:= mp4ff_meta_get_album(Result.hMP4,   pID3);
  if iRet = 1 then
    Result.Album:= pID3;

  Result.Title:= '';
  iRet:= mp4ff_meta_get_title(Result.hMP4,   pID3);
  if iRet = 1 then
    Result.Title:= pID3;

  Result.Date:= '';
  iRet:= mp4ff_meta_get_date(Result.hMP4,    pID3);
  if iRet = 1 then
    Result.Date:= pID3;

  Result.Genre:= '';
  iRet:= mp4ff_meta_get_genre(Result.hMP4,   pID3);
  if iRet = 1 then
    Result.Genre:= pID3;

  Result.Track:= '';
  iRet:= mp4ff_meta_get_track(Result.hMP4,   pID3);
  if iRet = 1 then
    Result.Track:= pID3;

  Result.Comment:= '';
  iRet:= mp4ff_meta_get_comment(Result.hMP4, pID3);
  if iRet = 1 then
    Result.Comment:= pID3;

  Result.Position  := 0;
  Result.fBufStart := 0;
  Result.fBufEnd   := 0;
 //  writeln('MP4OpenFile End');
end;

Procedure MP4CloseFile(var AACI: TAACInfo);
Begin
  // writeln('MP4CloseFile1');
   NeAACDecClose(AACI.pDecoder);
   sleep(50);
 //  writeln('MP4CloseFile2');
   mp4ff_close(AACI.hMP4);
 //  writeln('MP4CloseFile3');
   sleep(50);
 end;

procedure MP4GetData(var AACI: TAACInfo; var Buffer: pcfloat; var Bytes: longword);
var
  ReqBytes          : longword;
  CurBufSize        : longword;
  NewSampleBuf      : Pointer;
  NewBytesRead      : longword;
  NewBytesDecoded   : longword;

  Function readNextSample(var audioBuf : pcfloat; var audioSize : longword): longword;
   Begin
    audioSize := 0;
    Result:= 0;
    audioBuf  := nil;
       //  writeln('readNextSample');
    if AACI.Position > AACI.Size then
    Begin
      Result:= 0;
      Exit;
    end;
    Result := mp4ff_read_sample(AACI.hMP4, AACI.fTrack, AACI.Position, audioBuf,  audioSize);
    Inc(AACI.Position);
  end;

  Function getNextChunk(var SampBuf : Pointer; var NBR : longword) : longword;
  Var
    pAB : pcfloat;
    iAB : longword;
    frameInfo: NeAACDecFrameInfo;
  Begin
    NBR:= 0;
    // writeln('getNextChunk');
  Result:= 0;
  Result:= readNextSample(pAB, iAB);
    if Result = 0 then Exit;
    SampBuf := NeAACDecDecode(AACI.pDecoder, @frameInfo, pAB, iAB);
    if pAB <> nil then
      mp4ff_free_decoder_config(pAB);

    NBR:= frameInfo.samples * (AACI.BitsPerSample div 8);
  end;

begin
  //    writeln('MP4GetData1');
   ReqBytes:= Bytes;
  // writeln('MP4GetDataBegin1-2');
   CurBufSize:= AACI.fBufEnd  - AACI.fBufStart;
   
  While ReqBytes > CurBufSize do
  Begin
  // writeln('MP4GetData31');
    // We need to put more data into Buffer...

    // If We Have Left Over Data...
    if CurBufSize > 0 then
    Begin
      // Save Existing Left over data..
      Move(AACI._Buf[AACI.fBufStart], AACI.BufTmp[0], CurBufSize);
      // Put Existing Data to Start of buffer...
      Move(AACI.BufTmp[0], AACI._Buf[0], CurBufSize);
    end;
    
    // writeln('MP4GetData32');
    // because we reshuffled buffers, AACI.fBufStart is now 0
    AACI.fBufStart:= 0;
    NewSampleBuf  := nil;
    // Read next block of data
     
    NewBytesRead:= getNextChunk(NewSampleBuf, NewBytesDecoded);
   
    //  writeln('MP4GetData322');
    if NewBytesRead = 0 then
    begin
      Buffer         := nil;
      Bytes          := 0;
      Exit;
    end;
   // writeln('MP4GetData33');
    // Append new data to buffer
    Move(NewSampleBuf^, AACI._Buf[CurBufSize], NewBytesDecoded);
    // Update current unprocessed data count
    CurBufSize:= CurBufSize + NewBytesDecoded;
  //  writeln('MP4GetData34');
  end;

    // writeln('MP4GetData4');

  // set AACI.fBufEnd to last valid data byte in buffer
  AACI.fBufEnd:= CurBufSize;

  // writeln('MP4GetData5');

  // If requested Byte count is more tha what we have, reduce requested count..
  if Bytes > AACI.fBufEnd - AACI.fBufStart then
    Bytes := AACI.fBufEnd - AACI.fBufStart;

  // writeln('MP4GetData6');

  // pass data back to calling function/procedure
  Buffer := @AACI._Buf[AACI.fBufStart];

 // writeln('MP4GetData7');

  Inc(AACI.fBufStart, Bytes);

 // writeln('MP4GetData8');

end;

function MP4Seek(var AACI: TAACInfo; var SampleNum: longint) : Boolean;
begin
  Result := False;
  if (AACI.Size = 0) or (AACI.TotalSamples = 0) then
    Exit;

  if SampleNum > AACI.TotalSamples then
    SampleNum := AACI.TotalSamples;

  AACI.Position:= Trunc(SampleNum / AACI.TotalSamples * AACI.Size);
  Result := True;
end;

procedure LoadNeAAC(NeAAC : AnsiString);
var
thelib: string; 
Begin
   if Length(NeAAC) = 0 then thelib := libaa else thelib := NeAAC;
  hNeAAC:= DynLibs.SafeLoadLibrary(PChar(thelib));
  NeAACLoaded:= hNeAAC <> dynlibs.NilHandle;

     Pointer(NeAACDecGetErrorMessage) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecGetErrorMessage'));
      Pointer(NeAACDecGetCapabilities) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecGetCapabilities'));
       Pointer(NeAACDecOpen) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecOpen'));
        Pointer(NeAACDecGetCurrentConfiguration) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecGetCurrentConfiguration'));
         Pointer(NeAACDecSetConfiguration) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecSetConfiguration'));
          Pointer(NeAACDecInit) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecInit'));
           Pointer(NeAACDecInit2) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecInit2'));
            Pointer(NeAACDecPostSeekReset) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecPostSeekReset'));
             Pointer(NeAACDecClose) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecClose'));
         Pointer(NeAACDecDecode) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecDecode'));
           Pointer(NeAACDecDecode2) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecDecode2'));
            Pointer(NeAACDecPostSeekReset) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecPostSeekReset'));
             Pointer(NeAACDecAudioSpecificConfig) :=
        GetProcAddress(hNeAAC, PChar('NeAACDecAudioSpecificConfig'));
end;

Procedure UnLoadNeAAC;
Begin
  if NeAACLoaded then
    DynLibs.UnloadLibrary(hNeAAC);
  NeAACLoaded:= False;
end;

Function Is_NeAAC_Loaded : Boolean;
Begin
  Result:= NeAACLoaded;
end;

////////////////////////////// from mcwMP4FF.pas by Franklyn A. Harlow

function GetAACTrack(infile : mp4ff_t) : Integer;
var
  i, rc, numTracks : Integer;
  buff : pcfloat;
  buff_size : LongWord;
  mp4ASC : mp4AudioSpecificConfig;
begin
    numTracks := mp4ff_total_tracks(infile);
    for i := 0 to numTracks - 1 do
    begin
        buff := nil;
        buff_size:=0;
        mp4ff_get_decoder_config(infile, i, buff, buff_size);
        if buff <> nil then
        begin
          rc  := NeAACDecAudioSpecificConfig(buff, buff_size, mp4ASC);
          mp4ff_free_decoder_config(buff);
          if rc < 0 then
               continue;
          Result := i;
          Exit;
        end;
    end;
    Result :=  -1;
end;

procedure UnLoadMp4ff;
begin
  if Mp4ffLoaded then
  
    DynLibs.UnloadLibrary(hMp4ff);
  
  Mp4ffLoaded := False;
end;

Function isMp4ffLoaded : Boolean;
Begin
Result:= Mp4ffLoaded;
end;


 procedure Loadmp4ff(mp4ff : AnsiString);
 var
thelib: string; 
begin
  if Mp4ffLoaded then
    Exit;
 if Length(mp4ff) = 0 then thelib := libm4 else thelib := mp4ff;
  hMp4ff := DynLibs.SafeLoadLibrary(PChar(thelib));
  Mp4ffLoaded := hMp4ff <> dynlibs.NilHandle;
  
   // writeln('hMp4ff' + inttostr(hMp4ff));

   Pointer(mp4ff_open_read) :=
        GetProcAddress(hMp4ff, pchar('mp4ff_open_read'));
        
  //  if Pointer(mp4ff_open_read) <> nil then
  //    writeln('mp4ff_open_read OK') else 
  // writeln('mp4ff_open_read NOT OK'); 
      
     Pointer(mp4ff_open_read_metaonly) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_open_read_metaonly'));
     Pointer(mp4ff_close) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_close'));
     Pointer(mp4ff_get_sample_duration) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_sample_duration'));
     Pointer(mp4ff_get_sample_duration_use_offsets) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_sample_duration_use_offsets'));
     Pointer(mp4ff_get_sample_position) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_sample_position'));
     Pointer(mp4ff_get_sample_offset) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_sample_offset'));
     Pointer(mp4ff_find_sample) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_find_sample'));

     Pointer(mp4ff_find_sample_use_offsets) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_find_sample_use_offsets'));
     Pointer(mp4ff_set_sample_position) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_set_sample_position'));
     Pointer(mp4ff_read_sample) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_read_sample'));
     Pointer(mp4ff_read_sample_v2) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_read_sample_v2'));
     Pointer(mp4ff_read_sample_getsize) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_read_sample_getsize'));
     Pointer(mp4ff_get_sample_position) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_sample_position'));
     Pointer(mp4ff_get_sample_offset) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_sample_offset'));
     Pointer(mp4ff_find_sample) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_find_sample'));

       Pointer(mp4ff_get_decoder_config) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_get_decoder_config'));
     Pointer(mp4ff_get_track_type) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_get_track_type'));
     Pointer(mp4ff_total_tracks) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_total_tracks'));
     Pointer(mp4ff_num_samples) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_num_samples'));
     Pointer(mp4ff_time_scale) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_time_scale'));
     Pointer(mp4ff_get_avg_bitrate) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_avg_bitrate'));
     Pointer(mp4ff_get_max_bitrate) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_max_bitrate'));
     Pointer(mp4ff_get_track_duration) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_track_duration'));

       Pointer(mp4ff_get_track_duration_use_offsets) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_get_track_duration_use_offsets'));
     Pointer(mp4ff_get_sample_rate) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_get_sample_rate'));
     Pointer(mp4ff_get_channel_count) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_channel_count'));
     Pointer(mp4ff_get_audio_type) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_get_audio_type'));
     Pointer(mp4ff_free_decoder_config) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_free_decoder_config'));
     Pointer(mp4ff_meta_get_num_items) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_num_items'));
     Pointer(mp4ff_meta_get_by_index) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_by_index'));
     Pointer(mp4ff_meta_get_title) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_title'));

        Pointer(mp4ff_meta_get_artist) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_artist'));
     Pointer(mp4ff_meta_get_writer) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_writer'));
     Pointer(mp4ff_meta_get_album) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_album'));
     Pointer(mp4ff_meta_get_date) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_date'));
     Pointer(mp4ff_meta_get_tool) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_tool'));
     Pointer(mp4ff_meta_get_comment) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_comment'));
     Pointer(mp4ff_meta_get_genre) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_genre'));
     Pointer(mp4ff_meta_get_track) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_track'));

        Pointer(mp4ff_meta_get_disc) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_disc'));
     Pointer(mp4ff_meta_get_totaltracks) :=
        GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_totaltracks'));
     Pointer(mp4ff_meta_get_totaldiscs) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_totaldiscs'));
     Pointer(mp4ff_meta_get_compilation) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_compilation'));
     Pointer(mp4ff_meta_get_tempo) :=
            GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_tempo'));
     Pointer(mp4ff_meta_get_coverart) :=
           GetProcAddress(hMp4ff, PChar('mp4ff_meta_get_coverart'));

end;

initialization
  NeAACLoaded:= False;
  SetExceptionMask(GetExceptionMask + [exZeroDivide] + [exInvalidOp] +
 [exDenormalized] + [exOverflow] + [exPrecision]);

finalization
end.
