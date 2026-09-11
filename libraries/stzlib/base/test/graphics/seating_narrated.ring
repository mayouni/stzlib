# A SEATING PLAN, NARRATED -- DN23 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A seating plan is tables where they stand, seats around them, guests in
# the seats. The author writes places in metres and a seat count; the
# builder draws the seats around each table, anchors every name outward,
# and SPREADS the tables by their measured extents so that the names of
# one table never run into the next -- the author owns the places, the
# layout owns the clearance. Four rules say what a host may not do -- give
# a table more guests than seats, seat a guest twice, seat together a pair
# to be kept apart, stand two tables so that their seats meet.
#
# This guide RUNS: every number below is read back from the substance the
# builder wrote, and every rule is asked through the catalogue's gate.
#
#   Run:  ring seating_narrated.ring

load "../../stzBase.ring"
load "gg_math_scenes.ring"

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")

? "-- Scene 1: a wedding of five tables and thirty guests --"
oP = StzSeatingDiagram(FONT, StzMathWeddingTables(), StzMathWeddingGuests(), StzMathWeddingApart())
oP.Layout()
oS = oP.Substance()
aTab = oS.ObjectsOfType("Table")
aSeat = oS.ObjectsOfType("Seat")
aGuest = oS.ObjectsOfType("Guest")
? "   " + len(aTab) + " tables, " + len(aSeat) + " seats, " + len(aGuest) + " guests"
chk("five tables, thirty-six seats, thirty guests -- six seats stay free", len(aTab) = 5 and len(aSeat) = 36 and len(aGuest) = 30)
cTop = aTab[1]
? "   '" + oS.LabelOf(cTop) + "' seats " + oS.DataOf(cTop, "seats") + " and was given " + oS.DataOf(cTop, "given")
chk("a table knows its seats and how many were given", oS.DataOf(cTop, "seats") = 8 and oS.DataOf(cTop, "given") = 8)
? "   the author stood it at (" + oS.DataOf(cTop, "mx") + ", " + oS.DataOf(cTop, "my") + ") m; the layout stands it at (" +
  StzFactNumText(oS.DataOf(cTop, "sx")) + ", " + StzFactNumText(oS.DataOf(cTop, "sy")) + ") m after spreading"
chk("the builder keeps the author's place unless a neighbour's names would run into it",
    isNumber(oS.DataOf(cTop, "sx")) and isNumber(oS.DataOf(cTop, "rx")) and oS.DataOf(cTop, "rx") > 0)

? ""
? "-- Scene 2: four rules about hosting, and a sound plan passes them --"
aF = StzCheckPictures([ [ "wedding", oP ] ]).Findings()
? "   table_not_overbooked, a_guest_sits_once, kept_apart_are_apart, tables_stand_clear"
chk("the wedding has nothing wrong with it", len(aF) = 0)

? ""
? "-- Scene 3: the same wedding with one of each mistake --"
? "   Table 1 given seven guests for six seats; Ann seated at two tables; Ann"
? "   and Fay, to be kept apart, seated together; Table 3 stood into Table 2."
oW = StzSeatingDiagram(FONT, StzMathWeddingWrongTables(), StzMathWeddingWrongGuests(), StzMathWeddingApart())
aW = StzCheckPictures([ [ "wrong", oW ] ]).Findings()
say(aW)
chk("the overbooked table is named with its count", hits(aW, "table_not_overbooked") = 1 and has(aW, "Table 1"))
chk("a guest seated twice is reported on both listings", hits(aW, "a_guest_sits_once") = 2 and has(aW, "Ann"))
chk("the pair kept apart and seated together is caught", hits(aW, "kept_apart_are_apart") = 1)
chk("two tables that meet are reported on both", hits(aW, "tables_stand_clear") = 2)
chk("and those six are everything the rules find", len(aW) = 6)

? ""
? "-- Scene 4: the pictures --"
if StzGraphicsDevice()
	oP.ToPNG("guide_seating.png")
	oW.ToPNG("guide_seating_witness.png")
	? "   wrote guide_seating.png and guide_seating_witness.png"
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
