load "../../stzBase.ring"
decimals(2)

# GE10 -- THE FURNITURE, AND A FIELD THAT HAS A DIRECTION.
#
# Two panels. The upper one is the world at a moment: the line between day
# and night with its three twilight bands, drawn for the June solstice when
# the whole Arctic is lit and the whole Antarctic is not.
#
# The lower one is a field with two components, shown both ways at once --
# streamlines for the shape, which the eye reads as motion immediately, and
# arrows for the magnitude, which a streamline cannot carry.
#
# AND THE SCALE BAR IS MISSING FROM THE WORLD MAP ON PURPOSE. It asked for
# one and the map refused: the scale varies across that sheet by a factor
# the bar could not honour. A city plan gets one; a world map does not.

if NOT fexists("atlas/countries-110m.json")
	? "SKIPPED, by name: atlas/countries-110m.json is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oW = StzGeoFeaturesFromTopoJson(read("atlas/countries-110m.json"), "countries")

oC = new stzCanvas(1280, 1180)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 26).AddTextQ("What a map carries around it, and over it", 40, 50).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("day and night at a moment; a field shown as shape " +
	"and as magnitude; and a scale bar that refuses when it cannot be honest",
	40, 74).Fill("#777777")
oC.Flush()

# ---- the world at a moment ----------------------------------------------
nY0 = 130
oP = new stzGeoProjection(:EqualEarth)
oP.FitFeaturesIn(oW, 40, nY0, 1240, nY0 + 460, 4)
oM = StzGeoMap(oP, oW)
oM.SetPaper(30, nY0 - 10, 1250, nY0 + 470)
oM.SetSource("Natural Earth 110m; solar position from the Astronomical Almanac")
# THE OCEAN IS DRAWN, and that is not decoration. Without it the day-side
# sea is the canvas showing through, which reads as a bright crescent
# against the shaded night -- a halo the data does not have. Day and night
# have to be one surface for the terminator to be a line across it rather
# than an edge between two materials.
oP.DrawSphereOn(oC, "#EEF1F4", "#00000000", 0)
oC.Flush()
oM.SetNoData("#DCE2E8")
oM.DrawSheetOn(oC, "#B8C2CC", 0.4)

nYear = 2026  nMon = 6  nDay = 21  nHour = 12
aSun = oM.SunAt(nYear, nMon, nDay, nHour)

# THE NIGHT SIDE, FILLED -- four nested spherical caps, drawn outermost
# first and each translucent, so they accumulate into a gradient rather
# than a step. The first version of this sheet sampled every sixth pixel
# and painted a rectangle, which gave a staircase along the terminator and
# two flat tones; the Principal said so.
oM.DrawNightOn(oC, nYear, nMon, nDay, nHour, "#16294715")

oM.DrawTwilightOn(oC, nYear, nMon, nDay, nHour, "#2C4A7A66")

# the subsolar point
aQ = oP.Project(aSun[:lon], aSun[:lat])
if len(aQ) = 2
	oC.AddCircleQ(aQ[1], aQ[2], 7).FillQ("#F0B429").Stroke("#B07D0A", 1.5)
	oC.Flush()
	oM.DrawHaloTextOn(oC, oFont, 12, "the sun is overhead here",
		aQ[1] + 14, aQ[2] + 4, "#1A1A1A", "#FFFFFF", 1.6)
ok

# NORTH, MEASURED. On this projection it is up; on a rolled one it would
# not be, and the arrow would say so without anybody editing it.
oM.DrawNorthArrowOn(oC, oFont, 12, 90, nY0 + 400, 34, 0, 0, "#555555")

# ...AND THE SCALE BAR, WHICH REFUSES
nBar = oM.DrawScaleBarOn(oC, oFont, 12, 180, nY0 + 400, 150, 0, "#555555")
cBarNote = "a scale bar was asked for here and REFUSED: the scale varies " +
	"across this sheet by a factor of " + StzFactNumText(oM.ScaleVariation()) +
	", so no single bar is true"
if nBar > 0  cBarNote = "scale bar drawn"  ok

oC.SetFontQ(oFont, 17).AddTextQ("The world at " + nHour + ":00 UTC on the June solstice",
	40, nY0 - 30).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("the terminator and its three twilight bands -- civil, " +
	"nautical, astronomical, at 6, 12 and 18 degrees below the horizon",
	40, nY0 - 12).Fill("#888888")
oC.Flush()
oC.SetFontQ(oFont, 12).AddTextQ(cBarNote, 40, nY0 + 492).Fill("#B04A2A")
oC.Flush()
oC.SetFontQ(oFont, 12).AddTextQ("the whole Arctic is lit and the whole Antarctic is " +
	"not -- the terminator stops at 66.56 degrees, which is what the Arctic Circle IS",
	40, nY0 + 512).Fill("#888888")
oC.Flush()

# ---- a field with a direction --------------------------------------------
nY1 = nY0 + 570
oC.SetFontQ(oFont, 17).AddTextQ("A field that has a direction, shown both ways",
	40, nY1).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("evenly spaced, so the density says nothing and the " +
	"shape says everything; the stroke thickens with speed, and the heads sit " +
	"ALONG each line rather than at its end -- where a line ends is where " +
	"it met a neighbour, which says nothing about the field",
	40, nY1 + 20).Fill("#888888")
oC.Flush()

# an invented flow: two gyres, the shape an ocean basin makes
aG = [ -180, -80, 5, 5, 73, 33 ]
aU = []
aV = []
for j = 0 to 32
	for i = 0 to 72
		lon = -180 + 5 * i
		lat = -80 + 5 * j
		u = 0
		v = 0
		# two rotating centres, plus a westerly drift that grows with latitude
		aC = [ [ -60, 30, 1 ], [ 60, -25, -1 ] ]
		for k = 1 to 2
			dx = (lon - aC[k][1]) / 40
			dy = (lat - aC[k][2]) / 30
			r2 = dx*dx + dy*dy + 0.35
			u += aC[k][3] * -dy / r2
			v += aC[k][3] * dx / r2
		next
		u += 0.5 * sin(lat * 3.141592653589793 / 90)
		aU + u
		aV + v
	next
next

nY2 = nY1 + 46
oP2 = new stzGeoProjection(:EqualEarth)
oP2.FitFeaturesIn(oW, 40, nY2, 1240, nY2 + 400, 4)
oM2 = StzGeoMap(oP2, oW)
oM2.SetPaper(30, nY2 - 10, 1250, nY2 + 410)
# THE LAND HAS TO SURVIVE A HUNDRED AND FORTY-SIX LINES ON TOP OF IT. A
# basemap tuned to look right on its own disappears under a dense flow, so
# the contrast here is set against what covers it rather than against
# taste: a pale sea, a warm land, and a border dark enough to read between
# two streamlines.
oP2.DrawSphereOn(oC, "#EFF4F9", "#00000000", 0)
oC.Flush()
oM2.SetNoData("#E2DCD2")
oM2.DrawSheetOn(oC, "#9AA4AE", 0.7)

aSeeds = []
for lat = -70 to 70 step 10
	for lon = -170 to 170 step 20
		aSeeds + lon
		aSeeds + lat
	next
next
# EVENLY-SPACED, and the stroke carries the speed. The grid-seeded version
# put the lines where the SEEDS were: crowded in the gyre centres, bald in
# the drift between them, with no way to read a dense patch as fast flow
# rather than as a lucky lattice.
nLines = oM2.DrawFlowOnXT(oC, aG, aU, aV, 3.2, "#2F5D9E", "#C0392B", 0.35, 1.9, 400)
nArrows = 0

oC.SetFontQ(oFont, 12).AddTextQ("" + nLines + " evenly-spaced streamlines over an " +
	"invented two-gyre flow -- each stops where it comes within half a separation " +
	"of another, so the SPACING carries nothing and the shape carries everything; " +
	"the stroke thickens with speed", 40, nY2 + 430).Fill("#888888")
oC.Flush()

oC.ToPNG("geo_furniture.png")

? "-- the sun, on the June solstice at " + nHour + ":00 UTC --"
? "  overhead at " + aSun[:lat] + ", " + aSun[:lon] +
  "  (declination " + aSun[:declination] + ", equation of time " + aSun[:equationOfTime] + " min)"
? "  the terminator reaches latitude " + _MaxLat(oM.TerminatorAt(nYear, nMon, nDay, nHour))
? "  sun up at 0,80? " + oM.IsDaylightAt(nYear, nMon, nDay, nHour, 0, 80) +
  "   at 0,-80? " + oM.IsDaylightAt(nYear, nMon, nDay, nHour, 0, -80)
? ""
? "-- the scale bar --"
? "  scale varies across this sheet by x" + oM.ScaleVariation() +
  " -- so the bar was refused (it returned " + nBar + ")"
oCity = StzGeoMap(new stzGeoProjection(:Mercator), oW)
oCity.Projection().FitPointsIn([ 2.2, 48.8, 2.5, 48.9 ], 0, 0, 600, 300, 10)
oCity.SetPaper(0, 0, 600, 300)
? "  on a city-sized sheet it is x" + oCity.ScaleVariation() +
  ", and a bar of " + oCity.ScaleBarAt(140, 48.85)[:km] + " km draws"
? ""
? "-- the field --"
? "  " + nLines + " evenly-spaced streamlines"
? "-> geo_furniture.png"

func _MaxLat paRing
	_m_ = 0
	for _i_ = 1 to len(paRing) / 2
		if fabs(paRing[_i_ * 2]) > _m_  _m_ = fabs(paRing[_i_ * 2])  ok
	next
	return _m_
