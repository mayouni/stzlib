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

# ---- 5. GE0c: A RING THE MAP CUT STILL CLOSES ---------------------------
# Until GE0c a region across the antimeridian, or half behind a globe, came
# back as loose pieces and could only be stroked. The pieces are rejoined
# along the map's own edge now -- the horizon of a globe or the outline of a
# flat map, which is why one walk serves both -- so every region fills.

aSeam  = _Box(150, -30, -150, 20)    # 60 degrees wide, straddling the antimeridian
aCap   = _Cap(-60, 48)               # everything south of 60S
aPlain = _Box(-20, 5, 35, 50)        # an ordinary ring, cut by nothing

oC = new stzCanvas(1180, 800)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 22).AddTextQ("GE0c: a ring the map cuts is rejoined along the map's own edge -- and fills", 24, 40).Fill("#111111")

oP = new stzGeoProjection(:NaturalEarth)
oP.FitSphereIn(20, 62, 1160, 420, 8)
oP.DrawSphereOn(oC, "#F4F7FC", "#3B5B8C", 1.5)
oP.DrawGraticuleOn(oC, 30, "#D5DEEA", 1)
oP.DrawRingOn(oC, aCap,   "#8FB4E3", "#2E4A73", 1.5)
oP.DrawRingOn(oC, aSeam,  "#D9822B", "#8A4B12", 1.5)
oP.DrawRingOn(oC, aPlain, "#7FBF7F", "#2E6B2E", 1.5)
oC.SetFontQ(oFont, 15).AddTextQ("Natural Earth: orange straddles the antimeridian and comes back as TWO polygons, " +
	"each meeting a seam; blue is everything south of 60S and runs along the bottom", 24, 446).Fill("#555555")

oG = new stzGeoProjection(:Orthographic)
oG.CenterOnQ(150, 0).FitSphereIn(40, 480, 360, 790, 6)
oG.DrawSphereOn(oC, "#F4F7FC", "#3B5B8C", 1.5)
oG.DrawGraticuleOn(oC, 30, "#D5DEEA", 1)
oG.DrawRingOn(oC, aSeam, "#D9822B", "#8A4B12", 1.5)
oC.SetFontQ(oFont, 15).AddTextQ("a globe centred on it: one polygon", 44, 790).Fill("#555555")

oS = new stzGeoProjection(:AzimuthalEqualArea)
oS.CenterOnQ(0, -90).FitSphereIn(420, 480, 740, 790, 6)
oS.DrawSphereOn(oC, "#F4F7FC", "#3B5B8C", 1.5)
oS.DrawGraticuleOn(oC, 30, "#D5DEEA", 1)
oS.DrawRingOn(oC, aCap, "#8FB4E3", "#2E4A73", 1.5)
oC.SetFontQ(oFont, 15).AddTextQ("the polar cap from above: a disc", 424, 790).Fill("#555555")

oH = new stzGeoProjection(:Orthographic)
oH.CenterOnQ(0, 90).FitSphereIn(800, 480, 1120, 790, 6)
oH.DrawSphereOn(oC, "#F4F7FC", "#3B5B8C", 1.5)
oH.DrawGraticuleOn(oC, 30, "#D5DEEA", 1)
oH.DrawRingOn(oC, aCap, "#8FB4E3", "#2E4A73", 1.5)
oH.DrawRingOn(oC, _Box(-40, 20, 60, 70), "#7FBF7F", "#2E6B2E", 1.5)
oC.SetFontQ(oFont, 15).AddTextQ("from the north pole: the cap is wholly behind", 804, 790).Fill("#555555")

? "flat: seam ring -> " + len(oP.FilledRing(aSeam)) + " polygons, cap -> " + len(oP.FilledRing(aCap)) +
  ", plain -> " + len(oP.FilledRing(aPlain))
? "globe on the seam: " + len(oG.FilledRing(aSeam)) + "   polar view of the cap: " + len(oS.FilledRing(aCap)) +
  "   north view of the cap: " + len(oH.FilledRing(aCap))
oC.ToPNG("geo_cut.png")
? "-> geo_cut.png"

# ---- 6. GE1: THE SAME COUNTRIES FROM BOTH FORMATS -----------------------
# TopoJSON writes each shared border ONCE, as an arc, and a country as the
# arcs that bound it; GeoJSON writes it twice in full. Read back they must
# be the same numbers, and the two halves of this picture are that claim.
# Arda has a lake -- a HOLE, bridged into its outer ring so it stays a hole
# -- and Berea has an island, which is the part a largest-ring reader drops.

oGjs = StzGeoFeaturesFromJson(read("fixtures/two_countries.geojson"))
oTjs = StzGeoFeaturesFromTopoJson(read("fixtures/two_countries.topojson"), "land")
oCG = new stzCanvas(1180, 560)
oCG.SetBackground("#FFFFFF")
oCG.SetFontQ(oFont, 22).AddTextQ("GE1: the same two countries, read from GeoJSON and from TopoJSON", 24, 40).Fill("#111111")

aInk = [ "#8FB4E3", "#D9A05B" ]
aEdg = [ "#2E4A73", "#8A5A18" ]

oP = new stzGeoProjection(:Equirectangular)
oP.FitToFeatures(oGjs, 560, 420, 40)
oP.Translate([ oP.TranslateOf()[1] + 10, oP.TranslateOf()[2] + 70 ])
for i = 1 to oGjs.Count()
	oP.DrawFeatureOn(oCG, oGjs, i, aInk[i], aEdg[i], 1.5)
next
oCG.SetFontQ(oFont, 16).AddTextQ("from GeoJSON -- 633 bytes", 40, 520).Fill("#555555")

oQ = new stzGeoProjection(:Equirectangular)
oQ.FitToFeatures(oTjs, 560, 420, 40)
oQ.Translate([ oQ.TranslateOf()[1] + 600, oQ.TranslateOf()[2] + 70 ])
for i = 1 to oTjs.Count()
	oQ.DrawFeatureOn(oCG, oTjs, i, aInk[i], aEdg[i], 1.5)
next
oCG.SetFontQ(oFont, 16).AddTextQ("from TopoJSON -- the shared border written ONCE, as arc 0", 620, 520).Fill("#555555")

for i = 1 to oGjs.Count()
	aB = oGjs.BoundsOf(i)
	q = oP.Project((aB[1] + aB[3]) / 2, (aB[2] + aB[4]) / 2)
	oCG.SetFontQ(oFont, 17).AddTextQ(oGjs.NameOf(i) + "  " + oGjs.PropertyOf(i, "pop"), q[1] - 24, q[2]).Fill("#1B2B44")
next
oCG.ToPNG("geo_formats.png")
? "-> geo_formats.png"

# ---- 7. GE2: THE REAL WORLD, IN LAYERS ----------------------------------
# A map made of layers: the sphere, the graticule, every country in the
# colour its value earns, a legend that owns up to a class colouring
# nothing, and a caption saying HOW the map was made and on whose word its
# borders are where they are. The value is each country's own true area,
# measured on the sphere from its rings -- a number that needs no second
# file and that an equal-area projection can be checked against.
#
# THE ATLAS IS NOT COMMITTED. The geo plane vendors no boundary data;
# atlas/README.md says why and carries the two commands that fetch it.
# Without it this section says what it skipped.

if NOT fexists("atlas/countries-110m.json")
	? "SKIPPED, by name: atlas/countries-110m.json is not present --"
	? "  see atlas/README.md. The six sections above need no atlas at all."
else
	oW = StzGeoFeaturesFromTopoJson(read("atlas/countries-110m.json"), "countries")
	oP = new stzGeoProjection(:EqualEarth)
	oP.FitSphereIn(20, 66, 880, 520, 8)
	oM = StzGeoMap(oP, oW)
	aArea = oM.ValuesFromArea()
	oM.SetValuesQ(aArea).SetClassesQ([ 0, 100000, 500000, 2000000, 20000000 ])
	oM.SetSource("Natural Earth 1:110m, public domain, world-atlas 2.0.2, fetched 2026-09-12")

	oC = new stzCanvas(1180, 640)
	oC.SetBackground("#FFFFFF")
	oC.SetFontQ(oFont, 22).AddTextQ("Every country by its own true area, measured on the sphere", 24, 42).Fill("#111111")
	oM.DrawOn(oC)
	oM.DrawLegendOn(oC, oFont, 930, 120, "square kilometres")
	oM.DrawCaptionOn(oC, oFont, 24, 622)
	oC.ToPNG("geo_world.png")

	nTot = 0
	for i = 1 to len(aArea)  nTot += aArea[i]  next
	? "land measured from the rings: " + nTot + " km2   (the real figure is about 148,900,000)"
	nR = oW.IndexOfName("Russia")
	? "Russia " + aArea[nR] + " km2 (about 17,100,000)   France " +
	  aArea[oW.IndexOfName("France")] + " km2 (about 551,000 for the mainland)"
	? "-> geo_world.png"

	# ---- symbols and flows, on a globe ----
	oG = new stzGeoProjection(:Orthographic)
	oG.CenterOnQ(10, 25).FitSphereIn(30, 80, 590, 620, 8)
	oM2 = StzGeoMap(oG, oW)
	oM2.SetValuesQ(aArea).SetClassesQ([ 0, 100000, 500000, 2000000, 20000000 ])
	oM2.SetSource("Natural Earth 1:110m, public domain")

	oC2 = new stzCanvas(1180, 700)
	oC2.SetBackground("#FFFFFF")
	oC2.SetFontQ(oFont, 22).AddTextQ("Symbols by AREA, not radius -- and flows that are great circles", 24, 42).Fill("#111111")
	oM2.DrawSphereOn(oC2, "#F2F6FC", "#8FA8C8", 1)
	oM2.DrawGraticuleOn(oC2, 30, "#DCE4EE", 1)
	oM2.DrawRegionsOn(oC2, "#FFFFFF", 0.6)
	oM2.DrawSymbolsOn(oC2, aArea, 22, "#D9822B99", "#8A4B12")
	oG.DrawOutlineOn(oC2, "#3B5B8C", 1.5)
	oM2.DrawCaptionOn(oC2, oFont, 34, 648)

	oH = new stzGeoProjection(:NaturalEarth)
	oH.FitSphereIn(610, 80, 1160, 620, 8)
	oM3 = StzGeoMap(oH, oW)
	oM3.SetValuesQ(aArea).SetClassesQ([ 0, 100000, 500000, 2000000, 20000000 ])
	oM3.SetSource("Natural Earth 1:110m, public domain")
	oM3.DrawSphereOn(oC2, "#F2F6FC", "#8FA8C8", 1)
	oM3.DrawGraticuleOn(oC2, 30, "#DCE4EE", 1)
	oM3.DrawRegionsOn(oC2, "#FFFFFF", 0.6)
	aRoutes = [
		[ 10.18, 36.80, 139.69, 35.69, 2 ], [ 10.18, 36.80, -74.01, 40.71, 2 ],
		[ 10.18, 36.80, 151.21, -33.87, 2 ], [ 10.18, 36.80, -46.63, -23.55, 2 ],
		[ -74.01, 40.71, 139.69, 35.69, 1.4 ], [ 2.35, 48.85, -118.24, 34.05, 1.4 ],
		[ 103.82, 1.35, 4.90, 52.37, 1.4 ] ]
	oM3.DrawFlowsOn(oC2, aRoutes, "#C0392B", 2)
	oH.DrawOutlineOn(oC2, "#3B5B8C", 1.5)
	oM3.DrawCaptionOn(oC2, oFont, 614, 648)
	oC2.ToPNG("geo_symbols.png")
	? "-> geo_symbols.png"
ok

# ---- 8. GE3 and GE5: what the gate says, and what is under a pixel ------
# The same data on two projections. On Mercator a choropleth argues against
# its own legend -- the high latitudes are swollen and the colour says they
# are large -- and the gate says so BY NAME. On Equal Earth, with its source
# stated, the same map reports nothing. Then five pixels are INVERTED back
# to places and asked of the features: nothing is looked up.

if NOT fexists("atlas/countries-110m.json")
	? "SKIPPED, by name: atlas/countries-110m.json is not present."
else
	oRw = StzGeoFeaturesFromTopoJson(read("atlas/countries-110m.json"), "countries")
	aRA = StzGeoMap(new stzGeoProjection(:EqualEarth), oRw).ValuesFromArea()
	aREdges = [ 0, 100000, 500000, 2000000, 20000000 ]

	oCR = new stzCanvas(1180, 720)
	oCR.SetBackground("#FFFFFF")
	oCR.SetFontQ(oFont, 22).AddTextQ("GE3: the same data, two projections, and what the gate says about each", 24, 40).Fill("#111111")

	oMer = StzGeoMap(new stzGeoProjection(:Mercator), oRw)
	oMer.Projection().FitSphereIn(20, 66, 570, 430, 6)
	oMer.SetValuesQ(aRA).SetClasses(aREdges)
	oMer.DrawOn(oCR)
	aF = oMer.Findings()
	oCR.SetFontQ(oFont, 16).AddTextQ("Mercator -- " + len(aF) + " findings", 24, 458).Fill("#111111")
	nY = 482
	for i = 1 to len(aF)
		cI = "#B03030"
		if aF[i][:severity] != "error"  cI = "#A06000"  ok
		oCR.SetFontQ(oFont, 14).AddTextQ("[" + aF[i][:severity] + "] " + aF[i][:rule], 24, nY).Fill(cI)
		nY += 20
		oCR.SetFontQ(oFont, 13).AddTextQ(_Wrap(aF[i][:message], 78), 36, nY).Fill("#555555")
		nY += 22
	next

	oEqe = StzGeoMap(new stzGeoProjection(:EqualEarth), oRw)
	oEqe.Projection().FitSphereIn(610, 66, 1160, 430, 6)
	oEqe.SetValuesQ(aRA).SetClasses(aREdges)
	oEqe.SetSource("Natural Earth 1:110m, public domain")
	oEqe.DrawOn(oCR)
	oCR.SetFontQ(oFont, 16).AddTextQ("Equal Earth, with its source named -- " + len(oEqe.Findings()) +
		" findings, and the gate calls it sound", 614, 458).Fill("#111111")
	oCR.SetFontQ(oFont, 13).AddTextQ(oEqe.Caption(), 614, 482).Fill("#555555")

	# GE5: what is under a pixel. Every label below was found by INVERTING the
	# pixel and asking the features, not by looking a place up.
	oCR.SetFontQ(oFont, 16).AddTextQ("GE5: what is under a pixel -- inverted, then asked of the features", 614, 530).Fill("#111111")
	aSpots = [ [ 2.35, 48.85 ], [ 139.69, 35.69 ], [ -58.38, -34.6 ], [ 10.18, 36.8 ], [ 0, 0 ] ]
	nY = 558
	for i = 1 to len(aSpots)
		q = oEqe.Projection().Project(aSpots[i][1], aSpots[i][2])
		cN = oEqe.NameAt(q[1], q[2])
		if cN = ""  cN = "(nobody -- the open sea)"  ok
		oCR.AddCircleQ(q[1], q[2], 4).FillQ("#C0392B").Stroke("#FFFFFF", 1)
		oCR.SetFontQ(oFont, 14).AddTextQ("pixel " + q[1] + "," + q[2] + "  ->  " + cN, 614, nY).Fill("#333333")
		nY += 22
	next
	oCR.ToPNG("geo_rules.png")
	? "-> geo_rules.png   Mercator findings " + len(aF) + "   Equal Earth findings " + len(oEqe.Findings())
ok

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

func _Cap pnLat, pnSteps
	_a_ = []
	for _i_ = 0 to pnSteps - 1
		_a_ + (-180 + 360 * _i_ / pnSteps)
		_a_ + pnLat
	next
	return _a_

func _Box pnL0, pnF0, pnL1, pnF1
	_w_ = pnL1 - pnL0
	if _w_ < 0  _w_ += 360  ok
	_a_ = []
	for _i_ = 0 to 24
		_l_ = pnL0 + _w_ * _i_ / 24
		if _l_ > 180  _l_ -= 360  ok
		_a_ + _l_  _a_ + pnF0
	next
	for _i_ = 0 to 24
		_l_ = pnL1 - _w_ * _i_ / 24
		if _l_ < -180  _l_ += 360  ok
		_a_ + _l_  _a_ + pnF1
	next
	return _a_

func _Wrap pcT, pnN
	if len(pcT) <= pnN  return pcT  ok
	return StzStringSection(pcT, 1, pnN - 3) + "..."
