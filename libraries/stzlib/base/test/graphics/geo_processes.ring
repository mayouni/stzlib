load "../../stzBase.ring"
decimals(2)

# GE7d -- SEVEN MECHANISMS, AND WHY THE NULL MODEL IS THE WHOLE QUESTION.
#
# The top row is the same window seven times, each filled by a different
# rule for putting points down. They are MECHANISMS, not shapes: two of
# them place points without regard to one another, two make clusters, two
# refuse to let points come close, and one follows a surface.
#
# The bottom row is why it matters. The same clustered pattern is judged
# twice: once against complete spatial randomness, which calls it
# significantly clustered at every scale and tells the reader nothing they
# could not see; and once against the very process that produced it, which
# finds nothing left to explain. Rejecting CSR is the answer to a question
# nobody asked.

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")

cJson = '{"type":"FeatureCollection","features":[{"type":"Feature",' +
	'"properties":{"name":"Square"},"geometry":{"type":"Polygon",' +
	'"coordinates":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}}]}'
oW = StzGeoFeaturesFromJson(cJson)
oOne = StzGeoPoints([ 0.5, 0.5 ], oW)
nArea = oOne.AreaKm2()

# the intensity surface for the inhomogeneous panel: rising to the east
aGrid = [ 0, 0, 0.05, 0.05, 21, 21 ]
aLam = []
for j = 0 to 20
	for i = 0 to 20
		aLam + (0.04 * i / 20)
	next
next

aPanels = [
	[ "Poisson",       "no interaction; the COUNT is random",        "#4A6FA5" ],
	[ "Binomial",      "the same, count fixed -- no spread at all",  "#4A6FA5" ],
	[ "Inhomogeneous", "follows a surface rising to the east",       "#4A6FA5" ],
	[ "MaternCluster", "children uniform in a disc round a parent",  "#C0392B" ],
	[ "Thomas",        "children gaussian: a scale, but no edge",    "#C0392B" ],
	[ "MaternII",      "inhibition by DELETION -- it has a ceiling", "#2E8B57" ],
	[ "SSI",           "inhibition by REFUSAL -- it packs",          "#2E8B57" ]
]

oC = new stzCanvas(1340, 760)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 26).AddTextQ("Seven ways to put points down", 40, 50).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("a point process is a MECHANISM, and which one you " +
	"assume is the whole of the question you are asking", 40, 74).Fill("#777777")
oC.Flush()

nW = 175
nH = 175
nY0 = 130
for p = 1 to len(aPanels)
	a = aPanels[p]
	nX = 40 + (p - 1) * (nW + 10)

	o = StzGeoProcess(a[1])
	if a[1] = "Poisson"
		o.SetIntensity(0.02)
	but a[1] = "Binomial"
		o.SetCount(246)
	but a[1] = "Inhomogeneous"
		o.SetIntensityGrid(aGrid, aLam)
	but a[1] = "MaternCluster"
		o.SetParentIntensityQ(0.0012).SetMeanChildrenQ(20).SetRadiusKm(9)
	but a[1] = "Thomas"
		o.SetParentIntensityQ(0.0012).SetMeanChildrenQ(20).SetSigmaKm(4)
	but a[1] = "MaternII"
		o.SetIntensityQ(0.06).SetHardCoreKm(4)
	but a[1] = "SSI"
		o.SetCountQ(260).SetHardCoreKm(4)
	ok
	aPts = o.GenerateIn(oOne, 20260914)

	oC.AddRectQ(nX, nY0, nW, nH).FillQ("#FCFCFC").Stroke("#DDDDDD", 1)
	for k = 1 to len(aPts) / 2
		x = nX + aPts[k * 2 - 1] * nW
		y = nY0 + nH - aPts[k * 2] * nH
		oC.AddCircleQ(x, y, 1.7).FillQ(a[3]).Stroke("#00000000", 0)
	next
	oC.Flush()
	oC.SetFontQ(oFont, 13).AddTextQ(a[1], nX, nY0 - 22).Fill("#1A1A1A")
	oC.Flush()
	oC.SetFontQ(oFont, 10).AddTextQ("" + (len(aPts) / 2) + " points", nX, nY0 - 8).Fill("#999999")
	oC.Flush()
	oC.SetFontQ(oFont, 10).AddTextQ(a[2], nX, nY0 + nH + 16).Fill("#888888")
	oC.Flush()
next

# ---- the two verdicts ----------------------------------------------------
nY1 = nY0 + nH + 70
oC.SetFontQ(oFont, 19).AddTextQ("One pattern, judged twice", 40, nY1).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("Complete spatial randomness calls almost everything " +
	"clustered. A null that already explains something is the one that can be wrong.",
	40, nY1 + 22).Fill("#777777")
oC.Flush()

oM = StzGeoProcess(:MaternCluster)
oM.SetParentIntensityQ(0.002).SetMeanChildrenQ(25).SetRadiusKm(8)
aObsPts = oM.GenerateIn(oOne, 4242)
oObs = StzGeoPoints(aObsPts, oW)
aRad = [ 1, 2, 4, 8, 16, 32 ]
oCsr = StzGeoCSR(oObs.DensityPerKm2())

nY2 = nY1 + 56
nBW = 500
nBH = 230
aBands = [ [ oCsr, "against CSR", "#C0392B" ], [ oM, "against a Matern cluster null", "#2E8B57" ] ]

aObsL = oObs.L(aRad)
for b = 1 to 2
	oNull = aBands[b][1]
	nX = 40 + (b - 1) * (nBW + 80)
	aE = oNull.EnvelopeOfXT(oObs, aRad, 39, 99, :L)

	# the scale: L is CENTRED, so zero is randomness and the eye reads
	# the departure rather than subtracting a diagonal
	nLo = 0
	nHi = 0
	for i = 1 to len(aE)
		if aE[i][:lo] < nLo  nLo = aE[i][:lo]  ok
		if aE[i][:hi] > nHi  nHi = aE[i][:hi]  ok
		if aObsL[i] < nLo  nLo = aObsL[i]  ok
		if aObsL[i] > nHi  nHi = aObsL[i]  ok
	next
	nSpan = nHi - nLo
	if nSpan <= 0  nSpan = 1  ok

	oC.AddRectQ(nX, nY2, nBW, nBH).FillQ("#FCFCFC").Stroke("#DDDDDD", 1)

	# the band
	aTop = []
	aBot = []
	for i = 1 to len(aRad)
		x = nX + (i - 1) * nBW / (len(aRad) - 1)
		aTop + x  aTop + (nY2 + nBH - (aE[i][:hi] - nLo) / nSpan * nBH)
		aBot + x  aBot + (nY2 + nBH - (aE[i][:lo] - nLo) / nSpan * nBH)
	next
	aPoly = []
	for i = 1 to len(aTop)  aPoly + aTop[i]  next
	for i = len(aBot) / 2 to 1 step -1
		aPoly + aBot[i * 2 - 1]
		aPoly + aBot[i * 2]
	next
	oC.AddPolygonQ(aPoly).FillQ("#E8EEF5").Stroke("#00000000", 0)
	oC.Flush()

	# zero -- randomness
	yZero = nY2 + nBH - (0 - nLo) / nSpan * nBH
	oC.AddLineQ(nX, yZero, nX + nBW, yZero).Stroke("#AAAAAA", 1)

	# the observed
	aObsLine = []
	for i = 1 to len(aRad)
		x = nX + (i - 1) * nBW / (len(aRad) - 1)
		aObsLine + x
		aObsLine + (nY2 + nBH - (aObsL[i] - nLo) / nSpan * nBH)
	next
	oC.AddPolylineQ(aObsLine).Stroke(aBands[b][3], 2.6)
	oC.Flush()

	oC.SetFontQ(oFont, 14).AddTextQ(aBands[b][2], nX, nY2 - 12).Fill("#1A1A1A")
	oC.Flush()
	for i = 1 to len(aRad)
		x = nX + (i - 1) * nBW / (len(aRad) - 1)
		oC.SetFontQ(oFont, 10).AddTextQ("" + aRad[i], x - 4, nY2 + nBH + 16).Fill("#999999")
	next
	oC.Flush()
	aV = oNull.VerdictOn(oObs, aRad, 39, 99, :L)
	oC.SetFontQ(oFont, 12).AddTextQ(aV[:verdict], nX, nY2 + nBH + 40).Fill(aBands[b][3])
	oC.Flush()
next
oC.SetFontQ(oFont, 11).AddTextQ("radius, km -- the band is 39 simulations; " +
	"the grey line is randomness, where centred L is zero",
	40, nY2 + nBH + 66).Fill("#999999")
oC.Flush()

oC.ToPNG("geo_processes.png")

? "-- the seven, in one window of " + nArea + " km2 --"
for p = 1 to len(aPanels)
	a = aPanels[p]
	o = StzGeoProcess(a[1])
	if a[1] = "Poisson"
		o.SetIntensity(0.02)
	but a[1] = "Binomial"
		o.SetCount(246)
	but a[1] = "Inhomogeneous"
		o.SetIntensityGrid(aGrid, aLam)
	but a[1] = "MaternCluster"
		o.SetParentIntensityQ(0.0012).SetMeanChildrenQ(20).SetRadiusKm(9)
	but a[1] = "Thomas"
		o.SetParentIntensityQ(0.0012).SetMeanChildrenQ(20).SetSigmaKm(4)
	but a[1] = "MaternII"
		o.SetIntensityQ(0.06).SetHardCoreKm(4)
	but a[1] = "SSI"
		o.SetCountQ(260).SetHardCoreKm(4)
	ok
	? "  " + a[1] + ": " + (len(o.GenerateIn(oOne, 20260914)) / 2) + " points -- " + a[2]
next
? ""
? "-- one pattern of " + oObs.Count() + " points, judged twice --"
? "  against CSR:                  " + oCsr.VerdictOn(oObs, aRad, 39, 99, :L)[:verdict]
? "  against a Matern cluster null: " + oM.VerdictOn(oObs, aRad, 39, 99, :L)[:verdict]
? "-> geo_processes.png"
