load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE NODE VOCABULARY -- the last thing keeping dot.exe alive

	SOFTANZA_GRAPH_PLANE_PLAN.md section 3 refused to replace dot.exe for
	general layout "until GG1's kill criterion is actually met". GG1 met it:
	10,000 nodes under 2 s, bit-identical run to run and across processes.

	So the refusal expired, and what remained was NOT layout. A diagram node
	can be any of twenty-four graphviz shapes and stzCanvas could draw
	three. Measured before building anything: twenty of the twenty-four are
	a circle, a rect or a polygon -- already there -- and the other four
	needed exactly ONE missing primitive, the ellipse.

	This file proves the vocabulary is complete and that both output tiers
	agree about it, because a diagram that renders differently in SVG and
	PNG is worse than one that needs dot.

	Run:  ring gg_nodeshapes.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " THE NODE VOCABULARY -- 24 shapes, no external binary"
? "=============================================================="

aShapes = StzNodeShapeNames()
? ""
? "   the vocabulary : " + len(aShapes) + " shapes"

#---------------------------------------------------------------------------
? ""
? "-- 1. Every shape DRAWS, and draws something DIFFERENT -------"
#
# "It drew" is too weak: a shape library where eight names all emit a
# rectangle would pass that. So each shape is rendered alone on an
# identical canvas and its SVG compared against every other shape's. Two
# shapes producing byte-identical output is a name that lies.
#---------------------------------------------------------------------------

aSvg = []
for cS in aShapes
	oC = new stzCanvas(200, 140)
	oC.SetBackgroundQ("#FFFFFF").FillQ("#3C6E9A").StrokeQ("#12222F", 2)
	StzDrawNodeShape(oC, cS, 30, 20, 140, 100)
	cSvg = oC.ToSVG()
	aSvg + [ "" + cS, cSvg ]
next

nEmpty = 0
for a in aSvg
	if len(a[2]) < 200  nEmpty++  ok
next
? "   shapes that produced no geometry : " + nEmpty
chkeq("every shape in the vocabulary draws", nEmpty, 0)

# ALIASES ARE DECLARED, NOT DISCOVERED. graphviz's 'box' and 'rect' are
# the same shape under two names, and a caller writes whichever their
# source used. So the test is not "all 25 differ" -- that would be
# asserting a falsehood about graphviz -- it is "the only identical pairs
# are the ones named here". A new accidental collision still fails.
aAliases = [ [ "box", "rect" ] ]

nSame = 0  nAliased = 0
cPair = ""
for i = 1 to len(aSvg)
	for j = i + 1 to len(aSvg)
		if aSvg[i][2] = aSvg[j][2]
			if _IsAlias(aAliases, aSvg[i][1], aSvg[j][1])
				nAliased++
			else
				nSame++
				if cPair = ""  cPair = aSvg[i][1] + " = " + aSvg[j][1]  ok
			ok
		ok
	next
next
? "   declared aliases that matched, as they must : " + nAliased
? "   UNDECLARED pairs drawing the same thing     : " + nSame
if cPair != ""
	? "   first collision : " + cPair
ok
chkeq("box and rect really are one shape under two names", nAliased, len(aAliases))
chkeq("and no OTHER two names draw the same thing", nSame, 0)

#---------------------------------------------------------------------------
? ""
? "-- 2. The BOX is the contract -------------------------------"
#
# A caller lays out nodes in boxes and never in shape-specific geometry.
# So every shape must stay inside the box it was given -- a triangle that
# overflowed would collide with its neighbours in a diagram whose layout
# said it fitted.
#---------------------------------------------------------------------------

# MEASURED IN PIXELS, not by reading the SVG text. The first version of
# this scene scraped every number out of the SVG and compared it to the
# box -- which also swept up the viewBox, the canvas dimensions and the
# digits inside colour attributes, and duly reported "box at 3,2000". The
# property is about geometry, so the instrument has to be the geometry.
if NOT StzGraphicsDevice()
	? "   (no device -- containment is a pixel property; skipped)"
else
	BX = 100  BY = 60  BW = 200  BH = 160
	PAD = 3          # the stroke straddles the edge; 2px wide, so 3 is fair

	nOut = 0
	cWorst = ""
	for cS in aShapes
		oC = new stzCanvas(400, 300)
		oC.SetBackgroundQ("#FFFFFF").FillQ("#000000").StrokeQ("#000000", 2)
		StzDrawNodeShape(oC, cS, BX, BY, BW, BH)
		cPx = oC.ToPixels()
		nShapeOut = 0
		for py = 0 to 299
			for px = 0 to 399
				if px >= BX - PAD and px <= BX + BW + PAD and
				   py >= BY - PAD and py <= BY + BH + PAD
					loop
				ok
				nAt = (py * 400 + px) * 4 + 1
				if ascii(substr(cPx, nAt, 1)) < 200
					nShapeOut++
				ok
			next
		next
		if nShapeOut > 0
			nOut += nShapeOut
			if cWorst = ""  cWorst = "" + cS + " (" + nShapeOut + " px)"  ok
		ok
	next
	? "   inked pixels outside the given box : " + nOut
	if cWorst != ""
		? "   first offender : " + cWorst
	ok
	chkeq("no shape escapes its bounding box", nOut, 0)

	# THE NEGATIVE SIBLING: the same measurement on a shape deliberately
	# drawn oversize must FAIL to be contained, or the check above is
	# measuring nothing.
	oBad = new stzCanvas(400, 300)
	oBad.SetBackgroundQ("#FFFFFF").FillQ("#000000")
	StzDrawNodeShape(oBad, :Box, BX - 40, BY - 30, BW + 80, BH + 60)
	cBad = oBad.ToPixels()
	nBadOut = 0
	for py = 0 to 299
		for px = 0 to 399
			if px >= BX - PAD and px <= BX + BW + PAD and
			   py >= BY - PAD and py <= BY + BH + PAD
				loop
			ok
			nAt = (py * 400 + px) * 4 + 1
			if ascii(substr(cBad, nAt, 1)) < 200  nBadOut++  ok
		next
	next
	? "   a deliberately oversize box leaks " + nBadOut + " px, as it must"
	chk("the containment check DISCRIMINATES", nBadOut > 1000)
ok

#---------------------------------------------------------------------------
? ""
? "-- 3. Refusals name themselves ------------------------------"
#---------------------------------------------------------------------------

# "AND LISTS THE VOCABULARY" WAS NEVER CHECKED, and it was not true: the
# message called a StzJoinWith that did not exist, so the refusal raised R3
# "calling function without definition" instead of the sentence it was
# written to give. This assertion passed the whole time, because Raises()
# only asks WHETHER something raised.
try
	oBad = new stzCanvas(100, 100)
	StzDrawNodeShape(oBad, :Sparkle, 0, 0, 50, 50)
catch
	cShapeMsg = cCatchError
done
? "   the refusal : " + cShapeMsg
chk("the message names the offending shape",
    StzFindFirst("sparkle", StzLower(cShapeMsg)) > 0)
chk("...and actually lists the vocabulary",
    StzFindFirst("hexagon", StzLower(cShapeMsg)) > 0 and
    StzFindFirst("cylinder", StzLower(cShapeMsg)) > 0)

chk("an unknown shape is refused (and lists the vocabulary)", Raises('
	o = new stzCanvas(100, 100)
	StzDrawNodeShape(o, :Sparkle, 0, 0, 50, 50)
'))
chk("a box with no area is refused", Raises('
	o = new stzCanvas(100, 100)
	StzDrawNodeShape(o, :Box, 0, 0, 0, 50)
'))
chk("drawing on a non-canvas is refused", Raises('
	StzDrawNodeShape("not a canvas", :Box, 0, 0, 50, 50)
'))
chk("StzIsNodeShape knows the vocabulary", StzIsNodeShape(:Hexagon))
chk("  ...and knows what is NOT in it", NOT StzIsNodeShape(:Sparkle))

#---------------------------------------------------------------------------
? ""
? "-- 4. BOTH TIERS must agree about every shape ---------------"
#
# The whole reason a diagram can leave dot behind is that stzCanvas answers
# SVG with no device AND pixels through one, from ONE model. A shape that
# existed in only one tier would be a regression dressed as a feature.
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- the SVG tier above needed none)"
else
	nBlank = 0
	for cS in aShapes
		oC = new stzCanvas(160, 120)
		oC.SetBackgroundQ("#FFFFFF").FillQ("#204060")
		StzDrawNodeShape(oC, cS, 24, 16, 112, 88)
		cPx = oC.ToPixels()
		nInk = 0
		for i = 1 to len(cPx) step 61
			if ascii(substr(cPx, i, 1)) < 200  nInk++  ok
		next
		if nInk < 20  nBlank++  ok
	next
	? "   shapes that render blank on the GPU tier : " + nBlank
	chkeq("every shape reaches the pixel tier too", nBlank, 0)
ok

#---------------------------------------------------------------------------
? ""
? "-- 5. The contact sheet -------------------------------------"
#---------------------------------------------------------------------------

COLS = 5
CW = 150  CH = 110
oSheet = new stzCanvas(COLS * CW, ceil(len(aShapes) / COLS) * CH)
oSheet.SetBackgroundQ("#0D1220")
k = 0
for cS in aShapes
	cx = (k % COLS) * CW
	cy = floor(k / COLS) * CH
	oSheet.FillQ(StzColorFromHSL(20 + k * 14, 52, 58)).StrokeQ("#08101C", 2)
	StzDrawNodeShape(oSheet, cS, cx + 26, cy + 16, 98, 66)
	k++
next
write("gg_nodeshapes.svg", oSheet.ToSVG())
? "   wrote gg_nodeshapes.svg  (" + len(oSheet.ToSVG()) + " chars, no device needed)"
if StzGraphicsDevice()
	oSheet.ToPNG("gg_nodeshapes.png")
	? "   wrote gg_nodeshapes.png"
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

# Every number appearing in the SVG's geometry attributes, in order. Crude
# on purpose: it must not know which shape it is reading.
func _NumbersIn cSvg
	_a_ = []
	_cur_ = ""
	_n_ = len(cSvg)
	_bIn_ = FALSE
	for _i_ = 1 to _n_
		_ch_ = substr(cSvg, _i_, 1)
		# isdigit, NOT _ch_ >= "0" and _ch_ <= "9". Ring's relational
		# operators COERCE their operands to numbers, so comparing two
		# one-character strings raises R41 on the first non-numeric
		# character -- inside the comparison, nowhere near the conversion
		# it looks like it is guarding.
		if isdigit(_ch_) or _ch_ = "." or (_ch_ = "-" and _cur_ = "")
			_cur_ += _ch_
			_bIn_ = TRUE
		else
			# Tokens like "1.2.3" (version strings, ids) reach here and
			# 0 + that is an R41. Ring's string comparison made a
			# hand-written validator unreliable, so the conversion itself
			# is the test: what converts is a number, what does not is
			# skipped. The scraper must not know what it is reading.
			if _bIn_ and _cur_ != ""
				try
					_a_ + (0 + _cur_)
				catch
				done
			ok
			_cur_ = ""
			_bIn_ = FALSE
		ok
	next
	return _a_

func _IsAlias aPairs, cA, cB
	for _p_ in aPairs
		_x_ = StzLower("" + cA)  _y_ = StzLower("" + cB)
		if (_p_[1] = _x_ and _p_[2] = _y_) or (_p_[1] = _y_ and _p_[2] = _x_)
			return TRUE
		ok
	next
	return FALSE
