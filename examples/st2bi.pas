program st2bi;

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses {$IFDEF UNIX}
  cthreads,
  cwstring, {$ENDIF}
  Classes,
   dynlibs,
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
   bsFileName := ordir + 'lib/Linux/64bit/plugin/libbs2b-64.so';
       {$else}
   bsFileName := ordir + 'lib/Linux/64bit/plugin/libbs2b-32.so';
{$endif}
    
 {$ENDIF}
 
 {$IFDEF windows}
    {$if defined(cpu64)}
   bsFileName := ordir + 'lib\Windows\64bit\plugin\bs2b.dll';
       {$else}
   bsFileName := ordir + 'lib\Windows\32bit\plugin\LibBs2b-32.dll';
   {$endif}
    
 {$ENDIF}
 
  res := bs_Load(Pchar(bsFileName)) ;
   
   if res = true then

    writeln('OK library is loaded...') else
      writeln('NO library is NOT loaded...');

    //  readln;
      writeln(); 
    writeln('Try get Version number');   
     writeln(); 
   num :=  bs2b_runtime_version_int() ;
    writeln(); 
   
    writeln('Version number ' + inttostr(num));
    
  //   readln;
   
      writeln(); 
    writeln('Try get Version string'); 
     writeln();    
    versionstr := bs2b_runtime_version() ;
     writeln(); 
    
     writeln('Version string ' + versionstr);
    
    // readln; 
       
     writeln(); 
    writeln('Try to create a bs2b class'); 
     writeln();    
  Abs2bd :=   bs2b_open() ;
  
   writeln(); 
    writeln('Try to get level'); 
     writeln();
   writeln('Level is ' + inttostr(bs2b_get_level(Abs2bd)));
   
  //  readln;
  
   writeln(); 
    writeln('Try to cross feed'); 
     writeln();
  bs2b_cross_feed_f(Abs2bd, thesample, 2); 
  
  thesample2 := -1234567 ;
  
   writeln('Before Cross Level ' + inttostr(thesample2));
 
 
 writeln(); 
    writeln('Try to cross feed chanel 2'); 
     writeln();
  bs2b_cross_feed_s32(Abs2bd, thesample2, 2) ;
  
   writeln('Cross Level 2 is ' + inttostr(thesample2));
   
  // readln;
   
    thesample2 := -1234567 ;
  
   writeln('Before Cross Level ' + inttostr(thesample2));
 
 
 writeln(); 
    writeln('Try to cross feed chanel 1'); 
     writeln();
  bs2b_cross_feed_s32(Abs2bd, thesample2, 1) ;
  
   writeln('Cross Level 1 is ' + inttostr(thesample2));
   
 //  readln;
   
    thesample2 := -1234567 ;
   
    writeln('Before Cross Level ' + inttostr(thesample2));
 
 writeln(); 
    writeln('Try to cross feed chanel 0'); 
     writeln();
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
