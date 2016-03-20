program librarytester_fpGUI;

{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses
  {$IFDEF UNIX} 
  cthreads,
  cwstring,
  {$ENDIF}
  SysUtils,
    dynlibs,
  uos_bs2b,
  ctypes,
  Math,
  Classes,
  fpg_button,
  fpg_widget,
  fpg_label,
  fpg_Editbtn,
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
    Labelsnf: TfpgLabel;
    Labelmpg: TfpgLabel;
    Labelst: TfpgLabel;
    FilenameEdit3: TfpgFileNameEdit;
    FilenameEdit5: TfpgFileNameEdit;
    {@VFD_HEAD_END: Simpleplayer}
  public
    procedure AfterCreate; override;
     procedure btnCloseClick(Sender: TObject);
     procedure btnLoadClick(Sender: TObject);
     end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var
 ordir, opath: string;
 Pa_Handle:TLibHandle=dynlibs.NilHandle;

procedure TSimpleplayer.btnCloseClick(Sender: TObject);
  begin
  	if Pa_Handle <> DynLibs.NilHandle then   DynLibs.UnloadLibrary(Pa_Handle);
    Pa_Handle:=DynLibs.NilHandle;
  end;

  procedure TSimpleplayer.btnLoadClick(Sender: TObject);

  begin

    Pa_Handle:=DynLibs.SafeLoadLibrary(FilenameEdit1.FileName); // obtain the handle we want
  	if Pa_Handle <> DynLibs.NilHandle then

                        btnLoad.Text :=  'PortAudio=OK '
           else btnLoad.Text := 'PortAudio not load ';

    	if Pa_Handle <> DynLibs.NilHandle then  DynLibs.UnloadLibrary(Pa_Handle);

      Pa_Handle:=DynLibs.SafeLoadLibrary(FilenameEdit2.FileName); // obtain the handle we want
  	if Pa_Handle <> DynLibs.NilHandle then
                        btnLoad.Text := btnLoad.Text + 'SndFile=OK '
           else btnLoad.Text := btnLoad.Text + 'SndFile not load ' ;

    	if Pa_Handle <> DynLibs.NilHandle then DynLibs.UnloadLibrary(Pa_Handle);

      Pa_Handle:=DynLibs.SafeLoadLibrary(FilenameEdit3.FileName); // obtain the handle we want
  	if Pa_Handle <> DynLibs.NilHandle then
                        btnLoad.Text := btnLoad.Text + 'MPG123=OK '
           else btnLoad.Text := btnLoad.Text + 'MPG123 not load ' ;

    	if Pa_Handle <> DynLibs.NilHandle then  DynLibs.UnloadLibrary(Pa_Handle);

      Pa_Handle:=DynLibs.SafeLoadLibrary(FilenameEdit5.FileName); // obtain the handle we want
  	if Pa_Handle <> DynLibs.NilHandle then
                        btnLoad.Text := btnLoad.Text + 'SoundTouch=OK'
           else btnLoad.Text := btnLoad.Text + 'SoundTouch not load' ;

    	if Pa_Handle <> DynLibs.NilHandle then DynLibs.UnloadLibrary(Pa_Handle);

  end;

  procedure TSimpleplayer.AfterCreate;
  begin
    {%region 'Auto-generated GUI code' -fold}

    {@VFD_BODY_BEGIN: Simpleplayer}
  Name := 'Simpleplayer';
  SetPosition(491, 214, 502, 206);
  WindowTitle := 'Libraries Tester';
  IconName := '';
  BackGroundColor := $80000001;
  Hint := '';
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
    ParentShowHint := False;
    Text := 'Folder + filename of PortAudio Library';
    Hint := '';
  end;

  btnLoad := TfpgButton.Create(self);
  with btnLoad do
  begin
    Name := 'btnLoad';
    SetPosition(16, 168, 476, 31);
    Text := 'Test to load that libraries';
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

  Labelst := TfpgLabel.Create(self);
  with Labelst do
  begin
    Name := 'Labelst';
    SetPosition(136, 120, 316, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Folder + filename of SoundTouch Library';
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

  {@VFD_BODY_END: Simpleplayer}
    {%endregion}

    //////////////////////

    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
    Height := 197;
             {$IFDEF Windows}
     {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    FilenameEdit2.FileName := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
    FilenameEdit5.FileName := ordir + 'lib\Windows\64bit\LibSoundTouch-64.dll';
{$else}
    FilenameEdit1.FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    FilenameEdit2.FileName := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
    FilenameEdit5.FileName := ordir + 'lib\Windows\32bit\LibSoundTouch-32.dll';
   {$endif}

 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/uos', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    FilenameEdit2.FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    FilenameEdit3.FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
    FilenameEdit5.FileName := opath + '/lib/Mac/32bit/LibSoundTouch-32.dylib';

            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    FilenameEdit2.FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    FilenameEdit5.FileName := ordir + 'lib/Linux/64bit/LibSoundTouch-64.so';
{$else}
    FilenameEdit1.FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    FilenameEdit2.FileName := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    FilenameEdit5.FileName := ordir + 'lib/Linux/32bit/LibSoundTouch-32.so';
{$endif}

            {$ENDIF}

  {$IFDEF freebsd}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
     FilenameEdit2.FileName := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    FilenameEdit5.FileName := ordir + 'lib/FreeBSD/64bit/LibSoundTouch-64.so';
    {$else}
   FilenameEdit1.FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
     FilenameEdit2.FileName := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
    FilenameEdit5.FileName := ordir + 'lib/FreeBSD/32bit/LibSoundTouch-32.so';
{$endif}

 {$ENDIF}

    FilenameEdit1.Initialdir := ordir + 'lib';
    FilenameEdit2.Initialdir := ordir + 'lib';
    FilenameEdit3.Initialdir := ordir + 'lib';
    FilenameEdit5.Initialdir := ordir + 'lib';

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
 //   frm := TSimpleplayer.Create(nil);
       fpgApplication.CreateForm(TSimpleplayer, frm);
    try
      frm.Show;
      fpgApplication.Run;
    finally
      frm.Free;
    end;
  end;

begin
  MainProc;
end.
