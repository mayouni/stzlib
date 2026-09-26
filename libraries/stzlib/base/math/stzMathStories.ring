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
