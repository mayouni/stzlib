# stzGeoMap: the night side of the Earth on 2026-10-05 12:00 UTC (DrawNightOn, DrawTwilightOn), the sun's
# subsolar point (SunAt) and a daylight test (IsDaylightAt) for three cities.
# Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS to its folder if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoMap/daynight_world.ring
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

oC = new stzCanvas(1100, 620)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 24).AddTextQ("Day and night, 2026-10-05 12:00 UTC", 30, 38).Fill("#111111")
oC.Flush()
oP = new stzGeoProjection(:NaturalEarth)
oP.FitSphereIn(20, 56, 1080, 560, 6)
oM = StzGeoMap(oP, oW)
oM.SetPaper(20, 56, 1080, 560)
oM.SetSource("Natural Earth 1:110m (world-atlas); sun position computed by stzGeoMap.SunAt")
oM.SetNoData("#F3EEDC")
oM.DrawSphereOn(oC, "#CFE3F7", "#8FA8C8", 1)
oM.DrawGraticuleOn(oC, 30, "#B7CCE4", 0.8)
oM.DrawRegionsOn(oC, "#888888", 0.4)
nCaps = oM.DrawNightOn(oC, 2026, 10, 5, 12, "#0A1F4A55")
nLines = oM.DrawTwilightOn(oC, 2026, 10, 5, 12, "#0A1F4AAA")
aSun = oM.SunAt(2026, 10, 5, 12)
q = oP.Project(aSun[:lon], aSun[:lat])
oC.AddCircleQ(q[1], q[2], 8).FillQ("#F5B800").Stroke("#8A5A00", 1.5)
aCity = [ [ "Niamey", 2.1254, 13.5116 ], [ "Tokyo", 139.69, 35.69 ], [ "Los Angeles", -118.24, 34.05 ] ]
for i = 1 to len(aCity)
	q = oP.Project(aCity[i][2], aCity[i][3])
	cTxt = aCity[i][1] + ": night"
	if oM.IsDaylightAt(2026, 10, 5, 12, aCity[i][2], aCity[i][3])  cTxt = aCity[i][1] + ": day"  ok
	oC.AddCircleQ(q[1], q[2], 4).FillQ("#C0392B").Stroke("#FFFFFF", 1)
	oM.DrawHaloTextOn(oC, oBold, 14, cTxt, q[1] + 7, q[2] - 6, "#111111", "#FFFFFFDD", 1.5)
next
oM.DrawCaptionOn(oC, oFont, 30, 590)
? "caps " + nCaps + ", twilight lines " + nLines + ", sun " + @@( aSun )
chdir("../../doc/gallery/stzGeoMap")
oC.ToPNG("daynight_world.png")
? "-> daynight_world.png"
