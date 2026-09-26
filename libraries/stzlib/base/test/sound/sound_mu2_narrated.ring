# MU2 -- the scheduler and the score. A score is DATA; a performance places
# every note at its frame, live, ahead of the ring; and the plan's kill
# criterion is run from Ring, on the real-time path, not only in the engine.
#
# Kill criterion (plan section 6): "onset jitter > 1 ms across 200 notes at
# 180 BPM means the scheduler is not ahead of the deadline, and it is
# redesigned before anything is built on it."

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(4)
nRate = 48000
nUnreadable = 0

? "== MU2: the score is data, and every note lands on its frame =="
? ""

? "-- Scene 1: a score is data, and its algebra is Euterpea's --"

oS = StzScoreOfQ("c e g c5")
aE = oS.Events()
? "   'c e g c5' -> " + len(aE) + " events, " + oS.Beats() + " beats"
? "   hz: " + aE[1][3] + "  " + aE[2][3] + "  " + aE[3][3] + "  " + aE[4][3]
Chk("four quarter notes, the octave carried: C4 E4 G4 C5",
    len(aE) = 4 and oS.Beats() = 4 and
    fabs(aE[1][3] - 261.6256) < 0.001 and fabs(aE[4][3] - 523.2511) < 0.001)
Chk("each starts where the last ended: beats 0, 1, 2, 3",
    aE[1][1] = 0 and aE[2][1] = 1 and aE[3][1] = 2 and aE[4][1] = 3)

oA = StzScoreOfQ("c d")
oB = StzScoreOfQ("e f g")
oA.Then(oB)
Chk("THEN is a sequence: 2 + 3 notes, 5 beats, the second part from beat 2",
    oA.NumberOfEvents() = 5 and oA.Beats() = 5 and oA.Events()[3][1] = 2)

oC = StzScoreOfQ("c5 d5 e5 f5").On(:Harp)
oD = StzScoreOfQ("c3 g2").On(:Guitar)
oC.Together(oD)
aT = oC.Events()
Chk("TOGETHER is a parallel: both parts from beat 0, the length the longer",
    oC.NumberOfEvents() = 6 and oC.Beats() = 4 and aT[1][1] = 0 and aT[2][1] = 0)
Chk("and each part keeps its own instrument",
    aT[1][4] = "harp" and aT[2][4] = "guitar")

oIn = StzScoreOfQ("a").On(:Oud)
oOut = StzScoreOfQ("c").Then(oIn)
oOut.On(:Kora)
Chk("an outer On names only what is unnamed -- the innermost wins",
    oOut.Events()[1][4] = "kora" and oOut.Events()[2][4] = "oud")

oK = StzScoreQ().On(:Drumkit).Stroke(:kick, 1).Stroke(:hihat, 1)
# THE FIRST CUT FAILED THIS, and it was the class that was wrong: On() was a
# pure modifier, so On() on an empty score named nothing and these strokes
# went to the default piano. On now also names what is added after it.
Chk("On before the notes names the notes that follow",
    oK.Events()[1][4] = "drumkit" and oK.Events()[2][4] = "drumkit")

oRep = StzScoreOfQ("a4 ~ a4").Repeat(3)
Chk("REPEAT: 2 notes and a rest, three times -> 6 notes over 9 beats",
    oRep.NumberOfEvents() = 6 and oRep.Beats() = 9 and oRep.Events()[3][1] = 3)

oTr = StzScoreOfQ("a4").Transpose(0.5)
Chk("TRANSPOSE by half a semitone is a quarter tone: 440 -> 452.893 Hz",
    fabs(oTr.Events()[1][3] - 440 * pow(2, 0.5 / 12)) < 0.000001)
oTk = StzScoreQ().On(:Darbouka).Stroke(:dum, 1).Transpose(7)
Chk("and a transposed STROKE keeps its drum's own pitch",
    oTk.Events()[1][3] = 0)

oBad = StzScoreQ()
oBad.Note("H4", 1)
oBad.Note("A4", 0)
oBad.Stroke(:clap, 1)
oBad.On(:Theremin)
oBad.AddNotes("c q e")
? "   last refusal: " + oBad.LastError()
Chk("refused, and counted: a bad name, a zero length, an unknown stroke, " +
    "an unknown instrument, a bad token -- 5",
    oBad.Refusals() = 5 and oBad.NumberOfEvents() = 2)

? ""
? "-- Scene 2: where a beat lands -- tempo, grid and swing, in frames --"

oP = StzScoreQ()
Chk("120 BPM: beat 1 is frame 24000, beat 2.5 is frame 60000",
    oP.FrameOf(1, nRate) = 24000 and oP.FrameOf(2.5, nRate) = 60000)
oP.Tempo(180)
Chk("180 BPM: beat 1 is frame 16000", oP.FrameOf(1, nRate) = 16000)
oP.Tempo(120).Quantize(0.25)
Chk("a 1/16 grid: beat 1.07 snaps to 1, beat 1.13 to 1.25",
    oP.FrameOf(1.07, nRate) = 24000 and oP.FrameOf(1.13, nRate) = 30000)
oP.Quantize(0).Swing(2 / 3)
nOff = oP.FrameOf(0.5, nRate)
? "   swing 2/3: the off-beat eighth at beat 0.5 lands at frame " + nOff +
  " -- " + (nOff / 24000) + " of the beat"
Chk("swing 2/3 moves the off-beat eighth to two thirds of the beat",
    nOff = 16000)
Chk("and leaves the beat itself where it was", oP.FrameOf(1, nRate) = 24000 and
    oP.FrameOf(0, nRate) = 0)
Chk("it WARPS, it does not jump: beat 0.25 -> 1/3 of the beat, beat 0.75 -> 5/6",
    oP.FrameOf(0.25, nRate) = 8000 and oP.FrameOf(0.75, nRate) = 20000)
oP.Swing(0.5)
Chk("swing 0.5 is straight", oP.FrameOf(0.5, nRate) = 12000)
nR0 = oP.Refusals()
oP.Tempo(0)
oP.Swing(1)
oP.Quantize(-1)
Chk("a tempo of 0, a swing of 1 and a negative grid are refused",
    oP.Refusals() = nR0 + 3 and oP.TempoInBpm() = 120)

? ""
? "-- Scene 3: the offline performance puts every note on its frame --"
? "   Each note's onset is found by a threshold in the PERFORMANCE and held"
? "   against where the score says it is PLUS that note's own onset, read the"
? "   same way in the note alone -- so a drum whose attack takes a few samples"
? "   is not blamed on the placement."

# THE FIRST VERSION OF THIS SCENE FAILED, AND IT WAS THE INSTRUMENT. The
# strokes were half a beat long at half-beat spacing, so each one ended where
# the next began and its tail was still above the threshold there: every
# "onset" was found at the very start of the search window, 400 frames early,
# and scene 4 reported 8.33 ms. Scene 4 ALSO showed the ring's output equal to
# the offline render to the sample -- so the placement could not be what was
# 400 frames off. An onset threshold can only read a note that begins in
# silence. So the strokes are now staccato, and the instrument REFUSES a note
# that does not begin in silence rather than reading it wrong; the count of
# refusals is asserted to be zero.
oG = StzScoreQ().On(:Drumkit).Tempo(150).Swing(0.6)
for i = 1 to 12
	switch i % 3
	on 1  oG.Stroke(:kick, 0.2)
	on 2  oG.Stroke(:hihat, 0.2)
	on 0  oG.Stroke(:snare, 0.2)
	off
	oG.Rest(0.3)
next
oRd = new stzScoreRenderer(oG)
oPerf = oRd.Offline()
nWorstF = OnsetWorst(oPerf, oRd, oG)
? "   12 strokes, 150 BPM, swung 0.6: worst onset error " + nWorstF +
  " frames, " + nUnreadable + " unreadable"
Chk("every stroke begins in silence, so the instrument can read it", nUnreadable = 0)
Chk("every stroke starts on its frame, to the sample", nWorstF = 0)
Chk("a repeated note is rendered ONCE: 12 strokes, 3 distinct",
    oRd.NotesRendered() = 3)
oRd.Release()

? ""
? "-- Scene 4: THE KILL CRITERION, from Ring, on the real-time path --"
? "   200 notes at 180 BPM. A producer thread renders the graph into a ring;"
? "   this thread posts each note ahead of it and drains the ring -- the path a"
? "   sound card takes, minus the card. With no card the producer is never"
? "   waiting for a speaker, so it runs as fast as the machine can: harder for"
? "   the scheduler than a device, not easier."

oKill = StzScoreQ().On(:Drumkit).Tempo(180)
for i = 1 to 200
	switch i % 3
	on 1  oKill.Stroke(:kick, 0.4)
	on 2  oKill.Stroke(:hihat, 0.4)
	on 0  oKill.Stroke(:snare, 0.4)
	off
	oKill.Rest(0.6)
next
oSch = StzSchedulerQ(oKill)
t0 = clock()
oCap = oSch.RenderThroughRing()
nSecs = (clock() - t0) / clockspersecond()
? "   " + oKill.Seconds() + " s of music through the ring in " + nSecs + " s of wall time"
? "   placed " + oSch.Placed() + ", late " + oSch.Late() + ", posts refused " +
  oSch.PostsRefused() + ", lookahead " + oSch.Lookahead() + " frames"
nWorstK = OnsetWorst(oCap, oSch.Renderer(), oKill)
nWorstMs = nWorstK * 1000 / nRate
? "   worst onset error over 200 notes: " + nWorstK + " frames = " + nWorstMs +
  " ms, " + nUnreadable + " unreadable"
Chk("all 200 begin in silence, so all 200 are READ, not assumed", nUnreadable = 0)
Chk("all 200 placed, none late", oSch.Placed() = 200 and oSch.Late() = 0)
Chk("KILL CRITERION: worst onset error under 1 ms across 200 notes at 180 BPM",
    nWorstMs < 1)
oOff = oKill.ToSound()
Chk("the ring's output and the offline render are the same length",
    oOff.Frames() = oCap.Frames())
StzEngineSoundMixInto(oCap.BufferId(), oOff.BufferId(), 1, -1)
nDiff = oCap.Peak()
? "   ring minus offline, worst sample: " + nDiff
Chk("and the SAME, sample for sample: live and offline cannot disagree", nDiff = 0)
oSch.Release()

? ""
? "   Where notes OVERLAP -- a harp over a guitar bass, rings into each other --"
? "   several notes are summed into one sample, and f32 addition is not"
? "   associative: the ORDER of the sum is visible to this comparison."
# THE FIRST VERSION OF THIS CHECK WAS A BOUND, and the bound hid a defect. It
# asked for "within a millionth", passed, and printed 30 billionths on one run
# and 60 on the next. The same score, rendered live twice, came out different:
# the engine summed notes in SLOT order, and which slot a note gets depends on
# which notes had retired when it was placed -- thread timing. The engine now
# sums in START order, the order the offline render uses, so the check is
# equality again, and it runs twice to show the answer no longer moves.
oH = StzScoreOfQ("c5 e5 g5 c6 b5 g5 e5 d5").On(:Harp).Tempo(160)
oH.Together(StzScoreOfQ("c3 ~ g2 ~ a2 ~ e2 ~").On(:Guitar))
oOffH = oH.ToSound()
aDiffH = []
nLateH = 0
for nRun = 1 to 2
	oSchH = StzSchedulerQ(oH)
	oCapH = oSchH.RenderThroughRing()
	StzEngineSoundMixInto(oCapH.BufferId(), oOffH.BufferId(), 1, -1)
	aDiffH + oCapH.Peak()
	nLateH += oSchH.Late()
	oSchH.Release()
next
? "   two parts, overlapping, rendered live twice: late " + nLateH +
  ", worst sample difference from offline " + aDiffH[1] + " and " + aDiffH[2]
Chk("two overlapping parts, twice: none late, and IDENTICAL to the offline render both times",
    nLateH = 0 and aDiffH[1] = 0 and aDiffH[2] = 0)

? ""
? "-- Scene 5: a scheduler that is NOT ahead is caught -- the negative sibling --"
? "   The same 200 notes posted only one block ahead of the render clock, while"
? "   the producer runs a ring ahead of what is drained."
oSchL = StzSchedulerQ(oKill)
oSchL.SetLookahead(512)
oCapL = oSchL.RenderThroughRing()
? "   late " + oSchL.Late() + " of 200, the worst by " + oSchL.LateMaxInMs() + " ms"
Chk("the engine COUNTS the late notes", oSchL.Late() > 0)
Chk("and the worst is far past the 1 ms bar -- the instrument can see failure",
    oSchL.LateMaxInMs() > 1)
oSchL.Release()

? ""
? "   For the record, what MU0 spike 2 measured with the block-start trigger:"
? "   mean 4.81 ms late, worst 9.48 ms. The timeline above: 0 frames. The ear"
? "   question MU0 left open -- 'does 9.5 ms read as swing?' -- no longer decides"
? "   whether sub-block placement is built. The kill criterion decided it."

? ""
? "-- Scene 6: THE PHASE GATE -- the first line makes a sound --"
? "   Plan section 7: the one-line test runs at the close of every phase from"
? "   MU1 on. It could not run at MU1's close: there was no StzMusicQ, and MU1's"
? "   STATUS did not say so. It runs here."

t0 = clock()
oM = StzMusicQ()
oMs = oM.ToSound("c e g c5")
nT = (clock() - t0) / clockspersecond()
? "   StzMusicQ().ToSound(" + char(34) + "c e g c5" + char(34) + "): " +
  oMs.Duration() + " s of sound, ready in " + nT + " s"
Chk("the one line renders, with no refusal", isObject(oMs) and oMs.Frames() > 0 and
    oM.Refusals() = 0)
aWant = [ 261.6256, 329.6276, 391.9954, 523.2511 ]
nWorstC = 0
oMono = oMs.ToMonoQ()
for k = 1 to 4
	nHz = StzEngineSoundMeasurePitch(oMono.BufferId(), (k - 1) * 24000 + 4801, aWant[k], 0)
	nC = fabs(Cents(nHz, aWant[k]))
	if nC > nWorstC  nWorstC = nC ok
next
? "   the four notes, read back from the one line's sound: worst " + nWorstC + " cents"
Chk("the one line plays C E G C, each within 2 cents", nWorstC < 2)
Chk("and is ready well inside the plan's ten seconds", nT < 10)
? "   A device adds its ring, 16384 frames = 341 ms, before the first note is"
? "   HEARD. That number is the native path's; the browser's is 10 ms (plan S3)."

? ""
? "-- The listener's line --"
? "   MU2 is timing, and timing is measured: 0 frames. Whether the swung groove"
? "   in sound_mu2_demo.ring FEELS like swing -- and whether 0.6 or 2/3 is the"
? "   right default -- is not a number. UNPERCEIVED as of this writing."

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

# The first frame (1-based) from `nFrom` where |channel 1| exceeds `nThr`.
func Mu2FirstAbove poSnd, nFrom, nTo, nThr
	for _f_ = nFrom to nTo
		if fabs(poSnd.SampleAt(_f_, 1)) > nThr  return _f_ ok
	next
	return 0

# For every note of the plan: where the performance crosses the threshold,
# against where the plan put the note plus that note's own crossing. The worst
# difference, in frames. The note alone is read at threshold/gain, because in
# the performance it was scaled by the renderer's gain. A note whose search
# window does not START in silence is not read at all -- it is counted in
# nUnreadable, because a threshold there answers "where the last note's tail
# was", not "where this note began".
func OnsetWorst poPerf, poRend, poScore
	nUnreadable = 0
	_thr_ = 0.01
	_g_ = poRend.Gain()
	_worst_ = 0
	_aOwn_ = []
	for _p_ in poRend.Plan()
		_own_ = 0
		for _o_ in _aOwn_
			if _o_[1] = _p_[2]  _own_ = _o_[2] ok
		next
		if _own_ = 0
			_oN_ = StzSoundFromBufferQ(_p_[2])
			_own_ = Mu2FirstAbove(_oN_, 1, _oN_.Frames(), _thr_ / _g_)
			_aOwn_ + [ _p_[2], _own_ ]
		ok
		_want_ = _p_[1] + _own_                     # 1-based frame of the crossing
		_from_ = _want_ - 400
		if _from_ < 1  _from_ = 1 ok
		# silence BEFORE the expected onset: [want-400, want-50], clipped at
		# frame 1 (the first note has nothing before it, and that is silence)
		if _want_ - 50 >= _from_
			if Mu2FirstAbove(poPerf, _from_, _want_ - 50, _thr_) > 0
				nUnreadable++
				loop
			ok
		ok
		_got_ = Mu2FirstAbove(poPerf, _from_, _want_ + 4000, _thr_)
		if _got_ = 0
			_d_ = 99999
		else
			_d_ = fabs(_got_ - _want_)
		ok
		if _d_ > _worst_  _worst_ = _d_ ok
	next
	return _worst_
