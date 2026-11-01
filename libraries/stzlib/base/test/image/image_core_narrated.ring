# THE IMAGE PLANE'S CORE -- IM0, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md: one image type behind one engine handle
# (stz_image.dll), its codecs, and the first classical operations, with
# OpenCV's conventions. Every expected number below is computed by hand
# from the convention, so a guard that passes says the CONVENTION holds,
# not merely that the code ran.
#
#   Scene 1  files: PNG and BMP round trips are exact; garbage is refused
#   Scene 2  channels: BT.601 gray, by hand; invert keeps alpha
#   Scene 3  geometry: crop, flip, quarter turns -- pixel by pixel
#   Scene 4  resampling: nearest, bilinear (half-pixel centres), area
#   Scene 5  blur: a constant stays constant; an impulse becomes the kernel
#   Scene 6  thresholds: Otsu, and "above" means above
#   Scene 7  grids: an analysis is numbers, and pixels come back exactly
#   Scene 8  one handle: a copy sees a change made by an Apply form
#   Scene 9  the artefacts a person looks at (written to _image-out/)
#
# PER PX: one process, per-section wall time. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_image-out"
if StzDirExists(cOut)
	StzDirDeleteAll(cOut)
ok
StzDirCreatePath(cOut)
nAlive0 = StzImagesAlive()

pr()

#=====================================================================#
? "-- Scene 1: files --"
#=====================================================================#

cRgb = ""
for i = 1 to 12
	cRgb += char((i * 21) % 256) + char((i * 37) % 256) + char((i * 53) % 256)
next
oA = StzImageFromPixels(4, 3, 3, cRgb)
oA.SaveAs(cOut + "/rgb.png")
oB = StzImageQ(cOut + "/rgb.png")
chk("a PNG written and read back has the same size", Same(oB.Size(), [ 4, 3 ]))
chk("...and exactly the same pixels", oB.Pixels() = cRgb and oB.Channels() = 3)
oA.SaveAs(cOut + "/rgb.bmp")
oC = StzImageQ(cOut + "/rgb.bmp")
chk("a BMP round trip is exact too", oC.Pixels() = cRgb)
# PNG bytes are binary, so the byte-wise left(), not the codepoint StzLeft()
chk("...and ToPNG() is the PNG signature", left(oA.ToPNG(), 4) = char(137) + "PNG")

bRaised = 0
cWhy = ""
try
	StzImageFromBytes("this is not an image")
catch
	bRaised = 1
	cWhy = cCatchError
done
chk("bytes that are no image are refused, saying why",
	bRaised = 1 and StzFindFirst("stb_image", cWhy) > 0)
bRaised = 0
try
	oA.SaveAs(cOut + "/x.tiff")
catch
	bRaised = 1
done
chk("a format not written yet is refused, not guessed", bRaised = 1)
oB.Release() oC.Release()

sec("scene 1")

#=====================================================================#
? "-- Scene 2: channels --"
#=====================================================================#
# BT.601, rounded: red 0.299 x 255 = 76.2 -> 76; green 0.587 x 255 =
# 149.7 -> 150; blue 0.114 x 255 = 29.1 -> 29.

oP = StzImageFromPixels(4, 1, 3, char(255) + char(0) + char(0) + char(0) + char(255) + char(0) +
	char(0) + char(0) + char(255) + char(255) + char(255) + char(255))
oG = oP.Grayscaled()
chk("pure red is gray 76", Same(oG.Pixel(1, 1), [ 76 ]))
chk("...green 150, blue 29, white 255",
	Same(oG.Pixel(2, 1), [ 150 ]) and Same(oG.Pixel(3, 1), [ 29 ]) and Same(oG.Pixel(4, 1), [ 255 ]))
chk("the gray copy has one channel, the original keeps three",
	oG.Channels() = 1 and oP.Channels() = 3)

oRgba = StzImageFromPixels(1, 1, 4, char(10) + char(20) + char(30) + char(128))
chk("invert flips the colours and keeps alpha",
	Same(oRgba.Inverted().Pixel(1, 1), [ 245, 235, 225, 128 ]))
chk("a gray image coloured repeats its level", Same(oG.Coloured().Pixel(1, 1), [ 76, 76, 76 ]))

sec("scene 2")

#=====================================================================#
? "-- Scene 3: geometry --"
#=====================================================================#
# A 3 x 2 image 1 2 3 / 4 5 6. Turned clockwise it is 2 x 3:
# 4 1 / 5 2 / 6 3.

oS = StzImageFromPixels(3, 2, 1, char(1) + char(2) + char(3) + char(4) + char(5) + char(6))
oRot = oS.Rotated(90)
chk("a quarter turn swaps the size", Same(oRot.Size(), [ 2, 3 ]))
chk("...4 goes to the top-left, 1 beside it, 6 at the bottom-left",
	Same(oRot.Pixel(1, 1), [ 4 ]) and Same(oRot.Pixel(2, 1), [ 1 ]) and Same(oRot.Pixel(1, 3), [ 6 ]))
# Rotated() returns DATA (a new image); the turns that follow CHANGE that image
oTurn = oS.Rotated(90)
oTurn { ApplyRotation(90) ApplyRotation(90) ApplyRotation(90) }
chk("four quarter turns are the identity", oTurn.Pixels() = oS.Pixels())
oTurn.ApplyRotationQ(180).ApplyRotation(-180)
chk("half a turn and back is the identity", oTurn.Pixels() = oS.Pixels())
oTurn.Release()
chk("a horizontal flip reverses each row",
	oS.Flipped(:horizontal).Pixels() = char(3) + char(2) + char(1) + char(6) + char(5) + char(4))
chk("a vertical flip swaps the rows",
	oS.Flipped(:vertical).Pixels() = char(4) + char(5) + char(6) + char(1) + char(2) + char(3))

oRamp = Ramp4()
chk("a crop takes exactly its rectangle (from pixel 2,2: 50 60 / 90 100)",
	oRamp.Cropped(2, 2, 2, 2).Pixels() = char(50) + char(60) + char(90) + char(100))
bRaised = 0
try
	oRamp.Cropped(3, 3, 3, 3)
catch
	bRaised = 1
done
chk("a crop that leaves the image is refused", bRaised = 1)
oFree = oS.Rotated(45)
chk("a free angle (IM2) turns on the same canvas", Same(oFree.Size(), oS.Size()))
oFree.Release()

sec("scene 3")

#=====================================================================#
? "-- Scene 4: resampling --"
#=====================================================================#
# The 4 x 4 ramp v(x, y) = 10 * (4y + x), 0-based. Shrunk by AREA to
# 2 x 2, each pixel is the mean of a 2 x 2 block: 25 45 / 105 125.
# [0, 255] stretched bilinearly to 4 pixels samples at -0.25, 0.25,
# 0.75, 1.25 (half-pixel centres, edges clamped): 0 64 191 255.

chk("area shrink is the block means 25 45 / 105 125",
	oRamp.ResizedXT(2, 2, :area).Pixels() = char(25) + char(45) + char(105) + char(125))
oTwo = StzImageFromPixels(2, 1, 1, char(0) + char(255))
chk("bilinear stretch with half-pixel centres: 0 64 191 255",
	oTwo.Resized(4, 1).Pixels() = char(0) + char(64) + char(191) + char(255))
oN = StzImageFromPixels(2, 2, 1, char(1) + char(2) + char(3) + char(4)).ResizedXT(4, 4, :nearest)
chk("nearest doubles each pixel into a 2 x 2 block",
	oN.Pixels() = char(1) + char(1) + char(2) + char(2) + char(1) + char(1) + char(2) + char(2) +
		char(3) + char(3) + char(4) + char(4) + char(3) + char(3) + char(4) + char(4))
chk("...and the bilinear one is NOT blocks (a negative sibling)",
	StzImageFromPixels(2, 2, 1, char(1) + char(2) + char(3) + char(4)).Resized(4, 4).Pixels() != oN.Pixels())

sec("scene 4")

#=====================================================================#
? "-- Scene 5: blur --"
#=====================================================================#
# sigma 1: 7 taps exp(-t^2/2), t = -3..3, sum 2.50595; the centre weight
# is 0.39905 and its neighbour 0.24204. An impulse of 255 becomes
# 255 x 0.39905^2 = 40.6 -> 41 at the centre, 255 x 0.39905 x 0.24204 =
# 24.6 -> 25 beside it, and 0 beyond the radius.

cImp = copy(char(0), 81)
cImp = StzLeft(cImp, 40) + char(255) + StzRight(cImp, 40)
oImp = StzImageFromPixels(9, 9, 1, cImp).Blurred(1)
chk("the impulse's centre is 41", Same(oImp.Pixel(5, 5), [ 41 ]))
chk("...its four neighbours are 25", Same(oImp.Pixel(4, 5), [ 25 ]) and Same(oImp.Pixel(6, 5), [ 25 ]) and
	Same(oImp.Pixel(5, 4), [ 25 ]) and Same(oImp.Pixel(5, 6), [ 25 ]))
chk("...and four pixels away it is 0", Same(oImp.Pixel(1, 5), [ 0 ]))
oFlat = StzImageNew(6, 5, 3, 7).Blurred(2)
chk("a constant image stays constant under blur, borders included",
	oFlat.Pixels() = copy(char(7), 90))
bRaised = 0
try
	oFlat.Blurred(0)
catch
	bRaised = 1
done
chk("a blur of sigma 0 is refused", bRaised = 1)

sec("scene 5")

#=====================================================================#
? "-- Scene 6: thresholds --"
#=====================================================================#
# Two flat levels, 40 and 200: every t from 40 to 199 separates them
# equally well, and Otsu keeps the FIRST, 40 (as OpenCV's strict ">"
# does). A ramp of every level 0..255 splits in the middle, at 127.

oBi = StzImageFromPixels(4, 2, 1, copy(char(40), 4) + copy(char(200), 4))
chk("Otsu of two levels 40 / 200 is 40", oBi.OtsuThreshold() = 40)
oT = oBi.Thresholded(:otsu)
chk("...and thresholding there keeps exactly the four bright pixels",
	oT.Histogram().At(1, 256) = 4 and oT.Histogram().At(1, 1) = 4)
chk("a pixel EQUAL to the threshold is below it", Same(oBi.Thresholded(200).Pixel(1, 2), [ 0 ]))
oGrad = Gradient()
chk("Otsu of the full ramp is 127", oGrad.OtsuThreshold() = 127)
oGT = oGrad.Thresholded(:otsu)
chk("...level 127 goes dark, 128 goes light",
	Same(oGT.Pixel(128, 1), [ 0 ]) and Same(oGT.Pixel(129, 1), [ 255 ]))

sec("scene 6")

#=====================================================================#
? "-- Scene 7: grids --"
#=====================================================================#

oH = oRamp.Histogram()
chk("a histogram is 1 row of 256 levels", oH.Rows() = 1 and oH.Columns() = 256 and oH.ColumnMeaning() = "level")
chk("...its counts sum to the pixels", oH.Sum() = 16)
chk("...the ramp has one pixel at level 150 (column 151)", oH.At(1, 151) = 1)
oGr = oRamp.ToGrid()
chk("an image's grid is Height rows of Width columns", oGr.Rows() = 4 and oGr.Columns() = 4)
chk("...row 2, column 3 is the pixel (3, 2): 10 x (4 + 2) = 60", oGr.At(2, 3) = 60)
chk("...and the grid turns back into the same pixels", oGr.ToImage().Pixels() = oRamp.Pixels())
oSc = Gradient().SobelX().ToImageScaled()
chk("a signed grid made visible spans 0..255 (ToImageScaled)",
	oSc.Histogram().At(1, 1) > 0 and oSc.Histogram().At(1, 256) > 0)
oH.Release() oGr.Release()

sec("scene 7")

#=====================================================================#
? "-- Scene 8: one handle --"
#=====================================================================#
# Ring copies an object on assignment. The copy holds the same handle,
# and a mutating verb moves its result INTO that handle -- so the copy
# sees the change instead of holding a dead number.

o1 = StzImageFromPixels(1, 1, 1, char(10))
o2 = o1
o1.ApplyInversion()
chk("a copy sees a change made through the original", Same(o2.Pixel(1, 1), [ 245 ]))
o1.ApplyBlurQ(1).ApplyThresholdQ(100)
chk("...and the Q forms chain on the same pixels", Same(o2.Pixel(1, 1), [ 255 ]))
o1.Release()
chk("released once, every copy is empty", o2.IsEmpty() = 1)

sec("scene 8")

#=====================================================================#
? "-- Scene 9: the artefacts a person looks at --"
#=====================================================================#
# A counter proves delivery; only a look proves the picture is right
# (CENTRAL-PERCEPTGATE-01). These are written for a person to open.

oPage = StzImageQ("../ocr/_data/z09_p1_150dpi.png")
nT = clock()
oPageG = oPage.Grayscaled()
oPageB = oPageG.Blurred(2)
oPageT = oPageG.Thresholded(:otsu)
oPageS = oPageG.ResizedXT(floor(oPage.Width() / 4), floor(oPage.Height() / 4), :area)
nMs = (clock() - nT) * 1000 / clockspersecond()
oPageG.SaveAs(cOut + "/page_gray.png")
oPageB.SaveAs(cOut + "/page_blur2.png")
oPageT.SaveAs(cOut + "/page_otsu.png")
oPageS.SaveAs(cOut + "/page_quarter.png")
oGrad.SaveAs(cOut + "/ramp.png")
oGT.SaveAs(cOut + "/ramp_otsu.png")
? "    page " + oPage.Width() + " x " + oPage.Height() + ": gray + blur + Otsu + area-quarter in " + nMs + " ms"
chk("the page's Otsu level separates paper from ink (between 60 and 220)",
	oPageG.OtsuThreshold() > 60 and oPageG.OtsuThreshold() < 220)
chk("six PNGs are written for a person to look at", len(dir(cOut)) >= 6)
oPage.Release() oPageG.Release() oPageB.Release() oPageT.Release() oPageS.Release()

sec("scene 9")

# release what the scenes kept: exactly that many handles go back
aKept = [ oA, oP, oG, oRgba, oS, oRot, oRamp, oTwo, oN, oImp, oFlat, oBi, oT, oGrad, oGT ]
nBefore = StzImagesAlive()
nK = len(aKept)
for i = 1 to nK
	aKept[i].Release()
next
chk("releasing " + nK + " images frees exactly " + nK + " handles", StzImagesAlive() = nBefore - nK)
# ...ed() returns DATA: a new image the caller owns. This guard reads some
# inline (oG.Coloured().Pixel(1, 1)) and leaves them to the end of the run.
# A pipeline never does: the Apply forms change one image and make none.
? "    data images read inline and not released by this guard: " + (StzImagesAlive() - nAlive0)

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pf()

func Ramp4()
	c = ""
	for i = 0 to 15
		c += char(10 * i)
	next
	return StzImageFromPixels(4, 4, 1, c)

func Gradient()
	c = ""
	for i = 0 to 255
		c += char(i)
	next
	return StzImageFromPixels(256, 64, 1, copy(c, 64))

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
