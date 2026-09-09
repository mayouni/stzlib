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

#-- the graph family, the largest in Penrose's gallery (DN7f) --------------

# the dodecahedral graph: Hamilton's Icosian game of 1857, which is where
# the word "Hamiltonian" comes from, with one of its cycles marked
func StzMathDodecahedronSubstance()
	_oS_ = new stzMathSubstance(StzGraphDomain())
	_acV_ = []
	for _i_ = 0 to 9  _acV_ + ("u" + _i_)  next
	for _i_ = 0 to 9  _acV_ + ("v" + _i_)  next
	_oS_.DeclareAll("Vertex", _acV_)
	_n_ = 0
	for _i_ = 0 to 9
		_n_++  _oS_.Define("e" + _n_, "Edge", [ "u" + _i_, "u" + ((_i_ + 1) % 10) ])
		_n_++  _oS_.Define("e" + _n_, "Edge", [ "u" + _i_, "v" + _i_ ])
		_n_++  _oS_.Define("e" + _n_, "Edge", [ "v" + _i_, "v" + ((_i_ + 2) % 10) ])
	next
	_acC_ = [ "u0", "u1", "u2", "u3", "u4", "u5", "u6", "u7", "v7", "v5", "v3",
	          "v1", "v9", "u9", "u8", "v8", "v6", "v4", "v2", "v0" ]
	StzMathMarkCycle(_oS_, _acC_, "e", 30)
	return _oS_

# mark every edge of a cycle Highlighted, whichever way round it was defined
func StzMathMarkCycle(poS, pacCycle, pcEdgePrefix, pnEdges)
	_m_ = len(pacCycle)
	for _k_ = 1 to _m_
		_cA_ = pacCycle[_k_]
		_cB_ = pacCycle[(_k_ % _m_) + 1]
		for _j_ = 1 to pnEdges
			if poS.IsDefinedAs(pcEdgePrefix + _j_, "Edge", [ _cA_, _cB_ ]) or
			   poS.IsDefinedAs(pcEdgePrefix + _j_, "Edge", [ _cB_, _cA_ ])
				poS.Assert("Highlighted", [ pcEdgePrefix + _j_ ])
			ok
		next
	next

# THE LIMIT, kept in the catalogue on purpose. Twenty vertices from a
# random start: the hard node-link style cannot satisfy its own rules (79
# open on the crossing term alone), and the soft one settles at 17
# crossings on its best seed of eight. Neither is a picture of a
# dodecahedron. A local optimiser does not find a planar embedding it was
# not started near, and no term changes that.
func StzMathScene19(poFont)
	_o_ = new stzMathDiagram(StzGraphDomain(), StzMathDodecahedronSubstance(),
		StzSpringGraphStyle())
	_o_.SetFont(poFont, 12)
	_o_.SetVariation("game")
	return _o_

# a computer network with one-way links
func StzMathScene20(poFont)
	_oS_ = new stzMathSubstance(StzGraphDomain())
	_oS_.DeclareAll("Vertex", [ "Client", "Gateway", "Firewall", "Switch", "Web", "DB", "Backup" ])
	_oS_.Define("l1", "Arc", [ "Client", "Gateway" ])
	_oS_.Define("l2", "Arc", [ "Gateway", "Firewall" ])
	_oS_.Define("l3", "Arc", [ "Firewall", "Switch" ])
	_oS_.Define("l4", "Arc", [ "Switch", "Web" ])
	_oS_.Define("l5", "Arc", [ "Switch", "DB" ])
	_oS_.Define("l6", "Arc", [ "Web", "DB" ])
	_oS_.Define("l7", "Arc", [ "DB", "Backup" ])
	_oS_.Define("l8", "Arc", [ "Web", "Client" ])
	_oS_.AutoLabelAll()
	for _i_ = 1 to 8  _oS_.Label("l" + _i_, "")  next
	_o_ = new stzMathDiagram(StzGraphDomain(), _oS_, StzGraphStyle())
	_o_.SetFont(poFont, 16)
	# one crossing on this seed, eight on the first tried -- until DN11,
	# when the planar start learned to embed the 2-core and hang the leaf
	# (Backup) off it: planar now, and no crossing
	_o_.SetVariation("links")
	return _o_

# THE SAME DOMAIN as boxes and arrows: a computer architecture
func StzMathScene21(poFont)
	_oS_ = new stzMathSubstance(StzGraphDomain())
	_oS_.DeclareAll("Vertex", [ "CPU", "Cache", "RAM", "Bus", "GPU", "Disk", "Network" ])
	_oS_.Define("a1", "Arc", [ "CPU", "Cache" ])
	_oS_.Define("a2", "Arc", [ "Cache", "RAM" ])
	_oS_.Define("a3", "Arc", [ "CPU", "Bus" ])
	_oS_.Define("a4", "Arc", [ "Bus", "GPU" ])
	_oS_.Define("a5", "Arc", [ "Bus", "Disk" ])
	_oS_.Define("a6", "Arc", [ "Bus", "Network" ])
	_oS_.Define("a7", "Arc", [ "RAM", "Bus" ])
	_oS_.AutoLabelAll()
	for _i_ = 1 to 7  _oS_.Label("a" + _i_, "")  next
	_o_ = new stzMathDiagram(StzGraphDomain(), _oS_, StzBoxArrowStyle())
	_o_.SetFont(poFont, 18)
	_o_.SetVariation("architecture")
	return _o_

# a word cloud: the Minkowski separation of DN7d with nothing else
func StzMathScene22(poFont)
	_oS_ = new stzMathSubstance(StzWordDomain())
	_oS_.DeclareAll("Word", [ "Softanza", "Ring", "Zig", "diagram", "solver", "constraint",
		"style", "substance", "domain", "tape", "gradient", "canvas", "engine", "picture",
		"lawful", "Penrose", "layout", "seed" ])
	_oS_.Assert("Large", [ "Softanza" ])
	_oS_.Assert("Large", [ "diagram" ])
	for _c_ in [ "solver", "constraint", "engine", "Penrose", "style" ]
		_oS_.Assert("Medium", [ _c_ ])
	next
	_oS_.AutoLabelAll()
	_o_ = new stzMathDiagram(StzWordDomain(), _oS_, StzWordCloudStyle())
	_o_.SetFont(poFont, 17)
	_o_.SetVariation("cloud")
	return _o_

# the cube graph Q3 with a Hamiltonian cycle -- a Gray code
func StzMathCubeSubstance()
	_oS_ = new stzMathSubstance(StzGraphDomain())
	_acQ_ = [ "v000", "v001", "v010", "v011", "v100", "v101", "v110", "v111" ]
	_oS_.DeclareAll("Vertex", _acQ_)
	_n_ = 0
	for _i_ = 1 to 8
		for _j_ = _i_ + 1 to 8
			_d_ = 0
			for _b_ = 2 to 4
				if _acQ_[_i_][_b_] != _acQ_[_j_][_b_]  _d_++  ok
			next
			if _d_ = 1
				_n_++
				_oS_.Define("q" + _n_, "Edge", [ _acQ_[_i_], _acQ_[_j_] ])
			ok
		next
	next
	StzMathMarkCycle(_oS_, [ "v000", "v001", "v011", "v010", "v110", "v111", "v101", "v100" ], "q", _n_)
	_oS_.AutoLabelAll()
	for _i_ = 1 to _n_  _oS_.Label("q" + _i_, "")  next
	return _oS_

func StzMathScene23(poFont)
	_o_ = new stzMathDiagram(StzGraphDomain(), StzMathCubeSubstance(), StzSpringGraphStyle())
	_o_.SetFont(poFont, 15)
	# SEVEN CROSSINGS, the best of six seeds, and the cube is planar. The
	# crossing preference is in the energy and the solver cannot spend it:
	# from a random start every way out of a crossing passes through the
	# separation penalties, so the seed decides the basin and the weight
	# only its depth. Kept as the graph the engine cannot yet untangle.
	_o_.SetVariation("gray")
	return _o_

#-- splines (DN7h): blobs, a curved graph, Catmull-Rom -----------------------

# THE SAME seven-set tree as scenes 02 and 06, each set a blob
func StzMathScene24(poFont)
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), StzMathTreeSubstance(), StzBlobStyle())
	_o_.SetFont(poFont, 26)
	_o_.SetVariation("blobs")
	return _o_

# the cube again, its edges curved
func StzMathScene25(poFont)
	return StzMathScene25XT(poFont, "curved")

func StzMathScene25XT(poFont, pcSeed)
	_o_ = new stzMathDiagram(StzGraphDomain(), StzMathCubeSubstance(), StzCurvedGraphStyle())
	_o_.SetFont(poFont, 15)
	_o_.SetVariation(pcSeed)
	return _o_

# THE SEED THE ONE-WEDGE STORY IS TOLD ON. The story needs a picture where
# a name given ONE starting wedge ends past its leash and the retried name
# ends inside it. That was the catalogue's own seed until DN12 made every
# text box a tenth taller: on "curved" the single wedge now finds room for
# v111 first time (23 px, leash 44), so there was no failure to narrate.
# The seed moved twice in one day, and both moves are measurements: DN12's
# taller box let "curved" succeed first time, and DN13's corrected chord
# clearance with its 160px edge target let "one-wedge" succeed too. At the
# corrected style, sixteen seeds were swept: six strand v111 on one wedge
# (50 px against a 44 px leash) and land it inside on the retry, all six
# from a planar start -- and all SIXTEEN are clean under the one gate on
# the full solve and at 3x, where before DN13 two of twelve lawful
# pictures carried a name on the curve. The seed is the FIXTURE's, not the
# plane's -- the catalogue picture stays on "curved".
func StzMathOneWedgeStorySeed()
	return "second-wedge"

# six points and the Catmull-Rom curve through them
func StzMathScene26(poFont)
	_oS_ = new stzMathSubstance(StzPathDomain())
	_oS_.DeclareAll("Point", [ "P1", "P2", "P3", "P4", "P5", "P6" ])
	_oS_.Define("S", "Through", [ "P1", "P2", "P3", "P4", "P5", "P6" ])
	_oS_.AutoLabelAll()
	_oS_.Label("S", "")
	_o_ = new stzMathDiagram(StzPathDomain(), _oS_, StzCatmullStyle())
	_o_.SetFont(poFont, 18)
	_o_.SetVariation("catmull")
	return _o_

#-- ellipses (DN7i): sets in 2.5D, and the rays of an ellipse ----------------

# THE SAME seven-set tree a fourth time: solved as disks, drawn flattened
func StzMathScene27(poFont)
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), StzMathTreeSubstance(), StzEuler25DStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("two-and-a-half")
	return _o_

# an ellipse, its foci, and six rays from one focus to the other
func StzMathRaysSubstance()
	_oS_ = new stzMathSubstance(StzConicDomain())
	_oS_.Declare("Ellipse", "E")
	for _i_ = 1 to 6
		_oS_.Define("r" + _i_, "RayOf", [ "E" ])
	next
	return _oS_

func StzMathScene28(poFont)
	_o_ = new stzMathDiagram(StzConicDomain(), StzMathRaysSubstance(), StzEllipseRaysStyle())
	_o_.SetFont(poFont, 18)
	_o_.SetVariation("rays")
	return _o_

#-- a colour channel from substance data (DN7j) ----------------------------

# the quaternion group: 1 i j k -1 -i -j -k as 1..8; a product is computed
# on (sign, unit) with the unit table i.j = k, j.k = i, k.i = j
func StzMathQuaternionProduct(pnA, pnB)
	_sa_ = 1  _ua_ = pnA
	if pnA > 4  _sa_ = -1  _ua_ = pnA - 4  ok
	_sb_ = 1  _ub_ = pnB
	if pnB > 4  _sb_ = -1  _ub_ = pnB - 4  ok
	# unit products: [ [sign, unit] ] indexed [ua][ub], units 1=1 2=i 3=j 4=k
	_aT_ = [ [ [1,1], [1,2], [1,3], [1,4] ],
	         [ [1,2], [-1,1], [1,4], [-1,3] ],
	         [ [1,3], [-1,4], [-1,1], [1,2] ],
	         [ [1,4], [1,3], [-1,2], [-1,1] ] ]
	_r_ = _aT_[_ua_][_ub_]
	_s_ = _sa_ * _sb_ * _r_[1]
	if _s_ > 0  return _r_[2]  ok
	return _r_[2] + 4

func StzMathQuaternionSubstance()
	_acQ_ = [ "1", "i", "j", "k", "-1", "-i", "-j", "-k" ]
	_oS_ = new stzMathSubstance(StzTableDomain())
	for _r_ = 1 to 8
		_oS_.Declare("Head", "rh" + _r_)
		_oS_.SetData("rh" + _r_, "row", _r_)  _oS_.SetData("rh" + _r_, "col", 0)
		_oS_.Label("rh" + _r_, _acQ_[_r_])
		_oS_.Declare("Head", "ch" + _r_)
		_oS_.SetData("ch" + _r_, "row", 0)  _oS_.SetData("ch" + _r_, "col", _r_)
		_oS_.Label("ch" + _r_, _acQ_[_r_])
		for _c_ = 1 to 8
			_n_ = "c" + _r_ + "_" + _c_
			_p_ = StzMathQuaternionProduct(_r_, _c_)
			_oS_.Declare("Cell", _n_)
			_oS_.SetData(_n_, "row", _r_)  _oS_.SetData(_n_, "col", _c_)
			_oS_.SetData(_n_, "p", _p_)
			_oS_.Label(_n_, _acQ_[_p_])
		next
	next
	return _oS_

func StzMathScene29(poFont)
	_o_ = new stzMathDiagram(StzTableDomain(), StzMathQuaternionSubstance(),
		StzQuaternionTableStyle())
	_o_.SetFont(poFont, 22)
	_o_.SetVariation("quaternions")
	return _o_

# A . B = C, each cell coloured by its value on the matrix's own range
func StzMathMatrixSubstance()
	_aA_ = [ [ 2, 7, 1, 8 ], [ 2, 8, 1, 8 ], [ 2, 8, 4, 5 ] ]
	_aB_ = [ [ 9, 0, 4 ], [ 5, 2, 3 ], [ 5, 3, 6 ], [ 0, 2, 8 ] ]
	_aC_ = []
	for _i_ = 1 to 3
		_row_ = []
		for _j_ = 1 to 3
			_s_ = 0
			for _k_ = 1 to 4
				_s_ += _aA_[_i_][_k_] * _aB_[_k_][_j_]
			next
			_row_ + _s_
		next
		_aC_ + _row_
	next
	_oS_ = new stzMathSubstance(StzTableDomain())
	StzMathGrid(_oS_, "a", _aA_, 40, 110)
	StzMathGrid(_oS_, "b", _aB_, 330, 83)
	StzMathGrid(_oS_, "c", _aC_, 590, 110)
	_oS_.Declare("Glyph", "times")  _oS_.SetData("times", "x", 290)  _oS_.SetData("times", "y", 191)
	_oS_.Label("times", "x")
	_oS_.Declare("Glyph", "equals")  _oS_.SetData("equals", "x", 550)  _oS_.SetData("equals", "y", 191)
	_oS_.Label("equals", "=")
	_oS_.Declare("Head", "ha")  _oS_.SetData("ha", "x", 148)  _oS_.SetData("ha", "y", 60)  _oS_.Label("ha", "A  (3 x 4)")
	_oS_.Declare("Head", "hb")  _oS_.SetData("hb", "x", 411)  _oS_.SetData("hb", "y", 60)  _oS_.Label("hb", "B  (4 x 3)")
	_oS_.Declare("Head", "hc")  _oS_.SetData("hc", "x", 671)  _oS_.SetData("hc", "y", 60)  _oS_.Label("hc", "A . B  (3 x 3)")
	return _oS_

# a grid of cells named <prefix><row>_<col>, each with its row, column,
# origin, value and the value scaled to the grid's own range
func StzMathGrid(poS, pcPfx, paM, pnX0, pnY0)
	_lo_ = paM[1][1]  _hi_ = paM[1][1]
	for _i_ = 1 to len(paM)
		for _j_ = 1 to len(paM[_i_])
			if paM[_i_][_j_] < _lo_  _lo_ = paM[_i_][_j_]  ok
			if paM[_i_][_j_] > _hi_  _hi_ = paM[_i_][_j_]  ok
		next
	next
	for _i_ = 1 to len(paM)
		for _j_ = 1 to len(paM[_i_])
			_n_ = pcPfx + _i_ + "_" + _j_
			poS.Declare("Cell", _n_)
			poS.SetData(_n_, "row", _i_)  poS.SetData(_n_, "col", _j_)
			poS.SetData(_n_, "x0", pnX0)  poS.SetData(_n_, "y0", pnY0)
			poS.SetData(_n_, "v", paM[_i_][_j_])
			_t_ = 0
			if _hi_ > _lo_  _t_ = (paM[_i_][_j_] - _lo_) / (_hi_ - _lo_)  ok
			poS.SetData(_n_, "t", _t_)
			poS.Label(_n_, "" + paM[_i_][_j_])
		next
	next

func StzMathScene30(poFont)
	_o_ = new stzMathDiagram(StzTableDomain(), StzMathMatrixSubstance(), StzHeatmapStyle())
	_o_.SetFont(poFont, 19)
	_o_.SetVariation("heat")
	return _o_

#-- a graph is a substance (DN8a) -------------------------------------------

# the graph plane's own org chart, never a substance, made one and drawn
# by a Style: every position a Vertex, every reporting line an Arc
func StzMathOrgChart()
	_o_ = new stzOrgChart("acme")
	_o_.AddPositionXT("ceo", "Chief Executive")
	_o_.AddPositionXT("cto", "Technology")
	_o_.AddPositionXT("cfo", "Finance")
	_o_.AddPositionXT("eng", "Engineering")
	_o_.AddPositionXT("ops", "Operations")
	_o_.AddPositionXT("acc", "Accounting")
	_o_.ReportsTo("cto", "ceo")
	_o_.ReportsTo("cfo", "ceo")
	_o_.ReportsTo("eng", "cto")
	_o_.ReportsTo("ops", "cto")
	_o_.ReportsTo("acc", "cfo")
	return _o_

func StzMathScene31(poFont)
	_oS_ = StzSubstanceFromGraph(StzMathOrgChart(), StzGraphDomain(),
		[ :nodeType = "Vertex", :edgeConstructor = "Arc" ])
	_o_ = new stzMathDiagram(StzGraphDomain(), _oS_, StzBoxArrowStyle())
	_o_.SetFont(poFont, 17)
	_o_.SetVariation("acme")
	return _o_

#-- a notation's icons hold a formula (DN8e) ---------------------------------

# the graph plane's simplest DRAKON scene, rendered, its icons read back
# as rectangles and carried as data; a formula is a Glyph the substance
# says is Inside the action icon, and the polygon's edges hold it there.
# The caller loads gg_drakon_scenes.ring; this file does not, since the
# gate holds it already and a file loaded twice redefines its functions.
func StzMathScene33(poFont)
	_oD_ = StzDrakonScene01([ :Font = poFont, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 14 ])
	_aR_ = _oD_.@aRenderNodeRects
	_oS_ = new stzMathSubstance(StzTableDomain())
	for _i_ = 1 to len(_aR_)
		_cN_ = "icon_" + _aR_[_i_][5]
		_oS_.Declare("Cell", _cN_)
		_oS_.SetData(_cN_, "x", 160 + _aR_[_i_][1])  _oS_.SetData(_cN_, "y", 20 + _aR_[_i_][2])
		_oS_.SetData(_cN_, "w", _aR_[_i_][3])         _oS_.SetData(_cN_, "h", _aR_[_i_][4] + 40)
		_oS_.Label(_cN_, "" + _oD_.Node(_aR_[_i_][5])[:label])
	next
	_oS_.Declare("Glyph", "f")
	_oS_.Label("f", "c = a + b")
	_oS_.Assert("Inside", [ "f", "icon_a" ])
	_o_ = new stzMathDiagram(StzTableDomain(), _oS_, StzIconLabelStyle())
	_o_.SetFont(poFont, 15)
	_o_.SetVariation("icon")
	return _o_


#-- content generators, and the scale they expose (DN8f) -------------------

# THE CHAOS GAME. Five thousand points, each halfway from the last to a
# vertex of a triangle chosen at random -- Sierpinski's triangle, made by
# iteration in Ring and held as five thousand Dots with data. Nothing is
# solved: the content is the picture.
func StzMathSierpinskiSubstance(pnCount)
	_aV_ = [ [ 320, 40 ], [ 40, 560 ], [ 600, 560 ] ]
	SeedRandom(7)
	_aX_ = []  _aY_ = []
	_x_ = 320  _y_ = 300
	for _i_ = 1 to pnCount
		_k_ = floor(StzRandom01() * 3) + 1
		if _k_ > 3  _k_ = 3  ok
		_x_ = (_x_ + _aV_[_k_][1]) / 2
		_y_ = (_y_ + _aV_[_k_][2]) / 2
		_aX_ + _x_  _aY_ + _y_
	next
	_o_ = new stzMathSubstance(StzDotDomain())
	_o_.DeclareMany("Dot", "d", pnCount)
	_o_.SetDataFrom("d", "x", _aX_)
	_o_.SetDataFrom("d", "y", _aY_)
	return _o_

func StzMathScene34(poFont)
	_o_ = new stzMathDiagram(StzDotDomain(), StzMathSierpinskiSubstance(5000), StzDotStyle())
	_o_.SetFont(poFont, 12)
	_o_.SetVariation("chaos")
	return _o_

# THE NEPHROID AS AN ENVELOPE. A hundred and eighty circles, each centred
# on a base circle and each tangent to one diameter of it: no curve is
# drawn, and the nephroid -- two cusps, where the diameter meets the base
# circle -- appears where the circles crowd. (Through one POINT of the
# base circle instead, the same construction gives a cardioid.)
func StzMathNephroidSubstance(pnCount)
	_R_ = 130
	_cx_ = 320  _cy_ = 300
	_aX_ = []  _aY_ = []  _aR_ = []
	for _i_ = 1 to pnCount
		_t_ = 2 * 3.14159265358979 * (_i_ - 1) / pnCount
		_x_ = _cx_ + _R_ * cos(_t_)
		_y_ = _cy_ + _R_ * sin(_t_)
		_aX_ + _x_  _aY_ + _y_
		_aR_ + fabs(_y_ - _cy_)
	next
	_o_ = new stzMathSubstance(StzDotDomain())
	_o_.DeclareMany("Ring", "c", pnCount)
	_o_.SetDataFrom("c", "x", _aX_)
	_o_.SetDataFrom("c", "y", _aY_)
	_o_.SetDataFrom("c", "r", _aR_)
	# the base circle's centre, as a dot -- the diameter is the horizontal
	# through it
	_o_.Declare("Dot", "p")
	_o_.SetData("p", "x", _cx_)  _o_.SetData("p", "y", _cy_)
	return _o_

func StzMathScene35(poFont)
	_o_ = new stzMathDiagram(StzDotDomain(), StzMathNephroidSubstance(180), StzDotStyle())
	_o_.SetFont(poFont, 12)
	_o_.SetVariation("nephroid")
	return _o_

# BROWNIAN PATHS. Three walks of a thousand steps each, Gaussian steps by
# Box-Muller, kept on the paper by reflection; every step a definition
# Step(a, b) the matcher enumerates once, and its colour is which walk it
# is on, read off the step's own datum.
func StzMathBrownianSubstance(pnWalks, pnSteps)
	SeedRandom(11)
	_o_ = new stzMathSubstance(StzDotDomain())
	_acP_ = [ "a", "b", "c", "e", "f", "g" ]
	for _w_ = 1 to pnWalks
		_cP_ = _acP_[_w_]
		_aX_ = []  _aY_ = []
		_x_ = 320  _y_ = 300
		for _i_ = 1 to pnSteps + 1
			_aX_ + _x_  _aY_ + _y_
			_u1_ = StzRandom01()  _u2_ = StzRandom01()
			if _u1_ < 0.000001  _u1_ = 0.000001  ok
			_m_ = 7 * sqrt(-2 * log(_u1_))
			_x_ += _m_ * cos(2 * 3.14159265358979 * _u2_)
			_y_ += _m_ * sin(2 * 3.14159265358979 * _u2_)
			if _x_ < 30  _x_ = 60 - _x_  ok
			if _x_ > 610  _x_ = 1220 - _x_  ok
			if _y_ < 30  _y_ = 60 - _y_  ok
			if _y_ > 570  _y_ = 1140 - _y_  ok
		next
		_o_.DeclareMany("Dot", _cP_, pnSteps + 1)
		_o_.SetDataFrom(_cP_, "x", _aX_)
		_o_.SetDataFrom(_cP_, "y", _aY_)
		for _i_ = 1 to pnSteps
			_o_.Define("s" + _cP_ + _i_, "Step", [ _cP_ + _i_, _cP_ + (_i_ + 1) ])
			_o_.SetData("s" + _cP_ + _i_, "w", _w_)
		next
	next
	return _o_

func StzMathScene36(poFont)
	_o_ = new stzMathDiagram(StzDotDomain(), StzMathBrownianSubstance(3, 1000), StzDotStyle())
	_o_.SetFont(poFont, 12)
	_o_.SetVariation("brown")
	return _o_


#-- the live figure (DN8g) --------------------------------------------------

# BYRNE'S FIGURE, DRAGGED. The plate is solved cold, then its right-angle
# vertex A is taken sixty pixels right and thirty up, and the figure
# re-solves from where it stands: the squares follow their triangle, the
# areas find their squares again, and the angle at A is still right.
func StzMathScene37(poFont)
	_o_ = StzMathScene13(poFont)
	_o_.Layout()
	_o_.DragTo("A.icon", _o_.ValueOf("A.icon.cx") + 60, _o_.ValueOf("A.icon.cy") - 30)
	return _o_


#-- two storyboards: the plane's own kill (DN9f) ---------------------------

# THE EXPLANATION OF 2026-09-06, AS ONE STORYBOARD. Four frames over two
# solves of one content, every number in every caption bound to a fact,
# and the frames that show the flawed picture saying so.
func StzStoryOneWedge(poFont, pcFolio)
	_oBad_ = new stzMathDiagram(StzGraphDomain(), StzMathCubeSubstance(), StzCurvedGraphStyle())
	_oBad_.SetFont(poFont, 15)
	_oBad_.SetVariation(StzMathOneWedgeStorySeed())
	_oBad_._Compile()
	_oBad_._CompileViolationTapes()
	_oBad_._Initialise("planar")
	_oBad_._SolveStage(0)
	_oBad_._SolveStage(1)
	_oBad_._ReadViolations()
	_oBad_._FreeViolationTapes()
	_oBad_.@bLaidOut = 1
	_oBad_.@aVCache = []

	_o_ = new stzStoryboard("one-wedge", _oBad_, pcFolio)
	_o_.Frame("A graph drawn planar: every vertex carries its name, and every name has rules to obey.")
	_o_.ExpectFindings()
	_o_.Frame("A name must stay within {leash} px of its dot. That circle is a rule, not a drawing.")
	_o_.ExpectFindings()
	_o_.Bind("leash", :arg, [ "lessthan v111", 2 ])
	_o_.Show("lessthan v111")
	_o_.Emphasis("v111.icon", :ring)
	_o_.Frame("This one is {far} px away, so it is outside. Look closely.")
	_o_.ExpectFindings()
	_o_.Bind("far", :distance, [ "v111.icon", "v111.text" ])
	_o_.WindowOn("v111.icon", 105)
	_o_.FrameOf(StzMathScene25XT(poFont, StzMathOneWedgeStorySeed()),
		"Given a second starting direction, the same name settles {near} px out, inside the leash.")
	_o_.Bind("near", :distance, [ "v111.icon", "v111.text" ])
	_o_.Show("lessthan v111")
	_o_.Emphasis("v111.icon", :ring)
	_o_.WindowOn("v111.icon", 105)
	return _o_

# AND THE SAME FIVE MARKS WITH NO MATHEMATICS ANYWHERE: an org chart, a
# governance finding from the org plane quoted in a caption about a
# drawing of it, and the repaired chart as the last frame.
func StzStoryChartOf(pbFixed)
	_o_ = new stzOrgChart("acme")
	_o_.AddPositionXT("ceo", "Chief Executive")
	_o_.AddPositionXT("cto", "Technology")
	_o_.AddPositionXT("cfo", "Finance")
	_o_.AddPositionXT("eng", "Engineering")
	_o_.AddPositionXT("ops", "Operations")
	_o_.ReportsTo("cto", "ceo")
	_o_.ReportsTo("cfo", "ceo")
	_o_.ReportsTo("eng", "cto")
	if pbFixed  _o_.ReportsTo("ops", "cto")  ok
	return _o_

func StzStoryChartPicture(poFont, pbFixed)
	_oS_ = StzSubstanceFromGraph(StzStoryChartOf(pbFixed), StzGraphDomain(),
		[ :nodeType = "Vertex", :edgeConstructor = "Arc" ])
	_o_ = new stzMathDiagram(StzGraphDomain(), _oS_, StzBoxArrowStyle())
	_o_.SetFont(poFont, 16)
	_o_.SetVariation("acme")
	return _o_

# A FINDING FROM THE ORG PLANE, IN THE ONE FACT SHAPE, so a caption about
# a drawing can quote a verdict the drawing never reached itself
func StzStoryFindingAbout(poChart, pcWho)
	_aF_ = poChart.GovernanceFindings()
	for _i_ = 1 to len(_aF_)
		if StzLower("" + _aF_[_i_][:where]) = StzLower(pcWho)
			return StzFact(:verdict, "" + _aF_[_i_][:rule], 1, :none,
				"" + _aF_[_i_][:where], "" + _aF_[_i_][:message])
		ok
	next
	return StzFact(:verdict, pcWho, 0, :none, "orgchart",
		"nothing is found against " + pcWho)

func StzStoryOrgChart(poFont, pcFolio)
	_o_ = new stzStoryboard("acme", StzStoryChartPicture(poFont, 0), pcFolio)
	_o_.Frame("Five positions, and the lines that say who answers to whom.")
	_o_.Frame("The org rules read the chart and find one thing: {gap.message}")
	_o_.BindFact("gap", StzStoryFindingAbout(StzStoryChartOf(0), "ops"))
	_o_.Emphasis("ops.icon", :ring)
	_o_.Callout("ops.icon", "no supervisor", [])
	_o_.FrameOf(StzStoryChartPicture(poFont, 1),
		"One line added, and the same rules find nothing about it: {fixed.message}")
	_o_.BindFact("fixed", StzStoryFindingAbout(StzStoryChartOf(1), "ops"))
	_o_.Emphasis("ops.icon", :focus)
	return _o_

#-- molecules (DN11): the second caller of the solver -------------------------

# WATER: the smallest molecule with an angle. Three atoms, two bonds, one
# BondAngle whose ideal is 120 -- a 2D depiction's angle, said plainly in
# the domain file; the real one is 104.5.
func StzMathWaterSubstance()
	return StzMoleculeFromBonds([ "O", "H", "H" ], [ [ 1, 2, 1 ], [ 1, 3, 1 ] ])

func StzMathScene38(poFont)
	_o_ = new stzMathDiagram(StzChemistryDomain(), StzMathWaterSubstance(), StzBallAndStickStyle())
	_o_.SetFont(poFont, 11)
	_o_.SetVariation("water")
	return _o_

# BENZENE, every hydrogen drawn: a six-ring of carbons with alternating
# double bonds, a hydrogen on each. Twelve atoms, twelve bonds, and the
# ring is a REGULAR HEXAGON by consequence -- equal bonds and 120-degree
# ideals at every carbon, and nothing that says "hexagon".
func StzMathBenzeneSubstance()
	_acE_ = [ "C", "C", "C", "C", "C", "C", "H", "H", "H", "H", "H", "H" ]
	_aB_ = [ [ 1, 2, 2 ], [ 2, 3, 1 ], [ 3, 4, 2 ], [ 4, 5, 1 ], [ 5, 6, 2 ], [ 6, 1, 1 ],
	         [ 1, 7, 1 ], [ 2, 8, 1 ], [ 3, 9, 1 ], [ 4, 10, 1 ], [ 5, 11, 1 ], [ 6, 12, 1 ] ]
	return StzMoleculeFromBonds(_acE_, _aB_)

func StzMathScene39(poFont)
	_o_ = new stzMathDiagram(StzChemistryDomain(), StzMathBenzeneSubstance(), StzBallAndStickStyle())
	_o_.SetFont(poFont, 11)
	_o_.SetVariation("benzene")
	return _o_

# CAFFEINE, skeletal: fourteen heavy atoms, fifteen bonds, a six-ring
# FUSED to a five-ring on a shared edge, two carbonyls, three methyls.
# The five-ring cannot have its 120s and settles near 108; the six-ring
# keeps its; and the fusion is what a chain of triangles never posed.
func StzMathCaffeineSubstance()
	#  1 N1  2 C2  3 N3  4 C4  5 C5  6 C6  7 N7  8 C8  9 N9
	# 10 O   11 O  12 C(N1-Me)  13 C(N3-Me)  14 C(N7-Me)
	_acE_ = [ "N", "C", "N", "C", "C", "C", "N", "C", "N", "O", "O", "C", "C", "C" ]
	_aB_ = [ [ 1, 2, 1 ], [ 2, 3, 1 ], [ 3, 4, 1 ], [ 4, 5, 2 ], [ 5, 6, 1 ], [ 6, 1, 1 ],
	         [ 4, 9, 1 ], [ 9, 8, 2 ], [ 8, 7, 1 ], [ 7, 5, 1 ],
	         [ 2, 10, 2 ], [ 6, 11, 2 ],
	         [ 1, 12, 1 ], [ 3, 13, 1 ], [ 7, 14, 1 ] ]
	return StzMoleculeFromBonds(_acE_, _aB_)

func StzMathScene40(poFont)
	_o_ = new stzMathDiagram(StzChemistryDomain(), StzMathCaffeineSubstance(), StzBallAndStickStyle())
	_o_.SetFont(poFont, 11)
	_o_.SetVariation("caffeine")
	return _o_

# PHENOL IN WATER: one molecule and six that are not bonded to it -- seven
# components in one substance, which the solver has never been handed.
# Every hydrogen drawn, as the Principal's picture had them.
func StzMathSolvatedSubstance(pnWaters)
	# phenol: ring carbons 1-6, ring hydrogens 7-11 on carbons 2-6, O 12, its H 13
	_acE_ = [ "C", "C", "C", "C", "C", "C", "H", "H", "H", "H", "H", "O", "H" ]
	_aB_ = [ [ 1, 2, 2 ], [ 2, 3, 1 ], [ 3, 4, 2 ], [ 4, 5, 1 ], [ 5, 6, 2 ], [ 6, 1, 1 ],
	         [ 2, 7, 1 ], [ 3, 8, 1 ], [ 4, 9, 1 ], [ 5, 10, 1 ], [ 6, 11, 1 ],
	         [ 1, 12, 1 ], [ 12, 13, 1 ] ]
	_n_ = 13
	for _w_ = 1 to pnWaters
		_acE_ + "O"  _acE_ + "H"  _acE_ + "H"
		_aB_ + [ _n_ + 1, _n_ + 2, 1 ]
		_aB_ + [ _n_ + 1, _n_ + 3, 1 ]
		_n_ += 3
	next
	return StzMoleculeFromBonds(_acE_, _aB_)

func StzMathScene41(poFont)
	_o_ = new stzMathDiagram(StzChemistryDomain(), StzMathSolvatedSubstance(6), StzBallAndStickStyle())
	_o_.@oStyle.SetCanvas(720, 640)
	_o_.SetFont(poFont, 11)
	_o_.SetVariation("phenol in water")
	return _o_

# A V2000 MOL BLOCK OF BENZENE, its ring drawn as a regular hexagon of
# bond 1.40 A in the file -- the INDEPENDENT geometry the guard measures
# the solved picture against. Fixed columns, as the format is.
func StzMathBenzeneMol()
	_c_ = "benzene" + char(10) + "  hand-written V2000" + char(10) + char(10) +
	      " 12 12  0  0  0  0  0  0  0  0999 V2000" + char(10) +
	      "    1.4000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "    0.7000    1.2124    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "   -0.7000    1.2124    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "   -1.4000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "   -0.7000   -1.2124    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "    0.7000   -1.2124    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "    2.4900    0.0000    0.0000 H   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "    1.2450    2.1564    0.0000 H   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "   -1.2450    2.1564    0.0000 H   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "   -2.4900    0.0000    0.0000 H   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "   -1.2450   -2.1564    0.0000 H   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "    1.2450   -2.1564    0.0000 H   0  0  0  0  0  0  0  0  0  0  0  0" + char(10) +
	      "  1  2  2  0  0  0  0" + char(10) + "  2  3  1  0  0  0  0" + char(10) +
	      "  3  4  2  0  0  0  0" + char(10) + "  4  5  1  0  0  0  0" + char(10) +
	      "  5  6  2  0  0  0  0" + char(10) + "  6  1  1  0  0  0  0" + char(10) +
	      "  1  7  1  0  0  0  0" + char(10) + "  2  8  1  0  0  0  0" + char(10) +
	      "  3  9  1  0  0  0  0" + char(10) + "  4 10  1  0  0  0  0" + char(10) +
	      "  5 11  1  0  0  0  0" + char(10) + "  6 12  1  0  0  0  0" + char(10) +
	      "M  END" + char(10)
	return _c_
