# R2 -- stzGovernanceChecks: THE G2 SEED (5.7)
# Governance predicates as RUNNABLE VALIDATORS over a COLORED stzGraph.
#
# The vocabulary (the G1 seed, agreed in R1): nodes carry properties
#   :kind          pi_actor | llm_actor | hybrid_actor | guardian |
#                  effect | trace_sink | input | checkpoint | tool
#   :capabilities  a list among: effectful, sensing, compute, inference
#   :taint         trusted | open_llm_text | external_data | validated
# Edges carry their meaning as labels (feeds/proposes/guards/commits/
# escalates/traces).
#
# The invariants an agent RUNS before composing (structured findings,
# same shape as stzCodeRules): the honest claim is VALIDATOR-CHECKED
# ADMISSION, not compile-time proof (that stricter form is product
# space -- 5.7 boundary).
#
#   aF = StzCheckAgentGraph(oGraph)     # all invariants
#   ? StzAgentGraphIsSound(oGraph)      # verdict

func StzGovernanceInvariantNames()
	return [ "no-llm-effectful", "effects-guarded",
	         "open-text-contained", "effects-traced" ]

func StzCheckAgentGraph(poGraph)
	_aF_ = []
	_aF2_ = StzCheckNoLLMEffectful(poGraph)
	_n_ = len(_aF2_)
	for _i_ = 1 to _n_
		_aF_ + _aF2_[_i_]
	next
	_aF2_ = StzCheckEffectsGuarded(poGraph)
	_n_ = len(_aF2_)
	for _i_ = 1 to _n_
		_aF_ + _aF2_[_i_]
	next
	_aF2_ = StzCheckOpenTextContained(poGraph)
	_n_ = len(_aF2_)
	for _i_ = 1 to _n_
		_aF_ + _aF2_[_i_]
	next
	_aF2_ = StzCheckEffectsTraced(poGraph)
	_n_ = len(_aF2_)
	for _i_ = 1 to _n_
		_aF_ + _aF2_[_i_]
	next
	return _aF_

func StzAgentGraphIsSound(poGraph)
	return len(StzCheckAgentGraph(poGraph)) = 0

# INVARIANT 1 -- an LLM actor's capability set holds NO 'effectful':
# creativity proposes, it never commits (the 5.7 load-bearing rule).
func StzCheckNoLLMEffectful(poGraph)
	_aF_ = []
	_acIds_ = poGraph.NodesIds()
	_n_ = len(_acIds_)
	for _i_ = 1 to _n_
		if StzLower("" + poGraph.NodeProperty(_acIds_[_i_], "kind")) = "llm_actor"
			_aCaps_ = poGraph.NodeProperty(_acIds_[_i_], "capabilities")
			if isList(_aCaps_) and ring_find(_aCaps_, "effectful") > 0
				_aF_ + [ :invariant = "no-llm-effectful",
					:node = _acIds_[_i_], :severity = :error,
					:message = "llm actor '" + _acIds_[_i_] +
					"' holds the 'effectful' capability -- an LLM proposes, only a pi-gate commits" ]
			ok
		ok
	next
	return _aF_

# INVARIANT 2 -- every effect node is GUARDED: some guardian node has
# an edge into it (the direct-guard form; full dominator analysis is
# the next strengthening).
func StzCheckEffectsGuarded(poGraph)
	_aF_ = []
	_acIds_ = poGraph.NodesIds()
	_n_ = len(_acIds_)
	for _i_ = 1 to _n_
		if StzLower("" + poGraph.NodeProperty(_acIds_[_i_], "kind")) = "effect"
			_bGuarded_ = 0
			_aEdges_ = poGraph.Edges()
			_nE_ = len(_aEdges_)
			for _j_ = 1 to _nE_
				if _aEdges_[_j_][:to] = _acIds_[_i_]
					if StzLower("" + poGraph.NodeProperty(_aEdges_[_j_][:from], "kind")) = "guardian"
						_bGuarded_ = 1
						exit
					ok
				ok
			next
			if _bGuarded_ = 0
				_aF_ + [ :invariant = "effects-guarded",
					:node = _acIds_[_i_], :severity = :error,
					:message = "effect '" + _acIds_[_i_] +
					"' has no guardian edge into it -- every effect passes a pi-gate" ]
			ok
		ok
	next
	return _aF_

# INVARIANT 3 -- open LLM text never REACHES an effect except through
# a guardian: for every open_llm_text node, every path to an effect
# must contain a guardian node (checked over PathsXT).
func StzCheckOpenTextContained(poGraph)
	_aF_ = []
	_acIds_ = poGraph.NodesIds()
	_n_ = len(_acIds_)
	for _i_ = 1 to _n_
		if StzLower("" + poGraph.NodeProperty(_acIds_[_i_], "taint")) = "open_llm_text"
			for _j_ = 1 to _n_
				if StzLower("" + poGraph.NodeProperty(_acIds_[_j_], "kind")) = "effect"
					_acPaths_ = poGraph.PathsXT(_acIds_[_i_], _acIds_[_j_])
					_nP_ = len(_acPaths_)
					for _p_ = 1 to _nP_
						_bThroughGuardian_ = 0
						_acPath_ = _acPaths_[_p_]
						_nN_ = len(_acPath_)
						for _k_ = 2 to _nN_ - 1
							if StzLower("" + poGraph.NodeProperty(_acPath_[_k_], "kind")) = "guardian"
								_bThroughGuardian_ = 1
								exit
							ok
						next
						if _bThroughGuardian_ = 0
							_aF_ + [ :invariant = "open-text-contained",
								:node = _acIds_[_i_], :severity = :error,
								:message = "open llm text '" + _acIds_[_i_] +
								"' reaches effect '" + _acIds_[_j_] +
								"' with no guardian on the path -- injection has somewhere to land" ]
							exit
						ok
					next
				ok
			next
		ok
	next
	return _aF_

# INVARIANT 4 -- every effect leaves a WITNESS: an edge from the effect
# to a trace_sink node (the audit chain, 5.7 G5).
func StzCheckEffectsTraced(poGraph)
	_aF_ = []
	_acIds_ = poGraph.NodesIds()
	_n_ = len(_acIds_)
	for _i_ = 1 to _n_
		if StzLower("" + poGraph.NodeProperty(_acIds_[_i_], "kind")) = "effect"
			_bTraced_ = 0
			_aEdges_ = poGraph.Edges()
			_nE_ = len(_aEdges_)
			for _j_ = 1 to _nE_
				if _aEdges_[_j_][:from] = _acIds_[_i_]
					if StzLower("" + poGraph.NodeProperty(_aEdges_[_j_][:to], "kind")) = "trace_sink"
						_bTraced_ = 1
						exit
					ok
				ok
			next
			if _bTraced_ = 0
				_aF_ + [ :invariant = "effects-traced",
					:node = _acIds_[_i_], :severity = :error,
					:message = "effect '" + _acIds_[_i_] +
					"' reaches no trace sink -- every effect leaves an audit witness" ]
			ok
		ok
	next
	return _aF_
