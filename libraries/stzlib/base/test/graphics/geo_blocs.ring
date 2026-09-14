load "../../stzBase.ring"
decimals(1)

# G7 vs BRICS -- A MEMBERSHIP MAP, and what the usual one gets wrong.
#
# The Principal handed me an infographic of this and asked for it. It is a
# good exercise because a bloc map is NOT a choropleth: there is no scale,
# no ramp and no order. G7 is not more than BRICS, it is other than BRICS.
# So the plane grew `SetGroups` -- colours named by the caller, a legend
# that is a KEY of names rather than a row of ranges, and members given BY
# NAME because that is how anybody actually has a bloc.
#
# AND THE ORIGINAL MAKES AN ARGUMENT ITS PROJECTION INVENTED. A membership
# map carries exactly one quantity, and it is not written anywhere on the
# sheet: HOW MUCH OF THE WORLD each bloc covers. The reader takes it
# straight off the painted area. The infographic is drawn on a Mercator-like
# projection, where Russia and Canada are several times the ground they
# have -- so the two biggest countries on the sheet, one in each bloc, are
# both inflated, and the comparison the picture exists to invite is made
# against a distortion.
#
# This sheet draws it twice to show the size of that: once on the same kind
# of projection the original uses, once on an equal-area one, with the
# painted area MEASURED on the sphere underneath both. The numbers are the
# same in both panels because they are computed from the rings and not from
# the pixels; what changes is what the eye is told.
#
# Everything else here is GE4 (names to shapes without vendoring shapes),
# GE6b/c (a name inside its country or a number and a key) and GE3 (the
# rules). The only new thing is that membership is not a quantity.

if NOT fexists("atlas/countries-110m.json")
	? "SKIPPED, by name: atlas/countries-110m.json is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oW = StzGeoFeaturesFromTopoJson(read("atlas/countries-110m.json"), "countries")

cBlue = "#1B3A73"
cRed  = "#C0202A"
cGrey = "#C9CDD2"

aG7 = [ "United States of America", "Canada", "United Kingdom", "France",
        "Germany", "Italy", "Japan" ]
aBrics = [ "Brazil", "Russia", "India", "China", "South Africa", "Egypt",
           "Ethiopia", "Iran", "Saudi Arabia", "United Arab Emirates", "Indonesia" ]
aGroups = [ [ "G7 -- " + len(aG7) + " members", cBlue, aG7 ],
            [ "BRICS -- " + len(aBrics) + " members", cRed, aBrics ] ]

oC = new stzCanvas(1280, 1030)
oC.SetBackground("#F4F7FB")

# FLUSH BETWEEN TWO SIZES. stzCanvas applies the LAST SetFont to text that
# has not been flushed yet -- the trap its own Flush() documents -- so a
# title at 34 followed by a subtitle at 15 comes out with the two sizes
# swapped. The first render of this sheet showed exactly that.
cTitle = "G7 vs BRICS"
oC.SetFontQ(oFont, 36).AddTextQ(cTitle, (1280 - oFont.WidthOf(cTitle, 36)) / 2, 58).Fill(cBlue)
oC.Flush()
cSub = "Global geopolitical blocs -- and the projection that draws them"
oC.SetFontQ(oFont, 15).AddTextQ(cSub, (1280 - oFont.WidthOf(cSub, 15)) / 2, 84).Fill("#667788")
oC.Flush()

# EQUAL EARTH, NOT A CONIC. A conic is fitted to a BAND of latitude -- it
# is what GE6 gives a country -- and fitting one to the whole globe folds
# the world into a fan. The first draft of this sheet did exactly that. The
# equal-area projection a world map wants is Equal Earth (Savric, Patterson
# and Jenny, 2018), which is what every serious world sheet has used since.
aSheet = [ [ :Mercator,   "As the infographic draws it -- Mercator",
             "areas are not areas here, and Antarctica cannot be drawn at all: " +
             "Mercator sends the poles to infinity" ],
           [ :EqualEarth, "As an equal-area projection draws it -- Equal Earth",
             "every painted patch is the ground it stands for, poles included" ] ]

aReport = []
for m = 1 to 2
	nY0 = 120 + (m - 1) * 420
	oP = new stzGeoProjection(aSheet[m][1])
	if m = 1
		# Mercator runs to infinity at the poles, so it is fitted to a
		# lon/lat BOX cut where every atlas cuts it -- not to the features,
		# which include Antarctica and would send the fit to nothing
		oP.FitPointsIn([ -180, -58, 180, 82 ], 60, nY0, 1240, nY0 + 380, 0)
	else
		oP.FitFeaturesIn(oW, 60, nY0, 1240, nY0 + 380, 4)
	ok
	# MERCATOR CANNOT DRAW ANTARCTICA AND MUST NOT PRETEND TO. It sends the
	# poles to infinity, so a feature centred at 74 south projects a long
	# way below any box -- and SetPaper governs where LABELS may go, not
	# where geometry lands. The first render of this sheet had Antarctica
	# spilling out of the Mercator panel and lying across the one below it
	# as a grey bar over the Pacific. Every Mercator world map ever printed
	# cuts the poles off; this one says it does.
	oPanel = oW
	if m = 1  oPanel = oW.Within(-180, -58, 180, 82)  ok
	oM = StzGeoMap(oP, oPanel)
	oM.SetSource("Natural Earth 1:110m via world-atlas")
	oM.SetPaper(50, nY0 - 10, 1250, nY0 + 390)
	oM.SetNoData(cGrey)
	oM.SetGroups(aGroups)
	oM.DrawRegionsOn(oC, "#FFFFFF", 0.5)
	oC.Flush()

	# NAMED ON THE HONEST PANEL ONLY. The Mercator one exists to show a
	# distortion and names would bury it; and a bloc map names its MEMBERS,
	# which is what the map is about -- the label engine does that on its
	# own once groups are set. :Names, so a country too small for its name
	# at this scale simply goes unnamed rather than collecting a number and
	# a key: on a world sheet of eighteen members a key of numbers is worse
	# than the eight names it would save.
	if m = 2
		oM.SetLabelMode(:Auto)
		oM.SetKeyBox(1075, nY0 + 8, 1265, nY0 + 330)
		oM.SetKeyTitle("too small to name at this scale")
		oM.DrawLabelsOn(oC, oFont, 13, "#FFFFFF")
		oM.DrawKeyOn(oC, oFont, 13, "#555555")
		aR = oM.LabelReport()
		nNamed = aR[:named]
		nKeyed = aR[:numbered]
		nUnnamed = aR[:dropped]
	ok

	oC.SetFontQ(oFont, 17).AddTextQ(aSheet[m][2], 60, nY0 - 30).Fill("#111111")
	oC.Flush()
	oC.SetFontQ(oFont, 13).AddTextQ(aSheet[m][3], 60, nY0 - 12).Fill("#888888")
	oC.Flush()
	aReport + oM.Findings()
next

# ---- WHAT THE PAINTED AREA ACTUALLY IS, measured on the sphere ----------
nG7 = 0
nBr = 0
for i = 1 to len(aG7)     nG7 += oW.AreaKm2Of(oW.IndexOfName(aG7[i]))     next
for i = 1 to len(aBrics)  nBr += oW.AreaKm2Of(oW.IndexOfName(aBrics[i]))  next
nLand = oW.AreaKm2()

# EVERY SIZE FLUSHED BEFORE THE NEXT ONE IS SET -- the canvas applies the
# last SetFont to anything still unflushed, so a 16 and a 13 written back to
# back both come out at 13. The title of this sheet showed it first.
nY = 972
oC.AddRectQ(60, nY - 46, 26, 20).FillQ(cBlue).Stroke("#FFFFFF", 0.8)
oC.AddRectQ(430, nY - 46, 26, 20).FillQ(cRed).Stroke("#FFFFFF", 0.8)
oC.Flush()
oC.SetFontQ(oFont, 16).AddTextQ("G7 -- " + len(aG7) + " members", 96, nY - 30).Fill("#111111")
oC.SetFontQ(oFont, 16).AddTextQ("BRICS -- " + len(aBrics) + " members", 466, nY - 30).Fill("#111111")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ(StzFactNumText(nG7 / 1000000) + " million km2, " +
	StzFactNumText(nG7 * 100 / nLand) + "% of the land", 96, nY - 12).Fill("#666666")
oC.SetFontQ(oFont, 13).AddTextQ(StzFactNumText(nBr / 1000000) + " million km2, " +
	StzFactNumText(nBr * 100 / nLand) + "% of the land", 466, nY - 12).Fill("#666666")
oC.SetFontQ(oFont, 13).AddTextQ("Areas measured on the SPHERE from the countries' own " +
	"outlines, so they are", 820, nY - 30).Fill("#666666")
oC.SetFontQ(oFont, 13).AddTextQ("the same in both panels. Only what the eye is told changes.",
	820, nY - 12).Fill("#666666")
oC.Flush()

oC.SetFontQ(oFont, 13).AddTextQ("On the lower panel " + nNamed + " members carry their " +
	"name, " + nKeyed + " carry a number into the key beside it, " + nUnnamed + " fit neither.   " +
	"Natural Earth 1:110m via world-atlas, fetched not vendored.", 60, nY + 18).Fill("#888888")
oC.Flush()
oC.ToPNG("geo_blocs.png")

? "G7    " + len(aG7) + " members, " + StzFactNumText(nG7 / 1000000) + " M km2 (" +
	StzFactNumText(nG7 * 100 / nLand) + "% of land)"
? "BRICS " + len(aBrics) + " members, " + StzFactNumText(nBr / 1000000) + " M km2 (" +
	StzFactNumText(nBr * 100 / nLand) + "% of land)"
? "   BRICS covers " + StzFactNumText(nBr / nG7) + " times the ground the G7 does"
for i = 1 to 2
	? "   panel " + i + " (" + aSheet[i][2] + "):"
	if len(aReport[i]) = 0
		? "      nothing"
	else
		for g in aReport[i]  ? "      " + g[:severity] + " " + g[:rule]  next
	ok
next
? "   Equal Earth panel: " + nNamed + " named, " + nKeyed + " numbered into the key, " + nUnnamed + " neither"
? "-> geo_blocs.png"
