load "../../stzBase.ring"
load "../_narrated.ring"
decimals(4)
$nGfSeed = 20261024

# stzGeoFeatures -- the antimeridian trap in IndicesWithin and Within, reproduced with invented data and held shut.
# DOCREFORM follow-up, 2026-10-24. Run from inside test/geo:  ring stzGeoFeatures_defects_narrated.ring
#
# Data: invented, as GeoJSON written in this file (the world atlas is not needed). Eleven features:
#    1 Fiji         two parts, 177..180 E and -180..-178 W, lat -19..-16
#    2 Africa       one box, -17..51, lat -34..37
#    3 Europe       one box, -9..30, lat 36..60
#    4 Touch180     one box, 170..180, lat 50..60: touches the line and does not cross it
#    5 Russia       two parts, 28..180 and -180..-169, lat 50..75
#    6 Antarctica   a ring with a vertex every 10 degrees all round, lat -90..-70
#    7 Asia         one box, 60..145, lat 10..70
#    8 Americas     one box, -170..-30, lat -55..70
#    9 Wide180      one box, -90..90, lat 0..10: exactly 180 wide, so NOT taken to cross
#   10 Wide181      one box, -90..91, lat 20..30: one degree over, so taken to cross
#   11 OnTheLine    two parts, 178..180 and -180..-178, lat 0..5
#
# The register listed two rows and ONE cause: a feature across the antimeridian has a box about 360 degrees
# wide whose middle is longitude 0, so Fiji was taken by a window around Africa (IndicesWithin) and so by
# Within, which is Subset of it. Before the fix, on this data, the Africa window (-20, -36, 52, 38) took
# features 1, 2, 9 and 10 (Fiji and Wide181 wrongly). FIXED: a box wider than 180 degrees is taken to cross
# the line and its middle is that of its own vertices with negative longitudes shifted by 360, brought
# back into (-180, 180]; a window whose western edge is east of its eastern edge runs across the line.
#
# THE EXPECTED MIDDLES BELOW ARE WRITTEN BY HAND, before the code was changed, and the oracle that judges
# 400 windows uses only these literals and no stzGeoFeatures call:
#      feature      1      2     3     4      5      6     7      8     9     10      11
#      middle     179.5   17   10.5  175   109.5   175  102.5  -100    0   -179.5   180
#      latitude  -17.5   1.5   48    55    62.5   -80    40    7.5    5     25     2.5
# (Antarctica: shifted vertices run 0..350, so its middle is 175, "near 180, within half a vertex gap";
# Wide181: shifted -90 -> 270 and 91 stay, 91..270, middle 180.5 -> -179.5.)
#
# What each scenario holds, and the rule it answers to:
#   1. the Africa window     -> takes Africa and Wide180, NOT Fiji, Russia, Antarctica or Wide181
#   2. windows across 180    -> 170 to -170 takes the pacific features and not Africa; edges are inclusive
#   3. windows 160..180, -180..-160 -> a middle is one longitude; Fiji is at +179.5 and is never at -179.5
#   4. a window that is a point / on the edge -> zero width takes exactly the middle; edges inside
#   5. the unchanged half    -> 200 windows with lon0 <= lon1 give, for the six features that do not
#                              cross, exactly the old formula; 200 mixed windows give the oracle for all
#   6. the boxes             -> BoundsOf and Bounds still answer the 360 degree box
#   7. Within                -> a stzGeoFeatures whose Count is the number of indices, same order
#   8. no features, one      -> [ ], and a one-feature set, behave
#   9. arguments             -> text, lists, NaN raise a clear error; infinity and 0 are numbers
#  10. the source            -> the "Defect:" lines are gone and the rule is written down
#
# Every positive carries a negative sibling: what must still be taken, still be left alone.

# --- 1. the Africa window -----------------------------------------------------------------
Scenario("A window around Africa takes Africa, and Fiji, Russia and Antarctica are left alone")
	oW = GfWorld()
	Then("eleven features", oW.Count(), 11)
	Then("Fiji is feature 1", GfIs(oW.NameOf(1), "Fiji"), 1)
	aB = oW.BoundsOf(1)
	Then("Fiji's box is 360 degrees wide, -180 to 180: the trap is real", aB[3] - aB[1], 360)
	Then("the Africa window (-20, -36, 52, 38) takes exactly features 2 and 9", GfList(oW.IndicesWithin(-20, -36, 52, 38)), "2,9")
	aAf = oW.IndicesWithin(-20, -36, 52, 38)
	Then("it takes Africa", GfIs(GfNameAt(oW, aAf, 1), "Africa"), 1)
	Then("NEGATIVE: not Fiji", GfHas(oW.IndicesWithin(-20, -36, 52, 38), 1), 0)
	Then("NEGATIVE: not Wide181, whose box is 181 wide and whose old middle was 0.5", GfHas(oW.IndicesWithin(-20, -36, 52, 38), 10), 0)
	Then("NEGATIVE: Russia is out of the window by latitude AND by longitude: take the latitude away and it is still out",
		GfHas(oW.IndicesWithin(-20, -90, 52, 90), 5), 0)
	Then("NEGATIVE: and so is Antarctica, with every latitude allowed", GfHas(oW.IndicesWithin(-20, -90, 52, 90), 6), 0)
	Then("with every latitude allowed the window takes Africa, Europe and Wide180 and nothing across the line",
		GfList(oW.IndicesWithin(-20, -90, 52, 90)), "2,3,9")
	Then("Wide180 stays: a box exactly 180 wide keeps its plain middle, 0, as before", GfHas(oW.IndicesWithin(-20, -36, 52, 38), 9), 1)
	Then("NEGATIVE: the OnTheLine feature (middle 180) is not in an Africa window", GfHas(oW.IndicesWithin(-20, -90, 52, 90), 11), 0)
EndScenario()

# --- 2. windows across the line -------------------------------------------------------------
Scenario("A window from 170 east to -170 runs across the antimeridian")
	oW = GfWorld()
	aP = oW.IndicesWithin(170, -90, -170, 90)
	Then("the Pacific window takes Fiji, Touch180, Antarctica, Wide181 and OnTheLine", GfList(aP), "1,4,6,10,11")
	Then("NEGATIVE: not Africa", GfHas(aP, 2), 0)
	Then("NEGATIVE: not Europe, not Asia, not the Americas (middle -100)", GfHas(aP, 3) + GfHas(aP, 7) + GfHas(aP, 8), 0)
	Then("NEGATIVE: not Russia, whose middle is 109.5 -- it is placed by where most of it is", GfHas(aP, 5), 0)
	Then("NEGATIVE: not Wide180 (middle 0)", GfHas(aP, 9), 0)
	Then("with latitude -30..0 the Pacific window takes only Fiji", GfList(oW.IndicesWithin(170, -30, -170, 0)), "1")
	Then("with latitude 40..80 it takes only Touch180 (Russia is placed at 109.5)", GfList(oW.IndicesWithin(170, 40, -170, 80)), "4")
	Then("a window from 100 across to -170, latitude 40..80, takes Touch180, Russia and Asia", GfList(oW.IndicesWithin(100, 40, -170, 80)), "4,5,7")
	Then("the plain window 100..180 takes the same three: nothing sits between -180 and -170 at those latitudes",
		GfList(oW.IndicesWithin(100, 40, 180, 80)), "4,5,7")
	Then("NEGATIVE: and -180..-170 takes none of those three (Russia is not at -170)", GfList(oW.IndicesWithin(-180, 40, -170, 80)), "")
	Then("a middle exactly on the western edge is inside: Touch180 (175) with edge 175", GfHas(oW.IndicesWithin(175, 55, -170, 55), 4), 1)
	Then("a middle exactly on the eastern edge is inside: Wide181 (-179.5) with edge -179.5", GfHas(oW.IndicesWithin(170, 25, -179.5, 25), 10), 1)
	Then("NEGATIVE: half a degree short on the east, Wide181 is out", GfHas(oW.IndicesWithin(170, 25, -179.6, 25), 10), 0)
	Then("NEGATIVE: and half a degree short on the west, Touch180 (175) is out", GfHas(oW.IndicesWithin(175.1, 55, -170, 55), 4), 0)
	Then("a window from 180 to -180 takes only a middle exactly on the line: OnTheLine", GfList(oW.IndicesWithin(180, -90, -180, 90)), "11")
	Then("NEGATIVE: 180 to -180 does not take Fiji (179.5)", GfHas(oW.IndicesWithin(180, -90, -180, 90), 1), 0)
EndScenario()

# --- 3. 160..180 and -180..-160 -----------------------------------------------------------
Scenario("A middle is one longitude: Fiji is at +179.5 and never at -179.5")
	oW = GfWorld()
	Then("160..180 takes Fiji (179.5), Touch180, Antarctica and OnTheLine, the middles in it", GfList(oW.IndicesWithin(160, -90, 180, 90)), "1,4,6,11")
	Then("NEGATIVE: 160..180 does not take Wide181, whose middle is -179.5", GfHas(oW.IndicesWithin(160, -90, 180, 90), 10), 0)
	Then("-180..-160 takes only Wide181: DECIDED, a middle at -179.5 is there and Fiji's is not", GfList(oW.IndicesWithin(-180, -90, -160, 90)), "10")
	Then("NEGATIVE: -180..-160 does not take Fiji", GfHas(oW.IndicesWithin(-180, -90, -160, 90), 1), 0)
	Then("NEGATIVE: nor the Americas (-100)", GfHas(oW.IndicesWithin(-180, -90, -160, 90), 8), 0)
	Then("to take both sides, ask across the line: 160 to -160", GfList(oW.IndicesWithin(160, -90, -160, 90)), "1,4,6,10,11")
	Then("a middle at +180 is never at -180: OnTheLine is in 179..180", GfHas(oW.IndicesWithin(179, -90, 180, 90), 11), 1)
	Then("NEGATIVE: OnTheLine is not in -180..-179", GfHas(oW.IndicesWithin(-180, -90, -179, 90), 11), 0)
	Then("Antarctica's middle is 175 (vertices every 10 degrees, shifted 0..350): a point window finds it", GfList(oW.IndicesWithin(175, -80, 175, -80)), "6")
	Then("Touch180 touches the line and keeps its plain middle, 175: a window 174..176 takes it", GfList(oW.IndicesWithin(174, -90, 176, 90)), "4,6")
	Then("NEGATIVE: Touch180 is not at -175", GfHas(oW.IndicesWithin(-176, -90, -174, 90), 4), 0)
EndScenario()

# --- 4. a point window, the edges ---------------------------------------------------------
Scenario("A window of no width takes the features whose middle is exactly that place")
	oW = GfWorld()
	Then("lon 17, lat 1.5 is Africa's middle: it is taken", GfList(oW.IndicesWithin(17, 1.5, 17, 1.5)), "2")
	Then("NEGATIVE: lon 17, lat 0 is not: nothing", GfList(oW.IndicesWithin(17, 0, 17, 0)), "")
	Then("NEGATIVE: lon 17.0001 is not", GfList(oW.IndicesWithin(17.0001, 1.5, 17.0001, 1.5)), "")
	Then("lon 179.5, every latitude: exactly Fiji", GfList(oW.IndicesWithin(179.5, -90, 179.5, 90)), "1")
	Then("lon 10.5, lat 48 is Europe's middle, and the edges are inside", GfList(oW.IndicesWithin(10.5, 48, 10.5, 48)), "3")
	Then("the whole world, -180..180 and -90..90, takes all eleven", GfList(oW.IndicesWithin(-180, -90, 180, 90)), "1,2,3,4,5,6,7,8,9,10,11")
	Then("NEGATIVE: the latitude is unchanged by the fix -- a reversed latitude (38 to -36) takes nothing", GfList(oW.IndicesWithin(-20, 38, 52, -36)), "")
	Then("the latitude edge is inside too: Africa at lat 1.5 is in 1.5..1.5, lon -20..52", GfHas(oW.IndicesWithin(-20, 1.5, 52, 1.5), 2), 1)
EndScenario()

# --- 5. 200 + 200 windows against an oracle -------------------------------------------------
Scenario("The six features that do not cross answer as before, on 200 windows; all eleven match the oracle on 200 more")
	oW = GfWorld()
	aMid = [ 179.5, 17, 10.5, 175, 109.5, 175, 102.5, -100, 0, -179.5, 180 ]
	aLat = [ -17.5, 1.5, 48, 55, 62.5, -80, 40, 7.5, 5, 25, 2.5 ]
	aPlain = [ 2, 3, 4, 7, 8, 9 ]
	$nGfSeed = 20261024
	nBad1 = 0
	nFull1 = 0
	for k = 1 to 200
		aWin = GfWindow(TRUE)
		aGot = oW.IndicesWithin(aWin[1], aWin[2], aWin[3], aWin[4])
		aOld = GfOldFormula(aMid, aLat, aPlain, aWin)
		aGotPlain = GfKeep(aGot, aPlain)
		if GfList(aGotPlain) != GfList(aOld)  nBad1++  ok
		if len(aOld) > 0  nFull1++  ok
	next
	Then("200 windows with lon0 <= lon1: the six non-crossing features differ from the old formula in 0 windows", nBad1, 0)
	? "    [grid1 non-empty: " + nFull1 + "]"
	Then("NEGATIVE: the grid is not vacuous -- at least 40 of the 200 windows take one of the six", nFull1 >= 40, 1)
	nBad2 = 0
	nAcross = 0
	nTaken = 0
	for k = 1 to 200
		aWin = GfWindow(FALSE)
		aGot = oW.IndicesWithin(aWin[1], aWin[2], aWin[3], aWin[4])
		aOr = GfOracle(aMid, aLat, aWin)
		if GfList(aGot) != GfList(aOr)  nBad2++  ok
		if aWin[1] > aWin[3]  nAcross++  ok
		nTaken += len(aOr)
	next
	Then("200 mixed windows (some across the line): all eleven features match the oracle in 0 windows", nBad2, 0)
	Then("NEGATIVE: the grid is not vacuous -- at least 40 windows run across the line", nAcross >= 40, 1)
	? "    [across: " + nAcross + ", taken: " + nTaken + "]"
	Then("NEGATIVE: and the oracle takes 150 or more features in all", nTaken >= 150, 1)
EndScenario()

# --- 6. the boxes ---------------------------------------------------------------------------
Scenario("The boxes are untouched: BoundsOf still says 360 degrees for Fiji and Bounds the whole set")
	oW = GfWorld()
	aF = oW.BoundsOf(1)
	Then("Fiji's box is [ -180, -19, 180, -16 ] as it always was", GfList(aF), "-180,-19,180,-16")
	Then("Russia's box is [ -180, 50, 180, 75 ]", GfList(oW.BoundsOf(5)), "-180,50,180,75")
	Then("Africa's box is its own, [ -17, -34, 51, 37 ]", GfList(oW.BoundsOf(2)), "-17,-34,51,37")
	aIn = oW.IndicesWithin(160, -90, -160, 90)
	Then("after a windowed question the boxes are the same: Fiji", GfList(oW.BoundsOf(1)), "-180,-19,180,-16")
	Then("and the set's own box is [ -180, -90, 180, 75 ]", GfList(oW.Bounds()), "-180,-90,180,75")
	Then("NEGATIVE: the count did not change", oW.Count(), 11)
	oS = oW.Within(160, -90, -160, 90)
	Then("a subset made by Within keeps the wide box of its Fiji: still 360", GfWidth(oS, 1), 360)
EndScenario()

# --- 7. Within -------------------------------------------------------------------------------
Scenario("Within is Subset of IndicesWithin: a stzGeoFeatures whose Count is the number of indices")
	oW = GfWorld()
	aWins = [ [ -20, -36, 52, 38 ], [ 170, -90, -170, 90 ], [ 160, -90, 180, 90 ], [ -180, -90, -160, 90 ], [ 100, 40, -170, 80 ], [ 0, 0, 0, 0 ] ]
	nBad = 0
	nBadNames = 0
	for k = 1 to len(aWins)
		aWin = aWins[k]
		aIdx = oW.IndicesWithin(aWin[1], aWin[2], aWin[3], aWin[4])
		oS = oW.Within(aWin[1], aWin[2], aWin[3], aWin[4])
		if oS.Count() != len(aIdx)  nBad++  ok
		for m = 1 to len(aIdx)
			if NOT GfIs(GfName(oS, m), oW.NameOf(aIdx[m]))  nBadNames++  ok
		next
	next
	Then("for six windows the Count of Within equals the number of indices", nBad, 0)
	Then("and its features are those indices, in order, by name", nBadNames, 0)
	oA = oW.Within(-20, -36, 52, 38)
	Then("the Africa window's set holds two features", oA.Count(), 2)
	Then("they are Africa and Wide180", GfIs(GfName(oA, 1), "Africa") + GfIs(GfName(oA, 2), "Wide180"), 2)
	Then("NEGATIVE: Fiji is not among them", oA.IndexOfName("Fiji"), 0)
	oP = oW.Within(170, -30, -170, 0)
	Then("the Pacific window, latitude -30..0, holds Fiji alone", oP.Count(), 1)
	Then("it is Fiji, whole: both parts kept", GfIs(GfName(oP, 1), "Fiji") + GfParts(oP, 1), 3)
	oN = oW.Within(17, 0, 17, 0)
	Then("NEGATIVE: a window that takes nothing makes a set of no features", oN.Count(), 0)
	Then("NEGATIVE: and the original set is untouched", oW.Count(), 11)
EndScenario()

# --- 8. no features, one feature ------------------------------------------------------------
Scenario("An empty set answers [ ], and a set of one feature answers for that one")
	oE = StzGeoFeaturesFromJson('{"type":"FeatureCollection","features":[]}')
	Then("no features", oE.Count(), 0)
	Then("IndicesWithin answers an empty list", len(oE.IndicesWithin(-180, -90, 180, 90)), 0)
	Then("and so does a window across the line", len(oE.IndicesWithin(170, -90, -170, 90)), 0)
	oEw = oE.Within(-180, -90, 180, 90)
	Then("Within answers a set of no features", oEw.Count(), 0)
	oF = StzGeoFeaturesFromJson(GfCollection([ GfMulti("Fiji", GfBox(177, -19, 180, -16) + "," + GfBox(-180, -19, -178, -16)) ]))
	Then("one feature, Fiji", oF.Count(), 1)
	Then("an Africa window does not take it", len(oF.IndicesWithin(-20, -36, 52, 38)), 0)
	Then("NEGATIVE: the Pacific window does", GfList(oF.IndicesWithin(170, -90, -170, 90)), "1")
	Then("NEGATIVE: and so does 160..180", GfList(oF.IndicesWithin(160, -90, 180, 90)), "1")
	oFw = oF.Within(170, -90, -170, 90)
	Then("Within of the Pacific window holds one feature", oFw.Count(), 1)
	oPt = StzGeoFeaturesFromJson('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"Fika"},"geometry":{"type":"Point","coordinates":[-179.9,-17]}}]}')
	Then("a single point at -179.9 keeps its own longitude as its middle: -180..-179 takes it", GfList(oPt.IndicesWithin(-180, -90, -179, 90)), "1")
	Then("NEGATIVE: 179..180 does not", len(oPt.IndicesWithin(179, -90, 180, 90)), 0)
EndScenario()

# --- 9. arguments ---------------------------------------------------------------------------
Scenario("A window is four numbers: text, a list or NaN raise a clear error, and nothing is evaluated")
	oW = GfWorld()
	nNaN = pow(10, 400) - pow(10, 400)
	Then("a text western edge raises", GfRaises(oW, "abc", 0, 1, 1), 1)
	Then("the error says what a window is", GfHas2(GfErr(oW, "abc", 0, 1, 1), "four numbers"), 1)
	Then("a number written as text raises too", GfRaises(oW, "5", 0, 10, 10), 1)
	Then("an empty text raises", GfRaises(oW, 0, "", 1, 1), 1)
	Then("a list raises", GfRaises(oW, 0, 0, [ 1 ], 1), 1)
	Then("a NaN edge raises", GfRaises(oW, nNaN, 0, 1, 1), 1)
	Then("a NaN northern edge raises", GfRaises(oW, 0, 0, 1, nNaN), 1)
	Then("Within raises the same way", GfWithinRaises(oW, "abc", 0, 1, 1), 1)
	Then("text that would run code is only refused, never run: the error names the window", GfHas2(GfErr(oW, "system('x')", 0, 1, 1), "four numbers"), 1)
	Then("NEGATIVE: ordinary numbers do not raise", GfRaises(oW, -20, -36, 52, 38), 0)
	Then("NEGATIVE: zero is a number", GfRaises(oW, 0, 0, 0, 0), 0)
	Then("NEGATIVE: infinity is a number: -inf..inf takes the whole set", len(oW.IndicesWithin(-pow(10, 400), -pow(10, 400), pow(10, 400), pow(10, 400))), 11)
	Then("NEGATIVE: longitudes past 180 are compared as given, not wrapped: 170..190 takes the middles from 170 up, 179.5, 175, 175 and 180",
		GfList(oW.IndicesWithin(170, -90, 190, 90)), "1,4,6,11")
EndScenario()

# --- 10. the source ----------------------------------------------------------------------------
Scenario("The source states the rule and no longer calls the trap open")
	cSrc = read("../../geo/stzGeoFeatures.ring")
	Then("no 'Defect:' line is left in the class", GfHas2(cSrc, "Defect:"), 0)
	Then("no 'warning' line for the antimeridian is left", GfHas2(cSrc, "same antimeridian trap"), 0)
	Then("the class paragraph says the trap is handled", GfHas2(cSrc, "The trap in the windows is handled"), 1)
	Then("it says the picture was drawn with the old behaviour", GfHas2(cSrc, "was drawn with the OLD behaviour"), 1)
	Then("and that it has not been redrawn since", GfHas2(cSrc, "it has not been"), 1)
	Then("the block gives the across-the-line rule", GfHas2(cSrc, "so 170 to -170 is a Pacific window"), 1)
	Then("the block gives the edge rule", GfHas2(cSrc, "A middle exactly on an edge is inside"), 1)
	Then("NEGATIVE: the class text no longer says the windows take Fiji for an Africa window as a standing fact", GfHas2(cSrc, "so Within and IndicesWithin take Fiji"), 0)
EndScenario()

Summary()

# --------------------------------------------------------------------------------------
# helpers (after the scenarios: in Ring, code after a func is part of the func)

# a text of a list, numbers joined by commas, for a byte-for-byte comparison of the answer
func GfList(aL)
	cT = ""
	for i = 1 to len(aL)
		if i > 1  cT += ","  ok
		cT += "" + aL[i]
	next
	return cT

# the name of feature n of a set, "" when the set has fewer: a failing guard must say so, not stop
func GfName(oS, n)
	if n < 1 or n > oS.Count()  return ""  ok
	return oS.NameOf(n)

# the name of the feature whose position is the nth item of aIdx
func GfNameAt(oS, aIdx, n)
	if n > len(aIdx)  return ""  ok
	return GfName(oS, aIdx[n])

func GfParts(oS, n)
	if n < 1 or n > oS.Count()  return 0  ok
	return oS.PartCount(n)

# the longitude width of feature n's stored box, -1 when there is no such feature
func GfWidth(oS, n)
	if n < 1 or n > oS.Count()  return -1  ok
	aB = oS.BoundsOf(n)
	return aB[3] - aB[1]

func GfHas(aL, n)
	for i = 1 to len(aL)
		if aL[i] = n  return 1  ok
	next
	return 0

# exact text equality, length first (no text here holds a NUL)
func GfIs(cA, cB)
	if len(cA) != len(cB)  return 0  ok
	if strcmp(cA, cB) = 0  return 1  ok
	return 0

func GfHas2(cText, cNeedle)
	if substr(cText, cNeedle) > 0  return 1  ok
	return 0

func GfKeep(aIdx, aAllowed)
	aOut = []
	for i = 1 to len(aIdx)
		if GfHas(aAllowed, aIdx[i])  aOut + aIdx[i]  ok
	next
	return aOut

# the next number in [0, 1) from a fixed linear congruential generator
func GfRnd()
	$nGfSeed = ($nGfSeed * 1103515245 + 12345) % 2147483648
	return $nGfSeed / 2147483648

# a window of multiples of 0.5 degree: longitudes in -180..180, latitudes in -90..90 and ordered.
# When bOrdered the longitudes are ordered as well; otherwise they come as drawn (about half run across)
func GfWindow(bOrdered)
	x0 = floor(GfRnd() * 721) / 2 - 180
	x1 = floor(GfRnd() * 721) / 2 - 180
	y0 = floor(GfRnd() * 361) / 2 - 90
	y1 = floor(GfRnd() * 361) / 2 - 90
	if bOrdered and x0 > x1
		t = x0
		x0 = x1
		x1 = t
	ok
	if y0 > y1
		t = y0
		y0 = y1
		y1 = t
	ok
	return [ x0, y0, x1, y1 ]

# the OLD rule, the middle of the plain box inside the window, for the features in aOnly
func GfOldFormula(aMid, aLat, aOnly, aWin)
	aOut = []
	for k = 1 to len(aOnly)
		i = aOnly[k]
		if aMid[i] >= aWin[1] and aMid[i] <= aWin[3] and aLat[i] >= aWin[2] and aLat[i] <= aWin[4]
			aOut + i
		ok
	next
	return aOut

# the NEW rule from the hand-written middles: a window with its western edge past its eastern one runs across
func GfOracle(aMid, aLat, aWin)
	aOut = []
	for i = 1 to len(aMid)
		bLon = FALSE
		if aWin[1] <= aWin[3]
			if aMid[i] >= aWin[1] and aMid[i] <= aWin[3]  bLon = TRUE  ok
		else
			if aMid[i] >= aWin[1] or aMid[i] <= aWin[3]  bLon = TRUE  ok
		ok
		if bLon and aLat[i] >= aWin[2] and aLat[i] <= aWin[4]  aOut + i  ok
	next
	return aOut

func GfErr(oW, a, b, c, d)
	cErr = ""
	try
		oW.IndicesWithin(a, b, c, d)
	catch
		cErr = cCatchError
	done
	return cErr

func GfRaises(oW, a, b, c, d)
	if GfErr(oW, a, b, c, d) != ""  return 1  ok
	return 0

func GfWithinRaises(oW, a, b, c, d)
	cErr = ""
	try
		oW.Within(a, b, c, d)
	catch
		cErr = cCatchError
	done
	if cErr != ""  return 1  ok
	return 0

# --- the data, as GeoJSON written out
func GfPoly(cName, cCoords)
	return '{"type":"Feature","properties":{"name":"' + cName + '"},"geometry":{"type":"Polygon","coordinates":[[' + cCoords + ']]}}'

func GfMulti(cName, cPolys)
	return '{"type":"Feature","properties":{"name":"' + cName + '"},"geometry":{"type":"MultiPolygon","coordinates":[' + cPolys + ']}}'

# one polygon part: a rectangle, as the coordinates of a MultiPolygon member
func GfBox(x0, y0, x1, y1)
	return '[[[' + x0 + ',' + y0 + '],[' + x1 + ',' + y0 + '],[' + x1 + ',' + y1 + '],[' + x0 + ',' + y1 + '],[' + x0 + ',' + y0 + ']]]'

func GfRect(cName, x0, y0, x1, y1)
	return GfPoly(cName, '[' + x0 + ',' + y0 + '],[' + x1 + ',' + y0 + '],[' + x1 + ',' + y1 + '],[' + x0 + ',' + y1 + '],[' + x0 + ',' + y0 + ']')

func GfCollection(aFeatures)
	cJ = '{"type":"FeatureCollection","features":['
	for i = 1 to len(aFeatures)
		if i > 1  cJ += ","  ok
		cJ += aFeatures[i]
	next
	return cJ + "]}"

# a ring with a vertex every 10 degrees of longitude along lat -70, closed along lat -90
func GfAntarctica()
	cR = ""
	for x = -180 to 180 step 10
		cR += '[' + x + ',-70],'
	next
	cR += '[180,-90],[-180,-90],[-180,-70]'
	return GfPoly("Antarctica", cR)

func GfWorld()
	return StzGeoFeaturesFromJson(GfCollection([
		GfMulti("Fiji", GfBox(177, -19, 180, -16) + "," + GfBox(-180, -19, -178, -16)),
		GfRect("Africa", -17, -34, 51, 37),
		GfRect("Europe", -9, 36, 30, 60),
		GfRect("Touch180", 170, 50, 180, 60),
		GfMulti("Russia", GfBox(28, 50, 180, 75) + "," + GfBox(-180, 65, -169, 70)),
		GfAntarctica(),
		GfRect("Asia", 60, 10, 145, 70),
		GfRect("Americas", -170, -55, -30, 70),
		GfRect("Wide180", -90, 0, 90, 10),
		GfRect("Wide181", -90, 20, 91, 30),
		GfMulti("OnTheLine", GfBox(178, 0, 180, 5) + "," + GfBox(-180, 0, -178, 5))
	]))
