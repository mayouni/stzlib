# stzGeoEllipsoid: distance rings around Niamey made with DestinationKm (one point every 3 degrees of
# bearing) on an azimuthal equidistant map, where they must come out as true circles; and the measured
# area of a one-degree cell at five latitudes (AreaKm2), which shrinks with the cosine of the latitude.
# Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS to its folder if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoEllipsoid/rings_and_areas.ring
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

oC = new stzCanvas(900, 520)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Rings of 1000 km steps around Niamey, from DestinationKm", 20, 32).Fill("#111111")
oC.Flush()
oP = new stzGeoProjection(:AzimuthalEquidistant)
oP.CenterOn(2.1254, 13.5116)
oP.FitSphereIn(20, 50, 520, 500, 4)
oP.DrawSphereOn(oC, "#EAF1FB", "#8FA8C8", 1)
oP.DrawGraticuleOn(oC, 30, "#C9D6E8", 0.7)
oP.DrawFeaturesOn(oC, oLand, "#E9DFC4", "#9C8F6A", 0.4)
for nKm = 1000 to 9000 step 1000
	aRing = []
	for nAz = 0 to 360 step 3
		aD = oE.DestinationKm(13.5116, 2.1254, nAz, nKm)
		aRing + aD[2]
		aRing + aD[1]
	next
	oP.DrawLineOn(oC, aRing, "#C0392B", 1)
next
q = oP.Project(2.1254, 13.5116)
oC.AddCircleQ(q[1], q[2], 4).FillQ("#C0392B").Stroke("#FFFFFF", 1)

oC.SetFontQ(oBold, 17).AddTextQ("A cell of 1 x 1 degree", 560, 80).Fill("#111111")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("AreaKm2 of the box (lon 0..1, lat L..L+1)", 560, 102).Fill("#555555")
oC.Flush()
aLat = [ 0, 30, 60, 80, 89 ]
for i = 1 to len(aLat)
	nL = aLat[i]
	nA = oE.AreaKm2([ 0, nL, 1, nL, 1, nL + 1, 0, nL + 1 ])
	nW = 18 * cos(nL * 3.14159265 / 180) + 1
	nY = 130 + (i - 1) * 62
	oC.AddRectQ(560, nY, nW * 3, 40).FillQ("#2E86C1").Stroke("#1B4F72", 1)
	oC.SetFontQ(oFont, 14).AddTextQ("lat " + nL + ":  " + floor(nA) + " km2   (a degree of longitude is " +
		floor(oE.DegreeOfLongitudeKm(nL + 0.5) + 0.5) + " km)", 560, nY + 58).Fill("#222222")
	oC.Flush()
	? "lat " + nL + ": " + nA + " km2, degree of longitude " + oE.DegreeOfLongitudeKm(nL + 0.5) + " km, of latitude " + oE.DegreeOfLatitudeKm(nL + 0.5) + " km"
next
chdir("../../doc/gallery/stzGeoEllipsoid")
oC.ToPNGXT("rings_and_areas.png", 9)
? "-> rings_and_areas.png"
