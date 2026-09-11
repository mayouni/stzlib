# A CHOROPLETH MAP, NARRATED -- DN24 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A choropleth paints each region by where its value falls among a few
# classes, darker meaning more, and a legend beside the map says what
# each shade stands for. The regions are polygons in map units, the
# classes are edges the author gives, and every fill follows by
# arithmetic; the value's ink is chosen per class so it reads on its
# shade. Four rules say what a map may not do -- a region with no value,
# a value beyond the classes, a shade lighter than the class before it,
# a class that colours nothing. And the legend SAYS WHY: a reader shown
# the witness cold should not have to guess what a rim means.
#
# This guide RUNS: every number below is read back from the substance the
# builder wrote, and every rule is asked through the catalogue's gate.
#
#   Run:  ring choropleth_narrated.ring

load "../../stzBase.ring"
load "gg_math_scenes.ring"

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")

? "-- Scene 1: six provinces coloured by people per km2, in four classes --"
oM = StzChoroplethDiagram(FONT, "People per km2", StzMathProvinces(), StzMathProvinceEdges())
oM.Layout()
oS = oM.Substance()
aReg = oS.ObjectsOfType("Region")
aSw = oS.ObjectsOfType("Swatch")
? "   " + len(aReg) + " regions, " + len(aSw) + " legend swatches, the edges " + edgesText(StzMathProvinceEdges())
chk("six regions and one swatch per class", len(aReg) = 6 and len(aSw) = 4)
cCentre = aReg[3]
? "   '" + oS.LabelOf(cCentre) + "' has " + oS.DataOf(cCentre, "value") + " and falls in class " + oS.DataOf(cCentre, "class")
chk("a value between the fourth and fifth edge falls in the fourth class -- the lower edge belongs, the upper does not",
    oS.DataOf(cCentre, "value") = 310 and oS.DataOf(cCentre, "class") = 4)
cNorth = aReg[1]
? "   '" + oS.LabelOf(cNorth) + "' has " + oS.DataOf(cNorth, "value") + " and falls in class " + oS.DataOf(cNorth, "class")
chk("the lightest class holds the smallest value", oS.DataOf(cNorth, "class") = 1)
chk("the legend's fourth swatch stands for the fourth class", oS.Holds("K4", [ "l4" ]))
chk("and every swatch's shade is darker than the one before it",
    oS.DataOf("l2", "lum") < oS.DataOf("l1", "lum") and oS.DataOf("l3", "lum") < oS.DataOf("l2", "lum") and
    oS.DataOf("l4", "lum") < oS.DataOf("l3", "lum"))

? ""
? "-- Scene 2: four rules about a map, and a sound one passes them --"
aF = StzCheckPictures([ [ "provinces", oM ] ]).Findings()
? "   every_region_has_a_value, values_fall_in_the_classes, darker_means_more, every_class_has_a_region"
chk("the map has nothing wrong with it", len(aF) = 0)

? ""
? "-- Scene 3: the same map with one of each mistake, and a legend that says why --"
? "   the centre at 450, above the last class; the south-west with no value;"
? "   the north lifted out of the first class so it colours nothing; a palette"
? "   whose third shade is lighter than its second."
oW = StzChoroplethDiagramXT(FONT, "People per km2", StzMathWrongProvinces(), StzMathProvinceEdges(), StzMathWrongPalette())
oW.Layout()
oT = oW.Substance()
aW = StzCheckPictures([ [ "wrong", oW ] ]).Findings()
say(aW)
chk("the hole is named", hits(aW, "every_region_has_a_value") = 1 and has(aW, "South-west"))
chk("the value beyond the classes is named with the edge it passes",
    hits(aW, "values_fall_in_the_classes") = 1 and has(aW, "Centre"))
chk("the shade out of order is caught, class against class", hits(aW, "darker_means_more") = 1)
chk("the class that colours nothing is caught", hits(aW, "every_class_has_a_region") = 1)
chk("and those four are everything the rules find", len(aW) = 4)
? "   the legend reads: " + oT.LabelOf("l1") + " / " + oT.LabelOf("l3") + " / " + oT.LabelOf("labove")
chk("the legend says why -- the empty class, the shade out of order, the value above the classes",
    StzFindFirst("(no region)", oT.LabelOf("l1")) > 0 and StzFindFirst("(out of order)", oT.LabelOf("l3")) > 0 and
    StzFindFirst("above 400", oT.LabelOf("labove")) > 0)

? ""
? "-- Scene 4: the pictures --"
if StzGraphicsDevice()
	oM.ToPNG("guide_choropleth.png")
	oW.ToPNG("guide_choropleth_witness.png")
	? "   wrote guide_choropleth.png and guide_choropleth_witness.png"
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

func edgesText aN
	_c_ = ""
	for _i_ = 1 to len(aN)
		if _i_ > 1  _c_ += ", "  ok
		_c_ += StzFactNumText(aN[_i_])
	next
	return _c_
