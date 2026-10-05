# stzGeoMap: invented places in Niger counted per region (CountPointsIn), binned into hexagons (HexBin),
# marked by proportional circles (DrawSymbolsOn) and joined to Niamey by great circles (DrawFlowsOn).
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoMap/hexbin_flows.ring
load "../../stzBase.ring"
decimals(2)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
aPts = oWin.SampleClustered(7, 60, 45, 20261005)

oC = new stzCanvas(1000, 560)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 24).AddTextQ("Invented places in Niger, three ways", 30, 38).Fill("#111111")
oC.Flush()
nW = 3
for m = 1 to nW
	nX0 = 20 + (m - 1) * 325
	oP = StzGeoConicFor(oN, :ConicEqualArea)
	oP.FitFeaturesIn(oN, nX0 + 10, 90, nX0 + 300, 400, 6)
	oM = StzGeoMap(oP, oN)
	oM.SetPaper(nX0, 70, nX0 + 310, 410)
	oM.SetSource("geoBoundaries ADM1; the places are INVENTED")
	oM.DrawRegionsOn(oC, "#FFFFFF", 0.6)
	if m = 1
		aBins = oM.HexBin(aPts, 9)
		nMax = oM.HexBinMax(aBins)
		oM.DrawHexBinsOn(oC, aBins, 9, [ 1, 2, 4, 8, nMax + 1 ], [ "#FFFFB2", "#FECC5C", "#FD8D3C", "#E31A1C" ], "#FFFFFF")
		oC.SetFontQ(oFont, 15).AddTextQ("hexagon bins, max " + nMax + " places", nX0 + 10, 440).Fill("#333333")
		oC.Flush()
	but m = 2
		aCount = oM.CountPointsIn(aPts)
		oM.DrawSymbolsOn(oC, aCount, 26, "#2E86C188", "#1B4F72")
		oC.SetFontQ(oFont, 15).AddTextQ("circles by count in each region", nX0 + 10, 440).Fill("#333333")
		oC.Flush()
	else
		oM.DrawFlowsOn(oC, [ [ 2.1254, 13.5116, 12.6, 13.3 ], [ 2.1254, 13.5116, 8.0, 17.0 ], [ 2.1254, 13.5116, 9.0, 13.0, 3 ] ], "#C0392B", 1.5)
		oM.DrawSymbolAt(oC, 2.1254, 13.5116, 5, "#C0392B", "#FFFFFF")
		oC.SetFontQ(oFont, 15).AddTextQ("great circles from Niamey", nX0 + 10, 440).Fill("#333333")
		oC.Flush()
	ok
next
oM.DrawCaptionOn(oC, oFont, 30, 520)
? "outside: " + oM.PointsOutside(aPts) + ", points " + len(aPts) / 2
chdir("../../doc/gallery/stzGeoMap")
oC.ToPNG("hexbin_flows.png")
? "-> hexbin_flows.png"
