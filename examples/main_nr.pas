
/////////////////// Demo how to use United Openlib of Sound ////////////////////

unit main_nr;

{$mode objfpc}{$H+}

interface

uses
  uos_flat, Forms, Dialogs, SysUtils, fileutil, Graphics, ctypes,
  StdCtrls, ComCtrls, ExtCtrls, Classes, Controls;

type
  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Chknoise: TCheckBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit2: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label1: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    OpenDialog1: TOpenDialog;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    Shape1: TShape;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ChknoiseChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure ClosePlayer1;
    private
    { private declarations }
  public
    { public declarations }
  end;


procedure uos_logo();

var
  Form1: TForm1;
  BufferBMP: TBitmap;
  PlayerIndex1: integer;
  OutputIndex1, InputIndex1, DSPIndex1, DSPIndex2, PluginIndex1, PluginIndex2: integer;
  plugsoundtouch : boolean = false;
  plugbs2b : boolean = false;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.ClosePlayer1;
begin
  button3.Enabled := True;
  button4.Enabled := False;
  button5.Enabled := False;
  button6.Enabled := False;
end;

procedure TForm1.FormActivate(Sender: TObject);
var
  ordir: string;
{$IFDEF Darwin}
  opath: string;
{$ENDIF}
begin
  ordir := application.Location;
  uos_logo();
             {$IFDEF Windows}
     {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
  Edit2.Text := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
  {$else}
  Edit1.Text := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
  Edit2.Text := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
  {$endif}
  Edit4.Text := ordir + 'sound\noisyvoice.ogg';
 {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    Edit1.Text := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
     Edit2.Text := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
       {$else}
   Edit1.Text := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
     Edit2.Text := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
   {$endif}
     Edit4.Text := ordir + 'sound/noisyvoice.ogg';
 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit2.Text := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';

  Edit4.Text := opath + 'sound/noisyvoice.ogg';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/Linux/64bit/LibSndFile-64.so';

{$else}
  Edit1.Text := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit2.Text := ordir + 'lib/Linux/32bit/LibSndFile-32.so';

{$endif}
  Edit4.Text := ordir + 'sound/noisyvoice.ogg';
            {$ENDIF}

  opendialog1.Initialdir := application.Location + 'sound';

end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
end;

procedure TForm1.Panel1Click(Sender: TObject);
begin

end;


procedure TForm1.Button1Click(Sender: TObject);
var
loadok : boolean = false;
begin
  // Load the libraries
  // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfilefilename: PChar) : LongInt;

  if uos_LoadLib(Pchar(Edit1.text), Pchar(Edit2.text), nil, nil, nil, nil) = 0 then
  // You may load one or more libraries . When you want... :

 begin
    form1.hide;
    loadok := true;
    button1.Enabled := False;
    edit1.ReadOnly := True;
    edit2.ReadOnly := True;

          button1.Caption :=
        'PortAudio and SndFile libraries are loaded...'  ;
      Height := 82;
     panel1.left := 0;
      panel1.top := 0;
    panel1.height :=  form1.Height;
     panel1.width :=  form1.width;
      panel1.visible := true;
    Position := poScreenCenter;
    Caption := 'Noise Remover.    uos version ' + inttostr(uos_getversion());
    Show;
      end else  MessageDlg('Error while loading libraries...', mtWarning, [mbYes], 0);
  end;


procedure TForm1.Button5Click(Sender: TObject);
begin
  uos_Pause(PlayerIndex1);
  Button4.Enabled := True;
  Button5.Enabled := False;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Button4.Enabled := False;
  Button5.Enabled := True;
  Button6.Enabled := True;
  application.ProcessMessages;
  uos_RePlay(PlayerIndex1);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
   samformat: shortint;

 begin

     samformat := 0;

   PlayerIndex1 := 0;
   // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
   // If PlayerIndex exists already, it will be overwritten...

   {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
    uos_CreatePlayer(PlayerIndex1);
    {$else}
   uos_CreatePlayer(PlayerIndex1,self);
   {$endif}
   //// Create the player.
   //// PlayerIndex : from 0 to what your computer can do !
   //// If PlayerIndex exists already, it will be overwriten...

    InputIndex1 := uos_AddFromFile(PlayerIndex1, pchar(Edit4.text), -1,
    samformat, -1);
   //// add input from audio file with custom parameters
   ////////// FileName : filename of audio file
   //////////// PlayerIndex : Index of a existing Player
   ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
   ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
   //////////// FramesCount : default : -1 (65536 div channels)
   //  result : -1 nothing created, otherwise Input Index in array

   if InputIndex1 > -1 then begin

     // OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1) ;
   //// add a Output into device with default parameters
   OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, InputIndex1),
    uos_InputGetChannels(PlayerIndex1, InputIndex1), samformat, -1);
   //// add a Output into device with custom parameters
   //////////// PlayerIndex : Index of a existing Player
   //////////// Device ( -1 is default Output device )
   //////////// Latency  ( -1 is latency suggested ) )
   //////////// SampleRate : delault : -1 (44100)   /// here default samplerate of input
   //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
   //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
   //////////// FramesCount : default : -1 (65536)
   //  result : -1 nothing created, otherwise Output Index in array


 uos_InputAddDSPNoiseRemoval(PlayerIndex1, InputIndex1);
 uos_InputSetDSPNoiseRemoval(PlayerIndex1, InputIndex1, chknoise.Checked);
    /// Add DSP Noise removal. First chunck will be the noise sample.

   /////// procedure to execute when stream is terminated
   uos_EndProc(PlayerIndex1, @ClosePlayer1);
   ///// Assign the procedure of object to execute at end
   //////////// PlayerIndex : Index of a existing Player
   //////////// ClosePlayer1 : procedure of object to execute inside the general loop

   button3.Enabled := False;
   button6.Enabled := True;
   button5.Enabled := True;
   button4.Enabled := False;

   uos_Play(PlayerIndex1);  /////// everything is ready, here we are, lets play it...
   end;

end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  uos_Stop(PlayerIndex1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if opendialog1.Execute then
    Edit4.Text := opendialog1.FileName;
end;


procedure TForm1.ChknoiseChange(Sender: TObject);
begin
  if button3.Enabled = False then
  uos_InputSetDSPNoiseRemoval(PlayerIndex1, InputIndex1, chknoise.Checked);
end;


procedure uos_logo();
var
  xpos, ypos: integer;
  ratio: double;
begin
  xpos := 0;
  ypos := 0;
  ratio := 1;
  BufferBMP := TBitmap.Create;
  with form1 do
  begin
    form1.PaintBox1.Parent.DoubleBuffered := True;
    PaintBox1.Height := round(ratio * 116);
    PaintBox1.Width := round(ratio * 100);
    BufferBMP.Height := PaintBox1.Height;
    BufferBMP.Width := PaintBox1.Width;
    BufferBMP.Canvas.AntialiasingMode := amOn;
    BufferBMP.Canvas.Pen.Width := round(ratio * 6);
    BufferBMP.Canvas.brush.Color := clmoneygreen;
    BufferBMP.Canvas.FillRect(0, 0, PaintBox1.Width, PaintBox1.Height);
    BufferBMP.Canvas.Pen.Color := clblack;
    BufferBMP.Canvas.brush.Color := $70FF70;
    BufferBMP.Canvas.Ellipse(round(ratio * (22) + xpos),
      round(ratio * (30) + ypos), round(ratio * (72) + xpos),
      round(ratio * (80) + ypos));
    BufferBMP.Canvas.brush.Color := clmoneygreen;
    BufferBMP.Canvas.Arc(round(ratio * (34) + xpos), round(ratio * (8) + ypos),
      round(ratio * (58) + xpos), round(ratio * (32) + ypos), round(ratio * (58) + xpos),
      round(ratio * (20) + ypos), round(ratio * (46) + xpos),
      round(ratio * (32) + xpos));
    BufferBMP.Canvas.Arc(round(ratio * (34) + xpos), round(ratio * (32) + ypos),
      round(ratio * (58) + xpos), round(ratio * (60) + ypos), round(ratio * (34) + xpos),
      round(ratio * (48) + ypos), round(ratio * (46) + xpos),
      round(ratio * (32) + ypos));
    BufferBMP.Canvas.Arc(round(ratio * (-28) + xpos), round(ratio * (18) + ypos),
      round(ratio * (23) + xpos), round(ratio * (80) + ypos), round(ratio * (20) + xpos),
      round(ratio * (50) + ypos), round(ratio * (3) + xpos), round(ratio * (38) + ypos));
    BufferBMP.Canvas.Arc(round(ratio * (70) + xpos), round(ratio * (18) + ypos),
      round(ratio * (122) + xpos), round(ratio * (80) + ypos),
      round(ratio * (90 - xpos)),
      round(ratio * (38) + ypos), round(ratio * (72) + xpos),
      round(ratio * (50) + ypos));
    BufferBMP.Canvas.Font.Name := 'Arial';
    BufferBMP.Canvas.Font.Size := round(ratio * 10);
    BufferBMP.Canvas.TextOut(round(ratio * (4) + xpos),
      round(ratio * (83) + ypos), 'United Openlib');
    BufferBMP.Canvas.Font.Size := round(ratio * 7);
    BufferBMP.Canvas.TextOut(round(ratio * (20) + xpos),
      round(ratio * (101) + ypos), 'of');
    BufferBMP.Canvas.Font.Size := round(ratio * 10);
    BufferBMP.Canvas.TextOut(round(ratio * (32) + xpos),
      round(ratio * (98) + ypos), 'Sound');
  end;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if (button3.Enabled = False) then
  begin
    button6.Click;
    sleep(500);
  end;
    uos_free;
    BufferBMP.free;
  end;


end.
