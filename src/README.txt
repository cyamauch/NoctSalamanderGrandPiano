
-------------------------------------------------------------------------------

  Noct-Salamander Grand Piano

   A Free SFZ semi-concert grand piano
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
  (See overtone_config.txt, gain0_factor.txt and gain3_factor.txt)

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

- The amount of delay was equalized for each note.
  (See pcm_seek_pos.txt and mk_special.txt)

- Erased strange noises during recording using both fade and equalizer.
  (See mk_special.txt)

- Individually adjust for excessive amounts of overtone that may be caused by
  recordings (mainly Layer 1).
  (See filter_direct.txt)

- Adjustment of insufficient fundamental tone amount, insufficient overtone 
  amount, and abnormal envelope shape, which may be caused by the hammer 
  condition, using filters or individual processing.
  (See filter_direct.txt...D#7,F#7,C8, mk_special.sh...F#1,F#2,A2,C3,D#3) 

The Salamander Grand had a major problem in "F#1" and "C3", which caused a 
break in the continuity of sound quality.  The restoration process described 
in the fifth item above enabled us to obtain the sound that we originally 
wanted, and the sound source as a whole became more complete.

The restoration process for "C3" and "F#1" was extremely difficult. "C3" had 
a number of problems, such as strange noises when the strings were struck, 
insufficient overtone amount, and abnormal overtone amount transitions, so 
three types of processing were combined: fade, equalizer, and mix.  That was 
manageable because, in the case of "C3", the frequency components necessary 
for restoration were still present.  However, this was not the case with 
"F#1".  We repeated trial and error, but could not obtain a decent sound. 
We thought that the cause was either the wrong position of the hammers or an 
abnormality in the strings on the piano used for recording, but we realized 
that "F#1" did not contain the frequency components that were originally 
necessary.  Since it is impossible to recover the original sound alone, we 
ended up generating it from "A1".  We have made it to a level where you would
not notice it unless we are told, but we want to record this note only.

The C5 grand piano used for sampling was tuned fairly accurately, but slight
errors in very low and very high notes such as A0, C1, D#1, F#7, and C8 were
corrected to standard pitch according to tuned.txt.  For pitch adjustment, 
the built-in sound bank of the YAMAHA EA1 was referenced.

Although waveforms and spectra are also used extensively in the tuning process,
the final evaluation is based on aural perception of each individual sound and 
homogeneity/continuity.  For adjustment and confirmation, we mainly use a USB 
audio interface Roland Rubix22 and studio monitor headphones SONY MDR-CD900ST. 
In addition to that, BOSE 101IT speakers are also used for final confirmation.

The license terms of the original sound source require that the modifications 
be clearly stated.  This project adopted a policy of clarifying not only that, 
but also the content of the modification process.  Therefore, all processing 
was done by script, and FFmpeg (an open source product) was used for WAV data 
processings.  All codes are available at GitHub repository.  See src/build.sh 
for details.  You can change the parameters of overtone_config.txt, and run 
"make noct48" to generate your own piano sound (you need to get the original 
version of Salamander Grand).  This allows for a level of complexity and fine-
tuning of sound quality that is not possible through the GUI of VST plug-ins 
or filter settings within SFZ files.  It takes about 12 minutes to build a 
complete 48kHz version (Core i5-8250U CPU @ 1.6GHz). 


Changelog:

V3.0 (Nov.24,2023)
* First release based on Salamander Grand Piano V3+20161209.
V4.0RC1 (Mar.3,2024), V4.0RC8 (May.9,2024)
* Applied 4 filtering with effective rate, reassigned WAV, adjusted all 
  volume of WAV, erased noises and restoration of overtone/envelope F#1 and
  notes around C3.
V4.0 (May.14,2024)
* Amount of delay was equalized for each note.


Licence: 

CC-by (same licence as the original version)
http://creativecommons.org/licenses/by/3.0/


Acknowledgments:

We are very grateful to Alexander Holm for developing the original sound bank 
and advising us on this project.  We searched numerous free sound banks, but 
only Salamander Grand Piano had sufficient quality and freedom of development.

We would like to thank Katsuhiro Oguri (Professional Musician) for allowing us
to use his performance data.  The MIDI files not only made for an ideal 
listening section on this site, but also greatly aided in the development of 
the sound sources and in confirming the results of the adjustments. 

We would like to thank Frieve-A (Deep Learning Specialist) for his important
evaluation of our product.  His Youtube video was a great help in creating our
website.


Author:

Chisato Yamauchi
cyamauch (at) ir.isas.jaxa.jp


