program multiplayer_fpGUI;
{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses

  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,  cwstring,
  {$ENDIF}{$ENDIF}
   SysUtils,uos, ctypes, Math,  Classes,fpg_button, fpg_widget, fpg_label, fpg_Editbtn, fpg_RadioButton, fpg_trackbar, fpg_CheckBox, fpg_base, fpg_main, fpg_form
  { you can add units after this };

type

  TMultiplayer = class(TfpgForm)
  procedure UOS_logo(Sender: TObject);
  private
    {@VFD_HEAD_BEGIN: Multiplayer}
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
    FilenameEdit5: TfpgFileNameEdit;
    btnStart2: TfpgButton;
    btnpause2: TfpgButton;
    btnresume2: TfpgButton;
    btnStop2: TfpgButton;
    FilenameEdit6: TfpgFileNameEdit;
    btnStart3: TfpgButton;
    btnPause3: TfpgButton;
    btnResume3: TfpgButton;
    btnStop3: TfpgButton;
    FilenameEdit7: TfpgFileNameEdit;
    btnStart4: TfpgButton;
    btnPause4: TfpgButton;
    btnResume4: TfpgButton;
    btnStop4: TfpgButton;
    Button3: TfpgButton;
    {@VFD_HEAD_END: Multiplayer}
  public
     procedure AfterCreate; override;
   // constructor Create(AOwner: TComponent);
    procedure btnLoadClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
     procedure btnPauseClick(Sender: TObject);
      procedure btnResumeClick(Sender: TObject);
           procedure ClosePlayer1;

             procedure btnStartClick2(Sender: TObject);
    procedure btnStopClick2(Sender: TObject);
     procedure btnPauseClick2(Sender: TObject);
      procedure btnResumeClick2(Sender: TObject);
           procedure ClosePlayer2;

             procedure btnStartClick3(Sender: TObject);
    procedure btnStopClick3(Sender: TObject);
     procedure btnPauseClick3(Sender: TObject);
      procedure btnResumeClick3(Sender: TObject);
           procedure ClosePlayer3;

             procedure btnStartClick4(Sender: TObject);
    procedure btnStopClick4(Sender: TObject);
     procedure btnPauseClick4(Sender: TObject);
      procedure btnResumeClick4(Sender: TObject);
           procedure ClosePlayer4;

            procedure btnStartClickAll(Sender: TObject);

  end;

{@VFD_NEWFORM_DECL}

{@VFD_NEWFORM_IMPL}

var
  Init: TUOS_Init;
  Player1, Player2, Player3, Player4: TUOS_Player;
  ordir, opath: string;

procedure TMultiplayer.AfterCreate;
begin
  {%region 'Auto-generated GUI code' -fold}

  {@VFD_BODY_BEGIN: Multiplayer}
  Name := 'Multiplayer';
  SetPosition(322, 77, 502, 465);
  WindowTitle := 'Multi Player';
  Hint := '';
  WindowPosition := wpScreenCenter;
  BackgroundColor:= clmoneygreen;
  Ondestroy := @btnCloseClick;

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
    SetPosition(136, 0, 320, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Folder + filename of PortAudio Library';
  end;

  btnLoad := TfpgButton.Create(self);
  with btnLoad do
  begin
    Name := 'btnLoad';
    SetPosition(12, 128, 480, 23);
    Text := 'Load that libraries';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 0;
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
    SetPosition(12, 160, 480, 24);
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
    SetPosition(76, 192, 60, 23);
    Text := 'Play';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 6;
    onclick := @btnstartClick;
  end;

  btnStop := TfpgButton.Create(self);
  with btnStop do
  begin
    Name := 'btnStop';
    SetPosition(344, 192, 76, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 7;
    onclick := @btnStopClick;
  end;

  Labelsnf := TfpgLabel.Create(self);
  with Labelsnf do
  begin
    Name := 'Labelsnf';
    SetPosition(140, 40, 316, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Folder + filename of SndFile Library';
  end;

  Labelmpg := TfpgLabel.Create(self);
  with Labelmpg do
  begin
    Name := 'Labelmpg';
    SetPosition(136, 80, 316, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Folder + filename of Mpg123 Library';
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
    SetPosition(168, 192, 52, 23);
    Text := 'Pause';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 15;
    onclick := @btnPauseClick;
  end;

  btnresume := TfpgButton.Create(self);
  with btnresume do
  begin
    Name := 'btnresume';
    SetPosition(248, 192, 64, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 16;
    onclick := @btnResumeClick;
  end;

  FilenameEdit5 := TfpgFileNameEdit.Create(self);
  with FilenameEdit5 do
  begin
    Name := 'FilenameEdit5';
    SetPosition(12, 224, 480, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 14;
  end;

  btnStart2 := TfpgButton.Create(self);
  with btnStart2 do
  begin
    Name := 'btnStart2';
    SetPosition(76, 256, 60, 23);
    Text := 'Play';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 15;
    onclick := @btnstartClick2;
  end;

  btnpause2 := TfpgButton.Create(self);
  with btnpause2 do
  begin
    Name := 'btnpause2';
    SetPosition(168, 256, 52, 23);
    Text := 'Pause';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 16;
    onclick := @btnPauseClick2;
  end;

  btnresume2 := TfpgButton.Create(self);
  with btnresume2 do
  begin
    Name := 'btnresume2';
    SetPosition(248, 256, 64, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 17;
    onclick := @btnResumeClick2;
  end;

  btnStop2 := TfpgButton.Create(self);
  with btnStop2 do
  begin
    Name := 'btnStop2';
    SetPosition(348, 256, 76, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 18;
    onclick := @btnStopClick2;
  end;

  FilenameEdit6 := TfpgFileNameEdit.Create(self);
  with FilenameEdit6 do
  begin
    Name := 'FilenameEdit6';
    SetPosition(12, 288, 480, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 19;
  end;

  btnStart3 := TfpgButton.Create(self);
  with btnStart3 do
  begin
    Name := 'btnStart3';
    SetPosition(76, 320, 60, 23);
    Text := 'Play';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 20;
    onclick := @btnstartClick3;
  end;

  btnPause3 := TfpgButton.Create(self);
  with btnPause3 do
  begin
    Name := 'btnPause3';
    SetPosition(168, 320, 52, 23);
    Text := 'Pause';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 21;
    onclick := @btnPauseClick3;
  end;

  btnResume3 := TfpgButton.Create(self);
  with btnResume3 do
  begin
    Name := 'btnResume3';
    SetPosition(248, 320, 64, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 22;
    onclick := @btnResumeClick3;
  end;

  btnStop3 := TfpgButton.Create(self);
  with btnStop3 do
  begin
    Name := 'btnStop3';
    SetPosition(348, 320, 76, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 23;
    onclick := @btnStopClick3;
  end;

  FilenameEdit7 := TfpgFileNameEdit.Create(self);
  with FilenameEdit7 do
  begin
    Name := 'FilenameEdit7';
    SetPosition(12, 352, 480, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 24;
  end;

  btnStart4 := TfpgButton.Create(self);
  with btnStart4 do
  begin
    Name := 'btnStart4';
    SetPosition(76, 384, 60, 23);
    Text := 'Play';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 25;
    onclick := @btnstartClick4;
  end;

  btnPause4 := TfpgButton.Create(self);
  with btnPause4 do
  begin
    Name := 'btnPause4';
    SetPosition(168, 384, 52, 23);
    Text := 'Pause';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 26;
    onclick := @btnPauseClick4;
  end;

  btnResume4 := TfpgButton.Create(self);
  with btnResume4 do
  begin
    Name := 'btnResume4';
    SetPosition(248, 384, 64, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 27;
    onclick := @btnResumeClick4;
  end;

  btnStop4 := TfpgButton.Create(self);
  with btnStop4 do
  begin
    Name := 'btnStop4';
    SetPosition(348, 384, 76, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 28;
    onclick := @btnStopClick4;
  end;

  Button3 := TfpgButton.Create(self);
  with Button3 do
  begin
    Name := 'Button3';
    SetPosition(68, 425, 360, 23);
    Text := 'Play All Together';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 29;
    onclick := @btnStartClickAll;
  end;

  {@VFD_BODY_END: Multiplayer}
  {%endregion}
              ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));

             height := 157;
             {$IFDEF Windows}
     {$if defined(cpu64)}
  FilenameEdit1.FileName := ordir + 'lib\LibPortaudio-64.dll';
{$else}
  FilenameEdit1.FileName := ordir + 'lib\LibPortaudio-32.dll';
   {$endif}
  FilenameEdit4.FileName := ordir + 'sound\test.mp3';
    FilenameEdit5.FileName := ordir + 'sound\test.ogg';
     FilenameEdit6.FileName := ordir + 'sound\test.wav';
      FilenameEdit7.FileName := ordir + 'sound\test.flac';
 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  FilenameEdit1.FileName := opath + '/lib/LibPortaudio-32.dylib';
  FilenameEdit4.FileName := opath + 'sound/test.mp3';
    FilenameEdit5.FileName := opath + 'sound/test.ogg';
     FilenameEdit6.FileName := opath + 'sound/test.wav';
      FilenameEdit7.FileName := opath + 'sound/test.flac';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  FilenameEdit1.FileName := ordir + 'lib/LibPortaudio-64.so';
{$else}
  FilenameEdit1.FileName := ordir + 'lib/LibPortaudio-32.so';
{$endif}

  FilenameEdit4.FileName := ordir + 'sound/test.mp3';
FilenameEdit5.FileName := ordir + 'sound/test.ogg';
   FilenameEdit6.FileName := ordir + 'sound/test.wav';
    FilenameEdit7.FileName := ordir + 'sound/test.flac';

            {$ENDIF}
  //////////////////////////////////////////////////////////////////////////

    {$IFDEF Windows}
       {$if defined(cpu64)}
  FilenameEdit2.FileName := ordir + 'lib\LibSndFile-64.dll';
{$else}
  FilenameEdit2.FileName := ordir + 'lib\LibSndFile-32.dll';
{$endif}

 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  FilenameEdit2.FileName := opath + '/lib/LibSndFile-32.dylib';
            {$ENDIF}

   {$IFDEF linux}
      {$if defined(cpu64)}
  FilenameEdit2.FileName := ordir + 'lib/LibSndFile-64.so';
{$else}
  FilenameEdit2.FileName := ordir + 'lib/LibSndFile-32.so';
{$endif}

            {$ENDIF}
  //////////////////////////////////////////////////////////////////////////
 {$IFDEF Windows}
       {$if defined(cpu64)}
  FilenameEdit3.FileName :=ordir + 'lib\LibMpg123-64.dll';
{$else}
  FilenameEdit3.FileName := ordir + 'lib\LibMpg123-32.dll';
{$endif}
 {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/UOS', opath) - 1);
  FilenameEdit3.FileName := opath + '/lib/LibMpg123-32.dylib';
            {$ENDIF}

   {$IFDEF linux}
      {$if defined(cpu64)}
  FilenameEdit3.FileName := ordir + 'lib/LibMpg123-64.so';
{$else}
  FilenameEdit3.FileName := ordir + 'lib/LibMpg123-32.so';
{$endif}

            {$ENDIF}
  FilenameEdit4.Initialdir := ordir + 'sound';
FilenameEdit1.Initialdir := ordir + 'lib';
FilenameEdit2.Initialdir := ordir + 'lib';
FilenameEdit3.Initialdir := ordir + 'lib';
end;

procedure TMultiplayer.btnCloseClick(Sender: TObject);
 begin
  if assigned(Player1) and (btnstart.Enabled = false) then
    begin
    player1.stop;
       end;
   if assigned(Player2) and (btnstart2.Enabled = false) then
    begin
    player2.stop;
       end;
    if assigned(Player3) and (btnstart3.Enabled = false) then
    begin
    player3.stop;
      end;
     if assigned(Player4) and (btnstart4.Enabled = false) then
    begin
    player4.stop;
       end;
      sleep(200);
  if btnLoad.Enabled = False then
   Init.UnloadLib();
  end;

procedure TMultiplayer.btnLoadClick(Sender: TObject);
var
  str : string;
 begin
      Init := TUOS_Init.Create;   //// Create Iibraries Loader-Init

   Init.PA_FileName := FilenameEdit1.FileName;
   Init.MP_FileName := FilenameEdit3.FileName;
   Init.SF_FileName := FilenameEdit2.FileName;
   Init.Flag := LoadAll;

   if Init.LoadLib = 0 then
   begin
    hide;
    height := 465;
    btnStart.Enabled := True;
    btnLoad.Enabled := False;
    FilenameEdit1.ReadOnly := True;
    FilenameEdit2.ReadOnly := True;
    FilenameEdit3.ReadOnly := True;
    UpdateWindowPosition;
    btnLoad.Text:='PortAudio, SndFile and Mpg123 libraries are loaded...';
     WindowPosition := wpScreenCenter;
    Show;
   end;
 end;

 procedure TMultiplayer.ClosePlayer1;
 begin
    btnStart.Enabled := true;
   btnStop.Enabled := false;
   btnPause.Enabled := false;
   btnresume.Enabled := False;
   end;
procedure TMultiplayer.ClosePlayer2;
begin
          btnStart2.Enabled := true;
  btnStop2.Enabled := false;
  btnPause2.Enabled := false;
  btnresume2.Enabled := False;
  end;
procedure TMultiplayer.ClosePlayer3;
begin
            btnStart3.Enabled := true;
  btnStop3.Enabled := false;
  btnPause3.Enabled := false;
  btnresume3.Enabled := False;
  end;
procedure TMultiplayer.ClosePlayer4;
begin
    btnStart4.Enabled := true;
  btnStop4.Enabled := false;
  btnPause4.Enabled := false;
  btnresume4.Enabled := False;
  end;

 procedure TMultiplayer.btnStopClick(Sender: TObject);
 begin
   player1.Stop;
   closeplayer1;
    end;
procedure TMultiplayer.btnResumeClick(Sender: TObject);
begin
   Player1.RePlay;
 btnStart.Enabled := false;
  btnStop.Enabled := true;
  btnPause.Enabled := true;
  btnresume.Enabled := False;
end;

procedure TMultiplayer.btnPauseClick(Sender: TObject);
begin
   Player1.Pause;
 btnStart.Enabled := false;
  btnStop.Enabled := true;
  btnPause.Enabled := false;
  btnresume.Enabled := true;
end;

 procedure TMultiplayer.btnStartClick(Sender: TObject);

begin
   Player1 := TUOS_Player.Create(True,self);     //// Create the player

   Player1.AddIntoDevOut ;    //// add a Output into device with default parameters

   Player1.AddFromFile(FilenameEdit4.filename);    //// add input from audio file with default parameters

   Player1.EndProc := @ClosePlayer1;  /////// procedure to execute when stream is terminated

   btnStart.Enabled := false;
   btnStop.Enabled := true;
     btnpause.Enabled := true;
       btnresume.Enabled := false;
                     Player1.Play;  /////// everything is ready, here we are, lets play it...

 end;

procedure TMultiplayer.btnStopClick2(Sender: TObject);
begin
  player2.Stop;
  closeplayer2;
   end;
procedure TMultiplayer.btnResumeClick2(Sender: TObject);
begin
  Player2.RePlay;
btnStart2.Enabled := false;
 btnStop2.Enabled := true;
 btnPause2.Enabled := true;
 btnresume2.Enabled := False;
end;

procedure TMultiplayer.btnPauseClick2(Sender: TObject);
begin
  Player2.Pause;
btnStart2.Enabled := false;
 btnStop2.Enabled := true;
 btnPause2.Enabled := false;
 btnresume2.Enabled := true;
end;

procedure TMultiplayer.btnStartClick2(Sender: TObject);

begin
   Player2 := TUOS_Player.Create(True,self);     //// Create the player

   Player2.AddIntoDevOut;

   Player2.AddFromFile(filenameEdit5.filename);

   Player2.EndProc := @ClosePlayer2;  /////// procedure to execute when stream is terminated

  btnStart2.Enabled := false;
  btnStop2.Enabled := true;
    btnpause2.Enabled := true;
      btnresume2.Enabled := false;
                    Player2.Play;  /////// everything is ready, here we are, lets play it...

end;

procedure TMultiplayer.btnStopClick3(Sender: TObject);
begin
  player3.Stop;
  closeplayer3;
   end;
procedure TMultiplayer.btnResumeClick3(Sender: TObject);
begin
  Player3.RePlay;
btnStart3.Enabled := false;
 btnStop3.Enabled := true;
 btnPause3.Enabled := true;
 btnresume3.Enabled := False;
end;

procedure TMultiplayer.btnPauseClick3(Sender: TObject);
begin
  Player3.Pause;
btnStart3.Enabled := false;
 btnStop3.Enabled := true;
 btnPause3.Enabled := false;
 btnresume3.Enabled := true;
end;

procedure TMultiplayer.btnStartClick3(Sender: TObject);

begin

   Player3 := TUOS_Player.Create(True,self);     //// Create the player

 Player3.AddIntoDevOut;

 Player3.AddFromFile(filenameEdit6.filename);  //// add input from audio file with custom parameters

 Player3.EndProc := @ClosePlayer3;  /////// procedure to execute when stream is terminated


  btnStart3.Enabled := false;
  btnStop3.Enabled := true;
    btnpause3.Enabled := true;
      btnresume3.Enabled := false;
                    Player3.Play;  /////// everything is ready, here we are, lets play it...

end;

procedure TMultiplayer.btnStopClick4(Sender: TObject);
begin
  player4.Stop;
  closeplayer4;
   end;
procedure TMultiplayer.btnResumeClick4(Sender: TObject);
begin
  Player4.RePlay;
btnStart4.Enabled := false;
 btnStop4.Enabled := true;
 btnPause4.Enabled := true;
 btnresume4.Enabled := False;
end;

procedure TMultiplayer.btnPauseClick4(Sender: TObject);
begin
  Player4.Pause;
btnStart4.Enabled := false;
 btnStop4.Enabled := true;
 btnPause4.Enabled := false;
 btnresume4.Enabled := true;
end;

procedure TMultiplayer.btnStartClick4(Sender: TObject);

begin
  Player4 := TUOS_Player.Create(True,self);     //// Create the player

 Player4.AddIntoDevOut;

  Player4.AddFromFile(filenameEdit7.filename);

  Player4.EndProc := @ClosePlayer4;  /////// procedure to execute when stream is terminated

  btnStart4.Enabled := false;
  btnStop4.Enabled := true;
    btnpause4.Enabled := true;
      btnresume4.Enabled := false;
                    Player4.Play;  /////// everything is ready, here we are, lets play it...

end;

procedure TMultiplayer.btnStartClickAll(Sender: TObject);
begin
 btnStartClick(self);
 btnStartClick2(self);
  btnStartClick3(self);
  btnStartClick4(self);
end;
// constructor TMultiplayer.Create(AOwner: TComponent);
//begin
// inherited Create(AOwner);
 // borderless and steals focus like a normal form
// Include(FWindowAttributes, waBorderLess);
// end;

procedure TMultiplayer.UOS_logo(Sender: TObject);
var
xpos, ypos, pbwidth, pbheight: integer;
ratio: double;
begin
xpos := 0;
ypos := 0;
ratio := 1;
pbwidth := 115;
pbheight := 115;
with Custom1 do
begin
 Canvas.GradientFill(GetClientRect, clgreen, clBlack, gdVertical);
Canvas.TextColor := clWhite;
Canvas.DrawText(60, 20, 'UOS');
 end;
end;

procedure MainProc;
var
  frm: TMultiplayer;
begin
  fpgApplication.Initialize;
  frm := TMultiplayer.Create(nil);
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

