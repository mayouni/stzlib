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
# FLUENCY: SetFluency(:neural) rephrases the frame text through a loaded
# generative model when one IS loaded; with no model it stays on the
# deterministic floor and says so (LAW 3 -- never a fake upgrade).
#
# FORMAT: *.zcnv -- the persisted transcript + state (Save/Load).

func StzConversationQ(pcTopic)
	return new stzConversation(pcTopic)

func IsStzConversation(pObj)
	if isObject(pObj) and classname(pObj) = "stzconversation"
		return 1
	ok
	return 0

	func IsAStzConversation(pObj)
		return IsStzConversation(pObj)


# Runs a governed question-and-answer session in a knowledge space: the system asks from the gaps of a goal, and answers are admitted by law.
#
# A conversation happens inside a stzKnowledgeGraph and never owns one: the space is handed in on
# each call. You hand the session exactly one goal; NextQuestion is born from the first gap and says
# why it asks, and Reply admits each answer through the space governed door, so a law such as
# :Unique refuses a value and the refusal becomes a checkpoint for a human. A number picks an
# offered option, text such as X and Y is split into values, and a list is taken as data. The goal
# moves from pursuing to fulfilled when no gap remains, or to revoked; Conclude then writes the
# space to a knowledge file, and refuses while gaps remain. It needs no model: neural wording is
# used only when a generative model is really loaded.
#
#   receiver   oKB = new stzKnowledgeGraph("restaurant"); oKB.Know("margherita", "dish") o1 = new
#              stzConversation("setup"); o1.SetGoal(StzGoalQ().RequireEach("dish", "contains"))
#   example    ? o1.NextQuestion(oKB)
#              #--> What does 'margherita' have for 'contains'?  (why: every dish needs 'contains')
#              ? len(o1.Reply(oKB, "tomato and mozzarella")[:admitted])
#              #--> 2
#              ? o1.GoalState()
#              #--> fulfilled
#   see        stzKnowledgeGraph, stzGoal, stzTranscript, stzNeuralChat
class stzConversation from stzObject

	@cTopic = ""
	@cWhy = ""
	@oGoal = ""        # THE one goal this conversation is accountable for
	@cGoalState = "none" # none | pursuing | fulfilled | revoked
	@cGoalWhy = ""       # why it ended that way
	@oTranscript = ""
	@aPending = []       # [ subject, relation ] awaiting an answer
	@acOptions = []      # the values offered with the pending question
	@cForce = ""         # the pending question's illocutionary force
	@aCheckpoints = []   # G7: refusals + context, for a human
	@nCheckpointTTL = 0  # 0 = never expire; else live for N turns
	@cFluency = "plain"  # plain | neural
	@nTurns = 0

	# Builds a conversation session on a topic, with no goal, plain fluency and an empty transcript.
	#
	#   pcTopic    the topic name, which also tags the source of every answer admitted
	#   returns    nothing; the object is built
	#   see        SetGoal, NextQuestion
	def init(pcTopic)
		@cTopic = "" + pcTopic
		@oTranscript = new stzTranscript()

	# Returns the topic the session was built with.
	#
	#   returns    a text
	#   see        Save
	def Topic()
		return @cTopic

	# Hands the session the one goal it is accountable for, and starts pursuing it.
	#
	#   poGoal     the stzGoal to pursue, such as StzGoalQ().RequireEach(dish, contains)
	#   returns    the conversation itself, so calls chain
	#   note       after a goal is revoked or fulfilled a new one may be set
	#   warning    raises an error for a value that is not a stzGoal and while another goal is still
	#              being pursued
	#   see        GoalQ, MonitorGoal, RevokeGoal
	#@ aka  -- THE GOAL: one contract, accepted explicitly, then MONITORED -------- A conversation has exactly ONE goal. It is not assembled from inside the session -- it is BUILT as a stzGoal and HANDED OVER; from then on the conversation is accountable for it and watches it until it is FULFILLED (no gaps left in the space) or REVOKED (abandoned, with a reason). No goal = no loop: the elicitation is goal-dri
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
		@oTranscript.System("Goal adopted -- this conversation is now accountable for it.")
		return This

	# Returns the goal object the session is accountable for.
	#
	#   returns    the stzGoal object
	#   warning    raises an error while no goal is set, so test HasGoal first
	#   see        HasGoal, SetGoal
	def GoalQ()
		if @oGoal = ""
			stzraise("This conversation has no goal -- SetGoal(oGoal) first.")
		ok
		return @oGoal

	# TRUE if a goal was handed over.
	#
	#   returns    TRUE or FALSE
	#   see        SetGoal, GoalState
	def HasGoal()
		return @oGoal != ""

	# Returns where the goal stands: none, pursuing, fulfilled or revoked.
	#
	#   returns    a text
	#   see        GoalWhy, MonitorGoal
	#@ aka  none | pursuing | fulfilled | revoked
	def GoalState()
		return @cGoalState

	# Returns why the goal ended as it did.
	#
	#   returns    a text; empty while none or pursuing
	#   see        GoalState, RevokeGoal
	def GoalWhy()
		return @cGoalWhy

	# TRUE if a goal is set and neither fulfilled nor revoked.
	#
	#   returns    TRUE or FALSE
	#   see        GoalState
	def IsPursuingGoal()
		return @cGoalState = "pursuing"

	# TRUE if no gap remains for the goal in the space.
	#
	#   returns    TRUE or FALSE
	#   see        GoalState, MonitorGoal
	def IsGoalFulfilled()
		return @cGoalState = "fulfilled"

	# TRUE if the goal was abandoned on the record.
	#
	#   returns    TRUE or FALSE
	#   see        GoalState, RevokeGoal
	def IsGoalRevoked()
		return @cGoalState = "revoked"

	# Abandons the goal with a reason, clearing the pending question.
	#
	#   pcWhy      the reason, kept in GoalWhy and written to the transcript
	#   returns    the conversation itself, so calls chain
	#   note       a revoked goal asks nothing more and cannot be concluded
	#   warning    raises an error unless the goal is being pursued
	#   see        GoalWhy, SetGoal
	#@ aka  abandon the goal, on the record -- the other way out besides fulfilment
	def RevokeGoal(pcWhy)
		if @cGoalState != "pursuing"
			stzraise("No goal is being pursued here (state: " + @cGoalState + ") -- nothing to revoke.")
		ok
		@cGoalState = "revoked"
		@cGoalWhy = "" + pcWhy
		@aPending = []
		@acOptions = []
		@cForce = ""
		@oTranscript.System("Goal revoked: " + @cGoalWhy)
		return This

	# Re-reads the goal against the space and marks it fulfilled once no gap remains.
	#
	#   poSpace    the stzKnowledgeGraph the conversation runs in
	#   returns    a text, the goal state after the check
	#   note       NextQuestion and Reply call it themselves
	#   see        GoalState, Gaps
	#@ aka  THE MONITORING: re-read the goal against the space; the moment no gap remains, the contract is fulfilled -- recorded, not merely observed.
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
			@oTranscript.System("Goal fulfilled: " + @cGoalWhy)
		ok
		return @cGoalState

	def _RequireGoal()
		if @oGoal = ""
			stzraise("This conversation has no goal -- SetGoal(oGoal) first (the wise-coding loop is goal-driven).")
		ok

	def TranscriptQ()
		return @oTranscript

		# the name this accessor had until 2026-09-06, kept one version so a
		# caller written against it still runs; TranscriptQ() is the name
		def NarrationQ()
			return This.TranscriptQ()

	# Returns the transcript lines, in order.
	#
	#   returns    a list of [ speaker, text, certainty ] rows, speaker being system, user or
	#              verdict
	#   see        Transcript
	def History()
		return @oTranscript.Lines()

	# Returns how many turns have passed: one for each question asked and each reply given.
	#
	#   returns    a number
	#   see        History, Checkpoints
	def NumberOfTurns()
		return @nTurns

	# Returns the facts the goal still lacks in the space.
	#
	#   poSpace    the stzKnowledgeGraph the conversation runs in
	#   returns    a list of [ subject, relation, why ] rows; [ ] when the goal is met
	#   warning    raises an error while no goal is set
	#   see        NextQuestion, MonitorGoal
	#@ aka  -- the wise-coding loop ----------------------------------------------
	def Gaps(poSpace)
		This._RequireGoal()
		return @oGoal.Gaps(poSpace)

	# Returns the next question, born from the first gap, and remembers it as the pending one.
	#
	#   poSpace    the stzKnowledgeGraph the conversation runs in
	#   returns    a text, the question with its reason; empty when the goal is fulfilled or revoked
	#   note       NextQuestionXT gives the same question as data: question, force, subject,
	#              relation, options and why
	#   warning    raises an error while no goal is set
	#   see        Reply, Options, Force
	#@ aka  SYSTEM-LED: the next question is BORN FROM THE GAP -- and it can say why it asks (the elicitation is accountable).
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
		@oTranscript.System(_cQ_)
		@nTurns++
		return [ :question = _cQ_, :force = @cForce, :subject = _cSubj_,
			:relation = _cRel_, :options = @acOptions, :why = _cWhy_ ]

	# Returns the values offered with the pending question.
	#
	#   returns    a list of text; [ ] when the question is open
	#   note       values that the relation already takes elsewhere in the space become numbered
	#              options
	#   see        Force, Reply
	#@ aka  the values offered with the pending question (answer register 1)
	def Options()
		return @acOptions

	# Returns the kind of the pending question: which for a closed choice, what for an open one.
	#
	#   returns    a text; empty when nothing is pending
	#   see        Options, NextQuestion
	#@ aka  the pending question's illocutionary force ("which" | "what" | "")
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

	# Chooses plain or neural wording of the questions.
	#
	#   pcMode     plain or neural, without regard to case
	#   returns    the conversation itself, so calls chain
	#   note       neural wording needs a generative model loaded; without one the plain wording is
	#              kept
	#   warning    raises an error for any other mode
	#   see        Fluency, IsFluencyNeural
	#@ aka  -- fluency: a real upgrade when a model IS loaded, else the floor ----
	def SetFluency(pcMode)
		_c_ = StzLower(ring_trim("" + pcMode))
		if _c_ != "neural" and _c_ != "plain"
			stzraise("Fluency takes :plain or :neural (got '" + _c_ + "').")
		ok
		@cFluency = _c_
		return This

	# Returns the fluency that was asked for.
	#
	#   returns    a text, plain or neural
	#   see        SetFluency, IsFluencyNeural
	def Fluency()
		return @cFluency

	# TRUE if neural wording was asked for and a generative model is really loaded.
	#
	#   returns    TRUE or FALSE
	#   note       FALSE means the questions are on the deterministic floor
	#   see        SetFluency
	#@ aka  TRUE only when neural fluency was asked for AND a model is really loaded -- so a caller can never mistake the floor for the upgrade.
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

	# Answers the pending question; each value passes the space governed admission, and refusals become checkpoints.
	#
	#   poSpace    the stzKnowledgeGraph that admits the values
	#   pAnswer    a number or list of numbers that pick offered options, text such as X and Y, or a
	#              list of text
	#   returns    a hash-list [ :admitted, :refused, :narration, :goalState ]; :refused holds [
	#              value, reason ] rows
	#   note       values are split at commas and the word and; one admitted value is enough to
	#              clear the pending question
	#   warning    raises an error when no question is pending; a number that matches no offered
	#              option is refused and checkpointed, not guessed
	#   see        NextQuestion, Checkpoints, Why
	#@ aka  THE ANSWER PROTOCOL (0.3): the reply may be a LIST (data structure), or a STRING (an option / natural phrasing -- comma and 'and' separated values). Every candidate passes the SAME governed admission (R1: laws, dual-write); refusals are narrated AND checkpointed (G7). Verdict: [ :admitted, :refused, :narration ].
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
			@oTranscript.User(@@(pAnswer))
		but isString(pAnswer)
			_acVals_ = This._ValuesFromPhrase(pAnswer)
			@oTranscript.User(pAnswer)
		else
			# a bare number: pick that option
			_aPick_ = This._OptionsByIndices([ pAnswer ])
			_acVals_ = _aPick_[:values]
			_aBadIdx_ = _aPick_[:bad]
			@oTranscript.User("" + pAnswer)
		ok

		# an out-of-range pick REFUSES, narrated + checkpointed (LAW 3)
		_nB_ = len(_aBadIdx_)
		for _i_ = 1 to _nB_
			_cWhyB_ = "no option (" + _aBadIdx_[_i_] + ") was offered -- " +
				len(@acOptions) + " option(s) on the table"
			@oTranscript.Verdict(_cWhyB_, 1)
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
			@oTranscript.Verdict(@cWhy, 1)
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

	# Returns the explanation of the last admission or refusal.
	#
	#   returns    a text; empty before the first reply
	#   see        Reply, Checkpoints
	def Why()
		return @cWhy

	# Sets for how many turns a refusal checkpoint stays live.
	#
	#   nTurns     the number of turns, or 0 for never expiring
	#   returns    the conversation itself, so calls chain
	#   note       nothing is deleted; AllCheckpoints keeps the full record
	#   warning    raises an error for a negative number
	#   see        CheckpointTTL, Checkpoints
	#@ aka  -- G7 checkpoints, with a TTL ---------------------------------------- A refusal reaches a human -- but a checkpoint nobody cleared should not haunt the session forever. TTL(n) lets one LIVE for n turns; 0 (the default) means it never expires. Nothing is deleted: AllCheckpoints() still holds the full record -- expiry is about what still NEEDS a human.
	def SetCheckpointTTL(nTurns)
		if nTurns < 0
			stzraise("A checkpoint TTL cannot be negative (got " + nTurns + ").")
		ok
		@nCheckpointTTL = nTurns
		return This

	# Returns for how many turns a checkpoint stays live.
	#
	#   returns    a number; 0 means it never expires
	#   see        SetCheckpointTTL
	def CheckpointTTL()
		return @nCheckpointTTL

	# Returns the refusal checkpoints still live, which a human has yet to see.
	#
	#   returns    a list of hash-lists with subject, relation, attempted, why and turn
	#   see        AllCheckpoints, NumberOfExpiredCheckpoints
	#@ aka  the checkpoints still LIVE (unexpired) -- what a human must still see
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

	# Returns every refusal checkpoint ever raised, expired or not.
	#
	#   returns    a list of hash-lists with subject, relation, attempted, why and turn
	#   see        Checkpoints
	#@ aka  every checkpoint ever raised, expired or not (the audit record)
	def AllCheckpoints()
		return @aCheckpoints

	# Returns how many checkpoints have outlived the TTL.
	#
	#   returns    a number
	#   see        Checkpoints, AllCheckpoints
	def NumberOfExpiredCheckpoints()
		return len(@aCheckpoints) - len(This.Checkpoints())

	# Writes the finished knowledge space to a file, once the goal has no gap left.
	#
	#   poSpace      the stzKnowledgeGraph the session grew
	#   pcKnowFile   the base path of the knowledge file, written as .zknw
	#   returns      1 when the file was written
	#   warning      raises an error while no goal is set, when the goal was revoked, and when gaps
	#                remain
	#   see          Gaps, MonitorGoal
	#@ aka  gaps closed -> WRITE the knowledgebase (the session's real artifact); gaps remaining -> refuse with the list (LAW 3)
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
		@oTranscript.System("Concluded: the knowledgebase is written (" + pcKnowFile + ").")
		return 1

	# Writes the topic and the transcript to a .zcnv file.
	#
	#   pcFile     the path to write
	#   returns    a text, the path written, with .zcnv added when missing
	#   note       the goal state and checkpoints are not written, and the class has no Load
	#   see        Transcript, Topic
	#@ aka  -- persistence (*.zcnv) ---------------------------------------------
	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zcnv"
			pcFile += ".zcnv"
		ok
		_c_ = 'conversation "' + @cTopic + '"' + char(10) + "history" + char(10)
		_aL_ = @oTranscript.Lines()
		_n_ = len(_aL_)
		for _i_ = 1 to _n_
			_c_ += "    " + _aL_[_i_][1] + " | " + _aL_[_i_][2] + char(10)
		next
		write(pcFile, _c_)
		return pcFile

	# Returns the transcript as dialogue text, SOFTANZA and YOU lines with each verdict under its answer.
	#
	#   returns    a text
	#   see        History, Save
	def Transcript()
		return @oTranscript.Text()

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
