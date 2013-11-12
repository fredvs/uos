program simpleplayer_fpGUI;

{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads,
  cwstring, {$ENDIF} {$ENDIF}
  SysUtils,
  uos,
  ctypes,
  Math,
  Classes,
  fpg_button,
  fpg_widget,
  fpg_label,
  fpg_Editbtn,
  fpg_RadioButton,
  fpg_trackbar,
  fpg_CheckBox,
  fpg_base,
  fpg_main,
  fpg_form { you can add units after this };

type

  TSimpleplayer = class(TfpgForm)
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
    Labelmpg: TfpgLabel;
    FilenameEdit3: TfpgFileNameEdit;
    Label1: TfpgLabel;
    Llength: TfpgLabel;
    btnpause: TfpgButton;
    btnresume: TfpgButton;
    CheckBox1: TfpgCheckBox;
    RadioButton1: TfpgRadioButton;
    RadioButton2: TfpgRadioButton;
    RadioButton3: TfpgRadioButton;
    Label2: TfpgLabel;
    TrackBar1: TfpgTrackBar;
    TrackBar2: TfpgTrackBar;
    TrackBar3: TfpgTrackBar;
    Label3: TfpgLabel;
    Label4: TfpgLabel;
    Label5: TfpgLabel;

    {@VFD_HEAD_END: Simpleplayer}
  public
    procedure AfterCreate; override;
    // constructor Create(AOwner: TComponent);
    procedure btnLoadClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnResumeClick(Sender: TObject);

    procedure btnTrackOnClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; const pos: TPoint);
    procedure btnTrackOffClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; const pos: TPoint);
    procedure CustomMsgReceived(var msg: TfpgMessageRec); message MSG_CUSTOM1;
    procedure ClosePlayer1;
    procedure ShowPosition;
    procedure changecheck(Sender: TObject);
    procedure VolumeChange(Sender: TObject; pos: integer);
  end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var
  Init: TUOS_Init;
  Player1: TUOS_Player;
  ordir, opath: string;
  Out1Index, In1Index, DSP1Index, DSP2Index: integer;

  procedure TSimpleplayer.btnTrackOnClick(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; const pos: TPoint);
  begin
    TrackBar1.Tag := 1;
  end;

  procedure TSimpleplayer.btnTrackoffClick(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; const pos: TPoint);
  begin
    Player1.Seek(In1Index, TrackBar1.position);
    TrackBar1.Tag := 0;
  end;

  procedure TSimpleplayer.btnResumeClick(Sender: TObject);
  begin
    Player1.RePlay;
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := True;
    btnresume.Enabled := False;
  end;

  procedure TSimpleplayer.btnPauseClick(Sender: TObject);
  begin
    Player1.Pause;
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := False;
    btnresume.Enabled := True;
  end;

  procedure TSimpleplayer.changecheck(Sender: TObject);
  begin
    if assigned(Player1) and (btnstart.Enabled = False) then
      Player1.SetDSPIn(In1Index, DSP2Index, checkbox1.Checked);
  end;

  procedure TSimpleplayer.VolumeChange(Sender: TObject; pos: integer);
  begin
    if assigned(Player1) and (btnstart.Enabled = False) then
      Player1.SetDSPVolumeIn(In1Index, DSP1Index, (100 - TrackBar2.position) / 100,
        (100 - TrackBar3.position) / 100, True);
  end;


  procedure TSimpleplayer.btnCloseClick(Sender: TObject);
  begin
    if assigned(Player1) and (btnstart.Enabled = False) then
    begin
      player1.stop;
      sleep(100);
    end;
    if btnLoad.Enabled = False then
      Init.UnloadLib();
  end;

  procedure TSimpleplayer.btnLoadClick(Sender: TObject);
  var
    str: string;
  begin
    Init := TUOS_Init.Create;   //// Create Iibraries Loader-Init

    Init.PA_FileName := FilenameEdit1.FileName;
    Init.MP_FileName := FilenameEdit3.FileName;
    Init.SF_FileName := FilenameEdit2.FileName;
    Init.Flag := LoadAll;

    if Init.LoadLib = 0 then
    begin
      hide;
      Height := 305;
      btnStart.Enabled := True;
      btnLoad.Enabled := False;
      FilenameEdit1.ReadOnly := True;
      FilenameEdit2.ReadOnly := True;
      FilenameEdit3.ReadOnly := True;
      UpdateWindowPosition;
      btnLoad.Text := 'PortAudio, SndFile and Mpg123 libraries are loaded...';
      WindowPosition := wpScreenCenter;
      Show;
    end;
  end;

  procedure TSimpleplayer.ClosePlayer1;
  begin
    radiobutton1.Enabled := True;
    radiobutton2.Enabled := True;
    radiobutton3.Enabled := True;

    btnStart.Enabled := True;
    btnStop.Enabled := False;
    btnPause.Enabled := False;
    btnresume.Enabled := False;
    trackbar1.Position := 0;
    lposition.Text := '00:00:00.000';
  end;

  procedure TSimpleplayer.btnStopClick(Sender: TObject);
  begin
    player1.Stop;
    closeplayer1;
  end;

  function DSPReverseBefore(Data: TUOS_Data; fft: TUOS_FFT): TArFloat;
  begin
    if Data.position > Data.OutFrames div Data.Channels then
      Player1.Seek(In1Index, Data.position - (Data.OutFrames div Data.Channels));
  end;

  function DSPReverseAfter(Data: TUOS_Data; fft: TUOS_FFT): TArFloat;
  var
    x: integer;
    arfl: TArFloat;
  begin
    for x := 0 to ((Data.OutFrames div Data.Channels)) do
      if odd(x) then
        arfl[x] := Data.Buffer[(Data.OutFrames div Data.Channels) - x - 1]
      else
        arfl[x] := Data.Buffer[(Data.OutFrames div Data.Channels) - x + 1];
    Result := arfl;
  end;

  procedure TSimpleplayer.btnStartClick(Sender: TObject);
  var
    samformat: shortint;
    temptime: ttime;
    ho, mi, se, ms: word;
  begin

    if radiobutton1.Checked = True then
      samformat := 0;
    if radiobutton2.Checked = True then
      samformat := 1;
    if radiobutton3.Checked = True then
      samformat := 2;

    Player1 := TUOS_Player.Create(True, self);     //// Create the player

    // Out1Index := Player1.AddIntoDevOut ;    //// add a Output into device with default parameters
    Out1Index := Player1.AddIntoDevOut(-1, -1, -1, -1, samformat);
    //// add a Output into device with custom parameters
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)

    // In1Index := Player1.AddFromFile(Edit4.Text);    //// add input from audio file with default parameters
    In1Index := Player1.AddFromFile(filenameEdit4.filename, -1, samformat);
    //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output

    Player1.StreamIn[In1Index].LoopProc := @ShowPosition;
    /////// procedure to execute inside the loop

    DSP1Index := Player1.AddDSPVolumeIn(In1Index, 1, 1);  ///// DSP Volume changer
    ////////// In1Index : InputIndex of a existing input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    //  result : -1 nothing created, otherwise index of DSPIn in array

    Player1.SetDSPVolumeIn(In1Index, DSP1Index, (100 - TrackBar2.position) / 100,
      (100 - TrackBar3.position) / 100, True); /// Set volume
    ////////// In1Index : InputIndex of a existing Input
    ////////// DSPIndex : DSPIndex of a existing DSP
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled

    DSP2Index := Player1.AddDSPIn(In1Index, @DSPReverseBefore, @DSPReverseAfter, nil);
    ///// add a DSP procedure for input Reverse
    ////////// In1Index: InputIndex of existing input
    ////////// BeforeProc : procedure to do before the buffer is filled
    ////////// AfterProc : procedure to do after the buffer is filled
    ////////// LoopProc : external procedure to do after the buffer is filled

    Player1.SetDSPIn(In1Index, DSP2Index, checkbox1.Checked);
    //// enable reverse to checkbox state;

    trackbar1.Max := Player1.InputLength(In1Index); ////// Length of Input in samples

    temptime := Player1.InputLengthTime(In1Index);  ////// Length of input in time

    DecodeTime(temptime, ho, mi, se, ms);

    llength.Text := format('%d:%d:%d.%d', [ho, mi, se, ms]);

    Player1.EndProc := @ClosePlayer1;
    /////// procedure to execute when stream is terminated

    TrackBar1.position := 0;
    trackbar1.Enabled := True;
    CheckBox1.Enabled := True;
    // radiogroup1.Enabled:=false;

    // application.ProcessMessages;
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnpause.Enabled := True;
    btnresume.Enabled := False;
    radiobutton1.Enabled := False;
    radiobutton2.Enabled := False;
    radiobutton3.Enabled := False;
    Player1.Play;  /////// everything is ready, here we are, lets play it...

  end;

  procedure TSimpleplayer.ShowPosition;
  var
    temptime: ttime;
    ho, mi, se, ms: word;
  begin
    if (TrackBar1.Tag = 0) then
    begin
      TrackBar1.Position := Player1.InputPosition(In1Index);
      temptime := Player1.InputPositionTime(In1Index);  ////// Length of input in time
      DecodeTime(temptime, ho, mi, se, ms);
      lposition.Text := format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
    end;
  end;

  procedure TSimpleplayer.CustomMsgReceived(var msg: TfpgMessageRec);
  begin
    ShowPosition;
  end;

  // constructor TSimpleplayer.Create(AOwner: TComponent);
  //begin
  // inherited Create(AOwner);
  // borderless and steals focus like a normal form
  // Include(FWindowAttributes, waBorderLess);
  // end;

  procedure TSimpleplayer.AfterCreate;
  begin
    {%region 'Auto-generated GUI code' -fold}
    {@VFD_BODY_BEGIN: Simpleplayer}
    Name := 'Simpleplayer';
    SetPosition(320, 168, 502, 371);
    WindowTitle := 'Simple player ';
    Hint := '';
    WindowPosition := wpScreenCenter;
    BackgroundColor := clmoneygreen;
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
      SetPosition(136, 0, 320, 15);
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
      SetPosition(136, 16, 356, 24);
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
      SetPosition(136, 56, 356, 24);
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
      SetPosition(132, 160, 360, 24);
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
      SetPosition(220, 272, 44, 23);
      Text := 'Play';
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
      SetPosition(404, 272, 80, 23);
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
      SetPosition(296, 225, 84, 19);
      Alignment := taCenter;
      FontDesc := '#Label1';
      Hint := '';
      Text := '00:00:00.000';
    end;

    Labelsnf := TfpgLabel.Create(self);
    with Labelsnf do
    begin
      Name := 'Labelsnf';
      SetPosition(140, 40, 316, 15);
      Alignment := taCenter;
      FontDesc := '#Label1';
      Hint := '';
      Text := 'Folder + filename of SndFile Library';
    end;

    Labelmpg := TfpgLabel.Create(self);
    with Labelmpg do
    begin
      Name := 'Labelmpg';
      SetPosition(136, 80, 316, 15);
      Alignment := taCenter;
      FontDesc := '#Label1';
      Hint := '';
      Text := 'Folder + filename of Mpg123 Library';
    end;

    FilenameEdit3 := TfpgFileNameEdit.Create(self);
    with FilenameEdit3 do
    begin
      Name := 'FilenameEdit3';
      SetPosition(136, 96, 356, 24);
      ExtraHint := '';
      FileName := '';
      Filter := '';
      InitialDir := '';
      TabOrder := 12;
    end;

    Label1 := TfpgLabel.Create(self);
    with Label1 do
    begin
      Name := 'Label1';
      SetPosition(380, 225, 12, 15);
      FontDesc := '#Label1';
      Hint := '';
      Text := '/';
    end;

    Llength := TfpgLabel.Create(self);
    with Llength do
    begin
      Name := 'Llength';
      SetPosition(392, 225, 80, 15);
      FontDesc := '#Label1';
      Hint := '';
      Text := '00:00:00.000';
    end;

    btnpause := TfpgButton.Create(self);
    with btnpause do
    begin
      Name := 'btnpause';
      SetPosition(272, 272, 52, 23);
      Text := 'Pause';
      Enabled := False;
      FontDesc := '#Label1';
      Hint := '';
      ImageName := '';
      TabOrder := 15;
      onclick := @btnPauseClick;
    end;

    btnresume := TfpgButton.Create(self);
    with btnresume do
    begin
      Name := 'btnresume';
      SetPosition(332, 272, 64, 23);
      Text := 'Resume';
      Enabled := False;
      FontDesc := '#Label1';
      Hint := '';
      ImageName := '';
      TabOrder := 16;
      onclick := @btnResumeClick;
    end;

    CheckBox1 := TfpgCheckBox.Create(self);
    with CheckBox1 do
    begin
      Name := 'CheckBox1';
      SetPosition(240, 244, 104, 19);
      FontDesc := '#Label1';
      Hint := '';
      TabOrder := 17;
      Text := 'Play Reverse';
    end;

    RadioButton1 := TfpgRadioButton.Create(self);
    with RadioButton1 do
    begin
      Name := 'RadioButton1';
      SetPosition(108, 240, 96, 19);
      Checked := True;
      FontDesc := '#Label1';
      GroupIndex := 0;
      Hint := '';
      TabOrder := 18;
      Text := 'Float 32 bit';
    end;

    RadioButton2 := TfpgRadioButton.Create(self);
    with RadioButton2 do
    begin
      Name := 'RadioButton2';
      SetPosition(108, 256, 100, 19);
      FontDesc := '#Label1';
      GroupIndex := 0;
      Hint := '';
      TabOrder := 19;
      Text := 'Int 32 bit';
    end;

    RadioButton3 := TfpgRadioButton.Create(self);
    with RadioButton3 do
    begin
      Name := 'RadioButton3';
      SetPosition(108, 274, 100, 19);
      FontDesc := '#Label1';
      GroupIndex := 0;
      Hint := '';
      TabOrder := 20;
      Text := 'Int 16 bit';
    end;

    Label2 := TfpgLabel.Create(self);
    with Label2 do
    begin
      Name := 'Label2';
      SetPosition(108, 224, 104, 15);
      FontDesc := '#Label1';
      Hint := '';
      Text := 'Sample format';
    end;

    TrackBar1 := TfpgTrackBar.Create(self);
    with TrackBar1 do
    begin
      Name := 'TrackBar1';
      SetPosition(132, 192, 356, 30);
      Hint := '';
      TabOrder := 22;
      TrackBar1.OnMouseDown := @btntrackonClick;
      TrackBar1.OnMouseUp := @btntrackoffClick;
    end;

    TrackBar2 := TfpgTrackBar.Create(self);
    with TrackBar2 do
    begin
      Name := 'TrackBar2';
      SetPosition(16, 176, 32, 98);
      Hint := '';
      Orientation := orVertical;
      TabOrder := 23;
      OnChange := @volumechange;
    end;

    TrackBar3 := TfpgTrackBar.Create(self);
    with TrackBar3 do
    begin
      Name := 'TrackBar3';
      SetPosition(60, 176, 28, 98);
      Hint := '';
      Orientation := orVertical;
      TabOrder := 24;
      OnChange := @volumechange;
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

    {@VFD_BODY_END: Simpleplayer}
    {%endregion}

    //////////////////////

    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
    checkbox1.OnChange := @changecheck;
    RadioButton1.Checked := True;
    Height := 157;
             {$IFDEF Windows}
     {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib\LibPortaudio-64.dll';
{$else}
    FilenameEdit1.FileName := ordir + 'lib\LibPortaudio-32.dll';
   {$endif}
    FilenameEdit4.FileName := ordir + 'sound\test.mp3';
 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/LibPortaudio-32.dylib';
    FilenameEdit4.FileName := opath + 'sound/test.mp3';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/LibPortaudio-64.so';
{$else}
    FilenameEdit1.FileName := ordir + 'lib/LibPortaudio-32.so';
{$endif}

    FilenameEdit4.FileName := ordir + 'sound/test.mp3';
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
 {$IFDEF Windows}
       {$if defined(cpu64)}
    FilenameEdit3.FileName := ordir + 'lib\LibMpg123-64.dll';
{$else}
    FilenameEdit3.FileName := ordir + 'lib\LibMpg123-32.dll';
{$endif}
 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    FilenameEdit3.FileName := opath + '/lib/LibMpg123-32.dylib';
            {$ENDIF}

   {$IFDEF linux}
      {$if defined(cpu64)}
    FilenameEdit3.FileName := ordir + 'lib/LibMpg123-64.so';
{$else}
    FilenameEdit3.FileName := ordir + 'lib/LibMpg123-32.so';
{$endif}

            {$ENDIF}
    FilenameEdit4.Initialdir := ordir + 'sound';
    FilenameEdit1.Initialdir := ordir + 'lib';
    FilenameEdit2.Initialdir := ordir + 'lib';
    FilenameEdit3.Initialdir := ordir + 'lib';
  end;

  procedure TSimpleplayer.UOS_logo(Sender: TObject);
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
    frm: TSimpleplayer;
  begin
    fpgApplication.Initialize;
    frm := TSimpleplayer.Create(nil);
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
