# THE DECLARATIVE FACES -- SN4 of SOFTANZA_SOUND_PLAN.md.
#
# stzSound, stzSoundGraph, stzMicrophone: the surface a Ring programmer
# actually touches. Everything below the faces is already guarded elsewhere;
# what THIS guard asserts is that the faces obey the house naming law and do
# not quietly lose things.
#
# THE LAW, and why a guard can check it at all:
#   1. a method is an explicit VERB acting on the object;
#   2. ...Q performs the SAME act and returns THE MAIN OBJECT, so a chain
#      never leaves it -- and THAT is mechanically testable: the thing a Q
#      returns must be the same object you called it on;
#   3. To...() returns DATA.
#
# Rule 2 is the one that rots silently. A Q that returns a sub-object still
# looks fine at the call site until someone chains two of them, so this guard
# asserts identity rather than eyeballing the source.
#
# Everything except the last scene runs with NO audio hardware.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0

cTmp = currentdir() + "/temp"
if NOT direxists(cTmp)
	system("mkdir " + '"' + cTmp + '"')
ok

pr()
decimals(6)

? "== the declarative faces =="
? ""
if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load"
	? ""
	? "0 passed, 1 failed"
	bye
ok

# ---------------------------------------------------------------------------
? "-- Scene 1: stzSound holds a sound and answers plainly about it --"

oT = StzSoundOfSilenceQ(0.5, 1, 48000)
Chk("a silent sound is half a second", fabs(oT.Duration() - 0.5) < 0.001)
Chk("it is mono", oT.Channels() = 1)
Chk("at 48 kHz", oT.SampleRate() = 48000)
Chk("and it is actually silent", oT.Peak() = 0)
Chk("it is not empty", NOT oT.IsEmpty())

oT.SetSampleAt(10, 1, 0.5)
Chk("a written sample reads back (1-BASED, like every Ring face)", oT.SampleAt(10, 1) = 0.5)
Chk("and the peak notices", oT.Peak() = 0.5)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: the Q law -- a chain never leaves the main object --"
? "   Asserted by IDENTITY, not by reading the source: what a Q hands back"
? "   must be the very object it was called on."

oId = oT.ResampleToQ(44100)
Chk("ResampleToQ returned the SAME sound object", oId.BufferId() = oT.BufferId())
Chk("and it did the work: the rate changed", oT.SampleRate() = 44100)
Chk("while the duration did not", fabs(oT.Duration() - 0.5) < 0.001)

oId2 = oT.ToStereoQ()
Chk("ToStereoQ returned the same object too", oId2.BufferId() = oT.BufferId())
Chk("and the channel count changed", oT.Channels() = 2)

# the negative sibling: the PLAIN form acts and returns nothing
oPlain = oT.ToMono()
Chk("the plain twin returns nothing, as the law requires", oPlain = NULL)
Chk("but it still acted", oT.Channels() = 1)
oT.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: a sound survives a trip through a file --"

oA = StzSoundOfSilenceQ(0.25, 1, 48000)
for i = 1 to 100
	oA.SetSampleAt(i, 1, 0.9 * sin(i * 0.7))
next
cPath = cTmp + "/face_roundtrip.wav"
oA.SaveAsFloat(cPath)
Chk("the file was written", fexists(cPath))

oB = new stzSound(cPath)
Chk("and it loads back", NOT oB.IsEmpty())
Chk("with the same length", oB.Frames() = oA.Frames())
Chk("the same rate", oB.SampleRate() = oA.SampleRate())
nWorst = 0
for i = 1 to 100
	nD = fabs(oA.SampleAt(i, 1) - oB.SampleAt(i, 1))
	if nD > nWorst  nWorst = nD ok
next
Chk("and 32-bit is BIT-EXACT through the round trip", nWorst = 0)

# the negative sibling: a file that is not there fails and says so
oC = new stzSound(cTmp + "/there_is_no_such_sound.wav")
Chk("a missing file gives an empty sound", oC.IsEmpty())
Chk("and it says why", len(oC.LastError()) > 0)
oA.Release()
oB.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: stzSoundGraph builds by VERB, and refers back by NAME --"
? "   The plan's first sketch had oG.Add(StzOscillatorQ(:Sine).Hz(440)),"
? "   which hands you an intermediate object to hold and lose. The challenge"
? "   pass rejected it; this is what replaced it."

oG = new stzSoundGraph()
oG.AddOscillator(:Triangle, 440, 0.5)
oG.NameIt(:tone)
Chk("the oscillator was added", oG.NodeCount() = 1)
Chk("and it answers to its name", oG.HasNode(:tone))

oG.AddEnvelopeOn(:tone, 0.01, 0.3, 0.0, 0.2, 0.4)
oG.NameIt(:shaped)
Chk("an envelope was chained onto it", oG.NodeCount() = 2)

# the negative sibling: an unknown name is refused and SAYS SO
nBefore = oG.NodeCount()
oG.AddGainOn(:no_such_node, 0.5)
Chk("an unknown name adds nothing", oG.NodeCount() = nBefore)
Chk("and the graph says which name it did not know", len(oG.LastError()) > 0)

# waveform and filter names are words, not magic numbers
oG.AddFilterOn(:shaped, :LowPass, 2000, 0.9)
Chk("a filter names its kind in words", oG.NodeCount() = nBefore + 1)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: the graph's Q twins return the GRAPH --"

oG2 = new stzSoundGraph()
oRet = oG2.AddOscillatorQ(:Sine, 880, 0.4)
Chk("AddOscillatorQ returned the same graph", oRet.GraphId() = oG2.GraphId())
oRet2 = oG2.NameItQ(:bell).AddEchoOnQ(:bell, 0.2, 0.3, 0.4)
Chk("a two-link chain still returns the same graph", oRet2.GraphId() = oG2.GraphId())
Chk("and both links did their work", oG2.NodeCount() = 2)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: ToSound() and ToFile() -- To... returns DATA --"

oOut = oG2.ToSound(1.0)
Chk("ToSound gave back a stzSound", isObject(oOut))
if isObject(oOut)
	Chk("of the length asked for", fabs(oOut.Duration() - 1.0) < 0.01)
	Chk("and it is not silent", oOut.Peak() > 0.01)
	Chk("nor is it clipping", oOut.Peak() < 1.0)
	oOut.Release()
ok

cGraphFile = cTmp + "/face_graph.wav"
oG2.Rewind()
oG2.ToFile(cGraphFile, 1.0)
Chk("ToFile wrote the file", fexists(cGraphFile))
oBack = new stzSound(cGraphFile)
Chk("and it is a real sound", NOT oBack.IsEmpty() and oBack.Peak() > 0.01)
oBack.Release()
oG2.Release()
oG.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 7: a graph can play a stzSound as a source --"
? "   This is the seam between the two faces: a sound is data, a graph is a"
? "   plan, and the plan can take the data as an input."

oSrc = StzSoundOfSilenceQ(0.2, 1, 48000)
for i = 1 to oSrc.Frames()
	oSrc.SetSampleAt(i, 1, 0.4)      # DC, so anything that survives is the source
next
oG3 = StzSoundGraphOfQ(1, 48000)
oG3.AddSound(oSrc)
oG3.NameIt(:clip)
oG3.AddGainOn(:clip, 0.5)
oRendered = oG3.ToSound(0.2)
Chk("the graph rendered the sound it was given", isObject(oRendered))
if isObject(oRendered)
	Chk("through the gain: 0.4 x 0.5 = 0.2", fabs(oRendered.SampleAt(5, 1) - 0.2) < 0.001)
	oRendered.Release()
ok
oG3.Release()
oSrc.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 8: stzMicrophone is honest about whether it can record --"

oM = new stzMicrophone()
bMic = oM.IsAvailable()
Chk("IsAvailable answers TRUE or FALSE, never junk", bMic = TRUE or bMic = FALSE)

# the negative sibling, and it runs on EVERY machine: stopping a recording
# that never started is refused, not answered with an empty sound
oIdle = oM.StopRecording()
Chk("stopping when not recording gives NULL, not a silent sound", oIdle = NULL)
Chk("and it says so", len(oM.LastError()) > 0)
Chk("it knows it is not recording", NOT oM.IsRecording())

if NOT bMic
	nSkip++
	? "  [skip] no capture device -- the CI path. Everything above still ran."
else
	? "   input: " + len(oM.DeviceName()) + " characters of device name (not printed: not ASCII)"
	Chk("the device has a name", len(oM.DeviceName()) > 0)

	oRec = oM.RecordFor(0.6)
	Chk("recording produced a sound", isObject(oRec))
	if isObject(oRec)
		? "   captured " + oRec.Frames() + " frames, peak " + oRec.Peak()
		Chk("of about the length asked for", fabs(oRec.Duration() - 0.6) < 0.25)
		Chk("at the rate asked for", oRec.SampleRate() = 48000)
		# NOT a silence assertion: a muted mic legitimately records zeros.
		# What must be true is that FRAMES arrived.
		Chk("real frames arrived", oRec.Frames() > 1000)
		Chk("and nothing overran -- the ring was drained in time", oM.Overruns() = 0)
		oRec.Release()
	ok
	Chk("and it is no longer recording", NOT oM.IsRecording())
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
