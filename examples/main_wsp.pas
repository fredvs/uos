// Demo how to use United Openlib of Sound //

unit main_wsp;

{$mode objfpc}{$H+}

interface

uses
  uos_flat,
  Math,
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
  fphttpclient,
  openssl, { This implements the procedure InitSSLInterface }
  opensslsockets,
  Controls;

type
  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit8: TEdit;
    Label1: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lposition: TLabel;
    lerror: TLabel;
    opusformat: TRadioButton;
    aacformat: TRadioButton;
    PaintBox1: TPaintBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    mp3format: TRadioButton;
    RadioGroup1: TRadioGroup;
    Shape1: TShape;
    ShapeRight: TShape;
    ShapeLeft: TShape;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure ontimericytag(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure ClosePlayer1;
    procedure LoopProcPlayer1;
    procedure ShowLevel;
    procedure ChangePlugSet(Sender: TObject);
    procedure ResetPlugClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

procedure uos_logo();

var
  Form1: TForm1;
  BufferBMP: TBitmap;
  PlayerIndex1: cardinal;
  Out1Index, In1Index, DSP1Index, Plugin1Index: integer;
  plugsoundtouch: Boolean = False;
  aboolicy: Boolean = False;
  icystr: string;

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
      uos_SetPluginSoundTouch(PlayerIndex1, Plugin1Index, tempo, rate, checkbox2.Checked);
  end;

end;

procedure TForm1.ResetPlugClick(Sender: TObject);
begin
  TrackBar4.Position := 50;
  TrackBar5.Position := 50;
  if radiogroup1.Enabled = False then   // player1 was created
    uos_SetPluginSoundTouch(PlayerIndex1, Plugin1Index, 1, 1, checkbox2.Checked);

end;

procedure TForm1.ClosePlayer1;
begin
  Form1.button3.Enabled     := True;
  Form1.button4.Enabled     := False;
  Form1.button5.Enabled     := False;
  Form1.button6.Enabled     := False;
  Form1.radiogroup1.Enabled := True;
  Form1.ShapeLeft.Height    := 0;
  Form1.ShapeRight.Height   := 0;
  Form1.ShapeLeft.top       := 296;
  Form1.ShapeRight.top      := 296;
end;

procedure TForm1.FormActivate(Sender: TObject);
var
  ordir: string;
{$IFDEF Darwin}
  opath: string;
{$ENDIF}
begin
  {$if (defined(CPUAMD64) and defined(linux)) or (defined(CPUAMD64) and defined(windows))}
  aacformat.visible := true;
  {$else}
  aacformat.Visible := False;
  {$endif}

  ordir := application.Location;
  uos_logo();
  {$IFDEF Windows}
  {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
  Edit3.Text := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
  Edit5.Text := ordir + 'lib\Windows\64bit\plugin\LibSoundTouch-64.dll';
  edit8.Text := ordir + 'lib\Windows\64bit\libfdk-aac-64.dll';
 {$else}
 Edit1.Text := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
 Edit3.Text := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
 Edit5.Text := ordir + 'lib\Windows\32bit\plugin\LibSoundTouch-32.dll';
 edit8.Text := ordir + 'lib\Windows\32bit\libfdk-aac-32.dll';
 Edit6.Text := ordir + 'lib\Windows\32bit\LibOpusFile-32.dll';
 {$endif}
 {$ENDIF}

  {$IFDEF Darwin}
   {$IFDEF CPU32}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit3.Text := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
  Edit5.Text := opath + '/lib/Mac/32bit/plugin/LibSoundTouch-32.dylib';
   {$ENDIF}
    {$IFDEF CPU64}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
  Edit3.Text := opath + '/lib/Mac/64bit/LibMpg123-64.dylib';
   {$ENDIF}
    {$ENDIF}

 {$if defined(CPUAMD64) and defined(linux) }
  Edit1.Text := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit3.Text := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  edit8.Text := ordir + 'lib/Linux/64bit/libfdk-aac-64.so';
  Edit5.Text := ordir + 'lib/Linux/64bit/plugin/LibSoundTouch-64.so';
  Edit6.Text := ordir + 'lib/Linux/64bit/LibOpusFile-64.so';
{$ENDIF}
 {$if defined(cpu86) and defined(linux)}
  Edit1.Text := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit3.Text := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
  edit8.Text := ordir + 'lib/Linux/32bit/libfdk-aac-32.so';
  Edit5.Text := ordir + 'lib/Linux/32bit/plugin/LibSoundTouch-32.so';
{$endif}

 {$if defined(linux) and defined(cpuaarch64)}
  Edit1.Text := ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so';
  Edit3.Text := ordir + 'lib/Linux/aarch64_raspberrypi/libmpg123_aarch64.so';
  edit8.Text := ordir + 'lib/Linux/aarch64_raspberrypi/libfdk-aac-64.so';
  Edit5.Text := ordir + 'lib/Linux/aarch64_raspberrypi/plugin/libsoundtouch_aarch64.so';
 {$ENDIF}

 {$if defined(linux) and defined(cpuarm)}
  Edit1.Text := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
  Edit3.Text := ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so'; 
  edit8.Text := ordir + 'lib/Linux/arm_raspberrypi/libfdk-aac-64.so';
  Edit5.Text := ordir + 'lib/Linux/arm_raspberrypi/plugin/libsoundtouch-arm.so'; 
  {$ENDIF}

{$if defined(CPUAMD64) and defined(openbsd) }
  Edit1.Text := ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so';
  Edit3.Text := ordir + 'lib/OpenBSD/64bit/LibMpg123-64.so';
  Edit5.Text := ordir + 'lib/OpenBSD/64bit/plugin/LibSoundTouch-64.so';
  Edit6.Text := ordir + 'lib/OpenBSD/64bit/LibOpusFile-64.so';
{$ENDIF}

{$IFDEF freebsd}
    {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
  Edit3.Text := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
  Edit5.Text := '';
{$else}
  Edit1.Text := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
  Edit3.Text := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
  Edit5.Text := '';
{$endif}
{$ENDIF}

end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  if (button3.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex1, In1Index, TrackBar1.position / 100,
      TrackBar3.position / 100, True);
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  loadok: Boolean = False;
begin

  // Load the libraries
  // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName,  opusfilefilename, libxmpfilename, fdkaac: PChar) : LongInt;

  if uos_LoadLib(PChar(edit1.Text), nil, PChar(edit3.Text), nil, nil, PChar(edit6.Text), nil, PChar(edit8.Text)) = 0 then
  begin
    form1.hide;
    loadok          := True;
    button1.Caption :=
      'PortAudio, Mpg123, OpusFile and fdkaac libraries are loaded...';
  end
  else
    MessageDlg('Error while loading libraries...', mtWarning, [mbYes], 0);

  if loadok = True then
  begin
    if (trim(PChar(edit5.Text)) <> '') and fileexists(edit5.Text) and (uos_LoadPlugin('soundtouch', PChar(edit5.Text)) = 0) then
    begin
      button1.Caption :=
        'PortAudio, Mpg123, OpusFile, fdkaac and SoundTouch libraries are loaded...';
      plugsoundtouch  := True;
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

    button1.Enabled := False;
    edit1.ReadOnly  := True;
    edit3.ReadOnly  := True;
    edit5.ReadOnly  := True;
    form1.Height    := 558;
    form1.Position  := poScreenCenter;
    form1.Caption   := 'Simple Web Player.    uos version ' + IntToStr(uos_getversion());

    // Some audio web streaming
    //  edit4.text :=  'https://radio.lotustechnologieslk.net:2020/stream/hirufmgarden';
    //  edit4.Text := 'http://broadcast.infomaniak.net:80/alouette-high.mp3';
    //  edit4.text := 'http://www.hubharp.com/web_sound/BachGavotteShort.mp3' ;
    //  edit4.text := 'http://www.jerryradio.com/downloads/BMB-64-03-06-MP3/jg1964-03-06t01.mp3' ;
    //  edit4.text := 'https://github.com/fredvs/test/releases/download/fpc323/test.opus';
    //  edit4.text := 'https://radiorecord.hostingradio.ru/ps96.aacp';

    edit4.Text := 'http://stream-uk1.radioparadise.com/mp3-128';

    form1.Show;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if aboolicy then
    timer1.Enabled        := False;
  uos_Pause(PlayerIndex1);
  Button4.Enabled         := True;
  Button5.Enabled         := False;
  Form1.ShapeLeft.Height  := 0;
  Form1.ShapeRight.Height := 0;
  Form1.ShapeLeft.top     := 296;
  Form1.ShapeRight.top    := 296;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Button4.Enabled := False;
  Button5.Enabled := True;
  Button6.Enabled := True;
  application.ProcessMessages;
  uos_RePlay(PlayerIndex1);
  if aboolicy then
    timer1.Enabled := True;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  samformat, audioformat: shortint;
  sizebuff: integer;
  ticy: ppchar;
  sicy: PChar;
begin
  lerror.Caption := '';
  label2.Caption := '';
  PlayerIndex1   := 0;
  aboolicy       := False;
  sizebuff       := 8192;

  if mp3format.Checked = True then
  begin
    aboolicy    := True;
    audioformat := 0;
  end
  else if opusformat.Checked = True then
    audioformat := 1
  else if aacformat.Checked = True then
    audioformat := 2;

  if radiobutton1.Checked = True then
    samformat := 0;
  if radiobutton2.Checked = True then
    samformat := 1;
  if radiobutton3.Checked = True then
    samformat := 2;

  uos_CreatePlayer(PlayerIndex1);
  // Create the player.
  // PlayerIndex : from 0 to what your computer can do !
  // If PlayerIndex exists already, it will be overwriten...

  In1Index := uos_AddFromURL(PlayerIndex1, PChar(edit4.Text), -1, samformat, sizebuff, audioformat, True);
  // Add a Input from Audio URL with custom parameters
  // URL : URL of audio file (like  'http://someserver/somesound.mp3')
  // OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
  // SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (1024)
  // AudioFormat : default : -1 (mp3) (0: mp3, 1: opus, 2: aac)
  // ICY data on/off
  // example : InputIndex := AddFromFile(0,'http://someserver/somesound.mp3',-1,-1,-1);
  //  result : -1 nothing created, otherwise Input Index in array

  if In1Index <> -1 then
  begin

    radiogroup1.Enabled := False;

    Out1Index := uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, In1Index),
      uos_InputGetChannels(PlayerIndex1, In1Index), samformat, sizebuff, -1);

    // add a Output into device with custom parameters
    // PlayerIndex : Index of a existing Player
    // Device ( -1 is default Output device )
    // Latency  ( -1 is latency suggested ) )
    // SampleRate : delault : -1 (44100)   // here default samplerate of input
    // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    // SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    // FramesCount : default : -1 (65536)
    // ChunkCount : default : -1 (= 512)
    //  result : -1 nothing created, otherwise Output Index in array

    uos_InputSetLevelEnable(PlayerIndex1, In1Index, 2);
    // set calculation of level/volume (usefull for showvolume procedure)
    // set level calculation (default is 0)
    // 0 => no calcul
    // 1 => calcul before all DSP procedures.
    // 2 => calcul after all DSP procedures.
    // 3 => calcul before and after all DSP procedures.

    uos_LoopProcIn(PlayerIndex1, In1Index, @LoopProcPlayer1);
    // Assign the procedure of object to execute inside the loop for a Input
    // PlayerIndex : Index of a existing Player
    // InIndex : Index of a existing Input
    // LoopProcPlayer1 : procedure of object to execute inside the loop

    uos_InputAddDSPVolume(PlayerIndex1, In1Index, 1, 1);
    // DSP Volume changer
    // PlayerIndex1 : Index of a existing Player
    // In1Index : InputIndex of a existing input
    // VolLeft : Left volume  ( from 0 to 1 => gain > 1 )
    // VolRight : Right volume

    uos_InputSetDSPVolume(PlayerIndex1, In1Index, TrackBar1.position / 100,
      TrackBar3.position / 100, True); // Set volume
    // PlayerIndex1 : Index of a existing Player
    // In1Index : InputIndex of a existing Input
    // VolLeft : Left volume
    // VolRight : Right volume
    // Enable : Enabled

    if plugsoundtouch = True then
    begin
      Plugin1Index := uos_AddPlugin(PlayerIndex1, 'soundtouch', uos_InputGetSampleRate(PlayerIndex1, In1Index),
        uos_InputGetChannels(PlayerIndex1, In1Index));
      // add SoundTouch plugin with default samplerate(44100) / channels(2 = stereo)

      ChangePlugSet(self); // Change plugin settings
    end;

    // procedure to execute when stream is terminated
    uos_EndProc(PlayerIndex1, @ClosePlayer1);
    // Assign the procedure of object to execute at end
    // PlayerIndex : Index of a existing Player
    // ClosePlayer1 : procedure of object to execute inside the loop

    Button3.Enabled := False;
    Button4.Enabled := False;
    Button6.Enabled := True;
    Button5.Enabled := True;

    application.ProcessMessages;

    sleep(1000);

    uos_Play(PlayerIndex1);  // everything is ready, here we are, lets play it...

    application.ProcessMessages;
    if aboolicy then
      timer1.Enabled := True;

  end
  else
    lerror.Caption := 'URL did not accessed';

end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if aboolicy then
    timer1.Enabled := False;
  uos_Stop(PlayerIndex1);
  sleep(1000);
  ClosePlayer1;
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

procedure Tform1.ShowLevel;
begin
  ShapeLeft.Height  := round(uos_InputGetLevelLeft(PlayerIndex1, In1Index) * 146);
  ShapeRight.Height := round(uos_InputGetLevelRight(PlayerIndex1, In1Index) * 146);
  ShapeLeft.top     := 450 - ShapeLeft.Height;
  ShapeRight.top    := 450 - ShapeRight.Height;
end;

procedure Tform1.LoopProcPlayer1;
begin
  ShowLevel;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Height      := 260;
  ShapeLeft.Height  := 0;
  ShapeRight.Height := 0;
  label2.Caption    := '';
  SetExceptionMask(GetExceptionMask + [exZeroDivide] + [exInvalidOp] +
    [exDenormalized] + [exOverflow] + [exUnderflow] + [exPrecision]);

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
    if plugsoundtouch then
      uos_UnloadPlugin('soundtouch');
    uos_free();
  end;
  BufferBMP.Free;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin

end;

procedure TForm1.ontimericytag(Sender: TObject);
var
  ticy: ppchar;
  aname, apicture: string;
  sicy: PChar;
begin
  ticy := ppchar(sicy);
  checksynchronize(uos_InputUpdateICY(PlayerIndex1, In1Index, ticy));

  if ticy <> nil then
  begin
    sicy := ticy^;
    if icystr <> sicy then
    begin
      if system.Pos('StreamTitle=', sicy) > 0 then
      begin
        aname := Copy(sicy, system.pos('StreamTitle=', sicy) + 12, Length(sicy));
        aname := Copy(aname, 1, system.Pos(';', aname) - 1);
      end;

      if system.Pos('StreamUrl=', sicy) > 0 then
      begin
        apicture := Copy(sicy, system.pos('StreamUrl=', sicy) + 10, Length(sicy));
        apicture := Copy(apicture, 2, system.Pos(';', apicture) - 1);
        apicture := Copy(apicture, 1, system.Pos('''', apicture) - 1);
      end;
      label2.Caption := aname + #10 + apicture;
      icystr := sicy;
    end;
  end;

end;

end.

