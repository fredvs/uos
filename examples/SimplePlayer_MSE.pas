program SimplePlayer_MSE;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}

uses
 {$ifdef FPC}{$ifdef unix}cthreads,{$endif}{$endif} 
 msegui, mainmse_sp, SysUtils;
 
 var
 ordir: string;
begin
 application.createform(tmainfo,mainfo);
 ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
     {$IFDEF Windows}
     {$if defined(cpu64)}
     mainfo.padir.value := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
     mainfo.sfdir.value := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
     mainfo.mpdir.value := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
     mainfo.stdir.value := ordir + 'lib\Windows\64bit\plugin\LibSoundTouch-64.dll';
{$else}
    mainfo.padir.value := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    mainfo.sfdir.value := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
     mainfo.mpdir.value := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
    mainfo.m4dir.value := ordir + 'lib\Windows\32bit\LibMp4ff-32.dll';
    mainfo.fadir.value := ordir + 'lib\Windows\32bit\LibFaad2-32.dll';
  
    mainfo.ofdir.value := ordir + 'lib\Windows\32bit\LibOpusFile-32.dll';
    
    mainfo.stdir.value := ordir + 'lib\Windows\32bit\plugin\libSoundTouch-32.dll';
    mainfo.bsdir.value := ordir + 'lib\Windows\32bit\plugin\LibBs2b-32.dll';
    
  {$endif}
    mainfo.songdir.value := ordir + 'sound\test.opus';
 {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    mainfo.padir.value := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    mainfo.sfdir.value := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    mainfo.mpdir.value := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    mainfo.m4dir.value := ordir + 'lib/Linux/64bit/LibMp4ff-64.so';
    mainfo.fadir.value := ordir + 'lib/Linux/64bit/LibFaad2-64.so';
   
     mainfo.ofdir.value := ordir + 'lib/Linux/64bit/LibOpusFile-64.so';
    
    mainfo.stdir.value := ordir + 'lib/Linux/64bit/plugin/LibSoundTouch-64.so';
    mainfo.bsdir.value := ordir + 'lib/Linux/64bit/plugin/libbs2b-64.so';
    
{$else}
    mainfo.padir.value := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    mainfo.sfdir.value := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
    mainfo.mpdir.value := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    mainfo.m4dir.value := ordir + 'lib/Linux/32bit/LibMp4ff-32.so';
    mainfo.fadir.value := ordir + 'lib/Linux/32bit/LibFaad2-32.so';
    
    mainfo.stdir.value := ordir + 'lib/Linux/32bit/plugin/LibSoundTouch-32.so';
    mainfo.bsdir.value := ordir + 'lib/Linux/32bit/plugin/libbs2b-32.so';
    
{$endif}
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
   
    mainfo.opdir.value := ordir + 'lib/FreeBSD/64bit/libopus-64.so';
   
    {$else}
    mainfo.padir.value := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    mainfo.sfdir.value := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    mainfo.mpdir.value := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
   {$endif}
    mainfo.songdir.value := ordir + 'sound/test.ogg';
{$ENDIF}
   
   mainfo.songdir.controller.lastdir := ordir + 'sound' ;
mainfo.height := 356 ;
 
mainfo.vuLeft.Visible := False;
     
mainfo.vuRight.Visible := False;
     
mainfo.vuright.Height := 0;
     
mainfo.vuleft.Height := 0;
  
 application.run;
end.
