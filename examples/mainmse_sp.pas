unit mainmse_sp;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
  uos_flat,
  ctypes,
  msetypes,
  mseglob,
  mseguiglob,
  mseguiintf,
  mseapplication,
  msestat,
  msemenus,
  msegui,
  msegraphics,
  msegraphutils,
  mseevent,
  mseclasses,
  msewidgets,
  mseforms,
  msesimplewidgets,
  msedataedits,
  mseedit,
  mseificomp,
  mseificompglob,
  mseifiglob,
  msestatfile,
  msestream,
  msestrings,
  SysUtils,
  msegraphedits,
  msescrollbar,
  msefileutils,
  msemenuwidgets,
  msegrids,
  msewidgetgrid,
  msebitmap,
  msedatanodes,
  mselistbrowser,
  msesys,
  msesignal,
  msebarcode,
  msedock,
  msedragglob,
  mseact,
  msedropdownlist,
  msegridsglob,
  msefiledialogx;

type
  tmainfo = class(tmainform)
    btnload: TButton;
    panel1: tdockpanel;
    tlabel3: tlabel;
    tlabel2: tlabel;
    tlabel1: tlabel;
    TrackBar2: tslider;
    TrackBar3: tslider;
    trackbar1: tslider;
    checkbox1: tbooleanedit;
    btnstart: TButton;
    btnresume: TButton;
    btnpause: TButton;
    button1: TButton;
    label6: tlabel;
    TrackBar4: tslider;
    label7: tlabel;
    TrackBar5: tslider;
    btnstop: TButton;
    tgroupbox1: tgroupbox;
    radiobutton3: tbooleaneditradio;
    radiobutton2: tbooleaneditradio;
    radiobutton1: tbooleaneditradio;
    llength: tlabel;
    lposition: tlabel;
    chkstereo2mono: tbooleanedit;
    chkst2b: tbooleanedit;
    checkbox2: tbooleanedit;
    vuLeft: tdockpanel;
    vuRight: tdockpanel;
    padir: tfilenameeditx;
    sfdir: tfilenameeditx;
    mpdir: tfilenameeditx;
    m4dir: tfilenameeditx;
    fadir: tfilenameeditx;
    ofdir: tfilenameeditx;
    xmdir: tfilenameeditx;
    stdir: tfilenameeditx;
    bsdir: tfilenameeditx;
    songdir: tfilenameeditx;
    procedure loadlibr(const Sender: TObject);
    procedure playit(const Sender: TObject);
    procedure ClosePlayer1;
    procedure LoopProcPlayer1;
    procedure ShowPosition;
    procedure ShowLevel;
    procedure changereverse(const Sender: TObject);
    procedure ChangeStereo2Mono(const Sender: TObject);
    procedure ChangePlugSetSoundTouch(const Sender: TObject);
    procedure ChangePlugSetbs2b(const Sender: TObject);
    procedure ResetPlugClick(const Sender: TObject);
    procedure changevolume(const Sender: TObject);
    procedure changetempo(const Sender: TObject);
    procedure pauseit(const Sender: TObject);
    procedure resumeit(const Sender: TObject);
    procedure stopit(const Sender: TObject);
    procedure closeit(const Sender: TObject);
    procedure resetplugst(const Sender: TObject);
    procedure changepos(const Sender: TObject; var avalue: realty; var accept: Boolean);
  end;

var
  mainfo: tmainfo;
  PlayerIndex1: integer;
  OutputIndex1, InputIndex1, DSPIndex1, DSPIndex2, PluginIndex1, PluginIndex2: integer;
  inputlength: integer;
  plugsoundtouch: Boolean = False;
  plugbs2b: Boolean = False;

implementation

uses
  mainmse_sp_mfm;

function DSPStereo2Mono(var Data: TuosF_Data; var fft: TuosF_FFT): TDArFloat;
var
  x: integer = 0;
  ps: PDArShort;     // if input is Int16 format
  pl: PDArLong;      // if input is Int32 format
  pf: PDArFloat;     // if input is Float32 format
  samplef: cFloat;
  samplei: integer;
begin
  if (Data.channels = 2) then
  begin

    case Data.SampleFormat of
      2:
      begin
        ps := @Data.Buffer;
        while x < Data.OutFrames - 1 do
        begin
          samplei    := round((ps^[x] + ps^[x + 1]) / 2);
          ps^[x]     := samplei;
          ps^[x + 1] := samplei;
          x          := x + 2;
        end;
      end;

      1:
      begin
        pl := @Data.Buffer;
        while x < Data.OutFrames - 1 do
        begin
          samplei    := round((pl^[x] + pl^[x + 1]) / 2);
          pl^[x]     := samplei;
          pl^[x + 1] := samplei;
          x          := x + 2;
        end;
      end;

      0:
      begin
        pf := @Data.Buffer;
        while x < Data.OutFrames - 1 do
        begin
          samplef    := (pf^[x] + pf^[x + 1]) / 2;
          pf^[x]     := samplef;
          pf^[x + 1] := samplef;
          x          := x + 2;
        end;
      end;

    end;
    Result := Data.Buffer;
  end
  else
    Result := Data.Buffer;
end;

function DSPReverseBefore(var Data: TuosF_Data; var fft: TuosF_FFT): TDArFloat;
begin

  if (Data.position > Data.OutFrames div Data.channels) then
    uos_InputSeek(PlayerIndex1, InputIndex1, Data.position -
      (Length(Data.buffer) div 4));
end;

function DSPReverseAfter(var Data: TuosF_Data; var fft: TuosF_FFT): TDArFloat;
var
  x: integer = 0;
  arfl: TDArFloat;
begin
  if (Data.position > Data.OutFrames div Data.channels) then
  begin
    SetLength(arfl, Data.outframes);

    while x < (Data.outframes) - 1 do
    begin
      arfl[x]     := Data.Buffer[(Data.outframes) - x - 1];
      arfl[x + 1] := Data.Buffer[(Data.outframes) - x];
      x           := x + 2;
    end;
    Result := arfl;
  end
  else
    Result := Data.Buffer;
end;


procedure tmainfo.ChangePlugSetBs2b(const Sender: TObject);
begin
  uos_SetPluginBs2b(PlayerIndex1, PluginIndex1, -1, -1, -1, chkst2b.Value);
  application.ProcessMessages;
end;

procedure tmainfo.Changestereo2mono(const Sender: TObject);
begin
  uos_InputSetDSP(PlayerIndex1, InputIndex1, DSPIndex2, chkstereo2mono.Value);
  application.ProcessMessages;
end;

procedure tmainfo.ChangePlugSetSoundTouch(const Sender: TObject);
var
  tempo, rate: cfloat;
begin
  if (trim(PChar(ansistring(stdir.Value))) <> '') and fileexists(ansistring(stdir.Value)) then
  begin

    if 2 - (2 * (TrackBar4.Value)) < 0.3 then
      tempo := 0.3
    else
      tempo := 2 - (2 * (TrackBar4.Value));
    if 2 - (2 * (TrackBar5.Value)) < 0.3 then
      rate  := 0.3
    else
      rate  := 2 - (2 * (TrackBar5.Value));

    label6.Caption := 'Tempo: ' + floattostrf(tempo, ffFixed, 15, 1);
    label7.Caption := 'Pitch: ' + floattostrf(rate, ffFixed, 15, 1);

    if radiobutton1.Enabled = False then   // player1 was created
      uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, tempo, rate, checkbox2.Value);
    application.ProcessMessages;
  end;
end;

procedure tmainfo.ResetPlugClick(const Sender: TObject);
begin
  TrackBar4.Value := 0.5;
  TrackBar5.Value := 0.5;
  uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, 1, 1, checkbox2.Value);
  application.ProcessMessages;
end;


procedure tmainfo.changereverse(const Sender: TObject);
begin
  uos_InputSetDSP(PlayerIndex1, InputIndex1, DSPIndex1, checkbox1.Value);
end;

procedure tmainfo.ShowLevel;
begin

  vuLeft.Visible  := True;
  vuRight.Visible := True;
  if round(uos_InputGetLevelLeft(PlayerIndex1, InputIndex1) * 82) >= 0 then
    vuLeft.Height := round(uos_InputGetLevelLeft(PlayerIndex1, InputIndex1) * 82);
  if round(uos_InputGetLevelRight(PlayerIndex1, InputIndex1) * 82) >= 0 then
    vuRight.Height := round(uos_InputGetLevelRight(PlayerIndex1, InputIndex1) * 82);
  vuLeft.top       := 105 - vuLeft.Height;
  vuRight.top      := 105 - vuRight.Height;

end;

procedure tmainfo.ShowPosition;
var
  temptime: ttime;
  ho, mi, se, ms: word;
begin

  if (TrackBar1.Tag = 0) then
    if uos_InputPosition(PlayerIndex1, InputIndex1) > 0 then
    begin
      if inputlength > 0 then
        TrackBar1.Value := uos_InputPosition(PlayerIndex1, InputIndex1) / inputlength;
      temptime          := uos_InputPositionTime(PlayerIndex1, InputIndex1);
      // Length of input in time
      DecodeTime(temptime, ho, mi, se, ms);
      lposition.Caption := format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
    end;

end;


procedure tmainfo.LoopProcPlayer1;
begin
  ShowPosition;
  ShowLevel;
end;


procedure tmainfo.ClosePlayer1;
begin
  radiobutton1.Enabled := True;
  radiobutton2.Enabled := True;
  radiobutton3.Enabled := True;
  vuLeft.Visible       := False;
  vuRight.Visible      := False;
  vuright.Height       := 0;
  vuleft.Height        := 0;

  btnStart.Enabled  := True;
  btnStop.Enabled   := False;
  btnPause.Enabled  := False;
  btnresume.Enabled := False;
  trackbar1.Value   := 0;
  lposition.Caption := '00:00:00.000';
end;


procedure tmainfo.loadlibr(const Sender: TObject);
var
  loadok: Boolean = False;
begin

{$if defined(CPUAMD64) and defined(linux) }
     // For Linux amd64, check libsndfile.so
  if (sfdir.Value <> 'system') and (sfdir.Value <> '') then     
  if uos_TestLoadLibrary(PChar(ansistring(sfdir.Value))) = false then
   begin
   sfdir.Value := sfdir.Value + '.2';
   uos_TestLoadLibrary(PChar(ansistring(sfdir.Value)));
   end;
{$endif}

  // Load the libraries
  // function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName,  opusfilefilename, libxmpfilename: PChar) : LongInt;

  if uos_LoadLib(PChar(ansistring(padir.Value)),
    PChar(ansistring(sfdir.Value)),
    PChar(ansistring(mpdir.Value)),
    PChar(ansistring(m4dir.Value)),
    PChar(ansistring(fadir.Value)),
    PChar(ansistring(ofdir.Value)),
    PChar(ansistring(xmdir.Value))) = 0 then
  begin
    hide;
    loadok         := True;
    Height         := 210;
    panel1.Height  := Height;
    panel1.Width   := Width;
    panel1.left    := 0;
    panel1.top     := 0;
    panel1.Visible := True;

    btnStart.Enabled := True;
    btnLoad.Enabled  := False;

    padir.Enabled := False;
    sfdir.Enabled := False;
    mpdir.Enabled := False;
    m4dir.Enabled := False;
    stdir.Enabled := False;
    fadir.Enabled := False;
    bsdir.Enabled := False;
    ofdir.Enabled := False;
    xmdir.Enabled := False;

    btnLoad.Caption :=
      'PortAudio, SndFile, Mpg123, AAC, Opus, XMP libraries are loaded...';
  end
  else
    btnLoad.Caption :=
      'One or more libraries did not load, check filenames...';

  if loadok = True then
  begin
    if ((trim(PChar(ansistring(stdir.Value))) <> '') and fileexists(ansistring(stdir.Value))) then
      if (uos_LoadPlugin('soundtouch', PChar(ansistring(stdir.Value))) = 0) then
      begin
        plugsoundtouch  := True;
        btnLoad.Caption :=
          'PortAudio, SndFile, Mpg123, AAC, Opus, Xmp and Plugin are loaded...';
      end
      else
      begin
        TrackBar4.Enabled := False;
        TrackBar5.Enabled := False;
        CheckBox2.Enabled := False;
        Button1.Enabled   := False;
        label6.Enabled    := False;
        label7.Enabled    := False;
      end;

    if ((trim(PChar(ansistring(bsdir.Value))) <> '') and fileexists(ansistring(bsdir.Value))) then
      if (uos_LoadPlugin('bs2b', PChar(ansistring(bsdir.Value))) = 0) then
        plugbs2b        := True
      else
        chkst2b.Enabled := False;

    Caption := 'Simple Player.    uos Version ' + IntToStr(uos_getversion());

    Show;
  end;
end;

procedure tmainfo.playit(const Sender: TObject);
var
  samformat, libused, devused: shortint;
  temptime: ttime;
  ho, mi, se, ms: word;
begin

  if radiobutton1.Value = True then
    samformat := 0
  else if radiobutton2.Value = True then
    samformat := 1
  else if radiobutton3.Value = True then
    samformat := 2;

  radiobutton1.Enabled := False;
  radiobutton2.Enabled := False;
  radiobutton3.Enabled := False;

  InputIndex1 := -1;

  PlayerIndex1 := 0;
  // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
  // If PlayerIndex exists already, it will be overwritten...

  if uos_CreatePlayer(PlayerIndex1) then
    // Create the player.
    // PlayerIndex : from 0 to what your computer can do !
    // If PlayerIndex exists already, it will be overwriten...

    InputIndex1 := uos_AddFromFile(PlayerIndex1, PChar(ansistring(songdir.Value)), -1, samformat, 8192 * 4);

  // add input from audio file with custom parameters
  // FileName : filename of audio file
  // PlayerIndex : Index of a existing Player
  // OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
  // SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
  // FramesCount : default : -1 (65536 div channels)
  //  result : -1 nothing created, otherwise Input Index in array

  if InputIndex1 > -1 then
  begin

    devused := -1;

  {$if defined(cpuarm) or defined(cpuaarch64)}  // need a lower latency
   OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, devused, 0.3, 
     uos_InputGetSampleRate(PlayerIndex1, InputIndex1),
     uos_InputGetChannels(PlayerIndex1, InputIndex1), samformat, -1, -1)
  {$else}
    OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, devused, -1,
      uos_InputGetSampleRate(PlayerIndex1, InputIndex1),
      uos_InputGetChannels(PlayerIndex1, InputIndex1), samformat, 8192 * 4, -1);
  {$endif}

    // add a Output into device with custom parameters
    // PlayerIndex : Index of a existing Player
    // Device ( -1 is default Output device )
    // Latency  ( -1 is latency suggested ) )
    // SampleRate : delault : -1 (44100)   // here default samplerate of input
    // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    // SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    // FramesCount : default : -1 (65536)
    // ChunkCount : default : -1 (= 512)
    //  result : -1 nothing created, otherwise Output Index in array

    uos_InputSetLevelEnable(PlayerIndex1, InputIndex1, 2);
    // set calculation of level/volume (usefull for showvolume procedure)
    // set level calculation (default is 0)
    // 0 => no calcul
    // 1 => calcul before all DSP procedures.
    // 2 => calcul after all DSP procedures.
    // 3 => calcul before and after all DSP procedures.

    uos_InputSetPositionEnable(PlayerIndex1, InputIndex1, 1);
    // set calculation of position (usefull for positions procedure)
    // set position calculation (default is 0)
    // 0 => no calcul
    // 1 => calcul position.

    uos_LoopProcIn(PlayerIndex1, InputIndex1, @LoopProcPlayer1);
    // Assign the procedure of object to execute inside the loop
    // PlayerIndex : Index of a existing Player
    // InputIndex1 : Index of a existing Input
    // LoopProcPlayer1 : procedure of object to execute inside the loop

    uos_InputAddDSPVolume(PlayerIndex1, InputIndex1, 1, 1);
    // DSP Volume changer
    // PlayerIndex1 : Index of a existing Player
    // InputIndex1 : Index of a existing input
    // VolLeft : Left volume
    // VolRight : Right volume

    uos_InputSetDSPVolume(PlayerIndex1, InputIndex1, TrackBar2.Value, TrackBar3.Value, True);
    // Set volume
    // PlayerIndex1 : Index of a existing Player
    // InputIndex1 : InputIndex of a existing Input
    // VolLeft : Left volume
    // VolRight : Right volume
    // Enable : Enabled

    DSPIndex1 := uos_InputAddDSP(PlayerIndex1, InputIndex1, @DSPReverseBefore, @DSPReverseAfter, nil, nil);
    // add a custom DSP procedure for input
    // PlayerIndex1 : Index of a existing Player
    // InputIndex1: InputIndex of existing input
    // BeforeFunc : function to do before the buffer is filled
    // AfterFunc : function to do after the buffer is filled
    // EndedFunc : function to do at end of thread
    // LoopProc : external procedure to do after the buffer is filled

    // set the parameters of custom DSP
    uos_InputSetDSP(PlayerIndex1, InputIndex1, DSPIndex1, checkbox1.Value);

    // This is a other custom DSP...stereo to mono  to show how to do a DSP ;-)  
    //  DSPIndex2 := uos_InputAddDSP(PlayerIndex1, InputIndex1, nil, @DSPStereo2Mono, nil, nil);
    //  uos_InputSetDSP(PlayerIndex1, InputIndex1, DSPIndex2, chkstereo2mono.value); 

    // add bs2b plugin with samplerate_of_input1 / default channels (2 = stereo)
    if plugbs2b = True then
    begin
      PlugInIndex1 := uos_AddPlugin(PlayerIndex1, 'bs2b',
        uos_InputGetSampleRate(PlayerIndex1, InputIndex1), -1);
      uos_SetPluginbs2b(PlayerIndex1, PluginIndex1, -1, -1, -1, chkst2b.Value);
    end;

    // add SoundTouch plugin with samplerate of input1 / default channels (2 = stereo)
    // SoundTouch plugin should be the last added.
    if plugsoundtouch = True then
    begin
      PlugInIndex2 := uos_AddPlugin(PlayerIndex1, 'soundtouch',
        uos_InputGetSampleRate(PlayerIndex1, InputIndex1), -1);
      ChangePlugSetSoundTouch(self); // custom procedure to Change plugin settings
    end;

    inputlength := uos_InputLength(PlayerIndex1, InputIndex1);
      // Length of Input in samples

    if inputlength > 0 then // mod's cannot calculate length
    begin 
      trackbar1.enabled := true;
      temptime := uos_InputLengthTime(PlayerIndex1, InputIndex1);
      // Length of input in time

      DecodeTime(temptime, ho, mi, se, ms);

      llength.Caption := ' / ' + format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
    end
    else
    begin
      trackbar1.enabled := false; 
      llength.Caption := ' / ??:??:??.???';
    end;  

    // procedure to execute when stream is terminated
    uos_EndProc(PlayerIndex1, @ClosePlayer1);
    // Assign the procedure of object to execute at end
    // PlayerIndex : Index of a existing Player
    // ClosePlayer1 : procedure of object to execute inside the general loop

    TrackBar1.Value   := 0;
    CheckBox1.Enabled := True;

    btnStop.Enabled   := True;
    btnStart.Enabled  := False;
    btnpause.Enabled  := True;
    btnresume.Enabled := False;

    uos_Play(PlayerIndex1);  // everything is ready, here we are, lets play it...
  end;
end;

procedure tmainfo.changevolume(const Sender: TObject);
begin
  uos_InputSetDSPVolume(PlayerIndex1, InputIndex1, (TrackBar2.Value), (TrackBar3.Value), True);
end;

procedure tmainfo.changetempo(const Sender: TObject);
begin
  if (trim(PChar(stdir.Value)) <> '') and fileexists(stdir.Value) then
    ChangePlugSetSoundTouch(Sender);
end;

procedure tmainfo.pauseit(const Sender: TObject);
begin
  uos_Pause(PlayerIndex1);
  btnStop.Enabled   := True;
  btnPause.Enabled  := False;
  btnresume.Enabled := True;
  vuLeft.Visible    := False;
  vuRight.Visible   := False;
  vuright.Height    := 0;
  vuleft.Height     := 0;
end;

procedure tmainfo.resumeit(const Sender: TObject);
begin
  uos_RePlay(PlayerIndex1);
  btnStop.Enabled   := True;
  btnPause.Enabled  := True;
  btnresume.Enabled := False;
end;

procedure tmainfo.stopit(const Sender: TObject);
begin
  uos_Stop(PlayerIndex1);
  btnStart.Enabled  := True;
  btnStop.Enabled   := False;
  btnResume.Enabled := False;
  btnPause.Enabled  := False;
end;

procedure tmainfo.closeit(const Sender: TObject);
begin
  if (btnstart.Enabled = False) then
  begin
    uos_stop(PlayerIndex1);
    sleep(200);
    application.ProcessMessages;
  end;
  if btnLoad.Enabled = False then
  begin
    uos_UnloadPlugin('soundtouch');
    uos_UnloadPlugin('bs2b');
  end;
  uos_free(); // do not forget this...
end;

procedure tmainfo.resetplugst(const Sender: TObject);
begin
  TrackBar4.Value := 0.5;
  TrackBar5.Value := 0.5;
  uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, 1, 1, checkbox2.Value);
end;

procedure tmainfo.changepos(const Sender: TObject; var avalue: realty; var accept: Boolean);
begin
   if inputlength > 0 then // mod's cannot calculate length
   uos_InputSeek(PlayerIndex1, InputIndex1, round(avalue * inputlength));
end;


end.

