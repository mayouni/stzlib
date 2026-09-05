# THE MATHEMATICAL-DIAGRAM SCENES, AS FUNCTIONS TWO FILES SHARE.
#
# The catalogue renders them; the gate holds them to their constraints.
# Written once, here, for the reason gg_drakon_scenes gives: a family
# written in two places drifts. Each takes the font it renders with.
#
# Functions only: loading this file draws nothing.

#-- set theory (DN7a) ----------------------------------------------------

# Penrose's twosets-simple.substance: "Set A, B; Subset(B, A)".
func StzMathScene01(poFont)
	_oS_ = new stzMathSubstance(StzSetTheoryDomain())
	_oS_.DeclareAll("Set", [ "A", "B" ])
	_oS_.Assert("Subset", [ "B", "A" ])
	_oS_.AutoLabelAll()
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), _oS_, StzEulerStyle())
	_o_.SetFont(poFont, 28)
	_o_.SetVariation("twosets")
	return _o_

# Penrose's tree.substance -- the README's own example.
func StzMathTreeSubstance()
	_oS_ = new stzMathSubstance(StzSetTheoryDomain())
	_oS_.DeclareAll("Set", [ "A", "B", "C", "D", "E", "F", "G" ])
	_oS_.Assert("Subset", [ "B", "A" ])
	_oS_.Assert("Subset", [ "C", "A" ])
	_oS_.Assert("Subset", [ "D", "B" ])
	_oS_.Assert("Subset", [ "E", "B" ])
	_oS_.Assert("Subset", [ "F", "C" ])
	_oS_.Assert("Subset", [ "G", "C" ])
	_oS_.Assert("Disjoint", [ "E", "D" ])
	_oS_.Assert("Disjoint", [ "F", "G" ])
	_oS_.Assert("Disjoint", [ "B", "C" ])
	_oS_.AutoLabelAll()
	return _oS_

func StzMathScene02(poFont)
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), StzMathTreeSubstance(), StzEulerStyle())
	_o_.SetFont(poFont, 28)
	_o_.SetVariation("PlumvilleCapybara104")
	return _o_

# Penrose's nested.substance: a chain seven deep.
func StzMathScene03(poFont)
	_oS_ = new stzMathSubstance(StzSetTheoryDomain())
	_oS_.DeclareAll("Set", [ "A", "B", "C", "D", "E", "F", "G" ])
	_oS_.Assert("Subset", [ "B", "A" ])
	_oS_.Assert("Subset", [ "C", "B" ])
	_oS_.Assert("Subset", [ "D", "C" ])
	_oS_.Assert("Subset", [ "E", "D" ])
	_oS_.Assert("Subset", [ "F", "E" ])
	_oS_.Assert("Subset", [ "G", "F" ])
	_oS_.AutoLabelAll()
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), _oS_, StzEulerStyle())
	_o_.SetFont(poFont, 22)
	_o_.SetVariation("nested")
	return _o_

# Three sets meeting pairwise -- the Venn picture, via Intersecting.
func StzMathScene04(poFont)
	_oS_ = new stzMathSubstance(StzSetTheoryDomain())
	_oS_.DeclareAll("Set", [ "A", "B", "C" ])
	_oS_.Assert("Intersecting", [ "A", "B" ])
	_oS_.Assert("Intersecting", [ "B", "C" ])
	_oS_.Assert("Intersecting", [ "C", "A" ])
	_oS_.AutoLabelAll()
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), _oS_, StzEulerStyle())
	_o_.SetFont(poFont, 28)
	_o_.SetVariation("venn")
	return _o_

# A CONTRADICTION: B inside A and apart from A. Penrose's Fig. 2.
func StzMathScene05(poFont)
	_oS_ = new stzMathSubstance(StzSetTheoryDomain())
	_oS_.DeclareAll("Set", [ "A", "B" ])
	_oS_.Assert("Subset", [ "B", "A" ])
	_oS_.Assert("Disjoint", [ "A", "B" ])
	_oS_.AutoLabelAll()
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), _oS_, StzEulerStyle())
	_o_.SetFont(poFont, 28)
	_o_.SetVariation("contradiction")
	return _o_

#-- one substance, another representation (DN7b) --------------------------

# THE SAME tree.substance as scene 02, drawn by Penrose's tree.style: a
# name per set and an arrow from each subset up to its superset. Not a
# different diagram -- a different reading of one content.
func StzMathScene06(poFont)
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), StzMathTreeSubstance(), StzTreeStyle())
	_o_.SetFont(poFont, 26)
	_o_.SetVariation("tree-as-tree")
	return _o_

#-- linear algebra (DN7b) ----------------------------------------------------

# Penrose's twoVectorsPerp.substance: a unit vector and one orthogonal to it.
func StzMathScene07(poFont)
	_oS_ = new stzMathSubstance(StzLinearAlgebraDomain())
	_oS_.Declare("VectorSpace", "X")
	_oS_.DeclareAll("Vector", [ "x1", "x2" ])
	_oS_.Assert("In", [ "x1", "X" ])
	_oS_.Assert("In", [ "x2", "X" ])
	_oS_.Assert("Unit", [ "x1" ])
	_oS_.Assert("Orthogonal", [ "x1", "x2" ])
	_oS_.AutoLabelAll()
	_o_ = new stzMathDiagram(StzLinearAlgebraDomain(), _oS_, StzVectorStyle())
	_o_.SetFont(poFont, 22)
	_o_.SetVariation("perp")
	return _o_

# The tutorial's third chapter: u := addV(v, w), the sum ending where the
# parallelogram says, by construction.
func StzMathScene08(poFont)
	_oS_ = new stzMathSubstance(StzLinearAlgebraDomain())
	_oS_.Declare("VectorSpace", "U")
	_oS_.DeclareAll("Vector", [ "v", "w" ])
	_oS_.Define("u", "addV", [ "v", "w" ])
	_oS_.Assert("In", [ "u", "U" ])
	_oS_.Assert("In", [ "v", "U" ])
	_oS_.Assert("In", [ "w", "U" ])
	_oS_.Assert("Independent", [ "v", "w" ])
	_oS_.AutoLabelAll()
	_o_ = new stzMathDiagram(StzLinearAlgebraDomain(), _oS_, StzVectorStyle())
	_o_.SetFont(poFont, 22)
	_o_.SetVariation("addition")
	return _o_

#-- Euclidean geometry (DN7b) ------------------------------------------------

# Penrose's general-triangle.substance: three points and their triangle.
func StzMathScene09(poFont)
	_oS_ = new stzMathSubstance(StzGeometryDomain())
	_oS_.DeclareAll("Point", [ "A", "B", "C" ])
	_oS_.Define("ABC", "Triangle", [ "A", "B", "C" ])
	_oS_.AutoLabelAll()
	_oS_.Label("ABC", "")
	_o_ = new stzMathDiagram(StzGeometryDomain(), _oS_, StzEuclideanStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("triangle")
	return _o_

# A right isosceles triangle: the right angle at A, AB and AC equal --
# the two-column proof's first two lines. ONE substance, and scenes 10, 11
# and 12 are its three geometries: Penrose's Fig. 1.
func StzMathRightIsoscelesSubstance()
	_oS_ = new stzMathSubstance(StzGeometryDomain())
	_oS_.DeclareAll("Point", [ "A", "B", "C" ])
	_oS_.Define("AB", "Segment", [ "A", "B" ])
	_oS_.Define("AC", "Segment", [ "A", "C" ])
	_oS_.Define("BC", "Segment", [ "B", "C" ])
	_oS_.Define("BAC", "InteriorAngle", [ "B", "A", "C" ])
	_oS_.Assert("Right", [ "BAC" ])
	_oS_.Assert("EqualLength", [ "AB", "AC" ])
	_oS_.AutoLabelAll()
	_oS_.Label("AB", "")  _oS_.Label("AC", "")  _oS_.Label("BC", "")  _oS_.Label("BAC", "")
	return _oS_

func StzMathScene10(poFont)
	_o_ = new stzMathDiagram(StzGeometryDomain(), StzMathRightIsoscelesSubstance(), StzEuclideanStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("right-isosceles")
	return _o_

#-- the same statements, on a sphere and in the hyperbolic plane (DN7c) ----

func StzMathScene11(poFont)
	_o_ = new stzMathDiagram(StzGeometryDomain(), StzMathRightIsoscelesSubstance(), StzSphericalStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("on-a-sphere")
	return _o_

func StzMathScene12(poFont)
	_o_ = new stzMathDiagram(StzGeometryDomain(), StzMathRightIsoscelesSubstance(), StzHyperbolicStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("in-the-disk")
	return _o_

#-- Byrne's Euclid I.47 (DN7d) --------------------------------------------

# The right triangle alone: no equal sides, no segments -- Byrne's figure
# is built by the STYLE from the three points and the right angle.
func StzMathByrneSubstance()
	_oS_ = new stzMathSubstance(StzGeometryDomain())
	_oS_.DeclareAll("Point", [ "A", "B", "C" ])
	_oS_.Define("ABC", "Triangle", [ "A", "B", "C" ])
	_oS_.Define("BAC", "InteriorAngle", [ "B", "A", "C" ])
	_oS_.Assert("Right", [ "BAC" ])
	_oS_.AutoLabelAll()
	_oS_.Label("ABC", "")  _oS_.Label("BAC", "")
	return _oS_

func StzMathScene13(poFont)
	_o_ = new stzMathDiagram(StzGeometryDomain(), StzMathByrneSubstance(), StzByrneStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("byrne")
	return _o_

#-- three more domains, to show the engine's range (DN7e) ------------------

# A partial order has no coordinates to be faithful to, so a Hasse diagram
# is pure LAYOUT -- the opposite end of the engine from Byrne, where every
# coordinate was forced by the construction.
func StzMathLatticeSubstance(pacElems, paCovers, paSameRank, pacLabels)
	_oS_ = new stzMathSubstance(StzOrderDomain())
	_oS_.DeclareAll("Element", pacElems)
	for _i_ = 1 to len(paCovers)
		_oS_.Define("c" + _i_, "Cover", paCovers[_i_])
		_oS_.Label("c" + _i_, "")
	next
	for _i_ = 1 to len(paSameRank)
		_oS_.Assert("SameRank", paSameRank[_i_])
	next
	for _i_ = 1 to len(pacElems)
		_oS_.Label(pacElems[_i_], pacLabels[_i_])
	next
	return _oS_

# the divisors of 12, ordered by divisibility
func StzMathScene14(poFont)
	_oS_ = StzMathLatticeSubstance(
		[ "n1", "n2", "n3", "n4", "n6", "n12" ],
		[ [ "n2", "n1" ], [ "n3", "n1" ], [ "n4", "n2" ], [ "n6", "n2" ],
		  [ "n6", "n3" ], [ "n12", "n4" ], [ "n12", "n6" ] ],
		[ [ "n2", "n3" ], [ "n4", "n6" ] ],
		[ "1", "2", "3", "4", "6", "12" ])
	_o_ = new stzMathDiagram(StzOrderDomain(), _oS_, StzHasseStyle())
	_o_.SetFont(poFont, 21)
	# SEVEN OF TEN VARIATIONS DRAW THIS WITHOUT A CROSSING, and the style
	# never asked for one: nothing in the engine forbids two edges meeting.
	# Picking the seed is what Penrose's variations are for.
	_o_.SetVariation("divides")
	return _o_

# the divisors of 36 -- a three by three grid, and level-planar, where the
# powerset of three letters is the cube and cannot be drawn on levels
# without crossings
func StzMathScene17(poFont)
	_oS_ = StzMathLatticeSubstance(
		[ "m1", "m2", "m3", "m4", "m6", "m9", "m12", "m18", "m36" ],
		[ [ "m2", "m1" ], [ "m3", "m1" ], [ "m4", "m2" ], [ "m6", "m2" ],
		  [ "m6", "m3" ], [ "m9", "m3" ], [ "m12", "m4" ], [ "m12", "m6" ],
		  [ "m18", "m6" ], [ "m18", "m9" ], [ "m36", "m12" ], [ "m36", "m18" ] ],
		[ [ "m2", "m3" ], [ "m4", "m6" ], [ "m4", "m9" ], [ "m12", "m18" ] ],
		[ "1", "2", "3", "4", "6", "9", "12", "18", "36" ])
	_o_ = new stzMathDiagram(StzOrderDomain(), _oS_, StzHasseStyle())
	_o_.SetFont(poFont, 20)
	# AND HERE ONLY ONE SEED OF TWELVE DRAWS IT CLEAN, against seven of ten
	# on the divisors of 12. Nothing in the engine forbids two edges from
	# meeting, so the odds of a readable picture fall as the lattice grows
	# -- which is the argument for a crossing term, not a reason to distrust
	# the pictures.
	_o_.SetVariation("nine")
	return _o_

# A commuting square is not an illustration of an equation -- it IS how the
# equation is written. So here the layout carries the content and the
# coordinates carry none of it.
func StzMathScene15(poFont)
	_oS_ = new stzMathSubstance(StzCategoryDomain())
	_oS_.DeclareAll("Object", [ "A", "B", "C", "D" ])
	_oS_.Define("f", "Arrow", [ "A", "B" ])
	_oS_.Define("g", "Arrow", [ "B", "D" ])
	_oS_.Define("h", "Arrow", [ "A", "C" ])
	_oS_.Define("k", "Arrow", [ "C", "D" ])
	_oS_.Assert("CommutingSquare", [ "A", "B", "C", "D" ])
	_oS_.AutoLabelAll()
	_o_ = new stzMathDiagram(StzCategoryDomain(), _oS_, StzCommutativeStyle())
	_o_.SetFont(poFont, 26)
	_o_.SetVariation("commuting-square")
	return _o_

func StzMathScene18(poFont)
	_oS_ = new stzMathSubstance(StzCategoryDomain())
	_oS_.DeclareAll("Object", [ "X", "Y", "Z" ])
	_oS_.Define("f", "Arrow", [ "X", "Y" ])
	_oS_.Define("g", "Arrow", [ "Y", "Z" ])
	_oS_.Define("h", "Arrow", [ "X", "Z" ])
	_oS_.Assert("CommutingTriangle", [ "X", "Y", "Z" ])
	_oS_.AutoLabelAll()
	_o_ = new stzMathDiagram(StzCategoryDomain(), _oS_, StzCommutativeStyle())
	_o_.SetFont(poFont, 26)
	_o_.SetVariation("commuting-triangle")
	return _o_

# THALES, and the kill Byrne's figure taught. The substance says three
# things -- B and C are on the circle, BC runs through its centre, A is on
# the circle -- and never that the angle at A is right. Every place the
# solver may put A gives a right angle, so the mark is a claim about the
# picture that the picture was never asked to satisfy.
func StzMathThalesSubstance()
	_oS_ = new stzMathSubstance(StzGeometryDomain())
	_oS_.Declare("Circle", "K")
	_oS_.DeclareAll("Point", [ "B", "C", "A" ])
	_oS_.Define("BC", "Segment", [ "B", "C" ])
	_oS_.Define("AB", "Segment", [ "A", "B" ])
	_oS_.Define("AC", "Segment", [ "A", "C" ])
	_oS_.Define("ABC", "Triangle", [ "A", "B", "C" ])
	_oS_.Define("BAC", "InteriorAngle", [ "B", "A", "C" ])
	_oS_.Assert("OnCircle", [ "B", "K" ])
	_oS_.Assert("OnCircle", [ "C", "K" ])
	_oS_.Assert("OnCircle", [ "A", "K" ])
	_oS_.Assert("Diameter", [ "BC", "K" ])
	_oS_.AutoLabelAll()
	for _c_ in [ "K", "BC", "AB", "AC", "ABC", "BAC" ]
		_oS_.Label(_c_, "")
	next
	return _oS_

func StzMathScene16(poFont)
	_o_ = new stzMathDiagram(StzGeometryDomain(), StzMathThalesSubstance(),
		StzThalesStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("thales")
	return _o_
