# stzGeoProcess: one pattern from each of the seven processes in the same window (Niger), by GenerateIn,
# with the expected count (ExpectedCount) against the number drawn. The parents of the two cluster
# processes are never drawn; the inhomogeneous one follows a field that rises to the south-west.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoProcess/seven_processes.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
nA = oWin.AreaKm2()
nB = oWin.BoxAreaKm2()

# the intensity surface for the inhomogeneous process: a grid over the window, richer toward 11.7N, 0E
aG = StzEngineGeoGridOver(oWin.WindowBox(), 60)
aV = []
for r = 0 to aG[6] - 1
	for c = 0 to aG[5] - 1
		nLon = aG[1] + c * aG[3]
		nLat = aG[2] + r * aG[4]
		aV + (0.0012 * exp(-((nLat - 11.7) * (nLat - 11.7) + nLon * nLon) / 30))
	next
next

aP = []
oP1 = new stzGeoProcess(:Poisson)
oP1.SetIntensity(0.00015)
oP2 = new stzGeoProcess(:Binomial)
oP2.SetCount(180)
oP3 = new stzGeoProcess(:Inhomogeneous)
oP3.SetIntensityGrid(aG, aV)
oP4 = new stzGeoProcess(:MaternCluster)
oP4.SetParentIntensity(0.000004)
oP4.SetMeanChildren(40)
oP4.SetRadiusKm(60)
oP5 = new stzGeoProcess(:Thomas)
oP5.SetParentIntensity(0.000004)
oP5.SetMeanChildren(40)
oP5.SetSigmaKm(30)
oP6 = new stzGeoProcess(:MaternII)
oP6.SetIntensity(0.0004)
oP6.SetHardCoreKm(40)
oP7 = new stzGeoProcess(:SSI)
oP7.SetCount(180)
oP7.SetHardCoreKm(40)
aP = [ oP1, oP2, oP3, oP4, oP5, oP6, oP7 ]

oC = new stzCanvas(1000, 560)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Seven point processes, one window", 20, 32).Fill("#111111")
oC.Flush()
for m = 1 to 7
	nCol = (m - 1) % 4
	nRow = floor((m - 1) / 4)
	nX0 = 10 + nCol * 247
	nY0 = 50 + nRow * 255
	oP = StzGeoConicFor(oN, :ConicEqualArea)
	oP.FitFeaturesIn(oN, nX0 + 6, nY0 + 25, nX0 + 236, nY0 + 190, 3)
	oM = StzGeoMap(oP, oN)
	oM.DrawRegionsOn(oC, "#FFFFFF", 0.5)
	aPts = aP[m].GenerateIn(oWin, 20261005)
	for i = 1 to len(aPts) / 2
		q = oP.Project(aPts[i * 2 - 1], aPts[i * 2])
		if len(q) = 2  oC.AddCircleQ(q[1], q[2], 1.5).FillQ("#1B4F72CC")  ok
	next
	oC.SetFontQ(oBold, 15).AddTextQ(aP[m].Kind(), nX0 + 6, nY0 + 18).Fill("#111111")
	oC.Flush()
	cInter = "no interaction"
	if aP[m].IsClustering()  cInter = "clustering"  ok
	if aP[m].IsInhibiting()  cInter = "inhibiting"  ok
	oC.SetFontQ(oFont, 13).AddTextQ(cInter + ": " + floor(len(aPts) / 2) + " drawn, " + floor(aP[m].ExpectedCount(nA, nB)) + " expected", nX0 + 6, nY0 + 212).Fill("#333333")
	oC.Flush()
	? aP[m].Kind() + ": " + floor(len(aPts) / 2) + " drawn, " + aP[m].ExpectedCount(nA, nB) + " expected, " + @@( aP[m].Content() )
next
oC.SetFontQ(oFont, 13).AddTextQ("Invented patterns, seeded. Parents of the cluster processes are not drawn; MaternII thins a proposal, SSI refuses a landing.", 20, 540).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoProcess")
oC.ToPNGXT("seven_processes.png", 9)
? "-> seven_processes.png"
