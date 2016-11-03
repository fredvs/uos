program noiseremove_fpGUI;

{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses
  {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, 
  cwstring, {$ENDIF} {$ENDIF}
  SysUtils,
  uos_flat,
  ctypes, 
  //Math,
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
    Labelsnf: TfpgLabel;
    Labelmpg: TfpgLabel;
    FilenameEdit3: TfpgFileNameEdit;
    btnpause: TfpgButton;
    btnresume: TfpgButton;
    chknoise: TfpgCheckBox;
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
     {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
          {$else}
    procedure CustomMsgReceived(var msg: TfpgMessageRec); message MSG_CUSTOM1;
      {$ENDIF}
    procedure ClosePlayer1;
     procedure ChangeNoise(Sender: TObject);
    end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var
  PlayerIndex1: integer;
  ordir, opath: string;
  OutputIndex1, InputIndex1 : integer;
  

  procedure TSimpleplayer.ChangeNoise(Sender: TObject);
  begin
   if btnStart.Enabled = False then   /// player1 was created
  uos_SetDSPNoiseRemovalIn(PlayerIndex1, InputIndex1, chknoise.Checked);   
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
   
  end;

  
  procedure TSimpleplayer.btnCloseClick(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
    begin
      uos_stop(PlayerIndex1);
       sleep(100);
    end;
    end;

  procedure TSimpleplayer.btnLoadClick(Sender: TObject);
var
loadok : boolean = false;
  begin
    // Load the libraries
// function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName: PChar) : LongInt;
if uos_LoadLib(Pchar(FilenameEdit1.FileName), Pchar(FilenameEdit2.FileName),
 Pchar(FilenameEdit3.FileName), nil, nil) = 0 then
    begin
      hide;
      loadok := true;
      Height := 230;
      btnStart.Enabled := True;
      btnLoad.Enabled := False;
      FilenameEdit1.ReadOnly := True;
      FilenameEdit2.ReadOnly := True;
      FilenameEdit3.ReadOnly := True;
       UpdateWindowPosition;
       btnLoad.Text :=
        'PortAudio, SndFile, Mpg123 libraries are loaded...'
       end else btnLoad.Text :=
        'One or more libraries did not load, check filenames...';
        
             
      WindowPosition := wpScreenCenter;
      WindowTitle := 'Noise Remover.    uos Version ' + inttostr(uos_getversion());
       fpgapplication.ProcessMessages;
      sleep(500);
      Show;
    end;


  procedure TSimpleplayer.ClosePlayer1;
  begin
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

  ///// example how to do custom dsp
  
    procedure TSimpleplayer.btnStartClick(Sender: TObject);
  var
    samformat: shortint;
    
  begin

   
      samformat := 0;
   
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

     InputIndex1 := uos_AddFromFile(PlayerIndex1, pchar(filenameEdit4.filename), -1, 
     samformat, -1);
    //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    //////////// PlayerIndex : Index of a existing Player
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
    //////////// FramesCount : default : -1 (65536 div channels)
    //  result : -1 nothing created, otherwise Input Index in array

    if InputIndex1 > -1 then begin

      // OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1) ;
    //// add a Output into device with default parameters
    OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, InputIndex1),
     uos_InputGetChannels(PlayerIndex1, InputIndex1), samformat, -1);
    //// add a Output into device with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)   /// here default samplerate of input
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Output Index in array

 
  uos_AddDSPNoiseRemovalIn(PlayerIndex1, InputIndex1);
  uos_SetDSPNoiseRemovalIn(PlayerIndex1, InputIndex1, chknoise.Checked);
     /// Add DSP Noise removal. First chunck will be the noise sample.
 
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
  end;


   {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
      {$else}
  procedure TSimpleplayer.CustomMsgReceived(var msg: TfpgMessageRec);
  begin
    ShowLevel;
    ShowPosition ;
    end;

      {$ENDIF}

  procedure TSimpleplayer.AfterCreate;
  begin
    {%region 'Auto-generated GUI code' -fold}


    {@VFD_BODY_BEGIN: Simpleplayer}
  Name := 'Simpleplayer';
  SetPosition(396, 317, 503, 291);
  WindowTitle := 'Noise remover';
  IconName := '';
  BackGroundColor := $80000001;
  Hint := '';
  WindowPosition := wpScreenCenter;
  Ondestroy := @btnCloseClick;

  Custom1 := TfpgWidget.Create(self);
  with Custom1 do
  begin
    Name := 'Custom1';
    SetPosition(10, 16, 115, 107);
    OnPaint := @uos_logo;
  end;

  Labelport := TfpgLabel.Create(self);
  with Labelport do
  begin
    Name := 'Labelport';
    SetPosition(136, 0, 320, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Folder + filename of PortAudio Library';
    Hint := '';
  end;

  btnLoad := TfpgButton.Create(self);
  with btnLoad do
  begin
    Name := 'btnLoad';
    SetPosition(4, 130, 488, 24);
    Text := 'Load that libraries';
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 0;
    Hint := '';
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
    SetPosition(168, 160, 320, 24);
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
    SetPosition(92, 196, 66, 23);
    Text := 'Play';
    Enabled := False;
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 6;
    Hint := '';
    onclick := @btnstartClick;
  end;

  btnStop := TfpgButton.Create(self);
  with btnStop do
  begin
    Name := 'btnStop';
    SetPosition(320, 196, 66, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 7;
    Hint := '';
    onclick := @btnStopClick;
  end;

  Labelsnf := TfpgLabel.Create(self);
  with Labelsnf do
  begin
    Name := 'Labelsnf';
    SetPosition(140, 40, 316, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Folder + filename of SndFile Library';
    Hint := '';
  end;

  Labelmpg := TfpgLabel.Create(self);
  with Labelmpg do
  begin
    Name := 'Labelmpg';
    SetPosition(136, 80, 316, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Folder + filename of Mpg123 Library';
    Hint := '';
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
    SetPosition(168, 196, 66, 23);
    Text := 'Pause';
    Enabled := False;
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 15;
    Hint := '';
    onclick := @btnPauseClick;
  end;

  btnresume := TfpgButton.Create(self);
  with btnresume do
  begin
    Name := 'btnresume';
    SetPosition(244, 196, 66, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 16;
    Hint := '';
    onclick := @btnResumeClick;
  end;

  chknoise := TfpgCheckBox.Create(self);
  with chknoise do
  begin
    Name := 'chknoise';
    SetPosition(20, 160, 136, 19);
    FontDesc := '#Label1';
    ParentShowHint := False;
    TabOrder := 38;
    Text := 'Noise Remover';
    Hint := 'Noise remover';
    OnChange := @Changenoise;
  end;

  {@VFD_BODY_END: Simpleplayer}
    {%endregion}

    //////////////////////

    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
     Height := 159;
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
    FilenameEdit4.FileName := ordir + 'sound\noisyvoice.ogg';
 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/uos', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    FilenameEdit2.FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    FilenameEdit3.FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
    FilenameEdit4.FileName := opath + 'sound/noisyvoice.ogg';
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
    FilenameEdit4.FileName := ordir + 'sound/noisyvoice.ogg';
            {$ENDIF}

  {$IFDEF freebsd}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
     FilenameEdit2.FileName := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
     {$else}
    FilenameEdit1.FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    FilenameEdit2.FileName := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
   
{$endif}
    FilenameEdit4.FileName := ordir + 'sound/noisyvoice.ogg';
{$ENDIF}
    FilenameEdit4.Initialdir := ordir + 'sound';
    FilenameEdit1.Initialdir := ordir + 'lib';
    FilenameEdit2.Initialdir := ordir + 'lib';
    FilenameEdit3.Initialdir := ordir + 'lib';
  

  end;

  procedure TSimpleplayer.uos_logo(Sender: TObject);
   begin
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
    fpgApplication.CreateForm(TSimpleplayer, frm);
    try
     frm.Show;
      fpgApplication.Run;
    finally
      uos_free; // do not forget this...
      frm.Free;
    end;
  end;

begin
  MainProc;
end.
