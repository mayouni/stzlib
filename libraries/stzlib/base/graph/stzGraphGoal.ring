# base/graph/stzGraphGoal.ring
# -----------------------------------------------------------------------------
# stzGraphGoal -- A GOAL IS A WANTED GRAPH STATE (5.10 / R7).
#
# The declarative heart of stzApp's purpose slice: a goal names a
# PATTERN the world's graph must satisfy; the GAP is the set of
# instances that break it. Floor pattern (the Means DSL's core form):
#
#     every :Type Has(:relation) [ ...qualifiers ignored at floor... ]
#
# i.e. every instance node bound to the Type by an "isa" edge must
# carry at least one outgoing edge labeled <relation>. Time qualifiers
# (Since/Within) are deferred work -- parsing them is refused, never
# faked, when they stand ALONE without the core form (LAW 3).
#
# RING-TRUE: the goal object holds only the declarative pattern; it
# never stores a graph (stored objects are dead copies). Evaluation
# takes the LIVE graph as a parameter: GapOn(oGraph) / SatisfiedOn().
# -----------------------------------------------------------------------------

func StzGraphGoalQ(pcName)
	return new stzGraphGoal(pcName)

# Holds a wanted state of a graph, that every instance of a type has an outgoing edge of a given label, and reports who breaks it.
#
# A goal is declarative: RequireEveryHas(type, relation) or FromMeans("every :Type Has(:relation)")
# sets the pattern, and GapOn(graph) returns the instances that do not meet it. An instance is a
# node joined to the type's node by an edge labelled isa. The goal never stores a graph, it judges
# the live one passed in. Time qualifiers such as Within are not evaluated; a sentence without the
# every and Has clauses is refused with an error.
#
#   receiver   o1 = new stzGraphGoal("priced") o1.RequireEveryHas("Dish", "Price") oG = new
#              stzGraph("menu") oG.AddNode("dish") oG.AddNode("tajine") oG.AddNode("couscous")
#              oG.AddNode("price") oG.AddEdgeXT("tajine", "dish", "isa") oG.AddEdgeXT("couscous",
#              "dish", "isa") oG.AddEdgeXT("tajine", "price", "price")
#   example    ? o1.Narrate()
#              #--> goal priced: every dish has(price)
#              ? @@( o1.GapOn(oG) )
#              #--> [ "couscous" ]
#              ? o1.SatisfiedOn(oG)
#              #--> 0
#              oG.AddEdgeXT("couscous", "price", "price")
#              ? o1.SatisfiedOn(oG)
#              #--> 1
#   see        stzGraph, stzApp, stzWorldGraph
class stzGraphGoal from stzObject

	@cName = ""
	@cType = ""       # every instance of this thing...
	@cRelation = ""   # ...must have an outgoing edge with this label
	@cWhy = ""

	# Builds a goal with a name and no pattern yet.
	#
	#   pcName     the name of the goal
	#   returns    nothing; the object is built
	#   note       the goal holds only the declared pattern and never stores a graph; the graph is
	#              passed in when it is judged
	#   see        RequireEveryHas, FromMeans
	def init(pcName)
		@cName = "" + pcName

	# Returns the name the goal was built with.
	#
	#   returns    the name as text
	#   see        Narrate, TypeName
	def Name_()
		return @cName

	# Returns the reason text of the goal.
	#
	#   returns    the reason as text; always an empty text today
	#   note       nothing in the library sets a reason, so it answers an empty text whatever the
	#              goal holds
	#   see        Narrate
	def Why()
		return @cWhy

	# Returns the type every instance must belong to, in lower case.
	#
	#   returns    the type as text; an empty text before a pattern is set
	#   see        RelationName, RequireEveryHas
	def TypeName()
		return @cType

	# Returns the label of the outgoing edge every instance must carry, in lower case.
	#
	#   returns    the label as text; an empty text before a pattern is set
	#   see        TypeName, RequireEveryHas
	def RelationName()
		return @cRelation

	# Sets the pattern directly: every instance of a type must have an outgoing edge with a label.
	#
	#   pcType       the type name, lowercased on the way in
	#   pcRelation   the edge label every instance must carry, lowercased on the way in
	#   returns      the goal itself, so calls chain
	#   note         an instance is a node with an edge labelled isa into the type's node
	#   see          FromMeans, GapOn
	#@ aka  Direct declarative form.
	def RequireEveryHas(pcType, pcRelation)
		@cType = StzLower("" + pcType)
		@cRelation = StzLower("" + pcRelation)
		return This

	# Reads a sentence of the form every :Type Has(:relation) and sets the pattern from it.
	#
	#   pcMeans    the sentence
	#   returns    the goal itself, so calls chain
	#   note       the match is on lower-case text
	#   warning    a sentence with no every :Type clause, no Has(:relation) clause or an unclosed
	#              Has(: raises error stzGraphGoal.FromMeans: ... naming the missing clause; a time
	#              qualifier such as Within(7) is skipped, not checked
	#   see        RequireEveryHas, GapOn
	#@ aka  Parse the Means DSL's core form: "every :Type Has(:relation) ...". Raises when the core form is absent (a goal that cannot be evaluated must not pretend to be one).
	def FromMeans(pcMeans)
		_cM_ = StzLower("" + pcMeans)
		_nEvery_ = StzFindFirst("every :", _cM_)
		if _nEvery_ = 0
			stzraise("stzGraphGoal.FromMeans: no 'every :Type' clause in '" + pcMeans + "'.")
		ok
		_cRest_ = StzMidToEnd(_cM_, _nEvery_ + 7)
		_nSp_ = StzFindFirst(" ", _cRest_)
		if _nSp_ = 0
			stzraise("stzGraphGoal.FromMeans: nothing follows the type in '" + pcMeans + "'.")
		ok
		@cType = StzLeft(_cRest_, _nSp_ - 1)
		_nHas_ = StzFindFirst("has(:", _cRest_)
		if _nHas_ = 0
			stzraise("stzGraphGoal.FromMeans: no 'Has(:relation)' clause in '" + pcMeans + "'.")
		ok
		_cRel_ = StzMidToEnd(_cRest_, _nHas_ + 5)
		_nClose_ = StzFindFirst(")", _cRel_)
		if _nClose_ = 0
			stzraise("stzGraphGoal.FromMeans: unclosed Has(: in '" + pcMeans + "'.")
		ok
		@cRelation = StzLeft(_cRel_, _nClose_ - 1)
		return This

	# Returns the instances that break the goal: those with no outgoing edge carrying the required label.
	#
	#   poGraph    the live stzGraph to judge
	#   returns    a list of node ids; [ ] when every instance has the edge
	#   note       an instance is a node with an edge labelled isa into the type's node; the label
	#              is compared in lower case
	#   warning    a goal with no pattern raises error stzGraphGoal.GapOn: the goal ... has no
	#              pattern
	#   see        SatisfiedOn, RequireEveryHas
	#@ aka  The GAP: instances of the type (isa-edges into the type node) lacking any outgoing edge labeled with the relation. Evaluates on the LIVE graph passed in (by-ref param).
	def GapOn(poGraph)
		if @cType = "" or @cRelation = ""
			stzraise("stzGraphGoal.GapOn: the goal '" + @cName + "' has no pattern (FromMeans/RequireEveryHas first).")
		ok
		_aEdges_ = poGraph.Edges()
		_nLen_ = len(_aEdges_)
		_aInstances_ = []
		for _i_ = 1 to _nLen_
			if StzLower("" + _aEdges_[_i_][:label]) = "isa" and
			   _aEdges_[_i_][:to] = @cType
				_aInstances_ + _aEdges_[_i_][:from]
			ok
		next
		_aGap_ = []
		_nInst_ = len(_aInstances_)
		for _i_ = 1 to _nInst_
			_bHas_ = 0
			for _j_ = 1 to _nLen_
				if _aEdges_[_j_][:from] = _aInstances_[_i_] and
				   StzLower("" + _aEdges_[_j_][:label]) = @cRelation
					_bHas_ = 1
					exit
				ok
			next
			if NOT _bHas_
				_aGap_ + _aInstances_[_i_]
			ok
		next
		return _aGap_

	# TRUE if no instance breaks the goal on a graph.
	#
	#   poGraph    the live stzGraph to judge
	#   returns    TRUE or FALSE, as 1 or 0
	#   warning    a goal with no pattern raises the same error as GapOn
	#   see        GapOn
	def SatisfiedOn(poGraph)
		return len(This.GapOn(poGraph)) = 0

	# Returns the goal as one sentence, with its name, type and relation.
	#
	#   returns    a text such as goal fed: every dish has(price)
	#   note       before a pattern is set the type and the relation read as empty text
	#   see        FromMeans, Name_
	def Narrate()
		return "goal " + @cName + ": every " + @cType + " has(" + @cRelation + ")"
