# THE INSIGHT GALLERY -- five pictures, each one showing something true about
# sound that you cannot see in a number.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_insights_gallery.ring
#
# Writes five PNGs into temp/ and PLAYS the sound behind each one, so every
# claim can be checked with both senses. One of them is a real defect in this
# engine, drawn rather than described.
#
# WHY THESE FIVE: each is a phenomenon that a spectrogram or a spectrum makes
# obvious and a number makes invisible.
#
#   1  ALIASING       a genuine bug in our oscillators, visible as folding
#   2  A CLICK        why a step is broadband, and a ramp is not
#   3  TIMBRE         why saw and triangle measure the same and sound different
#   4  BEATS          two tones a few Hz apart, interfering
#   5  RESONANCE      what a filter's Q actually does

load "../../stzBase.ring"
decimals(2)

RATE = 48000
cOut = currentdir() + "/temp"
if NOT direxists(cOut)
	system("mkdir " + '"' + cOut + '"')
ok

bPlay = TRUE
if len(sysargv) >= 3 and lower(sysargv[3]) = "quiet"
	bPlay = FALSE
ok

? ""
? "=== FIVE THINGS SOUND DOES, DRAWN ==="

# ===========================================================================
# 1. ALIASING -- a real bug in this engine, not a textbook illustration
# ===========================================================================
? ""
? "1. ALIASING -- our oscillators are NAIVE, and this is what that costs."
? "   A saw is every harmonic at once. Sweep its pitch up and the upper"
? "   harmonics reach Nyquist (24 kHz) -- and a sampled system cannot hold"
? "   them, so they FOLD BACK DOWN as descending lines that were never"
? "   played. Listen for the shimmer moving the WRONG WAY."

# 1500 -> 6000 Hz, on purpose: high enough that harmonics 4, 5, 6 -- the LOUD
# ones -- are the ones crossing Nyquist. A lower sweep aliases too, but only
# via harmonic 60-odd at 1/60 the amplitude, which is a true picture of a
# faint thing. This is a true picture of a loud one.
oAl = StzSoundOfSilenceQ(3.0, 1, RATE)
nN = oAl.Frames()
nPh = 0
for i = 1 to nN
	nU = (i - 1) / nN
	nHz = 1500 + 4500 * nU
	nPh += nHz / RATE
	if nPh >= 1  nPh -= 1 ok
	oAl.SetSampleAt(i, 1, 0.45 * (2 * nPh - 1))      # a naive saw, on purpose
next
if bPlay  oAl.Play() ok

oG1 = oAl.ToSpectrogramOf(1, 4096, 1024, 4)
oP1 = new stzSoundPlot(920, 400)
oP1.SetTitle("Aliasing: harmonics that fold back",
             "a naive sawtooth swept 1.5 -> 6 kHz, drawn all the way to Nyquist")
oP1.SetNote("Every rising line that reaches the ceiling comes back DOWN. Nothing descending was ever played: it is energy past 24 kHz, reflected. A band-limited oscillator would not do this -- ours is not one yet.")
oP1.SetDynamicRange(42)      # a naive saw has a LOUD floor; -70 dB shows all of it
oP1.DrawSpectrogram(oG1, 24000)
oP1.SaveAsPNG(cOut + "/1_aliasing.png")
? "   -> temp/1_aliasing.png"
oG1.Release()
oAl.Release()

# ===========================================================================
# 2. A CLICK IS BROADBAND -- the thing SN3's ramp exists to prevent
# ===========================================================================
? ""
? "2. A CLICK -- SN3 measured the ramp as 480x smoother than a step."
? "   Here is WHY that matters. The same tone is cut twice: once instantly"
? "   at 1.0 s, once over 30 ms at 2.0 s. One is a bang across every"
? "   frequency at once; the other is inaudible."

# The tone plays twice and ENDS twice. The first ending is a step to zero;
# the second is faded out over 30 ms. Everything else is identical, so any
# difference in the picture belongs to the ending and to nothing else.
# (The second note also FADES IN, or its start would be a click of its own --
# the first draft of this plate had exactly that bug, and drew it.)
oCk = StzSoundOfSilenceQ(3.0, 1, RATE)
nN = oCk.Frames()
for i = 1 to nN
	nT = (i - 1) / RATE
	nV = 0.5 * sin(2 * 3.14159265358979 * 440 * nT)
	nGain = 0
	if nT < 1.0
		nGain = 1                                   # ... then a STEP to zero
	but nT >= 1.5 and nT < 2.5
		nGain = 1
		if nT < 1.53                                # 30 ms in
			nGain = (nT - 1.5) / 0.03
		but nT > 2.47                               # 30 ms out
			nGain = (2.5 - nT) / 0.03
		ok
	ok
	oCk.SetSampleAt(i, 1, nV * nGain)
next
if bPlay  oCk.Play() ok

oG2 = oCk.ToSpectrogramOf(1, 1024, 256, 4)
oP2 = new stzSoundPlot(920, 400)
oP2.SetTitle("A step is broadband; a fade is not",
             "one 440 Hz tone, ended twice: cut dead at 1 s, faded over 30 ms at 2.5 s")
oP2.SetNote("The stripe at 1 s is the click -- a discontinuity contains EVERY frequency at once, all the way up. At 2.5 s the same tone simply stops, and the picture shows nothing extra.")
oP2.DrawSpectrogram(oG2, 12000)
oP2.MarkTimeAt(1.0, 3.0, "cut dead")
oP2.MarkTimeAt(2.5, 3.0, "faded out")
oP2.SaveAsPNG(cOut + "/2_click.png")
? "   -> temp/2_click.png"
oG2.Release()
oCk.Release()

# ===========================================================================
# 3. TIMBRE IS HARMONICS -- why two waves measure alike and sound different
# ===========================================================================
? ""
? "3. TIMBRE -- the studio found saw and triangle have the SAME crest factor"
? "   (57.7%), yet nobody would confuse them. Here is the difference: it was"
? "   never in the level, it was in the harmonics."

# BAND-LIMITED, built by ADDING harmonics rather than by drawing the shape.
# Using the engine's own oscillators here would be honest but unreadable: they
# are naive, so plate 1's aliases fill the gaps between the harmonics with fur
# and bury the very structure this plate exists to show. One plate per idea.
aSpectra = []
aWaves = [ "sine", "triangle", "square", "saw" ]
for w = 1 to 4
	oSnd = StzSoundOfSilenceQ(0.4, 1, RATE)
	nN = oSnd.Frames()
	for i = 1 to nN
		nT = (i - 1) / RATE
		nV = 0
		for h = 1 to 29                     # 29 x 220 Hz = 6.4 kHz, under Nyquist
			nHz = 220 * h
			nA = 0
			switch aWaves[w]
			on "sine"      if h = 1  nA = 1 ok
			on "triangle"  if h % 2 = 1  nA = 0.81 / (h * h) ok
			on "square"    if h % 2 = 1  nA = 0.64 / h ok
			on "saw"       nA = 0.64 / h
			off
			if nA != 0
				nV += nA * sin(2 * 3.14159265358979 * nHz * nT)
			ok
		next
		oSnd.SetSampleAt(i, 1, 0.6 * nV)
	next
	if bPlay and w = 1  ? "   (playing each in turn)" ok
	if bPlay  oSnd.PlayFor(0.5) ok
	aSpectra + [ aWaves[w], oSnd.ToSpectrumOf(1, 1000, 8192) ]
	oSnd.Release()
next

oP3 = new stzSoundPlot(920, 400)
oP3.SetTitle("Timbre is harmonics, not level",
             "four waves at 220 Hz, same pitch, same loudness")
oP3.SetNote("Sine: one line, nothing else. Triangle: odd harmonics falling away fast. Square: odd harmonics falling away slowly. Saw: every harmonic. Same note, four instruments.")
oP3.DrawSpectra(aSpectra, 150, 6000)
oP3.SaveAsPNG(cOut + "/3_timbre.png")
? "   -> temp/3_timbre.png"
for s = 1 to len(aSpectra)
	aSpectra[s][2].Release()
next

# ===========================================================================
# 4. BEATS -- two tones that are almost the same pitch
# ===========================================================================
? ""
? "4. BEATS -- 440 Hz and 443 Hz together. Neither is loud and soft, but the"
? "   SUM pulses three times a second, because they drift in and out of"
? "   phase. This is how a piano tuner hears 'not quite'."

oBt = StzSoundOfSilenceQ(3.0, 1, RATE)
nN = oBt.Frames()
for i = 1 to nN
	nT = (i - 1) / RATE
	oBt.SetSampleAt(i, 1, 0.35 * sin(2 * 3.14159265358979 * 440 * nT) +
	                      0.35 * sin(2 * 3.14159265358979 * 443 * nT))
next
if bPlay  oBt.Play() ok

oP4 = new stzSoundPlot(920, 340)
oP4.SetTitle("Beats: 440 Hz + 443 Hz",
             "two steady tones, one pulsing result")
oP4.SetNote("Three bulges per second, and 443 - 440 = 3. The beat rate IS the frequency difference -- which is why you tune by listening for it to slow down.")
oP4.DrawWave(oBt)
oP4.SaveAsPNG(cOut + "/4_beats.png")
? "   -> temp/4_beats.png"
oBt.Release()

# ===========================================================================
# 5. RESONANCE -- what Q does
# ===========================================================================
? ""
? "5. RESONANCE -- the same saw through the same 600 Hz lowpass, twice:"
? "   gently (Q 0.7) and sharply (Q 8). High Q does not just cut, it BOOSTS"
? "   the frequencies right at the corner. Listen for the whistle."

aRes = []
aQs = [ [0.7, "Q 0.7 (gentle)"], [8.0, "Q 8 (resonant)"] ]
for q = 1 to 2
	oG = new stzSoundGraph()
	oG.Reshape(1, RATE)
	oG.AddOscillator(:Saw, 110, 0.5)
	oG.NameIt(:src)
	oG.AddFilterOn(:src, :LowPass, 600, aQs[q][1])
	oSnd = oG.ToSound(1.0)
	if bPlay  oSnd.PlayFor(1.2) ok
	aRes + [ aQs[q][2], oSnd.ToSpectrumOf(1, 2000, 8192) ]
	oSnd.Release()
	oG.Release()
next

oP5 = new stzSoundPlot(920, 380)
oP5.SetTitle("What a filter's Q does",
             "a 110 Hz saw through a 600 Hz low-pass, twice")
oP5.SetNote("Both roll off above 600 Hz. The resonant one lifts a hump right AT the corner before it falls -- that peak is the whistle you can hear.")
oP5.DrawSpectra(aRes, 80, 6000)
oP5.MarkFrequencyAt(600, 80, 6000, "the corner")
oP5.SaveAsPNG(cOut + "/5_resonance.png")
? "   -> temp/5_resonance.png"
for s = 1 to len(aRes)
	aRes[s][2].Release()
next

? ""
? "five plates written to temp/."
