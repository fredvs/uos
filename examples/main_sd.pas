unit main_sd;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Classes, StdCtrls,
  ExtCtrls,  uos_flat;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
    sound: array[0..2] of string;
    ms :  array[0..2] of Tmemorystream; 
    posi: integer;
    drum_beats: array[0..2] of string;
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  stopit :boolean = false;
  allok : boolean = false;
  x: integer = 0;
  channels : cardinal = 2 ; // stereo output
   
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
  var i: integer;
   ge : boolean = false;
begin
 Timer1.Enabled := false;
if stopit = false then
 begin

    for i := 0 to 2 do
    if(Copy(drum_beats[i], posi, 1) = 'x') then
    begin
     // uos_InputSetDSPVolume(i,0,0.5,0.5,true);
     uos_PlaynofreePaused(i) ;
     end;
     
     application.processmessages;  // yes or no ?
    
    // if uos_SetGlobalEvent(true) was executed --> This set events (like pause/replay threads) to global.
    // One event (for example uos_replay) will have impact on all players.
     for i := 0 to 2 do
    if(ge = false) and (Copy(drum_beats[i], posi, 1) = 'x') then 
    begin
    uos_RePlay(i); 
    ge := true; // A uos_replay() of each player will have impact on all players.
    end;
  
 inc(posi);
 if(posi > 16) then posi := 1;
 Timer1.Enabled := true;
  end;
 
 end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 Timer1.interval := strtoint(edit1.Text);
 stopit := false;
 posi := 1;
 Timer1.Enabled := true;
 end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  stopit := true;
end;

procedure TForm1.FormActivate(Sender: TObject);
var ordir: string;
    lib1, lib2: string;
    i : integer;
begin
  ordir := Application.Location;

    {$IFDEF Windows}
         {$if defined(cpu64)}
        lib1 := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
        lib2 := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
         {$else}
        lib1 := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
        lib2 := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
         {$endif}
     {$ENDIF}

     {$IFDEF linux}
        {$if defined(cpu64)}
       lib1 :=  ordir + 'lib/Linux/64bit/LibPortaudio-64.so'    ;
       lib2 := ordir + 'lib/Linux/64bit/LibSndFile-64.so'   ;
        {$else}
        lib1 := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
         lib2 := ordir + 'lib/Linux/32bit/LibSndFile-32.so'   ;
        {$endif}
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
        ordir := copy(ordir, 1, Pos('/UOS', ordir) - 1);
       lib1 :=  ordir + '/lib/Mac/32bit/LibPortaudio-32.dylib';
       lib2 :=  ordir + '/lib/Mac/32bit/LibSndFile-32.dylib';
     {$ENDIF}

uos_LoadLib(Pchar(lib1),  Pchar(lib2), nil, nil, nil,nil);

sound[0] := Application.Location + 'sound' + directoryseparator +  'drums' + directoryseparator + 'HH.wav';
sound[1] := Application.Location + 'sound' + directoryseparator +  'drums' + directoryseparator + 'SD.wav';
sound[2] := Application.Location + 'sound' + directoryseparator +  'drums' + directoryseparator + 'BD.wav';

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
   
  //  if uos_InputAddDSPVolume(i,0,1,1) > -1 then
 
   if uos_AddFromEndlessMuted(i, channels, 256) > -1 then 
 // this for a dummy endless input, must be last input
 
  if uos_AddIntoDevOut(i, -1, 0.03, -1, -1, 0, 256) > -1 then // stereo output
 begin
  uos_PlayNoFree(i);
  sleep(250);
  allok := true;
 end else allok := false; 
 end;
 
// if allok = false then application.terminate;
end;                                            

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
uos_free();
end;

end.

