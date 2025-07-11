
-------------------------------------------------------------------------------

    Noct-Salamander Grand Piano Project

    Free SFZ 48kHz/24bit Accurate Grand Piano Soundbanks

-------------------------------------------------------------------------------


*** Technical info

For this project, a dedicated processing system was developed to remaster the 
Salamander Grand soundbank, which has a high recording quality.

  "Salamander Grand Piano" Web site
  https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html

By setting the optimal codes and parameters for each sound source (WAV file) 
in the system, a new set of sound sources with high homogeneity and continuity
can be generated.

The remastering process is divided into the following two stages:

    Process to make the original Salamander Grand higher quality
    (Generate Accurate-Salamander Grand Piano soundbank)
    Tone modification process
    (Generate Twilight-, Moonlight- and Noct-Salamander Grand soundbanks)

Each is described below.


** Process to make the original Salamander Grand higher quality

The quality of the soundbanks, such as Twilight-Salamander, generated in the 
second stage of processing will inherit the results of this first stage of 
processing. Therefore, this first stage should be as perfect as possible.

The processing in the first stage completes the continuity in the velocity 
and note directions. To achieve this, the following processing is performed.
Of course, to ensure that sound quality is not compromised, we consistently 
use floating-point arithmetic:


 1. Evaluate the amount of overtone (not the volume), and reassign the WAV 
    files. WAV files with obvious recording errors are removed.
    (Purpose: To minimize subsequent filter processing. See assign.txt)

 2. Set the playback start position for all WAV files and equalize the amount 
    of delay for each note.
    (See pcm_seek_pos.txt and mk_special.txt)

 3. Fixed tuning errors.
    (Note: The amount of error was negligible.  See tuned.txt)

 4. Two filters (frequency x 12, frequency x 26) to adjust for excessive 
    amount of overtone that cannot be resolved by WAV file reassignment in 1.
    (See overtone_root.txt)

 5. Adjust the volume of all WAV files.
    The volume of the first 0.5 seconds of all 480 WAV files was measured and 
    adjusted so that all layers had the same volume curve (flat in the mids 
    and lows, linear decay in the highs).
    (See vol_factor.src.txt and vol_factor_base.txt)

 6. Adjustment for lack of fundamental tone volume (mainly in the middle to 
    treble)
    Adjusting the volume with the measurement in 5. reveals a lack of 
    fundamental tone amount by aural perception, so adjust the amount of 
    string tones with a narrow-band filters and go back to 5. and readjust 
    the volume.
    (See filter_direct.txt)

 7. Eliminate spotty noise that may be caused by the recording.
    (See mk_special.sh)

 8. Eliminates vibration sounds other than hammer and strings using 
    narrow-band filters
    (See filter_direct.txt)

 9. Excessive amount of overtones (mainly in Layer 1) that cannot be resolved 
    by the filter processing in 4. and high-frequency components 
    (around 3000Hz and 6000Hz) in mid-range notes are adjusted individually.
    (See filter_direct.txt)

10. Problems that cannot be solved by any of the above processes (envelope 
    problems, fatal problems, etc.) are handled by individual processing.
    (See mk_special.sh...F#1,F#2,A2,C3,D#3 and C6)

The YAMAHA C5 grand piano used for the Salamander Grand was tuned fairly 
accurately.  The piano is considered to be in generally good condition, and 
its tone, although quite uneven, is continuous throughout.  However, only "C3"
and "F#1" had an "abnormal tone" that could have been caused by defective 
hammers or strings, and the continuity of sound quality was broken there. 
Of the individual processes shown in the last item in the list above, the most
extensive was the restoration process for the two notes, which we spent a 
great deal of time working on:

The restoration process was best done in two ways: 1. using the original sound
source, and 2. using the sound source of the note closest to the original.
As a result, for both "F#1" and "C3", method 2 resulted in a better sound. 
In the case of "F#1", we realized that the original sound source did not have 
the necessary frequency components, so we gave up on the restoration using 
method 1.  In the case of "C3", the method 1 was still good, but the attack 
part could not be restored properly.

Therefore, we are using the "A1" and "A2" sound sources for the restoration 
process of "F#1" and "C3", respectively.  Of course, this is not simply a 
matter of using the same sound sources over and over again.  Spectral analysis
is used to fine-tune the attack strength, overtone components, etc., so the 
restored sound sources have a fairly natural tone.

All of the above processes have resulted in the desired tones for all 88 keys.
The production of the Accurate-Salamander Grand Piano has been finished. 


** Tone modification process

* Free high-quality soundbanks are not often released if we wait

The original Salamander Grand was not well suited for gentle (piano or 
pianissimo) expression due to its hard sound on the low velocity side.  The 
same is true for the higher quality Accurate-Salamander.

For such a deeply artistic theme, a new sound source set should be created by 
sampling another grand piano, but it is easy to imagine that there are not 
many free high-quality sound source sets available if we wait.  This is 
because, in order to obtain a high-quality soundbank, the completeness of the 
piano, the condition/tuning of each component of the piano, and the 
sampling/mastering method must all be at a high level of completeness.  If 
there is a problem with any of these, a great deal of effort will be spent on 
"essentially unnecessary processing", as seen in the "first stage processing" 
of this project.  Therefore, it is extremely difficult to achieve high quality
at low cost, and the good ones will inevitably cost money.

But that doesn't mean we have to give up completely on free new high-quality 
soundbanks.  We can generate another soundbanks by processing the Accurate-
Salamander data.  Of course, this is a far cry from "real" sampling, but even
a pseudo-sampling is far better than no soundbanks, and there are applications
where this is still sufficient.

* Reproduces the sound of a larger grand piano

The beautiful tone of large grand pianos is attributed to the steep decrease 
in overtones from low to high tones.  In particular, there are very few high-
frequency components in the low velocity middle and high tones.  So it is 
perfectly capable of gentle (piano or pianissimo) expression.  This is a 
natural consequence of physics.  That is, small objects tend to emit high 
frequencies and large objects tend to emit low frequencies.  The YAMAHA C5 
used for the Salamander Grand is not a large size, so it is natural that it 
would produce a tone with a lot of high frequencies.

This means that if we have good sampling data from a non-large grand piano, we
can obtain a tone similar to that of a large grand piano by adjusting its 
frequency components (mainly mid and high tones) and envelope.  That is the 
second stage of processing, which performs the following tone modification 
process on the Accurate-Salamander soundbanks that have already been processed
for high quality:

 - 4 filters applied from low to high frequencies:
   Frequency x 0.5, Frequency x 4, Frequency x 12 and Frequency x 26.
   (See overtone_config.{twilight,moonlight,noct}.txt,
    overtone3_config.{twilight,moonlight,noct}.txt)

 - Changed envelope shape (emulates slow string decay)

In pursuit of natural sound quality, the same filters used in the first stage
of processing are mainly used for filtering, and furthermore, the filtering 
and envelope modification levels are smoothly varied according to the scale. 
In the actual processing, floating-point arithmetic is consistently used from 
the original Salamander Grand to ensure that sound quality is not compromised,
and only the final result is output as a 24-bit integer.

Through this process, the three sound source sets Twilight-Salamander, 
Moonlight-Salamander and Noct-Salamander approach the tone of larger grand 
pianos more closely than the YAMAHA C5.  Thus new soundbanks have been 
available that we can use for gentle (piano or pianissimo) expression.

Note that there is room for improvement in the filtering method.  This may be
the focus of future upgrades.


** Equipment and software used, and licenses

For pitch adjustment, the built-in soundbank of the YAMAHA EA1 was used as a 
reference.

Although waveforms and spectra were used extensively in the adjustment 
process, we ultimately evaluated each sound and its homogeneity and continuity
by listening.  For adjustment and confirmation, we mainly used a USB audio 
interface Roland Rubix22 and studio monitor headphones SONY MDR-CD900ST. 
In addition, BOSE 101IT speakers were used for final confirmation.

Although the license terms of the original soundbank require that 
modifications be explicitly stated, this project has chosen to make the 
modifications explicit as well.  The reason for this is to ensure that the 
soundbanks released by this project are fully open source software.

All processing was done with scripts and FFmpeg was used for audio data 
processing.  All code is available in the GitHub repository.  See src/build.sh
for details.  You can also modify the parameter file introduced in the second 
stage and execute "make noct48" to generate a piano sound set with the desired
tones.(you need to get the original version of Salamander Grand) 
This allows for a level of complexity and fine-tuning of tone quality that is 
not possible through the GUI of player softwares or filter settings within SFZ
files.  Note that it takes about 12 minutes to build a complete 48 kHz version
(Core i5-8250U CPU @ 1.60 GHz).



*** Changelog:

V3.0 (Nov.24,2023)
* First release based on Salamander Grand Piano V3+20161209.
V4.0RC1 (Mar.3,2024), V4.0RC8 (May.9,2024)
* Applied 4 filtering with effective rate, reassigned WAV, adjusted all 
  volume of WAV, erased noises and restoration of overtone/envelope F#1 and
  notes around C3.
V4.0 (May.14,2024)
* Amount of delay was equalized for each note.
V4.1 (May.29,2024)
* Improved volume continuity.
* Testing the balance between bass and treble.
V5.0beta1 soundbank #0:"Daylight" (May.31,2024)
* Improved processing system to release multiple soundbanks.
* Minimized amount of delay.
V5.0beta2 (Jun.7,2024)
* soundbank #0:"Daylight" -- This offers instrument manufacturer-level quality 
            while maintaining the tone of the original Salamander Grand.
* soundbank #1:"Twilight" -- The low velocity side of soundbank #0 was adjusted
            softly.
* soundbank #2:"Moonlight" -- This provides softer sound than soundbank #1.
            Inherits the sound of soundbank #0 in high velocity.
* soundbank #3:"Noct" -- This emphasizes gentleness with a tone similar to that
            of a large grand piano.  Most suitable for relaxation music.
V5.0RC1 (Jun.19,2024), V5.0RC3 (Jun.27,2024)
* Tone of "C3" was further improved by a new restoration process.
* Noise during the attack of "A2" was eliminated.
* Waveform of "F#1" was improved.
* Renamed "Daylight" -> "Accurate".
V5.0 (Aug.5,2024)
* Volume adjustment for all sound sources is performed using the values 
  measured by FFmpeg (first 0.5 seconds of each WAV file).
* Adjustment of the volume ratio between hammered sound and string sound 
  on notes where the audible volume does not match the measured volume 
  (higher than F#4)
* High-frequency vibration noises in several notes around F#5 are removed 
  by narrow-band filters.
* High-frequency components (around 3000Hz and 6000Hz) in mid-range notes are 
  adjusted individually to improve continuity.
* "F#1" and "C3" are generated from "A1" and "A2" respectively.
* Code for restoring "C6" is added to mk_special.sh.
V5.1 (Aug.30,2024)
* amp_veltrack of SFZ files are changed: 76 => 83.
* Reviewed and improved removal of non-overtone frequency components between 
  A4 and C8.
* Improved amount of high-frequency component at A4,C5,A5,C6 and D#6.
* Improved tuning of C3: -3 => -2 cent.
V5.2 (Sep.18,2024)
* Improved continuity and minimized filtering between C2 and C4.  This results
  in a higher quality while keeping the tone closer to that of the original 
  Salamander.
V5.2a (Jan.23,2025)
* Updated the SFZ files:
 - Compliant with SFZ v1 and uses SFZ v2 features.
 - Fixed CC64 problems found on SFZ v1 softwares such as VirtualMIDISynth.
 - To enable "Release String Resonances", "Hammer Noise", and "Pedal Noise", 
   set CC20=64, CC21=64, and CC22=64 respectively.  They are disabled by 
   default.
 - By making F6 a half damper and F#6 and higher damperless, the behavior of a
   grand piano is perfectly reproduced.
V5.2f (Feb.4,2025)
* Updated the SFZ files to enable "repedaling".
  (Thanks to Andrew <https://github.com/esesur>)
* Moved amp_veltrack to the <global> section of the SFZ files.
V6.0beta1 (Jul.11,2025)
* Volume adjustments and tuning for all 88 notes are set in the SFZ file.
* The results of tuning by tuner Hiroharu Narikawa on July 8, 2025 have been
  reflected in tuned.txt and tuned_sfz.txt.
* The volume of all 88 notes in 16 velocity layers was adjusted to match the
  tuning.
* Change "velocity to WAV file" assignment:
  [v2:7 v3:4 v4:6 v5:4 v6:5] => [v2:6 v3:5 v4:5 v5:5 v6:5]
* The volume gap between velocity layers has been reduced to about 2
  velocities.  Accordingly, AMP_VELTRACK has been changed to 97.0.


*** Licence:

CC-by (same licence as the original version)
http://creativecommons.org/licenses/by/3.0/



*** Acknowledgments:

We are very grateful to Alexander Holm for developing the original sound bank 
and advising us on this project.  We searched numerous free sound banks, but 
only Salamander Grand Piano had sufficient quality and freedom of development.

We would like to thank Katsuhiro Oguri (Professional Musician) for allowing us
to use his performance data.  The MIDI files not only made for an ideal 
listening section on this site, but also greatly aided in the development of 
the soundbanks and in confirming the results of the adjustments. 

We would like to thank Frieve-A (Deep Learning Specialist) for his important
evaluation of our product.  His Youtube video was a great help in creating our
website.



*** Author:

Chisato Yamauchi
cyamauch (at) ir.isas.jaxa.jp
x.com/999irf

