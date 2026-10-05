# stzGeoPoints: three invented patterns of 200 places in Niger -- thrown at random (Sample), in clusters
# (SampleClustered) and kept apart (SampleDispersed) -- each with its mean centre, spatial median and
# standard deviational ellipse (EllipseRing) and the Clark-Evans verdict, whose truth is known.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoPoints/three_patterns.ring
load "../../stzBase.ring"
decimals(2)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
nSeed = 20261005
aPat = [ [ "uniform", oWin.Sample(200, nSeed) ],
         [ "clustered", oWin.SampleClustered(8, 25, 45, nSeed) ],
         [ "dispersed", oWin.SampleDispersed(200, 38, nSeed) ] ]

oC = new stzCanvas(1000, 480)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Are they clustered? Three invented patterns in Niger", 20, 32).Fill("#111111")
oC.Flush()
for m = 1 to 3
	nX0 = 10 + (m - 1) * 330
	oP = StzGeoConicFor(oN, :ConicEqualArea)
	oP.FitFeaturesIn(oN, nX0 + 8, 70, nX0 + 312, 330, 4)
	oM = StzGeoMap(oP, oN)
	oM.DrawRegionsOn(oC, "#FFFFFF", 0.6)
	aP = aPat[m][2]
	oX = oWin.With(aP)
	for i = 1 to oX.Count()
		q = oP.Project(aP[i * 2 - 1], aP[i * 2])
		if len(q) = 2  oC.AddCircleQ(q[1], q[2], 1.8).FillQ("#1B4F72BB")  ok
	next
	aPieces = oP.Ring(oX.EllipseRing(72))
	for k = 1 to len(aPieces)
		oC.AddPolylineQ(aPieces[k]).Stroke("#C0392B", 1.6)
	next
	aMc = oX.MeanCentre()
	aMd = oX.SpatialMedian()
	q = oP.Project(aMc[1], aMc[2])
	oC.AddCircleQ(q[1], q[2], 5).FillQ("#C0392B").Stroke("#FFFFFF", 1.2)
	q = oP.Project(aMd[1], aMd[2])
	oC.AddCircleQ(q[1], q[2], 5).FillQ("#F5B800").Stroke("#FFFFFF", 1.2)
	aCe = oX.ClarkEvans()
	oC.SetFontQ(oBold, 16).AddTextQ(aPat[m][1] + ": " + oX.Count() + " places", nX0 + 8, 58).Fill("#111111")
	oC.Flush()
	oC.SetFontQ(oFont, 14).AddTextQ("Clark-Evans R " + StzFactNumText(aCe[:r]) + ", z " + StzFactNumText(aCe[:z]) + " -> " + aCe[:verdict], nX0 + 8, 356).Fill("#222222")
	oC.Flush()
	aEl = oX.Ellipse()
	oC.SetFontQ(oFont, 13).AddTextQ("ellipse " + floor(aEl[:major]) + " x " + floor(aEl[:minor]) + " km, bearing " + floor(aEl[:bearing]) + " deg", nX0 + 8, 376).Fill("#555555")
	oC.Flush()
	? aPat[m][1] + ": " + @@( aCe ) + " centre " + @@( aMc ) + " median " + @@( aMd )
next
oC.SetFontQ(oFont, 13).AddTextQ("red dot: MeanCentre, yellow dot: SpatialMedian, red ring: standard deviational ellipse. Places are INVENTED and seeded.", 20, 420).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoPoints")
oC.ToPNGXT("three_patterns.png", 9)
? "-> three_patterns.png"
