

all::
	sh add_mul.sh vol_factor.src.src.V4.0RC1.txt vol_fix_distortion.V4.0RC1-to-RC2.src.txt > vol_factor.src.src.V4.0RC2.txt
	sh add_mul.sh vol_factor.src.src.V4.0RC2.txt vol_fix_V4.0RC2-to-RC3.src.txt > vol_factor.src.src.V4.0RC3.txt
	sh mk_vol_factor.src4build.sh vol_factor.src.src.V4.0RC3.txt > vol_factor.src4build.txt

copy::	all
	cp -p vol_factor.src4build.txt ../vol_factor.src.txt

