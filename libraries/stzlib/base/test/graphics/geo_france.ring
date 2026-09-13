load "../../stzBase.ring"
decimals(1)

# GE6 -- WHEN THE UNITS ALREADY HAVE NUMBERS, AND WHEN A KEY CANNOT SAVE
# YOU. France's departments are small and its names are long
# ("Pyrenees-Atlantiques" is wider than the department it names), so on a
# sheet this size twenty-nine names fit inside their borders and sixty-seven
# do not.
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
oP.FitFeaturesIn(oU, 40, 90, 720, 690, 8)
oM = StzGeoMap(oP, oU)
oM.SetSource("Natural Earth 1:10m, public domain")
oM.SetValuesQ(oM.ValuesFromArea()).SetClassesQ([ 0, 4000, 5500, 7000, 9000, 30000 ])
oM.SetRamp(:Greens)
# THE PAPER STOPS WHERE THE INSET STARTS. A label is placed anywhere on the
# paper and the inset is drawn afterwards, so an inset standing on the paper
# covers whatever was written under it -- this sheet lost the "06" of
# Alpes-Maritimes that way. The paper is the map's own ground; the inset
# lives beside it.
oM.SetPaper(30, 80, 725, 700)
oM.SetKeyCodes("iso_3166_2")
# THE PETITE COURONNE: four departments inside one city, the six this sheet
# used to drop. At the main map's scale they are a knot eight pixels across;
# at the inset's they are four shapes with four numbers.
oM.AddInsetXT([ 2.15, 48.7, 2.60, 49.0 ], [ 740, 430, 980, 670 ], "Paris and the Petite Couronne")
oM.DrawRegionsOn(oC, "#FFFFFF", 0.7)
oM.DrawLabelsOn(oC, oFont, 13, "#14301F")
oM.DrawInsetsOn(oC, oFont, 13, "#14301F")
r = oM.LabelReport()

oC.SetFontQ(oFont, 14).AddTextQ("" + r[:named] + " departments carry their name; " +
	r[:numbered] + " carry their official code; " + r[:inset] +
	" are in the inset; " + r[:dropped] + " fit nowhere at all.", 30, 730).Fill("#333333")
oC.SetFontQ(oFont, 13).AddTextQ("The Petite Couronne -- four departments inside one city -- is " +
	"the knot this sheet used to drop. It is the INSET now.", 30, 756).Fill("#777777")
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
	"  inset " + r[:inset] + "  dropped " + r[:dropped]
for q in oM.InsetReports()
	? "   inset " + q[:title] + ": " + q[:count] + " regions, " + q[:named] +
		" named, " + q[:dropped] + " not named, x" + q[:scale]
next
for i = 1 to len(aF)
	? "   gate: " + aF[i][:severity] + " " + aF[i][:rule]
next
? "-> geo_france.png"
