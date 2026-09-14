load "../../stzBase.ring"
decimals(2)

# GE7b -- WHERE IS IT THICKEST? The same eight hundred invented places in
# Tunisia, seen three ways. Wolfram spends three of its twelve geo plot types
# on this and they are one substrate -- a grid of numbers -- looked at
# differently:
#
#   1. THE PLACES THEMSELVES. Where, but not how many, and past a few hundred
#      dots the eye cannot count them anyway. This is the panel the other two
#      exist to replace.
#   2. THE SMOOTHED INTENSITY (GeoSmoothHistogram, GeoDensityPlot): the
#      kernel density, in PLACES PER SQUARE KILOMETRE, resampled through the
#      projection into one image. The legend can be read because the unit is
#      a real one -- not "relative intensity", which is what a density map
#      says when it is afraid of its own arithmetic.
#   3. THE CONTOURS (GeoContourPlot): the same field at five levels, as
#      LINES. A contour is never a fill: the ground between two levels is not
#      one value, and shading it as though it were is the choropleth lie in
#      another costume.
#
# The density is EDGE-CORRECTED. Without it the coast reads thin everywhere,
# because most of a kernel centred on the shore lands in the sea -- the same
# bias GE7a met in Clark-Evans, and the guard measures it: 488 against 654
# per million km2 at the border, on a true 650.

if NOT fexists("atlas/admin1_tunisia.geojson")
	? "SKIPPED, by name: atlas/admin1_tunisia.geojson is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oU = StzGeoFeaturesFromJson(read("atlas/admin1_tunisia.geojson"))
oWin = StzGeoPoints([], oU)
nSeed = 20260914

# EIGHT HUNDRED PLACES AROUND SIX CENTRES, which is what a real table of
# clinics or boreholes looks like: not uniform, not one blob.
aObs = oWin.SampleClustered(6, 140, 55, nSeed)
oPat = oWin.With(aObs)
oFld = StzGeoDensityField(oPat, 8, 45)
aS = oFld.Stats()
oFld.SetClassesEvery(6)
oFld.SetRamp(:YlOrRd)

oC = new stzCanvas(1200, 880)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 23).AddTextQ("Where is it thickest? " + oPat.Count() +
	" places, three ways", 30, 44).Fill("#111111")

aPanel = [ "The places", "The smoothed intensity", "The contours" ]
aWhat = [ "where, but not how many",
          "kernel density, quartic at 45 km, edge-corrected",
          "the same field at five levels" ]

for m = 1 to 3
	nX0 = 20 + (m - 1) * 395
	oP = StzGeoConicFor(oU, :ConicEqualArea)
	oP.FitFeaturesIn(oU, nX0 + 60, 130, nX0 + 320, 700, 6)
	oM = StzGeoMap(oP, oU)
	oM.SetPaper(nX0, 120, nX0 + 380, 715)
	oM.SetSource("Natural Earth 1:10m; the places are INVENTED")

	if m = 1
		oM.DrawRegionsOn(oC, "#FFFFFF", 0.7)
		for i = 1 to oPat.Count()
			q = oP.Project(aObs[i * 2 - 1], aObs[i * 2])
			if len(q) = 2  oC.AddCircleQ(q[1], q[2], 1.6).FillQ("#1B4F7299").Stroke("#00000000", 0)  ok
		next
	but m = 2
		# THE RASTER GOES ON TOP OF THE LAND, AND NOTHING GOES ON TOP OF IT.
		# The first version drew the regions again afterwards to get their
		# borders back, and DrawRegionsOn FILLS -- so the land was repainted
		# grey over the density and all that survived was a one-pixel fringe
		# along the coast. The borders are drawn as OUTLINES instead.
		oM.DrawRegionsOn(oC, "#FFFFFF", 0.5)
		oFld.DrawXT(oC, oP, nX0 + 20, 125, nX0 + 370, 710, 235)
		for iR = 1 to oU.Count()
			for iK = 1 to oU.PartCount(iR)
				for aPc in oP.Ring(oU.OuterRingOf(iR, iK))
					if len(aPc) >= 4  oC.AddPolylineQ(aPc).Stroke("#FFFFFFAA", 0.6)  ok
				next
			next
		next
	else
		oM.DrawRegionsOn(oC, "#FFFFFF", 0.7)
		aLev = oFld.LevelsEvery(5)
		oFld.DrawContoursOn(oC, oP, aLev, "#A93226", 1.2)
	ok
	oC.Flush()
	oC.SetFontQ(oFont, 17).AddTextQ(aPanel[m], nX0 + 10, 84).Fill("#111111")
	oC.SetFontQ(oFont, 13).AddTextQ(aWhat[m], nX0 + 10, 103).Fill("#777777")
next

# THE LEGEND, in the unit the field is actually measured in. Per million km2
# because per km2 on a country this size is six zeros of nothing, and a
# legend nobody can read is a legend that was not written.
aBig = []
for i = 1 to len(oFld.Classes())  aBig + (oFld.Classes()[i] * 1000000)  next
oBig = StzGeoField(oFld.Grid(), oFld.Values())
oBig.SetClasses(aBig)
oBig.SetPalette(oFld.Palette())
oBig.SetUnit("places per million km2")
oBig.DrawLegendOn(oC, oFont, 830, 752, "places per million km2")

oC.SetFontQ(oFont, 13).AddTextQ("" + aS[:known] + " of " + (aS[:known] + aS[:unknown]) +
	" grid nodes stand on Tunisia; the rest are UNKNOWN, not zero -- 'no ground here' " +
	"and 'no places here' are different statements.", 30, 800).Fill("#777777")
oC.SetFontQ(oFont, 13).AddTextQ("The density is edge-corrected: without it the coast " +
	"reads thin everywhere, because most of a kernel centred on the shore lands in the sea.",
	30, 822).Fill("#777777")
oC.SetFontQ(oFont, 13).AddTextQ("A contour is a LINE and never a fill -- the ground " +
	"between two levels is not one value.", 30, 844).Fill("#777777")
oC.SetFontQ(oFont, 13).AddTextQ("Natural Earth 1:10m; the places are INVENTED, seeded, " +
	"and clustered on purpose so the density has something to find.", 30, 866).Fill("#777777")
oC.Flush()
oC.ToPNG("geo_field.png")

? "" + oPat.Count() + " places; field " + oFld.ColumnCount() + " x " + oFld.RowCount() +
	", " + aS[:known] + " nodes measured, " + aS[:unknown] + " unknown"
? "   density runs " + StzFactNumText(aS[:min] * 1000000) + " to " +
	StzFactNumText(aS[:max] * 1000000) + " places per million km2"
for g in oFld.FindingsOn(StzGeoConicFor(oU, :ConicEqualArea))
	? "   gate: " + g[:severity] + " " + g[:rule]
next
? "-> geo_field.png"
