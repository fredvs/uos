{This unit is part of United Openlibraries of Sound (uos)}

{This is the Dynamic loading version of IceCast_Shout Pascal Wrapper.
 Load library with sha_load() and release with sh_unload().
 License : modified LGPL.
 Fred van Stappen / fiens@hotmail.com }

unit uos_shout;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

interface

uses
  dynlibs, CTypes, sysutils;

    const
    SHOUT_THREADSAFE = 1;
    SHOUT_TLS = 1;
    SHOUTERR_SUCCESS = 0;
    SHOUTERR_INSANE = -1;
    SHOUTERR_NOCONNECT = -2;
    SHOUTERR_NOLOGIN = -3;
    SHOUTERR_SOCKET = -4;
    SHOUTERR_MALLOC = -5;
    SHOUTERR_METADATA = -6;
    SHOUTERR_CONNECTED = -7;
    SHOUTERR_UNCONNECTED = -8;
    SHOUTERR_UNSUPPORTED = -9;
    SHOUTERR_BUSY = -10;
    SHOUTERR_NOTLS = -11;
    SHOUTERR_TLSBADCERT = -12;
    SHOUTERR_RETRY = -13;
    SHOUT_FORMAT_OGG = 0;
    SHOUT_FORMAT_MP3 = 1;
    SHOUT_FORMAT_WEBM = 2;
    SHOUT_FORMAT_WEBMAUDIO = 3;
    SHOUT_FORMAT_VORBIS = SHOUT_FORMAT_OGG;
    SHOUT_PROTOCOL_HTTP = 0;
    SHOUT_PROTOCOL_XAUDIOCAST = 1;
    SHOUT_PROTOCOL_ICY = 2;
    SHOUT_PROTOCOL_ROARAUDIO = 3;
    SHOUT_TLS_DISABLED = 0;
    SHOUT_TLS_AUTO = 1;
    SHOUT_TLS_AUTO_NO_PLAIN = 2;
    SHOUT_TLS_RFC2818 = 11;
    SHOUT_TLS_RFC2817 = 12;
    SHOUT_AI_BITRATE = 'bitrate';
    SHOUT_AI_SAMPLERATE = 'samplerate';
    SHOUT_AI_CHANNELS = 'channels';
    SHOUT_AI_QUALITY = 'quality';
    SHOUT_META_NAME = 'name';
    SHOUT_META_URL = 'url';
    SHOUT_META_GENRE = 'genre';
    SHOUT_META_DESCRIPTION = 'description';
    SHOUT_META_IRC = 'irc';
    SHOUT_META_AIM = 'aim';
    SHOUT_META_ICQ = 'icq';

 type
 shout_t = pointer;
 Pshout_t  = ^shout_t;
  {$if defined(cpu64)}
  cuint64 = qword;
  size_t = cuint64;
{$else}
  cuint32 = longword;
  size_t = cuint32;
{$endif}

  psize_t = ^size_t;

  shout_metadata_t = pointer;
  Pshout_metadata_t  = ^shout_metadata_t;

// methods
var

  shout_init: procedure();cdecl;
  shout_shutdown: procedure();cdecl;
  shout_version: function(var major:cint; var minor:cint; var patch:cint):pchar;cdecl;
  shout_new: function(): Pshout_t;cdecl;
  shout_free: procedure(shhandle :Pshout_t);cdecl;
  shout_get_error: function(shhandle :Pshout_t):pchar;cdecl;
  shout_get_errno: function(shhandle :Pshout_t):cint;cdecl;
  shout_get_connected: function(shhandle :Pshout_t):cint;cdecl;
  shout_set_host: function(shhandle :Pshout_t; host: pchar):cint;cdecl;
  shout_get_host: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_port: function(shhandle :Pshout_t; port:cushort):cint;cdecl;
  shout_get_port: function(shhandle :Pshout_t):cushort;cdecl;
  shout_set_agent: function(shhandle :Pshout_t; agent:pchar):cint;cdecl;
  shout_get_agent: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_tls: function(shhandle :Pshout_t; mode:cint):cint;cdecl;
  shout_get_tls: function(shhandle :Pshout_t):cint;cdecl;
  shout_set_ca_directory: function(shhandle :Pshout_t; directory:pchar):cint;cdecl;
  shout_get_ca_directory: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_ca_file: function(shhandle :Pshout_t; thefile:pchar):cint;cdecl;
  shout_get_ca_file: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_allowed_ciphers: function(shhandle :Pshout_t; ciphers:pchar):cint;cdecl;
  shout_get_allowed_ciphers: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_user: function(shhandle :Pshout_t; username:pchar):cint;cdecl;
  shout_get_user: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_password: function(shhandle :Pshout_t; password:pchar):cint;cdecl;
  shout_get_password: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_client_certificate: function(shhandle :Pshout_t; certificate:pchar):cint;cdecl;
  shout_get_client_certificate: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_mount: function(shhandle :Pshout_t; mount:pchar):cint;cdecl;
  shout_get_mount: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_name: function(shhandle :Pshout_t; name:pchar):cint;cdecl;
  shout_get_name: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_url: function(shhandle :Pshout_t; url:pchar):cint;cdecl;
  shout_get_url: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_genre: function(shhandle :Pshout_t; genre:pchar):cint;cdecl;
  shout_get_genre: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_description: function(shhandle :Pshout_t; description:pchar):cint;cdecl;
  shout_get_description: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_dumpfile: function(shhandle :Pshout_t; dumpfile:pchar):cint;cdecl;
  shout_get_dumpfile: function(shhandle :Pshout_t):pchar;cdecl;
  shout_set_audio_info: function(shhandle :Pshout_t; name:pchar; value:pchar):cint;cdecl;
  shout_get_audio_info: function(shhandle :Pshout_t; name:pchar):pchar;cdecl;
  shout_set_meta: function(shhandle :Pshout_t; name:pchar; value:pchar):cint;cdecl;
  shout_get_meta: function(shhandle :Pshout_t; name:pchar):pchar;cdecl;
  shout_set_public: function(shhandle :Pshout_t; make_public:cuint):cint;cdecl;
  shout_get_public: function(shhandle :Pshout_t):cuint;cdecl;
  shout_set_format: function(shhandle :Pshout_t; format:cuint):cint;cdecl;
  shout_get_format: function(shhandle :Pshout_t):cuint;cdecl;
  shout_set_protocol: function(shhandle :Pshout_t; protocol:cuint):cint;cdecl;
  shout_get_protocol: function(shhandle :Pshout_t):cuint;cdecl;
  shout_set_nonblocking: function(shhandle :Pshout_t; nonblocking:cuint):cint;cdecl;
  shout_get_nonblocking: function(shhandle :Pshout_t):cuint;cdecl;
  shout_open: function(shhandle :Pshout_t):cint;cdecl;
  shout_close: function(shhandle :Pshout_t):cint;cdecl;
  //shout_send: function(shhandle :Pshout_t; data:pcuchar; len:size_t):cint;cdecl;
  shout_send: function(shhandle :Pshout_t; data:pbyte; len:size_t):cint;cdecl;
  shout_send_raw: function(shhandle :Pshout_t; data:pcuchar; len:size_t):size_t;cdecl;
  shout_queuelen: function(shhandle :Pshout_t):size_t;cdecl;
  shout_sync: procedure(shhandle :Pshout_t);cdecl;
  shout_delay: function(shhandle :Pshout_t):cint;cdecl;
  shout_set_metadata: function(shhandle :Pshout_t; var metadata:shout_metadata_t):cint;cdecl;
  shout_metadata_new: function():Pshout_metadata_t;cdecl;
  shout_metadata_free: procedure(var shhandle:shout_metadata_t);cdecl;
  shout_metadata_add: function(var shhandle:shout_metadata_t; name:pchar; value:pchar):cint;cdecl;

  sh_Handle:TLibHandle=dynlibs.NilHandle; // this will hold our handle for the lib; it functions nicely as a mutli-lib prevention unit as well...

  ReferenceCounter : cardinal = 0;  // Reference counter

    function sh_IsLoaded : boolean; inline;

    Function sh_Load(const libfilename:string) :boolean; // load the lib

    Procedure sh_Unload(); // unload and frees the lib from memory : do not forget to call it before close application.


implementation

function sh_IsLoaded: boolean;
begin
 Result := (sh_Handle <> dynlibs.NilHandle);
end;

Function sh_Load (const libfilename:string) :boolean;
begin
  Result := False;
  if sh_Handle<>0 then
begin
 Inc(ReferenceCounter);
 result:=true {is it already there ?}
end  else
begin {go & load the library}
    if Length(libfilename) = 0 then exit;
    sh_Handle:=DynLibs.SafeLoadLibrary(libfilename); // obtain the handle we want
  	if sh_Handle <> DynLibs.NilHandle then
begin {now we tie the functions to the VARs from above}

Pointer(shout_init):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_init'));
Pointer(shout_shutdown):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_shutdown'));
Pointer(shout_version):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_version'));
Pointer(shout_new):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_new'));
Pointer(shout_free):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_free'));
Pointer(shout_get_error):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_error'));
Pointer(shout_get_errno):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_errno'));
Pointer(shout_get_connected):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_connected'));
Pointer(shout_set_host):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_host'));
Pointer(shout_get_host):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_host'));
Pointer(shout_set_port):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_port'));
Pointer(shout_get_port):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_port'));
Pointer(shout_set_agent):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_agent'));
Pointer(shout_get_agent):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_agent'));
Pointer(shout_set_tls):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_tls'));
Pointer(shout_get_tls):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_tls'));
Pointer(shout_set_ca_directory):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_ca_directory'));
Pointer(shout_get_ca_directory):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_ca_directory'));
Pointer(shout_set_ca_file):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_ca_file'));
Pointer(shout_get_ca_file):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_ca_file'));
Pointer(shout_set_allowed_ciphers):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_allowed_ciphers'));
Pointer(shout_get_allowed_ciphers):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_allowed_ciphers'));
Pointer(shout_set_user):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_user'));
Pointer(shout_get_user):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_user'));
Pointer(shout_set_password):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_password'));
Pointer(shout_get_password):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_password'));
Pointer(shout_set_client_certificate):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_client_certificate'));
Pointer(shout_get_client_certificate):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_client_certificate'));
Pointer(shout_set_mount):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_mount'));
Pointer(shout_get_mount):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_mount'));
Pointer(shout_set_name):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_name'));
Pointer(shout_get_name):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_name'));
Pointer(shout_set_url):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_url'));
Pointer(shout_get_url):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_url'));
Pointer(shout_set_genre):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_genre'));
Pointer(shout_get_genre):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_genre'));
Pointer(shout_set_description):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_description'));
Pointer(shout_get_description):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_description'));
Pointer(shout_set_dumpfile):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_dumpfile'));
Pointer(shout_get_dumpfile):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_dumpfile'));
Pointer(shout_set_audio_info):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_audio_info'));
Pointer(shout_get_audio_info):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_audio_info'));
Pointer(shout_set_meta):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_meta'));
Pointer(shout_get_meta):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_meta'));
Pointer(shout_set_public):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_public'));
Pointer(shout_get_public):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_public'));
Pointer(shout_set_format):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_format'));
Pointer(shout_get_format):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_format'));
Pointer(shout_set_protocol):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_protocol'));
Pointer(shout_get_protocol):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_protocol'));
Pointer(shout_set_nonblocking):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_nonblocking'));
Pointer(shout_get_nonblocking):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_get_nonblocking'));
Pointer(shout_open):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_open'));
Pointer(shout_close):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_close'));
Pointer(shout_send):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_send'));
Pointer(shout_send_raw):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_send_raw'));
Pointer(shout_queuelen):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_queuelen'));
Pointer(shout_sync):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_sync'));
Pointer(shout_delay):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_delay'));
Pointer(shout_set_metadata):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_set_metadata'));
Pointer(shout_metadata_new):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_metadata_new'));
Pointer(shout_metadata_free):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_metadata_free'));
Pointer(shout_metadata_add):=DynLibs.GetProcedureAddress(sh_Handle,PChar('shout_metadata_add'));

end;
   Result := sh_IsLoaded;
   ReferenceCounter:=1;
end;

end;

Procedure sh_Unload;
begin
// < Reference counting
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >
  if sh_IsLoaded then
  begin
    shout_shutdown();
    DynLibs.UnloadLibrary(sh_Handle);
    sh_Handle:=DynLibs.NilHandle;
  end;
end;

end.
