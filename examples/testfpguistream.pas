program testfpgui;

{$mode objfpc}{$H+}
 {$DEFINE UseCThreads}
uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  SysUtils, Classes, fpg_base, fpg_main, math, uos_flat,
  {%units 'Auto-generated GUI code'}
  fpg_form, fpg_button
  {%endunits}
  ;

type
 
  Ttest = class(TfpgForm)
  private
    {@VFD_HEAD_BEGIN: test}
    Button1: TfpgButton;
    {@VFD_HEAD_END: test}
  public
    procedure AfterCreate; override;
    procedure btnStartClick(Sender: TObject);

    procedure btnCloseClick(Sender: TObject);
    procedure ConsolePlay;
  end;

{@VFD_NEWFORM_DECL}

{@VFD_NEWFORM_IMPL}
var
 res: integer;
  ordir, opath, PA_FileName, MP_FileName, theurl : string;
  PlayerIndex1: cardinal = 0;

procedure Ttest.AfterCreate;
begin
  {%region 'Auto-generated GUI code' -fold}

  {@VFD_BODY_BEGIN: test}
  Name := 'test';
  SetPosition(427, 240, 300, 100);
  WindowTitle := 'Internet Radio test';
  IconName := '';
  Hint := '';
  WindowPosition := wpScreenCenter;
  Ondestroy := @btnCloseClick;

  Button1 := TfpgButton.Create(self);
  with Button1 do
  begin
    Name := 'Button1';
    SetPosition(100, 35, 100, 30);
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 1;
    Text := 'Start';
    onClick := @btnStartClick;
  end;

  {@VFD_BODY_END: test}
  {%endregion}
 end;

procedure Ttest.btnStartClick(Sender: TObject);
begin
ConsolePlay;
end;

procedure Ttest.btnCloseClick(Sender: TObject);
  begin
     uos_stop(PlayerIndex1);
          sleep(100);
      uos_UnloadLib();
  end;

 procedure Ttest.ConsolePlay;
  begin

        ordir := (ExtractFilePath(ParamStr(0)));

          {$IFDEF Windows}
     {$if defined(cpu64)}
    PA_FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    MP_FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
{$else}
    PA_FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    MP_FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
   {$endif}
  {$ENDIF}

 {$IFDEF linux}
    {$if defined(cpu64)}
    PA_FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    MP_FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    {$else}
    PA_FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    MP_FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
{$endif}
  {$ENDIF}

{$IFDEF freebsd}
    {$if defined(cpu64)}
   PA_FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
   MP_FileName := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
   {$else}
   PA_FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
   MP_FileName := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
   {$endif}
   {$ENDIF}

            {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    PA_FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    MP_FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
                {$ENDIF}

    PlayerIndex1 := 0;

    // Load the libraries
    res := uos_LoadLib(Pchar(PA_FileName), nil, Pchar(MP_FileName), nil , nil, nil) ;
  //  if res = 0 then  writeln('===> Libraries are loaded.') else  writeln('===> Libraries are NOT loaded.') ;


      uos_CreatePlayer(PlayerIndex1); //// Create the player
 //  writeln('===> uos_CreatePlayer => ok');

    theurl := 'http://broadcast.infomaniak.net:80/alouette-high.mp3';
 // theurl := 'http://broadcast.infomaniak.net/start-latina-high.mp3' ;
 // theurl := 'http://www.hubharp.com/web_sound/BachGavotteShort.mp3' ;
 // theurl := 'http://www.jerryradio.com/downloads/BMB-64-03-06-MP3/jg1964-03-06t01.mp3' ;

      uos_AddFromURL(PlayerIndex1,pchar(theurl)) ;
   //   writeln('===> uos_AddFromURL => ok');

    //// add a Output  => change framecount => 1024
     uos_AddIntoDevOut(PlayerIndex1, -1, -1, -1, -1, -1, 1024);
   //  writeln('===> uos_AddIntoDevOut => ok');

     uos_Play(PlayerIndex1);
end;

procedure MainProc;
var
  frm: Ttest;
begin
  fpgApplication.Initialize;
  try
    frm := Ttest.Create(nil);
    fpgApplication.MainForm := frm;
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
