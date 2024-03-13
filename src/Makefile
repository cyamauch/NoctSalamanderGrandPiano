
#
# Set your ffmpeg.exe.  Native Windows binary is OK.
#
FFMPEG = /cygdrive/c/archives/Piano/VirtualMIDISynth/ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe


SRCDIR48 =  ../SalamanderGrandPianoV3_48khz24bit
SRCPCMDIR48 =  $(SRCDIR48)/48khz24bit
DESTDIR48 = ../NoctSalamanderGrandPianoV4.0_48khz24bit
DESTPCMDIR48 = $(DESTDIR48)/48khz24bit

DESTDIR48TEST = ../NoctSalamanderGrandPiano_Test
DESTPCMDIR48TEST = $(DESTDIR48TEST)/48khz24bit

SRCDIR44 =  ../SalamanderGrandPianoV3_44.1khz16bit
SRCPCMDIR44 =  $(SRCDIR44)/44.1khz16bit
DESTDIR44 = ../NoctSalamanderGrandPianoV4.0_44.1khz16bit
DESTPCMDIR44 = $(DESTDIR44)/44.1khz16bit

DESTDIR44TEST = ../NoctSalamanderGrandPiano_Test
DESTPCMDIR44TEST = $(DESTDIR44TEST)/44.1khz16bit

vol_factor.txt::
	sh mk_vol_factor.sh  > vol_factor.txt

noct48:: vol_factor.txt
	mkdir -p $(DESTPCMDIR48)
	mkdir -p $(DESTDIR48)/src
	cp -p README.txt $(DESTDIR48)/.
	cp -p rename_wav.sh freq_data.csv freq-sec.txt freq-sec_fnc.png $(DESTDIR48)/src/.
	cp -p Makefile do_eql+env_all.sh mk_special.sh freq_piano_data.txt key_n-id.txt $(DESTDIR48)/src/.
	cp -p *_factor*.txt assign.txt tuned.txt filter_direct.txt sfz_sed_args.txt $(DESTDIR48)/src/.
	cp -p $(SRCDIR48)/README $(DESTDIR48)/README.orig.txt
	cp -p $(SRCPCMDIR48)/h*.wav $(DESTPCMDIR48)/.
	cp -p $(SRCPCMDIR48)/p*.wav $(DESTPCMDIR48)/.
	cp -p $(SRCPCMDIR48)/r*.wav $(DESTPCMDIR48)/.
	FS_SRC=48000 FFMPEG="$(FFMPEG)" FFMPEG_OPT="-c:a pcm_s24le" sh do_eql+env_all.sh make $(SRCPCMDIR48) $(DESTPCMDIR48) $(SRCDIR48)/SalamanderGrandPianoV3.sfz

noct44::
	mkdir -p $(DESTPCMDIR44)
	mkdir -p $(DESTDIR44)/src
	cp -p README.txt $(DESTDIR44)/.
	cp -p rename_wav.sh freq_data.csv freq-sec.txt freq-sec_fnc.png $(DESTDIR44)/src/.
	cp -p Makefile do_eql+env_all.sh mk_special.sh freq_piano_data.txt key_n-id.txt $(DESTDIR44)/src/.
	cp -p *_factor*.txt assign.txt tuned.txt filter_direct.txt sfz_sed_args.txt $(DESTDIR44)/src/.
	cp -p $(SRCDIR44)/README $(DESTDIR44)/README.orig.txt
	cp -p $(SRCPCMDIR44)/h*.wav $(DESTPCMDIR44)/.
	cp -p $(SRCPCMDIR44)/p*.wav $(DESTPCMDIR44)/.
	cp -p $(SRCPCMDIR44)/r*.wav $(DESTPCMDIR44)/.
	FFMPEG="$(FFMPEG)" FFMPEG_OPT="-c:a pcm_s16le -ar 44100" sh do_eql+env_all.sh copy $(DESTPCMDIR48) $(DESTPCMDIR44) $(SRCDIR44)/SalamanderGrandPianoV3.sfz

clean48::
	rm -rf $(DESTDIR48)

clean44::
	rm -rf $(DESTDIR44)

#
# Create mono version of WAV files for devel.
#
test48:: vol_factor.txt
	mkdir -p $(DESTPCMDIR48TEST)
	FS_SRC=48000 FFMPEG="$(FFMPEG)" FFMPEG_OPT="-ac 1 -c:a pcm_s24le" sh do_eql+env_all.sh make $(SRCPCMDIR48) $(DESTPCMDIR48TEST)

test44:: vol_factor.txt
	mkdir -p $(DESTPCMDIR44TEST)
	FS_SRC=44100 FFMPEG="$(FFMPEG)" FFMPEG_OPT="-ac 1 -c:a pcm_s16le" sh do_eql+env_all.sh make $(SRCPCMDIR44) $(DESTPCMDIR44TEST)

