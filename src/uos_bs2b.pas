{This unit is part of United Openlibraries of Sound (uos)}

{This is the Dynamic loading Pascal Wrapper of
    bs2b library of Boris Mikhaylov
 Load library with bs_load() and release with bs_unload().
 License : modified LGPL. 
 Fred van Stappen / fiens@hotmail.com 
} 


unit uos_bs2b;

{$mode objfpc}{$H+}
{$PACKRECORDS C}


interface

uses
  SysUtils, dynlibs, ctypes;

const

{ Minimum/maximum sample rate (Hz)  }
  BS2B_MINSRATE = 2000;  
  BS2B_MAXSRATE = 384000;  

{ Minimum/maximum cut frequency (Hz)  }
{ bs2b_set_level_fcut()  }
  BS2B_MINFCUT = 300;  
  BS2B_MAXFCUT = 2000;  
  
{ Minimum/maximum feed level (dB * 10 @ low frequencies)  }
{ bs2b_set_level_feed()  }
{ 1 dB  }
  BS2B_MINFEED = 10;  
{ 15 dB  }
  BS2B_MAXFEED = 150;  
  
const
  
  // for using with bs2b_set_level
  
  BS2B_HIGH_CLEVEL = (CInt32(700)) or ((CInt32(30)) shl 16);
  BS2B_MIDDLE_CLEVEL = (CInt32(500)) or ((CInt32(45)) shl 16);
  BS2B_LOW_CLEVEL = (CInt32(360)) or ((CInt32(60)) shl 16);
  { Easy crossfeed levels (Obsolete)  }
  BS2B_HIGH_ECLEVEL = (CInt32(700)) or ((CInt32(60)) shl 16);
  BS2B_MIDDLE_ECLEVEL = (CInt32(500)) or ((CInt32(72)) shl 16);
  BS2B_LOW_ECLEVEL = (CInt32(360)) or ((CInt32(84)) shl 16);
  
  BS2B_DEFAULT_CLEVEL = (CInt32(700)) or ((CInt32(45)) shl 16);
  BS2B_CMOY_CLEVEL =(CInt32(700)) or ((CInt32(60)) shl 16);
  BS2B_JMEIER_CLEVEL = (CInt32(650)) or ((CInt32(95)) shl 16);
 
{ Default sample rate (Hz)  }
const
  BS2B_DEFAULT_SRATE = 44100;  

{ A delay at low frequency by microseconds according to cut frequency  }
function bs2b_level_delay(fcut : longint) : longint;

{ Crossfeed level  }
{ Sample rate (Hz)  }
{ Lowpass IIR filter coefficients  }
{ Highboost IIR filter coefficients  }
{ Global gain against overloading  }
{ Buffer of last filtered sample: [0] 1-st channel, [1] 2-d channel  }
type
  Tt_bs2bdp = ^Tt_bs2bd;
  Tt_bs2bd = packed record
      level : CInt32;
      srate : CInt32;
      a0_lo : CDouble;
      b1_lo : CDouble;
      a0_hi : CDouble;
      a1_hi : CDouble;
      b1_hi : CDouble;
      gain : CDouble;
      lfs : packed record
          asis : array[0..1] of cdouble;
          lo : array[0..1] of cdouble;
          hi : array[0..1] of cdouble;
        end;
    end;

////// Dynamic load : Vars that will hold our dynamically loaded functions...
// *************************** functions *******************************

var
{ Open  }
bs2b_open : function():Tt_bs2bdp; cdecl;

{ Close  }
bs2b_close : procedure(bs2bdp:Tt_bs2bdp); cdecl;

{ Sets a new coefficients by new crossfeed value.
 * level = ( fcut | feed << 16 ) )
 * where 'feed' is crossfeeding level at low frequencies (dB * 10)
 * and 'fcut' is cut frecuency (Hz)
  }
bs2b_set_level : procedure(bs2bdp:Tt_bs2bdp; level: CInt32); cdecl;

{ Return a current crossfeed level value.  }
bs2b_get_level : function(bs2bdp:Tt_bs2bdp): CInt32; cdecl;

{ Sets a new coefficients by new cut frecuency value (Hz).  }
bs2b_set_level_fcut : procedure(bs2bdp:Tt_bs2bdp; fcut: CInt32); cdecl;

{ Return a current cut frecuency value (Hz).  }
bs2b_get_level_fcut : function(bs2bdp:Tt_bs2bdp): CInt32; cdecl;

{ Sets a new coefficients by new crossfeeding level value (dB * 10).  }
bs2b_set_level_feed : procedure(bs2bdp:Tt_bs2bdp; feed: CInt32); cdecl;

{ Return a current crossfeeding level value (dB * 10).  }
bs2b_get_level_feed : function(bs2bdp:Tt_bs2bdp): CInt32; cdecl;

{ Return a current delay value at low frequencies (micro seconds).  }
bs2b_get_level_delay : function(bs2bdp:Tt_bs2bdp): CInt32; cdecl;

{ Clear buffers and sets a new coefficients with new sample rate value.
 * srate - sample rate by Hz. }
bs2b_set_srate : procedure(bs2bdp:Tt_bs2bdp; srate: CInt32); cdecl;

{ Return current sample rate value  }
bs2b_get_srate : function(bs2bdp:Tt_bs2bdp): CInt32; cdecl;

{ Clear buffer  }
bs2b_clear : procedure(bs2bdp:Tt_bs2bdp); cdecl;

{ Return 1 if buffer is clear  }
bs2b_is_clear : function(bs2bdp:Tt_bs2bdp): CInt32; cdecl;

{ Return bs2b version string  }
(* Const before declarator ignored *)
bs2b_runtime_version : function():pchar; cdecl;

{ Return bs2b version integer  }
bs2b_runtime_version_int : function(): CInt32; cdecl;

{ 'bs2b_cross_feed_*' crossfeeds buffer of 'n' stereo samples
 * pointed by 'sample'.
 * sample[i]   - first channel,
 * sample[i+1] - second channel.
 * Where 'i' is ( i = 0; i < n * 2; i += 2 )
  }
{ sample poits to double floats native endians  }
bs2b_cross_feed_d : procedure(bs2bdp:Tt_bs2bdp; var sample:Cdouble; n: CInt32); cdecl;

{ sample poits to double floats big endians  }
bs2b_cross_feed_dbe : procedure(bs2bdp:Tt_bs2bdp; var sample:Cdouble; n: CInt32); cdecl;

{ sample poits to double floats little endians  }
bs2b_cross_feed_dle : procedure(bs2bdp:Tt_bs2bdp; var sample:Cdouble; n: CInt32); cdecl;

{ sample poits to floats native endians  }
bs2b_cross_feed_f : procedure(bs2bdp:Tt_bs2bdp; var sample:Cfloat; n:CInt32); cdecl;

{ sample poits to floats big endians  }
bs2b_cross_feed_fbe : procedure(bs2bdp:Tt_bs2bdp; var sample:Cfloat; n:CInt32); cdecl;

{ sample poits to floats little endians  }
bs2b_cross_feed_fle : procedure(bs2bdp:Tt_bs2bdp; var sample:cfloat; n:CInt32); cdecl;

{ sample poits to 32bit signed integers native endians  }
bs2b_cross_feed_s32 : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt32); cdecl;

{ sample poits to 32bit unsigned integers native endians  }
bs2b_cross_feed_u32 : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt32); cdecl;

{ sample poits to 32bit signed integers big endians  }
bs2b_cross_feed_s32be : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt32); cdecl;

{ sample poits to 32bit unsigned integers big endians  }
bs2b_cross_feed_u32be : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt32); cdecl;

{ sample poits to 32bit signed integers little endians  }
bs2b_cross_feed_s32le : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt32); cdecl;

{ sample poits to 32bit unsigned integers little endians  }
bs2b_cross_feed_u32le : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt32); cdecl;

{ sample poits to 16bit signed integers native endians  }
bs2b_cross_feed_s16 : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt16; n:CInt); cdecl;

{ sample poits to 16bit unsigned integers native endians  }
bs2b_cross_feed_u16 : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt); cdecl;

{ sample poits to 16bit signed integers big endians  }
bs2b_cross_feed_s16be : procedure(bs2bdp:Tt_bs2bdp; var sample:cint16; n:cint); cdecl;

{ sample poits to 16bit unsigned integers big endians  }
bs2b_cross_feed_u16be : procedure(bs2bdp:Tt_bs2bdp; var sample:cint16; n:cint); cdecl;

{ sample poits to 16bit signed integers little endians  }
bs2b_cross_feed_s16le : procedure(bs2bdp:Tt_bs2bdp; var sample:cint16; n:cint); cdecl;

{ sample poits to 16bit unsigned integers little endians  }
bs2b_cross_feed_u16le : procedure(bs2bdp:Tt_bs2bdp; var sample:cint16; n:cint); cdecl;

{ sample poits to 8bit signed integers  }
bs2b_cross_feed_s8 : procedure(bs2bdp:Tt_bs2bdp; var sample:cint8; n:cint); cdecl;

{ sample poits to 8bit unsigned integers  }
bs2b_cross_feed_u8 : procedure(bs2bdp:Tt_bs2bdp; var sample:cint8; n:cint); cdecl;

{ sample poits to 24bit signed integers native endians  }
bs2b_cross_feed_s24 : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt); cdecl;

{ sample poits to 24bit unsigned integers native endians  }
bs2b_cross_feed_u24 : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt); cdecl;

{ sample poits to 24bit signed integers be endians  }
bs2b_cross_feed_s24be : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt); cdecl;

{ sample poits to 24bit unsigned integers be endians  }
bs2b_cross_feed_u24be : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt); cdecl;

{ sample poits to 24bit signed integers little endians  }
bs2b_cross_feed_s24le : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt); cdecl;

{ sample poits to 24bit unsigned integers little endians  }
bs2b_cross_feed_u24le : procedure(bs2bdp:Tt_bs2bdp; var sample:CInt32; n:CInt); cdecl;

   function bs_IsLoaded() : boolean; inline; 
   
   Function bs_Load(const libfilename:string) :boolean; // load the lib

   Procedure bs_Unload(); // unload and frees the lib from memory : do not forget to call it before close application.

implementation

function bs2b_level_delay(fcut : longint) : longint;
begin
  result:=round((18700/fcut)*10);
end;

  var
    bs_Handle :TLibHandle=dynlibs.NilHandle;
    {$IFDEF windows} // try load dependency if not in /windows/system32/
    gc_Handle :TLibHandle=dynlibs.NilHandle;
    {$endif}
    ReferenceCounter : cardinal = 0;  // Reference counter
    
function bs_IsLoaded(): boolean;
begin
 Result := (bs_Handle <> dynlibs.NilHandle);
end;

Procedure bs_Unload();
begin
// < Reference counting
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >
  if bs_IsLoaded() then
  begin
    DynLibs.UnloadLibrary(bs_Handle);
    bs_Handle:=DynLibs.NilHandle;
     {$IFDEF windows}
    if gc_Handle <> DynLibs.NilHandle then begin
    DynLibs.UnloadLibrary(gc_Handle);
    gc_Handle:=DynLibs.NilHandle;
    end;
     {$endif}
      bs2b_open:=nil;
      bs2b_close:=nil;
      bs2b_set_level:=nil;
      bs2b_get_level:=nil;
      bs2b_set_level_fcut:=nil;
      bs2b_get_level_fcut:=nil;
      bs2b_set_level_feed:=nil;
      bs2b_get_level_feed:=nil;
      bs2b_get_level_delay:=nil;
      bs2b_set_srate:=nil;
      bs2b_get_srate:=nil;
      bs2b_clear:=nil;
      bs2b_is_clear:=nil;
      bs2b_runtime_version:=nil;
      bs2b_runtime_version_int:=nil;
      bs2b_cross_feed_d:=nil;
      bs2b_cross_feed_dbe:=nil;
      bs2b_cross_feed_dle:=nil;
      bs2b_cross_feed_f:=nil;
      bs2b_cross_feed_fbe:=nil;
      bs2b_cross_feed_fle:=nil;
      bs2b_cross_feed_s32:=nil;
      bs2b_cross_feed_u32:=nil;
      bs2b_cross_feed_s32be:=nil;
      bs2b_cross_feed_u32be:=nil;
      bs2b_cross_feed_s32le:=nil;
      bs2b_cross_feed_u32le:=nil;
      bs2b_cross_feed_s16:=nil;
      bs2b_cross_feed_u16:=nil;
      bs2b_cross_feed_s16be:=nil;
      bs2b_cross_feed_u16be:=nil;
      bs2b_cross_feed_s16le:=nil;
      bs2b_cross_feed_u16le:=nil;
      bs2b_cross_feed_s8:=nil;
      bs2b_cross_feed_u8:=nil;
      bs2b_cross_feed_s24:=nil;
      bs2b_cross_feed_u24:=nil;
      bs2b_cross_feed_s24be:=nil;
      bs2b_cross_feed_u24be:=nil;
      bs2b_cross_feed_s24le:=nil;
      bs2b_cross_feed_u24le:=nil;
  end;
end;

  Function bs_Load(const libfilename:string) :boolean;
    begin
      Result := False;
  if bs_Handle<>0 then 
begin
 Inc(ReferenceCounter);
result:=true {is it already there ?}
end  else begin {go & load the library}
    if Length(libfilename) = 0 then exit;
   
    {$IFDEF windows} 
    gc_Handle:= DynLibs.SafeLoadLibrary(ExtractFilePath(libfilename)+'libgcc_s_dw2-1.dll');
    {$endif}
   
    bs_Handle:=DynLibs.SafeLoadLibrary(libfilename); // obtain the handle we want
 
 	if bs_Handle <> DynLibs.NilHandle then
       begin {now we tie the functions to the VARs from above}

      pointer(bs2b_open):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_open'));
      pointer(bs2b_close):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_close'));
      pointer(bs2b_set_level):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_set_level'));
      pointer(bs2b_get_level):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_get_level'));
      pointer(bs2b_set_level_fcut):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_set_level_fcut'));
      pointer(bs2b_get_level_fcut):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_get_level_fcut'));
      pointer(bs2b_set_level_feed):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_set_level_feed'));
      pointer(bs2b_get_level_feed):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_get_level_feed'));
      pointer(bs2b_get_level_delay):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_get_level_delay'));
      pointer(bs2b_set_srate):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_set_srate'));
      pointer(bs2b_get_srate):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_get_srate'));
      pointer(bs2b_clear):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_clear'));
      pointer(bs2b_is_clear):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_is_clear'));
      pointer(bs2b_runtime_version):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_runtime_version'));
      pointer(bs2b_runtime_version_int):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_runtime_version_int'));
      pointer(bs2b_cross_feed_d):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_d'));
      pointer(bs2b_cross_feed_dbe):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_dbe'));
      pointer(bs2b_cross_feed_dle):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_dle'));
      pointer(bs2b_cross_feed_f):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_f'));
      pointer(bs2b_cross_feed_fbe):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_fbe'));
      pointer(bs2b_cross_feed_fle):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_fle'));
      pointer(bs2b_cross_feed_s32):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s32'));
      pointer(bs2b_cross_feed_u32):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u32'));
      pointer(bs2b_cross_feed_s32be):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s32be'));
      pointer(bs2b_cross_feed_u32be):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u32be'));
      pointer(bs2b_cross_feed_s32le):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s32le'));
      pointer(bs2b_cross_feed_u32le):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u32le'));
      pointer(bs2b_cross_feed_s16):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s16'));
      pointer(bs2b_cross_feed_u16):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u16'));
      pointer(bs2b_cross_feed_s16be):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s16be'));
      pointer(bs2b_cross_feed_u16be):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u16be'));
      pointer(bs2b_cross_feed_s16le):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s16le'));
      pointer(bs2b_cross_feed_u16le):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u16le'));
      pointer(bs2b_cross_feed_s8):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s8'));
      pointer(bs2b_cross_feed_u8):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u8'));
      pointer(bs2b_cross_feed_s24):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s24'));
      pointer(bs2b_cross_feed_u24):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u24'));
      pointer(bs2b_cross_feed_s24be):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s24be'));
      pointer(bs2b_cross_feed_u24be):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u24be'));
      pointer(bs2b_cross_feed_s24le):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_s24le'));
      pointer(bs2b_cross_feed_u24le):=DynLibs.GetProcAddress(bs_handle,PChar('bs2b_cross_feed_u24le'));
     end;
    Result := bs_IsLoaded;
    ReferenceCounter:=1;   
  end;
end;

end.

