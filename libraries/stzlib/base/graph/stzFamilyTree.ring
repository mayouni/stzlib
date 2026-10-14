#=====================================================================#
#  STZFAMILYTREE -- DN18: a family tree is a tree with two parents     #
#=====================================================================#
/*
	THE SIXTH NEW DOMAIN, and the cheapest after the fault tree: the
	same top-down tree, read the other way. A person is a box with a
	name and, beneath it, the years; a UNION is a small dot between two
	partners, and every child hangs from a union. Two parents per child
	is what makes it a family tree and not an org chart, and the union
	is what makes two parents drawable: the child has ONE line up, to
	the dot, and the dot has one line to each partner.

	WHAT IT IS HERE:

	    NOTATION   "family": person (a box, the name in the first band
	               and the years in a second), union (a dot), note. Top-
	               down, no heads -- kinship has no arrow -- and every
	               parent's children peers.

	    TREE       stzFamilyTree from stzDiagram: AddPerson, AddPersonXT
	               (id, name, born, died -- 0 for unknown), AddNote;
	               Marry(a, b) -> the union's id; Child(union, person)
	               and ChildOf(a, b, person), which marries them if they
	               are not yet. Read back: PartnersOf, ChildrenOf,
	               ParentsOf, SiblingsOf, AncestorsOf, DescendantsOf,
	               GenerationOf.

	    RULES      five, into the one report like the org chart's:

	               no_one_is_own_ancestor    a person is not among their
	                                         own ancestors
	               union_has_two_partners    a union joins two people --
	                                         one is a single parent and
	                                         says so, three is not a union
	               child_of_one_union        a person is born of one union
	               parents_are_older         a child is born after both
	                                         parents, where years are given
	               partners_are_not_kin      a union does not join a person
	                                         to their own ancestor or
	                                         descendant

	WHAT IS SAID PLAINLY: a single parent is drawn as a union with one
	partner, which the second rule treats as a warning and not an error.
	Adoption, step-relations and the ordering of siblings by birth are
	not here; the years are numbers, not dates.
*/

#---------------------------------------------------------------------#
#  THE NOTATION                                                        #
#---------------------------------------------------------------------#

func StzFamilyNotation()
	_o_ = StzNotation("family")
	if _o_.Name_() = "family"  return _o_  ok
	_o_ = new stzNotation("family")
	_o_.SetRankDir(:TopDown)
	_o_.SetSplines(:ortho)
	_o_.SetEdgesDirected(0)
	_o_.AddKindXT("person", "box", "white")
	# a union is a point between two people, a sixth of a cell
	_o_.AddKindXTT("union", "dot", "#333333", 0.16)
	_o_.AddKindXT("note", "note", "white")
	# a person's years stack under the name as a second band
	_o_.AddCompartmentKey("years")
	_o_.SetPeerChildren()
	StzRegisterNotation(_o_)
	return _o_

#---------------------------------------------------------------------#
#  THE RULES                                                           #
#---------------------------------------------------------------------#

func StzFamilyRuleSetQ()
	return new stzFamilyRuleSet()

func _FmKindOf(oGraph, pcId)
	return StzLower("" + oGraph.NodeProperty(pcId, "kind"))

func _FmUp(oGraph, pcId)
	_r_ = []
	_a_ = oGraph.Edges()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][:to]) = StzLower("" + pcId)  _r_ + ("" + _a_[_i_][:from])  ok
	next
	return _r_

func _FmDown(oGraph, pcId)
	_r_ = []
	_a_ = oGraph.Edges()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][:from]) = StzLower("" + pcId)  _r_ + ("" + _a_[_i_][:to])  ok
	next
	return _r_

# every node reachable upward from pcId, itself excluded
func _FmAbove(oGraph, pcId)
	_acSeen_ = []
	_acStack_ = _FmUp(oGraph, pcId)
	while len(_acStack_) > 0
		_c_ = StzLower("" + _acStack_[len(_acStack_)])
		del(_acStack_, len(_acStack_))
		_bSeen_ = FALSE
		for _i_ = 1 to len(_acSeen_)
			if _acSeen_[_i_] = _c_  _bSeen_ = TRUE  ok
		next
		if _bSeen_  loop  ok
		_acSeen_ + _c_
		_aK_ = _FmUp(oGraph, _c_)
		for _i_ = 1 to len(_aK_)  _acStack_ + _aK_[_i_]  next
	end
	return _acSeen_

func _FmIn(pcId, pacList)
	for _i_ = 1 to len(pacList)
		if StzLower("" + pacList[_i_]) = StzLower("" + pcId)  return TRUE  ok
	next
	return FALSE

func _FmOfKind(oGraph, pcKind)
	_r_ = []
	_a_ = oGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		if _FmKindOf(oGraph, _a_[_i_]) = pcKind  _r_ + (pcKind + ":" + StzLower("" + _a_[_i_]))  ok
	next
	return _r_

func _FmNotOfKind(oGraph, pcKind)
	_r_ = []
	_a_ = oGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		_k_ = _FmKindOf(oGraph, _a_[_i_])
		if _k_ != pcKind  _r_ + (_k_ + ":" + StzLower("" + _a_[_i_]))  ok
	next
	return _r_

func _StzAddFamilyRules(poSet)

	# NO ONE IS THEIR OWN ANCESTOR.
	_o1_ = new stzFamilyRule("no_one_is_own_ancestor")
	_o1_.SetSeverityQ("error")
	_o1_.SetMessageQ("no person is among their own ancestors")
	_o1_.SetOrderQ(10)
	_o1_.SetReadsQ([ "edge", "node.kind" ])
	_o1_.GovernsQ(func oGraph { return _FmOfKind(oGraph, "person") })
	_o1_.ExcludesQ(func oGraph { return _FmNotOfKind(oGraph, "person") })
	_o1_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _FmKindOf(oGraph, _a_[_i_]) != "person"  loop  ok
			if _FmIn(_a_[_i_], _FmAbove(oGraph, _a_[_i_]))
				_aOut_ + [ :where = _a_[_i_], :message = "'" + oGraph.NodeProperty(_a_[_i_], "name") +
					"' is among their own ancestors" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o1_)

	# A UNION HAS TWO PARTNERS. One is a single parent, drawn as such and
	# worth a word; three is not a union this tree can mean.
	_o2_ = new stzFamilyRule("union_has_two_partners")
	_o2_.SetSeverityQ("warning")
	_o2_.SetMessageQ("a union joins two people")
	_o2_.SetOrderQ(20)
	_o2_.SetReadsQ([ "edge", "node.kind" ])
	_o2_.GovernsQ(func oGraph { return _FmOfKind(oGraph, "union") })
	_o2_.ExcludesQ(func oGraph { return _FmNotOfKind(oGraph, "union") })
	_o2_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _FmKindOf(oGraph, _a_[_i_]) != "union"  loop  ok
			_n_ = len(_FmUp(oGraph, _a_[_i_]))
			if _n_ = 1
				_aOut_ + [ :where = _a_[_i_], :message = "the union under '" +
					oGraph.NodeProperty(_FmUp(oGraph, _a_[_i_])[1], "name") +
					"' has one partner -- a single parent, if that is meant" ]
			but _n_ > 2
				_aOut_ + [ :where = _a_[_i_], :message = "a union joins " + _n_ +
					" people -- two is a union" ]
			but _n_ = 0
				_aOut_ + [ :where = _a_[_i_], :message = "a union joins nobody" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o2_)

	# A CHILD IS BORN OF ONE UNION.
	_o3_ = new stzFamilyRule("child_of_one_union")
	_o3_.SetSeverityQ("error")
	_o3_.SetMessageQ("a person is born of one union")
	_o3_.SetOrderQ(30)
	_o3_.SetReadsQ([ "edge", "node.kind" ])
	_o3_.GovernsQ(func oGraph { return _FmOfKind(oGraph, "person") })
	_o3_.ExcludesQ(func oGraph { return _FmNotOfKind(oGraph, "person") })
	_o3_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _FmKindOf(oGraph, _a_[_i_]) != "person"  loop  ok
			_n_ = len(_FmUp(oGraph, _a_[_i_]))
			if _n_ > 1
				_aOut_ + [ :where = _a_[_i_], :message = "'" + oGraph.NodeProperty(_a_[_i_], "name") +
					"' is born of " + _n_ + " unions" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o3_)

	# PARENTS ARE OLDER, where the years are given.
	_o4_ = new stzFamilyRule("parents_are_older")
	_o4_.SetSeverityQ("warning")
	_o4_.SetMessageQ("a child is born after both parents")
	_o4_.SetOrderQ(40)
	_o4_.SetReadsQ([ "edge", "node.kind", "node.born" ])
	# governs the people whose birth year AND a parent's are known
	_o4_.GovernsQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _FmKindOf(oGraph, _a_[_i_]) != "person"  loop  ok
			if _FmDatedPair(oGraph, _a_[_i_])  _r_ + ("person:" + StzLower("" + _a_[_i_]))  ok
		next
		return _r_
	})
	_o4_.ExcludesQ(func oGraph {
		_r_ = _FmNotOfKind(oGraph, "person")
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _FmKindOf(oGraph, _a_[_i_]) != "person"  loop  ok
			if NOT _FmDatedPair(oGraph, _a_[_i_])  _r_ + ("person:" + StzLower("" + _a_[_i_]))  ok
		next
		return _r_
	})
	_o4_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _FmKindOf(oGraph, _a_[_i_]) != "person"  loop  ok
			_nB_ = oGraph.NodeProperty(_a_[_i_], "born")
			if NOT isNumber(_nB_) or _nB_ <= 0  loop  ok
			_aU_ = _FmUp(oGraph, _a_[_i_])
			for _u_ = 1 to len(_aU_)
				_aP_ = _FmUp(oGraph, _aU_[_u_])
				for _p_ = 1 to len(_aP_)
					_nPb_ = oGraph.NodeProperty(_aP_[_p_], "born")
					if NOT isNumber(_nPb_) or _nPb_ <= 0  loop  ok
					if _nPb_ >= _nB_
						_aOut_ + [ :where = _a_[_i_], :message = "'" + oGraph.NodeProperty(_a_[_i_], "name") +
							"' is born in " + _nB_ + " and their parent '" + oGraph.NodeProperty(_aP_[_p_], "name") +
							"' in " + _nPb_ ]
					ok
				next
			next
		next
		return _aOut_
	})
	poSet.AddRule(_o4_)

	# PARTNERS ARE NOT KIN, in the line: a union does not join a person to
	# their own ancestor or descendant.
	_o5_ = new stzFamilyRule("partners_are_not_kin")
	_o5_.SetSeverityQ("error")
	_o5_.SetMessageQ("a union does not join a person to their own ancestor or descendant")
	_o5_.SetOrderQ(50)
	_o5_.SetReadsQ([ "edge", "node.kind" ])
	_o5_.GovernsQ(func oGraph { return _FmOfKind(oGraph, "union") })
	_o5_.ExcludesQ(func oGraph { return _FmNotOfKind(oGraph, "union") })
	_o5_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _FmKindOf(oGraph, _a_[_i_]) != "union"  loop  ok
			_aP_ = _FmUp(oGraph, _a_[_i_])
			for _x_ = 1 to len(_aP_)
				for _y_ = 1 to len(_aP_)
					if _x_ = _y_  loop  ok
					if _FmIn(_aP_[_y_], _FmAbove(oGraph, _aP_[_x_]))
						_aOut_ + [ :where = _a_[_i_], :message = "'" + oGraph.NodeProperty(_aP_[_x_], "name") +
							"' is joined to their own ancestor '" + oGraph.NodeProperty(_aP_[_y_], "name") + "'" ]
					ok
				next
			next
		next
		return _aOut_
	})
	poSet.AddRule(_o5_)

# does this person have a known birth year AND a parent with one?
func _FmDatedPair(oGraph, pcId)
	_nB_ = oGraph.NodeProperty(pcId, "born")
	if NOT isNumber(_nB_) or _nB_ <= 0  return FALSE  ok
	_aU_ = _FmUp(oGraph, pcId)
	for _u_ = 1 to len(_aU_)
		_aP_ = _FmUp(oGraph, _aU_[_u_])
		for _p_ = 1 to len(_aP_)
			_nPb_ = oGraph.NodeProperty(_aP_[_p_], "born")
			if isNumber(_nPb_) and _nPb_ > 0  return TRUE  ok
		next
	next
	return FALSE

# CLASSES LAST, FUNCTIONS FIRST.

#---------------------------------------------------------------------#
#  THE TREE                                                            #
#---------------------------------------------------------------------#

# Draws a family tree and answers kinship questions: a person is a box with the years beneath the name, and every child hangs from a union dot.
#
# A union is a small dot between two partners and every child hangs from a union, which is what
# makes two parents drawable: the child has one line up, to the dot, and the dot has one line to
# each partner. Marry joins two people and answers the union's identifier, Child and ChildOf hang
# children from it, and the kinship questions (PartnersOf, ChildrenOf, ParentsOf, SiblingsOf,
# AncestorsOf, DescendantsOf, GenerationOf) are read off the tree. Five rules judge it. Not here:
# adoption, step-relations, ordering siblings by birth, and dates (years are numbers). ToCanvasXT
# draws the tree.
#
#   receiver   o1 = new stzFamilyTree("kin")
#   example    o1.AddPersonXT("anna", "Anna", 1930, 2001)
#              o1.AddPersonXT("boris", "Boris", 1928, 0)
#              o1.AddPerson("carl", "Carl")
#              o1.AddPerson("dora", "Dora")
#              o1.AddPerson("eva", "Eva")
#              o1.AddPerson("fred", "Fred")
#              o1.ChildOf("anna", "boris", "carl")
#              o1.ChildOf("anna", "boris", "dora")
#              o1.ChildOf("carl", "eva", "fred")
#              ? @@( o1.ChildrenOf("anna") )
#              #--> [ "carl", "dora" ]
#              ? @@( o1.SiblingsOf("carl") )
#              #--> [ "dora" ]
#              ? o1.GenerationOf("fred")
#              #--> 3
#              ? len(o1.AncestorsOf("fred"))
#              #--> 4
#              ? o1.GovernanceIsSound()
#              #--> 1
#   see        stzFamilyRuleSet, stzDiagram, stzFaultTree, stzPetriNet
class stzFamilyTree from stzDiagram

	# [ [ :id, :name, :born, :died ] ], 0 for an unknown year
	@aPeople = []
	# [ [ :id, :partners ] ]
	@aUnions = []
	# [ [ :union, :child ] ]
	@aBirths = []
	@aNotes = []

	# Builds an empty family tree that draws top-down with the family notation, with a title.
	#
	#   pcTitle    the title of the diagram
	#   returns    nothing; the object is built
	#   see        AddPerson, Marry
	def init(pcTitle)
		super.init(pcTitle)
		This.SetNotation(StzFamilyNotation())

	# Declares a person, drawn as a box with a name; AddPersonXT adds the years of birth and death.
	#
	#   pcId       the person's identifier, which must be new in the tree
	#   pcName     the name shown in the box
	#   returns    the tree itself, so calls chain
	#   note       AddPersonQ and AddPersonXTQ are the same calls
	#   warning    an identifier already in the tree raises an error; a year that is not a number,
	#              or a death before the birth when both are known, raises an error; the years are
	#              numbers, not dates
	#   see        Marry, AddNote
	#@ aka  -- the people ----------------------------------------------------------
	def AddPerson(pcId, pcName)
		return This.AddPersonXT(pcId, pcName, 0, 0)

	def AddPersonXT(pcId, pcName, pnBorn, pnDied)
		This._FmNoNode(pcId)
		if NOT isNumber(pnBorn) or NOT isNumber(pnDied)
			stzraise("stzFamilyTree: the years are numbers, 0 for unknown.")
		ok
		if pnDied > 0 and pnBorn > 0 and pnDied < pnBorn
			stzraise("stzFamilyTree: '" + pcName + "' dies in " + pnDied + " before being born in " + pnBorn + ".")
		ok
		@aPeople + [ :id = "" + pcId, :name = "" + pcName, :born = pnBorn, :died = pnDied ]
		_cY_ = This._FmYears(pnBorn, pnDied)
		if _cY_ = ""
			This.AddNodeXTT(pcId, pcName, [ :type = "person" ])
		else
			This.AddNodeXTT(pcId, pcName, [ :type = "person", :years = [ _cY_ ] ])
		ok
		return This

		def AddPersonQ(pcId, pcName)
			return This.AddPerson(pcId, pcName)

		def AddPersonXTQ(pcId, pcName, pnBorn, pnDied)
			return This.AddPersonXT(pcId, pcName, pnBorn, pnDied)

	# Adds a free note to the drawing; it is not a person of the tree.
	#
	#   pcId       the note's identifier
	#   pcText     the text of the note
	#   returns    the tree itself, so calls chain
	#   warning    the rules and the kinship questions ignore a note
	#   see        AddPerson
	def AddNote(pcId, pcText)
		@aNotes + ("" + pcId)
		This.AddNodeXTT(pcId, pcText, [ :type = "note" ])
		return This

	def _FmYears(pnBorn, pnDied)
		if pnBorn <= 0 and pnDied <= 0  return ""  ok
		_c_ = ""
		if pnBorn > 0  _c_ = "" + pnBorn  else  _c_ = "?"  ok
		if pnDied > 0  _c_ += " - " + pnDied  ok
		return _c_

	# Joins two people in a union, a dot between the partners, and returns the union's identifier.
	#
	#   pcA        the identifier of the first partner
	#   pcB        the identifier of the second partner
	#   returns    a text, the union's identifier, u1 for the first union, u2 for the next
	#   warning    marrying a pair already joined, in either order, answers the union they have and
	#              adds none; an unknown person raises an error; the identifier is built from the
	#              number of unions, so it repeats an identifier you gave AddUnion by hand: after
	#              AddUnion("u2", ...) the next new pair also gets u2 and Unions lists two unions
	#              with that identifier
	#   see        UnionOf, Child, ChildOf, AddUnion
	#@ aka  -- the unions -----------------------------------------------------------
	def Marry(pcA, pcB)
		_cU_ = This.UnionOf(pcA, pcB)
		if _cU_ != ""  return _cU_  ok
		if This._FmPersonIndex(pcA) = 0 or This._FmPersonIndex(pcB) = 0
			stzraise("stzFamilyTree: a union joins two people of this tree -- '" + pcA + "' and '" + pcB + "'.")
		ok
		_cU_ = "u" + (len(@aUnions) + 1)
		This._FmAddUnion(_cU_, [ "" + pcA, "" + pcB ])
		return _cU_

	# Adds a union under an identifier you choose, with any number of partners.
	#
	#   pcId          the union's identifier, which must be new in the tree
	#   pacPartners   the identifiers of the partners, as a list
	#   returns       the tree itself, so calls chain
	#   warning       one partner is a single parent and three or more is not a union: the rule
	#                 union_has_two_partners reports both as a warning; an unknown partner raises an
	#                 error
	#   see           Marry, Child
	#@ aka  a union with the partners named -- one for a single parent, or however many the author insists on, which the rules will judge
	def AddUnion(pcId, pacPartners)
		This._FmNoNode(pcId)
		for _i_ = 1 to len(pacPartners)
			if This._FmPersonIndex(pacPartners[_i_]) = 0
				stzraise("stzFamilyTree: '" + pacPartners[_i_] + "' is not a person of this tree.")
			ok
		next
		This._FmAddUnion("" + pcId, pacPartners)
		return This

	def _FmAddUnion(pcId, pacPartners)
		_aP_ = []
		for _i_ = 1 to len(pacPartners)  _aP_ + ("" + pacPartners[_i_])  next
		@aUnions + [ :id = "" + pcId, :partners = _aP_ ]
		This.AddNodeXTT(pcId, "", [ :type = "union" ])
		for _i_ = 1 to len(_aP_)
			This.AddEdgeXTT(_aP_[_i_], pcId, "", [ :type = "partner" ])
		next

	# Returns the identifier of the union that joins two people, in either order.
	#
	#   pcA        the identifier of one partner
	#   pcB        the identifier of the other
	#   returns    a text; empty when the two are not joined
	#   warning    only unions of exactly two partners are searched
	#   see        Marry, PartnersOf
	def UnionOf(pcA, pcB)
		for _i_ = 1 to len(@aUnions)
			if len(@aUnions[_i_][:partners]) != 2  loop  ok
			_p1_ = StzLower(@aUnions[_i_][:partners][1])
			_p2_ = StzLower(@aUnions[_i_][:partners][2])
			if (_p1_ = StzLower("" + pcA) and _p2_ = StzLower("" + pcB)) or
			   (_p1_ = StzLower("" + pcB) and _p2_ = StzLower("" + pcA))
				return @aUnions[_i_][:id]
			ok
		next
		return ""

	# Hangs a person from a union as a child of its partners.
	#
	#   pcUnion    the identifier of the union
	#   pcChild    the identifier of the person born of it
	#   returns    the tree itself, so calls chain
	#   warning    an unknown union or an unknown person raises an error; a person given two unions
	#              is reported by the rule child_of_one_union
	#   see        ChildOf, Marry, ParentsOf
	def Child(pcUnion, pcChild)
		if This._FmUnionIndex(pcUnion) = 0
			stzraise("stzFamilyTree: '" + pcUnion + "' is not a union of this tree.")
		ok
		if This._FmPersonIndex(pcChild) = 0
			stzraise("stzFamilyTree: '" + pcChild + "' is not a person of this tree.")
		ok
		@aBirths + [ :union = "" + pcUnion, :child = "" + pcChild ]
		This.AddEdgeXTT(pcUnion, pcChild, "", [ :type = "child" ])
		return This

	# Records a child of two parents, joining the parents in a union first if they are not joined yet.
	#
	#   pcA        the identifier of one parent
	#   pcB        the identifier of the other parent
	#   pcChild    the identifier of the child
	#   returns    the tree itself, so calls chain
	#   note       ChildOfQ is the same call
	#   warning    an unknown person raises an error
	#   see        Child, Marry
	#@ aka  ChildOf(a, b, child): the two are married if they are not yet
	def ChildOf(pcA, pcB, pcChild)
		_cU_ = This.Marry(pcA, pcB)
		This.Child(_cU_, pcChild)
		return This

		def ChildOfQ(pcA, pcB, pcChild)
			return This.ChildOf(pcA, pcB, pcChild)

	# Returns the people of the tree, in the order they were added.
	#
	#   returns    a list of hashlists with the keys id, name, born and died; 0 stands for an
	#              unknown year
	#   see        Unions, AddPerson
	def People()
		return @aPeople

	# Returns the unions of the tree, in the order they were made.
	#
	#   returns    a list of hashlists with the keys id and partners, the partners being a list of
	#              identifiers
	#   see        People, Marry
	def Unions()
		return @aUnions

	# Returns the people a person is joined to in unions, in the order of the unions.
	#
	#   pcId       the identifier of the person, without regard to case
	#   returns    a list of identifiers; empty for a person with no union or an unknown identifier
	#   see        UnionOf, ChildrenOf
	#@ aka  -- kinship, read off the tree ----------------------------------------
	def PartnersOf(pcId)
		_r_ = []
		for _i_ = 1 to len(@aUnions)
			_aP_ = @aUnions[_i_][:partners]
			if NOT _FmIn(pcId, _aP_)  loop  ok
			for _k_ = 1 to len(_aP_)
				if StzLower(_aP_[_k_]) != StzLower("" + pcId)  _r_ + _aP_[_k_]  ok
			next
		next
		return _r_

	# Returns the children born of the unions a person belongs to, in the order the unions and births were made.
	#
	#   pcId       the identifier of the person, without regard to case
	#   returns    a list of identifiers; empty when there is none
	#   see        ParentsOf, DescendantsOf, SiblingsOf
	def ChildrenOf(pcId)
		_r_ = []
		for _i_ = 1 to len(@aUnions)
			if NOT _FmIn(pcId, @aUnions[_i_][:partners])  loop  ok
			for _b_ = 1 to len(@aBirths)
				if StzLower(@aBirths[_b_][:union]) = StzLower(@aUnions[_i_][:id])  _r_ + @aBirths[_b_][:child]  ok
			next
		next
		return _r_

	# Returns the partners of the union a person was born of.
	#
	#   pcId       the identifier of the person, without regard to case
	#   returns    a list of identifiers, usually two; empty when no union was given for the person
	#   see        ChildrenOf, AncestorsOf
	def ParentsOf(pcId)
		_r_ = []
		for _b_ = 1 to len(@aBirths)
			if StzLower(@aBirths[_b_][:child]) != StzLower("" + pcId)  loop  ok
			_u_ = This._FmUnionIndex(@aBirths[_b_][:union])
			if _u_ = 0  loop  ok
			for _k_ = 1 to len(@aUnions[_u_][:partners])  _r_ + @aUnions[_u_][:partners][_k_]  next
		next
		return _r_

	# Returns the other children of the unions a person was born of.
	#
	#   pcId       the identifier of the person, without regard to case
	#   returns    a list of identifiers, each once; empty when there is none
	#   warning    only children of the same union count: half-siblings through another union are
	#              not listed
	#   see        ParentsOf, ChildrenOf
	def SiblingsOf(pcId)
		_r_ = []
		for _b_ = 1 to len(@aBirths)
			if StzLower(@aBirths[_b_][:child]) != StzLower("" + pcId)  loop  ok
			for _c_ = 1 to len(@aBirths)
				if StzLower(@aBirths[_c_][:union]) != StzLower(@aBirths[_b_][:union])  loop  ok
				if StzLower(@aBirths[_c_][:child]) = StzLower("" + pcId)  loop  ok
				if NOT _FmIn(@aBirths[_c_][:child], _r_)  _r_ + @aBirths[_c_][:child]  ok
			next
		next
		return _r_

	# Returns every ancestor of a person, parents first and then up each line.
	#
	#   pcId       the identifier of the person, without regard to case
	#   returns    a list of identifiers, each once; empty when no parent is known
	#   warning    the order is the walk's, not the generation's: the last parent comes first
	#   see        ParentsOf, DescendantsOf, GenerationOf
	def AncestorsOf(pcId)
		_r_ = []
		_aStack_ = This.ParentsOf(pcId)
		_n_ = 0
		while len(_aStack_) > 0 and _n_ < 10000
			_n_++
			_c_ = _aStack_[len(_aStack_)]
			del(_aStack_, len(_aStack_))
			if _FmIn(_c_, _r_)  loop  ok
			_r_ + _c_
			_aP_ = This.ParentsOf(_c_)
			for _k_ = 1 to len(_aP_)  _aStack_ + _aP_[_k_]  next
		end
		return _r_

	# Returns every descendant of a person, children and then down each line.
	#
	#   pcId       the identifier of the person, without regard to case
	#   returns    a list of identifiers, each once; empty when there is no child
	#   warning    the order is the walk's, not the generation's
	#   see        ChildrenOf, AncestorsOf
	def DescendantsOf(pcId)
		_r_ = []
		_aStack_ = This.ChildrenOf(pcId)
		_n_ = 0
		while len(_aStack_) > 0 and _n_ < 10000
			_n_++
			_c_ = _aStack_[len(_aStack_)]
			del(_aStack_, len(_aStack_))
			if _FmIn(_c_, _r_)  loop  ok
			_r_ + _c_
			_aK_ = This.ChildrenOf(_c_)
			for _k_ = 1 to len(_aK_)  _aStack_ + _aK_[_k_]  next
		end
		return _r_

	# Returns the generation of a person counted from the oldest known ancestor.
	#
	#   pcId       the identifier of the person, without regard to case
	#   returns    a number: 1 for a person with no known parent, then one more for each step down
	#              the longest line
	#   warning    an identifier that is not in the tree answers 1
	#   see        AncestorsOf, ParentsOf
	#@ aka  the generation counted from the oldest ancestor: 1 for a person with no known parent, one more per step down
	def GenerationOf(pcId)
		_aP_ = This.ParentsOf(pcId)
		if len(_aP_) = 0  return 1  ok
		_best_ = 0
		for _k_ = 1 to len(_aP_)
			if _FmIn(pcId, This.AncestorsOf(_aP_[_k_]))  loop  ok
			_g_ = This.GenerationOf(_aP_[_k_])
			if _g_ > _best_  _best_ = _g_  ok
		next
		return _best_ + 1

	# Returns the tree as a plain graph that the five family rules read.
	#
	#   returns    a stzGraph with the people, unions and notes as nodes and the partner and child
	#              lines as edges
	#   see        GovernanceFindings
	#@ aka  -- the projection the rules read ------------------------------------
	def AsRuleGraph()
		_oG_ = new stzGraph("family-rules")
		for _i_ = 1 to len(@aPeople)
			_p_ = @aPeople[_i_]
			_oG_.AddNode(_p_[:id])
			_oG_.SetNodeProperty(_p_[:id], "kind", "person")
			_oG_.SetNodeProperty(_p_[:id], "name", _p_[:name])
			_oG_.SetNodeProperty(_p_[:id], "born", _p_[:born])
		next
		for _i_ = 1 to len(@aUnions)
			_oG_.AddNode(@aUnions[_i_][:id])
			_oG_.SetNodeProperty(@aUnions[_i_][:id], "kind", "union")
			_oG_.SetNodeProperty(@aUnions[_i_][:id], "name", @aUnions[_i_][:id])
		next
		for _i_ = 1 to len(@aNotes)
			_oG_.AddNode(@aNotes[_i_])
			_oG_.SetNodeProperty(@aNotes[_i_], "kind", "note")
			_oG_.SetNodeProperty(@aNotes[_i_], "name", @aNotes[_i_])
		next
		for _i_ = 1 to len(@aUnions)
			for _k_ = 1 to len(@aUnions[_i_][:partners])
				if NOT _oG_.EdgeExists(@aUnions[_i_][:partners][_k_], @aUnions[_i_][:id])
					_oG_.AddEdgeXTT(@aUnions[_i_][:partners][_k_], @aUnions[_i_][:id], "", [ :type = "partner" ])
				ok
			next
		next
		for _i_ = 1 to len(@aBirths)
			if NOT _oG_.EdgeExists(@aBirths[_i_][:union], @aBirths[_i_][:child])
				_oG_.AddEdgeXTT(@aBirths[_i_][:union], @aBirths[_i_][:child], "", [ :type = "child" ])
			ok
		next
		return _oG_

	# Returns what the five family rules find wrong with the tree, warnings included.
	#
	#   returns    a list of findings, each a hashlist with the keys rule, where, severity and
	#              message; empty when the tree is sound
	#   note       CheckRules is the same call
	#   warning    the rules are no_one_is_own_ancestor, union_has_two_partners, child_of_one_union,
	#              parents_are_older and partners_are_not_kin
	#   see        GovernanceIsSound, AsRuleGraph
	def GovernanceFindings()
		return StzFamilyRuleSetQ().Check(This.AsRuleGraph())

	# TRUE if the rules found no error; warnings do not count against it.
	#
	#   returns    TRUE or FALSE
	#   warning    RulesAreSound is the same call; a single parent is a warning, so such a tree is
	#              still sound
	#   see        GovernanceFindings
	#@ aka  SOUND IS NO ERROR, not no finding: this family's rules set their severity deliberately, and a warning says the picture may stand. StzFindingsAreSound is the house's one answer; GovernanceFindings() is still every finding, warnings included, for a caller who wants them.
	def GovernanceIsSound()
		return StzFindingsAreSound(This.GovernanceFindings())

	def CheckRules()
		return This.GovernanceFindings()

	def RulesAreSound()
		return This.GovernanceIsSound()

	#-- helpers ---------------------------------------------------------------

	def _FmPersonIndex(pcId)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aPeople)
			if StzLower(@aPeople[_i_][:id]) = _c_  return _i_  ok
		next
		return 0

	def _FmUnionIndex(pcId)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aUnions)
			if StzLower(@aUnions[_i_][:id]) = _c_  return _i_  ok
		next
		return 0

	def _FmNoNode(pcId)
		if This._FmPersonIndex(pcId) > 0 or This._FmUnionIndex(pcId) > 0
			stzraise("stzFamilyTree: '" + pcId + "' is already in this tree.")
		ok

# Holds one named check of the family-tree governance, run over the rule graph of a tree.
#
# It is a graph rule filed under the family domain. The five rules the library ships are built by
# stzFamilyRuleSet and applied through the tree's GovernanceFindings; a rule of your own can be
# added to a set the same way.
#
#   receiver   o1 = new stzFamilyRule("my_rule")
#   example    ? o1.Name()
#              #--> my_rule
#              ? o1.Domain()
#              #--> family
#   see        stzFamilyRuleSet, stzFamilyTree, stzGraphRule
class stzFamilyRule from stzGraphRule
	# Builds a named rule of the family-tree governance, filed under the family domain.
	#
	#   pcName     the rule's name, such as parents_are_older
	#   returns    nothing; the object is built
	#   see        stzFamilyRuleSet, stzFamilyTree
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("family")

# Holds the five rules a family tree is judged by: no one is their own ancestor, a union has two partners, a child has one union, parents are older, partners are not kin.
#
# Check takes the rule graph of a tree (AsRuleGraph) and answers the findings. A tree asks for this
# through its own GovernanceFindings, so a rule set is built by hand only to add a rule of your own
# or to run the rules on a graph. A single parent, a union with one partner, is a warning and not an
# error.
#
#   receiver   o1 = new stzFamilyRuleSet()
#   example    ? o1.Name()
#              #--> family-governance
#              ? o1.NumberOfRules()
#              #--> 5
#              ? o1.RuleNames()[1]
#              #--> no_one_is_own_ancestor
#   see        stzFamilyRule, stzFamilyTree, stzGraphRuleSet
class stzFamilyRuleSet from stzGraphRuleSet
	# Builds the family-tree governance, the set of five rules a family tree is judged by.
	#
	#   returns    nothing; the object is built
	#   warning    the rules are no_one_is_own_ancestor, union_has_two_partners, child_of_one_union,
	#              parents_are_older and partners_are_not_kin, in that order
	#   see        stzFamilyRule, StzFamilyRuleSetQ, GovernanceFindings
	def init()
		super.init("family-governance")
		This.SetDomainQ("family")
		_StzAddFamilyRules(This)
