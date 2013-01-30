
/////////////////// Demo how to use United Openlib of Sound ////////////////////
unit main_sr;
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
    Shape1: TShape;
    TrackBar1: TTrackBar;
    TrackBar3: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ClosePlayer1;
    procedure TrackBar1Change(Sender: TObject);
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
  Out1Index, Out2Index, In1Index, DSP1Index : integer;
  Init: TUOS_Init;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ClosePlayer1;
begin
  button2.Enabled := true;
  button3.Enabled := False;
  button5.Enabled := false;
  CheckBox1.Enabled := true;
  CheckBox2.Enabled := true;
   if CheckBox2.checked = true then Button4.Enabled := true;
 end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
   if assigned(Player1) and (Button2.Enabled = false) then
     Player1.SetDSPVolumeIn(In1Index, DSP1Index, TrackBar1.position/100, TrackBar3.position/100, true);
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
  Edit3.Text := application.Location + 'sound\testrecord.wav';
 {$ENDIF}

  {$IFDEF Darwin}
  opath := application.Location;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  edit1.Text := opath + '/lib/LibPortaudio-32.dylib';
  Edit3.Text := opath + '/sound/testrecord.wav';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  edit1.Text := application.Location + 'lib/LibPortaudio-64.so';
{$else}
  edit1.Text := application.Location + 'lib/LibPortaudio-32.so';
{$endif}
  Edit3.Text := application.Location + 'sound/testrecord.wav';
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

            
end;

//////////////////////////////////////////////////////////////////////////


procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Init := TUOS_Init.Create;   //// Create Iibraries Loader-Init

  Init.PA_FileName := edit1.Text;
  Init.SF_FileName := edit2.Text;
  Init.Flag := LoadPA_SF;

  Init.LoadLib;

  if (Init.LoadResult.PAloaderror = 0)
  and
   (Init.LoadResult.Sfloaderror = 0) 
    then

  begin
    form1.hide;
    Init.InitLib();
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
    if Init.LoadResult.PAloaderror = 1 then
      MessageDlg(edit1.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if Init.LoadResult.PAloaderror = 2 then
      MessageDlg(edit1.Text + ' do not load...', mtWarning, [mbYes], 0);
    if Init.LoadResult.SFloaderror = 1 then
      MessageDlg(edit2.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if Init.LoadResult.SFloaderror = 2 then
      MessageDlg(edit2.Text + ' do not load...', mtWarning, [mbYes], 0);
     end;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  if (checkbox1.Checked = true) or (checkbox2.Checked = true) then begin
  
   Player1 := TUOS_Player.Create(True);
   
     Out1Index := Player1.AddIntoFile(edit3.text); //// add Output into wav file (save record)  with default parameters
     // Out1Index := Player1.AddIntoFile('test.wav', -1, -1, -1);   //// add a Output into wav file (save record) with custom parameters
  //////////// Filename : name of new file for recording
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  
    if checkbox1.Checked = true then Out2Index := Player1.AddIntoDevOut ; //// add a Output into OUT device with default parameters
    // Out1Index := Player1.AddIntoDevOut(-1, -1, -1, -1,0);   //// add a Output into device with custom parameters
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  
   In1Index := Player1.AddFromDevIn;  /// add Input from mic into IN device with default parameters
       //   In1Index := Player1.AddFromDevIn(-1, -1, -1, -1, -1,0);   //// add input from mic with custom parameters
    //////////// Device ( -1 is default Input device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)

    DSP1Index := Player1.AddDSPVolumeIn(In1Index, 1, 1) ;  ///// DSP Volume changer                               
     ////////// In1Index : InputIndex of a existing input
     ////////// VolLeft : Left volume
     ////////// VolRight : Right volume
      //  result : -1 nothing created, otherwise index of DSPIn in array    
        
     Player1.SetDSPVolumeIn(In1Index, DSP1Index, TrackBar1.position/100, TrackBar3.position/100, true); /// Set volume 
  
  Player1.EndProc := @ClosePlayer1;  /////// procedure to execute when stream is terminated

  Player1.Play;  /////// everything is ready to play...
    
  Button2.Enabled := false;
  Button3.Enabled := True;
  Button4.Enabled := false;
  CheckBox1.Enabled := false;
  CheckBox2.Enabled := false;
end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Player1.Stop;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
 Player1 := TUOS_Player.Create(True);
     
   Out1Index := Player1.AddIntoDevOut ; //// add a Output into OUT device with default parameters
    // Out1Index := Player1.AddIntoDevOut(-1, -1, -1, -1,0);   //// add a Output into device with custom parameters
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  
   In1Index := Player1.AddFromFile(Edit3.Text);    //// add input from audio file with default parameters 
    // In1Index := Player1.AddFromFile(Edit3.Text, -1, 0);  //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
 
   DSP1Index := Player1.AddDSPVolumeIn(In1Index, 1, 1) ;  ///// DSP Volume changer                               
     ////////// In1Index : InputIndex of a existing input
     ////////// VolLeft : Left volume
     ////////// VolRight : Right volume
      //  result : -1 nothing created, otherwise index of DSPIn in array    
        
     Player1.SetDSPVolumeIn(In1Index, DSP1Index, TrackBar1.position/100, TrackBar3.position/100, true); /// Set volume 

    Player1.EndProc := @ClosePlayer1;  /////// procedure to execute when stream is terminated  
    
    Player1.Play;  /////// everything is ready to play...
   button4.Enabled:=false; 
   button5.Enabled:=true; 
   button2.Enabled:=false; 
   CheckBox1.Enabled := false;
   CheckBox2.Enabled := false;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
if checkbox1.Checked = true then label7.show else label7.hide;
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
  if assigned(Player1) and (Button2.Enabled = false) then
    begin
    Button3.Click;
    sleep(500) ;
    end;
   if button1.Enabled = false then Init.UnloadLib();
    sleep(300) ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Height := 150;
end;

end.
