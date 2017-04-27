program deviceinfos_fpGUI;

{$mode objfpc}{$H+}

 uses
{$IFDEF UNIX}
  cthreads, 
  cwstring, 
 {$ENDIF}
    SysUtils,
  fpg_base,
  fpg_main,
  fpg_form,
  uos_flat,
  fpg_style_chrome_silver_flatmenu,
  fpg_stylemanager,
  Classes,
  fpg_button,
  fpg_widget,
  fpg_label,
  fpg_Editbtn,
  fpg_grid
  { you can add units after this };

type

  TDevicesInfos = class(TfpgForm)
    procedure UOS_logo(Sender: TObject);
  private
    {@VFD_HEAD_BEGIN: DevicesInfos}
    infos_grid: TfpgStringGrid;
    Custom1: TfpgWidget;
    Labelport: TfpgLabel;
    btnLoad: TfpgButton;
    FilenameEdit1: TfpgFileNameEdit;
    btnReLoad: TfpgButton;
    Label1: TfpgLabel;
    Label2: TfpgLabel;
    Label3: TfpgLabel;
    {@VFD_HEAD_END: DevicesInfos}
  public
    procedure AfterCreate; override;

    procedure btnLoadClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    procedure btnReLoadClick(Sender: TObject);
    procedure CheckInfos();
  end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var
   ordir: string;

  procedure TDevicesInfos.CheckInfos();
  var
    x: integer;
  begin

    UOS_GetInfoDevice();

    label1.Text := 'Devices Count = ' + IntToStr(UOSDeviceCount);

    label2.Text := 'Def Dev IN = ' + IntToStr(UOSDefaultDeviceIN);

    label3.Text := 'Def Dev OUT = ' + IntToStr(UOSDefaultDeviceOUT);

    infos_grid.rowcount := UOSDeviceCount;
    x := 0;

    while x < UOSDeviceCount do
    begin

      infos_grid.Cells[0, x] := IntToStr(UOSDeviceInfos[x].DeviceNum);
      infos_grid.Cells[1, x] := UOSDeviceInfos[x].DeviceName;
      if UOSDeviceInfos[x].DefaultDevIn = True then
        infos_grid.Cells[2, x] := 'Yes'
      else
        infos_grid.Cells[2, x] := 'No';

      if UOSDeviceInfos[x].DefaultDevOut = True then
        infos_grid.Cells[3, x] := 'Yes'
      else
        infos_grid.Cells[3, x] := 'No';

      infos_grid.Cells[4, x] := IntToStr(UOSDeviceInfos[x].ChannelsIn);
      infos_grid.Cells[5, x] := IntToStr(UOSDeviceInfos[x].ChannelsOut);
      infos_grid.Cells[6, x] := floattostrf(UOSDeviceInfos[x].SampleRate, ffFixed, 15, 0);
      infos_grid.Cells[7, x] := floattostrf(UOSDeviceInfos[x].LatencyHighIn, ffFixed, 15, 8);
      infos_grid.Cells[8, x] := floattostrf(UOSDeviceInfos[x].LatencyHighOut, ffFixed, 15, 8);
      infos_grid.Cells[9, x] := floattostrf(UOSDeviceInfos[x].LatencyLowIn, ffFixed, 15, 8);
      infos_grid.Cells[10, x] := floattostrf(UOSDeviceInfos[x].LatencyLowOut, ffFixed, 15, 8);
      infos_grid.Cells[11, x] := UOSDeviceInfos[x].HostAPIName;
      infos_grid.Cells[12, x] := UOSDeviceInfos[x].DeviceType;
      Inc(x);
    end;
  end;


  procedure TDevicesInfos.CloseClick(Sender: TObject);
  begin
    if btnLoad.Enabled = False then
      uos_UnloadLib();
  end;

  procedure TDevicesInfos.btnLoadClick(Sender: TObject);
   begin
      // Load the library
  // function uos_LoadLib(PortAudioFileName: PChar; SndFileFileName: PChar;
  // Mpg123FileName, opusfilefilename: PChar) : integer;
   if uos_LoadLib(pchar( FilenameEdit1.FileName), nil, nil, nil, nil, nil) = 0 then
      begin
      hide;
      Height := 385;
      btnReLoad.Enabled := True;
      btnLoad.Enabled := False;
      FilenameEdit1.ReadOnly := True;
      UpdateWindowPosition;
      btnLoad.Text := 'PortAudio library is loaded...';
      CheckInfos();
      WindowPosition := wpScreenCenter;
      fpgapplication.ProcessMessages;
      sleep(500);
      Show;
    end;
  end;

  procedure TDevicesInfos.btnReLoadClick(Sender: TObject);

  begin
    CheckInfos();
  end;


  procedure TDevicesInfos.AfterCreate;
  begin
    {%region 'Auto-generated GUI code' -fold}



    {@VFD_BODY_BEGIN: DevicesInfos}
  Name := 'DevicesInfos';
  SetPosition(320, 168, 502, 385);
  WindowTitle := 'Devices Infos ';
  Hint := '';
  BackGroundColor := $80000001;
  WindowPosition := wpScreenCenter;
  Ondestroy := @CloseClick;

  infos_grid := TfpgStringGrid.Create(self);
  with infos_grid do
  begin
    Name := 'infos_grid';
    SetPosition(10, 160, 480, 180);
    BackgroundColor := TfpgColor($80000002);
    FontDesc := '#Grid';
    HeaderFontDesc := '#GridHeader';
    Hint := '';
    RowCount := 1;
    ColumnCount := 0;
    RowSelect := False;
    TabOrder := 0;
    AddColumn('Dev', 40);
    AddColumn('Name', 200);
    AddColumn('Default IN', 80);
    AddColumn('Default OUT', 80);
    AddColumn('Chan IN', 60);
    AddColumn('Chan OUT', 60);
    AddColumn('S Rate', 63);
    AddColumn('Latency High In', 120);
    AddColumn('Latency High Out', 120);
    AddColumn('Latency Low In', 120);
    AddColumn('Latency Low Out', 120);
    AddColumn('Host API', 80);
    AddColumn('Type', 80);
    DefaultRowHeight := 24;
  end;

  Custom1 := TfpgWidget.Create(self);
  with Custom1 do
  begin
    Name := 'Custom1';
    SetPosition(10, 8, 115, 115);
    OnPaint := @UOS_logo;
  end;

  Labelport := TfpgLabel.Create(self);
  with Labelport do
  begin
    Name := 'Labelport';
    SetPosition(136, 40, 320, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Folder + filename of PortAudio Library';
  end;

  btnLoad := TfpgButton.Create(self);
  with btnLoad do
  begin
    Name := 'btnLoad';
    SetPosition(16, 128, 470, 23);
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 0;
    Text := 'Load that library';
    onclick := @btnLoadClick;
  end;

  FilenameEdit1 := TfpgFileNameEdit.Create(self);
  with FilenameEdit1 do
  begin
    Name := 'FilenameEdit1';
    SetPosition(136, 56, 356, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 3;
  end;

  btnReLoad := TfpgButton.Create(self);
  with btnReLoad do
  begin
    Name := 'btnReLoad';
    SetPosition(430, 353, 60, 23);
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 6;
    Text := 'Re-load';
    onclick := @btnReLoadClick;
  end;

  Label1 := TfpgLabel.Create(self);
  with Label1 do
  begin
    Name := 'Label1';
    SetPosition(15, 355, 120, 20);
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Devices Count';
  end;

  Label2 := TfpgLabel.Create(self);
  with Label2 do
  begin
    Name := 'Label2';
    SetPosition(155, 355, 120, 20);
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Default Dev IN';
  end;

  Label3 := TfpgLabel.Create(self);
  with Label3 do
  begin
    Name := 'Label3';
    SetPosition(290, 355, 120, 20);
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Default Dev OUT';
  end;

  {@VFD_BODY_END: DevicesInfos}
    {%endregion}


    //////////////////////

    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
    Height := 157;
             {$IFDEF Windows}
     {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
{$else}
    FilenameEdit1.FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
   {$endif}

 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/UOS', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';

            {$ENDIF}

{$IFDEF freebsd}
    {$if defined(cpu64)}
   FilenameEdit1.FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    {$else}
   FilenameEdit1.FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
 {$endif}
  {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + '/lib/Linux/64bit/LibPortaudio-64.so';
{$else}
    FilenameEdit1.FileName := ordir + '/lib/Linux/32bit/LibPortaudio-32.so';
{$endif}

            {$ENDIF}
    //////////////////////////////////////////////////////////////////////////

    FilenameEdit1.Initialdir := ordir + 'lib';

     end;

  procedure TDevicesInfos.UOS_logo(Sender: TObject);
  begin

    with Custom1 do
    begin
      Canvas.GradientFill(GetClientRect, clgreen, clBlack, gdVertical);
      Canvas.TextColor := clWhite;
      Canvas.DrawText(60, 20, 'UOS');
    end;
  end;

  procedure MainProc;
  var
    frm: TDevicesInfos;
  begin
    fpgApplication.Initialize;
      if fpgStyleManager.SetStyle('Chrome silver flat menu') then
          fpgStyle := fpgStyleManager.Style;
    frm := TDevicesInfos.Create(nil);
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
