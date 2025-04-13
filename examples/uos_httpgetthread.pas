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
    ContentType: string;
    ice_audio_info: string; //channels=2;samplerate=44100;bitrate=128
    icy_description: string;
    icy_genre: string;
    icy_name: string;
    icy_url: string;
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
  SL: TStringList;
  URL: string;
  //TempStream: TMemoryStream;
begin
  URL := FWantedURL;
  if Pos(' ', URL) > 0 then
  begin
    FIsRunning := False;
    Exit;
  end;

  // Writeln('Starting thread for URL: ', URL);
  InitSSLInterface;
  Http := TFPHTTPClient.Create(nil);
  SL   := TStringList.Create;
  try
    Http.AllowRedirect := True;
    Http.IOTimeout := 5000;
    try
      //Writeln('Sending HEAD request...');
      Http.RequestHeaders.Clear;
      Http.KeepConnection := False;
      Http.HTTPMethod('HEAD', URL, Nil, [200, 204, 301, 302, 303, 307, 308, 400]);
      SL.Assign(http.ResponseHeaders);
 
    //  Http.Head(URL, SL);
      // if assigned(SL) then Writeln('SL assigned') else Writeln('SL NOT assigned');
      // writeln('SL.values ' + inttostr(SL.count));
      if SL.Count = 0 then
         begin
          //writeln('SL.Count = 0');
          if Pos('mpeg', URL) > 0 then FormatType := 1 else
          if Pos('mp3', URL) > 0 then FormatType := 1 else
          if Pos('opus', URL) > 0 then FormatType := 2 else
          if Pos('ogg', URL) > 0 then FormatType := 2 else
          if Pos('aac', URL) > 0 then FormatType := 3 else
          FormatType := 2;
         end 
      else
        begin
        ContentType       := LowerCase(SL.Values['Content-Type']);
        //writeln('ContentType ' + ContentType);
        ice_audio_info:= LowerCase(SL.Values['ice-audio-info']); //channels=2;samplerate=44100;bitrate=128
        //writeln('ice_audio_info ' + ice_audio_info);
        icy_description:= LowerCase(SL.Values['icy-description']);
        //writeln('icy_description ' + icy_description);
        icy_genre := LowerCase(SL.Values['icy-genre']);
        //writeln('icy_genre ' + icy_genre);
        icy_name := LowerCase(SL.Values['icy-name']);
        //writeln('icy_name ' + icy_name);
        icy_url := LowerCase(SL.Values['icy-url']);
        //writeln('icy_url ' + icy_url);
        end;
      SL.Free;
    except
      on E: Exception do
      begin
          // Writeln('HEAD failed: ' + E.Message + '. Falling back to limited GET.');
          if Pos('mpeg', URL) > 0 then FormatType := 1 else
          if Pos('mp3', URL) > 0 then FormatType := 1 else
          if Pos('opus', URL) > 0 then FormatType := 2 else
          if Pos('ogg', URL) > 0 then FormatType := 2 else
          if Pos('aac', URL) > 0 then FormatType := 3 else
          FormatType := 2;
      end;
    end;
    
      if length(ContentType) > 0 then
      begin
      if Pos('mpeg', ContentType) > 0 then
        FormatType := 1
      else if Pos('aac', ContentType) > 0 then
        FormatType := 3
      else if Pos('ogg', ContentType) > 0 then
        FormatType := 2
      else if Pos('opus', ContentType) > 0 then
        FormatType := 2
      else if Pos('opus', icy_name) > 0 then
        FormatType := 2
      else if Pos('aac', icy_name) > 0 then
        FormatType := 3
      else if Pos('mp3', icy_name) > 0 then
        FormatType := 1  
      else if Pos('mpeg', URL) > 0 then
        FormatType := 1
       else if Pos('mp3', URL) > 0 then 
        FormatType := 1
       else if Pos('opus', URL) > 0 then
        FormatType := 2 
       else if Pos('ogg', URL) > 0 then
        FormatType := 2 
       else if Pos('aac', URL) > 0 then
        FormatType := 3 else
        FormatType := 2;
       end;
       
     // Writeln('FormatType: ' + inttostr(FormatType));
    
    if FormatType = 0 then
    begin
      // Writeln('Unknown format, exiting.');
      FIsRunning := False;
      Exit;
    end;

    try
      // Writeln('Sending GET request...');
      Http.RequestHeaders.Clear;

      if (ICYenabled = True) and (FormatType = 1) then
      begin
        // Writeln('Enabling ICY metadata...');
        Http.RequestHeaders.Clear;
        Http.AddHeader('icy-metadata', '1');
        Http.OnHeaders := @Headers;
      end;

      // Writeln(URL);
      Http.Get(URL, FOutStream);
    except
      on E: EHTTPClient do
      begin
        // writeln('Http.ResponseHeaders.Text ' + Http.ResponseHeaders.Text);
        // Writeln('HTTP error: ' + IntToStr(Http.ResponseStatusCode));
        if (Http.ResponseStatusCode > 399) or (Http.ResponseStatusCode < 1) then
          FIsRunning := False
        else if Http.ResponseStatusCode = 302 then
        begin
          URL := GetRedirectURL(Http.ResponseHeaders);
          // Writeln('Redirecting to: ', URL);
          if URL <> '' then
          begin
            Http.RequestHeaders.Clear;
            if (ICYenabled = True) and (FormatType = 1) then
            begin
              Http.AddHeader('icy-metadata', '1');
              Http.OnHeaders := @Headers;
            end;
            Http.Get(URL, FOutStream);
            // Writeln('Redirected GET completed.');
          end
          else
            FIsRunning := False;
        end
        else
          FIsRunning   := False;
      end;
      on E: Exception do
      begin
        // Writeln('GET failed: ' + E.Message);
        FIsRunning := False;
      end;
    end;
  finally
    Http.Free;
    FIsRunning := False;
    // Writeln('Thread finished.');
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