#=============================================================#
#  STZAGENTRULE / STZAGENTRULESET -- guardrails ARE graph rules #
#=============================================================#

/*--- The agent guardrails, as declared rules (graph-rules plan, phase 4)

The four governance invariants in meta/stzGovernanceChecks.ring
(no-llm-effectful, effects-guarded, open-text-contained, effects-traced) are
hand-written walks over an agent graph's nodes and edges. They are, literally,
graph rules written out by hand for want of a class. This redeclares them as an
stzAgentRuleSet (stzAgentRule IS-A stzGraphRule), so:

  - a project can add its OWN agent invariants without editing library code;
  - the set reproduces StzCheckAgentGraph exactly (same node, same rule);
  - and it adds the strengthening the library's own comment asked for --
    effects-dominated: not just "some guardian has a direct edge into the
    effect" (the direct-guard form), but "EVERY path from an input to the
    effect passes through a guardian" (the dominator form).

no-llm-effectful is a node-property CLAUSE (When kind=llm_actor AND capabilities
contains effectful -- the shape phase 1 proved). The edge/path invariants are
CHECKERS (the agent graph keeps edges/paths, not node-property clauses). The
CONSTRAINT form of no-llm-effectful -- refuse the grant at construction -- lives
on stzAgentGraph.Grant() (audit -> gate).
*/

func StzAgentRuleQ(pcName)
	return new stzAgentRule(pcName)

func StzAgentRuleSetQ()
	return new stzAgentRuleSet()

# TRUE when a path (a list of node ids) has a guardian at an INTERIOR position
# (matching the governance-check convention: endpoints do not count). Defined
# BEFORE the classes so the checker closures can resolve it.
func _StzPathHasGuardian(oGraph, paPath)
	_nN_ = len(paPath)
	for _k_ = 2 to _nN_ - 1
		if StzLower("" + oGraph.NodeProperty(paPath[_k_], "kind")) = "guardian"
			return TRUE
		ok
	next
	return FALSE

class stzAgentRule from stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("agentic")


class stzAgentRuleSet from stzGraphRuleSet
	def init()
		super.init("agent-guardrails")
		This.SetDomainQ("agentic")
		This._LoadAgentRules()

	def _LoadAgentRules()
		# 1. no-llm-effectful -- a node-property clause (creativity never commits)
		_oR1_ = new stzAgentRule("no-llm-effectful")
		_oR1_.SetSeverityQ("error")
		_oR1_.SetMessageQ("an llm actor must not hold the effectful capability")
		_oR1_.WhenQ("kind", "equals", "llm_actor")
		_oR1_.WhenQ("capabilities", "contains", "effectful")
		_oR1_.ThenViolationQ("llm actor holds 'effectful' -- an LLM proposes, only a pi-gate commits")
		This.AddRule(_oR1_)

		# 2. effects-guarded -- every effect has a guardian edge INTO it
		#    (the direct-guard form, reproducing StzCheckEffectsGuarded)
		_oR2_ = new stzAgentRule("effects-guarded")
		_oR2_.SetSeverityQ("error")
		_oR2_.SetMessageQ("every effect passes a pi-gate")
		_oR2_.UseCheckerQ(func oGraph {
			_aOut_ = []
			_aIds_ = oGraph.NodesIds()
			_aEdges_ = oGraph.Edges()
			_n_ = len(_aIds_)
			for _i_ = 1 to _n_
				if StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "kind")) = "effect"
					_bGuarded_ = 0
					_nE_ = len(_aEdges_)
					for _j_ = 1 to _nE_
						if _aEdges_[_j_][:to] = _aIds_[_i_]
							if StzLower("" + oGraph.NodeProperty(_aEdges_[_j_][:from], "kind")) = "guardian"
								_bGuarded_ = 1
								exit
							ok
						ok
					next
					if _bGuarded_ = 0
						_aOut_ + [ :where = _aIds_[_i_],
							:message = "effect '" + _aIds_[_i_] + "' has no guardian edge into it -- every effect passes a pi-gate" ]
					ok
				ok
			next
			return _aOut_
		})
		This.AddRule(_oR2_)

		# 3. open-text-contained -- open llm text reaches an effect only through a
		#    guardian (reproducing StzCheckOpenTextContained)
		_oR3_ = new stzAgentRule("open-text-contained")
		_oR3_.SetSeverityQ("error")
		_oR3_.SetMessageQ("open llm text reaches an effect only through a guardian")
		_oR3_.UseCheckerQ(func oGraph {
			_aOut_ = []
			_aIds_ = oGraph.NodesIds()
			_n_ = len(_aIds_)
			for _i_ = 1 to _n_
				if StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "taint")) = "open_llm_text"
					for _j_ = 1 to _n_
						if StzLower("" + oGraph.NodeProperty(_aIds_[_j_], "kind")) = "effect"
							_acPaths_ = oGraph.PathsXT(_aIds_[_i_], _aIds_[_j_])
							_nP_ = len(_acPaths_)
							for _p_ = 1 to _nP_
								if NOT _StzPathHasGuardian(oGraph, _acPaths_[_p_])
									_aOut_ + [ :where = _aIds_[_i_],
										:message = "open llm text '" + _aIds_[_i_] + "' reaches effect '" +
										_aIds_[_j_] + "' with no guardian on the path -- injection has somewhere to land" ]
									exit
								ok
							next
						ok
					next
				ok
			next
			return _aOut_
		})
		This.AddRule(_oR3_)

		# 4. effects-traced -- every effect has an edge to a trace_sink
		#    (reproducing StzCheckEffectsTraced)
		_oR4_ = new stzAgentRule("effects-traced")
		_oR4_.SetSeverityQ("error")
		_oR4_.SetMessageQ("every effect leaves an audit witness")
		_oR4_.UseCheckerQ(func oGraph {
			_aOut_ = []
			_aIds_ = oGraph.NodesIds()
			_aEdges_ = oGraph.Edges()
			_n_ = len(_aIds_)
			for _i_ = 1 to _n_
				if StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "kind")) = "effect"
					_bTraced_ = 0
					_nE_ = len(_aEdges_)
					for _j_ = 1 to _nE_
						if _aEdges_[_j_][:from] = _aIds_[_i_]
							if StzLower("" + oGraph.NodeProperty(_aEdges_[_j_][:to], "kind")) = "trace_sink"
								_bTraced_ = 1
								exit
							ok
						ok
					next
					if _bTraced_ = 0
						_aOut_ + [ :where = _aIds_[_i_],
							:message = "effect '" + _aIds_[_i_] + "' reaches no trace sink -- every effect leaves an audit witness" ]
					ok
				ok
			next
			return _aOut_
		})
		This.AddRule(_oR4_)

		# 5. effects-dominated (NEW, the strengthening) -- EVERY path from an
		#    input to an effect passes through a guardian. Stronger than the
		#    direct-guard form: a guardian edge into the effect does not help if
		#    another path from an input bypasses it.
		_oR5_ = new stzAgentRule("effects-dominated")
		_oR5_.SetSeverityQ("error")
		_oR5_.SetMessageQ("every path from an input to an effect passes a guardian")
		_oR5_.UseCheckerQ(func oGraph {
			_aOut_ = []
			_aIds_ = oGraph.NodesIds()
			_n_ = len(_aIds_)
			for _i_ = 1 to _n_
				if StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "kind")) = "effect"
					for _j_ = 1 to _n_
						if StzLower("" + oGraph.NodeProperty(_aIds_[_j_], "kind")) = "input"
							_acPaths_ = oGraph.PathsXT(_aIds_[_j_], _aIds_[_i_])
							_nP_ = len(_acPaths_)
							_bBypass_ = 0
							for _p_ = 1 to _nP_
								if NOT _StzPathHasGuardian(oGraph, _acPaths_[_p_])
									_bBypass_ = 1
									exit
								ok
							next
							if _bBypass_ = 1
								_aOut_ + [ :where = _aIds_[_i_],
									:message = "effect '" + _aIds_[_i_] + "' is reachable from input '" +
									_aIds_[_j_] + "' on a path with no guardian -- the effect is not dominated by a pi-gate" ]
							ok
						ok
					next
				ok
			next
			return _aOut_
		})
		This.AddRule(_oR5_)
