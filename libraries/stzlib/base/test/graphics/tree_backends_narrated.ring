# HIERARCHIES GAIN PIXELS -- GR6b of the graphics plane
# (SOFTANZA_GRAPHICS_PLAN.md).
#
# The diagram family reaches SVG by shelling out to an external dot.exe.
# Graph LAYOUT is a deep specialty and stays there -- but a TREE does not
# need it. stzTreeCanvas lays a hierarchy out here, so an org chart needs
# no external binary at all and gains a PNG tier that rasterizing dot's
# SVG could never have given (this plane has no SVG parser).
#
# What this guard protects:
#   - the LAYOUT, asserted as geometry rather than eyeballed: a parent is
#     centred over its children, siblings do not overlap, depth grows
#     downward, and a wider subtree pushes its neighbours aside
#   - ToDot() is UNTOUCHED -- the graph path still belongs to the tool
#     that does graph layout for a living
#   - the org chart reads its own model (ids, titles, reportsTo) into the
#     tree without the caller restating it
#   - forests, single nodes and cycles all answer honestly
#
# CI note: every scene runs with NO GPU -- the SVG tier is the floor.

load "../../stzBase.ring"

nPass = 0
nFail = 0
oF = new stzFont("../gpu/fixtures/amiri_arabic_subset.ttf")

# a balanced tree whose geometry is easy to reason about
aTree = [
	[ "r",  "Root",  "" ],
	[ "a",  "A",     "r" ],
	[ "b",  "B",     "r" ],
	[ "a1", "A1",    "a" ],
	[ "a2", "A2",    "a" ],
	[ "b1", "B1",    "b" ],
	[ "b2", "B2",    "b" ]
]

? "-- Scene 1: a hierarchy becomes a picture, with no device --"
oC = StzTreeCanvasQ(aTree, [ :Font = oF, :Title = "A tree" ])
chk("a canvas came back", isObject(oC) and oC.Width() > 0)
cSvg = oC.ToSVG()
chk("the SVG tier answered", len(cSvg) > 500)
chk("one box per node (7)", len(_RectsOf(cSvg)) = 7)
# 6 connectors (one per non-root node) + 7 box outlines: a stroked
# rectangle is emitted as a closed polyline, so both share the element
chk("6 connectors + 7 box outlines = 13 polylines",
    _CountOf(cSvg, "<polyline") = 13)
chk("labels became glyph outlines", substr(cSvg, '<path d="M') > 0)

? ""
? "-- Scene 2: the LAYOUT is right, asserted as geometry --"
# 4 leaves take slots 0..3; A centres over A1,A2 (0.5), B over B1,B2 (2.5),
# Root over A,B (1.5). With the default 168-wide node and 26 gap, slot k
# starts at margin + k*194.
aBoxes = _RectsOf(cSvg)
chk("7 boxes were emitted", len(aBoxes) = 7)
_aByY_ = _SortByY(aBoxes)
chk("the root sits on the top row", _aByY_[1][2] < _aByY_[3][2])
chk("depth grows downward: 3 distinct rows", _DistinctY(aBoxes) = 3)
# the root's centre must equal the mean of its children's centres
_nRootCx_ = _CenterXOfRow(aBoxes, 1)
_nMidCx_  = _CenterXOfRow(aBoxes, 2)
chk("a parent is CENTRED over its children (" + _nRootCx_ + " vs " +
    _nMidCx_ + ")", abs(_nRootCx_ - _nMidCx_) < 2)
chk("siblings do not overlap", _NoOverlapInRows(aBoxes))

? ""
? "-- Scene 3: a wider subtree pushes its neighbours aside --"
aWide = [
	[ "r", "Root", "" ], [ "a", "A", "r" ], [ "b", "B", "r" ],
	[ "a1", "A1", "a" ], [ "a2", "A2", "a" ], [ "a3", "A3", "a" ],
	[ "a4", "A4", "a" ]
]
oW = StzTreeCanvasQ(aWide, [ :Font = oF ])
chk("four leaves under A make a wider canvas than two", oW.Width() > 700)
aWB = _RectsOf(oW.ToSVG())
chk("B was pushed clear of A's four children", _NoOverlapInRows(aWB))

? ""
? "-- Scene 4: forests, single nodes, and cycles answer honestly --"
oSingle = StzTreeCanvasQ([ [ "only", "Only", "" ] ], [ :Font = oF ])
chk("a single node draws", len(_RectsOf(oSingle.ToSVG())) = 1)
oForest = StzTreeCanvasQ([ [ "p", "P", "" ], [ "q", "Q", "" ],
	[ "p1", "P1", "p" ] ], [ :Font = oF ])
chk("two roots stand side by side (a forest)",
    _DistinctY(_RectsOf(oForest.ToSVG())) = 2)
chk("an empty hierarchy RAISES", raises('StzTreeCanvasQ([], [])'))
chk("a cycle RAISES rather than looping forever",
    raises('StzTreeCanvasQ([ [ "x", "X", "y" ], [ "y", "Y", "x" ] ], [])'))
# a node naming a parent that does not exist becomes a ROOT -- asserted
# through _RectsOf so the background rectangle cannot make it pass by
# coincidence, and on the ROW COUNT so it says something: one row means
# it really was treated as a root, not hung off something invisible
_aGhost_ = _RectsOf(StzTreeCanvasQ([ [ "n", "N", "ghost" ],
	[ "m", "M", "n" ] ], [ :Font = oF ]).ToSVG())
chk("a node naming an unknown parent becomes a ROOT", len(_aGhost_) = 2)
chk("and its own child still hangs beneath it", _DistinctY(_aGhost_) = 2)

? ""
? "-- Scene 5: a long label is TRUNCATED, never spilled --"
oLong = StzTreeCanvasQ([ [ "x",
	"An extremely long position title that cannot possibly fit", "" ] ],
	[ :Font = oF ])
chk("it still draws one box", len(_RectsOf(oLong.ToSVG())) = 1)
chk("and the label was shortened to fit the box",
    oF.WidthOf("An extremely long position title that cannot possibly fit", 15) > 152)

? ""
? "-- Scene 6: the org chart reads its OWN model --"
oOrg = new stzOrgChart("Acme")
oOrg.AddExecutiveXT("ceo", "Chief Executive")
oOrg.AddExecutiveXT("cto", "Chief Technology")
oOrg.AddManagerXT("eng", "Engineering Lead")
oOrg.AddStaffXT("dev", "Developer")
oOrg.ReportsTo("cto", "ceo")
oOrg.ReportsTo("eng", "cto")
oOrg.ReportsTo("dev", "eng")

aN = oOrg.ToTreeNodes()
chk("every position became a node", len(aN) = 4)
chk("ids and TITLES both travelled", aN[1][1] = "ceo" and aN[1][2] = "Chief Executive")
chk("the root reports to nobody", aN[1][3] = "")
chk("reportsTo became the parent link", aN[2][3] = "ceo")
cOrgSvg = oOrg.ToSVG([ :Font = oF, :Title = "Acme" ])
chk("the chart draws itself without dot.exe", len(_RectsOf(cOrgSvg)) = 4)
chk("it is a chain, so 4 distinct rows", _DistinctY(_RectsOf(cOrgSvg)) = 4)

? ""
? "-- Scene 7: the DOT path is untouched --"
cDot = oOrg.ToDot()
chk("ToDot still produces DOT text", len(cDot) > 20)
chk("and it still names the positions", substr(cDot, "ceo") > 0)
chk("the two outputs are different things, by design", cDot != cOrgSvg)

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

# [ [x, y, w, h], ... ] parsed out of the SVG's <rect> elements. Reading
# the emitted document is the honest way to check a layout: it is what a
# consumer sees, not what the renderer believes it did.
func _RectsOf cSvg
	_a_ = []
	_aPos_ = StzFindCS("<rect", cSvg, TRUE)
	_nL_ = len(_aPos_)
	for _i_ = 1 to _nL_
		_cSeg_ = substr(cSvg, _aPos_[_i_], 200)
		_nX_ = _AttrNum(_cSeg_, 'x="')
		_nY_ = _AttrNum(_cSeg_, 'y="')
		_nW_ = _AttrNum(_cSeg_, 'width="')
		_nH_ = _AttrNum(_cSeg_, 'height="')
		# skip the background: it is a <rect> too, and counting it as a
		# node silently added a phantom row to every geometry assertion
		if _nW_ > 0 and _nH_ > 0 and _nX_ >= 5
			_a_ + [ _nX_, _nY_, _nW_, _nH_ ]
		ok
	next
	return _a_

func _AttrNum cSeg, cAttr
	_n_ = StzFindFirstCS(cAttr, cSeg, TRUE)
	if _n_ = 0  return -1  ok
	_nStart_ = _n_ + len(cAttr)
	_c_ = ""
	for _i_ = _nStart_ to len(cSeg)
		_ch_ = substr(cSeg, _i_, 1)
		if _ch_ = '"'  exit  ok
		_c_ += _ch_
	next
	return 0 + _c_

func _SortByY aRects
	_a_ = aRects
	_nL_ = len(_a_)
	for _i_ = 1 to _nL_ - 1
		for _j_ = 1 to _nL_ - _i_
			if _a_[_j_][2] > _a_[_j_+1][2]
				_t_ = _a_[_j_]  _a_[_j_] = _a_[_j_+1]  _a_[_j_+1] = _t_
			ok
		next
	next
	return _a_

func _DistinctY aRects
	_a_ = []
	_nL_ = len(aRects)
	for _i_ = 1 to _nL_
		_bF_ = FALSE
		for _j_ = 1 to len(_a_)
			if abs(_a_[_j_] - aRects[_i_][2]) < 2  _bF_ = TRUE  ok
		next
		if NOT _bF_  _a_ + aRects[_i_][2]  ok
	next
	return len(_a_)

# mean centre-x of the nRow-th distinct row, counting from the top
func _CenterXOfRow aRects, nRow
	_aYs_ = []
	_nL_ = len(aRects)
	for _i_ = 1 to _nL_
		_bF_ = FALSE
		for _j_ = 1 to len(_aYs_)
			if abs(_aYs_[_j_] - aRects[_i_][2]) < 2  _bF_ = TRUE  ok
		next
		if NOT _bF_  _aYs_ + aRects[_i_][2]  ok
	next
	for _i_ = 1 to len(_aYs_) - 1
		for _j_ = 1 to len(_aYs_) - _i_
			if _aYs_[_j_] > _aYs_[_j_+1]
				_t_ = _aYs_[_j_]  _aYs_[_j_] = _aYs_[_j_+1]  _aYs_[_j_+1] = _t_
			ok
		next
	next
	if nRow > len(_aYs_)  return -1  ok
	_nY_ = _aYs_[nRow]
	_nSum_ = 0  _nCnt_ = 0
	for _i_ = 1 to _nL_
		if abs(aRects[_i_][2] - _nY_) < 2
			_nSum_ += aRects[_i_][1] + aRects[_i_][3] / 2
			_nCnt_++
		ok
	next
	if _nCnt_ = 0  return -1  ok
	return _nSum_ / _nCnt_

func _NoOverlapInRows aRects
	_nL_ = len(aRects)
	for _i_ = 1 to _nL_
		for _j_ = _i_ + 1 to _nL_
			if abs(aRects[_i_][2] - aRects[_j_][2]) < 2
				_nL1_ = aRects[_i_][1]  _nR1_ = _nL1_ + aRects[_i_][3]
				_nL2_ = aRects[_j_][1]  _nR2_ = _nL2_ + aRects[_j_][3]
				if _nL1_ < _nR2_ and _nL2_ < _nR1_
					return FALSE
				ok
			ok
		next
	next
	return TRUE
