
Use tools in ../volume_evaluation_88keys to measure 88-notes.

Script file "measure_all_volumes.sh" directly uses WAV files to measure
30-notes (A0, C1 ... C8).

To measure gap between two layers (e.g., v7 and v8), 
- Use make_gap-measurement_mid.sh to generate .mid files
- Convert .mid to .wav using your MIDI player
- Run measure_all_gaps.sh.

Script "get_unsampled_volumes.sh" calculates correction values of volumes for
unsampled notes.  The result will be saved in "unsampled_volumes.txt".

