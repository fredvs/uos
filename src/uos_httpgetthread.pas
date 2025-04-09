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
    procedure DoIcyMetaInt;
    function GetRedirectURL(AResponseStrings: TStrings): string;
    procedure Headers(Sender: TObject);
  protected
    procedure Execute; override;
  public
    FIsRunning: Boolean;
    ICYenabled: Boolean;
    FormatType: integer;  // 0: mp3, 1:opus, 2:acc
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
  SL: TStringList;
  s : string;
begin
  URL          := FWantedURL;
  if pos(' ', URL) > 0 then
    FIsRunning := False
  else
  begin
    InitSSLInterface;
    Http       := TFPHTTPClient.Create(nil);
    SL:= TStringList.Create;
    http.AllowRedirect := True;
    http.IOTimeout := 2000;
    repeat
      try
        Http.RequestHeaders.Clear;
        HTTP.Head(URL, SL); // to define format type
        
        s := SL.Values['Content-Type'];
        SL.free;
        if system.pos('mpeg',s) > 0 then
        FormatType := 1 else
        if system.pos('aac',s) > 0 then
        FormatType := 3 else
        if system.pos('ogg',s) > 0 then
        FormatType := 2 else
        if system.pos('opus',s) > 0 then
        FormatType := 2 else
         FormatType := 0;
        if FormatType = 0 then Break; 
        
        //writeln(s + ' ' + inttostr(FormatType));
           
        if (ICYenabled = True) and (FormatType = 1)  then
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

