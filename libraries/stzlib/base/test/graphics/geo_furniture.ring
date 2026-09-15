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
oM.SetNoData("#F2F2F2")
oM.DrawSheetOn(oC, "#C9C9C9", 0.4)

nYear = 2026  nMon = 6  nDay = 21  nHour = 12
aSun = oM.SunAt(nYear, nMon, nDay, nHour)

# THE NIGHT SIDE AS SHADING, sampled rather than filled. The terminator is
# a great circle, so on most projections it leaves the sheet at one edge
# and returns at the other -- a filled polygon would have to decide what
# "inside" means on a projection that cuts it, and would get it wrong at
# exactly the two solstices. Asking each pixel-ish cell instead cannot.
nStep = 6
for py = nY0 to nY0 + 460 step nStep
	for px = 40 to 1240 step nStep
		aG = oP.Invert(px, py)
		if len(aG) < 2  loop  ok
		nEl = oM.SolarElevationAt(nYear, nMon, nDay, nHour, aG[1], aG[2])
		if nEl >= 0  loop  ok
		cInk = "#1A2A4422"
		if nEl < -18  cInk = "#12203A55"  ok
		oC.AddRectQ(px, py, nStep, nStep).FillQ(cInk).Stroke("#00000000", 0)
	next
next
oC.Flush()

oM.DrawTwilightOn(oC, nYear, nMon, nDay, nHour, "#2C4A7A")

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
oC.SetFontQ(oFont, 13).AddTextQ("streamlines carry the SHAPE, which the eye reads as " +
	"motion at once; arrows carry the MAGNITUDE, which a streamline cannot",
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
oM2.SetNoData("#F6F6F6")
oM2.DrawSheetOn(oC, "#DCDCDC", 0.4)

aSeeds = []
for lat = -70 to 70 step 10
	for lon = -170 to 170 step 20
		aSeeds + lon
		aSeeds + lat
	next
next
nLines = oM2.DrawStreamlinesOn(oC, aG, aU, aV, aSeeds, 0.9, 120, "#3E6FAF", 0.8)
nArrows = oM2.DrawVectorsOn(oC, aG, aU, aV, 5, 26, "#C0392B", 1.3)

oC.SetFontQ(oFont, 12).AddTextQ("" + nLines + " streamlines and " + nArrows +
	" arrows over the same invented two-gyre flow; the streamlines are " +
	"fourth-order Runge-Kutta, because Euler's method turns a closed gyre " +
	"into an opening spiral", 40, nY2 + 430).Fill("#888888")
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
? "  " + nLines + " streamlines, " + nArrows + " arrows"
? "-> geo_furniture.png"

func _MaxLat paRing
	_m_ = 0
	for _i_ = 1 to len(paRing) / 2
		if fabs(paRing[_i_ * 2]) > _m_  _m_ = fabs(paRing[_i_ * 2])  ok
	next
	return _m_
