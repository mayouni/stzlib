# THE IMAGE PLANE'S ANALYSIS -- IM1, narrated, against the OpenCV oracle
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM1: each operation is NATIVE Zig, and
# each is judged against OpenCV -- an independent implementation, never a
# dependency. The expectations in _oracle/ were written by
# _rig/oracle_opencv.py (OpenCV 5.0.0, NumPy for the FFT and Sauvola); this
# guard needs no Python. Every check says how far the engine is from the
# oracle, and the tolerance is stated beside it. Every positive has a
# negative sibling, so a comparison that cannot fail is caught.
#
#   Scene 1  morphology: 7 operations x 3 kernel shapes, pixel-exact
#   Scene 2  smoothing: median 3 and 5, histogram equalisation
#   Scene 3  derivatives: Sobel x / y and Scharr, value-exact
#   Scene 4  Canny on drawn shapes and on a real page
#   Scene 5  local thresholds: adaptive mean and Sauvola on the page
#   Scene 6  integral image, template matching, connected components
#   Scene 7  the 2D FFT against NumPy
#   Scene 8  JPEG out: decodes back, and its error is a JPEG's
#
# PER PX: one process, per-section wall time. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cOracle = "_oracle/"

pr()

oS = StzImageQ($cOracle + "in_shapes.png").ApplyGrayScaleQ()
oPg = StzImageQ($cOracle + "in_page.png").ApplyGrayScaleQ()
oTm = StzImageQ($cOracle + "in_template.png").ApplyGrayScaleQ()
? "    inputs: shapes " + oS.Width() + " x " + oS.Height() + ", page " + oPg.Width() + " x " + oPg.Height()

#=====================================================================#
? "-- Scene 1: morphology, every operation and every kernel shape --"
#=====================================================================#

nExact = 0
cMiss = ""
for cOp in [ "erode", "dilate", "open", "close", "gradient", "tophat", "blackhat" ]
	for cSh in [ "rect", "cross", "ellipse" ]
		oMine = oS.Morphed(cOp, 5, cSh)
		oRef = StzImageQ($cOracle + "morph_" + cOp + "_" + cSh + ".png").ApplyGrayScaleQ()
		aD = oMine.DifferenceWith(oRef)
		if aD[:pixels] = 0
			nExact++
		else
			cMiss += " " + cOp + "/" + cSh + "(" + aD[:pixels] + ")"
		ok
		oMine.Release() oRef.Release()
	next
next
chk("all 21 morphology results equal OpenCV's, pixel for pixel" + cMiss, nExact = 21)
oE = oS.Morphed(:erode, 5, :rect)
oD = oS.Morphed(:dilate, 5, :rect)
chk("...and a negative sibling: erosion and dilation do differ", oE.DifferenceWith(oD)[:pixels] > 1000)
oE.Release() oD.Release()

sec("scene 1")

#=====================================================================#
? "-- Scene 2: smoothing --"
#=====================================================================#

chk("median 3 equals OpenCV's", SameAs(oS.MedianFiltered(3), "median3", 0))
chk("median 5 equals OpenCV's", SameAs(oS.MedianFiltered(5), "median5", 0))
chk("...and median 3 is not median 5 (negative sibling)",
	oS.MedianFiltered(3).DifferenceWith(oS.MedianFiltered(5))[:pixels] > 100)
chk("histogram equalisation equals OpenCV's", SameAs(oS.Equalized(), "equalize", 0))
# IM1b: the engine's ONE gray is OpenCV 5's RGB2GRAY bit for bit -- derived over all
# 16,777,216 colours; the textbook 14-bit formula misses 43,864 of them
oCol = StzImageQ($cOracle + "in_colour.png")
chk("colour to gray equals OpenCV 5's on 3,072 random colours", oCol.Channels() = 3 and
	SameAs(oCol.Grayscaled(), "gray_colour", 0))

sec("scene 2")

#=====================================================================#
? "-- Scene 3: derivatives --"
#=====================================================================#

chk("Sobel x equals OpenCV's, value for value", GridMaxDiff(oS.SobelX(), "sobel_x") = 0)
chk("Sobel y equals OpenCV's", GridMaxDiff(oS.SobelY(), "sobel_y") = 0)
chk("Scharr x equals OpenCV's", GridMaxDiff(oS.DerivativeXT(:x, :scharr), "scharr_x") = 0)
chk("...and Sobel y is not Sobel x (negative sibling)", GridMaxDiff(oS.SobelY(), "sobel_x") > 100)

sec("scene 3")

#=====================================================================#
? "-- Scene 4: Canny --"
#=====================================================================#
# OpenCV's own non-maximum suppression (fixed-point tangent tests, ">"
# toward the previous neighbour and ">=" toward the next) and its
# hysteresis are copied, so the target is EXACT, not "close".

chk("Canny 50/150 on the shapes equals OpenCV's", SameAs(oS.Edges(50, 150), "canny_shapes", 0))
chk("Canny with the L2 gradient equals OpenCV's", SameAs(oS.EdgesL2(50, 150), "canny_shapes_l2", 0))
chk("Canny 60/180 on a real page equals OpenCV's", SameAs(oPg.Edges(60, 180), "canny_page", 0))
chk("...and other thresholds give other edges (negative sibling)",
	oS.Edges(10, 30).DifferenceWith(StzImageQ($cOracle + "canny_shapes.png").ApplyGrayScaleQ())[:pixels] > 50)

sec("scene 4")

#=====================================================================#
? "-- Scene 5: local thresholds --"
#=====================================================================#

chk("adaptive mean (block 15, C 8) on the page equals OpenCV's",
	SameAs(oPg.AdaptiveThresholded(15, 8), "adaptive_page", 0))
# Sauvola is compared with an independent NumPy writing of the same rule;
# float sums in another order may flip a pixel sitting exactly on T.
chk("Sauvola (window 25) on the page equals the NumPy reference within 0.05% of pixels",
	SameAs(oPg.SauvolaThresholded(25), "sauvola_page", 60))
chk("...and Sauvola is not the global Otsu cut (negative sibling)",
	oPg.SauvolaThresholded(25).DifferenceWith(oPg.Thresholded(:otsu))[:pixels] > 100)

sec("scene 5")

#=====================================================================#
? "-- Scene 6: integral, template matching, components --"
#=====================================================================#

chk("the integral image equals OpenCV's", GridMaxDiff(oS.IntegralGrid(), "integral") = 0)
nM = GridMaxDiff(oS.MatchTemplate(oTm), "match")
chk("template correlation equals OpenCV's within 1e-4 (OpenCV computes in float32): " + nM, nM < 0.0001)
aBest = oS.FindTemplate(oTm)
chk("...and the template is found where it was cut: left 47, top 9, score 1",
	aBest[1] = 47 and aBest[2] = 9 and aBest[3] > 0.9999)

oBin = oS.Thresholded(128)
aMine = oBin.Components()
aRef = LoadCsv($cOracle + "components8.csv")
chk("8-connected components: as many as OpenCV finds (" + len(aRef) + ")", len(aMine) = len(aRef))
chk("...with the same box, area and centroid for every one", SameComponents(aMine, aRef))
nRef4 = LoadCsv($cOracle + "components4_count.csv")[1][1]
chk("4-connected components: the same count as OpenCV's (" + nRef4 + ")", len(oBin.ComponentsXT(4)) = nRef4)

sec("scene 6")

#=====================================================================#
? "-- Scene 7: the 2D FFT --"
#=====================================================================#

oF = oS.SpectrumXT(1, 0)
nF = GridMaxDiff(oF, "fft2_shifted")
nPeak = oF.Max()
chk("|FFT2| equals NumPy's to 1e-6 of the peak (" + nF + " of " + nPeak + ")", nF / nPeak < 0.000001)
chk("...and the zero frequency sits at the centre, row 37, column 49", Same(oF.Peak(), [ 37, 49, nPeak ]) or
	(oF.Peak()[1] = 37 and oF.Peak()[2] = 49))

sec("scene 7")

#=====================================================================#
? "-- Scene 8: JPEG out --"
#=====================================================================#

oS.SaveAs("_oracle_out.jpg")
oBack = StzImageQ("_oracle_out.jpg").ApplyGrayScaleQ()
aJ = oBack.DifferenceWith(oS)
nPsnr = 10 * log10(255 * 255 / aJ[:mse])
chk("the JPEG decodes back at the same size", Same(oBack.Size(), oS.Size()))
chk("...lossy but close: PSNR " + nPsnr + " dB > 30 at quality 90", nPsnr > 30)
chk("...and quality 10 is visibly worse (negative sibling)",
	len(oS.ToJPEG(10)) < len(oS.ToJPEG(90)))
remove("_oracle_out.jpg")

sec("scene 8")

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pf()

# an image result against an oracle PNG: at most nAllowed pixels may differ
func SameAs(oMine, cName, nAllowed)
	oRef = StzImageQ($cOracle + cName + ".png").ApplyGrayScaleQ()
	aD = oMine.DifferenceWith(oRef)
	if aD[:pixels] > nAllowed
		? "      " + cName + ": " + aD[:pixels] + " pixels differ (max " + aD[:max] + ")"
	ok
	return aD[:pixels] <= nAllowed

# a grid against an oracle CSV: the largest absolute difference
func GridMaxDiff(oGrid, cName)
	aRef = LoadCsv($cOracle + cName + ".csv")
	nR = len(aRef)
	if nR != oGrid.Rows() or len(aRef[1]) != oGrid.Columns()
		? "      " + cName + ": shape " + oGrid.Rows() + "x" + oGrid.Columns() + " vs " + nR + "x" + len(aRef[1])
		return 1000000000
	ok
	nMax = 0
	for r = 1 to nR
		aRow = aRef[r]
		nC = len(aRow)
		for c = 1 to nC
			d = fabs(oGrid.At(r, c) - aRow[c])
			if d > nMax
				nMax = d
			ok
		next
	next
	return nMax

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

# OpenCV's rows are sorted by (top, left); so are ours by raster order of first pixel
func SameComponents(aMine, aRef)
	n = len(aRef)
	if len(aMine) != n
		return 0
	ok
	aSorted = []
	for i = 1 to n
		aSorted + [ aMine[i][:top] * 100000 + aMine[i][:left], i ]
	next
	aSorted = sort(aSorted, 1)
	for i = 1 to n
		a = aMine[aSorted[i][2]]
		b = aRef[i]
		if a[:left] != b[1] or a[:top] != b[2] or a[:width] != b[3] or a[:height] != b[4] or
		   a[:area] != b[5] or fabs(a[:cx] - b[6]) > 0.001 or fabs(a[:cy] - b[7]) > 0.001
			? "      component " + i + " differs"
			return 0
		ok
	next
	return 1

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
