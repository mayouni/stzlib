# A TIMELINE, NARRATED -- DN19 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A timeline is an axis that is a SCALE, and every mark on it a datum:
# an event is a year, an era is two years and a band beneath the axis,
# and the picture is arithmetic over those. The builder lays the names
# so that none covers a column whose stem reaches its level. Three rules
# say what a history may not do -- an era ending before it starts, two
# eras double-booked on one band, an event placed outside the era it
# claims.
#
# This guide RUNS: every number below is read back from the substance
# the builder wrote, and every rule is asked through the catalogue's gate.
#
#   Run:  ring timeline_narrated.ring

load "../../stzBase.ring"
load "gg_math_scenes.ring"

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")

? "-- Scene 1: the history of computing, nine events and four eras --"
oT = StzTimelineDiagram(FONT, StzMathHistoryEvents(), StzMathHistoryEras())
oT.Layout()
oS = oT.Substance()
aEv = oS.ObjectsOfType("Event")
aEra = oS.ObjectsOfType("Era")
? "   " + len(aEv) + " events on the axis, " + len(aEra) + " eras beneath it"
chk("nine events and four eras", len(aEv) = 9 and len(aEra) = 4)
? "   ENIAC is placed at " + oS.DataOf("e2", "t") + ", the iPhone at " + oS.DataOf("e9", "t")
chk("an event's year is the datum the picture is drawn from",
    oS.DataOf("e2", "t") = 1945 and oS.DataOf("e9", "t") = 2007)
nPerYearA = (oS.DataOf("e9", "x") - oS.DataOf("e1", "x")) / (2007 - 1936)
nPerYearB = (oS.DataOf("e5", "x") - oS.DataOf("e1", "x")) / (1969 - 1936)
? "   a year is " + StzFactNumText(nPerYearA) + " px between Turing and the iPhone, " +
  StzFactNumText(nPerYearB) + " px between Turing and ARPANET"
chk("the axis is ONE scale -- a year is the same width everywhere on it",
    fabs(nPerYearA - nPerYearB) < 0.01)
? "   the axis carries " + oS.DataOf("ax", "levels") + " name levels and " + oS.DataOf("ax", "bands") + " era bands"
chk("names that would collide are lifted to their own level, so the axis has more than one",
    oS.DataOf("ax", "levels") >= 2 and oS.DataOf("ax", "bands") >= 1)

? ""
? "-- Scene 2: three rules about time, and a sound history passes them --"
aF = StzCheckPictures([ [ "history", oT ] ]).Findings()
? "   era_ends_after_it_starts, band_not_double_booked, event_within_its_era"
chk("the history has nothing wrong with it", len(aF) = 0)

? ""
? "-- Scene 3: the same history typed wrong --"
? "   an era that ends before it starts; two eras on one band overlapping by a"
? "   year; ENIAC placed in the transistors' era, ten years before it begins."
oW = StzTimelineDiagram(FONT, StzMathHistoryWrongEvents(), StzMathHistoryWrongEras())
aW = StzCheckPictures([ [ "wrong", oW ] ]).Findings()
say(aW)
chk("the backwards era is caught, by name", hits(aW, "era_ends_after_it_starts") = 1 and has(aW, "Backwards"))
chk("a double-booked band is reported on both its eras", hits(aW, "band_not_double_booked") = 2)
chk("an event outside its era is caught with the years",
    hits(aW, "event_within_its_era") = 1 and has(aW, "ENIAC"))
chk("and those four are everything the rules find", len(aW) = 4)

? ""
? "-- Scene 4: the pictures --"
if StzGraphicsDevice()
	oT.ToPNG("guide_timeline.png")
	oW.ToPNG("guide_timeline_witness.png")
	? "   wrote guide_timeline.png and guide_timeline_witness.png"
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
