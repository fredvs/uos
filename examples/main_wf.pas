
 /////////////////// Demo how to use United Openlib of Sound ////////////////////

 //// Set debugger off => too much calcul...

unit main_wf;

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
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OpenDialog1: TOpenDialog;
    PaintBox1: TPaintBox;
    PaintBox2: TPaintBox;
    TrackBar1: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox2Paint(Sender: TObject);
    procedure DrawWaveForm;
    procedure ShowPosition;
    procedure ClosePlayer1;

  private
    { private declarations }
  public
    { public declarations }
  end;

procedure uos_logo();

var
  Form1: TForm1;
  BufferBMP, waveformBMP: TBitmap;
  PlayerIndex1, In1index, chan: integer;

implementation

{$R *.lfm}

{ TForm1 }

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
   {$IFDEF CPU32}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit2.Text := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
  Edit3.Text := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
  Edit4.Text := ordir + '/sound/test.mp3';
   {$ENDIF}
    {$IFDEF CPU64}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
  Edit2.Text := opath + '/lib/Mac/64bit/LibSndFile-64.dylib';
  Edit3.Text := opath + '/lib/Mac/64bit/LibMpg123-64.dylib';
  Edit4.Text := ordir + '/sound/test.mp3';
   {$ENDIF}
    {$ENDIF}

 {$if defined(CPUAMD64) and defined(openbsd) }
  Edit1.Text := ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/OpenBSD/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/OpenBSD/64bit/LibMpg123-64.so';
  Edit4.Text := ordir + 'sound/test.mp3';
 {$ENDIF}

     {$if defined(CPUAMD64) and defined(linux) }
  Edit1.Text := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  Edit4.Text := ordir + 'sound/test.mp3';
   {$ENDIF}
{$if defined(cpu86) and defined(linux)}
  Edit1.Text := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit2.Text := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
  Edit3.Text := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
  Edit4.Text := ordir + 'sound/test.mp3';
 {$endif}

  {$if defined(linux) and defined(cpuaarch64)}
  Edit1.Text := ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so';
  Edit2.Text := ordir + 'lib/Linux/aarch64_raspberrypi/libsndfile_aarch64.so';
  Edit3.Text := ordir + 'lib/Linux/aarch64_raspberrypi/libmpg123_aarch64.so';
  Edit4.Text := ordir + 'sound/test.mp3';
  {$ENDIF}

    {$if defined(linux) and defined(cpuarm)}
  Edit1.Text := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
  Edit2.Text := ordir + 'lib/Linux/arm_raspberrypi/libsndfile-arm.so';
  Edit3.Text := ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so'; 
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

procedure TForm1.PaintBox2Paint(Sender: TObject);
begin
  PaintBox2.Canvas.Draw(0, 0, waveformBMP);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin

{$if defined(CPUAMD64) and defined(linux) }
     // For Linux amd64, check libsndfile.so
if (Edit2.Text <> 'system') and (Edit2.Text <> '') then
  if uos_TestLoadLibrary(PChar(edit2.Text)) = false then
   edit2.Text := edit2.Text + '.2';
{$endif}

  // Load the libraries
   // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName,  opusfilefilename, libxmpfilename: PChar) : LongInt;

  // You may load one or more libraries . When you want... :

  if uos_LoadLib(PChar(edit1.Text), PChar(edit2.Text), PChar(edit3.Text), nil, nil, nil, nil) = 0 then
  begin
    form1.hide;
    button1.Caption :=
      'PortAudio, SndFile, Mpg123  libraries are loaded...';
    button1.Enabled := False;
    edit1.ReadOnly  := True;
    edit2.ReadOnly  := True;
    edit3.ReadOnly  := True;
    form1.Height    := 207;
    form1.Position  := poScreenCenter;
    form1.Caption   := 'Wave Form.    uos version ' + IntToStr(uos_getversion());
    form1.Show;
  end
  else
    MessageDlg('Error while loading libraries...', mtWarning, [mbYes], 0);

end;

procedure TForm1.ClosePlayer1;
begin
  Form1.button3.Enabled    := True;
  Form1.button4.Enabled    := True;
  Form1.button5.Enabled    := False;
  Form1.trackbar1.Enabled  := False;
  Form1.TrackBar1.Position := 0;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  filelength, framewanted: integer;
begin
  form1.Height   := 456;
  form1.Position := poScreenCenter;
  if fileexists(Edit4.Text) then
  begin
    if Assigned(waveformBMP) then
      waveformBMP.Free;
    waveformBMP        := TBitmap.Create;
    PaintBox2.Parent.DoubleBuffered := True;
    waveformBMP.Height := PaintBox2.Height;
    waveformBMP.Width  := PaintBox2.Width;
    waveformBMP.Canvas.AntialiasingMode := amOn;
    waveformBMP.Canvas.Pen.Width := 1;
    waveformBMP.Canvas.brush.Color := clgray;
    waveformBMP.Canvas.FillRect(0, 0, PaintBox2.Width, PaintBox2.Height);
    PaintBox2.Refresh;

    PlayerIndex1 := 0;

    //// Create the player.
    uos_CreatePlayer(PlayerIndex1);
    //// PlayerIndex : from 0 to what your computer can do !
    //// If PlayerIndex exists already, it will be overwriten...

    //// add input from audio file with default parameters
    In1Index := uos_AddFromFile(PlayerIndex1, PChar(Edit4.Text));

    chan := uos_InputGetChannels(PlayerIndex1, In1Index);
    //// no output because only decode the steam for wave form

    /// get the length of the audio file
    filelength := uos_InputLength(PlayerIndex1, In1Index);

    ///// set calculation of level/volume into array (usefull for wave form procedure)
    uos_InputSetLevelArrayEnable(PlayerIndex1, In1Index, 2);
    ///////// set level calculation (default is 0)
    // 0 => no calcul
    // 1 => calcul before all DSP procedures.
    // 2 => calcul after all DSP procedures.

    //// determine how much frame will be designed
    framewanted := filelength div paintbox2.Width;
    uos_InputSetFrameCount(PlayerIndex1, In1Index, framewanted);

    ///// Assign the procedure of object to execute at end of stream
    uos_EndProc(PlayerIndex1, @DrawWaveForm);

    uos_Play(PlayerIndex1);  /////// everything is ready, here we are, lets do it...

  end
  else
    MessageDlg(edit4.Text + ' do not exist...', mtWarning, [mbYes], 0);

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if fileexists(Edit4.Text) then
  begin

    PlayerIndex1 := 0;

    //// Create the player.
    uos_CreatePlayer(PlayerIndex1);
    //// PlayerIndex : from 0 to what your computer can do !
    //// If PlayerIndex exists already, it will be overwriten...

    //// add input from audio file with default parameters
    In1Index := uos_AddFromFile(PlayerIndex1, PChar(Edit4.Text));

    //// add a Output into device

  {$if defined(cpuarm) or defined(cpuaarch64)}  // need a lower latency
      uos_AddIntoDevOut(PlayerIndex1, -1, 0.3, uos_InputGetSampleRate(PlayerIndex1, In1Index), -1, -1, -1, -1);
   {$else}
    uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, In1Index), -1, -1, -1, -1);
    {$endif}

    uos_InputSetPositionEnable(PlayerIndex1, In1Index, 1);
    ///////// set position calculation (default is 0)
    // 0 => no calcul
    // 1 => calcul position.

    uos_LoopProcIn(PlayerIndex1, In1Index, @showposition);
    ///// Assign the procedure of object to execute inside the loop for a Input
    //////////// PlayerIndex : Index of a existing Player
    //////////// InIndex : Index of a existing Input
    //////////// showposition : procedure of object to execute inside the loop

    trackbar1.Max := uos_InputLength(PlayerIndex1, In1Index);
    ////// Length of Input in samples

    /////// procedure to execute when stream is terminated
    uos_EndProc(PlayerIndex1, @ClosePlayer1);
    ///// Assign the procedure of object to execute at end
    //////////// PlayerIndex : Index of a existing Player
    //////////// ClosePlayer1 : procedure of object to execute at end of loop

    TrackBar1.position := 0;
    trackbar1.Enabled  := True;
    Button3.Enabled    := False;
    Button4.Enabled    := False;
    Button5.Enabled    := True;

    application.ProcessMessages;

    uos_Play(PlayerIndex1);  /////// everything is ready, here we are, lets play it...

  end
  else
    MessageDlg(edit4.Text + ' do not exist...', mtWarning, [mbYes], 0);

end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  uos_Stop(PlayerIndex1);
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  if opendialog1.Execute then
    Edit4.Text := opendialog1.FileName;
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
begin
  form1.TrackBar1.Position := uos_InputPosition(PlayerIndex1, In1Index);
end;

procedure Tform1.DrawWaveForm;
var
  poswav: integer;
  waveformdata: array of cfloat;
begin
  sleep(250);
  poswav := 0;

  waveformdata := uos_InputGetLevelArray(PlayerIndex1, In1Index);

  while poswav < length(waveformdata) div chan do
  begin
    if chan = 2 then
    begin
      waveformBMP.Canvas.Pen.Color := clyellow;
      waveformBMP.Canvas.Line(poswav, paintbox2.Height div 2, poswav, ((paintbox2.Height div 2) - 1) - round((waveformdata[poswav * 2]) * (paintbox2.Height / 2) - 1));
      waveformBMP.Canvas.Pen.Color := clred;
      waveformBMP.Canvas.Line(poswav, (paintbox2.Height div 2) + 2, poswav, ((paintbox2.Height div 2) + 1) + round((waveformdata[(poswav * 2) + 1]) * (paintbox2.Height / 2) + 1));
    end;
    if chan = 1 then
    begin
      waveformBMP.Canvas.Pen.Color := clgreen;
      waveformBMP.Canvas.Line(poswav, 0, poswav, ((paintbox2.Height) - 1) - round((waveformdata[poswav]) * (paintbox2.Height) - 1));
    end;
    Inc(poswav);
  end;

  paintbox2.Refresh;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Height := 169;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if button1.Enabled = False then
    uos_free;
  BufferBMP.free;  
end;

end.

