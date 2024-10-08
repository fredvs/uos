program simpledrums_fpGUI;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  uos_flat, 
  fpg_style_chrome_silver_flatmenu,
  fpg_stylemanager,
  SysUtils, Classes, fpg_base, fpg_main,
  {%units 'Auto-generated GUI code'}
  fpg_form, fpg_label, fpg_button, fpg_edit
  {%endunits}
  ;

type

  Tsimpledrum = class(TfpgForm)
  private
    {@VFD_HEAD_BEGIN: simpledrum}
    Label1: TfpgLabel;
    Button1: TfpgButton;
    Button2: TfpgButton;
    EditInteger1: TfpgEdit;
    Label2: TfpgLabel;
    Label3: TfpgLabel;
    Label4: TfpgLabel;
    Label5: TfpgLabel;
    {@VFD_HEAD_END: simpledrum}
    public
    Timertick: Tfpgtimer;
   // Timertick: Tfptimer;
    sound: array[0..3] of string;
    posi: integer;
    drum_beats: array[0..2] of string; 
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure ontimertick(Sender: TObject);
    procedure initall;
    procedure AfterCreate; override;
  end;

{@VFD_NEWFORM_DECL}

{@VFD_NEWFORM_IMPL}

var
   stopit :boolean = false;
   channels : cardinal = 2 ; // stereo output
   allok : boolean = false;
   ms :  array[0..2] of Tmemorystream; 
     
procedure Tsimpledrum.initall;
var ordir: string;
    lib1, lib2: string;
    i : integer;
         
begin
 Timertick := Tfpgtimer.Create(100);
 Timertick.enabled := false;
 Timertick.OnTimer := @ontimertick;
 
 ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));

    {$IFDEF Windows}
         {$if defined(cpu64)}
        lib1 := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
        lib2 := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
         {$else}
        lib1 := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
        lib2 := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
         {$endif}
     {$ENDIF}

     {$if defined(CPUAMD64) and defined(linux) }
   lib1 := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  lib2 := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
     {$ENDIF}
  {$if defined(cpu86) and defined(linux)}
  lib1 := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  lib2 := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
  {$ENDIF}
   {$if defined(linux) and defined(cpuarm)}
  lib1 := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
  lib2 := ordir + 'lib/Linux/arm_raspberrypi/libsndfile-arm.so';
  {$ENDIF}
    {$if defined(linux) and defined(cpuaarch64)}
  lib1 := ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so';
  lib2 := ordir + 'lib/Linux/aarch64_raspberrypi/libsndfile_aarch64.so';
   {$ENDIF}
  
     {$IFDEF freebsd}
        {$if defined(cpu64)}
         lib1 :=  ordir + 'lib/FreeBSD/64bit/libportaudio-64.so'    ;
         lib2 := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so'   ;
        {$else}
        lib1 := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
        lib2 := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so'   ;
        {$endif}
      {$ENDIF}

             
    {$IFDEF Darwin}
  {$IFDEF CPU32}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
   lib1:= opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
   lib2 := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
         {$ENDIF}
  
   {$IFDEF CPU64}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    lib1 := opath + '/lib/Mac/64bit/LibSndFile-64.dylib';
    lib2 := opath + '/lib/Mac/64bit/LibMpg123-64.dylib';
    {$ENDIF}  
 {$ENDIF}

{$if defined(CPUAMD64) and defined(linux) }
     // For Linux amd64, check libsndfile.so
 if lib2 <> 'system' then     
  if uos_TestLoadLibrary(PChar(lib2)) = false then
   lib2 := lib2 + '.2';
{$endif}  

uos_LoadLib(Pchar(lib1),  Pchar(lib2), nil, nil, nil,nil, nil);

sound[0] := ordir + 'sound' + directoryseparator +  'drums' + directoryseparator + 'HH.wav';
sound[1] := ordir + 'sound' + directoryseparator +  'drums' + directoryseparator + 'SD.wav';
sound[2] := ordir + 'sound' + directoryseparator +  'drums' + directoryseparator + 'BD.wav';

// {  // using memorystream
ms[0] := TMemoryStream.Create; 
ms[0].LoadFromFile(pchar(sound[0]));  
ms[0].Position:= 0;

ms[1] := TMemoryStream.Create; 
ms[1].LoadFromFile(pchar(sound[1]));  
ms[1].Position:= 0;

ms[2] := TMemoryStream.Create; 
ms[2].LoadFromFile(pchar(sound[2]));  
ms[2].Position:= 0;
// }

drum_beats[0] := 'x0x0x0x0x0x0x0x0'; // hat
drum_beats[1] := '0000x0000000x000'; // snare
drum_beats[2] := 'x0000000x0x00000'; // kick

 posi := 1;

   for i := 0 to 2 do   
 begin
 if uos_CreatePlayer(i) then

 if uos_SetGlobalEvent(i, true) then
  // This set events (like pause/replay thread) to global.
  //One event (for example replay) will have impact on all players.  

   // using memorystream
 if uos_AddFromMemoryStream(i,ms[i],0,-1,0,256) > -1 then
 
 // using file
   // if uos_AddFromfile(i,pchar(sound[i]),-1,0,256) > -1 then 
{ 
 begin
   
    uos_InputAddDSPVolume(i, 0, 1, 1);
    ///// DSP Volume changer
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1 : InputIndex of a existing input
    ////////// VolLeft : Left volume  ( from 0 to 1 => gain > 1 )
    ////////// VolRight : Right volume

    uos_InputSetDSPVolume(i, 0, 1,
     1, True); /// Set volume
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1 : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled  

end;
}
 if uos_AddFromEndlessMuted(i, channels, 256) > -1 then 
  // this for a dummy endless input, must be last input 
  
 {$if defined(cpuarm) or defined(cpuaarch64)}  // need a lower latency
   if uos_AddIntoDevOut(i, -1, 0.08, -1, -1, 0, 256, -1) > -1 then // stereo output
       {$else}
   if uos_AddIntoDevOut(i, -1, 0.03, -1, -1, 0, 256, -1) > -1 then // stereo output
           {$endif}
 begin
  uos_PlayNoFree(i);
  sleep(250);
  allok := true;
 end else allok := false; 
 end;
 
 if allok = false then fpgapplication.terminate;
end;                                                                                                                            

procedure Tsimpledrum.AfterCreate;
begin
  {%region 'Auto-generated GUI code' -fold}
  {@VFD_BODY_BEGIN: simpledrum}
  Name := 'simpledrum';
  SetPosition(526, 230, 228, 163);
  WindowTitle := 'Simple Drums';
  IconName := '';
  BackGroundColor := $80000001;
  Hint := '';
  WindowPosition := wpScreenCenter;

  Label1 := TfpgLabel.Create(self);
  with Label1 do
  begin
    Name := 'Label1';
    SetPosition(12, 12, 80, 15);
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Interval in ms';
  end;

  Button1 := TfpgButton.Create(self);
  with Button1 do
  begin
    Name := 'Button1';
    SetPosition(32, 80, 164, 39);
    Text := 'Start';
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 3;
    onclick := @btnStartClick;
  end;

  Button2 := TfpgButton.Create(self);
  with Button2 do
  begin
    Name := 'Button2';
    SetPosition(32, 128, 164, 31);
    Text := 'Stop';
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 4;
    onclick := @btnStopClick;
  end;

  EditInteger1 := TfpgEdit.Create(self);
  with EditInteger1 do
  begin
    Name := 'EditInteger1';
    SetPosition(20, 32, 68, 23);
    ExtraHint := '';
    FontDesc := '#Edit1';
    ParentShowHint := False;
    TabOrder := 5;
    Text := '100';
  end;

  Label2 := TfpgLabel.Create(self);
  with Label2 do
  begin
    Name := 'Label2';
    SetPosition(156, 20, 60, 47);
    Alignment := taCenter;
    FontDesc := 'Courier 10 Pitch-32:bold:antialias=true';
    ParentShowHint := False;
    Text := '1';
  end;

  Label3 := TfpgLabel.Create(self);
  with Label3 do
  begin
    Name := 'Label3';
    SetPosition(104, 20, 24, 43);
    FontDesc := 'Courier 10 Pitch-32:antialias=true';
    ParentShowHint := False;
    Text := '\';
  end;

  Label4 := TfpgLabel.Create(self);
  with Label4 do
  begin
    Name := 'Label4';
    SetPosition(124, 20, 24, 43);
    BackgroundColor := TfpgColor($FFD3D3D3);
    FontDesc := 'Courier 10 Pitch-32:antialias=true';
    ParentShowHint := False;
    Text := '/';
    Visible := False;
    Hint := '';
  end;

  Label5 := TfpgLabel.Create(self);
  with Label5 do
  begin
    Name := 'Label5';
    SetPosition(20, 56, 80, 15);
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'BPM = 150';
    Hint := '';
  end;

  {@VFD_BODY_END: simpledrum}
  {%endregion}
  initall;
end;

procedure Tsimpledrum.btnStartClick(Sender: TObject);
  begin
  TimerTick.Interval := strtoint(EditInteger1.text);
  label5.text := 'BPM = ' + inttostr(round(1000/TimerTick.Interval*60/4));
  stopit := false;
  posi := 1;
  TimerTick.Enabled := true; 
  end;
  
procedure Tsimpledrum.btnStopClick(Sender: TObject);
  begin
    stopit := true;      
  end;
  
procedure Tsimpledrum.ontimertick(Sender: TObject);
  var i: integer;
  ge : boolean = false;
begin
if stopit = false then
 begin
if (posi = 1) or (posi = 9) then
begin
 label3.visible := true;
 label4.visible := false;
end else 
if (posi = 5) or (posi = 13) then
begin
 label3.visible := false;
 label4.visible := true;
end;
 
if (posi = 1) then label3.textcolor := clred else
label3.textcolor := clblack;

label2.text := inttostr(posi);
if posi = 1 then label2.textcolor := clred else
if (posi = 5) or (posi = 9) or (posi = 13) then
 label2.textcolor := cllime else label2.textcolor := clblack;
 
   for i := 0 to 2 do
    if(Copy(drum_beats[i], posi, 1) = 'x') then
    begin
    uos_PlaynofreePaused(i) ;
     end;
   
//    fpgapplication.processmessages;
      
    // uos_SetGlobalEvent(true) was executed --> This set events (like pause/replay threads) to global.
    // One event (for example uos_replay) will have impact on all players.
 
    for i := 0 to 2 do
    if(ge = false) and (Copy(drum_beats[i], posi, 1) = 'x') then 
    begin
    uos_RePlay(i); // A uos_replay() of each player will have impact on all players.
    ge := true; 
    end;
     
 inc(posi);
 if(posi > 16) then posi := 1;
 
 end else Timertick.Enabled := false;
  
end;   

procedure MainProc;
var
  frm: Tsimpledrum;
begin
  fpgApplication.Initialize;
  try
     if fpgStyleManager.SetStyle('Chrome silver flat menu') then
          fpgStyle := fpgStyleManager.Style;
    fpgApplication.CreateForm(Tsimpledrum, frm);
    fpgApplication.MainForm := frm;
    frm.Show;
    fpgApplication.Run;
  finally
  uos_free();
  frm.Free;
  end;
end;

begin
  MainProc;
end.
