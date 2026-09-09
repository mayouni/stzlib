#=====================================================================#
#  STZFAULTTREE -- DN17: a fault tree is a picture that computes       #
#=====================================================================#
/*
	THE FIFTH NEW DOMAIN, and the first on the graph plane whose picture
	answers a NUMBER. A fault tree says how an undesired event -- the
	TOP -- comes about: through gates, AND and OR, down to the BASIC
	events whose probabilities are known. Read up, it is a picture of
	causes; computed up, it is the probability of the top event and the
	minimal cut sets -- the smallest sets of basic events that bring the
	top about -- which is what an analyst draws the tree to learn.

	It lives on the GRAPH plane: events and gates are typed nodes, the
	lines between them are edges, and the layout is the tree layout the
	org chart already uses, read top-down. Nothing is directed in the
	drawing -- a fault tree has no arrowheads -- and the edges are held
	in the model from the event down to its gate and from the gate down
	to its inputs, which is the order the layout wants.

	WHAT IT IS HERE:

	    NOTATION   "fault": top and event (boxes), basic (a circle with
	               its probability inside and its name beneath),
	               undeveloped (a diamond -- an event the analyst chose
	               not to develop, and says so), and (the round-topped
	               gate), or (the shield), note. Top-down, no heads.

	    TREE       stzFaultTree from stzDiagram: AddTop, AddEvent,
	               AddBasicXT(id, name, p), AddBasic (no probability yet),
	               AddUndeveloped, AddNote; AddGate(id, :And | :Or),
	               Under(event, gate), Feed(gate, input) -- and
	               Develop(event, kind, [ inputs ]), which is the three in
	               one line. ProbabilityOf(id), TopProbability(),
	               MinimalCutSets().

	    RULES      five, into the one report like the org chart's:

	               one_top_event                 exactly one event stands
	                                             above every other, and it
	                                             is the top
	               gate_has_two_inputs           a gate with one input is a
	                                             wire
	               basic_event_has_probability   a leaf owes its number
	               event_is_developed            an event above the leaves
	                                             has one gate, or says it is
	                                             undeveloped
	               no_event_causes_itself        a cause is not among its
	                                             own effects

	    NUMBERS    an AND gate multiplies its inputs' probabilities, an OR
	               gate takes one minus the product of their complements.
	               Both assume the inputs independent; where a basic event
	               appears under two gates the number is an approximation
	               and the cut sets are the exact answer. The cut sets are
	               found by expansion -- an OR unions, an AND crosses --
	               and minimised.

	WHAT IS SAID PLAINLY: NOT gates, voting gates (k of n), inhibit
	gates, transfer symbols, common-cause groups and importance measures
	are not here. The gates draw for a top-down tree only.
*/

#---------------------------------------------------------------------#
#  THE NOTATION                                                        #
#---------------------------------------------------------------------#

func StzFaultNotation()
	_o_ = StzNotation("fault")
	if _o_.Name_() = "fault"  return _o_  ok
	_o_ = new stzNotation("fault")
	_o_.SetRankDir(:TopDown)
	_o_.SetSplines(:ortho)
	# NO ARROWHEADS: a fault tree is read up and drawn down, and a head
	# would pick one
	_o_.SetEdgesDirected(0)
	_o_.AddKindXT("top", "box", "white")
	_o_.AddKindXT("event", "box", "white")
	_o_.AddKindXTT("basic", "circle", "white", 0.72)
	_o_.AddKindXTT("undeveloped", "diamond", "white", 0.80)
	_o_.AddKindXTT("and", "andgate", "white", 0.52)
	_o_.AddKindXTT("or", "orgate", "white", 0.52)
	_o_.AddKindXT("note", "note", "white")
	# a basic event's inside is its probability; a gate is its shape
	_o_.SetNameOutside("basic")
	_o_.SetNameOutside("undeveloped")
	# a gate's inputs are peers: none of them continues the gate, so it
	# stands at their middle however deep each one goes
	_o_.SetPeerChildren()
	StzRegisterNotation(_o_)
	return _o_

func StzFaultGateKinds()
	return [ "and", "or" ]

#---------------------------------------------------------------------#
#  THE RULES                                                           #
#---------------------------------------------------------------------#

func StzFaultRuleSetQ()
	return new stzFaultRuleSet()

func _FtKindOf(oGraph, pcId)
	return StzLower("" + oGraph.NodeProperty(pcId, "kind"))

func _FtIsEvent(oGraph, pcId)
	_k_ = _FtKindOf(oGraph, pcId)
	return _k_ = "top" or _k_ = "event" or _k_ = "basic" or _k_ = "undeveloped"

func _FtIsGate(oGraph, pcId)
	_k_ = _FtKindOf(oGraph, pcId)
	return _k_ = "and" or _k_ = "or"

func _FtParents(oGraph, pcId)
	_r_ = []
	_a_ = oGraph.Edges()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][:to]) = StzLower("" + pcId)  _r_ + ("" + _a_[_i_][:from])  ok
	next
	return _r_

func _FtChildren(oGraph, pcId)
	_r_ = []
	_a_ = oGraph.Edges()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][:from]) = StzLower("" + pcId)  _r_ + ("" + _a_[_i_][:to])  ok
	next
	return _r_

func _FtNodesWhere(oGraph, pacKinds, pcPrefixMode)
	# pcPrefixMode "kind" prefixes each id with its own kind
	_r_ = []
	_a_ = oGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		_k_ = _FtKindOf(oGraph, _a_[_i_])
		_bIn_ = FALSE
		for _j_ = 1 to len(pacKinds)
			if pacKinds[_j_] = _k_  _bIn_ = TRUE  ok
		next
		if _bIn_  _r_ + (_k_ + ":" + StzLower("" + _a_[_i_]))  ok
	next
	return _r_

func _FtNodesNotWhere(oGraph, pacKinds)
	_r_ = []
	_a_ = oGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		_k_ = _FtKindOf(oGraph, _a_[_i_])
		_bIn_ = FALSE
		for _j_ = 1 to len(pacKinds)
			if pacKinds[_j_] = _k_  _bIn_ = TRUE  ok
		next
		if NOT _bIn_  _r_ + (_k_ + ":" + StzLower("" + _a_[_i_]))  ok
	next
	return _r_

# is pcId reachable from itself, walking the edges downward?
func _FtOnACycle(oGraph, pcId)
	_acSeen_ = []
	_acStack_ = _FtChildren(oGraph, pcId)
	_cMe_ = StzLower("" + pcId)
	while len(_acStack_) > 0
		_c_ = StzLower("" + _acStack_[len(_acStack_)])
		del(_acStack_, len(_acStack_))
		if _c_ = _cMe_  return TRUE  ok
		_bSeen_ = FALSE
		for _i_ = 1 to len(_acSeen_)
			if _acSeen_[_i_] = _c_  _bSeen_ = TRUE  ok
		next
		if _bSeen_  loop  ok
		_acSeen_ + _c_
		_aK_ = _FtChildren(oGraph, _c_)
		for _i_ = 1 to len(_aK_)  _acStack_ + _aK_[_i_]  next
	end
	return FALSE

func _StzAddFaultRules(poSet)

	# ONE TOP. The event nobody develops from above is the top, and there
	# is one of it: a second root is a second tree drawn in the same
	# frame, and a root that is not declared the top is a tree with no
	# name for what it is about.
	_o1_ = new stzFaultRule("one_top_event")
	_o1_.SetSeverityQ("error")
	_o1_.SetMessageQ("exactly one event stands above every other, and it is the top")
	_o1_.SetOrderQ(10)
	_o1_.SetReadsQ([ "edge", "node.kind" ])
	_o1_.GovernsQ(func oGraph { return _FtNodesWhere(oGraph, [ "top", "event", "basic", "undeveloped" ], "kind") })
	_o1_.ExcludesQ(func oGraph { return _FtNodesNotWhere(oGraph, [ "top", "event", "basic", "undeveloped" ]) })
	_o1_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		_nTop_ = 0
		for _i_ = 1 to len(_a_)
			if NOT _FtIsEvent(oGraph, _a_[_i_])  loop  ok
			_k_ = _FtKindOf(oGraph, _a_[_i_])
			_bRoot_ = len(_FtParents(oGraph, _a_[_i_])) = 0
			if _k_ = "top"
				_nTop_++
				if NOT _bRoot_
					_aOut_ + [ :where = _a_[_i_], :message = "the top event '" +
						oGraph.NodeProperty(_a_[_i_], "name") + "' is developed under a gate -- a top has nothing above it" ]
				ok
			but _bRoot_
				_aOut_ + [ :where = _a_[_i_], :message = "'" + oGraph.NodeProperty(_a_[_i_], "name") +
					"' stands under no gate and is not the top event" ]
			ok
		next
		if _nTop_ = 0
			_aOut_ + [ :where = "tree", :message = "the tree declares no top event" ]
		but _nTop_ > 1
			_aOut_ + [ :where = "tree", :message = "the tree declares " + _nTop_ + " top events -- one tree, one top" ]
		ok
		return _aOut_
	})
	poSet.AddRule(_o1_)

	# A GATE HAS TWO INPUTS. One input is a wire: AND of one thing is
	# that thing, OR of one thing is that thing.
	_o2_ = new stzFaultRule("gate_has_two_inputs")
	_o2_.SetSeverityQ("warning")
	_o2_.SetMessageQ("every gate has at least two inputs")
	_o2_.SetOrderQ(20)
	_o2_.SetReadsQ([ "edge", "node.kind" ])
	_o2_.GovernsQ(func oGraph { return _FtNodesWhere(oGraph, [ "and", "or" ], "kind") })
	_o2_.ExcludesQ(func oGraph { return _FtNodesNotWhere(oGraph, [ "and", "or" ]) })
	_o2_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _FtIsGate(oGraph, _a_[_i_])  loop  ok
			_n_ = len(_FtChildren(oGraph, _a_[_i_]))
			if _n_ < 2
				_cUp_ = ""
				_aP_ = _FtParents(oGraph, _a_[_i_])
				if len(_aP_) > 0  _cUp_ = " under '" + oGraph.NodeProperty(_aP_[1], "name") + "'"  ok
				_aOut_ + [ :where = _a_[_i_], :message = "the " + StzUpper(_FtKindOf(oGraph, _a_[_i_])) +
					" gate" + _cUp_ + " has " + _n_ + " input(s) -- a gate with one input is a wire" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o2_)

	# A BASIC EVENT HAS A PROBABILITY. The leaves are where the numbers
	# come from; a leaf without one makes every gate above it silent.
	_o3_ = new stzFaultRule("basic_event_has_probability")
	_o3_.SetSeverityQ("error")
	_o3_.SetMessageQ("every basic event declares its probability")
	_o3_.SetOrderQ(30)
	_o3_.SetReadsQ([ "node.kind", "node.p" ])
	_o3_.GovernsQ(func oGraph { return _FtNodesWhere(oGraph, [ "basic" ], "kind") })
	# an undeveloped event owes no number: it is the analyst saying so
	_o3_.ExcludesQ(func oGraph { return _FtNodesNotWhere(oGraph, [ "basic" ]) })
	_o3_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _FtKindOf(oGraph, _a_[_i_]) != "basic"  loop  ok
			_p_ = oGraph.NodeProperty(_a_[_i_], "p")
			if NOT isNumber(_p_) or _p_ < 0
				_aOut_ + [ :where = _a_[_i_], :message = "basic event '" +
					oGraph.NodeProperty(_a_[_i_], "name") + "' has no probability" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o3_)

	# AN EVENT IS DEVELOPED, OR SAYS IT IS NOT. A top or intermediate
	# event has exactly one gate beneath it; with none it is undeveloped
	# without saying so, with two it is two claims about one cause.
	_o4_ = new stzFaultRule("event_is_developed")
	_o4_.SetSeverityQ("warning")
	_o4_.SetMessageQ("every top or intermediate event has one gate beneath it")
	_o4_.SetOrderQ(40)
	_o4_.SetReadsQ([ "edge", "node.kind" ])
	_o4_.GovernsQ(func oGraph { return _FtNodesWhere(oGraph, [ "top", "event" ], "kind") })
	# a basic event is a leaf and an undeveloped one declares itself so
	_o4_.ExcludesQ(func oGraph { return _FtNodesNotWhere(oGraph, [ "top", "event" ]) })
	_o4_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			_k_ = _FtKindOf(oGraph, _a_[_i_])
			if _k_ != "top" and _k_ != "event"  loop  ok
			_n_ = len(_FtChildren(oGraph, _a_[_i_]))
			if _n_ = 0
				_aOut_ + [ :where = _a_[_i_], :message = "'" + oGraph.NodeProperty(_a_[_i_], "name") +
					"' has no gate beneath it -- develop it, or declare it undeveloped" ]
			but _n_ > 1
				_aOut_ + [ :where = _a_[_i_], :message = "'" + oGraph.NodeProperty(_a_[_i_], "name") +
					"' has " + _n_ + " gates beneath it -- one event, one gate" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o4_)

	# NO EVENT CAUSES ITSELF.
	_o5_ = new stzFaultRule("no_event_causes_itself")
	_o5_.SetSeverityQ("error")
	_o5_.SetMessageQ("no event is among its own causes")
	_o5_.SetOrderQ(50)
	_o5_.SetReadsQ([ "edge", "node.kind" ])
	_o5_.GovernsQ(func oGraph { return _FtNodesWhere(oGraph, [ "top", "event", "basic", "undeveloped" ], "kind") })
	_o5_.ExcludesQ(func oGraph { return _FtNodesNotWhere(oGraph, [ "top", "event", "basic", "undeveloped" ]) })
	_o5_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _FtIsEvent(oGraph, _a_[_i_])  loop  ok
			if _FtOnACycle(oGraph, _a_[_i_])
				_aOut_ + [ :where = _a_[_i_], :message = "'" + oGraph.NodeProperty(_a_[_i_], "name") +
					"' is among its own causes" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o5_)

# a probability written the way an analyst reads it: two decimals, or
# four when two would show nothing
func _FtFormat(pnP)
	if pnP >= 0.01 or pnP = 0
		decimals(2)
		_c_ = "" + pnP
	else
		decimals(4)
		_c_ = "" + pnP
	ok
	decimals(2)
	return _c_

# CLASSES LAST, FUNCTIONS FIRST: everything after the first `class` in a
# Ring file belongs to a class.

#---------------------------------------------------------------------#
#  THE TREE                                                            #
#---------------------------------------------------------------------#

class stzFaultTree from stzDiagram

	# [ [ :id, :name, :kind, :p ] ] -- kind top | event | basic | undeveloped;
	# p is -1 until declared
	@aEvents = []
	# [ [ :id, :kind, :event ] ] -- the gate and the event it develops
	@aGates = []
	# [ [ :gate, :input ] ]
	@aInputs = []
	@aNotes = []
	# what was written inside the basic events: [ id, p, x, y ]
	@aRenderProbs = []

	def init(pcTitle)
		super.init(pcTitle)
		This.SetNotation(StzFaultNotation())

	#-- the events ---------------------------------------------------------

	def AddTop(pcId, pcName)
		This._FtAddEvent(pcId, pcName, "top", -1)
		return This

	def AddEvent(pcId, pcName)
		This._FtAddEvent(pcId, pcName, "event", -1)
		return This

	# a basic event whose probability is not yet known -- the third rule
	# will say so
	def AddBasic(pcId, pcName)
		This._FtAddEvent(pcId, pcName, "basic", -1)
		return This

	def AddBasicXT(pcId, pcName, pnP)
		if NOT isNumber(pnP) or pnP < 0 or pnP > 1
			stzraise("stzFaultTree: a probability is a number between 0 and 1, not '" + pnP + "'.")
		ok
		This._FtAddEvent(pcId, pcName, "basic", pnP)
		return This

	def AddUndeveloped(pcId, pcName)
		This._FtAddEvent(pcId, pcName, "undeveloped", -1)
		return This

	def AddNote(pcId, pcText)
		@aNotes + ("" + pcId)
		This.AddNodeXTT(pcId, pcText, [ :type = "note" ])
		return This

	def _FtAddEvent(pcId, pcName, pcKind, pnP)
		This._FtNoNode(pcId)
		@aEvents + [ :id = "" + pcId, :name = "" + pcName, :kind = pcKind, :p = pnP ]
		This.AddNodeXTT(pcId, pcName, [ :type = pcKind ])

	#-- the gates ----------------------------------------------------------

	def AddGate(pcId, pcKind)
		This._FtNoNode(pcId)
		_k_ = StzLower(ring_trim("" + pcKind))
		_acK_ = StzFaultGateKinds()
		_bK_ = FALSE
		for _i_ = 1 to len(_acK_)
			if _acK_[_i_] = _k_  _bK_ = TRUE  ok
		next
		if NOT _bK_
			stzraise("stzFaultTree: '" + pcKind + "' is not a gate -- And or Or.")
		ok
		@aGates + [ :id = "" + pcId, :kind = _k_, :event = "" ]
		This.AddNodeXTT(pcId, "", [ :type = _k_ ])
		return This

	# Under(event, gate): the gate develops the event
	def Under(pcEvent, pcGate)
		if This._FtEventIndex(pcEvent) = 0
			stzraise("stzFaultTree: '" + pcEvent + "' is not an event of this tree.")
		ok
		_g_ = This._FtGateIndex(pcGate)
		if _g_ = 0
			stzraise("stzFaultTree: '" + pcGate + "' is not a gate of this tree.")
		ok
		@aGates[_g_][:event] = "" + pcEvent
		This.AddEdgeXTT(pcEvent, pcGate, "", [ :type = "develops" ])
		return This

	# Feed(gate, input): an event is an input of the gate. An event may
	# feed several gates -- a repeated event -- which is why the cut sets
	# are computed rather than read.
	def Feed(pcGate, pcInput)
		if This._FtGateIndex(pcGate) = 0
			stzraise("stzFaultTree: '" + pcGate + "' is not a gate of this tree.")
		ok
		if This._FtEventIndex(pcInput) = 0
			if This._FtGateIndex(pcInput) > 0
				stzraise("stzFaultTree: a gate's input is an event -- '" + pcInput +
					"' is a gate; give it an event of its own.")
			ok
			stzraise("stzFaultTree: '" + pcInput + "' is not an event of this tree.")
		ok
		@aInputs + [ :gate = "" + pcGate, :input = "" + pcInput ]
		This.AddEdgeXTT(pcGate, pcInput, "", [ :type = "feeds" ])
		return This

	# Develop(event, kind, [ inputs ]): the gate is named after the event
	def Develop(pcEvent, pcKind, pacInputs)
		_cG_ = "" + pcEvent + ".gate"
		This.AddGate(_cG_, pcKind)
		This.Under(pcEvent, _cG_)
		for _i_ = 1 to len(pacInputs)
			This.Feed(_cG_, pacInputs[_i_])
		next
		return This

		def DevelopQ(pcEvent, pcKind, pacInputs)
			return This.Develop(pcEvent, pcKind, pacInputs)

	def Events()
		return @aEvents

	def Gates()
		return @aGates

	def Inputs()
		return @aInputs

	def GateOf(pcEvent)
		_c_ = StzLower("" + pcEvent)
		for _i_ = 1 to len(@aGates)
			if StzLower(@aGates[_i_][:event]) = _c_  return @aGates[_i_][:id]  ok
		next
		return ""

	def InputsOf(pcGate)
		_r_ = []
		_c_ = StzLower("" + pcGate)
		for _i_ = 1 to len(@aInputs)
			if StzLower(@aInputs[_i_][:gate]) = _c_  _r_ + @aInputs[_i_][:input]  ok
		next
		return _r_

	def TopEvent()
		for _i_ = 1 to len(@aEvents)
			if @aEvents[_i_][:kind] = "top"  return @aEvents[_i_][:id]  ok
		next
		return ""

	#-- the numbers --------------------------------------------------------

	# THE PROBABILITY OF AN EVENT OR A GATE, computed up from the leaves.
	# AND multiplies, OR takes one minus the product of the complements;
	# both assume independent inputs. Refused by name where a leaf has no
	# number, where an event is undeveloped, or where a cause is among
	# its own effects.
	def ProbabilityOf(pcId)
		return This._FtProb(pcId, [])

	def _FtProb(pcId, pacPath)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(pacPath)
			if pacPath[_i_] = _c_
				stzraise("stzFaultTree: '" + This._FtNameOf(pcId) + "' is among its own causes -- no probability.")
			ok
		next
		_aPath_ = []
		for _i_ = 1 to len(pacPath)  _aPath_ + pacPath[_i_]  next
		_aPath_ + _c_
		_e_ = This._FtEventIndex(pcId)
		if _e_ > 0
			_k_ = @aEvents[_e_][:kind]
			if _k_ = "basic"
				if @aEvents[_e_][:p] < 0
					stzraise("stzFaultTree: basic event '" + @aEvents[_e_][:name] + "' has no probability.")
				ok
				return @aEvents[_e_][:p]
			ok
			if _k_ = "undeveloped"
				stzraise("stzFaultTree: '" + @aEvents[_e_][:name] + "' is undeveloped -- it has no probability.")
			ok
			_cG_ = This.GateOf(pcId)
			if _cG_ = ""
				stzraise("stzFaultTree: '" + @aEvents[_e_][:name] + "' has no gate beneath it -- no probability.")
			ok
			return This._FtProb(_cG_, _aPath_)
		ok
		_g_ = This._FtGateIndex(pcId)
		if _g_ = 0
			stzraise("stzFaultTree: '" + pcId + "' is not an event or a gate of this tree.")
		ok
		_aIn_ = This.InputsOf(pcId)
		if len(_aIn_) = 0
			stzraise("stzFaultTree: the gate '" + pcId + "' has no input -- no probability.")
		ok
		if @aGates[_g_][:kind] = "and"
			_p_ = 1
			for _i_ = 1 to len(_aIn_)
				_p_ = _p_ * This._FtProb(_aIn_[_i_], _aPath_)
			next
			return _p_
		ok
		_q_ = 1
		for _i_ = 1 to len(_aIn_)
			_q_ = _q_ * (1 - This._FtProb(_aIn_[_i_], _aPath_))
		next
		return 1 - _q_

	def TopProbability()
		_cT_ = This.TopEvent()
		if _cT_ = ""
			stzraise("stzFaultTree: the tree declares no top event.")
		ok
		return This.ProbabilityOf(_cT_)

	# THE MINIMAL CUT SETS of the top: the smallest sets of basic events
	# that bring it about. Expanded down the tree -- an OR unions its
	# inputs' sets, an AND crosses them -- then minimised: a set holding
	# another is dropped, and duplicates fold. Each set is a list of basic
	# ids in the order added; the sets come smallest first.
	def MinimalCutSets()
		_cT_ = This.TopEvent()
		if _cT_ = ""
			stzraise("stzFaultTree: the tree declares no top event.")
		ok
		_aS_ = This._FtCuts(_cT_, [])
		return This._FtMinimise(_aS_)

	# THE EXACT PROBABILITY OF THE TOP, from the minimal cut sets by
	# inclusion and exclusion over their unions -- the one number the
	# gate arithmetic cannot give when a basic event is repeated. Every
	# basic is still taken independent of every other. Refused above
	# twelve cut sets, where the subsets outrun what a picture can mean.
	def CutSetProbability()
		_aS_ = This.MinimalCutSets()
		_n_ = len(_aS_)
		if _n_ = 0  return 0  ok
		if _n_ > 12
			stzraise("stzFaultTree: " + _n_ + " minimal cut sets -- the exact sum is refused above twelve.")
		ok
		_nTot_ = 0
		_nMax_ = 1
		for _i_ = 1 to _n_  _nMax_ = _nMax_ * 2  next
		for _m_ = 1 to _nMax_ - 1
			_aU_ = []
			_k_ = 0
			_b_ = _m_
			for _i_ = 1 to _n_
				if _b_ % 2 = 1
					_aU_ = This._FtUnion(_aU_, _aS_[_i_])
					_k_++
				ok
				_b_ = floor(_b_ / 2)
			next
			_p_ = 1
			for _i_ = 1 to len(_aU_)
				_p_ = _p_ * This.ProbabilityOf(_aU_[_i_])
			next
			if _k_ % 2 = 1  _nTot_ += _p_  else  _nTot_ -= _p_  ok
		next
		return _nTot_

	def _FtCuts(pcId, pacPath)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(pacPath)
			if pacPath[_i_] = _c_
				stzraise("stzFaultTree: '" + This._FtNameOf(pcId) + "' is among its own causes -- no cut sets.")
			ok
		next
		_aPath_ = []
		for _i_ = 1 to len(pacPath)  _aPath_ + pacPath[_i_]  next
		_aPath_ + _c_
		_e_ = This._FtEventIndex(pcId)
		if _e_ > 0
			_k_ = @aEvents[_e_][:kind]
			if _k_ = "basic" or _k_ = "undeveloped"  return [ [ @aEvents[_e_][:id] ] ]  ok
			_cG_ = This.GateOf(pcId)
			if _cG_ = ""  return [ [ @aEvents[_e_][:id] ] ]  ok
			return This._FtCuts(_cG_, _aPath_)
		ok
		_g_ = This._FtGateIndex(pcId)
		if _g_ = 0  return []  ok
		_aIn_ = This.InputsOf(pcId)
		if @aGates[_g_][:kind] = "or"
			_r_ = []
			for _i_ = 1 to len(_aIn_)
				_aK_ = This._FtCuts(_aIn_[_i_], _aPath_)
				for _j_ = 1 to len(_aK_)  _r_ + _aK_[_j_]  next
			next
			return _r_
		ok
		# AND: the cross product of the inputs' sets
		_r_ = [ [] ]
		for _i_ = 1 to len(_aIn_)
			_aK_ = This._FtCuts(_aIn_[_i_], _aPath_)
			_aNew_ = []
			for _a_ = 1 to len(_r_)
				for _b_ = 1 to len(_aK_)
					_aNew_ + This._FtUnion(_r_[_a_], _aK_[_b_])
				next
			next
			_r_ = _aNew_
		next
		return _r_

	def _FtUnion(paA, paB)
		_r_ = []
		for _i_ = 1 to len(paA)  _r_ + paA[_i_]  next
		for _i_ = 1 to len(paB)
			_bIn_ = FALSE
			for _j_ = 1 to len(_r_)
				if StzLower("" + _r_[_j_]) = StzLower("" + paB[_i_])  _bIn_ = TRUE  ok
			next
			if NOT _bIn_  _r_ + paB[_i_]  ok
		next
		return _r_

	def _FtContains(paBig, paSmall)
		for _i_ = 1 to len(paSmall)
			_bIn_ = FALSE
			for _j_ = 1 to len(paBig)
				if StzLower("" + paBig[_j_]) = StzLower("" + paSmall[_i_])  _bIn_ = TRUE  ok
			next
			if NOT _bIn_  return FALSE  ok
		next
		return TRUE

	def _FtMinimise(paSets)
		# smallest first, so a superset always meets its subset before it
		# is kept
		_aS_ = []
		for _i_ = 1 to len(paSets)  _aS_ + paSets[_i_]  next
		for _i_ = 1 to len(_aS_) - 1
			for _j_ = 1 to len(_aS_) - _i_
				if len(_aS_[_j_]) > len(_aS_[_j_ + 1])
					_t_ = _aS_[_j_]  _aS_[_j_] = _aS_[_j_ + 1]  _aS_[_j_ + 1] = _t_
				ok
			next
		next
		_r_ = []
		for _i_ = 1 to len(_aS_)
			_bDrop_ = FALSE
			for _j_ = 1 to len(_r_)
				if This._FtContains(_aS_[_i_], _r_[_j_])  _bDrop_ = TRUE  exit  ok
			next
			if NOT _bDrop_  _r_ + _aS_[_i_]  ok
		next
		return _r_

	#-- the projection the rules read --------------------------------------

	def AsRuleGraph()
		_oG_ = new stzGraph("fault-rules")
		for _i_ = 1 to len(@aEvents)
			_e_ = @aEvents[_i_]
			_oG_.AddNode(_e_[:id])
			_oG_.SetNodeProperty(_e_[:id], "kind", _e_[:kind])
			_oG_.SetNodeProperty(_e_[:id], "name", _e_[:name])
			_oG_.SetNodeProperty(_e_[:id], "p", _e_[:p])
		next
		for _i_ = 1 to len(@aGates)
			_oG_.AddNode(@aGates[_i_][:id])
			_oG_.SetNodeProperty(@aGates[_i_][:id], "kind", @aGates[_i_][:kind])
			_oG_.SetNodeProperty(@aGates[_i_][:id], "name", @aGates[_i_][:id])
		next
		for _i_ = 1 to len(@aNotes)
			_oG_.AddNode(@aNotes[_i_])
			_oG_.SetNodeProperty(@aNotes[_i_], "kind", "note")
			_oG_.SetNodeProperty(@aNotes[_i_], "name", @aNotes[_i_])
		next
		for _i_ = 1 to len(@aGates)
			if @aGates[_i_][:event] != "" and NOT _oG_.EdgeExists(@aGates[_i_][:event], @aGates[_i_][:id])
				_oG_.AddEdgeXTT(@aGates[_i_][:event], @aGates[_i_][:id], "", [ :type = "develops" ])
			ok
		next
		for _i_ = 1 to len(@aInputs)
			if NOT _oG_.EdgeExists(@aInputs[_i_][:gate], @aInputs[_i_][:input])
				_oG_.AddEdgeXTT(@aInputs[_i_][:gate], @aInputs[_i_][:input], "", [ :type = "feeds" ])
			ok
		next
		return _oG_

	def GovernanceFindings()
		return StzFaultRuleSetQ().Check(This.AsRuleGraph())

	def GovernanceIsSound()
		return len(This.GovernanceFindings()) = 0

	def CheckRules()
		return This.GovernanceFindings()

	def RulesAreSound()
		return This.GovernanceIsSound()

	#-- the drawing ----------------------------------------------------------

	# what was written inside the basic events on the last render:
	# [ id, p, x, y ], p = -1 where none was declared
	def RenderProbabilities()
		return @aRenderProbs

	# THE PROBABILITY, INSIDE THE BASIC EVENT. A leaf is read by its
	# number; the name goes beneath. A leaf with no number shows a
	# question mark, which is the rule's finding made visible.
	def _DrawNodeMark(oC, pcId, pnX, pnY, pnW, pnH, cStroke, nStkW, oFont, nFsz)
		_e_ = This._FtEventIndex(pcId)
		if _e_ = 0  return  ok
		if @aEvents[_e_][:kind] != "basic"  return  ok
		_cx_ = pnX + pnW / 2
		_cy_ = pnY + pnH / 2
		if len(@aRenderProbs) > 0 and @aRenderProbs[1][1] = StzLower("" + pcId)
			@aRenderProbs = []
		ok
		_p_ = @aEvents[_e_][:p]
		@aRenderProbs + [ StzLower("" + pcId), _p_, _cx_, _cy_ ]
		if NOT isObject(oFont)  return  ok
		_cT_ = "?"
		if _p_ >= 0  _cT_ = _FtFormat(_p_)  ok
		_nSz_ = nFsz * 0.85
		_nW_ = oFont.WidthOf(_cT_, _nSz_)
		_nCap_ = oFont.CapHeightOf(_nSz_)
		oC.Flush()
		oC.SetFont(oFont, _nSz_)
		oC.FillQ(cStroke).AddText(_cT_, _cx_ - _nW_ / 2, _cy_ + _nCap_ / 2)

	#-- helpers ----------------------------------------------------------------

	def _FtEventIndex(pcId)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aEvents)
			if StzLower(@aEvents[_i_][:id]) = _c_  return _i_  ok
		next
		return 0

	def _FtGateIndex(pcId)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aGates)
			if StzLower(@aGates[_i_][:id]) = _c_  return _i_  ok
		next
		return 0

	def _FtNameOf(pcId)
		_i_ = This._FtEventIndex(pcId)
		if _i_ > 0  return @aEvents[_i_][:name]  ok
		return "" + pcId

	def _FtNoNode(pcId)
		if This._FtEventIndex(pcId) > 0 or This._FtGateIndex(pcId) > 0
			stzraise("stzFaultTree: '" + pcId + "' is already in this tree.")
		ok

class stzFaultRule from stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("fault")

class stzFaultRuleSet from stzGraphRuleSet
	def init()
		super.init("fault-governance")
		This.SetDomainQ("fault")
		_StzAddFaultRules(This)
