# stzGeoField: the kernel density of 500 invented, clustered places in Niger (StzGeoDensityField, in places
# per km2, edge-corrected), drawn as a raster (DrawXT) and as five contour lines (ContourAt via DrawContoursOn),
# with the legend in places per million km2. Stats() says how much of the grid is known.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoField/density_and_contours.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
aObs = oWin.SampleClustered(6, 80, 60, 20261005)
oPat = oWin.With(aObs)
oFld = StzGeoDensityField(oPat, 20, 60)
aS = oFld.Stats()
oFld.SetClassesEvery(6)
oFld.SetRamp(:YlOrRd)
aLev = oFld.LevelsEvery(5)
? "places " + oPat.Count() + ", grid " + oFld.ColumnCount() + " x " + oFld.RowCount() + ", known " + aS[:known] + ", unknown " + aS[:unknown]
? "gate on an equal-area map: " + @@( oFld.FindingsOn(StzGeoConicFor(oN, :ConicEqualArea)) )
? "gate on Mercator: " + len(oFld.FindingsOn(new stzGeoProjection(:Mercator))) + " finding(s)"

oC = new stzCanvas(900, 460)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Where is it thickest? " + oPat.Count() + " invented places in Niger", 20, 32).Fill("#111111")
oC.Flush()
aT = [ "the places", "the density raster", "five contour levels" ]
for m = 1 to 3
	nX0 = 10 + (m - 1) * 295
	oP = StzGeoConicFor(oN, :ConicEqualArea)
	oP.FitFeaturesIn(oN, nX0 + 8, 80, nX0 + 282, 320, 4)
	oM = StzGeoMap(oP, oN)
	if m = 1
		oM.DrawRegionsOn(oC, "#FFFFFF", 0.6)
		for i = 1 to oPat.Count()
			q = oP.Project(aObs[i * 2 - 1], aObs[i * 2])
			if len(q) = 2  oC.AddCircleQ(q[1], q[2], 1.6).FillQ("#1B4F7299")  ok
		next
	but m = 2
		oFld.DrawXT(oC, oP, nX0 + 8, 80, nX0 + 282, 320, 245)
	else
		oM.DrawRegionsOn(oC, "#FFFFFF", 0.6)
		oFld.DrawContoursOn(oC, oP, aLev, "#A93226", 1.2)
	ok
	oC.SetFontQ(oBold, 15).AddTextQ(aT[m], nX0 + 8, 66).Fill("#111111")
	oC.Flush()
next
# the legend in places per million km2 (per km2 would be six zeros of nothing)
aBig = []
for i = 1 to len(oFld.Classes())  aBig + (oFld.Classes()[i] * 1000000)  next
oBig = StzGeoField(oFld.Grid(), oFld.Values())
oBig.SetClasses(aBig)
oBig.SetPalette(oFld.Palette())
oBig.SetUnit("places per million km2")
oBig.DrawLegendOn(oC, oFont, 330, 345, "places per million km2")
chdir("../../doc/gallery/stzGeoField")
oC.ToPNGXT("density_and_contours.png", 9)
? "-> density_and_contours.png"
