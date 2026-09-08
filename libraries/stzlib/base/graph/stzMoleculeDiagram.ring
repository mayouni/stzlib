#=====================================================================#
#  STZMOLECULEDIAGRAM -- DN11: a molecule is a CONSTRAINT PROBLEM      #
#  over atoms, solved from connectivity alone by the math plane        #
#=====================================================================#
/*
	THE SECOND CALLER OF THE DN8 SOLVER, and it was chosen for that.
	The math plane has laid out sets, triangles, lattices and graphs;
	it has never been handed a RING. A molecule is nothing but rings and
	chains, and it arrives with no coordinates -- a MOL file carries them,
	but a hand-built molecule is atoms and bonds and nothing else, so the
	picture is SOLVED, exactly as the seven-set tree is.

	WHAT A MOLECULE IS HERE, in the plane's own three programs:

	    DOMAIN     Atom, with the elements as SUBTYPES (Carbon, Oxygen...)
	               so a style may speak to "Atom a" or to "Oxygen a";
	               Bond(Atom, Atom) with Double and Triple as predicates,
	               the specialisation idiom the graph domain's Highlighted
	               edge already uses; and BondAngle(p, q, r) with its IDEAL
	               as a predicate -- Ideal120, Ideal90, Ideal180 -- which is
	               hybridisation said in the plane's words.

	    SUBSTANCE  built from a list of elements and a list of bonds, or
	               read from a V2000 MOL block. The builder derives every
	               angle and its ideal from degree and bond order: a
	               triple bond makes its carbon linear, four neighbours
	               make a cross, everything else is trigonal. The file's
	               coordinates, when there are any, are NOT used -- they
	               are the independent expectation the guard measures the
	               solved picture against.

	    STYLE      ball-and-stick: a disc per atom, coloured by the CPK
	               convention THROUGH THE THEME'S ROLES -- carbon neutral,
	               oxygen danger-red, nitrogen info-blue, hydrogen the paper
	               with a muted rim -- so the same molecule is right in the
	               dark theme without a second table. A double bond is two
	               lines off the bond's normal, a triple is three; every
	               bond wants one length; every angle wants its ideal; no
	               two bonds cross; nothing sits on a bond it is not part of.

	EVERY ANGLE IS A DISTANCE. The plane's tape has no acos, and it does
	not need one: two bonds of length L meeting at 120 degrees put their
	far atoms sqrt(3)*L apart, at 90 degrees sqrt(2)*L, at 180 degrees 2L.
	So an angle's ideal is an ENCOURAGED distance between second
	neighbours and a hard floor under it, polynomial throughout -- the
	same trick the spherical style used to draw a right angle with no
	trigonometry. A six-ring under equal bonds and 120-degree ideals IS a
	regular hexagon, and nothing has to say "hexagon".

	WHAT THE DOMAIN OWES THE GATE: valence. A carbon with five bonds is not
	a drawing defect, it is a chemistry defect, and it is reported through
	the one gate beside "a name sits on a line" -- the rule reads the
	SUBSTANCE, recounts the bonds itself, and never trusts a number the
	builder might have written. A second rule names an atom with no bond.
	Both register themselves into the math governance from this file, so
	the file that knows the domain is the file that judges it.

	WHAT IS SAID PLAINLY: a 2D depiction draws every sp2 and every chain
	angle at 120 degrees and water's oxygen among them, where the real
	angle is 104.5. That is how chemists draw it on paper and it is what
	this style draws. Stereo wedges, charges, aromatic circles and implicit
	hydrogens are not in this item; a hydrogen is drawn when it is
	declared, and not otherwise.
*/

# REGISTERED AT LOAD, so the math governance judges chemistry without
# knowing chemistry exists. THIS LINE STANDS ABOVE THE FIRST func ON
# PURPOSE: Ring folds every top-level statement after a func into that
# func's body, so a registration at the foot of the file would run when
# nothing called it -- the same trap that puts a scene file's helpers at
# its end. The function it calls is defined below and resolved at call
# time, which is after the whole file has been read.
StzRegisterMathRuleSet("chemistry", StzChemistryRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzChemistryDomain()
	_o_ = new stzMathDomain("chemistry")
	_o_.AddType("Atom")
	# THE SKELETON IS A TYPE. Every element but hydrogen is a HeavyAtom, so
	# a style may ask for a start computed over the skeleton alone: a
	# hydrogen is a pendant vertex, and a pendant vertex is what breaks a
	# planar start -- Tutte puts it on top of its one neighbour, where the
	# separation gradient has no direction to push. Measured before this
	# type existed: the bare six-ring is lawful from the planar start in
	# one round at 120 degrees each; the same ring with six hydrogens fell
	# to a random start and folded. The hydrogens FOLLOW the skeleton.
	_o_.AddSubtype("HeavyAtom", "Atom")
	_o_.AddSubtype("Hydrogen", "Atom")
	_o_.AddSubtype("Carbon", "HeavyAtom")
	_o_.AddSubtype("Oxygen", "HeavyAtom")
	_o_.AddSubtype("Nitrogen", "HeavyAtom")
	_o_.AddSubtype("Sulfur", "HeavyAtom")
	_o_.AddSubtype("Phosphorus", "HeavyAtom")
	_o_.AddSubtype("Fluorine", "HeavyAtom")
	_o_.AddSubtype("Chlorine", "HeavyAtom")
	_o_.AddSubtype("Bromine", "HeavyAtom")
	_o_.AddType("Bond")
	_o_.AddConstructor("Bond", [ "Atom", "Atom" ])
	_o_.AddPredicate("Double", [ "Bond" ])
	_o_.AddPredicate("Triple", [ "Bond" ])
	_o_.AddType("Angle")
	_o_.AddFunction("BondAngle", [ "Atom", "Atom", "Atom" ], "Angle")
	_o_.AddPredicate("Ideal120", [ "Angle" ])
	_o_.AddPredicate("Ideal90", [ "Angle" ])
	_o_.AddPredicate("Ideal180", [ "Angle" ])
	return _o_

# the elements this domain knows: symbol, type name, maximum valence
func StzChemistryElements()
	return [ [ "H", "Hydrogen", 1 ], [ "C", "Carbon", 4 ], [ "N", "Nitrogen", 3 ],
	         [ "O", "Oxygen", 2 ], [ "S", "Sulfur", 6 ], [ "P", "Phosphorus", 5 ],
	         [ "F", "Fluorine", 1 ], [ "Cl", "Chlorine", 1 ], [ "Br", "Bromine", 1 ] ]

func StzChemistryTypeOf(pcSymbol)
	_c_ = ring_trim("" + pcSymbol)
	_a_ = StzChemistryElements()
	for _i_ = 1 to len(_a_)
		if StzLower(_a_[_i_][1]) = StzLower(_c_)  return _a_[_i_][2]  ok
	next
	return ""

func StzChemistrySymbolOf(pcType)
	_c_ = StzLower(ring_trim("" + pcType))
	_a_ = StzChemistryElements()
	for _i_ = 1 to len(_a_)
		if StzLower(_a_[_i_][2]) = _c_  return _a_[_i_][1]  ok
	next
	return ""

func StzChemistryMaxValence(pcSymbol)
	_c_ = ring_trim("" + pcSymbol)
	_a_ = StzChemistryElements()
	for _i_ = 1 to len(_a_)
		if StzLower(_a_[_i_][1]) = StzLower(_c_)  return _a_[_i_][3]  ok
	next
	return 0

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM CONNECTIVITY                                     #
#---------------------------------------------------------------------#

# pacElements: a symbol per atom, in order -- [ "O", "H", "H" ]
# paBonds:     [ from, to, order ] per bond, 1-based into the atoms
#
# Atoms are named a1..aN, bonds b1..bM, angles g1..gK. The label of an
# atom is its symbol; bonds and angles carry none.
func StzMoleculeFromBonds(pacElements, paBonds)
	_oS_ = new stzMathSubstance(StzChemistryDomain())
	_nA_ = len(pacElements)
	for _i_ = 1 to _nA_
		_cT_ = StzChemistryTypeOf(pacElements[_i_])
		if _cT_ = ""
			stzraise("StzMoleculeFromBonds: '" + pacElements[_i_] + "' is not an " +
				"element this domain knows -- " + _ChKnownSymbols())
		ok
		_oS_.Declare(_cT_, "a" + _i_)
		_oS_.Label("a" + _i_, ring_trim("" + pacElements[_i_]))
	next

	# the bonds, flat: three parallel lists of numbers. NOT adjacency lists
	# of lists -- Ring's `+` appends a list operand as ONE element, so
	# `_a_ + [ [] ]` and `_a_[i] = _a_[i] + [ q ]` both nest a level deeper
	# than they read, and the neighbour that came back was a list where a
	# number was meant. Same house trap as the option list.
	_anFrom_ = []
	_anTo_ = []
	_anOrder_ = []
	_nB_ = len(paBonds)
	for _k_ = 1 to _nB_
		_p_ = paBonds[_k_][1]
		_q_ = paBonds[_k_][2]
		_o_ = 1
		if len(paBonds[_k_]) >= 3  _o_ = paBonds[_k_][3]  ok
		if _p_ < 1 or _p_ > _nA_ or _q_ < 1 or _q_ > _nA_ or _p_ = _q_
			stzraise("StzMoleculeFromBonds: bond " + _k_ + " joins atoms " + _p_ +
				" and " + _q_ + ", and there are " + _nA_ + " atoms.")
		ok
		_oS_.Define("b" + _k_, "Bond", [ "a" + _p_, "a" + _q_ ])
		_oS_.Label("b" + _k_, "")
		if _o_ = 2  _oS_.Assert("Double", [ "b" + _k_ ])  ok
		if _o_ = 3  _oS_.Assert("Triple", [ "b" + _k_ ])  ok
		_anFrom_ + _p_
		_anTo_ + _q_
		_anOrder_ + _o_
	next

	# EVERY ANGLE AT EVERY ATOM, with its ideal read off the degree and the
	# bond orders: this is hybridisation said in the plane's words. The
	# neighbours of q are gathered by a scan of the bonds, into fresh flat
	# lists, each time -- the sizes are tens, never thousands.
	_nG_ = 0
	for _q_ = 1 to _nA_
		_aN_ = []
		_aO_ = []
		for _k_ = 1 to _nB_
			if _anFrom_[_k_] = _q_
				_aN_ + _anTo_[_k_]
				_aO_ + _anOrder_[_k_]
			but _anTo_[_k_] = _q_
				_aN_ + _anFrom_[_k_]
				_aO_ + _anOrder_[_k_]
			ok
		next
		_nD_ = len(_aN_)
		if _nD_ < 2  loop  ok
		_cIdeal_ = "Ideal120"
		_nSum_ = 0
		_bTriple_ = FALSE
		for _j_ = 1 to _nD_
			_nSum_ += _aO_[_j_]
			if _aO_[_j_] = 3  _bTriple_ = TRUE  ok
		next
		if _nD_ = 2 and (_bTriple_ or _nSum_ = 4)  _cIdeal_ = "Ideal180"  ok
		if _nD_ >= 4  _cIdeal_ = "Ideal90"  ok
		for _j_ = 1 to _nD_
			for _m_ = _j_ + 1 to _nD_
				_nG_++
				_oS_.Define("g" + _nG_, "BondAngle", [ "a" + _aN_[_j_], "a" + _q_, "a" + _aN_[_m_] ])
				_oS_.Label("g" + _nG_, "")
				_oS_.Assert(_cIdeal_, [ "g" + _nG_ ])
			next
		next
	next
	return _oS_

func _ChKnownSymbols()
	_a_ = StzChemistryElements()
	_c_ = ""
	for _i_ = 1 to len(_a_)
		if _c_ != ""  _c_ += ", "  ok
		_c_ += _a_[_i_][1]
	next
	return _c_

#---------------------------------------------------------------------#
#  A MOL BLOCK (V2000)                                                 #
#---------------------------------------------------------------------#
#
# Three header lines, a counts line "aaabbb...", then one atom per line
# with x y z in columns 1-30 and the symbol at 32-34, then one bond per
# line "aaabbbttt". Fixed columns and ASCII throughout, which is why the
# section reads are by column and not by delimiter.

func StzMolParse(pcText)
	_ac_ = StzSplit(StzReplace("" + pcText, char(13), ""), char(10))
	if len(_ac_) < 4
		stzraise("StzMolParse: a MOL block has three header lines and a counts line.")
	ok
	_cC_ = _ac_[4]
	_nA_ = 0 + ring_trim(_ChCols(_cC_, 1, 3))
	_nB_ = 0 + ring_trim(_ChCols(_cC_, 4, 6))
	if _nA_ < 1 or len(_ac_) < 4 + _nA_ + _nB_
		stzraise("StzMolParse: the counts line says " + _nA_ + " atoms and " + _nB_ +
			" bonds, and the block does not hold them.")
	ok
	_acEl_ = []
	_aXY_ = []
	for _i_ = 1 to _nA_
		_cL_ = _ac_[4 + _i_]
		_acEl_ + ring_trim(_ChCols(_cL_, 32, 34))
		_aXY_ + [ 0 + ring_trim(_ChCols(_cL_, 1, 10)), 0 + ring_trim(_ChCols(_cL_, 11, 20)) ]
	next
	_aBd_ = []
	for _k_ = 1 to _nB_
		_cL_ = _ac_[4 + _nA_ + _k_]
		_aBd_ + [ 0 + ring_trim(_ChCols(_cL_, 1, 3)), 0 + ring_trim(_ChCols(_cL_, 4, 6)),
		          0 + ring_trim(_ChCols(_cL_, 7, 9)) ]
	next
	return [ :elements = _acEl_, :bonds = _aBd_, :coordinates = _aXY_ ]

func StzMoleculeFromMol(pcText)
	_a_ = StzMolParse(pcText)
	return StzMoleculeFromBonds(_a_[:elements], _a_[:bonds])

# columns pnFrom..pnTo of an ASCII line, 1-based inclusive, tolerant of a
# short line
func _ChCols(pcLine, pnFrom, pnTo)
	_c_ = "" + pcLine
	_n_ = len(_c_)
	if pnFrom > _n_  return ""  ok
	_t_ = pnTo
	if _t_ > _n_  _t_ = _n_  ok
	return StzStringSection(_c_, pnFrom, _t_)

#---------------------------------------------------------------------#
#  THE STYLE                                                           #
#---------------------------------------------------------------------#

# the one bond length, in pixels
func StzBondLength()
	return 62

func StzBallAndStickStyle()
	_L_ = StzBondLength()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(640, 560)
	_o_.SetMargin(30)
	# THE START IS THE SKELETON. A molecule's heavy-atom graph is planar in
	# every case this item draws and the planar start is what lands a ring
	# as a ring; the hydrogens are pendant, and a pendant vertex is what
	# breaks Tutte. So the start is asked over HeavyAtom alone, and every
	# hydrogen begins a step from its carbon and is solved from there.
	_o_.StartTrying([ :planar, :force, :random ], "HeavyAtom", "icon", [ "Bond" ])

	# AN ATOM IS A DISC WITH ITS SYMBOL INSIDE. The symbol sits on the disc
	# by containment and a shared centre, and takes black or white against
	# whatever the disc is painted -- so oxygen's red and hydrogen's paper
	# both read.
	_o_.ForAll("Atom a", [
		[ :shape, "a.icon", :circle, [ :r = 12, :fill = "neutral",
		                               :stroke = "background", :strokeWidth = 1.5 ] ],
		[ :shape, "a.text", :text, [ :fill = [ :on, "under" ] ] ],
		[ :ensure, "contains", [ "a.icon", "a.text", 1 ] ],
		[ :encourage, "sameCenter", [ "a.text", "a.icon" ] ],
		[ :layer, "a.text", :above, "a.icon" ],
		# a weak pull to the middle of the paper, a sixty-fourth
		[ :encourage, "equal", [ "a.icon.cx / 8", 40 ] ],
		[ :encourage, "equal", [ "a.icon.cy / 8", 35 ] ] ])
	# THE CPK CONVENTION, THROUGH THE ROLES: the same table is right under
	# every theme, because a role resolves per theme and a hex would not
	_o_.ForAll("Oxygen a", [
		[ :delete, "a.icon" ],
		[ :shape, "a.icon", :circle, [ :r = 12, :fill = "danger",
		                               :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAll("Nitrogen a", [
		[ :delete, "a.icon" ],
		[ :shape, "a.icon", :circle, [ :r = 12, :fill = "info",
		                               :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAll("Sulfur a", [
		[ :delete, "a.icon" ],
		[ :shape, "a.icon", :circle, [ :r = 12, :fill = "warning",
		                               :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAll("Phosphorus a", [
		[ :delete, "a.icon" ],
		[ :shape, "a.icon", :circle, [ :r = 12, :fill = "warning",
		                               :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAll("Fluorine a", [
		[ :delete, "a.icon" ],
		[ :shape, "a.icon", :circle, [ :r = 12, :fill = "success",
		                               :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAll("Chlorine a", [
		[ :delete, "a.icon" ],
		[ :shape, "a.icon", :circle, [ :r = 12, :fill = "success",
		                               :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAll("Bromine a", [
		[ :delete, "a.icon" ],
		[ :shape, "a.icon", :circle, [ :r = 12, :fill = "primary",
		                               :stroke = "background", :strokeWidth = 1.5 ] ] ])
	# hydrogen is small, and the paper's colour with a rim -- it is the atom
	# a reader's eye should pass over. Ten, not eight: an eleven-pixel H is
	# fourteen tall in its box, and at eight the letter could not be held
	# inside the disc by a single pixel -- measured, 2.05px short on every
	# hydrogen, and the whole picture bent around that one impossibility.
	_o_.ForAll("Hydrogen a", [
		[ :delete, "a.icon" ],
		[ :shape, "a.icon", :circle, [ :r = 10, :fill = "background",
		                               :stroke = "muted", :strokeWidth = 1.5 ] ] ])

	# ATOMS KEEP APART, bonded or not: a bond holds its two at L, and every
	# other pair is held off by the discs plus a gap
	_o_.ForAll("Atom u; Atom v", [
		[ :ensure, "disjoint", [ "u.icon", "v.icon", 6 ] ],
		[ :encourage, "notTooClose", [ "u.icon", "v.icon", 2 ] ] ])

	# A BOND IS ONE LINE OF ONE LENGTH. The hard band keeps the picture from
	# collapsing or exploding; the encouragement is what makes every bond
	# the same, and with the angles below is what makes a ring regular.
	# THE BOND'S OWN LINE IS HIDDEN AND RUNS CENTRE TO CENTRE -- it is the
	# segment every rule speaks to. What is DRAWN stops at each disc's rim:
	# a stroke run to the centre passes under the symbol, and the gate's
	# name-off-ink rule rightly refuses to count paint order as clearance
	# -- every symbol in the first render read as sitting on its own bond.
	_o_.ForAllWhere("Bond b; Atom p; Atom q", "b := Bond(p, q)", [
		[ :shape, "b.icon", :line, [ :x1 = "p.icon.cx", :y1 = "p.icon.cy",
		                             :x2 = "q.icon.cx", :y2 = "q.icon.cy", :hidden = 1 ] ],
		[ :shape, "b.stick", :line, [
		    :x1 = "p.icon.cx + (p.icon.r + 1)*ux(b.icon)", :y1 = "p.icon.cy + (p.icon.r + 1)*uy(b.icon)",
		    :x2 = "q.icon.cx - (q.icon.r + 1)*ux(b.icon)", :y2 = "q.icon.cy - (q.icon.r + 1)*uy(b.icon)",
		    :stroke = "muted", :strokeWidth = 3 ] ],
		[ :ensure, "inRange", [ "len(b.icon)", _L_ * 0.85, _L_ * 1.15 ] ],
		[ :encourage, "equal", [ "len(b.icon) / 4", _L_ / 4 ] ],
		[ :layer, "p.icon", :above, "b.stick" ], [ :layer, "q.icon", :above, "b.stick" ] ])
	# A DOUBLE BOND IS TWO LINES OFF THE NORMAL, a triple three -- the
	# specialisation idiom: the general rule's stick is deleted and the
	# lines ride the hidden segment's normal, stopping at the rims too
	_o_.ForAllWhere("Bond b; Atom p; Atom q", "b := Bond(p, q); Double(b)", [
		[ :delete, "b.stick" ],
		[ :shape, "b.l1", :line, [
		    :x1 = "p.icon.cx + (p.icon.r + 1)*ux(b.icon) + 3*nx(b.icon)",
		    :y1 = "p.icon.cy + (p.icon.r + 1)*uy(b.icon) + 3*ny(b.icon)",
		    :x2 = "q.icon.cx - (q.icon.r + 1)*ux(b.icon) + 3*nx(b.icon)",
		    :y2 = "q.icon.cy - (q.icon.r + 1)*uy(b.icon) + 3*ny(b.icon)",
		    :stroke = "muted", :strokeWidth = 2.5 ] ],
		[ :shape, "b.l2", :line, [
		    :x1 = "p.icon.cx + (p.icon.r + 1)*ux(b.icon) - 3*nx(b.icon)",
		    :y1 = "p.icon.cy + (p.icon.r + 1)*uy(b.icon) - 3*ny(b.icon)",
		    :x2 = "q.icon.cx - (q.icon.r + 1)*ux(b.icon) - 3*nx(b.icon)",
		    :y2 = "q.icon.cy - (q.icon.r + 1)*uy(b.icon) - 3*ny(b.icon)",
		    :stroke = "muted", :strokeWidth = 2.5 ] ],
		[ :layer, "p.icon", :above, "b.l1" ], [ :layer, "q.icon", :above, "b.l1" ],
		[ :layer, "p.icon", :above, "b.l2" ], [ :layer, "q.icon", :above, "b.l2" ] ])
	_o_.ForAllWhere("Bond b; Atom p; Atom q", "b := Bond(p, q); Triple(b)", [
		[ :shape, "b.l1", :line, [
		    :x1 = "p.icon.cx + (p.icon.r + 1)*ux(b.icon) + 4.5*nx(b.icon)",
		    :y1 = "p.icon.cy + (p.icon.r + 1)*uy(b.icon) + 4.5*ny(b.icon)",
		    :x2 = "q.icon.cx - (q.icon.r + 1)*ux(b.icon) + 4.5*nx(b.icon)",
		    :y2 = "q.icon.cy - (q.icon.r + 1)*uy(b.icon) + 4.5*ny(b.icon)",
		    :stroke = "muted", :strokeWidth = 2.5 ] ],
		[ :shape, "b.l2", :line, [
		    :x1 = "p.icon.cx + (p.icon.r + 1)*ux(b.icon) - 4.5*nx(b.icon)",
		    :y1 = "p.icon.cy + (p.icon.r + 1)*uy(b.icon) - 4.5*ny(b.icon)",
		    :x2 = "q.icon.cx - (q.icon.r + 1)*ux(b.icon) - 4.5*nx(b.icon)",
		    :y2 = "q.icon.cy - (q.icon.r + 1)*uy(b.icon) - 4.5*ny(b.icon)",
		    :stroke = "muted", :strokeWidth = 2.5 ] ],
		[ :layer, "p.icon", :above, "b.l1" ], [ :layer, "q.icon", :above, "b.l1" ],
		[ :layer, "p.icon", :above, "b.l2" ], [ :layer, "q.icon", :above, "b.l2" ] ])

	# EVERY ANGLE IS A DISTANCE. Two bonds of L at 120 degrees put their far
	# atoms sqrt(3)*L apart; at 90, sqrt(2)*L; at 180, 2L. Each ideal is a
	# hard BAND and, inside it, an encouraged centre: the band is what makes
	# a ring a ring rather than a preference the separations outvote, and
	# it is wide enough for a five-ring's 108 degrees (1.618L against 1.732L
	# -- 0.93 of the ideal) and not for a square's 90. A three- or four-ring
	# is outside this item and says so as a violation, not as a picture.
	_o_.ForAllWhere("Angle g; Atom p; Atom q; Atom r", "g := BondAngle(p, q, r); Ideal120(g)", [
		[ :ensure, "inRange", [ "dist(p.icon, r.icon)", _L_ * 1.7320508 * 0.90, _L_ * 1.7320508 * 1.10 ] ],
		[ :encourage, "equal", [ "dist(p.icon, r.icon) / 4", _L_ * 1.7320508 / 4 ] ] ])
	_o_.ForAllWhere("Angle g; Atom p; Atom q; Atom r", "g := BondAngle(p, q, r); Ideal90(g)", [
		[ :ensure, "inRange", [ "dist(p.icon, r.icon)", _L_ * 1.4142136 * 0.92, _L_ * 1.4142136 * 1.15 ] ],
		[ :encourage, "equal", [ "dist(p.icon, r.icon) / 4", _L_ * 1.4142136 / 4 ] ] ])
	_o_.ForAllWhere("Angle g; Atom p; Atom q; Atom r", "g := BondAngle(p, q, r); Ideal180(g)", [
		[ :ensure, "greaterThan", [ "dist(p.icon, r.icon)", _L_ * 2 * 0.92 ] ],
		[ :encourage, "equal", [ "dist(p.icon, r.icon) / 4", _L_ * 2 / 4 ] ] ])

	# NOTHING SITS ON A BOND IT IS NOT PART OF, and no two bonds cross where
	# they share no atom -- the selector's distinct bindings say "not an
	# end of" without a predicate, as the graph style found
	_o_.ForAllWhere("Atom v; Bond b; Atom p; Atom q", "b := Bond(p, q)", [
		[ :ensure, "disjoint", [ "v.icon", "b.icon", 5 ] ] ])
	_o_.ForAllWhere("Bond b; Bond c; Atom p; Atom q; Atom r; Atom s",
	                "b := Bond(p, q); c := Bond(r, s)", [
		[ :ensure, "notCrossing", [ "b.icon", "c.icon", 4 ] ] ])
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE                                        #
#---------------------------------------------------------------------#
#
# Both read the SUBSTANCE and recount. A rule that read a valence the
# builder had stored would be checking the builder against itself.

# the bonds at one atom: [ bondName, otherAtom, order ] each
func StzChemistryBondsAt(poSubstance, pcAtom)
	_r_ = []
	_a_ = ring_trim("" + pcAtom)
	_aD_ = poSubstance.Definitions()
	for _i_ = 1 to len(_aD_)
		if StzLower("" + _aD_[_i_][2]) != "bond"  loop  ok
		_ac_ = _aD_[_i_][3]
		_cOther_ = ""
		if "" + _ac_[1] = _a_  _cOther_ = "" + _ac_[2]  ok
		if "" + _ac_[2] = _a_  _cOther_ = "" + _ac_[1]  ok
		if _cOther_ = ""  loop  ok
		_n_ = 1
		if poSubstance.Holds("Double", [ _aD_[_i_][1] ])  _n_ = 2  ok
		if poSubstance.Holds("Triple", [ _aD_[_i_][1] ])  _n_ = 3  ok
		_r_ + [ _aD_[_i_][1], _cOther_, _n_ ]
	next
	return _r_

func StzChemistryValenceOf(poSubstance, pcAtom)
	_a_ = StzChemistryBondsAt(poSubstance, pcAtom)
	_n_ = 0
	for _i_ = 1 to len(_a_)  _n_ += _a_[_i_][3]  next
	return _n_

func _ChIsChemistry(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "chemistry"

func StzChemistryRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("valence_respected")
	_o1_.SetClaim("no atom carries more bonds, counted by order, than its element allows")
	_o1_.SetOrder(40)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) {
		_r_ = []
		if NOT _ChIsChemistry(oDg)  return _r_  ok
		_ac_ = oDg.Substance().ObjectsOfType("Atom")
		for _i_ = 1 to len(_ac_)  _r_ + ("atom:" + _ac_[_i_])  next
		return _r_
	})
	# THE BOUNDARY: every object of a picture that is not chemistry. A
	# vertex has no valence, and a rule that governed it would be applying
	# a table it has no entry for.
	_o1_.SetCounter(func(oDg) {
		_r_ = []
		if _ChIsChemistry(oDg)  return _r_  ok
		if StzLower(classname(oDg)) != "stzmathdiagram"  return _r_  ok
		_ac_ = oDg.Substance().ObjectNames()
		for _i_ = 1 to len(_ac_)  _r_ + ("atom:" + _ac_[_i_])  next
		return _r_
	})
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cA_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_cSym_ = StzChemistrySymbolOf(_oS_.TypeOf(_cA_))
		_nMax_ = StzChemistryMaxValence(_cSym_)
		_nHas_ = StzChemistryValenceOf(_oS_, _cA_)
		if _nHas_ > _nMax_
			return [ FALSE, "'" + _cA_ + "' is " + _cSym_ + " and carries " + _nHas_ +
				" bonds by order, where " + _cSym_ + " allows " + _nMax_ ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("atom_bonded")
	_o2_.SetClaim("every atom of a molecule is bonded to at least one other")
	_o2_.SetOrder(41)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) {
		_r_ = []
		if NOT _ChIsChemistry(oDg)  return _r_  ok
		_ac_ = oDg.Substance().ObjectsOfType("Atom")
		for _i_ = 1 to len(_ac_)  _r_ + ("atom:" + _ac_[_i_])  next
		return _r_
	})
	_o2_.SetCounter(func(oDg) {
		_r_ = []
		if _ChIsChemistry(oDg)  return _r_  ok
		if StzLower(classname(oDg)) != "stzmathdiagram"  return _r_  ok
		_ac_ = oDg.Substance().ObjectNames()
		for _i_ = 1 to len(_ac_)  _r_ + ("atom:" + _ac_[_i_])  next
		return _r_
	})
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cA_ = StzStringSection(cSub, 6, len(cSub))
		if len(StzChemistryBondsAt(oDg.Substance(), _cA_)) = 0
			return [ FALSE, "'" + _cA_ + "' is bonded to nothing -- a stray atom, " +
				"not part of the molecule it is drawn with" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	return _ao_
