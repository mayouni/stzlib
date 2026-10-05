# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzScatterPlot/terminal.ring > ../../doc/gallery/stzScatterPlot/terminal.txt
# The terminal picture of the same two clusters as clusters.png.
load "../../stzBase.ring"

nSeed = 7
aPts = []
for c = 1 to 2
	nCx = 20 + (c - 1) * 40
	nCy = 30 + (c - 1) * 40
	for i = 1 to 40
		nSx = 0
		nSy = 0
		for k = 1 to 6
			nSeed = (nSeed * 16807) % 2147483647
			nSx += nSeed / 2147483647
			nSeed = (nSeed * 16807) % 2147483647
			nSy += nSeed / 2147483647
		next
		aPts + [ floor((nCx + (nSx - 3) * 8) * 10 + 0.5) / 10, floor((nCy + (nSy - 3) * 8) * 10 + 0.5) / 10 ]
	next
next
oPlot = new stzScatterPlot(aPts)
? oPlot.ToString()
