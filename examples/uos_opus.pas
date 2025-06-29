{This unit is part of United Openlibraries of Sound (uos)}

{This is the Pascal Wrapper + Dynamic loading of Opus library.
 Load library with op_load() and release with op_unload().
 License : modified LGPL. 
 Fred van Stappen / fiens@hotmail.com} 

unit uos_opus;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

interface

uses
   dynlibs, CTypes, SysUtils;

const
  OPUS_OK = 0;
  OPUS_BAD_ARG = -1;
  OPUS_BUFFER_TOO_SMALL = -2;
  OPUS_INTERNAL_ERROR = -3;
  OPUS_INVALID_PACKET = -4;
  OPUS_UNIMPLEMENTED = -5;
  OPUS_INVALID_STATE = -6;
  OPUS_ALLOC_FAIL = -7;

  OPUS_APPLICATION_VOIP = 2048;
  OPUS_APPLICATION_AUDIO = 2049;
  OPUS_APPLICATION_RESTRICTED_LOWDELAY = 2051;

  OPUS_SIGNAL_VOICE = 3001; // Signal being encoded is voice
  OPUS_SIGNAL_MUSIC = 3002; // Signal being encoded is music

  OPUS_BANDWIDTH_NARROWBAND = 1101; // 4 kHz bandpass @hideinitializer
  OPUS_BANDWIDTH_MEDIUMBAND = 1102; // 6 kHz bandpass @hideinitializer
  OPUS_BANDWIDTH_WIDEBAND = 1103;  // 8 kHz bandpass @hideinitializer
  OPUS_BANDWIDTH_SUPERWIDEBAND = 1104; // 12 kHz bandpass @hideinitializer
  OPUS_BANDWIDTH_FULLBAND = 1105; // 20 kHz bandpass @hideinitializer

  OPUS_FRAMESIZE_ARG = 5000; // Select frame size from the argument (default)
  OPUS_FRAMESIZE_2_5_MS = 5001; // Use 2.5 ms frames
  OPUS_FRAMESIZE_5_MS = 5002; // Use 5 ms frames
  OPUS_FRAMESIZE_10_MS = 5003; // Use 10 ms frames
  OPUS_FRAMESIZE_20_MS = 5004; // Use 20 ms frames
  OPUS_FRAMESIZE_40_MS = 5005; // Use 40 ms frames
  OPUS_FRAMESIZE_60_MS = 5006; // Use 60 ms frames

const
  OPUS_SET_APPLICATION_REQUEST = 4000;
  OPUS_GET_APPLICATION_REQUEST = 4001;
  OPUS_SET_BITRATE_REQUEST = 4002;
  OPUS_GET_BITRATE_REQUEST = 4003;
  OPUS_SET_MAX_BANDWIDTH_REQUEST = 4004;
  OPUS_GET_MAX_BANDWIDTH_REQUEST = 4005;
  OPUS_SET_VBR_REQUEST = 4006;
  OPUS_GET_VBR_REQUEST = 4007;
  OPUS_SET_BANDWIDTH_REQUEST = 4008;
  OPUS_GET_BANDWIDTH_REQUEST = 4009;
  OPUS_SET_COMPLEXITY_REQUEST = 4010;
  OPUS_GET_COMPLEXITY_REQUEST = 4011;
  OPUS_SET_INBAND_FEC_REQUEST = 4012;
  OPUS_GET_INBAND_FEC_REQUEST = 4013;
  OPUS_SET_PACKET_LOSS_PERC_REQUEST = 4014;
  OPUS_GET_PACKET_LOSS_PERC_REQUEST = 4015;
  OPUS_SET_DTX_REQUEST = 4016;
  OPUS_GET_DTX_REQUEST = 4017;
  OPUS_SET_VBR_CONSTRAINT_REQUEST = 4020;
  OPUS_GET_VBR_CONSTRAINT_REQUEST = 4021;
  OPUS_SET_FORCE_CHANNELS_REQUEST = 4022;
  OPUS_GET_FORCE_CHANNELS_REQUEST = 4023;
  OPUS_SET_SIGNAL_REQUEST = 4024;
  OPUS_GET_SIGNAL_REQUEST = 4025;
  OPUS_GET_LOOKAHEAD_REQUEST = 4027;
  OPUS_RESET_STATE_REQUEST = 4028;
  OPUS_GET_SAMPLE_RATE_REQUEST = 4029;
  OPUS_GET_FINAL_RANGE_REQUEST = 4031;
  OPUS_GET_PITCH_REQUEST = 4033;
  OPUS_SET_GAIN_REQUEST = 4034;
  OPUS_GET_GAIN_REQUEST = 4045;
  OPUS_SET_LSB_DEPTH_REQUEST = 4036;
  OPUS_GET_LSB_DEPTH_REQUEST = 4037;
  OPUS_GET_LAST_PACKET_DURATION_REQUEST = 4039;
  OPUS_SET_EXPERT_FRAME_DURATION_REQUEST = 4040;
  OPUS_GET_EXPERT_FRAME_DURATION_REQUEST = 4041;
  OPUS_SET_PREDICTION_DISABLED_REQUEST = 4042;
  OPUS_GET_PREDICTION_DISABLED_REQUEST = 4043;
  OPUS_MULTISTREAM_GET_ENCODER_STATE_REQUEST = 5120;
  OPUS_MULTISTREAM_GET_DECODER_STATE_REQUEST = 5122;

type
  TOpusEncoder = Pointer;
  TOpusDecoder = Pointer;
  TOpusRepacketizer = Pointer;
  TOpusMSDecoder = pointer;
  TOpusMSEncoder = pointer;

  TOpusFrames = array [0..47] of Pointer;
  TOpusFrameSizes = array [0..47] of cint;

type
  TRequestValueType = (orPointer, orInteger, orXY, orNoValue);
  TOpusCTLRequestRecord = record
    Request: Word;
    case ReqType: TRequestValueType of
      orPointer: (PtrValue: Pointer);
      orInteger: (IntValue: cint);
      orXY: (XValue: cint; YValue: pointer);
  end;
  
  var
  opus_get_version_string: function(): PAnsiChar; cdecl;  opus_strerror: function(error: cint): PAnsiChar; cdecl;  
  opus_encode: function(st: TOpusEncoder; pcm : pcfloat; frame_size: cint;
   var data; max_data_bytes: cint): cint; cdecl; 
  opus_encode_float: function(st: TOpusEncoder; pcm : pcfloat; frame_size: cint; var data; max_data_bytes: cint): cint; cdecl;
  opus_encoder_create: function(Fs: cint; channels, application: cint; out error: cint): TOpusEncoder; cdecl;
 
  opus_encoder_ctli: function(st: TOpusEncoder; const reqrequest: word ; reqval : cint ): cint; cdecl;
  opus_encoder_ctlp: function(st: TOpusEncoder; const reqrequest: word ; reqval : pointer ): cint; cdecl;
  opus_encoder_ctlxy: function(st: TOpusEncoder; const reqrequest: word ; reqx : cint ; reqy : pointer ): cint; cdecl;
  opus_encoder_ctln: function(st: TOpusEncoder; const reqrequest: word): cint; cdecl;
  
 opus_encoder_destroy: procedure(st: TOpusEncoder); cdecl;
  opus_encoder_get_size: function(channels: cint): cint; cdecl;
  opus_encoder_init: function(st: TOpusEncoder; Fs: cint; channels, application: cint): cint; cdecl;

 opus_decode: function(st: TOpusDecoder; const data; len: cint; pcm : pcfloat; frame_size, decode_fec: cint): cint; cdecl;
 opus_decode_float: function(st: TOpusDecoder; const data; len: cint; pcm : pcfloat; frame_size, decode_fec: cint): cint; cdecl;
 opus_decoder_create: function(fs: cint; channels: cint; out error: cint): TOpusDecoder; cdecl;
 
 opus_decoder_ctli: function(st: TOpusDecoder; const reqrequest: word ; reqval : cint ): cint; cdecl;
 opus_decoder_ctlp: function(st: TOpusDecoder; const reqrequest: word ; reqval : pointer ): cint; cdecl;
 opus_decoder_ctlxy: function(st: TOpusDecoder; const reqrequest: word ; reqx : cint ; reqy : pointer ): cint; cdecl;
 opus_decoder_ctln: function(st: TOpusDecoder; const reqrequest: word): cint; cdecl;

 opus_decoder_destroy: procedure(st: TOpusDecoder); cdecl;
 opus_decoder_get_nb_samples: function(st: TOpusDecoder; const packet; len: cint): cint; cdecl;
 opus_decoder_get_size: function(channels: cint): cint; cdecl;
 opus_decoder_init: function(st: TOpusDecoder; Fs: cint; channels: cint): cint; cdecl;
 opus_packet_get_bandwidth: function(const packet): cint; cdecl;
 opus_packet_get_nb_channels: function(const packet): cint; cdecl;
 opus_packet_get_nb_frames: function(const packet; len: cint): cint; cdecl;
 opus_packet_get_nb_samples: function(const packet; len, fs: cint): cint; cdecl;
 opus_packet_get_samples_per_frame: function(const packet; fs: cint): cint; cdecl;
 opus_packet_parse: function(const packet; var out_toc: Pointer; var frames: TOpusFrames; var size: TOpusFrameSizes; var payload_offset: cint): cint; cdecl;
 opus_pcm_soft_clip: procedure(pcm : pcfloat; frame_size, channels: cint; var softclip_mem: Double); cdecl;
 
 opus_multistream_packet_pad: function(var data; len, new_len, nb_streams: cint): cint; cdecl;
 opus_multistream_packet_unpad: function(var data; len, nb_streams: cint): cint; cdecl;
 opus_packet_pad: function(var data; len, new_len: cint): cint; cdecl;
 opus_packet_unpad: function(var data; len: cint): cint; cdecl;
 opus_repacketizer_cat: function(rp: TOpusRepacketizer; const data; len: cint): cint; cdecl;
 opus_repacketizer_create: function: TOpusRepacketizer; cdecl;
 opus_repacketizer_destroy: procedure(rp: TOpusRepacketizer); cdecl;
 opus_repacketizer_get_nb_frames: function(rp: TOpusRepacketizer): cint; cdecl;
 opus_repacketizer_get_size: function: cint; cdecl;
 opus_repacketizer_init: function(rp: TOpusRepacketizer): TOpusRepacketizer; cdecl;
 opus_repacketizer_out: function(rp: TOpusRepacketizer; var data; maxlen: cint): cint; cdecl;
 opus_repacketizer_out_range: function(rp: TOpusRepacketizer; var data; maxlen: cint): cint; cdecl;

 opus_multistream_decode: function(st: TOpusMSDecoder; const data; len: cint; pcm : pcfloat; frame_size, decode_fec: cint): cint; cdecl;
 opus_multistream_decode_float: function(st: TOpusMSDecoder; const data; len: cint; pcm : pcfloat; frame_size, decode_fec: cint): cint; cdecl;
 opus_multistream_decoder_create: function(fs: cint; channels, streams, coupled_streams: cint; const mapping: array of Byte; out error: cint): TOpusMSDecoder; cdecl;
 
 opus_multistream_decoder_ctli: function(st: TOpusMSDecoder; const reqrequest: word ; reqval : cint ): cint; cdecl;
 opus_multistream_decoder_ctlp: function(st: TOpusMSDecoder; const reqrequest: word ; reqval : pointer ): cint; cdecl;
 opus_multistream_decoder_ctlxy: function(st: TOpusMSDecoder; const reqrequest: word ; reqx : cint ; reqy : pointer ): cint; cdecl;
 opus_multistream_decoder_ctln: function(st: TOpusMSDecoder; const reqrequest: word): cint; cdecl;

 opus_multistream_decoder_destroy: procedure(st: TOpusMSDecoder); cdecl;
 opus_multistream_decoder_get_size: function(streams, coupled_streams: cint): cint; cdecl;
 opus_multistream_decoder_init: function(st: TOpusMSDecoder; fs: cint; channels, streams, coupled_streams: cint; const mapping: array of Byte): cint; cdecl;

 opus_multistream_encode: function(st: TOpusMSEncoder; pcm : pcfloat; frame_size: cint; var data; max_data_bytes: cint): cint; cdecl;
 opus_multistream_encode_float: function(st: TOpusMSEncoder; pcm : pcfloat; frame_size: cint; var data; max_data_bytes: cint): cint; cdecl;
 opus_multistream_encoder_create: function(Fs: cint; channels, streams, coupled_streams: cint; const mapping: array of Byte; application: cint; out error: cint): TOpusMSEncoder; cdecl;
 
 opus_multistream_encoder_ctli: function(st: TOpusMSEncoder; const reqrequest: word ; reqval : cint ): cint; cdecl;
 opus_multistream_encoder_ctlp: function(st: TOpusMSEncoder; const reqrequest: word ; reqval : pointer ): cint; cdecl;
 opus_multistream_encoder_ctlxy: function(st: TOpusMSEncoder; const reqrequest: word ; reqx : cint ; reqy : pointer ): cint; cdecl;
 opus_multistream_encoder_ctln: function(st: TOpusMSEncoder; const reqrequest: word ): cint; cdecl;

 opus_multistream_encoder_destroy: procedure(st: TOpusMSEncoder); cdecl;
 opus_multistream_encoder_get_size: function(streams, coupled_streams: cint): cint; cdecl;
 opus_multistream_encoder_init: function(st: TOpusMSEncoder; fs: cint; channels, streams, coupled_streams: cint; const mapping: array of Byte; application: cint): cint; cdecl;

 opus_multistream_surround_encoder_create: function(Fs: cint; channels, mapping_family, streams, coupled_streams: cint; const mapping: array of Byte; application: cint; out error: cint): TOpusMSEncoder; cdecl;
 opus_multistream_surround_encoder_get_size: function(channels, mapping_family: cint): cint; cdecl;
 opus_multistream_surround_encoder_init: function(st: TOpusMSEncoder; fs: cint; channels, mapping_family, streams, coupled_streams: cint; const mapping: array of Byte; application: cint): cint; cdecl; 

function opus_encoder_ctl(st: TOpusEncoder; const req: TOpusCTLRequestRecord): Integer; inline;
function opus_decoder_ctl(st: TOpusdecoder; const req: TOpusCTLRequestRecord): Integer; inline;

function opus_multistream_encoder_ctl(st: TOpusMSEncoder; const req: TOpusCTLRequestRecord): cint; inline;
function opus_multistream_decoder_ctl(st: TOpusMSdecoder; const req: TOpusCTLRequestRecord): cint; inline;

// Macros for opus_encode_ctl.
function OPUS_GET_APPLICATION(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_BITRATE(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_COMPLEXITY(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_DTX(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_EXPERT_FRAME_DURATION(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_FORCE_CHANNELS(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_LOOKAHEAD(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_LSB_DEPTH(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_MAX_BANDWIDTH(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_PACKET_LOSS_PERC(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_PREDICTION_DISABLED(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_SIGNAL(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_VBR(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_VBR_CONSTRAINT(var x: cint): TOpusCTLRequestRecord; inline;

function OPUS_SET_APPLICATION(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_BANDWIDTH(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_BITRATE(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_COMPLEXITY(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_DTX(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_EXPERT_FRAME_DURATION(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_FORCE_CHANNELS(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_INBAND_FEC(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_LSB_DEPTH(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_MAX_BANDWIDTH(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_PACKET_LOSS_PERC(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_PREDICTION_DISABLED(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_SIGNAL(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_VBR(x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_VBR_CONSTRAINT(x: cint): TOpusCTLRequestRecord; inline;

// For opus_decoder_ctl and opus_encoder_ctl.
function OPUS_GET_BANDWIDTH(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_FINAL_RANGE(var x: Cardinal): TOpusCTLRequestRecord; inline;
function OPUS_GET_SAMPLE_RATE(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_RESET_STATE: TOpusCTLRequestRecord; inline;

// For the opus_decode_ctl.
function OPUS_GET_GAIN(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_LAST_PACKET_DURATION(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_GET_PITCH(var x: cint): TOpusCTLRequestRecord; inline;
function OPUS_SET_GAIN(x: cint): TOpusCTLRequestRecord; inline;

function OPUS_MULTISTREAM_GET_DECODER_STATE(x: cint; var y: cint): TOpusCTLRequestRecord; inline;
function OPUS_MULTISTREAM_GET_ENCODER_STATE(x: cint; var y: cint): TOpusCTLRequestRecord; inline;

 var op_Handle:TLibHandle=dynlibs.NilHandle; 
 
 var ReferenceCounter : cardinal = 0;  
         
function op_IsLoaded : boolean; inline; 

Function op_Load(const libfilename:string) :boolean; 
    
Procedure op_Unload;
  
implementation

function op_IsLoaded: boolean;
begin
 Result := (op_Handle <> dynlibs.NilHandle);
end;

Procedure op_Unload;
begin
// < Reference counting
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >
  if op_IsLoaded then
  begin
    DynLibs.UnloadLibrary(op_Handle);
    op_Handle:=DynLibs.NilHandle;
  end;
end;

Function op_Load (const libfilename:string) :boolean;
begin
  Result := False;
  if op_Handle<>0 then 
begin
 Inc(ReferenceCounter);
 result:=true {is it already there ?}
end  else 
begin {go & load the library}
    if Length(libfilename) = 0 then exit;
    op_Handle:=DynLibs.SafeLoadLibrary(libfilename); // obtain the handle we want
  	if op_Handle <> DynLibs.NilHandle then
begin {now we tie the functions to the VARs from above}
Pointer(opus_get_version_string):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_get_version_string'));
Pointer(opus_strerror):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_strerror'));
Pointer(opus_encode):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encode'));
Pointer(opus_encode_float):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encode_float'));
Pointer(opus_encoder_create):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encoder_create'));

Pointer(opus_encoder_ctli):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encoder_ctl'));
Pointer(opus_encoder_ctlp):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encoder_ctl'));
Pointer(opus_encoder_ctlxy):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encoder_ctl'));
Pointer(opus_encoder_ctln):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encoder_ctl'));

Pointer(opus_encoder_destroy):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encoder_destroy'));
Pointer(opus_encoder_get_size):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encoder_get_size'));
Pointer(opus_encoder_init):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_encoder_init'));
Pointer(opus_decode):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decode'));
Pointer(opus_decode_float):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decode_float'));
Pointer(opus_decoder_create):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decoder_create'));

Pointer(opus_decoder_ctli):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decoder_ctl'));
Pointer(opus_decoder_ctlp):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decoder_ctl'));
Pointer(opus_decoder_ctlxy):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decoder_ctl'));
Pointer(opus_decoder_ctln):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decoder_ctl'));

Pointer(opus_decoder_destroy):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decoder_destroy'));
Pointer(opus_decoder_get_nb_samples):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decoder_get_nb_samples'));
Pointer(opus_decoder_get_size):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decoder_get_size'));
Pointer(opus_decoder_init):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_decoder_init'));
Pointer(opus_packet_get_bandwidth):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_packet_get_bandwidth'));
Pointer(opus_packet_get_nb_channels):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_packet_get_nb_channels'));
Pointer(opus_packet_get_nb_frames):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_packet_get_nb_frames'));
Pointer(opus_packet_get_nb_samples):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_packet_get_nb_samples'));
Pointer(opus_packet_get_samples_per_frame):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_packet_get_samples_per_frame'));
Pointer( opus_packet_parse):=DynLibs.GetProcedureAddress(OP_Handle,PChar(' opus_packet_parse'));
Pointer(opus_pcm_soft_clip):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_pcm_soft_clip'));
Pointer(opus_multistream_packet_pad):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_packet_pad'));
Pointer(opus_multistream_packet_unpad):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_packet_unpad'));
Pointer(opus_packet_pad):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_packet_pad'));
Pointer(opus_packet_unpad):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_packet_unpad'));
Pointer(opus_repacketizer_cat):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_repacketizer_cat'));
Pointer(opus_repacketizer_create):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_repacketizer_create'));
Pointer(opus_repacketizer_destroy):=DynLibs.GetProcedureAddress(OP_Handle,PChar('oopus_repacketizer_destroy'));
Pointer(opus_repacketizer_get_nb_frames):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_repacketizer_get_nb_frames'));
Pointer(opus_repacketizer_get_size):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_repacketizer_get_size'));
Pointer(opus_repacketizer_init):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_repacketizer_init'));
Pointer(opus_repacketizer_out):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_repacketizer_out'));
Pointer(opus_repacketizer_out_range):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_repacketizer_out_range'));
Pointer(opus_multistream_decode):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decode'));
Pointer(opus_multistream_decode_float):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decode_float'));
Pointer(opus_multistream_decoder_create):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decoder_create'));

Pointer(opus_multistream_decoder_ctli):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decoder_ctl'));
Pointer(opus_multistream_decoder_ctlp):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decoder_ctl'));
Pointer(opus_multistream_decoder_ctlxy):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decoder_ctl'));
Pointer(opus_multistream_decoder_ctln):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decoder_ctl'));

Pointer(opus_multistream_decoder_destroy):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decoder_destroy'));
Pointer(opus_multistream_decoder_get_size):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decoder_get_size'));
Pointer(opus_multistream_decoder_init):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_decoder_init'));
Pointer(opus_multistream_encode):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encode'));
Pointer(opus_multistream_encode_float):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encode_float'));
Pointer(opus_multistream_encoder_create):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encoder_create'));

Pointer(opus_multistream_encoder_ctli):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encoder_ctl'));
Pointer(opus_multistream_encoder_ctlp):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encoder_ctl'));
Pointer(opus_multistream_encoder_ctlxy):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encoder_ctl'));
Pointer(opus_multistream_encoder_ctln):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encoder_ctl'));

Pointer(opus_multistream_encoder_destroy):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encoder_destroy'));
Pointer(opus_multistream_encoder_get_size):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encoder_get_size'));
Pointer(opus_multistream_encoder_init):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_encoder_init'));
Pointer(opus_multistream_surround_encoder_create):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_surround_encoder_create'));
Pointer(opus_multistream_surround_encoder_get_size):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_surround_encoder_get_size'));
Pointer(opus_multistream_surround_encoder_init):=DynLibs.GetProcedureAddress(OP_Handle,PChar('opus_multistream_surround_encoder_init'));

end;
   Result := op_IsLoaded;
   ReferenceCounter:=1;   
end;

end;


function OPUS_GET_APPLICATION(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_APPLICATION_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_BITRATE(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_BITRATE_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_COMPLEXITY(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_COMPLEXITY_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_DTX(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_DTX_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_EXPERT_FRAME_DURATION(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_EXPERT_FRAME_DURATION_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_FORCE_CHANNELS(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_FORCE_CHANNELS_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_LOOKAHEAD(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_LOOKAHEAD_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_LSB_DEPTH(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_LSB_DEPTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_MAX_BANDWIDTH(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_MAX_BANDWIDTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_PACKET_LOSS_PERC(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_PACKET_LOSS_PERC_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_PREDICTION_DISABLED(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_PREDICTION_DISABLED_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_SIGNAL(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_SIGNAL_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_VBR(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_VBR_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_VBR_CONSTRAINT(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_VBR_CONSTRAINT_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_SET_APPLICATION(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_APPLICATION_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_BANDWIDTH(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_BANDWIDTH_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_BITRATE(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_BITRATE_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_COMPLEXITY(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_COMPLEXITY_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_DTX(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_DTX_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_EXPERT_FRAME_DURATION(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_EXPERT_FRAME_DURATION_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_FORCE_CHANNELS(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_FORCE_CHANNELS_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_INBAND_FEC(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_INBAND_FEC_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_LSB_DEPTH(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_LSB_DEPTH_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_MAX_BANDWIDTH(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_MAX_BANDWIDTH_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_PACKET_LOSS_PERC(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_PACKET_LOSS_PERC_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_PREDICTION_DISABLED(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_PREDICTION_DISABLED_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_SIGNAL(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_SIGNAL_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_VBR(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_VBR_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_VBR_CONSTRAINT(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_VBR_CONSTRAINT_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_GET_BANDWIDTH(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_BANDWIDTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_FINAL_RANGE(var x: Cardinal): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_BANDWIDTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_SAMPLE_RATE(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_BANDWIDTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_RESET_STATE: TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_RESET_STATE_REQUEST;
  Result.ReqType := orNoValue;
end;

function OPUS_GET_GAIN(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_GAIN_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_LAST_PACKET_DURATION(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_LAST_PACKET_DURATION_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_PITCH(var x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_PITCH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_SET_GAIN(x: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_GAIN_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_MULTISTREAM_GET_DECODER_STATE(x: cint; var y: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_MULTISTREAM_GET_DECODER_STATE_REQUEST;
  Result.ReqType := orXY;
  Result.XValue := x;
  Result.YValue := @y;
end;

function OPUS_MULTISTREAM_GET_ENCODER_STATE(x: cint; var y: cint): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_MULTISTREAM_GET_ENCODER_STATE_REQUEST;
  Result.ReqType := orXY;
  Result.XValue := x;
  Result.YValue := @y;
end;

function opus_encoder_ctl(st: TOpusEncoder; const req: TOpusCTLRequestRecord): Integer; inline;
begin
   case req.ReqType of
    orPointer: Result := opus_encoder_ctlp(st, req.Request, req.PtrValue);
    orInteger: Result := opus_encoder_ctli(st, req.Request, req.IntValue);
    orXY: Result := opus_encoder_ctlxy(st, req.Request, req.XValue, req.YValue);
    orNoValue: Result := opus_encoder_ctln(st, req.Request);
  else
    Result := OPUS_BAD_ARG;
  end;
end;

function opus_decoder_ctl(st: TOpusDecoder; const req: TOpusCTLRequestRecord): Integer; inline;
begin
   case req.ReqType of
    orPointer: Result := opus_decoder_ctlp(st, req.Request, req.PtrValue);
    orInteger: Result := opus_decoder_ctli(st, req.Request, req.IntValue);
    orXY: Result := opus_decoder_ctlxy(st, req.Request, req.XValue, req.YValue);
    orNoValue: Result := opus_decoder_ctln(st, req.Request);
  else
    Result := OPUS_BAD_ARG;
  end;
end;

function opus_multistream_encoder_ctl(st: TOpusMSEncoder; const req: TOpusCTLRequestRecord): Integer; inline;
begin
   case req.ReqType of
    orPointer: Result := opus_multistream_encoder_ctlp(st, req.Request, req.PtrValue);
    orInteger: Result := opus_multistream_encoder_ctli(st, req.Request, req.IntValue);
    orXY: Result := opus_multistream_encoder_ctlxy(st, req.Request, req.XValue, req.YValue);
    orNoValue: Result := opus_multistream_encoder_ctln(st, req.Request);
  else
    Result := OPUS_BAD_ARG;
  end;
end;

function opus_multistream_decoder_ctl(st: TOpusMSDecoder; const req: TOpusCTLRequestRecord): Integer; inline;
begin
   case req.ReqType of
    orPointer: Result := opus_multistream_decoder_ctlp(st, req.Request, req.PtrValue);
    orInteger: Result := opus_multistream_decoder_ctli(st, req.Request, req.IntValue);
    orXY: Result := opus_multistream_decoder_ctlxy(st, req.Request, req.XValue, req.YValue);
    orNoValue: Result := opus_multistream_decoder_ctln(st, req.Request);
  else
    Result := OPUS_BAD_ARG;
  end;
end;

end.
