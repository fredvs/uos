program simplewebplayer_fpGUI;

{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}
  cthreads,
  cwstring, {$ENDIF}
  SysUtils,
  uos_flat,
  ctypes,
  Math,
  Classes,
  fpg_button,
  fpg_widget,
  fpg_label,
  fpg_Edit,
  fpg_Editbtn,
  fpg_RadioButton,
  fpg_trackbar,
  fpg_CheckBox,
  fpg_Panel,
  fpg_base,
  fpg_main,
  fpg_form ;

type
  TSimpleplayer = class(TfpgForm)
    procedure uos_logo(Sender: TObject);
  private
    {@VFD_HEAD_BEGIN: Simpleplayer}
    Custom1: TfpgWidget;
    Labelport: TfpgLabel;
    btnLoad: TfpgButton;
    FilenameEdit1: TfpgFileNameEdit;
    btnStart: TfpgButton;
    btnStop: TfpgButton;
    Labelmpg: TfpgLabel;
    Labelst: TfpgLabel;
    FilenameEdit3: TfpgFileNameEdit;
    FilenameEdit5: TfpgFileNameEdit;
    btnpause: TfpgButton;
    btnresume: TfpgButton;
    RadioButton1: TfpgRadioButton;
    RadioButton2: TfpgRadioButton;
    RadioButton3: TfpgRadioButton;
    Label2: TfpgLabel;
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
    Edit1: TfpgEdit;
    Label8: TfpgLabel;
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
    procedure ClosePlayer1;
    procedure LoopProcPlayer1;
    procedure ShowLevel;
    procedure VolumeChange(Sender: TObject; pos: integer);
    procedure ChangePlugSet(Sender: TObject);
    procedure TrackChangePlugSet(Sender: TObject; pos: integer);
    procedure ResetPlugClick(Sender: TObject);
  end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var
  PlayerIndex1: integer;
  ordir, opath: string;
  In1Index, Plugin1Index: integer;
  plugsoundtouch : boolean = false;


  procedure TSimpleplayer.ChangePlugSet(Sender: TObject);
  var
    tempo, rate: cfloat;
  begin
         if (trim(Pchar(filenameedit5.FileName)) <> '') and fileexists(filenameedit5.FileName) then
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
      uos_SetPluginSoundTouch(PlayerIndex1, Plugin1Index, tempo, rate, checkbox2.Checked);
    end;
    end;
  end;

  procedure TSimpleplayer.ResetPlugClick(Sender: TObject);
  begin
    TrackBar4.Position := 50;
    TrackBar5.Position := 50;
    if radiobutton1.Enabled = False then   /// player1 was created
    begin
      uos_SetPluginSoundTouch(PlayerIndex1, Plugin1Index, 1, 1, checkbox2.Checked);
    end;
  end;

  procedure TSimpleplayer.TrackChangePlugSet(Sender: TObject; pos: integer);
  begin
       if (trim(Pchar(filenameedit5.FileName)) <> '') and fileexists(filenameedit5.FileName) then
      ChangePlugSet(Sender);
  end;

  procedure TSimpleplayer.btnResumeClick(Sender: TObject);
  begin
    uos_RePlay(PlayerIndex1);
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := True;
    btnresume.Enabled := False;
  end;

  procedure TSimpleplayer.btnPauseClick(Sender: TObject);
  begin
    uos_Pause(PlayerIndex1);
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


  procedure TSimpleplayer.VolumeChange(Sender: TObject; pos: integer);
  begin
    if (btnstart.Enabled = False) then
      uos_SetDSPVolumeIn(PlayerIndex1, In1Index,
        (100 - TrackBar2.position) / 100,
        (100 - TrackBar3.position) / 100, True);
  end;

 procedure TSimpleplayer.ShowLevel;
  begin
    vuLeft.Visible := True;
    vuRight.Visible := True;
    if round(uos_InputGetLevelLeft(PlayerIndex1, In1Index) * 128) >= 0 then
      vuLeft.Height := round(uos_InputGetLevelLeft(PlayerIndex1, In1Index) * 128);
    if round(uos_InputGetLevelRight(PlayerIndex1, In1Index) * 128) >= 0 then
      vuRight.Height := round(uos_InputGetLevelRight(PlayerIndex1, In1Index) * 128);
    vuLeft.top := 348 - vuLeft.Height;
    vuRight.top := 348 - vuRight.Height;
    vuright.UpdateWindowPosition;
    vuLeft.UpdateWindowPosition;
  end;

  procedure TSimpleplayer.btnCloseClick(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
    begin
      uos_stop(PlayerIndex1);
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
 // function uos_LoadLib(PortAudioFileName: PChar; SndFileFileName: PChar;
  // Mpg123FileName: PChar) : integer;

if uos_LoadLib(Pchar(FilenameEdit1.FileName), nil, Pchar(FilenameEdit3.FileName),nil, nil) = 0 then
    begin
      hide;
       loadok := true;
      Height := 403;
      btnStart.Enabled := True;
      btnLoad.Enabled := False;
      FilenameEdit1.ReadOnly := True;
      FilenameEdit3.ReadOnly := True;
      FilenameEdit5.ReadOnly := True;
      UpdateWindowPosition;
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
        'PortAudio, SndFile, Mpg123 and Plugin SoundTouch are loaded...';
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
       
       WindowPosition := wpScreenCenter;
      WindowTitle := 'Simple Web Player    uos version ' + inttostr(uos_getversion());

      // Some audio web streaming
     edit1.text := 'http://streaming304.radionomy.com:80/GENERATIONSOULDISCOFUNK-MP3';
 //  edit1.text := 'http://broadcast.infomaniak.net:80/alouette-high.mp3';
 //  edit1.text := 'http://arvorig-fm.online.stalig.net/live.mp3'
 //  edit1.text := 'http://str1.sad.ukrd.com:80/2br';
 //  edit1.text := 'http://streaming304.radionomy.com:80/GENERATIONSOULDISCOFUNK-MP3';
 //  edit1.text := 'http://broadcast.infomaniak.net/start-latina-high.mp3' ;
 //  edit1.text := 'http://www.hubharp.com/web_sound/BachGavotteShort.mp3' ;
 //  edit1.text := 'http://www.jerryradio.com/downloads/BMB-64-03-06-MP3/jg1964-03-06t01.mp3' ;

       fpgapplication.ProcessMessages;
      sleep(250);
      Show;
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

  end;

  procedure TSimpleplayer.btnStopClick(Sender: TObject);
  begin
    uos_Stop(PlayerIndex1);
    closeplayer1;
  end;

   procedure TSimpleplayer.btnStartClick(Sender: TObject);
  var
    samformat: shortint;
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

    PlayerIndex1 := 0;
    // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
    // If PlayerIndex exists already, it will be overwritten...

    {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
     uos_CreatePlayer(PlayerIndex1);
     {$else}
    uos_CreatePlayer(PlayerIndex1,self);
    {$endif}
    //// Create the player.
    //// PlayerIndex : from 0 to what your computer can do !
    //// If PlayerIndex exists already, it will be overwriten...

    In1Index :=  uos_AddFromURL(PlayerIndex1,pchar(edit1.text),-1,samformat,-1) ;
    /////// Add a Input from Audio URL with custom parameters
              ////////// URL : URL of audio file (like  'http://someserver/somesound.mp3')
              ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
              ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
              //////////// FramesCount : default : -1 (1024)
              ////////// example : InputIndex := AddFromFile(0,'http://someserver/somesound.mp3',-1,-1,-1);
         //  result : -1 nothing created, otherwise Input Index in array

    uos_AddIntoDevOut(PlayerIndex1, -1, -1, -1, -1, samformat, 1024);
    //// add a Output into device with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)   /// here default samplerate of input
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Output Index in array

    uos_InputSetLevelEnable(PlayerIndex1, In1Index, 2) ;
     ///// set calculation of level/volume (usefull for showvolume procedure)
                       ///////// set level calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

    uos_LoopProcIn(PlayerIndex1, In1Index, @LoopProcPlayer1);
    ///// Assign the procedure of object to execute inside the loop of input
    //////////// PlayerIndex : Index of a existing Player
    //////////// InIndex : Index of a existing Input
    //////////// LoopProcPlayer1 : procedure of object to execute inside the loop

    uos_AddDSPVolumeIn(PlayerIndex1, In1Index, 1, 1);
    ///// DSP Volume changer
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index : InputIndex of a existing input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume

    uos_SetDSPVolumeIn(PlayerIndex1, In1Index,
      (100 - TrackBar2.position) / 100,
      (100 - TrackBar3.position) / 100, True);
    /// Set volume
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled

       if  plugsoundtouch = true then
  begin
    Plugin1Index := uos_AddPlugin(PlayerIndex1, 'soundtouch', -1, -1);
    ///// add SoundTouch plugin with default samplerate(44100) / channels(2 = stereo)

    ChangePlugSet(self); //// custom procedure to Change plugin settings
   end;

     /////// procedure to execute when stream is terminated
    uos_EndProc(PlayerIndex1, @ClosePlayer1);
    ///// Assign the procedure of object to execute at end
    //////////// PlayerIndex : Index of a existing Player
    //////////// ClosePlayer1 : procedure of object to execute inside the general loop

    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnpause.Enabled := True;
    btnresume.Enabled := False;

    uos_Play(PlayerIndex1);  /////// everything is ready, here we are, lets play it...
 end;


   {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
      {$else}
  procedure TSimpleplayer.CustomMsgReceived(var msg: TfpgMessageRec);
  begin
    ShowLevel;
  end;

      {$ENDIF}

procedure TSimpleplayer.LoopProcPlayer1;
begin
 ShowLevel ;
end;

  procedure TSimpleplayer.AfterCreate;
  begin
    {%region 'Auto-generated GUI code' -fold}

    {@VFD_BODY_BEGIN: Simpleplayer}
  Name := 'Simpleplayer';
  SetPosition(467, 0, 502, 403);
  WindowTitle := 'Simple Web Player ';
  IconName := '';
  Hint := '';
  BackGroundColor := $80000001;
  WindowPosition := wpScreenCenter;
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
    SetPosition(12, 168, 480, 23);
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

  btnStart := TfpgButton.Create(self);
  with btnStart do
  begin
    Name := 'btnStart';
    SetPosition(116, 372, 44, 23);
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
    SetPosition(360, 372, 64, 23);
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 7;
    Text := 'Stop';
    onclick := @btnStopClick;
  end;

  Labelmpg := TfpgLabel.Create(self);
  with Labelmpg do
  begin
    Name := 'Labelmpg';
    SetPosition(148, 60, 316, 15);
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
    SetPosition(136, 76, 356, 24);
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

  btnpause := TfpgButton.Create(self);
  with btnpause do
  begin
    Name := 'btnpause';
    SetPosition(192, 372, 52, 23);
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
    SetPosition(272, 372, 64, 23);
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 16;
    Text := 'Resume';
    onclick := @btnResumeClick;
  end;

  RadioButton1 := TfpgRadioButton.Create(self);
  with RadioButton1 do
  begin
    Name := 'RadioButton1';
    SetPosition(128, 300, 96, 19);
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
    Checked := True;
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
    SetPosition(72, 348, 36, 19);
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
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 37;
    Text := 'Reset';
    OnClick := @ResetPlugClick;
  end;

  Edit1 := TfpgEdit.Create(self);
  with Edit1 do
  begin
    Name := 'Edit1';
    SetPosition(120, 232, 360, 24);
    ExtraHint := '';
    FontDesc := '#Edit1';
    Hint := '';
    TabOrder := 33;
    Text := 'http://broadcast.infomaniak.net:80/alouette-high.mp3';
  end;

  Label8 := TfpgLabel.Create(self);
  with Label8 do
  begin
    Name := 'Label8';
    SetPosition(236, 216, 100, 15);
    FontDesc := '#Label1';
    Hint := '';
    Text := 'HTTP location';
  end;

  {@VFD_BODY_END: Simpleplayer}
    {%endregion}

    //////////////////////

    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
    RadioButton3.Checked := True;
    Height := 197;
             {$IFDEF Windows}
     {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
    FilenameEdit5.FileName := ordir + 'lib\Windows\64bit\plugin\LibSoundTouch-64.dll';
{$else}
    FilenameEdit1.FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
    FilenameEdit5.FileName := ordir + 'lib\Windows\32bit\plugin\LibSoundTouch-32.dll';
   {$endif}
 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/uos', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    FilenameEdit3.FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
    FilenameEdit5.FileName := opath + '/lib/Mac/32bit/plugin/LibSoundTouch-32.dylib';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    FilenameEdit5.FileName := ordir + 'lib/Linux/64bit/plugin/LibSoundTouch-64.so';
{$else}
    FilenameEdit1.FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    FilenameEdit5.FileName := ordir + 'lib/Linux/32bit/plugin/LibSoundTouch-32.so';
{$endif}
            {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    FilenameEdit5.FileName := ''; 
    {$else}
   FilenameEdit1.FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-64.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/32bit/libmpg123-64.so';
     FilenameEdit5.FileName := '';
{$endif}
  {$ENDIF}

    FilenameEdit1.Initialdir := ordir + 'lib';
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
 //   frm := TSimpleplayer.Create(nil);
       fpgApplication.CreateForm(TSimpleplayer, frm);
    try
      frm.Show;
      fpgApplication.Run;
    finally
      uos_free;
      frm.Free;
    end;
  end;

begin
  MainProc;
end.
