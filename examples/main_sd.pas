unit main_sd;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, StdCtrls,
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
    sound: array[0..3] of string;
    posi: integer;
    drum_beats: array[0..2] of string;
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  stopit :boolean = false;
  x: integer = 0;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
  var i: integer;
begin

if stopit = false then
 begin
    for i := 0 to 2 do
    if(Copy(drum_beats[i], posi, 1) = 'x') then
    begin
    uos_Playnofree(i) ;
    end;
    
 inc(posi);
 if(posi > 16) then posi := 1;

  end
  else Timer1.Enabled := false;


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
    i,j : integer;
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

 drum_beats[0] := 'x0x0x0x0x0x0x0x0'; // hat
 drum_beats[1] := '0000x0000000x000'; // snare
 drum_beats[2] := 'x0000000x0x00000'; // kick

  posi := 1;

for i := 0 to 2 do
 begin
uos_CreatePlayer(i);
uos_AddIntoDevOut(i, -1, 0.001, -1, 1, 0, 512);
uos_AddFromFileIntoMemory(i, pchar(sound[i]), -1, 0, 512) ;
end;

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
i : integer;
begin
for i := 0 to 2 do   // free player (not done with playnofree)
 begin
  uos_Stop(i);
  uos_FreePlayer(i);
 end;
sleep(10);
  uos_free();
end;

end.

