# R5 -- stzOwnAgentStack: SOFTANZA IS THE FIRST CONSUMER OF agentic/
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 0.3 solution space + LAW 5:
#  the library eats its own cooking.) A CURATED set of library-internal
#  agents the library OWNS and consumes first -- the roster is a
#  Softanza-designer decision, distinct from the APPLICATION space where
#  programmers add their own agents over the same interfaces.
#
#   ? StzOwnAgents()                 # the curated roster
#   oWC = StzOwnAgent("wise-coder")  # a real, wired agent Softanza owns
#   oWC.PursueGoal(oGoal)               # drives the R3b elicitation loop
#
# THE ROSTER (each a stzPIAgent specialization the library uses):
#   wise-coder  -- drives conversation/ elicitation to a filled goal
#   validator   -- runs the answer protocol / governed admission
#   ranker      -- collapses weighted candidates by the evidential bands
#   induction   -- infers a pattern from examples (the ...ex family)
#   planner     -- goal-predicate search over the graph
# Only wise-coder is WIRED in this slice; the rest are declared, so the
# roster is honest about what runs vs what is reserved (LAW 3).

func StzOwnAgents()
	return [
		[ "wise-coder", "drives conversation/ elicitation to a filled goal", "wired" ],
		[ "validator", "runs the answer protocol / governed admission", "reserved" ],
		[ "ranker", "collapses weighted candidates by evidential bands", "reserved" ],
		[ "induction", "infers a ...ex pattern from examples", "reserved" ],
		[ "planner", "goal-predicate search over the knowledge graph", "reserved" ]
	]

func StzOwnAgentIsWired(pcName)
	_cN_ = StzLower(ring_trim("" + pcName))
	_a_ = StzOwnAgents()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if _a_[_i_][1] = _cN_
			return (_a_[_i_][3] = "wired")
		ok
	next
	return 0

func StzOwnAgent(pcName)
	_cN_ = StzLower(ring_trim("" + pcName))
	if _cN_ = "wise-coder"
		return new stzWiseCoderAgent()
	ok
	if StzOwnAgentIsWired(_cN_) = 0
		stzraise("Softanza's own agent '" + _cN_ + "' is RESERVED, not wired yet -- refusing rather than returning a stub (LAW 3). See StzOwnAgents().")
	ok
	stzraise("Softanza owns no agent named '" + _cN_ + "'.")


# THE WIRED OWN AGENT: wise-coder. It does NOT reimplement the
# elicitation loop -- it DRIVES conversation/ (R3b) as an agent,
# proving the library consumes its own agentic surface. The loop is
# still system-led (the gap generates the question); the agent adds
# the perceive-decide-act framing and a bounded pursuit.
class stzWiseCoderAgent from stzObject

	@cConvTopic = ""
	@nAsked = 0
	@cWhy = ""

	def init()

	def Name_()
		return "wise-coder (Softanza own agent)"

	# drive the elicitation over a goal to fixpoint (no gaps left),
	# answering from a supplied ANSWER SOURCE closure that maps
	# (subject, relation) -> a value string ("" = the agent stops,
	# leaving the gap for a human -- it never invents domain facts).
	# poKB = the SCOPED knowledge SPACE to elicit in (never a global world).
	# The conversation happens INSIDE that space, so the space drives it and
	# every admission lands in the CALLER's own graph (params are by-ref).
	def PursueGoal(poGoal, poKB, fAnswerSource)
		if NOT IsStzKnowledgeGraph(poKB)
			stzraise("PursueGoal needs the knowledge SPACE to elicit in -- PursueGoal(oGoal, oKB, fAnswers).")
		ok
		if NOT IsStzGoal(poGoal)
			stzraise("PursueGoal needs a stzGoal to pursue -- PursueGoal(oGoal, oKB, fAnswers).")
		ok
		@cConvTopic = "own-wise-coding"
		# a FRESH session per pursuit, opened in the space
		if poKB.HasConversation(@cConvTopic)
			poKB.RemoveConversation(@cConvTopic)
		ok
		poKB.AddConversation(@cConvTopic)
		# HAND THE GOAL OVER -- the session is now accountable for it
		poKB.ConversationQ(@cConvTopic).SetGoal(poGoal)

		@nAsked = 0
		_nRound_ = 0
		while _nRound_ < 200
			_nRound_++
			_aQ_ = poKB.AskInXT(@cConvTopic)
			if len(_aQ_) = 0
				exit                       # goal filled -- fixpoint
			ok
			@nAsked++
			_cVal_ = call fAnswerSource(_aQ_[:subject], _aQ_[:relation])
			if _cVal_ = ""
				# the agent refuses to invent -- leaves the gap
				@cWhy = "stopped: no answer for '" + _aQ_[:subject] +
					"' / '" + _aQ_[:relation] + "' -- gap left for a human"
				return [ :filled = 0, :asked = @nAsked, :why = @cWhy ]
			ok
			poKB.ReplyIn(@cConvTopic, _cVal_)
		end

		@cWhy = "goal filled in " + @nAsked + " question(s), governed admission throughout"
		return [ :filled = 1, :asked = @nAsked, :why = @cWhy ]

	def ConversationTopic()
		return @cConvTopic

	def Why()
		return @cWhy
