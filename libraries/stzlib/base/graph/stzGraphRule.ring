#=============================================#
#  FUNCTION-BASED RULES SYSTEM FOR stzGraph   #
#  Clean three-phase validation architecture  #
#=============================================#

# Three Rule Types:
# 1. CheckBeforeActing - Guards operations (blocks invalid changes)
# 2. ReactAfterActing - Auto-derives edges/nodes after changes
# 3. ValidateGraphSate - Validates final graph state

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

func GraphRules()
	return $aGraphRules

func RegisterRule(pcRuleGroup, pcRuleName, paRuleDefinition)
	if NOT HasKey($aGraphRules, pcRuleGroup)
		$aGraphRules[pcRuleGroup] = []
	ok
	
	aRule = [
		:name = pcRuleName,
		:type = paRuleDefinition[:type],
		:function = paRuleDefinition[:function],
		:params = paRuleDefinition[:params],
		:message = paRuleDefinition[:message],
		:severity = paRuleDefinition[:severity]
	]
	
	$aGraphRules[pcRuleGroup] + aRule

func GetRule(pcRuleGroup, pcRuleName)
	if HasKey($aGraphRules, pcRuleGroup)
		aRules = $aGraphRules[pcRuleGroup]
		nLen = len(aRules)
		for i = 1 to nLen
			if aRules[i][:name] = pcRuleName
				return aRules[i]
			ok
		next
	ok
	stzraise("Inexistant rule!")

#-------------------------------------------------#
#  BUILT-IN RULE FUNCTIONS : ReactAfterActing  #
#-------------------------------------------------#

func ConstructionFunc_Transitivity()
	return func(oGraph, paRuleParams) {
		aNewEdges = []
		aEdges = oGraph.Edges()
		nLen1 = len(aEdges)
		
		for i = 1 to nLen1
			aEdge1 = aEdges[i]
			nLen2 = len(aEdges)
			
			for j = 1 to nLen2
				aEdge2 = aEdges[j]
				
				if aEdge1[:to] = aEdge2[:from]
					cFrom = aEdge1[:from]
					cTo = aEdge2[:to]
					
					if NOT oGraph.EdgeExists(cFrom, cTo) and cFrom != cTo
						aNewEdges + [cFrom, cTo, "(transitive)", [:derived = TRUE]]
					ok
				ok
			next
		next
		
		return aNewEdges
	}

func ConstructionFunc_Symmetry()
	return func(oGraph, paRuleParams) {
		aNewEdges = []
		aEdges = oGraph.Edges()
		nLen = len(aEdges)
		
		for i = 1 to nLen
			aEdge = aEdges[i]
			if NOT oGraph.EdgeExists(aEdge[:to], aEdge[:from])
				aNewEdges + [aEdge[:to], aEdge[:from], "(symmetric)", [:derived = TRUE]]
			ok
		next
		
		return aNewEdges
	}

func ConstructionFunc_Hierarchy()
	return func(oGraph, paRuleParams) {
		cProp = paRuleParams[:property]
		cOrder = paRuleParams[:order]
		
		aNewEdges = []
		aEdges = oGraph.Edges()
		nLen1 = len(aEdges)
		
		for i = 1 to nLen1
			aEdge1 = aEdges[i]
			nLen2 = len(aEdges)
			
			for j = 1 to nLen2
				aEdge2 = aEdges[j]
				
				if aEdge1[:to] = aEdge2[:from]
					cFrom = aEdge1[:from]
					cMid = aEdge1[:to]
					cTo = aEdge2[:to]
					
					if NOT oGraph.EdgeExists(cFrom, cTo) and cFrom != cTo
						pFromVal = oGraph.NodeProperty(cFrom, cProp)
						pMidVal = oGraph.NodeProperty(cMid, cProp)
						pToVal = oGraph.NodeProperty(cTo, cProp)
						
						bValid = FALSE
						if cOrder = :ascending
							bValid = (pFromVal < pMidVal and pMidVal < pToVal)
						but cOrder = :descending
							bValid = (pFromVal > pMidVal and pMidVal > pToVal)
						ok
						
						if bValid
							aNewEdges + [cFrom, cTo, "(hierarchy)", [:derived = TRUE]]
						ok
					ok
				ok
			next
		next
		
		return aNewEdges
	}

#-------------------------------------------#
#  BUILT-IN RULE FUNCTIONS : CheckBeforeActing  #
#-------------------------------------------#

func DesignFunc_NoSelfLoop()
	return func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			if paOperationParams[:from] = paOperationParams[:to]
				return [TRUE, "Self-loops not allowed"]
			ok
		ok
		return [FALSE, ""]
	}

func DesignFunc_MaxDegree()
	return func(oGraph, paRuleParams, paOperationParams) {
		nMax = paRuleParams[:max]
		
		if HasKey(paOperationParams, :node)
			cNode = paOperationParams[:node]
			if oGraph.NodeExists(cNode)
				nDegree = len(oGraph.Neighbors(cNode)) + len(oGraph.Incoming(cNode))
				if nDegree >= nMax
					return [TRUE, "Node exceeds max degree of " + nMax]
				ok
			ok
		ok
		return [FALSE, ""]
	}

func DesignFunc_NoCycles()
	return func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			cFrom = paOperationParams[:from]
			cTo = paOperationParams[:to]
			
			if oGraph.PathExists(cTo, cFrom)
				return [TRUE, "Would create a cycle"]
			ok
		ok
		return [FALSE, ""]
	}

func DesignFunc_Separation()
	return func(oGraph, paRuleParams, paOperationParams) {
		cProp = paRuleParams[:property]
		aValues = paRuleParams[:values]
		
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			cFrom = paOperationParams[:from]
			cTo = paOperationParams[:to]
			
			if oGraph.NodeExists(cFrom) and oGraph.NodeExists(cTo)
				pFromVal = oGraph.NodeProperty(cFrom, cProp)
				pToVal = oGraph.NodeProperty(cTo, cProp)
				
				nLen = len(aValues)
				bFromRestricted = FALSE
				bToRestricted = FALSE
				
				for i = 1 to nLen
					if pFromVal = aValues[i]
						bFromRestricted = TRUE
					ok
					if pToVal = aValues[i]
						bToRestricted = TRUE
					ok
				next
				
				if bFromRestricted and bToRestricted
					return [TRUE, "Separation of duties violation"]
				ok
			ok
		ok
		return [FALSE, ""]
	}

func DesignFunc_PropertyMismatch()
	return func(oGraph, paRuleParams, paOperationParams) {
		cProp = paRuleParams[:property]
		cOp = paRuleParams[:operator]
		pVal = paRuleParams[:value]
		
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			cFrom = paOperationParams[:from]
			cTo = paOperationParams[:to]
			
			if oGraph.NodeExists(cFrom)
				pActual = oGraph.NodeProperty(cFrom, cProp)
				
				bMismatch = FALSE
				if cOp = "!="
					bMismatch = (pActual = pVal)
				but cOp = "="
					bMismatch = (pActual != pVal)
				but cOp = ">"
					bMismatch = (pActual <= pVal)
				but cOp = "<"
					bMismatch = (pActual >= pVal)
				ok
				
				if bMismatch
					return [TRUE, "Property constraint violated"]
				ok
			ok
		ok
		return [FALSE, ""]
	}

#------------------------------------------#
#  BUILT-IN RULE FUNCTIONS : OnFinalState  #
#------------------------------------------#

func FinalStateFunc_IsAcyclic()
	return func(oGraph, paRuleParams) {
		if oGraph.HasCyclicDependencies()
			return [FALSE, "Graph contains cycles"]
		ok
		return [TRUE, ""]
	}

func FinalStateFunc_IsConnected()
	return func(oGraph, paRuleParams) {
		if NOT oGraph.IsConnected()
			return [FALSE, "Graph is not connected"]
		ok
		return [TRUE, ""]
	}

func FinalStateFunc_MaxNodes()
	return func(oGraph, paRuleParams) {
		nMax = paRuleParams[:max]
		
		if oGraph.NodeCount() > nMax
			return [FALSE, "Exceeds maximum of " + nMax + " nodes"]
		ok
		return [TRUE, ""]
	}

func FinalStateFunc_DensityRange()
	return func(oGraph, paRuleParams) {
		nMin = paRuleParams[:min]
		nMax = paRuleParams[:max]
		
		nDensity = oGraph.Density()
		if nDensity < nMin or nDensity > nMax
			return [FALSE, "Density " + nDensity + " outside range [" + nMin + "," + nMax + "]"]
		ok
		return [TRUE, ""]
	}

func FinalStateFunc_NoBottlenecks()
	return func(oGraph, paRuleParams) {
		aBottlenecks = oGraph.BottleneckNodes()
		if len(aBottlenecks) > 0
			return [FALSE, "Bottlenecks found: " + JoinXT(aBottlenecks, ", ")]
		ok
		return [TRUE, ""]
	}

func FinalStateFunc_AllNodesReachable()
	return func(oGraph, paRuleParams) {
		cStart = paRuleParams[:start]
		
		if NOT oGraph.NodeExists(cStart)
			return [FALSE, "Start node does not exist"]
		ok
		
		aReachable = oGraph.ReachableFrom(cStart)
		nTotal = oGraph.NodeCount()
		
		if len(aReachable) < nTotal
			return [FALSE, "Not all nodes reachable from " + cStart]
		ok
		return [TRUE, ""]
	}

#=======================#
#  DEFAULT GRAPH RULES  #
#=======================#

# DAG rules
RegisterRule(:dag, "no_cycles_design", [
	:type = :CheckBeforeActing,
	:function = DesignFunc_NoCycles(),
	:params = [],
	:message = "Operation would create a cycle",
	:severity = :error
])

RegisterRule(:dag, "acyclic_state", [
	:type = :ValidateGraphSate,
	:function = FinalStateFunc_IsAcyclic(),
	:params = [],
	:message = "Graph must be acyclic",
	:severity = :error
])

# Reachability rules
RegisterRule(:reachability, "all_connected", [
	:type = :ValidateGraphSate,
	:function = FinalStateFunc_IsConnected(),
	:params = [],
	:message = "Graph must be fully connected",
	:severity = :warning
])

# Completeness rules
RegisterRule(:completeness, "no_bottlenecks", [
	:type = :ValidateGraphSate,
	:function = FinalStateFunc_NoBottlenecks(),
	:params = [],
	:message = "Graph contains bottleneck nodes",
	:severity = :warning
])
