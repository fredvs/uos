{This unit is part of United Openlibraries of Sound (uos)}

{      This is HTTP Thread Getter
 created by Andrew Haines -> andrewd207@aol.com
       License: modified LGPL.
 Fred van Stappen / fiens@hotmail.com}

unit uos_httpgetthread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Pipes;

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
    FormatType: integer;  // 0: mp3, 1: opus, 2: aac
    ContentType: string;
    ice_audio_info: string; // channels=2;samplerate=44100;bitrate=128
    icy_description: string;
    icy_genre: string;
    icy_name: string;
    icy_url: string;
    property IcyMetaInt: int64 read FIcyMetaInt;
    property IsRunning: Boolean read FIsRunning;
    constructor Create(AWantedURL: string; AOutputStream: TOutputPipeStream);
  end;

{ Function to check URL status with detailed error codes }
function CheckURLStatus(const URL: string): Integer;
{ Returns:
  0: URL is accessible (200, 204, etc.)
  1: Invalid URL format
  2: Connection timeout
  3: DNS resolution failure
  4: Redirect loop or failure
  5: Other network error (e.g., SSL, protocol error)
  301, 302, 303, 307, 308: HTTP redirect status
  400+: HTTP server error (e.g., 404, 500, 403)
}

implementation

uses
  fphttpclient, openssl, opensslsockets;

{ Check URL status with detailed error codes }
function CheckURLStatus(const URL: string): Integer;
var
  Http: TFPHTTPClient;
begin
  // Check for invalid URL format
  if (URL = '') or (Pos('http', LowerCase(URL)) <> 1) then
    Exit(1); // Invalid URL format

  Http := TFPHTTPClient.Create(nil);
  try
    Http.AllowRedirect := True;
    Http.MaxRedirects := 5; // Prevent infinite redirect loops
    Http.IOTimeout := 5000; // 5-second timeout
    Http.ConnectTimeout := 5000;
    Http.RequestHeaders.Clear;
    try
      Http.HTTPMethod('HEAD', URL, nil, [200, 204, 301, 302, 303, 307, 308]);
      Result := Http.ResponseStatusCode; // Return exact success status (e.g., 200, 204)
      //writeln('Http.ResponseStatusCode ', result);
      case Http.ResponseStatusCode of 200, 204, 301, 302, 303, 307, 308, 400:
        result := 0;
      end;  
    except
      on E: EHTTPClient do
      begin
        //writeln('error Http.ResponseStatusCode ', result);
       
        case Http.ResponseStatusCode of 301, 302, 303, 307, 308:
        Result := Http.ResponseStatusCode;
        end;   
          
        if Http.ResponseStatusCode = 400 then
          Result := 0
        else if Http.ResponseStatusCode > 400 then
          Result := Http.ResponseStatusCode // Return server error (e.g., 404, 500)
         else if Pos('redirect', LowerCase(E.Message)) > 0 then
          Result := 4 // Redirect loop or failure
        else
          Result := 5; // Other HTTP-related error
      end;
      on E: Exception do
      begin
        if Pos('timeout', LowerCase(E.Message)) > 0 then
          Result := 2 // Connection timeout
        else if (Pos('dns', LowerCase(E.Message)) > 0) or (Pos('host', LowerCase(E.Message)) > 0) then
          Result := 3 // DNS resolution failure
        else
          Result := 5; // Other unexpected error (e.g., SSL, protocol)
      end;
    end;
  finally
    Http.Free;
  end;
end;

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
    F := Pos(Search, Lowercase(S));
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
  SL: TStringList;
  URL: string;
begin
  URL := FWantedURL;
  if (URL = '') or (Pos(' ', URL) > 0) then
  begin
    FIsRunning := False;
    Exit;
  end;

  // Initialize SSL and HTTP client
  InitSSLInterface;
  Http := TFPHTTPClient.Create(nil);
  SL := TStringList.Create;
  ContentType := '';
  ice_audio_info := '';
  icy_description := '';
  icy_genre := '';
  icy_name := '';
  icy_url := '';
  FormatType := 0;

  try
    Http.AllowRedirect := True;
    Http.IOTimeout := 5000;
    Http.ConnectTimeout := 5000;

    // HEAD request to check headers
    try
      Http.RequestHeaders.Clear;
      Http.KeepConnection := False;
      Http.HTTPMethod('HEAD', URL, nil, [200, 204, 301, 302, 303, 307, 308]);
      SL.Assign(Http.ResponseHeaders);

      if SL.Count = 0 then
      begin
        // Fallback format detection based on URL
        if Pos('mpeg', URL) > 0 then FormatType := 1 else
        if Pos('mp3', URL) > 0 then FormatType := 1 else
        if Pos('opus', URL) > 0 then FormatType := 2 else
        if Pos('ogg', URL) > 0 then FormatType := 2 else
        if Pos('aac', URL) > 0 then FormatType := 3 else
          FormatType := 2;
      end
      else
      begin
        ContentType := LowerCase(SL.Values['Content-Type']);
        ice_audio_info := LowerCase(SL.Values['ice-audio-info']);
        icy_description := LowerCase(SL.Values['icy-description']);
        icy_genre := LowerCase(SL.Values['icy-genre']);
        icy_name := LowerCase(SL.Values['icy-name']);
        icy_url := LowerCase(SL.Values['icy-url']);
      end;
    except
      on E: Exception do
      begin
        // Fallback format detection
        if Pos('mpeg', URL) > 0 then FormatType := 1 else
        if Pos('mp3', URL) > 0 then FormatType := 1 else
        if Pos('opus', URL) > 0 then FormatType := 2 else
        if Pos('ogg', URL) > 0 then FormatType := 2 else
        if Pos('aac', URL) > 0 then FormatType := 3 else
          FormatType := 2;
      end;
    end;

    // Determine FormatType based on ContentType or fallback
    if Length(ContentType) > 0 then
    begin
      if Pos('mpeg', ContentType) > 0 then FormatType := 1
      else if Pos('aac', ContentType) > 0 then FormatType := 3
      else if Pos('ogg', ContentType) > 0 then FormatType := 2
      else if Pos('opus', ContentType) > 0 then FormatType := 2
      else if Pos('opus', icy_name) > 0 then FormatType := 2
      else if Pos('aac', icy_name) > 0 then FormatType := 3
      else if Pos('mp3', icy_name) > 0 then FormatType := 1
      else if Pos('mpeg', URL) > 0 then FormatType := 1
      else if Pos('mp3', URL) > 0 then FormatType := 1
      else if Pos('opus', URL) > 0 then FormatType := 2
      else if Pos('ogg', URL) > 0 then FormatType := 2
      else if Pos('aac', URL) > 0 then FormatType := 3
      else FormatType := 2;
    end;

    if FormatType = 0 then
    begin
      FIsRunning := False;
      Exit;
    end;

    // GET request to stream data
    try
      Http.RequestHeaders.Clear;

      if (ICYenabled = True) and (FormatType <> 3) then
      begin
        Http.AddHeader('icy-metadata', '1');
        Http.OnHeaders := @Headers;
      end;

      // Ensure FOutStream is valid
      if not Assigned(FOutStream) then
      begin
        FIsRunning := False;
        Exit;
      end;

      Http.Get(URL, FOutStream);
    except
      on E: EHTTPClient do
      begin
        if (Http.ResponseStatusCode > 399) or (Http.ResponseStatusCode < 1) then
          FIsRunning := False
        else if Http.ResponseStatusCode = 302 then
        begin
          URL := GetRedirectURL(Http.ResponseHeaders);
          if URL <> '' then
          begin
            Http.RequestHeaders.Clear;
            if (ICYenabled = True) and (FormatType = 1) then
            begin
              Http.AddHeader('icy-metadata', '1');
              Http.OnHeaders := @Headers;
            end;
            try
              Http.Get(URL, FOutStream);
            except
              on E: Exception do
              begin
                FIsRunning := False;
              end;
            end;
          end
          else
            FIsRunning := False;
        end
        else
          FIsRunning := False;
      end;
      on E: Exception do
      begin
        FIsRunning := False;
      end;
    end;
  finally
    SL.Free;
    Http.Free;
    FIsRunning := False;
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