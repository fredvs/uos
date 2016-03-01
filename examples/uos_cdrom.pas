{This unit is part of United Openlibraries of Sound (uos)}
{
     From CDRom, CDromLinux, CDRomWindows
         By Franklyn A. Harlow Feb 2016
           License : modified LGPL.
     Merged by Fred van Stappen fiens/hotmail.com  }

unit uos_cdrom;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF FPC}cdrom,{$ENDIF}
{$IFDEF MSWINDOWS}
 Windows,
{$ENDIF}
{$IFDEF unix}
 baseunix,
{$ENDIF}
 Classes, SysUtils;

  Const
  CDROM_OK = 0;
  CDROM_UNKNOWNERR = -1;

  CD_FRAMESIZE_RAW = 2352;
  BUF_SIZE = 75 * CD_FRAMESIZE_RAW;  // 75 frames - 1 sec

  kCDDA_Base     = 'cdda://sr';
  kCDDA_Track    = 'Track%20';
  kCDDA_TrackWin = 'Track';

Type
  TCDDATrackType = (cdtAudio, cdtData, cdtMixed);
  Tmsf = record
    min    : Byte;
    sec    : Byte;
    Frame  : Byte;
  end;
  TCDDAPosition = record
    Track : LongInt;
    msf   : Tmsf;
  end;
  TCDDATrackInfo = record
    TrackLength : Tmsf;
    TrackType   : TCDDATrackType;
  end;
  TCDStatus = (cdsNotReady, cdsReady, cdsPlaying, cdsPaused);
  TCDDATOCEntry = record
     dwStartSector : LongInt;   // Start sector of the track
     btFlag        : Byte;	    // Track flags (i.e. data or audio track)
     btTrackNumber : Byte;	    // Track number
   end;

  PCDROMInfo = ^TCDROMInfo;
  TCDROMInfo = Record

    Channels        : longword;  // stereo = 2
    BitsPerSample   : longword;  // ie short/smallint = 16
    SampleRate      : longword;  // Frequency = 44100
    TotalSamples    : Int64;
    TotalTime       : LongWord;  // Seconds
    pData           : pByte;
    pDataLen        : longword;
    Size            : Int64;
    Position        : Int64;
    StartPos        : TCDDAPosition;
    EndPos          : TCDDAPosition;
    BufStart        : LongWord;
    BufEnd          : LongWord;
    BufSize         : LongInt;
    Buf             : array[1..BUF_SIZE*2] of Byte;
    BufTmp          : array[1..BUF_SIZE*2] of Byte;
    fHandleVaild    : longint;    // 0< : Impossible, 0: Not Valid, >0 : Valid/Available
    CurrentPosition : Tmsf;       // Current Position Of Track Being Read
    {$IFDEF LIBCDRIP}
      Opened                 : LongInt;
      Busy                   : Boolean;
      CurrentDrive           : LongInt;
      EnableJitterCorrection : Boolean;
      LastJitterErrors       : LongInt;
      ReadSectors            : LongInt;
      OverlapSectors         : LongInt;
      CompareSectors         : LongInt;
      MultiReadCount         : LongInt;
      Paranoid               : Boolean;
      ParanoiaMode           : LongInt;
      LockTray               : Boolean;
      Status                 : TCDStatus;
      RipSize                : LongInt;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
      hCDROM          : longword;   // CDROM CreateFile Handle
    {$ENDIF}
    {$IFDEF unix}
      hCDROM          : longint;    // CDROM fpOpen Handle
    {$ENDIF}
  End;

Const
  EndOfDisc : TCDDAPosition = (Track : 100; msf : (min : 0; sec : 0; frame : 0));

  Function Frames2MSF(Frames : LongInt) : Tmsf;
  Function MSF2Frames(const msf : Tmsf) : LongInt;
  Function AddressToSectors (msf : Tmsf): int64;

  Function LoadCDROM(Lib : AnsiString): LongWord;
  Function UnloadCDROM: LongWord;
  Function isCDROMLoaded : Boolean;

  Function CDROM_GetFileNameDrive(FileName : AnsiString): Byte;
  Function CDROM_GetFileNameTrack(FileName : AnsiString): Byte;

  Function CDROM_OpenFile(FileName : AnsiString): PCDROMInfo;
  Function CDROM_Open(Drive, Track : Byte): PCDROMInfo;
  Function CDROM_Close(var pCDROMI: PCDROMInfo): LongWord;
  Function CDROM_GetData(var pCDROMI: PCDROMInfo; var pData: Pointer; var DataLength: longword): LongWord;

  Function GetSystemCDRoms: AnsiString;

implementation

Function LoadCDROM(Lib : AnsiString): LongWord;
Begin
     Result:= 32767;
  end;

Function UnloadCDROM: LongWord;
Begin
     Result:= 32767;
 end;

Function isCDROMLoaded : Boolean;
Begin
    Result:= True;
 end;

{$IFDEF unix}
Const
  CDROM_LBA           = $01;        // 'logical block': first frame is #0
  CDROM_MSF           = $02;        // 'minute-second-frame': binary, not bcd here!
  CDROM_DATA_TRACK    = $40;
  CDROM_LEADOUT       = $AA;

  CDROMREADTOCHDR     = $5305;      // Read TOC header
  CDROMREADTOCENTRY   = $5306;      // Read TOC entry
  CDROMREADAUDIO      = $530E;      // (struct cdrom_read_audio)
  CDROM_DRIVE_STATUS  = $5326;      // Get tray position, etc.
  CDROM_DISC_STATUS   = $5327;      // Get disc type, etc.

  CDS_NO_DISC = 1;
  CDS_TRAY_OPEN = 2;
  CDS_DRIVE_NOT_READY = 3;
  CDS_DISC_OK = 4;

  CDS_AUDIO = 100;
  CDS_MIXED = 105;

type
  cdrom_addr = record
   case Word of
    1: (msf: Tmsf;);
    2: (lba: longint;);
 end;
  cdrom_read_audio = record
    addr        : cdrom_addr; // frame address
    addr_format : Byte;       // CDROM_LBA or CDROM_MSF
    nframes     : LongInt;    // number of 2352-byte-frames to read at once
    buf         : PByte;      // frame buffer (size: nframes*2352 bytes)
  end;
  cdrom_tocentry = record
    cdte_track    : Byte;
    cdte_adr_ctrl : Byte;
    cdte_format   : Byte;
    cdte_addr     : cdrom_addr;
    cdte_datamode : Byte;
  end;
  cdrom_tochdr = record
    cdth_trk0: Byte;    // start track
    cdth_trk1: Byte;    // end track
  end;

// ********************** Private Linux SUPPORT Functions **************************************************************
function GetTrackInfo(hCDROM: LongInt; Track : LongInt): TCDDATrackInfo;
var
  Entry   : cdrom_tocentry;
  TOC     : cdrom_tochdr;
  F1      : LongInt;
  F2      : LongInt;
  Ret     : LongInt;
begin
  Ret:= fpioctl(hCDROM, CDROMREADTOCHDR, @TOC);
  if Ret <> 0 then
    raise Exception.Create('mcwCDROM_Linux.GetTrackInfo.fpioctl(CDROMREADTOCHDR) Error : ' + IntToStr(Ret));

  Entry.cdte_format := CDROM_MSF;
  Entry.cdte_track  := Track + TOC.cdth_trk0 - 1;

  Ret:= fpioctl(hCDROM, CDROMREADTOCENTRY, @Entry);
  if Ret <> 0 then
    raise Exception.Create('mcwCDROM_Linux.GetTrackInfo.fpioctl(CDROMREADTOCENTRY) Error : ' + IntToStr(Ret));

  F1 := MSF2Frames(Entry.cdte_addr.msf);

  if (Entry.cdte_adr_ctrl and CDROM_DATA_TRACK) <> 0 then
    Result.TrackType := cdtData
  else
    Result.TrackType := cdtAudio;

  if Entry.cdte_track < toc.cdth_trk1 then
    Inc(Entry.cdte_track)
  else
    Entry.cdte_track := CDROM_LEADOUT;

  Ret:= fpioctl(hCDROM, CDROMREADTOCENTRY, @Entry);
  if Ret <> 0 then
    raise Exception.Create('mcwCDROM_Linux.GetTrackInfo.fpioctl(CDROMREADTOCENTRY) #2 Error : ' + IntToStr(Ret));

  F2                := MSF2Frames(Entry.cdte_addr.msf);
  Result.TrackLength:= Frames2MSF(F2 - F1);
end;

function GetTrackMSF(hCDROM, Track : LongInt): Tmsf;
var
  entry : cdrom_tocentry;
  hdr   : cdrom_tochdr;
  Ret   : LongInt;
begin
  Ret:= fpioctl(hCDROM, CDROMREADTOCHDR, @hdr);
  if Ret <> 0 then
    raise Exception.Create('mcwCDROM_Linux.GetTrackMSF.fpioctl(CDROMREADTOCHDR) Error : ' + IntToStr(Ret));

  entry.cdte_format := CDROM_MSF;
  entry.cdte_track  := Track + hdr.cdth_trk0 - 1;
  if entry.cdte_track > hdr.cdth_trk1 then
    entry.cdte_track := CDROM_LEADOUT;

  Ret:= fpioctl(hCDROM, CDROMREADTOCENTRY, @entry);
  if Ret <> 0 then
    raise Exception.Create('mcwCDROM_Linux.GetTrackMSF.fpioctl(CDROMREADTOCENTRY) Error : ' + IntToStr(Ret));

  Result := entry.cdte_addr.msf;
end;

function GetPosMSF(hCDROM: LongInt; Pos : TCDDAPosition): Tmsf;
var
  msf1   : Tmsf;
  frames : longint;
begin
  msf1   := GetTrackMSF(hCDROM, Pos.Track);
  frames := MSF2Frames(msf1);
  frames := frames + MSF2Frames(Pos.msf);
  Result := Frames2MSF(frames);
end;

function GetSize(pCDROMI: PCDROMInfo): Int64;
var
  F1 : LongWord;
  F2 : LongWord;
begin
  F1:= (((pCDROMI^.StartPos.msf.min * 60) + pCDROMI^.StartPos.msf.sec) * 75) + pCDROMI^.StartPos.msf.Frame;
  F2:= (((pCDROMI^.EndPos.msf.min * 60) + pCDROMI^.EndPos.msf.sec) * 75) + pCDROMI^.EndPos.msf.Frame;
  Result := (F2 - F1) * CD_FRAMESIZE_RAW;
end;
// *********************************************************************************************************************

Function CDROM_GetFileNameDrive(FileName : AnsiString): Byte;
Begin
  Result:= 255;  // Assume Error
  if Copy(FileName, 1, Length(kCDDA_Base)) = kCDDA_Base then
    Result:= StrToIntDef(FileName[10], 256);
end;

Function CDROM_GetFileNameTrack(FileName : AnsiString): Byte;
Var
  s : AnsiString;
Begin
  Result:= 0;
  if Pos(kCDDA_Track, FileName) > 0 then
  Begin
    s:= Copy(FileName, Pos(kCDDA_Track, FileName) + Length(kCDDA_Track), Length(FileName));
    s:= Copy(s, 1, Pos('.', s) -1);
    Result:= StrToIntDef(s, 0);
  end;
end;

Function CDROM_OpenFile(FileName : AnsiString): PCDROMInfo;
Var
  Drive, Track : Byte;
Begin
  Result:= CDROM_Open(CDROM_GetFileNameDrive(FileName),
                      CDROM_GetFileNameTrack(FileName));
end;

Function CDROM_Open(Drive, Track : Byte): PCDROMInfo;
Var
  CDRomPath : AnsiString;
  slCDROMS  : TStringList;

  Res       : longint;
  Data      : longint;
  CDTI      : TCDDATrackInfo;
  CDTrackCount : LongInt;
  CDTOC        : Array of TTocEntry;
Begin
  Result:= nil;
  if (Drive = 255) or (Track < 1) then
    Exit;

  New(Result);

  // Read Only, CDROMI uses constants and ignores changes to these...
  Result^.Channels     := 2;
  Result^.BitsPerSample:= 16;
  Result^.SampleRate   := 44100;

  CDRomPath:= '/dev/sr' + IntToStr(Drive);
  slCDROMS := TStringList.Create;
  Try
    slCDROMS.Text:= GetSystemCDRoms;
    if slCDROMS.IndexOf(CDRomPath) = -1 then
      raise Exception.Create('mcwCDROM_Linux.CDROM_Open.GetSystemCDRoms Error : ' + CDRomPath + ' Not Found.');
  finally
    slCDROMS.Free;
  end;

  Result^.hCDROM:= fpopen(PAnsiChar(CDRomPath), O_RDONLY or O_NONBLOCK);;
  if Result^.hCDROM < 0 then
    raise Exception.Create('mcwCDROM_Linux.CDROM_Open.fpopen Error : (' + IntToStr(Result^.hCDROM) + ') On ' + CDRomPath);

  // What State Is CDROM in ?
  Res:= fpioctl(Result^.hCDROM, CDROM_DRIVE_STATUS, @Data);
  if Res <> CDS_DISC_OK then
  Begin
    CDROM_Close(Result);
    Dispose(Result);
    Result:= nil;
    Exit;
  end;
  // CDRom OK, What Kind Of Disk Do We Have?
  Res := fpioctl(Result^.hCDROM, CDROM_DISC_STATUS, @Data);
  if (Res <> CDS_AUDIO) And (Res <> CDS_MIXED) Then
  Begin
    CDROM_Close(Result);
    Dispose(Result);
    Result:= nil;
    Exit;
  end;

  CDTI := GetTrackInfo(Result^.hCDROM, Track);
  if CDTI.TrackType = cdtData then
    raise Exception.Create('mcwCDROM_Linux.CDROM_Open : Trying to rip a data track');

  Result^.StartPos.Track := Track;
  Result^.StartPos.msf   := GetTrackMSF(Result^.hCDROM, Result^.StartPos.Track);
  Result^.EndPos.Track   := Track +1;
  Result^.EndPos.msf     := GetTrackMSF(Result^.hCDROM, Result^.EndPos.Track);

  CDTrackCount := cdrom.ReadCDTOC(CDRomPath, CDTOC);

  if (Result^.EndPos.Track in [1..CDTrackCount]) = False then
    raise Exception.Create('mcwCDROM_Linux.CDROM_Open : The end track out of range' + #13 +
                           IntToStr(Result^.EndPos.Track) + ' Requested, 1..' + IntToStr(CDTrackCount) + ' Allowed...');

  Result^.CurrentPosition      := Result^.StartPos.msf;
  Result^.Position             := 0;
  Result^.Size                 := GetSize(Result);
  Result^.BufStart             := 1;
  Result^.BufEnd               := 0;
  Result^.BufSize              := BUF_SIZE;
  Result^.TotalSamples         := Result^.Size div 4;
  Result^.TotalTime            := Round(Result^.TotalSamples / 44100);

  Inc(Result^.fHandleVaild);

end;

Function CDROM_Close(var pCDROMI: PCDROMInfo): LongWord;
Begin
  Result := CDROM_UNKNOWNERR;
  if pCDROMI^.fHandleVaild = 1 then
    fpclose(pCDROMI^.hCDROM);
  if pCDROMI^.fHandleVaild > 0 then
   Dec(pCDROMI^.fHandleVaild);
  Result := CDROM_OK;
end;

Function CDROM_GetData(var pCDROMI: PCDROMInfo; var pData: Pointer; var DataLength: longword): LongWord;
var
  ReqLen     : LongWord;
  ReqFrames  : LongInt;
  cdaudio    : cdrom_read_audio;
  Ret        : LongWord;
  Res        : LongInt;
  TmpCount   : longword;
  Procedure getNextChunk;
  Begin
    TmpCount:= 0;

    // Have We Reached End On Track ?
    if MSF2Frames(pCDROMI^.CurrentPosition) >= MSF2Frames(pCDROMI^.EndPos.msf) then
    Begin
      pCDROMI^.BufEnd   := 0;
      pCDROMI^.BufStart := 0;
      Exit;
    End;

    // This is not first call
    if pCDROMI^.BufEnd > 0 then
    Begin
      // Copy Leftover Data to Start of buffer...
      TmpCount:= pCDROMI^.BufEnd - pCDROMI^.BufStart;
      Move(pCDROMI^.Buf[pCDROMI^.BufStart], pCDROMI^.BufTmp[1], TmpCount);
      Move(pCDROMI^.BufTmp[1], pCDROMI^.Buf[1], TmpCount);
    End;

    ReqFrames:= 75; // BUF_SIZE = 1 Sec Worth Data = 75 Frames = In Bytes
    if MSF2Frames(pCDROMI^.CurrentPosition) + ReqFrames > MSF2Frames(pCDROMI^.EndPos.msf) then
      ReqFrames:= MSF2Frames(pCDROMI^.EndPos.msf) - MSF2Frames(pCDROMI^.CurrentPosition);

    // *** Rip Next Chunk ******************************************
    cdaudio.nframes        := ReqFrames;  // BUF_SIZE = 1 Sec Worth Data = 75 Frames = In Bytes
    cdaudio.addr_format    := CDROM_MSF;
    cdaudio.addr.msf       := pCDROMI^.CurrentPosition;
    cdaudio.buf            := @pCDROMI^.Buf[TmpCount +1];

    Res:= fpioctl(pCDROMI^.hCDROM, CDROMREADAUDIO, @cdaudio);
    if Res <> 0 then
      raise Exception.Create('mcwCDROM_Linux.CDROM_GetData.getNextChunk.fpioctl(CDROMREADAUDIO) Error : ' + IntToStr(fpgeterrno));

    pCDROMI^.CurrentPosition:= Frames2MSF(MSF2Frames(pCDROMI^.CurrentPosition) + cdaudio.nframes);

    Ret := cdaudio.nframes * CD_FRAMESIZE_RAW;
    // *** End Rip Next Chunk ***************************************

    pCDROMI^.BufEnd:= TmpCount + Ret + 1;
    pCDROMI^.BufStart := 1;
  end;

begin
  // PortAudio expects exact amount of data, anything less causes "Blips"

  // pCDROMI.BufStart  = Start Byte of Current Valid, Not Sent Buffer...
  // pCDROMI.BufEnd    = Last  Byte of Current Valid, Not sent Buffer...

  ReqLen:= DataLength;

  if pCDROMI^.fHandleVaild = 0 then
    raise Exception.Create('mcwCDROM_Linux.CDROM_GetData Error : Call To GetData Without Vaild CDROM Handle.');

  // We don't read CDROM every call, only when we need new data...
  if (pCDROMI^.BufStart + ReqLen) > pCDROMI^.BufEnd then
    getNextChunk;

  // is the amount in buffer less than what was requested...
  if DataLength > (pCDROMI^.BufEnd - pCDROMI^.BufStart + 1) then
    DataLength := pCDROMI^.BufEnd - pCDROMI^.BufStart + 1;

  // Have We Finished Reading Track ?
  if pCDROMI^.BufEnd = 0 then
    DataLength:= 0;

  pData:= @pCDROMI^.Buf[pCDROMI^.BufStart];

  If DataLength > 0 Then
  Begin
    Inc(pCDROMI^.BufStart, DataLength);
    Inc(pCDROMI^.Position, DataLength);
  end;

  Result:= DataLength;
end;
{$ENDIF}
//////////////////////
{$IFDEF MSWINDOWS}
const
  CDDA = 2;
  IOCTL_CDROM_READ_TOC        = $00024000;
  IOCTL_CDROM_RAW_READ        = $0002403E;
  IOCTL_STORAGE_CHECK_VERIFY2 = $0002D0800;
  MAXIMUM_NUMBER_TRACKS       = 100;
  CB_CDROMSECTOR              = 2048;

Type
  _TRACK_DATA = record
      Reserved : UCHAR;
      Control_and_Adr: UCHAR;
      TrackNumber : UCHAR;
      Reserved1 : UCHAR;
      Address : array[0..3] of UCHAR;
    end;
  TRACK_DATA = _TRACK_DATA;
  PTRACK_DATA = ^_TRACK_DATA;
  _CDROM_TOC = record
      Length : WORD;
      FirstTrack : UCHAR;
      LastTrack  : UCHAR;
      TrackData  : array[0..(MAXIMUM_NUMBER_TRACKS)-1] of TRACK_DATA;
    end;
  CDROM_TOC = _CDROM_TOC;
  PCDROM_TOC = ^_CDROM_TOC;
  RAW_READ_INFO = record
    DiskOffset  : Int64;
    SectorCount : Cardinal;
    TrackMode   : Cardinal;
  end;

Function fpgeterrno(): LongWord;
Begin
  Result:= GetLastOSError;
end;

// ********************** Private Windows SUPPORT Functions ************************************************************
function GetTrackMSF(Table: CDROM_TOC; Track : LongInt): Tmsf;
begin
  Result.min  := Table.TrackData[Track -1].Address[1];
  Result.sec  := Table.TrackData[Track -1].Address[2];
  Result.Frame:= Table.TrackData[Track -1].Address[3];
end;

function GetPosMSF(Table: CDROM_TOC; Pos : TCDDAPosition): Tmsf;
var
  msf1   : Tmsf;
  frames : longint;
begin
  msf1   := GetTrackMSF(Table, Pos.Track);
  frames := MSF2Frames(msf1);
  frames := frames + MSF2Frames(Pos.msf);
  Result := Frames2MSF(frames);
end;

function GetSize(pCDROMI: PCDROMInfo): Int64;
var
  F1 : LongWord;
  F2 : LongWord;
begin
  F1:= (((pCDROMI^.StartPos.msf.min * 60) + pCDROMI^.StartPos.msf.sec) * 75) + pCDROMI^.StartPos.msf.Frame;
  F2:= (((pCDROMI^.EndPos.msf.min * 60) + pCDROMI^.EndPos.msf.sec) * 75) + pCDROMI^.EndPos.msf.Frame;
  Result := (F2 - F1) * CD_FRAMESIZE_RAW;
end;
// *********************************************************************************************************************

Function CDROM_GetFileNameDrive(FileName : AnsiString): Byte;
Var
  driveLetter : Char;
  drive       : Char;
  cdromcount  : Byte;
  found       : Boolean;
Begin
  found      := False;
  driveLetter:= FileName[1];
  cdromcount := 255;
  For drive := 'A' to 'Z' do
    if GetDriveType(PChar(drive + ':\')) = DRIVE_CDROM then
    Begin
      Inc(cdromcount);
      if drive = driveLetter then
      Begin
        found:= True;
        break;
      end;
    end;
  if not found then
    raise Exception.Create('CDROM (BDROM) Drive Not Found !');
  Result := cdromcount;
end;

Function CDROM_GetFileNameTrack(FileName : AnsiString): Byte;
Var
  s : AnsiString;
Begin
  // This works on Win7...
  s     := Copy(Filename, Pos(kCDDA_TrackWin, Filename) + 5, Length(Filename));
  s     := Copy(s, 1, Pos('.', s) -1);
  Result:= StrToIntDef(s , 0);
end;

Function CDROM_OpenFile(FileName : AnsiString): PCDROMInfo;
Var
  Drive, Track : Byte;
Begin
  Result:= CDROM_Open(CDROM_GetFileNameDrive(FileName),
                      CDROM_GetFileNameTrack(FileName));
end;

Function CDROM_Open(Drive, Track : Byte): PCDROMInfo;
Var
  CDRomPath : AnsiString;
  Table     : CDROM_TOC;
  BytesRead : LongWord;
  Ret       : BOOL;
  flags     : longword;
//  Index     : LongInt;
Begin
  Result:= nil;
  if (Drive = 255) or (Track < 1) then
    Exit;

  New(Result);

  // Read Only, CDROMI uses constants and ignores changes to these...
  Result^.Channels     := 2;
  Result^.BitsPerSample:= 16;
  Result^.SampleRate   := 44100;

  CDRomPath:= UpperCase('\\.\CDROM') + IntToStr(Drive);
  flags    := longword(GENERIC_READ);

  Result^.hCDROM:= CreateFileA(PAnsiChar(CDRomPath), Flags, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0 );
  if (Result^.hCDROM = INVALID_HANDLE_VALUE) then
    raise Exception.Create('mcwCDROM_Win.CDROM_Open.CreateFileA Error : (' + IntToStr(Result^.hCDROM) + ') On ' + CDRomPath);

  // What State Is CDROM in ?
  Ret:= DeviceIoControl(Result^.hCDROM, IOCTL_STORAGE_CHECK_VERIFY2, nil, 0, nil, 0, BytesRead, nil);
  if Not Ret then
  Begin
    CDROM_Close(Result);
    Dispose(Result);
    Result:= nil;
    Exit;
  end;

  Ret:= DeviceIoControl(Result^.hCDROM, IOCTL_CDROM_READ_TOC, nil, 0, @Table, sizeof(Table), BytesRead, nil);
  if Ret = False then
    raise Exception.Create('mcwCDROM_Win.CDROM_Open.DeviceIoControl(IOCTL_CDROM_READ_TOC) Error ');

  Result^.StartPos.Track  := Track;
  Result^.StartPos.msf    := GetTrackMSF(Table, Result^.StartPos.Track);
  Result^.EndPos.Track    := Track +1;
  Result^.EndPos.msf      := GetTrackMSF(Table, Result^.EndPos.Track);
  Result^.CurrentPosition := Result^.StartPos.msf;
  Result^.Position        := 0;
  Result^.Size            := GetSize(Result);
  Result^.BufStart        := 1;
  Result^.BufEnd          := 0;
  Result^.BufSize         := BUF_SIZE;
  Result^.TotalSamples    := Result^.Size div 4;
  Result^.TotalTime       := Round(Result^.TotalSamples / 44100);

  Inc(Result^.fHandleVaild);
end;

Function CDROM_Close(var pCDROMI: PCDROMInfo): LongWord;
Begin
  Result := CDROM_UNKNOWNERR;
  if pCDROMI^.fHandleVaild = 1 then
    CloseHandle(pCDROMI^.hCDROM);
  if pCDROMI^.fHandleVaild > 0 then
   Dec(pCDROMI^.fHandleVaild);
  Result := CDROM_OK;
end;

Function CDROM_GetData(var pCDROMI: PCDROMInfo; var pData: Pointer; var DataLength: longword): LongWord;
var
  ReqLen     : LongWord;
  ReqFrames  : LongInt;
  Info       : RAW_READ_INFO;
  BytesRead  : LongWord;
  Address    : Int64;
  Ret        : LongWord;
  Res        : BOOL;
  TmpCount   : longword;
  Procedure getNextChunk;
  Begin
    TmpCount:= 0;

    // Have We Reached End On Track ?
    if MSF2Frames(pCDROMI^.CurrentPosition) >= MSF2Frames(pCDROMI^.EndPos.msf) then
    Begin
      pCDROMI^.BufEnd   := 0;
      pCDROMI^.BufStart := 0;
      Exit;
    End;

    // This is not first call
    if pCDROMI^.BufEnd > 0 then
    Begin
      // Copy Leftover Data to Start of buffer...
      TmpCount:= pCDROMI^.BufEnd - pCDROMI^.BufStart;
      Move(pCDROMI^.Buf[pCDROMI^.BufStart], pCDROMI^.BufTmp[1], TmpCount);
      Move(pCDROMI^.BufTmp[1], pCDROMI^.Buf[1], TmpCount);
    End;
    // While Linux Can deal With 75 Frame Request, Windows Only 20 (?)
    ReqFrames:= 20; // BUF_SIZE = 1 Sec Worth Data = 75 Frames = In Bytes
    if MSF2Frames(pCDROMI^.CurrentPosition) + ReqFrames > MSF2Frames(pCDROMI^.EndPos.msf) then
      ReqFrames:= MSF2Frames(pCDROMI^.EndPos.msf) - MSF2Frames(pCDROMI^.CurrentPosition);

    // *** Rip Next Chunk ******************************************
    Address:= AddressToSectors(pCDROMI^.CurrentPosition);

    Info.TrackMode  := CDDA;
    Info.SectorCount:= ReqFrames;
    Info.DiskOffset := Address * CB_CDROMSECTOR;

    Res:= DeviceIoControl(pCDROMI^.hCDROM,
                          IOCTL_CDROM_RAW_READ,
                          @Info,
                          sizeof(Info),
                          @pCDROMI^.Buf[TmpCount +1],
                          ReqFrames * CD_FRAMESIZE_RAW,
                          BytesRead,
                          nil);
    if Res = False then
      raise Exception.Create('mcwCDROM_Win.CDROM_GetData.getNextChunk.fpioctl(CDROMREADAUDIO) Error : ' + IntToStr(fpgeterrno));

    pCDROMI^.CurrentPosition:= Frames2MSF(MSF2Frames(pCDROMI^.CurrentPosition) + ReqFrames);

    Ret := BytesRead; // Should Be The same as "ReqFrames * CD_FRAMESIZE_RAW"
    // *** End Rip Next Chunk ***************************************

    pCDROMI^.BufEnd:= TmpCount + Ret + 1;
    pCDROMI^.BufStart := 1;
  end;

begin
  // PortAudio expects exact amount of data, anything less causes "Blips"

  // pCDROMI.BufStart  = Start Byte of Current Valid, Not Sent Buffer...
  // pCDROMI.BufEnd    = Last  Byte of Current Valid, Not sent Buffer...

  ReqLen:= DataLength;

  if pCDROMI^.fHandleVaild = 0 then
    raise Exception.Create('mcwCDROM_Win.CDROM_GetData Error : Call To GetData Without Vaild CDROM Handle.');

  // We don't read CDROM every call, only when we need new data...
  if (pCDROMI^.BufStart + ReqLen) > pCDROMI^.BufEnd then
    getNextChunk;

  // is the amount in buffer less than what was requested...
  if DataLength > (pCDROMI^.BufEnd - pCDROMI^.BufStart + 1) then
    DataLength := pCDROMI^.BufEnd - pCDROMI^.BufStart + 1;

  // Have We Finished Reading Track ?
  if pCDROMI^.BufEnd = 0 then
    DataLength:= 0;

  pData:= @pCDROMI^.Buf[pCDROMI^.BufStart];

  If DataLength > 0 Then
  Begin
    Inc(pCDROMI^.BufStart, DataLength);
    Inc(pCDROMI^.Position, DataLength);
  end;

  Result:= DataLength;
end;
{$ENDIF}
/////////////////////

Function GetSystemCDRoms: AnsiString;
var
  Index   : longint;
  Ret     : LongInt;
  Devices : Array of string;
  sl      : TStringList;
begin
  Result:= '';
  sl:= TStringList.Create;

  SetLength(Devices, 99);
  Ret:= cdrom.GetCDRomDevices(Devices);
  If Ret > 0 Then
    For Index := 0 To Ret -1 do
      sl.Add(Devices[Index]);

  Result:= sl.Text;
  sl.Free;
end;

// ********************** Common Linux/Windows SUPPORT Functions *******************************************************
Function Frames2MSF(Frames : LongInt) : Tmsf;
var
  Temp : Integer;
begin
  Temp          := Frames div 75;
  Result.min    := Temp div 60;
  Result.sec    := Temp mod 60;
  Result.Frame  := Frames mod 75;
end;

function MSF2Frames(const msf : Tmsf) : LongInt;
begin
  Result := ((msf.min * 60) + msf.sec) * 75 + msf.Frame;
end;

Function AddressToSectors (msf : Tmsf): int64;
begin
 Result:= MSF2Frames(msf) - 150;
end;

// *********************************************************************************************************************

end.

