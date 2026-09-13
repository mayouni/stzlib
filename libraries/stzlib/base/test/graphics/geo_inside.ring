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

oC = new stzCanvas(1180, 820)
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
oMe.SetKeyBox(40, 470, 400, 620)
# NIAMEY IS A CAPITAL DISTRICT INSIDE TILLABERI, twelve pixels across on this
# sheet, with no empty paper anywhere near it to stand even a number in. It
# was the one region this picture dropped. The inset is what an atlas does
# with it.
oMe.AddInsetXT([ 1.85, 13.3, 2.4, 13.7 ], [ 430, 452, 580, 602 ], "Niamey")
oMe.SetKeyTitle("Numbered on the map")
oMe.DrawRegionsOn(oC, "#FFFFFF", 0.9)
oMe.DrawLabelsOn(oC, oFont, 14, "#1B2B44")
oMe.DrawKeyOn(oC, oFont, 14, "#333333")
oMe.DrawInsetsOn(oC, oFont, 13, "#1B2B44")
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
oMt.SetKeyBox(920, 100, 1170, 440)
# GRAND TUNIS: three governorates inside one city -- Tunis, Ben Arous and
# Manubah. Natural Earth folds Ariana into its neighbours, which is a fact
# about the file and not about Tunisia.
oMt.AddInsetXT([ 9.7, 36.5, 10.45, 37.15 ], [ 925, 490, 1170, 760 ], "Grand Tunis")
oMt.SetKeyTitle("Numbered on the map")
oMt.DrawRegionsOn(oC, "#FFFFFF", 0.9)
oMt.DrawLabelsOn(oC, oFont, 14, "#1B2B44")
oMt.DrawKeyOn(oC, oFont, 14, "#333333")
oMt.DrawInsetsOn(oC, oFont, 13, "#1B2B44")
rTn = oMt.LabelReport()
oC.SetFontQ(oFont, 17).AddTextQ("Tunisia -- 23 governorates", 650, 80).Fill("#111111")

# WHAT AN INSET COULD NOT NAME IS LABELLED NOWHERE AT ALL, because the parent
# left those regions to it. The sheet says so rather than reporting the
# parent's zero and letting the reader assume everything is named.
aInAll = []
for r in oMe.InsetReports()  aInAll + r  next
for r in oMt.InsetReports()  aInAll + r  next
nNot = 0
for r in aInAll  nNot += r[:dropped]  next
if nNot > 0
	oC.SetFontQ(oFont, 13).AddTextQ("" + nNot + " region(s) an inset took are still " +
		"unnamed inside it -- give that inset box more room.", 40, 776).Fill("#B04A3A")
ok
oC.SetFontQ(oFont, 13).AddTextQ("Niger: " + rNe[:named] + " named on the map, " +
	rNe[:numbered] + " numbered, " + rNe[:inset] + " in the inset, " + rNe[:dropped] + " dropped." +
	"   Tunisia: " + rTn[:named] + " named, " + rTn[:numbered] + " numbered, " +
	rTn[:inset] + " in the inset, " + rTn[:dropped] + " dropped.", 40, 798).Fill("#777777")
oC.Flush()
oC.ToPNG("geo_inside.png")

? "Niger   -- named " + rNe[:named] + "  numbered " + rNe[:numbered] +
	"  inset " + rNe[:inset] + "  dropped " + rNe[:dropped]
? "Tunisia -- named " + rTn[:named] + "  numbered " + rTn[:numbered] +
	"  inset " + rTn[:inset] + "  dropped " + rTn[:dropped]
# ONE AT A TIME. Ring's `+` on a list appends ONE ITEM, so `a + b` nests b
# inside a rather than joining them -- and the nested entry then reads as a
# row of empty fields. stzGeoMap.ring carries a comment saying exactly this,
# written earlier today, and this file did it anyway.
aIn = []
for r in oMe.InsetReports()  aIn + r  next
for r in oMt.InsetReports()  aIn + r  next
for r in aIn
	? "   inset " + r[:title] + ": " + r[:count] + " regions, " + r[:named] +
		" named, " + r[:dropped] + " not named, x" + r[:scale]
next
for g in oMe.Findings()  ? "   gate(Niger):   " + g[:severity] + " " + g[:rule]  next
for g in oMt.Findings()  ? "   gate(Tunisia): " + g[:severity] + " " + g[:rule]  next
? "-> geo_inside.png"
