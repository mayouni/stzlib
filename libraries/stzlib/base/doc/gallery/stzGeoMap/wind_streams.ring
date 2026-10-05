# stzGeoMap: an invented wind field (u east, v north) drawn as evenly spaced streamlines over a shaded
# speed raster (DrawStreamDensityOn), with the coastlines on top, then as arrows (DrawVectorsRampedOn).
# Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS to its folder if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoMap/wind_streams.ring
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

# the field: a 10-degree grid, row 0 SOUTH
aGrid = [ -180, -80, 10, 10, 37, 17 ]
aU = []
aV = []
for r = 0 to 16
	nLat = -80 + r * 10
	for c = 0 to 36
		nLon = -180 + c * 10
		aU + (-12 * cos(nLat * 3 * 3.14159265 / 180))
		aV + (5 * sin(nLon * 2 * 3.14159265 / 180) * cos(nLat * 3.14159265 / 180))
	next
next

oC = new stzCanvas(780, 400)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("An invented wind field: speed as colour, flow as streamlines", 20, 30).Fill("#111111")
oC.Flush()
oP = new stzGeoProjection(:NaturalEarth)
oP.FitSphereIn(15, 45, 765, 350, 6)
oM = StzGeoMap(oP, oW)
oM.SetPaper(15, 45, 765, 350)
oM.DrawStreamDensityOnXT(oC, aGrid, aU, aV, 7, :Viridis, "#1A2A44", 6, 0, 300)
oP.DrawFeaturesOn(oC, oW, "#00000000", "#FFFFFF", 0.5)
oP.DrawOutlineOn(oC, "#555555", 1)
oC.SetFontQ(oFont, 15).AddTextQ("DrawStreamDensityOnXT: streamlines over the speed raster; coastlines on top", 20, 380).Fill("#555555")
oC.Flush()

oC2 = new stzCanvas(900, 400)
oC2.SetBackground("#FFFFFF")
oP2 = new stzGeoProjection(:NaturalEarth)
oP2.FitSphereIn(20, 20, 880, 360, 6)
oM2 = StzGeoMap(oP2, oW)
oM2.DrawSphereOn(oC2, "#F4F8FC", "#8FA8C8", 1)
oP2.DrawFeaturesOn(oC2, oW, "#00000000", "#BBBBBB", 0.5)
nArrows = oM2.DrawVectorsRampedOn(oC2, aGrid, aU, aV, 1, 2.2, :Viridis, 1.2)
oC2.SetFontQ(oFont, 15).AddTextQ("DrawVectorsRampedOn: length and colour carry the speed (" + nArrows + " arrows)", 30, 385).Fill("#555555")
oC2.Flush()
? "grid " + aGrid[5] + "x" + aGrid[6] + ", arrows " + nArrows
chdir("../../doc/gallery/stzGeoMap")
oC.ToPNGXT("wind_streams.png", 9)
oC2.ToPNGXT("wind_arrows.png", 9)
? "-> wind_streams.png, wind_arrows.png"
