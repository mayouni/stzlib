# stzGeoProjection: a globe centred on Niamey (Orthographic, CenterOn) with great-circle routes (Arc),
# range rings of 1000 km steps (StzGeoCircleKm drawn by DrawRingOn) and the point under the cursor (Invert).
# Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS to its folder if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoProjection/globe_routes.ring
load "../../stzBase.ring"
decimals(2)
cAtlas = sysget("STZ_ATLAS")
if cAtlas = ""  cAtlas = "../graphics/atlas/"  ok
if NOT fexists(cAtlas + "countries-110m.json")
	? "SKIPPED, by name: " + cAtlas + "countries-110m.json is not present -- see test/graphics/atlas/README.md."
	return
ok
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oW = StzGeoFeaturesFromTopoJson(read(cAtlas + "countries-110m.json"), "countries")

oC = new stzCanvas(700, 640)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("From Niamey, by great circle", 20, 32).Fill("#111111")
oC.Flush()
oP = new stzGeoProjection(:Orthographic)
oP.CenterOn(2.1254, 13.5116)
oP.FitSphereIn(30, 50, 670, 590, 6)
oP.DrawSphereOn(oC, "#DCEBFA", "#6F8AB0", 1.2)
oP.DrawGraticuleOn(oC, 15, "#B7CCE4", 0.7)
oP.DrawFeaturesOn(oC, oW, "#EFE6CC", "#9C8F6A", 0.4)
for nKm = 1000 to 5000 step 1000
	oP.DrawRingOn(oC, StzGeoCircleKm(2.1254, 13.5116, nKm, 120), "#00000000", "#C0392B", 1)
next
aCity = [ [ "Paris", 2.3522, 48.8566 ], [ "Cairo", 31.2357, 30.0444 ], [ "Lagos", 3.3792, 6.5244 ],
          [ "Nairobi", 36.8219, -1.2921 ], [ "Cape Town", 18.4241, -33.9249 ], [ "Rio", -43.1729, -22.9068 ] ]
for i = 1 to len(aCity)
	oP.DrawLineOn(oC, StzGeoArc(2.1254, 13.5116, aCity[i][2], aCity[i][3], 64), "#1B4F72", 1.6)
	q = oP.Project(aCity[i][2], aCity[i][3])
	if len(q) = 2
		oC.AddCircleQ(q[1], q[2], 4).FillQ("#1B4F72").Stroke("#FFFFFF", 1)
		nKm = StzGeoDistanceKm(2.1254, 13.5116, aCity[i][2], aCity[i][3])
		oC.SetFontQ(oFont, 13).AddTextQ(aCity[i][1] + " " + floor(nKm) + " km", q[1] + 6, q[2] - 6).Fill("#111111")
		oC.Flush()
	ok
next
q = oP.Project(2.1254, 13.5116)
oC.AddCircleQ(q[1], q[2], 5).FillQ("#C0392B").Stroke("#FFFFFF", 1.5)
oC.SetFontQ(oFont, 14).AddTextQ(oP.Caption() + "; rings every 1000 km", 20, 622).Fill("#555555")
oC.Flush()
? "centre of the paper: " + @@( oP.Center() )
? "Invert of Niamey's pixel: " + @@( oP.Invert(q[1], q[2]) )
chdir("../../doc/gallery/stzGeoProjection")
oC.ToPNGXT("globe_routes.png", 9)
? "-> globe_routes.png"
