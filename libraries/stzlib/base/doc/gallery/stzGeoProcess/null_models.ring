# stzGeoProcess: the same clustered pattern (invented, 182 places in Niger) judged against three nulls --
# Poisson, Binomial and MaternCluster -- by EnvelopeOf (39 simulations) and VerdictOn, which says at which
# scales the pattern escapes the band. Against the null that made it, it never does.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoProcess/null_models.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
nSeed = 20261005
oObs = oWin.With(oWin.SampleClustered(8, 25, 45, nSeed))
aR = [ 10, 20, 30, 40, 60, 80, 100, 130, 160, 200 ]
aL = oObs.L(aR)

oP1 = new stzGeoProcess(:Poisson)
oP1.SetIntensity(oObs.DensityPerKm2())
oP2 = new stzGeoProcess(:Binomial)
oP2.SetCount(oObs.Count())
oP3 = new stzGeoProcess(:MaternCluster)
oP3.SetParentIntensity(8 / oWin.BoxAreaKm2())
oP3.SetMeanChildren(25)
oP3.SetRadiusKm(45)
aP = [ oP1, oP2, oP3 ]

oC = new stzCanvas(1000, 460)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("One pattern, three null models: L(r) against each envelope", 20, 32).Fill("#111111")
oC.Flush()
for m = 1 to 3
	nX0 = 20 + (m - 1) * 325
	aEnv = aP[m].EnvelopeOf(oObs, aR, 39, nSeed)
	aV = aP[m].VerdictOn(oObs, aR, 39, nSeed, :L)
	nBx = nX0 + 30
	nBy = 80
	nBw = 255
	nBh = 240
	oC.AddRectQ(nBx, nBy, nBw, nBh).FillQ("#FFFFFF").Stroke("#999999", 1)
	aBand = []
	for i = 1 to len(aR)
		aBand + (nBx + aR[i] / 200 * nBw)
		aBand + (nBy + nBh - (aEnv[i][:hi] + 40) / 440 * nBh)
	next
	for i = len(aR) to 1 step -1
		aBand + (nBx + aR[i] / 200 * nBw)
		aBand + (nBy + nBh - (aEnv[i][:lo] + 40) / 440 * nBh)
	next
	oC.AddPolygonQ(aBand).FillQ("#BBBBBB88").Stroke("#999999", 0.8)
	nY0 = nBy + nBh - 40 / 440 * nBh
	oC.AddLineQ(nBx, nY0, nBx + nBw, nY0).Stroke("#777777", 0.8)
	aLine = []
	for i = 1 to len(aR)
		aLine + (nBx + aR[i] / 200 * nBw)
		aLine + (nBy + nBh - (aL[i] + 40) / 440 * nBh)
	next
	oC.AddPolylineQ(aLine).Stroke("#C0392B", 2)
	oC.SetFontQ(oBold, 15).AddTextQ("null: " + aP[m].Kind(), nX0 + 30, 68).Fill("#111111")
	oC.Flush()
	cSay = "consistent with the null at every radius"
	if len(aV[:above]) > 0  cSay = "above the band at " + len(aV[:above]) + " of " + len(aR) + " radii"  ok
	if len(aV[:below]) > 0  cSay += ", below at " + len(aV[:below])  ok
	oC.SetFontQ(oFont, 14).AddTextQ(cSay, nX0 + 30, 342).Fill("#222222")
	oC.Flush()
	? aP[m].Kind() + ": " + @@( aV )
next
oC.SetFontQ(oFont, 13).AddTextQ("grey band: lowest and highest L over 39 simulations; red: the observed L (-40 to 400 km). The pattern is INVENTED.", 20, 420).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoProcess")
oC.ToPNGXT("null_models.png", 9)
? "-> null_models.png"
