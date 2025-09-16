program SimplePlayer_MSE;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
{$ifdef mswindows}{$apptype gui}{$endif}
{$endif}

uses
 {$ifdef FPC} {$ifdef unix} cthreads, {$endif} {$endif}
  msegui,
  mainmse_sp,
  SysUtils;

var
  ordir: string;
begin
  application.createform(tmainfo, mainfo);
  ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
     {$IFDEF Windows}
     {$if defined(cpu64)}
     mainfo.padir.value := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
     mainfo.sfdir.value := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
     mainfo.mpdir.value := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
     mainfo.xmdir.value := ordir + 'lib\Windows\64bit\libxmp-64.dll';
     mainfo.stdir.value := ordir + 'lib\Windows\64bit\plugin\LibSoundTouch-64.dll';
     {$else}
    mainfo.padir.value := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    mainfo.sfdir.value := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
    mainfo.mpdir.value := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
    mainfo.m4dir.value := ordir + 'lib\Windows\32bit\LibMp4ff-32.dll';
    mainfo.fadir.value := ordir + 'lib\Windows\32bit\LibFaad2-32.dll';
    mainfo.ofdir.value := ordir + 'lib\Windows\32bit\LibOpusFile-32.dll';
    mainfo.xmdir.value := ordir + 'lib\Windows\32bit\libxmp-32.dll';
    mainfo.stdir.value := ordir + 'lib\Windows\32bit\plugin\libSoundTouch-32.dll';
    mainfo.bsdir.value := ordir + 'lib\Windows\32bit\plugin\LibBs2b-32.dll';
    {$endif}
    mainfo.songdir.value := ordir + 'sound\test.ogg';
 {$ENDIF}

   {$if defined(CPUAMD64) and defined(linux) }
    mainfo.padir.value := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    mainfo.sfdir.value := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    mainfo.mpdir.value := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    mainfo.m4dir.value := ordir + 'lib/Linux/64bit/LibMp4ff-64.so';
    mainfo.fadir.value := ordir + 'lib/Linux/64bit/LibFaad2-64.so';
    mainfo.ofdir.value := ordir + 'lib/Linux/64bit/LibOpusFile-64.so';
    mainfo.xmdir.value := ordir + 'lib/Linux/64bit/libxmp-64.so';
    mainfo.stdir.value := ordir + 'lib/Linux/64bit/plugin/LibSoundTouch-64.so';
    mainfo.bsdir.value := ordir + 'lib/Linux/64bit/plugin/libbs2b-64.so';
    mainfo.songdir.value := ordir + 'sound/test.ogg';
    {$ENDIF}

    {$if defined(CPUAMD64) and defined(openbsd) }
    mainfo.padir.value := ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so';
    mainfo.sfdir.value := ordir + 'lib/OpenBSD/64bit/LibSndFile-64.so';
    mainfo.mpdir.value := ordir + 'lib/OpenBSD/64bit/LibMpg123-64.so';
    mainfo.m4dir.value :=  '' ;
    mainfo.fadir.value := '' ;
    mainfo.ofdir.value :=  '' ;
    mainfo.stdir.value := ordir + 'lib/OpenBSD/64bit/plugin/LibSoundTouch-64.so';
    mainfo.bsdir.value := '' ;
    mainfo.songdir.value := ordir + 'sound/test.ogg';
    {$ENDIF}

     {$if defined(CPUAMD64) and defined(netbsd) }
    mainfo.padir.value := ordir + 'lib/NetBSD/64bit/LibPortaudio-64.so';
    mainfo.sfdir.value := ordir + 'lib/NetBSD/64bit/LibSndFile-64.so';
    mainfo.mpdir.value := ordir + 'lib/NetBSD/64bit/LibMpg123-64.so';
    mainfo.m4dir.value :=  '' ;
    mainfo.fadir.value := '' ;
    mainfo.ofdir.value :=  '' ;
    mainfo.stdir.value := ordir + 'lib/NetBSD/64bit/LibSoundTouch-64.so';
    mainfo.bsdir.value := '' ;
    mainfo.songdir.value := ordir + 'sound/test.ogg';
    {$ENDIF}

     {$if defined(CPUAMD64) and defined(dragonflybsd) }
    mainfo.padir.value := ordir + 'lib/DragonFlyBSD/64bit/LibPortaudio-64.so';
    mainfo.sfdir.value := ordir + 'lib/DragonFlyBSD/64bit/LibSndFile-64.so';
    mainfo.mpdir.value := ordir + 'lib/DragonFlyBSD/64bit/LibMpg123-64.so';
    mainfo.m4dir.value :=  '' ;
    mainfo.fadir.value := '' ;
    mainfo.ofdir.value :=  '' ;
    mainfo.stdir.value := ordir + 'lib/DragonFlyBSD/64bit/LibSoundTouch-64.so';
    mainfo.bsdir.value := '' ;
    mainfo.songdir.value := ordir + 'sound/test.ogg';
    {$ENDIF}
 
{$if defined(cpu86) and defined(linux)}
    mainfo.padir.value := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    mainfo.sfdir.value := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
    mainfo.mpdir.value := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    mainfo.m4dir.value := ordir + 'lib/Linux/32bit/LibMp4ff-32.so';
    mainfo.fadir.value := ordir + 'lib/Linux/32bit/LibFaad2-32.so';
    mainfo.xmdir.value := ordir + 'lib/Linux/32bit/libxmp-32.so';
    mainfo.stdir.value := ordir + 'lib/Linux/32bit/plugin/LibSoundTouch-32.so';
    mainfo.bsdir.value := ordir + 'lib/Linux/32bit/plugin/libbs2b-32.so';
    mainfo.songdir.value := ordir + 'sound/test.ogg';
   {$ENDIF}

   {$if defined(linux) and defined(cpuarm)}
    mainfo.padir.value := ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
    mainfo.sfdir.value := ordir + 'lib/Linux/arm_raspberrypi/libsndfile-arm.so';
    mainfo.mpdir.value := ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so';
    mainfo.xmdir.value := ordir + 'lib/Linux/arm_raspberrypi/libxmp-arm.so';
    mainfo.stdir.value := ordir + 'lib/Linux/arm_raspberrypi/plugin/soundtouch-arm.so';
    mainfo.songdir.value := ordir + 'sound/test.ogg';
   {$ENDIF}

   {$if defined(linux) and defined(cpuaarch64)}
  mainfo.padir.value := ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so';
  mainfo.sfdir.value := ordir + 'lib/Linux/aarch64_raspberrypi/libsndfile_aarch64.so';
  mainfo.mpdir.value := ordir + 'lib/Linux/aarch64_raspberrypi/libmpg123_aarch64.so';
  mainfo.xmdir.value := ordir + 'lib/Linux/aarch64_raspberrypi/libxmp_aarch64.so';
  mainfo.stdir.value := ordir + 'lib/Linux/aarch64_raspberrypi/plugin/libsoundtouch_aarch64.so';
  mainfo.songdir.value := ordir + 'sound/test.ogg';
  {$ENDIF}

  {$IFDEF freebsd}
    {$if defined(cpu64)}
    mainfo.padir.value := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    mainfo.sfdir.value := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    mainfo.mpdir.value := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    mainfo.m4dir.value := ordir + 'lib/FreeBSD/64bit/libmp4ff-64.so';
    mainfo.fadir.value := ordir + 'lib/FreeBSD/64bit/libfaad2-64.so';
    mainfo.bsdir.value := ordir + 'lib/FreeBSD/64bit/plugin/libbs2b-64.so';
    mainfo.stdir.value  := ordir + 'lib/FreeBSD/64bit/plugin/libsoundtouch-64.so';
   
    mainfo.opdir.value := ordir + 'lib/FreeBSD/64bit/libopus-64.so';
   
    {$else}
    mainfo.padir.value := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    mainfo.sfdir.value := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    mainfo.mpdir.value := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
   {$endif}
    mainfo.songdir.value := ordir + 'sound/test.ogg';
 {$ENDIF}
 
 {$IFDEF Darwin}
   {$IFDEF CPU32}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  mainfo.padir.value := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
  mainfo.sfdir.value := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
  mainfo.mpdir.value := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
  mainfo.stdir.value := opath + '/lib/Mac/32bit/plugin/LibSoundTouch-32.dylib';
  mainfo.songdir.value := ordir + '/sound/test.ogg';
   {$ENDIF}
    {$IFDEF CPU64}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  mainfo.padir.value := opath + '/lib/Mac/64bit/LibPortaudio-64.dylib';
  mainfo.sfdir.value := opath + '/lib/Mac/64bit/LibSndFile-64.dylib';
  mainfo.mpdir.value := opath + '/lib/Mac/64bit/LibMpg123-64.dylib';
  mainfo.xmdir.value := opath + '/lib/Mac/64bit/libxmp-64.dylib';
  mainfo.stdir.value := opath + '/lib/Mac/64bit/plugin/libSoundTouchDLL-64.dylib';
  mainfo.songdir.value := ordir + '/sound/test.ogg';
   {$ENDIF}
{$ENDIF}
 
  mainfo.songdir.controller.lastdir := ordir + 'sound';
  mainfo.Height := 400;

  mainfo.vuLeft.Visible := False;

  mainfo.vuRight.Visible := False;

  mainfo.vuright.Height := 0;

  mainfo.vuleft.Height := 0;

  application.run;
end.

