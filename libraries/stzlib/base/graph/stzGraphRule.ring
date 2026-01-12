#============================================#
#  FUNCTION-BASED RULES SYSTEM FOR stzGraph
#  Simple, flexible, unlimited power
#============================================#

# Three Rule Types:
# 1. DERIVATION - Function generates new edges/nodes
# 2. CONSTRAINT - Function checks if operation should be blocked
# 3. VALIDATION - Function checks if graph state is valid

#------------------#
#  RULE CONTAINER  #
#------------------#

$GraphRules = [
	:security = [],
	:workflow = [],
	:compliance = [],
	:optimization = [],
	:business = [],
	:custom = []
]

#-------------#
#  FUNCTIONS  #
#-------------#

func GraphRules()
	return $GraphRules

func RegisterRule(pcTheme, pcRuleName, paRuleDefinition)
	if NOT HasKey($GraphRules, pcTheme)
		$GraphRules + [pcTheme, []]
	ok
	
	aRule = [
		:name = pcRuleName,
		:type = paRuleDefinition[:type],
		:function = paRuleDefinition[:function],
		:params = paRuleDefinition[:params],  # Store params here
		:message = paRuleDefinition[:message],
		:severity = paRuleDefinition[:severity]
	]
	
	$GraphRules[pcTheme] + aRule

func GetRule(pcTheme, pcRuleName)
	if HasKey($GraphRules, pcTheme)
		aRules = $GraphRules[pcTheme]
		nLen = len(aRules)
		for i = 1 to nLen
			if aRules[i][:name] = pcRuleName
				return aRules[i]
			ok
		next
	ok
	return NULL

#---------------------------#
#  BUILT-IN RULE FUNCTIONS  #
#---------------------------#

# DERIVATION FUNCTIONS
# Signature: func(oGraph, paRuleParams) -> [[from, to, label, properties], ...]

func DerivationFunc_Transitivity()
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

func DerivationFunc_Symmetry()
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

func DerivationFunc_Hierarchy()
	return func(oGraph, paRuleParams) {
		# Get params from rule definition
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

# CONSTRAINT FUNCTIONS
# Signature: func(oGraph, paRuleParams, paOperationParams) -> [blocked:BOOL, message:STRING]

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

func ConstraintFunc_NoCycles()
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

func ConstraintFunc_Separation()
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

func ConstraintFunc_PropertyMismatch()
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

#------------------------#
#  VALIDATION FUNCTIONS  #
#------------------------#
# Signature: func(oGraph, paRuleParams) -> [valid:BOOL, message:STRING]

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
		nMax = paRuleParams[:max]
		
		if oGraph.NodeCount() > nMax
			return [FALSE, "Exceeds maximum of " + nMax + " nodes"]
		ok
		return [TRUE, ""]
	}

func ValidationFunc_DensityRange()
	return func(oGraph, paRuleParams) {
		nMin = paRuleParams[:min]
		nMax = paRuleParams[:max]
		
		nDensity = oGraph.Density()
		if nDensity < nMin or nDensity > nMax
			return [FALSE, "Density " + nDensity + " outside range [" + nMin + "," + nMax + "]"]
		ok
		return [TRUE, ""]
	}

func ValidationFunc_NoBottlenecks()
	return func(oGraph, paRuleParams) {
		aBottlenecks = oGraph.BottleneckNodes()
		if len(aBottlenecks) > 0
			return [FALSE, "Bottlenecks found: " + JoinXT(aBottlenecks, ", ")]
		ok
		return [TRUE, ""]
	}

func ValidationFunc_AllNodesReachable()
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

#-------------------------------#
#  RULES RELATED TO stzDiagram  #
#-------------------------------#

RegisterRule(:dag, "dag", [
	:type = :validation,
	:function = ValidationFunc_IsAcyclic(),
	:params = [],
	:message = "Diagram must be acyclic (DAG)",
	:severity = :error
])

RegisterRule(:sox, "sox", [
	:type = :validation,
	:function = func(oGraph, paParams) {
		acFinancial = oGraph.NodesW("domain", "=", "financial")
		for cId in acFinancial
			if oGraph.NodeProp(cId, "audittrail") = NULL
				return [FALSE, "Financial node missing audit: " + cId]
			ok
		end
		return [TRUE, ""]
	},
	:params = [],
	:message = "Financial processes need audit trails",
	:severity = :error
])

RegisterRule(:gdpr, "gdpr", [
	:type = :validation,
	:function = func(oGraph, paParams) {
		acPersonal = oGraph.NodesW("dataType", "=", "personal")
		for cId in acPersonal
			if oGraph.NodeProp(cId, "requiresConsent") != 1
				return [FALSE, "Personal data missing consent: " + cId]
			ok
		end
		return [TRUE, ""]
	},
	:params = [],
	:message = "Personal data needs consent",
	:severity = :error
])
