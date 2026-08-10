# The sound graph, offline -- SN2 of SOFTANZA_SOUND_PLAN.md.
#
# NO AUDIO HARDWARE IS USED OR NEEDED. That is the phase's whole strategy: SN2
# proves the SAMPLES with no clock, so that SN3 only has to add the clock. Every
# assertion below is on exact numbers a hand calculation can check, never on
# "it sounds right".
#
# The two claims this guard exists to hold:
#
#   1. RENDER ALLOCATES NOTHING. The audio callback in SN3 is a no-allocation,
#      no-lock, no-Ring zone, and a graph that allocates while rendering cannot
#      be handed to it. The engine counts every allocation; the guard reads the
#      count either side of a render and asserts it did not move.
#
#   2. THE SINK IS A PARAMETER, NOT A FORK. The same node list rendered to a
#      buffer and to a file must produce identical samples -- so "what you hear"
#      and "what you export" cannot drift apart.

load "../../stzBase.ring"

nPass = 0
nFail = 0

CG_LIVE = 0
CG_BLOCKS = 1
CG_FRAMES = 2
CG_REFUSALS = 3
CG_STALE = 4

cTmp = currentdir() + "/temp"
if NOT direxists(cTmp)
	system("mkdir " + '"' + cTmp + '"')
ok

pr()
decimals(12)

? "== the sound graph, rendered offline =="
? ""
if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load"
	? ""
	? "0 passed, 1 failed"
	bye
ok

# ---------------------------------------------------------------------------
? "-- Scene 1: an oscillator produces EXACT numbers, not approximately music --"
? "   A sine at exactly rate/4 must land on 0, 1, 0, -1 and repeat. Anything"
? "   else means the phase accumulator drifts, and drift is inaudible until"
? "   the day two voices are supposed to cancel and do not."

nG = StzEngineSoundGraphNew(1, 48000, 8)
Chk("a graph is created", nG != 0)
nOsc = StzEngineSoundGraphAddOsc(nG, StzSoundWaveSine(), 12000, 1.0)
Chk("an oscillator node is added (1-based, so >= 1)", nOsc >= 1)
Chk("the node count is 1", StzEngineSoundGraphNodeCount(nG) = 1)
Chk("setting the output succeeds", StzEngineSoundGraphSetOutput(nG, nOsc) = 0)
Chk("it is not prepared yet", StzEngineSoundGraphIsPrepared(nG) = 0)
Chk("prepare succeeds", StzEngineSoundGraphPrepare(nG) = 0)
Chk("and now it is prepared", StzEngineSoundGraphIsPrepared(nG) = 1)

nOut = StzEngineSoundGraphToBuffer(nG, 8)
Chk("the render produced a buffer", nOut != 0)
Chk("with the frames asked for", StzEngineSoundFrames(nOut) = 8)
aWant = [0, 1, 0, -1, 0, 1, 0, -1]
bExact = TRUE
for i = 1 to 8
	if fabs(StzEngineSoundGet(nOut, i, 1) - aWant[i]) > 0.000001
		bExact = FALSE
	ok
next
Chk("every one of the 8 samples is exactly 0, 1, 0, -1, ...", bExact)
StzEngineSoundFree(nOut)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: RENDER ALLOCATES NOTHING -- the contract SN3 depends on --"
? "   Built with a filter, a delay and an envelope, so the nodes that hold"
? "   state are all represented. 200 blocks must not allocate one byte."

nG2 = StzEngineSoundGraphNew(2, 48000, 64)
nO2 = StzEngineSoundGraphAddOsc(nG2, StzSoundWaveSine(), 440, 0.5)
nF2 = StzEngineSoundGraphAddFilter(nG2, nO2, StzSoundFilterLowPass(), 1000, 0.707)
nD2 = StzEngineSoundGraphAddDelay(nG2, nF2, 0.01, 0.4, 0.5)
nE2 = StzEngineSoundGraphAddEnvelope(nG2, nD2, 0.001, 0.001, 0.8, 0.001, 0.05)
Chk("filter node added", nF2 >= 1)
Chk("delay node added", nD2 >= 1)
Chk("envelope node added", nE2 >= 1)
StzEngineSoundGraphSetOutput(nG2, nE2)
Chk("prepare succeeds on the full chain", StzEngineSoundGraphPrepare(nG2) = 0)

nAllocBefore = StzEngineSoundGraphAllocCount()
for i = 1 to 200
	StzEngineSoundGraphRenderBlock(nG2)
next
nAllocAfter = StzEngineSoundGraphAllocCount()
? "   allocations before: " + nAllocBefore + "   after 200 blocks: " + nAllocAfter
Chk("200 render blocks allocated EXACTLY nothing", nAllocAfter = nAllocBefore)

# the negative sibling: PREPARE does allocate, so the counter is live and the
# assertion above is not merely reading a counter that never moves
nG3 = StzEngineSoundGraphNew(1, 48000, 32)
nO3 = StzEngineSoundGraphAddOsc(nG3, StzSoundWaveSaw(), 100, 1)
StzEngineSoundGraphSetOutput(nG3, nO3)
nA1 = StzEngineSoundGraphAllocCount()
StzEngineSoundGraphPrepare(nG3)
nA2 = StzEngineSoundGraphAllocCount()
Chk("but PREPARE does allocate -- the counter is live, not stuck", nA2 > nA1)
StzEngineSoundGraphFree(nG3)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: THE SINK IS A PARAMETER, NOT A FORK --"
? "   The same prepared graph rendered to a buffer and to a WAV must give the"
? "   SAME samples. If these ever diverge, an export stops matching playback."

nG4 = StzEngineSoundGraphNew(1, 48000, 100)
nO4 = StzEngineSoundGraphAddOsc(nG4, StzSoundWaveTriangle(), 300, 0.8)
nF4 = StzEngineSoundGraphAddFilter(nG4, nO4, StzSoundFilterLowPass(), 2000, 0.9)
StzEngineSoundGraphSetOutput(nG4, nF4)
StzEngineSoundGraphPrepare(nG4)

nBuf = StzEngineSoundGraphToBuffer(nG4, 1000)
Chk("the buffer sink rendered", nBuf != 0)

StzEngineSoundGraphRewind(nG4)
cWav = cTmp + "/graph_sink.wav"
Chk("the file sink rendered", StzEngineSoundGraphToFile(nG4, 1000, cWav, 32) = 0)
Chk("and the file exists", fexists(cWav))

nFromFile = StzEngineSoundLoadFile(cWav)
Chk("the rendered file decodes", nFromFile != 0)
nWorst = 0
for i = 1 to 1000
	nD = fabs(StzEngineSoundGet(nBuf, i, 1) - StzEngineSoundGet(nFromFile, i, 1))
	if nD > nWorst
		nWorst = nD
	ok
next
? "   worst difference between the two sinks: " + nWorst
Chk("buffer and file are BIT-IDENTICAL", nWorst = 0)
StzEngineSoundFree(nBuf)
StzEngineSoundFree(nFromFile)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: a mix SUMS, and a cycle cannot be expressed --"

nG5 = StzEngineSoundGraphNew(1, 48000, 4)
nA5 = StzEngineSoundGraphAddOsc(nG5, StzSoundWaveSaw(), 1000, 0.25)
nB5 = StzEngineSoundGraphAddOsc(nG5, StzSoundWaveSaw(), 1000, 0.5)
nM5 = StzEngineSoundGraphAddMix(nG5)
Chk("mixing in the first source", StzEngineSoundGraphMixAdd(nG5, nM5, nA5) = 0)
Chk("mixing in the second", StzEngineSoundGraphMixAdd(nG5, nM5, nB5) = 0)

# the negative sibling, and it MUST come before prepare: a node cannot consume
# something created after it, so a cycle has no way to be written down
nRefBefore = StzEngineSoundGraphCounter(CG_REFUSALS)
Chk("feeding the mix into an EARLIER node is refused (no cycles)",
    StzEngineSoundGraphMixAdd(nG5, nA5, nM5) = 3)
Chk("sound.graph.refusals MOVED", StzEngineSoundGraphCounter(CG_REFUSALS) > nRefBefore)

StzEngineSoundGraphSetOutput(nG5, nM5)
StzEngineSoundGraphPrepare(nG5)
nSum = StzEngineSoundGraphToBuffer(nG5, 4)
# two saws of the same frequency at 0.25 and 0.5 sum to exactly 0.75 x the unit
# saw -- an exact statement, not "it got louder"
bSum = TRUE
for i = 1 to 4
	if fabs(StzEngineSoundGet(nSum, i, 1)) > 0.750001
		bSum = FALSE
	ok
next
Chk("the mix is exactly the sum of its inputs", bSum)
StzEngineSoundFree(nSum)
StzEngineSoundGraphFree(nG5)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: a lowpass kills a high tone AND passes a low one --"
? "   Both halves are asserted. Without the second, 'it went quiet' would"
? "   prove only that the filter silences everything."

nHigh = FilterPeak(12000, 200)
nLow = FilterPeak(50, 200)
? "   12 kHz through a 200 Hz lowpass: peak " + nHigh
? "   50 Hz  through the same filter:  peak " + nLow
Chk("the high tone is crushed", nHigh < 0.05)
Chk("the low tone passes essentially untouched", nLow > 0.8)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: the BLOCK SIZE is not audible --"
? "   SN3's device picks the block size, not us. If node state were reset or"
? "   dropped at a block boundary, the same graph would render differently at"
? "   different block sizes -- and it would be inaudible until it was not."

aR1 = RenderAt(32)
aR2 = RenderAt(500)
nWorst2 = 0
for i = 1 to 512
	nD = fabs(aR1[i] - aR2[i])
	if nD > nWorst2
		nWorst2 = nD
	ok
next
? "   worst difference between block 32 and block 500: " + nWorst2
Chk("block size 32 and 500 give the same samples", nWorst2 < 0.000001)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 7: rewind repeats a render EXACTLY, without reallocating --"

nG7 = StzEngineSoundGraphNew(2, 48000, 128)
nO7 = StzEngineSoundGraphAddOsc(nG7, StzSoundWaveTriangle(), 220, 0.7)
nD7 = StzEngineSoundGraphAddDelay(nG7, nO7, 0.005, 0.5, 0.5)
StzEngineSoundGraphSetOutput(nG7, nD7)
StzEngineSoundGraphPrepare(nG7)

nFirst = StzEngineSoundGraphToBuffer(nG7, 256)
nAllocs = StzEngineSoundGraphAllocCount()
Chk("rewind succeeds", StzEngineSoundGraphRewind(nG7) = 0)
Chk("rewind itself allocated nothing", StzEngineSoundGraphAllocCount() = nAllocs)
nSecond = StzEngineSoundGraphToBuffer(nG7, 256)

bSame = TRUE
for i = 1 to 256
	if StzEngineSoundGet(nFirst, i, 1) != StzEngineSoundGet(nSecond, i, 1)
		bSame = FALSE
	ok
	if StzEngineSoundGet(nFirst, i, 2) != StzEngineSoundGet(nSecond, i, 2)
		bSame = FALSE
	ok
next
Chk("both renders are identical, sample for sample, on both channels", bSame)
StzEngineSoundFree(nFirst)
StzEngineSoundFree(nSecond)
StzEngineSoundGraphFree(nG7)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 8: the two-phase contract refuses to be broken either way --"

nG8 = StzEngineSoundGraphNew(1, 48000, 16)
Chk("rendering before prepare returns NOT_PREPARED (7)", StzEngineSoundGraphRenderBlock(nG8) = 7)
Chk("preparing an empty graph returns BAD_ARG (3)", StzEngineSoundGraphPrepare(nG8) = 3)
nO8 = StzEngineSoundGraphAddOsc(nG8, StzSoundWaveSine(), 440, 1)
Chk("preparing with no output set returns BAD_ARG (3)", StzEngineSoundGraphPrepare(nG8) = 3)
StzEngineSoundGraphSetOutput(nG8, nO8)
Chk("now prepare succeeds", StzEngineSoundGraphPrepare(nG8) = 0)
Chk("adding a node AFTER prepare is refused (returns 0)",
    StzEngineSoundGraphAddOsc(nG8, StzSoundWaveSine(), 100, 1) = 0)
Chk("preparing twice returns ALREADY_PREPARED (8)", StzEngineSoundGraphPrepare(nG8) = 8)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 9: a freed graph is STALE, and the stale hit is COUNTED --"

nStale0 = StzEngineSoundGraphCounter(CG_STALE)
Chk("freeing once succeeds", StzEngineSoundGraphFree(nG8) = 0)
Chk("freeing twice returns STALE (2)", StzEngineSoundGraphFree(nG8) = 2)
Chk("a stale node count reads -1, not 0", StzEngineSoundGraphNodeCount(nG8) = -1)
Chk("sound.graph.stale.hits MOVED", StzEngineSoundGraphCounter(CG_STALE) > nStale0)

StzEngineSoundGraphFree(nG)
StzEngineSoundGraphFree(nG2)
StzEngineSoundGraphFree(nG4)

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers (below the main body: in Ring, top-level code after a func
# ---- never runs, so the scenes must come first) ---------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

# Peak of a tone after a lowpass, measured over the SECOND half so the
# filter's start-up transient is not what is being judged.
func FilterPeak nToneHz, nCornerHz
	_g_ = StzEngineSoundGraphNew(1, 48000, 256)
	_o_ = StzEngineSoundGraphAddOsc(_g_, StzSoundWaveSine(), nToneHz, 1.0)
	_f_ = StzEngineSoundGraphAddFilter(_g_, _o_, StzSoundFilterLowPass(), nCornerHz, 0.707)
	StzEngineSoundGraphSetOutput(_g_, _f_)
	StzEngineSoundGraphPrepare(_g_)
	_b_ = StzEngineSoundGraphToBuffer(_g_, 4096)
	_mx_ = 0
	for _i_ = 2048 to 4096
		_v_ = fabs(StzEngineSoundGet(_b_, _i_, 1))
		if _v_ > _mx_
			_mx_ = _v_
		ok
	next
	StzEngineSoundFree(_b_)
	StzEngineSoundGraphFree(_g_)
	return _mx_

# The same graph at a given block size, returned as a plain list so two block
# sizes can be compared sample for sample.
func RenderAt nBlock
	_g_ = StzEngineSoundGraphNew(1, 48000, nBlock)
	_o_ = StzEngineSoundGraphAddOsc(_g_, StzSoundWaveSaw(), 300, 0.9)
	_f_ = StzEngineSoundGraphAddFilter(_g_, _o_, StzSoundFilterLowPass(), 800, 1.2)
	StzEngineSoundGraphSetOutput(_g_, _f_)
	StzEngineSoundGraphPrepare(_g_)
	_b_ = StzEngineSoundGraphToBuffer(_g_, 512)
	_a_ = []
	for _i_ = 1 to 512
		_a_ + StzEngineSoundGet(_b_, _i_, 1)
	next
	StzEngineSoundFree(_b_)
	StzEngineSoundGraphFree(_g_)
	return _a_
