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
