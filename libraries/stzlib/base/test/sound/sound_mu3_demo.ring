# MU3 -- LIVE LOOPS, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_mu3_demo.ring
#
# Two short live sets. Each is a script of redefinitions made WHILE the loops
# play -- the way a live coder works, with the typing replaced by WaitCycles
# so it can be repeated. Each set runs twice: first drained here into a WAV
# (exact, repeatable: mu3_NN_*.wav), then LIVE on the sound card, where the
# console prints each cycle as it is HEARD, naming the version of every loop
# that is sounding.
#
# What to listen for: every change arrives on a bar line, never inside a bar.
# And the one thing no number settles: does it feel LIVE? A change arrives up
# to a bar and a third after it is made on this native path (a ring of 341 ms
# plus the bar in progress); the browser's is 10 ms (plan section 3, MU6).

load "../../stzBase.ring"

pr()
decimals(2)

? "=================================================================="
? " MU3 -- live loops: redefine while it plays, land on the bar"
? "=================================================================="

aSets = [
	[ "mu3_01_live_set.wav",
	  "darbouka, bendir and a mezwed -- NOT yet a tab' (universes are MU4)", 100, 10 ],
	[ "mu3_02_groove.wav",
	  "a Tidal-style groove: bd*2, a chance hat, a bass that alternates, an Off harp", 120, 10 ] ]

for i = 1 to len(aSets)
	s = aSets[i]
	? ""
	? "-- " + s[1] + " : " + s[2]
	oL = StzLiveQ(s[3])
	oL.CaptureInsteadOfDevice(s[4] * 4 * 60 / s[3], FALSE)
	Mu3Play(oL, i)
	oL.Stop()
	oL.Capture().SaveAs(s[1])
	? "   written: " + oL.Capture().Duration() + " s, late " + oL.Late() +
	  ", mid-cycle " + oL.MidCycleChanges()
	oL.Release()

	if StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1
		? "   now LIVE on the card -- each line printed as that cycle is heard:"
		oD = StzLiveQ(s[3])
		oD.OnCycle(func cTxt { ? "     " + cTxt })
		Mu3Play(oD, i)
		oD.Stop()
		? "   live: late " + oD.Late() + ", underruns " + oD.Underruns() +
		  ", mid-cycle " + oD.MidCycleChanges()
		oD.Release()
	ok
next

? ""
? "Tell me: did every change land on a bar? And does it feel live, or does"
? "the bar-and-a-third wait feel like typing into a letterbox? That verdict"
? "goes into the MU3 STATUS by name; until then it reads UNPERCEIVED."

# The two sets, as a live coder would type them. Ten cycles each. Every change
# is reported with the cycle it lands on -- or its refusal, because a refused
# redefinition keeps the old loop playing, and a demo that did not say so
# would let a listener credit the wrong version. (The first cut of this demo
# did exactly that: its reed phrase reached Bb5, above the mezwed's 900 Hz,
# was refused, and the console showed reed v1 playing on. The phrase now
# stays in range, and every Say line prints.)
func Mu3Play oL, nSet
	if nSet = 1
		Mu3Say(oL, "iqa", oL.LiveLoop(:iqa, "dum ~ tak ~ dum dum tak ~"))
		Mu3Say(oL, "frame", oL.LiveLoopOn(:frame, "dum ~ ~ ~", :Bendir))
		oL.WaitCycles(2)
		Mu3Say(oL, "reed", oL.LiveLoopOn(:reed, "d5 e-50 f5 g5 a5 ~ g5 f5", :Mezwed))
		oL.WaitCycles(2)
		Mu3Say(oL, "reed, new phrase", oL.LiveLoopOn(:reed, "a5 g5 a5 g5 f5 e-50 d5 ~", :Mezwed))
		oL.WaitCycles(2)
		Mu3Say(oL, "iqa, Every(2, :Rev)", oL.Every(2, :iqa, :Rev))
		oL.WaitCycles(2)
		Mu3Say(oL, "reed, silence", oL.Silence(:reed))
		oL.WaitCycles(2)
	else
		Mu3Say(oL, "drums", oL.LiveLoop(:drums, "bd*2 [~ sn] hh? hh"))
		Mu3Say(oL, "bass", oL.LiveLoopOn(:bass, "<c3 g2 a2 f2>*2", :Guitar))
		oL.WaitCycles(2)
		Mu3Say(oL, "harp, Off(0.25, 12)", oL.LiveLoopOf(:harp, StzPatternQ("c5 e5 g5 b5").Off(0.25, 12), :Harp))
		oL.WaitCycles(3)
		Mu3Say(oL, "drums, new", oL.LiveLoop(:drums, "bd [hh hh] sn [hh bd]"))
		oL.WaitCycles(3)
		Mu3Say(oL, "hush", oL.Hush())
		oL.WaitCycles(2)
	ok

func Mu3Say oL, cWhat, nK
	_at_ = oL.HeardFrames() / oL.CycleFrames()
	if nK < 0
		? "     >> typed at " + _at_ + ": " + cWhat + " -- REFUSED: " + oL.LastError()
	else
		? "     >> typed at " + _at_ + ": " + cWhat + " -> lands on cycle " + nK
	ok
