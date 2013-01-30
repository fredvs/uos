unit lazdyn_mpg123;

/////// This is the dynamical loader for mpg123 library.

//////  Tested in both 32 and 64 bits environnements (Windows, Linux and Macosx).

//////    Based on the --  mpg123rt.pas -- header (many thanks).

/////// Just call the functions Lp_load(your_lib_filename) / Lp_unload(your_lib_filename).                         *

//////         Fred van Stappen     fiens@hotmail.com

{*******************************************************************************
*                        --  mpg123rt.pas --                                   *
*                                                                              *
*  libmpg123:  MPEG Audio Decoder library (version 1.13.0)                     *
*                                                                              *
*                                                                              *
*  This file is for linking the dll ON RUNTIME                                 *
*******************************************************************************}

interface


  {$PACKENUM 4}    (* use 4-byte enums *)
  {$PACKRECORDS C} (* C/C++-compatible record packing *)
  {$MODE objfpc}

{$LONGSTRINGS ON}   (* remember: in Lazarus this is not default ! *)
{** LONGSTRINGS is equivalent to H+}

uses

  dynlibs  ;

type
  Tmpg123_handle = Pointer;   // this is not a usual pointer, more like a THandle ..
                              // so NOT called  "Pmpg123_handle"
                              // => we never access members of the internal
                              //    structure where the pointer points to !
                              //    Everything is managed by the DLL internally !!!

							  
{** Lazarus /  FPC :  needs explicite type casting, so we need types ! **}
(** Function to initialise the mpg123 library.
 *  This function is not thread-safe. Call it exactly once per process,
 *  before any other (possibly threaded) work with the library.
 * \return MPG123_OK if successful, otherwise an error number. *)
type Tmpg123_init   = function() : Integer; cdecl;
// The function RESULT "integer" is the generic signed int type

(** Function to close down the mpg123 library.
 * This function is not thread-safe. Call it exactly once per process,
 * before any other (possibly threaded) work with the library. *)
type Tmpg123_exit   = procedure; cdecl;

(** Create a handle with optional choice of decoder (named by a string,
 *  see mpg123_decoders() or mpg123_supported_decoders()).
 *  and optional retrieval of an error code to feed to mpg123_plain_strerror().
 *  Optional means: Any of or both the parameters may be NULL.
 *
 *  \return Non-NULL pointer when successful. *)
type Tmpg123_new    = function( const decoder : PChar; var error : Integer) : Tmpg123_handle; cdecl;


(** Delete handle, mh is either a valid mpg123 handle or NULL. *)
type Tmpg123_delete = procedure( mh: Tmpg123_handle); cdecl;



{** mpg123_parms - Enumeration of parameters types -  set / get. **}
const
  MPG123_VERBOSE       =  0;  // set verbosity value for enabling messages
                              // to stderr, >= 0 makes sense (integer)
  MPG123_FLAGS         =  1;  // set all flags, p.ex val = MPG123_GAPLESS|MPG123_MONO_MIX (integer)
  MPG123_ADD_FLAGS     =  2;  // add some flags (integer)
  MPG123_FORCE_RATE    =  3;  // when value > 0, force output rate to that value (integer)
  MPG123_DOWN_SAMPLE   =  4;  // 0=native rate, 1=half rate, 2=quarter rate (integer)
  MPG123_RVA           =  5;  // one of the RVA choices above (integer)
  MPG123_DOWNSPEED     =  6;  // play a frame N times (integer)
  MPG123_UPSPEED       =  7;  // play every Nth frame (integer)
  MPG123_START_FRAME   =  8;  // start with this frame (skip frames before that, integer)
  MPG123_DECODE_FRAMES =  9;  // decode only this number of frames (integer)
  MPG123_ICY_INTERVAL  = 10;  // stream contains ICY metadata with this interval (integer)
  MPG123_OUTSCALE      = 11;  // the scale for output samples (amplitude - integer
                              // or float according to mpg123 output format, normally integer)
  MPG123_TIMEOUT       = 12;  // timeout for reading from a stream (not supported
                              // on win32, integer)
  MPG123_REMOVE_FLAGS  = 13;  // remove some flags (inverse of MPG123_ADD_FLAGS, integer)
  MPG123_RESYNC_LIMIT  = 14;  // Try resync on frame parsing for that many bytes
                              // or until end of stream (<0 ... integer).
  MPG123_INDEX_SIZE    = 15;  // Set the frame index size (if supported).
                              // Values <0 mean that the index is allowed to grow
                              // dynamically in these steps (in positive direction,
                              // of course) -- Use this when you really want a
                              // full index with every individual frame.
  MPG123_PREFRAMES     = 16;


{** mpg123_param_flags - Flag bits for MPG123_FLAGS, use the usual binary or to combine. **}
const
  MPG123_FORCE_MONO    = $7;   //     0111 Force some mono mode: This is a test bitmask
                               //          for seeing if any mono forcing is active.
  MPG123_MONO_LEFT     = $1;   //     0001 Force playback of left channel only.
  MPG123_MONO_RIGHT    = $2;   //     0010 Force playback of right channel only.
  MPG123_MONO_MIX      = $4;   //     0100 Force playback of mixed mono.
  MPG123_FORCE_STEREO  = $8;   //     1000 Force stereo output.
  MPG123_FORCE_8BIT    = $10;  // 00010000 Force 8bit formats.
  MPG123_QUIET         = $20;  // 00100000 Suppress any printouts (overrules verbose).                    *)
  MPG123_GAPLESS       = $40;  // 01000000 Enable gapless decoding (default on
                               // if libmpg123 has support).
  MPG123_NO_RESYNC     = $80;  // 10000000 Disable resync stream after error.                             *)
  MPG123_SEEKBUFFER    = $100; // 000100000000 Enable small buffer on non-seekable
                               // streams to allow some peek-ahead (for better MPEG sync).
  MPG123_FUZZY         = $200; // 001000000000 Enable fuzzy seeks (guessing byte
                               // offsets or using approximate seek points from Xing TOC)
  (* 1.72 *)
  MPG123_FORCE_FLOAT   = $400; // 010000000000 Force floating point output
                               // (32 or 64 bits depends on mpg123 internal precision).
  MPG123_PLAIN_ID3TEXT = $800;
  MPG123_IGNORE_STREAMLENGTH = $1000; 
  MPG123_SKIP_ID3V2    = $2000; 


{** mpg123_param_rva - Choices for MPG123_RVA **}
const
  MPG123_RVA_OFF   = 0;  // RVA disabled (default).
  MPG123_RVA_MIX   = 1;  // Use mix/track/radio gain.
  MPG123_RVA_ALBUM = 2;  // Use album/audiophile gain
  MPG123_RVA_MAX   = MPG123_RVA_ALBUM; // The maximum RVA code, may increase in future.


//FixMe:  is long = LongInt ? or LongWord ?   //FixMe: is "C" double = "pascal" double ?
(** Set a specific parameter, for a specific mpg123_handle, using a parameter
 *  type key chosen from the mpg123_parms enumeration, to the specified value. *)
type Tmpg123_param    = function( mh : Tmpg123_handle; mpg123_parms_type : Integer;
                                  value: LongInt; fvalue: double): Integer; cdecl;
//FixMe:  is long = LongInt ? or LongWord ?   //FixMe: is "C" double = "pascal" double ?
(** Get a specific parameter, for a specific mpg123_handle.
 *  See the mpg123_parms enumeration for a list of available parameters. *)
type Tmpg123_getparam = function( mh: Tmpg123_handle; mpg123_parms_type: Integer;
                                  var val : LongInt; var fval : double): Integer; cdecl;


								  
{** mpg123_feature_set - ??? **}
const
  MPG123_FEATURE_ABI_UTF8OPEN      = 0;     
  MPG123_FEATURE_OUTPUT_8BIT       = 1;         
  MPG123_FEATURE_OUTPUT_16BIT      = 2;       
  MPG123_FEATURE_OUTPUT_32BIT      = 3;       
  MPG123_FEATURE_INDEX             = 4;       
  MPG123_FEATURE_PARSE_ID3V2       = 5;       
  MPG123_FEATURE_DECODE_LAYER1     = 6;     
  MPG123_FEATURE_DECODE_LAYER2     = 7;     
  MPG123_FEATURE_DECODE_LAYER3     = 8;     
  MPG123_FEATURE_DECODE_ACCURATE   = 9;   
  MPG123_FEATURE_DECODE_DOWNSAMPLE = 10;   
  MPG123_FEATURE_DECODE_NTOM       = 11;   
  MPG123_FEATURE_PARSE_ICY         = 12;   
  MPG123_FEATURE_TIMEOUT_READ      = 13;


// FixMe:   Cardinal ???
type Tmpg123_feature  = function( const feature_key : shortint): cardinal; cdecl;


{** mpg123_errors - message and error codes and return values from libmpg123 functions.
 * Most functions operating on a mpg123_handle simply return MPG123_OK on success and MPG123_ERR
 * on failure (setting the internal error variable of the handle to the specific error code).
 * Decoding/seek functions may also return message codes MPG123_DONE, MPG123_NEW_FORMAT and MPG123_NEED_MORE.
 * The positive range of return values is used for "useful" values when appropriate. **}
const
  MPG123_DONE              =-12;  // Message: Track ended.
  MPG123_NEW_FORMAT        =-11;  // Message: Output format will be different on next call.
  MPG123_NEED_MORE         =-10;  // Message: For feed reader: "Feed me more!"
  MPG123_ERR               = -1;  // <Generic Error>
  MPG123_OK                =  0;  // <Success>
  MPG123_BAD_OUTFORMAT     =  1;  // Unable to set up output format!
  MPG123_BAD_CHANNEL       =  2;  // Invalid channel number specified.
  MPG123_BAD_RATE          =  3;  // Invalid sample rate specified.
  MPG123_ERR_16TO8TABLE    =  4;  // Unable to allocate memory for 16 to 8 converter table!
  MPG123_BAD_PARAM         =  5;  // Bad parameter id!
  MPG123_BAD_BUFFER        =  6;  // Bad buffer given -- invalid pointer or too small size.
  MPG123_OUT_OF_MEM        =  7;  // Out of memory -- some malloc() failed.
  MPG123_NOT_INITIALIZED   =  8;  // You didn't initialize the library!
  MPG123_BAD_DECODER       =  9;  // Invalid decoder choice.
  MPG123_BAD_HANDLE        = 10;  // Invalid mpg123 handle.
  MPG123_NO_BUFFERS        = 11;  // Unable to initialize frame buffers (out of memory?).
  MPG123_BAD_RVA           = 12;  // Invalid RVA mode.
  MPG123_NO_GAPLESS        = 13;  // This build doesn't support gapless decoding.
  MPG123_NO_SPACE          = 14;  // Not enough buffer space.
  MPG123_BAD_TYPES         = 15;  // Incompatible numeric data types.
  MPG123_BAD_BAND          = 16;  // Bad equalizer band.
  MPG123_ERR_NULL          = 17;  // Null pointer given where valid storage address needed.
  MPG123_ERR_READER        = 18;  // Error reading the stream.
  MPG123_NO_SEEK_FROM_END  = 19;  // Cannot seek from end (end is not known).
  MPG123_BAD_WHENCE        = 20;  // Invalid 'whence' for seek function.
  MPG123_NO_TIMEOUT        = 21;  // Build does not support stream timeouts.
  MPG123_BAD_FILE          = 22;  // File access error.
  MPG123_NO_SEEK           = 23;  // Seek not supported by stream.
  MPG123_NO_READER         = 24;  // No stream opened.
  MPG123_BAD_PARS          = 25;  // Bad parameter handle.
  MPG123_BAD_INDEX_PAR     = 26;  // Bad parameters to mpg123_index()
  MPG123_OUT_OF_SYNC       = 27;  // Lost track in bytestream and did not try to resync.
  MPG123_RESYNC_FAIL       = 28;  // Resync failed to find valid MPEG data.
  MPG123_NO_8BIT           = 29;  // No 8bit encoding possible.
  MPG123_BAD_ALIGN         = 30;  // Stack aligmnent error
  MPG123_NULL_BUFFER       = 31;  // NULL input buffer with non-zero size...
  MPG123_NO_RELSEEK        = 32;  // Relative seek not possible (screwed up file offset)
  MPG123_NULL_POINTER      = 33;  // You gave a null pointer somewhere where you shouldn't have.
  MPG123_BAD_KEY           = 34;  // Bad key value given.
  MPG123_NO_INDEX          = 35;  // No frame index in this build.
  MPG123_INDEX_FAIL        = 36;  // Something with frame index went wrong.
  (* 1.72 *)
  MPG123_BAD_DECODER_SETUP = 37;  // Something prevents a proper decoder setup
  MPG123_MISSING_FEATURE   = 38;  // This feature has not been built into libmpg123.
  MPG123_BAD_VALUE         = 39;
  MPG123_LSEEK_FAILED      = 40;
  MPG123_BAD_CUSTOM_IO     = 41;
  MPG123_LFS_OVERFLOW      = 42;



(** A remark to LAZARUS  and  mpg123 "String" functions (=>PChar) :
 *
 *  Lazarus usually reqires AnsiToUTF8() to convert strings for LCL usage.
 *  Fortunately all Strings here are in ENGLISH language
 *  so a conversion should be unneccessary - as far as I know.
 *)

(** Return a string describing that error errcode means. *)
type Tmpg123_plain_strerror = function( errcode: Integer): PChar; cdecl;

(** Give string describing what error has occured in the context of handle mh.
 *  When a function operating on an mpg123 handle returns MPG123_ERR, you should
 *  check for the actual reason via  char *errmsg = mpg123_strerror(mh)
 *  This function will catch mh == NULL and return the message for MPG123_BAD_HANDLE. *)
type Tmpg123_strerror = function( mh: Tmpg123_handle): PChar; cdecl;

(** Return the plain errcode instead of a string. *)
type Tmpg123_errcode = function( mh: Tmpg123_handle): Integer; cdecl;


(** \defgroup mpg123_decoder mpg123 decoder selection
 *
 * Functions to list and select the available decoders.
 * Perhaps the most prominent feature of mpg123: You have several (optimized) decoders
 * to choose from (on x86 and PPC (MacOS) systems, that is).
 *)

(** Return a NULL-terminated array of generally available decoder names (plain 8bit ASCII). *)
type Tmpg123_decoders = function() : PPChar; cdecl;             //pp.. = Array of pointers !

(** Return a NULL-terminated array of the decoders supported by the CPU (plain 8bit ASCII). *)
type Tmpg123_supported_decoders = function(): PPchar; cdecl;      //pp.. = Array of pointers !

(** Set the chosen decoder to 'decoder_name' *)
type Tmpg123_decoder = function( mh: Tmpg123_handle; var decoder_name: PChar) : Integer; cdecl;

(** ??? *)
type Tmpg123_current_decoder = function( mh : Tmpg123_handle) : PChar; cdecl;


(** 16 or 8 bits, signed or unsigned... all flags fit into 15 bits and are
 * designed to have meaningful binary AND/OR.  Adding float and 32bit int
 * definitions for experimental fun. Only 32bit (and possibly 64bit) float is
 * somewhat there with a dedicated library build. *)
const  // mpg123_enc_enum
  MPG123_ENC_8           = $00f;  (**< 0000 0000 1111 Some 8 bit  integer encoding. *)
  MPG123_ENC_16          = $040;  (**< 0000 0100 0000 Some 16 bit integer encoding. *)
  MPG123_ENC_32          = $100;  (**< 0001 0000 0000 Some 32 bit integer encoding. *)
  MPG123_ENC_SIGNED      = $080;  (**< 0000 1000 0000 Some signed integer encoding. *)
  MPG123_ENC_FLOAT       = $800;  (**< 1110 0000 0000 Some float encoding. *)
  MPG123_ENC_SIGNED_16   = (MPG123_ENC_16 or MPG123_ENC_SIGNED or $10); (**< 0000 1101 0000 signed 16 bit *)
  MPG123_ENC_UNSIGNED_16 = (MPG123_ENC_16 or $20);                   (**< 0000 0110 0000 unsigned 16 bit*)
  MPG123_ENC_UNSIGNED_8  = $01;                                   (**< 0000 0000 0001 unsigned 8 bit*)
  MPG123_ENC_SIGNED_8    = (MPG123_ENC_SIGNED or $02);               (**< 0000 1000 0010 signed 8 bit*)
  MPG123_ENC_ULAW_8      = $04;                                  (**< 0000 0000 0100 ulaw 8 bit*)
  MPG123_ENC_ALAW_8      = $08;                                   (**< 0000 0000 1000 alaw 8 bit *)
  MPG123_ENC_SIGNED_32   = MPG123_ENC_32 or MPG123_ENC_SIGNED or $1000;   (**< 0001 1001 0000 signed 32 bit *)
  MPG123_ENC_UNSIGNED_32 = MPG123_ENC_32 or $2000;                     (**< 0001 0010 0000 unsigned 32 bit *)
  MPG123_ENC_FLOAT_32    = $200;                                  (**< 0010 0000 0000 32bit float *)
  MPG123_ENC_FLOAT_64    = $400;                                  (**< 0100 0000 0000 64bit float *)
  MPG123_ENC_ANY = MPG123_ENC_SIGNED_16 or MPG123_ENC_UNSIGNED_16 or MPG123_ENC_UNSIGNED_8
                   or MPG123_ENC_SIGNED_8 or MPG123_ENC_ULAW_8 or MPG123_ENC_ALAW_8
                   or MPG123_ENC_SIGNED_32 or MPG123_ENC_UNSIGNED_32
                   or MPG123_ENC_FLOAT_32 or MPG123_ENC_FLOAT_64; (**< any encoding *)


(** They can be combined into one number (3) to indicate mono and stereo... *)
// enum mpg123_channelcount
const
  MPG123_LEFT  = $1;
  MPG123_RIGHT = $2;



type





  {$if defined(cpu64)}
    cuint64 = qword;
  size_t  = cuint64;
{$else}
cuint32 = LongWord;
 size_t  = cuint32;
{$endif}

psize_t = ^size_t;


                 { as defined in the C standard }
                { => size_t is the result type of function SizeOf() }



type   //FixMe: use unit ctypes in LAZARUS instead !
  coff_t = integer;  //Int64;


type
//FixMe:  this is experimental - NOT TESTED !!!
  PLong = Pointer;
  pplong = array of PLong;        //pplong in mpg123 means: (a Pointer to) a list of Pointers
  //hint: use size_t to dim the pplong array  

  PInteger = Pointer;

  PPInteger = array of PInteger;  //ppinteger in mpg123 means: (a Pointer to) a list of Pointers

(** An array of supported standard sample rates
 *  These are possible native sample rates of MPEG audio files.
 *  You can still force mpg123 to resample to a different one, but by default
 *  you will only get audio in one of these samplings.
 *  \param list Store a pointer to the sample rates array there.
 *  \param number Store the number of sample rates there. *)
type Tmpg123_rates = procedure( var list : pplong; var number : size_t); cdecl;

(** An array of supported audio encodings.
 *  An audio encoding is one of the fully qualified members of mpg123_enc_enum
 *  (MPG123_ENC_SIGNED_16, not MPG123_SIGNED).
 *  \param list Store a pointer to the encodings array there.
 *  \param number Store the number of encodings there. *)
type Tmpg123_encodings = procedure( var list:ppinteger; var number:size_t); cdecl;

(** ??? *)
type Tmpg123_encsize = function( encoding : integer) : integer; cdecl;

(** Configure a mpg123 handle to accept no output format at all,
 *  use before specifying supported formats with mpg123_format *)
type Tmpg123_format_none = function( mh: Tmpg123_handle) : Integer; cdecl;

(** Configure mpg123 handle to accept all formats
 *  (also any custom rate you may set) -- this is default. *)
type Tmpg123_format_all = function( mh: Tmpg123_handle) : Integer; cdecl;

(** Set the audio format support of a mpg123_handle in detail:
 *  \param mh audio decoder handle
 *  \param rate The sample rate value (in Hertz).
 *  \param channels A combination of MPG123_STEREO and MPG123_MONO.
 *  \param encodings A combination of accepted encodings for rate and channels, p.ex MPG123_ENC_SIGNED16 | MPG123_ENC_ULAW_8 (or 0 for no support). Please note that some encodings may not be supported in the library build and thus will be ignored here.
 *  \return MPG123_OK on success, MPG123_ERR if there was an error. *)
type Tmpg123_format = function( mh: Tmpg123_handle; rate: Cardinal; channels: Integer; 
								encodings: Integer) : Integer; cdecl;
//FixMe: is rate = generic unsigned integer type Cardinal ?  or FixedLength = DWord / LongWord ? 

(** Check to see if a specific format at a specific rate is supported
 *  by mpg123_handle.
 *  \return 0 for no support (that includes invalid parameters), MPG123_STEREO,
 *          MPG123_MONO or MPG123_STEREO|MPG123_MONO. *)
type Tmpg123_format_support = function( mh: Tmpg123_handle; rate: Cardinal; 
										encoding: Integer) : Integer; cdecl;

(** Get the current output format written to the adresses given. *)
type Tmpg123_getformat = function( mh : Tmpg123_handle; var rate:Cardinal;
                                var channels, encoding : integer) : Integer; cdecl;



(** \defgroup mpg123_input mpg123 file input and decoding
 * Functions for input bitstream and decoding operations. *)

(* reading samples / triggering decoding, possible return values: *)
(** See enumeration of the error codes returned by libmpg123 functions. *)

(** Open and prepare to decode the specified file by filesystem path.
 *  This does not open HTTP urls; libmpg123 contains no networking code.
 *  If you want to decode internet streams, use mpg123_open_fd() or mpg123_open_feed(). *)
type Tmpg123_open = function( mh: Tmpg123_handle; path: PChar): Integer; cdecl;

(** Use an already opened file descriptor as the bitstream input
 *  mpg123_close() will _not_ close the file descriptor. *)
type Tmpg123_open_fd = function( mh: Tmpg123_handle; fd: Integer) : Integer; cdecl;

//FixMe: implement it :    (** ??? *)
//function mpg123_open_handle( mh : Tpmpg123_handle; var iohandle:???) : integer; cdecl;  external mpg123Lib;
//00446 EXPORT int mpg123_open_handle(mpg123_handle *mh, void *iohandle);

(** Open a new bitstream and prepare for direct feeding
 *  This works together with mpg123_decode(); you are responsible for reading and feeding the input bitstream. *)
type Tmpg123_open_feed = function( mh: Tmpg123_handle) : Integer; cdecl;

(** Closes the source, if libmpg123 opened it. *)
type Tmpg123_close = function( mh: Tmpg123_handle) : Integer; cdecl;

(** Read from stream and decode up to outmemsize bytes.
 *  \param outmemory address of output buffer to write to
 *  \param outmemsize maximum number of bytes to write
 *  \param done address to store the number of actually decoded bytes to
 *  \return error/message code (watch out for MPG123_DONE and friends!) *)
type Tmpg123_read = function( mh : Tmpg123_handle; outmemory : Pointer; outmemsize : size_t;
                              var done : size_t) : integer; cdecl;

(** Feed data for a stream that has been opened with mpg123_open_feed().
 *  It's give and take: You provide the bytestream, mpg123 gives you the decoded samples.
 *  \param in input buffer
 *  \param size number of input bytes
 *  \return error/message code. *)
type Tmpg123_feed = function( mh : Tmpg123_handle; inbuf : Pointer; size : size_t) : Integer; cdecl; 

(** Decode MPEG Audio from inmemory to outmemory.
 *  This is very close to a drop-in replacement for old mpglib.
 *  When you give zero-sized output buffer the input will be parsed until
 *  decoded data is available. This enables you to get MPG123_NEW_FORMAT (and query it)
 *  without taking decoded data.
 *  Think of this function being the union of mpg123_read() and mpg123_feed() (which it actually is, sort of;-).
 *  You can actually always decide if you want those specialized functions in separate steps or one call this one here.
 *  \param inmemory input buffer
 *  \param inmemsize number of input bytes
 *  \param outmemory output buffer
 *  \param outmemsize maximum number of output bytes
 *  \param done address to store the number of actually decoded bytes to
 *  \return error/message code (watch out especially for MPG123_NEED_MORE) *)
type Tmpg123_decode = function( mh: Tmpg123_handle; inmemory : Pointer; inmemsize : size_t;
	                        outmemory : Pointer; outmemsize : size_t;
                                var done : size_t): Integer; cdecl;

(** Decode next MPEG frame to internal buffer
 *  or read a frame and return after setting a new format.
 *  \param num current frame offset gets stored there
 *  \param audio This pointer is set to the internal buffer to read the decoded audio from.
 *  \param bytes number of output bytes ready in the buffer *)
type Tmpg123_decode_frame = function( mh : Tmpg123_handle; var num : coff_t; audio:PPChar;
                                      var bytes : size_t):integer; cdecl; 


(** \defgroup mpg123_seek mpg123 position and seeking
 *
 * Functions querying and manipulating position in the decoded audio bitstream.
 * The position is measured in decoded audio samples, or MPEG frame offset for the specific functions.
 * If gapless code is in effect, the positions are adjusted to compensate the skipped padding/delay - meaning, you should not care about that at all and just use the position defined for the samples you get out of the decoder;-)
 * The general usage is modelled after stdlib's ftell() and fseek().
 * Especially, the whence parameter for the seek functions has the same meaning as the one for fseek() and needs the same constants from stdlib.h:
 * - SEEK_SET: set position to (or near to) specified offset
 * - SEEK_CUR: change position by offset from now
 * - SEEK_END: set position to offset from end
 *
 * Note that sample-accurate seek only works when gapless support has been enabled at compile time; seek is frame-accurate otherwise.
 * Also, seeking is not guaranteed to work for all streams (underlying stream may not support it). *)

(** Returns the current position in samples.
 *  On the next read, you'd get that sample. *)
type Tmpg123_tell =  function( mh : Tmpg123_handle) : coff_t; cdecl;

(** Returns the frame number that the next read will give you data from. *)
type Tmpg123_tellframe = function( mh : Tmpg123_handle) : coff_t; cdecl;

(** Returns the current byte offset in the input stream. *)
type Tmpg123_tell_stream = function ( mh : Tmpg123_handle) : coff_t; cdecl;

(** Seek to a desired sample offset.
 *  Set whence to SEEK_SET, SEEK_CUR or SEEK_END.
 *  \return The resulting offset >= 0 or error/message code *)
type Tmpg123_seek = function( mh : Tmpg123_handle; sampleoff : coff_t; whence:Integer) : Integer; cdecl;

(** Seek to a desired sample offset in data feeding mode.
 *  This just prepares things to be right only if you ensure that the next chunk of input data will be from input_offset byte position.
 *  \param input_offset The position it expects to be at the
 *                      next time data is fed to mpg123_decode().
 *  \return The resulting offset >= 0 or error/message code *)
type Tmpg123_feedseek = function( mh : Tmpg123_handle; sampleoff : coff_t; whence : Integer;
                                  var input_offset : coff_t) : coff_t; cdecl;

(** Seek to a desired MPEG frame index.
 *  Set whence to SEEK_SET, SEEK_CUR or SEEK_END.
 *  \return The resulting offset >= 0 or error/message code *)
type Tmpg123_seek_frame = function( mh: Tmpg123_handle; frameoff: coff_t; whence: Integer): coff_t; cdecl;

(** Return a MPEG frame offset corresponding to an offset in seconds.
 *  This assumes that the samples per frame do not change in the file/stream, which is a good assumption for any sane file/stream only.
 *  \return frame offset >= 0 or error/message code *)
type Tmpg123_timeframe = function( mh: Tmpg123_handle; sec: double) : coff_t; cdecl;

(** Give access to the frame index table that is managed for seeking.
 *  You are asked not to modify the values... unless you are really aware of what you are doing.
 *  \param offsets pointer to the index array
 *  \param step    one index byte offset advances this many MPEG frames
 *  \param fill    number of recorded index offsets; size of the array *)
type Tmpg123_index = function( mh : Tmpg123_handle; var offsets : PPInteger; var step : coff_t;
                               var fill : size_t) : Integer;

(** Get information about current and remaining frames/seconds.
 *  WARNING: This function is there because of special usage by standalone mpg123 and may be removed in the final version of libmpg123!
 *  You provide an offset (in frames) from now and a number of output bytes
 *  served by libmpg123 but not yet played. You get the projected current frame
 *  and seconds, as well as the remaining frames/seconds. This does _not_ care
 *  about skipped samples due to gapless playback. *)
type Tmpg123_position = function( mh: Tmpg123_handle; frame_offset: coff_t;
                                  buffered_bytes: coff_t; var current_frame : coff_t;
                                  var frames_left : coff_t; var current_seconds : double;
                                  var seconds_left : double) : Integer; cdecl;


(** \defgroup mpg123_voleq mpg123 volume and equalizer **)

(** Set the 32 Band Audio Equalizer settings.
 *  \param channel Can be MPG123_LEFT, MPG123_RIGHT or MPG123_LEFT|MPG123_RIGHT for both.
 *  \param band The equaliser band to change (from 0 to 31)
 *  \param val The (linear) adjustment factor. *)
type Tmpg123_eq = function( mh : Tmpg123_handle; mpg123_channels_channel : Integer; band : Integer; 
                            val : double) : Integer; cdecl;
								
(** Get the 32 Band Audio Equalizer settings.
 *  \param channel Can be MPG123_LEFT, MPG123_RIGHT or MPG123_LEFT|MPG123_RIGHT for (arithmetic mean of) both.
 *  \param band The equaliser band to change (from 0 to 31)
 *  \return The (linear) adjustment factor. *)
type Tmpg123_geteq = function( mh : Tmpg123_handle; mpg123_channels_channel : Integer;
                               band : Integer) : double; cdecl;

(** Reset the 32 Band Audio Equalizer settings to flat *)
type Tmpg123_reset_eq = function( mh: Tmpg123_handle): Integer; cdecl;

(** Set the absolute output volume including the RVA setting,
 *  vol<0 just applies (a possibly changed) RVA setting. *)
type Tmpg123_volume = function( mh : Tmpg123_handle; vol : double) : Integer; cdecl;

(** Adjust output volume including the RVA setting by chosen amount *)
type Tmpg123_volume_change = function( mh : Tmpg123_handle; change : double) : Integer; cdecl;

(** Return current volume setting, the actual value due to RVA, and the RVA
 *  adjustment itself. It's all as double float value to abstract the sample
 *  format. The volume values are linear factors / amplitudes (not percent)
 *  and the RVA value is in decibels. *)
type Tmpg123_getvolume = function( mh : Tmpg123_handle; var base : double; var really : double;
                                   var rva_db : double) : Integer; cdecl; 

//00630 /* TODO: Set some preamp in addition / to replace internal RVA handling? */
 
 
(** \defgroup mpg123_status mpg123 status and information **)

(** mpg123_vbr - Enumeration of the mode types of Variable Bitrate *)
const
  MPG123_CBR = 0;  (**< Constant Bitrate Mode (default) *)
  MPG123_VBR = 1;  (**< Variable Bitrate Mode *)
  MPG123_ABR = 2;  (**< Average Bitrate Mode *)

(** enum mpg123_version - Enumeration of the MPEG Versions *)
const
  MPG123_1_0 = 0;  (**< MPEG Version 1.0 *)
  MPG123_2_0 = 1;  (**< MPEG Version 2.0 *)
  MPG123_2_5 = 2;  (**< MPEG Version 2.5 *)
	
(** enum mpg123_mode - Enumeration of the MPEG Audio mode.
 *  Only the mono mode has 1 channel, the others have 2 channels. *)
  MPG123_M_STEREO = 0;  (**< Standard Stereo. *) 
  MPG123_M_JOINT  = 1;  (**< Joint Stereo. *)
  MPG123_M_DUAL   = 2;  (**< Dual Channel. *)
  MPG123_M_MONO   = 3;  (**< Single Channel. *)

(** enum mpg123_flags - Enumeration of the MPEG Audio flag bits *)
  MPG123_CRC       = $1;  (**< The bitstream is error protected using 16-bit CRC. *)
  MPG123_COPYRIGHT = $2;  (**< The bitstream is copyrighted. *)
  MPG123_PRIVATE   = $4;  (**< The private bit has been set. *)
  MPG123_ORIGINAL  = $8;  (**< The bitstream is an original, not a copy. *)

(** Data structure for storing information about a frame of MPEG Audio *)
type
  pmpg123_frameinfo = ^Tmpg123_frameinfo;
  Tmpg123_frameinfo = packed record
	  mpg123_version_version : LongWord;  (**< The MPEG version (1.0/2.0/2.5). *)
	  layer                  : Integer;   (**< The MPEG Audio Layer (MP1/MP2/MP3). *)
	  rate                   : LongWord;  (**< The sampling rate in Hz. *)
	  mpg123_mode_mode       : LongInt;   (**< The audio mode (Mono, Stereo, Joint-stero, Dual Channel). *)
	  mode_ext               : Integer;   (**< The mode extension bit flag. *)
	  framesize              : Integer;   (**< The size of the frame (in bytes). *)
	  mpg123_flags_flags     : LongWord;  (**< MPEG Audio flag bits. *)
	  emphasis               : Integer;   (**< The emphasis type. *)
	  bitrate                : Integer;   (**< Bitrate of the frame (kbps). *)
	  abr_rate               : Integer;   (**< The target average bitrate. *)
	  mpg123_vbr_vbr         : LongWord;  (**< The VBR mode. *)
  end;

(** Get frame information about the MPEG audio bitstream and store it in a mpg123_frameinfo structure. *)
type Tmpg123_info = function( mh : Tmpg123_handle; var mi : Tmpg123_frameinfo) : Integer; cdecl;

(** Get the safe output buffer size for all cases (when you want to replace the internal buffer) *)
type Tmpg123_safe_buffer = function() : size_t; cdecl;

(** Make a full parsing scan of each frame in the file. ID3 tags are found. An accurate length
 *  value is stored. Seek index will be filled. A seek back to current position
 *  is performed. At all, this function refuses work when stream is not seekable.
 *  \return MPG123_OK or MPG123_ERR. *)
type Tmpg123_scan = function( mh: Tmpg123_handle) : Integer; cdecl;

(** Return, if possible, the full (expected) length of current track in samples.
 * \return length >= 0 or MPG123_ERR if there is no length guess possible. *)
type Tmpg123_length = function( mh: Tmpg123_handle): coff_t; cdecl;

(** Override the value for file size in bytes.
  * Useful for getting sensible track length values in feed mode or for HTTP streams.
  * \return MPG123_OK or MPG123_ERR *)
type Tmpg123_set_filesize = function( mh : Tmpg123_handle; size : coff_t) : Integer; cdecl;

(** Returns the time (seconds) per frame; <0 is error. *)
type Tmpg123_tpf = function( mh: Tmpg123_handle): double; cdecl;

(** Get and reset the clip count. *)
type Tmpg123_clip = function( mh: Tmpg123_handle): LongInt; cdecl;
//FixMe:  is long = LongInt ? or LongWord ?   


(** mpg123_state - The key values for state information from mpg123_getstate(). *)
const
  MPG123_ACCURATE = 1; (**< Query if positons are currently accurate (integer value, 0 if false, 1 if true) *)

  
(** Get various current decoder/stream state information.
 *  \param key the key to identify the information to give.
 *  \param val the address to return (long) integer values to
 *  \param fval the address to return floating point values to
 *  \return MPG123_OK or MPG123_ERR for success *)
type Tmpg123_getstate = function( mh : Tmpg123_handle; mpg123_state_key : Integer;
                                  var val : LongInt; var fval : double) : Integer; cdecl;
//FixMe:  is long = LongInt ? or LongWord ?   


(** \defgroup mpg123_metadata mpg123 metadata handling
 *
 * Functions to retrieve the metadata from MPEG Audio files and streams.
 * Also includes string handling functions. *)

(** Data structure for storing strings in a safer way than a standard C-String.
 *  Can also hold a number of null-terminated strings. *)
type
  Pmpg123_string = ^Tmpg123_string;
  Tmpg123_string = packed record
                     p    : PChar;   (**< pointer to the string data *)
	                 size : size_t;  (**< raw number of bytes allocated *)
                     fill : size_t;  (**< number of used bytes (including closing zero byte) *)
                   end;


(** Create and allocate memory for a new mpg123_string *)
type Tmpg123_init_string = procedure( psb: Pmpg123_string); cdecl;

(** Free-up mempory for an existing mpg123_string *)
type Tmpg123_free_string = procedure( psb : Pmpg123_string); cdecl;

(** Change the size of a mpg123_string
 *  \return 0 on error, 1 on success *)
type Tmpg123_resize_string = function( psb : Pmpg123_string; news : size_t): Integer; cdecl;

(** Increase size of a mpg123_string if necessary (it may stay larger).
 *  Note that the functions for adding and setting in current libmpg123 use this instead of mpg123_resize_string().
 *  That way, you can preallocate memory and safely work afterwards with pieces.
 *  \return 0 on error, 1 on success *)
type Tmpg123_grow_string = function( psb : Pmpg123_string; news : size_t) : Integer; cdecl;

(** Copy the contents of one mpg123_string string to another.
 *  \return 0 on error, 1 on success *)
type Tmpg123_copy_string = function( strfrom, strto : Pmpg123_string): Integer; cdecl;

(** Append a C-String to an mpg123_string
 *  \return 0 on error, 1 on success *)
type Tmpg123_add_string = function( psb : Pmpg123_string; stuff : PChar) : Integer; cdecl;

(** Append a C-substring to an mpg123 string
 *  \return 0 on error, 1 on success
 *  \param from offset to copy from
 *  \param count number of characters to copy (a null-byte is always appended) *)
type Tmpg123_add_substring = function( psb : Pmpg123_string; stuff : PChar;
                                       strfrom, count : size_t) : Integer; cdecl;

(** Set the conents of a mpg123_string to a C-string
 *  \return 0 on error, 1 on success *)
type Tmpg123_set_string = function( psb : Pmpg123_string; stuff : PChar) : Integer; cdecl;

(** Set the contents of a mpg123_string to a C-substring
 *  \return 0 on error, 1 on success
 *  \param from offset to copy from
 *  \param count number of characters to copy (a null-byte is always appended) *)
type Tmpg123_set_substring = function( psb : Pmpg123_string; stuff : PChar;
                                      strfrom, count : size_t) : Integer; cdecl;

(** ??? *)
type Tmpg123_strlen = function( psb : Pmpg123_string; utf8 : Integer) : size_t;



(** Sub data structure for ID3v2, for storing various text fields (including comments).
 *  This is for ID3v2 COMM, TXXX and all the other text fields.
 *  Only COMM and TXXX have a description, only COMM has a language.
 *  You should consult the ID3v2 specification for the use of the various text fields
 *  ("frames" in ID3v2 documentation, I use "fields" here to separate from MPEG frames). *)

(** enum mpg123_text_encoding - ??? *)
const
  mpg123_text_unknown  = 0; 
  mpg123_text_utf8     = 1; 
  mpg123_text_latin1   = 2; 
  mpg123_text_icy      = 3; 
  mpg123_text_cp1252   = 4;
  mpg123_text_utf16    = 5;
  mpg123_text_utf16bom = 6;
  mpg123_text_utf16be  = 7;
  mpg123_text_max      = 7; 

(** enum mpg123_id3_enc - ??? *)
  mpg123_id3_latin1   = 0; 
  mpg123_id3_utf16bom = 1; 
  mpg123_id3_utf16be  = 2; 
  mpg123_id3_utf8     = 3; 
  mpg123_id3_enc_max  = 3; 


//request mpg123_text_encoding :
type Tmpg123_enc_from_id3 = function( id3_enc_byte : byte) : Integer; cdecl;

//store utf8 string :
type Tmpg123_store_utf8 = function( psb : Pmpg123_string; mpg123_text_encoding : Integer;
                                    var source: byte; source_size : size_t ) : Integer; cdecl;

  
type
  Pmpg123_text = ^Tmpg123_text;
  Tmpg123_text = packed record
                   lang : array[0..2] of Char;  (**< Three-letter language code (not terminated). *)
                   id   : array[0..3] of Char;  (**< The ID3v2 text field id, like TALB, TPE2, ... (4 characters, no string termination). *)
                   description: Tmpg123_string; (**< Empty for the generic comment... *)
                   text : Tmpg123_string;       (**< ... *)
                 end;

(** Data structure for storing IDV3v2 tags.
 *  This structure is not a direct binary mapping with the file contents.
 *  The ID3v2 text frames are allowed to contain multiple strings.
 *  So check for null bytes until you reach the mpg123_string fill.
 *  All text is encoded in UTF-8. *)
type
  PPmpg123_id3v2 = ^Pmpg123_id3v2;
  Pmpg123_id3v2 = ^Tmpg123_id3v2;
  Tmpg123_id3v2 = packed record
                    Version : Byte;            (**< 3 or 4 for ID3v2.3 or ID3v2.4. *)
                    pTitle  : Pmpg123_string;   (**< Title string (pointer into text_list). *)
                    pArtist : Pmpg123_string;   (**< Artist string (pointer into text_list). *)
                    pAlbum  : Pmpg123_string;   (**< Album string (pointer into text_list). *)
                    pYear   : Pmpg123_string;   (**< The year as a string (pointer into text_list). *)
                    pGenre  : Pmpg123_string;   (**< Genre String (pointer into text_list). The genre string(s)
                                                    may very well need postprocessing, esp. for ID3v2.3. *)
                    pComment: Pmpg123_string; (**< Pointer to last encountered comment text with empty description. *)
                    (* Encountered ID3v2 fields are appended to these lists.
                       There can be multiple occurences, the pointers above always point
                       to the last encountered data. *)
                    pComment_list : Pmpg123_text;  (**< Array of comments. *)
                    NumComments   : size_t;        (**< Number of comments. *)
                    pText         : Pmpg123_text;  (**< Array of ID3v2 text fields *)
                    NumTexts      : size_t;        (**< Numer of text fields. *)
                    pExtra        : Pmpg123_text;  (**< The array of extra (TXXX) fields. *)
                    NumExtras     : size_t;        (**< Number of extra text (TXXX) fields. *)
                  end;

(** Data structure for ID3v1 tags (the last 128 bytes of a file).
 *  Don't take anything for granted (like string termination)!
 *  Also note the change ID3v1.1 did: comment[28] = 0; comment[19] = track_number
 *  It is your task to support ID3v1 only or ID3v1.1 ...*)
type
  PPmpg123_id3v1 = ^Pmpg123_id3v1;
  Pmpg123_id3v1  = ^Tmpg123_id3v1;
  Tmpg123_id3v1  = packed record
                     tag     : array[0..2] of Char;   (**< Always the string "TAG", the classic intro. *)
                     title   : array[0..29] of Char;  (**< Title string.  *)
                     artist  : array[0..29] of Char;  (**< Artist string. *)
                     album   : array[0..29] of Char;  (**< Album string. *)
                     year    : array[0..3] of Char;   (**< Year string. *)
                     comment : array[0..29] of Char;  (**< Comment string. *)
                     genre   : byte;                  (**< Genre index. *)
                   end;

const
  MPG123_ID3_     = $03;  (**< 0011 There is some ID3 info. Also matches 0010 or NEW_ID3. *)
  MPG123_NEW_ID3_ = $01;  (**< 0001 There is ID3 info that changed since last call to mpg123_id3. *)
  MPG123_ICY_     = $0C;  (**< 1100 There is some ICY info. Also matches 0100 or NEW_ICY.*)
  MPG123_NEW_ICY_ = $04;  (**< 0100 There is ICY info that changed since last call to mpg123_icy. *)
  
(** Query if there is (new) meta info, be it ID3 or ICY (or something new in future).
   The check function returns a combination of flags. 
   On error (no valid handle) just 0 is returned. *)
type Tmpg123_meta_check = function( mh: Tmpg123_handle): Integer; cdecl;

(** Point v1 and v2 to existing data structures wich may change on any next read/decode function call.
 *  v1 and/or v2 can be set to NULL when there is no corresponding data.
 *  \return Return value is MPG123_OK or MPG123_ERR,  *)
type Tmpg123_id3 = function( mh : Tmpg123_handle; v1:PPmpg123_id3v1; v2: PPmpg123_id3v2) : Integer; cdecl;

(** Point icy_meta to existing data structure wich may change on any next read/decode function call.
 *  \return Return value is MPG123_OK or MPG123_ERR,  *)
type Tmpg123_icy = function( mh : Tmpg123_handle; var icy_meta : PPChar) : Integer; cdecl;
(* same for ICY meta string *)

(** Decode from windows-1252 (the encoding ICY metainfo used) to UTF-8.
 *  \param icy_text The input data in ICY encoding
 *  \return pointer to newly allocated buffer with UTF-8 data (You free() it!) *)
type Tmpg123_icy2utf8 = function( icy_text : PChar) : PChar; cdecl;



(** \defgroup mpg123_advpar mpg123 advanced parameter API
 *
 *  Direct access to a parameter set without full handle around it.
 *	Possible uses:
 *    - Influence behaviour of library _during_ initialization of handle (MPG123_VERBOSE).
 *    - Use one set of parameters for multiple handles.
 *
 *	The functions for handling mpg123_pars (mpg123_par() and mpg123_fmt()
 *  family) directly return a fully qualified mpg123 error code, the ones
 *  operating on full handles normally MPG123_OK or MPG123_ERR, storing the
 *  specific error code itseld inside the handle. *)

(** Opaque structure for the libmpg123 decoder parameters. *)
const
  _NUM_CHANNELS = 2;
  _MPG123_RATES = 9;
  _MPG123_ENCODINGS = 10;
	
//struct mpg123_pars_struct  - FIXME:  not verified !!!
type
  Pmpg123_pars = ^Tmpg123_pars;
  Tmpg123_pars = packed record
                   verbose     : integer;   (* verbose level *)
		           flags       : longword;  (* combination of above *)
                   force_rate  : longword;
                   down_sample : integer;
                   rva         : integer; (* (which) rva to do: 
				                              0: nothing, 
							 				 1: radio/mix/track 
								 			 2: album/audiophile *)
                   halfspeed   : longword;
                   doublespeed : longword;
                 {$IFNDEF WIN32}
	               timeout     : longword;
                 {$ENDIF}
                   audio_caps : array[0.._NUM_CHANNELS-1,0.._MPG123_RATES,0.._MPG123_ENCODINGS-1] of Char;
  (*	long start_frame; *) (* frame offset to begin with *)
  (*	long frame_number;*) (* number of frames to decode *)
                   icy_interval: longword;
                   outscale    : double; // longword ?
                   resync_limit: longword;
                   index_size  : LongInt; (* Long, because: negative values have a meaning. *)
                   dummy : array[0..64] of byte; // dummy
                 end;


(** Create a handle with preset parameters. *)
type Tmpg123_parnew = function( mp : Pmpg123_pars; decoder : PChar;
                                var error : Integer) : Tmpg123_handle; cdecl;
	
(** Allocate memory for and return a pointer to a new mpg123_pars *)
type Tmpg123_new_pars = function( var error : Integer) : Pmpg123_pars; cdecl;

(** Delete and free up memory used by a mpg123_pars data structure *)
type Tmpg123_delete_pars = procedure( mp : Pmpg123_pars); cdecl;

(** Configure mpg123 parameters to accept no output format at all,
 * use before specifying supported formats with mpg123_format *)
type Tmpg123_fmt_none = function( mp : Pmpg123_pars) : Integer; cdecl; 

(** Configure mpg123 parameters to accept all formats
 *  (also any custom rate you may set) -- this is default. *)
type Tmpg123_fmt_all = function( mp : Pmpg123_pars) : Integer; cdecl; 

(** Set the audio format support of a mpg123_pars in detail:
    \param rate The sample rate value (in Hertz).
    \param channels A combination of MPG123_STEREO and MPG123_MONO.
    \param encodings A combination of accepted encodings for rate and
    \channels, p.ex MPG123_ENC_SIGNED16|MPG123_ENC_ULAW_8 (or 0 for no support).
    \return 0 on success, -1 if there was an error. / *)
type Tmpg123_fmt = function( mh : Pmpg123_pars; rate : LongWord; channels, encodings : Integer) : Integer; cdecl; 

(** Check to see if a specific format at a specific rate is supported
 *  by mpg123_pars.
 *  \return 0 for no support (that includes invalid parameters), 
 *    MPG123_STEREO, MPG123_MONO or MPG123_STEREO|MPG123_MONO. *)
type Tmpg123_fmt_support = function( mh : Pmpg123_pars; rate : LongWord; encoding : Integer) : Integer; cdecl; 

(** Set a specific parameter, for a specific mpg123_pars, using a parameter
 *  type key chosen from the mpg123_parms enumeration, to the specified value. *)
type Tmpg123_par = function( mp : Pmpg123_pars; mpg123_parms_type : Integer; value : LongWord; 
                                        fvalue : double) : Integer; cdecl;
										
(** Get a specific parameter, for a specific mpg123_pars.
 *  See the mpg123_parms enumeration for a list of available parameters. *)
type Tmpg123_getpar = function( mp : Pmpg123_pars; mpg123_parms_type : Integer; var val : LongWord; 
                                              var fval : double) : Integer; cdecl; 

											  
(** \defgroup mpg123_lowio mpg123 low level I/O
  * You may want to do tricky stuff with I/O that does not work with mpg123's default file access
  * or you want to make it decode into your own pocket...*)

(** Replace default internal buffer with user-supplied buffer.
  * Instead of working on it's own private buffer, mpg123 will directly use the one you provide for storing decoded audio. *)
type Tmpg123_replace_buffer = function( mh : Tmpg123_handle; data : Pointer; 
                                        size : size_t) : Integer; cdecl; 

(** The max size of one frame's decoded output with current settings.
 *  Use that to determine an appropriate minimum buffer size for decoding one frame. *)
type Tmpg123_outblock = function( mh : Tmpg123_handle) : size_t; cdecl;


//FixMe:  not verified :
//01008 EXPORT int mpg123_replace_reader( mpg123_handle *mh, 
//                                        ssize_t (*r_read) (int, void *, size_t), 
//                                        off_t (*r_lseek)(int, off_t, int));
//01009 
//01019 EXPORT int mpg123_replace_reader_handle( mpg123_handle *mh, 
//                                               ssize_t (*r_read) (void *, 
//                                               void *, size_t), off_t (*r_lseek)(void *, 
//                                               off_t, int), void (*cleanup)(void*));





{ *** ****************************** ***************************************** }
{ *** the mpg123 library functions : ***************************************** }
var
  mpg123_init                : Tmpg123_init;
  mpg123_exit                : Tmpg123_exit;
  mpg123_new                 : Tmpg123_new;
  mpg123_delete              : Tmpg123_delete;

var
  mpg123_param               : Tmpg123_param;
  mpg123_getparam            : Tmpg123_getparam;
  mpg123_feature             : Tmpg123_feature;

var
  mpg123_plain_strerror      : Tmpg123_plain_strerror;
  mpg123_strerror            : Tmpg123_strerror;
  mpg123_errcode             : Tmpg123_errcode;
  mpg123_decoders            : Tmpg123_decoders;
  mpg123_supported_decoders  : Tmpg123_supported_decoders;
  mpg123_decoder             : Tmpg123_decoder;
  mpg123_current_decoder     : Tmpg123_current_decoder;

var
  mpg123_rates               : Tmpg123_rates;
  mpg123_encodings           : Tmpg123_encodings;
  mpg123_encsize             : Tmpg123_encsize;
  mpg123_format_none         : Tmpg123_format_none;
  mpg123_format_all          : Tmpg123_format_all;
  mpg123_format              : Tmpg123_format;
  mpg123_format_support      : Tmpg123_format_support;
  mpg123_getformat	     : Tmpg123_getformat;

(** \defgroup mpg123_input mpg123 file input and decoding
 * Functions for input bitstream and decoding operations. *)
var
  mpg123_open		     : Tmpg123_open;
  mpg123_open_fd	     : Tmpg123_open_fd;
  mpg123_open_feed	     : Tmpg123_open_feed;
  mpg123_close		     : Tmpg123_close;
  mpg123_read		     : Tmpg123_read;
  mpg123_feed                : Tmpg123_feed;
  mpg123_decode		     : Tmpg123_decode;
  mpg123_decode_frame	     : Tmpg123_decode_frame;
  mpg123_tell                : Tmpg123_tell;
  mpg123_tellframe           : Tmpg123_tellframe;
  mpg123_tell_stream         : Tmpg123_tell_stream;
  mpg123_seek                : Tmpg123_seek;
  mpg123_feedseek            : Tmpg123_feedseek;
  mpg123_seek_frame          : Tmpg123_seek_frame;
  mpg123_timeframe           : Tmpg123_timeframe;
  mpg123_index               : Tmpg123_index;
  mpg123_position            : Tmpg123_position;

(** \defgroup mpg123_voleq mpg123 volume and equalizer **)
var
  mpg123_eq                  : Tmpg123_eq;
  mpg123_geteq               : Tmpg123_geteq;
  mpg123_reset_eq            : Tmpg123_reset_eq;
  mpg123_volume              : Tmpg123_volume;
  mpg123_volume_change       : Tmpg123_volume_change;
  mpg123_getvolume           : Tmpg123_getvolume;

(** \defgroup mpg123_status mpg123 status and information **)
var
  mpg123_info                : Tmpg123_info;
  mpg123_safe_buffer         : Tmpg123_safe_buffer;
  mpg123_scan                : Tmpg123_scan;
  mpg123_length              : Tmpg123_length;
  mpg123_set_filesize        : Tmpg123_set_filesize;
  mpg123_tpf                 : Tmpg123_tpf;
  mpg123_clip                : Tmpg123_clip;
  mpg123_getstate            : Tmpg123_getstate;

(** \defgroup mpg123_metadata mpg123 metadata handling *)
var
  mpg123_init_string         : Tmpg123_init_string;
  mpg123_free_string         : Tmpg123_free_string;
  mpg123_resize_string       : Tmpg123_resize_string;
  mpg123_grow_string         : Tmpg123_grow_string;
  mpg123_copy_string         : Tmpg123_copy_string;
  mpg123_add_string          : Tmpg123_add_string;
  mpg123_add_substring       : Tmpg123_add_substring;
  mpg123_set_string          : Tmpg123_set_string;
  mpg123_set_substring       : Tmpg123_set_substring;
  mpg123_strlen              : Tmpg123_strlen;

var
  mpg123_enc_from_id3        : Tmpg123_enc_from_id3;
  mpg123_store_utf8          : Tmpg123_store_utf8;

var
  mpg123_meta_check          : Tmpg123_meta_check;
  mpg123_id3                 : Tmpg123_id3;
  mpg123_icy                 : Tmpg123_icy;
  mpg123_icy2utf8            : Tmpg123_icy2utf8;

(** \defgroup mpg123_advpar mpg123 advanced parameter API *)
var
  mpg123_parnew              : Tmpg123_parnew;
  mpg123_new_pars            : Tmpg123_new_pars;
  mpg123_delete_pars         : Tmpg123_delete_pars;
  mpg123_fmt_none            : Tmpg123_fmt_none;
  mpg123_fmt_all             : Tmpg123_fmt_all;
  mpg123_fmt                 : Tmpg123_fmt;
  mpg123_fmt_support         : Tmpg123_fmt_support;
  mpg123_par                 : Tmpg123_par;
  mpg123_getpar              : Tmpg123_getpar;
  mpg123_replace_buffer      : Tmpg123_replace_buffer;
  mpg123_outblock            : Tmpg123_outblock;
  //mpg123_replace_reader : function(mh:Tmpg123_handle; r_read:function (_para1:longint; _para2:pointer; _para3:size_t):Tssize_t; r_lseek:function (_para1:longint; _para2:off_t; _para3:longint):off_t):longint;



   {Special function for dynamic loading of lib ...}

       var Mp_Handle:TLibHandle; // this will hold our handle for the lib; it functions nicely as a mutli-lib prevention unit as well...

     Function Mp_Load(const libfilename:string) :boolean; // load the lib

       function Mp_Unload() : boolean; // unload and frees the lib from memory : do not forget to call it before close application.

implementation


function  mp_unload():boolean;
begin
   if Mp_Handle<>DynLibs.NilHandle then
     begin
            DynLibs.UnloadLibrary(Mp_Handle);
     end;
  Mp_Handle:=DynLibs.NilHandle;

end;

 function Mp_Load (const libfilename:string) :boolean;

  begin
  Result := False;
  if Mp_Handle<>0 then result:=true {is it already there ?}
  else begin {go & load the library}
    if Length(libfilename) = 0 then exit;
    Mp_Handle:=DynLibs.LoadLibrary(libfilename); // obtain the handle we want
  	if Mp_Handle <> DynLibs.NilHandle then

    begin
      mpg123_init:=        Tmpg123_init( GetProcAddress(Mp_Handle, 'mpg123_init'));
      mpg123_exit:=        Tmpg123_exit( GetProcAddress(Mp_Handle, 'mpg123_exit'));
      mpg123_new:= 	       Tmpg123_new( GetProcAddress(Mp_Handle, 'mpg123_new'));
      mpg123_delete:=      Tmpg123_delete( GetProcAddress(Mp_Handle, 'mpg123_delete'));
      mpg123_param:=       Tmpg123_param( GetProcAddress(Mp_Handle, 'mpg123_param'));
      mpg123_getparam:=    Tmpg123_getparam( GetProcAddress(Mp_Handle, 'mpg123_getparam'));
      mpg123_plain_strerror:= Tmpg123_plain_strerror( GetProcAddress(Mp_Handle, 'mpg123_plain_strerror'));
      mpg123_strerror:=    Tmpg123_strerror( GetProcAddress(Mp_Handle, 'mpg123_strerror'));
      mpg123_errcode:=     Tmpg123_errcode( GetProcAddress(Mp_Handle, 'mpg123_errcode'));
      mpg123_decoders:=    Tmpg123_decoders( GetProcAddress(Mp_Handle, 'mpg123_decoders'));
      mpg123_supported_decoders:= Tmpg123_supported_decoders( GetProcAddress(Mp_Handle, 'mpg123_supported_decoders'));
      mpg123_decoder:=     Tmpg123_decoder( GetProcAddress(Mp_Handle, 'mpg123_decoder'));
      mpg123_rates:=       Tmpg123_rates( GetProcAddress(Mp_Handle, 'mpg123_rates'));
      mpg123_encodings:=   Tmpg123_encodings( GetProcAddress(Mp_Handle, 'mpg123_encodings'));
      mpg123_format_none:= Tmpg123_format_none( GetProcAddress(Mp_Handle, 'mpg123_format_none'));
      mpg123_format_all:=  Tmpg123_format_all( GetProcAddress(Mp_Handle, 'mpg123_format_all'));
      mpg123_format:=      Tmpg123_format( GetProcAddress(Mp_Handle, 'mpg123_format'));
      mpg123_format_support:= Tmpg123_format_support( GetProcAddress(Mp_Handle, 'mpg123_format_support'));
      mpg123_getformat:=   Tmpg123_getformat( GetProcAddress(Mp_Handle, 'mpg123_getformat'));
      mpg123_open:=        Tmpg123_open( GetProcAddress(Mp_Handle, 'mpg123_open'));
      mpg123_open_fd:=     Tmpg123_open_fd( GetProcAddress(Mp_Handle, 'mpg123_open_fd'));
      mpg123_open_feed:=   Tmpg123_open_feed( GetProcAddress(Mp_Handle, 'mpg123_open_feed'));
      mpg123_close:=       Tmpg123_close( GetProcAddress(Mp_Handle, 'mpg123_close'));
      mpg123_read:=        Tmpg123_read( GetProcAddress(Mp_Handle, 'mpg123_read'));
      mpg123_decode:=      Tmpg123_decode( GetProcAddress(Mp_Handle, 'mpg123_decode'));
      mpg123_decode_frame:= Tmpg123_decode_frame( GetProcAddress(Mp_Handle, 'mpg123_decode_frame'));
      mpg123_tell:=        Tmpg123_tell( GetProcAddress(Mp_Handle, 'mpg123_tell'));
      mpg123_tellframe:=   Tmpg123_tellframe( GetProcAddress(Mp_Handle, 'mpg123_tellframe'));
      mpg123_seek:=        Tmpg123_seek( GetProcAddress(Mp_Handle, 'mpg123_seek'));
      mpg123_feedseek:=    Tmpg123_feedseek( GetProcAddress(Mp_Handle, 'mpg123_feedseek'));
      mpg123_seek_frame:=  Tmpg123_seek_frame( GetProcAddress(Mp_Handle, 'mpg123_seek_frame'));
      mpg123_timeframe:=   Tmpg123_timeframe( GetProcAddress(Mp_Handle, 'mpg123_timeframe'));
      mpg123_index:=       Tmpg123_index( GetProcAddress(Mp_Handle, 'mpg123_index'));
      mpg123_position:=    Tmpg123_position( GetProcAddress(Mp_Handle, 'mpg123_position'));
      mpg123_eq:=          Tmpg123_eq( GetProcAddress(Mp_Handle, 'mpg123_eq'));
      mpg123_reset_eq:=    Tmpg123_reset_eq( GetProcAddress(Mp_Handle, 'mpg123_reset_eq'));
      mpg123_volume:=      Tmpg123_volume( GetProcAddress(Mp_Handle, 'mpg123_volume'));
      mpg123_volume_change:= Tmpg123_volume_change( GetProcAddress(Mp_Handle, 'mpg123_volume_change'));
      mpg123_getvolume:=   Tmpg123_getvolume( GetProcAddress(Mp_Handle, 'mpg123_getvolume'));
      mpg123_info:=        Tmpg123_info( GetProcAddress(Mp_Handle, 'mpg123_info'));
      mpg123_safe_buffer:= Tmpg123_safe_buffer( GetProcAddress(Mp_Handle, 'mpg123_safe_buffer'));
      mpg123_scan:=        Tmpg123_scan( GetProcAddress(Mp_Handle, 'mpg123_scan'));
      mpg123_length:=      Tmpg123_length( GetProcAddress(Mp_Handle, 'mpg123_length'));
      mpg123_tpf:=         Tmpg123_tpf( GetProcAddress(Mp_Handle, 'mpg123_tpf'));
      mpg123_clip:=        Tmpg123_clip( GetProcAddress(Mp_Handle, 'mpg123_clip'));
      mpg123_init_string:= Tmpg123_init_string( GetProcAddress(Mp_Handle, 'mpg123_init_string'));
      mpg123_free_string:= Tmpg123_free_string( GetProcAddress(Mp_Handle, 'mpg123_free_string'));
      mpg123_resize_string:= Tmpg123_resize_string( GetProcAddress(Mp_Handle, 'mpg123_resize_string'));
      mpg123_copy_string:= Tmpg123_copy_string( GetProcAddress(Mp_Handle, 'mpg123_copy_string'));
      mpg123_add_string:=  Tmpg123_add_string( GetProcAddress(Mp_Handle, 'mpg123_add_string'));
      mpg123_set_string:=  Tmpg123_set_string( GetProcAddress(Mp_Handle, 'mpg123_set_string'));
      mpg123_meta_check:=  Tmpg123_meta_check( GetProcAddress(Mp_Handle, 'mpg123_meta_check'));
      mpg123_id3:=         Tmpg123_id3( GetProcAddress(Mp_Handle, 'mpg123_id3'));
      mpg123_icy:=         Tmpg123_icy( GetProcAddress(Mp_Handle, 'mpg123_icy'));
      mpg123_parnew:=      Tmpg123_parnew( GetProcAddress(Mp_Handle, 'mpg123_parnew'));
      mpg123_new_pars:=    Tmpg123_new_pars( GetProcAddress(Mp_Handle, 'mpg123_new_pars'));
      mpg123_delete_pars:= Tmpg123_delete_pars( GetProcAddress(Mp_Handle, 'mpg123_delete_pars'));
      mpg123_fmt_none:=    Tmpg123_fmt_none( GetProcAddress(Mp_Handle, 'mpg123_fmt_none'));
      mpg123_fmt_all:=     Tmpg123_fmt_all( GetProcAddress(Mp_Handle, 'mpg123_fmt_all'));
      mpg123_fmt:=         Tmpg123_fmt( GetProcAddress(Mp_Handle, 'mpg123_fmt'));
      mpg123_fmt_support:= Tmpg123_fmt_support( GetProcAddress(Mp_Handle, 'mpg123_fmt_support'));
      mpg123_par:=         Tmpg123_par( GetProcAddress(Mp_Handle, 'mpg123_par'));
      mpg123_getpar:=      Tmpg123_getpar( GetProcAddress(Mp_Handle, 'mpg123_getpar'));
      mpg123_replace_buffer:= Tmpg123_replace_buffer( GetProcAddress(Mp_Handle, 'mpg123_replace_buffer'));
      mpg123_outblock:=    Tmpg123_outblock( GetProcAddress(Mp_Handle, 'mpg123_outblock'));
      // FixMe:
      //mpg123_replace_reader := GetProcAddress(hlib,'mpg123_replace_reader');
    end;
   result:=(Mp_Handle<>DynLibs.NilHandle);
end;
  end;

end.
