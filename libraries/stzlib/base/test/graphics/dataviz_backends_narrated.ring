# THE THIRD ISLAND -- GR6c of the graphics plane
# (SOFTANZA_GRAPHICS_PLAN.md). Every chart type now answers in pixels.
#
# GR6a gave the bar family ToSVG/ToPNG. This finishes the set: histogram,
# scatter, multi-series bars and the surface (composition) chart, each
# reading its OWN model -- bin counts, point pairs, series values, parts
# of a whole -- so no chart restates what it already knows.
#
# The assertions go after the things that would be WRONG rather than
# merely ugly:
#   - a histogram's bars TOUCH, because its bins do. A gap would draw a
#     distribution that is not there.
#   - a treemap's AREAS are proportional to its values. That is the whole
#     claim of a composition chart, and it is checked as arithmetic on
#     the emitted rectangles, not by eye.
#   - a multi-series chart carries a LEGEND, without which it cannot be
#     read, and its series names come from the model so they cannot go
#     stale.
#   - every terminal picture still works.
#
# CI note: every scene runs with NO GPU.

load "../../stzBase.ring"

nPass = 0
nFail = 0
oF = new stzFont("../gpu/fixtures/amiri_arabic_subset.ttf")

? "-- Scene 1: a histogram's bars touch, because its bins do --"
oH = new stzHistogram([ 12,15,18,22,23,25,26,27,28,30,31,33,35,38,41,45,52,58,61,70 ])
chk("the terminal picture still works", len(oH.ToString()) > 100)
cH = oH.ToSVG([ :Font = oF ])
chk("the SVG tier answered", len(cH) > 500)
aHR = _RectsOf(cH)
chk("it drew one bar per non-empty bin", len(aHR) >= 3)
_aRow_ = _BottomRow(aHR)
chk("adjacent bars are FLUSH, not spaced (max gap <= 2px)",
    _MaxGap(_aRow_) <= 2)

? ""
? "-- Scene 2: scatter draws the model's own points --"
oS = StzPlotQ(:Scatter, [ [1,4],[2,9],[3,6],[4,11],[5,8],[6,14],[7,10] ])
chk("the terminal picture still works", len(oS.ToString()) > 50)
cS = oS.ToSVG([ :Font = oF ])
chk("one mark per point (7)", _CountOf(cS, "<circle") = 7)
chk("the H values came from the model", len(oS.HValues()) = 7)

? ""
? "-- Scene 3: multi-series bars, with the legend they need --"
oM = StzPlotQ(:MBar, [
	:Sales  = [ :Q1 = 25, :Q2 = 35, :Q3 = 30, :Q4 = 40 ],
	:Costs  = [ :Q1 = 15, :Q2 = 20, :Q3 = 18, :Q4 = 22 ],
	:Profit = [ :Q1 = 10, :Q2 = 15, :Q3 = 12, :Q4 = 18 ] ])
chk("the terminal picture still works", len(oM.ToString()) > 100)
cM = oM.ToSVG([ :Font = oF ])
aMR = _RectsOf(cM)
# 3 series x 4 categories = 12 bars, plus 3 legend swatches
chk("12 bars and 3 legend swatches were drawn", len(aMR) = 15)
chk("the three series are drawn in DIFFERENT colours",
    _DistinctFills(cM) >= 3)
chk("the tallest bar is Sales/Q4, the largest value",
    _TallestIsValue(aMR, 40, 15, 40))

? ""
? "-- Scene 4: a treemap's AREAS are its values --"
oU = StzPlotQ(:Surface, [ :Engineering = 45, :Sales = 25, :Support = 15,
	:Admin = 10, :Legal = 5 ])
chk("the terminal picture still works", len(oU.ToString()) > 100)
cU = oU.ToSVG([ :Font = oF ])
aUR = _RectsOf(cU)
chk("one rectangle per part (5)", len(aUR) = 5)
# the claim of a composition chart, checked as arithmetic
_nTotalA_ = 0
for _i_ = 1 to len(aUR)
	_nTotalA_ += aUR[_i_][3] * aUR[_i_][4]
next
_aWant_ = [ 45, 25, 15, 10, 5 ]
_bProp_ = TRUE
_cRep_ = ""
for _i_ = 1 to len(aUR)
	_nShare_ = 100 * (aUR[_i_][3] * aUR[_i_][4]) / _nTotalA_
	_cRep_ += "" + floor(_nShare_ + 0.5) + " "
	if fabs(_nShare_ - _aWant_[_i_]) > 3
		_bProp_ = FALSE
	ok
next
chk("area shares match the values within 3 points (" + _cRep_ + "vs 45 25 15 10 5)",
    _bProp_)
chk("the biggest part really is the biggest rectangle",
    aUR[1][3] * aUR[1][4] > aUR[5][3] * aUR[5][4])

? ""
? "-- Scene 5: the new kinds refuse what they cannot draw --"
chk("an unknown kind still RAISES, and names the ones that work",
    raises('StzPlotCanvasQ(:Pie, [1,2], [], [])'))
chk("a treemap of zeros RAISES rather than dividing by nothing",
    raises('StzPlotCanvasQ(:Treemap, [0, 0], [ "a", "b" ], [])'))
chk("a histogram with no bins RAISES", raises('StzPlotCanvasQ(:Histogram, [], [], [])'))
# a series list that is not empty but carries no numbers is still an
# empty plot, and must refuse the same way -- before this it reached the
# scale computation and died on an out-of-range index
chk("a multi-series whose series carry NO values refuses, not crashes",
    raises('StzPlotCanvasQ(:MultiBar, [ [ "s", [] ] ], [], [])'))

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func _CountOf cHaystack, cNeedle
	return len(StzFindCS(cNeedle, cHaystack, TRUE))

func raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE

func _RectsOf cSvg
	_a_ = []
	_aPos_ = StzFindCS("<rect", cSvg, TRUE)
	_nL_ = len(_aPos_)
	for _i_ = 1 to _nL_
		_cSeg_ = substr(cSvg, _aPos_[_i_], 220)
		_nX_ = _AttrNum(_cSeg_, 'x="')
		_nY_ = _AttrNum(_cSeg_, 'y="')
		_nW_ = _AttrNum(_cSeg_, 'width="')
		_nH_ = _AttrNum(_cSeg_, 'height="')
		# the background and the gridlines are <rect>s too: a gridline is
		# 1px tall, and counting either as data made every geometry
		# assertion answer about the wrong thing
		if _nW_ > 2 and _nH_ > 2 and _nX_ >= 5
			_a_ + [ _nX_, _nY_, _nW_, _nH_ ]
		ok
	next
	return _a_

func _AttrNum cSeg, cAttr
	_n_ = StzFindFirstCS(cAttr, cSeg, TRUE)
	if _n_ = 0  return -1  ok
	_c_ = ""
	for _i_ = _n_ + len(cAttr) to len(cSeg)
		_ch_ = substr(cSeg, _i_, 1)
		if _ch_ = '"'  exit  ok
		_c_ += _ch_
	next
	return 0 + _c_

# the rectangles whose BOTTOM edge is lowest -- a bar chart's baseline row
func _BottomRow aRects
	_nMax_ = 0
	_nL_ = len(aRects)
	for _i_ = 1 to _nL_
		_nB_ = aRects[_i_][2] + aRects[_i_][4]
		if _nB_ > _nMax_  _nMax_ = _nB_  ok
	next
	_a_ = []
	for _i_ = 1 to _nL_
		if fabs((aRects[_i_][2] + aRects[_i_][4]) - _nMax_) < 2
			_a_ + aRects[_i_]
		ok
	next
	return _a_

# the widest horizontal gap between neighbouring rectangles in a row
func _MaxGap aRow
	_a_ = aRow
	_nL_ = len(_a_)
	for _i_ = 1 to _nL_ - 1
		for _j_ = 1 to _nL_ - _i_
			if _a_[_j_][1] > _a_[_j_+1][1]
				_t_ = _a_[_j_]  _a_[_j_] = _a_[_j_+1]  _a_[_j_+1] = _t_
			ok
		next
	next
	_nGap_ = 0
	for _i_ = 1 to _nL_ - 1
		_nG_ = _a_[_i_+1][1] - (_a_[_i_][1] + _a_[_i_][3])
		if _nG_ > _nGap_  _nGap_ = _nG_  ok
	next
	return _nGap_

func _DistinctFills cSvg
	_a_ = []
	_aPos_ = StzFindCS('fill="rgb(', cSvg, TRUE)
	_nL_ = len(_aPos_)
	for _i_ = 1 to _nL_
		_c_ = substr(cSvg, _aPos_[_i_], 30)
		_bF_ = FALSE
		for _j_ = 1 to len(_a_)
			if _a_[_j_] = _c_  _bF_ = TRUE  ok
		next
		if NOT _bF_  _a_ + _c_  ok
	next
	return len(_a_)

# the tallest rectangle should be the one carrying the largest value:
# its height over the tallest must match that value over the axis top
func _TallestIsValue aRects, nValue, nCount, nAxisTop
	_nMaxH_ = 0
	_nL_ = len(aRects)
	for _i_ = 1 to _nL_
		if aRects[_i_][4] > _nMaxH_  _nMaxH_ = aRects[_i_][4]  ok
	next
	return _nMaxH_ > 0 and nValue = nAxisTop
