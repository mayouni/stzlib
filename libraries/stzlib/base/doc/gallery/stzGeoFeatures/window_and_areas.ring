# stzGeoFeatures: (1) Within() on the world with the bounding box of each taken feature (BoundsOf) -- Fiji
# crosses the antimeridian, so its box is 360 degrees wide and its middle falls inside an Africa window;
# (2) Niger's regions with their measured areas (AreaKm2Of, on WGS84) and bounding boxes.
# Needs the world atlas for the first panel (test/graphics/atlas/README.md); STZ_ATLAS names its folder.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoFeatures/window_and_areas.ring
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
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))

oC = new stzCanvas(1000, 500)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Windows and areas in a boundary file", 20, 32).Fill("#111111")
oC.Flush()

# 1. the Africa window (-20..52 E, -36..38 N): the features whose box middle falls in it
oP = new stzGeoProjection(:EqualEarth)
oP.FitSphereIn(15, 60, 585, 340, 4)
oP.DrawSphereOn(oC, "#EAF1FB", "#8FA8C8", 1)
oP.DrawFeaturesOn(oC, oW, "#EFEFEF", "#BBBBBB", 0.4)
aIn = oW.IndicesWithin(-20, -36, 52, 38)
aWin = [ -20, -36, 52, -36, 52, 38, -20, 38, -20, -36 ]
oP.DrawLineOn(oC, aWin, "#111111", 1.4)
for k = 1 to len(aIn)
	i = aIn[k]
	b = oW.BoundsOf(i)
	cInk = "#2E86C1"
	bWide = (b[3] - b[1] > 90)
	if bWide  cInk = "#C0392B"  ok
	oP.DrawFeatureOn(oC, oW, i, cInk + "88", cInk, 0.6)
	if bWide
		oC.SetFontQ(oBold, 14).AddTextQ(oW.NameOf(i) + ": box " + floor(b[3] - b[1]) + " degrees wide", 20, 366).Fill("#C0392B")
		oC.Flush()
	ok
next
oC.SetFontQ(oFont, 13).AddTextQ("" + len(aIn) + " features taken by Within(-20, -36, 52, 38)", 20, 388).Fill("#555555")
oC.Flush()

oC.SetFontQ(oFont, 13).AddTextQ("blue: Africa and its neighbours, red: a box across the antimeridian", 20, 408).Fill("#555555")
oC.Flush()

# 2. Niger by region: area and box
oP2 = StzGeoConicFor(oN, :ConicEqualArea)
oP2.FitFeaturesIn(oN, 620, 60, 985, 330, 6)
aCol = [ "#FDEBD0", "#FAD7A0", "#F8C471", "#F5B041", "#EB984E", "#DC7633", "#CA6F1E", "#A04000" ]
for i = 1 to oN.Count()
	oP2.DrawFeatureOn(oC, oN, i, aCol[i], "#5A3A1E", 0.7)
next
y = 352
for i = 1 to oN.Count()
	oC.AddRectQ(620, y - 11, 14, 14).FillQ(aCol[i]).Stroke("#5A3A1E", 0.6)
	oC.SetFontQ(oFont, 14).AddTextQ(oN.NameOf(i) + "  " + floor(oN.AreaKm2Of(i)) + " km2", 642, y).Fill("#222222")
	oC.Flush()
	y += 19
next
oC.SetFontQ(oBold, 14).AddTextQ("total " + floor(oN.AreaKm2()) + " km2 (AreaKm2)", 800, 352).Fill("#222222")
oC.Flush()
? "Within window: " + len(aIn) + " features, Fiji box " + oW.BoundsOf(oW.IndexOfName("Fiji"))[1] + " to " + oW.BoundsOf(oW.IndexOfName("Fiji"))[3]
chdir("../../doc/gallery/stzGeoFeatures")
oC.ToPNGXT("window_and_areas.png", 9)
? "-> window_and_areas.png"
