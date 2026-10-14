# R5 -- stzAgentGraph: THE GOVERNANCE-COLORED COMPOSITION (G1, live)
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.7 G1/G2 + 5.6.)
# Declare a multi-agent composition as a COLORED stzGraph -- actors
# (pi/llm/hybrid), guardians, effects, tools, trace sinks -- then PROVE
# it sound with the meta/ governance validators (the three injection
# gates + the four invariants). Agents are subgraphs; governance is a
# set of graph predicates checked before anything runs (LAW 6).
#
#   oAG = new stzAgentGraph("mailer")
#   oAG.AddLLMActor("writer")               # capability set is EMPTY
#   oAG.AddGuardian("gate")
#   oAG.AddEffect("send")
#   oAG.AddTraceSink("audit")
#   oAG.Proposes("writer", "gate")          # creativity proposes
#   oAG.Guards("gate", "send")              # a pi-gate guards the effect
#   oAG.Traces("send", "audit")             # the effect leaves a witness
#   ? oAG.IsSound()   ? oAG.Violations()

# Declares a multi-agent composition as a colored graph and proves it sound before anything runs.
#
# Actors (program, language model, hybrid), guardians, effects, tools, trace sinks, inputs and human
# checkpoints are nodes, each with a fixed capability set and a taint color; edges say who proposes
# to, guards, feeds, traces or escalates to whom. The invariants checked are: a language-model actor
# never holds the effectful capability, every effect has a guardian into it and a path to a trace
# sink, open model text and external data never reach an effect without a guardian on the path.
# Grant is the governed door, which refuses effectful for an llm actor at the moment it is
# expressed, and a sealed record of what the doors granted lets Tampering report any property set
# around them through GraphQ. Declaring an id again replaces the node.
#
#   receiver   o1 = new stzAgentGraph("mailer")
#   example    o1.AddLLMActor("writer")
#              o1.AddGuardian("gate")
#              o1.AddEffect("send")
#              o1.AddTraceSink("audit")
#              ? o1.IsSound()
#              #--> 0
#              o1.Proposes("writer", "gate")
#              o1.Guards("gate", "send")
#              o1.Traces("send", "audit")
#              ? o1.IsSound()
#              #--> 1
#              ? o1.MayGrant("writer", "effectful")
#              #--> 0
#   see        stzGraph, stzAgentHost, stzAgentRuleSet
class stzAgentGraph from stzObject

	@cName = ""
	@oG = ""
	# THE SEALED RECORD (threat-model R1, 2026-09-29). GraphQ() hands out the
	# raw graph, so any property on it can be set around the governed doors.
	# The properties a GATE decides on are therefore ALSO recorded here, by the
	# governed doors only, out of GraphQ()'s reach: the gates read THIS record,
	# and Tampering() reports every node whose graph property no longer matches
	# it. A raw edit can still change the picture; it can no longer change a
	# decision, and it can no longer go unseen.
	@aSealed = []	# [ id, kind, [ capabilities ] ]

	# Builds an empty composition of agents, drawn as a colored graph that can be proved sound before anything runs.
	#
	#   pcName     the composition's name, quoted in its verdicts
	#   returns    nothing; the object is built
	#   see        AddLLMActor, IsSound, Explain
	def init(pcName)
		@cName = "" + pcName
		@oG = new stzGraph("agentgraph-" + pcName)

	# Returns the underlying graph, for drawing or inspection.
	#
	#   returns    the stzGraph that holds the nodes and edges
	#   note       a property set on it directly changes the picture but not the decisions, which
	#              read a sealed record; Tampering reports the difference
	#   see        Tampering, AddPIActor
	def GraphQ()
		return @oG

	# Adds a trusted actor that may produce effects, with the capabilities effectful, compute and sensing.
	#
	#   pcId       the node's id, trimmed and lower-cased
	#   returns    nothing; use AddPIActorQ to chain
	#   note       the id is lower-cased, so Boss and boss are one node
	#   warning    declaring an id that already exists replaces its kind, capabilities and taint,
	#              and the sealed record follows: an llm actor declared again as a pi actor is
	#              accepted
	#   see        AddLLMActor, AddEffect
	#@ aka  -- nodes (the capability lattice + taint colours) ----------------------
	def AddPIActor(pcId)
		This._Node(pcId, "pi_actor", [ "effectful", "compute", "sensing" ], "trusted")

	# an LLM actor's capability set is EMPTY (the 5.7 load-bearing rule)
	# and its output is tainted open_llm_text

		def AddPIActorQ(pcId)
			This.AddPIActor(pcId)
			return This

	# Adds a language-model actor, which holds only the inference capability and whose output is tainted as open text.
	#
	#   pcId       the node's id, trimmed and lower-cased
	#   returns    nothing; use AddLLMActorQ to chain
	#   note       an llm actor proposes and never commits: it cannot be granted the effectful
	#              capability
	#   warning    declaring an id that already exists replaces its kind and capabilities
	#   see        AddPIActor, Grant, MayGrant
	def AddLLMActor(pcId)
		This._Node(pcId, "llm_actor", [ "inference" ], "open_llm_text")

		def AddLLMActorQ(pcId)
			This.AddLLMActor(pcId)
			return This

	# Adds an actor that mixes program and model, which holds the inference capability and whose output is tainted as open text.
	#
	#   pcId       the node's id, trimmed and lower-cased
	#   returns    nothing; use AddHybridActorQ to chain
	#   note       unlike an llm actor, it can be granted effectful through Grant
	#   see        AddLLMActor, Grant
	def AddHybridActor(pcId)
		This._Node(pcId, "hybrid_actor", [ "inference" ], "open_llm_text")

		def AddHybridActorQ(pcId)
			This.AddHybridActor(pcId)
			return This

	# Adds a guardian, the gate that validates what passes through it, with the capabilities compute and sensing.
	#
	#   pcId       the node's id, trimmed and lower-cased
	#   returns    nothing; use AddGuardianQ to chain
	#   see        Guards, AddEffect
	def AddGuardian(pcId)
		This._Node(pcId, "guardian", [ "compute", "sensing" ], "validated")

		def AddGuardianQ(pcId)
			This.AddGuardian(pcId)
			return This

	# Adds an effect, a node that changes the world, with the capability effectful.
	#
	#   pcId       the node's id, trimmed and lower-cased
	#   returns    nothing; use AddEffectQ to chain
	#   note       every effect owes a guardian edge into it and a path to a trace sink
	#   see        Guards, Traces
	def AddEffect(pcId)
		This._Node(pcId, "effect", [ "effectful" ], "trusted")

		def AddEffectQ(pcId)
			This.AddEffect(pcId)
			return This

	# Adds a tool, a node that computes, with the capability compute.
	#
	#   pcId       the node's id, trimmed and lower-cased
	#   returns    nothing; use AddToolQ to chain
	#   see        Feeds, AddEffect
	def AddTool(pcId)
		This._Node(pcId, "tool", [ "compute" ], "trusted")

		def AddToolQ(pcId)
			This.AddTool(pcId)
			return This

	# Adds a trace sink, the witness where effects leave a record, with the capability sensing.
	#
	#   pcId       the node's id, trimmed and lower-cased
	#   returns    nothing; use AddTraceSinkQ to chain
	#   see        Traces, AddEffect
	def AddTraceSink(pcId)
		This._Node(pcId, "trace_sink", [ "sensing" ], "trusted")

		def AddTraceSinkQ(pcId)
			This.AddTraceSink(pcId)
			return This

	# Adds an external input, a node with no capability whose data is tainted as external.
	#
	#   pcId       the node's id, trimmed and lower-cased
	#   returns    nothing; use AddInputQ to chain
	#   note       external data that reaches an effect with no guardian or validated checkpoint on
	#              the path is a violation
	#   see        Feeds, AddGuardian
	def AddInput(pcId)
		This._Node(pcId, "input", [], "external_data")

		def AddInputQ(pcId)
			This.AddInput(pcId)
			return This

	# Adds a human checkpoint, a node where a person validates, with the capability sensing.
	#
	#   pcId       the node's id, trimmed and lower-cased
	#   returns    nothing; use AddCheckpointQ to chain
	#   see        Escalates, AddGuardian
	def AddCheckpoint(pcId)
		This._Node(pcId, "human_checkpoint", [ "sensing" ], "validated")

		def AddCheckpointQ(pcId)
			This.AddCheckpoint(pcId)
			return This

	def _Node(pcId, pcKind, pacCaps, pcTaint)
		_cId_ = StzLower(ring_trim("" + pcId))
		if NOT @oG.NodeExists(_cId_)
			@oG.AddNode(_cId_)
		ok
		@oG.SetNodeProperty(_cId_, "kind", pcKind)
		@oG.SetNodeProperty(_cId_, "capabilities", pacCaps)
		@oG.SetNodeProperty(_cId_, "taint", pcTaint)
		This._Seal(_cId_, pcKind, pacCaps)

	def _Seal(pcId, pcKind, pacCaps)
		_aCaps_ = []
		if isList(pacCaps)
			_n_ = len(pacCaps)
			for _i_ = 1 to _n_
				_aCaps_ + StzLower("" + pacCaps[_i_])
			next
		ok
		_i_ = This._SealIndex(pcId)
		if _i_ > 0
			@aSealed[_i_][2] = StzLower("" + pcKind)
			@aSealed[_i_][3] = _aCaps_
		else
			@aSealed + [ pcId, StzLower("" + pcKind), _aCaps_ ]
		ok

	def _SealIndex(pcId)
		_n_ = len(@aSealed)
		for _i_ = 1 to _n_
			if @aSealed[_i_][1] = pcId  return _i_  ok
		next
		return 0

	# the kind the governed door recorded ("" when the node never passed one)
	def _SealedKind(pcId)
		_i_ = This._SealIndex(pcId)
		if _i_ = 0  return ""  ok
		return @aSealed[_i_][2]

	# Returns the nodes whose graph properties no longer match what the governed doors recorded.
	#
	#   returns    a list of rows, each a list of the node, what changed (kind, capability or node),
	#              the recorded value and the value found; an empty list when untouched
	#   note       a kind flipped or a capability added through GraphQ shows here and makes IsSound
	#              answer FALSE
	#   see        GraphQ, IsSound
	#@ aka  Nodes whose graph properties no longer match the sealed record: a kind changed, or a capability present that no governed door granted. [ [ node, what, recorded, found ], ... ]
	def Tampering()
		_aOut_ = []
		_n_ = len(@aSealed)
		for _i_ = 1 to _n_
			_cId_ = @aSealed[_i_][1]
			if NOT @oG.NodeExists(_cId_)
				_aOut_ + [ _cId_, "node", "present", "removed" ]
				loop
			ok
			_cKind_ = StzLower("" + @oG.NodeProperty(_cId_, "kind"))
			if _cKind_ != @aSealed[_i_][2]
				_aOut_ + [ _cId_, "kind", @aSealed[_i_][2], _cKind_ ]
			ok
			_aCaps_ = @oG.NodeProperty(_cId_, "capabilities")
			if isList(_aCaps_)
				_nC_ = len(_aCaps_)
				for _j_ = 1 to _nC_
					if ring_find(@aSealed[_i_][3], StzLower("" + _aCaps_[_j_])) = 0
						_aOut_ + [ _cId_, "capability", "(not granted)", StzLower("" + _aCaps_[_j_]) ]
					ok
				next
			ok
		next
		return _aOut_

	def _TamperFindings(pcShape)
		_aT_ = This.Tampering()
		_aOut_ = []
		_n_ = len(_aT_)
		for _i_ = 1 to _n_
			_cMsg_ = "'" + _aT_[_i_][1] + "': " + _aT_[_i_][2] + " is '" + _aT_[_i_][4] +
				"' but the governed door recorded '" + _aT_[_i_][3] + "' -- set around the gate"
			if pcShape = "rule"
				_aOut_ + [ :rule = "governed-property-tampered", :subject = _aT_[_i_][1],
					:where = _aT_[_i_][1], :severity = :error, :message = _cMsg_ ]
			else
				_aOut_ + [ :invariant = "governed-property-tampered", :node = _aT_[_i_][1],
					:severity = :error, :message = _cMsg_ ]
			ok
		next
		return _aOut_

	# Draws a proposes edge, from an actor to the node it submits its output to.
	#
	#   pcFrom     the id of the proposing node
	#   pcTo       the id of the node it proposes to
	#   returns    the graph itself, so calls chain
	#   note       ids are trimmed and lower-cased
	#   warning    raises an error when either node was not added first, and does nothing when the
	#              edge already exists
	#   see        Guards, Feeds
	#@ aka  -- edges (the meaning is the label) -------------------------------------
	def Proposes(pcFrom, pcTo)
		This._Edge(pcFrom, pcTo, "proposes")
		return This

	# Draws a guards edge, from a guardian to the effect it stands in front of.
	#
	#   pcGuardian   the id of the guardian
	#   pcEffect     the id of the effect it guards
	#   returns      the graph itself, so calls chain
	#   warning      raises an error when either node was not added first
	#   see          Proposes, Traces
	def Guards(pcGuardian, pcEffect)
		This._Edge(pcGuardian, pcEffect, "guards")
		return This

	# Draws a feeds edge, from a node to the node that takes its data.
	#
	#   pcFrom     the id of the node that supplies data
	#   pcTo       the id of the node that consumes it
	#   returns    the graph itself, so calls chain
	#   warning    raises an error when either node was not added first
	#   see        Proposes, AddInput
	def Feeds(pcFrom, pcTo)
		This._Edge(pcFrom, pcTo, "feeds")
		return This

	# Draws a traces edge, from an effect to the sink that keeps its record.
	#
	#   pcEffect   the id of the effect
	#   pcSink     the id of the trace sink
	#   returns    the graph itself, so calls chain
	#   warning    raises an error when either node was not added first
	#   see        Guards, AddTraceSink
	def Traces(pcEffect, pcSink)
		This._Edge(pcEffect, pcSink, "traces")
		return This

	# Draws an escalates edge, from a node to the human checkpoint that takes over when it cannot decide.
	#
	#   pcFrom         the id of the node that escalates
	#   pcCheckpoint   the id of the human checkpoint
	#   returns        the graph itself, so calls chain
	#   warning        raises an error when either node was not added first
	#   see            Proposes, AddCheckpoint
	def Escalates(pcFrom, pcCheckpoint)
		This._Edge(pcFrom, pcCheckpoint, "escalates")
		return This

	def _Edge(pcFrom, pcTo, pcLabel)
		_cF_ = StzLower(ring_trim("" + pcFrom))
		_cT_ = StzLower(ring_trim("" + pcTo))
		if NOT @oG.EdgeExists(_cF_, _cT_)
			@oG.AddEdgeXTT(_cF_, _cT_, pcLabel, [ :type = "govern" ])
		ok

	# TRUE if granting a capability to an actor would keep the graph sound, which is FALSE for effectful on an llm actor and for an unknown actor.
	#
	#   pcActor    the id of the actor, trimmed and lower-cased
	#   pcCap      the capability, such as effectful
	#   returns    TRUE or FALSE
	#   note       it reads the sealed kind, so a kind flipped through GraphQ does not open the gate
	#   see        Grant
	#@ aka  -- the CONSTRAINT: no-llm-effectful, refused at construction ------------
	def MayGrant(pcActor, pcCap)
		_cA_ = StzLower(ring_trim("" + pcActor))
		if NOT @oG.NodeExists(_cA_)
			return 0
		ok
		# the SEALED kind decides: a raw kind flip must not open the gate
		if This._SealedKind(_cA_) = "llm_actor" and
		   StzLower(ring_trim("" + pcCap)) = "effectful"
			return 0
		ok
		return 1

	# Adds a capability to an actor through the governed door.
	#
	#   pcActor    the id of the actor
	#   pcCap      the capability to add, such as compute
	#   returns    nothing; use GrantQ to chain
	#   note       granting a capability already held changes nothing
	#   warning    raises an error for an actor that is not in the composition, and a refusal naming
	#              the rule for effectful on an llm actor; a hybrid actor may be granted effectful
	#   see        MayGrant, Tampering
	def Grant(pcActor, pcCap)
		This.GrantQ(pcActor, pcCap)

	def GrantQ(pcActor, pcCap)
		_cA_ = StzLower(ring_trim("" + pcActor))
		_cCap_ = StzLower(ring_trim("" + pcCap))
		if NOT @oG.NodeExists(_cA_)
			stzraise("stzAgentGraph.Grant: no actor '" + pcActor + "' in the composition.")
		ok
		if This._SealedKind(_cA_) = "llm_actor" and _cCap_ = "effectful"
			stzraise("REFUSED: granting 'effectful' to llm actor '" + _cA_ +
			         "' -- an LLM proposes, only a pi-gate commits (no-llm-effectful, " +
			         "enforced at CONSTRUCTION, not merely audited).")
		ok
		_aCaps_ = @oG.NodeProperty(_cA_, "capabilities")
		if NOT isList(_aCaps_)
			_aCaps_ = []
		ok
		if ring_find(_aCaps_, _cCap_) = 0
			_aCaps_ + _cCap_
			@oG.SetNodeProperty(_cA_, "capabilities", _aCaps_)
		ok
		_iS_ = This._SealIndex(_cA_)
		if _iS_ > 0 and ring_find(@aSealed[_iS_][3], _cCap_) = 0
			@aSealed[_iS_][3] + _cCap_
		ok
		return This

	# Returns every broken invariant of the composition, as a list of findings, empty when the composition is sound.
	#
	#   returns    a list of hash lists with the keys invariant, node, severity and message
	#   note       the invariants are no-llm-effectful, effects-guarded, open-text-contained,
	#              external-data-contained and effects-traced, plus governed-property-tampered for a
	#              node edited around the gate
	#   see        IsSound, Explain, ViolationsViaRules
	#@ aka  -- the proof (the three gates + four invariants, via meta/) --------------
	def Violations()
		_aF_ = StzCheckAgentGraph(@oG)
		_aT_ = This._TamperFindings("invariant")
		_n_ = len(_aT_)
		for _i_ = 1 to _n_  _aF_ + _aT_[_i_]  next
		return _aF_

	# The uniform graph-owned verb: this graph checks ITSELF against its
	# guardrails, in the unified finding shape (so an stzRuleReport can Collect
	# it exactly like any other graph). Same findings as the object rule set.
	def CheckRules()
		return This.ViolationsViaRules()

	# TRUE if the rule-set check finds no violation.
	#
	#   returns    TRUE or FALSE
	#   see        ViolationsViaRules, IsSound
	def RulesAreSound()
		return len(This.ViolationsViaRules()) = 0

	# Returns a new agent rule set, to which a project can add its own invariants.
	#
	#   returns    a stzAgentRuleSet holding the six built-in rules
	#   note       the set is not bound to this graph: call its Check with the graph
	#   see        ViolationsViaRules
	#@ aka  The invariants as a declared stzAgentRuleSet (graph-rules plan, phase 4) -- the SAME four findings as Violations(), plus the stronger effects-dominated rule. Object-based, so a project can add its own agent invariants.
	def RuleSetQ()
		return StzAgentRuleSetQ()

	# Returns the broken rules in the unified finding shape, so one report can collect them with any other graph.
	#
	#   returns    a list of hash lists with the keys rule, subject, where, severity and message
	#   note       it also reports the effects-dominated rule and tampering; a tampering finding
	#              names the node in subject, the others name agentic
	#   see        Violations, RulesAreSound
	def ViolationsViaRules()
		_aF_ = StzAgentRuleSetQ().Check(@oG)
		_aT_ = This._TamperFindings("rule")
		_n_ = len(_aT_)
		for _i_ = 1 to _n_  _aF_ + _aT_[_i_]  next
		return _aF_

	# TRUE if the composition breaks no invariant and no node was edited around the governed doors.
	#
	#   returns    TRUE or FALSE
	#   note       it answers FALSE for an effect with no guardian or no trace, for an llm actor
	#              that reaches an effect unguarded, and after Tampering finds a change
	#   see        Violations, Tampering, Explain
	def IsSound()
		return StzAgentGraphIsSound(@oG) and len(This.Tampering()) = 0

	# Returns a readable verdict: one sentence when governed, or the list of violations when refused.
	#
	#   returns    a text
	#   see        Violations, IsSound
	#@ aka  a readable verdict for the composition
	def Explain()
		_aV_ = This.Violations()
		if len(_aV_) = 0
			return "GOVERNED: '" + @cName +
				"' passes every invariant (no llm-effectful, effects guarded, open text contained, effects traced)."
		ok
		_c_ = "REFUSED: '" + @cName + "' has " + len(_aV_) + " violation(s):" + char(10)
		_n_ = len(_aV_)
		for _i_ = 1 to _n_
			_c_ += "  - " + _aV_[_i_][:invariant] + " @ " + _aV_[_i_][:node] +
				": " + _aV_[_i_][:message] + char(10)
		next
		return _c_
