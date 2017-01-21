{This unit is part of United Openlibraries of Sound (uos)}

{This is the Pascal Wrapper + Dynamic loading of OpusFile library.
 Load library with of_load() and release with of_unload().
 License : modified LGPL. 
 Fred van Stappen / fiens@hotmail.com}

unit uos_OpusFile;

{$mode objfpc}{$H+}

interface

uses
  ctypes, dynlibs, SysUtils;
  
type
  TOggOpusFile = ^OggOpusFile;
  OggOpusFile = record
  end;

// Error Codes
const
  OP_FALSE = -1;
  OP_HOLE = -3;
  OP_EREAD = -128;
  OP_EFAULT = -129;
  OP_EIMPL = -130;
  OP_EINVAL = -131;
  OP_ENOTVORBIS = -132;
  OP_EBADHEADER = -133;
  OP_EVERSION = -134;
  OP_ENOTAUDIO = -135;
  OP_EBADPACKET = -136;
  OP_EBADLINK = -137;
  OP_ENOSEEK = -138;
  OP_EBADTIMESTAMP = -139;


type
  TOP_PIC_FORMAT = (OP_PIC_FORMAT_UNKNOWN = -1, OP_PIC_FORMAT_URL, OP_PIC_FORMAT_JPEG,
                    OP_PIC_FORMAT_PNG, OP_PIC_FORMAT_GIF);
type
  TOpusHead = THandle;
  TOpusStream = THandle;
  {$if not declared(size_t)}
  size_t = NativeUInt;
  {$endif}

  op_read_func = function (stream: Pointer; var buffer; nbytes: Integer): Integer; cdecl;
  op_seek_func = function (stream: Pointer; offset: Int64; whence: Integer): Integer; cdecl;
  op_tell_func = function (stream: Pointer): Int64; cdecl;
  op_close_func = function (stream: Pointer): Integer; cdecl;

  TOpusFileCallbacks = record
    read: op_read_func;
    seek: op_seek_func;
    tell: op_tell_func;
    close: op_close_func;
  end;

function OpusReadCB(stream: Pointer; var buffer; nbytes: Integer): Integer; cdecl;
function OpusSeekCB(stream: Pointer; offset: Int64; whence: Integer): Integer; cdecl;
function OpusTellCB(stream: Pointer): Int64; cdecl;
function OpusCloseCB(stream: Pointer): Integer; cdecl;

const
  op_callbacks: TOpusFileCallbacks = (read: @OpusReadCB;
                                      seek: @OpusSeekCB;
                                      tell: @OpusTellCB;
                                      close: nil);
type
  TOpusMSDecoder = Pointer;
  op_decode_cb_func = function(ctx: Pointer; decoder: TOpusMSDecoder; pcm : pcfloat; op: Pointer;
                               nsamples, nchannels, format, li: Integer): Integer; cdecl;
  TOpusTags = record
    user_comments: PPAnsiChar; // The array of comment string vectors
    comment_lengths: PInteger; // An array of the corresponding length of each vector, in bytes
    comments: Integer;         // The total number of comment streams
    vendor: PAnsiChar;         // The null-terminated vendor string. This identifies the software used to encode the stream.
  end;
  POpusTags = ^TOpusTags;

  TOpusPictureTag = record
    Pic_Type: Integer; { The picture type according to the ID3v2 APIC frame:
                         <ol start="0">
                         <li>Other</li>
                         <li>32x32 pixels 'file icon' (PNG only)</li>
                         <li>Other file icon</li>
                         <li>Cover (front)</li>
                         <li>Cover (back)</li>
                         <li>Leaflet page</li>
                         <li>Media (e.g. label side of CD)</li>
                         <li>Lead artist/lead performer/soloist</li>
                         <li>Artist/performer</li>
                         <li>Conductor</li>
                         <li>Band/Orchestra</li>
                         <li>Composer</li>
                         <li>Lyricist/text writer</li>
                         <li>Recording Location</li>
                         <li>During recording</li>
                         <li>During performance</li>
                         <li>Movie/video screen capture</li>
                         <li>A bright colored fish</li>
                         <li>Illustration</li>
                         <li>Band/artist logotype</li>
                         <li>Publisher/Studio logotype</li>
                         </ol> }
    mime_type: PAnsiChar; // The MIME type of the picture, in printable ASCII characters 0x20-0x7E.
    description: PAnsiChar;  // The description of the picture, in UTF-8
    width: Cardinal;
    height: Cardinal;
    depth: Cardinal;  // The color depth of the picture in bits-per-pixel
    colors: Cardinal; // For indexed-color pictures (e.g., GIF), the number of colors used, or 0
    data_length: Cardinal;
    data: Pointer;
    format: TOP_PIC_FORMAT; // The format of the picture data, if known. OP_PIC_FORMAT_UNKNOWN..OP_PIC_FORMAT_GIF
  end;

var

 op_fopen: function(out cb: TOpusFileCallbacks; path: PAnsiChar; mode: PAnsiChar): TOpusStream;

 op_freopen: function(out cb: TOpusFileCallbacks; path: PAnsiChar; mode: PAnsiChar; stream: TOpusStream): TOpusStream;
 op_mem_stream_create: function(out cb: TOpusFileCallbacks; const data; size: size_t): TOpusStream;

 opus_head_parse: function(head: TOpusHead; const data; len: size_t): Integer;
 opus_granule_sample: function(head: TOpusHead; gp: Int64): Int64;
 opus_tags_parse: function(out tags: TOpusTags; const data; len: size_t): Integer;
 opus_tags_copy: function(var dst: TOpusTags; const src: TOpusTags): Integer;
 opus_tags_init: procedure(var tags: TOpusTags);
 opus_tags_add: function(var dst: TOpusTags; tag, value: PAnsiChar): Integer;
 opus_tags_add_comment: function(var dst: TOpusTags; comment: PAnsiChar): Integer;
 opus_tags_set_binary_suffix: function(var tags: TOpusTags; const data; len: Integer): Integer;
 opus_tags_query: function(const tags: TOpusTags; tag: PAnsiChar; count: Integer): Integer;
 opus_tags_query_count: function(const tags: TOpusTags; tag: PAnsiChar): Integer;
 opus_tags_get_binary_suffix: function(const tags: TOpusTags; out len: Integer): Integer;
 opus_tags_get_album_gain: function(const tags: TOpusTags; out gain_q8: Integer): Integer;
 opus_tags_get_track_gain: function(const tags: TOpusTags; out gain_q8: Integer): Integer;
 opus_tags_clear: procedure(var tags: TOpusTags);
 opus_tagcompare: function(tag_name, comment: PAnsiChar): Integer;
 opus_tagncompare: function(tag_name: PAnsiChar; tag_len: Integer; comment: PAnsiChar): Integer;
 opus_picture_tag_parse: function(out pic: TOpusPictureTag; tag: PAnsiChar): Integer;
 opus_picture_tag_init: procedure(var pic: TOpusPictureTag);
 opus_picture_tag_clear: procedure(var pic: TOpusPictureTag);

 op_test: function(head: TOpusHead; const initial_data; initial_bytes: size_t): Integer;
 op_open_file: function(path: PAnsiChar; out error: Integer): TOggOpusFile;
 op_open_memory: function(const data; const _size: size_t; out error: Integer): TOggOpusFile;
 op_open_callbacks: function(const source; const cb: TOpusFileCallbacks;
  const initial_data; initial_bytes: size_t; out error: Integer): TOggOpusFile;
 op_test_file: function(path: PAnsiChar; out error: Integer): TOggOpusFile;
 op_test_memory: function(const _data; const size: size_t; out error: Integer): TOggOpusFile;
 op_test_callbacks: function(const source; const cb: TOpusFileCallbacks; const initial_data; initial_bytes: size_t;
  out error: Integer): TOggOpusFile;
 op_test_open: function(OpusFile: TOggOpusFile): Integer;
 op_free: function(OpusFile: TOggOpusFile): Integer;

 op_seekable: function(OpusFile: TOggOpusFile): Integer;
 op_link_count: function(OpusFile: TOggOpusFile): Integer;
 op_serialno: function(OpusFile: TOggOpusFile; li: Integer): Cardinal;
 op_channel_count: function(OpusFile: TOggOpusFile; li: Integer): Integer;
 op_raw_total: function(OpusFile: TOggOpusFile; li: Integer): Int64;
 op_pcm_total: function(OpusFile: TOggOpusFile; li: Integer): Int64;
 op_head: function(OpusFile: TOggOpusFile; li: Integer): TOpusHead;
 op_tags: function(OpusFile: TOggOpusFile; li: Integer): POpusTags;
 op_current_link: function(OpusFile: TOggOpusFile): Integer;
 op_bitrate: function(OpusFile: TOggOpusFile; li: Integer): Integer;
 op_bitrate_instant: function(OpusFile: TOggOpusFile): Integer;
 op_raw_tell: function(OpusFile: TOggOpusFile): Int64;
 op_pcm_tell: function(OpusFile: TOggOpusFile): Int64;

 op_raw_seek: function(OpusFile: TOggOpusFile; byte_offset: Int64): Integer;
 op_pcm_seek: function(OpusFile: TOggOpusFile; pcm_offset: Int64): Integer;

 op_set_gain_offset: function(OpusFile: TOggOpusFile; gain_type: Integer; gain_offset_q8: Integer): Integer;
 op_set_dither_enabled: procedure(OpusFile: TOggOpusFile; enabled: Integer);
 
 op_read: function(OpusFile: TOggOpusFile; pcm : pcint; SampleCount: Integer; li: pcint): Integer;
 op_read_float: function(OpusFile: TOggOpusFile; pcm : pcfloat; SampleCount: Integer; li: pcint): Integer;
 op_read_stereo: function(OpusFile: TOggOpusFile; pcm : pcint; SampleCount: Integer): Integer;
 op_read_float_stereo: function(OpusFile: TOggOpusFile; pcm : pcfloat; SampleCount: Integer): Integer;
 of_Handle:TLibHandle=dynlibs.NilHandle; // this will hold our handle for the lib; it functions nicely as a mutli-lib prevention unit as well...

 ReferenceCounter : cardinal = 0;  // Reference counter
         
 function of_IsLoaded : boolean; inline; 

 Function of_Load(const libfilename:string) :boolean; // load the lib
 
 Procedure of_Unload;            

implementation

 function of_IsLoaded: boolean;
begin
 Result := (of_Handle <> dynlibs.NilHandle);
end;

Procedure of_Unload;
begin
// < Reference counting
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >
  if of_IsLoaded then
  begin
    DynLibs.UnloadLibrary(of_Handle);
    of_Handle:=DynLibs.NilHandle;
  end;
end;

Function of_Load (const libfilename:string) :boolean;
begin
  Result := False;
  if of_Handle<>0 then 
begin
 Inc(ReferenceCounter);
 result:=true {is it already there ?}
end  else 
begin {go & load the library}
    if Length(libfilename) = 0 then exit;
    of_Handle:=DynLibs.SafeLoadLibrary(libfilename); // obtain the handle we want
  	if of_Handle <> DynLibs.NilHandle then
begin {now we tie the functions to the VARs from above}
Pointer(op_fopen):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_fopen'));
Pointer(op_freopen):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_freopen'));
Pointer(op_mem_stream_create):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_mem_stream_create'));
Pointer(opus_head_parse):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_head_parse'));
Pointer(opus_granule_sample):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_granule_sample'));
Pointer(opus_tags_parse):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_parse'));
Pointer(opus_tags_copy):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_copy'));
Pointer(opus_tags_init):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_init'));
Pointer(opus_tags_add):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_add'));
Pointer(opus_tags_add_comment):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_add_comment'));
Pointer(opus_tags_set_binary_suffix):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_set_binary_suffix'));
Pointer(opus_tags_query):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_query'));
Pointer(opus_tags_query_count):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_query_count'));
Pointer(opus_tags_get_binary_suffix):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_get_binary_suffix'));
Pointer(opus_tags_get_album_gain):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_get_album_gain'));
Pointer(opus_tags_get_track_gain):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_get_track_gain'));
Pointer(opus_tags_clear):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tags_clear'));
Pointer(opus_tagcompare):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tagcompare'));
Pointer(opus_tagncompare):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_tagncompare'));
Pointer(opus_picture_tag_parse):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_picture_tag_parse'));
Pointer(opus_picture_tag_init):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_picture_tag_init'));
Pointer(opus_picture_tag_clear):=DynLibs.GetProcedureAddress(OF_Handle,PChar('opus_picture_tag_clear'));
Pointer(op_test):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_test'));
Pointer(op_free):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_free'));
Pointer(op_open_file):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_open_file'));
Pointer(op_open_memory):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_open_memory'));
Pointer(op_open_callbacks):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_open_callbacks'));
Pointer(op_test_file):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_test_file'));
Pointer(op_test_memory):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_test_memory'));
Pointer(op_test_callbacks):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_test_callbacks'));
Pointer(op_test_open):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_test_open'));
Pointer(op_seekable):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_seekable'));
Pointer(op_link_count):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_link_count'));
Pointer(op_serialno):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_serialno'));
Pointer(op_channel_count):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_channel_count'));
Pointer(op_raw_total):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_raw_total'));
Pointer(op_pcm_total):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_pcm_total'));
Pointer(op_head):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_head'));
Pointer(op_tags):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_tags'));
Pointer(op_current_link):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_current_link'));
Pointer(op_bitrate):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_bitrate'));
Pointer(op_bitrate_instant):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_bitrate_instant'));
Pointer(op_raw_tell):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_raw_tell'));
Pointer(op_raw_seek):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_raw_seek'));
Pointer(op_pcm_seek):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_pcm_seek'));
Pointer(op_set_gain_offset):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_set_gain_offset'));
Pointer(op_set_dither_enabled):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_set_dither_enabled'));
Pointer(op_read):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_read'));
Pointer(op_read_float):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_read_float'));
Pointer(op_read_stereo):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_read_stereo'));
Pointer(op_read_float_stereo):=DynLibs.GetProcedureAddress(OF_Handle,PChar('op_read_float_stereo'));

end;
   Result := of_IsLoaded;
   ReferenceCounter:=1;   
end;

end;

function OpusReadCB(stream: Pointer; var buffer; nbytes: Integer): Integer; cdecl;
begin
  if nbytes<>0
  then
    result := FileRead(THandle(stream^), Buffer, nbytes)
  else
    result := 0;
end;

function OpusSeekCB(stream: Pointer; offset: Int64; whence: Integer): Integer; cdecl;
var
  Seek_Result: Int64;
begin
  Seek_Result := FileSeek(THandle(stream^), offset, whence);
  if Seek_Result=-1
  then
    Result := -1
  else
    Result := 0;
end;

function OpusTellCB(stream: Pointer): Int64; cdecl;
begin
  Result := FileSeek(THandle(stream^), 0, 1);
end;

function OpusCloseCB(stream: Pointer): Integer; cdecl;
begin
  FileClose(THandle(stream^));
  Result := 0;
end;

end.
