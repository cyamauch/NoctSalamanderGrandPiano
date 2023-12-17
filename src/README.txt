Noct-Salamander Grand Piano
Refined Salamander Grand for Nocturne
-- A free SFZ piano emulating a concert grand through digital processing.


Technical info

This sound bank was created based on the Salamander Grand,

  "Salamander Grand Piano" Web site
  https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html

and tone quality of all basic WAV files listed in SFZ is improved to play 
nocturnes and other relaxation music.  Released SFZ files have 16 velocity 
layers with 48kHz24bit.

Naturally, we referenced the tones of several concert grand pianos.  The reason
why large grand pianos have beautiful tones is because they have fewer high-
frequency overtones.  This is a natural result of physics, and the digital 
processing was based on applying LPF to each of the notes as follows:

- Applied LPF for keys having 440Hz and higher frequency.
- Applied different LPFs in the two frequency bands.
  (Attenuates at f*13 for f < 1000Hz and at f*2 for f => 1000Hz)
- Changed the envelopes of all keys so that the string decay is more gradual.

In order to pursue natural sound quality, the levels of LPF and envelope 
modification were varied gradually according to the scale.

The original sound source is a sampling of the YAMAHA C5, but these processes 
make it possible to reproduce the tone of a larger grand piano.

FFmpeg was used for all processings.  See src/do_eql+env_all.sh for details. 
You can change the parameters in the script and *_factor.txt files, and run 
"make" to generate your own piano sound (you need to get the original version 
of Salamander Grand).  This allows for a level of complexity and fine-tuning 
of sound quality that is not possible through the GUI of VST plug-ins or 
filter settings within SFZ files. 


Changelog:

V3.0 (Nov.24,2023)
* First release based on Salamander Grand Piano V3+20161209.
V3.1 (Dec.??,2023)
* Configuration files (*_factor.txt) allow detailed LPF and volume settings.


Licence: 

CC-by (same licence as the original version)
http://creativecommons.org/licenses/by/3.0/


Acknowledgments:

We are very grateful to Alexander Holm for the original sound bank.
We searched numerous free sound banks, but only Salamander Grand Piano had 
sufficient quality and freedom of development. 


Author:

Chisato Yamauchi
cyamauch (at) ir.isas.jaxa.jp


