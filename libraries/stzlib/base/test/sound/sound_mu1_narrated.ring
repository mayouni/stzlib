# MU1 -- PITCH AND THE INSTRUMENT. See SOFTANZA_MUSIC_PLAN.md, MU1 and its STATUS.
#
# Twenty instruments on five engines, each note an ordinary stzSound.
#
# WHAT THIS GUARD CAN SETTLE, AND WHAT IT CANNOT. It can settle that every
# instrument renders, that every pitched one is in tune to the plan's 2-cent bar
# at the bottom, middle and top of its range, that the engines are physically
# DISTINCT rather than twenty names on one sound, that a drum's pitch can move,
# and that a sample can be played at another pitch. It cannot settle whether the
# oud sounds like an oud. That is the author's, by CENTRAL-PERCEPTGATE-01, and the
# last scene says so for all twenty.
#
# THE TUNER CANNOT BE ITS OWN WITNESS. Every string, bow and wind instrument tunes
# itself by measuring its own pitch, and a guard that checked the result with the
# SAME instrument would only prove the tuner converged. So Scene 4 re-measures
# three of them -- one per engine family -- with an instrument that shares no code
# with the engine: an eight-pole lowpass and timed zero crossings, in Ring.
#
# NO DEVICE NEEDED. Everything renders offline.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(3)
nRate = 48000

? "== MU1: twenty instruments, in tune, distinct, and honest about their names =="
? ""

# ---------------------------------------------------------------------------
? "-- Scene 1: the instruments exist, in the plan's order --"

aNames = StzInstruments()
? "   " + len(aNames) + ": " + Joined(aNames)
Chk("there are twenty", len(aNames) = 20)
Chk("in the plan's order: general, then Tunisia, then Niger",
    aNames[1] = "piano" and aNames[13] = "mezwed" and aNames[17] = "kakaki" and
    aNames[20] = "kalangu")

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: the pitch instruments, checked before anything is measured with them --"
? "   MU0 owed a finer instrument: an integer-lag autocorrelation at 218 frames"
? "   is 7.9 cents wide. This one refines the peak to a fraction of a sample, is"
? "   octave-guarded, and has a spectral sibling for sounds that are not harmonic."

oSine = RenderTone(293.6648, 1.0)
nH = StzEngineSoundMeasurePitch(oSine.BufferId(), 1001, 293.6648, 0)
nS = StzEngineSoundMeasurePitch(oSine.BufferId(), 1001, 293.6648, 1)
? "   a pure 293.6648 Hz sine reads " + nH + " (harmonic) and " + nS + " (spectral)"
Chk("the harmonic instrument reads a sine to a hundredth of a cent",
    fabs(Cents(nH, 293.6648)) < 0.01)
Chk("the spectral instrument to a tenth", fabs(Cents(nS, 293.6648)) < 0.1)
# THE NEGATIVE SIBLING, and it was a real defect before it was a test: a sine
# repeats at twice its period, so asked about the octave below it the first
# version found a flawless peak and answered with the wrong octave
Chk("asked about the octave BELOW a note, it REFUSES rather than answer",
    StzEngineSoundMeasurePitch(RenderTone(440, 1.0).BufferId(), 1001, 220, 0) = 0)
oSine.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: the fractional delay, against MU0's integer line --"
? "   The same A4, plucked by MU0's thirty-line spike and by MU1's guitar, read"
? "   by the same fine instrument."

nOld = StzEngineSoundPluckOf(440, nRate, 1.2, 0.996)
nOldHz = StzEngineSoundMeasurePitch(nOld, 12001, 440, 0)
oG = StzInstrumentQ(:Guitar)
oNew = oG.ToSoundOf(440, 1.2)
nNewHz = StzEngineSoundMeasurePitch(oNew.BufferId(), 12001, 440, 0)
? "   MU0 integer line: " + Cents(nOldHz, 440) + " cents     MU1 guitar: " +
  Cents(nNewHz, 440) + " cents"
Chk("MU0's integer line was out by more than the 2-cent bar -- the reason for MU1",
    fabs(Cents(nOldHz, 440)) > 2)
Chk("MU1's allpass puts A4 inside it", fabs(Cents(nNewHz, 440)) <= 2)
StzEngineSoundFree(nOld)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: every instrument renders, and every pitched one is in tune --"
? "   Low, middle and high of each instrument's range. Harmonic instruments by"
? "   the harmonic instrument, averaged over sixteen readings when the pitch"
? "   wanders (vibrato, or breath); bars, bells and drums by the spectral one,"
? "   on their lowest mode."
? ""
? "   instrument     engine    raw c   tuned c  |  cents: low     mid     high"

nBadPitch = 0
nBadRender = 0
for i = 1 to 20
	oI = StzInstrumentQ(aNames[i])
	aR = oI.Range()
	nLo = aR[1] * 1.2
	nHi = aR[2] * 0.8
	aHz = [ nLo, sqrt(nLo * nHi), nHi ]
	cClass = oI.PitchClass()
	aC = []
	nRaw = 0
	nTun = 0
	for j = 1 to 3
		nHz = aHz[j]
		if oI.Engine() = "membrane" and cClass = "none"
			nHz = 150
			if aNames[i] = "drumkit"  nHz = 55 ok
		ok
		oN = oI.ToSoundOf(nHz, 1.2)
		if NOT isObject(oN)
			nBadRender++
			aC + 9999
			loop
		ok
		if j = 2
			nRaw = oI.RawCents()
			nTun = oI.TuningCents()
		ok
		nPk = oN.Peak()
		if nPk < 0.3 or nPk > 1.0  nBadRender++ ok
		if cClass = "none"
			aC + 0
		but cClass = "inharmonic"
			aC + Cents(StzEngineSoundMeasurePitch(oN.BufferId(), 481, nHz, 1), nHz)
		else
			aC + Cents(ReadCentre(oN, nHz, Wanders(aNames[i])), nHz)
		ok
		oN.Release()
	next
	cRow = "   " + Pad(aNames[i], 14) + Pad(oI.Engine(), 9) + PadN(nRaw, 8) + PadN(nTun, 9) + "  | "
	if cClass = "none"
		cRow += "  (unpitched: renders, peak checked)"
	else
		for j = 1 to 3
			cRow += PadN(aC[j], 8)
			if fabs(aC[j]) > 2  nBadPitch++ ok
		next
	ok
	? cRow
next
? ""
Chk("all twenty render, every note peaks between 0.3 and 1.0", nBadRender = 0)
Chk("every pitched instrument is within 2 cents at low, middle and high", nBadPitch = 0)
? "   raw c is the UNTUNED model's error. The kakaki's lip model starts about"
? "   2.5 semitones flat and the jet about a third of a semitone sharp: that is"
? "   what the self-tuning is for, and why the waveguides report it."

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: the tuner is not its own witness --"
? "   Three notes, one per engine family, re-measured with an instrument that"
? "   shares no code with the engine: an eight-pole lowpass, then the time"
? "   between the first and last rising zero crossing across 0.7 s, each"
? "   crossing located between samples. The zokra, not the mezwed: the mezwed's"
? "   two chanters BEAT, and a beat null flips the phase and adds a crossing."

aX = [ [ "guitar", 303.6 ], [ "zokra", 480 ], [ "imzad", 379.5 ] ]
for k = 1 to len(aX)
	oN = StzInstrumentQ(aX[k][1]).ToSoundOf(aX[k][2], 1.2)
	nZ = PitchByLowpassCrossings(oN, aX[k][2], 0.3, 1.0)
	? "   " + Pad(aX[k][1], 8) + " asked " + aX[k][2] + " Hz, independently measured " +
	  nZ + " Hz = " + Cents(nZ, aX[k][2]) + " cents"
	Chk(aX[k][1] + " is in tune by an instrument that shares no code with the tuner",
	    fabs(Cents(nZ, aX[k][2])) <= 2)
	oN.Release()
next

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: the engines are DISTINCT, by their physics --"
? "   Twenty names on one sound would pass every scene above. These cannot."

# a cylinder closed at the reed supports only odd harmonics; a cone supports all
oMz = StzInstrumentQ(:Mezwed).ToSoundOf(330, 1.2)
oZk = StzInstrumentQ(:Zokra).ToSoundOf(330, 1.2)
nMz = Harmonic(oMz, 660) / Harmonic(oMz, 990)
nZk = Harmonic(oZk, 660) / Harmonic(oZk, 990)
? "   2nd / 3rd harmonic: mezwed (single reed, cylinder) " + nMz +
  "   zokra (double reed, cone) " + nZk
Chk("the cylinder suppresses its even harmonics -- H2 below half of H3", nMz < 0.5)
# THE FIRST VERSION OF THIS ASSERTION FAILED, AND IT WAS THE ASSERTION THAT WAS
# WRONG. It read "the cone does not -- H2 above H3", written before any number
# was taken, and the zokra measured H2/H3 = 0.178. But a cone PERMITS even
# harmonics; it does not promise the second outweighs the third, and nothing in
# bore physics says it does. What the physics says is the contrast, and the
# contrast is large: the cone carries twelve times the cylinder's even content.
# The threshold below -- five times -- was set AFTER that measurement, and is
# said so here rather than presented as a prediction.
? "   the cone's even content is " + (nZk / nMz) + " times the cylinder's"
Chk("the cone does not suppress them -- five times the cylinder's even content",
    nZk > 5 * nMz)

# a bow sustains; a pluck decays
oIm = StzInstrumentQ(:Imzad).ToSoundOf(330, 1.2)
oGt = StzInstrumentQ(:Guitar).ToSoundOf(330, 1.2)
nImS = RmsBetween(oIm, 0.9, 1.0) / RmsBetween(oIm, 0.3, 0.4)
nGtS = RmsBetween(oGt, 0.9, 1.0) / RmsBetween(oGt, 0.3, 0.4)
? "   loudness at 0.9 s over 0.3 s: imzad (bowed) " + nImS + "   guitar (plucked) " + nGtS
Chk("the bow SUSTAINS the note", nImS > 0.7)
Chk("the pluck DECAYS it", nGtS < 0.5)

# where a drum is struck decides which modes speak
oDb = StzInstrumentQ(:Darbouka)
oDum = oDb.ToSoundOfStroke(:Dum, 150, 0.5)
oTak = oDb.ToSoundOfStroke(:Tak, 150, 0.5)
nDum = Harmonic(oDum, 150) / Harmonic(oDum, 150 * 2.136)
nTak = Harmonic(oTak, 150) / Harmonic(oTak, 150 * 2.136)
? "   fundamental / mode (2,1): dum (centre) " + nDum + "   tak (rim) " + nTak
Chk("DUM, struck at the centre, is led by the fundamental", nDum > 1)
Chk("TAK, struck at the rim, is led by the upper mode", nTak < 1)

# the bendir's snares buzz; the darbouka has none
oBd = StzInstrumentQ(:Bendir).ToSoundOf(150, 0.5)
nBz = Harmonic(oBd, 2500) / Harmonic(oBd, 150)
nNo = Harmonic(oDum, 2500) / Harmonic(oDum, 150)
? "   2.5 kHz over fundamental: bendir " + nBz + "   darbouka " + nNo
Chk("the bendir BUZZES where the darbouka does not -- five times the high band", nBz > 5 * nNo)
oMz.Release()  oZk.Release()  oIm.Release()  oGt.Release()
oDum.Release()  oTak.Release()  oBd.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 7: a pitch that moves -- the kalangu, and the bow --"
? "   The talking drum is squeezed from 150 to 220 Hz over 0.8 s. Its pitch is"
? "   read early and late, each against where the glide should be at the"
? "   middle of that window -- a glide is not a note, and the tolerance is 30"
? "   cents, stated here before it was measured."

oK = StzInstrumentQ(:Kalangu).ToSoundOfGlide(150, 220, 0.8)
nWin = 16384 / nRate
nE = StzEngineSoundMeasurePitch(oK.BufferId(), 1, 150 * pow(220 / 150, (nWin / 2) / 0.8), 1)
nEx = 150 * pow(220 / 150, (nWin / 2) / 0.8)
nLateAt = floor((0.8 - nWin) * nRate) + 1
nL = StzEngineSoundMeasurePitch(oK.BufferId(), nLateAt, 150 * pow(220 / 150, (0.8 - nWin / 2) / 0.8), 1)
nLx = 150 * pow(220 / 150, (0.8 - nWin / 2) / 0.8)
? "   early window: expected " + nEx + ", read " + nE + "   late: expected " + nLx + ", read " + nL
Chk("the early window is where the glide should be", fabs(Cents(nE, nEx)) <= 30)
Chk("and so is the late one", fabs(Cents(nL, nLx)) <= 30)
# THE FIRST VERSION ASKED FOR A RISE OF MORE THAN 400 CENTS, AND THAT WAS MY
# ARITHMETIC, NOT THE DRUM. The whole glide is 663 cents, but the two windows
# are centred 0.46 s apart, so the curve itself rises only ~380 cents between
# them -- the assertion demanded more than the design produces. It now asks for
# the design's own number, to the same 30 cents as the windows.
nRise = Cents(nLx, nEx)
? "   the glide should rise " + nRise + " cents between the window centres; it rose " +
  Cents(nL, nE)
Chk("and the pitch ROSE by the glide's own amount between them, to 30 cents",
    fabs(Cents(nL, nE) - nRise) <= 30)
oK.Release()

oP = StzInstrumentQ(:Guitar)
nR0 = oP.Refusals()
oBad = oP.ToSoundOfGlide(200, 300, 0.5)
Chk("a plucked string REFUSES to glide -- it holds one pitch", NOT isObject(oBad) and oP.Refusals() > nR0)
? "   " + oP.LastError()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 8: a sample played at another pitch -- how a recording becomes an instrument --"

oA = StzInstrumentQ(:Guitar).ToSoundOf(220, 1.4)
nFifth = pow(2, 7 / 12)
oGr = new stzSoundGraph()
oGr.Reshape(1, nRate)
oGr.AddSound(oA)
oGr.NameIt(:src)
oGr.SetOutputTo(:src)
oGr.Prepare()
Chk("the rate is accepted",
    StzEngineSoundGraphSetRate(oGr.GraphId(), oGr.NodeNamed(:src), nFifth) = 0)
oUp = oGr.ToSound(0.7)
nUp = StzEngineSoundMeasurePitch(oUp.BufferId(), 4801, 220 * nFifth, 0)
? "   a 220 Hz note played at 2^(7/12) reads " + nUp + " Hz, " + Cents(nUp, 220 * nFifth) +
  " cents from the fifth above"
Chk("the sample sounds a fifth higher, to 2 cents", fabs(Cents(nUp, 220 * nFifth)) <= 2)
Chk("a rate of 0 is REFUSED",
    StzEngineSoundGraphSetRate(oGr.GraphId(), oGr.NodeNamed(:src), 0) != 0)
oUp.Release()  oGr.Release()

# THE OLD PATH IS UNTOUCHED: a source at rate 1 renders bit-identically to one
# whose rate was never set, which is what every guard before MU1 relies on
oG1 = SourceGraph(oA)
oG2 = SourceGraph(oA)
StzEngineSoundGraphSetRate(oG2.GraphId(), oG2.NodeNamed(:src), 1)
o1 = oG1.ToSound(0.2)
o2 = oG2.ToSound(0.2)
nDiff = 0
for f = 1 to o1.Frames()
	if o1.SampleAt(f, 1) != o2.SampleAt(f, 1)  nDiff++ ok
next
Chk("rate 1 is bit-identical to a rate never set -- " + nDiff + " samples differ", nDiff = 0)
o1.Release()  o2.Release()  oG1.Release()  oG2.Release()  oA.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 9: note names, and the refusals --"

Chk("A4 is 440", fabs(StzNoteToHz("A4") - 440) < 0.0001)
Chk("C4 is 261.626", fabs(StzNoteToHz("C4") - 261.6256) < 0.001)
Chk("D4+50 is a quarter tone above D4",
    fabs(Cents(StzNoteToHz("D4+50"), StzNoteToHz("D4")) - 50) < 0.0001)
Chk("Bb3 and A#3 are the same pitch", fabs(StzNoteToHz("Bb3") - StzNoteToHz("A#3")) < 0.0001)
Chk("'H4', 'A' and 'A4+x' are refused, not guessed",
    StzNoteToHz("H4") = 0 and StzNoteToHz("A") = 0 and StzNoteToHz("A4+x") = 0)

oU = StzInstrumentQ(:Theremin)
Chk("an unknown instrument is refused", NOT oU.IsUsable() and oU.Refusals() = 1)
? "   " + oU.LastError()
oO = StzInstrumentQ(:Oud)
Chk("a pitch outside the oud's range is refused", NOT isObject(oO.ToSoundOf(5000, 0.5)))
Chk("a stroke on a plucked string is refused", NOT isObject(oO.ToSoundOfStroke(:Tak, 200, 0.5)))
oD2 = StzInstrumentQ(:Darbouka)
Chk("a stroke the drum does not have is refused", NOT isObject(oD2.ToSoundOfStroke(:Slap, 150, 0.5)))
nV0 = oO.Refusals()
oO.SetVelocity(1.5)
Chk("a velocity above 1 is refused, and counted", oO.Refusals() > nV0 and oO.Velocity() = 0.8)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 10: the listener's line --"
? "   Every name above is PROVISIONAL. MU1's kill criterion: an instrument that"
? "   does not sound like its name to the author ships under a name that does"
? "   not lie -- and the fallback was written into the engine BEFORE anyone"
? "   listened:"
? ""
cLine = "   "
for i = 1 to 20
	oI = StzInstrumentQ(aNames[i])
	cLine += aNames[i] + " -> " + oI.HonestName()
	if i < 20  cLine += ",  " ok
	if i % 4 = 0
		? cLine
		cLine = "   "
	ok
next
? ""
? "   UNPERCEIVED, all twenty, as of this writing. sound_mu1_demo.ring plays"
? "   each; the STATUS records the author's verdict by name, instrument by"
? "   instrument, or keeps this word."

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed"
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

func Cents nA, nB
	if nA <= 0 or nB <= 0  return 9999 ok
	return 1200 * log(nA / nB) / log(2)

func Joined paList
	_s_ = ""
	for _i_ = 1 to len(paList)
		if _i_ > 1  _s_ += ", " ok
		_s_ += "" + paList[_i_]
	next
	return _s_

func Pad cS, nW
	_s_ = "" + cS
	while len(_s_) < nW  _s_ += " " end
	return _s_

func PadN nV, nW
	_s_ = "" + nV
	while len(_s_) < nW  _s_ = " " + _s_ end
	return _s_

func Wanders cName
	return cName = "flute" or cName = "sarewa" or cName = "imzad"

# The centre of a note, read the way the plan's bar is defined: one reading
# from 0.25 s for a steady pitch; sixteen, 50 ms apart, averaged in cents, for
# a pitch that wanders on purpose.
func ReadCentre poN, nHz, bWanders
	if NOT bWanders
		return StzEngineSoundMeasurePitch(poN.BufferId(), 12001, nHz, 0)
	ok
	_acc_ = 0
	_got_ = 0
	for _k_ = 0 to 15
		_v_ = StzEngineSoundMeasurePitch(poN.BufferId(), 12001 + _k_ * 2400, nHz, 0)
		if _v_ > 0
			_acc_ += log(_v_ / nHz) / log(2)
			_got_++
		ok
	next
	if _got_ < 12  return 0 ok
	return nHz * pow(2, _acc_ / _got_)

func RenderTone nHz, nSecs
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, nRate)
	_g_.AddOscillator(:Sine, nHz, 0.5)
	_g_.NameIt(:t)
	_g_.SetOutputTo(:t)
	_g_.Prepare()
	return _g_.ToSound(nSecs)

func SourceGraph poSound
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, nRate)
	_g_.AddSound(poSound)
	_g_.NameIt(:src)
	_g_.SetOutputTo(:src)
	_g_.Prepare()
	return _g_

# THE INDEPENDENT INSTRUMENT. Eight one-pole lowpasses at 1.2x the expected
# pitch leave the fundamental and bury the harmonics (the second is down to
# 4% relative); then the first and last RISING zero crossing in the span, each
# located between samples by linear interpolation, and the count between them.
# Nothing here calls the engine except to read samples.
func PitchByLowpassCrossings poN, nHz, nFrom, nTo
	_a_ = exp(-2 * 3.14159265358979 * nHz * 1.2 / nRate)
	_y_ = list(8)
	for _p_ = 1 to 8  _y_[_p_] = 0 next
	_f0_ = floor(nFrom * nRate)
	_f1_ = floor(nTo * nRate)
	_prev_ = 0
	_first_ = 0
	_last_ = 0
	_count_ = 0
	for _f_ = 1 to _f1_
		_x_ = poN.SampleAt(_f_, 1)
		for _p_ = 1 to 8
			_y_[_p_] = (1 - _a_) * _x_ + _a_ * _y_[_p_]
			_x_ = _y_[_p_]
		next
		if _f_ > _f0_ and _prev_ < 0 and _x_ >= 0
			_t_ = (_f_ - 1) + (-_prev_) / (_x_ - _prev_)
			if _first_ = 0
				_first_ = _t_
			else
				_last_ = _t_
				_count_++
			ok
		ok
		_prev_ = _x_
	next
	if _count_ = 0  return 0 ok
	return nRate * _count_ / (_last_ - _first_)

# The magnitude of one frequency, by Goertzel's recurrence over a Hann window
# from 0.05 s: no trigonometry per sample, and it answers for exactly the
# frequency asked rather than for the bin it falls in.
func Harmonic poN, nHz
	_n_ = 16384
	if poN.Frames() < 2400 + _n_  _n_ = poN.Frames() - 2400 ok
	_w_ = 2 * 3.14159265358979 * nHz / nRate
	_c_ = 2 * cos(_w_)
	_s1_ = 0
	_s2_ = 0
	for _i_ = 0 to _n_ - 1
		_h_ = 0.5 - 0.5 * cos(2 * 3.14159265358979 * _i_ / (_n_ - 1))
		_s0_ = _h_ * poN.SampleAt(2400 + _i_ + 1, 1) + _c_ * _s1_ - _s2_
		_s2_ = _s1_
		_s1_ = _s0_
	next
	return sqrt(_s1_ * _s1_ + _s2_ * _s2_ - _c_ * _s1_ * _s2_)

func RmsBetween poN, nA, nB
	_f0_ = floor(nA * nRate) + 1
	_f1_ = floor(nB * nRate)
	_acc_ = 0
	for _f_ = _f0_ to _f1_
		_v_ = poN.SampleAt(_f_, 1)
		_acc_ += _v_ * _v_
	next
	return sqrt(_acc_ / (_f1_ - _f0_ + 1))
