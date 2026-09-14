load "../../stzBase.ring"
decimals(2)

# GE2c -- THE SHEET A READER BELIEVES, and the interactive layer under it.
#
# The Principal handed over two frames of an Our World in Data map and asked
# for that level of clarity: clean borders, clean class colours, readable
# text, and the ability to put an interactive layer over a map the way the
# diagram plane does for any diagram.
#
# FOUR THINGS THE GOOD STATISTICAL MAPS DO THAT THIS PLANE DID NOT:
#
#   1. DARK HAIRLINE BORDERS, NOT WHITE. A white border between two pale
#      classes erases the boundary exactly where the map is doing its work.
#   2. A RAMP LEGEND WITH THE NUMBERS AT THE JOINS, and a hatched NO DATA
#      swatch so "not measured" is visibly not a value. A reader matches a
#      colour to a position on a bar; the numbers belong where the meaning
#      changes.
#   3. A SELECTION IS OUTLINED, NOT RECOLOURED. Recolouring destroys the one
#      thing the map encodes. The lower panel selects a whole class -- which
#      is what clicking a legend swatch means -- and the class is framed in
#      the legend AND outlined on the map, so the two read as one gesture.
#   4. TEXT OVER COLOUR GETS A HALO. A label on a choropleth has no single
#      background: the same word crosses a pale class and a dark one, so the
#      colour system's "this ink on THAT background" has no answer and the
#      cartographer's halo does.
#
# AND THE INTERACTIVE LAYER IS THE SVG ITSELF. SetInteractive gives every
# region an id a script can address and a class a stylesheet can hover --
# the same mechanism the diagram plane has had since DN3b. This file writes
# the SVG out beside the picture and prints what it carries.
#
# The data is INVENTED: a plausible-looking indicator, not a real one. A
# sheet in this style is persuasive, which is exactly why it must not carry
# numbers nobody measured.

if NOT fexists("atlas/countries-110m.json")
	? "SKIPPED, by name: atlas/countries-110m.json is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oW = StzGeoFeaturesFromTopoJson(read("atlas/countries-110m.json"), "countries")

# an invented indicator, highest in the Sahel and falling with latitude;
# a handful of countries left with NO value on purpose, so the no-data
# swatch has something to stand for
aVals = []
nSeed = 20260914
for i = 1 to oW.Count()
	b = oW.BoundsOf(i)
	cy = (b[2] + b[4]) / 2
	cx = (b[1] + b[3]) / 2
	nSeed = (nSeed * 1103515245 + 12345) % 2147483648
	if (nSeed % 100) < 4
		aVals + ""
		loop
	ok
	v = 22 * exp(-(pow(cy - 12, 2) / 260 + pow(cx - 18, 2) / 5200))
	v += 3 * exp(-(pow(cy - 22, 2) / 300 + pow(cx - 95, 2) / 900))
	v += (nSeed % 1000) / 1000 * 0.4
	aVals + v
next

aEdges = [ 0, 0.5, 1, 2, 5, 10, 20, 30 ]
cInk = "#4A4A4A"

aPanel = [ [ "Every country in its class", "dark hairline borders; the numbers sit at the joins" ],
           [ "One class selected", "outlined on the map and framed in the legend -- one gesture, shown twice" ] ]

oC = new stzCanvas(1300, 1210)
oC.SetBackground("#FFFFFF")
cTitle = "The sheet a reader believes"
oC.SetFontQ(oFont, 26).AddTextQ(cTitle, 40, 50).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("clean borders, a ramp legend, a selection that outlines " +
	"rather than recolours -- and every region carrying its own identity into the SVG",
	40, 74).Fill("#777777")
oC.Flush()

for m = 1 to 2
	nY0 = 146 + (m - 1) * 520
	oP = new stzGeoProjection(:EqualEarth)
	oP.FitFeaturesIn(oW, 50, nY0, 1250, nY0 + 420, 4)
	oM = StzGeoMap(oP, oW)
	oM.SetSource("Invented, for a sheet")
	oM.SetPaper(40, nY0 - 10, 1260, nY0 + 430)
	oM.SetValuesQ(aVals).SetClassesQ(aEdges)
	oM.SetRamp(:YlOrRd)
	oM.SetOpenTop(TRUE)
	# NO DATA IS HATCHED, AND THE FILL UNDER THE HATCH IS NEARLY THE PAGE.
	# The first version of this sheet said SetNoData("#FFFFFF") and stopped
	# there: white on a white page, so the five unmeasured countries were
	# indistinguishable from ocean and the legend advertised a category the
	# map never showed. The hatch is what carries the meaning now; the fill
	# only has to stay out of the ramp's way, which a near-white does and a
	# grey does not -- a grey joins the bottom of the scale.
	oM.SetNoData("#FCFCFC")
	oM.SetInteractive(TRUE)

	if m = 2
		# THE GESTURE: everyone between 2 and 5. That is class 4 of seven,
		# and it is what a reader does when they click a legend swatch.
		oM.HighlightClass(4)
	ok

	oM.DrawSheetOn(oC, cInk, 0.45)

	oC.SetFontQ(oFont, 17).AddTextQ(aPanel[m][1], 40, nY0 - 30).Fill("#1A1A1A")
	oC.Flush()
	oC.SetFontQ(oFont, 13).AddTextQ(aPanel[m][2], 40, nY0 - 12).Fill("#888888")
	oC.Flush()

	nEnd = oM.DrawRampLegendOn(oC, oFont, 13, 330, nY0 + 452, 560, 22, cInk)

	if m = 2
		# a named country, with a halo, to show text over colour
		k = oW.IndexOfName("Niger")
		if k > 0
			g = oM.LabelPointOf(k)
			q = oP.Project(g[1], g[2])
			if len(q) = 2
				oM.DrawHaloTextOn(oC, oFont, 13, "Niger  " + StzFactNumText(aVals[k]) + "%",
					q[1] - 26, q[2], "#FFFFFF", "#33000088", 1.4)
			ok
		ok
		# UNDER the legend, not beside it: the ramp ends in an open-top
		# arrow and a sentence set level with it runs into the point
		oC.SetFontQ(oFont, 13).AddTextQ("" + len(oM.Highlighted()) + " countries fall in the " +
			"selected class -- the frame in the legend and the outlines on the map are " +
			"the same gesture", 330, nEnd + 14).Fill("#555555")
		oC.Flush()
	ok
next

# ---- the interactive layer, written out and read back -------------------
cSvg = oC.ToSVG()
write("geo_sheet.svg", cSvg)
oC.ToPNG("geo_sheet.png")

nIds = len(StzFindCS("id=" + char(34) + "geo-", cSvg, TRUE))
nRegionClass = len(StzFindCS("geo-region", cSvg, TRUE))
nSwatch = len(StzFindCS("geo-legend-class-", cSvg, TRUE))

? "" + oW.Count() + " countries; classes " + (len(aEdges) - 1) + "; no data on " +
	_CountBlank(aVals) + " of them"
? "   the SVG carries " + nIds + " geo- identities, " + nRegionClass +
	" region classes and " + nSwatch + " legend swatches"
? "   a stylesheet can now hover .geo-region, and a script can address " +
	"#" + _FirstIdent(oW, oP) + " by name"
? "-> geo_sheet.png and geo_sheet.svg"

func _CountBlank paV
	_n_ = 0
	for _i_ = 1 to len(paV)  if NOT isNumber(paV[_i_])  _n_++  ok  next
	return _n_

func _FirstIdent poW, poP
	_m_ = StzGeoMap(poP, poW)
	return _m_.IdentOf(poW.IndexOfName("Niger"))
