# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzHistogram/bins20.ring
# The same 200 values cut into 20 bins with SetBinCount, to see finer bars and crowded labels.
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
oHist.SetBinCount(20)
oHist.ToPNG("../../doc/gallery/stzHistogram/bins20.png",
	[ :Font = oFont, :Title = "200 measurements, 20 bins", :Width = 900, :Height = 460 ])
? "done"
