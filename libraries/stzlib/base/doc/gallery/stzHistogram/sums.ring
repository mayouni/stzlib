# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzHistogram/sums.ring
# UseSum: each bar shows the sum of the values in its bin instead of how many there are.
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
oHist.UseSum()
oHist.ToPNG("../../doc/gallery/stzHistogram/sums.png",
	[ :Font = oFont, :Title = "Sum of the values in each bin", :Width = 800, :Height = 460 ])
? "done"
