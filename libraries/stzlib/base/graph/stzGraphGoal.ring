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

class stzGraphGoal from stzObject

	@cName = ""
	@cType = ""       # every instance of this thing...
	@cRelation = ""   # ...must have an outgoing edge with this label
	@cWhy = ""

	def init(pcName)
		@cName = "" + pcName

	def Name_()
		return @cName

	def Why()
		return @cWhy

	def TypeName()
		return @cType

	def RelationName()
		return @cRelation

	# Direct declarative form.
	def RequireEveryHas(pcType, pcRelation)
		@cType = StzLower("" + pcType)
		@cRelation = StzLower("" + pcRelation)
		return This

	# Parse the Means DSL's core form: "every :Type Has(:relation) ...".
	# Raises when the core form is absent (a goal that cannot be
	# evaluated must not pretend to be one).
	def FromMeans(pcMeans)
		_cM_ = StzLower("" + pcMeans)
		_nEvery_ = StzFindFirst(_cM_, "every :")
		if _nEvery_ = 0
			stzraise("stzGraphGoal.FromMeans: no 'every :Type' clause in '" + pcMeans + "'.")
		ok
		_cRest_ = StzMidToEnd(_cM_, _nEvery_ + 7)
		_nSp_ = StzFindFirst(_cRest_, " ")
		if _nSp_ = 0
			stzraise("stzGraphGoal.FromMeans: nothing follows the type in '" + pcMeans + "'.")
		ok
		@cType = StzLeft(_cRest_, _nSp_ - 1)
		_nHas_ = StzFindFirst(_cRest_, "has(:")
		if _nHas_ = 0
			stzraise("stzGraphGoal.FromMeans: no 'Has(:relation)' clause in '" + pcMeans + "'.")
		ok
		_cRel_ = StzMidToEnd(_cRest_, _nHas_ + 5)
		_nClose_ = StzFindFirst(_cRel_, ")")
		if _nClose_ = 0
			stzraise("stzGraphGoal.FromMeans: unclosed Has(: in '" + pcMeans + "'.")
		ok
		@cRelation = StzLeft(_cRel_, _nClose_ - 1)
		return This

	# The GAP: instances of the type (isa-edges into the type node)
	# lacking any outgoing edge labeled with the relation. Evaluates
	# on the LIVE graph passed in (by-ref param).
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
			_bHas_ = FALSE
			for _j_ = 1 to _nLen_
				if _aEdges_[_j_][:from] = _aInstances_[_i_] and
				   StzLower("" + _aEdges_[_j_][:label]) = @cRelation
					_bHas_ = TRUE
					exit
				ok
			next
			if NOT _bHas_
				_aGap_ + _aInstances_[_i_]
			ok
		next
		return _aGap_

	def SatisfiedOn(poGraph)
		return len(This.GapOn(poGraph)) = 0

	def Narrate()
		return "goal " + @cName + ": every " + @cType + " has(" + @cRelation + ")"
