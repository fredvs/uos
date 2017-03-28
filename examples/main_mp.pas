
/////////////////// Demo how to use United Openlib of Sound ////////////////////


unit main_mp;

{$mode objfpc}{$H+}

interface

uses
  uos_flat, Forms, Dialogs, Graphics, StdCtrls, ExtCtrls, Classes;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button2: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    OpenDialog1: TOpenDialog;
    PaintBox1: TPaintBox;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;

    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);

    procedure ClosePlayer0;
    procedure ClosePlayer1;
    procedure ClosePlayer2;
    procedure ClosePlayer3;

  private
    { private declarations }
  public

    { public declarations }
  end;

procedure uos_logo();


var
  Form1: TForm1;
  BufferBMP: TBitmap;
  PlayerIndex0, PlayerIndex1, PlayerIndex2, PlayerIndex3: cardinal;


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ClosePlayer0;
begin
  button16.Enabled := False;
  button15.Enabled := False;
  button3.Enabled := False;
end;

procedure TForm1.ClosePlayer1;
begin
  button17.Enabled := False;
  button18.Enabled := False;
  button6.Enabled := False;
end;

procedure TForm1.ClosePlayer2;
begin
  button19.Enabled := False;
  button20.Enabled := False;
  button9.Enabled := False;
end;

procedure TForm1.ClosePlayer3;
begin
  button21.Enabled := False;
  button22.Enabled := False;
  button12.Enabled := False;
end;

procedure TForm1.FormActivate(Sender: TObject);
var
  ordir: string;
{$IFDEF Darwin}
  opath: string;
            {$ENDIF}
begin
  uos_logo();
  ordir := application.Location;
                  {$IFDEF Windows}
     {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
  Edit2.Text := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
  Edit3.Text := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
   {$else}
  Edit1.Text := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
  Edit2.Text := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
  Edit3.Text := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
  Edit8.text := ordir + 'lib\Windows\32bit\LibMp4ff-32.dll';
  Edit9.text := ordir + 'lib\Windows\32bit\LibFaad2-32.dll';
   {$endif}
  {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit2.Text := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
  Edit3.Text := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
           {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
  Edit3.Text := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  Edit8.text := ordir + 'lib/Linux/64bit/LibMp4ff-64.so';
  Edit9.text := ordir + 'lib/Linux/64bit/LibFaad2-64.so';
  {$else}
  Edit1.Text := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit2.Text := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
  Edit3.Text := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
  Edit8.text := ordir + 'lib/Linux/32bit/LibMp4ff-32.so';
  Edit9.text := ordir + 'lib/Linux/32bit/LibFaad2-32.so';
 {$endif}
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
     {$ENDIF}


  opendialog1.Initialdir := application.Location + 'sound';

  Edit4.Text := application.Location + 'sound' + directoryseparator + 'test.mp3';
  Edit5.Text := application.Location + 'sound' + directoryseparator + 'test.ogg';
  Edit6.Text := application.Location + 'sound' + directoryseparator + 'test.wav';
  Edit7.Text := application.Location + 'sound' + directoryseparator + 'test.flac';

end;

procedure TForm1.FormClose(Sender: TObject);
begin

end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
end;

procedure TForm1.Button1Click(Sender: TObject);

begin
  // Load the libraries
  //function  uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName,
  // Mp4ffFileName, FaadFileName, opusfilefilename: PChar) : LongInt;

  if uos_LoadLib(Pchar(Edit1.text), Pchar(Edit2.text),
     Pchar(Edit3.text), Pchar(Edit8.text), Pchar(Edit9.text), nil) = 0 then
 begin
    form1.hide;
    form1.Position := podefault;
    button1.Caption := 'PortAudio, SndFile and Mpg123 libraries are loaded...';
    button1.Enabled := False;
    edit1.ReadOnly := True;
    edit2.ReadOnly := True;
    edit3.ReadOnly := True;
    form1.Height := 566;
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

procedure TForm1.Button20Click(Sender: TObject);
begin
  uos_RePlay(PlayerIndex2);
  button20.Enabled := False;
  button19.Enabled := True;
end;

procedure TForm1.Button21Click(Sender: TObject);
begin
  uos_Pause(PlayerIndex3);
  button22.Enabled := True;
  button21.Enabled := False;
end;

procedure TForm1.Button22Click(Sender: TObject);
begin
  uos_RePlay(PlayerIndex3);
  button22.Enabled := False;
  button21.Enabled := True;
end;


procedure TForm1.Button10Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit6.Text := opendialog1.FileName;
end;

procedure TForm1.Button11Click(Sender: TObject);

begin
  PlayerIndex3 := 3;

  uos_CreatePlayer(PlayerIndex3);

  uos_AddIntoDevOut(PlayerIndex3, -1, -1, -1, -1, 0, -1);
  //// add a Output with custom parameters
  //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Output Index in array


  uos_AddFromFile(PlayerIndex3, pchar(Edit7.Text), -1, 0, -1);
  //// add input from audio file with custom parameters
  ////////// FileName : filename of audio file
  //////////// PlayerIndex : Index of a existing Player
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Input Index in array

  /////// procedure to execute when stream is terminated
  uos_EndProc(PlayerIndex3, @ClosePlayer3);
  ///// Assign the procedure of object to execute at end
  //////////// PlayerIndex : Index of a existing Player
  //////////// ClosePlayer1 : procedure of object to execute inside the loop

  uos_Play(PlayerIndex3);
  ////// Ok let start it

  button22.Enabled := False;
  button21.Enabled := True;
  button12.Enabled := True;
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
  uos_Stop(PlayerIndex3);
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit7.Text := opendialog1.FileName;
end;

procedure TForm1.Button14Click(Sender: TObject);
begin
  Button2.Click;
  Button5.Click;
  Button8.Click;
  Button11.Click;
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
  uos_Pause(PlayerIndex0);
  button16.Enabled := True;
  button15.Enabled := False;
end;


procedure TForm1.Button16Click(Sender: TObject);
begin
  uos_RePlay(PlayerIndex0);
  button16.Enabled := False;
  button15.Enabled := True;
end;

procedure TForm1.Button17Click(Sender: TObject);
begin
  uos_Pause(PlayerIndex1);
  button18.Enabled := True;
  button17.Enabled := False;
end;

procedure TForm1.Button18Click(Sender: TObject);
begin
  uos_RePlay(PlayerIndex1);
  button18.Enabled := False;
  button17.Enabled := True;
end;

procedure TForm1.Button19Click(Sender: TObject);
begin
  uos_Pause(PlayerIndex2);
  button20.Enabled := True;
  button19.Enabled := False;
end;

procedure TForm1.Button2Click(Sender: TObject);

begin
  PlayerIndex0 := 0;

  uos_CreatePlayer(PlayerIndex0);

  uos_AddIntoDevOut(PlayerIndex0, -1, -1, -1, -1, 0, -1);
  //// add a Output with custom parameters
  //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Output Index in array


  uos_AddFromFile(PlayerIndex0, pchar(Edit4.Text), -1, 0, -1);
  //// add input from audio file with custom parameters
  ////////// FileName : filename of audio file
  //////////// PlayerIndex : Index of a existing Player
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Input Index in array

  /////// procedure to execute when stream is terminated
  uos_EndProc(PlayerIndex0, @ClosePlayer0);
  ///// Assign the procedure of object to execute at end
  //////////// PlayerIndex : Index of a existing Player
  //////////// ClosePlayer1 : procedure of object to execute inside the loop

  uos_Play(PlayerIndex0);
  ////// Ok let start it


  button15.Enabled := True;
  button3.Enabled := True;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  uos_Stop(PlayerIndex0);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit4.Text := opendialog1.FileName;
end;

procedure TForm1.Button5Click(Sender: TObject);

begin
  PlayerIndex1 := 1;

  uos_CreatePlayer(PlayerIndex1);

  uos_AddIntoDevOut(PlayerIndex1, -1, -1, -1, -1, 0, -1);
  //// add a Output with custom parameters
  //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Output Index in array


  uos_AddFromFile(PlayerIndex1, pchar(Edit5.Text), -1, 0, -1);
  //// add input from audio file with custom parameters
  ////////// FileName : filename of audio file
  //////////// PlayerIndex : Index of a existing Player
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Input Index in array

  /////// procedure to execute when stream is terminated
  uos_EndProc(PlayerIndex1, @ClosePlayer1);
  ///// Assign the procedure of object to execute at end
  //////////// PlayerIndex : Index of a existing Player
  //////////// ClosePlayer1 : procedure of object to execute inside the loop

  uos_Play(PlayerIndex1);
  ////// Ok let start it

  button17.Enabled := True;
  button6.Enabled := True;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  uos_Stop(PlayerIndex1);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit5.Text := opendialog1.FileName;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  PlayerIndex2 := 2;

  uos_CreatePlayer(PlayerIndex2);

  uos_AddIntoDevOut(PlayerIndex2, -1, -1, -1, -1, 0, -1);
  //// add a Output with custom parameters
  //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Output Index in array


  uos_AddFromFile(PlayerIndex2, pchar(Edit6.Text), -1, 0, -1);
  //// add input from audio file with custom parameters
  ////////// FileName : filename of audio file
  //////////// PlayerIndex : Index of a existing Player
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Input Index in array

  /////// procedure to execute when stream is terminated
  uos_EndProc(PlayerIndex2, @ClosePlayer2);
  ///// Assign the procedure of object to execute at end
  //////////// PlayerIndex : Index of a existing Player
  //////////// ClosePlayer1 : procedure of object to execute inside the loop

  uos_Play(PlayerIndex2);
  ////// Ok let start it
  ////// Ok let start it
  button19.Enabled := True;
  button9.Enabled := True;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  uos_Stop(PlayerIndex2);
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
  form1.Height := 230;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if button3.Enabled = True then
    uos_Stop(PlayerIndex0);
  if button6.Enabled = True then
    uos_Stop(PlayerIndex1);
  if button9.Enabled = True then
    uos_Stop(PlayerIndex2);
  if button12.Enabled = True then
    uos_Stop(PlayerIndex3);
  if button1.Enabled = False then
  uos_free;
end;

end.
