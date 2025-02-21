{This unit is part of United Openlibraries of Sound (uos)}

{      This is HTTP Thread Getter
 created by Andrew Haines -> andrewd207@aol.com
       License : modified LGPL.
 Fred van Stappen / fiens@hotmail.com}

unit uos_httpgetthread;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Pipes;

type

  { TThreadHttpGetter }

  TThreadHttpGetter = class(TThread)
  private
    FOutStream: TOutputPipeStream;
    FWantedURL: string;
    FIcyMetaInt: int64;      // ICY metadata interval (bytes)
    FOnIcyMetaInt: TNotifyEvent;
    MetaBuffer: TStringStream; // Buffer to hold metadata
    property OnIcyMetaInt: TNotifyEvent read FOnIcyMetaInt write FOnIcyMetaInt;
    procedure DoIcyMetaInt;
    function GetRedirectURL(AResponseStrings: TStrings): string;
    procedure Headers(Sender: TObject);
  protected
    procedure Execute; override;
  public
    FIsRunning: Boolean;
    ICYenabled: Boolean;
    property IcyMetaInt: int64 read FIcyMetaInt;
    property IsRunning: Boolean read FIsRunning;
    constructor Create(AWantedURL: string; AOutputStream: TOutputPipeStream);
  end;

implementation

uses
  fphttpclient,
  openssl, { This implements the procedure InitSSLInterface }
  opensslsockets;

{ TThreadHttpGetter }
function TThreadHttpGetter.GetRedirectURL(AResponseStrings: TStrings): string;
var
  S: string;
  F: integer;
  Search: string = 'location:';
begin
  Result := '';
  for S in AResponseStrings do
  begin
    // WriteLn(S);
    F := Pos(Search, Lowercase(s));

    if F > 0 then
    begin
      Inc(F, Length(Search));
      Exit(Trim(Copy(S, F, Length(S) - F + 1)));
    end;
  end;
end;

procedure TThreadHttpGetter.DoIcyMetaInt;
begin
  if Assigned(FOnIcyMetaInt) then
    FOnIcyMetaInt(Self);
end;

procedure TThreadHttpGetter.Headers(Sender: TObject);
begin
  FIcyMetaInt := StrToInt64Def(TFPHTTPClient(Sender).GetHeader(TFPHTTPClient(Sender).ResponseHeaders, 'icy-metaint'), 0);
  if (FIcyMetaInt > 0) and (FOnIcyMetaInt <> nil) then
    Synchronize(@DoIcyMetaInt);
end;

procedure TThreadHttpGetter.Execute;
var
  Http: TFPHTTPClient;
  URL: string;
  err: shortint = 0;
begin
  URL          := FWantedURL;
  if pos(' ', URL) > 0 then
    FIsRunning := False
  else
  begin
    InitSSLInterface;
    Http       := TFPHTTPClient.Create(nil);
    http.AllowRedirect := True;
    http.IOTimeout := 2000;
    repeat
      try
        Http.RequestHeaders.Clear;
        
        if ICYenabled = True then
        begin
        Http.AddHeader('icy-metadata', '1');  // Enable ICY metadata
        Http.OnHeaders := @Headers;
        end;
         
        // writeln(' avant http.get');
        Http.Get(URL, FOutStream);
        // writeln(' apres http.get');
        sleep(500);
      except
        on e: EHTTPClient do
        begin
          //  writeln(' Http.ResponseStatusCode ' +inttostr(Http.ResponseStatusCode));
          if (Http.ResponseStatusCode > 399) or (Http.ResponseStatusCode < 1) then // not accessible
          begin
            FIsRunning := False;
            break;
          end;
          if Http.ResponseStatusCode = 302 then
          begin
            URL := GetRedirectURL(Http.ResponseHeaders);
            if URL <> '' then
              Continue;
          end
          else
            Break;
          // raise E;
        end;
        on e: Exception do
        begin
          Break;
          //  WriteLn(e.Message);
        end
        else
          // Raise;
          Break;
      end;
      Break;
    until (False);
    try
      Http.Free;
    finally
      // make sure this is set to false when done
      FIsRunning := False;
    end;
  end;
end;

constructor TThreadHttpGetter.Create(AWantedURL: string; AOutputStream: TOutputPipeStream);
begin
  inherited Create(True);
  ICYenabled := False;
  FIsRunning := True;
  FWantedURL := AWantedURL;
  FOutStream := AOutputStream;
end;

end.

