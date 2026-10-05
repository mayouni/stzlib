# MU0 -- THE MEASUREMENTS THE MUSIC PLAN NEEDS BEFORE IT IS BELIEVED.
# See SOFTANZA_MUSIC_PLAN.md section 6, MU0, and its STATUS section.
#
# Four spikes, no faces. Each was written with its kill criterion BEFORE its
# number was taken, and each carries a CONTROL FOR THE CONTROL -- SS3's lesson,
# where the click instrument "passed" twice before it had measured a click.
#
#   1  can an oscillator change pitch on a 10 ms ramp without a click?
#   2  a trigger lands at the next block start: how much jitter is that, and
#      what does a person hear?  (the perception half is the demo's)
#   3  does a thirty-line Karplus-Strong sound like a string?  (the author's)
#   4  is a quarter tone 50 cents, to within 2?
#
# NO DEVICE NEEDED. Every spike renders offline; the demo beside this file is
# where the author listens, and CENTRAL-PERCEPTGATE-01 says that half is not
# optional -- it is simply not this file's.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(4)

? "== MU0: four measurements, taken before anything is built on them =="
? ""

nRate = 48000
nBlock = 512

# ---------------------------------------------------------------------------
? "-- Spike 1: a frequency ramp does not click --"
? "   The instrument is NOT SS3's. A gain step is an amplitude discontinuity"
? "   and the first difference sees it. A frequency change with continuous"
? "   PHASE has no amplitude step at all -- the first difference sees nothing"
? "   whether the change is ramped or not -- so the instrument here is the"
? "   SECOND difference, which sees a kink in the slope. A control for the"
? "   control proves that first: the same change with NO ramp must read as a"
? "   kink, or the instrument is blind and every number after it is decoration."

nHzA = 440
nHzB = 880
nAmp = 0.5
# the second difference of a sine of amplitude A at frequency f is bounded by
# A * (2*pi*f/rate)^2 -- derived, not measured, so the yardstick cannot drift
nBound = nAmp * pow(2 * 3.14159265358979 * nHzB / nRate, 2)
? "   the 880 Hz tone's own largest second difference: " + nBound

nNone = WorstKink(nHzA, nHzB, -1, 16)
? "   no change at all  : worst kink " + nNone + "   <- the instrument's own noise"
Chk("the instrument is quiet on an unchanged tone", nNone <= nBound * 1.05)

nJump = WorstKink(nHzA, nHzB, 0, 16)
? "   jump, no ramp     : worst kink " + nJump
Chk("an UNRAMPED frequency change is a kink the instrument sees -- the control works",
    nJump > nBound * 1.5)

nRamped = WorstKink(nHzA, nHzB, 10, 16)
? "   10 ms ramp        : worst kink " + nRamped
? "   the jump is " + (nJump / nRamped) + "x the ramped kink"
Chk("a 10 ms ramp does NOT kink beyond the tone's own curvature",
    nRamped <= nBound * 1.05)
Chk("and it is dramatically smaller than the jump", nRamped < nJump / 2)

# it ARRIVES, and it MOVES through the middle -- the two halves of a ramp
oGr = MakeOscGraph(nHzA, nAmp)
oW = oGr.ToSound(nBlock * 4 / nRate)
StzEngineSoundGraphSetFrequency(oGr.GraphId(), oGr.NodeNamed(:osc), nHzB, 200)
oMid = oGr.ToSound(nBlock * 8 / nRate)          # 85 ms into a 200 ms ramp
nMid = StzEngineSoundGraphCurrentFrequency(oGr.GraphId(), oGr.NodeNamed(:osc))
? "   85 ms into a 200 ms ramp the oscillator reads " + nMid + " Hz"
Chk("it has LEFT 440", nMid > 445)
Chk("and has not yet REACHED 880", nMid < 875)
oRest = oGr.ToSound(0.3)
nEnd = StzEngineSoundGraphCurrentFrequency(oGr.GraphId(), oGr.NodeNamed(:osc))
? "   and afterwards: " + nEnd + " Hz"
Chk("then it ARRIVES exactly", fabs(nEnd - nHzB) < 0.001)
oW.Release()  oMid.Release()  oRest.Release()  oGr.Release()

# refusals: the plane's law that a setting which silently does nothing is
# worse than one that says no
oGr2 = MakeOscGraph(nHzA, nAmp)
Chk("a frequency above Nyquist is REFUSED",
    StzEngineSoundGraphSetFrequency(oGr2.GraphId(), oGr2.NodeNamed(:osc), 30000, 0) != 0)
Chk("and so is setting it on a node that is not an oscillator",
    StzEngineSoundGraphSetFrequency(oGr2.GraphId(), oGr2.NodeNamed(:bus), 440, 0) != 0)
oGr2.Release()
? ""
? "   VERDICT on spike 1: the ramp is click-free at 10 ms. Portamento and"
? "   vibrato are IN, and with them the imzad, the goge and the kalangu."

# ---------------------------------------------------------------------------
? ""
? "-- Spike 2: a trigger lands at the next block start -- how late, exactly --"
? "   Twenty notes at 120 BPM, each fired the way the plane fires everything:"
? "   a request that the render honours at the START of its next block. The"
? "   ideal onset is on the beat; the measured onset is whatever block edge"
? "   came next. SN5's onset detector hops by 512 frames -- its resolution IS"
? "   the error being measured -- so the instrument here reads the first frame"
? "   above threshold after silence, which is exact to the sample."

nBeats = 20
nBpm = 120
nBeatFrames = floor(60 / nBpm * nRate)          # 24000
oG2 = new stzSoundGraph()
oG2.Reshape(1, nRate)
oG2.AddOscillator(:Sine, 1000, 0.5)
oG2.NameIt(:tone)
oG2.AddEnvelopeOn(:tone, 0.001, 0.04, 0.0, 0.02, 0.05)
oG2.NameIt(:env)
oG2.SetOutputTo(:env)
oG2.Prepare()
oSpend = oG2.ToSound(0.5)                        # spend the envelope first
oSpend.Release()

nTotal = nBeats * nBeatFrames + nRate
oGrid = StzSoundOfSilenceQ(nTotal / nRate, 1, nRate)
nAt = 0
nNextBeat = nRate                                # first beat one second in
nBeat = 0
aIdeal = []
while nAt + nBlock <= nTotal
	# THE MECHANISM UNDER TEST. The Ring thread asks at the beat; the render
	# honours the request at the start of the NEXT block it renders. Offline
	# that is: fire at the first block edge at or after the beat. The first cut
	# of this loop also fired when the beat fell INSIDE the coming block -- at
	# that block's start, EARLY -- and reported a negative mean lateness, which
	# no request-then-honour path can produce. It measured the simulation.
	if nBeat < nBeats and nAt >= nNextBeat
		StzEngineSoundGraphTriggerNode(oG2.GraphId(), oG2.NodeNamed(:env))
		aIdeal + nNextBeat
		nBeat++
		nNextBeat += nBeatFrames
	ok
	oB = oG2.ToSound(nBlock / nRate)
	Blit(oGrid, oB, nAt)
	oB.Release()
	nAt += nBlock
end
oG2.Release()

aOnsets = OnsetsOf(oGrid, 0.05, nRate)
? "   notes fired " + len(aIdeal) + ", onsets found " + len(aOnsets)
Chk("every note produced exactly one onset", len(aOnsets) = len(aIdeal))
nMax = 0
nSum = 0
for i = 1 to len(aOnsets)
	if i > len(aIdeal)  exit ok
	d = (aOnsets[i] - aIdeal[i]) / nRate * 1000
	if d > nMax  nMax = d ok
	nSum += d
next
nMean = nSum / len(aOnsets)
? "   late by: mean " + nMean + " ms, worst " + nMax + " ms   (one block is " +
  (nBlock / nRate * 1000) + " ms)"
Chk("no onset is EARLY -- a request is never honoured before it is made", nMax >= 0)
Chk("the worst lateness is within one block", nMax <= nBlock / nRate * 1000 + 0.05)
Chk("and it is real, not zero -- the grid IS quantised", nMax > 1.0)
oGrid.SaveAs("mu0_grid_quantised.wav")
? "   written mu0_grid_quantised.wav -- the demo plays it beside a sample-exact"
? "   version, and whether " + nMax + " ms reads as swing is the author's call"
oGrid.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Spike 3: a thirty-line pluck --"
? "   The number this file can take is the pitch; the verdict it cannot take"
? "   is whether it sounds like a string. That is the demo's, and the author's."

nBuf = StzEngineSoundPluckOf(220, nRate, 1.5, 0.996)
Chk("the seam rendered a pluck", nBuf != 0)
oPluck = StzSoundFromBufferQ(nBuf)
? "   " + oPluck.Duration() + " s, peak " + oPluck.Peak()
Chk("it is 1.5 s long", fabs(oPluck.Duration() - 1.5) < 0.001)
nEarly = PeakBetween(oPluck, 1, 4800)
nLate = PeakBetween(oPluck, oPluck.Frames() - 4800, oPluck.Frames())
? "   first 100 ms peak " + nEarly + ", last 100 ms peak " + nLate
Chk("it starts loud", nEarly > 0.3)
Chk("and DECAYS, as a string does", nLate < nEarly * 0.2)

# THE PITCH, and the finding that came with it: the averaging is half a
# sample of delay, so the line is chosen for N + 0.5 = rate/hz. What remains
# is the integer quantisation, up to half a sample -- measured here so MU1
# knows what the fractional delay it owes has to remove.
nPeriod = PeriodByAutocorrelation(oPluck, 12000, 36000, 180, 260)
nHzGot = nRate / nPeriod
nCents = 1200 * log(nHzGot / 220) / log(2)
? "   autocorrelation period " + nPeriod + " frames = " + nHzGot + " Hz, " +
  nCents + " cents from A3"
Chk("the pluck is within 10 cents of the pitch asked for (integer period)",
    fabs(nCents) <= 10)
? "   (THE INSTRUMENT'S OWN RESOLUTION, stated: an integer autocorrelation lag"
? "    at ~218 frames is 7.9 cents wide, so this reading is known to +/-8 cents"
? "    -- the same size as the integer-period error it was meant to measure. A"
? "    first cut of this line printed a +1.4-cent PREDICTION beside a +9.4-cent"
? "    MEASUREMENT; the prediction is gone. MU1 owes both a fractional delay for"
? "    the line and a finer pitch instrument to prove it, because the plan's"
? "    bar is 2 cents and nothing in this spike can see 2 cents on a pluck.)"

# a period that cannot fit is refused rather than aliased
Chk("a pitch too low for the line is REFUSED", StzEngineSoundPluckOf(5, nRate, 0.1, 0.996) = 0)
oPluck.SaveAs("mu0_pluck.wav")
? "   written mu0_pluck.wav"
oPluck.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Spike 4: a quarter tone is fifty cents --"
? "   D4 and D4 plus one step of 24-TET, rendered by the same oscillator the"
? "   plane uses for everything. The FFT is the coarse cross-check and its"
? "   resolution is REPORTED: 48000/8192 = 5.86 Hz per bin, which at 293 Hz is"
? "   34 cents -- an instrument that cannot answer a 2-cent question. The fine"
? "   instrument is the period over the whole buffer, read off zero crossings"
? "   of a pure sine, where one sample in 96000 is 0.02 cents."

nD4 = 440 * pow(2, -7/12)                        # 293.665 Hz
nQ  = nD4 * pow(2, 1/24)                         # one quarter step up
? "   asked for: " + nD4 + " Hz and " + nQ + " Hz"

oA = RenderTone(nD4, 2.0)
oB = RenderTone(nQ, 2.0)
nFa = PitchByCrossings(oA, nRate)
nFb = PitchByCrossings(oB, nRate)
nCa = 1200 * log(nFa / nD4) / log(2)
nCb = 1200 * log(nFb / nQ) / log(2)
nGap = 1200 * log(nFb / nFa) / log(2)
? "   measured : " + nFa + " Hz (" + nCa + " cents off) and " + nFb + " Hz (" +
  nCb + " cents off)"
? "   the step between them: " + nGap + " cents"
Chk("D4 is within 2 cents of D4", fabs(nCa) <= 2)
Chk("the quarter tone is within 2 cents of its target", fabs(nCb) <= 2)
Chk("and the step between them is 50 +/- 2 cents", fabs(nGap - 50) <= 2)

nFftA = oA.DominantFrequency()
? "   the FFT says " + nFftA + " Hz for D4 -- " + (1200 * log(nFftA / nD4) / log(2)) +
  " cents off, inside its own 34-cent bin"
Chk("the coarse instrument agrees to within its own resolution",
    fabs(1200 * log(nFftA / nD4) / log(2)) <= 34)

# the negative sibling: a semitone is NOT fifty cents, or the gap test proves nothing
oC = RenderTone(nD4 * pow(2, 1/12), 2.0)
nGapSemi = 1200 * log(PitchByCrossings(oC, nRate) / nFa) / log(2)
? "   a semitone, same instrument: " + nGapSemi + " cents"
Chk("a semitone reads as 100, so the 50 above was measured and not assumed",
    fabs(nGapSemi - 100) <= 2)

oQt = StzSoundOfSilenceQ(4.5, 1, nRate)
Blit(oQt, oA, 0)
Blit(oQt, oB, floor(2.25 * nRate))
oQt.SaveAs("mu0_quartertone.wav")
? "   written mu0_quartertone.wav"
oA.Release()  oB.Release()  oC.Release()  oQt.Release()

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

func MakeOscGraph nHz, nAmp
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, nRate)
	_g_.AddOscillator(:Sine, nHz, nAmp)
	_g_.NameIt(:osc)
	_g_.AddGainOn(:osc, 1.0)
	_g_.NameIt(:bus)
	_g_.SetOutputTo(:bus)
	_g_.Prepare()
	return _g_

# Render up to a block edge, change the frequency there, render on, and take
# the largest SECOND difference across the seam and the ramp. Block-aligned
# renders, phase swept over sixteen offsets: SS3's discipline, with SS3's
# instrument replaced because a phase-continuous frequency change has no
# first-difference step to see. nRampMs = -1 means change nothing.
func WorstKink nHzA, nHzB, nRampMs, nPhases
	_worst_ = 0
	for _k_ = 0 to nPhases - 1
		_g_ = MakeOscGraph(nHzA, nAmp)
		_warm_ = _g_.ToSound((4 + _k_) * nBlock / nRate)
		if nRampMs >= 0
			StzEngineSoundGraphSetFrequency(_g_.GraphId(), _g_.NodeNamed(:osc), nHzB, nRampMs)
		ok
		_cut_ = _g_.ToSound(8 * nBlock / nRate)
		# stitch the last two of warm onto cut so the seam's second
		# difference is computable
		_n_ = _warm_.Frames()
		_p2_ = _warm_.SampleAt(_n_ - 1, 1)
		_p1_ = _warm_.SampleAt(_n_, 1)
		for _i_ = 1 to _cut_.Frames()
			_x_ = _cut_.SampleAt(_i_, 1)
			_d2_ = fabs(_x_ - 2 * _p1_ + _p2_)
			if _d2_ > _worst_  _worst_ = _d2_ ok
			_p2_ = _p1_
			_p1_ = _x_
		next
		_warm_.Release()  _cut_.Release()  _g_.Release()
	next
	return _worst_

func RenderTone nHz, nSecs
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, nRate)
	_g_.AddOscillator(:Sine, nHz, 0.5)
	_g_.NameIt(:t)
	_g_.SetOutputTo(:t)
	_g_.Prepare()
	_s_ = _g_.ToSound(nSecs)
	_g_.Release()
	return _s_

# The period of a pure sine from its rising zero crossings, using the FIRST
# and LAST crossing and the count between: one sample of error over the whole
# buffer, which at 2 s is 0.02 cents.
func PitchByCrossings poSound, nRate
	_first_ = 0
	_last_ = 0
	_count_ = 0
	for _i_ = 2 to poSound.Frames()
		if poSound.SampleAt(_i_ - 1, 1) < 0 and poSound.SampleAt(_i_, 1) >= 0
			if _first_ = 0
				_first_ = _i_
			else
				_last_ = _i_
				_count_++
			ok
		ok
	next
	if _count_ = 0  return 0 ok
	return nRate * _count_ / (_last_ - _first_)

func PeriodByAutocorrelation poSound, nFrom, nTo, nLagLo, nLagHi
	_best_ = -999999999999
	_lag_ = nLagLo
	for _L_ = nLagLo to nLagHi
		_acc_ = 0
		for _i_ = nFrom to nTo
			_acc_ += poSound.SampleAt(_i_, 1) * poSound.SampleAt(_i_ + _L_, 1)
		next
		if _acc_ > _best_
			_best_ = _acc_
			_lag_ = _L_
		ok
	next
	return _lag_

func OnsetsOf poSound, nThresh, nRate
	_a_ = []
	_quiet_ = TRUE
	_since_ = 0
	for _i_ = 1 to poSound.Frames()
		_v_ = fabs(poSound.SampleAt(_i_, 1))
		if _quiet_ and _v_ > nThresh
			_a_ + (_i_ - 1)
			_quiet_ = FALSE
			_since_ = 0
		but NOT _quiet_
			if _v_ < nThresh * 0.2
				_since_++
				if _since_ > nRate * 0.02  _quiet_ = TRUE ok
			else
				_since_ = 0
			ok
		ok
	next
	return _a_

func PeakBetween poSound, nFrom, nTo
	_p_ = 0
	if nFrom < 1  nFrom = 1 ok
	if nTo > poSound.Frames()  nTo = poSound.Frames() ok
	for _i_ = nFrom to nTo
		_v_ = fabs(poSound.SampleAt(_i_, 1))
		if _v_ > _p_  _p_ = _v_ ok
	next
	return _p_

func Blit poDest, poSrc, nAt
	_max_ = poDest.Frames()
	for _i_ = 1 to poSrc.Frames()
		_d_ = nAt + _i_
		if _d_ > _max_  exit ok
		poDest.SetSampleAt(_d_, 1, poSrc.SampleAt(_i_, 1))
	next
