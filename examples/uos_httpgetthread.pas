{This unit is part of United Openlibraries of Sound (uos)}

{      This is HTTP Thread Getter
 created by Andrew Haines -> andrewd207@aol.com
       License : modified LGPL.
 Fred van Stappen / fiens@hotmail.com}

unit uos_httpgetthread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,  Pipes;

type
  
 { TThreadHttpGetter }

  TThreadHttpGetter = class(TThread)
  private
    FOutStream: TOutputPipeStream;
    FWantedURL: String;
    FIcyMetaInt: Int64;
    FOnIcyMetaInt: TNotifyEvent;
    property OnIcyMetaInt: TNotifyEvent read FOnIcyMetaInt write FOnIcyMetaInt; 
    procedure DoIcyMetaInt;
    function GetRedirectURL(AResponseStrings: TStrings): String;
    procedure Headers(Sender: TObject);
  protected
    procedure Execute; override;
  public
    FIsRunning: Boolean;
    ICYenabled: Boolean;
    property IcyMetaInt: Int64 read FIcyMetaInt;
    property IsRunning: Boolean read FIsRunning;
    constructor Create(AWantedURL: String; AOutputStream: TOutputPipeStream);
   end;

implementation
uses
  fphttpclient;

{ TThreadHttpGetter }

function TThreadHttpGetter.GetRedirectURL(AResponseStrings: TStrings): String;
var
  S: String;
  F: Integer;
  Search: String = 'location:';
begin
  Result := '';
  for S In AResponseStrings do
  begin
   // WriteLn(S);
    F := Pos(Search, Lowercase(s));

    if F > 0 then
    begin
      Inc(F, Length(Search));
      Exit(Trim(Copy(S, F, Length(S)-F+1)));
    end;
  end;
end;

procedure TThreadHttpGetter.DoIcyMetaInt; 
begin 
  if Assigned(FOnIcyMetaInt) then 
    FOnIcyMetaInt(Self); 
end; 

procedure TThreadHttpGetter.Headers(Sender: TObject ); 
begin 
  FIcyMetaInt := StrToInt64Def(TFPHTTPClient(Sender).GetHeader(TFPHTTPClient(Sender).ResponseHeaders, 'icy-metaint'),0); 
  if (FIcyMetaInt>0) and (FOnIcyMetaInt<>nil) then 
       Synchronize(@DoIcyMetaInt); 
end;

procedure TThreadHttpGetter.Execute;
var
  Http: TFPHTTPClient;
  URL: String;
begin
  Http := TFPHTTPClient.Create(nil);
  URL := FWantedURL;
  repeat
  try
    Http.RequestHeaders.Clear;
    if ICYenabled = true then
    Http.OnHeaders := @Headers; 
    Http.Get(URL, FOutStream);
  except
    on e: EHTTPClient do
    begin
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
    //  WriteLn(e.Message);
    end
    else
     // Raise;
      Break;
  end;
  Break;
  until False;

  try
    FOutStream.Free;
    Http.Free;
  finally
   // make sure this is set to false when done
    FIsRunning:=False;
  end;
end;
 
constructor TThreadHttpGetter.Create(AWantedURL: String; AOutputStream: TOutputPipeStream);
begin
  inherited Create(True);
  ICYenabled:=false;
  // FIsRunning:=True;
  FWantedURL:=AWantedURL;
  FOutStream:=AOutputStream;
  // Start;
end;

end.

