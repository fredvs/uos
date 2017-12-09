{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt

    Implementation of pipe stream.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{ $mode objfpc}

Unit PipesDelphi;

Interface

Uses sysutils,Classes;

Type
  EPipeError = Class(EStreamError);
  ENoReadPipe = Class(EPipeError);
  ENoWritePipe = Class (EPipeError);
  EPipeSeek = Class (EPipeError);
  EPipeCreation = Class (EPipeError);
  DWord = cardinal;

  { TInputPipeStream }

  TInputPipeStream = Class(THandleStream)
    Private
      FPos : Int64;
      function GetNumBytesAvailable: DWord;
    public
      Function Write (Const Buffer; Count : Longint) :Longint; Override;
      Function Seek (Offset : Longint;Origin : Word) : longint;override;
      Function Read (Var Buffer; Count : Longint) : longint; Override;
      property NumBytesAvailable: DWord read GetNumBytesAvailable;
    end;

  TOutputPipeStream = Class(THandleStream)
    Public
      Function Seek (Offset : Longint;Origin : Word) : longint;override;
      Function Read (Var Buffer; Count : Longint) : longint; Override;
    end;

Function CreatePipeHandles (Var Inhandle,OutHandle : THandle; PipeBufSize : integer = 1024) : Boolean;
Procedure CreatePipeStreams (Var InPipe : TInputPipeStream;
                             Var OutPipe : TOutputPipeStream);

Const EPipeMsg = 'Failed to create pipe.';
      ENoReadMSg = 'Cannot read from OuputPipeStream.';
      ENoWriteMsg = 'Cannot write to InputPipeStream.';
      ENoSeekMsg = 'Cannot seek on pipes';


Implementation

{$i PipesDelphi.inc}

Procedure CreatePipeStreams (Var InPipe : TInputPipeStream;
                             Var OutPipe : TOutputPipeStream);

Var InHandle,OutHandle : THandle;

begin
  if CreatePipeHandles (InHandle, OutHandle) then
    begin
    InPipe:=TInputPipeStream.Create (InHandle);
    OutPipe:=TOutputPipeStream.Create (OutHandle);
    end
  Else
    Raise EPipeCreation.Create (EPipeMsg)
end;

Function TInputPipeStream.Write (Const Buffer; Count : Longint) : longint;

begin
  Raise ENoWritePipe.Create (ENoWriteMsg);
end;

Function TInputPipeStream.Read (Var Buffer; Count : Longint) : longint;

begin
  Result:=Inherited Read(Buffer,Count);
  Inc(FPos,Result);
end;

Function TInputPipeStream.Seek (Offset : Longint;Origin : Word) : longint;

Const BufSize = 100;

Var Buf : array[1..BufSize] of Byte;

begin
  { Try to fake seek by reading and discarding }
  if Not((Origin=soFromCurrent) and (Offset>=0) or
         ((Origin=soFrombeginning) and (OffSet>=FPos))) then
     Raise EPipeSeek.Create(ENoSeekMSg);
  if Origin=soFromBeginning then
    Dec(Offset,FPos);
  While ((Offset Div BufSize)>0)
        and (Read(Buf,SizeOf(Buf))=BufSize) do
     Dec(Offset,BufSize);
  If (Offset>0) then
    Read(Buf,BufSize);
  Result:=FPos;
end;

Function TOutputPipeStream.Read(Var Buffer; Count : Longint) : longint;

begin
  Raise ENoReadPipe.Create (ENoReadMsg);
end;

Function TOutputPipeStream.Seek (Offset : Longint;Origin : Word) : longint;

begin
  Raise EPipeSeek.Create (ENoSeekMsg);
end;

end.
