unit uos_libxmp;

// by Fred vS | fiens@hotmail.com | 2024

{$mode objfpc}{$H+}
{$PACKRECORDS C}

interface

uses
  dynlibs,
  sysutils,
  CTypes;

const
  XMP_VERSION     = '4.6.0';
  XMP_VERCODE     = $040600;
  XMP_VER_MAJOR   = 4;
  XMP_VER_MINOR   = 6;
  XMP_VER_RELEASE = 0;

const
{$IFDEF windows}
  XMP_LIB_NAME = 'libxmp.dll'; 
{$ENDIF}
 
{$IFDEF unix} 
 {$IFDEF darwin}
  XMP_LIB_NAME = 'libxmp.dylib'; 
 {$ELSE}
  XMP_LIB_NAME    = 'libxmp.so.4.6.0';
 {$ENDIF}
{$ENDIF}

const
  XMP_NAME_SIZE     = 64;

  // Note event constants
  XMP_KEY_OFF       = $81;
  XMP_KEY_CUT       = $82;
  XMP_KEY_FADE      = $83;

  // Sample format flags
  XMP_FORMAT_8BIT   = 1 shl 0;
  XMP_FORMAT_UNSIGNED = 1 shl 1;
  XMP_FORMAT_MONO   = 1 shl 2;

  // Player parameters
  XMP_PLAYER_AMP    = 0;
  XMP_PLAYER_MIX    = 1;
  XMP_PLAYER_INTERP = 2;
  XMP_PLAYER_DSP    = 3;
  XMP_PLAYER_FLAGS  = 4;
  XMP_PLAYER_CFLAGS = 5;
  XMP_PLAYER_SMPCTL = 6;
  XMP_PLAYER_VOLUME = 7;
  XMP_PLAYER_STATE  = 8;
  XMP_PLAYER_SMIX_VOLUME = 9;
  XMP_PLAYER_DEFPAN = 10;
  XMP_PLAYER_MODE   = 11;
  XMP_PLAYER_MIXER_TYPE = 12;
  XMP_PLAYER_VOICES = 13;

  // Interpolation types
  XMP_INTERP_NEAREST = 0;
  XMP_INTERP_LINEAR = 1;
  XMP_INTERP_SPLINE = 2;

  // DSP effect types
  XMP_DSP_LOWPASS   = 1 shl 0;
  XMP_DSP_ALL       = XMP_DSP_LOWPASS;

  // Player state
  XMP_STATE_UNLOADED = 0;
  XMP_STATE_LOADED  = 1;
  XMP_STATE_PLAYING = 2;

  // Player flags
  XMP_FLAGS_VBLANK  = 1 shl 0;
  XMP_FLAGS_FX9BUG  = 1 shl 1;
  XMP_FLAGS_FIXLOOP = 1 shl 2;
  XMP_FLAGS_A500    = 1 shl 3;

  // Player modes
  XMP_MODE_AUTO     = 0;
  XMP_MODE_MOD      = 1;
  XMP_MODE_NOISETRACKER = 2;
  XMP_MODE_PROTRACKER = 3;
  XMP_MODE_S3M      = 4;
  XMP_MODE_ST3      = 5;
  XMP_MODE_ST3GUS   = 6;
  XMP_MODE_XM       = 7;
  XMP_MODE_FT2      = 8;
  XMP_MODE_IT       = 9;
  XMP_MODE_ITSMP    = 10;

  // Mixer types
  XMP_MIXER_STANDARD = 0;
  XMP_MIXER_A500    = 1;
  XMP_MIXER_A500F   = 2;

  // Sample flags
  XMP_SMPCTL_SKIP   = 1 shl 0;

  // Limits
  XMP_MAX_KEYS      = 121;
  XMP_MAX_ENV_POINTS = 32;
  XMP_MAX_MOD_LENGTH = 256;
  XMP_MAX_CHANNELS  = 64;
  XMP_MAX_SRATE     = 49170;
  XMP_MIN_SRATE     = 4000;
  XMP_MIN_BPM       = 20;
  XMP_MAX_FRAMESIZE = 5 * XMP_MAX_SRATE * 2 div XMP_MIN_BPM;

  // Error codes
  XMP_END           = 1;
  XMP_ERROR_INTERNAL = 2;
  XMP_ERROR_FORMAT  = 3;
  XMP_ERROR_LOAD    = 4;
  XMP_ERROR_DEPACK  = 5;
  XMP_ERROR_SYSTEM  = 6;
  XMP_ERROR_INVALID = 7;
  XMP_ERROR_STATE   = 8;

type
  xmp_context = PChar;

type
  xmp_channel = record
    pan: integer;   // Pan de canal (0x80 centrum)
    vol: integer;   // Volume of canal
    flg: integer;   // Flags of canal
  end;

  xmp_pattern = record
    rows: integer;
    index: array[1..1] of integer;
  end;

  xmp_event = record
    note: byte;
    ins: byte;
    vol: byte;
    fxt: byte;
    fxp: byte;
    f2t: byte;
    f2p: byte;
    _flag: byte;
  end;

  xmp_track = record
    rows: integer;
    event: array[1..1] of xmp_event;
  end;

  xmp_envelope = record
    flg: integer;
    npt: integer;
    scl: integer;
    sus: integer;
    sue: integer;
    lps: integer;
    lpe: integer;
    Data: array[1..XMP_MAX_ENV_POINTS * 2] of smallint;
  end;

  xmp_subinstrument = record
    vol: integer;
    gvl: integer;
    pan: integer;
    xpo: integer;
    fin: integer;
    vwf: integer;
    vde: integer;
    vra: integer;
    vsw: integer;
    rvv: integer;
    sid: integer;
    nna: integer;
    dct: integer;
    dca: integer;
    ifc: integer;
    ifr: integer;
  end;

  xmp_instrument = record
    Name: array[0..31] of char;
    vol: integer;
    nsm: integer;
    rls: integer;
    aei: xmp_envelope;
    pei: xmp_envelope;
    fei: xmp_envelope;
    map: array[0..XMP_MAX_KEYS] of record
      ins: byte;
      xpo: shortint;
    end;
    sub: ^xmp_subinstrument;
    extra: Pointer;
  end;

  xmp_sample = record
    Name: array[0..31] of char;
    len: integer;
    lps: integer;
    lpe: integer;
    flg: integer;
    Data: PByte;
  end;

  xmp_sequence = record
    entry_point: integer;
    duration: integer;
  end;

  xmp_module = record
    Name: array[0..XMP_NAME_SIZE - 1] of char;
    typ: array[0..XMP_NAME_SIZE - 1] of char;
    pat: integer;
    trk: integer;
    chn: integer;
    ins: integer;
    smp: integer;
    spd: integer;
    bpm: integer;
    len: integer;
    rst: integer;
    gvl: integer;
    xxp: ^xmp_pattern;
    xxt: ^xmp_track;
    xxi: ^xmp_instrument;
    xxs: ^xmp_sample;
    xxc: array[0..XMP_MAX_CHANNELS - 1] of xmp_channel;
    xxo: array[0..XMP_MAX_MOD_LENGTH] of byte;
  end;

  xmp_test_info = record
    Name: array[0..XMP_NAME_SIZE - 1] of char;
    type_: array[0..XMP_NAME_SIZE - 1] of char;
  end;

  xmp_module_info = record
    md5: array[0..15] of byte;
    vol_base: integer;
    module: ^xmp_module;
    comment: PChar;
    num_sequences: integer;
    seq_data: ^xmp_sequence;
  end;

  xmp_channel_info = record
    period: longword;
    position: longword;
    pitchbend: smallint;
    note: byte;
    instrument: byte;
    sample: byte;
    volume: byte;
    pan: byte;
    reserved: byte;
    event: xmp_event;
  end;

  xmp_frame_info = record
    pos: integer;
    pattern: integer;
    row: integer;
    num_rows: integer;
    frame: integer;
    speed: integer;
    bpm: integer;
    time: integer;
    total_time: integer;
    frame_time: integer;
    buffer: Pointer;
    buffer_size: integer;
    total_size: integer;
    volume: integer;
    loop_count: integer;
    virt_channels: integer;
    virt_used: integer;
    sequence: integer;
    channel_info: array[0..XMP_MAX_CHANNELS - 1] of xmp_channel_info;
  end;

  xmp_callbacks = record
    read_func: function(dest: Pointer; len, nmemb: longword; priv: Pointer): longword;
    seek_func: function(priv: Pointer; offset: longint; whence: integer): integer;
    tell_func: function(priv: Pointer): longint;
    close_func: function(priv: Pointer): integer;
  end;

  { Dynamic load : Vars that will hold our dynamically loaded functions...

   *************************** functions ******************************* }

var
  xmp_create_context: function: pointer; cdecl;
  xmp_free_context: procedure(ctx: Pointer); cdecl;
  xmp_load_module: function(ctx: Pointer; const filename: PChar): Integer; cdecl;
  xmp_load_module_from_memory: function(ctx: xmp_context; const Data: Pointer; size: longint): integer; cdecl;
  xmp_load_module_from_file: function(ctx: xmp_context; file_: Pointer; size: longint): integer; cdecl;
  xmp_load_module_from_callbacks: function(ctx: xmp_context; file_: Pointer; callbacks: xmp_callbacks): integer; cdecl;
  xmp_test_module: function(const filename: PChar; info: xmp_test_info): Integer; cdecl; 
  xmp_release_module: procedure(ctx: xmp_context); cdecl;
  xmp_start_player: function(ctx: xmp_context; rate: Integer; flags: Integer): Integer; cdecl; 
  xmp_play_buffer: function(ctx: xmp_context; buffer: Pointer; size: Integer; loop: Integer): Integer; cdecl;
  xmp_get_frame_info: procedure(ctx: xmp_context; var info: xmp_frame_info); cdecl;
  xmp_end_player: procedure(ctx: xmp_context); cdecl; 
  xmp_get_module_info: procedure(ctx: xmp_context; var info: xmp_module_info); cdecl; 
  xmp_get_format_list: function(): PAnsiChar; cdecl; 
  xmp_stop_module: procedure(ctx: xmp_context); cdecl; 
  xmp_restart_module: procedure(ctx: xmp_context); cdecl; 
  xmp_channel_vol: function(ctx: xmp_context; channel: Integer; volume: Integer): Integer; cdecl;
  xmp_set_player: function(ctx: xmp_context; param: Integer; value: Integer): Integer; cdecl;

// Not used yet...
//function xmp_test_module_from_memory(const data: Pointer; size: LongInt; info: xmp_test_info): Integer; cdecl; external 'xmp';
//function xmp_test_module_from_file(file_: Pointer; info: xmp_test_info): Integer; cdecl; external 'xmp';
//function xmp_test_module_from_callbacks(file_: Pointer; callbacks: xmp_callbacks; info: xmp_test_info): Integer; cdecl; external 'xmp';
//procedure xmp_scan_module(ctx: xmp_context); cdecl; external 'xmp';
//function xmp_play_frame(ctx: xmp_context): Integer; cdecl; external 'xmp';
//procedure xmp_inject_event(ctx: xmp_context; channel: Integer; var event: xmp_event); cdecl; external 'xmp';//function xmp_next_position(ctx: xmp_context): Integer; cdecl; external 'xmp';
//function xmp_prev_position(ctx: xmp_context): Integer; cdecl; external 'xmp';
//function xmp_set_position(ctx: xmp_context; pos: Integer): Integer; cdecl; external 'xmp';
//function xmp_set_row(ctx: xmp_context; row: Integer): Integer; cdecl; external 'xmp';
//function xmp_set_tempo_factor(ctx: xmp_context; factor: Double): Integer; cdecl; external 'xmp';//function xmp_seek_time(ctx: xmp_context; time: Integer): Integer; cdecl; external 'xmp';
//function xmp_channel_mute(ctx: xmp_context; channel: Integer; mute: Integer): Integer; cdecl; external 'xmp';//function xmp_get_player(ctx: xmp_context; param: Integer): Integer; cdecl; external 'xmp';
//function xmp_set_instrument_path(ctx: xmp_context; const path: PChar): Integer; cdecl; external 'xmp';


{Special function for dynamic loading of lib ...}

var
  xmp_Handle: TLibHandle = dynlibs.NilHandle;
  {$if defined(cpu32) and defined(windows)} // try load dependency if not in /windows/system32/
  gc_Handle :TLibHandle=dynlibs.NilHandle;
  {$endif}
var
  ReferenceCounter: cardinal = 0;  // Reference counter

function xmp_IsLoaded: Boolean; inline;

function xmp_Load(const libfilename: string): Boolean; // load the lib

procedure xmp_Unload(); // unload and frees the lib from memory : do not forget to call it before close application.

implementation

function xmp_IsLoaded: boolean;
begin
 Result := (xmp_Handle <> dynlibs.NilHandle);
end;

Function xmp_Load(const libfilename:string) :boolean;
var
thelib, thelibgcc: string; 
begin
  Result := False;
  if xmp_Handle<>0 then 
begin
 Inc(ReferenceCounter);
 result:=true {is it already there ?}
end  else 
begin 
 {$if defined(cpu32) and defined(windows)}
  if Length(libfilename) = 0 then thelibgcc := 'libgcc_s_dw2-1.dll' else
   thelibgcc := IncludeTrailingBackslash(ExtractFilePath(libfilename)) + 'libgcc_s_dw2-1.dll';
  gc_Handle:= DynLibs.SafeLoadLibrary(thelibgcc);
 {$endif}

{go & load the library}
   if Length(libfilename) = 0 then thelib := XMP_LIB_NAME else thelib := libfilename;
    xmp_Handle:=DynLibs.LoadLibrary(thelib); // obtain the handle we want
  	if xmp_Handle <> DynLibs.NilHandle then
begin {now we tie the functions to the VARs from above}

Pointer(xmp_create_context):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_create_context'));
Pointer(xmp_free_context):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_free_context'));
Pointer(xmp_load_module):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_load_module'));
Pointer(xmp_load_module_from_memory):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_load_module_from_memory'));
Pointer(xmp_load_module_from_file):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_load_module_from_file'));
Pointer(xmp_load_module_from_callbacks):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_load_module_from_callbacks'));
Pointer(xmp_test_module):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_test_module'));
Pointer(xmp_release_module):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_release_module'));
Pointer(xmp_start_player):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_start_player'));
Pointer(xmp_play_buffer):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_play_buffer'));
Pointer(xmp_get_frame_info):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_get_frame_info'));
Pointer(xmp_end_player):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_end_player'));
Pointer(xmp_get_module_info):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_get_module_info'));
Pointer(xmp_get_format_list):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_get_format_list'));
Pointer(xmp_stop_module):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_stop_module'));
Pointer(xmp_restart_module):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_restart_module'));
Pointer(xmp_channel_vol):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_channel_vol'));
Pointer(xmp_set_player):=DynLibs.GetProcedureAddress(xmp_Handle,PChar('xmp_set_player'));
end;
   Result := xmp_IsLoaded;
   ReferenceCounter:=1;   
end;

end;

Procedure xmp_Unload;
begin
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  if xmp_IsLoaded then
  begin
    DynLibs.UnloadLibrary(xmp_Handle);
    xmp_Handle:=DynLibs.NilHandle;
    {$if defined(cpu32) and defined(windows)}
    if gc_Handle <> DynLibs.NilHandle then begin
    DynLibs.UnloadLibrary(gc_Handle);
    gc_Handle:=DynLibs.NilHandle;
    end;
    {$endif}
  end;
end;


end.

