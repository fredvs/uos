
/////////////////// Demo how to use United Openlib of Sound ////////////////////

unit main_sp_nf;

{$mode objfpc}{$H+}

interface

uses
  uos, Forms, Dialogs, SysUtils, fileutil, Graphics, ctypes,
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
    Button7: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    llength: TLabel;
    lposition: TLabel;
    Label8: TLabel;
    OpenDialog1: TOpenDialog;
    PaintBox1: TPaintBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioGroup1: TRadioGroup;
    Shape1: TShape;
    ShapeRight: TShape;
    ShapeLeft: TShape;
    TrackBar2: TTrackBar;
    TrackBar1: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
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
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure TrackBar2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ClosePlayer1;
    procedure LoopProcPlayer1;
    procedure ShowPosition;
    procedure ShowLevel;
    procedure ChangePlugSet(Sender: TObject);
    procedure ResetPlugClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

////// This is the "standart" DSP procedure look.
function DSPReverseBefore(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;
function DSPReverseAfter(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;

procedure uos_logo();

var
  Form1: TForm1;
  BufferBMP: TBitmap;
   PlayerIndex1: Tuos_Player;
 // ordir, opath: string;
  Out1Index, In1Index, DSP1Index, DSP2Index, Plugin1Index: cardinal;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ChangePlugSet(Sender: TObject);
var
  tempo, rate: cfloat;
begin
  if (trim(Pchar(edit5.text)) <> '') and fileexists(edit5.text) then
    begin
  if (2 * (TrackBar4.Position / 100)) < 0.3 then
    tempo := 0.3
  else
    tempo := (2 * (TrackBar4.Position / 100));
  if (2 * (TrackBar5.Position / 100)) < 0.3 then
    rate := 0.3
  else
    rate := (2 * (TrackBar5.Position / 100));

  label7.Caption := 'Tempo: ' + floattostrf(tempo, ffFixed, 15, 1);
  label9.Caption := 'Rate: ' + floattostrf(rate, ffFixed, 15, 1);

  if radiogroup1.Enabled = False then   /// player1 was created
  begin
    PlayerIndex1.SetPluginSoundTouch(Plugin1Index, tempo, rate, checkbox2.Checked);
  end;

    end;
end;

procedure TForm1.ResetPlugClick(Sender: TObject);
begin
  TrackBar4.Position := 50;
  TrackBar5.Position := 50;
  if radiogroup1.Enabled = False then   /// player1 was created
  begin
   PlayerIndex1.SetPluginSoundTouch(Plugin1Index, 1, 1, checkbox2.Checked);
  end;

end;

procedure TForm1.ClosePlayer1;
begin
  Form1.button3.Enabled := True;
  Form1.button4.Enabled := False;
  Form1.button5.Enabled := False;
  Form1.button6.Enabled := False;
  Form1.trackbar2.Enabled := False;
  Form1.radiogroup1.Enabled := True;
  Form1.TrackBar2.Position := 0;
  Form1.ShapeLeft.Height := 0;
  Form1.ShapeRight.Height := 0;
  Form1.ShapeLeft.top := 280;
  Form1.ShapeRight.top := 280;
  form1.lposition.Caption := '00:00:00.000';
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
  Edit5.Text := ordir + 'lib\Windows\64bit\LibSoundTouch-64.dll';
{$else}
  Edit1.Text := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
  Edit2.Text := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
  Edit3.Text := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
  Edit5.Text := ordir + 'lib\Windows\32bit\LibSoundTouch-32.dll';
   {$endif}
  Edit4.Text := ordir + 'sound\test.mp3';
 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit2.Text := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
  Edit3.Text := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
  Edit5.Text := opath + '/lib/Mac/32bit/LibSoundTouch-32.dylib';
  Edit4.Text := opath + 'sound/test.mp3';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  Edit5.Text := ordir + 'lib/Linux/64bit/LibSoundTouch-64.so';
{$else}
  Edit1.Text := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit2.Text := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
  Edit3.Text := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
  Edit5.Text := ordir + 'lib/Linux/32bit/LibSoundTouch-32.so';
{$endif}
  Edit4.Text := ordir + 'sound/test.mp3';
            {$ENDIF}

{$IFDEF freebsd}
    {$if defined(cpu64)}
    Edit1.Text := ordir + 'lib/freeBSD/64bit/libportaudio-64.so';
     Edit2.Text := ordir + 'lib/freeBSD/64bit/libsndfile-64.so';
    Edit3.Text := ordir + 'lib/freeBSD/64bit/libmpg123-64.so';
     Edit5.Text := '' ;
    {$else}
   Edit1.Text := ordir + 'lib/freeBSD/32bit/libportaudio-32.so';
     Edit2.Text := ordir + 'lib/freeBSD/32bit/libsndfile-32.so';
    Edit3.Text := ordir + 'lib/freeBSD/32bit/libmpg123-32.so';
    Edit5.Text := '' ;
{$endif}
  Edit4.Text := ordir + 'sound/test.mp3';
            {$ENDIF}


  opendialog1.Initialdir := application.Location + 'sound';

end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  if (button3.Enabled = False) then
    PlayerIndex1.SetDSPVolumeIn(In1Index, DSP2Index, TrackBar1.position / 100,
      TrackBar3.position / 100, True);
end;

procedure TForm1.TrackBar2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  TrackBar2.Tag := 1;
end;

procedure TForm1.TrackBar2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  PlayerIndex1.Seek(In1Index, TrackBar2.position);
  TrackBar2.Tag := 0;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // Load the libraries
  // function uos_LoadLib(PortAudioFileName: Pchar; SndFileFileName: Pchar; Mpg123FileName: Pchar;
  //SoundTouchFileName: Pchar ; bs2bFileName: Pchar) : integer;
  // You may load one or more libraries . When you want... :

if uos_LoadLib(Pchar(edit1.Text), pchar(edit2.Text), pchar(edit3.Text), pchar(edit5.Text),nil) = 0 then
  begin
    form1.hide;
    button1.Enabled := False;
    edit1.ReadOnly := True;
    edit2.ReadOnly := True;
    edit3.ReadOnly := True;
    edit5.ReadOnly := True;
    form1.Height := 418;
    form1.Position := poScreenCenter;
          if (trim(Pchar(edit5.text)) <> '') and fileexists(edit5.text) then
       button1.Caption :=
        'PortAudio, SndFile, Mpg123 and Plugin SoundTouch libraries are loaded...'
        else
          begin
      TrackBar4.enabled := false;
       TrackBar5.enabled := false;
       CheckBox2.enabled := false;
       Button7.enabled := false;
       label9.enabled := false;
       label7.enabled := false;
             button1.Caption :=
        'PortAudio, SndFile and Mpg123 libraries are loaded...'  ;
              end;

    form1.Caption := 'Simple Player.    uos version ' + inttostr(uos_getversion());
    form1.Show;
  end
  else
      MessageDlg('Error while loading libraries...', mtWarning, [mbYes], 0);

end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  PlayerIndex1.Pause();
  Button4.Enabled := True;
  Button5.Enabled := False;
  Form1.ShapeLeft.Height := 0;
  Form1.ShapeRight.Height := 0;
  Form1.ShapeLeft.top := 280;
  Form1.ShapeRight.top := 280;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Button4.Enabled := False;
  Button5.Enabled := True;
  Button6.Enabled := True;
  application.ProcessMessages;
  PlayerIndex1.RePlay();
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  samformat: shortint;
  temptime: ttime;
  ho, mi, se, ms: word;
begin

  if fileexists(Edit4.Text) then
  begin


    if radiobutton1.Checked = True then
      samformat := 0;
    if radiobutton2.Checked = True then
      samformat := 1;
    if radiobutton3.Checked = True then
      samformat := 2;

    radiogroup1.Enabled := False;

   {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
   PlayerIndex1 := Tuos_Player.Create(true);
     {$else}
    PlayerIndex1 := Tuos_Player.Create(true,self);
    {$endif}

    // In1Index := uos_AddFromFile(PlayerIndex1, Edit4.Text);
    //// add input from audio file with default parameters
    In1Index := PlayerIndex1.AddFromFile(pchar(Edit4.Text), -1, samformat, -1);
    //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    //////////// PlayerIndex : Index of a existing Player
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
    //////////// FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Input Index in array

    // Out1Index := uos_AddIntoDevOut(PlayerIndex1) ;
    //// add a Output into device with default parameters
    Out1Index :=  PlayerIndex1.AddIntoDevOut( -1, -1, PlayerIndex1.StreamIn[In1Index].Data.SampleRate, -1, samformat, -1);
    //// add a Output into device with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)   /// here default samplerate of input
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Output Index in array

    PlayerIndex1.StreamIn[In1Index].Data.LevelEnable:= 2 ;
    ///// set calculation of level/volume (usefull for showvolume procedure)
                       ///////// set level calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

    PlayerIndex1.StreamIn[In1Index].Data.PositionEnable:= 1 ;
     ///// set calculation of position (usefull for positions procedure)
                       ///////// set position calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul position.

    PlayerIndex1.StreamIn[In1Index].LoopProc := @LoopProcPlayer1;
   ///// Assign the procedure of object to execute inside the loop for a Input
    //////////// PlayerIndex : Index of a existing Player
    //////////// InIndex : Index of a existing Input
    //////////// LoopProcPlayer1 : procedure of object to execute inside the loop

    DSP2Index := PlayerIndex1.AddDSPVolumeIn(In1Index, 1, 1);
    ///// DSP Volume changer
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index : InputIndex of a existing input
    ////////// VolLeft : Left volume  ( from 0 to 1 => gain > 1 )
    ////////// VolRight : Right volume

    PlayerIndex1.SetDSPVolumeIn(In1Index,DSP2Index, TrackBar1.position / 100,
      TrackBar3.position / 100, True); /// Set volume
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled

      DSP1Index := PlayerIndex1.AddDSPIn(In1Index, @DSPReverseBefore,
      @DSPReverseAfter, nil);
   ///// add a custom DSP procedure for input
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index: InputIndex of existing input
    ////////// BeforeProc : procedure to do before the buffer is filled
    ////////// AfterProc : procedure to do after the buffer is filled
    ////////// LoopProc : external procedure to do after the buffer is filled
    //////// result = DSPIndex of the custom  DSP

    PlayerIndex1.SetDSPIn(In1Index, DSP1Index, checkbox1.Checked);
    //// set the parameters of custom DSP;

   if (trim(Pchar(edit5.text)) <> '') and fileexists(edit5.text) then
    begin
    Plugin1Index := PlayerIndex1.AddPlugin('soundtouch', -1, -1);
    ///// add SoundTouch plugin with default samplerate(44100) / channels(2 = stereo)

    ChangePlugSet(self); //// Change plugin settings
     end;

    trackbar2.Max := PlayerIndex1.InputLength( In1Index);
    ////// Length of Input in samples

    temptime := PlayerIndex1.InputLengthTime(In1Index);
    ////// Length of input in time

    DecodeTime(temptime, ho, mi, se, ms);

    llength.Caption := format('%d:%d:%d.%d', [ho, mi, se, ms]);

    /////// procedure to execute when stream is terminated
    PlayerIndex1.EndProc := @ClosePlayer1;
    ///// Assign the procedure of object to execute at end
    //////////// PlayerIndex : Index of a existing Player
    //////////// ClosePlayer1 : procedure of object to execute inside the loop

    TrackBar2.position := 0;
    trackbar2.Enabled := True;
    Button3.Enabled := False;
    Button4.Enabled := False;
    Button6.Enabled := True;
    Button5.Enabled := True;
    CheckBox1.Enabled := True;

    application.ProcessMessages;

     PlayerIndex1.Play();  /////// everything is ready, here we are, lets play it...

  end
  else
    MessageDlg(edit4.Text + ' do not exist...', mtWarning, [mbYes], 0);

end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  PlayerIndex1.Stop();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if opendialog1.Execute then
    Edit4.Text := opendialog1.FileName;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if (button3.Enabled = False) then
  PlayerIndex1.SetDSPIn(In1Index, DSP1Index, checkbox1.Checked);
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

procedure TForm1.ShowPosition;
var
  temptime: ttime;
  ho, mi, se, ms: word;
begin
  if form1.TrackBar2.Tag = 0 then
  begin
    form1.TrackBar2.Position := PlayerIndex1.InputPosition(In1Index);
    temptime := PlayerIndex1.InputPositionTime(In1Index);
    ////// Length of input in time
    DecodeTime(temptime, ho, mi, se, ms);
    form1.lposition.Caption := format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
  end;
 end;

procedure Tform1.ShowLevel;
begin
  ShapeLeft.Height := round(PlayerIndex1.InputGetLevelLeft(In1Index) * 146);
  ShapeRight.Height := round(PlayerIndex1.InputGetLevelRight( In1Index) * 146);
  ShapeLeft.top := 354 - ShapeLeft.Height;
  ShapeRight.top := 354 - ShapeRight.Height;
end;

procedure Tform1.LoopProcPlayer1;
begin
 ShowPosition;
 ShowLevel ;
end;
//{
function DSPReverseBefore(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;
begin
  if Data.position > Data.OutFrames div Data.ratio then
 PlayerIndex1.Seek(In1Index, Data.position - (Data.OutFrames div (Data.Ratio)));
end;

function DSPReverseAfter(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;
var
  x: integer;
  arfl: TDArFloat;
begin
  SetLength(arfl, length(Data.Buffer));

  for x := 0 to ((Data.OutFrames * Data.Ratio) - 1) do
    if odd(x) then
      arfl[x] := Data.Buffer[((Data.OutFrames * Data.Ratio) - 1) - x - 1]
    else
      arfl[x] := Data.Buffer[((Data.OutFrames * Data.Ratio) - 1) - x + 1];
  Result := arfl;
end;
//}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Height := 193;
  ShapeLeft.Height := 0;
  ShapeRight.Height := 0;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if (button3.Enabled = False) then
  begin
    button6.Click;
    sleep(500);
  end;
  if button1.Enabled = False then
    uos_UnloadLib();
end;

end.
