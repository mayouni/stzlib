# stzGeoMap: every country coloured by its own area (ValuesFromArea) on the Equal Earth projection,
# with a hatched no-data class (Antarctica carries no value here) and a ramp legend.
# Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS to its folder if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoMap/world_area.ring
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

oC = new stzCanvas(1100, 640)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 26).AddTextQ("Country areas, km2, on Equal Earth", 30, 40).Fill("#111111")
oC.Flush()
oP = new stzGeoProjection(:EqualEarth)
oP.FitSphereIn(20, 60, 1080, 560, 6)
oM = StzGeoMap(oP, oW)
oM.SetPaper(20, 60, 1080, 560)
oM.SetSource("Natural Earth 1:110m (world-atlas); areas measured on WGS84")
aA = oM.ValuesFromArea()
iAnt = oW.IndexOfName("Antarctica")
if iAnt > 0  aA[iAnt] = ""  ok
oM.SetValues(aA)
oM.SetClasses([ 0, 50000, 250000, 1000000, 3000000, 20000000 ])
oM.SetRamp(:Viridis)
oM.DrawSphereOn(oC, "#EAF1FB", "#8FA8C8", 1)
oM.DrawGraticuleOn(oC, 30, "#D2DCEA", 0.8)
oM.DrawSheetOn(oC, "#444444", 0.4)
oM.DrawRampLegendOn(oC, oFont, 14, 40, 596, 620, 18, "#333333")
oM.DrawCaptionOn(oC, oFont, 30, 632)
? "no data: " + oM.NoDataCount() + ", gate: " + @@( oM.Findings() )
chdir("../../doc/gallery/stzGeoMap")
oC.ToPNG("world_area.png")
? "-> world_area.png"
