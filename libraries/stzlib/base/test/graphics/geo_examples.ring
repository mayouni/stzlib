load "../../stzBase.ring"
decimals(1)

# GE0 -- THE SPHERE, SHOWN. Four pictures that need no atlas: the sixteen
# projections with Tissot's indicatrix, great-circle routes on a globe and
# on a flat map, range rings on the map made for the question and on the
# one that bends them, and a continent on a fitted conic. Run it; the
# pictures beside this file are what it draws.

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")

# STEP 1 OF THE GEO PLANE: THE SPHERE. No atlas, no boundary -- what every
# map stands on before it has a coastline. Sixteen projections, each with
# the same graticule and the same circles of one true size (Tissot), so a
# reader can see for themselves which lie each one tells.

aKinds = StzGeoProjectionKinds()
? "projections the engine knows: " + len(aKinds)

nCols = 4
nCellW = 300
nCellH = 250
nTop = 70
nW = nCols * nCellW + 40
nRows = ceil(len(aKinds) / nCols)
nH = nTop + nRows * nCellH + 30

oCS = new stzCanvas(nW, nH)
oCS.SetBackground("#FFFFFF")
oCS.SetFontQ(oFont, 24).AddTextQ("Sixteen ways to flatten a sphere -- the same graticule, the same circles of one true size", 24, 44).Fill("#111111")

nMs = StzEngineWatchTimestampMs()
for i = 1 to len(aKinds)
	nCol = (i - 1) % nCols
	nRow = floor((i - 1) / nCols)
	nX0 = 20 + nCol * nCellW
	nY0 = nTop + nRow * nCellH
	oP = new stzGeoProjection(aKinds[i])
	# the globes read best turned a little; the flat maps as they are
	if oP.IsAzimuthal()  oP.Rotate([ -20, -30, 0 ])  ok
	oP.FitSphereIn(nX0 + 10, nY0 + 10, nX0 + nCellW - 10, nY0 + nCellH - 36, 4)
	oP.DrawSphereOn(oCS, "#EAF1FB", "#3B5B8C", 1)
	oP.DrawGraticuleOn(oCS, 15, "#B9C6D8", 1)
	oP.DrawTissotOn(oCS, 5, 30, "#D9822B66", "#B3601A")
	oP.DrawOutlineOn(oCS, "#3B5B8C", 1.5)
	cCap = oP.Name()
	if oP.IsEqualArea()  cCap += "  equal-area"  ok
	if oP.IsConformal()  cCap += "  conformal"  ok
	oCS.SetFontQ(oFont, 17).AddTextQ(cCap, nX0 + 12, nY0 + nCellH - 12).Fill("#222222")
next
nMs = StzEngineWatchTimestampMs() - nMs
? "sixteen maps laid out in " + nMs + " ms"
oCS.ToPNG("geo_sheet.png")
? "-> geo_sheet.png"

aCities = [
	[ "Tunis",      10.18,   36.80 ],
	[ "Paris",       2.35,   48.85 ],
	[ "New York",  -74.01,   40.71 ],
	[ "Tokyo",     139.69,   35.69 ],
	[ "Sao Paulo", -46.63,  -23.55 ],
	[ "Sydney",    151.21,  -33.87 ],
	[ "Cairo",      31.24,   30.04 ],
	[ "Cape Town",  18.42,  -33.92 ],
	[ "Los Angeles", -118.24, 34.05 ],
	[ "Reykjavik", -21.94,   64.15 ]
]
aRoutes = [ [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 1, 6 ], [ 1, 8 ], [ 3, 4 ], [ 9, 4 ], [ 2, 3 ], [ 1, 10 ] ]

# ---- 1. THE SAME ROUTES ON A GLOBE AND ON A FLAT MAP ---------------------
# A great circle is a straight line on the sphere and a curve on the
# paper; a route cut by the seam of the flat map comes back in two pieces,
# each ending exactly at the edge, and a route behind the globe is not
# drawn. Both come from one engine call, which is the point.

oC = new stzCanvas(1180, 560)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 22).AddTextQ("The same nine routes -- great circles -- on a globe and on a flat map", 24, 40).Fill("#111111")

oG = new stzGeoProjection(:Orthographic)
oG.CenterOnQ(-20, 30).FitSphereIn(20, 60, 520, 540, 10)
oG.DrawSphereOn(oC, "#EAF1FB", "#3B5B8C", 1.5)
oG.DrawGraticuleOn(oC, 15, "#C5D0E0", 1)
Routes(oC, oG, aCities, aRoutes, "#C0392B")
for i = 1 to len(aCities)  CityDot(oC, oG, aCities[i], oFont, "#1B2B44")  next
oC.SetFontQ(oFont, 15).AddTextQ(oG.Caption(), 24, 556).Fill("#555555")

oN = new stzGeoProjection(:NaturalEarth)
oN.FitSphereIn(540, 60, 1170, 540, 10)
oN.DrawSphereOn(oC, "#EAF1FB", "#3B5B8C", 1.5)
oN.DrawGraticuleOn(oC, 15, "#C5D0E0", 1)
Routes(oC, oN, aCities, aRoutes, "#C0392B")
for i = 1 to len(aCities)  CityDot(oC, oN, aCities[i], oFont, "#1B2B44")  next
oC.SetFontQ(oFont, 15).AddTextQ(oN.Caption(), 544, 556).Fill("#555555")
oC.ToPNG("geo_routes.png")
? "-> geo_routes.png"

# ---- 2. HOW FAR IS EVERYTHING FROM TUNIS? -------------------------------
# On an azimuthal equidistant map centred on a place, every circle of
# equal distance from it IS a circle, and every straight line from it is
# the true route. On Mercator the same rings are pulled out of shape as
# they go north. Same rings, same engine, two answers -- one honest.

oC2 = new stzCanvas(1180, 620)
oC2.SetBackground("#FFFFFF")
oC2.SetFontQ(oFont, 22).AddTextQ("Rings of 2,000 km around Tunis: true on the map made for the question, bent on the other", 24, 40).Fill("#111111")

oA = new stzGeoProjection(:AzimuthalEquidistant)
oA.CenterOnQ(10.18, 36.80).FitSphereIn(20, 60, 580, 600, 10)
oA.DrawSphereOn(oC2, "#EAF1FB", "#3B5B8C", 1.5)
oA.DrawGraticuleOn(oC2, 30, "#C5D0E0", 1)
for nKm = 2000 to 16000 step 2000
	oA.DrawRingOn(oC2, StzGeoCircleKm(10.18, 36.80, nKm, 180), "#00000000", "#D9822B", 1.5)
next
for i = 1 to len(aCities)  CityDot(oC2, oA, aCities[i], oFont, "#1B2B44")  next
oC2.SetFontQ(oFont, 15).AddTextQ(oA.Caption(), 24, 616).Fill("#555555")

oM = new stzGeoProjection(:Mercator)
oM.FitSphereIn(600, 60, 1160, 600, 10)
oM.DrawSphereOn(oC2, "#EAF1FB", "#3B5B8C", 1.5)
oM.DrawGraticuleOn(oC2, 30, "#C5D0E0", 1)
for nKm = 2000 to 8000 step 2000
	oM.DrawRingOn(oC2, StzGeoCircleKm(10.18, 36.80, nKm, 180), "#00000000", "#D9822B", 1.5)
next
for i = 1 to len(aCities)  CityDot(oC2, oM, aCities[i], oFont, "#1B2B44")  next
oC2.SetFontQ(oFont, 15).AddTextQ(oM.Caption(), 604, 616).Fill("#555555")
oC2.ToPNG("geo_rings.png")
? "-> geo_rings.png"
? "   Tunis to Tokyo " + StzGeoDistanceKm(10.18, 36.80, 139.69, 35.69) + " km, to Sydney " +
  StzGeoDistanceKm(10.18, 36.80, 151.21, -33.87) + " km"

# ---- 3. A REGION, FITTED: the conic a country's atlas actually uses ------
# A conformal conic with its two standard parallels through the region
# keeps shapes honest over a continent; FitToPoints scales and places it
# so the places given fill the paper. No atlas, still: the graticule and
# the cities are the whole picture, which is exactly what a caller with
# their own boundary file would add to.

aEurope = [
	[ "Lisbon",     -9.14, 38.72 ], [ "Madrid",  -3.70, 40.42 ], [ "Paris",     2.35, 48.85 ],
	[ "London",     -0.13, 51.51 ], [ "Dublin",  -6.26, 53.35 ], [ "Oslo",     10.75, 59.91 ],
	[ "Stockholm",  18.07, 59.33 ], [ "Helsinki", 24.94, 60.17 ], [ "Berlin",   13.40, 52.52 ],
	[ "Warsaw",     21.01, 52.23 ], [ "Kyiv",    30.52, 50.45 ], [ "Vienna",   16.37, 48.21 ],
	[ "Rome",       12.50, 41.90 ], [ "Athens",  23.73, 37.98 ], [ "Istanbul", 28.98, 41.01 ],
	[ "Tunis",      10.18, 36.80 ], [ "Algiers",  3.06, 36.75 ], [ "Reykjavik", -21.94, 64.15 ]
]
aPts = []
for i = 1 to len(aEurope)  aPts + aEurope[i][2]  aPts + aEurope[i][3]  next

oC3 = new stzCanvas(1180, 760)
oC3.SetBackground("#FFFFFF")
oC3.SetFontQ(oFont, 22).AddTextQ("Europe on a conformal conic, standard parallels 40N and 60N, fitted to eighteen capitals", 24, 40).Fill("#111111")
oE = new stzGeoProjection(:ConicConformal)
oE.ParallelsQ([ 40, 60 ]).RotateQ([ -10, 0, 0 ])
oE.FitToPoints(aPts, 1180, 720, 70)
oE.Translate([ oE.TranslateOf()[1], oE.TranslateOf()[2] + 40 ])
oE.DrawGraticuleOn(oC3, 5, "#C5D0E0", 1)
oC3.AddRectQ(0, 0, 1180, 58).Fill("#FFFFFF")
oC3.SetFontQ(oFont, 22).AddTextQ("Europe on a conformal conic, standard parallels 40N and 60N, fitted to eighteen capitals", 24, 40).Fill("#111111")
for i = 1 to len(aEurope)  CityDot(oC3, oE, aEurope[i], oFont, "#1B2B44")  next
oC3.SetFontQ(oFont, 15).AddTextQ(oE.Caption(), 24, 750).Fill("#555555")
oC3.ToPNG("geo_europe.png")
? "-> geo_europe.png"
? "   under the pixel at the centre of the sheet: " + oE.Invert(590, 400)[1] + "E " + oE.Invert(590, 400)[2] + "N"

# Ring runs top-level code only up to the first func, so the helpers
# stand at the end of the file
func CityDot(oC, oP, aCity, oFont, cInk)
	_q_ = oP.Project(aCity[2], aCity[3])
	if len(_q_) < 2  return  ok
	oC.AddCircleQ(_q_[1], _q_[2], 4).FillQ(cInk).Stroke("#FFFFFF", 1)
	oC.SetFontQ(oFont, 15).AddTextQ(aCity[1], _q_[1] + 7, _q_[2] + 5).Fill(cInk)

func Routes(oC, oP, aCities, aRoutes, cInk)
	for _i_ = 1 to len(aRoutes)
		_a_ = aCities[aRoutes[_i_][1]]
		_b_ = aCities[aRoutes[_i_][2]]
		_pcs_ = oP.Arc(_a_[2], _a_[3], _b_[2], _b_[3])
		for _k_ = 1 to len(_pcs_)
			if len(_pcs_[_k_]) >= 4
				oC.AddPolylineQ(_pcs_[_k_]).Stroke(cInk, 2)
			ok
		next
	next

