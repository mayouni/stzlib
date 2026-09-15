load "../../stzBase.ring"
decimals(2)

# GE8 -- THE SHORTEST PATH AND THE ONE YOU CAN STEER.
#
# Two lines between the same two places, drawn on the projection that was
# invented to make the second of them straight.
#
# THE GEODESIC is the shortest path on the ellipsoid. On a Mercator chart it
# BENDS, and the bend is not a drawing error: Mercator's whole design is to
# make a line of constant bearing straight, and the price of that is that
# the shortest path is not.
#
# THE RHUMB LINE is the path of constant bearing. It is longer -- 219 km
# longer from New York to London -- and before satellite navigation it was
# the route, because it is the one a compass can hold. You set the bearing
# once and you keep it.
#
# The difference between the two lines is what a great-circle course buys,
# and the reason it is not free is written along the geodesic: the bearing
# changes the whole way, by fifty-six degrees on this pair.

if NOT fexists("atlas/countries-110m.json")
	? "SKIPPED, by name: atlas/countries-110m.json is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oW = StzGeoFeaturesFromTopoJson(read("atlas/countries-110m.json"), "countries")
oE = StzGeoWGS84()

# the pairs: a name, and the two ends
aRoutes = [
	[ "New York to London",   40.6413, -73.7781,  51.4700,  -0.4543, "#C0392B" ],
	[ "London to Tokyo",      51.4700,  -0.4543,  35.5494, 139.7798, "#1F6FB4" ],
	[ "Lima to Sydney",      -12.0219, -77.1143, -33.9399, 151.1753, "#2E8B57" ]
]

oC = new stzCanvas(1320, 1040)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 26).AddTextQ("The shortest path, and the one you can steer", 40, 50).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("every distance on WGS84 -- the ellipsoid a GPS measures on, " +
	"not the sphere this plane used until now", 40, 74).Fill("#777777")
oC.Flush()

# ---- the Mercator panel, where the rhumb is straight --------------------
nY0 = 160
oP = new stzGeoProjection(:Mercator)
oP.FitFeaturesIn(oW.Within(-180, -60, 180, 78), 40, nY0, 1280, nY0 + 470, 2)
oM = StzGeoMap(oP, oW.Within(-180, -60, 180, 78))
oM.SetSource("Natural Earth 110m; distances on WGS84")
oM.SetPaper(30, nY0 - 10, 1290, nY0 + 480)
oM.SetNoData("#EFEFEF")
oM.DrawSheetOn(oC, "#BFBFBF", 0.4)

oC.SetFontQ(oFont, 17).AddTextQ("On Mercator the rhumb line is straight -- that is what the projection is FOR",
	40, nY0 - 30).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("...so the geodesic, which is shorter, has to bend",
	40, nY0 - 12).Fill("#888888")
oC.Flush()

for r = 1 to len(aRoutes)
	a = aRoutes[r]
	aGeo = oE.GeodesicFlat(a[2], a[3], a[4], a[5], 120)
	aRh  = oE.RhumbFlat(a[2], a[3], a[4], a[5], 120)
	oP.DrawLineOn(oC, aRh, a[6], 1.2)
	oP.DrawLineOn(oC, aGeo, a[6], 2.6)
	# A PATH THAT CROSSES THE ANTIMERIDIAN IS CUT BY THE CHART, not by a
	# fault in the drawing: Mercator has to end somewhere, and Lima to
	# Sydney goes through where it ends. The pieces leave one edge and
	# arrive at the other, which is what a paper chart does too.
	for k = 1 to 2
		q = oP.Project(a[3 + (k - 1) * 2], a[2 + (k - 1) * 2])
		if len(q) = 2
			oC.AddCircleQ(q[1], q[2], 4).FillQ("#FFFFFF").Stroke(a[6], 2)
		ok
	next
next
oC.Flush()

# ---- the numbers ---------------------------------------------------------
nY1 = nY0 + 520
oC.SetFontQ(oFont, 17).AddTextQ("What the two paths cost, and what the sphere was getting wrong",
	40, nY1).Fill("#1A1A1A")
oC.Flush()

aHead = [ "route", "geodesic", "rhumb", "longer by", "leave on", "arrive on", "sphere said", "out by" ]
aX = [ 40, 250, 380, 500, 620, 740, 880, 1030 ]
for h = 1 to len(aHead)
	oC.SetFontQ(oFont, 12).AddTextQ(aHead[h], aX[h], nY1 + 30).Fill("#999999")
next
oC.Flush()
oC.AddLineQ(40, nY1 + 38, 1150, nY1 + 38).Stroke("#DDDDDD", 1)

nRow = nY1 + 62
for r = 1 to len(aRoutes)
	a = aRoutes[r]
	g = oE.Between(a[2], a[3], a[4], a[5])
	rh = oE.RhumbBetween(a[2], a[3], a[4], a[5])
	sph = StzGeoDistanceOnSphereKm(a[3], a[2], a[5], a[4])
	aCell = [ a[1],
	          "" + StzFactNumText(g[:km]) + " km",
	          "" + StzFactNumText(rh[:km]) + " km",
	          "" + StzFactNumText(rh[:km] - g[:km]) + " km",
	          "" + StzFactNumText(g[:azimuth]) + " deg",
	          "" + StzFactNumText(g[:finalAzimuth]) + " deg",
	          "" + StzFactNumText(sph) + " km",
	          "" + StzFactNumText(g[:km] - sph) + " km" ]
	for h = 1 to len(aCell)
		cInk = "#333333"
		if h = 1  cInk = a[6]  ok
		if h = 8  cInk = "#C0392B"  ok
		oC.SetFontQ(oFont, 13).AddTextQ(aCell[h], aX[h], nRow).Fill(cInk)
	next
	oC.Flush()
	nRow += 30
next

oC.SetFontQ(oFont, 13).AddTextQ("The last column is why GE8 exists: the sphere of 6371.0088 km " +
	"is short by up to fifteen kilometres on a route anybody can look up.", 40, nRow + 20).Fill("#555555")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("The bearing on a geodesic CHANGES the whole way -- " +
	"leave on 51 degrees, arrive on 108 -- which is why it has to be re-steered and " +
	"why the rhumb was sailed instead.", 40, nRow + 42).Fill("#555555")
oC.Flush()

oC.ToPNGHiRes("geo_geodesy.png")

? "-- the routes, on WGS84 --"
for r = 1 to len(aRoutes)
	a = aRoutes[r]
	g = oE.Between(a[2], a[3], a[4], a[5])
	rh = oE.RhumbBetween(a[2], a[3], a[4], a[5])
	sph = StzGeoDistanceOnSphereKm(a[3], a[2], a[5], a[4])
	? "  " + a[1] + ": geodesic " + g[:km] + " km, rhumb " + rh[:km] +
	  " km, sphere said " + sph + " km"
	? "     leave on " + g[:azimuth] + " deg and arrive on " + g[:finalAzimuth] +
	  " deg; the rhumb holds " + rh[:azimuth] + " deg all the way"
next
? ""
? "-- and the ellipsoid itself --"
? "  " + oE.Name() + ": a = " + oE.EquatorialRadius() + " m, 1/f = " + oE.InverseFlattening()
? "  the pole is " + oE.QuarterMeridianKm() + " km from the equator"
? "  a degree of latitude runs " + oE.DegreeOfLatitudeKm(0) + " km at the equator and " +
  oE.DegreeOfLatitudeKm(89.5) + " km at the pole"
? "-> geo_geodesy.png"
