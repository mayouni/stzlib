# stzGeoField: 70 invented rain gauges in Niger turned into fields by stzGeoSamples -- inverse distance
# weighting, ordinary kriging and the kriging variance (the doubt) -- each drawn by DrawOn with its legend.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoField/rain_kriging.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)

# the gauges: places inside Niger, a rainfall that falls to the north with local bumps (INVENTED)
aXY = oWin.Sample(70, 20261005)
aS = []
for i = 1 to 70
	nLon = aXY[i * 2 - 1]
	nLat = aXY[i * 2]
	aS + nLon
	aS + nLat
	aS + (60 + 600 * exp(-(nLat - 11.7) / 5) + 50 * sin(1.3 * nLon) * cos(0.8 * nLat) + ((i * 37) % 17))
next
oS = new stzGeoSamples(aS, oN)
oS.FitAndUse(:Spherical)
? "model " + @@( oS.Model() )
? "cross-validation " + @@( oS.CrossValidate() )
? "gate " + @@( oS.Findings() )
oIdw = oS.IDWField(25, 2)
aK = oS.KrigeFields(25)
oKe = aK[1]
oKv = aK[2]
nMin = floor(oS.MinValue() / 50) * 50
nMax = ceil(oS.MaxValue() / 50) * 50
# (set everything BEFORE the fields go into a list: Ring copies an object it stores, so a change made
# through the list would not reach the original)
oIdw.SetClassesEvery(6)
oIdw.SetRamp(:Blues)
oIdw.SetUnit("mm of rain")
oKe.SetClassesEvery(6)
oKe.SetRamp(:Blues)
oKe.SetUnit("mm of rain")
oKv.SetClassesEvery(6)
oKv.SetRamp(:Reds)

oC = new stzCanvas(1000, 520)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Rain gauges to a surface: IDW, kriging, and how sure kriging is", 20, 32).Fill("#111111")
oC.Flush()
aT = [ "inverse distance, power 2", "ordinary kriging, spherical", "kriging variance" ]
aF = [ oIdw, oKe, oKv ]
for m = 1 to 3
	nX0 = 10 + (m - 1) * 330
	oP = StzGeoConicFor(oN, :ConicEqualArea)
	oP.FitFeaturesIn(oN, nX0 + 8, 90, nX0 + 312, 300, 4)
	aF[m].DrawOn(oC, oP, nX0 + 8, 90, nX0 + 312, 300)
	oP.DrawFeaturesOn(oC, oN, "#00000000", "#FFFFFF", 0.6)
	for i = 1 to oS.Count()
		q = oP.Project(oS.PlaceOf(i)[1], oS.PlaceOf(i)[2])
		if len(q) = 2  oC.AddCircleQ(q[1], q[2], 2).FillQ("#111111")  ok
	next
	oC.SetFontQ(oBold, 15).AddTextQ(aT[m], nX0 + 8, 76).Fill("#111111")
	oC.Flush()
	aF[m].DrawLegendOn(oC, oFont, nX0 + 8, 322, "")
next
chdir("../../doc/gallery/stzGeoField")
oC.ToPNGXT("rain_kriging.png", 9)
? "-> rain_kriging.png"
