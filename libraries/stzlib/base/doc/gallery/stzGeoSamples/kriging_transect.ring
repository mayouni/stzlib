# stzGeoSamples: the same 80 invented gauges, ordinary kriging with the exponential model (FitAndUse): the
# estimate with isohyets (KrigeFields, DrawContoursOn) and, along a west-east line at 15 N, the estimate and
# its doubt (KrigeAt answers [ estimate, variance ]; the band is the estimate plus and minus two standard errors).
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoSamples/kriging_transect.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
aXY = oWin.Sample(80, 11)
aS = []
for i = 1 to 80
	aS + aXY[i * 2 - 1]
	aS + aXY[i * 2]
	aS + (500 + 150 * sin(aXY[i * 2] * 0.9) * cos(aXY[i * 2 - 1] * 0.7) + ((i * 37) % 23))
next
oS = new stzGeoSamples(aS, oN)
oS.FitAndUse(:Exponential)
? "model " + @@( oS.Model() ) + " cross-validation " + @@( oS.CrossValidate() ) + " gate " + @@( oS.Findings() )
aK = oS.KrigeFields(20)
oE = aK[1]
oE.SetClasses([ 300, 400, 450, 500, 550, 600, 700 ])
oE.SetRamp(:Blues)
aLev = [ 450, 500, 550, 600 ]

oC = new stzCanvas(1000, 500)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Kriging: the estimate, its isohyets, and its doubt along a line", 20, 32).Fill("#111111")
oC.Flush()
oP = StzGeoConicFor(oN, :ConicEqualArea)
oP.FitFeaturesIn(oN, 20, 70, 440, 350, 4)
oE.DrawOn(oC, oP, 20, 70, 440, 350)
oP.DrawFeaturesOn(oC, oN, "#00000000", "#FFFFFF", 0.6)
oE.DrawContoursOn(oC, oP, aLev, "#111111", 1)
aLine = []
for nLon = 0.5 to 15.5 step 0.5
	aLine + nLon
	aLine + 15
next
oP.DrawLineOn(oC, aLine, "#C0392B", 2)
oC.SetFontQ(oBold, 15).AddTextQ("estimate and isohyets; the red line is the transect at 15 N", 20, 62).Fill("#111111")
oC.Flush()
oE.DrawLegendOn(oC, oFont, 20, 372, "")

nBx = 520
nBy = 70
nBw = 450
nBh = 240
oC.AddRectQ(nBx, nBy, nBw, nBh).FillQ("#FFFFFF").Stroke("#999999", 1)
aTop = []
aBot = []
aMid = []
for nLon = 0.5 to 15.5 step 0.5
	aKr = oS.KrigeAt(nLon, 15)
	nSe = sqrt(aKr[2])
	x = nBx + (nLon - 0.5) / 15 * nBw
	aTop + x
	aTop + (nBy + nBh - (aKr[1] + 2 * nSe - 200) / 600 * nBh)
	aMid + x
	aMid + (nBy + nBh - (aKr[1] - 200) / 600 * nBh)
	aBot + (nBy + nBh - (aKr[1] - 2 * nSe - 200) / 600 * nBh)
next
# the band as one polygon: along the top, back along the bottom
aBand = aTop
for i = len(aBot) to 1 step -1
	aBand + aTop[i * 2 - 1]
	aBand + aBot[i]
next
oC.AddPolygonQ(aBand).FillQ("#2E86C144").Stroke("#2E86C1", 0.8)
oC.AddPolylineQ(aMid).Stroke("#1B4F72", 2.4)
oC.SetFontQ(oBold, 15).AddTextQ("along 15 N: estimate and plus/minus two standard errors", nBx, 62).Fill("#111111")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("0.5 to 15.5 E; 200 to 800 mm (invented). Gauges pinch the band.", nBx, nBy + nBh + 22).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoSamples")
oC.ToPNGXT("kriging_transect.png", 9)
? "-> kriging_transect.png"
