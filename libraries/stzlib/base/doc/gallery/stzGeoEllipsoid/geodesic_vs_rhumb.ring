# stzGeoEllipsoid: the shortest path (GeodesicBetween) and the constant-bearing path (RhumbLineBetween)
# between New York and London, and Niamey to Tokyo, drawn on a Mercator where the rhumb line is straight.
# Distances come from DistanceKm and RhumbDistanceKm; the arguments of both are (lat, lon), the lines are
# lists of (lon, lat). Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoEllipsoid/geodesic_vs_rhumb.ring
load "../../stzBase.ring"
decimals(1)
cAtlas = sysget("STZ_ATLAS")
if cAtlas = ""  cAtlas = "../graphics/atlas/"  ok
if NOT fexists(cAtlas + "land-110m.json")
	? "SKIPPED, by name: " + cAtlas + "land-110m.json is not present -- see test/graphics/atlas/README.md."
	return
ok
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oLand = StzGeoFeaturesFromTopoJson(read(cAtlas + "land-110m.json"), "land")
oE = new stzGeoEllipsoid("WGS84")

oC = new stzCanvas(1000, 560)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Geodesic (blue) and rhumb line (red), on WGS84", 20, 32).Fill("#111111")
oC.Flush()
oP = new stzGeoProjection(:Mercator)
aBox = [ -175, -35, 175, 72 ]
oP.FitPointsIn([ aBox[1], aBox[2], aBox[3], aBox[4] ], 20, 50, 980, 500, 0)
oP.DrawSphereOn(oC, "#EAF1FB", "#8FA8C8", 1)
oP.DrawGraticuleOn(oC, 30, "#C9D6E8", 0.7)
oP.DrawFeaturesOn(oC, oLand, "#E9DFC4", "#9C8F6A", 0.4)
aPairs = [ [ "New York", 40.7128, -74.0060, "London", 51.5074, -0.1278 ],
           [ "Niamey", 13.5116, 2.1254, "Tokyo", 35.6895, 139.6917 ] ]
for i = 1 to len(aPairs)
	a = aPairs[i]
	nGeo = oE.DistanceKm(a[2], a[3], a[5], a[6])
	nRh = oE.RhumbDistanceKm(a[2], a[3], a[5], a[6])
	aGeo = oE.GeodesicFlat(a[2], a[3], a[5], a[6], 60)
	aRh = oE.RhumbFlat(a[2], a[3], a[5], a[6], 60)
	oP.DrawLineOn(oC, aGeo, "#1B4F72", 2.2)
	oP.DrawLineOn(oC, aRh, "#C0392B", 2.2)
	q1 = oP.Project(a[3], a[2])
	q2 = oP.Project(a[6], a[5])
	oC.AddCircleQ(q1[1], q1[2], 4).FillQ("#111111")
	oC.AddCircleQ(q2[1], q2[2], 4).FillQ("#111111")
	oC.SetFontQ(oBold, 14).AddTextQ(a[1], q1[1] - 20, q1[2] + 18).Fill("#111111")
	oC.Flush()
	oC.SetFontQ(oBold, 14).AddTextQ(a[4], q2[1] - 10, q2[2] - 10).Fill("#111111")
	oC.Flush()
	oC.SetFontQ(oFont, 15).AddTextQ(a[1] + " - " + a[4] + ":  geodesic " + floor(nGeo) + " km, leaves on " +
		floor(oE.Azimuth(a[2], a[3], a[5], a[6])) + " deg;  rhumb " + floor(nRh) + " km on a constant " +
		floor(oE.RhumbAzimuth(a[2], a[3], a[5], a[6])) + " deg", 20, 525 + (i - 1) * 22).Fill("#222222")
	oC.Flush()
	? a[1] + " - " + a[4] + ": geodesic " + nGeo + " km, rhumb " + nRh + " km, azimuth " + oE.Azimuth(a[2], a[3], a[5], a[6])
next
chdir("../../doc/gallery/stzGeoEllipsoid")
oC.ToPNGXT("geodesic_vs_rhumb.png", 9)
? "-> geodesic_vs_rhumb.png"
