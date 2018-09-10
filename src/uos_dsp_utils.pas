{This unit is part of United Openlibraries of Sound (uos)}
{
    This unit uses part of Pascal Audio IO package.
    (paio_channelhelper, pa_ringbuffer, pa_utils)  
        Copyright (c) 2016 by Andrew Haines.
    
    Fred van Stappen fiens@hotmail.com
}

unit uos_dsp_utils;

{$mode objfpc}{$H+}
{$interfaces corba}

interface

uses
  Classes, SysUtils;

const
  AUDIO_BUFFER_SIZE  = 8192;
  AUDIO_BUFFER_FLOAT_SAMPLES = AUDIO_BUFFER_SIZE div 4;

type
  PPSingle = ^PSingle;
  TSingleArray = array of Single;
  TChannelArray = array of TSingleArray;

 { TRingBuffer }

  TRingBuffer = class
  private
    FMem: PByte;
    FWritePos: Integer;
    FReadPos: Integer;
    FUsedSpace: Integer;
    FTotalSpace: Integer;
    function GetFreeSpace: Integer;
  public
    constructor Create(ASize: Integer);
    destructor Destroy; override;
    function Write(const ASource; ASize: Integer): Integer;
    function Read(var ADest; ASize: Integer): Integer;
    property FreeSpace: Integer read GetFreeSpace;
    property UsedSpace: Integer read FUsedSpace;

  end;

type
  IPAIODataIOInterface = interface
  ['IPAIODataIOInterface']
    procedure WriteDataIO(ASender: IPAIODataIOInterface; AData: PSingle; ASamples: Integer);
  end;

  { TPAIOChannelHelper }

  TPAIOChannelHelper = class(IPAIODataIOInterface)
  private
    FOutputs: TList;
    FTarget: IPAIODataIOInterface; // where we will send plexed data.
    FBuffers: TChannelArray;
    FPos: array of Integer;
    // called by the individual channel objects.
    procedure WriteDataIO(ASender: IPAIODataIOInterface; AData: PSingle; ASamples: Integer);
    procedure AllocateBuffers;
    procedure SendDataToTarget;
  public
    constructor Create(APlexedTarget: IPAIODataIOInterface);
    destructor Destroy; override;
    property Outputs: TList read FOutputs;// of  IPAIOSplitterJoinerInterface. Each is a channel in order.
    procedure Write(AData: PSingle; ASamples: Integer); // this expects interleaved data.
  end;

function NewChannelArray(AChannels: Integer; ASamplesPerChannel: Integer): TChannelArray;
function SplitChannels(AData: PSingle; ASamples: Integer; AChannels: Integer): TChannelArray;
function JoinChannels(AChannelData: TChannelArray; ASamples: Integer = -1): TSingleArray;
function JoinChannels(AChannelData: PPSingle; AChannels: Integer; ASamples: Integer): TSingleArray;

function Min(A,B: Integer): Integer;
function Max(A,B: Integer): Integer;

implementation

{ TPAIOChannelHelper }

procedure TPAIOChannelHelper.WriteDataIO(ASender: IPAIODataIOInterface; AData: PSingle; ASamples: Integer);
var
  BufIndex: Integer;
  BufSize, WCount: Integer;
  Written: Integer = 0;
begin
  BufIndex := FOutputs.IndexOf(Pointer(ASender));

  if BufIndex = -1 then
    raise Exception.Create('Trying to write data from an unknown instance');

  AllocateBuffers;

  BufSize := Length(FBuffers[0]);

  While ASamples > 0 do
  begin
    WCount := Min(BufSize-FPos[BufIndex], ASamples);
    Move(AData[Written], FBuffers[BufIndex][0], WCount*SizeOf(Single));
    Inc(Written, WCount);
    Dec(ASamples, WCount);
    Inc(FPos[BufIndex], WCount);

    if BufIndex = High(FBuffers) then
      SendDataToTarget;
  end;
end;

procedure TPAIOChannelHelper.AllocateBuffers;
begin
  if Length(FBuffers) <> FOutputs.Count then
  begin
    SetLength(FBuffers, 0);
    FBuffers := NewChannelArray(FOutputs.Count, AUDIO_BUFFER_SIZE*2);
    SetLength(FPos, FOutputs.Count);
  end;
end;

procedure TPAIOChannelHelper.SendDataToTarget;
var
  Plexed: TSingleArray;
  HighestCount: Integer = 0;
  i: Integer;
begin
  for i := 0 to High(FPos) do
    if FPos[i] > HighestCount then
      HighestCount:=FPos[i];
  Plexed := JoinChannels(FBuffers, HighestCount);

  FTarget.WriteDataIO(Self, @Plexed[0], Length(Plexed));

  for i := 0 to High(FPos) do
    Dec(FPos[i], HighestCount);
end;

constructor TPAIOChannelHelper.Create(APlexedTarget: IPAIODataIOInterface);
begin
  FOutputs := TList.Create;
  FTarget := APlexedTarget;
end;

destructor TPAIOChannelHelper.Destroy;
begin
  FOutputs.Free;
  inherited Destroy;
end;

procedure TPAIOChannelHelper.Write(AData: PSingle; ASamples: Integer);
var
  Channels: TChannelArray;
  i: Integer;
  Pos: Integer = 0;
  WCount: Integer;
begin
  AllocateBuffers;
  Channels := SplitChannels(AData, ASamples, Outputs.Count);
  while ASamples > 0 do
  begin
    WCount := Min(1024, ASamples div Outputs.Count);
    for i := 0 to Outputs.Count-1 do
    begin
      IPAIODataIOInterface(Outputs.Items[i]).WriteDataIO(Self, @Channels[i][Pos], WCount);
    end;
    Dec(ASamples, WCount * Outputs.Count);
    Inc(Pos, WCount);
  end;
end;

{ TRingBuffer }

function TRingBuffer.GetFreeSpace: Integer;
begin
  Result := FTotalSpace-FUsedSpace;
end;

constructor TRingBuffer.Create(ASize: Integer);
begin
  FMem:=Getmem(ASize);
  FTotalSpace:=ASize;
end;

destructor TRingBuffer.Destroy;
begin
  Freemem(FMem);
  inherited Destroy;
end;

function TRingBuffer.Write(const ASource; ASize: Integer): Integer;
var
  EOB: Integer; // end of buffer
  WSize: Integer;
  WTotal: Integer = 0;
begin
  if FUsedSpace = 0 then
  begin
    // give the best chance of not splitting the data at buffer end.
    FWritePos:=0;
    FReadPos:=0;
  end;
  if ASize > FreeSpace then
    raise Exception.Create('Ring buffer overflow');
  Result := ASize;
  Inc(FUsedSpace, ASize);
  while ASize > 0 do
  begin
    EOB := FTotalSpace - FWritePos;
    WSize := Min(ASize, EOB);
    Move(PByte(@ASource)[WTotal], FMem[FWritePos], WSize);
    Inc(FWritePos, WSize);
    Dec(ASize, WSize);

    if FWritePos >= FTotalSpace then
      FWritePos:= 0;
  end;
end;

function TRingBuffer.Read(var ADest; ASize: Integer): Integer;
var
  EOB: Integer; // end of buffer
  RSize: Integer;
  RTotal: Integer = 0;
begin
  if ASize > UsedSpace then
    raise Exception.Create('Ring buffer underflow');
  ASize := Min(ASize, UsedSpace);
  Result := ASize;

  Dec(FUsedSpace, ASize);
  while ASize > 0 do
  begin
    EOB := FTotalSpace - FReadPos;
    RSize := Min(EOB, ASize);
    Move(FMem[FReadPos], PByte(@ADest)[RTotal],RSize);
    Dec(ASize, RSize);
    Inc(FReadPos, RSize);
    if FReadPos >= FTotalSpace then
      FReadPos:=0;
  end;
end;

function Min(A,B: Integer): Integer;
begin
  if A < B then Exit(A);
  Result := B;
end;

function Max(A,B: Integer): Integer;
begin
  if A > B then Exit(A);
  Result := B;
end;

function NewChannelArray(AChannels: Integer; ASamplesPerChannel: Integer): TChannelArray;
var
  i: Integer;
begin
  SetLength(Result, AChannels);
  for i := 0 to AChannels-1 do
    SetLength(Result[i], ASamplesPerChannel);
end;

// Samples is total samples not samples per channel.
// So Samples = 1000 if 2 Channels have 500 each
function SplitChannels(AData: PSingle; ASamples: Integer; AChannels: Integer): TChannelArray;
var
  SamplesPerChannel: Integer;
  i, j: Integer;
begin
  SamplesPerChannel:=ASamples div AChannels;
  //SetLength(Result, AChannels);
  Result := NewChannelArray(AChannels, SamplesPerChannel);
  for i := 0 to AChannels-1 do
  begin
    //SetLength(Result[i], SamplesPerChannel);
    for j := 0 to SamplesPerChannel-1 do
    begin
      Result[i][j] := AData[j*AChannels+i];
    end;
  end;
end;

function JoinChannels(AChannelData: TChannelArray; ASamples: Integer): TSingleArray;
var
  i: Integer;
  j: Integer;
  Samples: Integer;
begin
  if Length(AChannelData) > 0 then
  begin
   if ASamples <> -1 then
     Samples := ASamples
   else
     Samples := Length(AChannelData[0]);

   SetLength(Result, Length(AChannelData) * Samples);
    for i := 0 to High(AChannelData) do
      for j := 0 to Samples-1 do
        Result[j*Length(AChannelData)+i] := AChannelData[i][j];
  end
  else
    SetLength(Result, 0);
end;

function JoinChannels(AChannelData: PPSingle; AChannels: Integer;
  ASamples: Integer): TSingleArray;
var
  i: Integer;
  j: Integer;
begin
  if ASamples > 0 then
  begin
   SetLength(Result, AChannels * ASamples);
    for i := 0 to AChannels-1 do
      for j := 0 to ASamples-1 do
        Result[j*AChannels+i] := AChannelData[i][j];
  end
  else
    SetLength(Result, 0);

end;

end.

