program filterplayer_fpGUI;

{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads,
  cwstring, {$ENDIF} {$ENDIF}
  SysUtils,
  uos_flat,

  ctypes,
  Math,
  Classes,
  fpg_button,
  fpg_edit,
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

  TFilterplayer = class(TfpgForm)
    procedure uos_logo(Sender: TObject);
  private
    {@VFD_HEAD_BEGIN: Filterplayer}
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
    RadioButton4: TfpgRadioButton;
    Edit1: TfpgEdit;
    Edit2: TfpgEdit;
    CheckBox2: TfpgCheckBox;
    {@VFD_HEAD_END: Filterplayer}
  public
    procedure AfterCreate; override;
    procedure btnLoadClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnResumeClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject; tmp: integer);
    procedure TrackBar2Change(Sender: TObject; tmp: integer);
    procedure TrackBar1Change(Sender: TObject; tmp: integer);
    procedure RadioButton1Change(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure TrackBar3proc;
    procedure TrackBar2proc;
    procedure TrackBar1proc;

    procedure ClosePlayer1;

  end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var

  PlayerIndex1: cardinal;
  ordir, opath: string;
  Out1Index, In1Index, EQIndex1, EQIndex2, EQIndex3, FTIndex1: integer;


  procedure TFilterplayer.btnResumeClick(Sender: TObject);
  begin
    uos_RePlay(PlayerIndex1);
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := True;
    btnresume.Enabled := False;
  end;

  procedure TFilterplayer.btnPauseClick(Sender: TObject);
  begin
    uos_Pause(PlayerIndex1);
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := False;
    btnresume.Enabled := True;
  end;


  procedure TFilterplayer.btnCloseClick(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
    begin
      uos_stop(PlayerIndex1);
      sleep(100);
    end;
    if btnLoad.Enabled = False then
      uos_UnloadLib();
  end;

  procedure TFilterplayer.btnLoadClick(Sender: TObject);
  var
    str: string;
  begin
      // Load the libraries
    // function uos_LoadLib(PortAudioFileName: PChar; SndFileFileName: PChar; Mpg123FileName: PChar) : integer;
  if uos_LoadLib(Pchar(FilenameEdit1.FileName), Pchar(FilenameEdit2.FileName), Pchar(FilenameEdit3.FileName), nil, nil) = 0 then
    begin
      hide;
      Height := 345;
      btnStart.Enabled := True;
      btnLoad.Enabled := False;
      FilenameEdit1.ReadOnly := True;
      FilenameEdit2.ReadOnly := True;
      FilenameEdit3.ReadOnly := True;
      UpdateWindowPosition;
      btnLoad.Text := 'PortAudio, SndFile and Mpg123 libraries are loaded...';
      WindowPosition := wpScreenCenter;
       fpgapplication.ProcessMessages;
      sleep(500);
      Show;
    end;
  end;

  procedure TFilterplayer.ClosePlayer1;
  begin
    radiobutton1.Enabled := True;
    radiobutton2.Enabled := True;
    radiobutton3.Enabled := True;
    radiobutton4.Enabled := True;
    btnStart.Enabled := True;
    btnStop.Enabled := False;
    btnPause.Enabled := False;
    btnresume.Enabled := False;
   end;

  procedure TFilterplayer.btnStopClick(Sender: TObject);
  begin
    uos_Stop(PlayerIndex1);
    closeplayer1;
  end;

  procedure TFilterplayer.btnStartClick(Sender: TObject);
  var
    EqGain: double;
    typfilt: shortint;
  begin

   PlayerIndex1 := 0 ; // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
                       // If PlayerIndex exists already, it will be overwritten...

 {$IF (FPC_FULLVERSION>=20701) or DEFINED(LCL) or DEFINED(ConsoleApp) or DEFINED(Library) or DEFINED(Windows)}
       uos_CreatePlayer(PlayerIndex1);
     {$else}
       uos_CreatePlayer(PlayerIndex1,sender);
    {$endif}


  //// Create the player.
  //// PlayerIndex : from 0 to what your computer can do !
  //// If PlayerIndex exists already, it will be overwriten...
     In1Index := uos_AddFromFile(PlayerIndex1, pchar(filenameEdit4.filename), -1, 0, -1);
    //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    //////////// PlayerIndex : Index of a existing Player
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
    //////////// FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Input Index in array

   Out1Index :=uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, In1Index), -1, 0, -1);
  //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (= 65536)

       EQIndex1 := uos_AddFilterIn(PlayerIndex1, In1Index, 1, 1000, 1, 1, True, nil);
      //////////// PlayerIndex : Index of a existing Player
      ////////// In1Index : InputIndex of a existing Input
      ////////// LowFrequency : Lowest frequency of filter
      ////////// HighFrequency : Highest frequency of filter
      ////////// Gain : gain to apply to filter ( 1 = no gain )
      ////////// TypeFilter: Type of filter : default = -1 = fBandSelect (fBandAll = 0, fBandSelect = 1, fBandReject = 2
      /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
      ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
      ////////// LoopProc : External procedure to execute after filter
      //  result : -1 nothing created, otherwise index of DSPIn in array

      EQIndex2 := uos_AddFilterIn(PlayerIndex1, In1Index, 1000, 8000, 1, 1, True, nil);
      EQIndex3 := uos_AddFilterIn(PlayerIndex1, In1Index, 8000, 22000, 1, 1, True, nil);

    if radiobutton1.Checked = True then
      typfilt := 2;
    if radiobutton2.Checked = True then
      typfilt := 3;
    if radiobutton3.Checked = True then
      typfilt := 4;
    if radiobutton4.Checked = True then
      typfilt := 5;

    FTIndex1 := uos_AddFilterIn(PlayerIndex1, In1Index, StrToInt(edit2.Text), StrToInt(edit1.Text),
    1, typfilt, True, nil);

    uos_SetFilterIn(PlayerIndex1, In1Index, FTIndex1, -1, -1, -1, -1, True, checkbox2.Checked, nil);
  //////////// PlayerIndex : Index of a existing Player
  ////////// InputIndex : InputIndex of a existing Input
  ////////// DSPInIndex : DSPInIndex of existing DSPIn
  ////////// LowFrequency : Lowest frequency of filter ( default = -1 : current LowFrequency )
  ////////// HighFrequency : Highest frequency of filter ( default = -1 : current HighFrequency )
  ////////// Gain   : Gain to apply ( -1 = current gain)  ( 0 = silence, 1 = no gain, < 1 = less gain, > 1 = more gain)
  ////////// TypeFilter: Type of filter : ( default = -1 = current filter ) (fBandAll = 0, fBandSelect = 1, fBandReject = 2
  /////////////////////////// fBandPass = 3, fHighPass = 4, fLowPass = 5)
  ////////// AlsoBuf : The filter alter buffer aswell ( otherwise, only result is filled in fft.data )
  ////////// Enable :  Filter enabled

  uos_EndProc(PlayerIndex1, @ClosePlayer1);
   ///// Assign the procedure of object to execute at end
   //////////// PlayerIndex : Index of a existing Player
   //////////// ClosePlayer1 : procedure of object to execute inside the loop
  /////// procedure to execute when stream is terminated

  uos_Play(PlayerIndex1);  /////// everything is ready, here we are, lets play it...

  btnStart.Enabled := False;
    btnPause.Enabled := True;
    btnResume.Enabled := False;
    btnStop.Enabled := True;
    TrackBar1proc;
    TrackBar2proc;
    TrackBar3proc;

  end;

  procedure TFilterplayer.CheckBox1Change(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
    begin
      uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex1, -1, -1, -1, -1, True, checkbox1.Checked, nil);
      uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex2, -1, -1, -1, -1, True, checkbox1.Checked, nil);
      uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex3, -1, -1, -1, -1, True, checkbox1.Checked, nil);
    end;
  end;

  procedure TFilterplayer.RadioButton1Change(Sender: TObject);
  var
    typfilt: shortint;
  begin
    if radiobutton1.Checked = True then
      typfilt := 2;
    if radiobutton2.Checked = True then
      typfilt := 3;
    if radiobutton3.Checked = True then
      typfilt := 4;
    if radiobutton4.Checked = True then
      typfilt := 5;
    if (btnstart.Enabled = False) then
      uos_SetFilterIn(PlayerIndex1, In1Index, FTIndex1, StrToInt(edit2.Text), StrToInt(edit1.Text),
        1, typfilt, True, checkbox2.Checked, nil);

  end;

  procedure TFilterplayer.TrackBar3proc;
  var
    gain: double;
  begin
    if (TrackBar3.Position) = 100 then
      gain := 1
    else
    if (200 - TrackBar3.Position) > 100 then
      gain := 1 + ((200 - TrackBar3.Position) / 25)
    else
      gain := (TrackBar3.Position) / 100;
    if  (btnStart.Enabled = False) then
    uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex3, -1, -1, Gain, -1, True,
        checkbox1.Checked, nil);
  end;

  procedure TFilterplayer.TrackBar2proc;
  var
    gain: double;
  begin
    if (TrackBar2.Position) = 100 then
      gain := 1
    else
    if (200 - TrackBar2.Position) > 100 then
      gain := 1 + ((200 - TrackBar2.Position) / 25)
    else
      gain := (TrackBar2.Position) / 100;
    if (btnStart.Enabled = False) then
     uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex2, -1, -1, Gain, -1, True,
        checkbox1.Checked, nil);
  end;

  procedure TFilterplayer.TrackBar1proc;
  var
    gain: double;
  begin
    if (TrackBar1.Position) = 100 then
      gain := 1
    else
    if (200 - TrackBar1.Position) > 100 then
      gain := 1 + ((200 - TrackBar1.Position) / 25)
    else
      gain := (TrackBar1.Position) / 100;
    if (btnStart.Enabled = False) then
     uos_SetFilterIn(PlayerIndex1, In1Index, EQIndex1, -1, -1, Gain, -1, True,
        checkbox1.Checked, nil);
  end;

  procedure TFilterplayer.TrackBar1Change(Sender: TObject; tmp: integer);
  begin
    TrackBar1proc;
  end;


  procedure TFilterplayer.TrackBar2Change(Sender: TObject; tmp: integer);
  begin
    Trackbar2proc;
  end;

  procedure TFilterplayer.TrackBar3Change(Sender: TObject; tmp: integer);
  begin
    trackbar3proc;
  end;


  procedure TFilterplayer.AfterCreate;
   begin
    {%region 'Auto-generated GUI code' -fold}

    {@VFD_BODY_BEGIN: Filterplayer}
  Name := 'Filterplayer';
  SetPosition(419, 72, 502, 371);
  WindowTitle := 'Filter player ';
  Hint := '';
  BackGroundColor := $80000001;
  WindowPosition := wpScreenCenter;
  Ondestroy := @btnCloseClick;

  Custom1 := TfpgWidget.Create(self);
  with Custom1 do
  begin
    Name := 'Custom1';
    SetPosition(10, 8, 115, 115);
    OnPaint := @uos_logo;
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
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 0;
    Text := 'Load that libraries';
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
    SetPosition(16, 280, 472, 24);
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
    SetPosition(104, 312, 44, 23);
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 6;
    Text := 'Play';
    onclick := @btnstartClick;
  end;

  btnStop := TfpgButton.Create(self);
  with btnStop do
  begin
    Name := 'btnStop';
    SetPosition(316, 312, 80, 23);
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 7;
    Text := 'Stop';
    onclick := @btnStopClick;
  end;

  lposition := TfpgLabel.Create(self);
  with lposition do
  begin
    Name := 'lposition';
    SetPosition(372, 157, 104, 19);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'High Frequency';
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

  Llength := TfpgLabel.Create(self);
  with Llength do
  begin
    Name := 'Llength';
    SetPosition(376, 201, 104, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Low Frequency';
  end;

  btnpause := TfpgButton.Create(self);
  with btnpause do
  begin
    Name := 'btnpause';
    SetPosition(164, 312, 52, 23);
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 15;
    Text := 'Pause';
    onclick := @btnPauseClick;
  end;

  btnresume := TfpgButton.Create(self);
  with btnresume do
  begin
    Name := 'btnresume';
    SetPosition(232, 312, 64, 23);
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 16;
    Text := 'Resume';
    onclick := @btnResumeClick;
  end;

  CheckBox1 := TfpgCheckBox.Create(self);
  with CheckBox1 do
  begin
    Name := 'CheckBox1';
    SetPosition(32, 252, 156, 19);
    Checked := True;
    FontDesc := '#Label1';
    Hint := '';
    TabOrder := 17;
    Text := 'Enable Equalizer';
    onchange := @CheckBox1Change;
  end;

  RadioButton1 := TfpgRadioButton.Create(self);
  with RadioButton1 do
  begin
    Name := 'RadioButton1';
    SetPosition(216, 176, 96, 19);
    Checked := True;
    FontDesc := '#Label1';
    GroupIndex := 0;
    Hint := '';
    TabOrder := 18;
    Text := 'BandReject';
    onchange := @RadioButton1Change;
  end;

  RadioButton2 := TfpgRadioButton.Create(self);
  with RadioButton2 do
  begin
    Name := 'RadioButton2';
    SetPosition(216, 200, 100, 19);
    FontDesc := '#Label1';
    GroupIndex := 0;
    Hint := '';
    TabOrder := 19;
    Text := 'BandPass';
    onchange := @RadioButton1Change;
  end;

  RadioButton3 := TfpgRadioButton.Create(self);
  with RadioButton3 do
  begin
    Name := 'RadioButton3';
    SetPosition(216, 222, 100, 19);
    FontDesc := '#Label1';
    GroupIndex := 0;
    Hint := '';
    TabOrder := 20;
    Text := 'HighPass';
    onchange := @RadioButton1Change;
  end;

  Label2 := TfpgLabel.Create(self);
  with Label2 do
  begin
    Name := 'Label2';
    SetPosition(220, 160, 72, 19);
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Filters';
  end;

  TrackBar1 := TfpgTrackBar.Create(self);
  with TrackBar1 do
  begin
    Name := 'TrackBar1';
    SetPosition(24, 160, 36, 74);
    Hint := '';
    Max := 200;
    Orientation := orVertical;
    Position := 100;
     TabOrder := 22;
    onchange := @TrackBar1Change;
  end;

  TrackBar2 := TfpgTrackBar.Create(self);
  with TrackBar2 do
  begin
    Name := 'TrackBar2';
    SetPosition(80, 160, 32, 74);
    Hint := '';
    Max := 200;
    Orientation := orVertical;
    Position := 100;
    TabOrder := 23;
    onchange := @TrackBar2Change;
  end;

  TrackBar3 := TfpgTrackBar.Create(self);
  with TrackBar3 do
  begin
    Name := 'TrackBar3';
    SetPosition(136, 160, 28, 74);
    Hint := '';
    Max := 200;
    Orientation := orVertical;
    Position := 100;
    TabOrder := 24;
    onchange := @TrackBar3Change;
  end;

  Label3 := TfpgLabel.Create(self);
  with Label3 do
  begin
    Name := 'Label3';
    SetPosition(68, 232, 52, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Medium';
  end;

  Label4 := TfpgLabel.Create(self);
  with Label4 do
  begin
    Name := 'Label4';
    SetPosition(20, 232, 40, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Low';
  end;

  Label5 := TfpgLabel.Create(self);
  with Label5 do
  begin
    Name := 'Label5';
    SetPosition(128, 232, 36, 19);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'High';
  end;

  RadioButton4 := TfpgRadioButton.Create(self);
  with RadioButton4 do
  begin
    Name := 'RadioButton4';
    SetPosition(216, 244, 92, 19);
    FontDesc := '#Label1';
    GroupIndex := 0;
    Hint := '';
    TabOrder := 28;
    Text := 'LowPass';
    onchange := @RadioButton1Change;
  end;

  Edit1 := TfpgEdit.Create(self);
  with Edit1 do
  begin
    Name := 'Edit1';
    SetPosition(368, 172, 116, 24);
    ExtraHint := '';
    FontDesc := '#Edit1';
    Hint := '';
    TabOrder := 29;
    Text := '15000';
  end;

  Edit2 := TfpgEdit.Create(self);
  with Edit2 do
  begin
    Name := 'Edit2';
    SetPosition(368, 216, 116, 24);
    ExtraHint := '';
    FontDesc := '#Edit1';
    Hint := '';
    TabOrder := 29;
    Text := '5000';
  end;

  CheckBox2 := TfpgCheckBox.Create(self);
  with CheckBox2 do
  begin
    Name := 'CheckBox2';
    SetPosition(368, 244, 120, 19);
    FontDesc := '#Label1';
    Hint := '';
    TabOrder := 30;
    Text := 'Enable Filter';
    onchange := @RadioButton1Change;
  end;

  {@VFD_BODY_END: Filterplayer}
    {%endregion}

    //////////////////////

    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
    RadioButton1.Checked := True;
    Height := 157;
                  {$IFDEF Windows}
     {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    FilenameEdit2.FileName := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
   {$else}
    FilenameEdit1.FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    FilenameEdit2.FileName := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
    {$endif}
    FilenameEdit4.FileName := ordir + 'sound\test.mp3';
 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/uos', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    FilenameEdit2.FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    FilenameEdit3.FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
    FilenameEdit4.FileName := opath + 'sound/test.mp3';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    FilenameEdit2.FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
   {$else}
    FilenameEdit1.FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    FilenameEdit2.FileName := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
   {$endif}
    FilenameEdit4.FileName := ordir + 'sound/test.mp3';
            {$ENDIF}

    {$IFDEF freebsd}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
     FilenameEdit2.FileName := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
      {$else}
   FilenameEdit1.FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-64.so';
     FilenameEdit2.FileName := ordir + 'lib/FreeBSD/32bit/libsndfile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/32bit/libmpg123-64.so';
   {$endif}
     FilenameEdit4.FileName := ordir + 'sound/test.mp3';
 {$ENDIF}



    FilenameEdit4.Initialdir := ordir + 'sound';
    FilenameEdit1.Initialdir := ordir + 'lib';
    FilenameEdit2.Initialdir := ordir + 'lib';
    FilenameEdit3.Initialdir := ordir + 'lib';
  end;

  procedure TFilterplayer.uos_logo(Sender: TObject);
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
      Canvas.DrawText(60, 20, 'uos');
    end;
  end;

  procedure MainProc;
  var
    frm: TFilterplayer;
  begin
    fpgApplication.Initialize;
    frm := TFilterplayer.Create(nil);
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
