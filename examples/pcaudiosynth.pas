program pcaudiosynth;

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses
{$IFDEF UNIX}
  cthreads, 
  cwstring, {$ENDIF}
  Classes,
  SysUtils,
  ctypes,
  CustApp,
  uos_pcaudio;

type

  TConsole = class(TCustomApplication)
  private
    procedure ConsolePlay;
  protected
    procedure doRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
  end;

var
freqsine : cfloat = 440.0;
samplerate : cfloat = 44100.0;
blocklen: cfloat = 1.0;  // in second
chan : int8 ;

ratio : cfloat;

arlen : int32;
audioobj : paudio_object = nil;
lensine : cfloat;
posine : int32; 
ordir, opath, pc_FileName, libname: string;

thename : pchar;
x : integer = 0;
typformat : integer = 0;
ps : array of cint16;
pl : array of cint32;
pf : array of cfloat; 

procedure ReadSynth;  
var
x2 : integer = 0;
begin
  
   case typformat of
  0: while x2 < length(ps)- chan +1 do
  begin
  ps[x2] := round( Sin((((x2 div chan)+ posine)/ lensine ) * Pi * 2 )* 32767) ;
 if chan = 2 then ps[x2+1] :=  ps[x2];
     if posine +1 > lensine  then posine := 0 else
  posine := posine +1 ;
 if chan = 2 then x2 := x2 + 2 else inc(x2) ;
  end;
  1: while x2 < length(pl) - chan +1 do
  begin
  pl[x2] := round( Sin((((x2 div chan)+ posine)/ lensine ) * Pi * 2 )* 2147483647) ;
  if chan = 2 then pl[x2+1] :=  pl[x2];
     if posine +1 > lensine  then posine := 0 else
  posine := posine +1 ;
  if chan = 2 then x2 := x2 + 2 else inc(x2) ;
  end;
  2: while x2 < length(pf) - chan +1 do
  begin
  pf[x2] := ( Sin((((x2 div chan)+ posine)/ lensine ) * Pi * 2 )) ;
  if chan = 2 then pf[x2+1] :=  pf[x2];
     if posine +1 > lensine then posine := 0 else
  posine := posine +1 ;
  if chan = 2 then x2 := x2 + 2 else inc(x2) ;
  end;
  end;
   
   end;

  procedure TConsole.ConsolePlay;
  begin
    writeln('Sine Wave test.');
    writeln();
  
   {$if defined(cpu64)}  
    {$IFDEF UNIX}
libname := 'LibPcaudio-64.so';
   {$else}
libname := 'LibPcaudio-64.dll';
 {$ENDIF}
 {$else}
   {$IFDEF UNIX}
libname := 'LibPcaudio-32.so';
   {$else}
libname := 'LibPcaudio-32.dll';
 {$ENDIF}
 {$ENDIF}
  
    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));


 {$IFDEF Windows}
     {$if defined(cpu64)}
    pc_FileName := ordir + 'lib\Windows\64bit\' + libname;
       {$else}
    pc_FileName := ordir + 'lib\Windows\32bit\' + libname;
     {$endif}
 {$ENDIF}

     {$if defined(cpu64) and defined(linux) }
    pc_FileName := ordir + 'lib/Linux/64bit/'+ libname;
    {$ENDIF}
   
   {$if defined(cpu86) and defined(linux)}
 pc_FileName := ordir + 'lib/Linux/32bit/'+ libname;
 {$ENDIF}
 
  {$if defined(linux) and defined(cpuarm)}
    pc_FileName := ordir + 'lib/Linux/arm_rpi/'+ libname;
  {$ENDIF}
 
 {$IFDEF freebsd}
    {$if defined(cpu64)}
    pc_FileName := ordir + 'lib/FreeBSD/64bit/'+ libname;
    {$else}
    pc_FileName := ordir + 'lib/FreeBSD/32bit/'+ libname;
    {$endif}
  {$ENDIF}

 {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    pc_FileName := opath + '/lib/Mac/32bit/libpcaudio.dylib';
 {$ENDIF}


   if pc_load(pc_FileName ) then
    writeln( pc_FileName + ' loaded.') else
    writeln(pc_FileName + ' NOT loaded.');
    
  arlen :=  round(blocklen*samplerate);
  
   typformat := 0;
   
   chan := 1;
   
   while typformat < 3 do begin
   
   setlength(ps,arlen);
   setlength(pl,arlen);
   setlength(pf,arlen);
  
   writeln();
    case typformat of
  0: writeln('Test sine-wave format integer 16 bit, ' + inttostr(chan) + ' channels...');
  1: writeln('Test sine-wave format integer 32 bit, ' + inttostr(chan) + ' channels...');
  2: writeln('Test sine-wave format float 32 bit, ' + inttostr(chan) + ' channels...');
     end;
  
    freqsine := 440.0;
    lensine := samplerate / freqsine * 2 ; 
    posine := 0 ;
    x := 0;
    thename := 'test pcaudiolib' ; 
    
     // to use alsa
     audioobj := create_audio_device_object('sysdefault', nil, nil);
      
    // to use pulse; 
 //   audioobj := create_audio_device_object(nil, thename, thename);
    
      if audioobj = nil then
    writeln('audioobj = nil ;(') else
    writeln('audioobj assigned.');

  case typformat of
  0: audio_object_open(audioobj, AUDIO_OBJECT_FORMAT_S16LE, 44100,chan);
  1: audio_object_open(audioobj, AUDIO_OBJECT_FORMAT_S32LE, 44100,chan);
  2: audio_object_open(audioobj, AUDIO_OBJECT_FORMAT_FLOAT32LE, 44100,chan);
  end;
  
  {$IFDEF Windows}  
   ratio := 6;   // mystery...
  {$else}
    ratio := 2;
  {$endif}
   
    while x <  ratio * chan   do
begin

ReadSynth;

 case typformat of
  0: audio_object_write(audioobj,pointer(ps), arlen*sizeof(ps[0])); 
  1: audio_object_write(audioobj,pointer(pl), arlen*sizeof(pl[0])); 
  2: audio_object_write(audioobj,pointer(pf), arlen*sizeof(pf[0])); 
  end;
inc(x);
end;
 audio_object_flush(audioobj);
// audio_object_drain(audioobj); 
 audio_object_close(audioobj);
 audio_object_destroy(audioobj);
 
 inc(typformat);
 
 if (typformat = 3) and (chan = 1) then
 begin
 typformat := 0;
 chan := 2;
 end;
 
 
 sleep(500);
 end;

 end;

  procedure TConsole.doRun;
  begin
    ConsolePlay;
   writeln();
   writeln('Ciao...');
    pc_unload(); // Do not forget this !
    Terminate;   
  end;

constructor TConsole.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

var
  Application: TConsole;
begin
  Application := TConsole.Create(nil);
  Application.Title := 'Sine-Wave and Pcaudiolib';
  Application.Run;
  Application.Free;
end.
