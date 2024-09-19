unit main_spectrum_mse;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
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
  ctypes,
  msegraphedits,
  mseificomp,
  mseificompglob,
  mseifiglob,
  msescrollbar,
  mseact,
  msebitmap,
  msedataedits,
  msedatanodes,
  msedropdownlist,
  mseedit,
  msefiledialog,
  msegrids,
  mselistbrowser,
  msestatfile,
  msestream,
  msesys,
  SysUtils,
  msesimplewidgets;

type
  tmainfo = class(tmainform)
    tprogressbar1: tprogressbar;
    tprogressbar2: tprogressbar;
    tprogressbar3: tprogressbar;
    tprogressbar4: tprogressbar;
    tprogressbar5: tprogressbar;
    tprogressbar6: tprogressbar;
    tprogressbar7: tprogressbar;
    tprogressbar8: tprogressbar;
    tprogressbar9: tprogressbar;
    tprogressbar10: tprogressbar;
    tfilenameedit1: tfilenameedit;
    button1: TButton;
    tbutton2: TButton;

    label1: tlabel;
    procedure formcreated(const Sender: TObject);

    procedure closeplayer;
    procedure FormDestroy(Sender: TObject);
    procedure LoopProcPlayer;
    procedure button1click(const Sender: TObject);
    procedure butstopclick(const Sender: TObject);
  end;

  equalizer_band_type = record
    lo_freq, hi_freq: integer;
    Text: string[10];
  end;

var
  mainfo: tmainfo;
  Equalizer_Bands: array[1..10] of equalizer_band_type;
  UOSLoaded: Boolean = False;

  res, x, y, z: integer;
  thearray: array of cfloat;
  ordir, SoundFilename, PA_FileName, SF_FileName, MP_FileName: string;
  PlayerIndex1, InputIndex1, OutputIndex1: integer;


implementation

uses
  main_spectrum_mse_mfm,
  uos_flat;

procedure tmainfo.formcreated(const Sender: TObject);
var
  i: integer = 1;
begin

  ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));

 {$IFDEF Windows}
     {$if defined(cpu64)}
    PA_FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    SF_FileName := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
    MP_FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
     {$else}
    PA_FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    SF_FileName := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
    MP_FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
     {$endif}
    SoundFilename := ordir + 'sound\test.mp3';
 {$ENDIF}

     {$if defined(CPUAMD64) and defined(linux) }
  SF_FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
  PA_FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
   MP_FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    SoundFilename := ordir + 'sound/test.mp3';
   {$ENDIF}

    {$if defined(CPUAMD64) and defined(openbsd) }
  SF_FileName := ordir + 'lib/OpenBSD/64bit/LibSndFile-64.so';
  PA_FileName := ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so';
   MP_FileName := ordir + 'lib/OpenBSD/64bit/LibMpg123-64.so';
    SoundFilename := ordir + 'sound/test.mp3';
   {$ENDIF}

   {$if defined(cpu86) and defined(linux)}
    PA_FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    SF_FileName := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
     MP_FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
   SoundFilename := ordir + 'sound/test.mp3';
 {$ENDIF}

  {$if defined(linux) and defined(cpuarm)}
    PA_FileName := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
    SF_FileName := ordir + 'lib/Linux/arm_raspberrypi/libsndfile-arm.so';
     MP_FileName := ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so';
      SoundFilename := ordir + 'sound/test.mp3';
 {$ENDIF}

 {$if defined(linux) and defined(cpuaarch64)}
  PA_FileName := ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so';
  SF_FileName := ordir + 'lib/Linux/aarch64_raspberrypi/libsndfile_aarch64.so';
  MP_FileName := ordir + 'lib/Linux/aarch64_raspberrypi/libmpg123_aarch64.so';
  SoundFilename := ordir + 'sound/test.mp3';
  {$ENDIF}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    SF_FileName := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
     MP_FileName := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    {$else}
    PA_FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    SF_FileName := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
      MP_FileName := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
    {$endif}
    SoundFilename := ordir + 'sound/test.mp3';
 {$ENDIF}

 {$IFDEF Darwin}
   {$IFDEF CPU32}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  PA_FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  SF_FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
  MP_FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
  SoundFilename := ordir + '/sound/test.ogg';
   {$ENDIF}
    {$IFDEF CPU64}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  PA_FileName := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
  SF_FileName := opath + '/lib/Mac/64bit/LibSndFile-64.dylib';
  MP_FileName := opath + '/lib/Mac/64bit/LibMpg123-64.dylib';
  SoundFilename := ordir + '/sound/test.ogg';
   {$ENDIF}
    {$ENDIF}
    
{$if defined(CPUAMD64) and defined(linux) }
     // For Linux amd64, check libsndfile.so
  if SF_FileName <> 'system' then     
  if uos_TestLoadLibrary(PChar(SF_FileName)) = false then
   SF_FileName := SF_FileName + '.2';
{$endif}

  tfilenameedit1.Value := SoundFilename;

  res := uos_LoadLib(PChar(PA_FileName), PChar(SF_FileName), PChar(MP_FileName), nil, nil, nil,nil);

  if Res <> 0 then
  begin
    label1.Caption  := 'UOS libraries in Error';
    Button1.Enabled := False;
  end
  else
    Button1.Enabled := True;

  Equalizer_Bands[1].lo_freq  := 18;
  Equalizer_Bands[1].hi_freq  := 46;
  Equalizer_Bands[1].Text     := '31.25';
  Equalizer_Bands[2].lo_freq  := 47;
  Equalizer_Bands[2].hi_freq  := 94;
  Equalizer_Bands[2].Text     := '62.5';
  Equalizer_Bands[3].lo_freq  := 95;
  Equalizer_Bands[3].hi_freq  := 188;
  Equalizer_Bands[3].Text     := '125';
  Equalizer_Bands[4].lo_freq  := 189;
  Equalizer_Bands[4].hi_freq  := 375;
  Equalizer_Bands[4].Text     := '250';
  Equalizer_Bands[5].lo_freq  := 376;
  Equalizer_Bands[5].hi_freq  := 750;
  Equalizer_Bands[5].Text     := '500';
  Equalizer_Bands[6].lo_freq  := 751;
  Equalizer_Bands[6].hi_freq  := 1500;
  Equalizer_Bands[6].Text     := '1K';
  Equalizer_Bands[7].lo_freq  := 1501;
  Equalizer_Bands[7].hi_freq  := 3000;
  Equalizer_Bands[7].Text     := '2K';
  Equalizer_Bands[8].lo_freq  := 3001;
  Equalizer_Bands[8].hi_freq  := 6000;
  Equalizer_Bands[8].Text     := '4K';
  Equalizer_Bands[9].lo_freq  := 6001;
  Equalizer_Bands[9].hi_freq  := 12000;
  Equalizer_Bands[9].Text     := '8K';
  Equalizer_Bands[10].lo_freq := 12001;
  Equalizer_Bands[10].hi_freq := 20000;
  Equalizer_Bands[10].Text    := '16K';

  while i < 11 do
  begin
    TProgressBar(findcomponent('tprogressbar' + IntToStr(i))).frame.Caption :=
      Equalizer_Bands[i].Text;
    Inc(i);
  end;
end;

procedure tmainfo.button1click(const Sender: TObject);
var
  i: integer;
begin

  PlayerIndex1 := 0;

  SoundFilename := tfilenameedit1.Value;

  if uos_CreatePlayer(PlayerIndex1) then
  begin
    InputIndex1 := uos_AddFromFile(PlayerIndex1, (PChar(SoundFilename)), -1, -1, 4096);

    if InputIndex1 > -1 then
    begin

      OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, -1, 0.3, -1, -1, -1, 4096, -1);

      if OutputIndex1 > -1 then
      begin
        // Spectrum : create  bandpass filters with alsobuf set to false, how many you want:
        for i := 1 to 10 do
            uos_InputAddFilter(PlayerIndex1, InputIndex1,
            3, Equalizer_Bands[i].lo_freq, Equalizer_Bands[i].hi_freq, 1,
            3, Equalizer_Bands[i].lo_freq, Equalizer_Bands[i].hi_freq, 1, False, nil);
       
        uos_EndProc(PlayerIndex1, @ClosePlayer);
        
        uos_LoopProcIn(PlayerIndex1, InputIndex1, @LoopProcPlayer);
        /////// everything is ready, here we are, lets play it...
        uos_Play(PlayerIndex1);
        Button1.Enabled := False;
      end;
    end;
  end;
end;

procedure tmainfo.ClosePlayer;
begin
  button1.Enabled := True;
end;

procedure tmainfo.FormDestroy(Sender: TObject);
begin
  uos_stop(PlayerIndex1);
  uos_free();
end;

procedure tmainfo.LoopProcPlayer;
var
  i: integer;
  v: cfloat;
begin
  if uos_getstatus(PlayerIndex1) > 0 then
  begin
    i        := 1;
    thearray := uos_InputFiltersGetLevelArray(PlayerIndex1, InputIndex1);
    x        := 0;
    while x < length(thearray) - 1 do
    begin
      if i <= 10 then
      begin
        v := (thearray[x] + thearray[x + 1]) / 2;
        TProgressBar(findcomponent('Tprogressbar' + IntToStr(i))).Value := v;
      end;
      x := x + 2;
      Inc(i);
    end;
  end;
end;

procedure tmainfo.butstopclick(const Sender: TObject);
begin
  uos_stop(PlayerIndex1);
end;

end.

