# THE MATHEMATICAL-DIAGRAM SCENES, AS FUNCTIONS TWO FILES SHARE.
#
# The catalogue renders them; the gate holds them to their constraints.
# Written once, here, for the reason gg_drakon_scenes gives: a family
# written in two places drifts. Each takes the font it renders with.
#
# Functions only: loading this file draws nothing.

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

# Penrose's tree.substance -- the README's own example: seven sets, six
# Subset and three Disjoint relations.
func StzMathScene02(poFont)
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
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), _oS_, StzEulerStyle())
	_o_.SetFont(poFont, 28)
	_o_.SetVariation("PlumvilleCapybara104")
	return _o_

# Penrose's nested.substance: a chain seven deep, the case the paper
# says "disks must shrink exponentially" for.
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

# A CONTRADICTION: B inside A and apart from A. Penrose's Fig. 2 -- the
# solver must fail gracefully and SAY so, never crash.
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
