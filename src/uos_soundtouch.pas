{This unit is part of United Openlibraries of Sound (uos)}

{This is the Dynamic loading version of SoundTouch Pascal Wrapper
 from Sandro Cumerlato <sandro.cumerlato@gmail.com>.
 Load library with St_load() and release with St_unload().
 License : modified LGPL.
 Fred van Stappen / fiens@hotmail.com}

unit uos_soundtouch;

{$mode objfpc}{$H+}

interface

uses
  DynLibs;

{$IF not DEFINED(windows)}
type
  THandle = pointer;
{$endif}

var
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
  soundtouch_putSamples: procedure(h: THandle; const samples: PSingle;
  numSamples: cardinal); cdecl;
  soundtouch_receiveSamples: function(h: THandle; outBuffer: PSingle;
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

 LibHandle:TLibHandle=dynlibs.NilHandle; // this will hold our handle for the lib
 ReferenceCounter : cardinal = 0;  // Reference counter
         
function ST_IsLoaded : boolean; inline; 
function ST_Load(const libfilename: string): boolean; // load the lib
procedure ST_Unload(); // unload and frees the lib from memory : do not forget to call it before close application.

implementation

function ST_IsLoaded: boolean;
begin
 Result := (LibHandle <> dynlibs.NilHandle);
end;

function ST_Load(const libfilename: string): boolean;
begin
   Result := False;
  if LibHandle<>0 then 
begin
 Inc(ReferenceCounter);
result:=true 
end  else begin 
    if Length(libfilename) = 0 then exit;
    LibHandle:=DynLibs.SafeLoadLibrary(libfilename); // obtain the handle we want.
  	if LibHandle <> DynLibs.NilHandle then
       begin
    try
    Pointer(soundtouch_createInstance) :=
        GetProcAddress(LibHandle, 'soundtouch_createInstance');
      if   Pointer(soundtouch_createInstance) = nil then  // not the SoundTouchDLL library.
      begin
        ST_Unload;
       result := false end
      else
       begin
         Pointer(soundtouch_clear) :=
        GetProcAddress(LibHandle, 'soundtouch_clear');
         Pointer(soundtouch_destroyInstance) :=
        GetProcAddress(LibHandle, 'soundtouch_destroyInstance');
      Pointer(soundtouch_flush) :=
        GetProcAddress(LibHandle, 'soundtouch_flush');
      Pointer(soundtouch_getSetting) :=
        GetProcAddress(LibHandle, 'soundtouch_getSetting');
      Pointer(soundtouch_getVersionId) :=
        GetProcAddress(LibHandle, 'soundtouch_getVersionId');
      Pointer(soundtouch_getVersionString2) :=
        GetProcAddress(LibHandle, 'soundtouch_getVersionString2');
      Pointer(soundtouch_getVersionString) :=
        GetProcAddress(LibHandle, 'soundtouch_getVersionString');
      Pointer(soundtouch_isEmpty) :=
        GetProcAddress(LibHandle, 'soundtouch_isEmpty');
      Pointer(soundtouch_numSamples) :=
        GetProcAddress(LibHandle, 'soundtouch_numSamples');
      Pointer(soundtouch_numUnprocessedSamples) :=
        GetProcAddress(LibHandle, 'soundtouch_numUnprocessedSamples');
      Pointer(soundtouch_putSamples) :=
        GetProcAddress(LibHandle, 'soundtouch_putSamples');
      Pointer(soundtouch_receiveSamples) :=
        GetProcAddress(LibHandle, 'soundtouch_receiveSamples');
      Pointer(soundtouch_setChannels) :=
        GetProcAddress(LibHandle, 'soundtouch_setChannels');
      Pointer(soundtouch_setPitch) :=
        GetProcAddress(LibHandle, 'soundtouch_setPitch');
      Pointer(soundtouch_setPitchOctaves) :=
        GetProcAddress(LibHandle, 'soundtouch_setPitchOctaves');
      Pointer(soundtouch_setPitchSemiTones) :=
        GetProcAddress(LibHandle, 'soundtouch_setPitchSemiTones');
      Pointer(soundtouch_setRate) :=
        GetProcAddress(LibHandle, 'soundtouch_setRate');
      Pointer(soundtouch_setRateChange) :=
        GetProcAddress(LibHandle, 'soundtouch_setRateChange');
      Pointer(soundtouch_setSampleRate) :=
        GetProcAddress(LibHandle, 'soundtouch_setSampleRate');
      Pointer(soundtouch_setSetting) :=
        GetProcAddress(LibHandle, 'soundtouch_setSetting');
      Pointer(soundtouch_setTempo) :=
        GetProcAddress(LibHandle, 'soundtouch_setTempo');
      Pointer(soundtouch_setTempoChange) :=
        GetProcAddress(LibHandle, 'soundtouch_setTempoChange');

    Result := St_IsLoaded;
    ReferenceCounter:=1;

       end;

      except
      ST_Unload;
    end;
  end;
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

  if LibHandle <> DynLibs.NilHandle then
  begin
    DynLibs.UnloadLibrary(LibHandle);
    LibHandle := DynLibs.NilHandle;
  end;
end;

end.
