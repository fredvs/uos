{This unit is part of United Openlibraries of Sound (uos)}

{This is the Pascal Wrapper + Dynamic loading of OpusURL library.
 Load library with ou_load() and release with ou_unload().
 License : modified LGPL. 
 Fred van Stappen / fiens@hotmail.com}

unit uos_Opusurl;

{$mode objfpc}{$H+}

interface

uses
  ctypes, uos_Opusfile, dynlibs, SysUtils;
  
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

var
 
 op_open_url: function(path: PAnsiChar; out error: Integer): TOpusFile;
 op_test_url: function(path: PAnsiChar; out error: Integer): TOpusFile;
 
 ou_Handle:TLibHandle=dynlibs.NilHandle; 
 
 ReferenceCounter : cardinal = 0;  // Reference counter
         
 function ou_IsLoaded : boolean; inline; 

 Function ou_Load(const libfilename:string) :boolean; // load the lib
 
 Procedure ou_Unload;            

implementation

 function ou_IsLoaded: boolean;
begin
 Result := (ou_Handle <> dynlibs.NilHandle);
end;

Procedure ou_Unload;
begin
// < Reference counting
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >
  if ou_IsLoaded then
  begin
    DynLibs.UnloadLibrary(ou_Handle);
    ou_Handle:=DynLibs.NilHandle;
  end;
end;

Function ou_Load (const libfilename:string) :boolean;
begin
  Result := False;
  if ou_Handle<>0 then 
begin
 Inc(ReferenceCounter);
 result:=true {is it already there ?}
end  else 
begin {go & load the library}
    if Length(libfilename) = 0 then exit;
    ou_Handle:=DynLibs.SafeLoadLibrary(libfilename); // obtain the handle we want
  	if ou_Handle <> DynLibs.NilHandle then
begin {now we tie the functions to the VARs from above}
Pointer(op_open_url):=DynLibs.GetProcedureAddress(OU_Handle,PChar('op_open_url'));
Pointer(op_test_url):=DynLibs.GetProcedureAddress(OU_Handle,PChar('op_test_url'));
end;
   Result := ou_IsLoaded;
   ReferenceCounter:=1;   
end;

end;

end.
