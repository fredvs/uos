program multiplayer_fpGUI;

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

  TMultiplayer = class(TfpgForm)
    procedure uos_logo(Sender: TObject);
  private
    {@VFD_HEAD_BEGIN: Multiplayer}
    Custom1: TfpgWidget;
    Labelport: TfpgLabel;
    btnLoad: TfpgButton;
    FilenameEdit1: TfpgFileNameEdit;
    FilenameEdit2: TfpgFileNameEdit;
    FilenameEdit4: TfpgFileNameEdit;
    btnStart: TfpgButton;
    btnStop: TfpgButton;
    Labelsnf: TfpgLabel;
    Labelmpg: TfpgLabel;
    FilenameEdit3: TfpgFileNameEdit;
    btnpause: TfpgButton;
    btnresume: TfpgButton;
    FilenameEdit5: TfpgFileNameEdit;
    btnStart2: TfpgButton;
    btnpause2: TfpgButton;
    btnresume2: TfpgButton;
    btnStop2: TfpgButton;
    FilenameEdit6: TfpgFileNameEdit;
    btnStart3: TfpgButton;
    btnPause3: TfpgButton;
    btnResume3: TfpgButton;
    btnStop3: TfpgButton;
    FilenameEdit7: TfpgFileNameEdit;
    btnStart4: TfpgButton;
    btnPause4: TfpgButton;
    btnResume4: TfpgButton;
    btnStop4: TfpgButton;
    Button3: TfpgButton;
    {@VFD_HEAD_END: Multiplayer}
  public
    procedure AfterCreate; override;
    // constructor Create(AOwner: TComponent);
    procedure btnLoadClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnResumeClick(Sender: TObject);
    procedure ClosePlayer0;

    procedure btnStartClick2(Sender: TObject);
    procedure btnStopClick2(Sender: TObject);
    procedure btnPauseClick2(Sender: TObject);
    procedure btnResumeClick2(Sender: TObject);
    procedure ClosePlayer1;

    procedure btnStartClick3(Sender: TObject);
    procedure btnStopClick3(Sender: TObject);
    procedure btnPauseClick3(Sender: TObject);
    procedure btnResumeClick3(Sender: TObject);
    procedure ClosePlayer2;

    procedure btnStartClick4(Sender: TObject);
    procedure btnStopClick4(Sender: TObject);
    procedure btnPauseClick4(Sender: TObject);
    procedure btnResumeClick4(Sender: TObject);
    procedure ClosePlayer3;

    procedure btnStartClickAll(Sender: TObject);

  end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var
  PlayerIndex0,  PlayerIndex2, PlayerIndex3: Cardinal;
  ordir, opath: string;
  PlayerIndex1 : cardinal;
  //PlayerIndex1 : tuos_player;

  procedure TMultiplayer.AfterCreate;
  begin
    {%region 'Auto-generated GUI code' -fold}


    {@VFD_BODY_BEGIN: Multiplayer}
  Name := 'Multiplayer';
  SetPosition(432, 151, 502, 465);
  WindowTitle := 'Multi Player';
  Hint := '';
  Ondestroy := @btnCloseClick;
  WindowPosition:=wpScreenCenter;

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
    SetPosition(12, 128, 480, 23);
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
    SetPosition(12, 160, 480, 24);
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
    SetPosition(76, 192, 60, 23);
    Text := 'Play';
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
    SetPosition(344, 192, 76, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 7;
    onclick := @btnStopClick;
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

  btnpause := TfpgButton.Create(self);
  with btnpause do
  begin
    Name := 'btnpause';
    SetPosition(168, 192, 52, 23);
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
    SetPosition(248, 192, 64, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 16;
    onclick := @btnResumeClick;
  end;

  FilenameEdit5 := TfpgFileNameEdit.Create(self);
  with FilenameEdit5 do
  begin
    Name := 'FilenameEdit5';
    SetPosition(12, 224, 480, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 14;
  end;

  btnStart2 := TfpgButton.Create(self);
  with btnStart2 do
  begin
    Name := 'btnStart2';
    SetPosition(76, 256, 60, 23);
    Text := 'Play';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 15;
    onclick := @btnstartClick2;
  end;

  btnpause2 := TfpgButton.Create(self);
  with btnpause2 do
  begin
    Name := 'btnpause2';
    SetPosition(168, 256, 52, 23);
    Text := 'Pause';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 16;
    onclick := @btnPauseClick2;
  end;

  btnresume2 := TfpgButton.Create(self);
  with btnresume2 do
  begin
    Name := 'btnresume2';
    SetPosition(248, 256, 64, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 17;
    onclick := @btnResumeClick2;
  end;

  btnStop2 := TfpgButton.Create(self);
  with btnStop2 do
  begin
    Name := 'btnStop2';
    SetPosition(348, 256, 76, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 18;
    onclick := @btnStopClick2;
  end;

  FilenameEdit6 := TfpgFileNameEdit.Create(self);
  with FilenameEdit6 do
  begin
    Name := 'FilenameEdit6';
    SetPosition(12, 288, 480, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 19;
  end;

  btnStart3 := TfpgButton.Create(self);
  with btnStart3 do
  begin
    Name := 'btnStart3';
    SetPosition(76, 320, 60, 23);
    Text := 'Play';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 20;
    onclick := @btnstartClick3;
  end;

  btnPause3 := TfpgButton.Create(self);
  with btnPause3 do
  begin
    Name := 'btnPause3';
    SetPosition(168, 320, 52, 23);
    Text := 'Pause';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 21;
    onclick := @btnPauseClick3;
  end;

  btnResume3 := TfpgButton.Create(self);
  with btnResume3 do
  begin
    Name := 'btnResume3';
    SetPosition(248, 320, 64, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 22;
    onclick := @btnResumeClick3;
  end;

  btnStop3 := TfpgButton.Create(self);
  with btnStop3 do
  begin
    Name := 'btnStop3';
    SetPosition(348, 320, 76, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 23;
    onclick := @btnStopClick3;
  end;

  FilenameEdit7 := TfpgFileNameEdit.Create(self);
  with FilenameEdit7 do
  begin
    Name := 'FilenameEdit7';
    SetPosition(12, 352, 480, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 24;
  end;

  btnStart4 := TfpgButton.Create(self);
  with btnStart4 do
  begin
    Name := 'btnStart4';
    SetPosition(76, 384, 60, 23);
    Text := 'Play';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 25;
    onclick := @btnstartClick4;
  end;

  btnPause4 := TfpgButton.Create(self);
  with btnPause4 do
  begin
    Name := 'btnPause4';
    SetPosition(168, 384, 52, 23);
    Text := 'Pause';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 26;
    onclick := @btnPauseClick4;
  end;

  btnResume4 := TfpgButton.Create(self);
  with btnResume4 do
  begin
    Name := 'btnResume4';
    SetPosition(248, 384, 64, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 27;
    onclick := @btnResumeClick4;
  end;

  btnStop4 := TfpgButton.Create(self);
  with btnStop4 do
  begin
    Name := 'btnStop4';
    SetPosition(348, 384, 76, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 28;
    onclick := @btnStopClick4;
  end;

  Button3 := TfpgButton.Create(self);
  with Button3 do
  begin
    Name := 'Button3';
    SetPosition(68, 425, 360, 23);
    Text := 'Play All Together';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 29;
    onclick := @btnStartClickAll;
  end;

  {@VFD_BODY_END: Multiplayer}
    {%endregion}
    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));

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
   {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/uos', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    FilenameEdit2.FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    FilenameEdit3.FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
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
    {$ENDIF}



    FilenameEdit1.Initialdir := ordir + 'lib';
    FilenameEdit2.Initialdir := ordir + 'lib';
    FilenameEdit3.Initialdir := ordir + 'lib';
    FilenameEdit4.FileName := ordir + 'sound' + directoryseparator + 'test.mp3';
    FilenameEdit5.FileName := ordir + 'sound' + directoryseparator + 'test.ogg';
    FilenameEdit6.FileName := ordir + 'sound' + directoryseparator + 'test.wav';
    FilenameEdit7.FileName := ordir + 'sound' + directoryseparator + 'test.flac';

   //////////////////////////////////////////////////////////////////////////
    end;

  procedure TMultiplayer.btnCloseClick(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
    begin
      uos_stop(PlayerIndex0);
    end;
    if (btnstart2.Enabled = False) then
    begin
    //PlayerIndex1.stop;
     uos_stop(PlayerIndex1);
    end;
    if  (btnstart3.Enabled = False) then
    begin
       uos_stop(PlayerIndex2);
    end;
    if (btnstart4.Enabled = False) then
    begin
       uos_stop(PlayerIndex3);
    end;
    sleep(200);
    if btnLoad.Enabled = False then
      uos_UnloadLib();
  end;

  procedure TMultiplayer.btnLoadClick(Sender: TObject);
  var
    str: string;
  begin

   // Load the libraries
    // function uos_LoadLib(PortAudioFileName: Pchar; SndFileFileName: Pchar; 
    // Mpg123FileName: Pchar) : integer;
    if uos_LoadLib(Pchar(FilenameEdit1.FileName), Pchar(FilenameEdit2.FileName), 
    Pchar(FilenameEdit3.FileName), nil, nil) = 0 then
   begin
      hide;
      Height := 465;
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

  procedure TMultiplayer.ClosePlayer0;
  begin
    btnStart.Enabled := True;
    btnStop.Enabled := False;
    btnPause.Enabled := False;
    btnresume.Enabled := False;
  end;

  procedure TMultiplayer.ClosePlayer1;
  begin
    btnStart2.Enabled := True;
    btnStop2.Enabled := False;
    btnPause2.Enabled := False;
    btnresume2.Enabled := False;
  end;

  procedure TMultiplayer.ClosePlayer2;
  begin
    btnStart3.Enabled := True;
    btnStop3.Enabled := False;
    btnPause3.Enabled := False;
    btnresume3.Enabled := False;
  end;

  procedure TMultiplayer.ClosePlayer3;
  begin
    btnStart4.Enabled := True;
    btnStop4.Enabled := False;
    btnPause4.Enabled := False;
    btnresume4.Enabled := False;
  end;

  procedure TMultiplayer.btnStopClick(Sender: TObject);
  begin
    uos_Stop(PlayerIndex0);
    closeplayer0;
  end;

  procedure TMultiplayer.btnResumeClick(Sender: TObject);
  begin
    uos_Replay(PlayerIndex0);
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := True;
    btnresume.Enabled := False;
  end;

  procedure TMultiplayer.btnPauseClick(Sender: TObject);
  begin
    uos_Pause(PlayerIndex0);
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := False;
    btnresume.Enabled := True;
  end;

  procedure TMultiplayer.btnStartClick(Sender: TObject);
  var
  InIndex : integer ;
  begin
  PlayerIndex0 := 0 ;

     {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
      uos_CreatePlayer(PlayerIndex0);
          {$else}
      uos_CreatePlayer(PlayerIndex0, sender);
      {$ENDIF}

    InIndex :=   uos_AddFromFile(PlayerIndex0, pchar(FilenameEdit4.filename), -1, 0, -1);  ;
     //// add input from audio file with custom parameters
  ////////// FileName : filename of audio file
  //////////// PlayerIndex : Index of a existing Player
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Input Index in array


   uos_AddIntoDevOut(PlayerIndex0, -1, -1, uos_InputGetSampleRate(PlayerIndex0, InIndex), -1, 0, -1);
 //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Output Index in array

   /////// procedure to execute when stream is terminated
     uos_EndProc(PlayerIndex0, @ClosePlayer0);
   ///// Assign the procedure of object to execute at end
   //////////// PlayerIndex : Index of a existing Player
   //////////// ClosePlayer1 : procedure of object to execute inside the loop

    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnpause.Enabled := True;
    btnresume.Enabled := False;

    uos_Play(PlayerIndex0);
    /////// everything is ready, here we are, lets play it...

  end;

  procedure TMultiplayer.btnStopClick2(Sender: TObject);
  begin
  // PlayerIndex1.stop;
  uos_Stop(PlayerIndex1);
//   closeplayer1;
 //    sleep(1000);
   //   PlayerIndex1.stop;
// if assigned(PlayerIndex1) then PlayerIndex1.destroy;
  end;

  procedure TMultiplayer.btnResumeClick2(Sender: TObject);
  begin
  //  uos_RePlay(PlayerIndex1);
    btnStart2.Enabled := False;
    btnStop2.Enabled := True;
    btnPause2.Enabled := True;
    btnresume2.Enabled := False;
  end;

  procedure TMultiplayer.btnPauseClick2(Sender: TObject);
  begin
    // uos_Pause(PlayerIndex1);
    btnStart2.Enabled := False;
    btnStop2.Enabled := True;
    btnPause2.Enabled := False;
    btnresume2.Enabled := True;
  end;

  procedure TMultiplayer.btnStartClick2(Sender: TObject);
  var
  InIndex : integer ;
  begin
  PlayerIndex1 := 1 ;

     {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
  uos_CreatePlayer(PlayerIndex1);
          {$else}
     uos_CreatePlayer(PlayerIndex1, sender);
    
      {$ENDIF}

   InIndex :=   uos_AddFromFile(PlayerIndex1, pchar(FilenameEdit5.filename), -1, 0, -1);  ;
  //// add input from audio file with custom parameters
  ////////// FileName : filename of audio file
  //////////// PlayerIndex : Index of a existing Player
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Input Index in array


  uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, InIndex), -1, 0, -1);
   
 //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Output Index in array

  /////// procedure to execute when stream is terminated
  uos_EndProc(PlayerIndex1, @ClosePlayer1);
     
  ///// Assign the procedure of object to execute at end
   //////////// PlayerIndex : Index of a existing Player
   //////////// ClosePlayer1 : procedure of object to execute inside the loop

    btnStart2.Enabled := False;
    btnStop2.Enabled := True;
    btnpause2.Enabled := True;
    btnresume2.Enabled := False;

    uos_Play(PlayerIndex1);
   ////// Ok let start it

  end;

  procedure TMultiplayer.btnStopClick3(Sender: TObject);
  begin
    uos_Stop(PlayerIndex2);
    closeplayer2;
  end;

  procedure TMultiplayer.btnResumeClick3(Sender: TObject);
  begin
    uos_RePlay(PlayerIndex2);
    btnStart3.Enabled := False;
    btnStop3.Enabled := True;
    btnPause3.Enabled := True;
    btnresume3.Enabled := False;
  end;

  procedure TMultiplayer.btnPauseClick3(Sender: TObject);
  begin
    uos_Pause(PlayerIndex2);
    btnStart3.Enabled := False;
    btnStop3.Enabled := True;
    btnPause3.Enabled := False;
    btnresume3.Enabled := True;
  end;

  procedure TMultiplayer.btnStartClick3(Sender: TObject);
  var
  InIndex : integer ;
  begin
  PlayerIndex2 := 2 ;

     {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
      uos_CreatePlayer(PlayerIndex2);
          {$else}
      uos_CreatePlayer(PlayerIndex2, sender);
      {$ENDIF}

    InIndex :=   uos_AddFromFile(PlayerIndex2, pchar(FilenameEdit6.filename), -1, 0, -1);  ;
     //// add input from audio file with custom parameters
  ////////// FileName : filename of audio file
  //////////// PlayerIndex : Index of a existing Player
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Input Index in array

   uos_AddIntoDevOut(PlayerIndex2, -1, -1, uos_InputGetSampleRate(PlayerIndex2, InIndex), -1, 0, -1);
 //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Output Index in array

  /////// procedure to execute when stream is terminated
        uos_EndProc(PlayerIndex2, @ClosePlayer2);
   ///// Assign the procedure of object to execute at end
   //////////// PlayerIndex : Index of a existing Player
   //////////// ClosePlayer1 : procedure of object to execute inside the loop

    uos_Play(PlayerIndex2);
  ////// Ok let start it


    btnStart3.Enabled := False;
    btnStop3.Enabled := True;
    btnpause3.Enabled := True;
    btnresume3.Enabled := False;
    /////// everything is ready, here we are, lets play it...

  end;

  procedure TMultiplayer.btnStopClick4(Sender: TObject);
  begin
     uos_Stop(PlayerIndex3);
    closeplayer3;
  end;

  procedure TMultiplayer.btnResumeClick4(Sender: TObject);
  begin
     uos_RePlay(PlayerIndex3);
    btnStart4.Enabled := False;
    btnStop4.Enabled := True;
    btnPause4.Enabled := True;
    btnresume4.Enabled := False;
  end;

  procedure TMultiplayer.btnPauseClick4(Sender: TObject);
  begin
    uos_Pause(PlayerIndex3);
    btnStart4.Enabled := False;
    btnStop4.Enabled := True;
    btnPause4.Enabled := False;
    btnresume4.Enabled := True;
  end;

  procedure TMultiplayer.btnStartClick4(Sender: TObject);

  var
  InIndex : integer ;
  begin
  PlayerIndex3 := 3 ;

     {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
      uos_CreatePlayer(PlayerIndex3);
          {$else}
      uos_CreatePlayer(PlayerIndex3, sender);
      {$ENDIF}

    InIndex :=   uos_AddFromFile(PlayerIndex3, pchar(FilenameEdit7.filename), -1, 0, -1);  ;
     //// add input from audio file with custom parameters
  ////////// FileName : filename of audio file
  //////////// PlayerIndex : Index of a existing Player
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Input Index in array


   uos_AddIntoDevOut(PlayerIndex3, -1, -1, uos_InputGetSampleRate(PlayerIndex3, InIndex), -1, 0, -1);
 //// add a Output into device with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  //////////// Device ( -1 is default Output device )
  //////////// Latency  ( -1 is latency suggested ) )
  //////////// SampleRate : delault : -1 (44100)
  //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
  //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (65536)
  //  result : -1 nothing created, otherwise Output Index in array

  /////// procedure to execute when stream is terminated
     uos_EndProc(PlayerIndex3, @ClosePlayer3);
   ///// Assign the procedure of object to execute at end
   //////////// PlayerIndex : Index of a existing Player
   //////////// ClosePlayer1 : procedure of object to execute inside the loop

    uos_Play(PlayerIndex3);
  ////// Ok let start it

    btnStart4.Enabled := False;
    btnStop4.Enabled := True;
    btnpause4.Enabled := True;
    btnresume4.Enabled := False;

    /////// everything is ready, here we are, lets play it...

  end;

  procedure TMultiplayer.btnStartClickAll(Sender: TObject);
  begin
    btnStartClick(self);
    btnStartClick2(self);
    btnStartClick3(self);
    btnStartClick4(self);
  end;

  procedure TMultiplayer.uos_logo(Sender: TObject);
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
    frm: TMultiplayer;
    x : integer;
  begin
    fpgApplication.Initialize;
    frm := TMultiplayer.Create(nil);
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
