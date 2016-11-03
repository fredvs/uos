unit mainmse_sp;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 uos_flat, ctypes,msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,
 msestat,msemenus,msegui,msegraphics,msegraphutils,mseevent,mseclasses,
 msewidgets,mseforms,msesimplewidgets,msedataedits,mseedit,mseificomp,
 mseificompglob,mseifiglob,msestatfile,msestream,msestrings,sysutils,
 msegraphedits,msescrollbar,msefileutils,msemenuwidgets,msegrids,msewidgetgrid,
 msebitmap,msedatanodes,msefiledialog,mselistbrowser,msesys,msesignal,
 msebarcode,msedock,msedragglob;

type
 tmainfo = class(tmainform)
   padir: tfilenameedit;
   btnload: tbutton;
   sfdir: tfilenameedit;
   mpdir: tfilenameedit;
   bsdir: tfilenameedit;
   m4dir: tfilenameedit;
   stdir: tfilenameedit;

   tdockpanel1: tdockpanel;
   tlabel3: tlabel;
   tlabel2: tlabel;
   tlabel1: tlabel;
   TrackBar2: tslider;
   TrackBar3: tslider;
   songdir: tfilenameedit;
   trackbar1: tslider;
   checkbox1: tbooleanedit;
   btnstart: tbutton;
   btnresume: tbutton;
   btnpause: tbutton;
   button1: tbutton;
   label6: tlabel;
   TrackBar4: tslider;
   label7: tlabel;
   TrackBar5: tslider;
   btnstop: tbutton;
   tgroupbox1: tgroupbox;
   radiobutton3: tbooleaneditradio;
   radiobutton2: tbooleaneditradio;
   radiobutton1: tbooleaneditradio;
   fadir: tfilenameedit;
   llength: tlabel;
   lposition: tlabel;
   chkstereo2mono: tbooleanedit;
   chkst2b: tbooleanedit;
   checkbox2: tbooleanedit;
   vuLeft: tdockpanel;
   vuRight: tdockpanel;
   procedure loadlibr(const sender: TObject);
   procedure playit(const sender: TObject);
    procedure ClosePlayer1;
    procedure LoopProcPlayer1;
    procedure ShowPosition;
    procedure ShowLevel;
    procedure changereverse(const Sender: TObject);
    procedure ChangeStereo2Mono(const Sender: TObject);
    procedure ChangePlugSetSoundTouch(const Sender: TObject);
    procedure ChangePlugSetbs2b(const Sender: TObject);
    procedure ResetPlugClick(const Sender: TObject);
   procedure changevolume(const sender: TObject);
   procedure changetempo(const sender: TObject);
   procedure pauseit(const sender: TObject);
   procedure resumeit(const sender: TObject);
   procedure stopit(const sender: TObject);
   procedure closeit(const sender: TObject);
   procedure resetplugst(const sender: TObject);
   procedure changepos(const sender: TObject; var avalue: realty;
                   var accept: Boolean);
 end;
var
 mainfo: tmainfo;
  PlayerIndex1: integer;
  OutputIndex1, InputIndex1, DSPIndex1, DSPIndex2, PluginIndex1, PluginIndex2: integer;
 inputlength : integer;
 plugsoundtouch : boolean = false;
  plugbs2b : boolean = false;
  
implementation
uses
 mainmse_sp_mfm ;
 
  function DSPStereo2Mono(Data: TuosF_Data; fft: TuosF_FFT): TDArFloat;
  var
    x: integer = 0;
    ps: PDArShort;     //////// if input is Int16 format
    pl: PDArLong;      //////// if input is Int32 format
    pf: PDArFloat;     //////// if input is Float32 format
    
    samplef : cFloat;
    samplei : integer;
  begin
   if (Data.channels = 2) then  
  begin
  
   case Data.SampleFormat of
    2:
    begin
      ps := @Data.Buffer;
     while x < Data.OutFrames  do
          begin
        samplei := round((ps^[x] + ps^[x+1])/2);
        ps^[x] := samplei ;
        ps^[x+1] := samplei ;
        x := x + 2;
        end;
     end;
     
    1:
    begin
      pl := @Data.Buffer;
     while x < Data.OutFrames  do
          begin
        samplei := round((pl^[x] + pl^[x+1])/2);   
        pl^[x] := samplei ;
        pl^[x+1] := samplei ;
        x := x + 2;
        end;
     end;
     
    0:
    begin
      pf := @Data.Buffer;
     while x < Data.OutFrames  do
          begin
        samplef := (pf^[x] + pf^[x+1])/2;   
        pf^[x] := samplef ;
        pf^[x+1] := samplef ;
        x := x + 2;
        end;
     end;
        
  
  end;
  Result := Data.Buffer; 
  end 
  else Result := Data.Buffer; 
  end;

 
 function DSPReverseBefore(Data: TuosF_Data; fft: TuosF_FFT): TDArFloat;
  begin
    if Data.position > Data.OutFrames div Data.ratio then
      uos_Seek(PlayerIndex1, InputIndex1, Data.position - 2 - (Data.OutFrames div Data.Ratio));
  end;

  function DSPReverseAfter(Data: TuosF_Data; fft: TuosF_FFT): TDArFloat;
  var
    x: integer = 0;
    arfl: TDArFloat;

  begin
    SetLength(arfl, length(Data.Buffer));
       while x < length(Data.Buffer) + 1 do
          begin
      arfl[x] := Data.Buffer[length(Data.Buffer) - x - 1] ;
      arfl[x+1] := Data.Buffer[length(Data.Buffer) - x ]  ;
         x := x +2;
          end;

    Result := arfl;
  end;
  
 
   procedure tmainfo.ChangePlugSetBs2b(const Sender: TObject);
   begin
  if radiobutton1.enabled = False then   /// player1 was created
  uos_SetPluginBs2b(PlayerIndex1, PluginIndex1, -1, -1, -1, chkst2b.value);   
  application.processmessages;
  end;
  
  procedure tmainfo.Changestereo2mono(const Sender: TObject);
  begin
   if radiobutton1.enabled = False then   /// player1 was created
   uos_SetDSPIn(PlayerIndex1, InputIndex1, DSPIndex2, chkstereo2mono.value); 
  application.processmessages;
  end;

  procedure tmainfo.ChangePlugSetSoundTouch(const Sender: TObject);
  var
    tempo, rate: cfloat;
  begin
         if (trim(Pchar(AnsiString(stdir.value))) <> '') and fileexists(AnsiString(stdir.value)) then
  begin
 
    if 2 - (2 * (TrackBar4.value )) < 0.3 then
      tempo := 0.3
    else
      tempo := 2 - (2 * (TrackBar4.value));
    if 2 - (2 * (TrackBar5.value)) < 0.3 then
      rate := 0.3
    else
      rate := 2 - (2 * (TrackBar5.value));

    label6.caption := 'Tempo: ' + floattostrf(tempo, ffFixed, 15, 1);
    label7.caption := 'Pitch: ' + floattostrf(rate, ffFixed, 15, 1);

    if radiobutton1.Enabled = False then   /// player1 was created
    begin
      uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, tempo, rate, checkbox2.value);
    end;
  application.processmessages;
    end;
  end;

  procedure tmainfo.ResetPlugClick(const Sender: TObject);
  begin
    TrackBar4.value := 0.5;
    TrackBar5.value := 0.5;
    if radiobutton1.Enabled = False then   /// player1 was created
    begin
      uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, 1, 1, checkbox2.value);
    end;
 application.processmessages;
  end;
  
 
  procedure tmainfo.changereverse(const Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
      uos_SetDSPIn(PlayerIndex1, InputIndex1, DSPIndex1, checkbox1.value);
  end;
  
   procedure tmainfo.ShowLevel;
  begin
  
    vuLeft.Visible := True;
    vuRight.Visible := True;
    if round(uos_InputGetLevelLeft(PlayerIndex1, InputIndex1) * 82) >= 0 then
      vuLeft.Height := round(uos_InputGetLevelLeft(PlayerIndex1, InputIndex1) * 82);
    if round(uos_InputGetLevelRight(PlayerIndex1, InputIndex1) * 82) >= 0 then
      vuRight.Height := round(uos_InputGetLevelRight(PlayerIndex1, InputIndex1) * 82);
    vuLeft.top := 105 - vuLeft.Height;
    vuRight.top := 105 - vuRight.Height;
   
  end;
  
  
  
 procedure tmainfo.ShowPosition;
  var
    temptime: ttime;
    ho, mi, se, ms: word;
  begin
  
    if (TrackBar1.Tag = 0) then
    begin
      if uos_InputPosition(PlayerIndex1, InputIndex1) > 0 then
      begin
        TrackBar1.value := uos_InputPosition(PlayerIndex1, InputIndex1) / inputlength;
        temptime := uos_InputPositionTime(PlayerIndex1, InputIndex1);
        ////// Length of input in time
        DecodeTime(temptime, ho, mi, se, ms);
        lposition.caption := format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
      end;
    end;
  
  end;  
  
  
   procedure tmainfo.LoopProcPlayer1;
begin
 ShowPosition;
 ShowLevel ;
end;
 
  
procedure tmainfo.ClosePlayer1;
  begin
    radiobutton1.Enabled := True;
    radiobutton2.Enabled := True;
    radiobutton3.Enabled := True;
     vuLeft.Visible := False;
     vuRight.Visible := False;
     vuright.Height := 0;
     vuleft.Height := 0;
   
    btnStart.Enabled := True;
    btnStop.Enabled := False;
    btnPause.Enabled := False;
    btnresume.Enabled := False;
    trackbar1.value := 0;
    lposition.caption := '00:00:00.000';
  end;
 

procedure tmainfo.loadlibr(const sender: TObject);
var
loadok : boolean = false;
  begin
    // Load the libraries
// function uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName: PChar) : LongInt;

if uos_LoadLib(Pchar(AnsiString(mainfo.padir.value)), Pchar(AnsiString(mainfo.sfdir.value)),
 Pchar(AnsiString(mainfo.mpdir.value)), Pchar(AnsiString(mainfo.m4dir.value)),
 Pchar(AnsiString(mainfo.fadir.value))) = 0 

 then
    begin
      hide;
      loadok := true;
      Height := 515;
      btnStart.Enabled := True;
      btnLoad.Enabled := False;
      
      padir.enabled := false;
      sfdir.enabled := false;
      mpdir.enabled := false;
      m4dir.enabled := false;
      stdir.enabled := false;
      fadir.enabled := false;
      bsdir.enabled := false;

      btnLoad.caption :=
        'PortAudio, SndFile, Mpg123, AAC libraries are loaded...'
       end else btnLoad.caption :=
        'One or more libraries did not load, check filenames...';
        
        if loadok = true then
        begin
           if ((trim(Pchar(AnsiString(mainfo.stdir.value))) <> '') and fileexists(AnsiString(mainfo.stdir.value)))
           
           
       then if (uos_LoadPlugin('soundtouch', Pchar(AnsiString(mainfo.stdir.value))) = 0) then
       begin
     plugsoundtouch := true;
          btnLoad.caption :=
        'PortAudio, SndFile, Mpg123, AAC and Plugin are loaded...';
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
          
      if ((trim(Pchar(AnsiString(mainfo.bsdir.value))) <> '') and fileexists(AnsiString(mainfo.bsdir.value))) 
  
      then if (uos_LoadPlugin('bs2b', Pchar(AnsiString(mainfo.bsdir.value))) = 0)
      then plugbs2b := true else chkst2b.enabled := false; 
          
      mainfo.caption := 'Simple Player.    uos Version ' + inttostr(uos_getversion());
       Show;
    end;
  end;

procedure tmainfo.playit(const sender: TObject);
var
    samformat: shortint;
    temptime: ttime;
    ho, mi, se, ms: word;
  begin

    if radiobutton1.value = True then
      samformat := 0 else
    if radiobutton2.value = True then
      samformat := 1 else
    if radiobutton3.value = True then
      samformat := 2;

    radiobutton1.Enabled := False;
    radiobutton2.Enabled := False;
    radiobutton3.Enabled := False;

    PlayerIndex1 := 0;
    // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
    // If PlayerIndex exists already, it will be overwritten...

      uos_CreatePlayer(PlayerIndex1);
  
    //// Create the player.
    //// PlayerIndex : from 0 to what your computer can do !
    //// If PlayerIndex exists already, it will be overwriten...

     InputIndex1 := uos_AddFromFile(PlayerIndex1, pchar(AnsiString(songdir.value)), -1, samformat, -1);
     
    //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    //////////// PlayerIndex : Index of a existing Player
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
    //////////// FramesCount : default : -1 (65536 div channels)
    //  result : -1 nothing created, otherwise Input Index in array

    if InputIndex1 > -1 then
     begin
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

    uos_InputSetLevelEnable(PlayerIndex1, InputIndex1, 2) ;
     ///// set calculation of level/volume (usefull for showvolume procedure)
                       ///////// set level calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

    uos_InputSetPositionEnable(PlayerIndex1, InputIndex1, 1) ;
     ///// set calculation of position (usefull for positions procedure)
                       ///////// set position calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul position.

    uos_LoopProcIn(PlayerIndex1, InputIndex1, @LoopProcPlayer1);
    ///// Assign the procedure of object to execute inside the loop
    //////////// PlayerIndex : Index of a existing Player
    //////////// InputIndex1 : Index of a existing Input
    //////////// LoopProcPlayer1 : procedure of object to execute inside the loop
   
    uos_AddDSPVolumeIn(PlayerIndex1, InputIndex1, 1, 1);
    ///// DSP Volume changer
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1 : Index of a existing input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume

     uos_SetDSPVolumeIn(PlayerIndex1, InputIndex1,
      TrackBar2.value, TrackBar3.value, True);
     /// Set volume
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1 : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled
  
   DSPIndex1 := uos_AddDSPIn(PlayerIndex1, InputIndex1, @DSPReverseBefore,
     @DSPReverseAfter, nil, nil);
      ///// add a custom DSP procedure for input
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1: InputIndex of existing input
    ////////// BeforeFunc : function to do before the buffer is filled
    ////////// AfterFunc : function to do after the buffer is filled
    ////////// EndedFunc : function to do at end of thread
    ////////// LoopProc : external procedure to do after the buffer is filled
   
   //// set the parameters of custom DSP
   uos_SetDSPIn(PlayerIndex1, InputIndex1, DSPIndex1, checkbox1.value);
    
   // This is a other custom DSP...stereo to mono  to show how to do a DSP ;-)  
    DSPIndex2 := uos_AddDSPIn(PlayerIndex1, InputIndex1, nil, @DSPStereo2Mono, nil, nil);
    uos_SetDSPIn(PlayerIndex1, InputIndex1, DSPIndex2, chkstereo2mono.value); 
   
   ///// add bs2b plugin with samplerate_of_input1 / default channels (2 = stereo)
  if plugbs2b = true then
  begin
   PlugInIndex1 := uos_AddPlugin(PlayerIndex1, 'bs2b',
   uos_InputGetSampleRate(PlayerIndex1, InputIndex1) , -1);
   uos_SetPluginbs2b(PlayerIndex1, PluginIndex1, -1 , -1, -1, chkst2b.value);
  end; 
  
  /// add SoundTouch plugin with samplerate of input1 / default channels (2 = stereo)
  /// SoundTouch plugin should be the last added.
    if plugsoundtouch = true then
  begin
    PlugInIndex2 := uos_AddPlugin(PlayerIndex1, 'soundtouch', 
    uos_InputGetSampleRate(PlayerIndex1, InputIndex1) , -1);
    ChangePlugSetSoundTouch(self); //// custom procedure to Change plugin settings
   end;    
         
    inputlength := uos_InputLength(PlayerIndex1, InputIndex1);
    ////// Length of Input in samples

   temptime := uos_InputLengthTime(PlayerIndex1, InputIndex1);
    ////// Length of input in time

    DecodeTime(temptime, ho, mi, se, ms);
    
    llength.caption := ' / ' + format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
    
     /////// procedure to execute when stream is terminated
    uos_EndProc(PlayerIndex1, @ClosePlayer1);
    ///// Assign the procedure of object to execute at end
    //////////// PlayerIndex : Index of a existing Player
    //////////// ClosePlayer1 : procedure of object to execute inside the general loop

    TrackBar1.value := 0;
    trackbar1.Enabled := True;
    CheckBox1.Enabled := True;

    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnpause.Enabled := True;
    btnresume.Enabled := False;

    uos_Play(PlayerIndex1);  /////// everything is ready, here we are, lets play it...
    end;
  end;

procedure tmainfo.changevolume(const sender: TObject);
begin
  if (btnstart.Enabled = False) then
      uos_SetDSPVolumeIn(PlayerIndex1, InputIndex1,
        ( TrackBar2.value),
        ( TrackBar3.value), True);
end;

procedure tmainfo.changetempo(const sender: TObject);
begin
       if (trim(Pchar(stdir.value)) <> '') and fileexists(stdir.value) then
      ChangePlugSetSoundTouch(Sender);
end;

procedure tmainfo.pauseit(const sender: TObject);
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
end;

procedure tmainfo.resumeit(const sender: TObject);
begin
    uos_RePlay(PlayerIndex1);
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := True;
    btnresume.Enabled := False;
end;

procedure tmainfo.stopit(const sender: TObject);
begin
 uos_Stop(PlayerIndex1);
ClosePlayer1;
end;

procedure tmainfo.closeit(const sender: TObject);
begin
 if (btnstart.Enabled = False) then
    begin
      uos_stop(PlayerIndex1);
      vuLeft.Visible := False;
      vuRight.Visible := False;
      vuright.Height := 0;
      vuleft.Height := 0;
      sleep(100);
    end;
    if btnLoad.Enabled = False then
    begin
      uos_UnloadPlugin('soundtouch');
      uos_UnloadPlugin('bs2b');
    end; 
   // uos_FreePlayer(PlayerIndex1);
   // uosPlayers[PlayerIndex1].destroy; // do not forget this...
    uos_free; // do not forget this...
    
end;

procedure tmainfo.resetplugst(const sender: TObject);
begin
 TrackBar4.value := 0.5;
    TrackBar5.value := 0.5;
    if radiobutton1.Enabled = False then   /// player1 was created
    begin
      uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, 1, 1, checkbox2.value);
    end;
end;

procedure tmainfo.changepos(const sender: TObject; var avalue: realty;
               var accept: Boolean);
begin
   uos_Seek(PlayerIndex1, InputIndex1, round(avalue * inputlength));
end;

end.
