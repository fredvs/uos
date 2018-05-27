program formspectrum_mse;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
uses
 {$ifdef FPC}{$ifdef unix} cthreads,{$endif}{$endif} 
 msegui,main_spectrum_mse;
begin
 application.createform(tmainfo,mainfo);
 application.run;
end.
