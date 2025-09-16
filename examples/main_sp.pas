
{ Demo how to use United Openlib of Sound (uos) }

unit main_sp;

{$mode objfpc}{$H+}

interface

uses
  uos_flat,
  Forms,
  Dialogs,
  SysUtils,
  fileutil,
  Graphics,
  ctypes,
  StdCtrls,
  ComCtrls,
  ExtCtrls,
  Classes,
  Controls;

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
    Chknoise: TCheckBox;
    chkstereo2mono: TCheckBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
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
    Label14: TLabel;
    Label15: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    llength: TLabel;
    lposition: TLabel;
    OpenDialog1: TOpenDialog;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioGroup1: TRadioGroup;
    Shape1: TShape;
    ShapeLeft: TShape;
    ShapeRight: TShape;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
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
    procedure CheckBox3Change(Sender: TObject);
    procedure ChknoiseChange(Sender: TObject);
    procedure chkstereo2monoChange(Sender: TObject);
    procedure Edit10Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure TrackBar2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
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

    // This is the "standart" DSP procedure look.
function DSPReverseBefore(var Data: TuosF_Data; var fft: TuosF_FFT): TDArFloat;
function DSPReverseAfter(var Data: TuosF_Data; var fft: TuosF_FFT): TDArFloat;

function DSPStereo2Mono(var Data: TuosF_Data; var fft: TuosF_FFT): TDArFloat;

procedure uos_logo();

var
  Form1: TForm1;
  BufferBMP: TBitmap;
  PlayerIndex1: integer;
  OutputIndex1, InputIndex1, DSPIndex1, DSPIndex2, PluginIndex1, PluginIndex2: integer;
  plugsoundtouch: Boolean = False;
  plugbs2b: Boolean = False;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ChangePlugSet(Sender: TObject);
var
  tempo, rate: cfloat;
begin
  if (trim(PChar(edit5.Text)) <> '') and fileexists(edit5.Text) then
  begin
    if (2 * (TrackBar4.Position / 100)) < 0.3 then
      tempo := 0.3
    else
      tempo := (2 * (TrackBar4.Position / 100));
    if (2 * (TrackBar5.Position / 100)) < 0.3 then
      rate  := 0.3
    else
      rate  := (2 * (TrackBar5.Position / 100));

    label7.Caption := 'Tempo: ' + floattostrf(tempo, ffFixed, 15, 1);
    label9.Caption := 'Pitch: ' + floattostrf(rate, ffFixed, 15, 1);

    if radiogroup1.Enabled = False then   // player1 was created
      uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, tempo, rate, checkbox2.Checked);
  end;

end;

procedure TForm1.ResetPlugClick(Sender: TObject);
begin
  TrackBar4.Position := 50;
  TrackBar5.Position := 50;
  if radiogroup1.Enabled = False then   // player1 was created
    uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, 1, 1, checkbox2.Checked);

end;

procedure TForm1.ClosePlayer1;
begin
  button3.Enabled     := True;
  button4.Enabled     := False;
  button5.Enabled     := False;
  button6.Enabled     := False;
  trackbar2.Enabled   := False;
  radiogroup1.Enabled := True;
  TrackBar2.Position  := 0;
  ShapeLeft.Height    := 0;
  ShapeRight.Height   := 0;
  ShapeLeft.top       := 118 - ShapeLeft.Height;
  ShapeRight.top      := 118 - ShapeRight.Height;
  lposition.Caption   := '00:00:00.000';
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
  Edit11.text := ordir + 'lib\Windows\64bit\libxmp-64.dll';
  Edit5.Text := ordir + 'lib\Windows\64bit\plugin\LibSoundTouch-64.dll';
  {$else}
  Edit1.Text := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
  Edit2.Text := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
  Edit3.Text := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
  Edit11.text := ordir + 'lib\Windows\32bit\libxmp-32.dll';
  Edit7.text := ordir + 'lib\Windows\32bit\LibMp4ff-32.dll';
  Edit10.text := ordir + 'lib\Windows\32bit\LibOpusFile-32.dll';
  Edit8.text := ordir + 'lib\Windows\32bit\LibFaad2-32.dll';
  Edit5.Text := ordir + 'lib\Windows\32bit\plugin\LibSoundTouch-32.dll'; 
  // Error on Windows10 with libbs2b --> when closing application.
  //Edit6.Text := ordir + 'lib\Windows\32bit\plugin\Libbs2b-32.dll';
  {$endif}
  Edit4.Text := ordir + 'sound\test.ogg';
 {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    Edit1.Text := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    Edit2.Text := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    Edit3.Text := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    Edit5.text := ordir + 'lib/FreeBSD/64bit/plugin/libsoundtouch-64.so';
    Edit6.text := ordir + 'lib/FreeBSD/64bit/plugin/libbs2b-64.so';
    Edit10.text := ordir + 'lib/FreeBSD/64bit/libopusfile-64.so';
  
    {$else}
    Edit1.Text := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    Edit2.Text := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    Edit3.Text := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
    Edit5.Text := '' ;
{$endif}
    Edit4.Text := ordir + 'sound/test.ogg';
{$ENDIF}

  {$IFDEF Darwin}
   {$IFDEF CPU32}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit2.Text := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
  Edit3.Text := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
  Edit5.Text := opath + '/lib/Mac/32bit/plugin/LibSoundTouch-32.dylib';
  Edit4.Text := ordir + '/sound/test.ogg';
   {$ENDIF}
    {$IFDEF CPU64}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
  Edit2.Text := opath + '/lib/Mac/64bit/LibSndFile-64.dylib';
  Edit3.Text := opath + '/lib/Mac/64bit/LibMpg123-64.dylib';
  Edit11.Text := opath + '/lib/Mac/64bit/libxmp-64.dylib';
  Edit5.Text := opath + '/lib/Mac/64bit/plugin/libSoundTouchDLL-64.dylib';
  Edit4.Text := ordir + '/sound/test.ogg';
   {$ENDIF}
  {$ENDIF}

 {$if defined(CPUAMD64) and defined(openbsd) }
  Edit1.Text := ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/OpenBSD/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/OpenBSD/64bit/LibMpg123-64.so';
  Edit5.Text := ordir + 'lib/OpenBSD/64bit/LibSoundTouch-64.so';
  Edit4.Text := ordir + '/sound/test.ogg'; 
 {$ENDIF}

  {$if defined(CPUAMD64) and defined(netbsd) }
  Edit1.Text := ordir + 'lib/NetBSD/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/NetBSD/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/NetBSD/64bit/LibMpg123-64.so';
  Edit5.Text := ordir + 'lib/NetBSD/64bit/LibSoundTouch-64.so';
  Edit4.Text := ordir + '/sound/test.ogg'; 
 {$ENDIF}

  {$if defined(CPUAMD64) and defined(dragonflybsd) }
  Edit1.Text := ordir + 'lib/DragonFlyBSD/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/DragonFlyBSD/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/DragonFlyBSD/64bit/LibMpg123-64.so';
  Edit5.Text := ordir + 'lib/DragonFlyBSD/64bit/LibSoundTouch-64.so';
  Edit4.Text := ordir + '/sound/test.ogg'; 
 {$ENDIF}

   {$if defined(CPUAMD64) and defined(linux) }
  Edit1.Text := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  Edit7.text := ordir + 'lib/Linux/64bit/LibMp4ff-64.so';
  Edit8.text := ordir + 'lib/Linux/64bit/LibFaad2-64.so';
  Edit10.text := ordir + 'lib/Linux/64bit/LibOpusFile-64.so';
  Edit11.text := ordir + 'lib/Linux/64bit/libxmp-64.so';
  Edit5.Text := ordir + 'lib/Linux/64bit/plugin/LibSoundTouch-64.so';
  Edit6.Text := ordir + 'lib/Linux/64bit/plugin/libbs2b-64.so';
   Edit4.Text := ordir + 'sound/test.ogg';
   {$ENDIF}

 {$if defined(cpu86) and defined(linux)}
  Edit1.Text := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit2.Text := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
  Edit3.Text := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
  Edit7.text := ordir + 'lib/Linux/32bit/LibMp4ff-32.so';
  Edit8.text := ordir + 'lib/Linux/32bit/LibFaad2-32.so';
  Edit5.Text := ordir + 'lib/Linux/32bit/plugin/LibSoundTouch-32.so';
  Edit11.text := ordir + 'lib/Linux/32bit/libxmp-32.so';
  Edit4.Text := ordir + 'sound/test.ogg';
  {$ENDIF}

  {$if defined(linux) and defined(cpuarm)}
  Edit1.Text := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
  Edit2.Text := ordir + 'lib/Linux/arm_raspberrypi/libsndfile-arm.so';
  Edit3.Text := ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so';
  Edit11.Text := ordir + 'lib/Linux/arm_raspberrypi/libxmp-arm.so';
  Edit5.Text := ordir + 'lib/Linux/arm_raspberrypi/plugin/libsoundtouch-32.so';
  Edit4.Text := ordir + 'sound/test.ogg';
  {$ENDIF}

   {$if defined(linux) and defined(cpuaarch64)}
  Edit1.Text := ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so';
  Edit2.Text := ordir + 'lib/Linux/aarch64_raspberrypi/libsndfile_aarch64.so';
  Edit3.Text := ordir + 'lib/Linux/aarch64_raspberrypi/libmpg123_aarch64.so';
  Edit11.text := ordir + 'lib/Linux/aarch64_raspberrypi/libxmp-aarch64.so';
  Edit5.Text := ordir + 'lib/Linux/aarch64_raspberrypi/plugin/libsoundtouch_aarch64.so';
  Edit4.Text := ordir + 'sound/test.ogg';
  {$ENDIF}

  opendialog1.Initialdir := application.Location + 'sound';

end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  uos_InputSetDSPVolume(PlayerIndex1, InputIndex1, TrackBar1.position / 100,
    TrackBar3.position / 100, True);
end;

procedure TForm1.TrackBar2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  TrackBar2.Tag := 1;
end;

procedure TForm1.TrackBar2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  uos_InputSeek(PlayerIndex1, InputIndex1, TrackBar2.position);
  TrackBar2.Tag := 0;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  loadok: Boolean = False;
begin
   {$if defined(CPUAMD64) and defined(linux) }  
  // For Linux amd64, check libsndfile.so
  if (Edit2.Text <> 'system') and (Edit2.Text <> '') then  
  if uos_TestLoadLibrary(PChar(Edit2.Text)) = false then
   begin
   Edit2.Text := Edit2.Text + '.2';
   if uos_TestLoadLibrary(PChar(Edit2.Text)) = false then
    MessageDlg('Error while loading SndFile library...', mtWarning, [mbYes], 0);
   end;
   {$endif}

  // Load the libraries
  // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName, opusfilefilename, xmpfilename: PChar) : LongInt;

  if uos_LoadLib(PChar(Edit1.Text), PChar(Edit2.Text),
    PChar(Edit3.Text), PChar(Edit7.Text), PChar(Edit8.Text), PChar(Edit10.Text), PChar(Edit11.Text)) = 0 then
    // You may load one or more libraries . When you want... :
  begin
    form1.hide;
    loadok          := True;
    button1.Enabled := False;
    edit1.ReadOnly  := True;
    edit2.ReadOnly  := True;
    edit3.ReadOnly  := True;
    edit7.ReadOnly  := True;
    edit8.ReadOnly  := True;
    edit10.ReadOnly := True;
    edit11.ReadOnly := True;
    button1.Caption :=
      'PortAudio, SndFile, Mpg123, AAC, Opus, XMP libraries are loaded...';
  end
  else
    MessageDlg('Error while loading libraries...', mtWarning, [mbYes], 0);

  if loadok = True then
  begin
    if ((trim(PChar(edit5.Text)) <> '') and fileexists(edit5.Text)) and (uos_LoadPlugin('soundtouch', PChar(Edit5.Text)) = 0) then
    begin
      plugsoundtouch  := True;
      button1.Caption :=
        'PortAudio, SndFile, Mpg123, AAC, Opus, XMP and Plugin are loaded...';
    end
    else
    begin
      TrackBar4.Enabled := False;
      TrackBar5.Enabled := False;
      CheckBox2.Enabled := False;
      Button7.Enabled   := False;
      label9.Enabled    := False;
      label7.Enabled    := False;
    end;

    if ((trim(PChar(edit6.Text)) <> '') and fileexists(edit6.Text)) and (uos_LoadPlugin('bs2b', PChar(edit6.Text)) = 0) then
      plugbs2b          := True
    else
      CheckBox3.Enabled := False;

    Height         := 232;
    panel1.left    := 0;
    panel1.top     := 0;
    panel1.Height  := form1.Height;
    panel1.Width   := form1.Width;
    panel1.Visible := True;
    Position       := poScreenCenter;
    Caption        := 'Simple Player.    uos version ' + IntToStr(uos_getversion());
    Show;
  end;

end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  uos_Pause(PlayerIndex1);
  Button4.Enabled   := True;
  Button5.Enabled   := False;
  ShapeLeft.Height  := 0;
  ShapeRight.Height := 0;
  ShapeLeft.top     := 118 - ShapeLeft.Height;
  ShapeRight.top    := 118 - ShapeRight.Height;
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
    InputIndex1 := -1;

    PlayerIndex1 := 0;
    // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
    // If PlayerIndex exists already, it will be overwritten...

    if uos_CreatePlayer(PlayerIndex1) then
      // Create the player.
      // PlayerIndex : from 0 to what your computer can do !
      // If PlayerIndex exists already, it will be overwriten...

      // InputIndex1 := uos_AddFromFile(PlayerIndex1, Edit4.Text);
      // add input from audio file with default parameters

      InputIndex1 := uos_AddFromFile(PlayerIndex1, PChar(Edit4.Text), -1, samformat, -1);
    // add input from audio file with custom parameters
    // FileName : filename of audio file
    // PlayerIndex : Index of a existing Player
    // OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    // SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
    // FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Input Index in array

    if InputIndex1 > -1 then
    begin

     {$if defined(cpuarm) or defined(cpuaarch64)}  // need a lower latency
    OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, -1, 0.3, uos_InputGetSampleRate(PlayerIndex1, InputIndex1),
     uos_InputGetChannels(PlayerIndex1, InputIndex1), samformat, -1, -1);
       {$else}
    OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, InputIndex1),
     uos_InputGetChannels(PlayerIndex1, InputIndex1), samformat, -1, -1);
      {$endif}

      // add a Output into device with custom parameters
      // PlayerIndex : Index of a existing Player
      // Device ( -1 is default Output device )
      // Latency  ( -1 is latency suggested ) )
      // SampleRate : delault : -1 (44100)   // here default samplerate of input
      // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
      // SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
      // FramesCount : default : -1 (65536)
      //  result : -1 nothing created, otherwise Output Index in array

      uos_InputSetLevelEnable(PlayerIndex1, InputIndex1, 2);
      // set calculation of level/volume (usefull for showvolume procedure)
      // set level calculation (default is 0)
      // 0 => no calcul
      // 1 => calcul before all DSP procedures.
      // 2 => calcul after all DSP procedures.
      // 3 => calcul before and after all DSP procedures.

      uos_InputSetPositionEnable(PlayerIndex1, InputIndex1, 1);
      // set calculation of position (usefull for positions procedure)
      // set position calculation (default is 0)
      // 0 => no calcul
      // 1 => calcul position.

      uos_LoopProcIn(PlayerIndex1, InputIndex1, @LoopProcPlayer1);
      // Assign the procedure of object to execute inside the loop for a Input
      // PlayerIndex : Index of a existing Player
      // InIndex : Index of a existing Input
      // LoopProcPlayer1 : procedure of object to execute inside the loop

      uos_InputAddDSPVolume(PlayerIndex1, InputIndex1, 1, 1);
      // DSP Volume changer
      // PlayerIndex1 : Index of a existing Player
      // InputIndex1 : InputIndex of a existing input
      // VolLeft : Left volume  ( from 0 to 1 => gain > 1 )
      // VolRight : Right volume

      uos_InputSetDSPVolume(PlayerIndex1, InputIndex1, TrackBar1.position / 100,
        TrackBar3.position / 100, True); // Set volume
      // PlayerIndex1 : Index of a existing Player
      // InputIndex1 : InputIndex of a existing Input
      // VolLeft : Left volume
      // VolRight : Right volume
      // Enable : Enabled

      DSPIndex1 := uos_InputAddDSP(PlayerIndex1, InputIndex1, @DSPReverseBefore, @DSPReverseAfter, nil, nil);
      // add a custom DSP procedure for input
      // PlayerIndex1 : Index of a existing Player
      // InputIndex1: InputIndex of existing input
      // BeforeFunc : function to do before the buffer is filled
      // AfterFunc : function to do after the buffer is filled
      // EndedFunc : function to do at end of thread
      // LoopProc : external procedure to do after the buffer is filled
      // result = DSPIndex of the custom  DSP

      uos_InputSetDSP(PlayerIndex1, InputIndex1, DSPIndex1, checkbox1.Checked);
      // set the parameters of custom DSP;

      // This is a other custom DSP...stereo to mono  to show how to do a DSP ;-)
      DSPIndex2 := uos_InputAddDSP(PlayerIndex1, InputIndex1, nil, @DSPStereo2Mono, nil, nil);
      uos_InputSetDSP(PlayerIndex1, InputIndex1, DSPIndex2, chkstereo2mono.Checked);

      // add bs2b plugin with samplerate_of_input1  / channels(2 = stereo)
      if plugbs2b = True then
      begin
        PlugInIndex1 := uos_AddPlugin(PlayerIndex1, 'bs2b', uos_InputGetSampleRate(PlayerIndex1, InputIndex1), -1);
        uos_SetPluginbs2b(PlayerIndex1, PluginIndex1, -1, -1, -1, checkbox3.Checked);
      end;

      // add SoundTouch plugin with samplerate_of_input1  / channels(2 = stereo)
      if plugsoundtouch = True then
      begin
        PluginIndex2 := uos_AddPlugin(PlayerIndex1, 'soundtouch', uos_InputGetSampleRate(PlayerIndex1, InputIndex1), -1);
        ChangePlugSet(self); // Change plugin settings
      end;

      trackbar2.Max := uos_InputLength(PlayerIndex1, InputIndex1);
      // Length of Input in samples
      
      if trackbar2.Max > 0 then // mod's can not calculate length
      begin
      trackbar2.enabled := true;
      temptime := uos_InputLengthTime(PlayerIndex1, InputIndex1);
      // Length of input in time

      DecodeTime(temptime, ho, mi, se, ms);

      llength.Caption := format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
      end else
      begin
      trackbar2.enabled := false;
      llength.Caption := '??:??:??.???';
      end;

      // procedure to execute when stream is terminated
      uos_EndProc(PlayerIndex1, @ClosePlayer1);
      // Assign the procedure of object to execute at end
      // PlayerIndex : Index of a existing Player
      // ClosePlayer1 : procedure of object to execute inside the loop

      TrackBar2.position := 0;

      Button3.Enabled    := False;
      Button4.Enabled    := False;
      Button6.Enabled    := True;
      Button5.Enabled    := True;
      CheckBox1.Enabled  := True;

      uos_Play(PlayerIndex1);  // everything is ready, here we are, lets play it...
    end;
  end
  else
    MessageDlg(edit4.Text + ' do not exist...', mtWarning, [mbYes], 0);

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
  uos_InputSetDSP(PlayerIndex1, InputIndex1, DSPIndex1, checkbox1.Checked);
end;

procedure TForm1.CheckBox3Change(Sender: TObject);
begin
  uos_SetPluginbs2b(PlayerIndex1, PluginIndex1, -1, -1, -1, checkbox3.Checked);
end;

procedure TForm1.ChknoiseChange(Sender: TObject);
begin
  uos_InputSetDSPNoiseRemoval(PlayerIndex1, InputIndex1, chknoise.Checked);
end;

procedure TForm1.chkstereo2monoChange(Sender: TObject);
begin
  uos_InputSetDSP(PlayerIndex1, InputIndex1, DSPIndex2, chkstereo2mono.Checked);
end;

procedure TForm1.Edit10Change(Sender: TObject);
begin

end;

procedure uos_logo();
var
  xpos, ypos: integer;
  ratio: double;
begin
  xpos      := 0;
  ypos      := 0;
  ratio     := 1;
  BufferBMP := TBitmap.Create;
  with form1 do
  begin
    form1.PaintBox1.Parent.DoubleBuffered := True;
    PaintBox1.Height := round(ratio * 116);
    PaintBox1.Width  := round(ratio * 100);
    BufferBMP.Height := PaintBox1.Height;
    BufferBMP.Width  := PaintBox1.Width;
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
  if TrackBar2.Tag = 0 then
  begin
    if trackbar2.Max > 0 then
    TrackBar2.Position := uos_InputPosition(PlayerIndex1, InputIndex1);
    temptime           := uos_InputPositionTime(PlayerIndex1, InputIndex1);
    // Length of input in time
    DecodeTime(temptime, ho, mi, se, ms);
    lposition.Caption  := format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
  end;
end;

procedure Tform1.ShowLevel;
begin
  ShapeLeft.Height  := round(uos_InputGetLevelLeft(PlayerIndex1, InputIndex1) * 92);
  ShapeRight.Height := round(uos_InputGetLevelRight(PlayerIndex1, InputIndex1) * 92);
  ShapeLeft.top     := 118 - ShapeLeft.Height;
  ShapeRight.top    := 118 - ShapeRight.Height;
end;

procedure Tform1.LoopProcPlayer1;
begin
  ShowPosition;
  ShowLevel;
end;

function DSPReverseBefore(var Data: TuosF_Data; var fft: TuosF_FFT): TDArFloat;
begin

  if (Data.position > Data.OutFrames div Data.channels) then
    uos_InputSeek(PlayerIndex1, InputIndex1, Data.position - (Data.OutFrames div Data.channels));
end;

function DSPReverseAfter(var Data: TuosF_Data; var fft: TuosF_FFT): TDArFloat;
var
  x: integer = 0;
  arfl: TDArFloat;
begin
  if (Data.position > Data.OutFrames div Data.channels) then
  begin
    SetLength(arfl, Data.outframes);

    while x < Data.outframes - 1 do
    begin
      arfl[x]     := Data.Buffer[Data.outframes - x - 1];
      arfl[x + 1] := Data.Buffer[Data.outframes - x];
      x           := x + 2;
    end;
    Result := arfl;
  end
  else
    Result := Data.Buffer;
end;

function DSPStereo2Mono(var Data: TuosF_Data; var fft: TuosF_FFT): TDArFloat;
var
  x: integer = 0;
  ps: PDArShort;     // if input is Int16 format
  pl: PDArLong;      // if input is Int32 format
  pf: PDArFloat;     // if input is Float32 format
  samplef: cFloat;
  samplei: integer;
begin
  if (Data.channels = 2) then
  begin

    case Data.SampleFormat of
      2:
      begin
        ps := @Data.Buffer;
        while x < Data.OutFrames do
        begin
          samplei    := round((ps^[x] + ps^[x + 1]) / 2);
          ps^[x]     := samplei;
          ps^[x + 1] := samplei;
          x          := x + 2;
        end;
      end;

      1:
      begin
        pl := @Data.Buffer;
        while x < Data.OutFrames do
        begin
          samplei    := round((pl^[x] + pl^[x + 1]) / 2);
          pl^[x]     := samplei;
          pl^[x + 1] := samplei;
          x          := x + 2;
        end;
      end;

      0:
      begin
        pf := @Data.Buffer;
        while x < Data.OutFrames do
        begin
          samplef    := (pf^[x] + pf^[x + 1]) / 2;
          pf^[x]     := samplef;
          pf^[x + 1] := samplef;
          x          := x + 2;
        end;
      end;

    end;
    Result := Data.Buffer;
  end
  else
    Result := Data.Buffer;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Height           := 422;
  ShapeLeft.Height := 0;
  ShapeRight.Height := 0;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if (button3.Enabled = False) then
  begin
    button6.Click;
    sleep(200);
    application.ProcessMessages;
  end;
  uos_free();
  BufferBMP.Free;
end;

end.

