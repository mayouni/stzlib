# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzHistogram/terminal.ring > ../../doc/gallery/stzHistogram/terminal.txt
# The terminal picture of the same 200 values as normal.png, with the percentage above each bar.
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
oHist = new stzHistogram(aData)
oHist.AddPercent()
? oHist.ToString()
