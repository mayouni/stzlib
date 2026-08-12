# HEAR AND SEE THE ANALYSIS -- SN5, out loud and on screen.
#
# A guard proves the numbers. This plays the sound the numbers describe, then
# draws the picture, so you can check both senses against each other.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_analysis_demo.ring
#
# It plays a rising sweep and draws its spectrogram (a diagonal), plays a
# click track and reports the tempo it heard, and measures the loudness of
# two tones you can hear are 6 dB apart.

load "../../stzBase.ring"
decimals(2)

cTmp = currentdir() + "/temp"
if NOT direxists(cTmp)
	system("mkdir " + '"' + cTmp + '"')
ok

? ""
? "=== SN5 ANALYSIS, HEARD AND SEEN ==="

# ---- 1. the sweep: hear it rise, then see it rise -------------------------
? ""
? "1. A sweep from 200 Hz to 4 kHz. Listen to it climb..."
oSw = StzSoundOfSilenceQ(3.0, 1, 48000)
nN = oSw.Frames()
nPh = 0
for i = 1 to nN
	nU = (i - 1) / nN
	nHz = 200 + 3800 * nU
	nPh += 2 * 3.14159265358979 * nHz / 48000
	oSw.SetSampleAt(i, 1, 0.5 * sin(nPh))
next
oSw.Play()

oSg = oSw.ToSpectrogram()
? "   ...and here is what it looked like:"
? "   " + oSg.Rows() + " windows, peak went from " +
  oSg.PeakFrequencyOfRow(4) + " Hz to " + oSg.PeakFrequencyOfRow(oSg.Rows() - 4) + " Hz"
oSg.ToSVGFile(cTmp + "/demo_sweep.svg", 760, 260)
? "   drawn through stzCanvas -> temp/demo_sweep.svg (a diagonal)"
oSg.Release()
oSw.Release()

# ---- 2. the click track: hear the beat, then read the BPM -----------------
? ""
? "2. A click track. Count along -- is it 120 BPM?"
oCl = StzSoundOfSilenceQ(2.5, 1, 48000)
for k = 0 to 4
	nAt = floor(k * 0.5 * 48000) + 1
	for i = 0 to 2999
		nEnv = 1 - i / 3000
		oCl.SetSampleAt(nAt + i, 1, 0.8 * nEnv * sin(2 * 3.14159265358979 * 1200 * i / 48000))
	next
next
oCl.Play()
oOn = oCl.ToOnsets()
? "   the analysis heard " + oOn.Columns() + " onsets and calls it " + oCl.Tempo() + " BPM"
oOn.Release()
oCl.Release()

# ---- 3. loudness: hear 6 dB, then measure 6 dB ----------------------------
? ""
? "3. The same tone twice -- the second is twice the amplitude."
? "   Your ears should hear it as clearly louder, not twice as loud."
oA = StzSoundOfSilenceQ(1.2, 1, 48000)
oB = StzSoundOfSilenceQ(1.2, 1, 48000)
for i = 1 to oA.Frames()
	nV = sin(2 * 3.14159265358979 * 440 * (i - 1) / 48000)
	oA.SetSampleAt(i, 1, 0.15 * nV)
	oB.SetSampleAt(i, 1, 0.30 * nV)
next
? "   quieter..."
oA.Play()
? "   louder..."
oB.Play()
? "   measured: " + oA.Loudness() + " LUFS and " + oB.Loudness() + " LUFS"
? "   difference: " + (oB.Loudness() - oA.Loudness()) + " LU  (doubling amplitude is +6.02)"
oA.Release()
oB.Release()

? ""
? "done."
