
/////////////////// Demo how to use United Openlib of Sound ////////////////////
unit main_sr;

{$mode objfpc}{$H+}
interface

uses
  uos_flat,
  uos,
  ctypes,
  Forms,
  Dialogs,
  SysUtils,
  Graphics,
  StdCtrls,
  ComCtrls,
  ExtCtrls,
  Classes,
  Controls, Grids;

type
  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    PaintBox1: TPaintBox;
    bwav: TRadioButton;
    bogg: TRadioButton;
    Shape1: TShape;
    TrackBar1: TTrackBar;
    TrackBar3: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ClosePlayer1;
    procedure TrackBar1Change(Sender: TObject);
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
  In1Index, out1index: integer;
  thebuffer: array of cfloat;
  thebufferinfos: TuosF_BufferInfos;
  thememorystream: Tmemorystream;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ClosePlayer1;
begin
  sleep(500);
  application.ProcessMessages;
  button2.Enabled := True;
  button3.Enabled := False;
  button5.Enabled := False;
  CheckBox1.Enabled := True;
  CheckBox2.Enabled := True;
  if CheckBox2.Checked = True then
    Button4.Enabled := True;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  if (Button2.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex1, In1Index, TrackBar1.position / 100,
      TrackBar3.position / 100, True);
end;

procedure TForm1.FormActivate(Sender: TObject);
{$IFDEF Darwin}
var
  opath: string;
{$ENDIF}
begin
  uos_logo();
  {$IFDEF Windows}
     {$if defined(cpu64)}
  edit1.Text := application.Location + 'lib\Windows\64bit\LibPortaudio-64.dll';
  edit2.Text := application.Location + 'lib\Windows\64bit\LibSndFile-64.dll';
{$else}
  edit1.Text := application.Location + 'lib\Windows\32bit\LibPortaudio-32.dll';
  edit2.Text := application.Location + 'lib\Windows\32bit\LibSndFile-32.dll';
   {$endif}
  Edit3.Text := application.Location + 'sound\testrecord.wav';
  {$ENDIF}

  {$IFDEF Darwin}
   {$IFDEF CPU32}
  opath := application.location;
  opath := copy(ordir, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit2.Text := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
  Edit3.Text := application.Location + '/sound/testrecord.wav';
   {$ENDIF}
    {$IFDEF CPU64}
  opath := application.location;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
  Edit2.Text := opath + '/lib/Mac/64bit/LibSndFile-64.dylib';
  Edit3.Text := application.Location + '/sound/testrecord.wav';
   {$ENDIF}
  {$ENDIF}

  {$if defined(CPUAMD64) and defined(linux) }
  Edit1.Text :=  application.Location + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit2.Text :=  application.Location + 'lib/Linux/64bit/LibSndFile-64.so';
   Edit3.Text := application.Location + 'sound/testrecord.wav';
  {$ENDIF}
  {$if defined(cpu86) and defined(linux)}
  Edit1.Text :=  application.Location + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit2.Text :=  application.Location + 'lib/Linux/32bit/LibSndFile-32.so';
   Edit3.Text := application.Location + 'sound/testrecord.wav';
  {$ENDIF}
  {$if defined(linux) and defined(cpuarm)}
  Edit1.Text :=  application.Location + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
  Edit2.Text :=  application.Location + 'lib/Linux/arm_raspberrypi/libsndfile-arm.so';
   Edit3.Text := application.Location + 'sound/testrecord.wav';
  {$ENDIF}
  {$if defined(linux) and defined(cpuaarch64)}
  Edit1.Text := application.Location + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so';
  Edit2.Text := application.Location + 'lib/Linux/aarch64_raspberrypi/libsndfile_aarch64.so';
   Edit3.Text := application.Location + 'sound/testrecord.wav';
  {$ENDIF}

  {$if defined(CPUAMD64) and defined(openbsd) }
  Edit1.Text :=  application.Location + 'lib/OpenBSD/64bit/LibPortaudio-64.so';
  Edit2.Text :=  application.Location + 'lib/OpenBSD/64bit/LibSndFile-64.so';
   Edit3.Text := application.Location + 'sound/testrecord.wav';
  {$ENDIF}

  {$IFDEF freebsd}
   {$if defined(cpu64)}
   Edit1.Text := application.Location +  'lib/FreeBSD/64bit/libportaudio-64.so';
  Edit2.Text := application.Location +  'lib/FreeBSD/64bit/libsndfile-64.so';
  {$else}
  Edit1.Text := application.Location +  'lib/FreeBSD/32bit/libportaudio-32.so';
  Edit2.Text := application.Location +  'lib/FreeBSD/32bit/libsndfile-32.so';
  {$endif}
  Edit3.Text := application.Location + 'sound/testrecord.wav';
  {$ENDIF}

end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
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
  if uos_LoadLib(PChar(edit1.Text), PChar(edit2.Text), nil, nil, nil, nil, nil) = 0 then
  begin
    form1.hide;
    button1.Caption := 'PortAudio and SndFile libraries are loaded...';
    button1.Enabled := False;
    edit1.ReadOnly := True;
    edit2.ReadOnly := True;
    form1.Height := 318;
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
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  outformatst: string;
  outformat, numchan: integer;
begin
  if (checkbox1.Checked = True) or (checkbox2.Checked = True) then
  begin

    PlayerIndex1 := 0;
    // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
    // If PlayerIndex exists already, it will be overwritten...

    uos_CreatePlayer(PlayerIndex1);
    // Create the player.
    // PlayerIndex : from 0 to what your computer can do !
    // If PlayerIndex exists already, it will be overwriten...

    //uos_AddIntoFileFromMem(PlayerIndex1, Pchar(edit3.Text));
    // add Output into wav file (save record) from TMemoryStream  with default parameters

    if bwav.Checked then
    begin
      outformatst := '.wav';
      outformat := 0;
    end
    else
    begin
      outformatst := '.ogg';
      outformat := 3;
    end;

    edit3.Text := 'rec_' + UTF8Decode(formatdatetime('YY_MM_DD_HH_mm_ss', now)) +
      outformatst;

    In1Index := uos_AddFromDevIn(PlayerIndex1);
    // add input from mic with custom parameters
    // PlayerIndex : Index of a existing Player
    // Device ( -1 is default Input device )
    // Latency  ( -1 is latency suggested ) )
    // SampleRate : delault : -1 (44100)
    // OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    // SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    // FramesCount : -1 default : 4096   ( > = safer, < =  better latency )

    numchan := uos_InputGetChannels(PlayerIndex1, In1Index);

    // saving in a file using a File-Stream:
    if CheckBox2.Checked then
      uos_AddIntoFile(PlayerIndex1, PChar(edit3.Text), -1, numchan, -1, 4096, outformat);

    //   function uos_AddIntoFile(PlayerIndex: cint32; Filename: PChar; SampleRate: cint32;
    // Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32 ; FileFormat: cint32): cint32;
    // Add a Output into audio wav file with custom parameters from TFileStream
    // PlayerIndex : Index of a existing Player
    // FileName : filename of saved audio wav file
    // SampleRate : delault : -1 (44100)
    // Channels : delault : -1 (2:stereo) (1:mono, 2:stereo, ...) if 2 it will force to stereo if input is mono
    // SampleFormat : default : -1 (2:Int16) (1:Int32, 2:Int16)
    // FramesCount : default : -1 (= 65536)
    // FileFormat : default : -1 (wav) (0:wav, 1:pcm, 2:custom, 3:ogg);

    //  saving in a Memory-Buffer:
    //  SetLength(thebuffer, 0);
    //  uos_AddIntoMemoryBuffer(PlayerIndex1, @thebuffer);

    // saving in a Memory-Stream:  
    // if thememorystream = nil then thememorystream := tmemorystream.create;
    // uos_AddIntoMemoryStream(PlayerIndex1, (thememorystream),-1,-1,-1,-1);

    // saving in a file using a Menory-Stream:   
    // uos_AddIntoFileFromMem(PlayerIndex1, Pchar(filenameEdit4.filename));
    // add Output into wav file (save record)  with default parameters

    {$if defined(cpuarm) or defined(cpuaarch64)}
    // need a lower latency
    out1index := uos_AddIntoDevOut(PlayerIndex1, -1, 0.8, -1, numchan, -1, -1, -1) ;
    {$else}
    out1index := uos_AddIntoDevOut(PlayerIndex1, -1, -1, -1, numchan, -1, -1, -1);
    {$endif}
    
    // function uos_AddIntoDevOut(PlayerIndex: cint32; Device: cint32; Latency: CDouble;
    // SampleRate: CDouble; Channels: cint32; SampleFormat: cint32 ;
    // FramesCount: cint32 ; ChunkCount: cint32): cint32;

    // Add a Output into Device Output
    // Device ( -1 is default device )
    // Latency  ( -1 is latency suggested )
    // SampleRate : delault : -1 (44100)
    // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    // SampleFormat : default : -1 (2:Int16) (0: Float32, 1:Int32, 2:Int16)
    // FramesCount : default : -1 (= 65536)
    // ChunkCount : default : -1 (= 512)
    //  result :  Output Index in array  -1 = error

    uos_outputsetenable(PlayerIndex1, out1index, checkbox1.Checked);

    uos_InputAddDSPVolume(PlayerIndex1, In1Index, 1, 1);
    // DSP Volume changer
    // PlayerIndex : Index of a existing Player
    // In1Index : InputIndex of a existing input
    // VolLeft : Left volume
    // VolRight : Right volume

    uos_InputSetDSPVolume(PlayerIndex1, In1Index, TrackBar1.position / 100,
      TrackBar3.position / 100, True); // Set volume

    // procedure to execute when stream is terminated
    //   uos_EndProc(PlayerIndex1, @ClosePlayer1);
    // Assign the procedure of object to execute at end
    // PlayerIndex : Index of a existing Player
    // ClosePlayer1 : procedure of object to execute inside the loop

    uos_Play(PlayerIndex1);  // everything is ready to play...

    Button2.Enabled := False;
    Button3.Enabled := True;
    Button4.Enabled := False;
    //CheckBox1.Enabled := False;
    CheckBox2.Enabled := False;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  uos_Stop(PlayerIndex1);
  ClosePlayer1;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  PlayerIndex1 := 0;
  // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
  // If PlayerIndex exists already, it will be overwritten...

  uos_CreatePlayer(PlayerIndex1);
  // Create the player.
  // PlayerIndex : from 0 to what your computer can do !
  // If PlayerIndex exists already, it will be overwriten...

  In1Index := uos_AddFromFile(PlayerIndex1, PChar(Edit3.Text));
  // add input from audio file with default parameters
  // In1Index := Player1.AddFromFile(0, Edit3.Text, -1, 0);  // add input from audio file with custom parameters
  // PlayerIndex : Index of a existing Player
  // FileName : filename of audio file
  // OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  // SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output

  //  uos_AddIntoDevOut(PlayerIndex1); // add a Output into OUT device with default parameters

  {$if defined(cpuarm) or defined(cpuaarch64)}
  // need a lower latency
    uos_AddIntoDevOut(PlayerIndex1, -1, 0.3, uos_InputGetSampleRate(PlayerIndex1, In1Index),
    -1, -1, -1, -1);
  {$else}
  uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, In1Index),
    -1, -1, -1, -1);
  {$endif}

  // add a Output into device with custom parameters
  // PlayerIndex : Index of a existing Player
  // Device ( -1 is default Output device )
  // Latency  ( -1 is latency suggested ) )
  // SampleRate : delault : -1 (44100)
  // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  // SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : -1 default : 65536
  // ChunkCount : default : -1 (= 512)

  uos_InputAddDSP1ChanTo2Chan(PlayerIndex1, In1Index);
  //  Convert mono channel to stereo channels.
  // If the input is stereo, original buffer is keeped.
  // InputIndex : InputIndex of a existing Input
  //  result :  index of DSPIn in array
  // example  DSPIndex1 := uos_InputAddDSP1ChanTo2Chan(PlayerIndex1, InputIndex1);

  uos_InputAddDSPVolume(PlayerIndex1, In1Index, 1, 1);
  // DSP Volume changer
  // PlayerIndex : Index of a existing Player
  // In1Index : InputIndex of a existing input
  // VolLeft : Left volume
  // VolRight : Right volume
  //  result : -1 nothing created, otherwise index of DSPIn in array

  uos_InputSetDSPVolume(PlayerIndex1, In1Index, TrackBar1.position / 100,
    TrackBar3.position / 100, True); // Set volume

  // procedure to execute when stream is terminated
  uos_EndProc(PlayerIndex1, @ClosePlayer1);
  // Assign the procedure of object to execute at end
  // PlayerIndex : Index of a existing Player
  // ClosePlayer1 : procedure of object to execute inside the loop

  uos_Play(PlayerIndex1);  // everything is ready to play...

  button4.Enabled := False;
  button5.Enabled := True;
  button2.Enabled := False;
  CheckBox1.Enabled := False;
  CheckBox2.Enabled := False;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  uos_outputsetenable(0, out1index, checkbox1.Checked);
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
  application.ProcessMessages;
  if (Button2.Enabled = False) then
  begin
    Button3.Click;
    sleep(500);
  end;
  if button1.Enabled = False then
    uos_free;
  BufferBMP.Free;
end;

end.
