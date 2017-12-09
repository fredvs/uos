{ United Openlibraries of Sound (uos)
  License : modified LGPL.
  Fred van Stappen fiens@hotmail.com }

{$IF (FPC_FULLVERSION < 20701) and DEFINED(fpgui)}
   {$DEFINE fpcGUI}
{$endif}

{$IF (FPC_FULLVERSION < 20701)}
   {$DEFINE FPCPRE20701}
{$endif}
