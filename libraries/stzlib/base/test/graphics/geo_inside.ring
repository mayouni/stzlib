load "../../stzBase.ring"
decimals(1)

# GE6 -- INSIDE A COUNTRY. Niger's eight regions and Tunisia's twenty-three
# governorates, each on its OWN conic: standard parallels at a sixth and
# five sixths of that country's latitude span, which is the rule an atlas
# has used for a century.
#
# AND EACH ON ITS OWN SHEET SHAPE, which is the lesson the first version of
# this picture taught. It laid both countries in equal halves of one strip,
# and Niger -- which is two and a half times wider than it is tall -- came
# out 250 pixels across, so six of its eight names had nowhere to go. The
# report blamed the label engine for what the LAYOUT had done. Niger gets a
# wide shallow box; Tunisia, which is twice as tall as it is wide, gets a
# narrow deep one.
#
# The names are placed the way an atlas places them: INSIDE the region where
# the name fits, and otherwise a NUMBER against the region with the name in
# the KEY beside the map. No leader lines -- see stzGeoMap.ring for the
# three rounds of them that were drawn, returned, and finally removed.

if NOT fexists("atlas/admin1_niger.geojson")
	? "SKIPPED, by name: atlas/admin1_niger.geojson is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")

oC = new stzCanvas(1180, 700)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 22).AddTextQ("Inside a country -- the units people actually analyse", 30, 44).Fill("#111111")

# ---- NIGER: wide and shallow, so the box is too -------------------------
oNe = StzGeoFeaturesFromJson(read("atlas/admin1_niger.geojson"))
oPe = StzGeoConicFor(oNe, :ConicEqualArea)
oPe.FitFeaturesIn(oNe, 40, 100, 560, 400, 6)
oMe = StzGeoMap(oPe, oNe)
oMe.SetSource("Natural Earth 1:10m")
oMe.SetValuesQ(oMe.ValuesFromArea()).SetClassesQ([ 0, 20000, 50000, 90000, 150000, 900000 ])
oMe.SetRamp(:YlGnBu)
oMe.SetPaper(30, 90, 570, 410)
oMe.SetKeyBox(40, 440, 570, 620)
oMe.SetKeyTitle("Numbered on the map")
oMe.DrawRegionsOn(oC, "#FFFFFF", 0.9)
oMe.DrawLabelsOn(oC, oFont, 14, "#1B2B44")
oMe.DrawKeyOn(oC, oFont, 14, "#333333")
rNe = oMe.LabelReport()
oC.SetFontQ(oFont, 17).AddTextQ("Niger -- 8 regions", 40, 80).Fill("#111111")

# ---- TUNISIA: twice as tall as wide, and the key beside it --------------
oTn = StzGeoFeaturesFromJson(read("atlas/admin1_tunisia.geojson"))
oPt = StzGeoConicFor(oTn, :ConicEqualArea)
oPt.FitFeaturesIn(oTn, 650, 100, 890, 640, 6)
oMt = StzGeoMap(oPt, oTn)
oMt.SetSource("Natural Earth 1:10m")
oMt.SetValuesQ(oMt.ValuesFromArea()).SetClassesQ([ 0, 1500, 3000, 5000, 8000, 40000 ])
oMt.SetRamp(:YlGnBu)
oMt.SetPaper(640, 90, 900, 650)
oMt.SetKeyBox(920, 100, 1170, 650)
oMt.SetKeyTitle("Numbered on the map")
oMt.DrawRegionsOn(oC, "#FFFFFF", 0.9)
oMt.DrawLabelsOn(oC, oFont, 14, "#1B2B44")
oMt.DrawKeyOn(oC, oFont, 14, "#333333")
rTn = oMt.LabelReport()
oC.SetFontQ(oFont, 17).AddTextQ("Tunisia -- 23 governorates", 650, 80).Fill("#111111")

oC.SetFontQ(oFont, 13).AddTextQ("Niger: " + rNe[:named] + " named on the map, " +
	rNe[:numbered] + " numbered into the key, " + rNe[:dropped] + " dropped." +
	"   Tunisia: " + rTn[:named] + " named, " + rTn[:numbered] + " numbered, " +
	rTn[:dropped] + " dropped.", 40, 675).Fill("#777777")
oC.Flush()
oC.ToPNG("geo_inside.png")

? "Niger   -- named " + rNe[:named] + "  numbered " + rNe[:numbered] + "  dropped " + rNe[:dropped]
? "Tunisia -- named " + rTn[:named] + "  numbered " + rTn[:numbered] + "  dropped " + rTn[:dropped]
? "-> geo_inside.png"
