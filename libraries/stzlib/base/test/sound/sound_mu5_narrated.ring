# MU5 -- the voice, honestly. Three attempts in the plan's order, each
# measured: (a) SAPI told to hold a pitch, (b) a formant vowel voice in the
# seam, (c) neither -> Sing() present and REFUSING, with the reason.
#
# Kill criterion (plan section 6): "the plan does not ship a Sing() that
# produces something the author would not call singing." So Sing() is gated on
# a declared verdict, and this guard asserts the gate is shut until the author
# opens it.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0
nRate = 48000

pr()
decimals(3)

? "== MU5: can it sing? Measured, then gated on the author's ear =="
? ""

? "-- Scene 1: (a) SAPI, told to hold a pitch --"
? "   The plan's first try: a syllable per note, <prosody pitch> on each. The"
? "   bar is 20 cents. The voice is slowed (rate x-slow) to give it its best chance."
oV = StzVoiceQ()
if oV.IsUsable() and oV.VoiceCount() > 0
	oV.UseVoice(oV.VoiceCount())
	nBase = Mu5MedianOf(Mu5Reads(oV.ToSoundOfSsml(Mu5Ssml("<prosody rate=" + char(34) + "x-slow" + char(34) + ">laaaa</prosody>"))))
	? "   voice: " + oV.CurrentVoiceName() + "; its own pitch, unasked: " + nBase + " Hz"
	nWorstOff = 0
	nWorstSpread = 0
	for st = -6 to 6 step 4
		cSgn = "+"
		if st < 0  cSgn = "" ok
		oS = oV.ToSoundOfSsml(Mu5Ssml("<prosody rate=" + char(34) + "x-slow" + char(34) + " pitch=" + char(34) +
		                              cSgn + st + "st" + char(34) + ">laaaa</prosody>"))
		aR = Mu5Reads(oS)
		nWant = nBase * pow(2, st / 12)
		nMed = Mu5MedianOf(aR)
		nOff = 1200 * log(nMed / nWant) / log(2)
		nSp = Mu5SpreadOf(aR)
		if fabs(nOff) > nWorstOff  nWorstOff = fabs(nOff) ok
		if nSp > nWorstSpread  nWorstSpread = nSp ok
		? "   asked " + PadN(st, 3) + " st: median " + PadN(floor(nMed * 10) / 10, 6) + " Hz, " +
		  PadN(floor(nOff), 5) + " cents off, wandering " + floor(nSp) + " cents within the syllable"
	next
	# A RECORD, NOT A WISH: this asserts SAPI FAILS the bar. If a future voice
	# held a pitch, this check would go red -- and (a) should be looked at again.
	Chk("(a) REJECTED, measured: SAPI misses the pitch by up to " + floor(nWorstOff) +
	    " cents and wanders up to " + floor(nWorstSpread) + " within a note -- the bar is 20",
	    nWorstOff > 20 or nWorstSpread > 20)
else
	nSkip++
	? "  [skip] no SAPI voice on this machine -- (a) cannot be measured here"
ok

? ""
? "-- Scene 1b: (a') SAPI's OWN voice, retuned onto the note --"
? "   After the author heard (a) and said SAPI's voice is 'very close from real"
? "   human voice', the rejection was seen for what it was: of its PITCH, not its"
? "   voice. So SAPI speaks the syllable and the engine's PSOLA lays its glottal"
? "   periods back down at the note's period. The same 20-cent bar as (a)."
oRt = StzSoundRetunedVoiceQ()
if oRt.IsUsable()
	oRt.SetVibrato(0)
	nWorstRt = 0
	nWorstSpRt = 0
	for cN in [ "G3", "C4", "E4", "G4", "C5" ]
		oN = oRt.Syllable("laa", cN, 1.2)
		nHz = StzNoteToHz(cN)
		aR = []
		for t in [ 0.5, 0.7, 0.9 ]
			aR + (1200 * log(StzEngineSoundMeasurePitch(oN.BufferId(), floor(t * 48000), nHz, 0) / nHz) / log(2))
		next
		nMed = aR[2]
		nSp = fabs(max(aR) - min(aR))
		if fabs(nMed) > nWorstRt  nWorstRt = fabs(nMed) ok
		if nSp > nWorstSpRt  nWorstSpRt = nSp ok
		nShift = 1200 * log(nHz / oRt.FromHz()) / log(2)
		? "   " + cN + ": spoken at " + floor(oRt.FromHz()) + " Hz, shifted " + PadN(floor(nShift), 5) +
		  " cents, " + oRt.Marks() + " periods; held at " + nMed + " cents, spread " + nSp
		oN.Release()
	next
	Chk("(a') HOLDS: SAPI's voice retuned onto five notes, G3 to C5, within 20 cents " +
	    "(worst " + nWorstRt + ") and steady within 20 (worst spread " + nWorstSpRt + ")",
	    nWorstRt < 20 and nWorstSpRt < 20)
	Chk("and far inside it: within 2 cents past the attack", nWorstRt < 2)
else
	nSkip++
	? "  [skip] no SAPI voice -- (a') cannot be measured here: " + oRt.LastError()
ok

? ""
? "-- Scene 2: (b) the formant voice -- on its pitch --"
? "   A Rosenberg glottal pulse through five formant resonators (the Csound"
? "   manual's tenor table below 330 Hz, soprano above). A phase accumulator:"
? "   no loop to tune, so the pitch should be exact."
oF = StzSoundFormantVoiceQ().SetVibrato(0)
nWorst = 0
for cVo in [ "a", "e", "i", "o", "u" ]
	for nHz in [ 110, 196, 330, 523 ]
		oN = oF.Vowel(cVo, nHz, 1.2)
		nGot = StzEngineSoundMeasurePitch(oN.BufferId(), 24001, nHz, 0)
		nC = fabs(1200 * log(nGot / nHz) / log(2))
		if nC > nWorst  nWorst = nC ok
		oN.Release()
	next
next
? "   5 vowels x 4 pitches (110 to 523 Hz), no vibrato: worst " + nWorst + " cents"
Chk("(b) holds its pitch within the plan's 2 cents -- every vowel, every register", nWorst < 2)
oFv = StzSoundFormantVoiceQ()
oNv = oFv.Vowel("a", 220, 2.0)
nAcc = 0
for k = 0 to 31
	nAt = floor(24000 + (48000 / 5.5) * 4 * k / 32)
	nAcc += 1200 * log(StzEngineSoundMeasurePitch(oNv.BufferId(), nAt + 1, 220, 0) / 220) / log(2)
next
? "   with a singer's +-25-cent vibrato, read evenly over four cycles: centre " + (nAcc / 32) + " cents"
Chk("and under its vibrato the centre is still the note, within 2 cents", fabs(nAcc / 32) < 2)

? ""
? "-- Scene 3: (b) the formant voice -- its vowels are the vowels --"
? "   Each vowel sung at 110 Hz, the harmonics measured one by one (a DFT at"
? "   every multiple of 110 up to 3.3 kHz), PRE-EMPHASISED (+6 dB per octave,"
? "   as formant analysis does), and the loudest below 900 Hz taken as the"
? "   first formant: it must land on the table's F1, within a harmonic."
# THE FIRST VERSION OF THIS SCENE FAILED ON i AND o, AND IT WAS THE READING.
# Without pre-emphasis the loudest harmonic of i and o was the SECOND (220 Hz),
# because the glottal source's own spectrum falls with frequency and a strong
# low harmonic out-shouts a weaker one sitting on the resonance. That is why
# formant analysis (LPC and its ancestors) pre-emphasises by +6 dB per octave
# before it looks for peaks -- applied here, and named, not tuned until green.
aF1 = []
bF1 = TRUE
for cVo in [ "a", "e", "i", "o", "u" ]
	oN = oF.Vowel(cVo, 110, 1.0)
	aH = Mu5Harmonics(oN, 110, 30)
	nF1 = Mu5LoudestIn(aH, 110, 200, 900)
	nWant = oF.FormantsOf(cVo, 110)[1]
	aF1 + nF1
	if fabs(nF1 - nWant) > 80  bF1 = FALSE ok
	? "   " + cVo + ": first formant measured " + PadN(nF1, 4) + " Hz, the table says " + nWant
	oN.Release()
next
Chk("every vowel's first formant is where the table puts it (within 80 Hz at 110 Hz spacing)", bF1)
Chk("and they are FIVE vowels, not one timbre: F1 falls from a (open) to i (closed)",
    aF1[1] > aF1[2] and aF1[2] > aF1[3] and aF1[1] > aF1[4] and aF1[1] > aF1[5])
oI = oF.Vowel("i", 110, 1.0)
nF2i = Mu5LoudestIn(Mu5Harmonics(oI, 110, 30), 110, 1200, 2500)
oA = oF.Vowel("a", 110, 1.0)
nF2a = Mu5LoudestIn(Mu5Harmonics(oA, 110, 30), 110, 900, 1500)
? "   second formants: i " + nF2i + " Hz (table 1870), a " + nF2a + " Hz (table 1080)"
Chk("i's second formant sits high and a's low, each within 110 Hz of the table",
    fabs(nF2i - 1870) <= 110 and fabs(nF2a - 1080) <= 110)

? ""
? "-- Scene 4: a line of vowels, and a glide --"
oL = oFv.VowelsQ("a e i o u", "c4 d4 e4 f4 g4", 96)
Chk("five vowels on five notes make one line", isObject(oL) and oL.Duration() > 3)
oG = oFv.SetVibrato(0).VowelGlide("a", 220, 330, 1.2)
nE = StzEngineSoundMeasurePitch(oG.BufferId(), 2401, 220, 0)
nL = StzEngineSoundMeasurePitch(oG.BufferId(), 50401, 330, 0)
nWantE = 220 * pow(1.5, 0.05 / 1.2)
nWantL = 220 * pow(1.5, 1.05 / 1.2)
? "   a glide 220 -> 330 Hz over 1.2 s: at 0.05 s " + nE + " Hz (the curve says " + nWantE +
  "), at 1.05 s " + nL + " (the curve says " + nWantL + ")"
# THE FIRST VERSION ASKED FOR 330 AT 1.05 s, AND THE CLAIM WAS WRONG: the
# glide spans the whole 1.2 s note in log frequency, so at 1.05 s it is due at
# 314, not 330. Each reading is now held to the curve at its own moment.
Chk("the voice glides ALONG the log curve: each reading within 2% of where the curve is then",
    fabs(nE / nWantE - 1) < 0.02 and fabs(nL / nWantL - 1) < 0.02 and nL > nE)

? ""
? "-- Scene 5: (c) Sing() -- gated on the author: one voice opened, one still shut --"
aVer = StzSoundSingingVerdict()
? "   the verdicts, declared: formant " + Mu5Get(Mu5Get(aVer, :formant), :verdict) +
  ", retuned " + Mu5Get(Mu5Get(aVer, :retuned), :verdict)
oS2 = StzSoundFormantVoiceQ()
oSung = oS2.Sing("la la la", "c4 e4 g4")
? "   Sing(" + char(34) + "la la la" + char(34) + "): refused -- " + ring_left(oS2.LastError(), 120) + "..."
Chk("while the formant verdict is UNPERCEIVED, its Sing() returns nothing and says why",
    Mu5Get(Mu5Get(aVer, :formant), :verdict) = "UNPERCEIVED" and isNull(oSung) and
    substr(oS2.LastError(), "not available YET") > 0)
# THE AUTHOR OPENED THE RETUNED VOICE'S Sing() on 2026-09-27: "the retuned
# voice is somehow singing, open Sing()". This scene said "shut" until then;
# it now holds the OPEN gate to the same bar the voice was measured by.
oS3 = StzSoundRetunedVoiceQ()
if oS3.IsUsable()
	oSung3 = oS3.Sing("la la la", "c4 e4 g4")
	Chk("the retuned voice's verdict is SINGING, by name, and its Sing() now SINGS",
	    Mu5Get(Mu5Get(aVer, :retuned), :verdict) = "SINGING" and
	    substr(Mu5Get(Mu5Get(aVer, :retuned), :by), "Mansour Ayouni") > 0 and isObject(oSung3))
	nWs = 0
	aNs = [ 261.6256, 329.6276, 391.9954 ]
	for k = 1 to 3
		nAt = floor(((k - 1) * 60 / 90 + 0.35) * 48000)
		nG = StzEngineSoundMeasurePitch(oSung3.BufferId(), nAt, aNs[k], 0)
		nC = fabs(1200 * log(nG / aNs[k]) / log(2))
		if nC > nWs  nWs = nC ok
	next
	? "   Sing(" + char(34) + "la la la" + char(34) + ", " + char(34) + "c4 e4 g4" + char(34) +
	  "): three notes, the worst " + nWs + " cents from its note (with a 20-cent vibrato)"
	Chk("and what it sings is ON the notes it was given: each within 20 cents", nWs < 20)
	Chk("the formant voice's gate stays SHUT -- its verdict is its own, and still unheard",
	    Mu5Get(Mu5Get(aVer, :formant), :verdict) = "UNPERCEIVED")
else
	nSkip++
	? "  [skip] no SAPI voice -- the retuned voice cannot sing here: " + oS3.LastError()
ok
Chk("and the author's words on SAPI's timbre are recorded in the verdict, by name",
    substr(Mu5Get(Mu5Get(aVer, :retuned), :timbre), "very close from real human voice") > 0)
Chk("and its reason carries the SAPI measurement, so (a) is not tried again blind",
    substr(oS2.LastError(), "407 cents") > 0)
Chk("the formant voice names its vowels in a syllable: la -> a, sky -> i, rhythm -> i",
    oS2._FirstVowel("la") = "a" and oS2._FirstVowel("sky") = "i" and oS2._FirstVowel("rhythm") = "i")

? ""
? "-- Scene 6: refusals --"
oR2 = StzSoundFormantVoiceQ()
Chk("a vowel that is not one is refused", isNull(oR2.Vowel("y", 220, 1)))
Chk("a pitch below a bass's is refused, with the engine's reason",
    isNull(oR2.Vowel("a", 50, 1)) and substr(lower(oR2.LastError()), "range") > 0)
oR2.SetBreath(2)
Chk("a breath above 1 is refused", oR2.Refusals() >= 3)

? ""
? "-- The listener's line --"
? "   (a) SAPI's pitch control: measured, and it cannot hold a note."
? "   (a') SAPI's voice, retuned: holds its notes, and the author HEARD it sing:"
? "        'the retuned voice is somehow singing' -- Sing() is open (2026-09-27)."
? "   (b) the formant voice: on its pitch, its vowels the table's; whether it is"
? "       a voice is still the author's -- UNPERCEIVED, and its Sing() shut."

? ""
? "" + nPass + " passed, " + nFail + " failed, " + nSkip + " skipped"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers --------------------------------------------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func PadN nV, nW
	_s_ = "" + nV
	while len(_s_) < nW  _s_ = " " + _s_ end
	return _s_

func Mu5Get aL, cK
	for _p_ in aL
		if lower("" + _p_[1]) = lower(cK)  return _p_[2] ok
	next
	return ""

func Mu5Ssml c
	_q_ = char(34)
	return "<speak version=" + _q_ + "1.0" + _q_ + " xmlns=" + _q_ + "http://www.w3.org/2001/10/synthesis" +
	       _q_ + " xml:lang=" + _q_ + "en-US" + _q_ + ">" + c + "</speak>"

# every 50 ms, the harmonic pitch reader; only readings in a voice's range
func Mu5Reads oS
	_a_ = []
	if NOT isObject(oS)  return _a_ ok
	_m_ = oS.ToMonoQ()
	_n_ = _m_.Frames()
	_step_ = floor(_m_.SampleRate() / 20)
	for _f_ = 1 to _n_ - 4096 step _step_
		_v_ = StzEngineSoundMeasurePitch(_m_.BufferId(), _f_, 170, 0)
		if _v_ > 60 and _v_ < 600  _a_ + _v_ ok
	next
	return _a_

func Mu5MedianOf aA
	if len(aA) = 0  return 1 ok
	_b_ = sort(aA)
	return _b_[floor((len(_b_) + 1) / 2)]

func Mu5SpreadOf aA
	if len(aA) < 2  return 0 ok
	_b_ = sort(aA)
	return 1200 * log(_b_[len(_b_)] / _b_[1]) / log(2)

# the amplitude of each harmonic k*f0, k = 1..nK, by a DFT over 0.2 s from 0.3 s
func Mu5Harmonics oS, nF0, nK
	_aH_ = []
	_from_ = floor(0.3 * nRate)
	_n_ = floor(0.2 * nRate)
	_x_ = list(_n_)
	for _i_ = 1 to _n_  _x_[_i_] = oS.SampleAt(_from_ + _i_, 1) next
	for _k_ = 1 to nK
		_w_ = 2 * 3.14159265358979 * _k_ * nF0 / nRate
		_re_ = 0
		_im_ = 0
		for _i_ = 1 to _n_
			_re_ += _x_[_i_] * cos(_w_ * _i_)
			_im_ += _x_[_i_] * sin(_w_ * _i_)
		next
		_aH_ + sqrt(_re_ * _re_ + _im_ * _im_) * _k_    # * k: pre-emphasis, +6 dB per octave
	next
	return _aH_

func Mu5LoudestIn aH, nF0, nLo, nHi
	_best_ = 0
	_at_ = 0
	for _k_ = 1 to len(aH)
		_f_ = _k_ * nF0
		if _f_ >= nLo and _f_ <= nHi and aH[_k_] > _best_
			_best_ = aH[_k_]
			_at_ = _f_
		ok
	next
	return _at_
