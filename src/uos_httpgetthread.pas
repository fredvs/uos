{This is HTTP Thread Getter
 created by Andrew Haines => andrewd207@aol.com
 License : modified LGPL.
 Fred van Stappen / fiens@hotmail.com}

unit uos_httpgetthread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strutils, Pipes;

type

  { TThreadHttpGetter }

  TThreadHttpGetter = class(TThread)
  private
    FOutStream: TOutputPipeStream;
    FWantedURL: String;
    FIsRunning: Boolean;
    function GetRedirectURL(AResponseStrings: TStrings): String;
  protected
    procedure Execute; override;
  public
    constructor Create(AWantedURL: String; AOutputStream: TOutputPipeStream);
    property IsRunning: Boolean read FIsRunning;
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
  FIsRunning:=True;
  FWantedURL:=AWantedURL;
  FOutStream:=AOutputStream;
  Start;
end;

end.

