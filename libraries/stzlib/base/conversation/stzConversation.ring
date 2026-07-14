# R3b -- stzConversation: THE CONVERSATIONAL DOOR (0.2) AS A DOMAIN
# A governed multi-turn exchange with STATE (topic, goal, grounding,
# history), running the WISE-CODING loop (0.3): the system asks, the
# gap generates the question, the answer protocol governs admission,
# refusals reach a human checkpoint, and the session can end by
# WRITING the knowledgebase. Deterministic floor -- NO model needed;
# stzNeuralChat (neural/) can upgrade fluency behind the same surface.
#
#   oCv = new stzConversation("restaurant-setup")
#   oCv.GoalQ().RequireEach("dish", "contains")
#   ? oCv.NextQuestion()      # SYSTEM-LED: born from the gap
#   oCv.Reply("tomato-sauce") # any register; admission GOVERNED
#   ? oCv.Why()               # every verdict narrated
#   oCv.Conclude("myworld")   # gaps closed -> the .zknw written
#
# FORMAT: *.zcnv -- the persisted transcript + state (Save/Load).

class stzConversation from stzObject

	@cTopic = ""
	@oGoal = NULL
	@oNarration = NULL
	@aPending = []       # [ subject, relation ] awaiting an answer
	@aCheckpoints = []   # G7: refusals + context, for a human
	@nTurns = 0

	def init(pcTopic)
		@cTopic = "" + pcTopic
		@oGoal = new stzGoal()
		@oNarration = new stzNarration()

	def Topic()
		return @cTopic

	def GoalQ()
		return @oGoal

	def NarrationQ()
		return @oNarration

	def History()
		return @oNarration.Lines()

	def NumberOfTurns()
		return @nTurns

	#-- the wise-coding loop ----------------------------------------------

	def Gaps()
		return @oGoal.Gaps()

	# SYSTEM-LED: the next question is BORN FROM THE GAP -- and it can
	# say why it asks (the elicitation is accountable).
	def NextQuestion()
		_aQ_ = This.NextQuestionXT()
		if len(_aQ_) = 0
			return ""
		ok
		return _aQ_[:question]

	def NextQuestionXT()
		_aGaps_ = @oGoal.Gaps()
		if len(_aGaps_) = 0
			@aPending = []
			return []
		ok
		_cSubj_ = _aGaps_[1][1]
		_cRel_ = _aGaps_[1][2]
		@aPending = [ _cSubj_, _cRel_ ]
		_cQ_ = "What does '" + _cSubj_ + "' bear for '" + _cRel_ + "'? (" +
			_aGaps_[1][3] + ")"
		# the enumerate branch: values this relation already takes
		# elsewhere become PROPOSED OPTIONS (answer register 1)
		_acOpts_ = This._KnownValuesOf(_cRel_)
		@oNarration.System(_cQ_)
		@nTurns++
		return [ :question = _cQ_, :subject = _cSubj_, :relation = _cRel_,
			:options = _acOpts_, :why = _aGaps_[1][3] ]

	# THE ANSWER PROTOCOL (0.3): the reply may be a LIST (data
	# structure), or a STRING (an option / natural phrasing -- comma
	# and 'and' separated values). Every candidate passes the SAME
	# governed admission (R1: laws, dual-write); refusals are narrated
	# AND checkpointed (G7). Verdict: [ :admitted, :refused, :narration ].
	def Reply(pAnswer)
		if len(@aPending) = 0
			stzraise("Nothing was asked -- call NextQuestion() first (the conversation is system-led).")
		ok
		_cSubj_ = @aPending[1]
		_cRel_ = @aPending[2]

		_acVals_ = []
		if isList(pAnswer)
			_n_ = len(pAnswer)
			for _i_ = 1 to _n_
				if isString(pAnswer[_i_]) and ring_trim(pAnswer[_i_]) != ""
					_acVals_ + ring_trim(pAnswer[_i_])
				ok
			next
			@oNarration.User(@@(pAnswer))
		but isString(pAnswer)
			_acVals_ = This._ValuesFromPhrase(pAnswer)
			@oNarration.User(pAnswer)
		ok

		_acAdmitted_ = []
		_aRefused_ = []
		_n_ = len(_acVals_)
		for _i_ = 1 to _n_
			_bOk_ = StzKnowRelation(_cSubj_, _cRel_, _acVals_[_i_])
			@oNarration.Verdict($cStzLastWhyB, $nStzLastCertainty)
			if _bOk_ = 1
				_acAdmitted_ + _acVals_[_i_]
			else
				_aRefused_ + [ _acVals_[_i_], $cStzLastWhyB ]
				# G7: a refusal reaches a human, context preserved
				@aCheckpoints + [ :subject = _cSubj_, :relation = _cRel_,
					:attempted = _acVals_[_i_], :why = $cStzLastWhyB,
					:turn = @nTurns ]
			ok
		next
		@nTurns++
		if len(_acAdmitted_) > 0
			@aPending = []
		ok
		return [ :admitted = _acAdmitted_, :refused = _aRefused_,
			:narration = $cStzLastWhyB ]

	def Why()
		return $cStzLastWhyB

	def Checkpoints()
		return @aCheckpoints

	# gaps closed -> WRITE the knowledgebase (the session's real
	# artifact); gaps remaining -> refuse with the list (LAW 3)
	def Conclude(pcKnowFile)
		_aGaps_ = @oGoal.Gaps()
		if len(_aGaps_) > 0
			stzraise("Can't conclude: " + len(_aGaps_) + " gap(s) remain -- the wise-coding loop is not done. Ask NextQuestion().")
		ok
		StzSaveKnowledgeBase(pcKnowFile)
		@oNarration.System("Concluded: the knowledgebase is written (" + pcKnowFile + ").")
		return 1

	#-- persistence (*.zcnv) ---------------------------------------------

	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zcnv"
			pcFile += ".zcnv"
		ok
		_c_ = 'conversation "' + @cTopic + '"' + NL + "history" + NL
		_aL_ = @oNarration.Lines()
		_n_ = len(_aL_)
		for _i_ = 1 to _n_
			_c_ += "    " + _aL_[_i_][1] + " | " + _aL_[_i_][2] + NL
		next
		write(pcFile, _c_)
		return pcFile

	def Transcript()
		return @oNarration.Text()

	#-- helpers -------------------------------------------------------------

	def _ValuesFromPhrase(pcAnswer)
		_c_ = StzReplace(" " + ring_trim("" + pcAnswer) + " ", " and ", ",")
		_acRaw_ = StzSplit(_c_, ",")
		_acOut_ = []
		_n_ = len(_acRaw_)
		for _i_ = 1 to _n_
			_cV_ = ring_trim(_acRaw_[_i_])
			if _cV_ != ""
				_acOut_ + _cV_
			ok
		next
		return _acOut_

	def _KnownValuesOf(pcRel)
		_acOut_ = []
		_n_ = len($aStzRelations)
		for _i_ = 1 to _n_
			if $aStzRelations[_i_][2] = pcRel
				if ring_find(_acOut_, $aStzRelations[_i_][3]) = 0
					_acOut_ + $aStzRelations[_i_][3]
				ok
			ok
		next
		return _acOut_
