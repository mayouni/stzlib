load "../../stzBase.ring"
decimals(2)

# GE9 -- THE GALLERY, AND WHAT EACH ONE COSTS.
#
# Forty-four ways to flatten a sphere, each drawn with Tissot's indicatrix
# over it: circles of equal size on the ground, which the projection turns
# into whatever it turns them into.
#
# READING THE CIRCLES IS THE WHOLE POINT. On an EQUAL-AREA projection every
# blob has the same area and they are squashed into ellipses -- the shapes
# are wrong and the sizes are right. On a CONFORMAL one every blob is a
# circle and they swell enormously toward the poles -- the shapes are right
# and the sizes are wrong. On a COMPROMISE neither holds and neither fails
# badly, which is what a compromise is.
#
# The two numbers under each panel are the measured cost: the mean areal
# scale and the mean angular deformation, both averaged over the globe by
# GROUND rather than by grid cell.

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aK = StzGeoProjectionKinds()

nCols = 6
nCell = 208
nPadX = 14
nPadY = 74
nRows = ceil(len(aK) / nCols)

oC = new stzCanvas(nCols * (nCell + nPadX) + 40, nRows * (nCell / 2 + nPadY) + 150)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 26).AddTextQ("Forty-four ways to flatten a sphere", 40, 50).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("each with Tissot's indicatrix over it -- circles of " +
	"equal size on the ground, and whatever the projection makes of them", 40, 74).Fill("#777777")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("blue: equal-area (right sizes, wrong shapes)     " +
	"red: conformal (right shapes, wrong sizes)     grey: a compromise, neither and both",
	40, 98).Fill("#888888")
oC.Flush()

nY0 = 130
for i = 1 to len(aK)
	nCol = ((i - 1) % nCols)
	nRow = floor((i - 1) / nCols)
	nX = 40 + nCol * (nCell + nPadX)
	nY = nY0 + nRow * (nCell / 2 + nPadY)

	oP = new stzGeoProjection(aK[i])
	oP.FitToSphere(nCell, nCell / 2, 2)
	oP.Translate([ nX + nCell / 2, nY + nCell / 4 ])

	cInk = "#9A9A9A"
	if oP.IsEqualArea()  cInk = "#3E6FAF"  ok
	if oP.IsConformal()  cInk = "#C0392B"  ok

	# the graticule and the world's edge, so the shape of the projection reads
	oP.DrawGraticuleOn(oC, 30, "#E4E4E4", 0.6)
	oP.DrawOutlineOn(oC, "#C8C8C8", 0.9)
	oC.Flush()

	# THE INDICATRIX, at every 60 degrees of longitude and 30 of latitude.
	# Drawn as the PROJECTED IMAGE of a small circle rather than as the
	# ellipse the numbers describe -- so a reader sees the bending an
	# ellipse cannot represent.
	for nLat = -60 to 60 step 30
		for nLon = -150 to 150 step 60
			aR = oP.IndicatrixAt(nLon, nLat, 9)
			if len(aR) >= 16
				oC.AddPolygonQ(aR).FillQ(cInk + "55").Stroke(cInk, 0.7)
			ok
		next
	next
	oC.Flush()

	aD = oP.DistortionXT(36, 18)
	oC.SetFontQ(oFont, 12).AddTextQ(aK[i], nX, nY - 10).Fill("#1A1A1A")
	oC.Flush()
	cNote = "area x" + StzFactNumText(aD[:arealMean]) + "   bend " +
	        StzFactNumText(aD[:angularMean]) + " deg"
	oC.SetFontQ(oFont, 10).AddTextQ(cNote, nX, nY + nCell / 2 + 16).Fill("#999999")
	oC.Flush()
next

oC.ToPNG("geo_gallery.png")

? "-- the gallery, by what it costs --"
aRow = []
for i = 1 to len(aK)
	oP = new stzGeoProjection(aK[i])
	aD = oP.DistortionXT(36, 18)
	cWhat = "compromise"
	if oP.IsEqualArea()  cWhat = "equal-area"  ok
	if oP.IsConformal()  cWhat = "conformal"  ok
	aRow + [ aD[:angularMean], aK[i], cWhat, aD[:arealMean], aD[:arealMax] ]
next
for a = 1 to len(aRow) - 1
	for b = 1 to len(aRow) - a
		if aRow[b][1] > aRow[b + 1][1]
			t = aRow[b]  aRow[b] = aRow[b + 1]  aRow[b + 1] = t
		ok
	next
next
? "  the five that bend angles LEAST:"
for i = 1 to 5
	? "    " + aRow[i][2] + " (" + aRow[i][3] + "): bend " + aRow[i][1] +
	  " deg, area mean x" + aRow[i][4] + ", worst x" + aRow[i][5]
next
? "  the five that bend them MOST:"
for i = len(aRow) - 4 to len(aRow)
	? "    " + aRow[i][2] + " (" + aRow[i][3] + "): bend " + aRow[i][1] +
	  " deg, area mean x" + aRow[i][4] + ", worst x" + aRow[i][5]
next
? ""
? "  every conformal projection bends exactly 0 degrees, everywhere, and"
? "  pays for it in area; every equal-area one holds area exactly and pays"
? "  in bent angles. There is no row with small numbers in both columns,"
? "  and there cannot be: that is Gauss's theorem, not a gap in the list."
? "-> geo_gallery.png"
