#=====================================================================#
#  STZPETRINET -- DN16: a Petri net is a picture whose STATE is on it  #
#=====================================================================#
/*
	THE FOURTH NEW DOMAIN, and the first whose picture carries a state:
	the marking. A place holds tokens, a transition moves them, and the
	same drawing read twice a moment apart shows two different facts.
	Nothing else on this plane has that -- an org chart, a schema, a
	circuit are what they are until the author edits them.

	It lives on the GRAPH plane: places and transitions are typed nodes,
	arcs are directed edges, and the net is bipartite by definition -- an
	arc joins a place to a transition or a transition to a place, never
	two of a kind. Places are circles with their name beneath, as every
	round cell here is drawn; transitions are bars across the flow;
	tokens are dots inside the place, drawn by the diagram itself after
	the glyph and before any name, and published like every other drawn
	fact.

	WHAT IT IS HERE:

	    NOTATION   "petri": place (circle, name below), transition (a bar
	               across the flow, name below), note (a comment, not a
	               node of the net -- the boundary every rule is stood on).
	               Directed, left to right.

	    DIAGRAM    stzPetriNet from stzDiagram: AddPlace / AddPlaceXT with
	               an initial marking, AddTransition, AddNote, Arc and
	               ArcXT with a weight. And the token game: Tokens,
	               SetTokens, Marking, IsEnabled, Enabled, Fire -- a
	               transition fires only when every input place holds at
	               least its arc's weight, and firing moves the tokens.
	               A refused firing says which place is short and by how
	               much.

	    RULES      five, into the one report through GovernanceFindings
	               like the org chart's:

	               arc_joins_place_and_transition   an arc joins one of
	                                                each kind, never two
	                                                places or two
	                                                transitions
	               transition_has_input             a transition with no
	                                                input fires forever
	               transition_has_output            a transition with no
	                                                output consumes into
	                                                nothing
	               place_can_be_marked              a place with no token
	                                                and nothing feeding it
	                                                is empty forever
	               transition_can_fire              a transition fed by
	                                                such a place is dead

	    PICTURE    tokens are drawn inside the place -- one to four as
	               dots, more as the number -- and published through
	               RenderTokens() as [ place, count, x, y ] so the gate
	               reads what was drawn and not what was meant.

	WHAT IS SAID PLAINLY: reachability, boundedness and liveness in the
	full sense are not computed -- the fifth rule is the structural case,
	a transition starved at birth. Inhibitor arcs, coloured tokens, timed
	transitions and priorities are not here.
*/

#---------------------------------------------------------------------#
#  THE NOTATION                                                        #
#---------------------------------------------------------------------#

func StzPetriNotation()
	_o_ = StzNotation("petri")
	if _o_.Name_() = "petri"  return _o_  ok
	_o_ = new stzNotation("petri")
	_o_.SetRankDir(:LeftToRight)
	_o_.SetSplines(:ortho)
	_o_.SetEdgesDirected(1)
	# a place is a round cell, drawn at seven tenths of the box so the
	# tokens have room and the name goes beneath; a transition is a bar
	# across the flow at the full box
	_o_.AddKindXTT("place", "circle", "white", 0.70)
	# a bar's box IS its ink: a tenth of the cell across the flow, so an
	# arc arriving at the box arrives at the bar
	_o_.AddKindXTT("transition", "bar", "#333333", 0.10)
	_o_.AddKindXT("note", "note", "white")
	# the inside of a place is for its tokens, and a bar has no inside
	_o_.SetNameOutside("place")
	_o_.SetNameOutside("transition")
	StzRegisterNotation(_o_)
	return _o_

#---------------------------------------------------------------------#
#  THE RULES                                                           #
#---------------------------------------------------------------------#

func StzPetriRuleSetQ()
	return new stzPetriRuleSet()

func _PnKindOf(oGraph, pcId)
	return StzLower("" + oGraph.NodeProperty(pcId, "kind"))

func _PnTokensOf(oGraph, pcId)
	_v_ = oGraph.NodeProperty(pcId, "tokens")
	if isNumber(_v_)  return _v_  ok
	return 0

# the ids of the nodes with an arc INTO pcId
func _PnFeeders(oGraph, pcId)
	_r_ = []
	_a_ = oGraph.Edges()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][:to]) = StzLower("" + pcId)  _r_ + ("" + _a_[_i_][:from])  ok
	next
	return _r_

# the ids of the nodes with an arc OUT OF pcId
func _PnFed(oGraph, pcId)
	_r_ = []
	_a_ = oGraph.Edges()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][:from]) = StzLower("" + pcId)  _r_ + ("" + _a_[_i_][:to])  ok
	next
	return _r_

# a place that holds no token and that no transition feeds: empty forever
func _PnStarved(oGraph, pcId)
	if _PnKindOf(oGraph, pcId) != "place"  return FALSE  ok
	if _PnTokensOf(oGraph, pcId) > 0  return FALSE  ok
	_aF_ = _PnFeeders(oGraph, pcId)
	for _i_ = 1 to len(_aF_)
		if _PnKindOf(oGraph, _aF_[_i_]) = "transition"  return FALSE  ok
	next
	return TRUE

func _PnNodesOfKind(oGraph, pcKind, pcPrefix)
	_r_ = []
	_a_ = oGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		if _PnKindOf(oGraph, _a_[_i_]) = pcKind  _r_ + (pcPrefix + StzLower("" + _a_[_i_]))  ok
	next
	return _r_

func _PnNodesNotOfKind(oGraph, pcKind)
	_r_ = []
	_a_ = oGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		_k_ = _PnKindOf(oGraph, _a_[_i_])
		if _k_ != pcKind  _r_ + (_k_ + ":" + StzLower("" + _a_[_i_]))  ok
	next
	return _r_

func _StzAddPetriRules(poSet)

	# THE NET IS BIPARTITE. An arc from a place to a place says tokens
	# move with nothing to move them; from a transition to a transition,
	# that something fires into nowhere. Neither is a Petri net.
	_o1_ = new stzPetriRule("arc_joins_place_and_transition")
	_o1_.SetSeverityQ("error")
	_o1_.SetMessageQ("every arc joins a place and a transition")
	_o1_.SetOrderQ(10)
	_o1_.SetReadsQ([ "edge", "node.kind" ])
	_o1_.GovernsQ(func oGraph {
		_r_ = []
		_a_ = oGraph.Edges()
		for _i_ = 1 to len(_a_)
			_r_ + ("arc:" + StzLower("" + _a_[_i_][:from]) + ">" + StzLower("" + _a_[_i_][:to]))
		next
		return _r_
	})
	# a note joins no arc: it is the boundary
	_o1_.ExcludesQ(func oGraph { return _PnNodesOfKind(oGraph, "note", "note:") })
	_o1_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.Edges()
		for _i_ = 1 to len(_a_)
			_cA_ = "" + _a_[_i_][:from]
			_cB_ = "" + _a_[_i_][:to]
			_kA_ = _PnKindOf(oGraph, _cA_)
			_kB_ = _PnKindOf(oGraph, _cB_)
			if (_kA_ = "place" and _kB_ = "transition") or (_kA_ = "transition" and _kB_ = "place")
				loop
			ok
			_cWhat_ = "two " + _kA_ + "s"
			if _kA_ != _kB_  _cWhat_ = "a " + _kA_ + " and a " + _kB_  ok
			_aOut_ + [ :where = _cA_ + ">" + _cB_, :message = "arc '" +
				oGraph.NodeProperty(_cA_, "name") + "' -> '" + oGraph.NodeProperty(_cB_, "name") +
				"' joins " + _cWhat_ + " -- a Petri arc joins a place and a transition" ]
		next
		return _aOut_
	})
	poSet.AddRule(_o1_)

	# A TRANSITION HAS AN INPUT. With none it is enabled at every moment
	# and fires forever -- a source, which is a modelling choice so rare
	# that it is more often a forgotten arc.
	_o2_ = new stzPetriRule("transition_has_input")
	_o2_.SetSeverityQ("warning")
	_o2_.SetMessageQ("every transition has an input place")
	_o2_.SetOrderQ(20)
	_o2_.SetReadsQ([ "edge", "node.kind" ])
	_o2_.GovernsQ(func oGraph { return _PnNodesOfKind(oGraph, "transition", "transition:") })
	_o2_.ExcludesQ(func oGraph { return _PnNodesNotOfKind(oGraph, "transition") })
	_o2_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _PnKindOf(oGraph, _a_[_i_]) != "transition"  loop  ok
			if len(_PnFeeders(oGraph, _a_[_i_])) = 0
				_aOut_ + [ :where = _a_[_i_], :message = "transition '" +
					oGraph.NodeProperty(_a_[_i_], "name") +
					"' has no input place -- it is enabled at every moment and fires forever" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o2_)

	# A TRANSITION HAS AN OUTPUT. With none, what it consumes vanishes.
	_o3_ = new stzPetriRule("transition_has_output")
	_o3_.SetSeverityQ("warning")
	_o3_.SetMessageQ("every transition has an output place")
	_o3_.SetOrderQ(20)
	_o3_.SetReadsQ([ "edge", "node.kind" ])
	_o3_.GovernsQ(func oGraph { return _PnNodesOfKind(oGraph, "transition", "transition:") })
	_o3_.ExcludesQ(func oGraph { return _PnNodesNotOfKind(oGraph, "transition") })
	_o3_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _PnKindOf(oGraph, _a_[_i_]) != "transition"  loop  ok
			if len(_PnFed(oGraph, _a_[_i_])) = 0
				_aOut_ + [ :where = _a_[_i_], :message = "transition '" +
					oGraph.NodeProperty(_a_[_i_], "name") +
					"' has no output place -- what it consumes vanishes" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o3_)

	# A PLACE CAN BE MARKED. No token now and no transition feeding it:
	# empty forever, and everything downstream of it waits forever.
	_o4_ = new stzPetriRule("place_can_be_marked")
	_o4_.SetSeverityQ("warning")
	_o4_.SetMessageQ("every place holds a token or is fed by a transition")
	_o4_.SetOrderQ(30)
	_o4_.SetReadsQ([ "edge", "node.kind", "node.tokens" ])
	_o4_.GovernsQ(func oGraph { return _PnNodesOfKind(oGraph, "place", "place:") })
	_o4_.ExcludesQ(func oGraph { return _PnNodesNotOfKind(oGraph, "place") })
	_o4_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _PnStarved(oGraph, _a_[_i_])  loop  ok
			_aOut_ + [ :where = _a_[_i_], :message = "place '" +
				oGraph.NodeProperty(_a_[_i_], "name") +
				"' holds no token and no transition feeds it -- it is empty forever" ]
		next
		return _aOut_
	})
	poSet.AddRule(_o4_)

	# A TRANSITION CAN FIRE. The structural case of liveness: a transition
	# with an input place that is empty forever is dead at birth, and
	# every arc out of it is a promise the net cannot keep.
	_o5_ = new stzPetriRule("transition_can_fire")
	_o5_.SetSeverityQ("error")
	_o5_.SetMessageQ("no transition is fed by a place that is empty forever")
	_o5_.SetOrderQ(40)
	_o5_.SetReadsQ([ "edge", "node.kind", "node.tokens" ])
	# governs the transitions that HAVE an input; one without is the
	# second rule's, and is the boundary here
	_o5_.GovernsQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _PnKindOf(oGraph, _a_[_i_]) != "transition"  loop  ok
			if len(_PnFeeders(oGraph, _a_[_i_])) > 0  _r_ + ("transition:" + StzLower("" + _a_[_i_]))  ok
		next
		return _r_
	})
	_o5_.ExcludesQ(func oGraph {
		_r_ = _PnNodesNotOfKind(oGraph, "transition")
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _PnKindOf(oGraph, _a_[_i_]) != "transition"  loop  ok
			if len(_PnFeeders(oGraph, _a_[_i_])) = 0  _r_ + ("transition:" + StzLower("" + _a_[_i_]))  ok
		next
		return _r_
	})
	_o5_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _PnKindOf(oGraph, _a_[_i_]) != "transition"  loop  ok
			_aF_ = _PnFeeders(oGraph, _a_[_i_])
			for _k_ = 1 to len(_aF_)
				if NOT _PnStarved(oGraph, _aF_[_k_])  loop  ok
				_aOut_ + [ :where = _a_[_i_], :message = "transition '" +
					oGraph.NodeProperty(_a_[_i_], "name") + "' can never fire: its input place '" +
					oGraph.NodeProperty(_aF_[_k_], "name") + "' is empty forever" ]
				exit
			next
		next
		return _aOut_
	})
	poSet.AddRule(_o5_)

# CLASSES LAST, FUNCTIONS FIRST: everything after the first `class` in a
# Ring file belongs to a class (stzErDiagram paid for this).

#---------------------------------------------------------------------#
#  THE NET                                                             #
#---------------------------------------------------------------------#

class stzPetriNet from stzDiagram

	# [ [ :id, :name, :tokens ] ]
	@aPlaces = []
	# [ [ :id, :name ] ]
	@aTransitions = []
	# [ [ :from, :to, :weight ] ]
	@aArcs = []
	@aNotes = []
	# what was drawn inside the places: [ place, count, x, y ]
	@aRenderTokens = []

	def init(pcTitle)
		super.init(pcTitle)
		This.SetNotation(StzPetriNotation())

	#-- the net ----------------------------------------------------------

	def AddPlace(pcId, pcName)
		return This.AddPlaceXT(pcId, pcName, 0)

	def AddPlaceXT(pcId, pcName, pnTokens)
		This._PnNoNode(pcId)
		if NOT isNumber(pnTokens) or pnTokens < 0 or pnTokens != floor(pnTokens)
			stzraise("stzPetriNet: a marking is a whole number of tokens, not '" + pnTokens + "'.")
		ok
		@aPlaces + [ :id = "" + pcId, :name = "" + pcName, :tokens = pnTokens ]
		This.AddNodeXTT(pcId, pcName, [ :type = "place", :tokens = pnTokens ])
		return This

		def AddPlaceQ(pcId, pcName)
			return This.AddPlace(pcId, pcName)

		def AddPlaceXTQ(pcId, pcName, pnTokens)
			return This.AddPlaceXT(pcId, pcName, pnTokens)

	def AddTransition(pcId, pcName)
		This._PnNoNode(pcId)
		@aTransitions + [ :id = "" + pcId, :name = "" + pcName ]
		This.AddNodeXTT(pcId, pcName, [ :type = "transition" ])
		return This

		def AddTransitionQ(pcId, pcName)
			return This.AddTransition(pcId, pcName)

	def AddNote(pcId, pcText)
		@aNotes + ("" + pcId)
		This.AddNodeXTT(pcId, pcText, [ :type = "note" ])
		return This

	# Arc(from, to): a token path. Accepted between any two nodes of the
	# net so the bipartite rule has something to report; refused only to
	# a node that is not in the net at all.
	def Arc(pcFrom, pcTo)
		return This.ArcXT(pcFrom, pcTo, 1)

	def ArcXT(pcFrom, pcTo, pnWeight)
		if This._PnPlaceIndex(pcFrom) = 0 and This._PnTransIndex(pcFrom) = 0
			stzraise("stzPetriNet: '" + pcFrom + "' is not a place or a transition of this net.")
		ok
		if This._PnPlaceIndex(pcTo) = 0 and This._PnTransIndex(pcTo) = 0
			stzraise("stzPetriNet: '" + pcTo + "' is not a place or a transition of this net.")
		ok
		if NOT isNumber(pnWeight) or pnWeight < 1 or pnWeight != floor(pnWeight)
			stzraise("stzPetriNet: an arc's weight is a whole number of tokens, at least one, not '" +
				pnWeight + "'.")
		ok
		@aArcs + [ :from = "" + pcFrom, :to = "" + pcTo, :weight = pnWeight ]
		_cL_ = ""
		if pnWeight > 1  _cL_ = "" + pnWeight  ok
		This.AddEdgeXTT(pcFrom, pcTo, _cL_, [ :weight = pnWeight ])
		return This

		def ArcQ(pcFrom, pcTo)
			return This.Arc(pcFrom, pcTo)

		def ArcXTQ(pcFrom, pcTo, pnWeight)
			return This.ArcXT(pcFrom, pcTo, pnWeight)

	def Places()
		return @aPlaces

	def Transitions()
		return @aTransitions

	def Arcs()
		return @aArcs

	#-- the token game ----------------------------------------------------

	def Tokens(pcPlace)
		_i_ = This._PnPlaceIndex(pcPlace)
		if _i_ = 0
			stzraise("stzPetriNet: '" + pcPlace + "' is not a place of this net.")
		ok
		return @aPlaces[_i_][:tokens]

	def SetTokens(pcPlace, pnTokens)
		_i_ = This._PnPlaceIndex(pcPlace)
		if _i_ = 0
			stzraise("stzPetriNet: '" + pcPlace + "' is not a place of this net.")
		ok
		if NOT isNumber(pnTokens) or pnTokens < 0 or pnTokens != floor(pnTokens)
			stzraise("stzPetriNet: a marking is a whole number of tokens, not '" + pnTokens + "'.")
		ok
		@aPlaces[_i_][:tokens] = pnTokens
		This.SetNodeProperty(pcPlace, "tokens", pnTokens)
		return This

	# [ [ place, tokens ] ... ] in the order the places were added
	def Marking()
		_r_ = []
		for _i_ = 1 to len(@aPlaces)
			_r_ + [ @aPlaces[_i_][:id], @aPlaces[_i_][:tokens] ]
		next
		return _r_

	# the input arcs of a transition: [ [ place, weight ] ... ]
	def InputsOf(pcTrans)
		_r_ = []
		_c_ = StzLower("" + pcTrans)
		for _i_ = 1 to len(@aArcs)
			if StzLower(@aArcs[_i_][:to]) = _c_ and This._PnPlaceIndex(@aArcs[_i_][:from]) > 0
				_r_ + [ @aArcs[_i_][:from], @aArcs[_i_][:weight] ]
			ok
		next
		return _r_

	def OutputsOf(pcTrans)
		_r_ = []
		_c_ = StzLower("" + pcTrans)
		for _i_ = 1 to len(@aArcs)
			if StzLower(@aArcs[_i_][:from]) = _c_ and This._PnPlaceIndex(@aArcs[_i_][:to]) > 0
				_r_ + [ @aArcs[_i_][:to], @aArcs[_i_][:weight] ]
			ok
		next
		return _r_

	# why a transition cannot fire, or "" when it can
	def WhyNotEnabled(pcTrans)
		if This._PnTransIndex(pcTrans) = 0
			stzraise("stzPetriNet: '" + pcTrans + "' is not a transition of this net.")
		ok
		_aIn_ = This.InputsOf(pcTrans)
		for _i_ = 1 to len(_aIn_)
			_n_ = This.Tokens(_aIn_[_i_][1])
			if _n_ < _aIn_[_i_][2]
				return "place '" + This._PnNameOf(_aIn_[_i_][1]) + "' holds " + _n_ +
					" and the arc wants " + _aIn_[_i_][2]
			ok
		next
		return ""

	def IsEnabled(pcTrans)
		return This.WhyNotEnabled(pcTrans) = ""

	def Enabled()
		_r_ = []
		for _i_ = 1 to len(@aTransitions)
			if This.IsEnabled(@aTransitions[_i_][:id])  _r_ + @aTransitions[_i_][:id]  ok
		next
		return _r_

	# FIRE: take each input arc's weight from its place, give each output
	# arc's weight to its place. Refused, by name and by number, when an
	# input is short -- a net never goes negative.
	def Fire(pcTrans)
		_cWhy_ = This.WhyNotEnabled(pcTrans)
		if _cWhy_ != ""
			stzraise("stzPetriNet: transition '" + This._PnNameOf(pcTrans) +
				"' is not enabled -- " + _cWhy_ + ".")
		ok
		_aIn_ = This.InputsOf(pcTrans)
		for _i_ = 1 to len(_aIn_)
			This.SetTokens(_aIn_[_i_][1], This.Tokens(_aIn_[_i_][1]) - _aIn_[_i_][2])
		next
		_aOut_ = This.OutputsOf(pcTrans)
		for _i_ = 1 to len(_aOut_)
			This.SetTokens(_aOut_[_i_][1], This.Tokens(_aOut_[_i_][1]) + _aOut_[_i_][2])
		next
		return This

		def FireQ(pcTrans)
			return This.Fire(pcTrans)

	#-- the projection the rules read ------------------------------------

	def AsRuleGraph()
		_oG_ = new stzGraph("petri-rules")
		for _i_ = 1 to len(@aPlaces)
			_oG_.AddNode(@aPlaces[_i_][:id])
			_oG_.SetNodeProperty(@aPlaces[_i_][:id], "kind", "place")
			_oG_.SetNodeProperty(@aPlaces[_i_][:id], "name", @aPlaces[_i_][:name])
			_oG_.SetNodeProperty(@aPlaces[_i_][:id], "tokens", @aPlaces[_i_][:tokens])
		next
		for _i_ = 1 to len(@aTransitions)
			_oG_.AddNode(@aTransitions[_i_][:id])
			_oG_.SetNodeProperty(@aTransitions[_i_][:id], "kind", "transition")
			_oG_.SetNodeProperty(@aTransitions[_i_][:id], "name", @aTransitions[_i_][:name])
		next
		for _i_ = 1 to len(@aNotes)
			_oG_.AddNode(@aNotes[_i_])
			_oG_.SetNodeProperty(@aNotes[_i_], "kind", "note")
			_oG_.SetNodeProperty(@aNotes[_i_], "name", @aNotes[_i_])
		next
		for _i_ = 1 to len(@aArcs)
			_r_ = @aArcs[_i_]
			if NOT _oG_.EdgeExists(_r_[:from], _r_[:to])
				_oG_.AddEdgeXTT(_r_[:from], _r_[:to], "", [ :weight = _r_[:weight] ])
			ok
		next
		return _oG_

	def GovernanceFindings()
		return StzPetriRuleSetQ().Check(This.AsRuleGraph())

	def GovernanceIsSound()
		return len(This.GovernanceFindings()) = 0

	def CheckRules()
		return This.GovernanceFindings()

	def RulesAreSound()
		return This.GovernanceIsSound()

	#-- the drawing ---------------------------------------------------------

	# what was drawn inside the places on the last render: [ place, count, x, y ]
	def RenderTokens()
		return @aRenderTokens

	# THE TOKENS, inside the place, after its glyph and before its name.
	# One to four are dots -- centre, pair, triangle, square -- and more
	# are written as the number, because a reader counts to four and
	# reads from five. Published either way.
	def _DrawNodeMark(oC, pcId, pnX, pnY, pnW, pnH, cStroke, nStkW, oFont, nFsz)
		_i_ = This._PnPlaceIndex(pcId)
		if _i_ = 0  return  ok
		_n_ = @aPlaces[_i_][:tokens]
		_cx_ = pnX + pnW / 2
		_cy_ = pnY + pnH / 2
		# the first cell drawn clears the previous render's record
		if len(@aRenderTokens) > 0 and @aRenderTokens[1][1] = StzLower("" + pcId)
			@aRenderTokens = []
		ok
		if _i_ = 1  @aRenderTokens = []  ok
		@aRenderTokens + [ StzLower("" + pcId), _n_, _cx_, _cy_ ]
		if _n_ = 0  return  ok
		_r_ = min([ pnW, pnH ]) / 2
		_d_ = max([ 2.5, _r_ * 0.16 ])
		_s_ = _r_ * 0.36
		_aAt_ = []
		if _n_ = 1
			_aAt_ = [ [ 0, 0 ] ]
		but _n_ = 2
			_aAt_ = [ [ 0 - _s_, 0 ], [ _s_, 0 ] ]
		but _n_ = 3
			_aAt_ = [ [ 0, 0 - _s_ ], [ 0 - _s_, _s_ * 0.7 ], [ _s_, _s_ * 0.7 ] ]
		but _n_ = 4
			_aAt_ = [ [ 0 - _s_, 0 - _s_ ], [ _s_, 0 - _s_ ], [ 0 - _s_, _s_ ], [ _s_, _s_ ] ]
		ok
		oC.Flush()
		if len(_aAt_) > 0
			for _k_ = 1 to len(_aAt_)
				oC.FillQ(cStroke).StrokeQ(cStroke, 0).
					AddCircle(_cx_ + _aAt_[_k_][1], _cy_ + _aAt_[_k_][2], _d_)
			next
			return
		ok
		if NOT isObject(oFont)  return  ok
		_cT_ = "" + _n_
		_nW_ = oFont.WidthOf(_cT_, nFsz)
		_nCap_ = oFont.CapHeightOf(nFsz)
		oC.SetFont(oFont, nFsz)
		oC.FillQ(cStroke).AddText(_cT_, _cx_ - _nW_ / 2, _cy_ + _nCap_ / 2)

	#-- helpers -----------------------------------------------------------

	def _PnPlaceIndex(pcId)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aPlaces)
			if StzLower(@aPlaces[_i_][:id]) = _c_  return _i_  ok
		next
		return 0

	def _PnTransIndex(pcId)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aTransitions)
			if StzLower(@aTransitions[_i_][:id]) = _c_  return _i_  ok
		next
		return 0

	def _PnNameOf(pcId)
		_i_ = This._PnPlaceIndex(pcId)
		if _i_ > 0  return @aPlaces[_i_][:name]  ok
		_i_ = This._PnTransIndex(pcId)
		if _i_ > 0  return @aTransitions[_i_][:name]  ok
		return "" + pcId

	def _PnNoNode(pcId)
		if This._PnPlaceIndex(pcId) > 0 or This._PnTransIndex(pcId) > 0
			stzraise("stzPetriNet: '" + pcId + "' is already in this net.")
		ok

class stzPetriRule from stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("petri")

class stzPetriRuleSet from stzGraphRuleSet
	def init()
		super.init("petri-governance")
		This.SetDomainQ("petri")
		_StzAddPetriRules(This)
