

all::
#	sh add_mul.sh vol_factor.src.src.V4.0RC1.txt vol_fix_distortion.V4.0RC1-to-RC2.src.txt > vol_factor.src.src.V4.0RC2.txt
#	sh add_mul.sh vol_factor.src.src.V4.0RC2.txt vol_fix_V4.0RC2-to-RC3.src.txt > vol_factor.src.src.V4.0RC3.txt
#	sh add_mul.sh vol_factor.src.src.V4.0RC3.txt vol_fix_V4.0RC3-to-RC4.src.txt > vol_factor.src.src.V4.0RC4.txt
#	sh add_mul.sh vol_factor.src.src.V4.0RC4.txt vol_fix_V4.0RC4-to-RC5.src.txt > vol_factor.src.src.V4.0RC5.txt
#	sh add_mul.sh vol_factor.src.src.V4.0RC5.txt vol_fix_V4.0RC5-to-RC6.src.txt > vol_factor.src.src.V4.0RC6.txt
#	sh add_mul.sh vol_factor.src.src.V4.0RC6.txt vol_fix_V4.0RC6-to-Rel.src.txt > vol_factor.src.src.V4.0Rel.txt
	sh add_mul.sh vol_factor.src.src.V4.0Rel.txt vol_fix_V4.0Rel-to-V5.0overall.txt > vol_factor.src.src.V5.0overall.txt
	sh add_mul.sh vol_factor.src.src.V5.0overall.txt vol_fix_V4.0Rel-to-V5.0beta1.txt > vol_factor.src.src.V5.0beta1.txt
	sh add_mul.sh vol_factor.src.src.V5.0beta1.txt vol_fix_V5.0beta1-to-V5.0RC1.txt > vol_factor.src.src.V5.0RC1.txt
	sh mk_vol_factor.src4build.sh vol_factor.src.src.V5.0RC1.txt > vol_factor.src4build.txt

copy::	all
	cp -p vol_factor.src4build.txt ../vol_factor.src.txt

