program st2bi;

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses {$IFDEF UNIX}
  cthreads,
  cwstring, {$ENDIF}
  Classes,
  SysUtils,
  CustApp, uos,
  uos_bs2b,
  ctypes { you can add units after this };

type

  { TUOSConsole }

  TuosConsole = class(TCustomApplication)
  private
    procedure ConsolePlay;
  protected
    procedure doRun; override;
  public
    procedure Consoleclose;
    constructor Create(TheOwner: TComponent); override;
  end;


var
  res: boolean;
  ordir, opath, bsFileName: string;
  versionstr : pchar;
  num : CInt32;
  thebuffer :  array[0..1] of cfloat;
  thebuffer2 : TDArFloat;
  thesample : cfloat;
  thesample2 : cint32;
  thesample3 : cint32;

  { TuosConsole }

  procedure TuosConsole.ConsolePlay;
  begin
    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));


 {$IFDEF linux}
    {$if defined(cpu64)}
   bsFileName := ordir + 'lib/Linux/64bit/libbs2b-64.so';
       {$else}
   bsFileName := ordir + 'lib/Linux/64bit/libbs2b-32.so';
{$endif}
    
 {$ENDIF}
 
    res := bs_Load(Pchar(bsFileName)) ;
   
   if res = true then

    writeln('OK library is loaded...') else
      writeln('NO library is NOT loaded...');

    //  readln;
      
   num :=  bs2b_runtime_version_int() ;
   
    writeln('Version number ' + inttostr(num));
    
  //   readln;
     
    versionstr := bs2b_runtime_version() ;
    
     writeln('Version string ' + versionstr);
    
    // readln; 
       
     
  Abs2bd :=   bs2b_open() ;
  
// Abs2bd^.level := 123456 ;
  
 //  Abs2bd^.lfs.asis[0] := thebuffer2[0];
   
 //  Abs2bd^.lfs.asis[1] := thebuffer2[1];
  
   writeln('Level is ' + inttostr(bs2b_get_level(Abs2bd)));
   
  //  readln;
  
  bs2b_cross_feed_f(Abs2bd, thesample, 2); 
  
  thesample2 := -1234567 ;
  
   writeln('Before Cross Level ' + inttostr(thesample2));
 
 
  bs2b_cross_feed_s32(Abs2bd, thesample2, 2) ;
  
   writeln('Cross Level 2 is ' + inttostr(thesample2));
   
  // readln;
   
    thesample2 := -1234567 ;
  
   writeln('Before Cross Level ' + inttostr(thesample2));
 
 
  bs2b_cross_feed_s32(Abs2bd, thesample2, 1) ;
  
   writeln('Cross Level 1 is ' + inttostr(thesample2));
   
 //  readln;
   
    thesample2 := -1234567 ;
   
    writeln('Before Cross Level ' + inttostr(thesample2));
 
 
  bs2b_cross_feed_s32(Abs2bd, thesample2, 0) ;
  
   writeln('Cross Level 0 is ' + inttostr(thesample2));
   
   // readln;
  
      end;

  procedure TuosConsole.doRun;
  begin
    ConsolePlay;
    writeln('Press a key to exit...');
      readln;
     Terminate;
    end;

  procedure TuosConsole.ConsoleClose;
  begin
    Terminate;
  end;

  constructor TuosConsole.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

var
  Application: TUOSConsole;
begin
  Application := TUOSConsole.Create(nil);
  Application.Title := 'Binaural test';
    Application.Run;
     bs_Unload();
  Application.Free;
end.
