{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2004 by Marco van de Voort, member of the
    Free Pascal development team

    Implements C types for in header conversions

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


 **********************************************************************}

unit Delphictypes;

interface

uses System.SyncObjs;


type
{$ifndef FPC}
    qword = int64;  // Keep h2pas "uses ctypes" headers working with delphi.
{$endif}


  { the following type definitions are compiler dependant }
  { and system dependant                                  }

  cint8                  = shortint;           pcint8                 = ^cint8;
  cuint8                 = byte;               pcuint8                = ^cuint8;
  cchar                  = cint8;              pcchar                 = ^cchar;
  cschar                 = cint8;              pcschar                = ^cschar;
  cuchar                 = cuint8;             pcuchar                = ^cuchar;

  cint16                 = smallint;           pcint16                = ^cint16;
  cuint16                = word;               pcuint16               = ^cuint16;
  cshort                 = cint16;             pcshort                = ^cshort;
  csshort                = cint16;             pcsshort               = ^csshort;
  cushort                = cuint16;            pcushort               = ^cushort;

  cint32                 = longint;            pcint32                = ^cint32;
  cuint32                = longword;           pcuint32               = ^cuint32;
  cint                   = cint32;             pcint                  = ^cint;              { minimum range is : 32-bit    }
  csint                  = cint32;             pcsint                 = ^csint;             { minimum range is : 32-bit    }
  cuint                  = cuint32;            pcuint                 = ^cuint;             { minimum range is : 32-bit    }
  csigned                = cint;               pcsigned               = ^csigned;
  cunsigned              = cuint;              pcunsigned             = ^cunsigned;

  cint64                 = int64;              pcint64                = ^cint64;
  cuint64                = qword;              pcuint64               = ^cuint64;
  clonglong              = cint64;             pclonglong             = ^clonglong;
  cslonglong             = cint64;             pcslonglong            = ^cslonglong;
  culonglong             = cuint64;            pculonglong            = ^culonglong;

  cbool                  = longbool;           pcbool                 = ^cbool;

{$if defined(cpu64) and not(defined(win64) and defined(cpux86_64))}
  clong                  = int64;              pclong                 = ^clong;
  cslong                 = int64;              pcslong                = ^cslong;
  culong                 = qword;              pculong                = ^culong;
{$else}
  clong                  = longint;            pclong                 = ^clong;
  cslong                 = longint;            pcslong                = ^cslong;
  culong                 = cardinal;           pculong                = ^culong;
{$ifend}

  cfloat                 = single;             pcfloat                = ^cfloat;
  cdouble                = double;             pcdouble               = ^cdouble;
  clongdouble            = extended;           pclongdouble           = ^clongdouble;

// Kylix compat types
  u_long  = culong;
  u_short = cushort;

  coff_t = clong;

  SizeUInt = LongWord;

  TDArFloat = array of cfloat;
  TDArShort = array of cInt16;
  TDArLong = array of cint;

  TDArPARFloat = array of TDArFloat;
  TDArIARFloat = array of TDArPARFloat;

  PDArFloat = ^TDArFloat;
  PDArShort = ^TDArShort;
  PDArLong = ^TDArLong;

const

  NilHandle=0;
  DefaultStackSize = 4*1024*1024;

  function RTLEventCreate : tevent;
  procedure RTLeventSetEvent(var event : tevent) ;
  procedure RTLeventReSetEvent(var event : tevent) ;
  procedure RTLeventWaitFor(var event : tevent);
  procedure RTLeventdestroy(var event : tevent);

implementation

  function RTLEventCreate : tevent;
  Begin
    result := tevent.create;
  End;
  procedure RTLeventSetEvent(var event : tevent) ;
  begin
     event.SetEvent;
  end;

  procedure RTLeventReSetEvent(var event : tevent) ;
  Begin
     event.ResetEvent;
  End;

  procedure RTLeventWaitFor(var event : tevent) ;
  Begin
     event.waitfor;
  End;

  procedure RTLeventdestroy(var event : tevent);
  Begin
     event.Destroy;
  End;


end.

