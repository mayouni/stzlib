load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	WHAT THE GUARDS COULD NOT SEE

	Every assertion in this file exists because a DEFECT SURVIVED A GREEN
	SUITE and was found by rendering a picture and looking at it.

	  - gg_nodeshapes proves every shape stays inside its box. The cylinder's
	    cap did stay inside its box, and was still wrong: at 26x200 the cap
	    was 26px deep and 13px across -- an ellipse taller than it is wide,
	    which is not a circle seen in perspective from any angle. Containment
	    was true and the shape was broken.

	  - stzGraph's label rule was DECIDED, its test was rewritten, and the
	    library line was never removed. Nothing failed, because a `#-->`
	    block is not compared to anything, the narration path replaced the
	    underscores back with spaces before a human read them, and the one
	    export test that showed the damage had recorded its expectation FROM
	    the buggy render.

	  - Nothing at all knew whether a node BOX fits the rank it landed in.
	    The layout spreads a rank evenly and knows nothing about box width;
	    the caller sets box width and knows nothing about rank population.
	    Sixteen 96px nodes went 82px apart and were drawn on top of one
	    another.

	The common shape: each property is about the PICTURE, and every
	instrument pointed somewhere else. So these assertions read pixels, or
	they assert the mechanism directly and prove the instrument can fail.

	Run:  ring gg_adversarial.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " WHAT THE GUARDS COULD NOT SEE"
? "=============================================================="

if NOT StzGraphicsDevice()
	? ""
	? " (no device -- every property here is a PIXEL property, so this"
	? "  file is UNJUDGED on this machine rather than passed)"
	return
ok

#---------------------------------------------------------------------------
? ""
? "-- 1. Painter order, across the segment KINDS ---------------"
#
# Images arrived as a third SegKind beside shapes and text, and the claim
# was that the ordered segment list interleaves them. "Both drew" would
# pass on a renderer that painted all images last. So: a shape, then an
# image ON TOP of it, and the overlap is read in pixels.
#---------------------------------------------------------------------------

FILL = "#C81E1E"          # the under-shape
IMG  = [ 30, 90, 200 ]    # the over-image

oA = new stzCanvas(240, 160)
oA.SetBackgroundQ("#FFFFFF")
oA.FillQ(FILL).AddRect(20, 20, 200, 120)
oA.AddImage(60, 50, 120, 60, 2, 2, _Solid(2, 2, IMG[1], IMG[2], IMG[3], 255))
cPx = oA.ToPixels()

aMid = _PixelAt(cPx, 240, 120, 80)     # inside BOTH
? "   the overlap reads : " + aMid[1] + "," + aMid[2] + "," + aMid[3]
chk("the image covers the shape it was issued after",
    _Near(aMid, IMG, 6))

# THE NEGATIVE SIBLING. The same two draws in the OTHER order must give the
# other answer -- otherwise this measures "an image was drawn somewhere",
# not ordering.
oB = new stzCanvas(240, 160)
oB.SetBackgroundQ("#FFFFFF")
oB.AddImage(60, 50, 120, 60, 2, 2, _Solid(2, 2, IMG[1], IMG[2], IMG[3], 255))
oB.Flush()
oB.FillQ(FILL).AddRect(20, 20, 200, 120)
aMid2 = _PixelAt(oB.ToPixels(), 240, 120, 80)
? "   issued the other way round : " + aMid2[1] + "," + aMid2[2] + "," + aMid2[3]
chk("...and the shape covers the image when issued after IT",
    NOT _Near(aMid2, IMG, 6))

#---------------------------------------------------------------------------
? ""
? "-- 2. An image's ALPHA blends, it does not replace ----------"
#---------------------------------------------------------------------------

GROUND = [ 200, 200, 0 ]
oC = new stzCanvas(240, 120)
oC.SetBackgroundQ("#FFFFFF")
oC.FillQ("#C8C800").AddRect(0, 0, 240, 120)
oC.AddImage(20, 20, 80, 80, 2, 2, _Solid(2, 2, 0, 0, 255, 128))    # half
oC.AddImage(140, 20, 80, 80, 2, 2, _Solid(2, 2, 0, 0, 255, 255))   # opaque
cPx = oC.ToPixels()

aHalf = _PixelAt(cPx, 240, 60, 60)
aFull = _PixelAt(cPx, 240, 180, 60)
? "   alpha 128 : " + aHalf[1] + "," + aHalf[2] + "," + aHalf[3]
? "   alpha 255 : " + aFull[1] + "," + aFull[2] + "," + aFull[3]

chk("an opaque image IS its own colour", _Near(aFull, [ 0, 0, 255 ], 6))
chk("a half-alpha image is neither the ground...",
    NOT _Near(aHalf, GROUND, 20))
chk("...nor the image colour", NOT _Near(aHalf, [ 0, 0, 255 ], 20))
chk("...but lies between the two", aHalf[3] > 90 and aHalf[1] > 60)

#---------------------------------------------------------------------------
? ""
? "-- 3. A shape must survive the box a DIAGRAM gives it -------"
#
# Every node shape was first drawn in a friendly 140x100. A diagram hands
# over whatever the layout produced -- 300x40 for a long label, 26x200 in a
# tall column. The cylinder's cap is the case that broke: its depth was a
# fraction of the HEIGHT alone, so a tall box made an ellipse deeper than
# it was wide.
#
# Read off the model rather than the pixels: a cap is an ellipse, and the
# property is "rx >= ry" -- foreshortening only ever flattens.
#---------------------------------------------------------------------------

nBadCap = 0
cWorst = ""
for aBox in [ [ 140, 100 ], [ 300, 40 ], [ 26, 200 ], [ 40, 300 ], [ 200, 26 ] ]
	oD = new stzCanvas(400, 400)
	oD.SetBackgroundQ("#FFFFFF").FillQ("#3C6E9A")
	StzDrawNodeShape(oD, :Cylinder, 20, 20, aBox[1], aBox[2])
	for aE in _CapsIn(oD.ToSVG())
		if aE[1] < aE[2]
			nBadCap++
			if cWorst = ""
				cWorst = "" + aBox[1] + "x" + aBox[2] + " -> rx " + aE[1] +
					" ry " + aE[2]
			ok
		ok
	next
next
? "   cylinder caps deeper than they are wide : " + nBadCap
if cWorst != ""  ? "   worst : " + cWorst  ok
chkeq("a cylinder's cap is an ellipse foreshortening can produce", nBadCap, 0)

# THE NEGATIVE SIBLING: the reading is done by _EllipsesIn, so prove it can
# SEE a bad cap. This is the geometry the old formula produced at 26x200.
oE = new stzCanvas(120, 260)
oE.SetBackgroundQ("#FFFFFF").FillQ("#3C6E9A")
oE.AddEllipse(60, 40, 13, 26)              # rx 13, ry 26 -- the old defect
nSeen = 0
for aE in _CapsIn(oE.ToSVG())
	if aE[1] < aE[2]  nSeen++  ok
next
? "   the old geometry, drawn deliberately, is seen : " + nSeen + " time(s)"
chk("the cap check DISCRIMINATES", nSeen = 1)

#---------------------------------------------------------------------------
? ""
? "-- 4. Boxes must FIT the rank they landed in ----------------"
#
# Counted in pixels: the BACKGROUND must still be visible between one box
# and the next.
#
# The obvious instrument was counting runs of the NODE colour and expecting
# sixteen. It answered sixteen whether the boxes were separated or fused,
# because every box is STROKED -- two abutting boxes are still two runs of
# green with a dark border between them. It was measuring "sixteen boxes
# were drawn", which was never in doubt, and not "sixteen boxes can be told
# apart", which is the whole property. Gaps of background are the thing a
# reader actually sees.
#---------------------------------------------------------------------------

NODEC = "#2E7D32"
oG = new stzDiagram("fan")
oG.AddNodeXTT("root", "Root", [ :type = "box", :color = NODEC ])
for i = 1 to 16
	oG.AddNodeXTT("k" + i, "Kid " + i, [ :type = "box", :color = NODEC ])
	oG.AddEdge("root", "k" + i)
next

aOpt = [ :Width = 1200, :Height = 500, :NodeWidth = 96, :NodeHeight = 34 ]
nFit = _GapsInDensestRow(oG.ToCanvasXT(aOpt), 1200, 500, NODEC)
? "   16 nodes in a 1200px picture, boxes asked for 96px wide"
? "   gaps of background between them : " + nFit + " (16 boxes -> 15 gaps)"
chkeq("every node in the rank can be told from its neighbour", nFit, 15)

# THE NEGATIVE SIBLING, and the proof that the fit pass is what fixed it:
# the same picture with fitting switched OFF must fuse the boxes into a wall.
aOff = [ :Width = 1200, :Height = 500, :NodeWidth = 96, :NodeHeight = 34,
         :FitBoxes = 0 ]
nRaw = _GapsInDensestRow(oG.ToCanvasXT(aOff), 1200, 500, NODEC)
? "   the same picture with :FitBoxes = FALSE : " + nRaw + " gaps"
chk("without fitting the boxes really do run together", nRaw < 15)

# and the mechanism itself, where the arithmetic is visible
? "   scale for 16 nodes 82px apart, 96px boxes : " +
  oG._RankFitScale(_Rank(16, 82), 96, 34)
chk("a crowded rank scales DOWN", oG._RankFitScale(_Rank(16, 82), 96, 34) < 1)
chk("a roomy rank is left ALONE", oG._RankFitScale(_Rank(4, 300), 96, 34) = 1)

#---------------------------------------------------------------------------
? ""
? "-- 5. A label reaches the picture AS AUTHORED ---------------"
#
# Asserted at the far end -- in the drawn output -- because the defect this
# replaces was invisible everywhere upstream of it.
#
# NOT by looking for the string in the SVG. The first version did, and both
# its assertions were vacuous: this renderer converts glyphs to geometry, so
# an SVG of a picture reading "VP Sales" contains neither "VP Sales" nor
# "VP_Sales" -- "it says the right thing" and "it never says the wrong
# thing" were both true of a file containing no text whatsoever.
#
# What CAN be asserted about a rasterised label is that the two spellings
# produce different pictures, and that one spelling always produces the
# same one. Then "the label reaches the picture" is a claim about ink.
#---------------------------------------------------------------------------

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
cSpace  = _LabelPixels("VP Sales", oFont)
cScore  = _LabelPixels("VP_Sales", oFont)
cAgain  = _LabelPixels("VP Sales", oFont)

chk("the same label renders the same picture twice", cSpace = cAgain)
chk("a space and an underscore are NOT the same picture", cSpace != cScore)

oH = new stzDiagram("org")
oH.AddNodeXTT("vp", "VP Sales", [ :type = "box", :color = "Primary.Solid" ])
chk("...and the label a diagram carries is the one authored",
    oH.Nodes()[1][:label] = "VP Sales")
chk("the dot export carries it too, quoted",
    StzFindFirst('label="VP Sales"', oH.ToDot()) > 0)

oI = new stzGraph("nl")
oI.AddNodeXT("@x", "two" + char(10) + "lines")
chk("a NEWLINE is still normalised -- it would break the emitted dot",
    oI.Nodes()[1][:label] = "two_lines")

#---------------------------------------------------------------------------
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

func _Solid nW, nH, r, g, b, a
	_sc_ = ""
	for _si_ = 1 to nW * nH
		_sc_ += char(r) + char(g) + char(b) + char(a)
	next
	return _sc_

func _PixelAt cPx, nW, nX, nY
	_pa_ = (nY * nW + nX) * 4 + 1
	return [ ascii(substr(cPx, _pa_, 1)), ascii(substr(cPx, _pa_ + 1, 1)),
	         ascii(substr(cPx, _pa_ + 2, 1)) ]

func _Near aGot, aWant, nTol
	for _ni_ = 1 to 3
		_nd_ = aGot[_ni_] - aWant[_ni_]
		if _nd_ < 0  _nd_ = -_nd_  ok
		if _nd_ > nTol  return FALSE  ok
	next
	return TRUE

# [ [ halfWidth, halfHeight ], ... ] for every POLYGON in an SVG.
#
# It reads polygons and not <ellipse> tags, and that correction is the whole
# reason the negative sibling below exists. The first version of this
# function looked for `<ellipse`, which the SVG tier never emits -- it
# flattens an ellipse to a polygon. So it found nothing, reported "0 caps
# deeper than wide", and the assertion PASSED on a canvas containing a
# deliberately broken cap. A check that reads the wrong tag agrees with
# every shape in the world.
func _CapsIn cSvg
	_ca_ = []
	_clen_ = StzLen(cSvg)
	for _cn_ in StzFindAll('<polygon points="', cSvg)
		_ctail_ = StzSubStr(cSvg, _cn_, min([ 4000, _clen_ - _cn_ + 1 ]))
		_cq_ = StzFindFirst('"', StzSubStr(_ctail_, 18, StzLen(_ctail_) - 17))
		if _cq_ = 0  loop  ok
		_cpts_ = StzSubStr(_ctail_, 18, _cq_ - 1)
		_cminx_ = -1  _cmaxx_ = -1  _cminy_ = -1  _cmaxy_ = -1
		for _cpair_ in StzSplit(_cpts_, " ")
			_cxy_ = StzSplit(StzTrim(_cpair_), ",")
			if len(_cxy_) != 2  loop  ok
			try
				_cx_ = 0 + _cxy_[1]
				_cy_ = 0 + _cxy_[2]
			catch
				loop
			done
			if _cminx_ < 0 or _cx_ < _cminx_  _cminx_ = _cx_  ok
			if _cmaxx_ < 0 or _cx_ > _cmaxx_  _cmaxx_ = _cx_  ok
			if _cminy_ < 0 or _cy_ < _cminy_  _cminy_ = _cy_  ok
			if _cmaxy_ < 0 or _cy_ > _cmaxy_  _cmaxy_ = _cy_  ok
		next
		if _cmaxx_ >= 0
			_ca_ + [ (_cmaxx_ - _cminx_) / 2, (_cmaxy_ - _cminy_) / 2 ]
		ok
	next
	return _ca_

func _HexRGB cHex
	_hh_ = StzUpper(StzReplace("" + cHex, "#", ""))
	if StzLen(_hh_) != 6  return [ -1, -1, -1 ]  ok
	_hd_ = "0123456789ABCDEF"
	_hr_ = []
	for _hi_ = 0 to 2
		_hA_ = StzFindFirst(StzSubStr(_hh_, _hi_ * 2 + 1, 1), _hd_) - 1
		_hB_ = StzFindFirst(StzSubStr(_hh_, _hi_ * 2 + 2, 1), _hd_) - 1
		if _hA_ < 0 or _hB_ < 0  return [ -1, -1, -1 ]  ok
		_hr_ + (_hA_ * 16 + _hB_)
	next
	return _hr_

# In the row containing the most of cHex, how many stretches of BACKGROUND
# separate one painted box from the next.
#
# Background and not the node colour, and gaps and not runs, for the reason
# in section 4: a stroked box that abuts its neighbour still reads as two
# runs of fill, so counting fill can never see the collision it was written
# to detect.
func _GapsInDensestRow oCanvas, nW, nH, cHex
	_mc_ = _HexRGB(cHex)
	_mpx_ = oCanvas.ToPixels()

	# The densest row: the one with the most node paint in it. Found on a
	# 4x4 STRIDE and then read in full -- a Ring loop over every pixel of a
	# 1200x500 canvas is 600,000 substr calls and takes minutes, which is
	# how the first version of this file came to be killed rather than run.
	# A box is tens of pixels tall, so a stride of 4 cannot miss one.
	_mrow_ = -1
	_mbest_ = 0
	for _my_ = 0 to nH - 1 step 4
		_mn_ = 0
		for _mx_ = 0 to nW - 1 step 4
			if _IsRGB(_mpx_, nW, _mx_, _my_, _mc_)  _mn_++  ok
		next
		if _mn_ > _mbest_  _mbest_ = _mn_  _mrow_ = _my_  ok
	next
	if _mrow_ < 0  return -1  ok

	# only BETWEEN the first and last box, so the empty canvas either side
	# is not counted as a gap
	_mfirst_ = -1  _mlast_ = -1
	for _mx_ = 0 to nW - 1
		if _IsRGB(_mpx_, nW, _mx_, _mrow_, _mc_)
			if _mfirst_ < 0  _mfirst_ = _mx_  ok
			_mlast_ = _mx_
		ok
	next
	if _mfirst_ < 0  return -1  ok

	_mgaps_ = 0
	_mlen_ = 0
	for _mx_ = _mfirst_ to _mlast_
		if _IsRGB(_mpx_, nW, _mx_, _mrow_, [ 255, 255, 255 ])
			_mlen_++
		else
			# 2px, so a stroke plus its antialiasing is never a "gap"
			if _mlen_ >= 2  _mgaps_++  ok
			_mlen_ = 0
		ok
	next
	if _mlen_ >= 2  _mgaps_++  ok
	return _mgaps_

# One node, one label, rendered -- the bytes of the picture.
func _LabelPixels cLabel, oFont
	_lo_ = new stzDiagram("lbl")
	_lo_.AddNodeXTT("n", cLabel, [ :type = "box", :color = "Primary.Solid" ])
	return _lo_.ToCanvasXT([ :Width = 300, :Height = 140, :Font = oFont ]).
		ToPixels()

func _IsRGB cPx, nW, nX, nY, aRGB
	_ir_ = (nY * nW + nX) * 4 + 1
	return ascii(substr(cPx, _ir_, 1)) = aRGB[1] and
	       ascii(substr(cPx, _ir_ + 1, 1)) = aRGB[2] and
	       ascii(substr(cPx, _ir_ + 2, 1)) = aRGB[3]

# n nodes on one row, nGap apart -- the shape _RankFitScale reads.
func _Rank nCount, nGap
	_ra_ = []
	for _ri_ = 1 to nCount
		_ra_ + [ "n" + _ri_, 40 + (_ri_ - 1) * nGap, 100 ]
	next
	return _ra_
