# THE IMAGE PLANE'S GEOMETRY -- IM2, narrated, against the OpenCV oracle
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM2: warps, the matrices that drive them,
# contours, polygons, hulls, rotated rectangles -- and what they are for: a
# page photographed at an angle, found, flattened, and read by OCR.
#
# The warps reproduce OpenCV's own fixed point (1/32-pixel positions, exact
# 15-bit bilinear weights), so the target is PIXEL-EXACT, not "close". The
# contour tracer follows OpenCV's border following, so its points come in
# OpenCV's order. Every positive has a negative sibling.
#
#   Scene 1  matrices from points and from an angle
#   Scene 2  warps, pixel for pixel: rotation, affine, perspective
#   Scene 3  outer contours, corners only and every point
#   Scene 4  polygons: Douglas-Peucker, convex hull, minimum-area rectangle
#   Scene 5  the photographed page: found, flattened, read
#
# Points are [ x, y ], 1-based like every Ring face; OpenCV's are 0-based,
# so the guard adds 1 to each oracle point. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cOracle = "_oracle/"

pr()

oS = StzImageQ($cOracle + "in_shapes.png").ApplyGrayScaleQ()
nW = oS.Width()
nH = oS.Height()

#=====================================================================#
? "-- Scene 1: matrices --"
#=====================================================================#

aP = StzPerspectiveMatrix([ [ 1, 1 ], [ 96, 1 ], [ 96, 72 ], [ 1, 72 ] ],
	[ [ 9, 5 ], [ 89, 11 ], [ 93, 67 ], [ 3, 71 ] ])
chk("the perspective matrix from four points equals OpenCV's (0.000000001)", MatrixDiff(aP, "m_persp") < 0.000000001)
aA = StzAffineMatrix([ [ 1, 1 ], [ 96, 1 ], [ 1, 72 ] ], [ [ 11, 6 ], [ 81, 13 ], [ 5, 61 ] ])
chk("the affine matrix from three points equals OpenCV's", MatrixDiff(aA, "m_affine") < 0.000000001)
aR = StzRotationMatrix((nW + 1) / 2, (nH + 1) / 2, -17, 1)
chk("a turn of 17 degrees counter-clockwise (-17 clockwise) equals OpenCV's matrix",
	MatrixDiff(aR, "m_rot17") < 0.000000000001)
chk("...and +17 is another matrix (negative sibling)",
	MatrixDiff(StzRotationMatrix((nW + 1) / 2, (nH + 1) / 2, 17, 1), "m_rot17") > 0.1)
bRaised = 0
try
	StzPerspectiveMatrix([ [ 1, 1 ], [ 2, 2 ], [ 3, 3 ], [ 1, 5 ] ], [ [ 1, 1 ], [ 9, 1 ], [ 9, 9 ], [ 1, 9 ] ])
catch
	bRaised = 1
done
chk("three source points in a line are refused, not solved", bRaised = 1)

sec("scene 1")

#=====================================================================#
? "-- Scene 2: warps, pixel for pixel --"
#=====================================================================#

chk("a free rotation equals OpenCV's warpAffine, pixel for pixel", SameAs(oS.Rotated(-17), "warp_rot17", 0))
chk("an affine warp onto 90 x 70 equals OpenCV's", SameAs(oS.Warped(aA, 90, 70), "warp_affine", 0))
chk("a perspective warp equals OpenCV's warpPerspective", SameAs(oS.Warped(aP, nW, nH), "warp_persp", 0))
chk("...and the other direction is another picture (negative sibling)",
	oS.Rotated(17).DifferenceWith(oS.Rotated(-17))[:pixels] > 1000)
oT = StzImageQ($cOracle + "in_shapes.png").ApplyGrayScaleQ()
oT.ApplyRotation(-17)
chk("ApplyRotation changes the image to the same pixels", SameAs(oT, "warp_rot17", 0))
oT.Release()
chk("a multiple of 90 is still an exact quarter turn", Same(oS.Rotated(90).Size(), [ nH, nW ]))

sec("scene 2")

#=====================================================================#
? "-- Scene 3: outer contours --"
#=====================================================================#
# The shapes above 128: a speck, the rectangle, the ring (its hole is NOT
# an outer contour), the disk, the line, a second speck -- six outlines.

oB = StzImageQ($cOracle + "in_shapes.png").ApplyGrayScaleQ().ApplyThresholdQ(128)
aMine = oB.Contours()
aRef = Grouped(LoadCsv($cOracle + "contours_simple.csv"))
chk("as many outer contours as OpenCV finds (" + len(aRef) + ")", len(aMine) = len(aRef))
chk("...every one with OpenCV's corner points, in OpenCV's order", SameContours(aMine, aRef))
aAll = oB.ContoursXT(:all)
chk("every border point too (" + len(LoadCsv($cOracle + "contours_none.csv")) + " points)",
	SameContours(aAll, Grouped(LoadCsv($cOracle + "contours_none.csv"))))
chk("...and the corners are fewer than the points (negative sibling)", Count(aMine) < Count(aAll))

sec("scene 3")

#=====================================================================#
? "-- Scene 4: polygons --"
#=====================================================================#

aRect = ContourStartingAt(aAll, 7, 7)
aQ = StzApproxPolygon(aRect, 0.02 * StzPolygonPerimeter(aRect))
chk("the rectangle's outline simplifies to OpenCV's four corners", SameSet(aQ, Plus1(LoadCsv($cOracle + "approx_rect.csv"))))
aHull = StzConvexHull(LongestContourRight(aAll))
chk("the ring's convex hull has OpenCV's vertices", SameSet(aHull, Plus1(LoadCsv($cOracle + "hull_ring.csv"))))
aLine = Plus1(LoadCsv($cOracle + "line_points.csv"))
aMR = StzMinAreaRect(aLine)
aRefR = LoadCsv($cOracle + "minrect_line.csv")
chk("the line's minimum-area rectangle has OpenCV's area (" + aMR[:area] + ")", fabs(aMR[:area] - aRefR[5][1]) < 0.001)
chk("...and OpenCV's four corners", SameSetNear(aMR[:corners], Plus1([ aRefR[1], aRefR[2], aRefR[3], aRefR[4] ]), 0.001))
chk("...thinner than its upright box (negative sibling)",
	aMR[:area] < (Extent(aLine, 1) + 1) * (Extent(aLine, 2) + 1))

sec("scene 4")

#=====================================================================#
? "-- Scene 5: the photographed page --"
#=====================================================================#
# The oracle laid the page on a dark table in perspective, its corners at
# (141,121) (1001,191) (941,1301) (81,1221) in Ring's 1-based terms.
# PageCorners finds them from the pixels alone; FlattenedPage pulls them to
# a rectangle; OCR then reads what a skewed photo would not give it.

oPhoto = StzImageQ($cOracle + "in_photo.png").ApplyGrayScaleQ()
aC = oPhoto.PageCorners()
aTrue = [ [ 141, 121 ], [ 1001, 191 ], [ 941, 1301 ], [ 81, 1221 ] ]
nErr = CornerError(aC, aTrue)
chk("the page's four corners are found within 3 pixels (worst " + nErr + ")", len(aC) = 4 and nErr <= 3)
# the page's header band is 56 gray on a 40-gray table: a fixed tolerance of 24
# merged them and put the top corners 82 pixels low; the measured one keeps them apart
oM = oPhoto.ForegroundMask()
chk("...because the tolerance is measured from the table (" + oPhoto.ForegroundTolerance() + " levels, below the band's 16)",
	oPhoto.ForegroundTolerance() < 16)
oM.Release()
aBad = StzImageQ($cOracle + "in_photo.png").ApplyGrayScaleQ().ForegroundMaskXT(24).Contours()
chk("...and a fixed 24 would have lost the header band (negative sibling)", len(aBad) > 0 and
	CornerError(StzOrderedCorners(StzApproxPolygon(Largest(aBad), 0.02 * StzPolygonPerimeter(Largest(aBad)))), aTrue) > 40)
nT = clock()
oFlat = oPhoto.FlattenedPage()
nMs = (clock() - nT) * 1000 / clockspersecond()
? "    flattened to " + oFlat.Width() + " x " + oFlat.Height() + " in " + nMs + " ms"
# its size is the photo's longer edges: one photograph cannot give the page's
# true proportions (that needs the camera's focal length), so a known size is
# said with FlattenedPageXT -- here the page's own 800 x 1131
chk("the flattened size is the photo's longer edges (" + oFlat.Width() + " x " + oFlat.Height() + ")",
	fabs(oFlat.Width() - Longer(StzPointDistance(aC[1], aC[2]), StzPointDistance(aC[4], aC[3]))) <= 0.5 and
	fabs(oFlat.Height() - Longer(StzPointDistance(aC[1], aC[4]), StzPointDistance(aC[2], aC[3]))) <= 0.5)
oFlat.Release()
oFlat = oPhoto.FlattenedPageXT(800, 1131)
oTruth = StzImageQ($cOracle + "page_small.png").ApplyGrayScaleQ()
aD = oFlat.DifferenceWith(oTruth)
chk("...and it is the page again: mean difference " + aD[:mean] + " levels (< 6)", aD[:mean] < 6)
aD0 = oPhoto.ResizedXT(800, 1131, :area).DifferenceWith(oTruth)
chk("...where the unflattened photo is far off (negative sibling: " + aD0[:mean] + ")", aD0[:mean] > 3 * aD[:mean])
oFlat.SaveAs("_flat_page.png")
cRead = Joined(StzOcrModelLines("_flat_page.png"))
chk("OCR reads the flattened page's title: 'Ligne 12'", StzFindFirst("Ligne 12", cRead) > 0)
chk("...and its timetable: 'Gare routi'", StzFindFirst("Gare routi", cRead) > 0)
remove("_flat_page.png")
bRaised = 0
try
	StzImageNew(50, 40, 1, 30).FlattenedPage()
catch
	bRaised = 1
done
chk("an image with no page is refused, not flattened into nonsense", bRaised = 1)

sec("scene 5")

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pfq()
shutdown($nFail)

func SameAs(oMine, cName, nAllowed)
	oRef = StzImageQ($cOracle + cName + ".png").ApplyGrayScaleQ()
	aD = oMine.DifferenceWith(oRef)
	oRef.Release()
	if aD[:pixels] > nAllowed
		? "      " + cName + ": " + aD[:pixels] + " pixels differ (max " + aD[:max] + ")"
	ok
	return aD[:pixels] <= nAllowed

func MatrixDiff(aM, cName)
	aRef = LoadCsv($cOracle + cName + ".csv")
	n = 0
	for r = 1 to 3
		for c = 1 to 3
			d = fabs(aM[(r - 1) * 3 + c] - aRef[r][c])
			if d > n
				n = d
			ok
		next
	next
	return n

func LoadCsv(cPath)
	cText = read(cPath)
	aLines = StzSplit(cText, char(10))
	aOut = []
	n = len(aLines)
	for i = 1 to n
		cL = ring_trim(StzReplace(aLines[i], char(13), ""))
		if cL = ""
			loop
		ok
		aF = StzSplit(cL, ",")
		aNum = []
		m = len(aF)
		for j = 1 to m
			aNum + (0 + aF[j])
		next
		aOut + aNum
	next
	return aOut

# oracle rows [ k, x, y ] -> contours of 1-based points, in OpenCV's order
func Grouped(aRows)
	aOut = []
	n = len(aRows)
	for i = 1 to n
		k = aRows[i][1] + 1
		while len(aOut) < k
			aOut + []
		end
		aOut[k] + [ aRows[i][2] + 1, aRows[i][3] + 1 ]
	next
	return aOut

func Plus1(aPts)
	aOut = []
	n = len(aPts)
	for i = 1 to n
		aOut + [ aPts[i][1] + 1, aPts[i][2] + 1 ]
	next
	return aOut

# the same contours, matched by their first point, each with the same points in order
func SameContours(aMine, aRef)
	if len(aMine) != len(aRef)
		return 0
	ok
	n = len(aRef)
	for i = 1 to n
		bFound = 0
		for j = 1 to n
			if @@(aMine[j][1]) = @@(aRef[i][1])
				if @@(aMine[j]) = @@(aRef[i])
					bFound = 1
				else
					? "      contour from " + @@(aRef[i][1]) + ": " + len(aMine[j]) + " points vs " + len(aRef[i])
				ok
				exit
			ok
		next
		if bFound = 0
			return 0
		ok
	next
	return 1

func Count(aCs)
	n = 0
	m = len(aCs)
	for i = 1 to m
		n += len(aCs[i])
	next
	return n

func ContourStartingAt(aCs, x, y)
	n = len(aCs)
	for i = 1 to n
		if aCs[i][1][1] = x and aCs[i][1][2] = y
			return aCs[i]
		ok
	next
	return []

# the ring: the contour reaching farthest right among those starting in the top half
func LongestContourRight(aCs)
	nBest = 0
	k = 1
	n = len(aCs)
	for i = 1 to n
		if aCs[i][1][2] < 30 and len(aCs[i]) > nBest and aCs[i][1][1] > 40
			nBest = len(aCs[i])
			k = i
		ok
	next
	return aCs[k]

func SameSet(aA, aB)
	return SameSetNear(aA, aB, 0.000001)

func SameSetNear(aA, aB, nTol)
	if len(aA) != len(aB)
		? "      " + len(aA) + " points vs " + len(aB)
		return 0
	ok
	n = len(aB)
	for i = 1 to n
		bHit = 0
		for j = 1 to n
			if fabs(aA[j][1] - aB[i][1]) <= nTol and fabs(aA[j][2] - aB[i][2]) <= nTol
				bHit = 1
				exit
			ok
		next
		if bHit = 0
			? "      no point near " + @@(aB[i])
			return 0
		ok
	next
	return 1

func Extent(aPts, k)
	lo = aPts[1][k]
	hi = lo
	n = len(aPts)
	for i = 2 to n
		if aPts[i][k] < lo
			lo = aPts[i][k]
		ok
		if aPts[i][k] > hi
			hi = aPts[i][k]
		ok
	next
	return hi - lo

func Longer(a, b)
	if a > b
		return a
	ok
	return b

func Largest(aCs)
	k = 1
	nA = 0
	n = len(aCs)
	for i = 1 to n
		a = StzPolygonArea(aCs[i])
		if a > nA
			nA = a
			k = i
		ok
	next
	return aCs[k]

func CornerError(aC, aTrue)
	if len(aC) != 4
		return 1000000000
	ok
	n = 0
	for i = 1 to 4
		d = StzPointDistance(aC[i], aTrue[i])
		if d > n
			n = d
		ok
	next
	return n

func Joined(aLines)
	c = ""
	n = len(aLines)
	for i = 1 to n
		c += " " + aLines[i][:text]
	next
	return c

func chk(cWhat, bCond)
	if bCond = 1
		$nPass++
		? "  [OK] " + cWhat
	else
		$nFail++
		? "  [FAIL] " + cWhat
	ok

func Same(a, b)
	if isList(a) and isList(b)
		return @@(a) = @@(b)
	ok
	return 0

func sec(cName)
	? "    ~ " + cName + ": " + ((clock() - $nSec) / clockspersecond()) + "s"
	? ""
	$nSec = clock()
