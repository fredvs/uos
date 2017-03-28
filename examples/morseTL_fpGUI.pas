program morseTL_fpGUI;

{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}
 cthreads,
  cwstring, {$ENDIF}
  fpg_stylemanager,
  fpg_style_chrome_silver_flatmenu,
   SysUtils, Classes,  fpg_base,
  fpg_main,    fpg_form, fpg_button,
  fpg_label, fpg_edit, fpg_memo, uos_flat;

type

  Tform1 = class(TfpgForm)
  private
    {@VFD_HEAD_BEGIN: form1}
    Label1: TfpgLabel;
    TimerCount: TfpgTimer;
    Memo1: TfpgMemo;
    interchar: TfpgEdit;
    interspace: TfpgEdit;
    Label2: TfpgLabel;
    Label3: TfpgLabel;
    Button1: TfpgButton;
    Button2: TfpgButton;
    {@VFD_HEAD_END: form1}
  public
    procedure AfterCreate; override;
    procedure CreateMorsePlayer();
    procedure PlayClick(Sender: TObject);
    procedure QuitClick(Sender: TObject);
    procedure onTimerCount(Sender: TObject);

  end;

{@VFD_NEWFORM_DECL}

{@VFD_NEWFORM_IMPL}

var
  i :  cardinal;
  ordir : string;
//  AParent: TObject;


procedure TForm1.CreateMorsePlayer();
var
filetoplay, fileeror : string;
chara : string;
player : cardinal;
begin
if i <= length(Memo1.Text) then
begin
     Button1.Enabled := false;
     TimerCount.Enabled := false;
chara := copy(Memo1.Text,i,1);

  fileeror :=  pchar(ordir + 'sound' + directoryseparator + 'morse_audio'+  directoryseparator +'0.mp3')  ;

  if odd(i) then player := 0 else player := 1;  ///// to switch between player1 <> player2

    if chara <> ' ' then
   begin
  {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
     uos_CreatePlayer(player);
     {$else}
    uos_CreatePlayer(player,AParent);
    {$endif}

  uos_AddIntoDevOut(player);

  filetoplay := ordir + 'sound' + directoryseparator + 'morse_audio'+  directoryseparator + lowercase(chara) + '.mp3' ;

       if fileexists(pchar(filetoplay)) then
  uos_AddFromFile(player,pchar(filetoplay)) else
  uos_AddFromFile(player,pchar(fileeror)) ;  /// if not existing char
  if length(Memo1.text) > i then
  begin
  uos_EndProc(player, @CreateMorsePlayer);
   end else
    begin
    Button1.Enabled := true;
  TimerCount.Enabled := false;
    end;
   sleep(strtoint(interchar.Text)) ;     ///// the pause between each character
       inc(i);

         uos_Play(player);
          TimerCount.Enabled := true;
                   end
  else
  begin
   sleep(strtoint(interspace.Text)) ;   ///// the pause if space character
   inc(i);
  if length(Memo1.text) >= i then CreateMorsePlayer;
  end;

 end ;

 end;


procedure TForm1.PlayClick(Sender: TObject);
begin
 if Memo1.Text <> '' then
 begin
  i := 1 ;
 CreateMorsePlayer();
 end;
end;

procedure TForm1.onTimerCount(Sender: TObject);
begin
  fpgapplication.processmessages;
end;


procedure TForm1.QuitClick(Sender: TObject);
begin
   TimerCount.Enabled := false;
  close;
end;

procedure Tform1.AfterCreate;
var
PA_FileName, MP_FileName : string;
begin
  {%region 'Auto-generated GUI code' -fold}

  {@VFD_BODY_BEGIN: form1}
  Name := 'form1';
  SetPosition(294, 118, 502, 321);
  WindowTitle := 'Morse Translator';
  Hint := '';

  Label1 := TfpgLabel.Create(self);
  with Label1 do
  begin
    Name := 'Label1';
    SetPosition(104, 20, 288, 27);
    Alignment := taCenter;
    FontDesc := '#Label2';
    Hint := '';
    Text := 'Write something here :';
  end;

  Memo1 := TfpgMemo.Create(self);
  with Memo1 do
  begin
    Name := 'Memo1';
    SetPosition(40, 44, 432, 165);
    FontDesc := '#Edit1';
    Hint := '';
    TabOrder := 2;
  end;

  interchar := TfpgEdit.Create(self);
  with interchar do
  begin
    Name := 'interchar';
    SetPosition(96, 236, 76, 24);
    ExtraHint := '';
    FontDesc := '#Edit1';
    Hint := '';
    TabOrder := 3;
    Text := '250';
  end;

  interspace := TfpgEdit.Create(self);
  with interspace do
  begin
    Name := 'interspace';
    SetPosition(296, 236, 68, 24);
    ExtraHint := '';
    FontDesc := '#Edit1';
    Hint := '';
    TabOrder := 4;
    Text := '1500';
  end;

  Label2 := TfpgLabel.Create(self);
  with Label2 do
  begin
    Name := 'Label2';
    SetPosition(56, 216, 172, 15);
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Pause inter char in msec';
  end;

  Label3 := TfpgLabel.Create(self);
  with Label3 do
  begin
    Name := 'Label3';
    SetPosition(244, 216, 216, 15);
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Pause for space char in msec';
  end;

  Button1 := TfpgButton.Create(self);
  with Button1 do
  begin
    Name := 'Button1';
    SetPosition(80, 276, 128, 27);
    Text := 'Translate it';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 7;
    onclick:=@PlayClick;
  end;

  Button2 := TfpgButton.Create(self);
  with Button2 do
  begin
    Name := 'Button2';
    SetPosition(340, 276, 80, 23);
    Text := 'Close';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 8;
    OnClick:=@QuitClick;
  end;

  {@VFD_BODY_END: form1}
  {%endregion}
     memo1.Text:='';
     ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));

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

 uos_LoadLib(Pchar(PA_FileName), nil, pchar(MP_FileName), nil, nil, nil);

     TimerCount := Tfpgtimer.Create(100);
     TimerCount.Enabled := False;
  timerCount.OnTimer := @ontimercount;

  end;

procedure MainProc;
var
  frm: Tform1;
begin
  fpgApplication.Initialize;
   if fpgStyleManager.SetStyle('Chrome silver flat menu') then
          fpgStyle := fpgStyleManager.Style;
    fpgApplication.CreateForm(Tform1, frm);
   try
    frm.Show;
    frm.UpdateWindowPosition;
    fpgApplication.Run;
  finally
  uos_free;
  frm.Free;
  end;
end;

begin
  MainProc;
end.
