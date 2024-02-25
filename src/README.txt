Noct-Salamander Grand Piano
Refined Salamander Grand for Nocturne
-- A free SFZ piano emulating a concert grand through digital processing.


Technical info

This sound bank was created based on the Salamander Grand,

  "Salamander Grand Piano" Web site
  https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html

and tone quality is improved to play nocturnes and other relaxation music.
Instead of modifying the SFZ file, carefully selected and configured filters
were applied to the WAV files.  This allows easy conversion to any soundbank
format and incorporation into software such as plug-ins.

Naturally, we referenced the tones of several concert grand pianos.  The reason
why large grand pianos have beautiful tones is because they have fewer high-
frequency overtones.  This is a natural result of physics, and the digital 
processing was based on applying LPF to each of the notes as follows:

- Applied 4 filtering:
  frequency*0.5, frequency*4, frequency*12 and frequency*26.
  (See gain0_factor.txt, gain1_factor.txt, gain2_factor.txt, gain3_factor.txt)

- The effective rate of filter processing is changed for each velocity layer.

- Changed the envelopes of all keys so that the string decay is more gradual.

In order to pursue natural sound quality, the levels of filtering and envelope 
modification were varied gradually according to the scale.

The original sound source is a sampling of the YAMAHA C5, but these processes 
make it possible to reproduce the tone of a larger grand piano.

In Version 4, the continuity of sound quality and volume in the scale was 
carefully adjusted:

- Reassigned WAV files to improve continuity of scale at each velocity layer.
  (See assign.txt)

- All volume of WAV files were carefully adjusted for each velocity layer.
  (See vol_factor_base.txt, vol_factor.src.txt)

- Erased strange noises during recording.
  (See filter_direct.txt)

The C5 grand piano used for sampling was tuned fairly accurately, but slight
errors in very low and very high notes such as A0, C1, D#1, F#7, and C8 were
corrected to standard pitch according to tuned.txt.  For pitch adjustment, 
the built-in sound bank of the YAMAHA EA1 was referenced.

FFmpeg was used for all processings.  See src/do_eql+env_all.sh for details.
You can change the parameters of the *.txt files, and run "make noct48" to 
generate your own piano sound (you need to get the original version of 
Salamander Grand).  This allows for a level of complexity and fine-tuning of
sound quality that is not possible through the GUI of VST plug-ins or filter
settings within SFZ files. 


Changelog:

V3.0 (Nov.24,2023)
* First release based on Salamander Grand Piano V3+20161209.
V4.0 (Feb.??,2024)
* Applied 4 filtering, reassigned WAV, adjusted all volume of WAV, 
  erased noises.


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


