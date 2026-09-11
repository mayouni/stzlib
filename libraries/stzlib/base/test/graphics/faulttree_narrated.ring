# A FAULT TREE, NARRATED -- DN17 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A fault tree is a top event, the gates that develop it, and the basic
# events at the leaves, each with a probability. THE PICTURE COMPUTES:
# an AND multiplies its inputs, an OR takes one minus the product of
# their complements, and the top's probability is written on it. It also
# knows its MINIMAL CUT SETS -- the smallest sets of basic events that
# bring the top about -- and the exact probability from them, which is
# where the gate arithmetic and the truth part company when an event is
# repeated. Five rules say what a tree may not be -- two top events, a
# gate with one input, a basic event with no probability, an intermediate
# event with no gate, an event among its own causes.
#
# This guide RUNS: every probability below is the tree's own, and every
# rule is asked through the diagram's own governance.
#
#   Run:  ring faulttree_narrated.ring

load "../../stzBase.ring"
load "gg_fault_scenes.ring"

if NOT StzGraphicsDevice()
	? "(no device -- a notation picture is rendered as it is built, so this guide is UNJUDGED here)"
	return
ok

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

? "-- Scene 1: a pump that fails to start --"
oT = StzFaultScene01(OPT)
# the render put Ring's global decimals back to two; four show the arithmetic
decimals(4)
? "   top: '" + oT.TopEvent() + "' -- " + len(oT.Events()) + " events, " + len(oT.Gates()) + " gates"
? "   'No power' is mains out AND battery flat: 0.1 x 0.2 = " + oT.ProbabilityOf("power")
chk("an AND gate multiplies", fabs(oT.ProbabilityOf("power") - 0.02) < 0.000000001)
? "   the top is no power OR motor seized: 1 - (1 - 0.02)(1 - 0.05) = " + oT.TopProbability()
chk("an OR gate takes one minus the product of the complements", fabs(oT.TopProbability() - 0.069) < 0.000000001)
aCuts = oT.MinimalCutSets()
? "   minimal cut sets: " + cutsText(aCuts)
chk("two ways to the top: the motor alone, or mains and battery together",
    len(aCuts) = 2)
? "   the exact probability from the cut sets: " + oT.CutSetProbability()
chk("with no repeated event, the gate arithmetic and the cut sets agree",
    fabs(oT.CutSetProbability() - oT.TopProbability()) < 0.000000001)

? ""
? "-- Scene 2: a repeated event, where the gate arithmetic overstates --"
? "   the same stuck sensor sits under both branches of the tank overflowing"
oTank = StzFaultScene02(OPT)
decimals(4)
? "   gate arithmetic: " + oTank.TopProbability() + "   from the cut sets: " + oTank.CutSetProbability()
? "   minimal cut sets: " + cutsText(oTank.MinimalCutSets())
chk("the gates assume independence and say 0.0494; the cut sets { sensor, valve } and { sensor, relay } say 0.044",
    fabs(oTank.TopProbability() - 0.0494) < 0.000000001 and fabs(oTank.CutSetProbability() - 0.044) < 0.000000001)

? ""
? "-- Scene 3: five rules about a tree, and a sound one passes them --"
? "   one_top_event, gate_has_two_inputs, basic_event_has_probability,"
? "   event_is_developed, no_event_causes_itself"
chk("the pump tree has nothing wrong with it", oT.GovernanceIsSound())
chk("nor has the tank", oTank.GovernanceIsSound())

? ""
? "-- Scene 4: the witness -- one of each mistake, and two things that are not --"
? "   two top events; a gate with one input; a basic event with no probability;"
? "   an event with no gate; a cause among its own effects. An undeveloped event"
? "   that says so, and a note, are left alone."
oW = StzFaultSceneWitness(OPT)
aW = oW.GovernanceFindings()
say(aW)
chk("two top events are caught", hits(aW, "one_top_event") >= 1)
chk("the gate with one input is caught", hits(aW, "gate_has_two_inputs") = 1)
chk("the basic event with no probability is named", hits(aW, "basic_event_has_probability") = 1 and has(aW, "Dust"))
chk("the event with no gate is named", hits(aW, "event_is_developed") = 1 and has(aW, "Undeveloped, unsaid"))
chk("the line stopping among the causes of its own jam is caught", hits(aW, "no_event_causes_itself") >= 1)
chk("the undeveloped event and the note are left alone", NOT has(aW, "Operator absent") and NOT has(aW, "draft of"))

? ""
? "-- Scene 5: the pictures --"
oT.LastCanvas().ToPNG("guide_faulttree.png")
oW.LastCanvas().ToPNG("guide_faulttree_witness.png")
? "   wrote guide_faulttree.png and guide_faulttree_witness.png"

? ""
? "== " + nPass + " passed, " + nFail + " failed =="

#---------------------------------------------------------------------------

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func hits aF, cRule
	_n_ = 0
	for _i_ = 1 to len(aF)
		if StzLower("" + aF[_i_][:rule]) = StzLower(cRule)  _n_++  ok
	next
	return _n_

func has aF, cText
	for _i_ = 1 to len(aF)
		if StzFindFirst(cText, "" + aF[_i_][:message]) > 0  return 1  ok
	next
	return 0

func say aF
	for _i_ = 1 to len(aF)
		? "     " + aF[_i_][:rule] + " -- " + aF[_i_][:message]
	next

func cutsText aCuts
	_c_ = ""
	for _i_ = 1 to len(aCuts)
		if _i_ > 1  _c_ += "  "  ok
		_c_ += "{ "
		for _j_ = 1 to len(aCuts[_i_])
			if _j_ > 1  _c_ += ", "  ok
			_c_ += "" + aCuts[_i_][_j_]
		next
		_c_ += " }"
	next
	return _c_
