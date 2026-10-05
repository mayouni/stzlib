# stzGeoMap: a membership map (SetGroups) of West African blocs on an equal-area conic, with the
# group key, names for the members only, and a note of what did not resolve.
# Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS to its folder if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoMap/africa_blocs.ring
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
oWorld = StzGeoFeaturesFromTopoJson(read(cAtlas + "countries-110m.json"), "countries")
# a feature that crosses the antimeridian (Fiji) has a box of 360 degrees whose middle falls anywhere,
# so Within() takes it: keep only features narrower than 90 degrees
aKeep = []
for i = 1 to len(oWorld.IndicesWithin(-20, -36, 52, 38))
	k = oWorld.IndicesWithin(-20, -36, 52, 38)[i]
	b = oWorld.BoundsOf(k)
	if b[3] - b[1] < 90  aKeep + k  ok
next
oA = oWorld.Subset(aKeep)

oC = new stzCanvas(1000, 640)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 26).AddTextQ("West African blocs", 30, 40).Fill("#111111")
oC.Flush()
oP = StzGeoConicFor(oA, :ConicEqualArea)
oP.FitFeaturesIn(oA, 30, 60, 760, 600, 8)
oM = StzGeoMap(oP, oA)
oM.SetPaper(20, 50, 770, 610)
oM.SetSource("Natural Earth 1:110m (world-atlas); membership as named in this script")
oM.SetNoData("#EFEFEF")
oM.SetGroups([ [ "Sahel alliance (AES)", "#C0392B", [ "Niger", "Mali", "Burkina Faso" ] ],
               [ "Other ECOWAS", "#2E86C1", [ "Nigeria", "Benin", "Togo", "Ghana", "Côte d'Ivoire", "Senegal", "Guinea", "Liberia", "Sierra Leone", "Gambia", "Guinea-Bissau" ] ] ])
oM.DrawSphereOn(oC, "#EAF1FB", "#8FA8C8", 1)
oM.DrawSheetOn(oC, "#555555", 0.5)
oM.SetLabelMode(:Names)
oM.DrawLabelsOn(oC, oFont, 13, "#FFFFFF")
oM.DrawGroupKeyOn(oC, oFont, 16, 790, 120, "#222222")
oM.DrawCaptionOn(oC, oFont, 30, 630)
? "unresolved: " + @@( oM.UnresolvedMembers() )
? "labels: " + @@( oM.LabelReport() )
? "gate: " + @@( oM.Findings() )
chdir("../../doc/gallery/stzGeoMap")
oC.ToPNG("africa_blocs.png")
? "-> africa_blocs.png"
