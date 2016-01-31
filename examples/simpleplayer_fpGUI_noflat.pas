program simpleplayer_fpGUI_noflat;

{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses {$IFDEF UNIX}
  cthreads,
  cwstring, {$ENDIF}
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
  fpg_Panel,
  fpg_base,
  fpg_main,
  fpg_form { you can add units after this };

type
  TSimpleplayer = class(TfpgForm)
    procedure uos_logo(Sender: TObject);
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
    Labelst: TfpgLabel;
    FilenameEdit3: TfpgFileNameEdit;
    FilenameEdit5: TfpgFileNameEdit;
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
    vuleft: TfpgPanel;
    vuright: TfpgPanel;
    CheckBox2: TfpgCheckBox;
    Label6: TfpgLabel;
    Label7: TfpgLabel;
    TrackBar4: TfpgTrackBar;
    TrackBar5: TfpgTrackBar;
    Button1: TfpgButton;
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
     {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
          {$else}
    procedure CustomMsgReceived(var msg: TfpgMessageRec); message MSG_CUSTOM1;
      {$ENDIF}
    procedure ClosePlayer1;
    procedure LoopProcPlayer1;
    procedure ShowPosition;
    procedure ShowLevel;
    procedure changecheck(Sender: TObject);
    procedure VolumeChange(Sender: TObject; pos: integer);
    procedure ChangePlugSet(Sender: TObject);
    procedure TrackChangePlugSet(Sender: TObject; pos: integer);
    procedure ResetPlugClick(Sender: TObject);
  end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var
  PlayerIndex1: Tuos_Player;
  ordir, opath: string;
  In1Index, DSP1Index, DSP2Index, Plugin1Index: integer;
  plugsoundtouch : boolean = true;

  procedure TSimpleplayer.btnTrackOnClick(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; const pos: TPoint);
  begin
    TrackBar1.Tag := 1;
  end;

  procedure TSimpleplayer.ChangePlugSet(Sender: TObject);
  var
    tempo, rate: cfloat;
  begin
    if 2 - (2 * (TrackBar4.Position / 100)) < 0.3 then
      tempo := 0.3
    else
      tempo := 2 - (2 * (TrackBar4.Position / 100));
    if 2 - (2 * (TrackBar5.Position / 100)) < 0.3 then
      rate := 0.3
    else
      rate := 2 - (2 * (TrackBar5.Position / 100));

    label6.Text := 'Tempo: ' + floattostrf(tempo, ffFixed, 15, 1);
    label7.Text := 'Pitch: ' + floattostrf(rate, ffFixed, 15, 1);

    if radiobutton1.Enabled = False then   /// player1 was created
    begin
      PlayerIndex1.SetPluginSoundTouch(Plugin1Index, tempo, rate, checkbox2.Checked);
    end;
  end;

  procedure TSimpleplayer.ResetPlugClick(Sender: TObject);
  begin
    TrackBar4.Position := 50;
    TrackBar5.Position := 50;
    if radiobutton1.Enabled = False then   /// player1 was created
    begin
      PlayerIndex1.SetPluginSoundTouch(Plugin1Index, 1, 1, checkbox2.Checked);
    end;
  end;

  procedure TSimpleplayer.TrackChangePlugSet(Sender: TObject; pos: integer);
  begin
        if (trim(Pchar(filenameedit5.FileName)) <> '') and fileexists(filenameedit5.FileName) then
         ChangePlugSet(Sender);
  end;

  procedure TSimpleplayer.btnTrackoffClick(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; const pos: TPoint);
  begin
    PlayerIndex1.Seek(In1Index, TrackBar1.position);
    TrackBar1.Tag := 0;
  end;

  procedure TSimpleplayer.btnResumeClick(Sender: TObject);
  begin
    PlayerIndex1.RePlay();
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := True;
    btnresume.Enabled := False;
  end;

  procedure TSimpleplayer.btnPauseClick(Sender: TObject);
  begin
    PlayerIndex1.Pause();
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := False;
    btnresume.Enabled := True;
    vuLeft.Visible := False;
    vuRight.Visible := False;
    vuright.Height := 0;
    vuleft.Height := 0;
    vuright.UpdateWindowPosition;
    vuLeft.UpdateWindowPosition;
  end;

  procedure TSimpleplayer.changecheck(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
      PlayerIndex1.SetDSPIn(In1Index, DSP1Index, checkbox1.Checked);
  end;

  procedure TSimpleplayer.VolumeChange(Sender: TObject; pos: integer);
  begin
    if (btnstart.Enabled = False) then
      PlayerIndex1.SetDSPVolumeIn(In1Index, DSP2Index,
        (100 - TrackBar2.position) / 100,
        (100 - TrackBar3.position) / 100, True);
  end;

 procedure TSimpleplayer.ShowLevel;
  begin
    vuLeft.Visible := True;
    vuRight.Visible := True;
    if round(PlayerIndex1.InputGetLevelLeft(In1Index) * 128) >= 0 then
      vuLeft.Height := round(PlayerIndex1.InputGetLevelLeft(In1Index) * 128);
    if round(PlayerIndex1.InputGetLevelRight(In1Index) * 128) >= 0 then
      vuRight.Height := round(PlayerIndex1.InputGetLevelRight(In1Index) * 128);
    vuLeft.top := 348 - vuLeft.Height;
    vuRight.top := 348 - vuRight.Height;
    vuright.UpdateWindowPosition;
    vuLeft.UpdateWindowPosition;
  end;

  procedure TSimpleplayer.btnCloseClick(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
    begin
      PlayerIndex1.Stop();
      vuLeft.Visible := False;
      vuRight.Visible := False;
      vuright.Height := 0;
      vuleft.Height := 0;
      vuright.UpdateWindowPosition;
      vuLeft.UpdateWindowPosition;
      sleep(100);
    end;
    if btnLoad.Enabled = False then
      uos_UnloadLib();
  end;

  procedure TSimpleplayer.btnLoadClick(Sender: TObject);
  var
   loadok : boolean = false;
  begin
    // Load the libraries
    // function uos_LoadLib(PortAudioFileName: Pchar; SndFileFileName: Pchar; Mpg123FileName: Pchar) : integer;
if uos_LoadLib(Pchar(FilenameEdit1.FileName), Pchar(FilenameEdit2.FileName), Pchar(FilenameEdit3.FileName)) = 0 then
    begin
      hide;
      Height := 403;
      loadok := true;
      btnStart.Enabled := True;
      btnLoad.Enabled := False;
      FilenameEdit1.ReadOnly := True;
      FilenameEdit2.ReadOnly := True;
      FilenameEdit3.ReadOnly := True;
      FilenameEdit5.ReadOnly := True;
       WindowPosition := wpScreenCenter;
           btnLoad.Text :=
        'PortAudio, SndFile, Mpg123 libraries are loaded...'
        end else btnLoad.Text :=
        'One or more libraries did not load, check filenames...';

         if loadok = true then
        begin
           if ((trim(Pchar(filenameedit5.FileName)) <> '') and fileexists(filenameedit5.FileName))
       and (uos_LoadPlugin('soundtouch', Pchar(FilenameEdit5.FileName)) = 0)  then
       begin
      plugsoundtouch := true;
          btnLoad.Text :=
        'PortAudio, SndFile, Mpg123 and Plugin are loaded...';
        end
         else
         begin
        TrackBar4.enabled := false;
       TrackBar5.enabled := false;
       CheckBox2.enabled := false;
       Button1.enabled := false;
       label6.enabled := false;
       label7.enabled := false;
           end;
                UpdateWindowPosition;
               WindowTitle := 'Simple Player.    uos version ' + inttostr(uos_getversion());
       fpgapplication.ProcessMessages;
    sleep(500);
     show;
    end;
  end;

  procedure TSimpleplayer.ClosePlayer1;
  begin
    radiobutton1.Enabled := True;
    radiobutton2.Enabled := True;
    radiobutton3.Enabled := True;
    vuLeft.Visible := False;
    vuRight.Visible := False;
    vuright.Height := 0;
    vuleft.Height := 0;
    vuright.UpdateWindowPosition;
    vuLeft.UpdateWindowPosition;
    btnStart.Enabled := True;
    btnStop.Enabled := False;
    btnPause.Enabled := False;
    btnresume.Enabled := False;
    trackbar1.Position := 0;
    lposition.Text := '00:00:00.000';
  end;

  procedure TSimpleplayer.btnStopClick(Sender: TObject);
  begin
    PlayerIndex1.Stop();
    closeplayer1;
  end;

  function DSPReverseBefore(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;
  begin
    if Data.position > Data.OutFrames div Data.ratio then
      PlayerIndex1.Seek(In1Index, Data.position - (Data.OutFrames div Data.Ratio));
  end;

  function DSPReverseAfter(Data: Tuos_Data; fft: Tuos_FFT): TDArFloat;
  var
    x: integer = 0;
    arfl: TDArFloat;
  begin
   SetLength(arfl, length(Data.Buffer));
       while x < length(Data.Buffer) + 2 do
          begin
      arfl[x] := Data.Buffer[length(Data.Buffer) - x - 2] ;
      arfl[x+1] := Data.Buffer[length(Data.Buffer) - x - 1] ;
         x := x +2;
          end;

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

    radiobutton1.Enabled := False;
    radiobutton2.Enabled := False;
    radiobutton3.Enabled := False;

    {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
   PlayerIndex1 := Tuos_Player.Create(true);
     {$else}
    PlayerIndex1 := Tuos_Player.Create(true,self);
    {$endif}


    In1Index := PlayerIndex1.AddFromFile( pchar(filenameEdit4.filename), -1, samformat, -1);
    //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    //////////// PlayerIndex : Index of a existing Player
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
    //////////// FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Input Index in array

    if  In1Index > -1 then begin

    // Out1Index := uos_AddIntoDevOut(PlayerIndex1) ;
    //// add a Output into device with default parameters
    PlayerIndex1.AddIntoDevOut(-1, -1, PlayerIndex1.StreamIn[In1Index].Data.SampleRate, -1, samformat, -1);
    //// add a Output into device with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)   /// here default samplerate of input
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Output Index in array

    PlayerIndex1.StreamIn[In1Index].Data.levelEnable:=2 ;
   ///// set calculation of level/volume to true (usefull for showvolume procedure)
                       ///////// set level calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

   PlayerIndex1.StreamIn[In1Index].Data.PositionEnable:= 1 ;
     ///// set calculation of position (usefull for positions procedure)
                       ///////// set position calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul position.

    PlayerIndex1.StreamIn[In1Index].LoopProc := @LoopProcPlayer1;
    ///// Assign the procedure of object to execute inside the loop of input
    //////////// PlayerIndex : Index of a existing Player
    //////////// InIndex : Index of a existing Input
    //////////// LoopProcPlayer1 : procedure of object to execute inside the loop

    DSP2Index := PlayerIndex1.AddDSPVolumeIn(In1Index, 1, 1);
    ///// DSP Volume changer
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index : InputIndex of a existing input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume


    PlayerIndex1.SetDSPVolumeIn(In1Index,DSP2Index,
      (100 - TrackBar2.position) / 100,
      (100 - TrackBar3.position) / 100, True);
    /// Set volume
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled

    DSP1Index := PlayerIndex1.AddDSPIn(In1Index, @DSPReverseBefore,
      @DSPReverseAfter, nil);
    ///// add a custom DSP procedure for input
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index: InputIndex of existing input
    ////////// BeforeProc : procedure to do before the buffer is filled
    ////////// AfterProc : procedure to do after the buffer is filled
    ////////// LoopProc : external procedure to do after the buffer is filled

    PlayerIndex1.SetDSPIn(In1Index, DSP1Index, checkbox1.Checked);
    //// set the parameters of custom DSP;

    if (trim(Pchar(filenameedit5.FileName)) <> '') and fileexists(filenameedit5.FileName) then
      begin
    Plugin1Index := PlayerIndex1.AddPlugin('soundtouch', -1, -1);
    ///// add SoundTouch plugin with default samplerate(44100) / channels(2 = stereo)

    ChangePlugSet(self); //// custom procedure to Change plugin settings
     end;

    trackbar1.Max := PlayerIndex1.InputLength( In1Index);
    ////// Length of Input in samples

    temptime := PlayerIndex1.InputLengthTime(In1Index);
    ////// Length of input in time

    DecodeTime(temptime, ho, mi, se, ms);

    llength.Text := format('%d:%d:%d.%d', [ho, mi, se, ms]);

    /////// procedure to execute when stream is terminated
    PlayerIndex1.EndProc := @ClosePlayer1;
    ///// Assign the procedure of object to execute at end
    //////////// PlayerIndex : Index of a existing Player
    //////////// ClosePlayer1 : procedure of object to execute inside the general loop

    TrackBar1.position := 0;
    trackbar1.Enabled := True;
    CheckBox1.Enabled := True;

    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnpause.Enabled := True;
    btnresume.Enabled := False;

    PlayerIndex1.Play();  /////// everything is ready, here we are, lets play it...
    end;
  end;

  procedure TSimpleplayer.ShowPosition;
  var
    temptime: ttime;
    ho, mi, se, ms: word;
  begin
    if (TrackBar1.Tag = 0) then
    begin
      if PlayerIndex1.InputPosition(In1Index) > 0 then
      begin
        TrackBar1.Position := PlayerIndex1.InputPosition(In1Index);
        temptime := PlayerIndex1.InputPositionTime(In1Index);
        ////// Length of input in time
        DecodeTime(temptime, ho, mi, se, ms);
        lposition.Text := format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
      end;
    end;
  end;

   {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
      {$else}
  procedure TSimpleplayer.CustomMsgReceived(var msg: TfpgMessageRec);
  begin
    ShowLevel;
    ShowPosition ;
    end;

      {$ENDIF}

procedure TSimpleplayer.LoopProcPlayer1;
begin
 ShowPosition;
 ShowLevel ;
end;

  procedure TSimpleplayer.AfterCreate;
  begin
    {%region 'Auto-generated GUI code' -fold}


    {@VFD_BODY_BEGIN: Simpleplayer}
    Name := 'Simpleplayer';
    SetPosition(467, 0, 502, 403);
    WindowTitle := 'Simple player ';
    Hint := '';
    WindowPosition := wpScreenCenter;
    BackgroundColor := clmoneygreen;
    Ondestroy := @btnCloseClick;

    Custom1 := TfpgWidget.Create(self);
    with Custom1 do
    begin
      Name := 'Custom1';
      SetPosition(10, 8, 115, 155);
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
      SetPosition(16, 168, 476, 23);
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
      SetPosition(132, 200, 360, 24);
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
      SetPosition(136, 372, 44, 23);
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
      SetPosition(360, 372, 80, 23);
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
      SetPosition(224, 265, 84, 19);
      Alignment := taCenter;
      FontDesc := '#Label2';
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

    Labelst := TfpgLabel.Create(self);
    with Labelst do
    begin
      Name := 'Labelst';
      SetPosition(136, 120, 316, 15);
      Alignment := taCenter;
      FontDesc := '#Label1';
      Hint := '';
      Text := 'Folder + filename of SoundTouch Library';
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

    FilenameEdit5 := TfpgFileNameEdit.Create(self);
    with FilenameEdit5 do
    begin
      Name := 'FilenameEdit5';
      SetPosition(136, 136, 356, 24);
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
      SetPosition(308, 265, 12, 15);
      FontDesc := '#Label1';
      Hint := '';
      Text := '/';
    end;

    Llength := TfpgLabel.Create(self);
    with Llength do
    begin
      Name := 'Llength';
      SetPosition(316, 265, 80, 15);
      FontDesc := '#Label2';
      Hint := '';
      Text := '00:00:00.000';
    end;

    btnpause := TfpgButton.Create(self);
    with btnpause do
    begin
      Name := 'btnpause';
      SetPosition(200, 372, 52, 23);
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
      SetPosition(272, 372, 64, 23);
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
      SetPosition(12, 372, 104, 19);
      FontDesc := '#Label1';
      Hint := '';
      TabOrder := 17;
      Text := 'Play Reverse';
    end;

    RadioButton1 := TfpgRadioButton.Create(self);
    with RadioButton1 do
    begin
      Name := 'RadioButton1';
      SetPosition(128, 300, 96, 19);
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
      SetPosition(128, 316, 100, 19);
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
      SetPosition(128, 334, 100, 19);
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
      SetPosition(116, 284, 104, 15);
      FontDesc := '#Label2';
      Hint := '';
      Text := 'Sample format';
    end;

    TrackBar1 := TfpgTrackBar.Create(self);
    with TrackBar1 do
    begin
      Name := 'TrackBar1';
      SetPosition(132, 232, 356, 30);
      Hint := '';
      TabOrder := 22;
      TrackBar1.OnMouseDown := @btntrackonClick;
      TrackBar1.OnMouseUp := @btntrackoffClick;
    end;

    TrackBar2 := TfpgTrackBar.Create(self);
    with TrackBar2 do
    begin
      Name := 'TrackBar2';
      SetPosition(4, 216, 32, 134);
      Hint := '';
      Orientation := orVertical;
      TabOrder := 23;
      OnChange := @volumechange;
    end;

    TrackBar3 := TfpgTrackBar.Create(self);
    with TrackBar3 do
    begin
      Name := 'TrackBar3';
      SetPosition(72, 216, 28, 134);
      Hint := '';
      Orientation := orVertical;
      TabOrder := 24;
      OnChange := @volumechange;
    end;

    Label3 := TfpgLabel.Create(self);
    with Label3 do
    begin
      Name := 'Label3';
      SetPosition(12, 196, 84, 15);
      Alignment := taCenter;
      FontDesc := '#Label2';
      Hint := '';
      Text := 'Volume';
    end;

    Label4 := TfpgLabel.Create(self);
    with Label4 do
    begin
      Name := 'Label4';
      SetPosition(0, 348, 40, 15);
      Alignment := taCenter;
      FontDesc := '#Label1';
      Hint := '';
      Text := 'Left';
    end;

    Label5 := TfpgLabel.Create(self);
    with Label5 do
    begin
      Name := 'Label5';
      SetPosition(68, 348, 36, 19);
      Alignment := taCenter;
      FontDesc := '#Label1';
      Hint := '';
      Text := 'Right';
    end;

    vuleft := TfpgPanel.Create(self);
    with vuleft do
    begin
      Name := 'vuleft';
      SetPosition(40, 220, 8, 128);
      BackgroundColor := TfpgColor($00D51D);
      FontDesc := '#Label1';
      Hint := '';
      Style := bsFlat;
      Text := '';
    end;

    vuright := TfpgPanel.Create(self);
    with vuright do
    begin
      Name := 'vuright';
      SetPosition(60, 220, 8, 128);
      BackgroundColor := TfpgColor($1DD523);
      FontDesc := '#Label1';
      Hint := '';
      Style := bsFlat;
      Text := '';
    end;

    CheckBox2 := TfpgCheckBox.Create(self);
    with CheckBox2 do
    begin
      Name := 'CheckBox2';
      SetPosition(268, 284, 184, 19);
      FontDesc := '#Label1';
      Hint := '';
      TabOrder := 32;
      Text := 'Enable SoundTouch PlugIn';
      OnChange := @ChangePlugSet;
    end;

    Label6 := TfpgLabel.Create(self);
    with Label6 do
    begin
      Name := 'Label6';
      SetPosition(272, 312, 80, 19);
      FontDesc := '#Label1';
      Hint := '';
      Text := 'Tempo: 1.0';
    end;

    Label7 := TfpgLabel.Create(self);
    with Label7 do
    begin
      Name := 'Label7';
      SetPosition(380, 312, 80, 15);
      FontDesc := '#Label1';
      Hint := '';
      Text := 'Pitch: 1.0';
    end;

    TrackBar4 := TfpgTrackBar.Create(self);
    with TrackBar4 do
    begin
      Name := 'TrackBar4';
      SetPosition(344, 308, 28, 54);
      Hint := '';
      Orientation := orVertical;
      Position := 50;
      Position := 50;
      TabOrder := 35;
      OnChange := @TrackChangePlugSet;
    end;

    TrackBar5 := TfpgTrackBar.Create(self);
    with TrackBar5 do
    begin
      Name := 'TrackBar5';
      SetPosition(440, 308, 28, 54);
      Hint := '';
      Orientation := orVertical;
      Position := 50;
      Position := 50;
      TabOrder := 36;
      OnChange := @TrackChangePlugSet;
    end;

    Button1 := TfpgButton.Create(self);
    with Button1 do
    begin
      Name := 'Button1';
      SetPosition(260, 336, 60, 23);
      Text := 'Reset';
      FontDesc := '#Label1';
      Hint := '';
      ImageName := '';
      TabOrder := 37;
      OnClick := @ResetPlugClick;
    end;

    {@VFD_BODY_END: Simpleplayer}
    {%endregion}

    //////////////////////

    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
    checkbox1.OnChange := @changecheck;
    RadioButton1.Checked := True;
    Height := 197;
             {$IFDEF Windows}
     {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    FilenameEdit2.FileName := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
    FilenameEdit5.FileName := ordir + 'lib\Windows\64bit\LibSoundTouch-64.dll';
{$else}
    FilenameEdit1.FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    FilenameEdit2.FileName := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
    FilenameEdit5.FileName := ordir + 'lib\Windows\32bit\libSoundTouch-32.dll';
   {$endif}
    FilenameEdit4.FileName := ordir + 'sound\test.mp3';
 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/uos', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    FilenameEdit2.FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    FilenameEdit3.FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
    FilenameEdit5.FileName := opath + '/lib/Mac/32bit/libSoundTouch-32.dylib';
    FilenameEdit4.FileName := opath + 'sound/test.mp3';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    FilenameEdit2.FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    FilenameEdit5.FileName := ordir + 'lib/Linux/64bit/LibSoundTouch-64.so';
{$else}
    FilenameEdit1.FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    FilenameEdit2.FileName := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    FilenameEdit5.FileName := ordir + 'lib/Linux/32bit/libSoundTouch-32.so';
{$endif}
    FilenameEdit4.FileName := ordir + 'sound/test.mp3';
            {$ENDIF}

 
 {$IFDEF freebsd}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/freeBSD/64bit/libportaudio-64.so';
     FilenameEdit2.FileName := ordir + 'lib/freeBSD/64bit/libsndfile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/freeBSD/64bit/libmpg123-64.so';
    FilenameEdit5.FileName := '';
    {$else}
   FilenameEdit1.FileName := ordir + 'lib/freeBSD/32bit/libportaudio-32.so';
     FilenameEdit2.FileName := ordir + 'lib/freeBSD/32bit/libsndfile-32.so';
    FilenameEdit3.FileName := ordir + 'lib/freeBSD/32bit/libmpg123-32.so';
     FilenameEdit5.FileName := '';
{$endif}
     FilenameEdit4.FileName := ordir + 'sound/test.mp3';
 {$ENDIF}

    FilenameEdit4.Initialdir := ordir + 'sound';
    FilenameEdit1.Initialdir := ordir + 'lib';
    FilenameEdit2.Initialdir := ordir + 'lib';
    FilenameEdit3.Initialdir := ordir + 'lib';
    FilenameEdit5.Initialdir := ordir + 'lib';

    vuLeft.Visible := False;
    vuRight.Visible := False;
    vuLeft.Height := 0;
    vuRight.Height := 0;
    vuright.UpdateWindowPosition;
    vuLeft.UpdateWindowPosition;
  end;

  procedure TSimpleplayer.uos_logo(Sender: TObject);
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
