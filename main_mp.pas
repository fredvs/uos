
/////////////////// Demo how to use United Openlib of Sound ////////////////////


unit main_mp;

{$mode objfpc}{$H+}

interface

uses
  uos, Forms, Dialogs, Graphics, StdCtrls, ExtCtrls;

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
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
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
    procedure PaintBox1Paint(Sender: TObject);

    procedure ClosePlayer1;
    procedure ClosePlayer2;
    procedure ClosePlayer3;
    procedure ClosePlayer4;

  private
    { private declarations }
  public

    { public declarations }
  end;

procedure UOS_logo();


var
  Form1: TForm1;
  BufferBMP: TBitmap;
  Player1, Player2, Player3, Player4: TUOS_Player;
  testInit: TUOS_Init;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ClosePlayer1;
begin
  button16.Enabled := False;
  button15.Enabled := False;
  button3.Enabled := False;
end;

procedure TForm1.ClosePlayer2;
begin
  button17.Enabled := False;
  button18.Enabled := False;
  button6.Enabled := False;
end;

procedure TForm1.ClosePlayer3;
begin
  button19.Enabled := False;
  button20.Enabled := False;
  button9.Enabled := False;
end;

procedure TForm1.ClosePlayer4;
begin
  button21.Enabled := False;
  button22.Enabled := False;
  button12.Enabled := False;
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
  edit4.Text := application.Location + 'sound\test.wav';
  edit5.Text := application.Location + 'sound\test.mp3';
  edit6.Text := application.Location + 'sound\test.flac';
  edit7.Text := application.Location + 'sound\test.ogg';
 {$ENDIF}

  {$IFDEF Darwin}
  opath := application.Location;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  edit1.Text := opath + '/lib/LibPortaudio-32.dylib';
  edit4.Text := opath + 'sound/test.wav';
  edit5.Text := opath + 'sound/test.mp3';
  edit6.Text := opath + 'sound/test.flac';
  edit7.Text := opath + 'sound/test.ogg';
  {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  edit1.Text := application.Location + 'lib/LibPortaudio-64.so';
{$else}
  edit1.Text := application.Location + 'lib/LibPortaudio-32.so';
{$endif}
  edit4.Text := application.Location + 'sound/test.wav';
  edit5.Text := application.Location + 'sound/test.mp3';
  edit6.Text := application.Location + 'sound/test.flac';
  edit7.Text := application.Location + 'sound/test.ogg';
   {$ENDIF}
 
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

procedure TForm1.Button1Click(Sender: TObject);

begin
  testInit := TUOS_Init.Create;   //// Create Iibraries Loader-Init

  testInit.PA_FileName := edit1.Text;
  testInit.SF_FileName := edit2.Text;
  testInit.MP_FileName := edit3.Text;
  testInit.Flag := Loadall;

  testInit.LoadLib;      ///// Load libraries

  if (testInit.LoadResult.PAloaderror = 0) and (testInit.LoadResult.MPloaderror = 0) and
    (testInit.LoadResult.Sfloaderror = 0) then

  begin
    form1.hide;
    form1.Position := podefault;
    testInit.InitLib;     //// Init libraries
    button1.Caption := 'PortAudio, SndFile and Mpg123 libraries are loaded...';
    button1.Enabled := False;
    edit1.ReadOnly := True;
    edit2.ReadOnly := True;
    edit3.ReadOnly := True;
    form1.Height := 478;
    form1.Position := poScreenCenter;
    form1.Show;
  end
  else
  begin
    if testInit.LoadResult.PAloaderror = 1 then
      MessageDlg(edit1.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if testInit.LoadResult.PAloaderror = 2 then
      MessageDlg(edit1.Text + ' do not load...', mtWarning, [mbYes], 0);
    if testInit.LoadResult.SFloaderror = 1 then
      MessageDlg(edit2.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if testInit.LoadResult.SFloaderror = 2 then
      MessageDlg(edit2.Text + ' do not load...', mtWarning, [mbYes], 0);
    if testInit.LoadResult.MPloaderror = 1 then
      MessageDlg(edit3.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if testInit.LoadResult.MPloaderror = 2 then
      MessageDlg(edit3.Text + ' do not load...', mtWarning, [mbYes], 0);
  end;

end;

procedure TForm1.Button20Click(Sender: TObject);
begin
  Player3.RePlay;
  button20.Enabled := False;
  button19.Enabled := True;
end;

procedure TForm1.Button21Click(Sender: TObject);
begin
  Player4.Pause;
  button22.Enabled := True;
  button21.Enabled := False;
end;

procedure TForm1.Button22Click(Sender: TObject);
begin
  Player4.RePlay;
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
  Player4 := TUOS_Player.Create(True);
  
  Player4.AddIntoDevOut;   //// add a Output with default parameters
  // Player4.AddIntoDevOut(-1, -1, -1, -1,0);   //// add a Output with custom parameters
  //////////// Device ( -1 is default device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)

  Player4.AddFromFile(Edit7.Text);  //// add a input from file with default parameters
  // Player4.AddFromFile(Edit7.Text, -1, 0);  //// add a input from file with custom parameters
  ////////// FileName : filename of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output

  Player4.EndProc := @ClosePlayer4;
  /////// procedure to execute when stream is terminated

  Player4.Play;
  ////// Ok let start it

  button22.Enabled := False;
  button21.Enabled := True;
  button12.Enabled := True;
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
  Player4.Stop;
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
  Player1.Pause;
  button16.Enabled := True;
  button15.Enabled := False;
end;


procedure TForm1.Button16Click(Sender: TObject);
begin
  Player1.RePlay;
  button16.Enabled := False;
  button15.Enabled := True;
end;

procedure TForm1.Button17Click(Sender: TObject);
begin
  Player2.Pause;
  button18.Enabled := True;
  button17.Enabled := False;
end;

procedure TForm1.Button18Click(Sender: TObject);
begin
  Player2.RePlay;
  button18.Enabled := False;
  button17.Enabled := True;
end;

procedure TForm1.Button19Click(Sender: TObject);
begin
  Player3.Pause;
  button20.Enabled := True;
  button19.Enabled := False;
end;


procedure TForm1.Button2Click(Sender: TObject);

begin
  Player1 := TUOS_Player.Create(True);

  Player1.AddIntoDevOut;   //// add a Output with default parameters
  // Player1.AddIntoDevOut(-1, -1, -1, -1,0);   //// add a Output with custom parameters
  //////////// Device ( -1 is default device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)

  Player1.AddFromFile(Edit4.Text);  //// add a input from file with default parameters
  // Player1.AddFromFile(Edit4.Text, -1, 0);  //// add a input from file with custom parameters
  ////////// FileName : filename of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output

  Player1.EndProc := @ClosePlayer1;
  /////// procedure to execute when stream is terminated

  Player1.Play;
  ////// Ok let start it

  button15.Enabled := True;
  button3.Enabled := True;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Player1.Stop;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit4.Text := opendialog1.FileName;
end;

procedure TForm1.Button5Click(Sender: TObject);

begin
  Player2 := TUOS_Player.Create(True);

  Player2.AddIntoDevOut;   //// add a Output with default parameters
  // Player2.AddIntoDevOut(-1, -1, -1, -1, 0);   //// add a Output with custom parameters
  //////////// Device ( -1 is default device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)

  Player2.AddFromFile(Edit5.Text);  //// add a input from file with custom parameters
  //Player2.AddFromFile(Edit5.Text, -1, 0);  //// add a input from file with custom parameters
  ////////// FileName : filename of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output

  Player2.EndProc := @ClosePlayer2;
  /////// procedure to execute when stream is terminated

  Player2.Play;
  ////// Ok let start it

  button17.Enabled := True;
  button6.Enabled := True;

end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Player2.Stop;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit5.Text := opendialog1.FileName;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  Player3 := TUOS_Player.Create(True);

  Player3.AddIntoDevOut;   //// add a Output with default parameters
  // Player3.AddIntoDevOut(-1, -1, -1, -1, 0);   //// add a Output with custom parameters
  //////////// Device ( -1 is default device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)

  Player3.AddFromFile(Edit6.Text);  //// add a input from file with default parameters
  //Player3.AddFromFile(Edit6.Text, -1, -1);  //// add a input from file with custom parameters
  ////////// FileName : filename of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output

  Player3.EndProc := @ClosePlayer3;
  /////// procedure to execute when stream is terminated

  Player3.Play;
  ////// Ok let start it
  button19.Enabled := True;
  button9.Enabled := True;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  Player3.Stop;
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
  if button3.Enabled = True then
    player1.Stop;
  if button6.Enabled = True then
    player2.Stop;
  if button9.Enabled = True then
    player3.Stop;
  if button12.Enabled = True then
    player4.Stop;
  if button1.Enabled = False then
    testInit.UnloadLib();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  form1.Height := 148;
end;

end.
