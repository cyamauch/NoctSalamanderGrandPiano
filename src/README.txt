
-------------------------------------------------------------------------------

  Noct-Salamander Grand Piano

   A Free SFZ/WAV semi-concert grand piano
   --- remastering the Salamander Grand using a physics-based approach

-------------------------------------------------------------------------------


Technical info

Our project does not involve new recordings, but rather the development of a 
new piano sound source by digitally processing the Salamander Grand, which has
a high recording quality. 

  "Salamander Grand Piano" Web site
  https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html

In order to ensure a high level of homogeneity/continuity of each sound 
source, all of Salamander Grand's basic WAV sound sources were remastered. 
Instead of modifying the SFZ file, we applied a carefully configured filter per
note to each of the 480 WAV files. 

Naturally, we referenced the tones of several concert grand pianos.  The 
beautiful tone of a large grand piano is due to the steep decrease in 
overtones from the bass to the treble. Since this is a natural consequence 
of physics, if we have good sampling data from a non-large grand piano, we can
obtain a sound very close to that of a large grand piano by adjusting its 
frequency components. In this project, digital processing was used to adjust 
the amount of overtones by pitch and velocity as follows:

- Applied 4 filtering from the bass to the treble:
  frequency*0.5, frequency*4, frequency*12 and frequency*26.
  (See gain0_factor.txt, gain1_factor.txt, gain2_factor.txt, gain3_factor.txt)

- The effective rate of filter processing is changed for each velocity layer.

- Changed the envelopes of all keys so that the string decay is more gradual.

In order to pursue natural sound quality, the levels of filtering and envelope 
modification were varied gradually according to the scale.

The original sound source is a sampling of the YAMAHA C5, but these processes 
make it possible to reproduce the tone of a larger grand piano.

In Version 4, the homogeneity/continuity of sound quality and volume in the 
scale was carefully adjusted:

- Reassigned WAV files to improve homogeneity/continuity of scale at each 
  velocity layer.
  (See assign.txt)

- All volume of WAV files were carefully adjusted for each velocity layer.
  (See vol_factor.src.txt and vol_factor_base.txt)

- Erased strange noises during recording using both afade and equalizer.
  (See mk_special.txt)

- Individually adjust for excessive amounts of overtone that may be caused by
  recordings (mainly Layer 1).
  (See filter_direct.txt)

- Adjustment of individual and layer-by-layer overtone amounts and abnormal 
  envelope shapes (F#2, A2, C3, D#3) that may have been caused by hammer 
  conditions.
  (See mk_special.sh)

The Salamander Grand had a major problem with a lack of overtone around C3, 
which caused a break in the continuity of sound quality, but the restoration 
process described in the fifth item above enabled us to obtain the sound that
we originally wanted, and the sound source as a whole became more complete.

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

Although waveforms and spectra are also used extensively in the tuning process,
the final evaluation is based on aural perception of each individual sound and 
homogeneity/continuity. A USB audio interface Roland Rubix22 and studio monitor
headphones SONY MDR-CD900ST are used for final adjustment and confirmation. 


Changelog:

V3.0 (Nov.24,2023)
* First release based on Salamander Grand Piano V3+20161209.
V4.0RC1 (Mar.3,2024), V4.0RC4 (Mar.24,2024)
* Applied 4 filtering with effective rate, reassigned WAV, adjusted all 
  volume of WAV, erased noises and restoration of overtone/envelope near C3.


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


