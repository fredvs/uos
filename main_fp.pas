
/////////////////// Demo how to use United Openlib of Sound ////////////////////


unit main_fp;

{$mode objfpc}{$H+}

interface

uses
  uos, Forms, Dialogs, SysUtils, Graphics, 
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
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
     procedure TrackBar2Change(Sender: TObject);
       procedure ClosePlayer1;
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar3MouseUp(Sender: TObject; Button: TMouseButton; 
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
  end;
  
procedure UOS_logo();

var
  Form1: TForm1;
  BufferBMP: TBitmap;
  Player1: TUOS_Player;
  Out1Index, In1Index, EQIndex1, EQIndex2, EQIndex3, FTIndex1: integer;
  Init: TUOS_Init;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ClosePlayer1;
begin
  Form1.button3.Enabled := true;
  Form1.button4.Enabled := False;
  Form1.button5.Enabled := False;
  Form1.button6.Enabled := False;
end;

procedure TForm1.TrackBar3Change(Sender: TObject);
var
gain : double;  
begin
 if TrackBar3.Position = 100 then gain := 1 else
 if TrackBar3.Position > 100 then gain :=  1 + ((100 - TrackBar3.Position) / 25)
 else gain := TrackBar3.Position / 100 ;
  
 if assigned(Player1) and (button3.Enabled = false) then 
   Player1.SetFilterIn(In1Index, EQIndex3, -1, -1, Gain, -1, True, checkbox1.Checked);
end;

procedure TForm1.TrackBar3MouseUp(Sender: TObject; Button: TMouseButton; 
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TForm1.FormActivate(Sender: TObject);
{$IFDEF Darwin}
var
  opath: string;
            {$ENDIF}
begin
   UOS_logo();
      {$IFDEF Windows}
     {$if defined(cpu64)}
  edit1.Text := application.Location + 'lib\LibPortaudio-64.dll';
{$else}
  edit1.Text := application.Location + 'lib\LibPortaudio-32.dll';
   {$endif}
  Edit4.Text := application.Location + 'sound\test.ogg';
 {$ENDIF}

  {$IFDEF Darwin}
  opath := application.Location;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  edit1.Text := opath + '/lib/LibPortaudio-32.dylib';
  Edit4.Text := opath + 'sound/test.ogg';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  edit1.Text := application.Location + 'lib/LibPortaudio-64.so';
{$else}
  edit1.Text := application.Location + 'lib/LibPortaudio-32.so';
{$endif}

  Edit4.Text := application.Location + 'sound/test.ogg';
            {$ENDIF}
  //////////////////////////////////////////////////////////////////////////

    {$IFDEF Windows}
       {$if defined(cpu64)}
  edit2.Text := application.Location + 'lib\LibSndFile-64.dll';
{$else}
  edit2.Text := application.Location + 'lib\LibSndFile-32.dll';
{$endif}

 {$ENDIF}

  {$IFDEF Darwin}
  opath := application.Location;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  edit2.Text := opath + '/lib/LibSndFile-32.dylib';
            {$ENDIF}

   {$IFDEF linux}
      {$if defined(cpu64)}
  edit2.Text := application.Location + 'lib/LibSndFile-64.so';
{$else}
  edit2.Text := application.Location + 'lib/LibSndFile-32.so';
{$endif}

            {$ENDIF}
  //////////////////////////////////////////////////////////////////////////
 {$IFDEF Windows}
       {$if defined(cpu64)}
  edit3.Text := application.Location + 'lib\LibMpg123-64.dll';
{$else}
  edit3.Text := application.Location + 'lib\LibMpg123-32.dll';
{$endif}
 {$ENDIF}

  {$IFDEF Darwin}
  opath := application.Location;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  edit3.Text := opath + '/lib/LibMpg123-32.dylib';
            {$ENDIF}

   {$IFDEF linux}
      {$if defined(cpu64)}
  edit3.Text := application.Location + 'lib/LibMpg123-64.so';
{$else}
  edit3.Text := application.Location + 'lib/LibMpg123-32.so';
{$endif}

            {$ENDIF}
  opendialog1.Initialdir := application.Location + 'sound';
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
end;

procedure TForm1.RadioButton1Change(Sender: TObject);
var
  typfilt : shortint;
begin
 if radiobutton1.Checked = true then typfilt := 2;
 if radiobutton2.Checked = true then typfilt := 3;
 if radiobutton3.Checked = true then typfilt := 4;
 if radiobutton4.Checked = true then typfilt := 5;
 if assigned(Player1) and (button3.Enabled = false) then
  Player1.SetFilterIn(In1Index, FTIndex1,  strtoint(edit6.text),strtoint(edit5.text), 1, typfilt, True, checkbox2.Checked);
  
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
  var
  gain : double;  
  begin
   if TrackBar1.Position = 100 then gain := 1 else
   if TrackBar1.Position > 100 then gain :=  1 + ((100 - TrackBar1.Position) / 20)
   else gain := TrackBar1.Position / 100 ;
  if assigned(Player1) and (button3.Enabled = false) then 
     Player1.SetFilterIn(In1Index, EQIndex1, -1, -1, Gain, -1, True, checkbox1.Checked);
  end;


procedure TForm1.TrackBar2Change(Sender: TObject);
var
gain : double;  
begin
 if TrackBar2.Position = 100 then gain := 1 else
 if TrackBar2.Position > 100 then gain :=  1 + ((100 - TrackBar2.Position) / 25)
 else gain := TrackBar2.Position / 100 ;
 if assigned(Player1) and (button3.Enabled = false) then 
   Player1.SetFilterIn(In1Index, EQIndex2, -1, -1, Gain, -1, True, checkbox1.Checked);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Init := TUOS_Init.Create;   //// Create Iibraries Loader-Init
 
  Init.PA_FileName := edit1.Text;
  Init.SF_FileName := edit2.Text;
  Init.MP_FileName := edit3.Text;
  Init.Flag := LoadAll;

  Init.LoadLib;

  if (Init.LoadResult.PAloaderror = 0)
  and (Init.LoadResult.MPloaderror = 0) and
   (Init.LoadResult.Sfloaderror = 0) 
    then
  begin
    form1.hide;
    Init.InitLib();
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
    if Init.LoadResult.PAloaderror = 1 then
      MessageDlg(edit1.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if Init.LoadResult.PAloaderror = 2 then
      MessageDlg(edit1.Text + ' do not load...', mtWarning, [mbYes], 0);
    if Init.LoadResult.SFloaderror = 1 then
      MessageDlg(edit2.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if Init.LoadResult.SFloaderror = 2 then
      MessageDlg(edit2.Text + ' do not load...', mtWarning, [mbYes], 0);
    if Init.LoadResult.MPloaderror = 1 then
      MessageDlg(edit3.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if Init.LoadResult.MPloaderror = 2 then
      MessageDlg(edit3.Text + ' do not load...', mtWarning, [mbYes], 0);
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Player1.Pause;
  Button4.Enabled := True;
  Button5.Enabled := False;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Player1.RePlay;
  Button4.Enabled := False;
  Button5.Enabled := True;
  Button6.Enabled := True;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
EqGain : double ;
typfilt : shortint;
begin
   Player1 := TUOS_Player.Create(True);     //// Create the player

 Out1Index := Player1.AddIntoDevOut ;    //// add a Output into device with default parameters 
 // Out1Index := Player1.AddIntoDevOut(-1, -1, -1, -1,0);   //// add a Output into device with custom parameters
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  
 In1Index := Player1.AddFromFile(Edit4.Text);    //// add input from audio file with default parameters 
  // In1Index := Player1.AddFromFile(Edit4.Text, -1, 0);  //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output

 EQIndex1 := Player1.AddFilterIn(In1Index, 1, 1000, 1, 1, True);
  ////////// In1Index : InputIndex of a existing Input
  ////////// LowFrequency : Lowest frequency of filter
  ////////// HighFrequency : Highest frequency of filter
  ////////// Gain : gain to apply to filter ( 1 = no gain )
  ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  //  result : -1 nothing created, otherwise index of DSPIn in array   
  
 EQIndex2 := Player1.AddFilterIn(In1Index, 1000, 8000, 1, 1, True);
 EQIndex3 := Player1.AddFilterIn(In1Index, 8000,22000, 1, 1, True);

 if radiobutton1.Checked = true then typfilt := 2;
 if radiobutton2.Checked = true then typfilt := 3;
 if radiobutton3.Checked = true then typfilt := 4;
 if radiobutton4.Checked = true then typfilt := 5;
 
 FTIndex1 := Player1.AddFilterIn(In1Index, strtoint(edit6.text),strtoint(edit5.text), 1, typfilt, True);

 Player1.SetFilterIn(In1Index, FTIndex1, -1, -1, -1, -1, True, checkbox2.Checked);
////////// InputIndex : InputIndex of a existing Input
////////// DSPInIndex : DSPInIndex of existing DSPIn
////////// LowFrequency : Lowest frequency of filter ( default = -1 : current LowFrequency )
////////// HighFrequency : Highest frequency of filter ( default = -1 : current HighFrequency )
////////// Gain   : Gain to apply ( -1 = current gain)  ( 0 = silence, 1 = no gain, < 1 = less gain, > 1 = more gain)
////////// TypeFilter: Type of filter : ( default = -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
/////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
////////// Enable :  Filter enabled 
 
 
 if TrackBar1.Position = 100 then EqGain := 1 else
 if TrackBar1.Position > 100 then EqGain :=  1 + ((100 - TrackBar1.Position) div 25)
 else EqGain := TrackBar1.Position div 100 ;
  Player1.SetFilterIn(In1Index, EQIndex1, -1, -1, EqGain, -1, true, checkbox1.Checked);
  
  if TrackBar2.Position = 100 then EqGain := 1 else
 if TrackBar2.Position > 100 then EqGain :=  1 + ((100 - TrackBar2.Position) div 25)
 else EqGain := TrackBar2.Position div 100 ;
  Player1.SetFilterIn(In1Index, EQIndex2, -1, -1, EqGain, -1, true, checkbox1.Checked);
  
  if TrackBar3.Position = 100 then EqGain := 1 else
 if TrackBar3.Position > 100 then EqGain :=  1 + ((100 - TrackBar3.Position) div 25)
 else EqGain := TrackBar3.Position div 100 ;
  Player1.SetFilterIn(In1Index, EQIndex3, -1, -1, EqGain, -1, true, checkbox1.Checked);

   Player1.EndProc := @ClosePlayer1;  /////// procedure to execute when stream is terminated

   Player1.Play;  /////// everything is ready, here we are, lets play it...
  
   trackbar2.Enabled := True;
   Button3.Enabled := false;
   Button4.Enabled := false;
   Button6.Enabled := True;
   Button5.Enabled := true;
   CheckBox1.Enabled := True;
   end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Player1.Stop;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if opendialog1.Execute then
    Edit4.Text := opendialog1.FileName;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if assigned(Player1) and (button3.Enabled = false) then 
  if assigned(Player1) and (button3.Enabled = false) then begin
   Player1.SetFilterIn(In1Index, EQIndex1, -1, -1, -1, -1, true, checkbox1.Checked); 
   Player1.SetFilterIn(In1Index, EQIndex2, -1, -1, -1, -1, true, checkbox1.Checked); 
   Player1.SetFilterIn(In1Index, EQIndex3, -1, -1, -1, -1, true, checkbox1.Checked); 
  end;
end;

procedure UOS_logo();
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

procedure TForm1.FormClose(Sender: TObject);
begin
  if assigned(Player1) and (button3.Enabled = false) then
    begin
    button6.Click;
    sleep(500) ;
    end;
   if button1.Enabled = false then Init.UnloadLib();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Height := 150;
end;

end.
