{This unit is part of United Openlibraries of Sound (uos)}

{This is the Dynamic loading + Unix compatible version of SoundTouch Pascal Wrapper
 from Sandro Cumerlato <sandro.cumerlato@gmail.com>.
 of the original C version of Olli Parviainen <oparviai@iki.fi>.

 Added BPMdetect method too.
 Load library with St_load() and release with St_unload().
 License : modified LGPL.
 Fred van Stappen / fiens@hotmail.com}

unit uos_soundtouch;

{$IFDEF FPC}
   {$mode objfpc}{$H+}
   {$PACKRECORDS C}
{$else}
   {$MINENUMSIZE 4} (* use 4-byte enums *)
{$endif}

interface


{$IFNDEF FPC}
   uses sysutils, windows, DELPHIctypes;
{$else}
   uses dynlibs, CTypes;
{$endif}
 
const
libst=
 
{$IFDEF darwin}
 'libSoundTouchDLL.dylib';
  {$ELSE}
 {$IFDEF unix}
 'libSoundTouch.so.1';
  {$ELSE}
  {$if defined(cpu64)}
   'SoundTouch_x64.dll';
     {$else}
   'SoundTouch.dll';
     {$endif}
  {$ENDIF}     
   {$ENDIF} 

//{$IF not DEFINED(windows)}
//type
//  THandle = pointer;
//{$endif}
{$IFDEF FPC}
   {$IF not DEFINED(windows)}
   type
     THandle = pointer;
   {$endif}
{$endif}

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

var
  bpm_createInstance: function(chan: CInt32; sampleRate : CInt32): THandle; cdecl;
  bpm_destroyInstance: procedure(h: THandle); cdecl;
  bpm_getBpm: function(h: THandle): cfloat; cdecl;
  bpm_putSamples: procedure(h: THandle; const samples: pcfloat;
  numSamples: cardinal); cdecl;

  soundtouch_clear: procedure(h: THandle); cdecl;
  soundtouch_createInstance: function(): THandle; cdecl;
  soundtouch_flush: procedure(h: THandle); cdecl;
  soundtouch_getSetting: function(h: THandle; settingId: integer): integer; cdecl;
  soundtouch_getVersionId: function(): cardinal; cdecl;
  soundtouch_getVersionString2: procedure(VersionString: PAnsiChar;
  bufferSize: integer); cdecl;
  soundtouch_getVersionString: function(): PAnsiChar; cdecl;
  soundtouch_isEmpty: function(h: THandle): integer; cdecl;
  soundtouch_numSamples: function(h: THandle): cardinal; cdecl;
  soundtouch_numUnprocessedSamples: function(h: THandle): cardinal; cdecl;
  soundtouch_putSamples: procedure(h: THandle; const samples: pcfloat;
  numSamples: cardinal); cdecl;
  soundtouch_receiveSamples: function(h: THandle; outBuffer: pcfloat;
  maxSamples: cardinal): cardinal; cdecl;
  soundtouch_setChannels: procedure(h: THandle; numChannels: cardinal); cdecl;
  soundtouch_setPitch: procedure(h: THandle; newPitch: single); cdecl;
  soundtouch_setPitchOctaves: procedure(h: THandle; newPitch: single); cdecl;
  soundtouch_setPitchSemiTones: procedure(h: THandle; newPitch: single); cdecl;
  soundtouch_setRate: procedure(h: THandle; newRate: single); cdecl;
  soundtouch_setRateChange: procedure(h: THandle; newRate: single); cdecl;
  soundtouch_setSampleRate: procedure(h: THandle; srate: cardinal); cdecl;
  soundtouch_destroyInstance: procedure(h: THandle); cdecl;
  soundtouch_setSetting: function(h: THandle; settingId: integer; Value: integer): boolean; cdecl;
  soundtouch_setTempo: procedure(h: THandle; newTempo: single); cdecl;
  soundtouch_setTempoChange: procedure(h: THandle; newTempo: single); cdecl;

 //LibHandle:TLibHandle=dynlibs.NilHandle; // this will hold our handle for the lib
  {$IFDEF FPC}
  LibHandle:TLibHandle=dynlibs.NilHandle; // this will hold our handle for the lib; it functions nicely as a mutli-lib prevention unit as well...
  {$ELSE}
  LibHandle:THandle=NilHandle; // this will hold our handle for the lib
  {$ENDIF FPC}
 ReferenceCounter : cardinal = 0;  // Reference counter
         
function ST_IsLoaded : boolean; inline; 
function ST_Load(const libfilename: string): boolean; // load the lib
procedure ST_Unload(); // unload and frees the lib from memory : do not forget to call it before close application.

implementation

function ST_IsLoaded: boolean;
begin
   {$IFNDEF FPC}
   Result := (LibHandle <> 0);
   {$else}
   Result := (LibHandle <> dynlibs.NilHandle);
   {$endif}
end;

function ST_Load(const libfilename: string): boolean;
var
thelib: string; 
begin
   Result := False;
  if LibHandle<>0 then 
  begin
   Inc(ReferenceCounter);
  result:=true
  end
  else begin
      if Length(libfilename) = 0 then thelib := libst else thelib := libfilename;

  {$IFNDEF FPC}
  LibHandle:=SafeLoadLibrary(thelib); // obtain the handle we want
  {$else}
  LibHandle:=DynLibs.SafeLoadLibrary(thelib); // obtain the handle we want
  {$endif}
      {$IFNDEF FPC}
      if LibHandle <> 0 then
      begin {now we tie the functions to the VARs from above}
        try

            {$IFNDEF FPC}
            soundtouch_createInstance := GetProcAddress(LibHandle, 'soundtouch_createInstance');
            if Pointer(soundtouch_createInstance) = nil then begin // not the SoundTouchDLL library.
               ST_Unload;
               result := false
            end else begin
               soundtouch_clear := GetProcAddress(LibHandle, 'soundtouch_clear');
               soundtouch_destroyInstance := GetProcAddress(LibHandle, 'soundtouch_destroyInstance');
               soundtouch_flush := GetProcAddress(LibHandle, 'soundtouch_flush');
               soundtouch_getSetting := GetProcAddress(LibHandle, 'soundtouch_getSetting');
               soundtouch_getVersionId := GetProcAddress(LibHandle, 'soundtouch_getVersionId');
               soundtouch_getVersionString2 := GetProcAddress(LibHandle, 'soundtouch_getVersionString2');
               soundtouch_getVersionString := GetProcAddress(LibHandle, 'soundtouch_getVersionString');
               soundtouch_isEmpty := GetProcAddress(LibHandle, 'soundtouch_isEmpty');
               soundtouch_numSamples := GetProcAddress(LibHandle, 'soundtouch_numSamples');
               soundtouch_numUnprocessedSamples := GetProcAddress(LibHandle, 'soundtouch_numUnprocessedSamples');
               soundtouch_putSamples := GetProcAddress(LibHandle, 'soundtouch_putSamples');
               soundtouch_receiveSamples := GetProcAddress(LibHandle, 'soundtouch_receiveSamples');
               soundtouch_setChannels := GetProcAddress(LibHandle, 'soundtouch_setChannels');
               soundtouch_setPitch := GetProcAddress(LibHandle, 'soundtouch_setPitch');
               soundtouch_setPitchOctaves := GetProcAddress(LibHandle, 'soundtouch_setPitchOctaves');
               soundtouch_setPitchSemiTones := GetProcAddress(LibHandle, 'soundtouch_setPitchSemiTones');
               soundtouch_setRate := GetProcAddress(LibHandle, 'soundtouch_setRate');
               soundtouch_setRateChange := GetProcAddress(LibHandle, 'soundtouch_setRateChange');
               soundtouch_setSampleRate := GetProcAddress(LibHandle, 'soundtouch_setSampleRate');
               soundtouch_setSetting := GetProcAddress(LibHandle, 'soundtouch_setSetting');
               soundtouch_setTempo := GetProcAddress(LibHandle, 'soundtouch_setTempo');
               soundtouch_setTempoChange := GetProcAddress(LibHandle, 'soundtouch_setTempoChange');
               bpm_createInstance := GetProcAddress(LibHandle, 'bpm_createInstance');
               bpm_destroyInstance := GetProcAddress(LibHandle, 'bpm_destroyInstance');
               bpm_getBpm := GetProcAddress(LibHandle, 'bpm_getBpm');
               bpm_putSamples := GetProcAddress(LibHandle, 'bpm_putSamples');

               Result := St_IsLoaded;
               ReferenceCounter:=1;
            end;
            {$else}
            Pointer(soundtouch_createInstance) := GetProcAddress(LibHandle, 'soundtouch_createInstance');
            if Pointer(soundtouch_createInstance) = nil then begin // not the SoundTouchDLL library.
               ST_Unload;
               result := false
            end else begin
               Pointer(soundtouch_clear) := GetProcAddress(LibHandle, 'soundtouch_clear');
               Pointer(soundtouch_destroyInstance) := GetProcAddress(LibHandle, 'soundtouch_destroyInstance');
               Pointer(soundtouch_flush) := GetProcAddress(LibHandle, 'soundtouch_flush');
               Pointer(soundtouch_getSetting) := GetProcAddress(LibHandle, 'soundtouch_getSetting');
               Pointer(soundtouch_getVersionId) := GetProcAddress(LibHandle, 'soundtouch_getVersionId');
               Pointer(soundtouch_getVersionString2) := GetProcAddress(LibHandle, 'soundtouch_getVersionString2');
               Pointer(soundtouch_getVersionString) := GetProcAddress(LibHandle, 'soundtouch_getVersionString');
               Pointer(soundtouch_isEmpty) := GetProcAddress(LibHandle, 'soundtouch_isEmpty');
               Pointer(soundtouch_numSamples) := GetProcAddress(LibHandle, 'soundtouch_numSamples');
               Pointer(soundtouch_numUnprocessedSamples) := GetProcAddress(LibHandle, 'soundtouch_numUnprocessedSamples');
               Pointer(soundtouch_putSamples) := GetProcAddress(LibHandle, 'soundtouch_putSamples');
               Pointer(soundtouch_receiveSamples) := GetProcAddress(LibHandle, 'soundtouch_receiveSamples');
               Pointer(soundtouch_setChannels) := GetProcAddress(LibHandle, 'soundtouch_setChannels');
               Pointer(soundtouch_setPitch) := GetProcAddress(LibHandle, 'soundtouch_setPitch');
               Pointer(soundtouch_setPitchOctaves) := GetProcAddress(LibHandle, 'soundtouch_setPitchOctaves');
               Pointer(soundtouch_setPitchSemiTones) := GetProcAddress(LibHandle, 'soundtouch_setPitchSemiTones');
               Pointer(soundtouch_setRate) := GetProcAddress(LibHandle, 'soundtouch_setRate');
               Pointer(soundtouch_setRateChange) := GetProcAddress(LibHandle, 'soundtouch_setRateChange');
               Pointer(soundtouch_setSampleRate) := GetProcAddress(LibHandle, 'soundtouch_setSampleRate');
               Pointer(soundtouch_setSetting) := GetProcAddress(LibHandle, 'soundtouch_setSetting');
               Pointer(soundtouch_setTempo) := GetProcAddress(LibHandle, 'soundtouch_setTempo');
               Pointer(soundtouch_setTempoChange) := GetProcAddress(LibHandle, 'soundtouch_setTempoChange');
               Pointer(bpm_createInstance) := GetProcAddress(LibHandle, 'bpm_createInstance');
               Pointer(bpm_destroyInstance) := GetProcAddress(LibHandle, 'bpm_destroyInstance');
               Pointer(bpm_getBpm) := GetProcAddress(LibHandle, 'bpm_getBpm');
               Pointer(bpm_putSamples) := GetProcAddress(LibHandle, 'bpm_putSamples');

               Result := St_IsLoaded;
               ReferenceCounter:=1;
            end;
            {$endif}
        except
        ST_Unload;
        end;
      end;
      {$ELSE}
      if LibHandle <> DynLibs.NilHandle then
      begin
        try
        Pointer(soundtouch_createInstance) :=GetProcAddress(LibHandle, 'soundtouch_createInstance');
          if   Pointer(soundtouch_createInstance) = nil then  // not the SoundTouchDLL library.
          begin
          ST_Unload;
          result := false
          end
          else begin
          Pointer(soundtouch_clear) :=GetProcAddress(LibHandle, 'soundtouch_clear');
          Pointer(soundtouch_destroyInstance) :=GetProcAddress(LibHandle, 'soundtouch_destroyInstance');
          Pointer(soundtouch_flush) :=GetProcAddress(LibHandle, 'soundtouch_flush');
          Pointer(soundtouch_getSetting) :=GetProcAddress(LibHandle, 'soundtouch_getSetting');
          Pointer(soundtouch_getVersionId) :=GetProcAddress(LibHandle, 'soundtouch_getVersionId');
          Pointer(soundtouch_getVersionString2) :=GetProcAddress(LibHandle, 'soundtouch_getVersionString2');
          Pointer(soundtouch_getVersionString) :=GetProcAddress(LibHandle, 'soundtouch_getVersionString');
          Pointer(soundtouch_isEmpty) :=GetProcAddress(LibHandle, 'soundtouch_isEmpty');
          Pointer(soundtouch_numSamples) :=GetProcAddress(LibHandle, 'soundtouch_numSamples');
          Pointer(soundtouch_numUnprocessedSamples) :=GetProcAddress(LibHandle, 'soundtouch_numUnprocessedSamples');
          Pointer(soundtouch_putSamples) :=GetProcAddress(LibHandle, 'soundtouch_putSamples');
          Pointer(soundtouch_receiveSamples) :=GetProcAddress(LibHandle, 'soundtouch_receiveSamples');
          Pointer(soundtouch_setChannels) :=GetProcAddress(LibHandle, 'soundtouch_setChannels');
          Pointer(soundtouch_setPitch) :=GetProcAddress(LibHandle, 'soundtouch_setPitch');
          Pointer(soundtouch_setPitchOctaves) :=GetProcAddress(LibHandle, 'soundtouch_setPitchOctaves');
          Pointer(soundtouch_setPitchSemiTones) :=GetProcAddress(LibHandle, 'soundtouch_setPitchSemiTones');
          Pointer(soundtouch_setRate) :=GetProcAddress(LibHandle, 'soundtouch_setRate');
          Pointer(soundtouch_setRateChange) :=GetProcAddress(LibHandle, 'soundtouch_setRateChange');
          Pointer(soundtouch_setSampleRate) :=GetProcAddress(LibHandle, 'soundtouch_setSampleRate');
          Pointer(soundtouch_setSetting) :=GetProcAddress(LibHandle, 'soundtouch_setSetting');
          Pointer(soundtouch_setTempo) :=GetProcAddress(LibHandle, 'soundtouch_setTempo');
          Pointer(soundtouch_setTempoChange) :=GetProcAddress(LibHandle, 'soundtouch_setTempoChange');

          Pointer(bpm_createInstance) :=GetProcAddress(LibHandle, 'bpm_createInstance');
          Pointer(bpm_destroyInstance) :=GetProcAddress(LibHandle, 'bpm_destroyInstance');
          Pointer(bpm_getBpm) :=GetProcAddress(LibHandle, 'bpm_getBpm');
          Pointer(bpm_putSamples) :=GetProcAddress(LibHandle, 'bpm_putSamples');

          Result := St_IsLoaded;
          ReferenceCounter:=1;
          end;

        except
        ST_Unload;
        end;
      end;
      {$ENDIF}
  end;
end;

procedure ST_Unload;
begin
// < Reference counting
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >

      {$IFNDEF FPC}
      FreeLibrary(LibHandle);
      LibHandle:=0;
      {$else}
      if LibHandle <> DynLibs.NilHandle then
      begin
      DynLibs.UnloadLibrary(LibHandle);
      LibHandle:=DynLibs.NilHandle;
      end;
      {$endif}
end;

end.
