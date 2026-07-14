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

	def Graph()
		return @oG

	#-- nodes (the capability lattice + taint colours) ----------------------

	def AddPIActor(pcId)
		This._Node(pcId, "pi_actor", [ "effectful", "compute", "sensing" ], "trusted")
		return This

	# an LLM actor's capability set is EMPTY (the 5.7 load-bearing rule)
	# and its output is tainted open_llm_text
	def AddLLMActor(pcId)
		This._Node(pcId, "llm_actor", [ "inference" ], "open_llm_text")
		return This

	def AddHybridActor(pcId)
		This._Node(pcId, "hybrid_actor", [ "inference" ], "open_llm_text")
		return This

	def AddGuardian(pcId)
		This._Node(pcId, "guardian", [ "compute", "sensing" ], "validated")
		return This

	def AddEffect(pcId)
		This._Node(pcId, "effect", [ "effectful" ], "trusted")
		return This

	def AddTool(pcId)
		This._Node(pcId, "tool", [ "compute" ], "trusted")
		return This

	def AddTraceSink(pcId)
		This._Node(pcId, "trace_sink", [ "sensing" ], "trusted")
		return This

	def AddInput(pcId)
		This._Node(pcId, "input", [], "external_data")
		return This

	def AddCheckpoint(pcId)
		This._Node(pcId, "human_checkpoint", [ "sensing" ], "validated")
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

	#-- the proof (the three gates + four invariants, via meta/) --------------

	def Violations()
		return StzCheckAgentGraph(@oG)

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
