# A FISHBONE, NARRATED -- DN20 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A fishbone (Ishikawa) diagram is an EFFECT at the head, a spine, and
# the categories of cause as bones leaning toward the head by turns,
# with the causes written along them. The builder spaces the bones by
# half the widest carry so no cause runs into its neighbour. Three rules
# say what an analysis may not do -- a bone with nothing on it, a cause
# listed under two categories, the effect written among its own causes.
#
# This guide RUNS: every count below is read back from the substance the
# builder wrote, and every rule is asked through the catalogue's gate.
#
#   Run:  ring fishbone_narrated.ring

load "../../stzBase.ring"
load "gg_math_scenes.ring"

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")

? "-- Scene 1: why the coffee is bitter -- six categories, nine causes --"
oF = StzFishboneDiagram(FONT, "Bitter coffee", StzMathCoffeeCategories())
oF.Layout()
oS = oF.Substance()
aCat = oS.ObjectsOfType("Category")
aCause = oS.ObjectsOfType("Cause")
? "   the effect '" + oS.LabelOf("h") + "' at the head, " + len(aCat) + " bones, " + len(aCause) + " causes"
chk("six categories and nine causes, one effect", len(aCat) = 6 and len(aCause) = 9)
nSpineY = oS.DataOf("s", "y")
nHeadY = oS.DataOf("h", "y")
? "   the spine runs at y = " + StzFactNumText(nSpineY) + " into the head at y = " + StzFactNumText(nHeadY)
chk("the spine meets the head on its centre line", fabs(nSpineY - nHeadY) < 0.01)
chk("the spine ends where the head begins",
    fabs(oS.DataOf("s", "x1") - (oS.DataOf("h", "x0") - 1)) < 0.01)

? ""
? "-- Scene 2: three rules about an analysis, and a sound one passes them --"
aF = StzCheckPictures([ [ "coffee", oF ] ]).Findings()
? "   every_bone_carries_a_cause, a_cause_is_named_once, the_effect_is_not_its_own_cause"
chk("the analysis has nothing wrong with it", len(aF) = 0)

? ""
? "-- Scene 3: the same analysis with three mistakes --"
? "   a category with nothing under it; 'Stale beans' listed under two"
? "   categories; the effect written among its own causes."
oW = StzFishboneDiagram(FONT, "Bitter coffee", StzMathCoffeeWrongCategories())
aW = StzCheckPictures([ [ "wrong", oW ] ]).Findings()
say(aW)
chk("the empty bone is caught, by its category", hits(aW, "every_bone_carries_a_cause") = 1 and has(aW, "Measurement"))
chk("a cause named twice is reported on both listings", hits(aW, "a_cause_is_named_once") = 2 and has(aW, "Stale beans"))
chk("the effect among its own causes is caught", hits(aW, "the_effect_is_not_its_own_cause") = 1)
chk("and those four are everything the rules find", len(aW) = 4)

? ""
? "-- Scene 4: the pictures --"
if StzGraphicsDevice()
	oF.ToPNG("guide_fishbone.png")
	oW.ToPNG("guide_fishbone_witness.png")
	? "   wrote guide_fishbone.png and guide_fishbone_witness.png"
else
	? "   (no device -- the numbers above needed none; the pictures do)"
ok

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
