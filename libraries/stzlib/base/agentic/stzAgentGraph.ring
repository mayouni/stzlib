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

class stzAgentGraph from stzObject

	@cName = ""
	@oG = NULL

	def init(pcName)
		@cName = "" + pcName
		@oG = new stzGraph("agentgraph-" + pcName)

	def GraphQ()
		return @oG

	#-- nodes (the capability lattice + taint colours) ----------------------

	def AddPIActor(pcId)
		This._Node(pcId, "pi_actor", [ "effectful", "compute", "sensing" ], "trusted")

	# an LLM actor's capability set is EMPTY (the 5.7 load-bearing rule)
	# and its output is tainted open_llm_text

		def AddPIActorQ(pcId)
			This.AddPIActor(pcId)
			return This

	def AddLLMActor(pcId)
		This._Node(pcId, "llm_actor", [ "inference" ], "open_llm_text")

		def AddLLMActorQ(pcId)
			This.AddLLMActor(pcId)
			return This

	def AddHybridActor(pcId)
		This._Node(pcId, "hybrid_actor", [ "inference" ], "open_llm_text")

		def AddHybridActorQ(pcId)
			This.AddHybridActor(pcId)
			return This

	def AddGuardian(pcId)
		This._Node(pcId, "guardian", [ "compute", "sensing" ], "validated")

		def AddGuardianQ(pcId)
			This.AddGuardian(pcId)
			return This

	def AddEffect(pcId)
		This._Node(pcId, "effect", [ "effectful" ], "trusted")

		def AddEffectQ(pcId)
			This.AddEffect(pcId)
			return This

	def AddTool(pcId)
		This._Node(pcId, "tool", [ "compute" ], "trusted")

		def AddToolQ(pcId)
			This.AddTool(pcId)
			return This

	def AddTraceSink(pcId)
		This._Node(pcId, "trace_sink", [ "sensing" ], "trusted")

		def AddTraceSinkQ(pcId)
			This.AddTraceSink(pcId)
			return This

	def AddInput(pcId)
		This._Node(pcId, "input", [], "external_data")

		def AddInputQ(pcId)
			This.AddInput(pcId)
			return This

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

	#-- edges (the meaning is the label) -------------------------------------

	def Proposes(pcFrom, pcTo)
		This._Edge(pcFrom, pcTo, "proposes")
		return This

	def Guards(pcGuardian, pcEffect)
		This._Edge(pcGuardian, pcEffect, "guards")
		return This

	def Feeds(pcFrom, pcTo)
		This._Edge(pcFrom, pcTo, "feeds")
		return This

	def Traces(pcEffect, pcSink)
		This._Edge(pcEffect, pcSink, "traces")
		return This

	def Escalates(pcFrom, pcCheckpoint)
		This._Edge(pcFrom, pcCheckpoint, "escalates")
		return This

	def _Edge(pcFrom, pcTo, pcLabel)
		_cF_ = StzLower(ring_trim("" + pcFrom))
		_cT_ = StzLower(ring_trim("" + pcTo))
		if NOT @oG.EdgeExists(_cF_, _cT_)
			@oG.AddEdgeXTT(_cF_, _cT_, pcLabel, [ :type = "govern" ])
		ok

	#-- the CONSTRAINT: no-llm-effectful, refused at construction ------------
	#
	# Violations() below is the AUDIT -- it catches a bad graph after it is
	# built. Grant() is the GATE: the governed way to add a capability, which
	# REFUSES granting 'effectful' to an llm actor at the moment of expression,
	# so the no-llm-effectful violation can never enter the graph through the
	# sanctioned door. (A raw SetNodeProperty still bypasses it -- the audit
	# stays the backstop -- but the composition API refuses.) This is the
	# guardrail moving from audit to gate.

	# TRUE when granting pcCap to pcActor would keep the graph sound w.r.t.
	# no-llm-effectful (a queryable form of the constraint).
	def MayGrant(pcActor, pcCap)
		_cA_ = StzLower(ring_trim("" + pcActor))
		if NOT @oG.NodeExists(_cA_)
			return FALSE
		ok
		if StzLower("" + @oG.NodeProperty(_cA_, "kind")) = "llm_actor" and
		   StzLower(ring_trim("" + pcCap)) = "effectful"
			return FALSE
		ok
		return TRUE

	def Grant(pcActor, pcCap)
		This.GrantQ(pcActor, pcCap)

	def GrantQ(pcActor, pcCap)
		_cA_ = StzLower(ring_trim("" + pcActor))
		_cCap_ = StzLower(ring_trim("" + pcCap))
		if NOT @oG.NodeExists(_cA_)
			stzraise("stzAgentGraph.Grant: no actor '" + pcActor + "' in the composition.")
		ok
		if StzLower("" + @oG.NodeProperty(_cA_, "kind")) = "llm_actor" and _cCap_ = "effectful"
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
		return This

	#-- the proof (the three gates + four invariants, via meta/) --------------

	def Violations()
		return StzCheckAgentGraph(@oG)

	# The invariants as a declared stzAgentRuleSet (graph-rules plan, phase 4) --
	# the SAME four findings as Violations(), plus the stronger effects-dominated
	# rule. Object-based, so a project can add its own agent invariants.
	def RuleSetQ()
		return StzAgentRuleSetQ()

	def ViolationsViaRules()
		return StzAgentRuleSetQ().Check(@oG)

	def IsSound()
		return StzAgentGraphIsSound(@oG)

	# a readable verdict for the composition
	def Explain()
		_aV_ = This.Violations()
		if len(_aV_) = 0
			return "GOVERNED: '" + @cName +
				"' passes every invariant (no llm-effectful, effects guarded, open text contained, effects traced)."
		ok
		_c_ = "REFUSED: '" + @cName + "' has " + len(_aV_) + " violation(s):" + NL
		_n_ = len(_aV_)
		for _i_ = 1 to _n_
			_c_ += "  - " + _aV_[_i_][:invariant] + " @ " + _aV_[_i_][:node] +
				": " + _aV_[_i_][:message] + NL
		next
		return _c_
