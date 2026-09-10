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

class stzFamilyTree from stzDiagram

	# [ [ :id, :name, :born, :died ] ], 0 for an unknown year
	@aPeople = []
	# [ [ :id, :partners ] ]
	@aUnions = []
	# [ [ :union, :child ] ]
	@aBirths = []
	@aNotes = []

	def init(pcTitle)
		super.init(pcTitle)
		This.SetNotation(StzFamilyNotation())

	#-- the people ----------------------------------------------------------

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

	#-- the unions -----------------------------------------------------------

	# Marry(a, b) -> the union's id. A union joins the two; marrying a
	# pair already married answers the union they have.
	def Marry(pcA, pcB)
		_cU_ = This.UnionOf(pcA, pcB)
		if _cU_ != ""  return _cU_  ok
		if This._FmPersonIndex(pcA) = 0 or This._FmPersonIndex(pcB) = 0
			stzraise("stzFamilyTree: a union joins two people of this tree -- '" + pcA + "' and '" + pcB + "'.")
		ok
		_cU_ = "u" + (len(@aUnions) + 1)
		This._FmAddUnion(_cU_, [ "" + pcA, "" + pcB ])
		return _cU_

	# a union with the partners named -- one for a single parent, or
	# however many the author insists on, which the rules will judge
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

	# ChildOf(a, b, child): the two are married if they are not yet
	def ChildOf(pcA, pcB, pcChild)
		_cU_ = This.Marry(pcA, pcB)
		This.Child(_cU_, pcChild)
		return This

		def ChildOfQ(pcA, pcB, pcChild)
			return This.ChildOf(pcA, pcB, pcChild)

	def People()
		return @aPeople

	def Unions()
		return @aUnions

	#-- kinship, read off the tree ----------------------------------------

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

	def ChildrenOf(pcId)
		_r_ = []
		for _i_ = 1 to len(@aUnions)
			if NOT _FmIn(pcId, @aUnions[_i_][:partners])  loop  ok
			for _b_ = 1 to len(@aBirths)
				if StzLower(@aBirths[_b_][:union]) = StzLower(@aUnions[_i_][:id])  _r_ + @aBirths[_b_][:child]  ok
			next
		next
		return _r_

	def ParentsOf(pcId)
		_r_ = []
		for _b_ = 1 to len(@aBirths)
			if StzLower(@aBirths[_b_][:child]) != StzLower("" + pcId)  loop  ok
			_u_ = This._FmUnionIndex(@aBirths[_b_][:union])
			if _u_ = 0  loop  ok
			for _k_ = 1 to len(@aUnions[_u_][:partners])  _r_ + @aUnions[_u_][:partners][_k_]  next
		next
		return _r_

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

	# the generation counted from the oldest ancestor: 1 for a person
	# with no known parent, one more per step down
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

	#-- the projection the rules read ------------------------------------

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

	def GovernanceFindings()
		return StzFamilyRuleSetQ().Check(This.AsRuleGraph())

	def GovernanceIsSound()
		return len(This.GovernanceFindings()) = 0

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

class stzFamilyRule from stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("family")

class stzFamilyRuleSet from stzGraphRuleSet
	def init()
		super.init("family-governance")
		This.SetDomainQ("family")
		_StzAddFamilyRules(This)
