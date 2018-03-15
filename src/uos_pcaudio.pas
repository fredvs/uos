 { This is the Pascal Dynamic loading of pcaudiolib C Wrapper.
        https://github.com/rhdunn/pcaudiolib
 Load library with pc_load() and release with pc_unload().
 Fred van Stappen
 fiens@hotmail.com
 }

unit uos_pcaudio;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

interface

uses
  dynlibs, CTypes;

const
libpc=
 {$IFDEF unix}
 'libpcaudio.so.0';
  {$ELSE}
 'pcaudio.dll';
  {$ENDIF}  

type
 {$IFDEF unix}
{$if defined(cpu64)}
  size_t = cuint64;
{$else}
  size_t = cuint32;
{$endif}
 {$ENDIF}  
 
audio_object_format =(
      AUDIO_OBJECT_FORMAT_S8 = 0,
      AUDIO_OBJECT_FORMAT_U8 = 1,
      AUDIO_OBJECT_FORMAT_S16LE = 2,
      AUDIO_OBJECT_FORMAT_S16BE = 3,
      AUDIO_OBJECT_FORMAT_U16LE = 4,
      AUDIO_OBJECT_FORMAT_U16BE = 5,
      AUDIO_OBJECT_FORMAT_S18LE = 6,
      AUDIO_OBJECT_FORMAT_S18BE = 7,
      AUDIO_OBJECT_FORMAT_U18LE = 8,
      AUDIO_OBJECT_FORMAT_U18BE = 9,
      AUDIO_OBJECT_FORMAT_S20LE = 10,
      AUDIO_OBJECT_FORMAT_S20BE = 11,
      AUDIO_OBJECT_FORMAT_U20LE = 12,
      AUDIO_OBJECT_FORMAT_U20BE = 13,
      AUDIO_OBJECT_FORMAT_S24LE = 14,
      AUDIO_OBJECT_FORMAT_S24BE = 15,
      AUDIO_OBJECT_FORMAT_U24LE = 16,
      AUDIO_OBJECT_FORMAT_U24BE = 17,
      AUDIO_OBJECT_FORMAT_S24_32LE = 18,
      AUDIO_OBJECT_FORMAT_S24_32BE = 19,
      AUDIO_OBJECT_FORMAT_U24_32LE = 20,
      AUDIO_OBJECT_FORMAT_U24_32BE = 21,
      AUDIO_OBJECT_FORMAT_S32LE = 22,
      AUDIO_OBJECT_FORMAT_S32BE = 23,
      AUDIO_OBJECT_FORMAT_U32LE = 24,
      AUDIO_OBJECT_FORMAT_U32BE = 25,
      AUDIO_OBJECT_FORMAT_FLOAT32LE = 26,
      AUDIO_OBJECT_FORMAT_FLOAT32BE = 27,
      AUDIO_OBJECT_FORMAT_FLOAT64LE = 28,
      AUDIO_OBJECT_FORMAT_FLOAT64BE = 29,
      AUDIO_OBJECT_FORMAT_IEC958LE = 30,
      AUDIO_OBJECT_FORMAT_IEC958BE = 31,
      AUDIO_OBJECT_FORMAT_ALAW = 32,
      AUDIO_OBJECT_FORMAT_ULAW = 33,
      AUDIO_OBJECT_FORMAT_ADPCM = 34,
      AUDIO_OBJECT_FORMAT_MPEG = 35,
      AUDIO_OBJECT_FORMAT_GSM = 36,
      AUDIO_OBJECT_FORMAT_AC3 = 37
      );
      
  Paudio_object_format = ^audio_object_format; 
  
  type
    audio_object = record 
    end;
  
 Paudio_object = ^audio_object; 
   
  var create_audio_device_object: function(device, application_name, description: PChar):paudio_object; cdecl ;
  
  var audio_object_open: function(audobject:paudio_object; audioobjectformat:audio_object_format; rate:cuint32; channels:cuint8):longint; cdecl ;

  var audio_object_close: procedure(audobject:paudio_object); cdecl ;

  var audio_object_destroy: procedure(audobject:paudio_object); cdecl ;

  var audio_object_write: function(audobject:paudio_object; data:pointer; bytes:size_t):cint; cdecl ;

  var audio_object_drain: function(audobject:paudio_object):cint; cdecl ;

  var audio_object_flush: function(audobject:paudio_object):cint; cdecl ;

  var audio_object_strerror: function(audobject:paudio_object; error:longint):PCchar;  cdecl ;

      {Special function for dynamic loading of lib ...}

  var Pc_Handle:TLibHandle=dynlibs.NilHandle; 

  var ReferenceCounter : cardinal = 0;  
         
  function Pc_IsLoaded : boolean; inline; 

  function Pc_Load(const libfilename:string) :boolean; // load the lib

  Procedure Pc_Unload(); // unload and frees the lib from memory : do not forget to call it before close application.

implementation

function Pc_IsLoaded: boolean;
begin
 Result := (Pc_Handle <> dynlibs.NilHandle);
end;

Function Pc_Load (const libfilename:string) :boolean;
var
thelib: string; 
begin
  Result := False;
  if Pc_Handle<>0 then 
begin
 Inc(ReferenceCounter);
 result:=true 
end  else 
begin 
   if Length(libfilename) = 0 then thelib := libpc else thelib := libfilename;
    Pc_Handle:=DynLibs.SafeLoadLibrary(thelib); 
  	if Pc_Handle <> DynLibs.NilHandle then
begin 
Pointer(create_audio_device_object):=DynLibs.GetProcedureAddress(Pc_Handle,PChar('create_audio_device_object'));
Pointer(audio_object_open):=DynLibs.GetProcedureAddress(Pc_Handle,PChar('audio_object_open'));
Pointer(audio_object_close):=DynLibs.GetProcedureAddress(Pc_Handle,PChar('audio_object_close'));
Pointer(audio_object_destroy):=DynLibs.GetProcedureAddress(Pc_Handle,PChar('audio_object_destroy'));
Pointer(audio_object_write):=DynLibs.GetProcedureAddress(Pc_Handle,PChar('audio_object_write'));
Pointer(audio_object_drain):=DynLibs.GetProcedureAddress(Pc_Handle,PChar('audio_object_drain'));
Pointer(audio_object_flush):=DynLibs.GetProcedureAddress(Pc_Handle,PChar('audio_object_flush'));
Pointer(audio_object_strerror):=DynLibs.GetProcedureAddress(Pc_Handle,PChar('audio_object_strerror'));
  Result := Pc_IsLoaded;
   ReferenceCounter:=1;  
end;
  
end;

end;

Procedure Pc_Unload;
begin
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  if Pc_IsLoaded then
  begin
    DynLibs.UnloadLibrary(Pc_Handle);
    Pc_Handle:=DynLibs.NilHandle;
  end;
end;

end.

