# stzGeoProjection: Niger on the conic StzGeoConicFor picks for it (standard parallels at a sixth and
# five sixths of the latitude span), with Niamey projected and inverted, beside the same country on
# Mercator, where the area scale at its latitudes is printed (ArealScaleAt), and the UTM zone of Niamey.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoProjection/niger_conic_utm.ring
load "../../stzBase.ring"
decimals(2)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))

oC = new stzCanvas(980, 520)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Niger on two projections", 20, 32).Fill("#111111")
oC.Flush()
aSets = [ [ "Conic equal-area", StzGeoConicFor(oN, :ConicEqualArea) ], [ "Mercator", new stzGeoProjection(:Mercator) ] ]
for m = 1 to 2
	nX = 15 + (m - 1) * 480
	oP = aSets[m][2]
	oP.FitFeaturesIn(oN, nX + 10, 60, nX + 460, 400, 8)
	# parallels at 12, 16, 20 and 24 degrees and meridians every 4, over Niger only (DrawGraticuleOn would draw the whole sphere)
	for nLat = 12 to 24 step 4
		aL = []
		for nLon = -1 to 17  aL + nLon  aL + nLat  next
		oP.DrawLineOn(oC, aL, "#B9C6D8", 0.8)
	next
	for nLon = 0 to 16 step 4
		aL = []
		for nLat = 11 to 24  aL + nLon  aL + nLat  next
		oP.DrawLineOn(oC, aL, "#B9C6D8", 0.8)
	next
	oP.DrawFeaturesOn(oC, oN, "#EFE6CC", "#7C6B3E", 0.7)
	q = oP.Project(2.1254, 13.5116)
	oC.AddCircleQ(q[1], q[2], 5).FillQ("#C0392B").Stroke("#FFFFFF", 1.5)
	oC.SetFontQ(oBold, 14).AddTextQ("Niamey", q[1] + 8, q[2] + 4).Fill("#7A1010")
	oC.Flush()
	oC.SetFontQ(oBold, 16).AddTextQ(aSets[m][1], nX + 6, 425).Fill("#111111")
	oC.Flush()
	oC.SetFontQ(oFont, 13).AddTextQ(oP.Caption(), nX + 6, 445).Fill("#555555")
	oC.Flush()
	oC.SetFontQ(oFont, 13).AddTextQ("area scale at 13.5N: x" + StzFactNumText(oP.ArealScaleAt(2.1, 13.5)) +
		", at 23N: x" + StzFactNumText(oP.ArealScaleAt(2.1, 23)), nX + 6, 465).Fill("#333333")
	oC.Flush()
	aBack = oP.Invert(q[1], q[2])
	oC.SetFontQ(oFont, 13).AddTextQ("Niamey -> pixel " + floor(q[1]) + "," + floor(q[2]) + " -> back to " +
		StzFactNumText(aBack[1]) + ", " + StzFactNumText(aBack[2]), nX + 6, 485).Fill("#333333")
	oC.Flush()
next
aZ = StzGeoUtmZoneOf(2.1254, 13.5116)
oC.SetFontQ(oFont, 14).AddTextQ("UTM zone of Niamey: " + aZ[:zone] + aZ[:band] + ", central meridian " + aZ[:centralMeridian] +
	" E, false easting " + aZ[:falseEasting], 15, 508).Fill("#111111")
oC.Flush()
oU = StzGeoUtmProjection(aZ[:zone])
? "UTM " + aZ[:zone] + ": " + @@( aZ ) + " name " + oU.Name()
? "Niamey in the UTM projection's own units: " + @@( oU.Project(2.1254, 13.5116) )
chdir("../../doc/gallery/stzGeoProjection")
oC.ToPNGXT("niger_conic_utm.png", 9)
? "-> niger_conic_utm.png"
