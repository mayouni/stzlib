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
# Gaps() reads the DEFAULT knowledge graph's world (R1) and answers
# with the missing [ subject, relation ] slots -- deterministic, so
# the elicitation is accountable: every question can say WHY it asks.

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

	# the missing slots: [ [ subject, relation, why ] ... ]
	def Gaps()
		_aGaps_ = []

		# schema form: every entity of the type must bear the relation
		_n_ = len(@aEach)
		for _i_ = 1 to _n_
			_cType_ = @aEach[_i_][1]
			_cRel_ = @aEach[_i_][2]
			_aAll_ = $oWorldEntities.Entities()
			_nAll_ = len(_aAll_)
			for _e_ = 1 to _nAll_
				if _aAll_[_e_][:type] = _cType_
					if NOT This._Bears(_aAll_[_e_][:name], _cRel_)
						_aGaps_ + [ _aAll_[_e_][:name], _cRel_,
							"every " + _cType_ + " needs '" + _cRel_ + "'" ]
					ok
				ok
			next
		next

		# subject form
		_n_ = len(@aOne)
		for _i_ = 1 to _n_
			if NOT This._Bears(@aOne[_i_][1], @aOne[_i_][2])
				_aGaps_ + [ @aOne[_i_][1], @aOne[_i_][2],
					"'" + @aOne[_i_][1] + "' needs '" + @aOne[_i_][2] + "'" ]
			ok
		next

		return _aGaps_

	def IsSatisfied()
		return len(This.Gaps()) = 0

	def _Bears(pcSubject, pcRel)
		_aOut_ = RelationsOf(pcSubject)
		_n_ = len(_aOut_)
		for _i_ = 1 to _n_
			if _aOut_[_i_][1] = pcRel
				return 1
			ok
		next
		return 0
