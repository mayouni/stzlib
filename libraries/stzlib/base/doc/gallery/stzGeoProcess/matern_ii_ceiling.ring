# stzGeoProcess: how many points survive as the proposal rate is pushed up, for MaternII (thinning, which has
# a ceiling: StzGeoMaternIICeiling) and for SSI (refusal, which keeps packing) with a 40 km hard core, in the
# Niger window. A chart of GenerateIn counts, and where the ceiling line falls.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoProcess/matern_ii_ceiling.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
nA = oWin.AreaKm2()
nCore = 40
nCeil = StzGeoMaternIICeiling(1000, nCore)
? "ceiling at 1000 proposed per km2 and a 40 km core: " + nCeil + " per km2 = " + (nCeil * nA) + " in the window"
aRate = [ 0.00005, 0.0001, 0.0002, 0.0004, 0.0008, 0.0016, 0.0032 ]
aM2 = []
aSS = []
for i = 1 to len(aRate)
	oM2 = new stzGeoProcess(:MaternII)
	oM2.SetIntensity(aRate[i])
	oM2.SetHardCoreKm(nCore)
	aM2 + (len(oM2.GenerateIn(oWin, 20261005)) / 2)
	oSS = new stzGeoProcess(:SSI)
	oSS.SetCount(floor(aRate[i] * nA))
	oSS.SetHardCoreKm(nCore)
	aSS + (len(oSS.GenerateIn(oWin, 20261005)) / 2)
next
? "MaternII survivors " + @@( aM2 )
? "SSI kept " + @@( aSS )

oC = new stzCanvas(700, 460)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 20).AddTextQ("Thinning has a ceiling, refusal keeps packing (40 km core)", 20, 32).Fill("#111111")
oC.Flush()
nBx = 70
nBy = 60
nBw = 580
nBh = 330
oC.AddRectQ(nBx, nBy, nBw, nBh).FillQ("#FFFFFF").Stroke("#999999", 1)
nMax = 700
aL1 = []
aL2 = []
for i = 1 to len(aRate)
	x = nBx + (i - 1) / (len(aRate) - 1) * nBw
	aL1 + x
	aL1 + (nBy + nBh - aM2[i] / nMax * nBh)
	aL2 + x
	aL2 + (nBy + nBh - aSS[i] / nMax * nBh)
	decimals(5)
	cRt = "" + aRate[i]
	decimals(1)
	oC.SetFontQ(oFont, 12).AddTextQ(cRt, x - 22, nBy + nBh + 18).Fill("#555555")
	oC.Flush()
next
oC.AddPolylineQ(aL1).Stroke("#C0392B", 2.2)
oC.AddPolylineQ(aL2).Stroke("#1B4F72", 2.2)
oC.SetFontQ(oBold, 14).AddTextQ("MaternII survivors (red)", nBx + 20, nBy + 24).Fill("#C0392B")
oC.Flush()
oC.SetFontQ(oBold, 14).AddTextQ("SSI points kept (blue)", nBx + 20, nBy + 44).Fill("#1B4F72")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("proposed points per km2 (x axis), 0 to " + nMax + " points (y axis)", nBx, nBy + nBh + 40).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoProcess")
oC.ToPNGXT("matern_ii_ceiling.png", 9)
? "-> matern_ii_ceiling.png"
