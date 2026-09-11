# A PETRI NET, NARRATED -- DN16 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A Petri net is places that hold tokens, transitions that move them, and
# arcs that say from where to where, with a weight. THE PICTURE CARRIES
# ITS STATE: the marking is drawn as dots in the places, a transition is
# enabled when every input place holds its arc's weight, and firing it is
# arithmetic on the marking. Five rules say what a net may not be -- an
# arc joining two places or two transitions, a transition with no input
# or no output, a place that can never be marked, a transition that can
# never fire.
#
# This guide RUNS: the net is fired through its own verbs, and every rule
# is asked through the diagram's own governance.
#
#   Run:  ring petri_narrated.ring

load "../../stzBase.ring"
load "gg_petri_scenes.ring"

if NOT StzGraphicsDevice()
	? "(no device -- a notation picture is rendered as it is built, so this guide is UNJUDGED here)"
	return
ok

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

? "-- Scene 1: a mutex -- two processes, one key --"
oN = StzPetriScene01(OPT)
? "   " + len(oN.Places()) + " places, " + len(oN.Transitions()) + " transitions, " + len(oN.Arcs()) + " arcs"
? "   marking: " + markingText(oN)
aE = oN.Enabled()
? "   enabled now: " + idsText(aE)
chk("both processes may enter while the key is free", len(aE) = 2 and inList("e1", aE) and inList("e2", aE))

? ""
? "-- Scene 2: firing is arithmetic on the marking --"
oN.Fire("e1")
? "   after 'Enter A' fires -- marking: " + markingText(oN)
? "   enabled now: " + idsText(oN.Enabled())
? "   why not 'Enter B': " + oN.WhyNotEnabled("e2")
chk("A holds the key, so B cannot enter and only 'Leave A' is enabled",
    oN.Tokens("key") = 0 and oN.Tokens("c1") = 1 and len(oN.Enabled()) = 1 and inList("l1", oN.Enabled()))
chk("and the refusal says which place is short, by name and by number",
    StzFindFirst("'Key' holds 0", oN.WhyNotEnabled("e2")) > 0)
oN.Fire("l1")
? "   after 'Leave A' fires -- marking: " + markingText(oN)
chk("leaving returns the key and both may enter again", oN.Tokens("key") = 1 and len(oN.Enabled()) = 2)

? ""
? "-- Scene 3: a buffer with weights -- a producer fills two slots at a time --"
oB = StzPetriScene02(OPT)
? "   marking: " + markingText(oB)
oB.Fire("put")
oB.Fire("put")
? "   after two puts -- marking: " + markingText(oB)
? "   why not a third: " + oB.WhyNotEnabled("put")
chk("two puts take four of the five free slots, and the third is refused for the one that is left",
    oB.Tokens("free") = 1 and oB.Tokens("full") = 4 and NOT oB.IsEnabled("put") and
    StzFindFirst("holds 1 and the arc wants 2", oB.WhyNotEnabled("put")) > 0)

? ""
? "-- Scene 4: five rules about a net, and the sound ones pass them --"
? "   arc_joins_place_and_transition, transition_has_input, transition_has_output,"
? "   place_can_be_marked, transition_can_fire"
chk("the mutex has nothing wrong with it", oN.GovernanceIsSound())
chk("nor has the buffer", oB.GovernanceIsSound())

? ""
? "-- Scene 5: the witness -- one of each mistake, and a note that is not of the net --"
oW = StzPetriSceneWitness(OPT)
aW = oW.GovernanceFindings()
say(aW)
chk("an arc from a place to a place is caught", hits(aW, "arc_joins_place_and_transition") = 1)
chk("the transition with no input is named", hits(aW, "transition_has_input") = 1 and has(aW, "Source"))
chk("the transition with no output is named", hits(aW, "transition_has_output") = 1 and has(aW, "Sink"))
chk("the place empty forever and the transition it starves are both caught",
    hits(aW, "place_can_be_marked") >= 1 and hits(aW, "transition_can_fire") >= 1 and has(aW, "Starved"))
chk("the note is left alone", NOT has(aW, "draft of"))

? ""
? "-- Scene 6: the pictures --"
oN.LastCanvas().ToPNG("guide_petri.png")
oW.LastCanvas().ToPNG("guide_petri_witness.png")
? "   wrote guide_petri.png and guide_petri_witness.png"

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

func inList cId, aIds
	for _i_ = 1 to len(aIds)
		if StzLower("" + aIds[_i_]) = StzLower("" + cId)  return 1  ok
	next
	return 0

func idsText aIds
	_c_ = ""
	for _i_ = 1 to len(aIds)
		if _i_ > 1  _c_ += ", "  ok
		_c_ += "" + aIds[_i_]
	next
	return _c_

func markingText oNet
	_a_ = oNet.Marking()
	_c_ = ""
	for _i_ = 1 to len(_a_)
		if _i_ > 1  _c_ += ", "  ok
		_c_ += "" + _a_[_i_][1] + "=" + _a_[_i_][2]
	next
	return _c_
