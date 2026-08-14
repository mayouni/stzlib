# ONE DISPLAY LIST, TWO RENDERERS -- and they are made to prove it here.
#
# The house doctrine since GR2b: a picture is described ONCE and rendered
# twice, "so the two backends cannot disagree about where anything sits."
# §3 of SOFTANZA_GUI_PLAN.md leans on the same idea one level up -- the
# CSS/RCSS profile is a contract, RmlUi is one conforming implementation
# and a browser is another, and CONFORMANCE FIXTURES prove they agree.
#
# Until this file, nothing had ever checked it. Both tiers were exercised
# separately, every guard passed, and no test had ever put the SVG and the
# pixels side by side. "Cannot disagree" was an argument, not a result.
#
# THE OBSERVABLES, stated rather than assumed. A vector tier and a raster
# tier cannot be compared byte for byte -- one is geometry, the other is
# a grid. What they must agree on is WHERE and WHAT:
#
#   1. every box's bounding rectangle, to the pixel
#   2. its colour, exactly
#   3. the presence and position of text
#
# So a colour is chosen per box, the SVG's polygons for that colour are
# reduced to a bounding box, the PNG's pixels of that colour are reduced
# to a bounding box, and the two are compared. Disagreement in either
# tier's transform, rounding or winding shows up as a moved edge.
#
# The vector half needs no device and IS the CI coverage. The raster half
# is gated on a GPU, exactly like every other graphics guard.

load "../../stzBase.ring"

nPass = 0
nFail = 0

if NOT StzGuiAvailable()
	? "No layout engine on this machine -- nothing to compare."
	? " 0 ok, 0 failed"
	return
ok

# Colours chosen to be UNMISTAKABLE and mutually distant, so a pixel
# belongs to exactly one box and no blend can be confused for another.
cDoc = 'DEFINE PANEL p (
  SIZE [400, 300], DIRECTION column, FONT "app", BACKGROUND "#000000",
  CHILDREN [top, mid, bot]
) RATIONALE "Three bands, three unmistakable colours."

DEFINE BOX top ( HEIGHT 60, BACKGROUND "#ff0000" ) RATIONALE "pure red"
DEFINE BOX mid ( HEIGHT 80, BACKGROUND "#00ff00", CHILDREN [word] ) RATIONALE "pure green, with text in it"
DEFINE TEXT word ( CONTENT "AGREE", SIZE 28, COLOR "#000000" ) RATIONALE "ink to find on both tiers"
DEFINE BOX bot ( HEIGHT 50, BACKGROUND "#0000ff" ) RATIONALE "pure blue"'

oU = new stzUiDocument(cDoc)
chk("the fixture document is clean", oU.IsClean())
oU.UseFont("../gpu/fixtures/amiri_arabic_subset.ttf")
oP = oU.ToPanel()

oC = new stzCanvas(400, 300)
oC.SetBackground("#000000")
oP.DrawInto(oC)

? "-- Scene 1: the layout says where the boxes are --"
aTop = oP.BoxOf("top")
aMid = oP.BoxOf("mid")
aBot = oP.BoxOf("bot")
? "   top " + @@(aTop) + "  mid " + @@(aMid) + "  bot " + @@(aBot)
chk("three bands, stacked in order", aTop[2] < aMid[2] and aMid[2] < aBot[2])
chk("...at their declared heights", aTop[4] = 60 and aMid[4] = 80 and aBot[4] = 50)

? ""
? "-- Scene 2: the VECTOR tier, on a machine with no device --"
cSvg = oC.ToSVG()
chk("the SVG tier answered", len(cSvg) > 200)
aSvgRed = _SvgBox(cSvg, "rgb(255,0,0)")
aSvgGreen = _SvgBox(cSvg, "rgb(0,255,0)")
aSvgBlue = _SvgBox(cSvg, "rgb(0,0,255)")
? "   svg red   " + @@(aSvgRed)
? "   svg green " + @@(aSvgGreen)
? "   svg blue  " + @@(aSvgBlue)
chk("the red band is in the vector output", len(aSvgRed) = 4)
chk("the green one too", len(aSvgGreen) = 4)
chk("and the blue", len(aSvgBlue) = 4)

# the vector tier must agree with the LAYOUT before it can be asked to
# agree with the raster tier
chk("the SVG red box is where the layout put it",
    _Near(aSvgRed[1], aTop[1]) and _Near(aSvgRed[2], aTop[2]) and
    _Near(aSvgRed[3] - aSvgRed[1], aTop[3]) and
    _Near(aSvgRed[4] - aSvgRed[2], aTop[4]))
chk("...and the blue one", _Near(aSvgBlue[2], aBot[2]) and
    _Near(aSvgBlue[4] - aSvgBlue[2], aBot[4]))
# the negative sibling: a colour nobody declared must be found NOWHERE,
# or the finder is matching something other than what it claims
chk("a colour the document never used is absent",
    len(_SvgBox(cSvg, "rgb(123,45,67)")) = 0)

? ""
? "-- Scene 3: text reached the vector tier as OUTLINES --"
# The SVG tier draws glyphs as paths from the same layout the GPU tier
# uses, so a viewer needs no font. Its presence is the assertion; its
# shape is the text pipeline's own guards' business.
chk("the SVG carries path data", StzFindFirst("<path", cSvg) > 0)
chk("...and it is not the boxes, which are polygons",
    len(StzFindCS("<polygon", cSvg, 1)) >= 3)

if NOT oC.CanDrawPixels()
	? ""
	? "No GPU on this machine -- the raster half is skipped, and the"
	? "comparison stays UNPROVEN rather than being assumed."
	? "=============================================================="
	? " " + nPass + " ok, " + nFail + " failed"
	? "=============================================================="
	return
ok

? ""
? "-- Scene 4: the RASTER tier, and whether it agrees --"
cPix = oC.ToPixels()
chk("the GPU tier answered with a full frame", len(cPix) = 400 * 300 * 4)

aPixRed = _PixBox(cPix, 400, 300, 255, 0, 0)
aPixGreen = _PixBox(cPix, 400, 300, 0, 255, 0)
aPixBlue = _PixBox(cPix, 400, 300, 0, 0, 255)
? "   png red   " + @@(aPixRed)
? "   png green " + @@(aPixGreen)
? "   png blue  " + @@(aPixBlue)

chk("the red band rasterized", len(aPixRed) = 4)
chk("the green one too", len(aPixGreen) = 4)
chk("and the blue", len(aPixBlue) = 4)

# THE COMPARISON THIS FILE EXISTS FOR
chk("red agrees between the two tiers, to the pixel", _SameBox(aSvgRed, aPixRed))
chk("green agrees", _SameBox(aSvgGreen, aPixGreen))
chk("blue agrees", _SameBox(aSvgBlue, aPixBlue))

# ...and the negative sibling that stops those three being vacuous: the
# bands must not all be the SAME box, or "they agree" would be trivially
# true of any three identical rectangles
chk("the three bands are genuinely different rectangles",
    NOT _SameBox(aPixRed, aPixGreen) and NOT _SameBox(aPixGreen, aPixBlue))

? ""
? "-- Scene 5: the text is in the same place on both tiers --"
# Black ink on the green band: count the dark pixels INSIDE the green
# box. The vector tier drew paths there; the raster tier must have ink
# there. Neither number is compared to the other -- what is asserted is
# that both tiers put text in the same box and neither left it empty.
nInk = _InkIn(cPix, 400, 300, aMid)
? "   dark pixels inside the green band: " + nInk
chk("the raster tier inked the text", nInk > 40)
chk("...inside the band, not over the whole panel",
    nInk < (aMid[3] * aMid[4]) / 3)
aT = oP.Texts()
chk("the layout put exactly one string there", len(aT) = 1)
chk("...and none of it was lost", oP.TextIsWhole())

oP.Free()

? ""
? "=============================================================="
? " " + nPass + " ok, " + nFail + " failed"
? "=============================================================="

#-- helpers ---------------------------------------------------------------
#
# Ring parses everything after the first `func` as a function body, so
# every helper lives below the last top-level line.

# The bounding box [x0, y0, x1, y1] of every SVG polygon painted in one
# colour, or [] when that colour is not in the file.
func _SvgBox cSvg, cFill
	_aAt_ = StzFindCS(cFill, cSvg, 1)
	if len(_aAt_) = 0
		return []
	ok
	_nX0_ = 999999   _nY0_ = 999999
	_nX1_ = -999999  _nY1_ = -999999
	_nN_ = len(_aAt_)
	for _k_ = 1 to _nN_
		# walk back to this polygon's points="..." and read the pairs
		_nP_ = _RFindBefore(cSvg, 'points="', _aAt_[_k_])
		if _nP_ = 0
			loop
		ok
		# there is no StzFindFirstFrom in the family, so the search runs
		# on the tail and the offset is added back
		_nS_ = _nP_ + 8
		_cTail_ = substr(cSvg, _nS_, 400)
		_nE_ = StzFindFirst('"', _cTail_)
		if _nE_ = 0
			loop
		ok
		_aPts_ = StzSplit(substr(_cTail_, 1, _nE_ - 1), " ")
		_nPn_ = len(_aPts_)
		for _j_ = 1 to _nPn_
			_aXY_ = StzSplit(_aPts_[_j_], ",")
			if len(_aXY_) != 2
				loop
			ok
			_x_ = 0 + _aXY_[1]
			_y_ = 0 + _aXY_[2]
			if _x_ < _nX0_  _nX0_ = _x_ ok
			if _y_ < _nY0_  _nY0_ = _y_ ok
			if _x_ > _nX1_  _nX1_ = _x_ ok
			if _y_ > _nY1_  _nY1_ = _y_ ok
		next
	next
	if _nX1_ < _nX0_
		return []
	ok
	return [ _nX0_, _nY0_, _nX1_, _nY1_ ]

# The last occurrence of cNeedle before position nBefore, or 0.
func _RFindBefore cHay, cNeedle, nBefore
	_a_ = StzFindCS(cNeedle, cHay, 1)
	_nBest_ = 0
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if _a_[_i_] < nBefore and _a_[_i_] > _nBest_
			_nBest_ = _a_[_i_]
		ok
	next
	return _nBest_

# The bounding box of every pixel matching a colour, within a tolerance
# that admits the blend at an edge but not a neighbouring band.
func _PixBox cPix, nW, nH, nR, nG, nB
	_nX0_ = 999999   _nY0_ = 999999
	_nX1_ = -999999  _nY1_ = -999999
	for _y_ = 0 to nH - 1
		_nRow_ = _y_ * nW * 4
		for _x_ = 0 to nW - 1
			_i_ = _nRow_ + _x_ * 4 + 1
			if fabs(ascii(substr(cPix, _i_, 1)) - nR) < 40 and
			   fabs(ascii(substr(cPix, _i_ + 1, 1)) - nG) < 40 and
			   fabs(ascii(substr(cPix, _i_ + 2, 1)) - nB) < 40
				if _x_ < _nX0_  _nX0_ = _x_ ok
				if _y_ < _nY0_  _nY0_ = _y_ ok
				if _x_ > _nX1_  _nX1_ = _x_ ok
				if _y_ > _nY1_  _nY1_ = _y_ ok
			ok
		next
	next
	if _nX1_ < _nX0_
		return []
	ok
	# a filled span of N pixels runs from edge to edge-1, so the far edge
	# is one past the last lit pixel -- the vector tier states it as the
	# edge, and this is where the two conventions are reconciled
	return [ _nX0_, _nY0_, _nX1_ + 1, _nY1_ + 1 ]

func _SameBox aA, aB
	if len(aA) != 4 or len(aB) != 4
		return 0
	ok
	for _i_ = 1 to 4
		if NOT _Near(aA[_i_], aB[_i_])
			return 0
		ok
	next
	return 1

# One pixel of slack: the vector tier speaks in f64 and the raster tier
# in whole pixels, so an edge at 59.5 is honestly either 59 or 60.
func _Near nA, nB
	return fabs(nA - nB) <= 1

# Dark pixels inside a box -- the text's ink on a bright band.
func _InkIn cPix, nW, nH, aBox
	_n_ = 0
	_y0_ = floor(aBox[2])   _y1_ = floor(aBox[2] + aBox[4]) - 1
	_x0_ = floor(aBox[1])   _x1_ = floor(aBox[1] + aBox[3]) - 1
	for _y_ = _y0_ to _y1_
		for _x_ = _x0_ to _x1_
			_i_ = (_y_ * nW + _x_) * 4 + 1
			if _i_ < 1 or _i_ + 2 > len(cPix)
				loop
			ok
			_lum_ = (ascii(substr(cPix, _i_, 1)) * 3 +
			         ascii(substr(cPix, _i_ + 1, 1)) * 6 +
			         ascii(substr(cPix, _i_ + 2, 1))) / 10
			if _lum_ < 60
				_n_++
			ok
		next
	next
	return _n_

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
