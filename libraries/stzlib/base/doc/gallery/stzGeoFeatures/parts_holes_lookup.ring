# stzGeoFeatures: what a boundary file holds -- parts and holes (the two invented fixture countries, one with a
# lake, one with an island), a point-in-region raster (IndexAt over a grid of Niger), and a real enclave
# (Lesotho is a hole of South Africa: HoleCountOf, PartContains).
# Needs the world atlas for the third panel (test/graphics/atlas/README.md); STZ_ATLAS names its folder.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoFeatures/parts_holes_lookup.ring
load "../../stzBase.ring"
decimals(2)
cAtlas = sysget("STZ_ATLAS")
if cAtlas = ""  cAtlas = "../graphics/atlas/"  ok
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oFx = StzGeoFeaturesFromJson(read("../graphics/fixtures/two_countries.geojson"))
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))

oC = new stzCanvas(1000, 420)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Inside a boundary file: parts, holes and 'which region is here'", 20, 32).Fill("#111111")
oC.Flush()

# 1. the fixtures: every part, every ring; the hole of Arda stays white, the island of Berea is its part 2
oP = new stzGeoProjection(:Equirectangular)
oP.FitFeaturesIn(oFx, 20, 100, 320, 330, 8)
aInk = [ "#2E86C1", "#C0392B" ]
for i = 1 to oFx.Count()
	oP.DrawFeatureOn(oC, oFx, i, aInk[i] + "AA", aInk[i], 1.2)
	oC.SetFontQ(oBold, 13).AddTextQ(oFx.NameOf(i) + ": " + oFx.PartCount(i) + " part(s), " + oFx.HoleCountOf(i) + " hole(s)", 20, 52 + i * 15).Fill(aInk[i])
	oC.Flush()
next
aT = [ [ 2.5, 4.5 ], [ 8, 5 ], [ 14.2, 5 ] ]
for k = 1 to len(aT)
	q = oP.Project(aT[k][1], aT[k][2])
	i = oFx.IndexAt(aT[k][1], aT[k][2])
	oC.AddCircleQ(q[1], q[2], 4).FillQ("#111111")
	oC.SetFontQ(oFont, 12).AddTextQ("" + i, q[1] + 6, q[2] - 5).Fill("#111111")
	oC.Flush()
next
oC.SetFontQ(oFont, 13).AddTextQ("fixtures: the number by a dot is IndexAt, 0 in the hole", 20, 352).Fill("#555555")
oC.Flush()

# 2. IndexAt over a grid of Niger: each dot takes the colour of the region it falls in
oP2 = StzGeoConicFor(oN, :ConicEqualArea)
oP2.FitFeaturesIn(oN, 340, 70, 640, 330, 6)
aCol = [ "#E74C3C", "#F39C12", "#27AE60", "#2980B9", "#8E44AD", "#16A085", "#D35400", "#2C3E50" ]
nIn = 0
nOut = 0
for nLat = 11.5 to 23.6 step 0.4
	for nLon = 0 to 16.1 step 0.4
		i = oN.IndexAt(nLon, nLat)
		q = oP2.Project(nLon, nLat)
		if i > 0
			oC.AddCircleQ(q[1], q[2], 2.1).FillQ(aCol[i])
			nIn++
		else
			nOut++
		ok
	next
next
oC.SetFontQ(oFont, 13).AddTextQ("IndexAt over a grid: " + nIn + " in, " + nOut + " out", 340, 352).Fill("#555555")
oC.Flush()

# 3. South Africa and its hole
if fexists(cAtlas + "countries-110m.json")
	oW = StzGeoFeaturesFromTopoJson(read(cAtlas + "countries-110m.json"), "countries")
	iSA = oW.IndexOfName("South Africa")
	iLs = oW.IndexOfName("Lesotho")
	oP3 = new stzGeoProjection(:Equirectangular)
	oP3.FitFeatureIn(oW, iSA, 670, 70, 980, 330, 6)
	oP3.DrawFeatureOn(oC, oW, iSA, "#F5CBA7", "#A04000", 1.2)
	oP3.DrawFeatureOn(oC, oW, iLs, "#D5F5E3", "#1E8449", 1.2)
	q = oP3.Project(28.2, -29.5)
	oC.SetFontQ(oFont, 13).AddTextQ("South Africa has " + oW.HoleCountOf(iSA) + " hole: " + oW.NameOf(oW.IndexAt(28.2, -29.5)), 670, 352).Fill("#555555")
	oC.Flush()
	? "South Africa holes " + oW.HoleCountOf(iSA) + ", parts " + oW.PartCount(iSA) + ", point in Lesotho is in feature " + oW.NameOf(oW.IndexAt(28.2, -29.5)) + ", PartContains(SA) " + oW.PartContains(iSA, 1, 28.2, -29.5)
else
	? "SKIPPED, by name: third panel, " + cAtlas + "countries-110m.json is not present."
ok
chdir("../../doc/gallery/stzGeoFeatures")
oC.ToPNGXT("parts_holes_lookup.png", 9)
? "-> parts_holes_lookup.png"
