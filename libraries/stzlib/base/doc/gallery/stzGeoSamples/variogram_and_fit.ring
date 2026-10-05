# stzGeoSamples: 80 invented rain gauges in Niger and the diagnostic nobody draws -- the variogram cloud
# (Variogram, bins of half the squared difference against distance) with the three fitted models
# (FitVariogram, GammaAt) and the gauges on the map, coloured by value (inverse distance weighting, IDWField).
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoSamples/variogram_and_fit.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
aXY = oWin.Sample(80, 11)
aS = []
for i = 1 to 80
	aS + aXY[i * 2 - 1]
	aS + aXY[i * 2]
	aS + (500 + 150 * sin(aXY[i * 2] * 0.9) * cos(aXY[i * 2 - 1] * 0.7) + ((i * 37) % 23))
next
oS = new stzGeoSamples(aS, oN)
aBins = oS.Variogram(10, 0)
? "bins [h km, gamma, pairs]: " + @@( aBins )
aModels = [ :Spherical, :Exponential, :Gaussian ]
aInk = [ "#1B4F72", "#27AE60", "#8E44AD" ]
aFit = []
for k = 1 to 3
	aFit + oS.FitVariogramXT(aBins, aModels[k])
	? aModels[k] + ": " + @@( aFit[k] )
next
aBest = oS.FitVariogramXT(aBins, :Best)
? "best: " + aBest[:model]

oC = new stzCanvas(1000, 440)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Gauges and the variogram that tells how far one gauge speaks for its neighbours", 20, 32).Fill("#111111")
oC.Flush()
# left: the map, gauges coloured by value
oIdw = oS.IDWField(25, 2)
oIdw.SetClassesEvery(6)
oIdw.SetRamp(:Blues)
oP = StzGeoConicFor(oN, :ConicEqualArea)
oP.FitFeaturesIn(oN, 20, 70, 440, 350, 4)
oIdw.DrawOn(oC, oP, 20, 70, 440, 350)
oP.DrawFeaturesOn(oC, oN, "#00000000", "#FFFFFF", 0.6)
for i = 1 to oS.Count()
	q = oP.Project(oS.PlaceOf(i)[1], oS.PlaceOf(i)[2])
	if len(q) = 2  oC.AddCircleQ(q[1], q[2], 3).FillQ("#111111").Stroke("#FFFFFF", 0.8)  ok
next
oC.SetFontQ(oBold, 15).AddTextQ("80 gauges over the IDW surface", 20, 62).Fill("#111111")
oC.Flush()
# right: the variogram
nBx = 540
nBy = 70
nBw = 430
nBh = 280
nHmax = 900
nGmax = 10000
oC.AddRectQ(nBx, nBy, nBw, nBh).FillQ("#FFFFFF").Stroke("#999999", 1)
for i = 1 to len(aBins)
	x = nBx + aBins[i][1] / nHmax * nBw
	y = nBy + nBh - aBins[i][2] / nGmax * nBh
	oC.AddCircleQ(x, y, 4).FillQ("#111111")
next
for k = 1 to 3
	oS.SetModel(aFit[k])
	aL = []
	for h = 0 to 880 step 20
		aL + (nBx + h / nHmax * nBw)
		aL + (nBy + nBh - oS.GammaAt(h) / nGmax * nBh)
	next
	oC.AddPolylineQ(aL).Stroke(aInk[k], 2)
	oC.SetFontQ(oFont, 14).AddTextQ(aModels[k] + "  range " + floor(aFit[k][:range]) + " km, sill " + floor(aFit[k][:sill]), nBx + 12, nBy + 20 + (k - 1) * 18).Fill(aInk[k])
	oC.Flush()
next
oC.SetFontQ(oBold, 15).AddTextQ("variogram: bins (black) and three fitted models", nBx, 62).Fill("#111111")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("distance 0 to " + nHmax + " km; gamma 0 to " + nGmax + "; best fit: " + aBest[:model], nBx, nBy + nBh + 20).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoSamples")
oC.ToPNGXT("variogram_and_fit.png", 9)
? "-> variogram_and_fit.png"
