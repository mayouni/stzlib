load "../../stzBase.ring"
decimals(1)

# GE6 -- WHEN THE UNITS ALREADY HAVE NUMBERS, AND WHEN A KEY CANNOT SAVE
# YOU. France's departments are small and its names are long
# ("Pyrenees-Atlantiques" is wider than the department it names), so on a
# sheet this size twenty-four names fit inside their borders and
# seventy-two do not.
#
# THE KEY IS NOT THE ANSWER HERE, AND THAT IS A MEASURED CLAIM, taken from
# this same picture before it was rewritten. Numbered sequentially it
# produced 75 key entries; at the type floor of 13 px a key row is 18 px
# tall and a key column about 160 px wide, so the widest key box this sheet
# could spare carried 39 of them. The other 36 were numbers on the map
# appearing nowhere at all -- and the first DrawKeyOn dropped them in
# SILENCE, under a comment in stzGeoMap.ring claiming a key must never do
# that. The gate refuses it now by name: the_key_lists_every_number.
#
# So France is drawn the way France is actually printed: WITH THE CODES THE
# COUNTRY ALREADY USES. 75 is Paris, 13 is Marseille, 59 is the Nord, and a
# French reader knows them the way an American knows CA and TX. Natural
# Earth carries them in iso_3166_2 as "FR-59"; SetKeyCodes takes the part
# after the dash, and the map needs no key at all.
#
# The gate still has something to say about that, and it is right to: a
# sheet of codes with no key is open to a reader at home in the country and
# closed to everyone else. So every_number_has_a_key fires here as a
# WARNING rather than an error, and this sheet PRINTS ITS OWN FINDINGS at
# the foot -- a picture that shows what the gate thinks of it is harder to
# ship broken than one whose findings live in a test nobody opens.

if NOT fexists("atlas/admin1_france.geojson")
	? "SKIPPED, by name: atlas/admin1_france.geojson is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")

# METROPOLITAN ONLY. Natural Earth's France carries Guyane, Reunion,
# Martinique, Guadeloupe and Mayotte, and a conic fitted to all of them puts
# its standard parallels in the Atlantic -- the GE3 rule
# the_extent_is_one_place exists because this file taught it.
oU = StzGeoFeaturesFromJson(read("atlas/admin1_france.geojson")).Within(-5.5, 41, 10, 51.5)

oC = new stzCanvas(1000, 900)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 24).AddTextQ("France -- 96 departments, numbered the way France numbers them", 30, 48).Fill("#111111")

oP = StzGeoConicFor(oU, :ConicEqualArea)
oP.FitFeaturesIn(oU, 50, 90, 950, 690, 8)
oM = StzGeoMap(oP, oU)
oM.SetSource("Natural Earth 1:10m, public domain")
oM.SetValuesQ(oM.ValuesFromArea()).SetClassesQ([ 0, 4000, 5500, 7000, 9000, 30000 ])
oM.SetRamp(:Greens)
oM.SetPaper(40, 80, 960, 700)
oM.SetKeyCodes("iso_3166_2")
oM.DrawRegionsOn(oC, "#FFFFFF", 0.7)
oM.DrawLabelsOn(oC, oFont, 13, "#14301F")
r = oM.LabelReport()

oC.SetFontQ(oFont, 14).AddTextQ("" + r[:named] + " departments carry their name; " +
	r[:numbered] + " carry their official code; " + r[:dropped] +
	" would fit neither inside their borders nor against them and are not " +
	"drawn at all.", 30, 730).Fill("#333333")
oC.SetFontQ(oFont, 13).AddTextQ("The ones left out are the Petite Couronne -- four departments" +
	" inside one city, with no empty paper to stand a number in.", 30, 756).Fill("#777777")
oC.SetFontQ(oFont, 13).AddTextQ("An atlas answers that with an INSET: a zoomed box for the " +
	"Ile-de-France. That is the next step and is not in this picture.", 30, 778).Fill("#777777")
oM.DrawCaptionOn(oC, oFont, 30, 816)

# THE GATE, PRINTED ON THE SHEET. A picture that shows its own findings is
# harder to ship broken than one whose findings live in a test nobody reads.
aF = oM.Findings()
nY = 852
oC.SetFontQ(oFont, 13).AddTextQ("What the gate says about this sheet:", 30, nY).Fill("#555555")
for i = 1 to len(aF)
	nY += 20
	oC.SetFontQ(oFont, 13).AddTextQ("  " + aF[i][:severity] + " -- " + aF[i][:rule], 30, nY).Fill("#555555")
next
oC.Flush()
oC.ToPNG("geo_france.png")

? "France -- named " + r[:named] + "  numbered " + r[:numbered] +
	"  dropped " + r[:dropped] + "  unlisted " + r[:unlisted]
for i = 1 to len(aF)
	? "   gate: " + aF[i][:severity] + " " + aF[i][:rule]
next
? "-> geo_france.png"
