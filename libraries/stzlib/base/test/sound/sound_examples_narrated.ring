# WORKED EXAMPLES -- and every one of them is also a guard.
#
# This file has two jobs and does them with the same lines. It is the place to
# LOOK to learn how the sound plane is used, and it is the place that FAILS if
# the plane stops behaving. Examples that are not run rot; guards that are not
# readable teach nothing. These are both.
#
# The examples deliberately combine things the phase guards test in isolation:
# a chord is three oscillators through one mix, a bell is an envelope feeding a
# delay, a fade-in is a control ramp on a live device. Combinations are where
# integration bugs live.
#
# Everything except the last example runs with NO sound card.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0

RATE = 48000

cTmp = currentdir() + "/temp"
if NOT direxists(cTmp)
	system("mkdir " + '"' + cTmp + '"')
ok

pr()
decimals(6)

? "== HOW SOUND WORKS -- six worked examples that are also assertions =="

if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load"
	? ""
	? "0 passed, 1 failed"
	bye
ok

# ===========================================================================
? ""
? "--- EXAMPLE 1: make a tone and write it to a file --------------------"
? ""
? "    oG = StzEngineSoundGraphNew(1, 48000, 512)      # mono, 48 kHz"
? "    nTone = StzEngineSoundGraphAddOsc(oG, SINE, 440, 0.8)"
? "    StzEngineSoundGraphSetOutput(oG, nTone)"
? "    StzEngineSoundGraphPrepare(oG)"
? "    StzEngineSoundGraphToFile(oG, 48000, 'tone.wav', 16)"
? ""

nG1 = StzEngineSoundGraphNew(1, RATE, 512)
nTone = StzEngineSoundGraphAddOsc(nG1, StzSoundWaveSine(), 440, 0.8)
StzEngineSoundGraphSetOutput(nG1, nTone)
StzEngineSoundGraphPrepare(nG1)
cTone = cTmp + "/tone.wav"
Chk("one second of 440 Hz is written", StzEngineSoundGraphToFile(nG1, RATE, cTone, 16) = 0)

# read it back and look at it -- this is how you inspect any sound
nS1 = StzEngineSoundLoadFile(cTone)
? "    duration " + StzEngineSoundDuration(nS1) + " s, " +
  StzEngineSoundRate(nS1) + " Hz, " + StzEngineSoundChannels(nS1) + " channel"
? "    peak " + StzEngineSoundPeak(nS1) + ", rms " + StzEngineSoundRms(nS1)
Chk("it is exactly one second", fabs(StzEngineSoundDuration(nS1) - 1.0) < 0.001)
Chk("it kept its sample rate", StzEngineSoundRate(nS1) = RATE)
Chk("the peak is the amplitude we asked for", fabs(StzEngineSoundPeak(nS1) - 0.8) < 0.01)
# a sine's RMS is its peak / sqrt(2) -- a real property, not a vibe
Chk("and its RMS is peak/sqrt(2), as a sine's must be",
    fabs(StzEngineSoundRms(nS1) - 0.8 / sqrt(2)) < 0.01)
StzEngineSoundFree(nS1)
StzEngineSoundGraphFree(nG1)

# ===========================================================================
? ""
? "--- EXAMPLE 2: a chord -- three oscillators through one mix ----------"
? ""
? "    nA = AddOsc(oG, SINE, 440.00, 0.3)     # A4"
? "    nB = AddOsc(oG, SINE, 554.37, 0.3)     # C#5"
? "    nC = AddOsc(oG, SINE, 659.25, 0.3)     # E5"
? "    nMix = AddMix(oG)"
? "    MixAdd(oG, nMix, nA)  /  nB  /  nC"
? ""

nG2 = StzEngineSoundGraphNew(1, RATE, 512)
nA = StzEngineSoundGraphAddOsc(nG2, StzSoundWaveSine(), 440.00, 0.3)
nB = StzEngineSoundGraphAddOsc(nG2, StzSoundWaveSine(), 554.37, 0.3)
nC = StzEngineSoundGraphAddOsc(nG2, StzSoundWaveSine(), 659.25, 0.3)
nMix = StzEngineSoundGraphAddMix(nG2)
StzEngineSoundGraphMixAdd(nG2, nMix, nA)
StzEngineSoundGraphMixAdd(nG2, nMix, nB)
StzEngineSoundGraphMixAdd(nG2, nMix, nC)
StzEngineSoundGraphSetOutput(nG2, nMix)
StzEngineSoundGraphPrepare(nG2)
nChord = StzEngineSoundGraphToBuffer(nG2, RATE / 2)

# EVERY oscillator starts at phase 0, so at the very first sample all three
# are exactly 0 -- and a moment later they are NOT in step. That is what
# makes this a chord rather than one louder note.
? "    first sample (all three at phase 0): " + StzEngineSoundGet(nChord, 1, 1)
? "    peak of the chord: " + StzEngineSoundPeak(nChord) + "   rms: " + StzEngineSoundRms(nChord)
Chk("all three start together at zero", fabs(StzEngineSoundGet(nChord, 1, 1)) < 0.000001)
Chk("the chord is louder than one note alone", StzEngineSoundPeak(nChord) > 0.3)
Chk("but never louder than all three summed", StzEngineSoundPeak(nChord) <= 0.9 + 0.000001)

# WHY THE PEAK GETS SO CLOSE TO THE SUM, and it is the interesting part:
# 440 : 554.37 : 659.25 is almost exactly 4 : 5 : 6. Near-integer ratios means
# the three waves nearly RE-ALIGN every few cycles, so the peaks nearly add.
# That near-alignment IS consonance -- it is why this chord sounds restful and
# why 440 : 466 : 493 would not. (An earlier version of this example asserted
# the opposite, that different pitches must drift apart. They do; these three
# just come back together, which is the whole point of a major triad.)
Chk("a 4:5:6 chord nearly re-aligns -- that near-alignment IS consonance",
    StzEngineSoundPeak(nChord) > 0.85)

# and the RMS tells the other half of the story: energy adds like sqrt(N) for
# tones that are not locked together, not like N
nOneRms = 0.3 / sqrt(2)
? "    one note's rms would be " + nOneRms + "; three together: " + StzEngineSoundRms(nChord)
Chk("energy grows like sqrt(3), not 3 -- these are three tones, not one louder one",
    StzEngineSoundRms(nChord) > nOneRms * 1.4 and StzEngineSoundRms(nChord) < nOneRms * 2.0)
StzEngineSoundFree(nChord)
StzEngineSoundGraphFree(nG2)

# ===========================================================================
? ""
? "--- EXAMPLE 3: a bell -- oscillator, envelope, then an echo ----------"
? ""
? "    nOsc = AddOsc(oG, SINE, 880, 0.9)"
? "    nEnv = AddEnvelope(oG, nOsc, 0.005, 0.30, 0.0, 0.05, 0.30)"
? "                          attack decay sustain release gate"
? "    nEcho = AddDelay(oG, nEnv, 0.25, 0.45, 0.5)"
? "                          time  feedback wet"
? ""

nG3 = StzEngineSoundGraphNew(1, RATE, 512)
nOsc3 = StzEngineSoundGraphAddOsc(nG3, StzSoundWaveSine(), 880, 0.9)
nEnv3 = StzEngineSoundGraphAddEnvelope(nG3, nOsc3, 0.005, 0.30, 0.0, 0.05, 0.30)
nEcho3 = StzEngineSoundGraphAddDelay(nG3, nEnv3, 0.25, 0.45, 0.5)
StzEngineSoundGraphSetOutput(nG3, nEcho3)
StzEngineSoundGraphPrepare(nG3)
nBell = StzEngineSoundGraphToBuffer(nG3, RATE * 2)

# the shape of a bell, measured in four windows
nAtStart = WindowPeak(nBell, 1, 100)                 # the attack, still rising
nAtHit = WindowPeak(nBell, 200, 2000)                # the strike
nAfterNote = WindowPeak(nBell, RATE * 0.5, RATE * 0.6)  # note over, echo alive
nAtEnd = WindowPeak(nBell, RATE * 1.9, RATE * 2)     # everything decayed
? "    attack window " + nAtStart + " -> strike " + nAtHit
? "    after the note ends, the ECHO is still there: " + nAfterNote
? "    and by 1.9 s it has decayed to: " + nAtEnd
Chk("the attack starts quietly, not instantly", nAtStart < nAtHit)
Chk("the strike is loud", nAtHit > 0.3)
Chk("the note is over but the ECHO still sounds", nAfterNote > 0.01)
Chk("the echo is quieter than the strike", nAfterNote < nAtHit)
Chk("and everything decays away by the end", nAtEnd < nAfterNote)
StzEngineSoundFree(nBell)
StzEngineSoundGraphFree(nG3)

# ===========================================================================
? ""
? "--- EXAMPLE 4: shaping a tone -- a lowpass at three cutoffs ----------"
? ""
? "    nSaw = AddOsc(oG, SAW, 220, 0.7)      # a saw is rich in harmonics"
? "    nLpf = AddFilter(oG, nSaw, LOWPASS, cutoff, 0.707)"
? ""

nRms300 = SawThroughLowpass(300)
nRms2000 = SawThroughLowpass(2000)
nRms12000 = SawThroughLowpass(12000)
? "    cutoff   300 Hz -> rms " + nRms300
? "    cutoff  2000 Hz -> rms " + nRms2000
? "    cutoff 12000 Hz -> rms " + nRms12000
# a saw at 220 Hz has harmonics all the way up; opening the filter lets more
# of them through, so the energy must rise MONOTONICALLY with the cutoff
Chk("opening the filter lets more energy through (300 < 2000)", nRms300 < nRms2000)
Chk("and more again (2000 < 12000)", nRms2000 < nRms12000)
Chk("a nearly-closed filter still passes the fundamental", nRms300 > 0.01)

# ===========================================================================
? ""
? "--- EXAMPLE 5: stereo -- putting a sound in a place ------------------"
? ""
? "    oG = GraphNew(2, 48000, 512)          # TWO channels now"
? "    nPan = AddPan(oG, nOsc, 0.0)          # 0 = left, 0.5 = centre, 1 = right"
? ""

aLeft = PanEnergy(0.0)
aCentre = PanEnergy(0.5)
aRight = PanEnergy(1.0)
? "    pan 0.0 (left)   -> L " + aLeft[1] + "  R " + aLeft[2]
? "    pan 0.5 (centre) -> L " + aCentre[1] + "  R " + aCentre[2]
? "    pan 1.0 (right)  -> L " + aRight[1] + "  R " + aRight[2]
Chk("hard left puts the sound in the left channel", aLeft[1] > 0.5 and aLeft[2] < 0.001)
Chk("hard right puts it in the right", aRight[2] > 0.5 and aRight[1] < 0.001)
Chk("centre splits it evenly", fabs(aCentre[1] - aCentre[2]) < 0.001)
# CONSTANT POWER: centre is 1/sqrt(2) per side, NOT half. A linear pan law
# would read 0.5 here and audibly dip in the middle of a sweep.
Chk("and centre is 0.707 per side, not 0.5 -- the law is constant POWER",
    fabs(aCentre[1] - 0.7071) < 0.01)

# ===========================================================================
? ""
? "--- EXAMPLE 6: preparing a sound for delivery ------------------------"
? ""
? "    nCd = StzEngineSoundResample(nSrc, 44100, SINC)   # 48k -> 44.1k"
? "    nMono = StzEngineSoundToChannels(nCd, 1)          # stereo -> mono"
? ""

nG6 = StzEngineSoundGraphNew(2, RATE, 512)
nO6 = StzEngineSoundGraphAddOsc(nG6, StzSoundWaveSine(), 1000, 0.6)
nP6 = StzEngineSoundGraphAddPan(nG6, nO6, 0.5)
StzEngineSoundGraphSetOutput(nG6, nP6)
StzEngineSoundGraphPrepare(nG6)
nSrc6 = StzEngineSoundGraphToBuffer(nG6, RATE)

nCd = StzEngineSoundResample(nSrc6, 44100, StzSoundQualitySinc())
nMono = StzEngineSoundToChannels(nCd, 1)
? "    source: " + StzEngineSoundRate(nSrc6) + " Hz, " + StzEngineSoundChannels(nSrc6) + " ch, " + StzEngineSoundDuration(nSrc6) + " s"
? "    result: " + StzEngineSoundRate(nMono) + " Hz, " + StzEngineSoundChannels(nMono) + " ch, " + StzEngineSoundDuration(nMono) + " s"
Chk("the rate changed", StzEngineSoundRate(nCd) = 44100)
Chk("the channel count changed", StzEngineSoundChannels(nMono) = 1)
Chk("the DURATION did not -- that is the whole point of resampling",
    fabs(StzEngineSoundDuration(nMono) - StzEngineSoundDuration(nSrc6)) < 0.001)
Chk("and the sound is still there, at the same level",
    fabs(StzEngineSoundRms(nMono) - StzEngineSoundRms(nSrc6)) < 0.02)
Chk("the ORIGINAL was not touched by either conversion", StzEngineSoundRate(nSrc6) = RATE)

cOut6 = cTmp + "/for_cd.wav"
Chk("and it saves as a 16-bit WAV", StzEngineSoundSaveWav(nMono, cOut6, 16) = 0)
StzEngineSoundFree(nSrc6)
StzEngineSoundFree(nCd)
StzEngineSoundFree(nMono)
StzEngineSoundGraphFree(nG6)

# ===========================================================================
? ""
? "--- EXAMPLE 7: playing it out loud, with a fade-in -------------------"
? ""
? "    nStream = StzEngineSoundStreamStart(oG, 8192)     # producer thread"
? "    nDev = StzEngineAudioDevPlaybackOpen(RingPtr(nStream), 256)"
? "    StzEngineAudioDevPlaybackStart(nDev)"
? "    StzEngineSoundGraphSetGain(oG, nGain, 1.0, 400)   # fade in over 400 ms"
? ""

if NOT StzAudioDevEngineLoaded() or StzEngineAudioDevIsAvailable() = 0
	nSkip++
	? "  [skip] no audio device -- every example above still ran"
else
	nG7 = StzEngineSoundGraphNew(2, RATE, 256)
	nO7 = StzEngineSoundGraphAddOsc(nG7, StzSoundWaveTriangle(), 330, 0.25)
	nGain7 = StzEngineSoundGraphAddGain(nG7, nO7, 0.0)   # start SILENT
	StzEngineSoundGraphSetOutput(nG7, nGain7)
	StzEngineSoundGraphPrepare(nG7)

	nStream7 = StzEngineSoundStreamStart(nG7, 8192)
	sleep(0.1)
	nDev7 = StzEngineAudioDevPlaybackOpen(StzEngineSoundStreamRingPtr(nStream7), 256)
	Chk("the device opens on the stream", nDev7 != 0)
	if nDev7 != 0
		StzEngineAudioDevPlaybackStart(nDev7)
		Chk("it starts silent", StzEngineSoundGraphCurrentGain(nG7, nGain7) = 0)
		StzEngineSoundGraphSetGain(nG7, nGain7, 1.0, 400)   # fade in
		sleep(0.9)
		Chk("the fade completed while it was playing",
		    fabs(StzEngineSoundGraphCurrentGain(nG7, nGain7) - 1.0) < 0.001)
		StzEngineSoundGraphSetGain(nG7, nGain7, 0.0, 300)   # and back out
		sleep(0.6)
		Chk("and it faded back out", StzEngineSoundGraphCurrentGain(nG7, nGain7) < 0.001)
		StzEngineAudioDevPlaybackStop(nDev7)
		? "    played " + StzEngineAudioDevPlaybackFramesOut(nDev7) + " frames, " +
		  "worst callback " + StzEngineAudioDevPlaybackWorstUs(nDev7) + " us"
		Chk("nothing underran through the whole fade", StzEngineSoundStreamUnderruns(nStream7) = 0)
		StzEngineAudioDevPlaybackClose(nDev7)
	ok
	StzEngineSoundStreamStop(nStream7)
	StzEngineSoundGraphFree(nG7)
ok

# ===========================================================================
? ""
? "" + nPass + " passed, " + nFail + " failed, " + nSkip + " skipped"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers (below the main body) ----------------------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func WindowPeak nId, nFrom, nTo
	_mx_ = 0
	for _i_ = nFrom to nTo
		_v_ = fabs(StzEngineSoundGet(nId, _i_, 1))
		if _v_ > _mx_
			_mx_ = _v_
		ok
	next
	return _mx_

func SawThroughLowpass nCutoff
	_g_ = StzEngineSoundGraphNew(1, RATE, 512)
	_o_ = StzEngineSoundGraphAddOsc(_g_, StzSoundWaveSaw(), 220, 0.7)
	_f_ = StzEngineSoundGraphAddFilter(_g_, _o_, StzSoundFilterLowPass(), nCutoff, 0.707)
	StzEngineSoundGraphSetOutput(_g_, _f_)
	StzEngineSoundGraphPrepare(_g_)
	_b_ = StzEngineSoundGraphToBuffer(_g_, RATE / 4)
	_r_ = StzEngineSoundRms(_b_)
	StzEngineSoundFree(_b_)
	StzEngineSoundGraphFree(_g_)
	return _r_

# Returns [left rms, right rms] for a mono tone placed at nPan.
func PanEnergy nPan
	_g_ = StzEngineSoundGraphNew(2, RATE, 512)
	_o_ = StzEngineSoundGraphAddOsc(_g_, StzSoundWaveSine(), 440, 1.0)
	_p_ = StzEngineSoundGraphAddPan(_g_, _o_, nPan)
	StzEngineSoundGraphSetOutput(_g_, _p_)
	StzEngineSoundGraphPrepare(_g_)
	_b_ = StzEngineSoundGraphToBuffer(_g_, RATE / 8)
	_n_ = StzEngineSoundFrames(_b_)
	_sl_ = 0
	_sr_ = 0
	for _i_ = 1 to _n_
		_l_ = StzEngineSoundGet(_b_, _i_, 1)
		_rr_ = StzEngineSoundGet(_b_, _i_, 2)
		_sl_ += _l_ * _l_
		_sr_ += _rr_ * _rr_
	next
	StzEngineSoundFree(_b_)
	StzEngineSoundGraphFree(_g_)
	# rms per side, scaled so a full-scale sine reads 1.0 rather than 0.707 --
	# it is the LEFT/RIGHT comparison that matters here, not the absolute
	return [sqrt(_sl_ / _n_) * sqrt(2), sqrt(_sr_ / _n_) * sqrt(2)]
