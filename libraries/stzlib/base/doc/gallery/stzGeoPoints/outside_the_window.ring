# stzGeoPoints: a table of places some of which lie across the border -- Niamey area places, three in Mali, one in
# Nigeria and one in Algeria (INVENTED) -- observed in Niger's window. Outside counts them, Findings warns, the
# density counts them anyway, and stzGeoMap.AssignPoints sends them to region 0.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoPoints/outside_the_window.ring
load "../../stzBase.ring"
decimals(6)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
aIn = oWin.Sample(60, 20261005)
aOut = [ -2.0, 15.0, -3.0, 16.5, -1.5, 18.0, 8.5, 9.5, 5.0, 26.0 ]
aAll = aIn
for i = 1 to len(aOut)  aAll + aOut[i]  next
oX = oWin.With(aAll)
? "count " + oX.Count() + ", outside " + oX.Outside() + ", density " + oX.DensityPerKm2()
? "findings " + @@( oX.Findings() )
? "sound " + oX.IsSound()

oC = new stzCanvas(900, 480)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Places across the border: counted, reported, never dropped", 20, 32).Fill("#111111")
oC.Flush()
oP = new stzGeoProjection(:ConicEqualArea)
oP.Rotate([ -8, 0, 0 ])
oP.Parallels([ 12, 22 ])
oP.FitPointsIn([ -4, 8, 17, 27 ], 20, 60, 560, 440, 4)
oM = StzGeoMap(oP, oN)
oM.DrawRegionsOn(oC, "#FFFFFF", 0.6)
oM.SetPaper(10, 50, 570, 450)
aW = oM.AssignPoints(aAll)
for i = 1 to oX.Count()
	q = oP.Project(aAll[i * 2 - 1], aAll[i * 2])
	if len(q) = 2
		if aW[i] = 0
			oC.AddCircleQ(q[1], q[2], 5).FillQ("#C0392B").Stroke("#FFFFFF", 1)
		else
			oC.AddCircleQ(q[1], q[2], 2.6).FillQ("#1B4F72BB")
		ok
	ok
next
oC.SetFontQ(oBold, 16).AddTextQ("" + oX.Count() + " places, " + oX.Outside() + " outside the window (red)", 590, 90).Fill("#111111")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("Outside() = " + oX.Outside() + ", AssignPoints gives 0 to " + oM.PointsOutside(aAll), 590, 120).Fill("#333333")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("density " + oX.DensityPerKm2() + " per km2 counts all " + oX.Count(), 590, 144).Fill("#333333")
oC.Flush()
aF = oX.Findings()
oC.SetFontQ(oFont, 14).AddTextQ("Findings: " + aF[1][:severity] + " " + aF[1][:rule], 590, 180).Fill("#7B241C")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("IsSound() = " + oX.IsSound() + ": a warning does not break it", 590, 204).Fill("#333333")
oC.Flush()
chdir("../../doc/gallery/stzGeoPoints")
oC.ToPNGXT("outside_the_window.png", 9)
? "-> outside_the_window.png"
