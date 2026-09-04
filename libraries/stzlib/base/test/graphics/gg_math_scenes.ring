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

# A right isosceles triangle: the right angle at A marked, AB and AC
# ticked equal -- the two-column proof's first two lines, drawn.
func StzMathScene10(poFont)
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
	_o_ = new stzMathDiagram(StzGeometryDomain(), _oS_, StzEuclideanStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("right-isosceles")
	return _o_
