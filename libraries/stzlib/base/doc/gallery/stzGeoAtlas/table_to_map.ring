# stzGeoAtlas: a business table whose first column is names as people type them -- codes, former names, a
# misspelling -- becomes a map in two calls (ValuesFor, then SetValues). What did not bind is listed
# (Unresolved), not guessed; features the table never mentioned stay hatched as no data.
# Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS to its folder if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoAtlas/table_to_map.ring
load "../../stzBase.ring"
decimals(1)
cAtlas = sysget("STZ_ATLAS")
if cAtlas = ""  cAtlas = "../graphics/atlas/"  ok
if NOT fexists(cAtlas + "countries-110m.json")
	? "SKIPPED, by name: " + cAtlas + "countries-110m.json is not present -- see test/graphics/atlas/README.md."
	return
ok
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oW = StzGeoFeaturesFromTopoJson(read(cAtlas + "countries-110m.json"), "countries")
oA = StzGeoAtlas(oW)

# the caller's table (INVENTED figures): order and spelling are the caller's
aRows = [ [ "USA", 330 ], [ "Ivory Coast", 27 ], [ "Burma", 54 ], [ "NE", 26 ], [ "fr", 68 ], [ "Czechia", 10 ],
          [ "Republic of Korea", 52 ], [ "Brasil", 214 ], [ "Nigeria", 213 ], [ "Brazil", 214 ], [ "Atlantis", 1 ],
          [ "Russia", 144 ], [ "India", 1400 ], [ "Egypt", 104 ], [ "Australia", 26 ], [ "Mexico", 128 ] ]
aVal = oA.ValuesFor(aRows)
aLost = oA.Unresolved(aRows)
aUnc = oA.Uncovered(aRows)
? "unresolved: " + @@( aLost )
? "features the table did not mention: " + len(aUnc) + " of " + oA.Count()

oC = new stzCanvas(1100, 640)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 24).AddTextQ("A table of names, drawn: population in millions (invented)", 20, 36).Fill("#111111")
oC.Flush()
oP = new stzGeoProjection(:EqualEarth)
oP.FitSphereIn(20, 56, 880, 460, 6)
oM = StzGeoMap(oP, oW)
oM.SetPaper(20, 56, 880, 460)
oM.SetSource("Natural Earth 1:110m (world-atlas); the figures are INVENTED")
oM.SetValues(aVal)
oM.SetClasses([ 0, 30, 60, 120, 250, 1500 ])
oM.SetRamp(:Greens)
oM.DrawSphereOn(oC, "#EAF1FB", "#8FA8C8", 1)
oM.DrawSheetOn(oC, "#555555", 0.4)
oM.DrawRampLegendOn(oC, oFont, 13, 30, 500, 460, 18, "#333333")
oC.SetFontQ(oBold, 15).AddTextQ("did not bind (" + len(aLost) + "):", 620, 500).Fill("#C0392B")
oC.Flush()
for i = 1 to len(aLost)
	oC.SetFontQ(oFont, 15).AddTextQ(aLost[i], 760, 500 + (i - 1) * 20).Fill("#C0392B")
	oC.Flush()
next
oC.SetFontQ(oFont, 14).AddTextQ("" + (oA.Count() - len(aUnc)) + " of " + oA.Count() + " features carry a value; " + len(aUnc) + " are hatched (the table said nothing)", 20, 566).Fill("#333333")
oC.Flush()
oM.DrawCaptionOn(oC, oFont, 20, 600)
oC.Flush()
chdir("../../doc/gallery/stzGeoAtlas")
oC.ToPNGXT("table_to_map.png", 9)
? "-> table_to_map.png"
