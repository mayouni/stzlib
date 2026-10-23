load "../../stzBase.ring"
load "../_narrated.ring"

# stzSoundLive: the three rows of the wave-14 defects file (CaptureInsteadOfDevice,
# WaitCycles, Landings), each reproduced and then pinned, and every public method run
# once in capture mode.
#
# SAFETY: no audio device and no microphone is ever opened here. Every session below
# calls CaptureInsteadOfDevice BEFORE anything can start, so the sound is drained into
# memory. The reactive-loop path (DriveWith with a stzReactive) is covered by
# sound_mu3_narrated.ring, Scene 7, and is not repeated here.
#
# THE GUARD MUST NOT HANG: the wait that used to hang is now bounded by the class
# itself (a deadline on the monotonic clock: 30 s more than the wait's own length, 4 x
# its length on top). The worst case of a regression is therefore a wait of about
# 32 s that ends in a refusal, not an infinite one. A subclass whose drain is dead
# (stzSoundLiveStalled, at the end of this file) proves the deadline itself, in about
# a second.
#
# START AFTER STOP (the last two scenarios): a stopped session that is started again starts a
# clean run. The heard cycle is back to -1, the console and the ledger are emptied, every loop
# posts from cycle 0 in the version it has now, the capture buffer is replaced and the last error
# is cleared; the loops, the landings, the version numbers and the refusals count are kept. Before,
# the restart began at frame 0 but kept the heard cycle and the loops' next-cycle counters, so the
# first cycles were silent and the console logged nothing until the old cycle number.
#
# EXIT CODE: every session below is released, because a capture session left RUNNING when the
# process exits crashes it (exit 139 on bash, 0xC0000005 on Windows). The first scenario used to
# leave its session running. The crash is engine-side: a bare StzEngineSoundStreamStart with no
# Stop does the same without this class; the producer thread is still running when the DLL goes.

# UNPERCEIVED: nobody has heard any of this. The evidence is frame counts, sample
# rates, peaks and wall times; whether it SOUNDS right is a human's gate.

# 240 bpm: a cycle is one bar of 4 beats = exactly 1 s = 48000 frames, so the arithmetic
# below reads in seconds.

Scenario("CaptureInsteadOfDevice: what it takes, what it refuses")
	Given("a new session at 240 bpm")
	oA = StzSoundLiveQ(240)
	Then("it plays on a device until capture is chosen", oA.OnDevice(), 1)
	Then("and has captured nothing: Capture() is an empty text", isNull(oA.Capture()), 1)
	When("a length that is not a number is given")
	oA.CaptureInsteadOfDevice("three", FALSE)
	Then("it is refused and counted", oA.Refusals(), 1)
	Then("with the reason set", SlHas(oA.LastError(), "number of seconds above 0"), 1)
	Then("and the session is still on a device", oA.OnDevice(), 1)
	When("zero seconds and then a negative length are given")
	oA.CaptureInsteadOfDevice(0, FALSE)
	oA.CaptureInsteadOfDevice(-3, FALSE)
	Then("both are refused too", oA.Refusals(), 3)
	Then("and the session is STILL on a device", oA.OnDevice(), 1)
	When("a length of 3 seconds is given")
	oA.CaptureInsteadOfDevice(3, FALSE)
	Then("it is accepted: no new refusal", oA.Refusals(), 3)
	Then("and the session is off the device", oA.OnDevice(), 0)
	When("a second call, before the start, asks for 2 seconds")
	oA.CaptureInsteadOfDevice(2, FALSE)
	Then("it replaces the first: no refusal", oA.Refusals(), 3)
	oA.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oA.WaitCycles(0.5)
	Then("the buffer is the second call's: 2 seconds = 96000 frames", oA.Capture().Frames(), 96000)
	Then("at the session's rate", oA.Capture().SampleRate(), 48000)
	Then("with two channels", oA.Capture().Channels(), 2)
	When("capture is chosen again after the loops have started")
	oA.CaptureInsteadOfDevice(5, FALSE)
	Then("it is refused and counted", oA.Refusals(), 4)
	Then("saying that the choice comes before the start", SlHas(oA.LastError(), "before the loops start"), 1)
	Then("and the running buffer is untouched: still 96000 frames", oA.Capture().Frames(), 96000)
	oA.Release()
	EndScenario()

Scenario("CaptureInsteadOfDevice: the buffer is silent beyond what was heard")
	Given("a 2 second capture, and half a cycle (0.5 s = 24000 frames) waited")
	oB = StzSoundLiveQ(240)
	oB.CaptureInsteadOfDevice(2, FALSE)
	oB.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oB.WaitCycles(0.5)
	Then("24000 frames were heard", oB.HeardFrames(), 24000)
	aSl = oB.Capture().ToList(1)
	Then("the list of the first channel has the whole buffer's frames", len(aSl), 96000)
	Then("what was heard sounds: the peak over frames 1 to 24000 is above 0.01",
		SlPeakOfRange(aSl, 1, 24000) > 0.01, 1)
	Then("and the tail past what was heard is exactly silent: the peak over 24001 to 96000 is 0",
		SlPeakOfRange(aSl, 24001, 96000), 0)
	oB.Release()
	EndScenario()

Scenario("WaitCycles: a wait longer than the capture buffer ends where the buffer ends")
	Given("a 3 second capture at 240 bpm (3 cycles fit) with one loop")
	oC = StzSoundLiveQ(240)
	oC.CaptureInsteadOfDevice(3, FALSE)
	oC.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oC.WaitCycles(1)
	oC.WaitCycles(1)
	Then("two waits that fit heard 96000 frames", oC.HeardFrames(), 96000)
	Then("and neither was refused", oC.Refusals(), 0)
	When("5 more cycles are asked, with only 1 cycle of buffer left (this used to never return)")
	nT0 = SlNow()
	oC.WaitCycles(5)
	nElapsed = SlNow() - nT0
	Then("it returned, within 10 s of the monotonic clock", nElapsed < 10, 1)
	Then("what was heard is exactly the buffer: 144000 frames", oC.HeardFrames(), 144000)
	Then("which is the 3 cycles that fit", oC.HeardFrames() / oC.CycleFrames(), 3)
	Then("the cut was counted as a refusal", oC.Refusals(), 1)
	Then("saying how long the buffer is and how many cycles were asked",
		SlHas(oC.LastError(), "capture buffer of 3 s ends before 5 more cycles"), 1)
	Then("cycle 3 was heard begin, at the very end", oC.HeardCycle(), 3)
	Then("the buffer is a valid sound: 144000 frames", oC.Capture().Frames(), 144000)
	Then("at 48000 Hz", oC.Capture().SampleRate(), 48000)
	Then("in 2 channels", oC.Capture().Channels(), 2)
	Then("3 seconds long", oC.Capture().Duration(), 3)
	Then("it sounds where the loop plays: peak above 0.01", oC.Capture().Peak() > 0.01, 1)
	Then("and never clips: peak at most 1", oC.Capture().Peak() <= 1, 1)
	Then("no note was late", oC.Late(), 0)
	When("the full buffer is waited on again")
	oC.WaitCycles(1)
	Then("it returns at once, hears nothing more", oC.HeardFrames(), 144000)
	Then("and is refused again", oC.Refusals(), 2)
	When("a wait of 0 cycles is asked of the full buffer")
	oC.WaitCycles(0)
	Then("it is not a cut: no new refusal", oC.Refusals(), 2)
	oC.Release()
	EndScenario()

Scenario("WaitCycles: waits that fit are not touched")
	Given("a 3 second capture and a wait of exactly 3 cycles, the whole buffer")
	oD = StzSoundLiveQ(240)
	oD.CaptureInsteadOfDevice(3, FALSE)
	oD.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oD.WaitCycles(3)
	Then("144000 frames were heard", oD.HeardFrames(), 144000)
	Then("with no refusal: filling the buffer exactly is not a cut", oD.Refusals(), 0)
	Given("another session, a wait of 2 cycles in the same 3 seconds")
	oE = StzSoundLiveQ(240)
	oE.CaptureInsteadOfDevice(3, FALSE)
	oE.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oE.WaitCycles(2)
	Then("96000 frames were heard", oE.HeardFrames(), 96000)
	Then("with no refusal", oE.Refusals(), 0)
	Then("and the heard cycle is the last boundary crossed, cycle 2 beginning at frame 96000", oE.HeardCycle(), 2)
	Then("the console has one line per boundary heard: cycles 0, 1 and 2", len(oE.ConsoleLog()), 3)
	oD.Release()
	oE.Release()
	EndScenario()

Scenario("WaitCycles: what it refuses")
	Given("a session that has not started")
	oF = StzSoundLiveQ(240)
	oF.CaptureInsteadOfDevice(2, FALSE)
	oF.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oF.WaitCycles("two")
	Then("a text is refused and counted", oF.Refusals(), 1)
	oF.WaitCycles(-1)
	Then("so is a negative number", oF.Refusals(), 2)
	Then("and neither started the session", oF.IsRunning(), 0)
	oF.WaitCycles(1)
	Then("a valid wait then starts it", oF.IsRunning(), 1)
	Then("and hears 48000 frames", oF.HeardFrames(), 48000)
	Then("with the refusals unchanged", oF.Refusals(), 2)
	oF.Release()
	EndScenario()

Scenario("WaitCycles: paced capture is cut at the end of its buffer too")
	Given("a paced capture of 1 second at 400 bpm (a cycle is 0.6 s), 5 cycles asked")
	oG = StzSoundLiveQ(400)
	oG.CaptureInsteadOfDevice(1, TRUE)
	oG.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	nT0 = SlNow()
	oG.WaitCycles(5)
	nElapsed = SlNow() - nT0
	Then("it returned: paced, so about the buffer's own second, never more than 10 s", nElapsed < 10, 1)
	Then("and not faster than the clock it is paced by: at least 0.8 s", nElapsed >= 0.8, 1)
	Then("it heard exactly the buffer: 48000 frames", oG.HeardFrames(), 48000)
	Then("and the cut was counted", oG.Refusals(), 1)
	oG.Release()
	EndScenario()

Scenario("WaitCycles: the deadline gives up on a wait that cannot move")
	Given("a session whose drain does nothing (a subclass), a slack of 1 s, and 0.05 cycle asked")
	oS = new stzSoundLiveStalled()
	oS.SetTempo(400)
	oS.SetSlack(1)
	oS.CaptureInsteadOfDevice(2, FALSE)
	oS.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	nT0 = SlNow()
	oS.WaitCycles(0.05)
	nElapsed = SlNow() - nT0
	Then("it gave up: the deadline is 1 s + 4 x the wait (0.12 s) = 1.12 s, so at least 1 s", nElapsed >= 1, 1)
	Then("and within 6 s, not forever", nElapsed < 6, 1)
	Then("nothing was heard: the wait did not move", oS.HeardFrames(), 0)
	Then("giving up was counted as a refusal", oS.Refusals(), 1)
	Then("saying so", SlHas(oS.LastError(), "gave up after"), 1)
	When("a wait of 0 cycles is asked of the same stalled session")
	oS.WaitCycles(0)
	Then("there is nothing to wait for: it returns, no new refusal", oS.Refusals(), 1)
	oS.Release()
	EndScenario()

Scenario("Landings: the version of a loop counts its definitions and never goes back")
	Given("tune defined three times before the start, beat once, in a 4 second capture")
	oH = StzSoundLiveQ(240)
	oH.CaptureInsteadOfDevice(4, FALSE)
	oH.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oH.LiveLoopOn(:tune, "a4 c5 e5 c5", :Harp)
	oH.LiveLoopOn(:tune, "g4 c5 e5 c5", :Harp)
	oH.LiveLoop(:beat, "bd hh sn hh")
	aLan = oH.Landings()
	Then("four landings, in the order the definitions were made", len(aLan), 4)
	Then("tune is v1, v2 and v3", "" + aLan[1][2] + aLan[2][2] + aLan[3][2], "123")
	Then("beat is v1 on its own count", aLan[4][2], 1)
	Then("every one landed on cycle 0 before the start", "" + aLan[1][3] + aLan[2][3] + aLan[3][3] + aLan[4][3], "0000")
	Then("and the heard cycle at each call was -1", aLan[1][4] + aLan[2][4] + aLan[3][4] + aLan[4][4], -4)
	When("a pattern that does not parse is defined for tune")
	nBad = oH.LiveLoopOn(:tune, "bd [hh sn", :Harp)
	Then("it is refused", nBad, -1)
	Then("and it consumed no version: still four landings", len(oH.Landings()), 4)
	When("the session runs 1 cycle and tune is redefined while it plays")
	oH.WaitCycles(1)
	nK = oH.LiveLoopOn(:tune, "d4 c5 e5 c5", :Harp)
	aLan = oH.Landings()
	Then("a fifth landing was added", len(aLan), 5)
	Then("it is v4, not v2: the number continues", aLan[5][2], 4)
	Then("it landed on the cycle the call returned", aLan[5][3], nK)
	Then("which is after the cycle then heard: 2 or later", nK >= 2, 1)
	Then("the heard cycle at the call was 1", aLan[5][4], 1)
	When("the session runs 2 cycles more")
	oH.WaitCycles(2)
	aTune = SlVersionsOf(oH.ConsoleLog(), "tune")
	Then("the console has a line for each of the 4 cycles heard, 0 to 3", len(oH.ConsoleLog()), 4)
	Then("tune is named in every line", len(aTune), 4)
	Then("its version never goes back from one line to the next", SlNonDecreasing(aTune), 1)
	Then("it is v3 until the landing cycle", SlVersionsBefore(aTune, nK, 3), 1)
	Then("and v4 from the landing cycle on", SlVersionsFrom(aTune, nK, 4), 1)
	aBeat = SlVersionsOf(oH.ConsoleLog(), "beat")
	Then("beat, never redefined, is v1 on every line", SlVersionsFrom(aBeat, 0, 1), 1)
	oH.Release()
	EndScenario()

Scenario("Landings: a silence before the start is a version like any other")
	Given("tune defined, silenced by Hush, and defined again, all before the start")
	oI = StzSoundLiveQ(240)
	oI.CaptureInsteadOfDevice(2, FALSE)
	oI.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	nHush = oI.Hush()
	oI.LiveLoopOn(:tune, "e5 g5 c5 e5", :Harp)
	aLan = oI.Landings()
	Then("Hush landed on cycle 0", nHush, 0)
	Then("three landings: v1, v2 (the silence) and v3", "" + aLan[1][2] + aLan[2][2] + aLan[3][2], "123")
	oI.WaitCycles(1)
	nK = oI.Silence(:tune)
	aLan = oI.Landings()
	Then("a silence while running continues the count: v4", aLan[4][2], 4)
	Then("and lands on the cycle Silence returned", aLan[4][3], nK)
	oI.WaitCycles(1)
	aTune = SlVersionsOf(oI.ConsoleLog(), "tune")
	Then("the console's tune versions never go back either", SlNonDecreasing(aTune), 1)
	oI.Release()
	EndScenario()

Scenario("Every public method, once, in capture mode")
	Given("a session at 240 bpm with a callback on each heard cycle")
	$aSlSeen = []
	oJ = StzSoundLiveQ(240)
	Then("StzSoundLiveQ set the speed: Tempo is 240", oJ.Tempo(), 240)
	Then("CycleFrames at 240 bpm is 48000", oJ.CycleFrames(), 48000)
	Then("FrameOfCycle(2) is 96000", oJ.FrameOfCycle(2), 96000)
	oJ.SetTempo(10)
	Then("SetTempo refuses a speed outside 20 to 400", oJ.Refusals(), 1)
	Then("and keeps the speed", oJ.Tempo(), 240)
	oJ.SetDefaultInstrument("Harp")
	oJ.CaptureInsteadOfDevice(4, FALSE)
	oJ.OnCycle("SlFeed")
	Then("Start with no loops is refused", oJ.Start(), 0)
	Then("saying there are no loops", SlHas(oJ.LastError(), "no loops"), 1)
	Then("Hush with no loops answers -1", oJ.Hush(), -1)
	Then("Silence of an unknown loop answers -1", oJ.Silence(:nope), -1)
	Then("Every of an unknown loop answers -1", oJ.Every(2, :nope, :Rev), -1)
	Then("LiveLoop lands on cycle 0 before the start", oJ.LiveLoop(:beat, "bd hh sn hh"), 0)
	Then("LiveLoopOn lands on cycle 0 before the start", oJ.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp), 0)
	oPad = StzSoundPatternQ("c4 e4").Fast(2)
	Then("LiveLoopOf takes a pattern object", oJ.LiveLoopOf(:pad, oPad, "harp"), 0)
	Then("LiveLoopOf refuses what is not a pattern", oJ.LiveLoopOf(:bad, "c4 e4", "harp"), -1)
	Then("Every with a transform the pattern refuses answers -1", oJ.Every(2, :beat, :Nope), -1)
	Then("Every with a valid transform lands on cycle 0 before the start", oJ.Every(2, :beat, :Rev), 0)
	Then("nothing runs yet", oJ.IsRunning(), 0)
	Then("RenderFrames is 0 before the start", oJ.RenderFrames(), 0)
	Then("HeardFrames is 0 before the start", oJ.HeardFrames(), 0)
	Then("HeardCycle is -1 before the start", oJ.HeardCycle(), -1)
	Then("Ledger is empty before the start", len(oJ.Ledger()), 0)
	When("the session starts")
	Then("Start answers 1", oJ.Start(), 1)
	Then("and asking again while running answers 1", oJ.Start(), 1)
	Then("IsRunning is 1", oJ.IsRunning(), 1)
	Then("RenderFrames is past 0: the first window is posted", oJ.RenderFrames() >= 0, 1)
	Then("the unpaced Tick does not drain: nothing is heard until a wait", oJ.Tick().HeardFrames(), 0)
	oJ.WaitCycles(1.5)
	Then("HeardFrames after 1.5 cycles is 72000", oJ.HeardFrames(), 72000)
	Then("HeardCycle is 1", oJ.HeardCycle(), 1)
	Then("ConsoleLog has one line per boundary: 2", len(oJ.ConsoleLog()), 2)
	Then("its first line names the versions of cycle 0",
		oJ.ConsoleLog()[1][3], "cycle 0 | beat v2 | tune v1 | pad v1")
	Then("the callback was called once per line", len($aSlSeen), 2)
	Then("with the same text", $aSlSeen[2], oJ.ConsoleLog()[2][3])
	Then("Ledger holds what was posted", len(oJ.Ledger()) > 0, 1)
	nKs = oJ.Silence(:pad)
	Then("Silence of a running loop lands on a later cycle", nKs >= 2, 1)
	nKh = oJ.Hush()
	oJ.WaitCycles(1)
	Then("redefinitions while running withdrew posted notes: Cancelled is above 0 (the producer applies a withdrawal on its own thread, so it is read a cycle later)",
		oJ.Cancelled() > 0, 1)
	Then("Hush answers the cycle of the last loop's landing", nKh >= nKs, 1)
	Then("and none landed mid-cycle: MidCycleChanges is 0", oJ.MidCycleChanges(), 0)
	Then("no note was late", oJ.Late(), 0)
	Then("NotesRenderedLive is a number", isNumber(oJ.NotesRenderedLive()), 1)
	Then("SecondsRendering is above 0: the notes were rendered", oJ.SecondsRendering() > 0, 1)
	Then("DrainShortfall is 0 outside paced capture", oJ.DrainShortfall(), 0)
	Then("Underruns is 0 in capture mode", oJ.Underruns(), 0)
	Then("OnDevice is 0", oJ.OnDevice(), 0)
	Then("Renderer is an object", isObject(oJ.Renderer()), 1)
	nRef0 = oJ.Refusals()
	oJ.DriveWith(5)
	Then("DriveWith refuses what is not a stzReactive", oJ.Refusals(), nRef0 + 1)
	oJ.Stop()
	Then("Stop ends the performance", oJ.IsRunning(), 0)
	Then("and keeps what was heard: 72000 frames plus the cycle waited after Hush", oJ.HeardFrames(), 120000)
	oJ.Stop()
	Then("Stop on a stopped session does nothing", oJ.IsRunning(), 0)
	oJ.Release()
	Then("Release frees the graph and the notes without error", oJ.IsRunning(), 0)
	EndScenario()

Scenario("Tick drains in paced capture")
	Given("a paced capture at 400 bpm, started, then 0.3 s of wall time")
	oK = StzSoundLiveQ(400)
	oK.CaptureInsteadOfDevice(1, TRUE)
	oK.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oK.Start()
	sleep(0.3)
	oK.Tick()
	nHeardK = oK.HeardFrames()
	Then("some frames were drained by Tick alone", nHeardK > 0, 1)
	Then("and no more than the buffer holds", nHeardK <= 48000, 1)
	oK.Release()
	EndScenario()

Scenario("Start after Stop: a stopped session that is started again starts clean")
	Given("a 4 second capture at 240 bpm, with tune and beat defined, and a refusal made on purpose")
	$aSlSeen = []
	oR1 = StzSoundLiveQ(240)
	oR1.CaptureInsteadOfDevice(4, FALSE)
	oR1.OnCycle("SlFeed")
	oR1.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oR1.LiveLoop(:beat, "bd hh sn hh")
	oR1.WaitCycles("two")
	nRef1 = oR1.Refusals()
	Then("the refusal was counted", nRef1, 1)
	Then("and its reason is set", SlHas(oR1.LastError(), "number of cycles"), 1)
	When("it runs 3 cycles, tune is redefined while it plays, and it is stopped")
	oR1.WaitCycles(3)
	Then("run 1 heard 3 cycles of frames: 144000", oR1.HeardFrames(), 144000)
	Then("the heard cycle is 3: the boundary of cycle 3 is crossed at frame 144000", oR1.HeardCycle(), 3)
	Then("the console has one line for each of the cycles 0, 1, 2 and 3", SlCycleNumbers(oR1.ConsoleLog()), "0123")
	Then("the first run's first line names the versions it posted", oR1.ConsoleLog()[1][3], "cycle 0 | tune v1 | beat v1")
	Then("the refusal made before the start was not cleared by the first start", SlHas(oR1.LastError(), "number of cycles"), 1)
	nK1 = oR1.LiveLoopOn(:tune, "d4 c5 e5 c5", :Harp)
	Then("the redefinition while playing landed later than the heard cycle", nK1 > 3, 1)
	oR1.Stop()
	Then("it is stopped", oR1.IsRunning(), 0)
	Given("the stopped session, read before anything restarts it")
	Then("the heard frames are still 144000", oR1.HeardFrames(), 144000)
	Then("the heard cycle is still 3", oR1.HeardCycle(), 3)
	Then("the console still has its 4 lines", len(oR1.ConsoleLog()), 4)
	Then("the ledger still holds what was posted", len(oR1.Ledger()) > 0, 1)
	Then("the capture buffer is still there: 192000 frames", oR1.Capture().Frames(), 192000)
	Then("the callback was called for the 4 cycles heard", len($aSlSeen), 4)
	nLan1 = len(oR1.Landings())
	Then("three landings so far: tune v1, beat v1 and tune v2", nLan1, 3)
	Then("tune is at v2 and the count is the loop's own", oR1.Landings()[3][2], 2)
	When("it is started again")
	$aSlSeen = []
	Then("Start answers 1", oR1.Start(), 1)
	Then("it is running", oR1.IsRunning(), 1)
	Then("the first boundary heard is cycle 0 again: the heard cycle is 0, not 3", oR1.HeardCycle(), 0)
	Then("the console was emptied and holds the line of cycle 0 only", len(oR1.ConsoleLog()), 1)
	Then("that line names the version each loop has now: tune v2 plays from cycle 0", oR1.ConsoleLog()[1][3], "cycle 0 | tune v2 | beat v1")
	Then("the ledger holds only the new run: no row for a cycle past the first window", SlLedgerHasNoCycleAbove(oR1.Ledger(), 4), 1)
	Then("... and both loops were posted for cycle 0", SlLedgerCountAt(oR1.Ledger(), 0), 2)
	Then("the last error is cleared", oR1.LastError(), "")
	Then("the refusals count is the session's: kept at 1", oR1.Refusals(), nRef1)
	Then("the capture buffer is a new one of the same length", oR1.Capture().Frames(), 192000)
	When("it runs 3 cycles")
	oR1.WaitCycles(3)
	Then("run 2 heard frames from 0 again: 144000, not 288000", oR1.HeardFrames(), 144000)
	Then("the heard cycle numbers are 0 to 3 again", SlCycleNumbers(oR1.ConsoleLog()), "0123")
	Then("the callback was called for cycles 0 to 3: the first cycles are no longer silent", len($aSlSeen), 4)
	Then("... the first with the text of cycle 0", $aSlSeen[1], "cycle 0 | tune v2 | beat v1")
	Then("... the last with the text of cycle 3", $aSlSeen[4], "cycle 3 | tune v2 | beat v1")
	Then("the loops are posted from the first cycle: the first second of the capture sounds, peak above 0.01",
		SlPeakOfRange(oR1.Capture().ToList(1), 1, 48000) > 0.01, 1)
	Then("no note was late", oR1.Late(), 0)
	Then("no withdrawal was refused: nothing landed mid-cycle", oR1.MidCycleChanges(), 0)
	Then("the landings were not touched by the restart: still 3", len(oR1.Landings()), nLan1)
	Then("the refusal count is still the session's", oR1.Refusals(), nRef1)
	When("tune is defined again in the second run, and the session is stopped and run a third time")
	nK2 = oR1.LiveLoopOn(:tune, "e5 g5 c5 e5", :Harp)
	Then("the new definition is v3: the version never goes back", oR1.Landings()[4][2], 3)
	oR1.Stop()
	$aSlSeen = []
	oR1.WaitCycles(3)
	Then("run 3 heard 144000 frames from 0", oR1.HeardFrames(), 144000)
	Then("with the heard cycles 0 to 3 once more", SlCycleNumbers(oR1.ConsoleLog()), "0123")
	Then("and the first line names tune v3", oR1.ConsoleLog()[1][3], "cycle 0 | tune v3 | beat v1")
	Then("the callback was called 4 times in run 3", len($aSlSeen), 4)
	oR1.Release()
	EndScenario()

Scenario("Start after Stop: the negative siblings, a stop with no restart and a start that is not a restart")
	Given("a stopped session that is not started again")
	oR2 = StzSoundLiveQ(240)
	oR2.CaptureInsteadOfDevice(3, FALSE)
	oR2.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oR2.WaitCycles(2)
	oR2.Stop()
	Then("the heard frames stay readable: 96000", oR2.HeardFrames(), 96000)
	Then("the heard cycle stays readable: 2", oR2.HeardCycle(), 2)
	Then("the console stays readable: cycles 0, 1 and 2", SlCycleNumbers(oR2.ConsoleLog()), "012")
	Then("the ledger stays readable and is not empty", len(oR2.Ledger()) > 0, 1)
	Then("the capture stays readable: 144000 frames", oR2.Capture().Frames(), 144000)
	Then("and it still sounds where it was heard: peak above 0.01", oR2.Capture().Peak() > 0.01, 1)
	Then("reading it twice gives the same answer", oR2.HeardCycle() + oR2.HeardFrames(), 96002)
	Then("the loop's definition is still there: one landing, v1", oR2.Landings()[1][2], 1)
	Then("a second Stop changes nothing", oR2.Stop().HeardCycle(), 2)
	Then("and the session is not running", oR2.IsRunning(), 0)
	oR2.Release()
	Given("a session that is started twice without a stop in between")
	oR3 = StzSoundLiveQ(240)
	oR3.CaptureInsteadOfDevice(3, FALSE)
	oR3.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oR3.WaitCycles(2)
	Then("Start while running answers 1", oR3.Start(), 1)
	Then("and does not reset the run: the heard cycle is still 2", oR3.HeardCycle(), 2)
	Then("nor the frames heard: 96000", oR3.HeardFrames(), 96000)
	Then("nor the console: 3 lines", len(oR3.ConsoleLog()), 3)
	oR3.Release()
	Given("a session whose first start follows a refusal, which is not a restart")
	oR4 = StzSoundLiveQ(240)
	oR4.CaptureInsteadOfDevice(2, FALSE)
	oR4.SetTempo(5)
	oR4.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oR4.Start()
	Then("the first start keeps the last error: it was not stopped before", SlHas(oR4.LastError(), "beats per minute"), 1)
	Then("and the refusal count", oR4.Refusals(), 1)
	oR4.Release()
	Given("a stopped session whose loops are all silenced before it is started again")
	oR5 = StzSoundLiveQ(240)
	oR5.CaptureInsteadOfDevice(2, FALSE)
	oR5.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
	oR5.WaitCycles(1)
	oR5.Hush()
	oR5.Stop()
	oR5.WaitCycles(1)
	Then("the restarted run hears 48000 frames from 0", oR5.HeardFrames(), 48000)
	Then("and the silence is the loop's version now: the capture is silent", oR5.Capture().Peak() < 0.001, 1)
	Then("the heard cycles restarted too: 0 and 1", SlCycleNumbers(oR5.ConsoleLog()), "01")
	oR5.Release()
	EndScenario()

Summary()

# ---- helpers (at the end: top-level code after a func belongs to that func) ----

func SlNow()
	return StzEngineWatchTimestampNs() / 1000000000

func SlHas(cText, cSub)
	return (substr(cText, cSub) > 0)

func SlFeed(cText)
	$aSlSeen + cText

func SlPeakOfRange(aList, nFrom, nTo)
	nPk = 0
	for i = nFrom to nTo
		nV = aList[i]
		if nV < 0  nV = -nV ok
		if nV > nPk  nPk = nV ok
	next
	return nPk

# the version numbers of one loop, line by line, from a console log
func SlVersionsOf(aLog, cLoop)
	aOut = []
	for i = 1 to len(aLog)
		cLine = aLog[i][3]
		nAt = substr(cLine, "| " + cLoop + " v")
		if nAt > 0
			cRest = right(cLine, len(cLine) - (nAt + len(cLoop) + 3))
			nSp = substr(cRest, " ")
			if nSp > 0  cRest = left(cRest, nSp - 1) ok
			aOut + (0 + cRest)
		ok
	next
	return aOut

# the cycle numbers of a console log, written one after the other: "0123"
func SlCycleNumbers(aLog)
	cOut = ""
	for i = 1 to len(aLog)
		cOut += aLog[i][1]
	next
	return cOut

# 1 when no row of a ledger is for a cycle above nCycle
func SlLedgerHasNoCycleAbove(aLedger, nCycle)
	for i = 1 to len(aLedger)
		if aLedger[i][1] > nCycle  return 0 ok
	next
	return 1

# how many rows of a ledger are for the cycle nCycle
func SlLedgerCountAt(aLedger, nCycle)
	nCount = 0
	for i = 1 to len(aLedger)
		if aLedger[i][1] = nCycle  nCount++ ok
	next
	return nCount

func SlNonDecreasing(aNums)
	for i = 2 to len(aNums)
		if aNums[i] < aNums[i - 1]  return 0 ok
	next
	return 1

# every line before the cycle nCycle (lines are cycles 0, 1, ...) carries version nVer
func SlVersionsBefore(aNums, nCycle, nVer)
	for i = 1 to len(aNums)
		if (i - 1) < nCycle and aNums[i] != nVer  return 0 ok
	next
	return 1

func SlVersionsFrom(aNums, nCycle, nVer)
	for i = 1 to len(aNums)
		if (i - 1) >= nCycle and aNums[i] != nVer  return 0 ok
	next
	return 1

# A session whose drain is dead, to prove the wait's own deadline: the ring is never
# read, so the heard frames cannot move.
class stzSoundLiveStalled from stzSoundLive

	def SetSlack(pnSeconds)
		@nWaitSlack = pnSeconds

	def _Drain(pnFrames)
		return
