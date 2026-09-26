#=====================================================================#
#  STZMATHSTORIES -- the plane's told figures: a picture built from    #
#  library code, a motion of declared states over it, facts bound       #
#=====================================================================#
/*
	A STORY is a picture and the states it is told through. The first is
	Euclid I.47 in Byrne's colours: three points, a triangle, a right
	angle at A, and a style under which every square and rectangle is an
	EXPRESSION over the three points -- so the picture cannot come apart
	when a point is dragged, and the equality a^2 + b^2 = c^2 is never
	asserted anywhere. It is read back out of the solved coordinates as
	a fact, in every state, and the gate holds it to zero.

	    oM = StzPythagorasMotionQ(StzMathFigureFont())
	    oM.PlayStates(oWindow, 2500)                # the window
	    oS = oM.ExportTo("folio", "pythagoras")     # the frames and the narration

	The domain and the style are the graph plane's (StzGeometryDomain,
	StzByrneStyle); the substance and the states are this plane's.
*/

# Byrne's I.47 from library code: three points, a triangle, a right angle
func StzPythagorasPictureQ(poFont)
	_oS_ = new stzMathSubstance(StzGeometryDomain())
	_oS_.DeclareAll("Point", [ "A", "B", "C" ])
	_oS_.Define("ABC", "Triangle", [ "A", "B", "C" ])
	_oS_.Define("BAC", "InteriorAngle", [ "B", "A", "C" ])
	_oS_.Assert("Right", [ "BAC" ])
	_oS_.AutoLabelAll()
	_oS_.Label("ABC", "")
	_oS_.Label("BAC", "")
	_o_ = new stzMathDiagram(StzGeometryDomain(), _oS_, StzByrneStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("byrne")
	_o_.Layout()
	return _o_

# the expression facts of I.47, over the picture's own coordinates
func StzPythagorasGapExpr()
	return "dist(A.icon, B.icon)^2 + dist(A.icon, C.icon)^2 - dist(B.icon, C.icon)^2"

# the story: four states, A dragged three times, the equality read at each
func StzPythagorasMotionQ(poFont)
	_oM_ = StzMathMotionOverQ(StzPythagorasPictureQ(poFont))
	_cA2_ = "dist(A.icon, B.icon)^2"
	_cB2_ = "dist(A.icon, C.icon)^2"
	_cC2_ = "dist(B.icon, C.icon)^2"

	_oM_.State("A right triangle ABC with its right angle at A ({angle} degrees), and a square " +
		"on each side. The square on the hypotenuse BC measures {c2} px^2; the squares on " +
		"AB and AC measure {a2} and {b2}. Their sum is {sum} px^2.", [])
	_oM_.StateFact("angle", :angle, [ "B.icon", "A.icon", "C.icon" ])
	_oM_.StateFact("c2", :expr, [ _cC2_, "px^2" ])
	_oM_.StateFact("a2", :expr, [ _cA2_, "px^2" ])
	_oM_.StateFact("b2", :expr, [ _cB2_, "px^2" ])
	_oM_.StateFact("sum", :expr, [ _cA2_ + " + " + _cB2_, "px^2" ])

	_oM_.State("Drag A up and to the right. The squares follow, the angle at A stays " +
		"{angle} degrees, and the two smaller squares still make the larger one: " +
		"a^2 + b^2 - c^2 = {gap} px^2.", [ [ :DragBy, "A.icon", 60, -30 ] ])
	_oM_.StateFact("angle", :angle, [ "B.icon", "A.icon", "C.icon" ])
	_oM_.StateFact("gap", :expr, [ StzPythagorasGapExpr(), "px^2" ])

	_oM_.State("Drag A down and to the left, past where it began. The hypotenuse square is " +
		"now {c2} px^2 and the sum of the other two is {sum} px^2: the difference is " +
		"{gap} px^2.", [ [ :DragBy, "A.icon", -110, 20 ] ])
	_oM_.StateFact("c2", :expr, [ _cC2_, "px^2" ])
	_oM_.StateFact("sum", :expr, [ _cA2_ + " + " + _cB2_, "px^2" ])
	_oM_.StateFact("gap", :expr, [ StzPythagorasGapExpr(), "px^2" ])

	_oM_.State("Bring A back. Nothing in the picture asserts the equality: every square is " +
		"derived from the three points, and a^2 + b^2 - c^2 = {gap} px^2 is what the " +
		"coordinates read back. That is Euclid I.47, a consequence of the construction.",
		[ [ :DragBy, "A.icon", 50, 10 ] ])
	_oM_.StateFact("gap", :expr, [ StzPythagorasGapExpr(), "px^2" ])
	return _oM_

#-- the chaos game --------------------------------------------------------

# THE CHAOS GAME, from library code: three corners, a starting point, and a
# rule -- pick a corner at random, go halfway to it, put a dot. Nothing is
# solved: every dot is data, held by the dot domain and drawn as it is. The
# picture that appears is Sierpinski's triangle, and its two signatures are
# checked, never assumed, by StzChaosGameCounts.
func StzChaosGameCorners()
	return [ [ 320, 40 ], [ 40, 560 ], [ 600, 560 ] ]

func StzChaosGamePictureQ(poFont, pnDots, pnSeed)
	_o_ = new stzMathDiagram(StzDotDomain(), StzChaosGameSubstance(pnDots, pnSeed), StzDotStyle())
	_o_.SetFont(poFont, 12)
	_o_.SetVariation("chaos")
	_o_.Layout()
	return _o_

func StzChaosGameSubstance(pnDots, pnSeed)
	if NOT isNumber(pnDots) or pnDots < 1 or pnDots > 20000
		stzraise("StzChaosGameSubstance: between 1 and 20,000 dots.")
	ok
	_aV_ = StzChaosGameCorners()
	SeedRandom(pnSeed)
	_aX_ = []  _aY_ = []
	_x_ = 320  _y_ = 300
	for _i_ = 1 to pnDots
		_k_ = floor(StzRandom01() * 3) + 1
		if _k_ > 3  _k_ = 3  ok
		_x_ = (_x_ + _aV_[_k_][1]) / 2
		_y_ = (_y_ + _aV_[_k_][2]) / 2
		_aX_ + _x_  _aY_ + _y_
	next
	_o_ = new stzMathSubstance(StzDotDomain())
	_o_.DeclareMany("Dot", "d", pnDots)
	_o_.SetDataFrom("d", "x", _aX_)
	_o_.SetDataFrom("d", "y", _aY_)
	return _o_

# [ inside the outer triangle, inside the central hole ] over the first
# pnDots dots of a chaos-game picture -- two facts read off the dots by an
# independent point-in-triangle test, so the fractal's signature (all in,
# none in the hole) is measured, not a property any dot was given
func StzChaosGameCounts(poPicture, pnDots)
	_aV_ = StzChaosGameCorners()
	_aT_ = [ _aV_[1][1], _aV_[1][2], _aV_[2][1], _aV_[2][2], _aV_[3][1], _aV_[3][2] ]
	_aH_ = [ (_aV_[1][1] + _aV_[2][1]) / 2, (_aV_[1][2] + _aV_[2][2]) / 2,
	         (_aV_[1][1] + _aV_[3][1]) / 2, (_aV_[1][2] + _aV_[3][2]) / 2,
	         (_aV_[2][1] + _aV_[3][1]) / 2, (_aV_[2][2] + _aV_[3][2]) / 2 ]
	_nIn_ = 0  _nHole_ = 0
	for _i_ = 1 to pnDots
		_x_ = poPicture.ValueOf("d" + _i_ + ".icon.cx")
		_y_ = poPicture.ValueOf("d" + _i_ + ".icon.cy")
		if _CgIn(_x_, _y_, _aT_, 0)  _nIn_++  ok
		if _CgIn(_x_, _y_, _aH_, 0.5)  _nHole_++  ok
	next
	return [ _nIn_, _nHole_ ]

# inside a triangle: the three cross products of one sign; pnMargin > 0
# asks for STRICTLY inside, so a dot on the hole's edge is not in the hole
func _CgIn(px, py, paT, pnMargin)
	_s_ = []
	for _i_ = 1 to 3
		_j_ = (_i_ % 3) + 1
		_c_ = (paT[2*_j_-1] - paT[2*_i_-1]) * (py - paT[2*_i_]) - (paT[2*_j_] - paT[2*_i_]) * (px - paT[2*_i_-1])
		_s_ + _c_
	next
	return (_s_[1] >= pnMargin and _s_[2] >= pnMargin and _s_[3] >= pnMargin) or
	       (_s_[1] <= -pnMargin and _s_[2] <= -pnMargin and _s_[3] <= -pnMargin)
