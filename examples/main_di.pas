
/////////////////// Demo how to use United Openlib of Sound ////////////////////


unit main_di;

{$mode objfpc}{$H+}

interface

uses
  uos_flat, Forms, Dialogs, SysUtils, Graphics,
  StdCtrls, ExtCtrls, Grids, Classes;

type
  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PaintBox1: TPaintBox;
    Shape1: TShape;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure CheckInfos();
  private
    { private declarations }
  public
    { public declarations }
  end;


procedure uos_logo();

var
  Form1: TForm1;
  BufferBMP: TBitmap;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.FormActivate(Sender: TObject);
{$IFDEF Darwin}
var
  opath: string;
            {$ENDIF}
begin
  uos_logo();
      {$IFDEF Windows}
     {$if defined(cpu64)}
  edit1.Text := application.Location + 'lib\Windows\64bit\LibPortaudio-64.dll';
{$else}
  edit1.Text := application.Location + 'lib\Windows\32bit\LibPortaudio-32.dll';
   {$endif}
 {$ENDIF}

  {$IFDEF Darwin}
  opath := application.Location;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  edit1.Text := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
  edit1.Text := application.Location + 'lib/Linux/64bit/LibPortaudio-64.so';
{$else}
  edit1.Text := application.Location + 'lib/Linux/32bit/LibPortaudio-32.so';
{$endif}
 {$endif}

 {$IFDEF freebsd}
    {$if defined(cpu64)}
  edit1.Text := application.Location + 'lib/FreeBSD/64bit/libportaudio-64.so';
{$else}
  edit1.Text := application.Location + 'lib/FreeBSD/32bit/libportaudio-32.so';
{$endif}

            {$ENDIF}
  //////////////////////////////////////////////////////////////////////////

end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, BufferBMP);
end;

procedure TForm1.CheckInfos();
var
  x: integer;
begin

  uos_GetInfoDevice();

  label2.Caption := 'Devices Count = ' + IntToStr(uosDeviceCount);

  label3.Caption := 'Default Device IN = ' + IntToStr(uosDefaultDeviceIN);

  label4.Caption := 'Default Device OUT = ' + IntToStr(uosDefaultDeviceOUT);

  stringgrid1.rowcount := uosDeviceCount + 1;


  x := 1;

  while x < uosDeviceCount + 1  do
  begin

    stringgrid1.Cells[0, x] := IntToStr(uosDeviceInfos[x - 1].DeviceNum);
    stringgrid1.Cells[1, x] := uosDeviceInfos[x - 1].DeviceName;
    if uosDeviceInfos[x - 1].DefaultDevIn = True then
      stringgrid1.Cells[2, x] := 'Yes'
    else
      stringgrid1.Cells[2, x] := 'No';

    if uosDeviceInfos[x - 1].DefaultDevOut = True then
      stringgrid1.Cells[3, x] := 'Yes'
    else
      stringgrid1.Cells[3, x] := 'No';

    stringgrid1.Cells[4, x] := IntToStr(uosDeviceInfos[x - 1].ChannelsIn);
    stringgrid1.Cells[5, x] := IntToStr(uosDeviceInfos[x - 1].ChannelsOut);
    stringgrid1.Cells[6, x] := floattostrf(uosDeviceInfos[x - 1].SampleRate, ffFixed, 15, 0);
    stringgrid1.Cells[7, x] := floattostrf(uosDeviceInfos[x - 1].LatencyHighIn, ffFixed, 15, 8);
    stringgrid1.Cells[8, x] := floattostrf(uosDeviceInfos[x - 1].LatencyHighOut,
      ffFixed, 15, 8);
    stringgrid1.Cells[9, x] := floattostrf(uosDeviceInfos[x - 1].LatencyLowIn, ffFixed, 15, 8);
    stringgrid1.Cells[10, x] :=
      floattostrf(uosDeviceInfos[x - 1].LatencyLowOut, ffFixed, 15, 8);
    stringgrid1.Cells[11, x] := uosDeviceInfos[x - 1].HostAPIName;
    stringgrid1.Cells[12, x] := uosDeviceInfos[x - 1].DeviceType;
    Inc(x);
  end;

end;



procedure TForm1.Button1Click(Sender: TObject);
begin
  // Load the library
 //function  uos_loadlib(PortAudioFileName, SndFileFileName, Mpg123FileName, Mp4ffFileName, FaadFileName: PChar) : LongInt;

  if uos_LoadLib(pchar(edit1.Text), nil, nil, nil, nil) = 0 then
  begin
    form1.hide;
    button1.Caption := 'PortAudio is loaded...';
    button1.Enabled := False;
    edit1.ReadOnly := True;

     CheckInfos();
    form1.Height := 388;
    form1.Position := poScreenCenter;
    form1.Show;
  end
  else
  begin
    if uosLoadResult.PAloaderror = 1 then
      MessageDlg(edit1.Text + ' do not exist...', mtWarning, [mbYes], 0);
    if uosLoadResult.PAloaderror = 2 then
      MessageDlg(edit1.Text + ' do not load...', mtWarning, [mbYes], 0);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  CheckInfos();
end;


procedure uos_logo();
var
  xpos, ypos: integer;
  ratio: double;
begin
  xpos := 0;
  ypos := 0;
  ratio := 1;
  BufferBMP := TBitmap.Create;
  with form1 do
  begin
    form1.PaintBox1.Parent.DoubleBuffered := True;
    PaintBox1.Height := round(ratio * 116);
    PaintBox1.Width := round(ratio * 100);
    BufferBMP.Height := PaintBox1.Height;
    BufferBMP.Width := PaintBox1.Width;
    BufferBMP.Canvas.AntialiasingMode := amOn;
    BufferBMP.Canvas.Pen.Width := round(ratio * 6);
    BufferBMP.Canvas.brush.Color := clmoneygreen;
    BufferBMP.Canvas.FillRect(0, 0, PaintBox1.Width, PaintBox1.Height);
    BufferBMP.Canvas.Pen.Color := clblack;
    BufferBMP.Canvas.brush.Color := $70FF70;
    BufferBMP.Canvas.Ellipse(round(ratio * (22) + xpos),
      round(ratio * (30) + ypos), round(ratio * (72) + xpos),
      round(ratio * (80) + ypos));
    BufferBMP.Canvas.brush.Color := clmoneygreen;
    BufferBMP.Canvas.Arc(round(ratio * (34) + xpos), round(ratio * (8) + ypos),
      round(ratio * (58) + xpos), round(ratio * (32) + ypos), round(ratio * (58) + xpos),
      round(ratio * (20) + ypos), round(ratio * (46) + xpos),
      round(ratio * (32) + xpos));
    BufferBMP.Canvas.Arc(round(ratio * (34) + xpos), round(ratio * (32) + ypos),
      round(ratio * (58) + xpos), round(ratio * (60) + ypos), round(ratio * (34) + xpos),
      round(ratio * (48) + ypos), round(ratio * (46) + xpos),
      round(ratio * (32) + ypos));
    BufferBMP.Canvas.Arc(round(ratio * (-28) + xpos), round(ratio * (18) + ypos),
      round(ratio * (23) + xpos), round(ratio * (80) + ypos), round(ratio * (20) + xpos),
      round(ratio * (50) + ypos), round(ratio * (3) + xpos), round(ratio * (38) + ypos));
    BufferBMP.Canvas.Arc(round(ratio * (70) + xpos), round(ratio * (18) + ypos),
      round(ratio * (122) + xpos), round(ratio * (80) + ypos),
      round(ratio * (90 - xpos)),
      round(ratio * (38) + ypos), round(ratio * (72) + xpos),
      round(ratio * (50) + ypos));
    BufferBMP.Canvas.Font.Name := 'Arial';
    BufferBMP.Canvas.Font.Size := round(ratio * 10);
    BufferBMP.Canvas.TextOut(round(ratio * (4) + xpos),
      round(ratio * (83) + ypos), 'United Openlib');
    BufferBMP.Canvas.Font.Size := round(ratio * 7);
    BufferBMP.Canvas.TextOut(round(ratio * (20) + xpos),
      round(ratio * (101) + ypos), 'of');
    BufferBMP.Canvas.Font.Size := round(ratio * 10);
    BufferBMP.Canvas.TextOut(round(ratio * (32) + xpos),
      round(ratio * (98) + ypos), 'Sound');
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);

begin
  Form1.Height := 150;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if button1.Enabled = False then
    uos_free;
end;

end.
