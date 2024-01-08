
#
# Set your ffmpeg.exe.  Native Windows binary is OK.
#
FFMPEG = /cygdrive/c/archives/Piano/VirtualMIDISynth/ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe


SRCDIR44 =  ../SalamanderGrandPianoV3_44.1khz16bit
SRCPCMDIR44 =  $(SRCDIR44)/44.1khz16bit 
DESTDIR44 = ../NoctSalamanderGrandPianoV3.1_44.1khz16bit
DESTPCMDIR44 = $(DESTDIR44)/44.1khz16bit

SRCDIR48 =  ../SalamanderGrandPianoV3_48khz24bit
SRCPCMDIR48 =  $(SRCDIR48)/48khz24bit
DESTDIR48 = ../NoctSalamanderGrandPianoV3.1_48khz24bit
DESTPCMDIR48 = $(DESTDIR48)/48khz24bit


noct44::
	mkdir -p $(DESTPCMDIR44)
	mkdir -p $(DESTDIR44)/src
	cp -p README.txt $(DESTDIR44)/.
	cp -p do_eql+env_all.sh freq_data.csv freq-sec.txt freq-sec_fnc.png $(DESTDIR44)/src/.
	cp -p Makefile freq_piano_data.txt *_factor.txt substitute.txt tuned.txt $(DESTDIR44)/src/.
	cp -p $(SRCDIR44)/README $(DESTDIR44)/README.orig.txt
	cp -p $(SRCDIR44)/SalamanderGrandPianoV3.sfz $(DESTDIR44)/.
	FS_SRC=44100 FFMPEG="$(FFMPEG)" FFMPEG_OPT="-c:a pcm_s16le" sh do_eql+env_all.sh $(SRCPCMDIR44) $(DESTPCMDIR44)

noct48::
	mkdir -p $(DESTPCMDIR48)
	mkdir -p $(DESTDIR48)/src
	cp -p README.txt $(DESTDIR48)/.
	cp -p do_eql+env_all.sh freq_data.csv freq-sec.txt freq-sec_fnc.png $(DESTDIR48)/src/.
	cp -p Makefile freq_piano_data.txt *_factor.txt substitute.txt tuned.txt $(DESTDIR48)/src/.
	cp -p $(SRCDIR48)/README $(DESTDIR48)/README.orig.txt
	cp -p $(SRCDIR48)/SalamanderGrandPianoV3.sfz $(DESTDIR48)/.
	FS_SRC=48000 FFMPEG="$(FFMPEG)" FFMPEG_OPT="-c:a pcm_s24le" sh do_eql+env_all.sh $(SRCPCMDIR48) $(DESTPCMDIR48)

clean44::
	rm -rf $(DESTDIR44)

clean48::
	rm -rf $(DESTDIR48)

