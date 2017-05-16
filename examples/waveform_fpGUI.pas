program waveform_fpGUI;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX}
  cthreads, {$ENDIF}
  SysUtils,
  Classes,
  fpg_base,
  fpg_main,
  fpg_widget,
  uos_flat,
  ctypes,
  fpg_style_chrome_silver_flatmenu,
  fpg_stylemanager,
  {%units 'Auto-generated GUI code'}
  fpg_form,
  fpg_editbtn,
  fpg_label,
  fpg_button {%endunits};

type

  Twaveform = class(TfpgForm)
  private
    {@VFD_HEAD_BEGIN: waveform}
    FilenameEdit1: TfpgFileNameEdit;
    Label1: TfpgLabel;
    Button1: TfpgButton;
    Custom1: TfpgWidget;
    {@VFD_HEAD_END: waveform}
  public
    procedure AfterCreate; override;
    procedure drawwave(Sender: TObject);
    procedure btnDrawClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure DrawWaveForm;
  end;

var
  opath, fnsf, fnmp, ordir: string;
  PlayerIndex1, In1Index, filelength, framewanted: integer;
  poswav, chan: integer;
  waveformdata: array of cfloat;


  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

  procedure Twaveform.DrawWaveForm;
  begin
     waveformdata := uos_InputGetArrayLevel(PlayerIndex1, In1Index);
    fpgapplication.ProcessMessages;
    button1.tag := 1;
    custom1.Visible := True;

  end;

  procedure Twaveform.btndrawclick(Sender: TObject);
  begin
    custom1.Visible := False;

    windowtitle := 'Wave Form.    uos version ' + IntToStr(uos_getversion());

    PlayerIndex1 := 0;

    //// Create the player.
    uos_CreatePlayer(PlayerIndex1);
    //// PlayerIndex : from 0 to what your computer can do !
    //// If PlayerIndex exists already, it will be overwriten...

    //// add input from audio file with default parameters
    In1Index := uos_AddFromFile(PlayerIndex1, PChar(FilenameEdit1.filename));

    //// no output because only decode the steam for wave form

    /// get the length of the audio file
    filelength := uos_InputLength(PlayerIndex1, In1Index);

    chan := uos_InputGetChannels(PlayerIndex1, In1Index);
    
   // writeln('chan = ' + inttostr(chan));
   //  writeln('filelength = ' + inttostr(filelength));

    ///// set calculation of level/volume into array (usefull for wave form procedure)
    uos_InputSetArrayLevelEnable(PlayerIndex1, In1Index, 2);
    ///////// set level calculation (default is 0)
    // 0 => no calcul
    // 1 => calcul before all DSP procedures.
    // 2 => calcul after all DSP procedures.

    //// determine how much frame will be designed
    framewanted := filelength div custom1.Width;
    uos_InputSetFrameCount(PlayerIndex1, In1Index, framewanted);

     ///// Assign the procedure of object to execute at end of stream
    uos_EndProc(PlayerIndex1, @DrawWaveForm);

    uos_Play(PlayerIndex1);  /////// everything is ready, here we are, lets do it...

  end;

  procedure Twaveform.drawwave(Sender: TObject);
  begin
    if button1.tag = 0 then
      with Custom1 do
      begin
        Canvas.GradientFill(GetClientRect, clgreen, clBlack, gdVertical);
        Canvas.TextColor := clWhite;
        Canvas.DrawText(60, 20, 'uos');
      end
    else
    begin
      Custom1.Canvas.GradientFill(GetClientRect, clwhite, clblack, gdVertical);

      poswav := 0;

      while poswav < length(waveformdata) div chan do
      begin
        if chan = 2 then
        begin
          Custom1.Canvas.setcolor(cldarkgreen);

          Custom1.Canvas.drawLine(poswav, Custom1.Height div 2, poswav, ((Custom1.Height div 2) - 1) - round(
            (waveformdata[poswav * 2]) * (Custom1.Height / 2) - 1));
          Custom1.Canvas.setcolor(clred);
          Custom1.Canvas.drawLine(poswav, (Custom1.Height div 2) + 2, poswav, ((Custom1.Height div 2) + 1) + round(
            (waveformdata[(poswav * 2) + 1]) * (Custom1.Height / 2) + 1));
        end;
        if chan = 1 then
        begin
          Custom1.Canvas.setcolor(cldarkgreen);
          Custom1.Canvas.drawLine(poswav, 0, poswav, ((Custom1.Height) - 1) - round((waveformdata[poswav]) * (Custom1.Height) - 1));
        end;
        Inc(poswav);
      end;
      Custom1.Canvas.TextColor := clBlack;
      Custom1.Canvas.DrawText(60, 20, 'Right Channel');

      Custom1.Canvas.TextColor := clWhite;
      Custom1.Canvas.DrawText(60, Custom1.Height - 40, 'Left Channel');

    end;

  end;

  procedure Twaveform.btnCloseClick(Sender: TObject);
  begin
    uos_UnloadLib();
  end;

  procedure Twaveform.AfterCreate;
  begin
    {%region 'Auto-generated GUI code' -fold}

    {@VFD_BODY_BEGIN: waveform}
    Name := 'waveform';
    SetPosition(267, 185, 841, 475);
    WindowTitle := 'Wave Form';
    IconName := '';
    Hint := '';
    WindowPosition := wpScreenCenter;
    BackgroundColor := clmoneygreen;
    Ondestroy := @btnCloseClick;

    FilenameEdit1 := TfpgFileNameEdit.Create(self);
    with FilenameEdit1 do
    begin
      Name := 'FilenameEdit1';
      SetPosition(28, 28, 360, 24);
      ExtraHint := '';
      FileName := '';
      Filter := '';
      InitialDir := '';
      TabOrder := 1;
    end;

    Label1 := TfpgLabel.Create(self);
    with Label1 do
    begin
      Name := 'Label1';
      SetPosition(164, 12, 80, 15);
      FontDesc := '#Label1';
      Hint := '';
      Text := 'Audio file';
    end;

    Button1 := TfpgButton.Create(self);
    with Button1 do
    begin
      Name := 'Button1';
      SetPosition(400, 28, 412, 23);
      FontDesc := '#Label1';
      Hint := '';
      ImageName := '';
      TabOrder := 3;
      Text := 'Draw Wave Form';
      onclick := @btndrawClick;
    end;

    Custom1 := TfpgWidget.Create(self);
    with Custom1 do
    begin
      Name := 'Custom1';
      SetPosition(2, 68, 836, 404);
      OnPaint := @drawwave;
    end;

    {@VFD_BODY_END: waveform}
    {%endregion}


    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
    //    Height := 197;
             {$IFDEF Windows}
     {$if defined(cpu64)}
    fnsf := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
    fnmp := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';

{$else}
    fnsf := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
    fnmp := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
   {$endif}
    FilenameEdit1.FileName := ordir + 'sound\test.mp3';
 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/uos', opath) - 1);
    fnsf := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    fnmp := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
    FilenameEdit1.FileName := opath + 'sound/test.mp3';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    fnsf := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    fnmp := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  {$else}
    fnsf := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
    fnmp := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
   {$endif}
    FilenameEdit1.FileName := ordir + 'sound/test.mp3';
            {$ENDIF}


 {$IFDEF freebsd}
    {$if defined(cpu64)}
    fnsf := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    fnmp := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
      {$else}
    fnsf := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    fnmp := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
 {$endif}
    FilenameEdit1.FileName := ordir + 'sound/test.mp3';
 {$ENDIF}

    if uos_LoadLib(nil, PChar(fnsf), PChar(fnmp),nil, nil, nil) = 0 then
      button1.Enabled := True
    else
    begin
      button1.Enabled := False;
      button1.Text := 'Error while loading libraries   :-(';
    end;

  end;

  procedure MainProc;
  var
    frm: Twaveform;
  begin
    fpgApplication.Initialize;
    try
      if fpgStyleManager.SetStyle('Chrome silver flat menu') then
          fpgStyle := fpgStyleManager.Style;
      fpgApplication.CreateForm(Twaveform, frm);
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
