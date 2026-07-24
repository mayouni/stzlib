#==================================================================#
#  STZSECURITYRULE / STZSECURITYRULESET -- security rules over a graph #
#==================================================================#

/*--- Security invariants that see PATHS, not just flags (graph-rules plan, P5)

stzSecurityPosture checks one node at a time. These rules run over an explicit
stzSecurityGraph and see the whole surface, so they catch what a flag check
cannot:

  - sandboxed-reaches-effectful -- THE headline. A sandboxed actor that can REACH
    the effectful capability by ANY path (through a tool it uses, or an actor it
    delegates to), even though it holds NO effectful capability itself. The
    posture check's no-sandboxed-effectful only sees the direct case; this sees
    the escalation.
  - sandboxed-holds-secret -- a sandboxed actor attached to a live secret (the
    audit form of stzSecurityGraph.AttachSecret's construction-time gate).
  - unstored-secret -- a secret a site references but that lives in no store, so
    its reveals are uncaudited (the graph form of the posture's inline-key).

stzSecurityRule IS-A stzGraphRule; the set IS-A stzGraphRuleSet.
*/

func StzSecurityRuleQ(pcName)
	return new stzSecurityRule(pcName)

func StzSecurityRuleSetQ()
	return new stzSecurityRuleSet()

class stzSecurityRule from stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("security")


class stzSecurityRuleSet from stzGraphRuleSet
	def init()
		super.init("security-invariants")
		This.SetDomainQ("security")
		This._LoadSecurityRules()

	def _LoadSecurityRules()
		# 1. sandboxed-reaches-effectful -- the multi-hop escalation. For each
		#    sandboxed actor, is the effectful capability node reachable by any
		#    path? (PathExists follows uses/grants/delegates/holds edges.)
		_oR1_ = new stzSecurityRule("sandboxed-reaches-effectful")
		_oR1_.SetSeverityQ("error")
		_oR1_.SetMessageQ("a sandboxed actor must not be able to reach the effectful capability")
		_oR1_.UseCheckerQ(func oGraph {
			_aOut_ = []
			_aIds_ = oGraph.NodesIds()
			_n_ = len(_aIds_)
			# locate the effectful capability node (if any)
			_cEff_ = ""
			for _i_ = 1 to _n_
				if StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "kind")) = "capability" and
				   StzLower("" + _aIds_[_i_]) = "effectful"
					_cEff_ = _aIds_[_i_]
					exit
				ok
			next
			if _cEff_ = ""
				return _aOut_
			ok
			for _i_ = 1 to _n_
				if StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "kind")) = "actor" and
				   StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "posture")) = "sandboxed"
					if oGraph.PathExists(_aIds_[_i_], _cEff_)
						_aOut_ + [ :where = _aIds_[_i_],
							:message = "sandboxed actor '" + _aIds_[_i_] +
							"' can REACH the effectful capability by some path -- privilege escalation" ]
					ok
				ok
			next
			return _aOut_
		})
		This.AddRule(_oR1_)

		# 2. sandboxed-holds-secret -- a sandboxed actor with an 'attaches' edge
		#    to a secret. The audit form of AttachSecret's gate.
		_oR2_ = new stzSecurityRule("sandboxed-holds-secret")
		_oR2_.SetSeverityQ("error")
		_oR2_.SetMessageQ("a sandboxed actor must not hold a live secret")
		_oR2_.UseCheckerQ(func oGraph {
			_aOut_ = []
			_aIds_ = oGraph.NodesIds()
			_aEdges_ = oGraph.Edges()
			_n_ = len(_aIds_)
			for _i_ = 1 to _n_
				if StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "kind")) = "actor" and
				   StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "posture")) = "sandboxed"
					_nE_ = len(_aEdges_)
					for _j_ = 1 to _nE_
						if _aEdges_[_j_][:from] = _aIds_[_i_] and
						   StzLower("" + oGraph.NodeProperty(_aEdges_[_j_][:to], "kind")) = "secret"
							_aOut_ + [ :where = _aIds_[_i_],
								:message = "sandboxed actor '" + _aIds_[_i_] + "' holds secret '" +
								_aEdges_[_j_][:to] + "' -- a sandboxed actor could exfiltrate it" ]
							exit
						ok
					next
				ok
			next
			return _aOut_
		})
		This.AddRule(_oR2_)

		# 3. unstored-secret -- a secret a site references but that is in no store
		#    (the graph form of the posture's inline-key warning).
		_oR3_ = new stzSecurityRule("unstored-secret")
		_oR3_.SetSeverityQ("warning")
		_oR3_.SetMessageQ("a referenced secret should live in a central store")
		_oR3_.UseCheckerQ(func oGraph {
			_aOut_ = []
			_aIds_ = oGraph.NodesIds()
			_aEdges_ = oGraph.Edges()
			_n_ = len(_aIds_)
			for _i_ = 1 to _n_
				if StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "kind")) = "secret"
					# referenced by any site?
					_bReferenced_ = 0
					_bStored_ = 0
					_nE_ = len(_aEdges_)
					for _j_ = 1 to _nE_
						if _aEdges_[_j_][:to] = _aIds_[_i_] and
						   StzLower("" + oGraph.NodeProperty(_aEdges_[_j_][:from], "kind")) = "site"
							_bReferenced_ = 1
						ok
						if _aEdges_[_j_][:from] = _aIds_[_i_] and
						   StzLower("" + oGraph.NodeProperty(_aEdges_[_j_][:to], "kind")) = "store"
							_bStored_ = 1
						ok
					next
					if _bReferenced_ = 1 and _bStored_ = 0
						_aOut_ + [ :where = _aIds_[_i_],
							:message = "secret '" + _aIds_[_i_] + "' is referenced by a site but lives in no store -- " +
							"its reveals are not centrally audited" ]
					ok
				ok
			next
			return _aOut_
		})
		This.AddRule(_oR3_)
