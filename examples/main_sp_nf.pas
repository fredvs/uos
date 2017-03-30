
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
    CheckBox3: TCheckBox;
    chkstereo2mono: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
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
    procedure Button8Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure chkstereo2monoChange(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
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

function DSPStereo2Mono(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;

procedure uos_logo();

var
  Form1: TForm1;
  BufferBMP: TBitmap;
  plugsoundtouch : boolean = false;
  plugbs2b : boolean = false;

  PlayerIndex1: Tuos_Player;

  OutputIndex1, InputIndex1, DSPIndex1, DSPIndex2, DSPVolume, PluginIndex1, PluginIndex2: integer;


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
  label9.Caption := 'Pitch: ' + floattostrf(rate, ffFixed, 15, 1);

  if radiogroup1.Enabled = False then   /// player1 was created
  begin
   PlayerIndex1.SetPluginSoundTouch(PluginIndex2, tempo, rate, checkbox2.Checked);
  end;
end;

end;

procedure TForm1.ResetPlugClick(Sender: TObject);
begin
  TrackBar4.Position := 50;
  TrackBar5.Position := 50;
  if radiogroup1.Enabled = False then   /// player1 was created
  begin
    PlayerIndex1.SetPluginSoundTouch(PluginIndex2, 1, 1, checkbox2.Checked);
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
  Form1.ShapeLeft.top := 342;
  Form1.ShapeRight.top := 342;
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
  Edit5.Text := ordir + 'lib\Windows\64bit\plugin\LibSoundTouch-64.dll';
{$else}
  Edit1.Text := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
  Edit2.Text := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
  Edit3.Text := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
  Edit7.text := ordir + 'lib\Windows\32bit\LibMp4ff-32.dll';
  Edit8.text := ordir + 'lib\Windows\32bit\LibFaad2-32.dll';
  Edit5.Text := ordir + 'lib\Windows\32bit\plugin\LibSoundTouch-32.dll'; 
  // Problems with Windows10 when closing application
  //Edit6.Text := ordir + 'lib\Windows\32bit\plugin\Libbs2b-32.dll';
   {$endif}
  Edit4.Text := ordir + 'sound\test.mp3';
 {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    Edit1.Text := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
     Edit2.Text := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    Edit3.Text := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    Edit5.Text := '' ;
    Edit6.text := ordir + 'lib/FreeBSD/64bit/plugin/libbs2b-64.so';
  
    {$else}
   Edit1.Text := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
     Edit2.Text := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    Edit3.Text := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
     Edit5.Text := '' ;
{$endif}
     Edit4.Text := ordir + 'sound/test.mp3';
 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit2.Text := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
  Edit3.Text := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
  Edit5.Text := opath + '/lib/Mac/32bit/plugin/LibSoundTouch-32.dylib';
  Edit4.Text := opath + 'sound/test.mp3';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  Edit7.text := ordir + 'lib/Linux/64bit/LibMp4ff-64.so';
  Edit8.text := ordir + 'lib/Linux/64bit/LibFaad2-64.so';
  Edit5.Text := ordir + 'lib/Linux/64bit/plugin/LibSoundTouch-64.so';
  Edit6.Text := ordir + 'lib/Linux/64bit/plugin/libbs2b-64.so';
{$else}
  Edit1.Text := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit2.Text := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
  Edit3.Text := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
  Edit7.text := ordir + 'lib/Linux/32bit/LibMp4ff-32.so';
  Edit8.text := ordir + 'lib/Linux/32bit/LibFaad2-32.so';
  Edit5.Text := ordir + 'lib/Linux/32bit/plugin/LibSoundTouch-32.so';
  Edit6.Text := ordir + 'lib/Linux/32bit/plugin/libbs2b-32.so';
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
    PlayerIndex1.InputSetDSPVolume(InputIndex1, DSPVolume, TrackBar1.position / 100,
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
  PlayerIndex1.InputSeek( InputIndex1, TrackBar2.position);
  TrackBar2.Tag := 0;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
loadok : boolean = false;
begin
  // Load the libraries
 //function  uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName,
  // Mp4ffFileName, FaadFileName, opusfilefilename: PChar) : LongInt;

  if uos_LoadLib(Pchar(Edit1.text), Pchar(Edit2.text),
     Pchar(Edit3.text), Pchar(Edit7.text), Pchar(Edit8.text), nil) = 0 then
  // You may load one or more libraries . When you want... :

 begin
    form1.hide;
    loadok := true;
    button1.Enabled := False;
    edit1.ReadOnly := True;
    edit2.ReadOnly := True;
    edit3.ReadOnly := True;
    edit5.ReadOnly := True;
          button1.Caption :=
        'PortAudio, SndFile and Mpg123 libraries are loaded...'  ;
             end else  MessageDlg('Error while loading libraries...', mtWarning, [mbYes], 0);

if loadok = true then
        begin
           if ((trim(Pchar(edit5.text)) <> '') and fileexists(edit5.text))
       and (uos_LoadPlugin('soundtouch', Pchar(Edit5.text)) = 0)  then
       begin
      plugsoundtouch := true;
        button1.Caption :=
        'PortAudio, SndFile, Mpg123 and Plugin are loaded...';
        end
         else
         begin
       TrackBar4.enabled := false;
       TrackBar5.enabled := false;
       CheckBox2.enabled := false;
       Button7.enabled := false;
       label9.enabled := false;
       label7.enabled := false;
           end;

      if ((trim(Pchar(edit6.text)) <> '') and fileexists(edit6.text))
      and (uos_LoadPlugin('bs2b', Pchar(edit6.text)) = 0)
      then plugbs2b := true else CheckBox3.enabled := false;

    form1.Height := 556;
    form1.Position := poScreenCenter;
    form1.Caption := 'Simple Player.    uos version ' + inttostr(uos_getversion());
    form1.Show;
  end;


end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  PlayerIndex1.Pause();
  Button4.Enabled := True;
  Button5.Enabled := False;
  Form1.ShapeLeft.Height := 0;
  Form1.ShapeRight.Height := 0;
  Form1.ShapeLeft.top := 342;
  Form1.ShapeRight.top := 342;
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

   // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
    // If PlayerIndex exists already, it will be overwritten...

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

    //// Create the player.
    //// PlayerIndex : from 0 to what your computer can do !
    //// If PlayerIndex exists already, it will be overwriten...

     InputIndex1 := PlayerIndex1.AddFromFile( pchar(Edit4.text), -1, samformat, -1);
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

    OutputIndex1 := PlayerIndex1.AddIntoDevOut(-1, -1, PlayerIndex1.StreamIn[InputIndex1].Data.SampleRate, -1, samformat, -1);
    //// add a Output into device with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)   /// here default samplerate of input
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Output Index in array

  //  PlayerIndex1.StreamIn[In1Index].Data.levelEnable:=2 ;
    PlayerIndex1.InputSetLevelEnable(InputIndex1, 2) ;
     ///// set calculation of level/volume (usefull for showvolume procedure)
                       ///////// set level calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

  //  PlayerIndex1.StreamIn[In1Index].Data.PositionEnable:= 1 ;
    PlayerIndex1.InputSetPositionEnable(InputIndex1, 1) ;
     ///// set calculation of position (usefull for positions procedure)
                       ///////// set position calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul position.

   PlayerIndex1.StreamIn[InputIndex1].LoopProc := @LoopProcPlayer1;
     ///// Assign the procedure of object to execute inside the loop
    //////////// PlayerIndex : Index of a existing Player
    //////////// InputIndex1 : Index of a existing Input
    //////////// LoopProcPlayer1 : procedure of object to execute inside the loop

    DSPVolume := PlayerIndex1.InputAddDSPVolume(InputIndex1, 1, 1);
    ///// DSP Volume changer
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1 : Index of a existing input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume

    PlayerIndex1.InputSetDSPVolume(InputIndex1, DSPVolume, TrackBar1.position / 100,
      TrackBar3.position / 100, True);    /// Set volume
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// DSPVolume : Index of a existing dsp
    ////////// InputIndex1 : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled

   DSPIndex1 := PlayerIndex1.InputAddDSP(InputIndex1, @DSPReverseBefore,
     @DSPReverseAfter, nil, nil);
      ///// add a custom DSP procedure for input
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1: InputIndex of existing input
    ////////// BeforeFunc : function to do before the buffer is filled
    ////////// AfterFunc : function to do after the buffer is filled
    ////////// EndedFunc : function to do at end of thread
    ////////// LoopProc : external procedure to do after the buffer is filled

   //// set the parameters of custom DSP
   PlayerIndex1.InputSetDSP(InputIndex1, DSPIndex1, checkbox1.Checked);

   // This is a other custom DSP...stereo to mono  to show how to do a DSP ;-)
    DSPIndex2 := PlayerIndex1.InputAddDSP(InputIndex1, nil, @DSPStereo2Mono, nil, nil);
    PlayerIndex1.InputSetDSP(InputIndex1, DSPIndex2, chkstereo2mono.checked);

   ///// add bs2b plugin with samplerate_of_input1 / default channels (2 = stereo)
  if plugbs2b = true then
  begin
   PlugInIndex1 := PlayerIndex1.AddPlugin('bs2b',PlayerIndex1.StreamIn[InputIndex1].Data.SampleRate , -1);
   PlayerIndex1.SetPluginbs2b(PluginIndex1, -1 , -1, -1, checkbox3.checked);
  end;

  /// add SoundTouch plugin with samplerate of input1 / default channels (2 = stereo)
  /// SoundTouch plugin should be the last added.
    if plugsoundtouch = true then
  begin
    PlugInIndex2 := PlayerIndex1.AddPlugin('soundtouch',
    PlayerIndex1.StreamIn[InputIndex1].Data.SampleRate , -1);
    ChangePlugSet(self); //// custom procedure to Change plugin settings
   end;

   trackbar2.Max := PlayerIndex1.InputLength(InputIndex1);
    ////// Length of Input in samples

   temptime := PlayerIndex1.InputLengthTime(InputIndex1);
    ////// Length of input in time

    DecodeTime(temptime, ho, mi, se, ms);

    llength.caption := format('%d:%d:%d.%d', [ho, mi, se, ms]);

    /////// procedure to execute when stream is terminated
     PlayerIndex1.EndProc := @ClosePlayer1;
    ///// Assign the procedure of object to execute at end
    //////////// PlayerIndex : Index of a existing Player
    //////////// ClosePlayer1 : procedure of object to execute inside the general loop

    TrackBar2.position := 0;
    trackbar1.Enabled := True;
    CheckBox1.Enabled := True;

    button3.Enabled := False;
    button6.Enabled := True;
    button5.Enabled := True;
    button4.Enabled := False;

    PlayerIndex1.Play();
     end;
  end;

end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  PlayerIndex1.Stop();
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  PlayerIndex1.PlayNoFree();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if opendialog1.Execute then
    Edit4.Text := opendialog1.FileName;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if (button3.Enabled = False) then
    PlayerIndex1.InputSetDSP(InputIndex1, DSPIndex1, checkbox1.Checked);
end;

procedure TForm1.CheckBox3Change(Sender: TObject);
begin
  if radiogroup1.Enabled = False then   /// player1 was created
  begin
   PlayerIndex1.SetPluginbs2b(PluginIndex1, -1, -1, -1, checkbox3.checked);
    end;
end;

procedure TForm1.chkstereo2monoChange(Sender: TObject);
begin
   if radiogroup1.Enabled = False then
    PlayerIndex1.InputSetDSP(InputIndex1, DSPIndex2, chkstereo2mono.checked);
 end;

procedure TForm1.Edit5Change(Sender: TObject);
begin

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
    form1.TrackBar2.Position := PlayerIndex1.InputPosition(InputIndex1);
    temptime :=PlayerIndex1.InputPositionTime(InputIndex1);
    ////// Length of input in time
    DecodeTime(temptime, ho, mi, se, ms);
    form1.lposition.Caption := format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
  end;
 end;

procedure Tform1.ShowLevel;
begin
  ShapeLeft.Height := round(PlayerIndex1.InputGetLevelLeft(InputIndex1) * 92);
  ShapeRight.Height := round(PlayerIndex1.InputGetLevelRight(InputIndex1) * 92);
  ShapeLeft.top := 430- ShapeLeft.Height;
  ShapeRight.top := 430 - ShapeRight.Height;
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
    PlayerIndex1.InputSeek(InputIndex1, Data.position - (Data.OutFrames div (Data.Ratio)));
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

function DSPStereo2Mono(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;
var
  x: integer = 0;
  ps: PDArShort;     //////// if input is Int16 format
  pl: PDArLong;      //////// if input is Int32 format
  pf: PDArFloat;     //////// if input is Float32 format

  samplef : cFloat;
  samplei : integer;
begin
 if (Data.channels = 2) then
begin

 case Data.SampleFormat of
  2:
  begin
    ps := @Data.Buffer;
   while x < Data.OutFrames  do
        begin
      samplei := round((ps^[x] + ps^[x+1])/2);        ps^[x] := samplei ;
      ps^[x+1] := samplei ;
      x := x + 2;
      end;
   end;

  1:
  begin
    pl := @Data.Buffer;
   while x < Data.OutFrames  do
        begin
      samplei := round((pl^[x] + pl^[x+1])/2);
      pl^[x] := samplei ;
      pl^[x+1] := samplei ;
      x := x + 2;
      end;
   end;

  0:
  begin
    pf := @Data.Buffer;
   while x < Data.OutFrames  do
        begin
      samplef := (pf^[x] + pf^[x+1])/2;
      pf^[x] := samplef ;
      pf^[x+1] := samplef ;
      x := x + 2;
      end;
   end;


end;
Result := Data.Buffer;
end
else Result := Data.Buffer;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Height := 326;
  ShapeLeft.Height := 0;
  ShapeRight.Height := 0;
  trackbar1.Position:=100;
  trackbar3.Position:=100;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if (button3.Enabled = False) then
  begin
    button6.Click;
    sleep(500);
  end;
  if button1.Enabled = False then
  begin
   PlayerIndex1.free;
    uos_free;
  end;
end;


end.
