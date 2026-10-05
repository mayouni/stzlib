# stzGeoPoints: the curves behind the verdicts, for the same three invented patterns -- L(r) with the grey band
# of 39 simulated random patterns (EnvelopeL), and the nearest-neighbour distribution G(r) and empty-space
# distribution F(r). L above the band is clustering at that scale, below it is dispersion.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoPoints/ripley_g_f.ring
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
aR = [ 10, 20, 30, 40, 60, 80, 100, 130, 160, 200 ]

oC = new stzCanvas(1000, 700)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("The curves behind the verdicts: L(r), G(r) and F(r)", 20, 32).Fill("#111111")
oC.Flush()
for m = 1 to 3
	nX0 = 20 + (m - 1) * 325
	oX = oWin.With(aPat[m][2])
	aL = oX.L(aR)
	aE = oX.EnvelopeL(aR, 39, nSeed)
	aG = oX.G(aR)
	aF = oX.F(aR, 300, nSeed)
	# panel 1 (top): L with its band. x = radius 0..200 km, y = L from -40 to +120 km
	nBx = nX0 + 30
	nBy = 70
	nBw = 255
	nBh = 240
	oC.AddRectQ(nBx, nBy, nBw, nBh).FillQ("#FFFFFF").Stroke("#999999", 1)
	aHi = []
	aLo = []
	for i = 1 to len(aR)
		x = nBx + aR[i] / 200 * nBw
		aHi + x
		aHi + (nBy + nBh - (aE[i][2] + 40) / 240 * nBh)
	next
	for i = len(aR) to 1 step -1
		x = nBx + aR[i] / 200 * nBw
		aHi + x
		aHi + (nBy + nBh - (aE[i][1] + 40) / 240 * nBh)
	next
	oC.AddPolygonQ(aHi).FillQ("#BBBBBB88").Stroke("#999999", 0.8)
	nY0 = nBy + nBh - (0 + 40) / 240 * nBh
	oC.AddLineQ(nBx, nY0, nBx + nBw, nY0).Stroke("#777777", 0.8)
	aLine = []
	for i = 1 to len(aR)
		aLine + (nBx + aR[i] / 200 * nBw)
		aLine + (nBy + nBh - (aL[i] + 40) / 240 * nBh)
	next
	oC.AddPolylineQ(aLine).Stroke("#C0392B", 2)
	oC.SetFontQ(oBold, 15).AddTextQ(aPat[m][1] + ": L(r), km (-40 to 200)", nX0 + 30, 62).Fill("#111111")
	oC.Flush()
	# panel 2 (bottom): G and F, 0..1
	nBy2 = 380
	nBh2 = 220
	oC.AddRectQ(nBx, nBy2, nBw, nBh2).FillQ("#FFFFFF").Stroke("#999999", 1)
	aGl = []
	aFl = []
	for i = 1 to len(aR)
		aGl + (nBx + aR[i] / 200 * nBw)
		aGl + (nBy2 + nBh2 - aG[i] * nBh2)
		aFl + (nBx + aR[i] / 200 * nBw)
		aFl + (nBy2 + nBh2 - aF[i] * nBh2)
	next
	oC.AddPolylineQ(aGl).Stroke("#1B4F72", 2)
	oC.AddPolylineQ(aFl).Stroke("#27AE60", 2)
	oC.SetFontQ(oBold, 15).AddTextQ("G (blue), F (green), 0 to 1", nX0 + 30, 372).Fill("#111111")
	oC.Flush()
	oC.SetFontQ(oFont, 12).AddTextQ("0", nBx - 10, nBy2 + nBh2 + 14).Fill("#555555")
	oC.Flush()
	oC.SetFontQ(oFont, 12).AddTextQ("200 km", nBx + nBw - 38, nBy2 + nBh2 + 14).Fill("#555555")
	oC.Flush()
	? aPat[m][1] + " L " + @@( aL ) + " | band lo " + @@( aE[1] ) + " | G " + @@( aG )
next
oC.SetFontQ(oFont, 13).AddTextQ("grey band: 39 uniform simulations in the same window; red line: the observed L. Places are INVENTED and seeded.", 20, 640).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoPoints")
oC.ToPNGXT("ripley_g_f.png", 9)
? "-> ripley_g_f.png"
