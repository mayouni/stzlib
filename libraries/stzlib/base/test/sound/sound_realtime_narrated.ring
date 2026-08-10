# The real-time tier -- SN3 of SOFTANZA_SOUND_PLAN.md.
#
# FACT 4: audio is DEADLINE-bound, and correct-but-late is WRONG. The callback
# fires on a thread the OS owns and must finish before a deadline it does not
# control, so three house habits are FORBIDDEN inside it: allocation, locks,
# and any Ring/VM call. This guard exists to prove the structure that makes
# those absences true rather than hoped for.
#
# THE ARCHITECTURE, in one line: a producer thread renders the graph into a
# lock-free ring buffer, and the audio callback only ever DRAINS that ring.
# The thread with the deadline does a bounded copy; the thread doing the work
# has no deadline at all.
#
# MOST OF THIS GUARD NEEDS NO SOUND CARD. The ring and its underrun accounting
# are exercised through a device-free drain -- the same popInterleaved the
# callback runs. Only the last scene opens a real device, and it announces
# itself as skipped when there is none, so a green run on a silent CI box
# cannot be mistaken for a green run on a loud one.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0

CS_STREAMS = 0
CS_BLOCKS = 1
CS_STALLS = 2

pr()
decimals(12)

? "== the real-time tier: producer, ring, and the deadline =="
? ""
if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load"
	? ""
	? "0 passed, 1 failed"
	bye
ok

# ---------------------------------------------------------------------------
? "-- Scene 1: a stream keeps the ring fed, and the samples arrive IN ORDER --"
? "   A sine at rate/4 is exactly 0, 1, 0, -1 forever. Anything else means the"
? "   ring lost, duplicated or reordered a frame -- which is precisely the"
? "   class of fault a lock-free buffer fails at, and silently."

nG = StzEngineSoundGraphNew(1, 48000, 64)
nOsc = StzEngineSoundGraphAddOsc(nG, StzSoundWaveSine(), 12000, 1.0)
StzEngineSoundGraphSetOutput(nG, nOsc)
Chk("the graph prepares", StzEngineSoundGraphPrepare(nG) = 0)

nS = StzEngineSoundStreamStart(nG, 4096)
Chk("the stream starts", nS != 0)
Chk("and it hands out a ring ADDRESS for the other DLL", StzEngineSoundStreamRingPtr(nS) != 0)

# give the producer a moment to get ahead, then drain
sleep(0.15)
Chk("the producer got ahead of us", StzEngineSoundStreamReadable(nS) > 0)

nBuf = StzEngineSoundNewSilent(512, 1, 48000)
nGot = StzEngineSoundStreamDrain(nS, 512, nBuf)
Chk("the drain delivered every frame asked for", nGot = 512)

aWant = [0, 1, 0, -1]
bOrder = TRUE
for i = 1 to 512
	nExpect = aWant[((i - 1) % 4) + 1]
	if fabs(StzEngineSoundGet(nBuf, i, 1) - nExpect) > 0.000001
		bOrder = FALSE
	ok
next
Chk("all 512 frames are exactly 0, 1, 0, -1 in order", bOrder)
Chk("and NOTHING underran", StzEngineSoundStreamUnderruns(nS) = 0)
StzEngineSoundFree(nBuf)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: ZERO underruns when the producer keeps up --"
? "   Sipping slower than the producer fills is the healthy case. The counter"
? "   must stay at exactly zero -- not 'low', zero."

nTotal = 0
for i = 1 to 30
	sleep(0.005)
	nTotal += StzEngineSoundStreamDrain(nS, 128, 0)
next
Chk("every sip was fully served", nTotal = 30 * 128)
Chk("sound.underruns is still EXACTLY zero", StzEngineSoundStreamUnderruns(nS) = 0)
Chk("and no underrun EVENTS were recorded either", StzEngineSoundStreamUnderrunEvents(nS) = 0)
Chk("the producer stalled on a full ring -- the healthy sign it was ahead",
    StzEngineSoundStreamCounter(CS_STALLS) > 0)
? "   producer blocks rendered: " + StzEngineSoundStreamCounter(CS_BLOCKS) +
  "   stalls (ring full): " + StzEngineSoundStreamCounter(CS_STALLS)

StzEngineSoundStreamStop(nS)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: THE NEGATIVE SIBLING -- an overloaded stream UNDERRUNS, and the"
? "   counter PROVES it. A guard that only ever sees zero underruns cannot"
? "   tell a working counter from a counter that is never incremented."

nG2 = StzEngineSoundGraphNew(1, 48000, 64)
nO2 = StzEngineSoundGraphAddOsc(nG2, StzSoundWaveSine(), 440, 0.5)
StzEngineSoundGraphSetOutput(nG2, nO2)
StzEngineSoundGraphPrepare(nG2)
nS2 = StzEngineSoundStreamStart(nG2, 256)     # a deliberately tiny ring
Chk("the overloaded stream starts", nS2 != 0)

# demand far more, far faster, than any producer could supply
nAsked = 200000
nServed = StzEngineSoundStreamDrain(nS2, nAsked, 0)
nUnder = StzEngineSoundStreamUnderruns(nS2)
? "   asked " + nAsked + " frames, served " + nServed + ", underran " + nUnder
Chk("we were served less than we asked for", nServed < nAsked)
Chk("sound.underruns MOVED", nUnder > 0)
Chk("and it counts the shortfall exactly", fabs((nAsked - nServed) - nUnder) <= 1)
Chk("underrun EVENTS were counted too", StzEngineSoundStreamUnderrunEvents(nS2) > 0)
StzEngineSoundStreamStop(nS2)
StzEngineSoundGraphFree(nG2)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: a control change is applied WITHOUT A CLICK --"
? "   Jumping a gain between two samples is a step, and a step is broadband"
? "   energy the signal never contained. The ramp spreads it over milliseconds."
? "   Both halves are measured: the ramp must remove the step AND still arrive."

nRamped = GainStep(10.0)
nInstant = GainStep(0.0)
? "   worst sample-to-sample jump, 10 ms ramp: " + nRamped
? "   worst sample-to-sample jump, no ramp:    " + nInstant
Chk("the ramped change has no step", nRamped < 0.01)
Chk("the UNRAMPED change is a full-scale step -- so the metric has teeth",
    nInstant > 0.9)
Chk("the ramp is at least 50x smoother than the step", nInstant > nRamped * 50)

# and it ARRIVES: a ramp that only approaches its target is a fade, not a ramp
nG4 = StzEngineSoundGraphNew(1, 48000, 64)
nO4 = StzEngineSoundGraphAddOsc(nG4, StzSoundWaveSquare(), 1, 1.0)
nGain4 = StzEngineSoundGraphAddGain(nG4, nO4, 1.0)
StzEngineSoundGraphSetOutput(nG4, nGain4)
StzEngineSoundGraphPrepare(nG4)
Chk("the gain starts where it was built", StzEngineSoundGraphCurrentGain(nG4, nGain4) = 1)
StzEngineSoundGraphSetGain(nG4, nGain4, 0.25, 5.0)
nTmp = StzEngineSoundGraphToBuffer(nG4, 1024)
Chk("the ramp ARRIVED at the target, not near it",
    fabs(StzEngineSoundGraphCurrentGain(nG4, nGain4) - 0.25) < 0.0001)
StzEngineSoundFree(nTmp)
StzEngineSoundGraphFree(nG4)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: a bad ring address is REFUSED, not played --"
? "   The device tier takes an ADDRESS across a DLL boundary, and Ring can type"
? "   any number at all. Alignment, magic and version are all checked before a"
? "   single sample is read through it."

if NOT StzAudioDevEngineLoaded()
	nSkip++
	? "  [skip] stz_audiodev.dll absent -- a supported configuration"
else
	Chk("a null ring address is refused", StzEngineAudioDevPlaybackOpen(0, 256) = 0)
	Chk("a nonsense ring address is refused", StzEngineAudioDevPlaybackOpen(12345, 256) = 0)
	Chk("and the refusal explains itself", len(StzEngineAudioDevLastError()) > 0)
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: REAL PLAYBACK through a real device --"
? "   The only scene that needs hardware. It plays a quiet tone for a second"
? "   and asserts the callback ran, delivered frames, and underran zero times."

if NOT StzAudioDevEngineLoaded()
	nSkip++
	? "  [skip] no device DLL"
but StzEngineAudioDevIsAvailable() = 0
	nSkip++
	? "  [skip] no audio backend on this machine -- the CI path"
else
	nG6 = StzEngineSoundGraphNew(2, 48000, 256)
	nO6 = StzEngineSoundGraphAddOsc(nG6, StzSoundWaveSine(), 440, 0.05)
	nGain6 = StzEngineSoundGraphAddGain(nG6, nO6, 1.0)
	StzEngineSoundGraphSetOutput(nG6, nGain6)
	StzEngineSoundGraphPrepare(nG6)

	nS6 = StzEngineSoundStreamStart(nG6, 8192)
	Chk("the stream starts", nS6 != 0)
	sleep(0.1)   # let the producer prefill before the device asks

	nDev = StzEngineAudioDevPlaybackOpen(StzEngineSoundStreamRingPtr(nS6), 256)
	Chk("the device opened on the stream's ring", nDev != 0)
	if nDev != 0
		Chk("playback starts", StzEngineAudioDevPlaybackStart(nDev) = 0)
		sleep(1.0)
		# a control change WHILE the device is playing -- the whole point of
		# doing this lock-free
		Chk("a gain change is accepted mid-playback",
		    StzEngineSoundGraphSetGain(nG6, nGain6, 0.3, 20.0) = 0)
		sleep(0.5)
		StzEngineAudioDevPlaybackStop(nDev)

		nCb = StzEngineAudioDevPlaybackCallbacks(nDev)
		nFr = StzEngineAudioDevPlaybackFramesOut(nDev)
		nUr = StzEngineSoundStreamUnderruns(nS6)
		? "   callbacks: " + nCb + "   frames delivered: " + nFr
		? "   worst callback: " + StzEngineAudioDevPlaybackWorstUs(nDev) + " us"
		? "   underruns: " + nUr
		Chk("the callback actually ran", nCb > 0)
		Chk("it delivered roughly a second and a half of audio", nFr > 48000)
		Chk("sustained playback underran ZERO times", nUr = 0)
		Chk("the gain change arrived", fabs(StzEngineSoundGraphCurrentGain(nG6, nGain6) - 0.3) < 0.001)

		# ORDER MATTERS: the consumer must close before the producer frees the
		# ring, or the callback would read freed memory
		Chk("the device closes", StzEngineAudioDevPlaybackClose(nDev) = 0)
	ok
	StzEngineSoundStreamStop(nS6)
	StzEngineSoundGraphFree(nG6)
ok

StzEngineSoundGraphFree(nG)

# ---------------------------------------------------------------------------
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

# The worst sample-to-sample jump around a gain change, measured ACROSS the
# moment it happens -- render a little at the old value, change it, render on,
# and look at the junction as well as the interior. Rendering from scratch
# with the change already applied would show no discontinuity at all, because
# the change landed before the first sample.
func GainStep nRampMs
	_g_ = StzEngineSoundGraphNew(1, 48000, 64)
	# DC, so anything that moves in the output is the gain and nothing else
	_o_ = StzEngineSoundGraphAddOsc(_g_, StzSoundWaveSquare(), 1, 1.0)
	_gn_ = StzEngineSoundGraphAddGain(_g_, _o_, 1.0)
	StzEngineSoundGraphSetOutput(_g_, _gn_)
	StzEngineSoundGraphPrepare(_g_)

	_before_ = StzEngineSoundGraphToBuffer(_g_, 128)
	StzEngineSoundGraphSetGain(_g_, _gn_, 0.0, nRampMs)
	_after_ = StzEngineSoundGraphToBuffer(_g_, 1024)

	# the junction first -- the single most likely place for a click
	_worst_ = fabs(StzEngineSoundGet(_after_, 1, 1) - StzEngineSoundGet(_before_, 128, 1))
	for _i_ = 2 to 1024
		_d_ = fabs(StzEngineSoundGet(_after_, _i_, 1) - StzEngineSoundGet(_after_, _i_ - 1, 1))
		if _d_ > _worst_
			_worst_ = _d_
		ok
	next
	StzEngineSoundFree(_before_)
	StzEngineSoundFree(_after_)
	StzEngineSoundGraphFree(_g_)
	return _worst_
