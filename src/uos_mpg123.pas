{This unit is part of United Openlibraries of Sound (uos)}

{ This is the dynamical loader for mpg123 library with reference counting.
  Load the library with mp_load() and release with mp_unload().
  License : modified LGPL.
  Fred van Stappen  fiens@hotmail.com }

unit uos_mpg123;

interface

{$DEFINE newversion}   // uncomment for mpg123 new version
{$mode objfpc}{$H+}

uses
 ctypes, 
 classes, dynlibs;
 
const
libmp=
 {$IFDEF unix}
  {$IFDEF darwin}
 'libmpg123.0.dylib';
  {$ELSE}
 'libmpg123.so.0';
  {$ENDIF}    
  {$ELSE}
 'mpg123.dll';
 {$ENDIF} 
  
const
  SEEK_SET = 0;       //* seek relative to beginning of file */
  SEEK_CUR = 1;       //* seek relative to current file position */
  SEEK_END = 2;       //* seek relative to end of file */
  SEEK_DATA = 3;       //* seek to the next data */
  SEEK_HOLE = 4;       //* seek to the next hole */
  SEEK_MAX = SEEK_HOLE;
  
 
type 
 {$IF Defined(MSWINDOWS)} 
  off_t = int64;
  {$ELSE}  
  off_t    = clonglong;  
 {$ENDIF} 
  
  Puos_count_t = ^Tuos_count_t;
  Tuos_count_t = off_t;     
  
  PMemoryStream = ^TMemoryStream;        

  Tmpg123_handle = Pointer;
  Tmpg123_init = function(): integer; cdecl;
  Tmpg123_exit = procedure; cdecl;
  Tmpg123_new = function(const decoder: PChar;
    var error: integer): Tmpg123_handle; cdecl;
  Tmpg123_delete = procedure(mh: Tmpg123_handle); cdecl;

const
  MPG123_VERBOSE = 0;  // set verbosity value for enabling messages
  // to stderr, >= 0 makes sense (integer)
  MPG123_FLAGS = 1;
  // set all flags, p.ex val = MPG123_GAPLESS|MPG123_MONO_MIX (integer)
  MPG123_ADD_FLAGS = 2;  // add some flags (integer)
  MPG123_FORCE_RATE = 3;
  // when value > 0, force output rate to that value (integer)
  MPG123_DOWN_SAMPLE = 4;  // 0=native rate, 1=half rate, 2=quarter rate (integer)
  MPG123_RVA = 5;  // one of the RVA choices above (integer)
  MPG123_DOWNSPEED = 6;  // play a frame N times (integer)
  MPG123_UPSPEED = 7;  // play every Nth frame (integer)
  MPG123_START_FRAME = 8;  // start with this frame (skip frames before that, integer)
  MPG123_DECODE_FRAMES = 9;  // decode only this number of frames (integer)
  MPG123_ICY_INTERVAL = 10;
  // stream contains ICY metadata with this interval (integer)
  MPG123_OUTSCALE = 11;  // the scale for output samples (amplitude - integer
  // or float according to mpg123 output format, normally integer)
  MPG123_TIMEOUT = 12;  // timeout for reading from a stream (not supported
  // on win32, integer)
  MPG123_REMOVE_FLAGS = 13;  // remove some flags (inverse of MPG123_ADD_FLAGS, integer)
  MPG123_RESYNC_LIMIT = 14;  // Try resync on frame parsing for that many bytes
  // or until end of stream (<0 ... integer).
  MPG123_INDEX_SIZE = 15;  // Set the frame index size (if supported).
  // Values <0 mean that the index is allowed to grow
  // dynamically in these steps (in positive direction,
  // of course) -- Use this when you really want a
  // full index with every individual frame.
  MPG123_PREFRAMES = 16;

{** mpg123_param_flags - Flag bits for MPG123_FLAGS, use the usual binary or to combine. **}
  MPG123_FORCE_MONO = $7;   //     0111 Force some mono mode: This is a test bitmask
  //          for seeing if any mono forcing is active.
  MPG123_MONO_LEFT = $1;   //     0001 Force playback of left channel only.
  MPG123_MONO_RIGHT = $2;   //     0010 Force playback of right channel only.
  MPG123_MONO_MIX = $4;   //     0100 Force playback of mixed mono.
  MPG123_FORCE_STEREO = $8;   //     1000 Force stereo output.
  MPG123_FORCE_8BIT = $10;  // 00010000 Force 8bit formats.
  MPG123_QUIET = $20;
  // 00100000 Suppress any printouts (overrules verbose).                    *)
  MPG123_GAPLESS = $40;  // 01000000 Enable gapless decoding (default on
  // if libmpg123 has support).
  MPG123_NO_RESYNC = $80;
  // 10000000 Disable resync stream after error.                             *)
  MPG123_SEEKBUFFER = $100; // 000100000000 Enable small buffer on non-seekable
  // streams to allow some peek-ahead (for better MPEG sync).
  MPG123_FUZZY = $200; // 001000000000 Enable fuzzy seeks (guessing byte
  // offsets or using approximate seek points from Xing TOC)
  (* 1.72 *)
  MPG123_FORCE_FLOAT = $400; // 010000000000 Force floating point output
  // (32 or 64 bits depends on mpg123 internal precision).
  MPG123_PLAIN_ID3TEXT = $800;
  MPG123_IGNORE_STREAMLENGTH = $1000;
  
   {$IF DEFINED(newversion)}
      MPG123_IGNORE_INFOFRAME = $4000;
        MPG123_AUTO_RESAMPLE = $8000;
        MPG123_PICTURE = $10000;
        MPG123_NO_PEEK_END = $20000;
        MPG123_SKIP_ID3V2 = $2000;
        MPG123_FORCE_SEEKABLE = $40000;
    {$endif}

{** mpg123_param_rva - Choices for MPG123_RVA **}
  MPG123_RVA_OFF = 0;  // RVA disabled (default).
  MPG123_RVA_MIX = 1;  // Use mix/track/radio gain.
  MPG123_RVA_ALBUM = 2;  // Use album/audiophile gain
  MPG123_RVA_MAX = MPG123_RVA_ALBUM; // The maximum RVA code, may increase in future.

type
  Tmpg123_param = function(mh: Tmpg123_handle; mpg123_parms_type: integer;
    Value: longint; fvalue: double): integer; cdecl;
  Tmpg123_getparam = function(mh: Tmpg123_handle; mpg123_parms_type: integer;
    var val: longint; var fval: double): integer; cdecl;

{** mpg123_feature_set - ??? **}
const
  MPG123_FEATURE_ABI_UTF8OPEN = 0;
  MPG123_FEATURE_OUTPUT_8BIT = 1;
  MPG123_FEATURE_OUTPUT_16BIT = 2;
  MPG123_FEATURE_OUTPUT_32BIT = 3;
  MPG123_FEATURE_INDEX = 4;
  MPG123_FEATURE_PARSE_ID3V2 = 5;
  MPG123_FEATURE_DECODE_LAYER1 = 6;
  MPG123_FEATURE_DECODE_LAYER2 = 7;
  MPG123_FEATURE_DECODE_LAYER3 = 8;
  MPG123_FEATURE_DECODE_ACCURATE = 9;
  MPG123_FEATURE_DECODE_DOWNSAMPLE = 10;
  MPG123_FEATURE_DECODE_NTOM = 11;
  MPG123_FEATURE_PARSE_ICY = 12;
  MPG123_FEATURE_TIMEOUT_READ = 13;

type
  Tmpg123_feature = function(const feature_key: shortint): cardinal; cdecl;

const
  MPG123_DONE = -12;  // Message: Track ended.
  MPG123_NEW_FORMAT = -11;
  // Message: Output format will be different on next call.
  MPG123_NEED_MORE = -10;  // Message: For feed reader: "Feed me more!"
  MPG123_ERR = -1;  // <Generic Error>
  MPG123_OK = 0;  // <Success>
  MPG123_BAD_OUTFORMAT = 1;  // Unable to set up output format!
  MPG123_BAD_CHANNEL = 2;  // Invalid channel number specified.
  MPG123_BAD_RATE = 3;  // Invalid sample rate specified.
  MPG123_ERR_16TO8TABLE = 4;
  // Unable to allocate memory for 16 to 8 converter table!
  MPG123_BAD_PARAM = 5;  // Bad parameter id!
  MPG123_BAD_BUFFER = 6;
  // Bad buffer given -- invalid pointer or too small size.
  MPG123_OUT_OF_MEM = 7;  // Out of memory -- some malloc() failed.
  MPG123_NOT_INITIALIZED = 8;  // You didn't initialize the library!
  MPG123_BAD_DECODER = 9;  // Invalid decoder choice.
  MPG123_BAD_HANDLE = 10;  // Invalid mpg123 handle.
  MPG123_NO_BUFFERS = 11;  // Unable to initialize frame buffers (out of memory?).
  MPG123_BAD_RVA = 12;  // Invalid RVA mode.
  MPG123_NO_GAPLESS = 13;  // This build doesn't support gapless decoding.
  MPG123_NO_SPACE = 14;  // Not enough buffer space.
  MPG123_BAD_TYPES = 15;  // Incompatible numeric data types.
  MPG123_BAD_BAND = 16;  // Bad equalizer band.
  MPG123_ERR_NULL = 17;
  // Null pointer given where valid storage address needed.
  MPG123_ERR_READER = 18;  // Error reading the stream.
  MPG123_NO_SEEK_FROM_END = 19;  // Cannot seek from end (end is not known).
  MPG123_BAD_WHENCE = 20;  // Invalid 'whence' for seek function.
  MPG123_NO_TIMEOUT = 21;  // Build does not support stream timeouts.
  MPG123_BAD_FILE = 22;  // File access error.
  MPG123_NO_SEEK = 23;  // Seek not supported by stream.
  MPG123_NO_READER = 24;  // No stream opened.
  MPG123_BAD_PARS = 25;  // Bad parameter handle.
  MPG123_BAD_INDEX_PAR = 26;  // Bad parameters to mpg123_index()
  MPG123_OUT_OF_SYNC = 27;  // Lost track in bytestream and did not try to resync.
  MPG123_RESYNC_FAIL = 28;  // Resync failed to find valid MPEG data.
  MPG123_NO_8BIT = 29;  // No 8bit encoding possible.
  MPG123_BAD_ALIGN = 30;  // Stack aligmnent error
  MPG123_NULL_BUFFER = 31;  // NULL input buffer with non-zero size...
  MPG123_NO_RELSEEK = 32;  // Relative seek not possible (screwed up file offset)
  MPG123_NULL_POINTER = 33;
  // You gave a null pointer somewhere where you shouldn't have.
  MPG123_BAD_KEY = 34;  // Bad key value given.
  MPG123_NO_INDEX = 35;  // No frame index in this build.
  MPG123_INDEX_FAIL = 36;  // Something with frame index went wrong.
  (* 1.72 *)
  MPG123_BAD_DECODER_SETUP = 37;  // Something prevents a proper decoder setup
  MPG123_MISSING_FEATURE = 38;  // This feature has not been built into libmpg123.
  MPG123_BAD_VALUE = 39;
  MPG123_LSEEK_FAILED = 40;
  MPG123_BAD_CUSTOM_IO = 41;
  MPG123_LFS_OVERFLOW = 42;

type
  Tmpg123_plain_strerror = function(errcode: integer): PChar; cdecl;
  Tmpg123_strerror = function(mh: Tmpg123_handle): PChar; cdecl;
  Tmpg123_errcode = function(mh: Tmpg123_handle): integer; cdecl;
  Tmpg123_decoders = function(): PPChar; cdecl;
  Tmpg123_supported_decoders = function(): PPchar; cdecl;
  Tmpg123_decoder = function(mh: Tmpg123_handle;
    var decoder_name: PChar): integer; cdecl;
  Tmpg123_current_decoder = function(mh: Tmpg123_handle): PChar; cdecl;

const  // mpg123_enc_enum
  MPG123_ENC_8 = $00f;  (**< 0000 0000 1111 Some 8 bit  integer encoding. *)
  MPG123_ENC_16 = $040;  (**< 0000 0100 0000 Some 16 bit integer encoding. *)
  MPG123_ENC_32 = $100;  (**< 0001 0000 0000 Some 32 bit integer encoding. *)
  MPG123_ENC_SIGNED = $080;  (**< 0000 1000 0000 Some signed integer encoding. *)
  MPG123_ENC_FLOAT = $800;  (**< 1110 0000 0000 Some float encoding. *)
  MPG123_ENC_SIGNED_16 = (MPG123_ENC_16 or MPG123_ENC_SIGNED or $10);
  (**< 0000 1101 0000 signed 16 bit *)
  MPG123_ENC_UNSIGNED_16 = (MPG123_ENC_16 or $20);
  (**< 0000 0110 0000 unsigned 16 bit*)
  MPG123_ENC_UNSIGNED_8 = $01;
  (**< 0000 0000 0001 unsigned 8 bit*)
  MPG123_ENC_SIGNED_8 = (MPG123_ENC_SIGNED or $02);
  (**< 0000 1000 0010 signed 8 bit*)
  MPG123_ENC_ULAW_8 = $04;
  (**< 0000 0000 0100 ulaw 8 bit*)
  MPG123_ENC_ALAW_8 = $08;
  (**< 0000 0000 1000 alaw 8 bit *)
  MPG123_ENC_SIGNED_32 = MPG123_ENC_32 or MPG123_ENC_SIGNED or $1000;
  (**< 0001 1001 0000 signed 32 bit *)
  MPG123_ENC_UNSIGNED_32 = MPG123_ENC_32 or $2000;
  (**< 0001 0010 0000 unsigned 32 bit *)
  MPG123_ENC_FLOAT_32 = $200;
  (**< 0010 0000 0000 32bit float *)
  MPG123_ENC_FLOAT_64 = $400;
  (**< 0100 0000 0000 64bit float *)
  MPG123_ENC_ANY = MPG123_ENC_SIGNED_16 or MPG123_ENC_UNSIGNED_16 or
    MPG123_ENC_UNSIGNED_8 or MPG123_ENC_SIGNED_8 or
    MPG123_ENC_ULAW_8 or MPG123_ENC_ALAW_8 or
    MPG123_ENC_SIGNED_32 or MPG123_ENC_UNSIGNED_32 or
    MPG123_ENC_FLOAT_32 or MPG123_ENC_FLOAT_64; (**< any encoding *)

  MPG123_LEFT = $1;
  MPG123_RIGHT = $2;
  MPG123_LR = $3;

type
{$if defined(cpu64)}
  cuint64 = qword;
  size_t = cuint64;
{$else}
  cuint32 = longword;
  size_t = cuint32;
{$endif}

  psize_t = ^size_t;
  coff_t = size_t;  //Int64;
  PLong = Pointer;
  pplong = array of PLong;
  PInteger = Pointer;
  PPInteger = array of PInteger;

  Tmpg123_rates = procedure(var list: pplong; var number: size_t); cdecl;
  Tmpg123_encodings = procedure(var list: ppinteger; var number: size_t); cdecl;
  Tmpg123_encsize = function(encoding: integer): integer; cdecl;
  Tmpg123_format_none = function(mh: Tmpg123_handle): integer; cdecl;
  Tmpg123_format_all = function(mh: Tmpg123_handle): integer; cdecl;
  Tmpg123_format = function(mh: Tmpg123_handle; rate: cardinal;
    channels: integer; encodings: integer): integer; cdecl;
  Tmpg123_format_support = function(mh: Tmpg123_handle; rate: cardinal;
    encoding: integer): integer; cdecl;
  Tmpg123_getformat = function(mh: Tmpg123_handle; var rate: cardinal;
    var channels, encoding: integer): integer; cdecl;
  Tmpg123_open = function(mh: Tmpg123_handle; path: PChar): integer; cdecl;
  Tmpg123_open_fd = function(mh: Tmpg123_handle; fd: integer): integer; cdecl;

{$IF DEFINED(newversion)}
   Tmpg123_open_handle = function(mh: Tmpg123_handle; pha: pointer): integer; cdecl;
   {* Use an opaque handle as bitstream input. This works only with the
     *  replaced I/O from mpg123_replace_reader_handle()!
     *  mpg123_close() will call the cleanup callback for your handle (if you gave one).
     *  \return MPG123_OK on success
      }
  Tmpg123_replace_reader_handle = function(mh : Tmpg123_handle;   r_read : pointer;
    r_lseek : pointer ; cleanup :  pointer): integer; cdecl;
   {* Replace I/O functions with your own ones operating on some kind of handle instead of integer descriptors.
     *  The handle is a void pointer, so you can pass any data you want...
     *  mpg123_open_handle() is the call you make to use the I/O defined here.
     *  There is no fallback to internal read/seek here.
     *  Note: As it would be troublesome to mess with this while having a file open,
     *  this mpg123_close() is implied here.
     *  \param r_read The callback for reading (behaviour like posix read).
     *  \param r_lseek The callback for seeking (like posix lseek).
     *  \param cleanup A callback to clean up an I/O handle on mpg123_close, can be NULL for none (you take care of cleaning your handles).  }

  Tmpg123_replace_reader = function(mh : Tmpg123_handle;   r_read : pointer;
    r_lseek : pointer): integer; cdecl;
  Tmpg123_getformat2 = function(mh: Tmpg123_handle; var rate: cardinal;
    var channels, encoding: integer; var clear_flag: integer): integer; cdecl;
  Tmpg123_framelength = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_framepos = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_spf = function(mh: Tmpg123_handle): integer; cdecl;
  Tmpg123_meta_free = procedure(mh: Tmpg123_handle); cdecl;
  Tmpg123_set_index = function(mh: Tmpg123_handle; var offsets: PPInteger;
    step: coff_t; fill: size_t): integer;

{$if not(defined(cpu64) and defined(unix))}
  Tmpg123_open_32 = function(mh: Tmpg123_handle; path: PChar): integer; cdecl;
  Tmpg123_open_fd_32 = function(mh: Tmpg123_handle; fd: integer): integer; cdecl;
  Tmpg123_open_handle_32 = function(mh: Tmpg123_handle; pha: pointer): integer; cdecl;
  Tmpg123_decode_frame_32 = function(mh: Tmpg123_handle; var num: coff_t;
    audio: PPChar; var bytes: size_t): integer; cdecl;
  Tmpg123_framebyframe_decode_32 = function(mh: Tmpg123_handle; var num: coff_t;
    audio: PPChar; var bytes: size_t): integer; cdecl; 
  Tmpg123_framepos_32 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_tell_32 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_tellframe_32 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_seek_32 = function(mh: Tmpg123_handle; sampleoff: coff_t;
    whence: integer): integer; cdecl;
  Tmpg123_feedseek_32 = function(mh: Tmpg123_handle; sampleoff: coff_t;
    whence: integer; var input_offset: coff_t): coff_t;  cdecl;
  Tmpg123_seek_frame_32 = function(mh: Tmpg123_handle; frameoff: coff_t;
    whence: integer): coff_t; cdecl;
  Tmpg123_timeframe_32 = function(mh: Tmpg123_handle; sec: double): coff_t; cdecl;
  Tmpg123_index_32 = function(mh: Tmpg123_handle; var offsets: PPInteger;
    var step: coff_t; var fill: size_t): integer; 
  Tmpg123_set_index_32 = function(mh: Tmpg123_handle; var offsets: PPInteger;
    step: coff_t; fill: size_t): integer;
  Tmpg123_position_32 = function(mh: Tmpg123_handle; frame_offset: coff_t;
    buffered_bytes: coff_t;
    var current_frame: coff_t; var frames_left: coff_t;
    var current_seconds: double;
    var seconds_left: double): integer; cdecl;
  Tmpg123_framelength_32 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_length_32 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_set_filesize_32 = function(mh: Tmpg123_handle; size: coff_t): integer; cdecl;
  Tmpg123_replace_reader_32 = function(mh : Tmpg123_handle;   r_read : pointer;
    r_lseek : pointer): integer; cdecl;
  Tmpg123_replace_reader_handle_32 = function(mh : Tmpg123_handle;   r_read : pointer;
    r_lseek : pointer ; cleanup :  pointer): integer; cdecl;
{$endif}
 

  Tmpg123_open_64 = function(mh: Tmpg123_handle; path: PChar): integer; cdecl;
  Tmpg123_open_fd_64 = function(mh: Tmpg123_handle; fd: integer): integer; cdecl;
  Tmpg123_open_handle_64 = function(mh: Tmpg123_handle; pha: pointer): integer; cdecl;
  Tmpg123_decode_frame_64 = function(mh: Tmpg123_handle; var num: coff_t;
    audio: PPChar; var bytes: size_t): integer; cdecl;
  Tmpg123_framebyframe_decode_64 = function(mh: Tmpg123_handle; var num: coff_t;
    audio: PPChar; var bytes: size_t): integer; cdecl; 
  Tmpg123_framepos_64 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_tell_64 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_tellframe_64 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_seek_64 = function(mh: Tmpg123_handle; sampleoff: coff_t;
    whence: integer): integer; cdecl;
  Tmpg123_feedseek_64 = function(mh: Tmpg123_handle; sampleoff: coff_t;
    whence: integer; var input_offset: coff_t): coff_t;  cdecl;
  Tmpg123_seek_frame_64 = function(mh: Tmpg123_handle; frameoff: coff_t;
    whence: integer): coff_t; cdecl;
  Tmpg123_timeframe_64 = function(mh: Tmpg123_handle; sec: double): coff_t; cdecl;
  Tmpg123_index_64 = function(mh: Tmpg123_handle; var offsets: PPInteger;
    var step: coff_t; var fill: size_t): integer;
  Tmpg123_set_index_64 = function(mh: Tmpg123_handle; var offsets: PPInteger;
    step: coff_t; fill: size_t): integer;
  Tmpg123_position_64 = function(mh: Tmpg123_handle; frame_offset: coff_t;
    buffered_bytes: coff_t;
    var current_frame: coff_t; var frames_left: coff_t;
    var current_seconds: double;
    var seconds_left: double): integer; cdecl;
  Tmpg123_framelength_64 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_length_64 = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_set_filesize_64 = function(mh: Tmpg123_handle; size: coff_t): integer; cdecl;
  Tmpg123_replace_reader_64 = function(mh : Tmpg123_handle;   r_read : pointer;
    r_lseek : pointer): integer; cdecl;
  Tmpg123_replace_reader_handle_64 = function(mh : Tmpg123_handle;   r_read : pointer;
    r_lseek : pointer ; cleanup :  pointer): integer; cdecl;
{$endif}

 Tmpg123_open_feed = function(mh: Tmpg123_handle): integer; cdecl;
 Tmpg123_close = function(mh: Tmpg123_handle): integer; cdecl;
 Tmpg123_read = function(mh: Tmpg123_handle; outmemory: pcfloat;
    outmemsize: size_t; var done: size_t): integer; cdecl;
 Tmpg123_feed = function(mh: Tmpg123_handle; inbuf: Pointer;
    size: size_t): integer; cdecl;
 Tmpg123_decode = function(mh: Tmpg123_handle; inmemory: Pointer;
    inmemsize: size_t; outmemory: Pointer;
    outmemsize: size_t; var done: size_t): integer; cdecl;
  Tmpg123_decode_frame = function(mh: Tmpg123_handle; var num: coff_t;
    audio: PPChar; var bytes: size_t): integer; cdecl;

{$IF DEFINED(newversion)}
  Tmpg123_framebyframe_decode = function(mh: Tmpg123_handle; var num: coff_t;
    audio: PPChar; var bytes: size_t): integer; cdecl; 
 Tmpg123_framebyframe_next = function(mh: Tmpg123_handle): integer; cdecl; 
 Tmpg123_framedata = function(mh: Tmpg123_handle; var header: longint;
    bodydata: PPChar; var bodybytes: size_t): integer; cdecl;  
{$endif}

 Tmpg123_tell = function(mh: Tmpg123_handle): coff_t; cdecl;
 Tmpg123_tellframe = function(mh: Tmpg123_handle): coff_t; cdecl;
 Tmpg123_tell_stream = function(mh: Tmpg123_handle): coff_t; cdecl;
 Tmpg123_seek = function(mh: Tmpg123_handle; sampleoff: coff_t;
    whence: integer): integer; cdecl;
 Tmpg123_feedseek = function(mh: Tmpg123_handle; sampleoff: coff_t;
    whence: integer; var input_offset: coff_t): coff_t;
    cdecl;
 Tmpg123_seek_frame = function(mh: Tmpg123_handle; frameoff: coff_t;
    whence: integer): coff_t; cdecl;
 Tmpg123_timeframe = function(mh: Tmpg123_handle; sec: double): coff_t; cdecl;
 Tmpg123_index = function(mh: Tmpg123_handle; var offsets: PPInteger;
    var step: coff_t; var fill: size_t): integer;
 Tmpg123_position = function(mh: Tmpg123_handle; frame_offset: coff_t;
    buffered_bytes: coff_t;
    var current_frame: coff_t; var frames_left: coff_t;
    var current_seconds: double;
    var seconds_left: double): integer; cdecl;
 Tmpg123_eq = function(mh: Tmpg123_handle; mpg123_channels_channel: integer;
    band: integer; val: double): integer; cdecl;
 Tmpg123_geteq = function(mh: Tmpg123_handle; mpg123_channels_channel: integer;
    band: integer): double; cdecl;
 Tmpg123_reset_eq = function(mh: Tmpg123_handle): integer; cdecl;
 Tmpg123_volume = function(mh: Tmpg123_handle; vol: double): integer; cdecl;
 Tmpg123_volume_change = function(mh: Tmpg123_handle; change: double): integer; cdecl;
 Tmpg123_getvolume = function(mh: Tmpg123_handle; var base: double;
    var really: double; var rva_db: double): integer;
    cdecl;

const
  MPG123_CBR = 0;  (**< Constant Bitrate Mode (default) *)
  MPG123_VBR = 1;  (**< Variable Bitrate Mode *)
  MPG123_ABR = 2;  (**< Average Bitrate Mode *)

(** enum mpg123_version - Enumeration of the MPEG Versions *)
  MPG123_1_0 = 0;  (**< MPEG Version 1.0 *)
  MPG123_2_0 = 1;  (**< MPEG Version 2.0 *)
  MPG123_2_5 = 2;  (**< MPEG Version 2.5 *)

(** enum mpg123_mode - Enumeration of the MPEG Audio mode.
 *  Only the mono mode has 1 channel, the others have 2 channels. *)
  MPG123_M_STEREO = 0;  (**< Standard Stereo. *)
  MPG123_M_JOINT = 1;  (**< Joint Stereo. *)
  MPG123_M_DUAL = 2;  (**< Dual Channel. *)
  MPG123_M_MONO = 3;  (**< Single Channel. *)

  (** enum mpg123_flags - Enumeration of the MPEG Audio flag bits *)
  MPG123_CRC = $1;  (**< The bitstream is error protected using 16-bit CRC. *)
  MPG123_COPYRIGHT = $2;  (**< The bitstream is copyrighted. *)
  MPG123_PRIVATE = $4;  (**< The private bit has been set. *)
  MPG123_ORIGINAL = $8;  (**< The bitstream is an original, not a copy. *)

(** Data structure for storing information about a frame of MPEG Audio *)
type
   pmpg123_frameinfo = ^Tmpg123_frameinfo;
    Tmpg123_frameinfo = record
    mpg123_version_version: longword;  (**< The MPEG version (1.0/2.0/2.5). *)
    layer: integer;   (**< The MPEG Audio Layer (MP1/MP2/MP3). *)
    rate: longword;  (**< The sampling rate in Hz. *)
    mpg123_mode_mode: longint;
    (**< The audio mode (Mono, Stereo, Joint-stero, Dual Channel). *)
    mode_ext: integer;   (**< The mode extension bit flag. *)
    framesize: integer;   (**< The size of the frame (in bytes). *)
    mpg123_flags_flags: longword;  (**< MPEG Audio flag bits. *)
    emphasis: integer;   (**< The emphasis type. *)
    bitrate: integer;   (**< Bitrate of the frame (kbps). *)
    abr_rate: integer;   (**< The target average bitrate. *)
    mpg123_vbr_vbr: longword;  (**< The VBR mode. *)
  end;

  Tmpg123_info = function(mh: Tmpg123_handle;
    var mi: Tmpg123_frameinfo): integer; cdecl;
  Tmpg123_safe_buffer = function(): size_t; cdecl;
  Tmpg123_scan = function(mh: Tmpg123_handle): integer; cdecl;
  Tmpg123_length = function(mh: Tmpg123_handle): coff_t; cdecl;
  Tmpg123_set_filesize = function(mh: Tmpg123_handle; size: coff_t): integer; cdecl;
  Tmpg123_tpf = function(mh: Tmpg123_handle): double; cdecl;
  Tmpg123_clip = function(mh: Tmpg123_handle): longint; cdecl;

const
  MPG123_ACCURATE = 1;
(**< Query if positons are currently accurate (integer value, 0 if false, 1 if true) *)

type
  Tmpg123_getstate = function(mh: Tmpg123_handle; mpg123_state_key: integer;
    var val: longint; var fval: double): integer; cdecl;
  Pmpg123_string = ^Tmpg123_string;

  Tmpg123_string = record
    p: PChar;   (**< pointer to the string data *)
    size: size_t;  (**< raw number of bytes allocated *)
    fill: size_t;
    (**< number of used bytes (including closing zero byte) *)
  end;

  Tmpg123_init_string = procedure(psb: Pmpg123_string); cdecl;
  Tmpg123_free_string = procedure(psb: Pmpg123_string); cdecl;
  Tmpg123_resize_string = function(psb: Pmpg123_string; news: size_t): integer; cdecl;
  Tmpg123_grow_string = function(psb: Pmpg123_string; news: size_t): integer; cdecl;
  Tmpg123_copy_string = function(strfrom, strto: Pmpg123_string): integer; cdecl;
  Tmpg123_add_string = function(psb: Pmpg123_string; stuff: PChar): integer; cdecl;
  Tmpg123_add_substring = function(psb: Pmpg123_string; stuff: PChar;
    strfrom, Count: size_t): integer; cdecl;
  Tmpg123_set_string = function(psb: Pmpg123_string; stuff: PChar): integer; cdecl;
  Tmpg123_set_substring = function(psb: Pmpg123_string; stuff: PChar;
    strfrom, Count: size_t): integer; cdecl;
  Tmpg123_strlen = function(psb: Pmpg123_string; utf8: integer): size_t;

{$IF DEFINED(newversion)}
  Tmpg123_chomp_string = function(psb: Pmpg123_string): integer;
{$endif}

const
  mpg123_text_unknown = 0;
  mpg123_text_utf8 = 1;
  mpg123_text_latin1 = 2;
  mpg123_text_icy = 3;
  mpg123_text_cp1252 = 4;
  mpg123_text_utf16 = 5;
  mpg123_text_utf16bom = 6;
  mpg123_text_utf16be = 7;
  mpg123_text_max = 7;
  mpg123_id3_latin1 = 0;
  mpg123_id3_utf16bom = 1;
  mpg123_id3_utf16be = 2;
  mpg123_id3_utf8 = 3;
  mpg123_id3_enc_max = 3;

 type
  Tmpg123_enc_from_id3 = function(id3_enc_byte: byte): integer; cdecl;
  Tmpg123_store_utf8 = function(psb: Pmpg123_string; mpg123_text_encoding: integer;
    var Source: byte;
    source_size: size_t): integer; cdecl;
  Pmpg123_text = ^Tmpg123_text;

  Tmpg123_text = record
    lang: array[0..2] of char;
    (**< Three-letter language code (not terminated). *)
    id: array[0..3] of char;
    (**< The ID3v2 text field id, like TALB, TPE2, ... (4 characters, no string termination). *)
    description: Tmpg123_string; (**< Empty for the generic comment... *)
    Text: Tmpg123_string;       (**< ... *)
  end;

{$IF DEFINED(newversion)}
       {* The picture type values from ID3v2.  }
      mpg123_id3_pic_type =  Longint;
   const
        mpg123_id3_pic_other = 0;
        mpg123_id3_pic_icon = 1;
        mpg123_id3_pic_other_icon = 2;
        mpg123_id3_pic_front_cover = 3;
        mpg123_id3_pic_back_cover = 4;
        mpg123_id3_pic_leaflet = 5;
        mpg123_id3_pic_media = 6;
        mpg123_id3_pic_lead = 7;
        mpg123_id3_pic_artist = 8;
        mpg123_id3_pic_conductor = 9;
        mpg123_id3_pic_orchestra = 10;
        mpg123_id3_pic_composer = 11;
        mpg123_id3_pic_lyricist = 12;
        mpg123_id3_pic_location = 13;
        mpg123_id3_pic_recording = 14;
        mpg123_id3_pic_performance = 15;
        mpg123_id3_pic_video = 16;
        mpg123_id3_pic_fish = 17;
        mpg123_id3_pic_illustration = 18;
        mpg123_id3_pic_artist_logo = 19;
        mpg123_id3_pic_publisher_logo = 20;

     {* Sub data structure for ID3v2, for storing picture data including comment.
     *  This is for the ID3v2 APIC field. You should consult the ID3v2 specification
     *  for the use of the APIC field ("frames" in ID3v2 documentation, I use "fields"
     *  here to separate from MPEG frames).  }

    type
      PPmpg123_picture = ^Pmpg123_picture;
      Pmpg123_picture = ^Tmpg123_picture;

      Tmpg123_picture = record
          pictype : char;
          description : Tmpg123_string;
          mime_type : Tmpg123_string;
          size : size_t;
          data : Pbyte;
        end;

{$endif}

type
    PPmpg123_id3v2 = ^Pmpg123_id3v2;
     Pmpg123_id3v2 = ^Tmpg123_id3v2;

  Tmpg123_id3v2 = record
    Version: byte;            (**< 3 or 4 for ID3v2.3 or ID3v2.4. *)
    Title: Pmpg123_string;
    (**< Title string (pointer into text_list). *)
    Artist: Pmpg123_string;
    (**< Artist string (pointer into text_list). *)
    Album: Pmpg123_string;
    (**< Album string (pointer into text_list). *)
    Year: Pmpg123_string;
    (**< The year as a string (pointer into text_list). *)
    Genre: Pmpg123_string;   (**< Genre String (pointer into text_list). The genre string(s)
                                                    may very well need postprocessing, esp. for ID3v2.3. *)
    Comment: Pmpg123_string;
    (**< Pointer to last encountered comment text with empty description. *)
                    (* Encountered ID3v2 fields are appended to these lists.
                       There can be multiple occurences, the pointers above always point
                       to the last encountered data. *)
    Comment_list: Pmpg123_text;  (**< Array of comments. *)
    NumComments: size_t;        (**< Number of comments. *)
    Text: Pmpg123_text;  (**< Array of ID3v2 text fields *)
    NumTexts: size_t;        (**< Numer of text fields. *)
    Extra: Pmpg123_text;
    (**< The array of extra (TXXX) fields. *)
    NumExtras: size_t;
    (**< Number of extra text (TXXX) fields. *)

     {$IF DEFINED(newversion)}
      picture : Pmpg123_picture;
      pictures : size_t;
     {$endif}
  end;

  PPmpg123_id3v1 = ^Pmpg123_id3v1;
  Pmpg123_id3v1 = ^Tmpg123_id3v1;
  Tmpg123_id3v1 = record
    tag: array[0..2] of char;
    (**< Always the string "TAG", the classic intro. *)
    title: array[0..29] of char;  (**< Title string.  *)
    artist: array[0..29] of char;  (**< Artist string. *)
    album: array[0..29] of char;  (**< Album string. *)
    year: array[0..3] of char;   (**< Year string. *)
    comment: array[0..29] of char;  (**< Comment string. *)
    genre: byte;                  (**< Genre index. *)
  end;

const
  MPG123_ID3_ = $03;
  (**< 0011 There is some ID3 info. Also matches 0010 or NEW_ID3. *)
  MPG123_NEW_ID3_ = $01;
  (**< 0001 There is ID3 info that changed since last call to mpg123_id3. *)
  MPG123_ICY_ = $0C;
  (**< 1100 There is some ICY info. Also matches 0100 or NEW_ICY.*)
  MPG123_NEW_ICY_ = $04;
(**< 0100 There is ICY info that changed since last call to mpg123_icy. *)

type
  Tmpg123_meta_check = function(mh: Tmpg123_handle): integer; cdecl;
  Tmpg123_id3 = function(mh: Tmpg123_handle; v1: PPmpg123_id3v1;
    v2: PPmpg123_id3v2): integer; cdecl;
  Tmpg123_icy = function(mh: Tmpg123_handle; var icy_meta: PChar): integer; cdecl;
  // Tmpg123_icy = function(mh: Tmpg123_handle; icy_meta: PPChar): integer; cdecl; 
  Tmpg123_icy2utf8 = function(icy_text: PChar): PChar; cdecl;

const
  _NUM_CHANNELS = 2;
  _MPG123_RATES = 9;
  _MPG123_ENCODINGS = 10;

type
  Pmpg123_pars = ^Tmpg123_pars;

  Tmpg123_pars = record
    verbose: integer;   (* verbose level *)
    flags: longword;  (* combination of above *)
    force_rate: longword;
    down_sample: integer;
    rva: integer; (* (which) rva to do:
                                      0: nothing,
                        1: radio/mix/track
                        2: album/audiophile *)
    halfspeed: longword;
    doublespeed: longword;
                 {$IFNDEF WINDOWS}
    timeout: longword;
                 {$ENDIF}
    audio_caps: array[0.._NUM_CHANNELS - 1, 0.._MPG123_RATES,
    0.._MPG123_ENCODINGS - 1] of char;
    (*  long start_frame; *)(* frame offset to begin with *)
    (*  long frame_number;*)(* number of frames to decode *)
    icy_interval: longword;
    outscale: double; // longword ?
    resync_limit: longword;
    index_size: longint;
    (* Long, because: negative values have a meaning. *)
    dummy: array[0..64] of byte; // dummy
  end;

  Tmpg123_parnew = function(mp: Pmpg123_pars; decoder: PChar;
    var error: integer): Tmpg123_handle; cdecl;
  Tmpg123_new_pars = function(var error: integer): Pmpg123_pars; cdecl;
  Tmpg123_delete_pars = procedure(mp: Pmpg123_pars); cdecl;
  Tmpg123_fmt_none = function(mp: Pmpg123_pars): integer; cdecl;
  Tmpg123_fmt_all = function(mp: Pmpg123_pars): integer; cdecl;
  Tmpg123_fmt = function(mh: Pmpg123_pars; rate: longword;
    channels, encodings: integer): integer; cdecl;
  Tmpg123_fmt_support = function(mh: Pmpg123_pars; rate: longword;
    encoding: integer): integer; cdecl;
  Tmpg123_par = function(mp: Pmpg123_pars; mpg123_parms_type: integer;
    Value: longword; fvalue: double): integer;
    cdecl;
  Tmpg123_getpar = function(mp: Pmpg123_pars; mpg123_parms_type: integer;
    var val: longword; var fval: double)
    : integer; cdecl;
  Tmpg123_replace_buffer = function(mh: Tmpg123_handle; Data: Pointer;
    size: size_t): integer; cdecl;

  Tmpg123_outblock = function(mh: Tmpg123_handle): size_t; cdecl;

{ *** the mpg123 library functions : ***************************************** }
var
  mpg123_init: Tmpg123_init;
  mpg123_exit: Tmpg123_exit;
  mpg123_new: Tmpg123_new;
  mpg123_delete: Tmpg123_delete;

  mpg123_param: Tmpg123_param;
  mpg123_getparam: Tmpg123_getparam;
  mpg123_feature: Tmpg123_feature;

  mpg123_plain_strerror: Tmpg123_plain_strerror;
  mpg123_strerror: Tmpg123_strerror;
  mpg123_errcode: Tmpg123_errcode;
  mpg123_decoders: Tmpg123_decoders;
  mpg123_supported_decoders: Tmpg123_supported_decoders;
  mpg123_decoder: Tmpg123_decoder;
  mpg123_current_decoder: Tmpg123_current_decoder;

  mpg123_rates: Tmpg123_rates;
  mpg123_encodings: Tmpg123_encodings;
  mpg123_encsize: Tmpg123_encsize;
  mpg123_format_none: Tmpg123_format_none;
  mpg123_format_all: Tmpg123_format_all;
  mpg123_format: Tmpg123_format;
  mpg123_format_support: Tmpg123_format_support;
  mpg123_getformat: Tmpg123_getformat;
  mpg123_getformat2: Tmpg123_getformat2;
 
(** \defgroup mpg123_input mpg123 file input and decoding
 * Functions for input bitstream and decoding operations. *)

  mpg123_open: Tmpg123_open;
  mpg123_open_fd: Tmpg123_open_fd;

{$IF DEFINED(newversion)}
{$if not(defined(cpu64) and defined(unix))}
  mpg123_open_32: Tmpg123_open_32;
  mpg123_open_fd_32: Tmpg123_open_fd_32;
  mpg123_open_handle_32 : Tmpg123_open_handle_32;
{$ifend}
  mpg123_open_64: Tmpg123_open_64;
  mpg123_open_fd_64: Tmpg123_open_fd_64;
  mpg123_open_handle: Tmpg123_open_handle;
  mpg123_open_handle_64: Tmpg123_open_handle_64;
  mpg123_replace_reader: Tmpg123_replace_reader;
  mpg123_replace_reader_handle: Tmpg123_replace_reader_handle;
  mpg123_set_index: Tmpg123_set_index;
 {$endif}

  mpg123_open_feed: Tmpg123_open_feed;
  mpg123_close: Tmpg123_close;
  mpg123_read: Tmpg123_read;
  mpg123_feed: Tmpg123_feed;
  mpg123_decode: Tmpg123_decode;
  mpg123_decode_frame: Tmpg123_decode_frame;
  mpg123_framepos: Tmpg123_framepos;

{$IF DEFINED(newversion)}
  {$if not(defined(cpu64) and defined(unix))}
  mpg123_decode_frame_32: Tmpg123_decode_frame_32;
  mpg123_framebyframe_decode_32: Tmpg123_framebyframe_decode_32;
  mpg123_tell_32: Tmpg123_tell_32;
  mpg123_framepos_32: Tmpg123_framepos_32;
  mpg123_tellframe_32: Tmpg123_tellframe_32;
  mpg123_seek_32: Tmpg123_seek_32;
  mpg123_seek_frame_32: Tmpg123_seek_frame_32;
  mpg123_timeframe_32: Tmpg123_timeframe_32;
  mpg123_index_32: Tmpg123_index_32;
  mpg123_set_index_32: Tmpg123_set_index_32;
  mpg123_position_32: Tmpg123_position_32;
  mpg123_framelength_32: Tmpg123_framelength_32;
  mpg123_length_32: Tmpg123_length_32;
  mpg123_set_filesize_32: Tmpg123_set_filesize_32;
  mpg123_replace_reader_32: Tmpg123_replace_reader_32;
  mpg123_replace_reader_handle_32: Tmpg123_replace_reader_handle_32;
  {$ifend}
  mpg123_framebyframe_decode: Tmpg123_framebyframe_decode;
  mpg123_framebyframe_next: Tmpg123_framebyframe_next;
  mpg123_framedata: Tmpg123_framedata;
  mpg123_decode_frame_64: Tmpg123_decode_frame_64;
  mpg123_framebyframe_decode_64: Tmpg123_framebyframe_decode_64;
  mpg123_tell_64: Tmpg123_tell_64;
  mpg123_framepos_64: Tmpg123_framepos_64;
  mpg123_tellframe_64: Tmpg123_tellframe_64;
  mpg123_seek_64: Tmpg123_seek_64;
  mpg123_seek_frame_64: Tmpg123_seek_frame_64;
  mpg123_timeframe_64: Tmpg123_timeframe_64;
  mpg123_index_64: Tmpg123_index_64;
  mpg123_set_index_64: Tmpg123_set_index_64;
  mpg123_position_64: Tmpg123_position_64;
  mpg123_framelength_64: Tmpg123_framelength_64;
  mpg123_length_64: Tmpg123_length_64;
  mpg123_set_filesize_64: Tmpg123_set_filesize_64;
  mpg123_replace_reader_64: Tmpg123_replace_reader_64;
  mpg123_replace_reader_handle_64: Tmpg123_replace_reader_handle_64;  
{$endif}

  mpg123_tell: Tmpg123_tell;
  mpg123_tellframe: Tmpg123_tellframe;
  mpg123_tell_stream: Tmpg123_tell_stream;
  mpg123_seek: Tmpg123_seek;
  mpg123_feedseek: Tmpg123_feedseek;
  mpg123_seek_frame: Tmpg123_seek_frame;
  mpg123_timeframe: Tmpg123_timeframe;
  mpg123_index: Tmpg123_index;
  mpg123_position: Tmpg123_position;

(** \defgroup mpg123_voleq mpg123 volume and equalizer **)
  mpg123_eq: Tmpg123_eq;
  mpg123_geteq: Tmpg123_geteq;
  mpg123_reset_eq: Tmpg123_reset_eq;
  mpg123_volume: Tmpg123_volume;
  mpg123_volume_change: Tmpg123_volume_change;
  mpg123_getvolume: Tmpg123_getvolume;

(** \defgroup mpg123_status mpg123 status and information **)
  mpg123_info: Tmpg123_info;
  mpg123_safe_buffer: Tmpg123_safe_buffer;
  mpg123_scan: Tmpg123_scan;
  mpg123_length: Tmpg123_length;
  mpg123_framelength: Tmpg123_framelength;
  mpg123_set_filesize: Tmpg123_set_filesize;
  mpg123_tpf: Tmpg123_tpf;
  mpg123_spf: Tmpg123_spf;
  mpg123_clip: Tmpg123_clip;
  mpg123_getstate: Tmpg123_getstate;

(** \defgroup mpg123_metadata mpg123 metadata handling *)
  mpg123_init_string: Tmpg123_init_string;
  mpg123_free_string: Tmpg123_free_string;
  mpg123_resize_string: Tmpg123_resize_string;
  mpg123_grow_string: Tmpg123_grow_string;
  mpg123_copy_string: Tmpg123_copy_string;
  mpg123_add_string: Tmpg123_add_string;
  mpg123_add_substring: Tmpg123_add_substring;
  mpg123_set_string: Tmpg123_set_string;
  mpg123_set_substring: Tmpg123_set_substring;
  mpg123_strlen: Tmpg123_strlen;
  mpg123_chomp_string :Tmpg123_chomp_string;

  mpg123_enc_from_id3: Tmpg123_enc_from_id3;
  mpg123_store_utf8: Tmpg123_store_utf8;

  mpg123_meta_check: Tmpg123_meta_check;
  mpg123_meta_free: Tmpg123_meta_free;
  mpg123_id3: Tmpg123_id3;
  mpg123_icy: Tmpg123_icy;
  mpg123_icy2utf8: Tmpg123_icy2utf8;

(** \defgroup mpg123_advpar mpg123 advanced parameter API *)
  mpg123_parnew: Tmpg123_parnew;
  mpg123_new_pars: Tmpg123_new_pars;
  mpg123_delete_pars: Tmpg123_delete_pars;
  mpg123_fmt_none: Tmpg123_fmt_none;
  mpg123_fmt_all: Tmpg123_fmt_all;
  mpg123_fmt: Tmpg123_fmt;
  mpg123_fmt_support: Tmpg123_fmt_support;
  mpg123_par: Tmpg123_par;
  mpg123_getpar: Tmpg123_getpar;
  mpg123_replace_buffer: Tmpg123_replace_buffer;
  mpg123_outblock: Tmpg123_outblock;

{Special function for dynamic loading of lib ...}

var
  Mp_Handle: TLibHandle;
  // this will hold our handle for the lib; it functions nicely as a mutli-lib prevention unit as well...
  ReferenceCounter: cardinal = 0;  // Reference counter

function mp_IsLoaded: boolean; inline;
function mp_load(const libfilename: string): boolean; // load the lib

function mp_unload(): boolean;
// unload and frees the lib from memory : do not forget to call it before close application.

implementation

function mp_IsLoaded: boolean;
begin
  Result := (Mp_Handle <> dynlibs.NilHandle);
end;

function mp_unload(): boolean;
begin
result := false;
  // < Reference counting
  if ReferenceCounter > 0 then
    Dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >
  if mp_IsLoaded then
  begin
    mpg123_exit ;
    DynLibs.UnloadLibrary(mp_Handle);
    mp_Handle := DynLibs.NilHandle;
    result := true;
  end;
end;

function Mp_Load(const libfilename: string): boolean;
var
thelib: string; 
begin
  Result := False;
  if Mp_Handle <> 0 then
  begin
    Result := True; {is it already there ?}
    Inc(ReferenceCounter);
  end
  else
  begin {go & load the library}
    if Length(libfilename) = 0 then thelib := libmp else thelib := libfilename;
    Mp_Handle := DynLibs.SafeLoadLibrary(thelib); // obtain the handle we want
    if Mp_Handle <> DynLibs.NilHandle then

    begin
      mpg123_init := Tmpg123_init(GetProcAddress(Mp_Handle, 'mpg123_init'));
      mpg123_exit := Tmpg123_exit(GetProcAddress(Mp_Handle, 'mpg123_exit'));
      mpg123_new := Tmpg123_new(GetProcAddress(Mp_Handle, 'mpg123_new'));
      mpg123_delete := Tmpg123_delete(GetProcAddress(Mp_Handle, 'mpg123_delete'));
      mpg123_param := Tmpg123_param(GetProcAddress(Mp_Handle, 'mpg123_param'));
      mpg123_getparam := Tmpg123_getparam(
        GetProcAddress(Mp_Handle, 'mpg123_getparam'));
      mpg123_plain_strerror := Tmpg123_plain_strerror(
        GetProcAddress(Mp_Handle, 'mpg123_plain_strerror'));
      mpg123_strerror := Tmpg123_strerror(
        GetProcAddress(Mp_Handle, 'mpg123_strerror'));
      mpg123_errcode := Tmpg123_errcode(GetProcAddress(Mp_Handle, 'mpg123_errcode'));
      mpg123_decoders := Tmpg123_decoders(
        GetProcAddress(Mp_Handle, 'mpg123_decoders'));
      mpg123_supported_decoders :=
        Tmpg123_supported_decoders(GetProcAddress(Mp_Handle, 'mpg123_supported_decoders'));
      mpg123_decoder := Tmpg123_decoder(GetProcAddress(Mp_Handle, 'mpg123_decoder'));
      mpg123_rates := Tmpg123_rates(GetProcAddress(Mp_Handle, 'mpg123_rates'));
      mpg123_encodings := Tmpg123_encodings(
        GetProcAddress(Mp_Handle, 'mpg123_encodings'));
      mpg123_format_none := Tmpg123_format_none(
        GetProcAddress(Mp_Handle, 'mpg123_format_none'));
      mpg123_format_all := Tmpg123_format_all(
        GetProcAddress(Mp_Handle, 'mpg123_format_all'));
      mpg123_format := Tmpg123_format(GetProcAddress(Mp_Handle, 'mpg123_format'));
      mpg123_format_support := Tmpg123_format_support(
        GetProcAddress(Mp_Handle, 'mpg123_format_support'));
      mpg123_getformat := Tmpg123_getformat(
        GetProcAddress(Mp_Handle, 'mpg123_getformat'));
      mpg123_open := Tmpg123_open(GetProcAddress(Mp_Handle, 'mpg123_open'));
      mpg123_open_fd := Tmpg123_open_fd(GetProcAddress(Mp_Handle, 'mpg123_open_fd'));

     {$IF DEFINED(newversion)}
      mpg123_open_handle := Tmpg123_open_handle(GetProcAddress(Mp_Handle, 'mpg123_open_handle'));
      mpg123_replace_reader := Tmpg123_replace_reader(GetProcAddress(Mp_Handle,
     'mpg123_replace_reader'));
     mpg123_replace_reader_handle := Tmpg123_replace_reader_handle(GetProcAddress(Mp_Handle,
     'mpg123_replace_reader_handle'));
     mpg123_framebyframe_decode := Tmpg123_framebyframe_decode(
        GetProcAddress(Mp_Handle, 'mpg123_framebyframe_decode'));
      mpg123_framebyframe_next := Tmpg123_framebyframe_next(
        GetProcAddress(Mp_Handle, 'mpg123_framebyframe_next'));
      mpg123_framedata := Tmpg123_framedata(
        GetProcAddress(Mp_Handle, 'mpg123_framedata'));
       mpg123_meta_free := Tmpg123_meta_free(
        GetProcAddress(Mp_Handle, 'mpg123_meta_free'));
       mpg123_strlen := Tmpg123_strlen(
        GetProcAddress(Mp_Handle, 'mpg123_strlen'));
      mpg123_chomp_string := Tmpg123_chomp_string(
        GetProcAddress(Mp_Handle, 'mpg123_chomp_string'));
       mpg123_getformat2 := Tmpg123_getformat2(
        GetProcAddress(Mp_Handle, 'mpg123_getformat2'));
       mpg123_framepos := Tmpg123_framepos(GetProcAddress(Mp_Handle, 'mpg123_framepos'));
      mpg123_framelength := Tmpg123_framelength(GetProcAddress(Mp_Handle, 'mpg123_framelength'));
      mpg123_encsize := Tmpg123_encsize(GetProcAddress(Mp_Handle, 'mpg123_encsize'));
       mpg123_set_index := Tmpg123_set_index(GetProcAddress(Mp_Handle, 'mpg123_set_index'));

      {$if not(defined(cpu64) and defined(unix))}
      mpg123_open_32 := Tmpg123_open_32(GetProcAddress(Mp_Handle, 'mpg123_open_32'));
      mpg123_open_fd_32 := Tmpg123_open_fd_32(GetProcAddress(Mp_Handle, 'mpg123_open_fd_32'));
      mpg123_open_handle_32 := Tmpg123_open_handle_32(GetProcAddress(Mp_Handle, 'mpg123_open_handle_32'));         
      mpg123_decode_frame_32 := Tmpg123_decode_frame_32(GetProcAddress(Mp_Handle, 'mpg123_decode_frame_32'));
      mpg123_framebyframe_decode_32 := Tmpg123_framebyframe_decode_32(GetProcAddress(Mp_Handle, 'mpg123_framebyframe_decode_32'));
      mpg123_tell_32 := Tmpg123_tell_32(GetProcAddress(Mp_Handle, 'mpg123_tell_32'));
      mpg123_framepos_32 := Tmpg123_framepos_32(GetProcAddress(Mp_Handle, 'mpg123_framepos_32'));
      mpg123_tellframe_32 := Tmpg123_tellframe_32(GetProcAddress(Mp_Handle, 'mpg123_tellframe_32'));
      mpg123_seek_32 := Tmpg123_seek_32(GetProcAddress(Mp_Handle, 'mpg123_seek_32'));
      mpg123_seek_frame_32 := Tmpg123_seek_frame_32(GetProcAddress(Mp_Handle, 'mpg123_seek_frame_32'));
      mpg123_timeframe_32 := Tmpg123_timeframe_32(GetProcAddress(Mp_Handle, 'mpg123_timeframe_32')); 
      mpg123_index_32 := Tmpg123_index_32(GetProcAddress(Mp_Handle, 'mpg123_index_32'));
      mpg123_set_index_32 := Tmpg123_set_index_32(GetProcAddress(Mp_Handle, 'mpg123_set_index_32'));
      mpg123_position_32 := Tmpg123_position_32(GetProcAddress(Mp_Handle, 'mpg123_position_32'));
      mpg123_framelength_32 := Tmpg123_framelength_32(GetProcAddress(Mp_Handle, 'mpg123_framelength_32'));
      mpg123_length_32 := Tmpg123_length_32(GetProcAddress(Mp_Handle, 'mpg123_length_32'));
      mpg123_set_filesize_32 := Tmpg123_set_filesize_32(GetProcAddress(Mp_Handle, 'mpg123_set_filesize_32'));
      mpg123_replace_reader_32 := Tmpg123_replace_reader_32(GetProcAddress(Mp_Handle, 'mpg123_replace_reader_32'));
      mpg123_replace_reader_handle_32 := Tmpg123_replace_reader_handle_32(GetProcAddress(Mp_Handle, 'mpg123_replace_reader_handle_32'));
     {$endif}

       mpg123_open_64 := Tmpg123_open_64(GetProcAddress(Mp_Handle, 'mpg123_open_64'));
       mpg123_open_fd_64 := Tmpg123_open_fd_64(GetProcAddress(Mp_Handle, 'mpg123_open_fd_64'));
       mpg123_open_handle_64 := Tmpg123_open_handle_64(GetProcAddress(Mp_Handle, 'mpg123_open_handle_64'));         
       mpg123_decode_frame_64 := Tmpg123_decode_frame_64(GetProcAddress(Mp_Handle, 'mpg123_decode_frame_64'));
       mpg123_framebyframe_decode_64 := Tmpg123_framebyframe_decode_64(GetProcAddress(Mp_Handle, 'mpg123_framebyframe_decode_64'));
       mpg123_tell_64 := Tmpg123_tell_64(GetProcAddress(Mp_Handle, 'mpg123_tell_64'));
       mpg123_framepos_64 := Tmpg123_framepos_64(GetProcAddress(Mp_Handle, 'mpg123_framepos_64'));
       mpg123_tellframe_64 := Tmpg123_tellframe_64(GetProcAddress(Mp_Handle, 'mpg123_tellframe_64'));
       mpg123_seek_64 := Tmpg123_seek_64(GetProcAddress(Mp_Handle, 'mpg123_seek_64'));
       mpg123_seek_frame_64 := Tmpg123_seek_frame_64(GetProcAddress(Mp_Handle, 'mpg123_seek_frame_64'));
       mpg123_timeframe_64 := Tmpg123_timeframe_64(GetProcAddress(Mp_Handle, 'mpg123_timeframe_64')); 
       mpg123_index_64 := Tmpg123_index_64(GetProcAddress(Mp_Handle, 'mpg123_index_64'));
      mpg123_set_index_64 := Tmpg123_set_index_64(GetProcAddress(Mp_Handle, 'mpg123_set_index_64'));
      mpg123_position_64 := Tmpg123_position_64(GetProcAddress(Mp_Handle, 'mpg123_position_64'));
      mpg123_framelength_64 := Tmpg123_framelength_64(GetProcAddress(Mp_Handle, 'mpg123_framelength_64'));
      mpg123_length_64 := Tmpg123_length_64(GetProcAddress(Mp_Handle, 'mpg123_length_64'));
      mpg123_set_filesize_64 := Tmpg123_set_filesize_64(GetProcAddress(Mp_Handle, 'mpg123_set_filesize_64'));
      mpg123_replace_reader_64 := Tmpg123_replace_reader_64(GetProcAddress(Mp_Handle, 'mpg123_replace_reader_64'));
      mpg123_replace_reader_handle_64 := Tmpg123_replace_reader_handle_64(GetProcAddress(Mp_Handle, 'mpg123_replace_reader_handle_64'));

     {$endif}

      mpg123_open_feed := Tmpg123_open_feed(
        GetProcAddress(Mp_Handle, 'mpg123_open_feed'));
      mpg123_close := Tmpg123_close(GetProcAddress(Mp_Handle, 'mpg123_close'));
      mpg123_read := Tmpg123_read(GetProcAddress(Mp_Handle, 'mpg123_read'));
      mpg123_decode := Tmpg123_decode(GetProcAddress(Mp_Handle, 'mpg123_decode'));
      mpg123_decode_frame := Tmpg123_decode_frame(
        GetProcAddress(Mp_Handle, 'mpg123_decode_frame'));
      mpg123_tell := Tmpg123_tell(GetProcAddress(Mp_Handle, 'mpg123_tell'));
      mpg123_tellframe := Tmpg123_tellframe(
        GetProcAddress(Mp_Handle, 'mpg123_tellframe'));
      mpg123_seek := Tmpg123_seek(GetProcAddress(Mp_Handle, 'mpg123_seek'));
      mpg123_feedseek := Tmpg123_feedseek(
        GetProcAddress(Mp_Handle, 'mpg123_feedseek'));
      mpg123_seek_frame := Tmpg123_seek_frame(
        GetProcAddress(Mp_Handle, 'mpg123_seek_frame'));
      mpg123_timeframe := Tmpg123_timeframe(
        GetProcAddress(Mp_Handle, 'mpg123_timeframe'));
      mpg123_index := Tmpg123_index(GetProcAddress(Mp_Handle, 'mpg123_index'));
      mpg123_position := Tmpg123_position(
        GetProcAddress(Mp_Handle, 'mpg123_position'));
      mpg123_eq := Tmpg123_eq(GetProcAddress(Mp_Handle, 'mpg123_eq'));
      mpg123_reset_eq := Tmpg123_reset_eq(
        GetProcAddress(Mp_Handle, 'mpg123_reset_eq'));
      mpg123_volume := Tmpg123_volume(GetProcAddress(Mp_Handle, 'mpg123_volume'));
      mpg123_volume_change := Tmpg123_volume_change(
        GetProcAddress(Mp_Handle, 'mpg123_volume_change'));
      mpg123_getvolume := Tmpg123_getvolume(
        GetProcAddress(Mp_Handle, 'mpg123_getvolume'));
      mpg123_info := Tmpg123_info(GetProcAddress(Mp_Handle, 'mpg123_info'));
      mpg123_safe_buffer := Tmpg123_safe_buffer(
        GetProcAddress(Mp_Handle, 'mpg123_safe_buffer'));
      mpg123_scan := Tmpg123_scan(GetProcAddress(Mp_Handle, 'mpg123_scan'));
      mpg123_length := Tmpg123_length(GetProcAddress(Mp_Handle, 'mpg123_length'));
      mpg123_tpf := Tmpg123_tpf(GetProcAddress(Mp_Handle, 'mpg123_tpf'));
      mpg123_spf := Tmpg123_spf(GetProcAddress(Mp_Handle, 'mpg123_spf'));
      mpg123_clip := Tmpg123_clip(GetProcAddress(Mp_Handle, 'mpg123_clip'));
      mpg123_init_string := Tmpg123_init_string(
        GetProcAddress(Mp_Handle, 'mpg123_init_string'));
      mpg123_free_string := Tmpg123_free_string(
        GetProcAddress(Mp_Handle, 'mpg123_free_string'));
      mpg123_resize_string := Tmpg123_resize_string(
        GetProcAddress(Mp_Handle, 'mpg123_resize_string'));
      mpg123_copy_string := Tmpg123_copy_string(
        GetProcAddress(Mp_Handle, 'mpg123_copy_string'));
      mpg123_add_string := Tmpg123_add_string(
        GetProcAddress(Mp_Handle, 'mpg123_add_string'));
       mpg123_add_substring := Tmpg123_add_substring(
        GetProcAddress(Mp_Handle, 'mpg123_add_substring'));
      mpg123_set_string := Tmpg123_set_string(
        GetProcAddress(Mp_Handle, 'mpg123_set_string'));
      mpg123_set_substring := Tmpg123_set_substring(
        GetProcAddress(Mp_Handle, 'mpg123_set_substring'));
      mpg123_meta_check := Tmpg123_meta_check(
        GetProcAddress(Mp_Handle, 'mpg123_meta_check'));
      mpg123_id3 := Tmpg123_id3(GetProcAddress(Mp_Handle, 'mpg123_id3'));
      mpg123_icy := Tmpg123_icy(GetProcAddress(Mp_Handle, 'mpg123_icy'));
      mpg123_parnew := Tmpg123_parnew(GetProcAddress(Mp_Handle, 'mpg123_parnew'));
      mpg123_new_pars := Tmpg123_new_pars(
        GetProcAddress(Mp_Handle, 'mpg123_new_pars'));
      mpg123_delete_pars := Tmpg123_delete_pars(
        GetProcAddress(Mp_Handle, 'mpg123_delete_pars'));
      mpg123_fmt_none := Tmpg123_fmt_none(
        GetProcAddress(Mp_Handle, 'mpg123_fmt_none'));
      mpg123_fmt_all := Tmpg123_fmt_all(GetProcAddress(Mp_Handle, 'mpg123_fmt_all'));
      mpg123_fmt := Tmpg123_fmt(GetProcAddress(Mp_Handle, 'mpg123_fmt'));
      mpg123_fmt_support := Tmpg123_fmt_support(
        GetProcAddress(Mp_Handle, 'mpg123_fmt_support'));
      mpg123_par := Tmpg123_par(GetProcAddress(Mp_Handle, 'mpg123_par'));
      mpg123_getpar := Tmpg123_getpar(GetProcAddress(Mp_Handle, 'mpg123_getpar'));
      mpg123_replace_buffer := Tmpg123_replace_buffer(
        GetProcAddress(Mp_Handle, 'mpg123_replace_buffer'));
      mpg123_outblock := Tmpg123_outblock(
        GetProcAddress(Mp_Handle, 'mpg123_outblock'));
    end;
    Result := mp_IsLoaded;
    ReferenceCounter := 1;

  end;
end;

end.
