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
	:completeness = [],
	:bottleneck = []
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

#=======================#
#  DEFAULT GRAPH RULES  #
#=======================#
#
# These MUST stay above the first `func` in this file. Ring treats statements
# that follow a function definition as part of that function's body, so when
# this block sat at the foot of the file it was unreachable code inside
# ValidationFunc_AllNodesReachable() and never executed. The rule groups were
# empty for the library's whole history, and the validators built on them
# reported "pass" unconditionally.
#
# RegisterRule and the ValidationFunc_/ConstraintFunc_ builders are defined
# below; Ring hoists function definitions, so calling them from here is fine.

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
#
# COMPLETENESS NOW MEANS COMPLETENESS. This group used to hold exactly one
# rule -- no_bottlenecks -- which is the property ValidateBottleneck already
# reports, under a name that promises something else entirely. A caller
# picking a validator by name got a degree-distribution check when it asked
# whether the graph was complete.
#
# So the bottleneck rule moved to its own :bottleneck group (below, where its
# name is honest), and :completeness got the rule its name implies: nothing
# is left dangling. Nothing stopped being checked -- :bottleneck joined
# $acGraphDefaultValidators, so a default Validate() still runs it.
RegisterRule(:completeness, "no_orphan_nodes", [
	:type = :Validation,
	:function = ValidationFunc_NoOrphanNodes(),
	:params = [],
	:message = "Graph contains orphan nodes (no incoming and no outgoing edge)",
	:severity = :warning
])

# Bottleneck rules
RegisterRule(:bottleneck, "no_bottlenecks", [
	:type = :Validation,
	:function = ValidationFunc_NoBottlenecks(),
	:params = [],
	:message = "Graph contains bottleneck nodes",
	:severity = :warning
])

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
						_aNewEdges_ + [_cFrom_, _cTo_, "(transitive)", [:derived = 1]]
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
				_aNewEdges_ + [_aEdge_[:to], _aEdge_[:from], "(symmetric)", [:derived = 1]]
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
						
						_bValid_ = 0
						if _cOrder_ = :ascending
							_bValid_ = (pFromVal < pMidVal and pMidVal < pToVal)
						but _cOrder_ = :descending
							_bValid_ = (pFromVal > pMidVal and pMidVal > pToVal)
						ok
						
						if _bValid_
							_aNewEdges_ + [_cFrom_, _cTo_, "(hierarchy)", [:derived = 1]]
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
				return [1, "Self-loops not allowed"]
			ok
		ok
		return [0, ""]
	}

func ConstraintFunc_MaxDegree()
	return func(oGraph, paRuleParams, paOperationParams) {
		_nMax_ = paRuleParams[:max]
		
		if HasKey(paOperationParams, :node)
			_cNode_ = paOperationParams[:node]
			if oGraph.NodeExists(_cNode_)
				_nDegree_ = len(oGraph.Neighbors(_cNode_)) + len(oGraph.Incoming(_cNode_))
				if _nDegree_ >= _nMax_
					return [1, "Node exceeds max degree of " + _nMax_]
				ok
			ok
		ok
		return [0, ""]
	}

func ConstraintFunc_NoCycles()
	return func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			_cFrom_ = paOperationParams[:from]
			_cTo_ = paOperationParams[:to]
			
			if oGraph.PathExists(_cTo_, _cFrom_)
				return [1, "Would create a cycle"]
			ok
		ok
		return [0, ""]
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
				_bFromRestricted_ = 0
				_bToRestricted_ = 0
				
				for i = 1 to _nLen_
					if pFromVal = _aValues_[i]
						_bFromRestricted_ = 1
					ok
					if pToVal = _aValues_[i]
						_bToRestricted_ = 1
					ok
				next
				
				if _bFromRestricted_ and _bToRestricted_
					return [1, "Separation of duties violation"]
				ok
			ok
		ok
		return [0, ""]
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
				
				_bMismatch_ = 0
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
					return [1, "Property constraint violated"]
				ok
			ok
		ok
		return [0, ""]
	}

#------------------------------------------#
#  BUILT-IN RULE FUNCTIONS : OnValidation  #
#------------------------------------------#

func ValidationFunc_IsAcyclic()
	return func(oGraph, paRuleParams) {
		if oGraph.HasCyclicDependencies()
			return [0, "Graph contains cycles"]
		ok
		return [1, ""]
	}

func ValidationFunc_IsConnected()
	return func(oGraph, paRuleParams) {
		if NOT oGraph.IsConnected()
			return [0, "Graph is not connected"]
		ok
		return [1, ""]
	}

func ValidationFunc_MaxNodes()
	return func(oGraph, paRuleParams) {
		_nMax_ = paRuleParams[:max]
		
		if oGraph.NodeCount() > _nMax_
			return [0, "Exceeds maximum of " + _nMax_ + " nodes"]
		ok
		return [1, ""]
	}

func ValidationFunc_DensityRange()
	return func(oGraph, paRuleParams) {
		_nMin_ = paRuleParams[:min]
		_nMax_ = paRuleParams[:max]
		
		_nDensity_ = oGraph.Density()
		if _nDensity_ < _nMin_ or _nDensity_ > _nMax_
			return [0, "Density " + _nDensity_ + " outside range [" + _nMin_ + "," + _nMax_ + "]"]
		ok
		return [1, ""]
	}

func ValidationFunc_NoBottlenecks()
	return func(oGraph, paRuleParams) {
		_aBottlenecks_ = oGraph.BottleneckNodes()
		if len(_aBottlenecks_) > 0
			return [0, "Bottlenecks found: " + JoinXT(_aBottlenecks_, ", ")]
		ok
		return [1, ""]
	}

func ValidationFunc_AllNodesReachable()
	return func(oGraph, paRuleParams) {
		_cStart_ = paRuleParams[:start]

		if NOT oGraph.NodeExists(_cStart_)
			return [0, "Start node does not exist"]
		ok

		# ReachableFrom() NEVER RETURNS THE START NODE (see its contract in
		# stzGraph.ring), so the count to beat is every OTHER node, not every
		# node. Compared against NodeCount() this rule could not pass on any
		# graph at all -- a perfect 3-node chain answers 2 < 3 and reported
		# "Not all nodes reachable". It is not registered in any default group
		# today, so nothing had run it; the trap is fixed here rather than
		# left for whoever registers it first.
		_aReachable_ = oGraph.ReachableFrom(_cStart_)
		_nOthers_ = oGraph.NodeCount() - 1

		if len(_aReachable_) < _nOthers_
			return [0, "Not all nodes reachable from " + _cStart_]
		ok
		return [1, ""]
	}

# NO ORPHAN NODES -- what :completeness actually asks.
#
# An orphan is a node with no incoming AND no outgoing edge. In a graph that
# has no edges at all every node is trivially an orphan and the answer is
# meaningless, so that case passes: the rule speaks about nodes left out of
# a structure, and a graph with no structure leaves nobody out.
func ValidationFunc_NoOrphanNodes()
	return func(oGraph, paRuleParams) {
		if oGraph.NumberOfEdges() = 0
			return [1, ""]
		ok

		_acOrphans_ = []
		_aNodes_ = oGraph.Nodes()
		_nLen_ = len(_aNodes_)
		for _i_ = 1 to _nLen_
			_cId_ = _aNodes_[_i_][:id]
			if len(oGraph.Neighbors(_cId_)) = 0 and len(oGraph.Incoming(_cId_)) = 0
				_acOrphans_ + _cId_
			ok
		next

		if len(_acOrphans_) > 0
			return [0, "Orphan nodes: " + JoinXT(_acOrphans_, ", ")]
		ok
		return [1, ""]
	}

#=======================#
#  DEFAULT GRAPH RULES  #
#=======================#
#
# MOVED TO THE TOP OF THIS FILE. They used to sit here -- which is AFTER the
# `return` inside func ValidationFunc_AllNodesReachable() above, so Ring read
# every one of them as unreachable code inside that function rather than as
# top-level statements. They never ran. $aGraphRules[:dag], [:reachability]
# and [:completeness] were all empty at runtime, which made ValidateReachability
# and ValidateCompleteness return "pass" on any input at all -- including a
# graph whose IsConnected() is 0. See the block after $acStzRulfLoaded.

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
			return [ 1, "" ]
		ok
		return [ 0, "" + paParams[:name] + ": " + len(_aF_) + " finding(s)" ]
	}

func _StzGraphRuleNodeMatches(oGraph, pcId, paClauses)
	_n_ = len(paClauses)
	for _i_ = 1 to _n_
		if NOT _StzGraphRuleClauseHolds(oGraph, pcId, paClauses[_i_])
			return 0
		ok
	next
	return 1

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
	but _op_ = "not-contains"
		return NOT (isList(_actual_) and ring_find(_actual_, _want_) > 0)
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
	return 0

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
		return 0
	ok
	return StzLower(ring_trim("" + pActual)) = StzLower(ring_trim("" + pWant))

func _StzGraphRuleValEmpty(pVal)
	if isList(pVal)
		return len(pVal) = 0
	ok
	if isNull(pVal)
		return 1
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
	# THE VOCABULARY HAD NO WAY TO SAY "MUST NOT", and a prohibition is
	# most of what a rule set is for. Without this, the only way to write
	# one in clauses is to put the violation INTO the scope -- which the
	# file's own example does, at no-llm-effectful:
	#
	#     WhenQ("kind", "equals", "llm_actor")
	#     WhenQ("capabilities", "contains", "effectful")
	#
	# That rule governs only the actors already violating it, so "governs
	# nothing" and "everything complies" are the same output. On an
	# error-severity agentic control, those are the two readings a person
	# most needs to tell apart: no LLM actor holds the effectful capability,
	# versus there is no LLM actor in this graph at all.
	#
	# The absence was not an oversight in any one rule. Every prohibition
	# written in this DSL was forced into the same shape by the operator
	# set, so the coverage figure of each was unreadable in the same way.
	but _o_ = "not-contains" or _o_ = "lacks" or _o_ = "excludes" or
	   _o_ = "!contains"
		return "not-contains"
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
	         "contains|not-contains|exists|missing|greaterthan|lessthan|greaterequal|lessequal).")

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
	@fChecker   = ""             # explicit checker closure (overrides clauses)

	# THE SCOPE, FOR A RULE THAT USES A CHECKER.
	#
	# @aClauses above is a scope and always was -- "When" is the word this
	# file chose for it. But a checker OVERRIDES the clauses, and MEASURED
	# 2026-08-29 across the shipped rule sets: 26 of 34 rules use a checker
	# and 5 declare any When at all.
	#
	#     org 6 rules / 5 checkers / 0 scopes      code  8 / 7 / 0
	#     security 4 / 3 / 0                       service 4 / 3 / 0
	#     agent 6 / 4 / 2                          workflow 6 / 4 / 3
	#
	# So the declarative scope was built, shipped, and then bypassed by
	# three quarters of the rules written after it -- and not out of
	# laziness. A checker computes reachability, in-degree, cross-node
	# queries; the clause DSL cannot say those things, so a real rule had
	# to choose between an expressible scope and a correct check, and
	# correctly chose the check.
	#
	# These two let it have both. They do not replace the checker, and
	# they are not consulted when the rule runs -- they exist so the
	# SELECTION half becomes visible to stzRuleGovernance, which is where
	# every scope defect this library has paid for actually lived. A rule
	# that selects the wrong subjects and judges them correctly returns
	# "pass", and a suite sees a pass.
	@fGoverns   = ""             # func(oGraph) -> subject keys it governs
	@fExcludes  = ""             # func(oGraph) -> subject keys it must NOT
	@cUniversal = ""             # declared universal, with the reason
	@nOrder     = 0
	@acReads    = []
	@acWrites   = []

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
	# WHICH SUBJECTS THIS RULE GOVERNS -- declared beside the checker, not
	# instead of it. See the block at @fGoverns for why both are needed.
	def Governs(fFunc)
		This.GovernsQ(fFunc)

	def GovernsQ(fFunc)
		@fGoverns = fFunc
		return This

	# ...AND WHICH IT MUST NOT. The negative sibling, at rule level: a
	# boundary that is never exercised is a boundary that could be
	# anywhere.
	def Excludes(fFunc)
		This.ExcludesQ(fFunc)

	def ExcludesQ(fFunc)
		@fExcludes = fFunc
		return This

	# A rule with no boundary because the claim genuinely has none. The
	# reason is required: "universal" without one is indistinguishable
	# from a scope predicate that broke, which is the case worth catching.
	def DeclareUniversal(pcWhy)
		This.DeclareUniversalQ(pcWhy)

	def DeclareUniversalQ(pcWhy)
		@cUniversal = "" + pcWhy
		return This

	# What it reads, what it writes, and when it runs -- so an ordering
	# defect is a fact about declarations rather than something found by
	# rendering the world and squinting at it.
	def SetReadsQ(pacNames)
		@acReads = pacNames
		return This

	def SetWritesQ(pacNames)
		@acWrites = pacNames
		return This

	def SetOrderQ(pnOrder)
		@nOrder = pnOrder
		return This

	  #-- the governance interface ---------------------------------------
	  #
	  # stzRuleGovernance asks a rule these and nothing else, so an
	  # stzGraphRule can be governed exactly as a plastic rule is, with no
	  # wrapper and no second implementation of the same idea.

	# ...AND A CLAUSE RULE ALREADY HAS A SCOPE: its When clauses.
	#
	# The first governance run over the BPM set reported every clause
	# rule as scope_empty, which was the governance's own defect and not
	# the rules'. "When" is the scope -- this file has said so since it
	# was written -- so a rule that declares one needs no second copy of
	# it as a closure, and asking for one would have been this layer
	# demanding duplication in the name of catching duplication.
	#
	# A rule with BOTH is answered by the closure, because a closure is
	# reached for exactly when the clauses cannot say the thing.
	def SubjectsIn(poGraph)
		if @fGoverns != ""  return call @fGoverns(poGraph)  ok
		if len(@aClauses) = 0  return []  ok
		return This._NodesMatchingClauses(poGraph, 1)

	# ...and the boundary of a clause rule is the complement: the nodes
	# it looked at and did not take. Free, exact, and available for every
	# clause rule in the library without anyone writing a line.
	def CounterSubjectsIn(poGraph)
		if @fExcludes != ""  return call @fExcludes(poGraph)  ok
		if len(@aClauses) = 0  return []  ok
		return This._NodesMatchingClauses(poGraph, 0)

	def _NodesMatchingClauses(poGraph, bWant)
		_r_ = []
		_a_ = poGraph.NodesIds()
		_n_ = len(_a_)
		_nc_ = len(@aClauses)
		for _i_ = 1 to _n_
			_hit_ = 1
			for _j_ = 1 to _nc_
				if NOT _StzGraphRuleClauseHolds(poGraph, _a_[_i_],
					@aClauses[_j_])
					_hit_ = 0
					exit
				ok
			next
			if _hit_ != bWant  loop  ok
			_r_ + ("node:" + StzLower("" + _a_[_i_]))
		next
		return _r_

	def Name_()        return @cName
	def Claim()        return @cMessage
	def Reads()        return @acReads
	def Writes()       return @acWrites
	def Order()        return @nOrder
	def IsUniversal()  return @cUniversal != ""
	def UniversalWhy() return @cUniversal

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
		return ""

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
				return 0
			ok
		next
		return 1

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
