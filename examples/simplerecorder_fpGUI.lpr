program simplerecorder_fpGUI;
{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses

  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,  cwstring,
  {$ENDIF}{$ENDIF}
    SysUtils, uos, ctypes, Math ,  Classes,fpg_button, fpg_widget, fpg_label, fpg_Editbtn, fpg_RadioButton, fpg_trackbar, fpg_CheckBox, fpg_base, fpg_main, fpg_form
  { you can add units after this };

type

  TSimplerecorder = class(TfpgForm)
    procedure UOS_logo(Sender: TObject);
        private
    {@VFD_HEAD_BEGIN: Simpleplayer}
    Custom1: TfpgWidget;
    Labelport: TfpgLabel;
    btnLoad: TfpgButton;
    FilenameEdit1: TfpgFileNameEdit;
    FilenameEdit2: TfpgFileNameEdit;
    FilenameEdit4: TfpgFileNameEdit;
    btnStart: TfpgButton;
    btnStop: TfpgButton;
    lposition: TfpgLabel;
    Labelsnf: TfpgLabel;
    button4: TfpgButton;
    button5: TfpgButton;
    CheckBox1: TfpgCheckBox;
    Label2: TfpgLabel;
    TrackBar2: TfpgTrackBar;
    TrackBar3: TfpgTrackBar;
    Label3: TfpgLabel;
    Label4: TfpgLabel;
    Label5: TfpgLabel;
    CheckBox2: TfpgCheckBox;
    {@VFD_HEAD_END: Simpleplayer}
  public
    procedure AfterCreate; override;
   // constructor Create(AOwner: TComponent);
    procedure btnLoadClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
     procedure btnPlaySavedClick(Sender: TObject);
      procedure ClosePlayer1;
      procedure VolumeChange(Sender: TObject; pos : integer);
  end;

{@VFD_NEWFORM_DECL}

{@VFD_NEWFORM_IMPL}

var
  Init: TUOS_Init;
  Player1: TUOS_Player;
  ordir, opath: string;
   Out1Index, In1Index, DSP1Index, DSP2Index: integer;


procedure TSimplerecorder.btnPlaySavedClick(Sender: TObject);
 begin
   Player1 := TUOS_Player.Create(True,self);     //// Create the player

   Out1Index := Player1.AddIntoDevOut(-1, -1, -1, -1,2);   //// add a Output into device with custom parameters
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)

    In1Index := Player1.AddFromFile(filenameEdit4.filename, -1, 2);  //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output

   DSP1Index := Player1.AddDSPVolumeIn(In1Index, 1, 1) ;  ///// DSP Volume changer
     ////////// In1Index : InputIndex of a existing input
     ////////// VolLeft : Left volume
     ////////// VolRight : Right volume
      //  result : -1 nothing created, otherwise index of DSPIn in array

  Player1.SetDSPVolumeIn(In1Index, DSP1Index, (100-TrackBar2.position)/100, (100-TrackBar3.position) /100, true); /// Set volume
      ////////// In1Index : InputIndex of a existing Input
      ////////// DSPIndex : DSPIndex of a existing DSP
      ////////// VolLeft : Left volume
      ////////// VolRight : Right volume
      ////////// Enable : Enabled

      Player1.EndProc := @ClosePlayer1;  /////// procedure to execute when stream is terminated


   btnStart.Enabled := false;
   btnStop.Enabled := false;
     button4.Enabled := false;
       button5.Enabled := true;
            Player1.Play;  /////// everything is ready, here we are, lets play it...
 end;

procedure TSimplerecorder.VolumeChange(Sender: TObject; pos : integer);
 begin
   if assigned(Player1) and (btnstart.Enabled = false) then
    Player1.SetDSPVolumeIn(In1Index, DSP1Index,(100-TrackBar2.position)/100, (100-TrackBar3.position)/100, true);
 end;


procedure TSimplerecorder.btnCloseClick(Sender: TObject);
 begin
  if assigned(Player1) and (btnstart.Enabled = false) then
    begin
    player1.stop;
   sleep(100);
     end;
  if btnLoad.Enabled = False then
   Init.UnloadLib();
  end;

procedure TSimplerecorder.btnLoadClick(Sender: TObject);
var
  str : string;
 begin
      Init := TUOS_Init.Create;   //// Create Iibraries Loader-Init

   Init.PA_FileName := FilenameEdit1.FileName;
     Init.SF_FileName := FilenameEdit2.FileName;
   Init.Flag := LoadPA_SF;

   if Init.LoadLib = 0 then
   begin
    hide;
    height := 305;
    btnStart.Enabled := True;
    btnLoad.Enabled := False;
    FilenameEdit1.ReadOnly := True;
    FilenameEdit2.ReadOnly := True;

    UpdateWindowPosition;
    btnLoad.Text:='PortAudio and SndFile libraries are loaded...';
     WindowPosition := wpScreenCenter;
    Show;
   end;
 end;

 procedure TSimplerecorder.ClosePlayer1;
 begin
               btnStart.Enabled := true;
   btnStop.Enabled := false;
   button4.Enabled := true;
   button5.Enabled := false;

 end;

 procedure TSimplerecorder.btnStopClick(Sender: TObject);
 begin
   player1.Stop;
   sleep(100);
   closeplayer1;
    end;

 procedure TSimplerecorder.btnStartClick(Sender: TObject);
  var
    Out1Index, Out2Index : integer;

begin
   if (checkbox1.Checked = true) or (checkbox2.Checked = true) then begin

   Player1 := TUOS_Player.Create(True,self);     //// Create the player

    Out1Index := Player1.AddIntoFile(filenameEdit4.filename); //// add Output into wav file (save record)  with default parameters
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

  Player1.SetDSPVolumeIn(In1Index, DSP1Index, (100-TrackBar2.position)/100, (100-TrackBar3.position) /100, true); /// Set volume
      ////////// In1Index : InputIndex of a existing Input
      ////////// DSPIndex : DSPIndex of a existing DSP
      ////////// VolLeft : Left volume
      ////////// VolRight : Right volume
      ////////// Enable : Enabled

   Player1.EndProc := @ClosePlayer1;  /////// procedure to execute when stream is terminated

    CheckBox1.Enabled := True;
  // radiogroup1.Enabled:=false;

  // application.ProcessMessages;
   btnStart.Enabled := false;
   btnStop.Enabled := true;
     button5.Enabled := false;
       button4.Enabled := false;

                 Player1.Play;  /////// everything is ready, here we are, lets play it...

 end;


   end;


procedure TSimplerecorder.AfterCreate;
begin
  {%region 'Auto-generated GUI code' -fold}
  {@VFD_BODY_BEGIN: Simpleplayer}
  Name := 'Simpleplayer';
  SetPosition(392, 184, 502, 371);
  WindowTitle := 'Simple Recorder';
  Hint := '';
  WindowPosition := wpScreenCenter;
  BackgroundColor:= clmoneygreen;
  Ondestroy := @btnCloseClick;

  Custom1 := TfpgWidget.Create(self);
  with Custom1 do
  begin
    Name := 'Custom1';
    SetPosition(10, 8, 115, 115);
    OnPaint := @UOS_logo;
  end;

  Labelport := TfpgLabel.Create(self);
  with Labelport do
  begin
    Name := 'Labelport';
    SetPosition(140, 12, 320, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Folder + filename of PortAudio Library';
  end;

  btnLoad := TfpgButton.Create(self);
  with btnLoad do
  begin
    Name := 'btnLoad';
    SetPosition(16, 128, 476, 23);
    Text := 'Load that libraries';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 0;
    onclick := @btnLoadClick;
  end;

  FilenameEdit1 := TfpgFileNameEdit.Create(self);
  with FilenameEdit1 do
  begin
    Name := 'FilenameEdit1';
    SetPosition(136, 28, 356, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 3;
  end;

  FilenameEdit2 := TfpgFileNameEdit.Create(self);
  with FilenameEdit2 do
  begin
    Name := 'FilenameEdit2';
    SetPosition(136, 80, 356, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 4;
  end;

  FilenameEdit4 := TfpgFileNameEdit.Create(self);
  with FilenameEdit4 do
  begin
    Name := 'FilenameEdit4';
    SetPosition(124, 192, 364, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 5;
  end;

  btnStart := TfpgButton.Create(self);
  with btnStart do
  begin
    Name := 'btnStart';
    SetPosition(244, 232, 68, 23);
    Text := 'Start';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 6;
    onclick := @btnstartClick;
  end;

  btnStop := TfpgButton.Create(self);
  with btnStop do
  begin
    Name := 'btnStop';
    SetPosition(344, 232, 80, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 7;
    onclick := @btnStopClick;
  end;

  lposition := TfpgLabel.Create(self);
  with lposition do
  begin
    Name := 'lposition';
    SetPosition(144, 173, 312, 19);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Folder + filename of wav saved file';
  end;

  Labelsnf := TfpgLabel.Create(self);
  with Labelsnf do
  begin
    Name := 'Labelsnf';
    SetPosition(140, 64, 316, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Folder + filename of SndFile Library';
  end;

  button4 := TfpgButton.Create(self);
  with button4 do
  begin
    Name := 'button4';
    SetPosition(184, 268, 112, 23);
    Text := 'Play saved file';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 15;
    onclick := @btnPlaySavedClick;
  end;

  button5 := TfpgButton.Create(self);
  with button5 do
  begin
    Name := 'button5';
    SetPosition(324, 268, 104, 23);
    Text := 'Stop saved file';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 16;
    onclick := @btnStopClick;
  end;

  CheckBox1 := TfpgCheckBox.Create(self);
  with CheckBox1 do
  begin
    Name := 'CheckBox1';
    SetPosition(132, 224, 104, 19);
    Checked := True;
    FontDesc := '#Label1';
    Hint := '';
    TabOrder := 17;
    Text := 'Listen MIC';
  end;

  Label2 := TfpgLabel.Create(self);
  with Label2 do
  begin
    Name := 'Label2';
    SetPosition(124, 155, 356, 15);
    Alignment := taCenter;
    FontDesc := '#Label2';
    Hint := '';
    Text := 'WARNING : Use headphones or set volume to low...';
    TextColor := TfpgColor($FFFF0000);
  end;

  TrackBar2 := TfpgTrackBar.Create(self);
  with TrackBar2 do
  begin
    Name := 'TrackBar2';
    SetPosition(16, 176, 32, 98);
    Hint := '';
    Orientation := orVertical;
    TabOrder := 23;
    OnChange := @volumechange  ;
  end;

  TrackBar3 := TfpgTrackBar.Create(self);
  with TrackBar3 do
  begin
    Name := 'TrackBar3';
    SetPosition(60, 176, 28, 98);
    Hint := '';
    Orientation := orVertical;
    TabOrder := 24;
    OnChange := @volumechange  ;
  end;

  Label3 := TfpgLabel.Create(self);
  with Label3 do
  begin
    Name := 'Label3';
    SetPosition(12, 156, 84, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Volume';
  end;

  Label4 := TfpgLabel.Create(self);
  with Label4 do
  begin
    Name := 'Label4';
    SetPosition(8, 280, 40, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Left';
  end;

  Label5 := TfpgLabel.Create(self);
  with Label5 do
  begin
    Name := 'Label5';
    SetPosition(56, 280, 36, 19);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Right';
  end;

  CheckBox2 := TfpgCheckBox.Create(self);
  with CheckBox2 do
  begin
    Name := 'CheckBox2';
    SetPosition(132, 244, 100, 19);
    Checked := True;
    FontDesc := '#Label1';
    Hint := '';
    TabOrder := 22;
    Text := 'Save to file';
  end;

  {@VFD_BODY_END: Simpleplayer}
  {%endregion}

  //////////////////////

               ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
            CheckBox1.Checked:=true;
                CheckBox2.Checked:=true;
             height := 157;
             {$IFDEF Windows}
     {$if defined(cpu64)}
  FilenameEdit1.FileName := ordir + 'lib\LibPortaudio-64.dll';
{$else}
  FilenameEdit1.FileName := ordir + 'lib\LibPortaudio-32.dll';
   {$endif}
  FilenameEdit4.FileName := ordir + 'sound\testrecord.wav';
 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  FilenameEdit1.FileName := opath + '/lib/LibPortaudio-32.dylib';
  FilenameEdit4.FileName := opath + 'sound/testrecord.wav';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  FilenameEdit1.FileName := ordir + 'lib/LibPortaudio-64.so';
{$else}
  FilenameEdit1.FileName := ordir + 'lib/LibPortaudio-32.so';
{$endif}

  FilenameEdit4.FileName := ordir + 'sound/testrecord.wav';
            {$ENDIF}
  //////////////////////////////////////////////////////////////////////////

    {$IFDEF Windows}
       {$if defined(cpu64)}
  FilenameEdit2.FileName := ordir + 'lib\LibSndFile-64.dll';
{$else}
  FilenameEdit2.FileName := ordir + 'lib\LibSndFile-32.dll';
{$endif}

 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  FilenameEdit2.FileName := opath + '/lib/LibSndFile-32.dylib';
            {$ENDIF}

   {$IFDEF linux}
      {$if defined(cpu64)}
  FilenameEdit2.FileName := ordir + 'lib/LibSndFile-64.so';
{$else}
  FilenameEdit2.FileName := ordir + 'lib/LibSndFile-32.so';
{$endif}

            {$ENDIF}
  //////////////////////////////////////////////////////////////////////////

  FilenameEdit4.Initialdir := ordir + 'sound';
FilenameEdit1.Initialdir := ordir + 'lib';
FilenameEdit2.Initialdir := ordir + 'lib';

end;

procedure TSimplerecorder.UOS_logo(Sender: TObject);
var
xpos, ypos, pbwidth, pbheight: integer;
ratio: double;
begin
xpos := 0;
ypos := 0;
ratio := 1;
pbwidth := 115;
pbheight := 115;
with Custom1 do
begin
 Canvas.GradientFill(GetClientRect, clgreen, clBlack, gdVertical);
Canvas.TextColor := clWhite;
Canvas.DrawText(60, 20, 'UOS');
 end;
end;

procedure MainProc;
var
  frm: TSimplerecorder;
begin
  fpgApplication.Initialize;
  frm := TSimplerecorder.Create(nil);
  try
     frm.Show;
     fpgApplication.Run;
  finally
    frm.Free;
  end;
end;

begin
           MainProc;
end.

