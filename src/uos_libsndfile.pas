{This unit is part of United Openlibraries of Sound (uos)}

{This is the Dynamic loading version with reference counting of LibSndFile.pas.
 Load the library with sf_load() and release with sf_unload().
 Thanks to Phoenix for sf_open_virtual (TMemoryStream as input)
 License : modified LGPL.
 Fred van Stappen / fiens@hotmail.com }

unit uos_libsndfile;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
  {$PACKENUM 4}(* use 4-byte enums *)
  {$PACKRECORDS C}(* C/C++-compatible record packing *)
  {$MACRO ON}//don't know whatfor !
{$ELSE}
  {$MINENUMSIZE 4}(* use 4-byte enums *)
{** MINENUMSIZE is equivalent to Z+}
{$ENDIF}

{$LONGSTRINGS ON}
{** LONGSTRINGS is equivalent to H+}

interface

uses
  dynlibs, classes,
  ctypes;

const
libsf=
 {$IFDEF unix}
 {$IFDEF darwin}
 'libsndfile.1.dylib';
  {$ELSE}
 'libsndfile.so.1';
  {$ENDIF}    
  {$ELSE}
 'sndfile.dll';
  {$ENDIF}    
  
type   
  PMemoryStream = ^TMemoryStream;
 
type 
 {$IF Defined(MSWINDOWS)} 
  off_t = int64;
  {$ELSE}  
  off_t    = clonglong;  
  size_t   = culong; 
  {$ENDIF} 

const
  //* Major formats. *//
  SF_FORMAT_WAV = $010000;    // Microsoft WAV format (little endian default).
  SF_FORMAT_AIFF = $020000;    // Apple/SGI AIFF format (big endian).
  SF_FORMAT_AU = $030000;    // Sun/NeXT AU format (big endian).
  SF_FORMAT_RAW = $040000;    // RAW PCM data.
  SF_FORMAT_PAF = $050000;    // Ensoniq PARIS file format.
  SF_FORMAT_SVX = $060000;    // Amiga IFF / SVX8 / SV16 format.
  SF_FORMAT_NIST = $070000;    // Sphere NIST format.
  SF_FORMAT_VOC = $080000;    // VOC files.
  SF_FORMAT_IRCAM = $0A0000;    // Berkeley/IRCAM/CARL
  SF_FORMAT_W64 = $0B0000;    // Sonic Foundry's 64 bit RIFF/WAV
  SF_FORMAT_MAT4 = $0C0000;    // Matlab (tm) V4.2 / GNU Octave 2.0
  SF_FORMAT_MAT5 = $0D0000;    // Matlab (tm) V5.0 / GNU Octave 2.1
  SF_FORMAT_PVF = $0E0000;    // Portable Voice Format
  SF_FORMAT_XI = $0F0000;    // Fasttracker 2 Extended Instrument
  SF_FORMAT_HTK = $100000;    // HMM Tool Kit format
  SF_FORMAT_SDS = $110000;    // Midi Sample Dump Standard
  SF_FORMAT_AVR = $120000;    // Audio Visual Research
  SF_FORMAT_WAVEX = $130000;    // MS WAVE with WAVEFORMATEX
  SF_FORMAT_SD2 = $160000;    // Sound Designer 2
  SF_FORMAT_FLAC = $170000;    // FLAC lossless file format
  SF_FORMAT_CAF = $180000;    // Core Audio File format

const
  //Subtypes from here on.
  SF_FORMAT_PCM_S8 = $0001;    // Signed 8 bit data
  SF_FORMAT_PCM_16 = $0002;    // Signed 16 bit data
  SF_FORMAT_PCM_24 = $0003;    // Signed 24 bit data
  SF_FORMAT_PCM_32 = $0004;    // Signed 32 bit data

  SF_FORMAT_PCM_U8 = $0005;    // Unsigned 8 bit data (WAV and RAW only)

  SF_FORMAT_FLOAT = $0006;    // 32 bit float data
  SF_FORMAT_DOUBLE = $0007;    // 64 bit float data

  SF_FORMAT_ULAW = $0010;    // U-Law encoded.
  SF_FORMAT_ALAW = $0011;    // A-Law encoded.
  SF_FORMAT_IMA_ADPCM = $0012;    // IMA ADPCM.
  SF_FORMAT_MS_ADPCM = $0013;    // Microsoft ADPCM.

  SF_FORMAT_GSM610 = $0020;    // GSM 6.10 encoding.
  SF_FORMAT_VOX_ADPCM = $0021;    // OKI / Dialogix ADPCM

  SF_FORMAT_G721_32 = $0030;    // 32kbs G721 ADPCM encoding.
  SF_FORMAT_G723_24 = $0031;    // 24kbs G723 ADPCM encoding.
  SF_FORMAT_G723_40 = $0032;    // 40kbs G723 ADPCM encoding.

  SF_FORMAT_DWVW_12 = $0040;    // 12 bit Delta Width Variable Word encoding.
  SF_FORMAT_DWVW_16 = $0041;    // 16 bit Delta Width Variable Word encoding.
  SF_FORMAT_DWVW_24 = $0042;    // 24 bit Delta Width Variable Word encoding.
  SF_FORMAT_DWVW_N = $0043;    // N bit Delta Width Variable Word encoding.

  SF_FORMAT_DPCM_8 = $0050;    // 8 bit differential PCM (XI only)
  SF_FORMAT_DPCM_16 = $0051;    // 16 bit differential PCM (XI only)

const
  //* Endian-ness options. *//
  SF_ENDIAN_FILE = $00000000;  // Default file endian-ness.
  SF_ENDIAN_LITTLE = $10000000;  // Force little endian-ness.
  SF_ENDIAN_BIG = $20000000;  // Force big endian-ness.
  SF_ENDIAN_CPU = $30000000;  // Force CPU endian-ness.

  SF_FORMAT_SUBMASK = $0000FFFF;
  SF_FORMAT_TYPEMASK = $0FFF0000;
  SF_FORMAT_ENDMASK = $30000000;

{
** The following are the valid command numbers for the sf_command()
** interface.  The use of these commands is documented in the file
** command.html in the doc directory of the source code distribution.
}
const
  SFC_GET_LIB_VERSION = $1000;
  SFC_GET_LOG_INFO = $1001;

  SFC_GET_NORM_DOUBLE = $1010;
  SFC_GET_NORM_FLOAT = $1011;
  SFC_SET_NORM_DOUBLE = $1012;
  SFC_SET_NORM_FLOAT = $1013;
  SFC_SET_SCALE_FLOAT_INT_READ = $1014;

  SFC_GET_SIMPLE_FORMAT_COUNT = $1020;
  SFC_GET_SIMPLE_FORMAT = $1021;

  SFC_GET_FORMAT_INFO = $1028;

  SFC_GET_FORMAT_MAJOR_COUNT = $1030;
  SFC_GET_FORMAT_MAJOR = $1031;
  SFC_GET_FORMAT_SUBTYPE_COUNT = $1032;
  SFC_GET_FORMAT_SUBTYPE = $1033;

  SFC_CALC_SIGNAL_MAX = $1040;
  SFC_CALC_NORM_SIGNAL_MAX = $1041;
  SFC_CALC_MAX_ALL_CHANNELS = $1042;
  SFC_CALC_NORM_MAX_ALL_CHANNELS = $1043;
  SFC_GET_SIGNAL_MAX = $1044;
  SFC_GET_MAX_ALL_CHANNELS = $1045;

  SFC_SET_ADD_PEAK_CHUNK = $1050;

  SFC_UPDATE_HEADER_NOW = $1060;
  SFC_SET_UPDATE_HEADER_AUTO = $1061;

  SFC_FILE_TRUNCATE = $1080;

  SFC_SET_RAW_START_OFFSET = $1090;

  SFC_SET_DITHER_ON_WRITE = $10A0;
  SFC_SET_DITHER_ON_READ = $10A1;

  SFC_GET_DITHER_INFO_COUNT = $10A2;
  SFC_GET_DITHER_INFO = $10A3;

  SFC_GET_EMBED_FILE_INFO = $10B0;

  SFC_SET_CLIPPING = $10C0;
  SFC_GET_CLIPPING = $10C1;

  SFC_GET_INSTRUMENT = $10D0;
  SFC_SET_INSTRUMENT = $10D1;

  SFC_GET_LOOP_INFO = $10E0;

  SFC_GET_BROADCAST_INFO = $10F0;
  SFC_SET_BROADCAST_INFO = $10F1;

  // Following commands for testing only.
  SFC_TEST_IEEE_FLOAT_REPLACE = $6001;

  {
  ** SFC_SET_ADD_* values are deprecated and will disappear at some
  ** time in the future. They are guaranteed to be here up to and
  ** including version 1.0.8 to avoid breakage of existing software.
  ** They currently do nothing and will continue to do nothing.
  }
  SFC_SET_ADD_DITHER_ON_WRITE = $1070;
  SFC_SET_ADD_DITHER_ON_READ = $1071;

{
** String types that can be set and read from files. Not all file types
** support this and even the file types which support one, may not support
** all string types.
}
const
  SF_STR_TITLE = $01;
  SF_STR_COPYRIGHT = $02;
  SF_STR_SOFTWARE = $03;
  SF_STR_ARTIST = $04;
  SF_STR_COMMENT = $05;
  SF_STR_DATE = $06;

{
** Use the following as the start and end index when doing metadata
** transcoding.
}
  SF_STR_FIRST = SF_STR_TITLE;
  SF_STR_LAST = SF_STR_DATE;

const
  // True and false
  SF_FALSE = 0;
  SF_TRUE = 1;

const
  // Modes for opening files.
  SFM_READ = $10;
  SFM_WRITE = $20;
  SFM_RDWR = $30;

{
** Public error values. These are guaranteed to remain unchanged
** for the duration of the library major version number.
** There are also a large number of private error numbers which are
** internal to the library which can change at any time.
}
const
  SF_ERR_NO_ERROR = 0;
  SF_ERR_UNRECOGNISED_FORMAT = 1;
  SF_ERR_SYSTEM = 2;
  SF_ERR_MALFORMED_FILE = 3;
  SF_ERR_UNSUPPORTED_ENCODING = 4;

//A SNDFILE* pointer can be passed around much like stdio.h's FILE* pointer.

type
  TSNDFILE_HANDLE = pointer;  // this is not a usual pointer, more like a THandle ..
// so NOT called  "PSndFile_handle"
// => we never access members of the internal
//    structure where the pointer points to !
//    Everything is managed by the DLL internally !!!
//PSNDFILE_tag = PSNDFILE;

  {
** The following typedef is system specific and is defined when libsndfile is.
** compiled. uos_count_t can be one of loff_t (Linux), off_t (*BSD),
** off64_t (Solaris), __int64_t (Win32) etc.
}
type
  Puos_count_t = ^Tuos_count_t;
  Tuos_count_t = off_t;

const
  SF_COUNT_MAX = ctypes.clong($7FFFFFFFFFFFFFFF);

{
** A pointer to a SF_INFO structure is passed to sf_open_read () and filled in.
** On write, the SF_INFO structure is filled in by the user and passed into
** sf_open_write ().
}

type
  PSF_INFO = ^TSF_INFO;

  TSF_INFO = record
    frames: Tuos_count_t;
    // Used to be called samples.  Changed to avoid confusion.
    samplerate: ctypes.cint;
    channels: ctypes.cint;
    format: ctypes.cint;
    sections: ctypes.cint;
    seekable: ctypes.cint;
  end;

{
** The SF_FORMAT_INFO struct is used to retrieve information about the sound
** file formats libsndfile supports using the sf_command () interface.
**
** Using this interface will allow applications to support new file formats
** and encoding types when libsndfile is upgraded, without requiring
** re-compilation of the application.
**
** Please consult the libsndfile documentation (particularly the information
** on the sf_command () interface) for examples of its use.
}

type
  PSF_FORMAT_INFO = ^TSF_FORMAT_INFO;

  TSF_FORMAT_INFO = record
    format: ctypes.cint;
    Name: ctypes.pcchar;
    extention: ctypes.pcchar;
  end;

{
** Enums and typedefs for adding dither on read and write.
** See the html documentation for sf_command(), SFC_SET_DITHER_ON_WRITE
** and SFC_SET_DITHER_ON_READ.
}
const
  SFD_DEFAULT_LEVEL = 0;
  SFD_CUSTOM_LEVEL = $40000000;

  SFD_NO_DITHER = 500;
  SFD_WHITE = 501;
  SFD_TRIANGULAR_PDF = 502;

type
  PSF_DITHER_INFO = ^TSF_DITHER_INFO;

  TSF_DITHER_INFO = record
    type_: ctypes.cint;
    level: ctypes.cdouble;
    Name: ctypes.pcchar;
  end;

{
** Struct used to retrieve information about a file embedded within a
** larger file. See SFC_GET_EMBED_FILE_INFO.
}
type
  PSF_EMBED_FILE_INFO = ^TSF_EMBED_FILE_INFO;

  TSF_EMBED_FILE_INFO = record
    offset: Tuos_count_t;
    length: Tuos_count_t;
  end;

// Structs used to retrieve music sample information from a file.

const
  // The loop mode field in SF_INSTRUMENT will be one of the following.
  SF_LOOP_NONE = 800;
  SF_LOOP_FORWARD = 801;
  SF_LOOP_BACKWARD = 802;
  SF_LOOP_ALTERNATING = 803;

type
  PSF_INSTRUMENT = ^TSF_INSTRUMENT;

  TSF_INSTRUMENT = record
    gain: ctypes.cint;
    basenote,
    detune: ctypes.cchar;
    velocity_lo,
    velocity_hi: ctypes.cchar;
    loop_count: ctypes.cint;
    loops: array[0..15] of record
      mode: ctypes.cint;
      start: ctypes.cuint;
      end_: ctypes.cuint;
      Count: ctypes.cuint;
    end;
  end;

// Struct used to retrieve loop information from a file.
type
  PSF_LOOP_INFO = ^TSF_LOOP_INFO;

  TSF_LOOP_INFO = record
    time_sig_num: ctypes.cushort;
    // any positive integer    > 0
    time_sig_den: ctypes.cushort;
    // any positive power of 2 > 0
    loop_mode: ctypes.cint;                // see SF_LOOP enum

    num_beats: ctypes.cint;
    // this is NOT the amount of quarter notes !!!
    // a full bar of 4/4 is 4 beats
    // a full bar of 7/8 is 7 beats

    bpm: ctypes.cfloat;
    // suggestion, as it can be calculated using other fields:
    // file's lenght, file's sampleRate and our time_sig_den
    // -> bpms are always the amount of _quarter notes_ per minute

    root_key: ctypes.cint;
    // MIDI note, or -1 for None
    future: array[0..5] of ctypes.cint;
  end;


{
**  Struct used to retrieve broadcast (EBU) information from a file.
**  Strongly (!) based on EBU "bext" chunk format used in Broadcast WAVE.
}
type
  PSF_BROADCAST_INFO = ^TSF_BROADCAST_INFO;

  TSF_BROADCAST_INFO = record
    description: array[0..255] of char;//ctypes.cchar;
    originator: array[0..31] of char;//ctypes.cchar;
    originator_reference: array[0..31] of char;//ctypes.cchar;
    origination_date: array[0..9] of char;//ctypes.cchar;
    origination_time: array[0..7] of char;//ctypes.cchar;
    time_reference_low: ctypes.cuint;//ctypes.cint;
    time_reference_high: ctypes.cuint;//ctypes.cint;
    version: ctypes.cshort;
    umid: array[0..63] of char;//ctypes.cchar;
    reserved: array[0..189] of char;//ctypes.cchar;
    coding_history_size: ctypes.cuint;
    coding_history: array[0..255] of char;//ctypes.cchar;
  end;

 // Thanks to Phoenix
 type
 //pm_get_filelen = ^tm_get_filelen;
 tm_get_filelen =
  function (pms: PMemoryStream): Tuos_count_t; cdecl; 
 //pm_seek = ^tm_seek;
 tm_seek =
  function (offset: Tuos_count_t; whence: cint32; pms: PMemoryStream): Tuos_count_t; cdecl; 
 //pm_read = ^tm_read;
 tm_read =
  function (const buf: Pointer; count: Tuos_count_t; pms: PMemoryStream): Tuos_count_t; cdecl; 
 //pm_write = ^tm_write;
 tm_write =
  function (const buf: Pointer; count: Tuos_count_t; pms: PMemoryStream): Tuos_count_t; cdecl; 
 //pm_tell = ^tm_tell;
 tm_tell =
  function (pms: PMemoryStream): Tuos_count_t; cdecl; 
 
 TSF_VIRTUAL = packed record
  sf_vio_get_filelen  : tm_get_filelen;
  seek         : tm_seek;
  read         : tm_read;
  write        : tm_write;
  tell         : tm_tell;
 end;
 
 PSF_VIRTUAL = ^TSF_VIRTUAL;  
 
{
** Open the specified file for read, write or both. On error, this will
** return a NULL pointer. To find the error number, pass a NULL SNDFILE
** to sf_perror () or sf_error_str ().
** All calls to sf_open() should be matched with a call to sf_close().
}
////////////////////////////////////////////////////////////////////////////////////////

function sf_open(path: string; mode: ctypes.cint;
  var sfinfo: TSF_INFO): TSNDFILE_HANDLE;

////// Dynamic load : Vars that will hold our dynamically loaded functions..
var
  sf_open_native: function(path: PChar;
  mode: ctypes.cint; sfinfo: PSF_INFO): TSNDFILE_HANDLE; cdecl;

var
sf_version_string: function(): PChar; cdecl;

var
  sf_open_fd: function(fd: ctypes.cint; mode: ctypes.cint; sfinfo: PSF_INFO;
  close_desc: ctypes.cint): TSNDFILE_HANDLE; cdecl;

var
  sf_open_virtual: function(sfvirtual: PSF_VIRTUAL; mode: ctypes.cint;
  sfinfo: PSF_INFO; user_data: Pointer): TSNDFILE_HANDLE; cdecl;

var
  sf_error: function(sndfile: TSNDFILE_HANDLE): ctypes.cint; cdecl;

var
  sf_strerror: function(sndfile: TSNDFILE_HANDLE): PChar; cdecl;

var
  sf_error_number: function(errnum: ctypes.cint): PChar; cdecl;

var
  sf_perror: function(sndfile: TSNDFILE_HANDLE): ctypes.cint; cdecl;

var
  sf_error_str: function(sndfile: TSNDFILE_HANDLE;
  str: ctypes.pcchar; len: size_t): ctypes.cint; cdecl;

{
 In libsndfile there are 4 functions with the same name (sf_command), 3 of them use the parameter "overload".
 In dynamic loading (because of var) we use 4 different names for the 4 functions sf_command :
 sf_command_pointer, sf_command_double, sf_command_array, sf_command_tsf. All that 4 functions gonna point
 to sf_command in libsndfile library.
}

var
  sf_command_pointer: function(sndfile: TSNDFILE_HANDLE; command: ctypes.cint;
  Data: Pointer; datasize: ctypes.cint): ctypes.cint; cdecl;

var
  sf_command_double: function(sndfile: TSNDFILE_HANDLE; command: ctypes.cint;
  var Data: double; datasize: ctypes.cint): ctypes.cint; cdecl;

var
  sf_command_array: function(sndfile: TSNDFILE_HANDLE; command: ctypes.cint;
  var Data: array of char; datasize: ctypes.cint): ctypes.cint; cdecl;

var
  sf_command_tsf: function(sndfile: TSNDFILE_HANDLE; command: ctypes.cint;
  var Data: TSF_BROADCAST_INFO; datasize: ctypes.cint): ctypes.cint; cdecl;

var
  sf_format_check: function(var info: TSF_INFO): ctypes.cint; cdecl;

{
** Seek within the waveform data chunk of the SNDFILE. sf_seek () uses
** the same values for whence (SEEK_SET, SEEK_CUR and SEEK_END) as
** stdio.h function fseek ().
** An offset of zero with whence set to SEEK_SET will position the
** read / write pointer to the first data sample.
** On success sf_seek returns the current position in (multi-channel)
** samples from the start of the file.
** Please see the libsndfile documentation for moving the read pointer
** separately from the write pointer on files open in mode SFM_RDWR.
** On error all of these functions return -1.
}

//the following CONST values originally are NOT in libsndfile.pas:
const
  SEEK_SET = 0;       //* seek relative to beginning of file */

const
  SEEK_CUR = 1;       //* seek relative to current file position */

const
  SEEK_END = 2;       //* seek relative to end of file */

const
  SEEK_DATA = 3;       //* seek to the next data */

const
  SEEK_HOLE = 4;       //* seek to the next hole */

const
  SEEK_MAX = SEEK_HOLE;

var
  sf_seek: function(sndfile: TSNDFILE_HANDLE; frame: Tuos_count_t;
  whence: ctypes.cint): Tuos_count_t; cdecl;

{
** Functions for retrieving and setting string data within sound files.
** Not all file types support this features; AIFF and WAV do. For both
** functions, the str_type parameter must be one of the SF_STR_* values
** defined above.
** On error, sf_set_string() returns non-zero while sf_get_string()
** returns NULL.
}
var
  sf_set_string: function(sndfile: TSNDFILE_HANDLE; str_type: ctypes.cint;
  str: ctypes.pcchar): ctypes.cint; cdecl;

var
  sf_get_string: function(sndfile: TSNDFILE_HANDLE;
  str_type: ctypes.cint): PChar; cdecl;

var
  sf_read_raw: function(sndfile: TSNDFILE_HANDLE; ptr: Pointer;
  bytes: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_write_raw: function(sndfile: TSNDFILE_HANDLE; ptr: Pointer;
  bytes: Tuos_count_t): Tuos_count_t; cdecl;

{
** Functions for reading and writing the data chunk in terms of frames.
** The number of items actually read/written = frames * number of channels.
**     sf_xxxx_raw  read/writes the raw data bytes from/to the file
**     sf_xxxx_short  passes data in the native short format
**     sf_xxxx_int  passes data in the native int format
**     sf_xxxx_float  passes data in the native float format
**     sf_xxxx_double  passes data in the native double format
** All of these read/write function return number of frames read/written.
}
var
  sf_readf_short: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcshort;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_writef_short: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcshort;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_readf_int: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcint;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_writef_int: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcint;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_readf_float: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcfloat;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_writef_float: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcfloat;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_readf_double: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcdouble;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_writef_double: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcdouble;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

{
** Functions for reading and writing the data chunk in terms of items.
** Otherwise similar to above.
** All of these read/write function return number of items read/written.
}
var
  sf_read_short: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcshort;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_write_short: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcshort;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_read_int: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcint;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_write_int: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcint;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_read_float: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcfloat;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_write_float: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcfloat;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_read_double: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcdouble;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

var
  sf_write_double: function(sndfile: TSNDFILE_HANDLE; ptr: ctypes.pcdouble;
  frames: Tuos_count_t): Tuos_count_t; cdecl;

{
** Close the SNDFILE and clean up all memory allocations associated
** with this file.
** Returns 0 on success, or an error number.
}
var
  sf_close: function(sndfile: TSNDFILE_HANDLE): ctypes.cint; cdecl;

{
** If the file is opened SFM_WRITE or SFM_RDWR, call fsync() on the file
** to force the writing of data to disk. If the file is opened SFM_READ
** no action is taken.
}
var
  sf_write_sync: function(sndfile: TSNDFILE_HANDLE): ctypes.cint; cdecl;

{Special function for dynamic loading of lib ...}

var
  sf_Handle: TLibHandle;
// this will hold our handle for the lib; it functions nicely as a mutli-lib prevention unit as well...

function sf_Load(const libfilename: string): boolean; // load the lib

procedure sf_Unload();
// unload and frees the lib from memory : do not forget to call it before close application.

function sf_IsLoaded: boolean; inline;

implementation

var
  ReferenceCounter: cardinal = 0;  // Reference counter

function sf_Load(const libfilename: string): boolean;
var
thelib: string; 
begin
  Result := False;
  if sf_Handle <> 0 then
  begin
    Result := True {is it already there ?};
    //Reference counting
    Inc(ReferenceCounter);
  end
  else
  begin {go & load the library}
   if Length(libfilename) = 0 then thelib := libsf else thelib := libfilename;
    sf_Handle := DynLibs.SafeLoadLibrary(thelib); // obtain the handle we want
    if sf_Handle <> DynLibs.NilHandle then
    begin {now we tie the functions to the VARs from above}
      
      Pointer(sf_version_string) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_version_string'));
      Pointer(sf_open_native) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_open'));
      Pointer(sf_open_fd) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_open_fd'));
      Pointer(sf_open_virtual) := DynLibs.GetProcedureAddress(
        sf_Handle, PChar('sf_open_virtual'));
      Pointer(sf_error) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_error'));
      Pointer(sf_strerror) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_strerror'));
      Pointer(sf_error_number) := DynLibs.GetProcedureAddress(
        sf_Handle, PChar('sf_error_number'));
      Pointer(sf_perror) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_perror'));
      Pointer(sf_error_str) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_error_str'));
      Pointer(sf_command_pointer) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_command'));
      Pointer(sf_command_array) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_command'));
      Pointer(sf_command_double) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_command'));
      Pointer(sf_command_tsf) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_command'));
      Pointer(sf_format_check) := DynLibs.GetProcedureAddress(
        sf_Handle, PChar('sf_format_check'));
      Pointer(sf_seek) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_seek'));
      Pointer(sf_set_string) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_set_string'));
      Pointer(sf_get_string) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_get_string'));
      Pointer(sf_read_raw) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_read_raw'));
      Pointer(sf_write_raw) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_write_raw'));
      Pointer(sf_readf_short) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_readf_short'));
      Pointer(sf_writef_short) := DynLibs.GetProcedureAddress(
        sf_Handle, PChar('sf_writef_short'));
      Pointer(sf_readf_int) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_readf_int'));
      Pointer(sf_writef_int) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_writef_int'));
      Pointer(sf_readf_float) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_readf_float'));
      Pointer(sf_writef_float) := DynLibs.GetProcedureAddress(
        sf_Handle, PChar('sf_writef_float'));
      Pointer(sf_readf_double) := DynLibs.GetProcedureAddress(
        sf_Handle, PChar('sf_readf_double'));
      Pointer(sf_writef_double) := DynLibs.GetProcedureAddress(
        sf_Handle, PChar('sf_writef_double'));
      Pointer(sf_read_short) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_read_short'));
      Pointer(sf_write_short) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_write_short'));
      Pointer(sf_read_int) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_read_int'));
      Pointer(sf_write_int) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_write_int'));
      Pointer(sf_read_float) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_read_float'));
      Pointer(sf_write_float) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_write_float'));
      Pointer(sf_read_double) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_read_double'));
      Pointer(sf_write_double) := DynLibs.GetProcedureAddress(
        sf_Handle, PChar('sf_write_double'));
      Pointer(sf_close) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_close'));
      Pointer(sf_write_sync) := DynLibs.GetProcedureAddress(sf_Handle, PChar('sf_write_sync'));

    end;
    Result := sf_IsLoaded;
    ReferenceCounter := 1;
  end;

end;

procedure sf_Unload;
begin
  // < Reference counting
  if ReferenceCounter > 0 then
    Dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >
  if sf_IsLoaded then
  begin
    DynLibs.UnloadLibrary(sf_Handle);
    sf_Handle := DynLibs.NilHandle;
  end;

end;

function sf_open(path: string; mode: ctypes.cint;
  var sfinfo: TSF_INFO): TSNDFILE_HANDLE;
begin
  Result := sf_open_native(PChar(path), mode, @sfinfo);
end;

function sf_IsLoaded: boolean;
begin
  Result := (sf_Handle <> dynlibs.NilHandle);
end;

end.
