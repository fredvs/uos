unit main_mt;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, StdCtrls,
  Buttons, uos_flat, Classes;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtnPlay: TBitBtn;
    ButtonQuit: TButton;
    interchar: TEdit;
    interspace: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;

     procedure BitBtnPlayClick(Sender: TObject);
     procedure ButtonQuitClick(Sender: TObject);
     procedure FormActivate(Sender: TObject);
     procedure FormDestroy(Sender: TObject);
     procedure CreateMorsePlayer();

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  i :  cardinal;
  ordir : string;
implementation

{$R *.lfm}


procedure TForm1.CreateMorsePlayer();
var
filetoplay, fileerror : string;
chara : string;
player : cardinal;
begin
if i <= length(Memo1.Text) then
begin
chara := copy(Memo1.Text,i,1);

fileerror := ordir + 'sound' + directoryseparator + 'morse_audio'+  directoryseparator +'0.mp3' ;

if odd(i) then player := 0 else player := 1;  ///// to switch between player1 <> player2

    if chara <> ' ' then
   begin
   uos_CreatePlayer(player);
  uos_AddIntoDevOut(player);

  filetoplay := ordir + 'sound' + directoryseparator + 'morse_audio'+  directoryseparator + lowercase(chara) + '.mp3' ;

       if fileexists(pchar(filetoplay)) then
  uos_AddFromFile(player,pchar(filetoplay)) else
  uos_AddFromFile(player,pchar(fileerror)) ;  /// if not existing char
  if length(Memo1.text) > i then  uos_EndProc(player, @CreateMorsePlayer);        /// assign EndProc
     sleep(strtoint(interchar.Text)) ;     ///// the pause between each character
    uos_Play(player);
    inc(i);
   end
  else
  begin
   sleep(strtoint(interspace.Text)) ;   ///// the pause if space character
   inc(i);
  if length(Memo1.text) >= i then CreateMorsePlayer;
  end;

 end;
end;

procedure TForm1.BitBtnPlayClick(Sender: TObject);
var
charac : string;
begin
 if Memo1.Text <> '' then
 begin
  i := 1 ;
 CreateMorsePlayer();
 end;

end;

procedure TForm1.ButtonQuitClick(Sender: TObject);
begin
  close;
end;

procedure TForm1.FormActivate(Sender: TObject);
var
PA_FileName, MP_FileName : string;
begin
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

   end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  uos_free;    /// for release dynamic loaded libraries
  end;

end.

