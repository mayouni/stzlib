# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzHistogram/normal.ring
# 200 values from a bell-shaped sample (mean 100, spread 12; a fixed seed so it can be repeated),
# binned by the default rule (Sturges: 9 bins), counts written above the bars.
load "../../stzBase.ring"

nSeed = 42
aData = []
for i = 1 to 200
	nSum = 0
	for k = 1 to 12
		nSeed = (nSeed * 16807) % 2147483647
		nSum += nSeed / 2147483647
	next
	aData + (floor(((nSum - 6) * 12 + 100) * 10 + 0.5) / 10)
next

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oHist = new stzHistogram(aData)
? "mean " + oHist.Mean() + " sd " + oHist.StandardDeviation() + " n " + oHist.DataCount()
oHist.ToPNG("../../doc/gallery/stzHistogram/normal.png",
	[ :Font = oFont, :Title = "200 measurements, default bins", :Width = 800, :Height = 460 ])
? "done"
