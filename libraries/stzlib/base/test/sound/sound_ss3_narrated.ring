# SS3 -- PRIORITY AND DUCKING. See SOFTANZA_SOUND_PLAN.md §S.3 and §S.8.
#
# §S.3 decided the priority contract and deliberately did NOT build this half:
# attenuating a lower-priority voice needs a per-bus gain node, and adding a
# node was on the far side of that session's boundary. This is that node, and
# the policy that drives it.
#
# DUCK OR DROP, and the plane already does one of them. A cue displaced by
# something louder in meaning is DROPPED -- a cue arriving after its event lies
# about when it happened. Ducking is the other half: a cue that is ALREADY
# SOUNDING cannot be un-sounded, so it is turned DOWN while the alert speaks
# over it.
#
# SS3'S KILL CRITERION, quoted so a later reader sees what was at stake:
# *if ducking cannot be made click-free at the 10 ms ramp SN3 measured, it is
# dropped in favour of drop-and-count -- a missing sound is better than a
# click, and plate 2 of the insight gallery shows why.*
#
# Scene 1 IS that criterion, measured on the waveform. A click is a step
# discontinuity, and a step is visible as a sample-to-sample jump far larger
# than the signal's own slope. The negative control -- the same change with NO
# ramp -- is what makes the number mean something.
#
# NO DEVICE NEEDED except Scene 4: a gain ramp is arithmetic on rendered
# samples, so the criterion can be settled on a machine that cannot play.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0

pr()
decimals(4)

? "== ducking: quieter, not gone, and never with a click =="
? ""

# ---------------------------------------------------------------------------
? "-- Scene 1: THE KILL CRITERION -- a 10 ms ramp does not click --"
? "   A steady 440 Hz tone through a gain node. Its own steepest"
? "   sample-to-sample slope is the yardstick: any gain change that jumps"
? "   produces a delta far larger, and that delta IS the click."

nRate = 48000
nHz = 440
nAmp = 0.5

# the signal's own steepest step, from first principles rather than measured,
# so the yardstick cannot drift with the measurement
nOwnSlope = nAmp * 2 * 3.14159265 * nHz / nRate
? "   the tone's own steepest step: " + nOwnSlope

# THE MEASUREMENT HAD TO BE FIXED TWICE BEFORE IT MEANT ANYTHING, and both
# ways it was wrong are worth keeping, because either one would have "proved"
# ducking click-free without looking at a click.
#
# FIRST WRONG: set the gain BETWEEN two renders, then look for the click
# INSIDE the second buffer. With no ramp the whole second buffer is uniformly
# quieter, so its steepest step is SMALLER than the original tone's -- the
# control passed by being quiet. The discontinuity is exactly at the SEAM,
# the one place that was not being looked at.
#
# SECOND WRONG: look at the seam, and find a step of 0.810 -- with NO GAIN
# CHANGE AT ALL. ToSound renders in whole BLOCKS of 512 frames and returns the
# seconds asked for, so a length that is not a multiple of the block leaves
# the oscillator further along than the buffer shows. The seam was measuring
# discarded samples, not audio. Rendering in whole blocks makes it continuous:
# the same seam then steps 0.003.
#
# And one seam is not enough either: the size of a jump depends on WHERE IN
# THE CYCLE it lands, and at a zero crossing even an unramped change is nearly
# silent. 512 frames is 4.693 periods of this tone, so each extra block lands
# the change at a different phase, and sixteen of them sweep the cycle. The
# WORST is taken, because a real duck lands wherever it lands.

nBlock = 512
nPhases = 16

# THE CONTROL FOR THE CONTROL: no gain change at all. If this were large the
# instrument would be measuring the renderer, exactly as it was a moment ago.
nQuiet0 = WorstSeamStep(nHz, nAmp, nRate, -1, nPhases, nBlock)
? "   with NO CHANGE   : worst step " + nQuiet0 + "   <- the instrument's own noise"
Chk("an unchanged gain produces no step beyond the tone's own slope",
    nQuiet0 <= nOwnSlope * 1.05)

nJump = WorstSeamStep(nHz, nAmp, nRate, 0, nPhases, nBlock)
? "   with NO ramp     : worst step " + nJump
Chk("an unramped gain change DOES click -- the control works",
    nJump > nOwnSlope * 3)

nRamped = WorstSeamStep(nHz, nAmp, nRate, 10, nPhases, nBlock)
? "   with a 10 ms ramp: worst step " + nRamped
? "   the unramped jump is " + (nJump / nRamped) + "x the ramped step"

Chk("a 10 ms ramp does NOT click -- no step exceeds the tone's own slope",
    nRamped <= nOwnSlope * 1.05)
Chk("and it is dramatically smaller than the unramped change",
    nRamped < nJump / 3)
? ""
? "   VERDICT: the criterion is MET. Ducking ships ramped; it would have been"
? "   dropped in favour of drop-and-count if this number had gone the other way."

# --- and it ARRIVES, not merely moves -------------------------------------
oG2 = MakeGainGraph(nHz, nAmp, nRate)
oWarm2 = oG2.ToSound(0.20)
StzEngineSoundGraphSetGain(oG2.GraphId(), oG2.NodeNamed(:bus), 0.25, 10)
oCut2 = oG2.ToSound(0.20)
nAfter = StzEngineSoundGraphCurrentGain(oG2.GraphId(), oG2.NodeNamed(:bus))
? "   the gain the render is applying afterwards: " + nAfter
Chk("the ramp ARRIVES at its target rather than creeping", fabs(nAfter - 0.25) < 0.001)

# and the audio really is quieter -- a ramp that arrived at the right NUMBER
# while leaving the samples alone would pass everything above
nBefore = PeakOf(oWarm2)
nQuiet = PeakOfLast(oCut2, 0.05)
? "   peak before " + nBefore + ", peak after the ramp " + nQuiet
Chk("and the SOUND is actually attenuated, not just the number",
    nQuiet < nBefore * 0.5)

oWarm2.Release()  oCut2.Release()  oG2.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: the ramp is a RAMP -- it passes through the middle --"
? "   A gain that arrives instantly and reports the target would satisfy"
? "   every assertion above. Catching it in transit is what proves the ramp"
? "   exists rather than the bookkeeping."

oG3 = MakeGainGraph(nHz, nAmp, nRate)
oW3 = oG3.ToSound(0.05)
StzEngineSoundGraphSetGain(oG3.GraphId(), oG3.NodeNamed(:bus), 0.0, 200)
oMid = oG3.ToSound(0.05)              # 50 ms into a 200 ms ramp
nMid = StzEngineSoundGraphCurrentGain(oG3.GraphId(), oG3.NodeNamed(:bus))
? "   50 ms into a 200 ms ramp the gain reads " + nMid
Chk("it has LEFT 1.0", nMid < 0.99)
Chk("and has not yet REACHED 0.0", nMid > 0.01)
oRest = oG3.ToSound(0.20)
nEnd = StzEngineSoundGraphCurrentGain(oG3.GraphId(), oG3.NodeNamed(:bus))
? "   and after the ramp is over: " + nEnd
Chk("then it arrives", nEnd < 0.001)
oW3.Release()  oMid.Release()  oRest.Release()  oG3.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: the POLICY -- quieter in meaning gets out of the way --"
? "   Needs no device for the declarations; the buses themselves do."

oE = new stzEarcons()
Chk("ducking is on by default", oE.IsDucking())
? "   default depth: " + oE.DuckDepthDb() + " dB over " + oE.DuckRampMs() + " ms"
Chk("the default depth is an ATTENUATION", oE.DuckDepthDb() < 0)
Chk("and the default ramp is SN3's 10 ms", oE.DuckRampMs() = 10)

# -12 dB is a choice with a reason, and the reason is testable: a duck to
# silence would be indistinguishable from a DROP, and then there would be no
# point having built this.
nG = pow(10, oE.DuckDepthDb() / 20)
? "   -12 dB is a linear gain of " + nG
Chk("the ducked voice is still AUDIBLE, not silenced", nG > 0.05)
Chk("but clearly quieter", nG < 0.5)

nR0 = oE.Refusals()
oE.SetDuckDepth(6)
Chk("a POSITIVE dB is refused -- a duck is an attenuation", oE.Refusals() > nR0)
? "   " + oE.LastError()
Chk("and the depth was not changed by the refusal", oE.DuckDepthDb() < 0)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: heard -- the buses exist and only the quieter ones move --"

if StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1
	oE.Start()
	if NOT oE.IsStarted()
		Skip("the pool would not start: " + oE.LastError())
	else
		Chk("every value has its own bus", oE.GainOf(:Danger) >= 0 and
		    oE.GainOf(:Warning) >= 0 and oE.GainOf(:Info) >= 0 and
		    oE.GainOf(:Success) >= 0)
		? "   before: danger=" + oE.GainOf(:Danger) + " warning=" +
		  oE.GainOf(:Warning) + " info=" + oE.GainOf(:Info) +
		  " success=" + oE.GainOf(:Success)
		Chk("and every bus starts at unity", fabs(oE.GainOf(:Info) - 1.0) < 0.001)

		nD0 = oE.DucksApplied()
		oE.Fire(:Danger)
		sleep(0.25)
		? "   after a DANGER: danger=" + oE.GainOf(:Danger) + " warning=" +
		  oE.GainOf(:Warning) + " info=" + oE.GainOf(:Info) +
		  " success=" + oE.GainOf(:Success)
		Chk("the duck was COUNTED", oE.DucksApplied() > nD0)
		Chk("DANGER'S OWN bus is untouched -- an alert never ducks itself",
		    fabs(oE.GainOf(:Danger) - 1.0) < 0.001)
		Chk("warning was ducked", oE.GainOf(:Warning) < 0.5)
		Chk("info was ducked", oE.GainOf(:Info) < 0.5)
		Chk("success was ducked", oE.GainOf(:Success) < 0.5)

		oE.Unduck()
		sleep(0.25)
		? "   after unducking: info=" + oE.GainOf(:Info)
		Chk("and everything comes back to unity", fabs(oE.GainOf(:Info) - 1.0) < 0.01)

		# THE ASYMMETRY, and it is the whole policy: a QUIET meaning must not
		# duck a loud one. Without this the test above would pass for a
		# function that ducks everything.
		oE.Fire(:Success)
		sleep(0.25)
		? "   after a SUCCESS: danger=" + oE.GainOf(:Danger) +
		  " warning=" + oE.GainOf(:Warning)
		Chk("a SUCCESS does not duck DANGER -- priority is one-way",
		    fabs(oE.GainOf(:Danger) - 1.0) < 0.01)
		Chk("nor WARNING", fabs(oE.GainOf(:Warning) - 1.0) < 0.01)

		oE.Stop()
	ok
	oE.Release()
else
	Skip("the buses only exist once a device is open")
ok

# ---------------------------------------------------------------------------
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

func Skip cLabel
	nSkip++
	? "  [skip] " + cLabel

func MakeGainGraph nHz, nAmp, nRate
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, nRate)
	_g_.AddOscillator(:Sine, nHz, nAmp)
	_g_.NameIt(:tone)
	_g_.AddGainOn(:tone, 1.0)
	_g_.NameIt(:bus)
	_g_.SetOutputTo(:bus)
	_g_.Prepare()
	return _g_

# THE WORST SEAM. Render up to a gain change, change it, render on, and look
# at the sample pair that straddles the change -- plus everything after it,
# since a ramp spreads the change over many samples.
#
# EVERY RENDER IS A WHOLE NUMBER OF BLOCKS, or the seam is an artefact of the
# renderer rather than a property of the audio (see the note above). Passing
# nRampMs = -1 means "change nothing", which is how the instrument is checked
# against itself.
func WorstSeamStep nHz, nAmp, nRate, nRampMs, nPhases, nBlock
	_worst_ = 0
	for _k_ = 0 to nPhases - 1
		_g_ = MakeGainGraph(nHz, nAmp, nRate)
		# 512 frames is 4.693 periods of a 440 Hz tone, so each extra block
		# lands the change at a different point in the cycle
		_warm_ = _g_.ToSound((4 + _k_) * nBlock / nRate)
		if nRampMs >= 0
			StzEngineSoundGraphSetGain(_g_.GraphId(), _g_.NodeNamed(:bus),
			                           0.25, nRampMs)
		ok
		_cut_ = _g_.ToSound(8 * nBlock / nRate)
		_d_ = fabs(_cut_.SampleAt(1, 1) - _warm_.SampleAt(_warm_.Frames(), 1))
		if _d_ > _worst_  _worst_ = _d_ ok
		_d2_ = BiggestStep(_cut_)
		if _d2_ > _worst_  _worst_ = _d2_ ok
		_warm_.Release()  _cut_.Release()  _g_.Release()
	next
	return _worst_

# A CLICK IS A STEP. The biggest sample-to-sample difference in the buffer is
# therefore the instrument, and it needs no ear.
func BiggestStep poSound
	_m_ = 0
	for _i_ = 2 to poSound.Frames()
		_d_ = fabs(poSound.SampleAt(_i_, 1) - poSound.SampleAt(_i_ - 1, 1))
		if _d_ > _m_  _m_ = _d_ ok
	next
	return _m_

func PeakOf poSound
	_m_ = 0
	for _i_ = 1 to poSound.Frames()
		_v_ = fabs(poSound.SampleAt(_i_, 1))
		if _v_ > _m_  _m_ = _v_ ok
	next
	return _m_

func PeakOfLast poSound, nSecs
	_from_ = poSound.Frames() - floor(nSecs * poSound.SampleRate())
	if _from_ < 1  _from_ = 1 ok
	_m_ = 0
	for _i_ = _from_ to poSound.Frames()
		_v_ = fabs(poSound.SampleAt(_i_, 1))
		if _v_ > _m_  _m_ = _v_ ok
	next
	return _m_
