# MU3 -- the pattern language and live loops. Rhythm is a string, a pattern
# is a function of time, and a loop redefined while it plays changes on a
# cycle boundary.
#
# Kill criterion (plan section 6): "if a change ever lands mid-bar, or the
# console and the speakers disagree by more than one cycle, it is not live
# coding and is not called that."

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0

pr()
decimals(4)
nRate = 48000

? "== MU3: rhythm is a string, and a redefinition lands on a boundary =="
? ""

? "-- Scene 1: the mini-notation, read by the pattern it makes --"

Chk("'bd ~ sn [hh hh]': kick at 0, snare at 1/2, two hats sharing the last quarter",
    Shape("bd ~ sn [hh hh]", 0) = "kick@0 snare@0.5 hihat@0.75 hihat@0.875")
Chk("'<c e g>' alternates: C4 on cycle 0, E4 on 1, G4 on 2, C4 again on 3",
    Shape("<c e g>", 0) = "C4@0" and Shape("<c e g>", 1) = "E4@0" and
    Shape("<c e g>", 2) = "G4@0" and Shape("<c e g>", 3) = "C4@0")
Chk("'a*2 b': the a twice in the first half", Shape("a*2 b", 0) = "A4@0 A4@0.25 B4@0.5")
Chk("'a/2': once every other cycle, two cycles long",
    Shape("a/2", 0) = "A4@0" and Shape("a/2", 1) = "" and
    StzPatternQ("a/2").CycleEvents(0)[1][2] = 2)
Chk("'a@3 b': a weighs three steps", Shape("a@3 b", 0) = "A4@0 B4@0.75")
Chk("'a!3 b': a as three steps", Shape("a!3 b", 0) = "A4@0 A4@0.25 A4@0.5 B4@0.75")
Chk("'[c, e] g': a stack -- C and E together", Shape("[c, e] g", 0) = "C4@0 E4@0 G4@0.5")
Chk("the octave carries left to right: 'c e g c5 e' ends on E5",
    Shape("c e g c5 e", 0) = "C4@0 E4@0.2 G4@0.4 C5@0.6 E5@0.8")

oDeg = StzPatternQ("hh? hh? hh? hh? hh? hh? hh? hh?")
nKept = 0
for c = 0 to 499  nKept += len(oDeg.CycleEvents(c)) next
oDeg2 = StzPatternQ("hh? hh? hh? hh? hh? hh? hh? hh?")
bSame = TRUE
for c = 0 to 99
	if Shape2(oDeg, c) != Shape2(oDeg2, c)  bSame = FALSE ok
next
? "   '?' kept " + nKept + " of 4000 over 500 cycles"
# THE FIRST HASH KEPT 2 OF 12 in the smoke test that preceded this guard: a
# sum mod a prime, one multiply, then the low digits. It is now folded and
# decided from the high end; the bound below is 4 standard deviations wide.
Chk("'?' keeps about half -- 1874..2126 of 4000", nKept >= 1874 and nKept <= 2126)
Chk("and the same text keeps the SAME ones: a guard can hold it", bSame)

aBad = [ [ "[a b", "']' is missing" ], [ "a*1.5", "whole number" ], [ "x q", "neither a note" ],
         [ "a b]", "closes nothing" ], [ "<a, b>", "inside < >" ], [ "", "empty" ] ]
nRef = 0
for b in aBad
	o = StzPatternQ(b[1])
	if NOT o.IsValid() and substr(o.LastError(), b[2]) > 0  nRef++ ok
next
? "   e.g. '[a b' -> " + StzPatternQ("[a b").LastError()
Chk("six broken patterns are refused, each saying what and where", nRef = 6)

? ""
? "-- Scene 2: the algebra --"

Chk("Fast(2) plays the cycle twice", Shape2(StzPatternQ("a b").Fast(2), 0) = "A4@0 B4@0.25 A4@0.5 B4@0.75")
Chk("Slow(2) spreads it over two", Shape2(StzPatternQ("a b").Slow(2), 0) = "A4@0" and
    Shape2(StzPatternQ("a b").Slow(2), 1) = "B4@0")
Chk("Rev plays it backwards", Shape2(StzPatternQ("a b c d").Rev(), 0) = "D4@0 C4@0.25 B4@0.5 A4@0.75")
oEv = StzPatternQ("a b c d").Every(3, :Rev)
Chk("Every(3, :Rev) reverses cycles 0 and 3 and leaves 1 and 2",
    Shape2(oEv, 0) = "D4@0 C4@0.25 B4@0.5 A4@0.75" and Shape2(oEv, 1) = "A4@0 B4@0.25 C4@0.5 D4@0.75" and
    Shape2(oEv, 3) = "D4@0 C4@0.25 B4@0.5 A4@0.75")
oOff = StzPatternQ("c5 e5 g5 b5").Off(0.25, 12)
? "   Off(0.25, 12), cycle 1: " + Shape2(oOff, 1)
Chk("Off(0.25, 12): a copy a quarter later and an octave up -- and the last note's " +
    "copy spills into the NEXT cycle",
    Shape2(oOff, 1) = "C5@0 B6@0 E5@0.25 C6@0.25 G5@0.5 E6@0.5 B5@0.75 G6@0.75" and
    Shape2(oOff, 0) = "C5@0 E5@0.25 C6@0.25 G5@0.5 E6@0.5 B5@0.75 G6@0.75")
Chk("they compose: Fast(2) of an alternation still alternates",
    Shape2(StzPatternQ("<a c>").Fast(2), 0) = "A4@0 C4@0.5")
nR0 = StzPatternQ("a").Fast(1.5).Refusals()
Chk("a fractional factor is refused, not rounded", nR0 = 1)
Chk("the period counts alternation, slowing and Every: '<a b c> d/2' -> 6, Every(4) of 'a' -> 4",
    StzPatternQ("<a b c> d/2").Period() = 6 and StzPatternQ("a").Every(4, :Rev).Period() = 4)

? ""
? "-- Scene 3: a pattern becomes a score --"
oPs = StzPatternQ("bd [hh hh] sn hh").ToScoreQ(2)
Chk("two cycles of 'bd [hh hh] sn hh' are ten events over 8 beats",
    oPs.NumberOfEvents() = 10 and oPs.Beats() = 8)
Chk("and the second cycle's snare is at beat 6", oPs.Events()[9][1] = 6 and oPs.Events()[9][6] = "snare")

? ""
? "-- Scene 4: THE KILL CRITERION -- redefinitions, while it plays --"
? "   120 BPM, a cycle is a bar: 4 beats, 2 s, 96000 frames. Two loops; four"
? "   changes made at chosen HEARD positions, one of them 0.05 cycle before a"
? "   boundary. The ring is drained here, not by a card, so every position is"
? "   exact. What came out is then held against a render built INDEPENDENTLY"
? "   from the patterns and the landing cycles Loop returned -- sample for"
? "   sample."

oL = StzLiveQ(120)
oL.CaptureInsteadOfDevice(20, FALSE)
oL.LiveLoop(:beat, "bd hh sn hh")
oL.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
aChanges = []    # [ what, heard cycle at the call, posted-ahead, landing ]

oL.WaitCycles(2.5)
nA = oL.HeardFrames() / oL.CycleFrames()
nP = PostedUpTo(oL, "tune")
K1 = oL.LiveLoopOn(:tune, "a4 c5 e5 c5", :Harp)
aChanges + [ "tune -> 'a4 c5 e5 c5'", nA, nP, K1 ]

oL.WaitCycles(1.5)
nA = oL.HeardFrames() / oL.CycleFrames()
nP = PostedUpTo(oL, "beat")
K2 = oL.Every(2, :beat, :Rev)
aChanges + [ "beat -> Every(2, :Rev)", nA, nP, K2 ]

oL.WaitCycles(1.95)
nA = oL.HeardFrames() / oL.CycleFrames()
nP = PostedUpTo(oL, "beat")
K3 = oL.LiveLoop(:beat, "bd*2 [~ sn] hh?")
aChanges + [ "beat -> 'bd*2 [~ sn] hh?'", nA, nP, K3 ]

oL.WaitCycles(1)
nA = oL.HeardFrames() / oL.CycleFrames()
nP = PostedUpTo(oL, "tune")
K4 = oL.Silence(:tune)
aChanges + [ "tune -> silence", nA, nP, K4 ]

oL.WaitCycles(3.05)
oL.Stop()
nHeardCycles = oL.HeardFrames() / oL.CycleFrames()

? ""
? "   change                           heard at   posted to   lands on"
for c in aChanges
	? "   " + Pad(c[1], 32) + " " + Pad(c[2], 10) + " " + Pad(c[3], 11) + " cycle " + c[4]
next
Chk("every change lands on the first cycle the render had not reached: 3, 5, 7, 8",
    K1 = 3 and K2 = 5 and K3 = 7 and K4 = 8)
bOneAhead = TRUE
for c in aChanges
	if c[4] - c[2] > 1 + (16384 + 5312) / 96000  bOneAhead = FALSE ok
next
Chk("each within one cycle plus a ring of the moment it was typed", bOneAhead)

oExpL = [
	[ "drumkit", [ [ 0, StzPatternQ("bd hh sn hh") ],
	               [ 5, StzPatternQ("bd hh sn hh").Every(2, :Rev) ],
	               [ 7, StzPatternQ("bd*2 [~ sn] hh?") ] ] ],
	[ "harp",    [ [ 0, StzPatternQ("c5 e5 g5 e5") ],
	               [ 3, StzPatternQ("a4 c5 e5 c5") ],
	               [ 8, NULL ] ] ] ]
oExp = Expected(oExpL, 10, 120)
oCap = oL.Capture()
? "   heard " + nHeardCycles + " cycles; captured " + oCap.Frames() + " frames; expected " +
  oExp.Frames() + " (its last notes ring past the end, and are cut there)"
StzEngineSoundMixInto(oCap.BufferId(), oExp.BufferId(), 1, -1)
nDiff = oCap.Peak()
? "   live minus the independent render, worst sample: " + nDiff
Chk("KILL CRITERION: the live output IS the render where every change lands on its " +
    "boundary -- equal, sample for sample, over 10 cycles and 4 changes", nDiff = 0)
? "   notes withdrawn " + oL.Cancelled() + ", withdrawals refused because the note was " +
  "already sounding " + oL.MidCycleChanges() + ", late " + oL.Late()
Chk("KILL CRITERION: no change landed mid-cycle -- the engine refused no withdrawal",
    oL.MidCycleChanges() = 0)
Chk("the landing cycles HAD been posted, and were withdrawn -- the mechanism was used, " +
    "not avoided", oL.Cancelled() > 0)
Chk("and no note was late", oL.Late() = 0)

? ""
? "-- Scene 5: THE KILL CRITERION -- the console and the speakers --"
? "   Notes are posted a ring + a cycle + 0.5 s ahead. At each change above,"
? "   the POSTED cycle ran ahead of the HEARD one:"
nWorstAhead = 0
for c in aChanges
	nAh = c[3] - floor(c[2])
	if nAh > nWorstAhead  nWorstAhead = nAh ok
next
? "   up to " + nWorstAhead + " cycles -- a console that printed at posting time would be " +
  "that far ahead of the sound, the disagreement VC4 paid for."
Chk("the trap is real: posting runs more than one cycle ahead of hearing", nWorstAhead > 1)

aWant = [ "cycle 0 | beat v1 | tune v1", "cycle 1 | beat v1 | tune v1",
          "cycle 2 | beat v1 | tune v1", "cycle 3 | beat v1 | tune v2",
          "cycle 4 | beat v1 | tune v2", "cycle 5 | beat v2 | tune v2",
          "cycle 6 | beat v2 | tune v2", "cycle 7 | beat v3 | tune v2",
          "cycle 8 | beat v3 | tune v3", "cycle 9 | beat v3 | tune v3" ]
aLog = oL.ConsoleLog()
bText = (len(aLog) >= 10)
bWhen = TRUE
nLagWorst = 0
for i = 1 to 10
	if i > len(aLog)  exit ok
	if aLog[i][3] != aWant[i]  bText = FALSE ok
	nLag = aLog[i][2] - oL.FrameOfCycle(i - 1)
	if nLag < 0 or nLag > 4096  bWhen = FALSE ok
	if nLag > nLagWorst  nLagWorst = nLag ok
next
for i = 1 to 10
	if i <= len(aLog)  ? "   " + aLog[i][3] ok
next
? "   (tune v3 is its silence)"
Chk("KILL CRITERION: the console names, for every cycle, the versions the speakers played " +
    "-- read from what was posted for THAT cycle", bText)
Chk("and prints each line when that cycle is HEARD: at most one drain (4096 frames, " +
    "85 ms) after its boundary -- worst " + nLagWorst, bWhen)
oL.Release()

? ""
? "-- Scene 6: rendering while playing -- on the sound card --"
? "   A capture drained by THIS thread stalls with any render on this thread, so"
? "   it cannot show what a render costs a device. A card drains on its own"
? "   thread. So: a kit loop plays on the card; then a MEZWED loop is added --"
? "   a wind that tunes itself by listening, rendered while the kit plays."
if StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1
	oD = StzLiveQ(180)
	oD.LiveLoop(:kit, "bd hh sn hh")
	oD.WaitCycles(1)
	nA = oD.HeardFrames() / oD.CycleFrames()
	t0 = clock()
	K5 = oD.LiveLoopOn(:reed, "d5 e-50 f5 g5 a5 g5 f5 e-50", :Mezwed)
	nRend = (clock() - t0) / clockspersecond()
	oD.WaitCycles(3)
	nDist = len(StzPatternQ("d5 e-50 f5 g5 a5 g5 f5 e-50").DistinctNotes(1))
	? "   the mezwed's " + nDist + " distinct notes rendered in " + nRend +
	  " s while the kit played; heard at " + nA + ", landed on cycle " + K5
	? "   (a render longer than the horizon WOULD make notes late -- and Late() would count them)"
	? "   late " + oD.Late() + ", underruns " + oD.Underruns() + ", mid-cycle " +
	  oD.MidCycleChanges() + " -- the horizon was a ring + a cycle + 0.5 s = " +
	  ((16384 + oD.CycleFrames()) / nRate + 0.5) + " s"
	Chk("a render WHILE PLAYING cost no note its frame, and the card never ran dry",
	    oD.Late() = 0 and oD.Underruns() = 0 and oD.MidCycleChanges() = 0 and K5 >= 2)
	oD.Release()
else
	nSkip++
	? "  [skip] no audio device on this machine"
ok

? ""
? "-- Scene 7: driven by the reactive loop --"
? "   A timer every 20 ms ticks the session; another redefines the tune at"
? "   1.5 s; a third stops the loop. Ring's anonymous functions see no locals,"
? "   so the session is reached through a global pointer (stzLive's header)."
oLive = StzLiveQ(240)
oLive.CaptureInsteadOfDevice(4, TRUE)
oLive.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
nKR = -1
oRx = new stzReactiveSystem()
oLive.DriveWith(oRx)
oRx.RunAfter(1500, func { nKR = oLive.LiveLoopOn(:tune, "g5 e5 c5 e5", :Harp) })
oRx.RunAfter(3200, func { oRx.Stop() })
oRx.Start()
oLive.Stop()
aRL = oLive.ConsoleLog()
? "   heard " + (oLive.HeardFrames() / nRate) + " s through the reactive loop; the " +
  "redefinition landed on cycle " + nKR
for l in aRL  ? "   " + l[3] next
bRx = len(aRL) >= 3 and nKR >= 2
if bRx
	bRx = (aRL[nKR + 1][3] = "cycle " + nKR + " | tune v2") and
	      (aRL[nKR][3] = "cycle " + (nKR - 1) + " | tune v1")
ok
Chk("the reactive loop drove it: ticks arrived, and the change landed on its cycle", bRx)
Chk("with nothing mid-cycle", oLive.MidCycleChanges() = 0)
oLive.Release()

? ""
? "-- Scene 8: refusals leave the music playing --"
oRf = StzLiveQ(120)
oRf.CaptureInsteadOfDevice(6, FALSE)
oRf.LiveLoop(:beat, "bd hh sn hh")
oRf.WaitCycles(1)
nBad = oRf.LiveLoop(:beat, "bd [hh sn")
Chk("a pattern that does not parse is refused, and the old one keeps playing",
    nBad = -1 and len(oRf.Landings()) = 1)
Chk("strokes on a piano are refused", oRf.LiveLoopOn(:x, "bd sn", :Piano) = -1)
Chk("notes on the kit are refused", oRf.LiveLoopOn(:y, "c e g", :Drumkit) = -1)
Chk("Every on a loop that does not exist is refused", oRf.Every(2, :nope, :Rev) = -1)
oRf.SetTempo(90)
Chk("and the tempo, once loops exist, is refused -- a live tempo change is not in MU3",
    oRf.Tempo() = 120)
oRf.Stop()
oRf.Release()

? ""
? "-- Scene 9: THE PHASE GATE, and the plan's own section-4 line --"
oM = StzMusicQ().Tempo(96)
oMs = oM.ToSound("c e g c5")
nWorstC = 0
oMono = oMs.ToMonoQ()
aHz = [ 261.6256, 329.6276, 391.9954, 523.2511 ]
for k = 1 to 4
	nHz = StzEngineSoundMeasurePitch(oMono.BufferId(), floor((k - 1) * 30000 + 6001), aHz[k], 0)
	nC = fabs(1200 * log(nHz / aHz[k]) / log(2))
	if nC > nWorstC  nWorstC = nC ok
next
Chk("the first line still makes C E G C, within 2 cents (worst " + nWorstC + ")", nWorstC < 2)
oP4 = StzPatternQ("dum ~ tak ~ dum dum tak ~")
oLv = StzLiveQ(96)
oLv.CaptureInsteadOfDevice(3, FALSE)
Chk("section 4's '# the rhythm names itself': 'dum ~ tak ~ dum dum tak ~' is taken by " +
    "the darbouka with no instrument named", oLv.LiveLoop(:iqa, "dum ~ tak ~ dum dum tak ~") = 0 and
    oLv.Refusals() = 0)
oLv.WaitCycles(1)
Chk("and it sounds", oLv.Capture().Peak() > 0.1)
oLv.Release()

? ""
? "-- The listener's line --"
? "   Placement is exact and every change lands on its boundary. Whether a"
? "   live loop FEELS live -- whether a change arriving up to a bar and a third"
? "   after it is typed is quick enough on the native path -- is not a number."
? "   UNPERCEIVED as of this writing. sound_mu3_demo.ring plays it."

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

func Shape cText, nCycle
	return Shape2(StzPatternQ(cText), nCycle)

func Shape2 oP, nCycle
	_s_ = ""
	for _e_ in oP.CycleEvents(nCycle)
		if _s_ != ""  _s_ += " " ok
		_s_ += _e_[4] + "@" + Num(_e_[1])
	next
	return _s_

func Num n
	_c_ = "" + n
	if substr(_c_, ".") > 0
		while right(_c_, 1) = "0"  _c_ = left(_c_, len(_c_) - 1) end
		if right(_c_, 1) = "."  _c_ = left(_c_, len(_c_) - 1) ok
	ok
	return _c_

func Pad c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " " end
	return _s_

# The last cycle posted so far for a loop, read from the ledger.
func PostedUpTo oS, cName
	_m_ = -1
	for _e_ in oS.Ledger()
		if _e_[2] = cName and _e_[1] > _m_  _m_ = _e_[1] ok
	next
	return _m_

# THE INDEPENDENT RENDER. From each loop's instrument and its versions
# [ fromCycle, pattern-or-NULL ], cycle by cycle, into a stzScore at the given
# tempo -- nothing read from the live session -- and rendered offline.
func Expected aLoops, nCycles, nBpm
	_oS_ = StzScoreQ().Tempo(nBpm)
	for _c_ = 0 to nCycles - 1
		for _l_ in aLoops
			_oP_ = NULL
			for _v_ in _l_[2]
				if _v_[1] <= _c_  _oP_ = _v_[2] ok
			next
			if isNull(_oP_)  loop ok
			_oS_.On(_l_[1])
			for _e_ in _oP_.CycleEvents(_c_)
				if _e_[3] = "stroke"
					_oS_.StrokeAt(4 * (_c_ + _e_[1]), _e_[4], 4 * _e_[2])
				else
					_oS_.NoteAt(4 * (_c_ + _e_[1]), _e_[4], 4 * _e_[2])
				ok
			next
		next
	next
	_oR_ = new stzScoreRenderer(_oS_)
	return _oR_.Offline()
