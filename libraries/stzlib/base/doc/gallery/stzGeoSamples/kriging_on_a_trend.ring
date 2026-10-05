# stzGeoSamples: when kriging goes wrong without an error. 60 invented gauges whose value falls steadily to the
# north (a trend, not a stationary field): :Best fits a Gaussian model whose range is longer than the data,
# and KrigeFields answers numbers far outside what any gauge measured. Left, the good case of the other
# sheets (classes 300-700 mm); right, the trend. Cells outside the classes draw as no data.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoSamples/kriging_on_a_trend.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))
oWin = StzGeoPoints([], oN)
aA = oWin.Sample(80, 11)
aB = oWin.Sample(60, 11)
aG = []
for i = 1 to 80
	aG + aA[i * 2 - 1]
	aG + aA[i * 2]
	aG + (500 + 150 * sin(aA[i * 2] * 0.9) * cos(aA[i * 2 - 1] * 0.7) + ((i * 37) % 23))
next
aT = []
for i = 1 to 60
	aT + aB[i * 2 - 1]
	aT + aB[i * 2]
	aT + (800 - 55 * (aB[i * 2] - 11.7) + ((i * 37) % 23))
next
oGood = new stzGeoSamples(aG, oN)
oTrend = new stzGeoSamples(aT, oN)
oGood.FitAndUse(:Best)
oTrend.FitAndUse(:Best)
aKg = oGood.KrigeFields(25)
aKt = oTrend.KrigeFields(25)
? "good: measured " + oGood.MinValue() + " to " + oGood.MaxValue() + ", kriged " + @@( aKg[1].Stats() ) + " model " + @@( oGood.Model() )
? "trend: measured " + oTrend.MinValue() + " to " + oTrend.MaxValue() + ", kriged " + @@( aKt[1].Stats() ) + " model " + @@( oTrend.Model() )
? "trend gate: " + @@( oTrend.Findings() ) + " IsSound " + oTrend.IsSound()
aKg[1].SetClasses([ 300, 400, 450, 500, 550, 600, 700 ])
aKg[1].SetRamp(:Blues)
aKt[1].SetClasses([ 300, 400, 450, 500, 550, 600, 700 ])
aKt[1].SetRamp(:Blues)
oF1 = aKg[1]
oF2 = aKt[1]

oC = new stzCanvas(900, 500)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Kriging on a trend: the numbers leave the measured range", 20, 32).Fill("#111111")
oC.Flush()
for m = 1 to 2
	nX0 = 10 + (m - 1) * 450
	oP = StzGeoConicFor(oN, :ConicEqualArea)
	oP.FitFeaturesIn(oN, nX0 + 10, 90, nX0 + 430, 330, 4)
	if m = 1
		oF1.DrawOn(oC, oP, nX0 + 10, 90, nX0 + 430, 330)
		oC.SetFontQ(oBold, 15).AddTextQ("stationary data: measured 362-664, kriged " + floor(aKg[1].Min()) + " to " + floor(aKg[1].Max()), nX0 + 10, 76).Fill("#111111")
	else
		oF2.DrawOn(oC, oP, nX0 + 10, 90, nX0 + 430, 330)
		oC.SetFontQ(oBold, 15).AddTextQ("trend: measured " + floor(oTrend.MinValue()) + "-" + floor(oTrend.MaxValue()) + ", kriged " + floor(aKt[1].Min()) + " to " + floor(aKt[1].Max()), nX0 + 10, 76).Fill("#C0392B")
	ok
	oC.Flush()
	oP.DrawFeaturesOn(oC, oN, "#00000000", "#999999", 0.6)
next
oC.SetFontQ(oFont, 13).AddTextQ("White inside the country = a kriged value outside 300-700 (no class). Findings() warned about the range only; IsSound() says TRUE.", 20, 360).Fill("#555555")
oC.Flush()
oF1.DrawLegendOn(oC, oFont, 20, 385, "")
chdir("../../doc/gallery/stzGeoSamples")
oC.ToPNGXT("kriging_on_a_trend.png", 9)
? "-> kriging_on_a_trend.png"
