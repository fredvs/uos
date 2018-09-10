{This unit is part of United Openlibraries of Sound (uos)}
{
 audacity which this file was converted from is GPLv2
 http://www.audacityteam.org/about/license/
      Converted By Andrew Haines
        License : modified LGPL.
    Fred van Stappen fiens@hotmail.com
 }

unit uos_dsp_noiseremoval;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uos_dsp_utils ;

type
  PFFT = ^TFFT;

  { TFFT }

  TFFT = object
    BitReversed: PInteger;
    SinTable: PSingle;
    Points: Integer;
    FPCSinTable: array of Single;
    function  InitializeFFT(FFTLen: Integer): PFFT; static;
    procedure EndFFT;
    function  GetFFT(FFTLen: Integer): PFFT; static;
    procedure ReleaseFFT;
    procedure InverseRealFFTf(buffer: PSingle);
    procedure CleanupFFT; static; // ???
    procedure RealFFTf(buffer: PSingle);
    procedure ReorderToTime(Buffer: PSingle; TimeOut: PSingle);
    procedure ReorderToFreq(Buffer: PSingle; RealOut: PSingle; ImagOut: PSingle);
  end;

type
  PPSingle=^PSingle;
  TSingleArray = array of Single;

  TNoiseRemoval = class;
  TNoiseWriteProc = procedure(ASender: TObject; AData: PSingle; ASampleCount: Integer) of Object;

  { TNoiseRemoval }

  TNoiseRemoval = class
  private
    FDoProfile: Boolean;
    FHasProfile: Boolean;

    // Parameters chosen before the first phase
    FSampleRate: Double;
    FWindowSize: Integer;
    FSpectrumSize: Integer;
    FMinSignalTime: Single; // in secs

    // The frequency-indexed noise threshold derived during the first
    // phase of analysis
    FNoiseThreshold: array of Single; // length in FSpectrumSize

    // Parameters that affect the noise removal, regardless of how the
    // noise profile was extracted
    FSensitivity: Double;
    FFreqSmoothingHz: Double;
    FNoiseGain: Double;      // in dB, should be negative
    FAttackDecayTime: Double;
    FbLeaveNoise: Boolean;

    // change this later
    procedure Initialize;
    procedure Reset; // StartNewTrack
    procedure ProcessSamples(len: Integer; Buffer:PSingle);
    procedure FillFirstHistoryWindow;
    procedure ApplyFreqSmoothing(ASpec: PSingle);
    procedure GetProfile;
    procedure RemoveNoise;
    procedure RotateHistoryWindows;
    procedure FinishTrack;
    procedure Cleanup;
  private
    //FOutputTrack: PSingle; // WaveTrack;
    FInSampleCount: Integer;
    FOutSampleCount: Integer;
    FInputPos: Integer;
    FFFT: PFFT;
    FFFTBuffer: PSingle;             // FWindowSize
    FWindow: PSingle;                // FWindowSize
    FFreqSmoothingBins: Integer;
    FAttackDecayBlocks: Integer;
    FOneBlockAttackDecay: Single;
    FNoiseAttenFactor: Single;
    FSensitivityFactor: Single;
    FMinSignalBlocks: Integer;
    FHistoryLen: Integer;
    FInWaveBuffer: PSingle;          // FWindowSize
    FOutOverlapBuffer: PSingle;      // FWindowSize
    FSpectrums:  array of PSingle;   // FHistoryLen x FSpectrumSize
    FGains: array of PSingle;        // FHistoryLen x FSpectrumSize
    FRealFFTs: array of PSingle;     // FHistoryLen x FWindowSize
    FImagFFTs: array of PSingle;     // FHistoryLen x FWindowSize
    FWriteProc: TNoiseWriteProc;
    FInited: Boolean;
    FTotalRead: QWord;
    function GetNoiseProfile: TSingleArray;
    procedure SetAttackDecayTime(AValue: Double);
    procedure SetFreqSmoothingHz(AValue: Double);
    procedure SetGain(AValue: Double);
    procedure SetNoiseProfile(AValue: TSingleArray);
    procedure SetSensitivity(AValue: Double);
  public
    constructor Create;
    destructor Destroy; override;
    function Init(ASampleRate: Integer): Boolean;
    function Process(AData: PSingle; ASampleCount: Integer; AGetNoiseProfile: Boolean; AMoreComing: Boolean = False): Boolean;
    procedure Flush; // finish writing out data in buffers.

    property NoiseProfile: TSingleArray read GetNoiseProfile write SetNoiseProfile;

    // these have defaults
    property Sensitivity: Double read FSensitivity write SetSensitivity;
    property Gain: Double read FNoiseGain write SetGain;
    property FreqSmoothingHz: Double read FFreqSmoothingHz write SetFreqSmoothingHz;
    property AttackDecayTime: Double read FAttackDecayTime write SetAttackDecayTime;
    property LeaveNoise: Boolean read FbLeaveNoise write FbLeaveNoise;

    // don't mess with these.
    property SampleRate: Double read FSampleRate;// write FSampleRate;
    property WindowSize: Integer read FWindowSize;// write FWindowSize;
    property SpectrumSize: Integer read FSpectrumSize;// write FSpectrumSize;
    property MinSignalTime: Single read FMinSignalTime;// write FMinSignalTime; // in secs

    // This must be assigned or av's will occur
    property WriteProc: TNoiseWriteProc read FWriteProc write FWriteProc;
  end;

type

  { TNoiseRemovalChannel }

  TNoiseRemovalChannel = class(TNoiseRemoval, IPAIODataIOInterface)
    HasProfile: Boolean;
    ProfileComplete: Boolean;
    procedure WriteDataIO(ASender: IPAIODataIOInterface; AData: PSingle; ASamples: Integer);
  end;

  { TNoiseRemovalMultiChannel }

  TNoiseRemovalMultiChannel = class(IPAIODataIOInterface)
  private
    FChannels,
    FSampleRate: Integer;
    FHelper: TPAIOChannelHelper;
    FNoise: array of TNoiseRemovalChannel;
    FWriteProc: TNoiseWriteProc;
    //IPAIODataIOInterface
    procedure WriteDataIO(ASender: IPAIODataIOInterface; AData: PSingle; ASamples: Integer);
    procedure DataWrite(ASender: TObject; AData: PSingle; ASampleCount: Integer);
  public
    constructor Create(AChannels: Integer; ASampleRate: Integer);
    destructor Destroy; override;
    procedure ReadNoiseProfile(AData: PSingle; ASamples: Integer);
    procedure ProcessNoise(AData: PSingle; ASamples: Integer);
    procedure Flush;
    property WriteProc: TNoiseWriteProc read FWriteProc write FWriteProc;
  end;
  
{ TuosNoiseRemoval }
 type
   TuosNoiseRemoval = class(TNoiseRemovalMultiChannel)
     OutStream: TStream;
   public
     isprofiled : boolean ;
     samprate : integer ;
     procedure WriteData(ASender: TObject; AData: PSingle; ASampleCount: Integer) ;
     function FilterNoise(ANoisyAudio: PSingle; InFrames: Integer; out Samples: Integer): PSingle;
   end;

 implementation
uses
  math;

const
  PI = 3.14159265358979323846;
  MAX_HFFT = 10;
var
  FFTArray: array[0..MAX_HFFT-1] of PFFT;
  FFTLockCount: array[0..MAX_HFFT-1] of Integer;

{ TMultiChannelNoiseRemoval }

procedure TNoiseRemovalMultiChannel.WriteDataIO(ASender: IPAIODataIOInterface; AData: PSingle; ASamples: Integer);
begin
  if Assigned(FWriteProc) then
    FWriteProc(Self, AData, ASamples);
end;

procedure TNoiseRemovalMultiChannel.DataWrite(ASender: TObject; AData: PSingle; ASampleCount: Integer);
begin
  (FHelper as IPAIODataIOInterface).WriteDataIO(ASender as IPAIODataIOInterface, AData, ASampleCount);
end;

constructor TNoiseRemovalMultiChannel.Create(AChannels: Integer;
  ASampleRate: Integer);
var
  i: Integer;
begin
  FChannels:=AChannels;
  FSampleRate:=ASampleRate;
  FHelper := TPAIOChannelHelper.Create(Self);
  SetLength(FNoise, AChannels);
  for i := 0 to High(FNoise) do
  begin
    FNoise[i] := TNoiseRemovalChannel.Create;
    FNoise[i].WriteProc:=@DataWrite;
    FNoise[i].Init(ASampleRate);
    FHelper.Outputs.Add(FNoise[i] as IPAIODataIOInterface);
  end;
end;

destructor TNoiseRemovalMultiChannel.Destroy;
var
  i: Integer;
begin
  for i := 0 to High(FNoise) do
  begin
    FNoise[i].Free;
  end;
  SetLength(FNoise, 0);
  FHelper.Free;
end;

procedure TNoiseRemovalMultiChannel.ReadNoiseProfile(AData: PSingle;
  ASamples: Integer);
var
  i: Integer;
begin
  FHelper.Write(AData, ASamples);
  for i := 0 to High(FNoise) do
  begin
    FNoise[i].ProfileComplete:=True;
    FNoise[i].Process(nil, 0, True, False);
    FNoise[i].HasProfile:=True;
    FNoise[i].Init(FSampleRate);
  end;
end;

procedure TNoiseRemovalMultiChannel.ProcessNoise(AData: PSingle;
  ASamples: Integer);
begin
  FHelper.Write(AData, ASamples);
end;

procedure TNoiseRemovalMultiChannel.Flush;
var
  i: Integer;
begin
  for i := 0 to High(FNoise) do
    FNoise[i].Flush;
end;

procedure TNoiseRemovalChannel.WriteDataIO(ASender: IPAIODataIOInterface;
  AData: PSingle; ASamples: Integer);
begin
  Process(AData, ASamples, not HasProfile, not HasProfile);
end;

{ TuosNoiseRemoval }
 
procedure TuosNoiseRemoval.WriteData(ASender: TObject; AData: PSingle;
  ASampleCount: Integer);
begin
  OutStream.Write(AData^, ASampleCount*SizeOf(Single));
end; 

function TuosNoiseRemoval.FilterNoise(ANoisyAudio: PSingle; InFrames: Integer; out Samples: Integer): PSingle;
var
  MNoisyAudio: TMemoryStream;
 begin
   OutStream := TMemoryStream.Create; 
   
   MNoisyAudio := TMemoryStream.Create;
   MNoisyAudio.Write(ANoisyAudio^, InFrames*SizeOf(Single));
   MNoisyAudio.Position:=0;

   if isprofiled = false then // take the first chunk as noisy sample
   begin
   ReadNoiseProfile(PSingle(MNoisyAudio.Memory), MNoisyAudio.Size div SizeOf(Single));
   isprofiled := true;
   end;
   
   Result := nil;
     
   ProcessNoise(PSingle(MNoisyAudio.Memory), MNoisyAudio.Size div SizeOf(Single));
  
   Result:=GetMem(OutStream.Size);
   Samples := OutStream.Size div SizeOf(Single);
   OutStream.Position:=0;
   OutStream.Read(Result^, OutStream.Size);
   
   MNoisyAudio.free;
   OutStream.Free;

 // Result := ANoisyAudio;
 end;

{ TNoiseRemoval }

function NewFloatArray(ALength: Integer): PSingle; inline;
begin
  Result := Getmem(ALength*SizeOf(Single));
end;

procedure TNoiseRemoval.Initialize;
var
  i: Integer;
begin
  FFreqSmoothingBins := Trunc(FFreqSmoothingHz * FWindowSize / FSampleRate);
  FAttackDecayBlocks := 1 + Trunc(FAttackDecayTime * FSampleRate / (FWindowSize / 2));
  // Applies to amplitudes, divide by 20:
  FNoiseAttenFactor  := power(10, FNoiseGain/20);

  // Applies to gain factors which apply to amplitudes, divide by 20:
  //FOneBlockAttackDecay := power(10.0, (FNoiseGain / (20.0 * FAttackDecayBlocks)));
  FOneBlockAttackDecay := power(10.0, (FNoiseGain /  FAttackDecayBlocks) / 20 );
  // Applies to power, divide by 10:
  FSensitivityFactor := power(10.0, FSensitivity/10.0);
  FMinSignalBlocks := Trunc(FMinSignalTime * FSampleRate / (FWindowSize / 2));
  if( FMinSignalBlocks < 1 ) then
    FMinSignalBlocks := 1;
  FHistoryLen := (2 * FAttackDecayBlocks) - 1;

  if (FHistoryLen < FMinSignalBlocks) then
    FHistoryLen := FMinSignalBlocks;

  SetLength(FSpectrums, FHistoryLen);
  SetLength(FGains, FHistoryLen);
  SetLength(FRealFFTs, FHistoryLen);
  SetLength(FImagFFTs, FHistoryLen);
  for i := 0 to FHistoryLen-1 do
  begin
    FSpectrums[i] := NewFloatArray(FSpectrumSize);
    FGains[i]     := NewFloatArray(FSpectrumSize);
    FRealFFTs[i]  := NewFloatArray(FSpectrumSize);
    FImagFFTs[i]  := NewFloatArray(FSpectrumSize);
  end;

   // Initialize the FFT
   FFFT := TFFT.InitializeFFT(FWindowSize);

   FFFTBuffer        := NewFloatArray(FWindowSize);
   FInWaveBuffer     := NewFloatArray(FWindowSize);
   FWindow           := NewFloatArray(FWindowSize);
   FOutOverlapBuffer := NewFloatArray(FWindowSize);

   // Create a Hanning window function
   for i := 0 to FWindowSize-1 do
      FWindow[i] := 0.5 - 0.5 * cos((2.0*pi*i) / FWindowSize);

   if FDoProfile then
   begin
      FillChar(FNoiseThreshold[0], SizeOf(FNoiseThreshold[0])*FSpectrumSize, 0);
      //for i := 0 to FSpectrumSize-1 do
      //   FNoiseThreshold[i] := float(0);
   end;

end;

procedure TNoiseRemoval.Reset;
var
  i, j: Integer;
begin
  for i := 0 to FHistoryLen-1 do
  begin
    for j := 0 to FSpectrumSize-1 do
    begin
      FSpectrums[i][j] := 0;
      FGains[i][j] := FNoiseAttenFactor;
      FRealFFTs[i][j] := 0.0;
      FImagFFTs[i][j] := 0.0;
    end;
  end;

  for j := 0 to FWindowSize-1 do
    FOutOverlapBuffer[j] := 0.0;

  FInputPos := 0;
  FInSampleCount := 0;
  FOutSampleCount := -(FWindowSize div 2) * (FHistoryLen - 1);
end;

function Min(A, B: Integer): Integer;
begin
  if A < B then
    Exit(A);
  Result := B;
end;

procedure TNoiseRemoval.ProcessSamples(len: Integer; Buffer: PSingle);
var
  i: Integer;
  avail: Integer;
begin
  //while((len and FOutSampleCount) < FInSampleCount) do
  while len > 0 do
  begin
    avail := Min(len, FWindowSize - FInputPos);
    for i := 0 to avail-1 do
      FInWaveBuffer[FInputPos + i] := buffer[i];
    buffer += avail;
    len -= avail;
    FInputPos += avail;

    if (FInputPos = FWindowSize) then
    begin
      FillFirstHistoryWindow();
      if (FDoProfile) then
        GetProfile()
      else
        RemoveNoise();
      RotateHistoryWindows();

      // Rotate halfway for overlap-add
      //for(i = 0; i < mWindowSize / 2; i++) {
      for i := 0 to FWindowSize div 2 -1 do
        FInWaveBuffer[i] := FInWaveBuffer[i + FWindowSize div 2];

      FInputPos := FWindowSize div 2;
    end;
  end;
end;

procedure TNoiseRemoval.FillFirstHistoryWindow;
var
  i: Integer;
begin
  for i := 0 to FWindowSize-1 do
    FFFTBuffer[i] := FInWaveBuffer[i];
  FFFT^.RealFFTf(FFFTBuffer);
  //for(i = 1; i < (mSpectrumSize-1); i++) {
  for i := 1 to FSpectrumSize-2 do
  begin
    FRealFFTs[0][i] := FFFTBuffer[FFFT^.BitReversed[i]  ];
    FImagFFTs[0][i] := FFFTBuffer[FFFT^.BitReversed[i]+1];
    FSpectrums[0][i] := FRealFFTs[0][i]*FRealFFTs[0][i] + FImagFFTs[0][i]*FImagFFTs[0][i];
    FGains[0][i] := FNoiseAttenFactor;
  end;

   // DC and Fs/2 bins need to be handled specially
   FSpectrums[0][0] := FFFTBuffer[0]*FFFTBuffer[0];
   FSpectrums[0][FSpectrumSize-1] := FFFTBuffer[1]*FFFTBuffer[1];
   FGains[0][0] := FNoiseAttenFactor;
   FGains[0][FSpectrumSize-1] := FNoiseAttenFactor;
end;

function Max(A,B: Integer): Integer; inline;
begin
  if A>B then
    Exit(A);
  Result := B;
end;

procedure TNoiseRemoval.ApplyFreqSmoothing(ASpec: PSingle);
var
  tmp: PSingle;
  i, j, j0, j1: Integer;
begin
  tmp := NewFloatArray(FSpectrumSize);
  for i := 0 to FSpectrumSize-1 do
  begin
      j0 := Max(0, i - FFreqSmoothingBins);
      j1 := Min(FSpectrumSize-1, i + FFreqSmoothingBins);
      tmp[i] := 0.0;
      //for(j = j0; j <= j1; j++)
      for j := j0 to j1-1 do
      begin
         tmp[i] += Aspec[j];
      end;
      tmp[i] := tmp[i] / (j1 - j0 + 1);
   end;

   //for(i = 0; i < mSpectrumSize; i++)
   for i := 0 to  FSpectrumSize-1 do
      Aspec[i] := tmp[i];

   Freemem(Tmp);
end;

procedure TNoiseRemoval.GetProfile;
var
  start,
  finish,
  i, j: Integer;
  min: Single;
begin
  // The noise threshold for each frequency is the maximum
  // level achieved at that frequency for a minimum of
  // mMinSignalBlocks blocks in a row - the max of a min.

  start := FHistoryLen - FMinSignalBlocks;
  finish := FHistoryLen;


  for j := 0 to FSpectrumSize-1 do
  begin
    min := FSpectrums[start][j];
    for i := start+1 to finish-1 do
      if (FSpectrums[i][j] < min) then
        min := FSpectrums[i][j];

    if (min > FNoiseThreshold[j]) then
      FNoiseThreshold[j] := min;
  end;

  FOutSampleCount += FWindowSize div 2; // what is this for?  Not used when we are getting the profile?
end;

procedure TNoiseRemoval.RemoveNoise;
var
  center: Integer;
  start,
  finish,
  i,j : Integer;
  min: Single;
  out_: Integer;
begin
  center := FHistoryLen div 2;
  start  := center - FMinSignalBlocks div 2;
  finish := start + FMinSignalBlocks;

   // Raise the gain for elements in the center of the sliding history
   for j := 0 to FSpectrumSize-1 do
   begin
      min := FSpectrums[start][j];
      //for (i = start+1; i < finish; i++) {
      for i := start+1 to finish-1 do
      begin
        if (FSpectrums[i][j] < min) then
          min := FSpectrums[i][j];
      end;
      if (min > FSensitivityFactor * FNoiseThreshold[j]) and (FGains[center][j] < 1.0) then
      begin
         if (FbLeaveNoise) then
           FGains[center][j] := 0.0
         else
           FGains[center][j] := 1.0;
      end
      else
      begin
         if (FbLeaveNoise) then
           FGains[center][j] := 1.0;
      end;
   end;

   // Decay the gain in both directions;
   // note that mOneBlockAttackDecay is less than 1.0
   // of linear attenuation per block
   for j := 0 to FSpectrumSize-1 do
   begin
     for i := center+1 to FHistoryLen-1 do
     begin
       if (FGains[i][j] < FGains[i - 1][j] * FOneBlockAttackDecay) then
         FGains[i][j] := FGains[i - 1][j] * FOneBlockAttackDecay;
       if (FGains[i][j] < FNoiseAttenFactor) then
         FGains[i][j] := FNoiseAttenFactor;
     end;
     for i := center-1 downto 0 do
     begin
       if (FGains[i][j] < FGains[i + 1][j] * FOneBlockAttackDecay) then
         FGains[i][j] := FGains[i + 1][j] * FOneBlockAttackDecay;
       if (FGains[i][j] < FNoiseAttenFactor) then
         FGains[i][j] := FNoiseAttenFactor;
     end;
   end;


   // Apply frequency smoothing to output gain
   out_ := FHistoryLen - 1;  // end of the queue

   ApplyFreqSmoothing(FGains[out_]);

   // Apply gain to FFT
   //for (j = 0; j < (mSpectrumSize-1); j++) {
   for j := 0 to FSpectrumSize-2 do
   begin
     FFFTBuffer[j*2  ] := FRealFFTs[out_][j] * FGains[out_][j];
     FFFTBuffer[j*2+1] := FImagFFTs[out_][j] * FGains[out_][j];
   end;
   // The Fs/2 component is stored as the imaginary part of the DC component
   FFFTBuffer[1] := FRealFFTs[out_][FSpectrumSize-1] * FGains[out_][FSpectrumSize-1];

   // Invert the FFT into the output buffer
   FFFT^.InverseRealFFTf(FFFTBuffer);

   // Overlap-add
   for j := 0 to FSpectrumSize-2 do
   begin
      FOutOverlapBuffer[j*2  ] += FFFTBuffer[FFFT^.BitReversed[j]  ] * FWindow[j*2  ];
      FOutOverlapBuffer[j*2+1] += FFFTBuffer[FFFT^.BitReversed[j]+1] * FWindow[j*2+1];
   end;

   // Output the first half of the overlap buffer, they're done -
   // and then shift the next half over.

   if (FOutSampleCount >= 0) then // ...but not if it's the first half-window
   begin
      //FOutputTrack->Append((samplePtr)mOutOverlapBuffer, floatSample, mWindowSize / 2);
     FWriteProc(Self, FOutOverlapBuffer, FWindowSize div 2);
   end;


   FOutSampleCount += FWindowSize div 2;
   //for(j = 0; j < mWindowSize / 2; j++)
   for j := 0 to FWindowSize div 2 -1 do
   begin
      FOutOverlapBuffer[j] := FOutOverlapBuffer[j + (FWindowSize div 2)];
      FOutOverlapBuffer[j + (FWindowSize div 2)] := 0.0;
   end
end;

procedure TNoiseRemoval.RotateHistoryWindows;
var
  last: Integer;
  i: Integer;
  lastSpectrum: PSingle;
  lastGain: PSingle;
  lastRealFFT: PSingle;
  lastImagFFT: PSingle;
begin
  last := FHistoryLen - 1;

   // Remember the last window so we can reuse it
   lastSpectrum := FSpectrums[last];
   lastGain     := FGains[last];
   lastRealFFT  := FRealFFTs[last];
   lastImagFFT  := FImagFFTs[last];

   // Rotate each window forward
   //for(i = last; i >= 1; i--) {
   for i := last downto 1 do
   begin
     FSpectrums[i] := FSpectrums[i-1];
     FGains[i]     := FGains[i-1];
     FRealFFTs[i]  := FRealFFTs[i-1];
     FImagFFTs[i]  := FImagFFTs[i-1];
   end;

   // Reuse the last buffers as the new first window
   FSpectrums[0] := lastSpectrum;
   FGains[0]     := lastGain;
   FRealFFTs[0]  := lastRealFFT;
   FImagFFTs[0]  := lastImagFFT;
end;

procedure TNoiseRemoval.FinishTrack;
var
  empty: PSingle;
  i: Integer;
begin
  // Keep flushing empty input buffers through the history
  // windows until we've output exactly as many samples as
  // were input.
  // Well, not exactly, but not more than mWindowSize/2 extra samples at the end.
  // We'll delete them later in ProcessOne.
  empty := NewFloatArray(FWindowSize div 2);
  //for(i = 0; i < mWindowSize / 2; i++)
  for i := 0 to FWindowSize div 2 -1 do
    empty[i] := 0.0;

  while (FOutSampleCount < FInSampleCount) do
    ProcessSamples(FWindowSize div 2, empty);

  Freemem(empty);
end;

procedure TNoiseRemoval.Cleanup;
var
  i: Integer;
begin
   FFFT^.EndFFT;

   if (FDoProfile) then
      ApplyFreqSmoothing(@FNoiseThreshold[0]);


   for i := 0 to FHistoryLen-1 do
   begin
     FreeMem(FSpectrums[i]);
     FreeMem(FGains[i]);
     FreeMem(FRealFFTs[i]);
     FreeMem(FImagFFTs[i]);
   end;
   SetLength(FSpectrums,0);
   SetLength(FGains,0);
   SetLength(FRealFFTs,0);
   SetLength(FImagFFTs,0);

   FreeMem(FFFTBuffer);
   FreeMem(FInWaveBuffer);
   FreeMem(FWindow);
   FreeMem(FOutOverlapBuffer);

   FInited := False;
end;

function TNoiseRemoval.GetNoiseProfile: TSingleArray;
begin
  SetLength(Result, FSpectrumSize);
  Move(FNoiseThreshold[0], Result[0], FSpectrumSize);
end;

procedure TNoiseRemoval.SetAttackDecayTime(AValue: Double);
begin
  if FAttackDecayTime=AValue then Exit;
  if AValue < 0.0 then AValue := 0;
  if AValue > 1.0 then AValue := 1.0;
  FAttackDecayTime:=AValue;
end;

procedure TNoiseRemoval.SetFreqSmoothingHz(AValue: Double);
begin
  if FFreqSmoothingHz=AValue then Exit;
  if AValue<0 then AValue:=0;
  if AValue>1000 then AValue := 1000;
  FFreqSmoothingHz:=AValue;
end;

procedure TNoiseRemoval.SetGain(AValue: Double);
begin
  if FNoiseGain=AValue then Exit;
  if AValue > 0 then AValue:=0;
  if AValue < -48 then AValue := -48;

  FNoiseGain:=AValue;
end;

procedure TNoiseRemoval.SetNoiseProfile(AValue: TSingleArray);
begin
  SetLength(FNoiseThreshold, FSpectrumSize);
  Move(AValue[0], FNoiseThreshold[0], FSpectrumSize);
  FHasProfile:=True;

  FDoProfile:=False;
  Cleanup; // set after FDoProfile so the profile is not processed.

end;

procedure TNoiseRemoval.SetSensitivity(AValue: Double);
begin
  if FSensitivity=AValue then Exit;
  if AValue < -20.0 then AValue:=-20.0;
  if AValue > 20.0 then AValue := 20.0;
  FSensitivity:=AValue;
end;

constructor TNoiseRemoval.Create;
begin
  FWindowSize:=2048;
  FSpectrumSize:= 1 + FWindowSize div 2;

  // loaded prefs
  FSensitivity := 0.0;
  FNoiseGain := -24.0;
  FFreqSmoothingHz := 150.0;
  FAttackDecayTime:= 0.15;
  FbLeaveNoise:=False;

  FMinSignalTime := 0.05;
  FHasProfile := False;
  FDoProfile := True;

  SetLength(FNoiseThreshold, FSpectrumSize);

end;

destructor TNoiseRemoval.Destroy;
begin
  SetLength(FNoiseThreshold, 0);
  inherited Destroy;
end;

function TNoiseRemoval.Init(ASampleRate: Integer): Boolean;
begin
  FSampleRate:=ASampleRate;
  Initialize;
  FInited:=True;
  Result := True;
  Reset;
end;

function TNoiseRemoval.Process(AData: PSingle; ASampleCount: Integer;
  AGetNoiseProfile: Boolean; AMoreComing: Boolean = False): Boolean;
begin
  if not FInited then
    Raise Exception.Create('TNoiseRemoval is not Inited');

  if not AGetNoiseProfile and not FHasProfile then
    raise Exception.Create('Tried to remove noise without profile.');

  FDoProfile:=AGetNoiseProfile;

  if FDoProfile and (FTotalRead = 0) then
  begin
    Initialize;
    reset;
  end;

  Inc(FTotalRead, ASampleCount);
  ProcessSamples(ASampleCount, AData);
  Result := True;

  if AMoreComing then
    Exit;

  if {AGetNoiseProfile or }FDoProfile then
  begin
    FHasProfile:=True;
    Cleanup; // triggers the data in FNoiseThreshold to be processed

    // must be set after Cleanup() is called
    //FDoProfile:=False;

    //Initialize;
    FTotalRead:=0;
  end;

  FHasProfile:=True;
  FDoProfile := False;

end;

procedure TNoiseRemoval.Flush;
begin
  if not FInited then
    Exit;

  FinishTrack;
  Cleanup; // Sets FInited to False
end;

{ TFFT }

function TFFT.InitializeFFT(FFTLen: Integer): PFFT;
var
  i: Integer;
  temp: Integer;
  mask: Integer;
begin
   Result := New(PFFT);
   if Result = nil then
     raise EOutOfMemory.Create('Error allocating memory for FFT');


   with Result^ do begin

   {*
   *  FFT size is only half the number of data points
   *  The full FFT output can be reconstructed from this FFT's output.
   *  (This optimization can be made since the data is real.)
   *}
   Points := FFTLen div 2;

   SetLength(FPCSinTable, 2*Points);
   SinTable:=@FPCSinTable[0];

   BitReversed := Getmemory(Points*SizeOf(Integer));
   if BitReversed = nil then
     raise EOutOfMemory.Create('Error allocating memory for BitReversed.');

   for i := 0 to Points-1 do
   begin
      temp:=0;
      mask := Points div 2;
      while mask > 0 do
      begin
        //for(mask=h->Points/2;mask>0;mask >>= 1)
        //   temp=(temp >> 1) + (i&mask ? h->Points : 0);
        temp := (temp shr 1);
        if (i and mask) <> 0 then
          temp := temp + Points;
        //else temp := temp + 0;  // why would you do that?
        mask := mask shr 1;
      end;

      BitReversed[i]:=temp;
   end;

   for i := 0 to Points-1 do
   begin
     SinTable[BitReversed[i]  ]:= -sin(2*PI*i/(2*Points));
     SinTable[BitReversed[i]+1]:= -cos(2*PI*i/(2*Points));
   end;

{$ifdef EXPERIMENTAL_EQ_SSE_THREADED}
   // new SSE FFT routines work on live data
   for(i=0;i<32;i++)
      if((1<<i)&fftlen)
         h->pow2Bits=i;
{$endif}

   end; // with Result^


end;

procedure TFFT.EndFFT;
begin
  if Points>0 then
  begin
    Freemem(BitReversed);
    SetLength(FPCSinTable, 0);
    SinTable:=nil;
  end;

  Dispose(PFFT(@Self));
end;

function TFFT.GetFFT(FFTLen: Integer): PFFT;
var
  h: Integer = 0;
  n: Integer;
begin
  n := fftlen div 2;

  while (h<MAX_HFFT) and (FFTArray[h] <> nil) and (n <> FFTArray[h]^.Points) do
  begin
    if (h<MAX_HFFT) then
    begin
      if(FFTArray[h] = nil) then
      begin
        FFTArray[h] := InitializeFFT(fftlen);
        FFTLockCount[h] := 0;
      end;
      Inc(FFTLockCount[h]);
      Exit(FFTArray[h]);
    end
    else begin
      // All buffers used, so fall back to allocating a new set of tables
      Exit(InitializeFFT(fftlen));
    end;
    Inc(h);
  end;
end;

procedure TFFT.ReleaseFFT;
var
  h: Integer = 0;
begin

   while (h<MAX_HFFT) and (FFTArray[h] <> @Self) do
   begin
     if(h<MAX_HFFT) then
     begin
       Dec(FFTLockCount[h]);
     end
     else
     begin
       EndFFT;
     end;
     Inc(h);
   end;
end;

procedure TFFT.InverseRealFFTf(buffer: PSingle);
var
  A, B: PSingle;
  sptr: PSingle;
  endptr1, endptr2: PSingle;
  br1: PInteger;
  HRplus,HRminus,HIplus,HIminus: Single;
  v1,v2,sin,cos: Single;
  ButterfliesPerGroup: Integer;
begin

   ButterfliesPerGroup:=Points div 2;

   //* Massage input to get the input for a real output sequence. */
   A:=@buffer[2];
   B:=@buffer[Points*2-2];
   br1:=@BitReversed[1];
   while(A<B) do
   begin
      sin:=SinTable[br1^];
      cos:=SinTable[br1[1]];
      //HRplus = (HRminus = *A     - *B    ) + (*B     * 2);
      HRminus:=A^-B^;
      HRplus:=HRminus+ (B^ *2);

      //HIplus = (HIminus = *(A+1) - *(B+1)) + (*(B+1) * 2);
      HIminus:=A[1]-B[1];
      HIplus:=HIminus+(B[1] *2);

      v1 := (sin*HRminus + cos*HIplus);
      v2 := (cos*HRminus - sin*HIplus);
      A^ := (HRplus  + v1) * single(0.5);
      B^ := A^ - v1;
      A[1] := (HIminus - v2) * single(0.5);
      B[1] := A[1] - HIminus;

      A+=2;
      B-=2;
      Inc(br1);
   end;
   //* Handle center bin (just need conjugate) */
   A[1] :=-A[1];
   {* Handle DC bin separately - this ignores any Fs/2 component
   buffer[1]=buffer[0]=buffer[0]/2;*}
   //* Handle DC and Fs/2 bins specially */
   //* The DC bin is passed in as the real part of the DC complex value */
   //* The Fs/2 bin is passed in as the imaginary part of the DC complex value */
   //* (v1+v2) = buffer[0] == the DC component */
   //* (v1-v2) = buffer[1] == the Fs/2 component */
   v1:=0.5*(buffer[0]+buffer[1]);
   v2:=0.5*(buffer[0]-buffer[1]);
   buffer[0]:=v1;
   buffer[1]:=v2;

   {*
   *  Butterfly:
   *     Ain-----Aout
   *         \ /
   *         / \
   *     Bin-----Bout
   *}

   endptr1:=@buffer[Points*2];

   while(ButterfliesPerGroup>0) do
   begin
      A:=buffer;
      B:=@buffer[ButterfliesPerGroup*2];
      sptr:=@SinTable[0];

      while(A<endptr1) do
      begin
         sin:=sptr^; Inc(sptr); // *(sptr++);
         cos:=sptr^; Inc(sptr); // *(sptr++);
         endptr2:=B;
         while(A<endptr2) do
         begin
            v1:=B^*cos - B[1]*sin;
            v2:=B^*sin + B[1]*cos;
            B^ := (A^+v1)*Single(0.5);
            A^ := B^ - v1; Inc(A); Inc(B); //*(A++)=*(B++)-v1;
            B^ := (A^ + v2)* Single(0.5);    //*B=(*A+v2)*(fft_type)0.5;
            A^ := B^ - v2; Inc(A); Inc(B); //*(A++)=*(B++)-v2;
         end;
         A:=B;
         B := @B[ButterfliesPerGroup*2];
      end;
      ButterfliesPerGroup := ButterfliesPerGroup shr 1;
   end;
end;

procedure TFFT.CleanupFFT;
var
  h: Integer;
begin

   for h :=0 to  MAX_HFFT-1do begin
      if((FFTLockCount[h] <= 0) and (FFTArray[h] <> nil)) then
      begin
        FFTArray[h]^.EndFFT;
        FFTArray[h] := nil;
      end;
   end;
end;

procedure TFFT.RealFFTf(buffer: PSingle);
var
  A, B: PSingle;
  sptr: PSingle;
  endptr1, endptr2: PSingle;
  br1, br2: PInteger;
  HRplus,HRminus,HIplus,HIminus: Single;
  v1,v2,sin_,cos_: Single;
  ButterfliesPerGroup: Integer;
begin
  ButterfliesPerGroup:=Points div 2;

   {*
   *  Butterfly:
   *     Ain-----Aout
   *         \ /
   *         / \
   *     Bin-----Bout
   *}

   endptr1:=buffer+Points*2;

   while(ButterfliesPerGroup>0) do
   begin
      A:=buffer;
      B:=buffer+ButterfliesPerGroup*2;
      sptr:=@SinTable[0];

      while(A<endptr1) do
      begin
         sin_:=sptr^;
         cos_ := sptr[1];
         endptr2:=B;
         while(A<endptr2) do
         begin
           v1 := B^ * cos_ + B[1] * sin_;  //v1=*B*cos + *(B+1)*sin;
           v2 := B^ * sin_ - B[1] * cos_;  //v2=*B*sin - *(B+1)*cos;
           B^ := A^+v1;                    //*B=(*A+v1);
           A^ := B^-2*v1; Inc(A); Inc(B);  //*(A++)=*(B++)-2*v1;

           B^ := A^-v2;                    //*B=(*A-v2);
           A^ := B^+2*v2; Inc(A); Inc(B);  //*(A++)=*(B++)+2*v2;
         end;
         A:=B;
         B:=B+ButterfliesPerGroup*2;
         sptr:=sptr+2;
      end;

      ButterfliesPerGroup := ButterfliesPerGroup shr 1;
   end;

   //* Massage output to get the output for a real input sequence. */
   br1:=@BitReversed[1];   // is this wrong? Should be @BitReversed[0] ; ?
   br2:=@BitReversed[Points-1];

   while(br1<br2) do
   begin
      sin_:=SinTable[br1[0]];
      cos_:=SinTable[br1[1]];
      A:=@buffer[br1^];
      B:=@buffer[br2^];
      //HRplus = (HRminus = *A     - *B    ) + (*B     * 2);
      HRminus := A^ - B^;
      HRplus := HRminus + (B^ * 2);

      //HIplus = (HIminus = *(A+1) - *(B+1)) + (*(B+1) * 2);
      HIminus := A[1] - B[1];
      HIplus := HIminus + (B[1] * 2);

      v1 := (sin_*HRminus - cos_*HIplus);
      v2 := (cos_*HRminus + sin_*HIplus);
      A^ := (HRplus  + v1) * single(0.5);
      B^ := A^ - v1;
      A[1] := (HIminus + v2) * single(0.5);
      B[1] := A[1] - HIminus;

      Inc(br1);
      Dec(br2);
   end;
   //* Handle the center bin (just need a conjugate) */
   A:=buffer+br1[1];
   A^ := -A^;
   {* Handle DC bin separately - and ignore the Fs/2 bin
   buffer[0]+=buffer[1];
   buffer[1]=(fft_type)0;*}
   ///* Handle DC and Fs/2 bins separately */
   ///* Put the Fs/2 value into the imaginary part of the DC bin */
   v1:=buffer[0]-buffer[1];
   buffer[0]+=buffer[1];
   buffer[1]:=v1;

end;

procedure TFFT.ReorderToTime(Buffer: PSingle; TimeOut: PSingle);
var
  i: Integer;
begin
  // Copy the data into the real outputs
   //for(int i=0;i<hFFT->Points;i++) {
  for i := 0 to Points-1 do
  begin
    TimeOut[i*2  ]:=buffer[BitReversed[i]  ];
    TimeOut[i*2+1]:=buffer[BitReversed[i]+1];
  end;
end;

procedure TFFT.ReorderToFreq(Buffer: PSingle; RealOut: PSingle; ImagOut: PSingle
  );
var
  i: Integer;
begin
  // Copy the data into the real and imaginary outputs
  //for(int i=1;i<hFFT->Points;i++)
  for i := 1 to Points-1 do
  begin

      RealOut[i]:=buffer[BitReversed[i]  ];
      ImagOut[i]:=buffer[BitReversed[i]+1];
   end;
   RealOut[0] := buffer[0]; // DC component
   ImagOut[0] := 0;
   RealOut[Points] := buffer[1]; // Fs/2 component
   ImagOut[Points] := 0;
end;

initialization
  FillChar(FFTArray, SizeOf(FFTArray), 0);
  FillChar(FFTLockCount, SizeOf(FFTLockCount), 0);

end.

