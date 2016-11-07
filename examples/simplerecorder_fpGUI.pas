program simplerecorder_fpGUI;

{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
// cmem,
  cthreads,
  cwstring, {$ENDIF} {$ENDIF}
  SysUtils,
  uos_flat,
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

  TSimplerecorder = class(TfpgForm)
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
    procedure VolumeChange(Sender: TObject; pos: integer);
  end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var
  PlayerIndex1: cardinal ;
  ordir, opath: string;
  In1Index : integer;

  procedure TSimplerecorder.btnPlaySavedClick(Sender: TObject);
  begin
  
 if fileexists( Pchar(filenameedit4.FileName)) then begin
     PlayerIndex1 := 1 ; // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
                       // If PlayerIndex exists already, it will be overwritten...

      {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
      uos_CreatePlayer(PlayerIndex1);
          {$else}
      uos_CreatePlayer(PlayerIndex1, sender);
      {$ENDIF}
  //// Create the player.
  //// PlayerIndex : from 0 to what your computer can do !
  //// If PlayerIndex exists already, it will be overwriten...

   uos_AddIntoDevOut(PlayerIndex1); //// add a Output into OUT device with default parameters
    //  uos_AddIntoDevOut(0, -1, -1, -1, -1, 0,-1);   //// add a Output into device with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : -1 default : 65536

  In1Index :=uos_AddFromFile(PlayerIndex1, Pchar(filenameedit4.FileName)); //// add input from audio file with default parameters
  // In1Index := Player1.AddFromFile(0, Edit3.Text, -1, 0);  //// add input from audio file with custom parameters
  //////////// PlayerIndex : Index of a existing Player
  ////////// FileName : filename of audio file
  ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output

 uos_AddDSPVolumeIn(PlayerIndex1, In1Index, 1, 1);
    ///// DSP Volume changer
    //////////// PlayerIndex : Index of a existing Player
    ////////// In1Index : InputIndex of a existing input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume

   uos_SetDSPVolumeIn(PlayerIndex1, In1Index, (100 - TrackBar2.position) / 100,
        (100 - TrackBar3.position) / 100, True); /// Set volume

   /////// procedure to execute when stream is terminated
   uos_EndProc(PlayerIndex1, @ClosePlayer1);
   ///// Assign the procedure of object to execute at end
   //////////// PlayerIndex : Index of a existing Player
   //////////// ClosePlayer1 : procedure of object to execute inside the loop

   uos_Play(PlayerIndex1);  /////// everything is ready to play...

    btnStart.Enabled := False;
    btnStop.Enabled := False;
    button4.Enabled := False;
    button5.Enabled := True;

  end;
  end;

  procedure TSimplerecorder.VolumeChange(Sender: TObject; pos: integer);
  begin
    if (btnstart.Enabled = False) then
      uos_SetDSPVolumeIn(PlayerIndex1, In1Index, (100 - TrackBar2.position) / 100,
        (100 - TrackBar3.position) / 100, True);
    end;


  procedure TSimplerecorder.btnCloseClick(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
    begin
      uos_stop(PlayerIndex1);
      sleep(100);
    end;
    if btnLoad.Enabled = False then
      uos_UnloadLib();
  end;

  procedure TSimplerecorder.btnLoadClick(Sender: TObject);
  var
    str: string;
  begin

    // Load the libraries
    // function uos_LoadLib(PortAudioFileName: PChar; SndFileFileName: PChar;
  // Mpg123FileName: PChar) : integer;
  if uos_LoadLib(Pchar(FilenameEdit1.FileName), Pchar(FilenameEdit2.FileName),nil, nil, nil) = 0 then
  begin
      hide;
      Height := 305;
      btnStart.Enabled := True;
      btnLoad.Enabled := False;
      FilenameEdit1.ReadOnly := True;
      FilenameEdit2.ReadOnly := True;
      UpdateWindowPosition;
      btnLoad.Text := 'PortAudio and SndFile libraries are loaded...';
      WindowPosition := wpScreenCenter;
       fpgapplication.ProcessMessages;
      sleep(500);
      Show;
    end;
  end;

  procedure TSimplerecorder.ClosePlayer1;
  begin
    btnStart.Enabled := True;
    btnStop.Enabled := False;
    button4.Enabled := True;
    button5.Enabled := False;
  end;

  procedure TSimplerecorder.btnStopClick(Sender: TObject);
  begin
    uos_Stop(PlayerIndex1);
    closeplayer1;
  end;

  procedure TSimplerecorder.btnStartClick(Sender: TObject);
  var
    Out1Index, Out2Index: integer;

  begin
    if (checkbox1.Checked = True) or (checkbox2.Checked = True) then
    begin

    PlayerIndex1 := 0 ; // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
                       // If PlayerIndex exists already, it will be overwritten...

     {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
      uos_CreatePlayer(PlayerIndex1);
          {$else}
      uos_CreatePlayer(PlayerIndex1, sender);
      {$ENDIF}
  //// Create the player.
  //// PlayerIndex : from 0 to what your computer can do !
  //// If PlayerIndex exists already, it will be overwriten...

  uos_AddIntoFile(PlayerIndex1, Pchar(filenameEdit4.filename));

      // uos_AddIntoFile(PlayerIndex: cint32; Filename: PChar; SampleRate: cint32;
  //               Channels: cint32; SampleFormat: cint32 ; FramesCount: cint32): cint32;
    //// add Output into wav file (save record)  with default parameters
    // uos_AddIntoDevOut(0, 'test.wav', -1, -1, -1);   //// add a Output into wav file (save record) with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Filename : name of new file for recording
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) ( 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : -1 default : 65536

    if checkbox1.Checked = True then
    uos_AddIntoDevOut(PlayerIndex1);
  
     //// add a Output into OUT device with default parameters
    // Out2Index := uos_AddIntoDevOut(0, -1, -1, -1, -1, 0,-1);   //// add a Output into device with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : -1 default : 65536

    In1Index :=uos_AddFromDevIn(PlayerIndex1);
    
     /// add Input from mic into IN device with default parameters
    //   In1Index := uos_AddFromDevIn(0, -1, -1, -1, -1, -1, 0, -1);   //// add input from mic with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Input device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)
    //////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : -1 default : 4096   ( > = safer, < =  better latency )

 //   uos_AddDSPVolumeIn(PlayerIndex1, In1Index, 1, 1);
    ///// DSP Volume changer
    //////////// PlayerIndex : Index of a existing Player
    ////////// In1Index : InputIndex of a existing input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume

   // uos_SetDSPVolumeIn(PlayerIndex1,  In1Index, (100 - TrackBar2.position) / 100,
   //  (100 - TrackBar3.position) / 100, True);  /// Set volume

   /////// procedure to execute when stream is terminated
     uos_EndProc(PlayerIndex1, @ClosePlayer1);
   ///// Assign the procedure of object to execute at end
   //////////// PlayerIndex : Index of a existing Player
   //////////// ClosePlayer1 : procedure of object to execute inside the loop

    uos_Play(PlayerIndex1);  /////// everything is ready to play...

      CheckBox1.Enabled := True;
      btnStart.Enabled := False;
      btnStop.Enabled := True;
      button5.Enabled := False;
      button4.Enabled := False;
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
    BackgroundColor := clmoneygreen;
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
    CheckBox1.Checked := True;
    CheckBox2.Checked := True;
    Height := 157;
             {$IFDEF Windows}
     {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    FilenameEdit2.FileName := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
{$else}
   FilenameEdit1.FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
   FilenameEdit2.FileName := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
   {$endif}
    FilenameEdit4.FileName := ordir + 'sound\testrecord.wav';
 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/uos', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    FilenameEdit2.FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    FilenameEdit4.FileName := opath + 'sound/testrecord.wav';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    FilenameEdit2.FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
{$else}
    FilenameEdit1.FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
      FilenameEdit2.FileName := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
{$endif}
     FilenameEdit4.FileName := ordir + 'sound/testrecord.wav';
            {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
     FilenameEdit2.FileName := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
      {$else}
   FilenameEdit1.FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
     FilenameEdit2.FileName := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
 {$endif}
     FilenameEdit4.FileName := ordir + 'sound/testrecord.wav';
 {$ENDIF}

    //////////////////////////////////////////////////////////////////////////

    FilenameEdit4.Initialdir := ordir + 'sound';
    FilenameEdit1.Initialdir := ordir + 'lib';
    FilenameEdit2.Initialdir := ordir + 'lib';

  end;

  procedure TSimplerecorder.uos_logo(Sender: TObject);
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
    frm: TSimplerecorder;
  begin
    fpgApplication.Initialize;
    frm := TSimplerecorder.Create(nil);
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
