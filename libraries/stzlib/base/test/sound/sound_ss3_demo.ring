# SS3 -- DUCKING, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_ss3_demo.ring
#
# The guard proves the ramp does not click, on the waveform, with a control
# for the control. Only listening tells you whether a duck SOUNDS like getting
# out of the way rather than like a fault -- and that judgement is not one a
# number can make.
#
# WHAT TO LISTEN FOR, in order:
#
#   1  a steady bed, alone
#   2  the same bed with a DANGER over it: the bed drops -12 dB and comes back
#   3  the same moment with the ramp set to ZERO: the click the guard measures
#   4  a duck to SILENCE, which is why -12 dB is the default
#   5  the policy: danger ducks everything, success ducks nothing
#
# Scene 3 is deliberately unpleasant. It is the sound the kill criterion exists
# to prevent, and hearing it once is the argument for the ramp.

load "../../stzBase.ring"

pr()
decimals(2)

? "=================================================================="
? " SS3 -- ducking: quieter, not gone, and never with a click"
? "=================================================================="
? ""

if NOT (StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1)
	? "No output device on this machine. The guard needs none for the"
	? "kill criterion -- run sound_ss3_narrated.ring."
	bye
ok

nRate = 48000

# ---------------------------------------------------------------------------
# The bed: a continuous tone, standing in for whatever a program has playing
# when an alert arrives. Rendered ONCE and reused, so every scene is the same
# sound and only the ducking differs.

? "Building a steady bed and the four cues."
oBed = StzSoundOfSilenceQ(4.0, 1, nRate)
for i = 1 to oBed.Frames()
	oBed.SetSampleAt(i, 1, 0.30 * sin(2 * 3.14159265 * 330 * i / nRate))
next

oE = new stzEarcons()
oCue = oE.ToSoundOf(:Danger)
? "   bed: " + oBed.Duration() + " s at 330 Hz, peak " + oBed.Peak()
? "   danger cue: " + oCue.Duration() + " s, peak " + oCue.Peak()
? ""

# ---------------------------------------------------------------------------
? "-- 1 -- the bed alone, so you know what unducked sounds like --"
Hear(Mix1(oBed, "", nRate, 0, 0), nRate)
sleep(0.6)

# ---------------------------------------------------------------------------
? ""
? "-- 2 -- a DANGER over it, ducked -12 dB on a 10 ms ramp --"
? "   The cue is not louder. The bed got out of the way, which is the whole"
? "   difference between an alert that cuts through and one that shouts."
Hear(Mix1(oBed, oCue, nRate, 0.2512, 10), nRate)
sleep(0.6)

# ---------------------------------------------------------------------------
? ""
? "-- 3 -- THE SAME MOMENT WITH NO RAMP. This is the click. --"
? "   The guard measures it at 0.3744 against the tone's own 0.0288 slope --"
? "   thirteen times the signal's steepest step. Here is what that is."
? "   (deliberately unpleasant: it is the sound the criterion prevents)"
Hear(Mix1(oBed, oCue, nRate, 0.2512, 0), nRate)
sleep(0.8)

# ---------------------------------------------------------------------------
? ""
? "-- 4 -- ducked to SILENCE, which is why -12 dB is the default --"
? "   A duck this deep is indistinguishable from the bed being DROPPED, and"
? "   the plane already has dropping. -12 dB leaves it audibly present, so a"
? "   listener can tell 'quieter' from 'gone' -- which is information."
Hear(Mix1(oBed, oCue, nRate, 0.0, 10), nRate)
sleep(0.6)

# ---------------------------------------------------------------------------
? ""
? "-- 5 -- the policy, live: quieter in meaning gets out of the way --"
? "   Now through stzEarcons itself, with its real buses. Four cues fire in"
? "   turn. Watch the gains: a DANGER ducks everything below it, a SUCCESS"
? "   ducks nothing, because priority is one-way."
? ""

oP = new stzEarcons()
oP.Start()
if NOT oP.IsStarted()
	? "   the pool would not start: " + oP.LastError()
else
	_aCV176_ = [ "Success", "Info", "Warning", "Danger" ]
	_nCV176_ = len(_aCV176_)
	for _iCV176_ = 1 to _nCV176_
		cV = _aCV176_[_iCV176_]
		oP.Unduck()
		sleep(0.3)
		oP.Fire(cV)
		sleep(0.7)
		? "   fired " + cV + ":  danger=" + oP.GainOf(:Danger) +
		  "  warning=" + oP.GainOf(:Warning) +
		  "  info=" + oP.GainOf(:Info) +
		  "  success=" + oP.GainOf(:Success)
	next
	? ""
	? "   ducks applied: " + oP.DucksApplied() + " (counted, like every other"
	? "   thing this plane does behind a listener's back)"
	oP.Stop()
ok
oP.Release()

? ""
? "=================================================================="
? " If scene 2 sounded like the bed making room and scene 3 sounded like"
? " a fault, the ramp is doing its job and the criterion was worth having."
? "=================================================================="

# ---- helpers --------------------------------------------------------------

# One buffer: the bed, with a cue laid over it at 1.0 s and the bed attenuated
# under it. The attenuation is applied HERE rather than by a graph, so the
# ramp length is exactly what is being demonstrated and nothing else varies.
func Mix1 poBed, poCue, nRate, nDuckGain, nRampMs
	_out_ = StzSoundOfSilenceQ(poBed.Duration(), 1, nRate)
	_at_ = floor(1.0 * nRate)
	_dur_ = 0
	if isObject(poCue)  _dur_ = poCue.Frames() ok
	_hold_ = _at_ + _dur_ + floor(0.35 * nRate)     # stay ducked a little after
	_ramp_ = floor(nRampMs * nRate / 1000)
	if _ramp_ < 1  _ramp_ = 1 ok

	for _i_ = 1 to poBed.Frames()
		_g_ = 1.0
		if isObject(poCue)
			if _i_ >= _at_ and _i_ < _at_ + _ramp_
				# down
				_t_ = (_i_ - _at_) / _ramp_
				_g_ = 1.0 + (nDuckGain - 1.0) * _t_
			but _i_ >= _at_ + _ramp_ and _i_ < _hold_
				_g_ = nDuckGain
			but _i_ >= _hold_ and _i_ < _hold_ + _ramp_
				# and back up, on the same ramp -- restoring with a jump would
				# click exactly as ducking with one does
				_t_ = (_i_ - _hold_) / _ramp_
				_g_ = nDuckGain + (1.0 - nDuckGain) * _t_
			ok
		ok
		_out_.SetSampleAt(_i_, 1, poBed.SampleAt(_i_, 1) * _g_)
	next

	if isObject(poCue)
		for _i_ = 1 to poCue.Frames()
			_d_ = _at_ + _i_
			if _d_ > _out_.Frames()  exit ok
			_out_.SetSampleAt(_d_, 1,
			                  _out_.SampleAt(_d_, 1) + poCue.SampleAt(_i_, 1))
		next
	ok
	return _out_

func Hear poSound, nRate
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, nRate)
	_g_.AddSound(poSound)
	_t_ = new stzSoundTransport(_g_)
	_t_.PlayFor(poSound.Duration() + 0.15)
	while NOT _t_.IsStopped()
		_t_.Tick()
		sleep(0.02)
	end
	_t_.Release()
	_g_.Release()
