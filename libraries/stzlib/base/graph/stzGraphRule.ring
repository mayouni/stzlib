#=============================================#
#  FUNCTION-BASED RULES SYSTEM FOR stzGraph   #
#  Clean three-phase validation architecture  #
#=============================================#

# Three Rule Types:
# 1. Constraint - Guards operations (blocks invalid changes)
# 2. Derivation - Auto-derives edges/nodes after changes
# 3. Validation - Validates final graph state

#------------------#
#  RULE CONTAINER  #
#------------------#

$aGraphRules = [
	:dag = [],
	:semantic = [],
	:structural = [],
	:reachability = [],
	:completeness = []
]

# The .stzrulf files already loaded into this process.
#
# A .stzrulf defines FUNCTIONS, and Ring refuses to define the same function
# twice -- C22, "Function redefinition", which is a COMPILE error that
# try/catch cannot catch and that takes the program down. Two graphs both
# wanting the same custom rules is perfectly reasonable, so the second load
# has to be a quiet no-op rather than a crash. stzGraph.LoadRuleFunctionsFrom()
# keeps this list; the key is the path as spelled, so the same file reached by
# two different spellings would still double-load.

$acStzRulfLoaded = []

#-------------#
#  FUNCTIONS  #
#-------------#

func StzGraphRules()
	return $aGraphRules

	func GraphRules()
		return StzGraphRules()

func StzRegisterRule(pcRuleGroup, pcRuleName, paRuleDefinition)
	if CheckParams()
		if isList(pcRuleGroup) and IsInGroupNamedParamList(pcRuleGroup)
			pcRuleGroup = pcRuleGroup[2]
		ok
	ok

	if NOT HasKey($aGraphRules, pcRuleGroup)
		$aGraphRules[pcRuleGroup] = []
	ok

	_aRule_ = [
		:name = UPPER(pcRuleName),
		:type = paRuleDefinition[:type],
		:function = paRuleDefinition[:function],
		:params = paRuleDefinition[:params],
		:message = paRuleDefinition[:message],
		:severity = paRuleDefinition[:severity]
	]

	$aGraphRules[pcRuleGroup] + _aRule_

	func RegisterRule(pcRuleGroup, pcRuleName, paRuleDefinition)
		StzRegisterRule(pcRuleGroup, pcRuleName, paRuleDefinition)

	func RegisterRuleInGroup(pcRuleGroup, pcRuleName, paRuleDefinition)
		StzRegisterRule(pcRuleGroup, pcRuleName, paRuleDefinition)

func StzGetRule(pcRuleGroup, pcRuleName)
	pcRuleName = UPPER(pcRuleName)
	if HasKey($aGraphRules, pcRuleGroup)
		_aRules_ = $aGraphRules[pcRuleGroup]
		_nLen_ = len(_aRules_)
		for i = 1 to _nLen_
			if _aRules_[i][:name] = pcRuleName
				return _aRules_[i]
			ok
		next
	ok
	stzraise("Inexistant rule!")

	func GetRule(pcRuleGroup, pcRuleName)
		return StzGetRule(pcRuleGroup, pcRuleName)

#-------------------------------------------------#
#  BUILT-IN RULE FUNCTIONS : Derivation  #
#-------------------------------------------------#

func DerivationFunc_Transitivity()
	return func(oGraph, paRuleParams) {
		_aNewEdges_ = []
		_aEdges_ = oGraph.Edges()
		_nLen1_ = len(_aEdges_)
		
		for i = 1 to _nLen1_
			_aEdge1_ = _aEdges_[i]
			_nLen2_ = len(_aEdges_)
			
			for j = 1 to _nLen2_
				_aEdge2_ = _aEdges_[j]
				
				if _aEdge1_[:to] = _aEdge2_[:from]
					_cFrom_ = _aEdge1_[:from]
					_cTo_ = _aEdge2_[:to]
					
					if NOT oGraph.EdgeExists(_cFrom_, _cTo_) and _cFrom_ != _cTo_
						_aNewEdges_ + [_cFrom_, _cTo_, "(transitive)", [:derived = TRUE]]
					ok
				ok
			next
		next
		
		return _aNewEdges_
	}

func DerivationFunc_Symmetry()
	return func(oGraph, paRuleParams) {
		_aNewEdges_ = []
		_aEdges_ = oGraph.Edges()
		_nLen_ = len(_aEdges_)
		
		for i = 1 to _nLen_
			_aEdge_ = _aEdges_[i]
			if NOT oGraph.EdgeExists(_aEdge_[:to], _aEdge_[:from])
				_aNewEdges_ + [_aEdge_[:to], _aEdge_[:from], "(symmetric)", [:derived = TRUE]]
			ok
		next
		
		return _aNewEdges_
	}

func DerivationFunc_Hierarchy()
	return func(oGraph, paRuleParams) {
		_cProp_ = paRuleParams[:property]
		_cOrder_ = paRuleParams[:order]
		
		_aNewEdges_ = []
		_aEdges_ = oGraph.Edges()
		_nLen1_ = len(_aEdges_)
		
		for i = 1 to _nLen1_
			_aEdge1_ = _aEdges_[i]
			_nLen2_ = len(_aEdges_)
			
			for j = 1 to _nLen2_
				_aEdge2_ = _aEdges_[j]
				
				if _aEdge1_[:to] = _aEdge2_[:from]
					_cFrom_ = _aEdge1_[:from]
					_cMid_ = _aEdge1_[:to]
					_cTo_ = _aEdge2_[:to]
					
					if NOT oGraph.EdgeExists(_cFrom_, _cTo_) and _cFrom_ != _cTo_
						pFromVal = oGraph.NodeProperty(_cFrom_, _cProp_)
						pMidVal = oGraph.NodeProperty(_cMid_, _cProp_)
						pToVal = oGraph.NodeProperty(_cTo_, _cProp_)
						
						_bValid_ = FALSE
						if _cOrder_ = :ascending
							_bValid_ = (pFromVal < pMidVal and pMidVal < pToVal)
						but _cOrder_ = :descending
							_bValid_ = (pFromVal > pMidVal and pMidVal > pToVal)
						ok
						
						if _bValid_
							_aNewEdges_ + [_cFrom_, _cTo_, "(hierarchy)", [:derived = TRUE]]
						ok
					ok
				ok
			next
		next
		
		return _aNewEdges_
	}

#-------------------------------------------#
#  BUILT-IN RULE FUNCTIONS : Constraint  #
#-------------------------------------------#

func ConstraintFunc_NoSelfLoop()
	return func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			if paOperationParams[:from] = paOperationParams[:to]
				return [TRUE, "Self-loops not allowed"]
			ok
		ok
		return [FALSE, ""]
	}

func ConstraintFunc_MaxDegree()
	return func(oGraph, paRuleParams, paOperationParams) {
		_nMax_ = paRuleParams[:max]
		
		if HasKey(paOperationParams, :node)
			_cNode_ = paOperationParams[:node]
			if oGraph.NodeExists(_cNode_)
				_nDegree_ = len(oGraph.Neighbors(_cNode_)) + len(oGraph.Incoming(_cNode_))
				if _nDegree_ >= _nMax_
					return [TRUE, "Node exceeds max degree of " + _nMax_]
				ok
			ok
		ok
		return [FALSE, ""]
	}

func ConstraintFunc_NoCycles()
	return func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			_cFrom_ = paOperationParams[:from]
			_cTo_ = paOperationParams[:to]
			
			if oGraph.PathExists(_cTo_, _cFrom_)
				return [TRUE, "Would create a cycle"]
			ok
		ok
		return [FALSE, ""]
	}

func ConstraintFunc_Separation()
	return func(oGraph, paRuleParams, paOperationParams) {
		_cProp_ = paRuleParams[:property]
		_aValues_ = paRuleParams[:values]
		
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			_cFrom_ = paOperationParams[:from]
			_cTo_ = paOperationParams[:to]
			
			if oGraph.NodeExists(_cFrom_) and oGraph.NodeExists(_cTo_)
				pFromVal = oGraph.NodeProperty(_cFrom_, _cProp_)
				pToVal = oGraph.NodeProperty(_cTo_, _cProp_)
				
				_nLen_ = len(_aValues_)
				_bFromRestricted_ = FALSE
				_bToRestricted_ = FALSE
				
				for i = 1 to _nLen_
					if pFromVal = _aValues_[i]
						_bFromRestricted_ = TRUE
					ok
					if pToVal = _aValues_[i]
						_bToRestricted_ = TRUE
					ok
				next
				
				if _bFromRestricted_ and _bToRestricted_
					return [TRUE, "Separation of duties violation"]
				ok
			ok
		ok
		return [FALSE, ""]
	}

func ConstraintFunc_PropertyMismatch()
	return func(oGraph, paRuleParams, paOperationParams) {
		_cProp_ = paRuleParams[:property]
		_cOp_ = paRuleParams[:operator]
		pVal = paRuleParams[:value]
		
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			_cFrom_ = paOperationParams[:from]
			_cTo_ = paOperationParams[:to]
			
			if oGraph.NodeExists(_cFrom_)
				pActual = oGraph.NodeProperty(_cFrom_, _cProp_)
				
				_bMismatch_ = FALSE
				if _cOp_ = "!="
					_bMismatch_ = (pActual = pVal)
				but _cOp_ = "="
					_bMismatch_ = (pActual != pVal)
				but _cOp_ = ">"
					_bMismatch_ = (pActual <= pVal)
				but _cOp_ = "<"
					_bMismatch_ = (pActual >= pVal)
				ok
				
				if _bMismatch_
					return [TRUE, "Property constraint violated"]
				ok
			ok
		ok
		return [FALSE, ""]
	}

#------------------------------------------#
#  BUILT-IN RULE FUNCTIONS : OnValidation  #
#------------------------------------------#

func ValidationFunc_IsAcyclic()
	return func(oGraph, paRuleParams) {
		if oGraph.HasCyclicDependencies()
			return [FALSE, "Graph contains cycles"]
		ok
		return [TRUE, ""]
	}

func ValidationFunc_IsConnected()
	return func(oGraph, paRuleParams) {
		if NOT oGraph.IsConnected()
			return [FALSE, "Graph is not connected"]
		ok
		return [TRUE, ""]
	}

func ValidationFunc_MaxNodes()
	return func(oGraph, paRuleParams) {
		_nMax_ = paRuleParams[:max]
		
		if oGraph.NodeCount() > _nMax_
			return [FALSE, "Exceeds maximum of " + _nMax_ + " nodes"]
		ok
		return [TRUE, ""]
	}

func ValidationFunc_DensityRange()
	return func(oGraph, paRuleParams) {
		_nMin_ = paRuleParams[:min]
		_nMax_ = paRuleParams[:max]
		
		_nDensity_ = oGraph.Density()
		if _nDensity_ < _nMin_ or _nDensity_ > _nMax_
			return [FALSE, "Density " + _nDensity_ + " outside range [" + _nMin_ + "," + _nMax_ + "]"]
		ok
		return [TRUE, ""]
	}

func ValidationFunc_NoBottlenecks()
	return func(oGraph, paRuleParams) {
		_aBottlenecks_ = oGraph.BottleneckNodes()
		if len(_aBottlenecks_) > 0
			return [FALSE, "Bottlenecks found: " + JoinXT(_aBottlenecks_, ", ")]
		ok
		return [TRUE, ""]
	}

func ValidationFunc_AllNodesReachable()
	return func(oGraph, paRuleParams) {
		_cStart_ = paRuleParams[:start]
		
		if NOT oGraph.NodeExists(_cStart_)
			return [FALSE, "Start node does not exist"]
		ok
		
		_aReachable_ = oGraph.ReachableFrom(_cStart_)
		_nTotal_ = oGraph.NodeCount()
		
		if len(_aReachable_) < _nTotal_
			return [FALSE, "Not all nodes reachable from " + _cStart_]
		ok
		return [TRUE, ""]
	}

#=======================#
#  DEFAULT GRAPH RULES  #
#=======================#

# DAG rules
RegisterRule(:dag, "no_cycles_Constraint", [
	:type = :Constraint,
	:function = ConstraintFunc_NoCycles(),
	:params = [],
	:message = "Operation would create a cycle",
	:severity = :error
])

RegisterRule(:dag, "acyclic_state", [
	:type = :Validation,
	:function = ValidationFunc_IsAcyclic(),
	:params = [],
	:message = "Graph must be acyclic",
	:severity = :error
])

# Reachability rules
RegisterRule(:reachability, "all_connected", [
	:type = :Validation,
	:function = ValidationFunc_IsConnected(),
	:params = [],
	:message = "Graph must be fully connected",
	:severity = :warning
])

# Completeness rules
RegisterRule(:completeness, "no_bottlenecks", [
	:type = :Validation,
	:function = ValidationFunc_NoBottlenecks(),
	:params = [],
	:message = "Graph contains bottleneck nodes",
	:severity = :warning
])

#=====================================================#
#  STZGRAPHRULE -- THE OBJECT FACE OF THE RULE ENGINE  #
#=====================================================#

/*--- Rule governance, as a first-class object (graph-rules plan, phase 1)

Everything above is a FUNCTION registry: StzRegisterRule(group, name, def) with
closures that are param-driven (Ring anonymous functions do NOT close over the
enclosing scope -- see the built-ins above, all driven by paRuleParams). That
registry works, but a rule has no IDENTITY: no object to name, inherit from, or
carry per-rule state (domain, severity, message).

stzGraphRule is the OBJECT face over that same registry. You DECLARE a rule
fluently; it COMPILES DOWN to a registered rule function; and the registered
function and the object's own Check() share ONE matcher (StzGraphRuleFindings),
so the two faces can never disagree -- the property phase 1 must earn.

    oRule = new stzGraphRule("no-llm-effectful")
    oRule.SetDomain("agentic").SetSeverityQ("error").
          SetMessageQ("an llm actor must not hold the effectful capability").
          WhenQ("kind", "equals", "llm_actor").
          WhenQ("capabilities", "contains", "effectful").
          ThenViolationQ("llm actor holds effectful -- an LLM proposes, a gate commits")

    ? oRule.Check(oGraph)      # [ [ :rule, :where, :severity, :message ], ... ]
    oRule.Register()           # StzGetRule("agentic","no-llm-effectful") now finds it

WHY THIS IS THE FOUNDATION: it is the parent the plan's stzCodeRule /
stzAgentRule / stzSecurityRule will inherit, and the class stzWorkflow already
constructs (its BPM/SLA rule bases call new stzGraphRule(...) today against a
class that did not exist -- phase 2 repairs them by this very type).

Clauses are ANDed: a node matching EVERY When() clause is a finding. A rule too
rich for property-matching (reachability, dominance -- the code/agent phases)
supplies an explicit checker via UseChecker(); the DSL is the common path.

Scope sigils: attributes @-prefixed, temps _x_-wrapped -- bare class-head
attributes capture same-named user globals in Ring 1.27, and this file defines
the globals $aGraphRules / $acStzRulfLoaded right above.
*/

# The ONE source of truth for "what does this rule find on this graph". BOTH the
# object Check() and the registered closure call it, so they cannot diverge.
# paSpec = [ :name, :subject, :clauses, :violation, :severity, :checker ].
# Returns findings in the UNIFIED shape [ :rule, :subject, :where, :severity,
# :message ] (empty = the rule holds). :subject is the rule's domain, so one
# CI gate can span code / agents / security in a single findings list.
func StzGraphRuleFindings(oGraph, paSpec)
	_aOut_ = []
	_cName_ = paSpec[:name]
	_cSev_  = paSpec[:severity]
	_cViol_ = paSpec[:violation]
	_cSubj_ = ""
	if HasKey(paSpec, :subject)
		_cSubj_ = paSpec[:subject]
	ok

	# escape hatch: an explicit checker owns the whole decision. It gets the
	# graph and returns [ [ :where = id, :message = msg ], ... ] ("" = graph-wide).
	if HasKey(paSpec, :checker) and not isNull(paSpec[:checker])
		_fChk_ = paSpec[:checker]         # call wants a plain var, not a[:k]
		_aRaw_ = call _fChk_(oGraph)
		_nR_ = len(_aRaw_)
		for _i_ = 1 to _nR_
			_r_ = _aRaw_[_i_]
			_where_ = ""
			_msg_ = _cViol_
			if isList(_r_)
				if HasKey(_r_, :where)    _where_ = _r_[:where]    ok
				if HasKey(_r_, :message)  _msg_ = _r_[:message]    ok
			ok
			_aOut_ + [ :rule = _cName_, :subject = _cSubj_, :where = _where_, :severity = _cSev_, :message = _msg_ ]
		next
		return _aOut_
	ok

	# clause DSL: When-clauses select the SCOPE; Then-clauses (requirements) say
	# what must HOLD on a scope node. No requirements => being in scope IS the
	# violation (a PROHIBITION: "no node should match this"). With requirements
	# => a scope node that FAILS any requirement is the violation (an
	# IMPLICATION: "every node matching When must satisfy Then").
	_aClauses_ = paSpec[:clauses]
	_aReq_ = []
	if HasKey(paSpec, :requirements)
		_aReq_ = paSpec[:requirements]
	ok
	if len(_aClauses_) = 0 and len(_aReq_) = 0
		return _aOut_
	ok
	_aIds_ = oGraph.NodesIds()
	_nN_ = len(_aIds_)
	for _i_ = 1 to _nN_
		if NOT _StzGraphRuleNodeMatches(oGraph, _aIds_[_i_], _aClauses_)
			loop
		ok
		if len(_aReq_) = 0
			_aOut_ + [ :rule = _cName_, :subject = _cSubj_, :where = _aIds_[_i_], :severity = _cSev_, :message = _cViol_ ]
		but NOT _StzGraphRuleNodeMatches(oGraph, _aIds_[_i_], _aReq_)
			_aOut_ + [ :rule = _cName_, :subject = _cSubj_, :where = _aIds_[_i_], :severity = _cSev_, :message = _cViol_ ]
		ok
	next
	return _aOut_

# A validation closure for the registry: [ ok, message ]. Param-driven (no
# capture) -- it reads the same paSpec the object stored, so it mirrors Check().
func StzGraphRuleValidationFn()
	return func oGraph, paParams {
		_aF_ = StzGraphRuleFindings(oGraph, paParams)
		if len(_aF_) = 0
			return [ TRUE, "" ]
		ok
		return [ FALSE, "" + paParams[:name] + ": " + len(_aF_) + " finding(s)" ]
	}

func _StzGraphRuleNodeMatches(oGraph, pcId, paClauses)
	_n_ = len(paClauses)
	for _i_ = 1 to _n_
		if NOT _StzGraphRuleClauseHolds(oGraph, pcId, paClauses[_i_])
			return FALSE
		ok
	next
	return TRUE

# aClause = [ prop, op, wantedValue ]. op in equals|not-equals|contains|exists|missing.
func _StzGraphRuleClauseHolds(oGraph, pcId, aClause)
	_prop_ = aClause[1]
	_op_   = aClause[2]
	_want_ = aClause[3]
	_actual_ = oGraph.NodeProperty(pcId, _prop_)   # 0 when unset

	if _op_ = "equals"
		return _StzGraphRuleValEq(_actual_, _want_)
	but _op_ = "not-equals"
		return NOT _StzGraphRuleValEq(_actual_, _want_)
	but _op_ = "contains"
		return isList(_actual_) and ring_find(_actual_, _want_) > 0
	but _op_ = "exists"
		return NOT _StzGraphRuleValEmpty(_actual_)
	but _op_ = "missing"
		return _StzGraphRuleValEmpty(_actual_)
	but _op_ = "greaterthan"
		return _StzGraphRuleValCmp(_actual_, _want_) = 1
	but _op_ = "lessthan"
		return _StzGraphRuleValCmp(_actual_, _want_) = -1
	but _op_ = "greaterequal"
		return _StzGraphRuleValCmp(_actual_, _want_) >= 0
	but _op_ = "lessequal"
		return _StzGraphRuleValCmp(_actual_, _want_) <= 0
	ok
	return FALSE

# -1 / 0 / 1 comparison, for the ordering operators only. Numeric when both are
# numbers (the real case -- node properties like sla=5, duration=10 are stored as
# numbers; an unset property is 0, so "sla greaterthan 0" correctly fails a
# missing sla). Non-numeric operands are NOT orderable here, so they return 0
# (incomparable) rather than letting Ring attempt a numeric coercion that raises
# R41 on a value like "sla". Ordering a string against a string is a rule-design
# error -- use a checker for cross-property comparisons.
func _StzGraphRuleValCmp(pActual, pWant)
	if isNumber(pActual) and isNumber(pWant)
		if pActual < pWant
			return -1
		but pActual > pWant
			return 1
		ok
		return 0
	ok
	return 0

# scalar equality, case/space-insensitive on strings (matches the governance
# idiom StzLower(prop) = "llm_actor"); a list never equals a scalar.
func _StzGraphRuleValEq(pActual, pWant)
	if isList(pActual) or isList(pWant)
		return FALSE
	ok
	return StzLower(ring_trim("" + pActual)) = StzLower(ring_trim("" + pWant))

func _StzGraphRuleValEmpty(pVal)
	if isList(pVal)
		return len(pVal) = 0
	ok
	if isNull(pVal)
		return TRUE
	ok
	return ring_trim("" + pVal) = "" or ("" + pVal) = "0"

# normalize a user-written operator to its canonical token; raise on unknown so
# a typo is caught at declaration, not silently never-matching.
func _StzGraphRuleNormalizeOp(pcOp)
	_o_ = StzLower(ring_trim("" + pcOp))
	if _o_ = "equals" or _o_ = "=" or _o_ = "is"
		return "equals"
	but _o_ = "not-equals" or _o_ = "!=" or _o_ = "isnot"
		return "not-equals"
	but _o_ = "contains" or _o_ = "has" or _o_ = "includes"
		return "contains"
	but _o_ = "exists" or _o_ = "present"
		return "exists"
	but _o_ = "missing" or _o_ = "absent"
		return "missing"
	but _o_ = "greaterthan" or _o_ = ">" or _o_ = "gt"
		return "greaterthan"
	but _o_ = "lessthan" or _o_ = "<" or _o_ = "lt"
		return "lessthan"
	but _o_ = "greaterequal" or _o_ = ">=" or _o_ = "ge"
		return "greaterequal"
	but _o_ = "lessequal" or _o_ = "<=" or _o_ = "le"
		return "lessequal"
	ok
	stzraise("stzGraphRule: unknown operator '" + pcOp + "' (use equals|not-equals|" +
	         "contains|exists|missing|greaterthan|lessthan|greaterequal|lessequal).")

func StzGraphRuleQ(pcName)
	return new stzGraphRule(pcName)

class stzGraphRule from stzObject

	@cName      = ""
	@cType      = "validation"     # validation | constraint | derivation
	@cDomain    = "custom"         # the registry GROUP this rule joins
	@cSeverity  = "error"          # error | warning | info
	@cMessage   = ""               # the rule description
	@cViolation = ""               # the message attached to each finding
	@aClauses     = []             # When: [ [ prop, op, want ], ... ] -- the SCOPE
	@aRequirements = []            # Then: [ [ prop, op, want ], ... ] -- must HOLD
	@fChecker   = NULL             # explicit checker closure (overrides clauses)

	def init(pcName)
		if ring_trim("" + pcName) = ""
			stzraise("stzGraphRule: a rule needs a name.")
		ok
		@cName = "" + pcName

		#-- the fluent DSL (plain does the act; Q chains) -----------------

	def SetRuleType(pcType)
		This.SetRuleTypeQ(pcType)

	def SetRuleTypeQ(pcType)
		_t_ = StzLower(ring_trim("" + pcType))
		if _t_ != "validation" and _t_ != "constraint" and _t_ != "derivation"
			stzraise("stzGraphRule.SetRuleType: must be validation|constraint|derivation, got '" + pcType + "'.")
		ok
		@cType = _t_
		return This

	def SetDomain(pcDomain)
		This.SetDomainQ(pcDomain)

	def SetDomainQ(pcDomain)
		if ring_trim("" + pcDomain) = ""
			stzraise("stzGraphRule.SetDomain: the domain (registry group) cannot be empty.")
		ok
		@cDomain = StzLower(ring_trim("" + pcDomain))
		return This

	def SetSeverity(pcSeverity)
		This.SetSeverityQ(pcSeverity)

	def SetSeverityQ(pcSeverity)
		_s_ = StzLower(ring_trim("" + pcSeverity))
		if _s_ != "error" and _s_ != "warning" and _s_ != "info"
			stzraise("stzGraphRule.SetSeverity: must be error|warning|info, got '" + pcSeverity + "'.")
		ok
		@cSeverity = _s_
		return This

	def SetMessage(pcMsg)
		This.SetMessageQ(pcMsg)

	def SetMessageQ(pcMsg)
		@cMessage = "" + pcMsg
		return This

	# a node-matching clause: property `pcProp` `pcOp` `pValue`. Clauses AND.
	def When(pcProp, pcOp, pValue)
		This.WhenQ(pcProp, pcOp, pValue)

	def WhenQ(pcProp, pcOp, pValue)
		if ring_trim("" + pcProp) = ""
			stzraise("stzGraphRule.When: a clause needs a property name.")
		ok
		@aClauses + [ "" + pcProp, _StzGraphRuleNormalizeOp(pcOp), pValue ]
		return This

	def ThenViolation(pcMsg)
		This.ThenViolationQ(pcMsg)

	def ThenViolationQ(pcMsg)
		@cViolation = "" + pcMsg
		return This

	# a REQUIREMENT clause: on a node in scope (matching every When), this must
	# hold, else the node is a finding. Turns the rule from a prohibition ("no
	# node should match") into an implication ("every matching node must satisfy
	# this"). Same operator set as When, incl. the comparisons.
	def Then(pcProp, pcOp, pValue)
		This.ThenQ(pcProp, pcOp, pValue)

	def ThenQ(pcProp, pcOp, pValue)
		if ring_trim("" + pcProp) = ""
			stzraise("stzGraphRule.Then: a requirement needs a property name.")
		ok
		@aRequirements + [ "" + pcProp, _StzGraphRuleNormalizeOp(pcOp), pValue ]
		return This

	# supply an explicit checker for rules too rich for the clause DSL. It is
	# called as call fChecker(oGraph) and returns [ [ :where, :message ], ... ].
	def UseChecker(fChecker)
		This.UseCheckerQ(fChecker)

	def UseCheckerQ(fChecker)
		@fChecker = fChecker
		return This

		#-- reads ---------------------------------------------------------

	def Name()
		return @cName

	def RuleType()
		return @cType

	def Domain()
		return @cDomain

	def Severity()
		return @cSeverity

	def Message()
		return @cMessage

	def ViolationMessage()
		if @cViolation != ""
			return @cViolation
		ok
		return @cMessage

	def Clauses()
		return @aClauses

	def NumberOfClauses()
		return len(@aClauses)

	def Requirements()
		return @aRequirements

	def NumberOfRequirements()
		return len(@aRequirements)

	def IsImplication()
		return len(@aRequirements) > 0

	def HasChecker()
		return not isNull(@fChecker)

		#-- the engine bridge ---------------------------------------------

	# Run this rule over a graph. Returns findings in the shared shape:
	#   [ [ :rule, :where, :severity, :message ], ... ]  (empty = the rule holds)
	def Check(oGraph)
		return StzGraphRuleFindings(oGraph, This._Spec())

	# TRUE when the rule holds (no findings).
	def Holds(oGraph)
		return len(This.Check(oGraph)) = 0

	def NumberOfFindings(oGraph)
		return len(This.Check(oGraph))

	# Compile this rule DOWN to an entry in the shared $aGraphRules registry, so
	# the existing engine runs it like any hand-registered rule. The registered
	# function is param-driven and delegates to the SAME matcher Check() uses,
	# so the two faces cannot diverge.
	def Register()
		This.RegisterQ()

	def RegisterQ()
		StzRegisterRule(@cDomain, @cName, [
			:type     = This._RegistryType(),
			:function = StzGraphRuleValidationFn(),
			:params   = This._Spec(),
			:message  = @cMessage,
			:severity = This._RegistrySeverity()
		])
		return This

	# The registry entry this rule produces (without registering) -- for
	# inspection and for the equivalence guard.
	def RegistryEntry()
		return [
			:name     = Upper(@cName),
			:type     = This._RegistryType(),
			:function = StzGraphRuleValidationFn(),
			:params   = This._Spec(),
			:message  = @cMessage,
			:severity = This._RegistrySeverity()
		]

	def Show()
		? "graph rule '" + @cName + "' [" + @cType + "] in '" + @cDomain +
		  "' (" + @cSeverity + ")"
		? "  when: " + This._ClausesText()
		? "  then: " + This.ViolationMessage()
		return This

		#-- internals -----------------------------------------------------

	def _Spec()
		return [
			:name         = @cName,
			:subject      = @cDomain,
			:clauses      = @aClauses,
			:requirements = @aRequirements,
			:violation    = This.ViolationMessage(),
			:severity     = @cSeverity,
			:checker      = @fChecker
		]

	# the registry default rules spell the type capitalized (:Validation)
	def _RegistryType()
		if @cType = "constraint"
			return :Constraint
		but @cType = "derivation"
			return :Derivation
		ok
		return :Validation

	def _RegistrySeverity()
		if @cSeverity = "warning"
			return :warning
		but @cSeverity = "info"
			return :info
		ok
		return :error

	def _ClausesText()
		_c_ = ""
		_n_ = len(@aClauses)
		for _i_ = 1 to _n_
			if _i_ > 1  _c_ += " AND "  ok
			_c_ += (@aClauses[_i_][1] + " " + @aClauses[_i_][2] + " " + ("" + @aClauses[_i_][3]))
		next
		if _c_ = ""  return "(no clauses)"  ok
		return _c_


#=====================================================#
#  STZGRAPHRULESET -- A NAMED COLLECTION OF RULES      #
#=====================================================#

/*--- The container both rule-base consumers assumed (graph-rules plan, phase 2)

stzWorkflow's stzBPMRuleBase / stzSLARuleBase and stzOrgChart's compliance
bases all wanted the SAME thing: a named set of stzGraphRules you can add to and
run over a graph in one call, aggregating findings. Neither had it -- the
workflow bases called This.AddRule(...) against a method that did not exist, and
the orgchart bases were name-only stubs. This is that container.

    oSet = new stzGraphRuleSet("bpm")
    oSet.AddRule(oRule1)
    oSet.AddRule(oRule2)
    ? oSet.Check(oGraph)      # every rule's findings, aggregated, in ONE shape
    ? oSet.IsSound(oGraph)    # TRUE iff no rule with an ERROR finding fired

A rule base is just a stzGraphRuleSet with a domain: the workflow and compliance
bases below inherit this, declare their rules in init(), and gain Check/IsSound
for free -- one engine, many rule bases.
*/

func StzGraphRuleSetQ(pcName)
	return new stzGraphRuleSet(pcName)

class stzGraphRuleSet from stzObject

	@cName   = ""
	@cDomain = ""
	@aRules  = []          # a list of stzGraphRule objects

	def init(pcName)
		@cName = "" + pcName

	def SetDomain(pcDomain)
		This.SetDomainQ(pcDomain)

	def SetDomainQ(pcDomain)
		@cDomain = StzLower(ring_trim("" + pcDomain))
		return This

	# Add a rule to the set. If the rule has no domain of its own, it inherits
	# the set's, so a base's rules all land in one registry group when compiled.
	def AddRule(poRule)
		This.AddRuleQ(poRule)

	def AddRuleQ(poRule)
		if @cDomain != "" and poRule.Domain() = "custom"
			poRule.SetDomainQ(@cDomain)
		ok
		@aRules + poRule
		return This

	  #-- reads -----------------------------------------------------------

	def Name()
		return @cName

	def Domain()
		return @cDomain

	def Rules()
		return @aRules

	def NumberOfRules()
		return len(@aRules)

	def RuleNamed(pcName)
		_n_ = len(@aRules)
		for _i_ = 1 to _n_
			if @aRules[_i_].Name() = pcName
				return @aRules[_i_]
			ok
		next
		return NULL

	def RuleNames()
		_out_ = []
		_n_ = len(@aRules)
		for _i_ = 1 to _n_
			_out_ + @aRules[_i_].Name()
		next
		return _out_

	  #-- the engine bridge -----------------------------------------------

	# Run EVERY rule over the graph; return all findings aggregated in the shared
	# shape [ [ :rule, :where, :severity, :message ], ... ].
	def Check(oGraph)
		_aAll_ = []
		_n_ = len(@aRules)
		for _i_ = 1 to _n_
			_aF_ = @aRules[_i_].Check(oGraph)
			_nF_ = len(_aF_)
			for _j_ = 1 to _nF_
				_aAll_ + _aF_[_j_]
			next
		next
		return _aAll_

	def NumberOfFindings(oGraph)
		return len(This.Check(oGraph))

	# TRUE when no ERROR-severity finding fired (warnings/info advise, like
	# stzSecurityPosture.IsSound and stzGovernanceChecks).
	def IsSound(oGraph)
		_aF_ = This.Check(oGraph)
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if _aF_[_i_][:severity] = "error"
				return FALSE
			ok
		next
		return TRUE

	# Compile every rule down into the shared $aGraphRules registry.
	def RegisterAll()
		_n_ = len(@aRules)
		for _i_ = 1 to _n_
			@aRules[_i_].Register()
		next
		return This

	def Show()
		? "rule set '" + @cName + "' [" + @cDomain + "] -- " + len(@aRules) + " rule(s)"
		_n_ = len(@aRules)
		for _i_ = 1 to _n_
			? "  - " + @aRules[_i_].Name() + " (" + @aRules[_i_].Severity() + ")"
		next
		return This
