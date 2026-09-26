# MU2 -- THE SCORE AND THE SCHEDULER, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_mu2_demo.ring
#
# The guard proved every note lands on its frame -- 0 frames of error across
# 200 notes at 180 BPM, live. It cannot prove that a swung groove FEELS swung,
# or which swing is right. That is the verdict MU2 needs from a person.
#
# Each piece is written to a WAV beside this file (mu2_NN_name.wav), then
# played LIVE through the scheduler on the sound card -- the real-time path,
# every note posted ahead of the ring -- with its late notes and underruns
# printed after it. Both should read 0.

load "../../stzBase.ring"

pr()
decimals(3)

? "=================================================================="
? " MU2 -- a score is data; every note on its frame; live"
? "=================================================================="
? ""

aPieces = []    # [ file, what to listen for, stzScore ]

# ---- 1. the phase gate: the first line makes a sound ----------------------

? "1. The one line:  StzMusicQ().Play(" + char(34) + "c e g c5" + char(34) + ")"
oM = StzMusicQ()
oM.Play("c e g c5")
? "   (played live; the WAV is written below)"
aPieces + [ "mu2_01_one_line.wav", "the first line of music -- C E G C on the piano",
            oM.ScoreOf("c e g c5") ]

# ---- 2 and 3. the same groove, straight and swung -------------------------

oStraight = Mu2Groove().Tempo(100)
oSwung = Mu2Groove().Tempo(100).Swing(2 / 3)
aPieces + [ "mu2_02_groove_straight.wav",
            "kick, hat, snare in straight eighths, 100 BPM", oStraight ]
aPieces + [ "mu2_03_groove_swung.wav",
            "the SAME score, swung 2/3 -- does it swing, or only limp?", oSwung ]

# ---- 4. the algebra: two parts, Then and Together -------------------------

oTune = StzScoreOfQ("e5 d5 c5 d5 e5 e5 e5 ~ d5 d5 d5 ~ e5 g5 g5 ~").On(:Harp)
oBass = StzScoreOfQ("c3 ~ g2 ~ c3 ~ g2 ~ g2 ~ d3 ~ c3 ~ g2 ~").On(:Guitar)
oTwo = StzScoreQ().Together(oTune).Together(oBass).Tempo(132)
aPieces + [ "mu2_04_two_parts.wav",
            "a harp tune TOGETHER with a guitar bass -- one score, two instruments",
            oTwo ]

# ---- 5. the same score at two tempi ---------------------------------------

oA = StzScoreOfQ("a3 c4 e4 a4 g4 e4 c4 d4").On(:Kora)
oFast = StzScoreQ().Then(oA).Then(oA).Tempo(90)
oFaster = StzScoreQ().Then(oA).Then(oA).Tempo(160)
aPieces + [ "mu2_05_kora_90.wav", "a kora figure at 90 BPM", oFast ]
aPieces + [ "mu2_06_kora_160.wav", "the same notes at 160 BPM -- only the tempo moved", oFaster ]

# ---- 6. a mezwed line over darbouka and bendir ----------------------------
#
# NOT a tab': a universe (tuning, movement, cycle) is declared data, MU4's.
# This is only the algebra carrying three Tunisian instruments at once, with
# a quarter-flat E written as E4-50.

oLine = StzScoreOfQ("d4 e-50 f g a ~ g f e-50 d ~ ~ a g f e-50").On(:Mezwed)
oDrum = StzScoreQ().On(:Darbouka)
for k = 1 to 4
	oDrum.Stroke(:dum, 0.5).Stroke(:tak, 0.5).Rest(0.5).Stroke(:tak, 0.5)
	oDrum.Stroke(:dum, 0.5).Rest(0.5).Stroke(:tak, 0.5).Stroke(:ka, 0.5)
next
oFrame = StzScoreQ().On(:Bendir)
for k = 1 to 8  oFrame.Stroke(:dum, 1).Rest(1) next
oTun = StzScoreQ().Together(oLine).Together(oDrum).Together(oFrame).Tempo(112)
aPieces + [ "mu2_07_mezwed_darbouka_bendir.wav",
            "a mezwed line with a quarter-flat E, over darbouka and bendir -- NOT yet a tab'",
            oTun ]

# ---- write, then play live -------------------------------------------------

? ""
? "Writing each piece, then playing it live through the scheduler:"
? ""
for p in aPieces
	oSnd = p[3].ToSound()
	oSnd.SaveAs(p[1])
	? "  " + p[1] + "   " + oSnd.Duration() + " s, peak " + oSnd.Peak()
	? "     " + p[2]
	oP = StzSchedulerQ(p[3])
	oP.Play()
	oP.RunToEnd()
	? "     live: " + oP.Placed() + " notes placed, " + oP.Late() + " late, " +
	  oP.Underruns() + " frames of underrun" + Mu2Err(oP)
	oP.Release()
	sleep(0.4)
next

? ""
? "Tell me, for 03: does it swing, or only limp? And is 2/3 the right"
? "default swing, or something straighter (0.6)? That verdict goes into the"
? "MU2 STATUS by name; until then it reads UNPERCEIVED."

# ---- helpers ---------------------------------------------------------------

# kick, hat, snare, hat in eighths -- kick on 1 and 3, snare on 2 and 4 --
# for two bars
func Mu2Groove
	_oK_ = StzScoreQ().On(:Drumkit)
	for _b_ = 1 to 8
		if _b_ % 2 = 1
			_oK_.Stroke(:kick, 0.5)
		else
			_oK_.Stroke(:snare, 0.5)
		ok
		_oK_.Stroke(:hihat, 0.5)
	next
	return _oK_

func Mu2Err poP
	if poP.LastError() = ""  return "" ok
	return "  (" + poP.LastError() + ")"
