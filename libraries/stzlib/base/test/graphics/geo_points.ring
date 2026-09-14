load "../../stzBase.ring"
decimals(2)

# GE7a -- ARE THEY CLUSTERED? Three patterns of four hundred places in
# Tunisia, made so that the answer is KNOWN: one uniform, one a Matern
# cluster process, one hard-core. For each, the sheet shows the three things
# an analyst reports first:
#
#   - THE POINTS, with their mean centre and the standard deviational
#     ellipse -- where the middle is and which way the spread runs;
#   - CLARK-EVANS in one number: the mean nearest-neighbour distance over the
#     one a random pattern of the same density expects, and its verdict;
#   - RIPLEY'S L(r) AGAINST THE NULL. The grey band is thirty-nine simulated
#     random patterns of the same count in the same window. L above the
#     band is clustering at that scale, L below it is dispersion, L inside
#     it is what chance does. No edge-correction formula is applied to K and
#     none is needed: the simulated nulls have the same edge the data has.
#
# The point of the sheet is not the three verdicts. It is that the three
# verdicts are RIGHT, on patterns whose truth this file made.

if NOT fexists("atlas/admin1_tunisia.geojson")
	? "SKIPPED, by name: atlas/admin1_tunisia.geojson is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oU = StzGeoFeaturesFromJson(read("atlas/admin1_tunisia.geojson"))
oWin = StzGeoPoints([], oU)
nSeed = 20260914
aRad = [ 10, 20, 30, 40, 50, 60, 80, 100, 120 ]

aPat = [ [ "Uniform",   oWin.Sample(400, nSeed),                   "thrown like rice" ],
         [ "Clustered", oWin.SampleClustered(8, 50, 25, nSeed),    "eight parents, fifty children within 25 km" ],
         [ "Dispersed", oWin.SampleDispersed(400, 15, nSeed),      "no two closer than 15 km" ] ]

oC = new stzCanvas(1200, 910)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 23).AddTextQ("Are they clustered? Three patterns, and the null by simulation", 30, 44).Fill("#111111")

for m = 1 to 3
	nX0 = 20 + (m - 1) * 395
	oP = StzGeoConicFor(oU, :ConicEqualArea)
	oP.FitFeaturesIn(oU, nX0 + 30, 120, nX0 + 350, 520, 6)
	oM = StzGeoMap(oP, oU)
	oM.SetPaper(nX0, 110, nX0 + 380, 530)
	oM.DrawRegionsOn(oC, "#FFFFFF", 0.7)

	aP = aPat[m][2]
	oX = oWin.With(aP)
	nN = oX.Count()
	for i = 1 to nN
		q = oP.Project(aP[i * 2 - 1], aP[i * 2])
		if len(q) = 2  oC.AddCircleQ(q[1], q[2], 1.7).FillQ("#1B4F72BB").Stroke("#00000000", 0)  ok
	next
	aRing = oX.EllipseRing(72)
	aPieces = oP.Ring(aRing)
	for k = 1 to len(aPieces)
		oC.AddPolylineQ(aPieces[k]).Stroke("#C0392B", 1.8)
	next
	aCen = oX.MeanCentre()
	q = oP.Project(aCen[1], aCen[2])
	if len(q) = 2  oC.AddCircleQ(q[1], q[2], 4.5).FillQ("#C0392B").Stroke("#FFFFFF", 1.2)  ok

	ce = oX.ClarkEvans()
	oC.SetFontQ(oFont, 17).AddTextQ(aPat[m][1] + " -- " + nN + " places", nX0 + 10, 84).Fill("#111111")
	oC.SetFontQ(oFont, 13).AddTextQ(aPat[m][3], nX0 + 10, 102).Fill("#777777")
	oC.SetFontQ(oFont, 14).AddTextQ("Clark-Evans R " + StzFactNumText(ce[:r]) + "   z " +
		StzFactNumText(ce[:z]) + "   ->  " + ce[:verdict], nX0 + 10, 552).Fill("#111111")

	aL = oX.L(aRad)
	aE = oX.EnvelopeL(aRad, 39, nSeed)
	_DrawLChart(oC, oFont, nX0 + 40, 580, 330, 230, aRad, aL, aE)
	oC.Flush()
	? aPat[m][1] + ": " + nN + " places, R " + StzFactNumText(ce[:r]) + ", z " +
		StzFactNumText(ce[:z]) + " -> " + ce[:verdict] + "; L(30) " + StzFactNumText(aL[3]) +
		" against a band of [" + StzFactNumText(aE[3][1]) + ", " + StzFactNumText(aE[3][2]) + "]"
next

oC.SetFontQ(oFont, 13).AddTextQ("Red: the mean centre and the standard deviational ellipse. " +
	"Grey band: L(r) of 39 simulated random patterns of the same count in the same window -- " +
	"above it is clustering, below it dispersion.", 30, 848).Fill("#777777")
oC.SetFontQ(oFont, 13).AddTextQ("The band itself falls at large r: the window's edge takes neighbours " +
	"from every point near it. That is the edge effect, seen -- and why the null is simulated under " +
	"the same edge rather than assumed flat.", 30, 868).Fill("#777777")
oC.SetFontQ(oFont, 13).AddTextQ("Natural Earth 1:10m; the places are INVENTED, seeded, and made " +
	"so that the answer is known.", 30, 888).Fill("#777777")
oC.Flush()
oC.ToPNG("geo_points.png")
? "-> geo_points.png"

# L(r) against its envelope, as a small chart: the band first, then the zero
# line, then the curve, so the curve is never under the band
func _DrawLChart poC, poFont, pnX, pnY, pnW, pnH, paRad, paL, paE
	_lo_ = 0  _hi_ = 0
	for _i_ = 1 to len(paRad)
		if paL[_i_] < _lo_  _lo_ = paL[_i_]  ok
		if paL[_i_] > _hi_  _hi_ = paL[_i_]  ok
		if paE[_i_][1] < _lo_  _lo_ = paE[_i_][1]  ok
		if paE[_i_][2] > _hi_  _hi_ = paE[_i_][2]  ok
	next
	_pad_ = (_hi_ - _lo_) * 0.12
	if _pad_ < 1  _pad_ = 1  ok
	_lo_ -= _pad_
	_hi_ += _pad_
	_rmax_ = paRad[len(paRad)]
	_band_ = []
	for _i_ = 1 to len(paRad)
		_band_ + _LX(pnX, pnW, paRad[_i_], _rmax_)
		_band_ + _LY(pnY, pnH, paE[_i_][2], _lo_, _hi_)
	next
	for _i_ = len(paRad) to 1 step -1
		_band_ + _LX(pnX, pnW, paRad[_i_], _rmax_)
		_band_ + _LY(pnY, pnH, paE[_i_][1], _lo_, _hi_)
	next
	poC.AddPolygonQ(_band_).FillQ("#DDE3E8").Stroke("#00000000", 0)
	# the zero line: what a random pattern does
	poC.AddLineQ(pnX, _LY(pnY, pnH, 0, _lo_, _hi_), pnX + pnW, _LY(pnY, pnH, 0, _lo_, _hi_)).Stroke("#9AA7B4", 1)
	_line_ = []
	for _i_ = 1 to len(paRad)
		_line_ + _LX(pnX, pnW, paRad[_i_], _rmax_)
		_line_ + _LY(pnY, pnH, paL[_i_], _lo_, _hi_)
	next
	poC.AddPolylineQ(_line_).Stroke("#1B4F72", 2.2)
	# the frame and its words
	poC.AddLineQ(pnX, pnY, pnX, pnY + pnH).Stroke("#444444", 1)
	poC.AddLineQ(pnX, pnY + pnH, pnX + pnW, pnY + pnH).Stroke("#444444", 1)
	poC.SetFontQ(poFont, 12).AddTextQ("r, km", pnX + pnW - 14, pnY + pnH + 14).Fill("#555555")
	poC.SetFontQ(poFont, 12).AddTextQ("L(r) = sqrt(K/pi) - r", pnX + 4, pnY - 6).Fill("#555555")
	for _i_ = 1 to len(paRad)
		if paRad[_i_] % 40 = 0 and _i_ < len(paRad)
			_x_ = _LX(pnX, pnW, paRad[_i_], _rmax_)
			poC.SetFontQ(poFont, 11).AddTextQ("" + paRad[_i_], _x_ - 6, pnY + pnH + 14).Fill("#777777")
		ok
	next
	poC.SetFontQ(poFont, 11).AddTextQ("0", pnX - 10, _LY(pnY, pnH, 0, _lo_, _hi_) + 4).Fill("#777777")

func _LX pnX, pnW, pnR, pnRmax
	return pnX + pnW * pnR / pnRmax

func _LY pnY, pnH, pnV, pnLo, pnHi
	return pnY + pnH - pnH * (pnV - pnLo) / (pnHi - pnLo)
