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
		return 1
	ok
	return 0

	func IsAStzGoal(pObj)
		return IsStzGoal(pObj)


# Holds the target shape of a domain model, so the gap between it and a knowledgebase says which question to ask next.
#
# A goal is a pure specification and reads no global world: Gaps(oKB) is given the knowledgebase and
# answers what is missing in that one graph. RequireEach demands a relation of every entity of a
# type, RequireOne of one named subject. The graph is deliberately not stored, because a stored
# object is copied and would go stale. Build it with new stzGoal() or StzGoalQ().
#
#   receiver   o1 = new stzGoal()
#   example    oKB = new stzKnowledgeGraph("menu")
#              oKB.Know("margherita", "dish")
#              o1.RequireEach("dish", "contains")
#              ? o1.Gaps(oKB)[1][3]
#              #--> every dish needs 'contains'
#              oKB.KnowRelation("margherita", "contains", "tomato-sauce")
#              ? o1.IsSatisfied(oKB)
#              #--> 1
#   see        stzKnowledgeGraph, stzConversation, stzTranscript
class stzGoal from stzObject

	@aEach = []     # [ [ type, relation ] ... ]
	@aOne = []      # [ [ subject, relation ] ... ]

	# Builds a goal with no requirement yet, which any knowledgebase satisfies.
	#
	#   returns    nothing; the object is built
	#   see        RequireEach, RequireOne
	def init()

	# Adds the schema requirement that every entity of a type bears a relation; both names are trimmed and lowercased.
	#
	#   pcType     the entity type, such as dish
	#   pcRel      the relation every entity of that type must bear, such as contains
	#   returns    the goal itself, so calls chain
	#   see        RequireOne, Gaps
	def RequireEach(pcType, pcRel)
		@aEach + [ StzLower(ring_trim("" + pcType)), StzLower(ring_trim("" + pcRel)) ]
		return This

	# Adds the requirement that one named subject bears a relation; both names are trimmed and lowercased.
	#
	#   pcSubject   the entity that must bear the relation
	#   pcRel       the relation, such as run-by
	#   returns     the goal itself, so calls chain
	#   see         RequireEach, Gaps
	def RequireOne(pcSubject, pcRel)
		@aOne + [ StzLower(ring_trim("" + pcSubject)), StzLower(ring_trim("" + pcRel)) ]
		return This

	# Returns the requirements added so far, the each pairs and the one pairs.
	#
	#   returns    a list [ [ each, pairs ], [ one, pairs ] ], every pair being [ name, relation ]
	#   see        RequireEach, RequireOne
	def Requirements()
		return [ :each = @aEach, :one = @aOne ]

	# Returns the slots of the goal that a knowledgebase does not fill yet, each with the reason, so the next question can be asked.
	#
	#   poKB       the stzKnowledgeGraph to read, passed in and never stored
	#   returns    a list of [ subject, relation, why ] rows; empty when nothing is missing
	#   note       the order is the schema rows first, then the one-subject rows
	#   warning    raises an error when the argument is not a stzKnowledgeGraph; a subject missing
	#              under both RequireEach and RequireOne is listed twice, once with each reason
	#   see        IsSatisfied, RequireEach
	#@ aka  the missing slots of THIS goal against poKB: [ [ subject, relation, why ] ]
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

	# TRUE if the knowledgebase leaves no gap, which an empty goal always does.
	#
	#   poKB       the stzKnowledgeGraph to read
	#   returns    1 or 0, numbers
	#   see        Gaps
	def IsSatisfied(poKB)
		return len(This.Gaps(poKB)) = 0

	# does the SCOPED graph already record (subject, relation, *) ?
	def _Bears(poKB, pcSubject, pcRel)
		return len(poKB.Query([ "" + pcSubject, "" + pcRel, "?o" ])) > 0
