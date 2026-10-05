# stzGeoAtlas: the page of how each key the caller types finds its feature (IndexOf): the file's own id first,
# then its own name folded (case, accents, punctuation, a leading "the"), then an alias in either direction,
# then a two- or three-letter code through the library's country table. A near miss is not guessed.
# Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS to its folder if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoAtlas/how_a_key_resolves.ring
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
aKeys = [ "Niger", "  NIGER ", "562", "NE", "NER", "ne", "Nigeria", "USA", "United States", "Ivory Coast",
          "Cote d'Ivoire", "Burma", "The Gambia", "Czechia", "Holland", "Russia", "UK", "Cape Verde", "Brasil", "Atlantis", "Niger " + char(34) + "x" ]

oC = new stzCanvas(900, 130 + len(aKeys) * 24)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("How a key finds its country: IndexOf against the 110m world file", 20, 34).Fill("#111111")
oC.Flush()
oC.SetFontQ(oBold, 15).AddTextQ("typed", 30, 74).Fill("#555555")
oC.Flush()
oC.SetFontQ(oBold, 15).AddTextQ("IndexOf", 300, 74).Fill("#555555")
oC.Flush()
oC.SetFontQ(oBold, 15).AddTextQ("the file calls it", 400, 74).Fill("#555555")
oC.Flush()
y = 102
nFound = 0
for i = 1 to len(aKeys)
	k = oA.IndexOf(aKeys[i])
	cInk = "#1E8449"
	cName = oA.NameOf(aKeys[i])
	if k = 0
		cInk = "#C0392B"
		cName = "(not found, not guessed)"
	else
		nFound++
	ok
	oC.SetFontQ(oFont, 16).AddTextQ(char(34) + aKeys[i] + char(34), 30, y).Fill("#222222")
	oC.Flush()
	oC.SetFontQ(oFont, 16).AddTextQ("" + k, 300, y).Fill(cInk)
	oC.Flush()
	oC.SetFontQ(oFont, 16).AddTextQ(cName, 400, y).Fill(cInk)
	oC.Flush()
	? aKeys[i] + " -> " + k + " " + cName
	y += 24
next
oC.SetFontQ(oFont, 14).AddTextQ("" + nFound + " of " + len(aKeys) + " keys found; the folded forms: " + StzGeoNormalizeName("Cote d'Ivoire") + ", " + StzGeoNormalizeName("The Gambia"), 30, y + 14).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoAtlas")
oC.ToPNGXT("how_a_key_resolves.png", 9)
? "-> how_a_key_resolves.png"
