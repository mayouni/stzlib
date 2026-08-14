# THE CONVERGENCE -- SN6 of SOFTANZA_SOUND_PLAN.md.
#
# Sound stops being a thing you call and start; it becomes a thing that RUNS,
# with a state, a clock, and a place in the loop the rest of the library
# already turns.
#
#   stzSoundTransport   play / pause / resume / stop, without blocking, with
#                       stzStateMachine deciding what is legal and the DEVICE
#                       deciding what time it is
#   stzVoicePool        the same sound fired again and again from a graph
#                       built once -- the game plane's door
#
# WHAT EACH SCENE PROVES, and why it is worth a guard:
#
#   1  a transport does not block, and its clock is the one you hear
#   2  the state machine refuses, and the refusal is COUNTED
#   3  pause freezes the clock; resume continues rather than restarting
#   4  a retrigger restarts ONE voice
#   5  slots overlap, and a steal is read from the clock, not guessed
#   6  the reactive plane can drive it -- one loop, not one per thing
#
# Scenes 1, 3, 5 and 6 need a real output device. They SKIP, loudly, when
# there is none, rather than passing on a machine that proved nothing.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0

pr()
decimals(3)

? "== the convergence: transport, clock, voices =="
? ""
if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load"
	? ""
	? "0 passed, 1 failed"
	bye
ok

bDev = StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1
if NOT bDev
	? "  (no output device -- the scenes that need one will SKIP)"
	? ""
ok

# ---------------------------------------------------------------------------
? "-- Scene 1: a transport RUNS. It does not block, and its clock is real --"

oG = MakeToneGraph(330)
oT = new stzSoundTransport(oG)
Chk("it starts out stopped", oT.State() = "stopped")
Chk("and its rate came from the graph", oT.SampleRate() = 48000)
Chk("a master gain was added for it to fade", oG.NodeNamed(:master) > 0)

if bDev
	# THE GRAPH IS AN OSCILLATOR: it never ends. PlayFor(n) on it would block
	# forever. So a Play() that returns AT ALL is the property being proved,
	# and what it costs is opening a device -- a fixed price, measured below,
	# that does not grow with the sound.
	nT0 = clock()
	oT.Play()
	nMs = (clock() - nT0) / clockspersecond() * 1000
	? "   Play() returned in " + nMs + " ms, on a sound with no end"
	Chk("Play RETURNS -- the old PlayFor would still be sleeping", nMs < 1500)
	Chk("and it is playing", oT.IsPlaying())
	# recorded, because it changes how a game should be written: opening a
	# WASAPI device is not free. Start the pool when the level loads, not when
	# the first footstep happens.
	? "   (that cost is the DEVICE opening, not the sound -- start early)"

	sleep(0.5)
	oT.Tick()
	nPos = oT.PositionInSeconds()
	? "   after half a second the clock reads " + nPos + "s"
	Chk("the clock advanced", nPos > 0.2)
	# THE CLOCK IS THE DEVICE'S. It counts frames the device has CONSUMED, so
	# it can lag a wall clock -- it must never LEAD one, because that would be
	# reporting audio the listener has not heard yet.
	Chk("and it does not run ahead of the wall", nPos < 0.75)

	oT.Stop()
	Chk("stopping stops it", oT.IsStopped())
	? "   underruns over the run: " + oT.Underruns()
	Chk("with no underruns", oT.Underruns() = 0)
else
	Skip("Play/clock/stop need an output device")
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: the state machine REFUSES, and the refusal is counted --"
? "   These need no device: an illegal move is refused before anything is"
? "   opened, which is the point of asking first."

oG2 = MakeToneGraph(220)
oT2 = new stzSoundTransport(oG2)
nR0 = oT2.Refusals()
oT2.Resume()
Chk("resume from stopped is refused", oT2.Refusals() = nR0 + 1)
? "   " + oT2.LastError()
oT2.Pause()
Chk("pause from stopped is refused", oT2.Refusals() = nR0 + 2)
oT2.Stop()
Chk("stop from stopped is refused too", oT2.Refusals() = nR0 + 3)
Chk("and none of that moved it", oT2.State() = "stopped")

# THE NEGATIVE SIBLING. Without this, "everything is refused" would pass --
# and a transport that refuses everything is not a strict transport, it is a
# broken one.
oT2.Rewind()
Chk("rewind IS allowed while stopped", oT2.Refusals() = nR0 + 3)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: pause freezes the clock; resume CONTINUES --"

if bDev
	oG3 = MakeToneGraph(440)
	oT3 = new stzSoundTransport(oG3)
	oT3.Play()
	sleep(0.4)
	oT3.Pause()
	nAt = oT3.PositionInSeconds()
	Chk("it is paused", oT3.IsPaused())
	sleep(0.5)
	? "   paused at " + nAt + "s; half a second later it reads " +
	  oT3.PositionInSeconds() + "s"
	Chk("a paused clock does not run", fabs(oT3.PositionInSeconds() - nAt) < 0.02)

	oT3.Resume()
	sleep(0.4)
	oT3.Tick()
	nAfter = oT3.PositionInSeconds()
	? "   after resuming it reads " + nAfter + "s"
	Chk("resume CONTINUES rather than restarting", nAfter > nAt + 0.1)
	oT3.Stop()
	oT3.Release()
	oG3.Release()
else
	Skip("pause/resume need an output device")
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: a retrigger restarts ONE voice and no other --"
? "   No device needed: this is arithmetic on rendered samples."

oG4 = new stzSoundGraph()
oG4.Reshape(1, 48000)
oG4.AddOscillator(:Sine, 1000, 1.0)
oG4.NameIt(:a)
oG4.AddEnvelopeOn(:a, 0.02, 0, 1.0, 0, 10)
oG4.NameIt(:aenv)
oG4.AddOscillator(:Sine, 1500, 1.0)
oG4.NameIt(:b)
oG4.AddEnvelopeOn(:b, 0.02, 0, 1.0, 0, 10)
oG4.NameIt(:benv)
oG4.AddMixOf([ :aenv, :benv ])
oG4.Prepare()

oWarm = oG4.ToSound(0.1)                    # both climb and reach full
nFull = PeakBetween(oWarm, 3000, 4800)
? "   both voices at full: " + nFull
Chk("two voices are sounding", nFull > 1.5)

nRc = StzEngineSoundGraphTriggerNode(oG4.GraphId(), oG4.NodeNamed(:aenv))
Chk("the retrigger was accepted", nRc = 0)
oAfter = oG4.ToSound(0.1)
nJust = PeakBetween(oAfter, 1, 64)
? "   just after A restarts: " + nJust
Chk("A went back to the bottom of its attack", nJust < nFull * 0.7)
Chk("and B is still sounding -- it was not touched", nJust > nFull * 0.3)
nBack = PeakBetween(oAfter, 2000, 4800)
Chk("20 ms later the pair is loud again", nBack > nFull * 0.85)

# the negative sibling: an unknown node is refused rather than silently doing
# nothing, and doing nothing is exactly what a wrong index would look like
Chk("an unknown node is REFUSED",
    StzEngineSoundGraphTriggerNode(oG4.GraphId(), 9999) != 0)

oWarm.Release()
oAfter.Release()
oG4.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: a pool overlaps, and reads its steals off the clock --"

oP = new stzVoicePool(48000)
oP.AddToneVoice(:short, :Square, 880, 0.06, 3)
oP.AddToneVoice(:long, :Sine, 300, 1.0, 2)
Chk("two voices", len(oP.VoiceNames()) = 2)
Chk("with the slots asked for", oP.SlotsOf(:short) = 3 and oP.SlotsOf(:long) = 2)

nR = oP.Refusals()
oP.Fire(:short)
Chk("firing before Start is refused", oP.Refusals() = nR + 1)
oP.Fire(:nosuchvoice)
Chk("and so is an unknown voice", oP.Refusals() = nR + 2)

if bDev
	oP.Start()
	Chk("the pool started", oP.IsStarted())
	if oP.IsStarted()
		# SHORT shots into three slots, slowly: nothing should be stolen
		for i = 1 to 6
			oP.Fire(:short)
			sleep(0.1)
		next
		? "   short: " + oP.FiresOf(:short) + " fires, " +
		  oP.StealsOf(:short) + " steals"
		Chk("six short shots through three slots steal NOTHING",
		    oP.StealsOf(:short) = 0)

		# LONG shots into two slots, fast: the last four must steal. This is
		# the negative sibling -- without it, a steal counter stuck at zero
		# would have passed the test above.
		for i = 1 to 6
			oP.Fire(:long)
			sleep(0.1)
		next
		? "   long: " + oP.FiresOf(:long) + " fires, " +
		  oP.StealsOf(:long) + " steals"
		Chk("six long shots through two slots steal four", oP.StealsOf(:long) = 4)
		Chk("and the pool kept up -- no underruns", oP.Underruns() = 0)
		oP.Stop()
	ok
else
	Skip("a pool needs an output device")
ok
oP.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: the REACTIVE plane drives it. One loop, not one per thing. --"

if bDev
	oG6 = MakeToneGraph(523)
	oT6 = new stzSoundTransport(oG6)
	nTicks = 0
	oT6.OnTick(func { nTicks++ })
	oT6.PlayFor(0.8)
	Chk("it is playing", oT6.IsPlaying())
	oT6.RunToEnd()
	? "   it ticked " + nTicks + " times and stopped itself at " +
	  oT6.PositionInSeconds() + "s"
	Chk("PlayFor stopped it by itself", oT6.IsStopped())
	Chk("the tick callback really ran", nTicks > 10)
	Chk("and it stopped at about the length asked for",
	    oT6.PositionInSeconds() > 0.7 and oT6.PositionInSeconds() < 1.1)
	oT6.Release()
	oG6.Release()
else
	Skip("driving a transport needs an output device")
ok

oT.Release()
oT2.Release()
oG.Release()
oG2.Release()

# ---------------------------------------------------------------------------
? ""
? "-- a pool starts SILENT, however long its voices are --"
? "   Needs no device: this is about how far the graph must be rendered"
? "   before every source has run out, which is arithmetic."
? ""
? "   THE BUG THIS CATCHES: the pool spent its voices by rendering a fixed"
? "   THREE SECONDS and throwing it away. A sound voice has no envelope to"
? "   turn down -- it is silent because its source RAN OUT -- so a voice"
? "   longer than three seconds was left partway through. The device then"
? "   opened straight into the TAIL of it. With a five-second spoken"
? "   announcement you heard its last words, then heard the whole sentence"
? "   again when it was fired. No counter sees this: playing a voice nobody"
? "   triggered is not a dropped frame."

nLong = 5.0
oLongSnd = StzSoundOfSilenceQ(nLong, 1, 48000)
for i = 1 to oLongSnd.Frames()
	oLongSnd.SetSampleAt(i, 1, 0.5)     # loud for its WHOLE length
next
Chk("the test voice really is " + nLong + " s long",
    fabs(oLongSnd.Duration() - nLong) < 0.01)

oGp = new stzSoundGraph()
oGp.Reshape(1, 48000)
oGp.AddSound(oLongSnd)
oGp.NameIt(:src)
oGp.AddMixOf([ :src ])
oGp.Prepare()

# render the OLD distance, then look at what is left
oSpent3 = oGp.ToSound(3.0)
oNext3 = oGp.ToSound(0.2)
nAfter3 = PeakBetween(oNext3, 1, oNext3.Frames())
? "   after rendering 3 s, the next 200 ms peaks at " + nAfter3
Chk("THREE SECONDS DOES NOT SPEND A FIVE-SECOND VOICE -- this is the bug",
    nAfter3 > 0.1)

# now render the rest of its own duration, which is what the fix does
oRest = oGp.ToSound(nLong - 3.0 + 0.25)
oNextAll = oGp.ToSound(0.2)
nAfterAll = PeakBetween(oNextAll, 1, oNextAll.Frames())
? "   after rendering its own " + nLong + " s, the next 200 ms peaks at " +
  nAfterAll
Chk("its OWN duration does spend it -- the pool starts silent",
    nAfterAll < 0.001)

oSpent3.Release()
oNext3.Release()
oRest.Release()
oNextAll.Release()
oLongSnd.Release()
oGp.Release()

# ---------------------------------------------------------------------------
? ""
? "-- a sound plays at ITS rate, not the device's --"
? "   THE BUG THIS CATCHES was inaudible to every counter. The device was"
? "   opened with sampleRate = 0 -- 'let the device pick' -- so a 22050 Hz"
? "   buffer handed to a 44100 Hz device played every sample TWICE AS FAST."
? "   No frame was lost, so no underrun fired and nothing looked wrong. It"
? "   surfaced only when a SPOKEN phrase came out as gibberish. Earcons"
? "   render at 48000 and matched the device by luck, which is why it hid"
? "   for so long."
? ""
? "   The only instrument that sees this is a CLOCK, so the assertion is a"
? "   wall-clock one: a buffer at a rate the hardware does not natively run"
? "   must still take its own duration to play."

if bDev
	nOddRate = 22050            # deliberately NOT a common device rate
	oGr = new stzSoundGraph()
	oGr.Reshape(1, nOddRate)
	oGr.AddOscillator(:Sine, 440, 0.2)
	oTr = new stzSoundTransport(oGr)
	nWant = 2.0
	nT0 = clock()
	oTr.PlayFor(nWant)
	while NOT oTr.IsStopped()
		oTr.Tick()
		sleep(0.01)
	end
	nHeard = (clock() - nT0) / clockspersecond()
	? "   asked for " + nWant + " s at " + nOddRate + " Hz, heard " + nHeard + " s"
	# a generous band: device start-up and tick granularity cost a little,
	# but the failure this guards against is a factor of TWO, not a fraction
	Chk("a 22050 Hz buffer takes its own duration to play, not half of it",
	    nHeard > nWant * 0.8 and nHeard < nWant * 1.5)
	oTr.Release()
	oGr.Release()
else
	Skip("timing playback needs an output device")
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

func MakeToneGraph nHz
	_g_ = new stzSoundGraph()
	_g_.Reshape(2, 48000)
	_g_.AddOscillator(:Triangle, nHz, 0.4)
	_g_.NameIt(:tone)
	_g_.AddEnvelopeOn(:tone, 0.02, 0.1, 0.8, 0.2, 30)
	return _g_

func PeakBetween oSound, nFrom, nTo
	_p_ = 0
	_n_ = oSound.Frames()
	if nTo > _n_  nTo = _n_ ok
	for _i_ = nFrom to nTo
		_v_ = fabs(oSound.SampleAt(_i_, 1))
		if _v_ > _p_  _p_ = _v_ ok
	next
	return _p_
