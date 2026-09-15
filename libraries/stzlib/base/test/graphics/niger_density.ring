load "../../stzBase.ring"
decimals(2)

# WHERE NIGER LIVES -- a single analytical map, from real data.
#
# Boundaries:  geoBoundaries gbHumanitarian ADM1 (UN OCHA / IGN Niger), ODbL.
# Population:  Recensement General 2012 (RGPH 2012), Institut National de la
#             Statistique du Niger -- the official census, by region.
# Areas:      MEASURED HERE, by Softanza's own GE8 geodesic routine on the
#             WGS84 ellipsoid -- so the density is the library's own number,
#             not a figure copied from a table.
#
# The story is one number against another: Agadez is more than half of
# Niger's territory and holds under three per cent of its people. The
# Sahara empties toward the north; the Sahel fills toward the south.

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")

# --- the data ------------------------------------------------------------
# official RGPH 2012 population by region (INS-Niger)
aPop = [ [ "Agadez", 487620 ], [ "Diffa", 593821 ], [ "Dosso", 2037713 ],
         [ "Maradi", 3402094 ], [ "Niamey", 1026848 ], [ "Tahoua", 3328365 ],
         [ "Tillaberi", 2722482 ], [ "Zinder", 3539764 ] ]

oW = StzGeoFeaturesFromJson(read("niger_adm1.geojson"))
nN = oW.Count()

# density per region, area from OUR geodesic engine
aDens = []
aPopV = []
aArea = []
nTotP = 0
nTotA = 0
for i = 1 to nN
	cN = oW.NameOf(i)
	nA = oW.AreaKm2Of(i)
	nP = 0
	for k = 1 to len(aPop)
		if StzLower(aPop[k][1]) = StzLower(cN)  nP = aPop[k][2]  ok
	next
	aArea + nA
	aPopV + nP
	aDens + (nP / nA)
	nTotP += nP
	nTotA += nA
next

# --- the map -------------------------------------------------------------
nW = 1500
nH = 1180
oC = new stzCanvas(nW, nH)
oC.SetBackground("#FBF7F0")

# title block
oC.SetFontQ(oBold, 40).AddTextQ("Where Niger lives", 60, 74).Fill("#1A1206")
oC.Flush()
oC.SetFontQ(oFont, 19).AddTextQ("Population density by region, 2012 -- the Sahara empties " +
	"to the north, the Sahel fills to the south", 62, 106).Fill("#8A7A5E")
oC.Flush()

# the choropleth
nY0 = 150
oP = new stzGeoProjection(:ConicEqualArea)
oP.FitFeaturesIn(oW, 60, nY0, 1080, nY0 + 900, 20)
oM = StzGeoMap(oP, oW)
oM.SetPaper(50, nY0 - 10, 1090, nY0 + 910)
oM.SetSource("RGPH 2012 (INS Niger); boundaries geoBoundaries/UN; areas by Softanza GE8")
oM.SetValuesQ(aDens)
# density classes, people per km2, with an open top for the capital city
oM.SetClassesQ([ 0, 2, 10, 50, 100 ])
oM.SetOpenTop(TRUE)
oM.SetRamp(:YlOrRd)
oM.DrawSheetOn(oC, "#5A3A1E", 0.9)

# --- region labels: name + density, placed by the engine ----------------
for i = 1 to nN
	cN = oW.NameOf(i)
	if StzLower(cN) = "niamey"  loop  ok      # the capital gets its own callout
	g = oM.LabelPointOf(i)
	q = oP.Project(g[1], g[2])
	if len(q) < 2  loop  ok
	oM.DrawHaloTextOn(oC, oBold, 17, cN, q[1] - oBold.WidthOf(cN, 17) / 2, q[2] - 3,
		"#2A1C0A", "#FFFFFFDD", 1.7)
	cD = StzFactNumText(aDens[i]) + " /km" + "²"
	oM.DrawHaloTextOn(oC, oFont, 13, cD, q[1] - oFont.WidthOf(cD, 13) / 2, q[2] + 15,
		"#5A4A2E", "#FFFFFFDD", 1.5)
next

# --- Niamey: the capital, off the scale ---------------------------------
# No leader line: the dot is labelled in place with its name only, and the
# fact about it is set under the map rather than pointed at with a line.
nNiamey = oW.IndexOfName("Niamey")
if nNiamey > 0
	g = oM.LabelPointOf(nNiamey)
	q = oP.Project(g[1], g[2])
	if len(q) = 2
		oC.AddCircleQ(q[1], q[2], 6).FillQ("#7A1010").Stroke("#FFFFFF", 2)
		oC.AddCircleQ(q[1], q[2], 2.4).FillQ("#FFFFFF").Stroke("#00000000", 0)
		oC.Flush()
		oM.DrawHaloTextOn(oC, oBold, 15, "Niamey",
			q[1] - oBold.WidthOf("Niamey", 15) / 2, q[2] + 18, "#2A1C0A", "#FFFFFFDD", 1.7)
	ok
ok

# the capital's fact, set under the map -- no line pointing at it
cNiaLbl = "Niamey, the capital -- "
oC.SetFontQ(oBold, 15).AddTextQ(cNiaLbl, 62, 1096).Fill("#2A1C0A")
oC.Flush()
oC.SetFontQ(oFont, 15).AddTextQ("1,844 people per km" + "²" + ", off the scale of the ramp",
	62 + oBold.WidthOf(cNiaLbl, 15), 1096).Fill("#7A1010")
oC.Flush()

# --- the legend ----------------------------------------------------------
nLegX = 1150
nLegY = 300
oC.SetFontQ(oBold, 16).AddTextQ("people per km" + "²", nLegX, nLegY - 14).Fill("#1A1206")
oC.Flush()
oM.DrawRampLegendOn(oC, oFont, 13, nLegX, nLegY + 30, 250, 26, "#5A3A1E")

# --- the analytical callout: the headline fact --------------------------
nCardY = 470
oC.AddRoundRectQ(nLegX, nCardY, 300, 250, 12).FillQ("#FFFFFF").Stroke("#E6DAC4", 1.5)
oC.Flush()
oC.SetFontQ(oBold, 60).AddTextQ("52%", nLegX + 22, nCardY + 74).Fill("#BD3A0A")
oC.Flush()
oC.SetFontQ(oFont, 15).AddTextQ("of Niger's land is Agadez", nLegX + 24, nCardY + 104).Fill("#5A4A2E")
oC.Flush()
oC.SetFontQ(oBold, 60).AddTextQ("2.8%", nLegX + 22, nCardY + 184).Fill("#7A5A1E")
oC.Flush()
oC.SetFontQ(oFont, 15).AddTextQ("of its people live there", nLegX + 24, nCardY + 214).Fill("#5A4A2E")
oC.Flush()

# --- total, and the source line -----------------------------------------
oC.SetFontQ(oBold, 15).AddTextQ("17.1 million people", nLegX, nCardY + 300).Fill("#5A4A2E")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("in 8 regions -- 2012 census", nLegX, nCardY + 322).Fill("#8A7A5E")
oC.Flush()

oC.SetFontQ(oFont, 12).AddTextQ("Boundaries: geoBoundaries gbHumanitarian (UN OCHA / IGN " +
	"Niger), ODbL.   Population: RGPH 2012, Institut National de la Statistique du Niger.",
	62, nH - 44).Fill("#A89A80")
oC.Flush()
oC.SetFontQ(oFont, 12).AddTextQ("Region areas measured on the WGS84 ellipsoid by Softanza's " +
	"GE8 geodesic engine (from the generalised boundary) -- the density is the library's own number.",
	62, nH - 26).Fill("#A89A80")
oC.Flush()

# the small maker's mark
oC.SetFontQ(oBold, 13).AddTextQ("made with Softanza", nW - 190, nH - 26).Fill("#BD3A0A")
oC.Flush()

oC.ToPNGHiRes("niger_density.png")

? "-- Where Niger lives --"
for i = 1 to nN
	? "  " + oW.NameOf(i) + ": " + StzFactNumText(aDens[i]) + " /km2 (" +
	  StzFactNumText(aPopV[i]) + " people, " + StzFactNumText(floor(aArea[i])) + " km2)"
next
? "  Agadez is " + StzFactNumText(aArea[1] / nTotA * 100) + "% of the land, " +
  StzFactNumText(aPopV[1] / nTotP * 100) + "% of the people"
? "-> niger_density.png"
