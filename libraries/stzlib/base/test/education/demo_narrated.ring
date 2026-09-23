# E2 -- the decision-maker demo runs end to end, from a clean folder, twice in a row.
#
# The demo (base/education/demo/demo.ring) is run as a real child process,
# the way a presenter runs it, into a workspace that does not exist yet.
# Then it runs AGAIN into the same, re-cleaned workspace. This guard asserts:
#   - both runs exit cleanly, show all eight scenes, and prove every claim
#   - both runs leave the same artifacts: the reader page and the learners
#   - the two transcripts are IDENTICAL, except the one clock reading the
#     progress file carries (checked-at-ms) -- so what a decision maker
#     sees is reproducible, not a lucky take
# Per-run wall times are printed. Two cold runs of a 38-second demo make
# this the slowest guard of the plane (about 80 s); it is E2's gate, run
# once per change to the demo, never after every edit.
#
# Run from this folder: ring demo_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

cWs = "t_edu_demo_ws"
cDemo = "../../education/demo/demo.ring"
acOut = []
anSecs = []

for nRun = 1 to 2
	StzEduRemoveTree(cWs)
	t0 = clock()
	aR = StzEngineSystemRunXT(StzEduRingExe() + " " + cDemo + " " + cWs)
	anSecs + ((clock() - t0) / clockspersecond())
	acOut + (aR[1] + aR[3])

	Scenario("Run " + nRun + ": the demo, from a clean workspace")
	Then("the demo process exited cleanly", aR[2], 0)
	Then("all eight scenes were shown", len(StzFind("=== Minute ", aR[1])), 8)
	Then("no claim was left unproved", len(StzFind("NOT PROVED", aR[1])), 0)
	Then("the closing count proves every claim", StzFindFirst("DEMO: 20 proved, 0 not proved", aR[1]) > 0, 1)
	Then("the reader page exists", fexists(cWs + "/elementary-introduction.html"), 1)
	Then("the learners' progress exists as plain text",
		fexists(cWs + "/learners/amina/progress.zknw") and fexists(cWs + "/learners/zara/progress.zknw"), 1)
	Then("the institution's folder was copied whole",
		fexists(cWs + "/institution/program/program.zknw") and
		fexists(cWs + "/institution/overlays/bank/worlds/workplace.zknw"), 1)
	EndScenario()
	? "  [time] run " + nRun + ": " + anSecs[nRun] + " s"
next

Scenario("Twice in a row: the same demo, word for word")
c1 = EduDemoMaskClock(acOut[1])
c2 = EduDemoMaskClock(acOut[2])
Then("the two transcripts are identical once the clock reading is masked", c1 = c2, 1)
Then("the mask hid exactly one line per run (the evidence's timestamp)",
	len(StzFind("checked-at-ms | <clock>", c1)), 1)
Then("...and the raw transcripts DO differ, so the mask hides a real clock reading",
	acOut[1] != acOut[2], 1)
EndScenario()

StzEduRemoveTree(cWs)
? ""
? "  [time] whole guard: " + (anSecs[1] + anSecs[2]) + " s of demo runs"
Summary()

#===========================================================================
# helpers -- after the last top-level statement (Ring stops there)

# Replaces the digits of the one clock reading a learner's progress holds.
func EduDemoMaskClock(pcText)
	_eg_acL_ = StzSplit(StzReplace(pcText, char(13), ""), char(10))
	_eg_c_ = ""
	for _eg_i_ = 1 to len(_eg_acL_)
		_eg_l_ = _eg_acL_[_eg_i_]
		if StzFindFirst("| checked-at-ms |", _eg_l_) > 0
			_eg_l_ = StzLeft(_eg_l_, StzFindFirst("| checked-at-ms |", _eg_l_) - 1) + "| checked-at-ms | <clock>"
			_eg_l_ = StzReplace(_eg_l_, "| | checked-at-ms", "| checked-at-ms")
		ok
		_eg_c_ += _eg_l_ + char(10)
	next
	return _eg_c_
