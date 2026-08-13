load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	ADDIMAGE -- a field of samples, drawn in ONE call

	A standing request from the sound plane since SN5, with the cost measured
	THERE rather than guessed here:

	    a 760x260 spectrogram had to be drawn as one rectangle per cell --
	    1,574 rects, 88 ms, ~104 KB of SVG -- because stzCanvas had no way
	    to say "here is a field of values, draw it".

	It is also the primitive `image -> data` needs anyway: a plane that can
	analyse an image but not draw one is halfway.

	Run:  ring gg_image_primitive.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " ADDIMAGE -- one call instead of one rect per cell"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. The SVG tier carries it with no device at all ---------"
#
# Checked FIRST because it needs no GPU: the vector tier is the floor of
# the ladder, and an image that only existed on the pixel tier would have
# broken the promise that ToSVG() always works.
#---------------------------------------------------------------------------

IW = 32  IH = 32
cRamp = _Ramp(IW, IH)

oV = new stzCanvas(200, 160)
oV.SetBackgroundQ("#FFFFFF")
oV.AddImage(20, 20, 160, 120, IW, IH, cRamp)
cSvg = oV.ToSVG()
? "   SVG : " + len(cSvg) + " chars"
chk("the SVG tier emits an <image>", StzFindFirst("<image", cSvg) > 0)
chk("...carried as a self-contained data URI",
    StzFindFirst("data:image/png;base64,", cSvg) > 0)
chk("...and it is not letterboxed into the box it was given",
    StzFindFirst("preserveAspectRatio", cSvg) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 2. ONE command, whatever the cell count ------------------"
#
# The claim the sound plane is waiting on. A scene's command count is the
# honest witness: 1,024 cells drawn as rects is 1,024 commands.
#---------------------------------------------------------------------------

oOne = new stzCanvas(200, 160)
oOne.AddImage(0, 0, 200, 160, IW, IH, cRamp)
nCmdImage = oOne.ShapeCount()

oMany = new stzCanvas(200, 160)
for y = 0 to IH - 1
	for x = 0 to IW - 1
		oMany.Flush()
		oMany.FillQ("#808080").AddRect(x * 6, y * 5, 6, 5)
	next
next
nCmdRects = oMany.ShapeCount()

? "   " + (IW * IH) + " cells as rects : " + nCmdRects + " commands"
? "   the same field as an image : " + nCmdImage + " command"
chkeq("an image is ONE command", nCmdImage, 1)
chk("...against one per cell the other way", nCmdRects >= IW * IH)

nSvgMany = len(oMany.ToSVG())
nSvgOne = len(oOne.ToSVG())
? "   SVG size : " + nSvgMany + " chars as rects, " + nSvgOne + " as an image"
chk("and the vector file is smaller too", nSvgOne < nSvgMany)

#---------------------------------------------------------------------------
? ""
? "-- 3. The pixels ARRIVE, and arrive in the right place ------"
#
# "It drew something" is too weak. The ramp has a known value at every
# cell, so the rendered pixel is checked against the SOURCE -- and the
# corners are checked separately, because an image drawn upside down or
# mirrored would pass a centre-only test.
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- the SVG tier above needed none)"
else
	W = 256  H = 256
	oP = new stzCanvas(W, H)
	oP.SetBackgroundQ("#000000")
	oP.AddImage(0, 0, W, H, IW, IH, cRamp)
	cPx = oP.ToPixels()

	# the ramp is red = x*8, green = y*8, blue = 128
	aCases = [
		[ "top-left",     16,  16 ],
		[ "top-right",   240,  16 ],
		[ "bottom-left",  16, 240 ],
		[ "bottom-right",240, 240 ],
		[ "centre",      128, 128 ]
	]
	nWrong = 0
	for a in aCases
		nSx = floor(a[2] * IW / W)
		nSy = floor(a[3] * IH / H)
		nWantR = nSx * 8
		nWantG = nSy * 8
		aGot = _At(cPx, W, a[2], a[3])
		nD = fabs(aGot[1] - nWantR) + fabs(aGot[2] - nWantG) + fabs(aGot[3] - 128)
		? "   " + PadR(a[1], 13) + " got " + aGot[1] + "," + aGot[2] + "," + aGot[3] +
		  "   want " + nWantR + "," + nWantG + ",128" + iif(nD <= 30, "", "   WRONG")
		if nD > 30  nWrong++  ok
	next
	chkeq("every corner and the centre match the source", nWrong, 0)

	# THE NEGATIVE SIBLING: a flipped image would pass a centre test and
	# fail this one, so prove the check can tell the difference.
	aTL = _At(cPx, W, 16, 16)
	aBR = _At(cPx, W, 240, 240)
	chk("top-left and bottom-right are NOT the same pixel",
	    fabs(aTL[1] - aBR[1]) + fabs(aTL[2] - aBR[2]) > 60)
ok

#---------------------------------------------------------------------------
? ""
? "-- 4. A still image UPLOADS ONCE ----------------------------"
#
# The property that makes a live spectrogram affordable. The scene already
# proves this for vertices; an image is far bigger than its vertices, so a
# per-frame re-upload would be the dominant cost of a window that showed
# one.
#---------------------------------------------------------------------------

if StzGraphicsDevice()
	oStill = new stzCanvas(200, 160)
	oStill.AddImage(0, 0, 200, 160, IW, IH, cRamp)
	oStill.ToPixels()
	aS1 = oStill.Stats()
	for i = 1 to 5
		oStill.ToPixels()
	next
	aS2 = oStill.Stats()
	? "   builds after 1 render : " + aS1[5] + "   after 6 : " + aS2[5]
	chkeq("six renders of an unchanged image rebuild nothing", aS2[5], aS1[5])
ok

#---------------------------------------------------------------------------
? ""
? "-- 5. Refusals name the size they wanted --------------------"
#---------------------------------------------------------------------------

chk("a short pixel buffer is refused", Raises('
	o = new stzCanvas(100, 100)
	o.AddImage(0, 0, 50, 50, 32, 32, "tooshort")
'))
chk("a box with no area is refused", Raises('
	o = new stzCanvas(100, 100)
	o.AddImage(0, 0, 0, 50, 2, 2, _Ramp(2, 2))
'))
try
	oE = new stzCanvas(100, 100)
	oE.AddImage(0, 0, 50, 50, 32, 32, "tooshort")
catch
	cMsg = cCatchError
done
? "   " + cMsg
chk("...and the message says how many bytes it needed",
    StzFindFirst("4096", cMsg) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 6. A TINT multiplies, and white leaves it alone ----------"
#---------------------------------------------------------------------------

if StzGraphicsDevice()
	oT = new stzCanvas(64, 64)
	oT.AddImageXT(0, 0, 64, 64, IW, IH, cRamp, :White)
	aPlain = _At(oT.ToPixels(), 64, 32, 32)

	oT2 = new stzCanvas(64, 64)
	oT2.AddImageXT(0, 0, 64, 64, IW, IH, cRamp, "#FF0000")
	aTint = _At(oT2.ToPixels(), 64, 32, 32)

	# the UNTINTED image, to compare a white tint against. The first version
	# of this scene wrote `... or TRUE`, which is an assertion that cannot
	# fail -- it passed while proving nothing at all.
	oNo = new stzCanvas(64, 64)
	oNo.AddImage(0, 0, 64, 64, IW, IH, cRamp)
	aNone = _At(oNo.ToPixels(), 64, 32, 32)

	? "   untinted   : " + aNone[1] + "," + aNone[2] + "," + aNone[3]
	? "   white tint : " + aPlain[1] + "," + aPlain[2] + "," + aPlain[3]
	? "   red tint   : " + aTint[1] + "," + aTint[2] + "," + aTint[3]
	chk("a white tint leaves the image exactly as it was",
	    fabs(aPlain[1] - aNone[1]) + fabs(aPlain[2] - aNone[2]) +
	    fabs(aPlain[3] - aNone[3]) <= 2)
	chk("a red tint removes the other channels",
	    aTint[2] < aPlain[2] / 2 and aTint[3] < aPlain[3] / 2)
ok

? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

#---------------------------------------------------------------------------

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func chkeq cWhat, xGot, xWant
	chk(cWhat + "  [got " + xGot + ", want " + xWant + "]", xGot = xWant)

func Raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_

# red = x*8, green = y*8, blue = 128 -- a field whose value at any cell is
# known without rendering it, which is what makes scene 3 an assertion
# rather than an eyeball.
func _Ramp nW, nH
	_c_ = ""
	for _y_ = 0 to nH - 1
		for _x_ = 0 to nW - 1
			_c_ += char(_x_ * 8) + char(_y_ * 8) + char(128) + char(255)
		next
	next
	return _c_

func _At cPx, nW, nX, nY
	_i_ = (nY * nW + nX) * 4 + 1
	if _i_ + 2 > len(cPx)  return [ 0, 0, 0 ]  ok
	return [ ascii(substr(cPx, _i_, 1)), ascii(substr(cPx, _i_ + 1, 1)),
	         ascii(substr(cPx, _i_ + 2, 1)) ]
