# R3b -- stzGoal: WHAT THE CONVERSATION IS FOR
# A goal declares the TARGET SHAPE of a complete domain model; the GAP
# between that shape and the current knowledgebase GENERATES the next
# questions (wise coding, 0.3: goal-driven slot filling over the graph).
#
# Two forms cover the elicitation floor:
#   RequireEach("dish", "contains")   every entity of a type bears a
#                                     relation (the schema form)
#   RequireOne("kitchen", "run-by")   one specific subject bears it
#
# A goal is a pure SPEC -- the target shape. It is APPLIED TO a scoped
# knowledgebase: Gaps(oKB) answers "what is missing in THIS graph", never
# reading a global world. The graph arrives as a PARAMETER (by reference in
# Ring) and is deliberately NOT stored: an object kept in an attribute is
# COPIED, so a stored graph would silently go stale the moment its owner
# wrote to it (see [[feedback-ring-vm-traps]]).
#
#   oKB = new stzKnowledgeGraph("menu")
#   oKB.Know("margherita", "dish")
#   oGoal = new stzGoal().RequireEach("dish", "contains")
#   ? oGoal.Gaps(oKB)   #--> [ [ "margherita", "contains", "every dish..." ] ]

func StzGoalQ()
	return new stzGoal()

func IsStzGoal(pObj)
	if isObject(pObj) and classname(pObj) = "stzgoal"
		return TRUE
	ok
	return FALSE

	func IsAStzGoal(pObj)
		return IsStzGoal(pObj)


class stzGoal from stzObject

	@aEach = []     # [ [ type, relation ] ... ]
	@aOne = []      # [ [ subject, relation ] ... ]

	def init()

	def RequireEach(pcType, pcRel)
		@aEach + [ StzLower(ring_trim("" + pcType)), StzLower(ring_trim("" + pcRel)) ]
		return This

	def RequireOne(pcSubject, pcRel)
		@aOne + [ StzLower(ring_trim("" + pcSubject)), StzLower(ring_trim("" + pcRel)) ]
		return This

	def Requirements()
		return [ :each = @aEach, :one = @aOne ]

	# the missing slots of THIS goal against poKB: [ [ subject, relation, why ] ]
	def Gaps(poKB)
		if NOT IsStzKnowledgeGraph(poKB)
			stzraise("Gaps() needs the SCOPED knowledgebase to read -- Gaps(oKB) with a stzKnowledgeGraph (a goal never reads a global world).")
		ok
		_aGaps_ = []

		# schema form: every entity of the type must bear the relation
		_n_ = len(@aEach)
		for _i_ = 1 to _n_
			_cType_ = @aEach[_i_][1]
			_cRel_ = @aEach[_i_][2]
			_acEnts_ = poKB.Query([ "?x", "is-a", _cType_ ])
			_nAll_ = len(_acEnts_)
			for _e_ = 1 to _nAll_
				if NOT This._Bears(poKB, _acEnts_[_e_], _cRel_)
					_aGaps_ + [ _acEnts_[_e_], _cRel_,
						"every " + _cType_ + " needs '" + _cRel_ + "'" ]
				ok
			next
		next

		# subject form
		_n_ = len(@aOne)
		for _i_ = 1 to _n_
			if NOT This._Bears(poKB, @aOne[_i_][1], @aOne[_i_][2])
				_aGaps_ + [ @aOne[_i_][1], @aOne[_i_][2],
					"'" + @aOne[_i_][1] + "' needs '" + @aOne[_i_][2] + "'" ]
			ok
		next

		return _aGaps_

	def IsSatisfied(poKB)
		return len(This.Gaps(poKB)) = 0

	# does the SCOPED graph already record (subject, relation, *) ?
	def _Bears(poKB, pcSubject, pcRel)
		return len(poKB.Query([ "" + pcSubject, "" + pcRel, "?o" ])) > 0
