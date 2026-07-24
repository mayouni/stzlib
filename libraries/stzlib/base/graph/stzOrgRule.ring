#================================================================#
#  STZORGRULE / STZORGRULESET -- org governance over the projection #
#================================================================#

/*--- Compliance rules over an org chart's graph (graph-rules plan, phase 2b)

Phase 2 unified stzOrgChart's SOX/GDPR/... compliance stubs as rule sets but
left them EMPTY, because an stzOrgChart is a POSITIONS model, not a graph. Phase
2b gives it a projection (stzOrgChart.AsRuleGraph -- positions to nodes,
reportsTo to "supervises" edges, level/department/roles to node properties) and
these rules over it.

TWO honest tiers:

  UNIVERSAL org-integrity (every compliance base carries these -- broken
  reporting is a problem under any regime):
    no-self-report       -- a position that reports to itself
    no-cyclic-reporting  -- a reporting cycle (A -> B -> A)
    no-orphan-position   -- a non-executive position with no supervisor
    span-of-control      -- a supervisor with too many direct reports

  ONE regime exemplar, clearly illustrative (SOX):
    separation-of-duties -- a position holding conflicting roles (approver AND
                            executor -- the classic maker/checker control).

Faithful per-regime coverage (GDPR data-owner rules, HIPAA access rules, ...) is
DOMAIN-SPECIFICATION work, not fabricated here. The mechanism is real and the
SOX exemplar shows the shape; the other bases carry the universal tier and are
ready for their specifics.
*/

func StzOrgRuleQ(pcName)
	return new stzOrgRule(pcName)

func StzOrgRuleSetQ()
	return new stzOrgRuleSet()

# Add the universal org-integrity rules to any rule set (so every compliance
# base -- stzRuleBase and its subclasses -- carries them).
func _StzAddUniversalOrgRules(poSet)
	# no-self-report (error) -- reportsTo points at the position's own id.
	_oSelf_ = new stzOrgRule("no-self-report")
	_oSelf_.SetSeverityQ("error")
	_oSelf_.SetMessageQ("a position must not report to itself")
	_oSelf_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_aIds_ = oGraph.NodesIds()
		_n_ = len(_aIds_)
		for _i_ = 1 to _n_
			if StzLower("" + oGraph.NodeProperty(_aIds_[_i_], "reportsTo")) = StzLower("" + _aIds_[_i_])
				_aOut_ + [ :where = _aIds_[_i_], :message = "position '" + _aIds_[_i_] + "' reports to itself" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_oSelf_)

	# no-cyclic-reporting (error) -- a MULTI-node reporting cycle (self-loops are
	# the rule above). A position that can reach itself through supervises edges.
	_oCyc_ = new stzOrgRule("no-cyclic-reporting")
	_oCyc_.SetSeverityQ("error")
	_oCyc_.SetMessageQ("the reporting structure must be acyclic")
	_oCyc_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_aIds_ = oGraph.NodesIds()
		_n_ = len(_aIds_)
		for _i_ = 1 to _n_
			_id_ = _aIds_[_i_]
			if StzLower("" + oGraph.NodeProperty(_id_, "reportsTo")) = StzLower("" + _id_)
				loop     # a self-loop -- no-self-report owns it
			ok
			# a cycle of length >= 1: some direct report can reach _id_ again.
			# (PathExists(A,A) is reflexively true, so check via successors.)
			_aRep_ = oGraph.Neighbors(_id_)
			_nR_ = len(_aRep_)
			for _k_ = 1 to _nR_
				if oGraph.PathExists(_aRep_[_k_], _id_)
					_aOut_ + [ :where = _id_, :message = "position '" + _id_ + "' is in a reporting cycle" ]
					exit
				ok
			next
		next
		return _aOut_
	})
	poSet.AddRule(_oCyc_)

	# no-orphan-position (warning) -- a non-executive position with no supervisor
	# (no incoming supervises edge). An executive/root legitimately has none.
	_oOrph_ = new stzOrgRule("no-orphan-position")
	_oOrph_.SetSeverityQ("warning")
	_oOrph_.SetMessageQ("a non-executive position must have a supervisor")
	_oOrph_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_aIds_ = oGraph.NodesIds()
		_n_ = len(_aIds_)
		for _i_ = 1 to _n_
			_id_ = _aIds_[_i_]
			if StzLower("" + oGraph.NodeProperty(_id_, "level")) != "executive"
				if oGraph.InDegree(_id_) = 0
					_aOut_ + [ :where = _id_, :message = "position '" + _id_ +
						"' has no supervisor -- a broken reporting line" ]
				ok
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_oOrph_)

	# span-of-control (warning) -- a supervisor with more than 8 direct reports.
	_oSpan_ = new stzOrgRule("span-of-control")
	_oSpan_.SetSeverityQ("warning")
	_oSpan_.SetMessageQ("a supervisor should not have an excessive span of control")
	_oSpan_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_aIds_ = oGraph.NodesIds()
		_n_ = len(_aIds_)
		for _i_ = 1 to _n_
			_id_ = _aIds_[_i_]
			_nRep_ = oGraph.OutDegree(_id_)
			if _nRep_ > 8
				_aOut_ + [ :where = _id_, :message = "position '" + _id_ + "' has " + _nRep_ +
					" direct reports (> 8) -- excessive span of control" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_oSpan_)
	return poSet

# Add the SOX separation-of-duties exemplar: a position holding two conflicting
# roles (approver AND executor -- maker/checker). Illustrative, not certified.
func StzAddSODRule(poSet)
	_oSOD_ = new stzOrgRule("separation-of-duties")
	_oSOD_.SetSeverityQ("error")
	_oSOD_.SetMessageQ("a position must not hold conflicting duties (approver AND executor)")
	_oSOD_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_aIds_ = oGraph.NodesIds()
		_n_ = len(_aIds_)
		for _i_ = 1 to _n_
			_id_ = _aIds_[_i_]
			_roles_ = oGraph.NodeProperty(_id_, "roles")
			if _StzRolesConflict(_roles_)
				_aOut_ + [ :where = _id_, :message = "position '" + _id_ +
					"' holds both approver and executor roles -- separation-of-duties violation" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_oSOD_)
	return poSet

# TRUE when a roles list holds BOTH an approver-like and an executor-like role.
func _StzRolesConflict(paRoles)
	if NOT isList(paRoles)
		return FALSE
	ok
	_bApprove_ = FALSE
	_bExecute_ = FALSE
	_n_ = len(paRoles)
	for _i_ = 1 to _n_
		_r_ = StzLower("" + paRoles[_i_])
		if StzFindFirst("approv", _r_) > 0  _bApprove_ = TRUE  ok
		if StzFindFirst("execut", _r_) > 0  _bExecute_ = TRUE  ok
	next
	return _bApprove_ and _bExecute_


class stzOrgRule from stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("orgchart")


# The universal org-integrity set, standalone (stzOrgChart.GovernanceFindings
# uses it). The compliance bases in stzOrgChart.ring carry the same universal
# tier via _StzAddUniversalOrgRules.
class stzOrgRuleSet from stzGraphRuleSet
	def init()
		super.init("org-governance")
		This.SetDomainQ("orgchart")
		_StzAddUniversalOrgRules(This)
