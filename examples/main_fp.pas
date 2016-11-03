
/////////////////// Demo how to use United Openlib of Sound ////////////////////


unit main_fp;

{$mode objfpc}{$H+}

interface

uses
  uos_flat, Forms, Dialogs, SysUtils, Graphics,
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
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    OpenDialog1: TOpenDialog;
    PaintBox1: TPaintBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioGroup1: TRadioGroup;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure ClosePlayer1;
    procedure TrackBar3Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

procedure uos_logo();

var
  test : ttimer;
  Form1: TForm1;
  BufferBMP: TBitmap;
  PlayerIndex1: cardinal;
  Out1Index, In1Index, EQIndex1, EQIndex2, EQIndex3, FTIndex1: integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ClosePlayer1;
begin
  Form1.button3.Enabled := True;
  Form1.button4.Enabled := False;
  Form1.button5.Enabled := False;
  Form1.button6.Enabled := False;
end;

procedure TForm1.TrackBar3Change(Sender: TObject);
var
  gain: double;
begin
  if TrackBar3.Position = 100 then
    gain := 1
  else
  if TrackBar3.Position > 100 then
    gain := 1 + ((100 - TrackBar3.Position) / 25)
  else
    gain := TrackBar3.Position / 100;

  if (button3.Enabled = False) then
    uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex3, -1, -1, Gain, -1, True,
      checkbox1.Checked, nil);
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
  Edit3.Text := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
   {$else}
  Edit1.Text := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
  Edit2.Text := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
  Edit3.Text := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
    {$endif}
  Edit4.Text := ordir + 'sound\test.mp3';
 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit2.Text := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
  Edit3.Text := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
  Edit4.Text := opath + 'sound/test.mp3';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  {$else}
  Edit1.Text := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit2.Text := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
  Edit3.Text := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
  {$endif}
  Edit4.Text := ordir + 'sound/test.mp3';
            {$ENDIF}
  
 {$IFDEF freebsd}
    {$if defined(cpu64)}
   Edit1.Text := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
  Edit3.Text := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
  Edit2.Text := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
  {$else}
  Edit1.Text := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
  Edit2.Text := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
  Edit3.Text := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
  {$endif}
  Edit4.Text := ordir + 'sound/test.mp3';
            {$ENDIF}

  opendialog1.Initialdir := application.Location + 'sound';
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
end;

procedure TForm1.RadioButton1Change(Sender: TObject);
var
  typfilt: shortint;
begin
  if radiobutton1.Checked = True then
    typfilt := 2;
  if radiobutton2.Checked = True then
    typfilt := 3;
  if radiobutton3.Checked = True then
    typfilt := 4;
  if radiobutton4.Checked = True then
    typfilt := 5;
  if (button3.Enabled = False) then
    uos_SetFilterIn(PlayerIndex1, In1Index, FTIndex1, StrToInt(edit6.Text),
      StrToInt(edit5.Text),
      1, typfilt, True, checkbox2.Checked, nil);

end;



procedure TForm1.TrackBar1Change(Sender: TObject);
var
  gain: double;
begin
  if TrackBar1.Position = 100 then
    gain := 1
  else
  if TrackBar1.Position > 100 then
    gain := 1 + ((100 - TrackBar1.Position) / 20)
  else
    gain := TrackBar1.Position / 100;
  if (button3.Enabled = False) then
    uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex1, -1, -1, Gain, -1, True,
      checkbox1.Checked, nil);
end;


procedure TForm1.TrackBar2Change(Sender: TObject);
var
  gain: double;
begin
  if TrackBar2.Position = 100 then
    gain := 1
  else
  if TrackBar2.Position > 100 then
    gain := 1 + ((100 - TrackBar2.Position) / 25)
  else
    gain := TrackBar2.Position / 100;
  if (button3.Enabled = False) then
    uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex2, -1, -1, Gain, -1, True,
      checkbox1.Checked, nil);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin

  // Load the libraries
  // function uos_LoadLib(PortAudioFileName: Pchar; SndFileFileName: Pchar; Mpg123FileName ; Mp4ff, Faad2: Pchar) : integer;
     if uos_LoadLib(Pchar(edit1.Text), pchar(edit2.Text), pchar(edit3.Text), nil, nil) = 0 then
  begin
    form1.hide;
    button1.Caption := 'PortAudio, SndFile and Mpg123 libraries are loaded...';
    button1.Enabled := False;
    edit1.ReadOnly := True;
    edit2.ReadOnly := True;
    edit3.ReadOnly := True;
    form1.Height := 352;
    form1.Position := poScreenCenter;
    form1.Show;
  end
  else
  begin
    if uosLoadResult.PAloaderror = 1 then
      MessageDlg(edit1.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if uosLoadResult.PAloaderror = 2 then
      MessageDlg(edit1.Text + ' do not load...', mtWarning, [mbYes], 0);
    if uosLoadResult.SFloaderror = 1 then
      MessageDlg(edit2.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if uosLoadResult.SFloaderror = 2 then
      MessageDlg(edit2.Text + ' do not load...', mtWarning, [mbYes], 0);
    if uosLoadResult.MPloaderror = 1 then
      MessageDlg(edit3.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if uosLoadResult.MPloaderror = 2 then
      MessageDlg(edit3.Text + ' do not load...', mtWarning, [mbYes], 0);
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  uos_Pause(PlayerIndex1);
  Button4.Enabled := True;
  Button5.Enabled := False;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  uos_RePlay(PlayerIndex1);
  ;
  Button4.Enabled := False;
  Button5.Enabled := True;
  Button6.Enabled := True;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  EqGain: double;
  typfilt: shortint;
begin
  PlayerIndex1 := 0;
  // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
  // If PlayerIndex exists already, it will be overwritten...

    uos_CreatePlayer(PlayerIndex1);
  //// Create the player.
  //// PlayerIndex : from 0 to what your computer can do !
  //// If PlayerIndex exists already, it will be overwriten...

  In1Index := uos_AddFromFile(PlayerIndex1, pchar(Edit4.Text), -1, 0, -1);
  //// add input from audio file with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  ////////// FileName : filename of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  ////////// FramesCount : default: -1 (= 65536)

  if  In1Index > -1 then begin

  Out1Index := uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, In1Index), -1, 0, -1);
  //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (= 65536)

  EQIndex1 := uos_AddFilterIn(PlayerIndex1, In1Index, 1, 1000, 1, 1, True, nil);
  //////////// PlayerIndex : Index of a existing Player
  ////////// In1Index : InputIndex of a existing Input
  ////////// LowFrequency : Lowest frequency of filter
  ////////// HighFrequency : Highest frequency of filter
  ////////// Gain : gain to apply to filter ( 1 = no gain )
  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  ////////// LoopProc : External procedure to execute after filter
  //  result : -1 nothing created, otherwise index of DSPIn in array

  EQIndex2 := uos_AddFilterIn(PlayerIndex1, In1Index, 1000, 8000, 1, 1, True, nil);
  EQIndex3 := uos_AddFilterIn(PlayerIndex1, In1Index, 8000, 22000, 1, 1, True, nil);

  if radiobutton1.Checked = True then
    typfilt := 2;
  if radiobutton2.Checked = True then
    typfilt := 3;
  if radiobutton3.Checked = True then
    typfilt := 4;
  if radiobutton4.Checked = True then
    typfilt := 5;

  FTIndex1 := uos_AddFilterIn(PlayerIndex1, In1Index, StrToInt(edit6.Text),
    StrToInt(edit5.Text), 1, typfilt, True, nil);

  uos_SetFilterIn(PlayerIndex1, In1Index, FTIndex1, -1, -1, -1, -1,
    True, checkbox2.Checked, nil);
  //////////// PlayerIndex : Index of a existing Player
  ////////// InputIndex : InputIndex of a existing Input
  ////////// DSPInIndex : DSPInIndex of existing DSPIn
  ////////// LowFrequency : Lowest frequency of filter ( default = -1 : current LowFrequency )
  ////////// HighFrequency : Highest frequency of filter ( default = -1 : current HighFrequency )
  ////////// Gain   : Gain to apply ( -1 = current gain)  ( 0 = silence, 1 = no gain, < 1 = less gain, > 1 = more gain)
  ////////// TypeFilter: Type of filter : ( default = -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  ////////// Enable :  Filter enabled


  if TrackBar1.Position = 100 then
    EqGain := 1
  else
  if TrackBar1.Position > 100 then
    EqGain := 1 + ((100 - TrackBar1.Position) div 25)
  else
    EqGain := TrackBar1.Position div 100;

  uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex1, -1, -1, EqGain, -1, True,
    checkbox1.Checked, nil);

  if TrackBar2.Position = 100 then
    EqGain := 1
  else
  if TrackBar2.Position > 100 then
    EqGain := 1 + ((100 - TrackBar2.Position) div 25)
  else
    EqGain := TrackBar2.Position div 100;
  uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex2, -1, -1, EqGain, -1, True,
    checkbox1.Checked, nil);

  if TrackBar3.Position = 100 then
    EqGain := 1
  else
  if TrackBar3.Position > 100 then
    EqGain := 1 + ((100 - TrackBar3.Position) div 25)
  else
    EqGain := TrackBar3.Position div 100;
  uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex3, -1, -1, EqGain, -1, True,
    checkbox1.Checked, nil);

  uos_EndProc(PlayerIndex1, @ClosePlayer1);
  ///// Assign the procedure of object to execute at end
  //////////// PlayerIndex : Index of a existing Player
  //////////// ClosePlayer1 : procedure of object to execute inside the loop
  /////// procedure to execute when stream is terminated

  uos_Play(PlayerIndex1);  /////// everything is ready, here we are, lets play it...

  trackbar2.Enabled := True;
  Button3.Enabled := False;
  Button4.Enabled := False;
  Button6.Enabled := True;
  Button5.Enabled := True;
  CheckBox1.Enabled := True;

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

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if (button3.Enabled = False) then
  begin
    uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex1, -1, -1, -1, -1, True,
      checkbox1.Checked, nil);
    uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex2, -1, -1, -1, -1, True,
      checkbox1.Checked, nil);
    uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex3, -1, -1, -1, -1, True,
      checkbox1.Checked, nil);
  end;
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
  Form1.Height := 150;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if (button3.Enabled = False) then
  begin
    button6.Click;
    sleep(500);
  end;
  if button1.Enabled = False then
   uos_free;
end;

end.
