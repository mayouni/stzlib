# R3b -- stzConversation: THE CONVERSATIONAL DOOR (0.2) AS A DOMAIN
# A governed multi-turn exchange with STATE (topic, goal, grounding,
# history), running the WISE-CODING loop (0.3): the system asks, the
# gap generates the question, the answer protocol governs admission,
# refusals reach a human checkpoint, and the session can end by
# WRITING the knowledgebase. Deterministic floor -- NO model needed;
# stzNeuralChat (neural/) can upgrade fluency behind the same surface.
#
# A CONVERSATION HAPPENS INSIDE A KNOWLEDGE SPACE -- it never owns one.
# The space (stzKnowledgeGraph) HOLDS its conversations by composition and
# is the door for anything needing knowledge; this class holds only the
# SESSION state (topic, goal, pending frame, narration, checkpoints, turns).
# The space hands ITSELF in, live, per call (a Ring attribute store COPIES,
# so a held graph would go stale -- mechanism serves the model, never the
# reverse; see [[feedback-ring-vm-traps]] #12):
#
#   oKB = new stzKnowledgeGraph("restaurant")     # the knowledge SPACE
#   oKB.Know("margherita", "dish")
#   oKB.AddConversationQ("setup").                # ADD a session IN the space,
#       SetGoal(StzGoalQ().RequireEach("dish", "contains"))   # hand it ONE goal
#   ? oKB.AskIn("setup")                          # SYSTEM-LED: born from the gap
#   oKB.ReplyIn("setup", "tomato-sauce")          # admitted INTO the space
#   ? oKB.ConversationQ("setup").GoalState()      # pursuing -> fulfilled|revoked
#   oKB.ConcludeIn("setup", "myworld")            # gaps closed -> .zknw written
#
# AddConversationQ(name) ADDS one and hands you the new object to chain on;
# ConversationQ(name) is for the one ALREADY there. The verb states the act,
# the Q states what comes back.
#
# THE GOAL is not assembled from inside: it is BUILT whole and HANDED OVER
# (SetGoal). A conversation carries exactly ONE, and is accountable for it
# until it is FULFILLED or REVOKED -- see the goal section below.
#
# THE QUESTION IS A FRAME (the house doctrine applied to elicitation): a
# FORCE opens it and SLOTS fill it -- :which when the domain already knows
# candidate values (a closed choice), :what when it is open. The force
# drives the phrasing, and NextQuestionXT() hands the frame back as data
# ([ :force, :subject, :relation, :options, :why ]) so any door -- CLI,
# agent, web -- can render it. (The NNL stzQuestion frame is deliberately
# NOT reused here: it is a chain that ANSWERS questions over data
# (WhatIsQ().TheQ()...), not one that ASKS a human.)
#
# ANSWER REGISTERS: a NUMBER (or list of numbers) picks the offered
# OPTION(s) -- register 1; a STRING is natural phrasing ("X and Y"); a LIST
# of strings is a data structure. Numbers vs strings disambiguate cleanly:
# an index is never mistaken for a literal value.
#
# FLUENCY: Fluency(:neural) rephrases the frame text through a loaded
# generative model when one IS loaded; with no model it stays on the
# deterministic floor and says so (LAW 3 -- never a fake upgrade).
#
# FORMAT: *.zcnv -- the persisted transcript + state (Save/Load).

func StzConversationQ(pcTopic)
	return new stzConversation(pcTopic)

func IsStzConversation(pObj)
	if isObject(pObj) and classname(pObj) = "stzconversation"
		return TRUE
	ok
	return FALSE

	func IsAStzConversation(pObj)
		return IsStzConversation(pObj)


class stzConversation from stzObject

	@cTopic = ""
	@cWhy = ""
	@oGoal = NULL        # THE one goal this conversation is accountable for
	@cGoalState = "none" # none | pursuing | fulfilled | revoked
	@cGoalWhy = ""       # why it ended that way
	@oNarration = NULL
	@aPending = []       # [ subject, relation ] awaiting an answer
	@acOptions = []      # the values offered with the pending question
	@cForce = ""         # the pending question's illocutionary force
	@aCheckpoints = []   # G7: refusals + context, for a human
	@nCheckpointTTL = 0  # 0 = never expire; else live for N turns
	@cFluency = "plain"  # plain | neural
	@nTurns = 0

	def init(pcTopic)
		@cTopic = "" + pcTopic
		@oNarration = new stzNarration()

	def Topic()
		return @cTopic

	#-- THE GOAL: one contract, accepted explicitly, then MONITORED --------
	# A conversation has exactly ONE goal. It is not assembled from inside
	# the session -- it is BUILT as a stzGoal and HANDED OVER; from then on
	# the conversation is accountable for it and watches it until it is
	# FULFILLED (no gaps left in the space) or REVOKED (abandoned, with a
	# reason). No goal = no loop: the elicitation is goal-driven, so asking
	# without one REFUSES rather than inventing something to ask (LAW 3).

	def SetGoal(poGoal)
		if NOT IsStzGoal(poGoal)
			stzraise("SetGoal() needs a stzGoal -- build it (StzGoalQ().RequireEach(...)) and hand it over.")
		ok
		if @cGoalState = "pursuing"
			stzraise("This conversation is already pursuing a goal -- a conversation has ONE goal. RevokeGoal(why) first.")
		ok
		@oGoal = poGoal
		@cGoalState = "pursuing"
		@cGoalWhy = ""
		@oNarration.System("Goal adopted -- this conversation is now accountable for it.")
		return This

	def GoalQ()
		if @oGoal = NULL
			stzraise("This conversation has no goal -- SetGoal(oGoal) first.")
		ok
		return @oGoal

	def HasGoal()
		return @oGoal != NULL

	# none | pursuing | fulfilled | revoked
	def GoalState()
		return @cGoalState

	def GoalWhy()
		return @cGoalWhy

	def IsPursuingGoal()
		return @cGoalState = "pursuing"

	def IsGoalFulfilled()
		return @cGoalState = "fulfilled"

	def IsGoalRevoked()
		return @cGoalState = "revoked"

	# abandon the goal, on the record -- the other way out besides fulfilment
	def RevokeGoal(pcWhy)
		if @cGoalState != "pursuing"
			stzraise("No goal is being pursued here (state: " + @cGoalState + ") -- nothing to revoke.")
		ok
		@cGoalState = "revoked"
		@cGoalWhy = "" + pcWhy
		@aPending = []
		@acOptions = []
		@cForce = ""
		@oNarration.System("Goal revoked: " + @cGoalWhy)
		return This

	# THE MONITORING: re-read the goal against the space; the moment no gap
	# remains, the contract is fulfilled -- recorded, not merely observed.
	def MonitorGoal(poSpace)
		if @cGoalState != "pursuing"
			return @cGoalState
		ok
		if len(@oGoal.Gaps(poSpace)) = 0
			@cGoalState = "fulfilled"
			@cGoalWhy = "every required slot is filled in '" + poSpace.Id() + "'"
			@aPending = []
			@acOptions = []
			@cForce = ""
			@oNarration.System("Goal fulfilled: " + @cGoalWhy)
		ok
		return @cGoalState

	def _RequireGoal()
		if @oGoal = NULL
			stzraise("This conversation has no goal -- SetGoal(oGoal) first (the wise-coding loop is goal-driven).")
		ok

	def NarrationQ()
		return @oNarration

	def History()
		return @oNarration.Lines()

	def NumberOfTurns()
		return @nTurns

	#-- the wise-coding loop ----------------------------------------------

	def Gaps(poSpace)
		This._RequireGoal()
		return @oGoal.Gaps(poSpace)

	# SYSTEM-LED: the next question is BORN FROM THE GAP -- and it can
	# say why it asks (the elicitation is accountable).
	def NextQuestion(poSpace)
		_aQ_ = This.NextQuestionXT(poSpace)
		if len(_aQ_) = 0
			return ""
		ok
		return _aQ_[:question]

	def NextQuestionXT(poSpace)
		This._RequireGoal()
		# a revoked contract asks nothing more; a fulfilled one is done
		if This.MonitorGoal(poSpace) != "pursuing"
			return []
		ok
		_aGaps_ = @oGoal.Gaps(poSpace)
		if len(_aGaps_) = 0
			return []
		ok
		_cSubj_ = _aGaps_[1][1]
		_cRel_ = _aGaps_[1][2]
		_cWhy_ = _aGaps_[1][3]
		@aPending = [ _cSubj_, _cRel_ ]

		# the enumerate branch: values this relation already takes elsewhere
		# become PROPOSED OPTIONS -- and having them CHOOSES the force.
		@acOptions = This._KnownValuesOf(poSpace, _cRel_)
		if len(@acOptions) > 0
			@cForce = "which"      # a closed choice: the domain knows candidates
		else
			@cForce = "what"       # open: nothing to offer yet
		ok

		_cQ_ = This._Phrase(This._FrameText(_cSubj_, _cRel_, _cWhy_))
		@oNarration.System(_cQ_)
		@nTurns++
		return [ :question = _cQ_, :force = @cForce, :subject = _cSubj_,
			:relation = _cRel_, :options = @acOptions, :why = _cWhy_ ]

	# the values offered with the pending question (answer register 1)
	def Options()
		return @acOptions

	# the pending question's illocutionary force ("which" | "what" | "")
	def Force()
		return @cForce

	#-- the FRAME: force opens it, slots fill it --------------------------

	def _FrameText(pcSubj, pcRel, pcWhy)
		if @cForce = "which"
			_c_ = "Which '" + pcRel + "' does '" + pcSubj + "' have? " +
				This._OptionsText() + " -- or answer freely."
		else
			_c_ = "What does '" + pcSubj + "' have for '" + pcRel + "'?"
		ok
		return _c_ + "  (why: " + pcWhy + ")"

	def _OptionsText()
		_c_ = ""
		_n_ = len(@acOptions)
		for _i_ = 1 to _n_
			_c_ += "(" + _i_ + ") " + @acOptions[_i_] + "  "
		next
		return ring_trim(_c_)

	#-- fluency: a real upgrade when a model IS loaded, else the floor ----

	def Fluency(pcMode)
		_c_ = StzLower(ring_trim("" + pcMode))
		if _c_ != "neural" and _c_ != "plain"
			stzraise("Fluency takes :plain or :neural (got '" + _c_ + "').")
		ok
		@cFluency = _c_
		return This

	def FluencyMode()
		return @cFluency

	# TRUE only when neural fluency was asked for AND a model is really
	# loaded -- so a caller can never mistake the floor for the upgrade.
	def IsFluencyNeural()
		return @cFluency = "neural" and StzHasGenerativeModel()

	def _Phrase(pcText)
		if This.IsFluencyNeural()
			_cOut_ = StzGenerate("Rephrase this question naturally for a " +
				"person, keeping every fact and option intact: " + pcText, 60)
			if ring_trim("" + _cOut_) != ""
				return _cOut_
			ok
		ok
		return pcText   # the deterministic floor (LAW 3: no fake upgrade)

	# THE ANSWER PROTOCOL (0.3): the reply may be a LIST (data
	# structure), or a STRING (an option / natural phrasing -- comma
	# and 'and' separated values). Every candidate passes the SAME
	# governed admission (R1: laws, dual-write); refusals are narrated
	# AND checkpointed (G7). Verdict: [ :admitted, :refused, :narration ].
	def Reply(poSpace, pAnswer)
		if len(@aPending) = 0
			stzraise("Nothing was asked -- call NextQuestion() first (the conversation is system-led).")
		ok
		_cSubj_ = @aPending[1]
		_cRel_ = @aPending[2]

		# THE REGISTERS. A number (or list of numbers) = OPTION INDICES
		# (register 1); a string = natural phrasing; a list of strings = a
		# data structure. Numbers vs strings disambiguate with no guessing:
		# an index can never be mistaken for a literal value.
		_acVals_ = []
		_aBadIdx_ = []
		if isList(pAnswer)
			if This._AllIndices(pAnswer)
				_aPick_ = This._OptionsByIndices(pAnswer)
				_acVals_ = _aPick_[:values]
				_aBadIdx_ = _aPick_[:bad]
			else
				_n_ = len(pAnswer)
				for _i_ = 1 to _n_
					if isString(pAnswer[_i_]) and ring_trim(pAnswer[_i_]) != ""
						_acVals_ + ring_trim(pAnswer[_i_])
					ok
				next
			ok
			@oNarration.User(@@(pAnswer))
		but isString(pAnswer)
			_acVals_ = This._ValuesFromPhrase(pAnswer)
			@oNarration.User(pAnswer)
		else
			# a bare number: pick that option
			_aPick_ = This._OptionsByIndices([ pAnswer ])
			_acVals_ = _aPick_[:values]
			_aBadIdx_ = _aPick_[:bad]
			@oNarration.User("" + pAnswer)
		ok

		# an out-of-range pick REFUSES, narrated + checkpointed (LAW 3)
		_nB_ = len(_aBadIdx_)
		for _i_ = 1 to _nB_
			_cWhyB_ = "no option (" + _aBadIdx_[_i_] + ") was offered -- " +
				len(@acOptions) + " option(s) on the table"
			@oNarration.Verdict(_cWhyB_, 1)
			@aCheckpoints + [ :subject = _cSubj_, :relation = _cRel_,
				:attempted = "(" + _aBadIdx_[_i_] + ")", :why = _cWhyB_,
				:turn = @nTurns ]
		next

		_acAdmitted_ = []
		_aRefused_ = []
		_nB2_ = len(_aBadIdx_)
		for _i_ = 1 to _nB2_
			_aRefused_ + [ "(" + _aBadIdx_[_i_] + ")", "no such option" ]
		next
		_n_ = len(_acVals_)
		for _i_ = 1 to _n_
			# THE GOVERNED DOOR of this session's OWN graph: laws checked,
			# verdict explained, refusal recorded -- provenance carried (G8).
			_aAd_ = poSpace.Admit(_cSubj_, _cRel_, _acVals_[_i_],
				[ :source = "conversation:" + @cTopic, :confidence = 1 ])
			@cWhy = _aAd_[:why]
			$cStzLastWhyB = @cWhy       # the house 'last why' convention
			$nStzLastCertainty = 1
			@oNarration.Verdict(@cWhy, 1)
			if _aAd_[:admitted] = 1
				_acAdmitted_ + _acVals_[_i_]
			else
				_aRefused_ + [ _acVals_[_i_], @cWhy ]
				# G7: a refusal reaches a human, context preserved
				@aCheckpoints + [ :subject = _cSubj_, :relation = _cRel_,
					:attempted = _acVals_[_i_], :why = @cWhy,
					:turn = @nTurns ]
			ok
		next
		@nTurns++
		if len(_acAdmitted_) > 0
			@aPending = []
		ok
		This.MonitorGoal(poSpace)   # the contract may have just been fulfilled
		return [ :admitted = _acAdmitted_, :refused = _aRefused_,
			:narration = @cWhy, :goalState = @cGoalState ]

	def Why()
		return @cWhy

	#-- G7 checkpoints, with a TTL ----------------------------------------
	# A refusal reaches a human -- but a checkpoint nobody cleared should not
	# haunt the session forever. TTL(n) lets one LIVE for n turns; 0 (the
	# default) means it never expires. Nothing is deleted: AllCheckpoints()
	# still holds the full record -- expiry is about what still NEEDS a human.

	def CheckpointTTL(nTurns)
		if nTurns < 0
			stzraise("A checkpoint TTL cannot be negative (got " + nTurns + ").")
		ok
		@nCheckpointTTL = nTurns
		return This

	def CheckpointTTLValue()
		return @nCheckpointTTL

	# the checkpoints still LIVE (unexpired) -- what a human must still see
	def Checkpoints()
		if @nCheckpointTTL = 0
			return @aCheckpoints
		ok
		_aOut_ = []
		_n_ = len(@aCheckpoints)
		for _i_ = 1 to _n_
			if (@aCheckpoints[_i_][:turn] + @nCheckpointTTL) >= @nTurns
				_aOut_ + @aCheckpoints[_i_]
			ok
		next
		return _aOut_

	# every checkpoint ever raised, expired or not (the audit record)
	def AllCheckpoints()
		return @aCheckpoints

	def NumberOfExpiredCheckpoints()
		return len(@aCheckpoints) - len(This.Checkpoints())

	# gaps closed -> WRITE the knowledgebase (the session's real
	# artifact); gaps remaining -> refuse with the list (LAW 3)
	def Conclude(poSpace, pcKnowFile)
		This._RequireGoal()
		if This.MonitorGoal(poSpace) = "revoked"
			stzraise("Can't conclude: the goal was REVOKED (" + @cGoalWhy + ") -- a revoked contract has nothing to conclude.")
		ok
		_aGaps_ = @oGoal.Gaps(poSpace)
		if len(_aGaps_) > 0
			stzraise("Can't conclude: " + len(_aGaps_) + " gap(s) remain -- the wise-coding loop is not done. Ask the next question.")
		ok
		poSpace.WriteToKnowFile(pcKnowFile)   # THE SPACE this session grew
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

	# A list is an INDEX list only if every item is a non-string (a number).
	# Checked via isString so no bare isNumber()/type() in class scope (R20).
	def _AllIndices(paList)
		_n_ = len(paList)
		if _n_ = 0
			return 0
		ok
		for _i_ = 1 to _n_
			if isString(paList[_i_]) or isList(paList[_i_])
				return 0
			ok
		next
		return 1

	# Map option indices -> values; out-of-range picks come back as :bad so
	# the caller REFUSES them instead of guessing (LAW 3).
	def _OptionsByIndices(paIdx)
		_aVals_ = []
		_aBad_ = []
		_nO_ = len(@acOptions)
		_n_ = len(paIdx)
		for _i_ = 1 to _n_
			_nIx_ = paIdx[_i_]
			if _nIx_ >= 1 and _nIx_ <= _nO_
				if ring_find(_aVals_, @acOptions[_nIx_]) = 0
					_aVals_ + @acOptions[_nIx_]
				ok
			else
				_aBad_ + _nIx_
			ok
		next
		return [ :values = _aVals_, :bad = _aBad_ ]

	# the values this relation already takes IN THIS SESSION'S graph
	def _KnownValuesOf(poSpace, pcRel)
		_cR_ = StzLower("" + pcRel)
		_acOut_ = []
		_aF_ = poSpace.Facts()
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if StzLower("" + _aF_[_i_][2]) = _cR_
				if ring_find(_acOut_, _aF_[_i_][3]) = 0
					_acOut_ + _aF_[_i_][3]
				ok
			ok
		next
		return _acOut_
