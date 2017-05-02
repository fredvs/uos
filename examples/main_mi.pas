
/////////////////// Demo how to use United Openlib of Sound ////////////////////


unit main_mi;

{$mode objfpc}{$H+}

interface

uses
  uos_flat, Forms, Dialogs, SysUtils, fileutil, Graphics, ctypes,
  StdCtrls, ComCtrls, ExtCtrls, Classes, Controls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button7: TButton;
    Button8: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit2: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    OpenDialog1: TOpenDialog;
    PaintBox1: TPaintBox;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    TrackBar7: TTrackBar;
    TrackBar8: TTrackBar;
    procedure Button11Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure CheckBox5Change(Sender: TObject);
    procedure CheckBox6Change(Sender: TObject);
    procedure CheckBox7Change(Sender: TObject);
    procedure CheckBox8Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);

    procedure ClosePlayer0;
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure TrackBar5Change(Sender: TObject);
    procedure TrackBar6Change(Sender: TObject);
    procedure TrackBar7Change(Sender: TObject);
    procedure TrackBar8Change(Sender: TObject);


  private
    { private declarations }
  public

    { public declarations }
  end;

procedure uos_logo();


var
  Form1: TForm1;
  BufferBMP: TBitmap;
  PlayerIndex0, inindex1, inindex2, inindex3, inindex4, inindex5, inindex6, inindex7, inindex8, channels : cardinal;


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ClosePlayer0;
begin
  button16.Enabled := False;
  button15.Enabled := False;
  button3.Enabled := false;
  button14.Enabled := false;
  button2.Enabled := true;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
   if (button14.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex0, InIndex1, TrackBar1.position / 100,
      TrackBar1.position / 100, True);
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
    if (button14.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex0, InIndex2, TrackBar2.position / 100,
      TrackBar2.position / 100, True);

end;

procedure TForm1.TrackBar3Change(Sender: TObject);
begin
    if (button14.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex0, InIndex3, TrackBar3.position / 100,
      TrackBar3.position / 100, True);

end;

procedure TForm1.TrackBar4Change(Sender: TObject);
begin
    if (button14.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex0, InIndex4, TrackBar4.position / 100,
      TrackBar4.position / 100, True);
end;

procedure TForm1.TrackBar5Change(Sender: TObject);
begin
   if (button14.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex0, InIndex8, TrackBar5.position / 100,
      TrackBar5.position / 100, True);

end;

procedure TForm1.TrackBar6Change(Sender: TObject);
begin
   if (button14.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex0, InIndex5, TrackBar6.position / 100,
      TrackBar6.position / 100, True);

end;

procedure TForm1.TrackBar7Change(Sender: TObject);
begin
   if (button14.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex0, InIndex6, TrackBar7.position / 100,
      TrackBar7.position / 100, True);

end;

procedure TForm1.TrackBar8Change(Sender: TObject);
begin
   if (button14.Enabled = False) then
    uos_InputSetDSPVolume(PlayerIndex0, InIndex7, TrackBar8.position / 100,
      TrackBar8.position / 100, True);

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
   {$else}
  Edit1.Text := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
  Edit2.Text := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
   {$endif}
  {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  Edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  Edit2.Text := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
           {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  Edit1.Text := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  Edit2.Text := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
   {$else}
  Edit1.Text := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
  Edit2.Text := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
 {$endif}
    {$ENDIF}

{$IFDEF freebsd}
    {$if defined(cpu64)}
   Edit1.Text := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
   Edit2.Text := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
  {$else}
  Edit1.Text := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
  Edit2.Text := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
  {$endif}
    {$ENDIF}


  opendialog1.Initialdir := application.Location + 'sound';

  Edit4.Text := application.Location + 'sound' + directoryseparator + 'test.wav';
  Edit5.Text := application.Location + 'sound' + directoryseparator + 'test.ogg';
  Edit6.Text := application.Location + 'sound' + directoryseparator + 'test.wav';
  Edit7.Text := application.Location + 'sound' + directoryseparator + 'test.flac';
  Edit8.Text := application.Location + 'sound' + directoryseparator + 'test.ogg';
  Edit9.Text := application.Location + 'sound' + directoryseparator + 'test.flac';
  Edit10.Text := application.Location + 'sound' + directoryseparator + 'test.wav';
  Edit11.Text := application.Location + 'sound' + directoryseparator + 'test.ogg';

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

   if uos_LoadLib(Pchar(edit1.Text), pchar(edit2.Text), nil, nil, nil, nil) = 0 then
  begin
    form1.hide;
    form1.Position := podefault;
    button1.Caption := 'PortAudio and SndFile libraries are loaded...';
    button1.Enabled := False;
    edit1.ReadOnly := True;
    edit2.ReadOnly := True;
    form1.Height := 478;
    form1.Position := poScreenCenter;
    button2.click;
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

procedure TForm1.Button11Click(Sender: TObject);
begin
   if opendialog1.Execute then
    edit10.Text := opendialog1.FileName;
end;

procedure TForm1.Button17Click(Sender: TObject);
begin
   if opendialog1.Execute then
    edit11.Text := opendialog1.FileName;
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit6.Text := opendialog1.FileName;
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit7.Text := opendialog1.FileName;
end;

procedure TForm1.Button14Click(Sender: TObject);
begin

  button15.Enabled := True;
  button3.Enabled := True;
  button14.Enabled := false;
  button16.Enabled := false;
  button2.Enabled := false;
  
  // set the volume from the sliders.
  TrackBar1Change(self);
  TrackBar2Change(self);
   TrackBar3Change(self);
    TrackBar4Change(self);
     TrackBar5Change(self);
      TrackBar6Change(self);
       TrackBar7Change(self);
        TrackBar8Change(self);
        
  
  uos_PlayNoFree(PlayerIndex0);
  ////// Ok let start it

end;

procedure TForm1.Button15Click(Sender: TObject);
begin
  uos_Pause(PlayerIndex0);
  button15.Enabled := False;
  button16.Enabled := true;

end;


procedure TForm1.Button16Click(Sender: TObject);
begin
  uos_RePlay(PlayerIndex0);
  button16.Enabled := False;
  button15.Enabled := True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   PlayerIndex0 := 0;
   
   channels := 2 ; // (stereo output)

 uos_CreatePlayer(PlayerIndex0);

 inindex1 := uos_AddFromFile(PlayerIndex0, pchar(Edit4.Text), -1, 0, 1024);
 inindex2 := uos_AddFromFile(PlayerIndex0, pchar(Edit5.Text), -1, 0, 1024);
 inindex3 := uos_AddFromFile(PlayerIndex0, pchar(Edit6.Text), -1, 0, 1024);
 inindex4 := uos_AddFromFile(PlayerIndex0, pchar(Edit7.Text), -1, 0, 1024);
 inindex5 := uos_AddFromFile(PlayerIndex0, pchar(Edit8.Text), -1, 0, 1024);
 inindex6 := uos_AddFromFile(PlayerIndex0, pchar(Edit9.Text), -1, 0, 1024);
 inindex7 := uos_AddFromFile(PlayerIndex0, pchar(Edit10.Text), -1, 0, 1024);
 inindex8 := uos_AddFromFile(PlayerIndex0, pchar(Edit11.Text), -1, 0, 1024);
  //// add input from audio file with custom parameters
  ////////// FileName : filename of audio file
  //////////// PlayerIndex : Index of a existing Player
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Input Index in array

 uos_AddFromEndlessMuted(PlayerIndex0, channels, 1024) ;
 // this for a dummy endless input, must be last input

  uos_InputAddDSPVolume(PlayerIndex0, InIndex1, 1, 1);
  uos_InputAddDSPVolume(PlayerIndex0, InIndex2, 1, 1);
  uos_InputAddDSPVolume(PlayerIndex0, InIndex3, 1, 1);
  uos_InputAddDSPVolume(PlayerIndex0, InIndex4, 1, 1);
  uos_InputAddDSPVolume(PlayerIndex0, InIndex5, 1, 1);
  uos_InputAddDSPVolume(PlayerIndex0, InIndex6, 1, 1);
  uos_InputAddDSPVolume(PlayerIndex0, InIndex7, 1, 1);
  uos_InputAddDSPVolume(PlayerIndex0, InIndex8, 1, 1);
    ///// DSP Volume changer
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index : InputIndex of a existing input
    ////////// VolLeft : Left volume  ( from 0 to 1 => gain > 1 )
    ////////// VolRight : Right volume

  uos_AddIntoDevOut(PlayerIndex0, -1, -1, -1, -1, 0, 1024);
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
  
  CheckBox1Change(Sender);
  CheckBox2Change(Sender);
  CheckBox3Change(Sender);
  CheckBox4Change(Sender);
  CheckBox5Change(Sender);
  CheckBox6Change(Sender);
  CheckBox7Change(Sender);
  CheckBox8Change(Sender);
 
  /////// procedure to execute when stream is terminated
    uos_EndProc(PlayerIndex0, @ClosePlayer0);
  ///// Assign the procedure of object to execute at end
  //////////// PlayerIndex : Index of a existing Player
  //////////// ClosePlayer1 : procedure of object to execute inside the loop

   application.ProcessMessages;
   
   button14.Enabled := true;
end;


procedure TForm1.Button3Click(Sender: TObject);
begin
  uos_Stop(PlayerIndex0);
  sleep(100);
  button2.Enabled:=true;
  button3.Enabled:=false;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit4.Text := opendialog1.FileName;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
   if opendialog1.Execute then
    edit8.Text := opendialog1.FileName;
end;


procedure TForm1.Button7Click(Sender: TObject);
begin
  if opendialog1.Execute then
    edit5.Text := opendialog1.FileName;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
   if opendialog1.Execute then
    edit9.Text := opendialog1.FileName;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
    uos_InputSetEnable(PlayerIndex0, InIndex1, checkbox1.checked);
end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin
   uos_InputSetEnable(PlayerIndex0, InIndex2, checkbox2.checked);
end;

procedure TForm1.CheckBox3Change(Sender: TObject);
begin
   uos_InputSetEnable(PlayerIndex0, InIndex5, checkbox3.checked);
end;

procedure TForm1.CheckBox4Change(Sender: TObject);
begin
   uos_InputSetEnable(PlayerIndex0, InIndex6, checkbox4.checked);
end;

procedure TForm1.CheckBox5Change(Sender: TObject);
begin
   uos_InputSetEnable(PlayerIndex0, InIndex3, checkbox5.checked);
end;

procedure TForm1.CheckBox6Change(Sender: TObject);
begin
    uos_InputSetEnable(PlayerIndex0, InIndex4, checkbox6.checked);
end;

procedure TForm1.CheckBox7Change(Sender: TObject);
begin
   uos_InputSetEnable(PlayerIndex0, InIndex7, checkbox7.checked);
end;

procedure TForm1.CheckBox8Change(Sender: TObject);
begin
   uos_InputSetEnable(PlayerIndex0, InIndex8, checkbox8.checked);
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
  form1.Height := 148;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
    uos_free;
end;

end.
