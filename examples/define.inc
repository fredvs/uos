{ United Openlibraries of Sound (uos)
  License : modified LGPL.
  Fred van Stappen fiens@hotmail.com }

// Compiler definition

{.$DEFINE ConsoleApp} // if FPC version < 2.7.1 uncomment for console application
{.$DEFINE library}   // uncomment for building uos library (native and java)
{.$DEFINE java}   // uncomment for building uos java library
{.$DEFINE fpgui}   // uncomment if FPC version < 2.7.1 and using fpGUI widget

{$DEFINE portaudio} // uncomment to enable portaudio In/Out sound port
{$DEFINE sndfile} // uncomment to enable sndfile (wav, ogg, flac audio file)
{$DEFINE mpg123} // uncomment to enable mpg123 (mp3 audio file)
{$DEFINE neaac} // uncomment to enable neaac (m4a audio file)

{$DEFINE soundtouch} // uncomment to enable soundtouch tempo plugin
{$DEFINE bs2b} // uncomment to enable bs2b binaural to stereo plugin

{$DEFINE webstream} // uncomment to enable Internet Audio Stream
{$DEFINE noiseremoval} // uncomment to enable noiseremoval DSP

{$DEFINE synthesizer} // uncomment to enable Synthesizer

{.$DEFINE cdrom} // uncomment to enable cdrom audio decoder

