#============================================#
#  stzGraph - FUNDAMENTAL GRAPH ABSTRACTION  #
#  Pure computational thinking construct     #
#============================================#

class stzGraph

	@cId = ""
	@acNodes = []
	@acEdges = []
	@acProperties = []
	
	# ASCII Display Characters
	@cBoxTopLeft = "╭"
	@cBoxTopRight = "╮"
	@cBoxBottomLeft = "╰"
	@cBoxBottomRight = "╯"
	@cBoxHorizontal = "─"
	@cBoxVertical = "│"
	@cArrowDown = "v"
	@cArrowUp = "↑"
	@cPipeChar = "|"
	@cBranchSeparator = "////"
	@cCycleIndicator = "CYCLE"
	@cConnectorDash = "-"
	@cConnectorArrow = ">"

	def init(pcId)
		@cId = pcId
		@acNodes = []
		@acEdges = []
		@acProperties = []

	def Id()
		return @cId

	#------------------------------------------
	#  NODE OPERATIONS
	#------------------------------------------

	def AddNode(pcNodeId, pcLabel)
		This.AddNodeXT(pcNodeId, pcLabel, [])

	def AddNodeXT(pcNodeId, pcLabel, pacProperties)
		aNode = [
			:id = pcNodeId,
			:label = pcLabel,
			:properties = iif(isList(pacProperties), pacProperties, [])
		]
		@acNodes + aNode

	def Node(pcNodeId)
		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			if aNode["id"] = pcNodeId
				return aNode
			ok
		end
		return ""

	def NodeExists(pcNodeId)
		return This.Node(pcNodeId) != ""

	def RemoveNode(pcNodeId)
		acNew = []
		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			if aNode["id"] != pcNodeId
				acNew + aNode
			ok
		end
		@acNodes = acNew
		
		acNewEdges = []
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] != pcNodeId and aEdge["to"] != pcNodeId
				acNewEdges + aEdge
			ok
		end
		@acEdges = acNewEdges

	def AllNodes()
		return @acNodes

	def NodeCount()
		return len(@acNodes)

	#-------------------#
	#  EDGE OPERATIONS  #
	#-------------------#

	def AddEdge(pcFromId, pcToId, pcLabel)
		This.AddEdgeXT(pcFromId, pcToId, pcLabel, [])

	def AddEdgeXT(pcFromId, pcToId, pcLabel, pacProperties)
		if NOT This.NodeExists(pcFromId) or NOT This.NodeExists(pcToId)
			return 0
		ok

		aEdge = [
			:from = pcFromId,
			:to = pcToId,
			:label = pcLabel,
			:properties = iif(isList(pacProperties), pacProperties, [])
		]
		@acEdges + aEdge
		return 1

	def Edge(pcFromId, pcToId)
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] = pcFromId and aEdge["to"] = pcToId
				return aEdge
			ok
		end
		return ""

	def EdgeExists(pcFromId, pcToId)
		return This.Edge(pcFromId, pcToId) != ""

	def RemoveEdge(pcFromId, pcToId)
		acNew = []
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if NOT (aEdge["from"] = pcFromId and aEdge["to"] = pcToId)
				acNew + aEdge
			ok
		end
		@acEdges = acNew

	def AllEdges()
		return @acEdges

	def EdgeCount()
		return len(@acEdges)

	#---------------------------#
	#  TRAVERSAL & PATHFINDING  #
	#---------------------------#

	def PathExists(pcFromId, pcToId)
		if pcFromId = pcToId
			return 1
		ok
		acVisited = []
		return This._PathExistsDFS(pcFromId, pcToId, acVisited)

	def _PathExistsDFS(pcCurrent, pcTarget, pacVisited)
		if pcCurrent = pcTarget
			return 1
		ok

		if find(pacVisited, pcCurrent) > 0
			return 0
		ok

		pacVisited + pcCurrent

		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] = pcCurrent
				if This._PathExistsDFS(aEdge["to"], pcTarget, pacVisited)
					return 1
				ok
			ok
		end

		return 0

	def FindAllPaths(pcFromId, pcToId)
		if CheckParams()
			if isList(pcFromId) and StzListQ(pcFromId).IsFromNamedParam()
				pcFromId = pcFromId[2]
			ok
			if isList(pcToId) and StzListQ(pcToId).IsToNamedParam()
				pcToId = pcToId[2]
			ok
			
		ok

		acAllPaths = []
		acCurrentPath = [pcFromId]
		This._FindAllPathsDFS(pcFromId, pcToId, acCurrentPath, acAllPaths, 0)
		return acAllPaths
	
		def AllPaths(pcFromId, pcToId)
			return This.FindAllPaths(pcFromId, pcToId)

		def Paths(pcFromId, pcToId)
			return This.FindAllPaths(pcFromId, pcToId)

	def _FindAllPathsDFS(pcCurrent, pcTarget, pacCurrentPath, pacAllPaths, pnDepth)
		
		if pnDepth > 10
			return
		ok
	
		if pcCurrent = pcTarget
			pacAllPaths + pacCurrentPath
			return
		ok
	
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] = pcCurrent
				cNext = aEdge["to"]
				
				if find(pacCurrentPath, cNext) = 0
					pacCurrentPath + cNext
					This._FindAllPathsDFS(cNext, pcTarget, pacCurrentPath, pacAllPaths, pnDepth + 1)
					pacCurrentPath = stzleft(pacCurrentPath, len(pacCurrentPath) - 1)
				ok
			ok
		end

	def Neighbors(pcNodeId)
		if CheckParams()
			if isList(pcNodeId) and StzListQ(pcNodeId).IsOfOrToNamedParam()
				pcNodeId = pcNodeId[2]
			ok
		ok

		acNeighbors = []
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] = pcNodeId
				acNeighbors + aEdge["to"]
			ok
		end
		return acNeighbors

		def NeighborsTo(pcNodeId)
			return This.Neighbors(pcNodeId)

		def NeighborsOf(pcNodeId)
			return This.Neighbors(pcNodeId)

	def Incoming(pcNodeId)
		if CheckParams()
			if isList(pcNodeId) and StzListQ(pcNodeId).IsToNamedParam()
				pcNodeId = pcNodeId[2]
			ok
		ok

		acIncoming = []
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["to"] = pcNodeId
				acIncoming + aEdge["from"]
			ok
		end
		return acIncoming

		def IncomingTo(pcNodeId)
			return This.Incoming(pcNodeId)

	#------------------------------------------
	#  CYCLE DETECTION
	#------------------------------------------

	def CyclicDependencies()
		acVisited = []
		acRecStack = []

		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			if find(acVisited, aNode["id"]) = 0
				if This._HasCycleDFS(aNode["id"], acVisited, acRecStack)
					return 1
				ok
			ok
		end

		return 0

	def _HasCycleDFS(pcNode, pacVisited, pacRecStack)
		pacVisited + pcNode
		pacRecStack + pcNode

		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] = pcNode
				if find(pacVisited, aEdge["to"]) = 0
					if This._HasCycleDFS(aEdge["to"], pacVisited, pacRecStack)
						return 1
					ok
				but find(pacRecStack, aEdge["to"]) > 0
					return 1
				ok
			ok
		end

		nLen = len(pacRecStack)
		if nLen > 1
			pacRecStack = stzleft(pacRecStack, len(pacRecStack) - 1)
		ok

		return 0

	#------------------------------------------
	#  REACHABILITY & CONNECTIVITY
	#------------------------------------------

def ReachableFrom(pcNodeId)
	if NOT This.NodeExists(pcNodeId)
		return []
	ok
	
	acReachable = []
	acVisited = []
	acQueue = [pcNodeId]
	acVisited + pcNodeId
	nQueueIdx = 1

	while nQueueIdx <= len(acQueue)
		cCurrent = acQueue[nQueueIdx]
		acReachable + cCurrent
		
		acNeighbors = This.Neighbors(cCurrent)
		nLen = len(acNeighbors)
		for i = 1 to nLen
			cNeighbor = acNeighbors[i]
			if find(acVisited, cNeighbor) = 0
				acVisited + cNeighbor
				acQueue + cNeighbor
			ok
		end
		
		nQueueIdx += 1
	end
	
	return acReachable

	
	def _ReachableBFS(pcNodeId, pacReachable, pacVisited)
		acQueue = [pcNodeId]
		pacVisited + pcNodeId
	
		while len(acQueue) > 0
			cCurrent = acQueue[1]
			if len(acQueue) > 1
				acQueue = stzright(acQueue, len(acQueue) - 1)
			else
				acQueue = []
			ok
			pacReachable + cCurrent
	
			acNeighbors = This.Neighbors(cCurrent)
			nLen = len(acNeighbors)
			for i = 1 to nLen
				cNeighbor = acNeighbors[i]
				if find(pacVisited, cNeighbor) = 0
					pacVisited + cNeighbor
					acQueue + cNeighbor
				ok
			end
		end

	#------------------------------------------
	#  ANALYSIS METRICS
	#------------------------------------------

	def BottleneckNodes()
		acBottlenecks = []
		nTotalDegree = 0
		
		# Calculate average degree
		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			nIncoming = len(This.Incoming(aNode["id"]))
			nOutgoing = len(This.Neighbors(aNode["id"]))
			nTotalDegree += nIncoming + nOutgoing
		end
		
		nAvgDegree = nTotalDegree / len(@acNodes)
		
		# Mark nodes above average
		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			nIncoming = len(This.Incoming(aNode["id"]))
			nOutgoing = len(This.Neighbors(aNode["id"]))
			nDegree = nIncoming + nOutgoing
			
			if nDegree > nAvgDegree
				acBottlenecks + aNode["id"]
			ok
		end
		
		return acBottlenecks

	def NodeDensity()
		nNodes = len(@acNodes)
		nEdges = len(@acEdges)

		if nNodes <= 1
			return 0
		ok

		nMaxEdges = nNodes * (nNodes - 1)
		return (nEdges * 100) / nMaxEdges

	def LongestPath()
		nMax = 0

		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			acReachable = This.ReachableFrom(aNode["id"])
			nLength = len(acReachable) - 1

			if nLength > nMax
				nMax = nLength
			ok
		end

		return nMax

#------------------------------------------
	#  1. INDEPENDENCE AND PARALLELIZATION
	#------------------------------------------

	def ParallelizableBranches()
		acBranches = []
		nLen = len(@acNodes)
		
		for i = 1 to nLen
			aNode = @acNodes[i]
			cNodeId = aNode["id"]
			acNeighbors = This.Neighbors(cNodeId)
			
			if len(acNeighbors) > 1
				# For each pair of neighbors, check if they're independent
				nNeighborLen = len(acNeighbors)
				for j = 1 to nNeighborLen
					cNeighbor1 = acNeighbors[j]
					acReachable1 = This.ReachableFrom(cNeighbor1)
					
					for k = j + 1 to nNeighborLen
						cNeighbor2 = acNeighbors[k]
						acReachable2 = This.ReachableFrom(cNeighbor2)
						
						# Remove starting nodes from comparison
						acReachable1Clean = []
						acReachable2Clean = []
						
						nLen1 = len(acReachable1)
						for m = 1 to nLen1
							if acReachable1[m] != cNeighbor1
								acReachable1Clean + acReachable1[m]
							ok
						end
						
						nLen2 = len(acReachable2)
						for m = 1 to nLen2
							if acReachable2[m] != cNeighbor2
								acReachable2Clean + acReachable2[m]
							ok
						end
						
						# Check if downstream nodes are disjoint
						bDisjoint = 1
						nCheck = len(acReachable1Clean)
						for m = 1 to nCheck
							if find(acReachable2Clean, acReachable1Clean[m]) > 0
								bDisjoint = 0
								exit
							ok
						end
						
						if bDisjoint
							acBranches + [cNeighbor1, cNeighbor2]
						ok
					end
				end
			ok
		end
		
		return acBranches

	def DependencyFreeNodes()
		acDependencyFree = []
		nLen = len(@acNodes)
		
		for i = 1 to nLen
			aNode = @acNodes[i]
			cNodeId = aNode["id"]
			acIncoming = This.Incoming(cNodeId)
			
			if len(acIncoming) = 0
				acDependencyFree + cNodeId
			ok
		end
		
		return acDependencyFree

	#------------------------------------------
	#  2. CRITICALITY AND IMPACT
	#------------------------------------------

	def ImpactOf(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		
		acReachable = This.ReachableFrom(pcNodeId)
		return len(acReachable) - 1
	
	def FailureScope(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return []
		ok
		
		acReachable = This.ReachableFrom(pcNodeId)
		acScope = []
		
		nLen = len(acReachable)
		for i = 1 to nLen
			cNode = acReachable[i]
			if cNode != pcNodeId
				acScope + cNode
			ok
		end
	
		return acScope

	def NodeCriticality()
		acCriticality = []
		nLen = len(@acNodes)
		
		for i = 1 to nLen
			aNode = @acNodes[i]
			cNodeId = aNode["id"]
			nIncoming = len(This.Incoming(cNodeId))
			nOutgoing = len(This.Neighbors(cNodeId))
			nTotalDegree = nIncoming + nOutgoing
			
			acCriticality + [
				:id = cNodeId,
				:criticality = nTotalDegree
			]
		end
		
		return acCriticality

	def MostCriticalNodes(pnCount)
	
		if isNULL(pnCount)
			pnCount = 5
		ok
		
		acCriticality = This.NodeCriticality()
		nLen = len(acCriticality)
		
		for i = 1 to nLen - 1
			nMaxIdx = i
			for j = i + 1 to nLen
				if acCriticality[j]["criticality"] > acCriticality[nMaxIdx]["criticality"]
					nMaxIdx = j
				ok
			end
			
			if nMaxIdx != i
				aTemp = acCriticality[i]
				acCriticality[i] = acCriticality[nMaxIdx]
				acCriticality[nMaxIdx] = aTemp
			ok
		end
	
		acResult = []
		nLimit = Min([pnCount, nLen])
		for i = 1 to nLimit
			acResult + acCriticality[i]["id"]
		end
		
		return acResult

	#------------------------------------------
	#  3. CONSTRAINTS AND VALIDATION
	#------------------------------------------
	
	def AddConstraint(pcConstraintType)
	    if NOT isList(@acProperties)
	        @acProperties = []
	    ok
	    
	    cType = upper(pcConstraintType)
	    
	    aConstraint = [
	        :type = cType,
	        :violations = []
	    ]
	    
	    if NOT HasKey(@acProperties, "constraints")
	        @acProperties["constraints"] = []
	    ok
	    
	    @acProperties["constraints"] + aConstraint
	
	def ValidateConstraints()
	    if NOT HasKey(@acProperties, "constraints")
	        return 1
	    ok
	    
	    acConstraints = @acProperties["constraints"]
	    nLen = len(acConstraints)
	    
	    for i = 1 to nLen
	        aConstraint = acConstraints[i]
	        cType = aConstraint["type"]
	        
	        bValid = This._EvaluateConstraint(cType)
	        
	        if NOT bValid
	            aConstraint["violations"] + "Constraint failed"
	        ok
	    end
	    
	    return len(This.ConstraintViolations()) = 0
	
	def _EvaluateConstraint(pcType)
	    if pcType = "ACYCLIC" or pcType = "NO_CYCLES"
	        return NOT This.CyclicDependencies()
	    ok
	    
	    if pcType = "CONNECTED"
	        return This._IsConnected()
	    ok
	    
	    return 1
	
	def _IsConnected()
	    if len(@acNodes) <= 1
	        return 1
	    ok
	    
	    acVisited = []
	    acQueue = [@acNodes[1]["id"]]
	    acVisited + @acNodes[1]["id"]
	    nIdx = 1
	    
	    while nIdx <= len(acQueue)
	        cCurrent = acQueue[nIdx]
	        
	        acNeighbors = This.Neighbors(cCurrent)
	        acIncoming = This.Incoming(cCurrent)
	        
	        for i = 1 to len(acNeighbors)
	            cNext = acNeighbors[i]
	            if find(acVisited, cNext) = 0
	                acVisited + cNext
	                acQueue + cNext
	            ok
	        end
	        
	        for i = 1 to len(acIncoming)
	            cNext = acIncoming[i]
	            if find(acVisited, cNext) = 0
	                acVisited + cNext
	                acQueue + cNext
	            ok
	        end
	        
	        nIdx += 1
	    end
	    
	    return len(acVisited) = len(@acNodes)
	
	def ConstraintViolations()
	    if NOT HasKey(@acProperties, "constraints")
	        return []
	    ok
	    
	    acViolations = []
	    acConstraints = @acProperties["constraints"]
	    nLen = len(acConstraints)
	    
	    for i = 1 to nLen
	        aConstraint = acConstraints[i]
	        if len(aConstraint["violations"]) > 0
	            acViolations + [
	                :type = aConstraint["type"],
	                :count = len(aConstraint["violations"])
	            ]
	        ok
	    end
	    
	    return acViolations
	

	#------------------------------------------
	#  4. INFERENCE AND IMPLICIT KNOWLEDGE
	#------------------------------------------

	def AddInferenceRule(pcRuleType)
	    if NOT isList(@acProperties)
	        @acProperties = []
	    ok
	    
	    cType = upper(pcRuleType)
	    
	    aRule = [
	        :type = cType,
	        :inferredEdges = []
	    ]
	    
	    if NOT HasKey(@acProperties, "inferenceRules")
	        @acProperties["inferenceRules"] = []
	    ok
	    
	    @acProperties["inferenceRules"] + aRule

	def ApplyInference()
	    if NOT HasKey(@acProperties, "inferenceRules")
	        return 0
	    ok
	    
	    acRules = @acProperties["inferenceRules"]
	    nRuleLen = len(acRules)
	    nInferred = 0
	    
	    for i = 1 to nRuleLen
	        aRule = acRules[i]
	        cType = aRule["type"]
	        
	        if cType = "TRANSITIVITY"
	            nInferred += This._ApplyTransitivity(aRule)
	        ok
	        
	        if cType = "SYMMETRY"
	            nInferred += This._ApplySymmetry(aRule)
	        ok
	        
	        if cType = "COMPOSITION"
	            nInferred += This._ApplyComposition(aRule)
	        ok
	    end
	    
	    return nInferred

	def _ApplyTransitivity(paRule)
		nInferred = 0
		nEdgeLen = len(@acEdges)
		acNewEdges = []
		
		for i = 1 to nEdgeLen
			aEdge1 = @acEdges[i]
			cMidpoint = aEdge1["to"]
			
			for j = 1 to nEdgeLen
				aEdge2 = @acEdges[j]
				if aEdge2["from"] = cMidpoint
					cFrom = aEdge1["from"]
					cTo = aEdge2["to"]
					
					if NOT This.EdgeExists(cFrom, cTo)
						if find(acNewEdges, [cFrom, cTo]) = 0
							acNewEdges + [cFrom, cTo]
							nInferred += 1
						ok
					ok
				ok
			end
		end
		
		nNewLen = len(acNewEdges)
		for i = 1 to nNewLen
			aNewEdge = acNewEdges[i]
			This.AddEdge(aNewEdge[1], aNewEdge[2], "(inferred)")
		end
		
		return nInferred

	def _ApplySymmetry(paRule)
		nInferred = 0
		acNewEdges = []
		nEdgeLen = len(@acEdges)
		
		for i = 1 to nEdgeLen
			aEdge = @acEdges[i]
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			
			if NOT This.EdgeExists(cTo, cFrom)
				if find(acNewEdges, [cTo, cFrom]) = 0
					acNewEdges + [cTo, cFrom]
					nInferred += 1
				ok
			ok
		end
		
		nNewLen = len(acNewEdges)
		for i = 1 to nNewLen
			aNewEdge = acNewEdges[i]
			This.AddEdge(aNewEdge[1], aNewEdge[2], "(inferred-symmetric)")
		end
		
		return nInferred

	def _ApplyComposition(paRule)
		nInferred = 0
		acNewEdges = []
		nEdgeLen = len(@acEdges)
		
		for i = 1 to nEdgeLen
			aEdge1 = @acEdges[i]
			cMidpoint = aEdge1["to"]
			
			for j = 1 to nEdgeLen
				aEdge2 = @acEdges[j]
				if aEdge2["from"] = cMidpoint
					cFrom = aEdge1["from"]
					cTo = aEdge2["to"]
					
					if NOT This.EdgeExists(cFrom, cTo)
						if find(acNewEdges, [cFrom, cTo]) = 0
							acNewEdges + [cFrom, cTo]
							nInferred += 1
						ok
					ok
				ok
			end
		end
		
		nNewLen = len(acNewEdges)
		for i = 1 to nNewLen
			aNewEdge = acNewEdges[i]
			This.AddEdge(aNewEdge[1], aNewEdge[2], "(inferred-composed)")
		end
		
		return nInferred

	def InferredEdges()
		acInferred = []
		nEdgeLen = len(@acEdges)
		
		for i = 1 to nEdgeLen
			aEdge = @acEdges[i]
			if substr(aEdge["label"], "(inferred") > 0
				acInferred + aEdge
			ok
		end
		
		return acInferred

	#------------------------------------------
	#  5. RICH QUERYING
	#------------------------------------------

	def Query(pcPattern)
		if isString(pcPattern)
			return This._QueryByString(pcPattern)
		ok
		
		if isList(pcPattern)
			return This._QueryByList(pcPattern)
		ok
		
		return []

	def _QueryByString(pcPattern)
		acResults = []
		
		if substr(pcPattern, "find_nodes_")
			cNodeType = substr(pcPattern, "find_nodes_", "")
			acResults = This._FindNodesByPattern(cNodeType)
		ok
		
		if substr(pcPattern, "find_paths_")
			acParts = split(pcPattern, "_to_")
			if len(acParts) = 2
				cFrom = trim(acParts[1])
				cTo = trim(acParts[2])
				acResults = This.FindAllPaths(cFrom, cTo)
			ok
		ok
		
		if substr(pcPattern, "connected_to_")
			cNodeId = substr(pcPattern, "connected_to_", "")
			acResults = This.Neighbors(cNodeId)
		ok
		
		return acResults

	def _QueryByList(pacPattern)
		if NOT IsHashList(pacPattern)
			return []
		ok
		
		acResults = []
		
		if HasKey(pacPattern, "nodeType")
			acResults = This._FindNodesByType(pacPattern["nodeType"])
		ok
		
		if HasKey(pacPattern, "edgeLabel")
			acResults = This._FindEdgesByLabel(pacPattern["edgeLabel"])
		ok
		
		if HasKey(pacPattern, "pathFrom") and HasKey(pacPattern, "pathTo")
			acResults = This.FindAllPaths(pacPattern["pathFrom"], pacPattern["pathTo"])
		ok
		
		return acResults

	def _FindNodesByPattern(pcPattern)
		acFound = []
		nLen = len(@acNodes)
		
		for i = 1 to nLen
			aNode = @acNodes[i]
			if HasKey(aNode, "properties")
				acProps = aNode["properties"]
				nPropLen = len(acProps)
				for j = 1 to nPropLen
					if pcPattern $in acProps[j]
						acFound + aNode["id"]
						exit
					ok
				end
			ok
		end
		
		return acFound

	def _FindNodesByType(pcType)
		acFound = []
		nLen = len(@acNodes)
		
		for i = 1 to nLen
			aNode = @acNodes[i]
			if HasKey(aNode, "properties")
				acProps = aNode["properties"]
				if HasKey(acProps, "type")
					if acProps["type"] = pcType
						acFound + aNode["id"]
					ok
				ok
			ok
		end
		
		return acFound

	def _FindEdgesByLabel(pcLabel)
		acFound = []
		nLen = len(@acEdges)
		
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["label"] = pcLabel
				acFound + aEdge
			ok
		end
		
		return acFound

	def FindNodesWhere(pFunc)
		acMatching = []
		nLen = len(@acNodes)
		
		for i = 1 to nLen
			aNode = @acNodes[i]
			if call pFunc(aNode)
				acMatching + aNode["id"]
			ok
		end
		
		return acMatching

		def NodesWhere(pFunc)
			return This.FindNodesWhere(pFunc)

		def NodesWF(pFunc)
			return This.FindNodesWhere(pFunc)

	def FindPathsMatching(pFunc)
		acMatchingPaths = []
		nNodeLen = len(@acNodes)
		
		for i = 1 to nNodeLen
			for j = 1 to nNodeLen
				aNodeI = @acNodes[i]
				aNodeJ = @acNodes[j]
				
				if aNodeI["id"] != aNodeJ["id"]
					acPaths = This.FindAllPaths(aNodeI["id"], aNodeJ["id"])
					nPathLen = len(acPaths)
					
					for k = 1 to nPathLen
						acPath = acPaths[k]
						if call pFunc(acPath)
							acMatchingPaths + acPath
						ok
					end
				ok
			end
		end
		
		return acMatchingPaths

		def PathsMatching(pFunc)
			return This.PathsMatching(pFunc)

		def PathsMatchingF(pFunc)
			return This.PathsMatching(pFunc)

	#------------------------------------------
	#  6. TEMPORAL EVOLUTION
	#------------------------------------------

	def Snapshot(pcName)
		if NOT isList(@acProperties)
			@acProperties = []
		ok
		
		if NOT HasKey(@acProperties, "snapshots")
			@acProperties["snapshots"] = []
		ok
		
		aSnapshot = [
			:name = pcName,
			:timestamp = now(),
			:nodes = This._CopyList(@acNodes),
			:edges = This._CopyList(@acEdges)
		]
		
		@acProperties["snapshots"] + aSnapshot
		return aSnapshot

	def _CopyList(paList)
		acCopy = []
		nLen = len(paList)
		
		for i = 1 to nLen
			if isList(paList[i])
				acCopy + This._CopyList(paList[i])
			but isHash(paList[i])
				acCopy + paList[i].copy()
			else
				acCopy + paList[i]
			ok
		end
		
		return acCopy

	def RestoreSnapshot(pcName)
		if NOT HasKey(@acProperties, "snapshots")
			return 0
		ok
		
		acSnapshots = @acProperties["snapshots"]
		nLen = len(acSnapshots)
		
		for i = 1 to nLen
			aSnapshot = acSnapshots[i]
			if aSnapshot["name"] = pcName
				@acNodes = This._CopyList(aSnapshot["nodes"])
				@acEdges = This._CopyList(aSnapshot["edges"])
				return 1
			ok
		end
		
		return 0

	def ChangesSince(pcSnapshotName)
		if NOT HasKey(@acProperties, "snapshots")
			return []
		ok
		
		acSnapshots = @acProperties["snapshots"]
		aOldSnapshot = NULL
		
		nLen = len(acSnapshots)
		for i = 1 to nLen
			if acSnapshots[i]["name"] = pcSnapshotName
				aOldSnapshot = acSnapshots[i]
				exit
			ok
		end
		
		if aOldSnapshot = NULL
			return []
		ok
		
		acChanges = [
			:nodesAdded = [],
			:nodesRemoved = [],
			:edgesAdded = [],
			:edgesRemoved = []
		]
		
		# Find added nodes
		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			bFound = 0
			nOldLen = len(aOldSnapshot["nodes"])
			for j = 1 to nOldLen
				if aOldSnapshot["nodes"][j]["id"] = aNode["id"]
					bFound = 1
					exit
				ok
			end
			if NOT bFound
				acChanges["nodesAdded"] + aNode["id"]
			ok
		end
		
		# Find removed nodes
		nOldLen = len(aOldSnapshot["nodes"])
		for i = 1 to nOldLen
			aOldNode = aOldSnapshot["nodes"][i]
			bFound = 0
			nLen = len(@acNodes)
			for j = 1 to nLen
				if @acNodes[j]["id"] = aOldNode["id"]
					bFound = 1
					exit
				ok
			end
			if NOT bFound
				acChanges["nodesRemoved"] + aOldNode["id"]
			ok
		end
		
		# Find added edges
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			bFound = 0
			nOldLen = len(aOldSnapshot["edges"])
			for j = 1 to nOldLen
				aOldEdge = aOldSnapshot["edges"][j]
				if aOldEdge["from"] = aEdge["from"] and aOldEdge["to"] = aEdge["to"]
					bFound = 1
					exit
				ok
			end
			if NOT bFound
				acChanges["edgesAdded"] + [aEdge["from"], aEdge["to"]]
			ok
		end
		
		# Find removed edges
		nOldLen = len(aOldSnapshot["edges"])
		for i = 1 to nOldLen
			aOldEdge = aOldSnapshot["edges"][i]
			bFound = 0
			nLen = len(@acEdges)
			for j = 1 to nLen
				aEdge = @acEdges[j]
				if aEdge["from"] = aOldEdge["from"] and aEdge["to"] = aOldEdge["to"]
					bFound = 1
					exit
				ok
			end
			if NOT bFound
				acChanges["edgesRemoved"] + [aOldEdge["from"], aOldEdge["to"]]
			ok
		end
		
		return acChanges

	def ListSnapshots()
		if NOT HasKey(@acProperties, "snapshots")
			return []
		ok
		
		acSnapshots = []
		acSnapshotList = @acProperties["snapshots"]
		nLen = len(acSnapshotList)
		
		for i = 1 to nLen
			acSnapshots + acSnapshotList[i]["name"]
		end
		
		return acSnapshots

	#------------------------------------------
	#  7. EXPORT AND INTEROPERABILITY
	#------------------------------------------

	def ExportDOT()
		cDOT = "digraph " + This.Id() + " {" + nl
		cDOT += "  rankdir=LR;" + nl
		cDOT += "  node [shape=box];" + nl + nl
		
		# Export nodes
		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			cLabel = aNode["label"]
			cDOT += "  " + aNode["id"] + " [label=""" + cLabel + """];" + nl
		end
		
		cDOT += nl
		
		# Export edges
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			cLabel = aEdge["label"]
			cDOT += "  " + aEdge["from"] + " -> " + aEdge["to"]
			if cLabel != ""
				cDOT += " [label=""" + cLabel + """]"
			ok
			cDOT += ";" + nl
		end
		
		cDOT += "}" + nl
		return cDOT

	def ExportJSON()
		aJSON = [
			:id = This.Id(),
			:nodes = @acNodes,
			:edges = @acEdges,
			:metrics = [
				:nodeCount = len(@acNodes),
				:edgeCount = len(@acEdges),
				:density = This.NodeDensity(),
				:longestPath = This.LongestPath(),
				:hasCycles = This.CyclicDependencies()
			]
		]
		return tojson(aJSON)

	def ExportYAML()
		cYAML = "graph: " + This.Id() + nl
		cYAML += "nodes:" + nl
		
		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			cYAML += "  - id: " + aNode["id"] + nl
			cYAML += "    label: " + aNode["label"] + nl
			if len(aNode["properties"]) > 0
				cYAML += "    properties:" + nl
				acProps = aNode["properties"]
				nPropLen = len(acProps)
				for j = 1 to nPropLen
					cYAML += "      - " + string(acProps[j]) + nl
				end
			ok
		end
		
		cYAML += nl + "edges:" + nl
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			cYAML += "  - from: " + aEdge["from"] + nl
			cYAML += "    to: " + aEdge["to"] + nl
			cYAML += "    label: " + aEdge["label"] + nl
		end
		
		return cYAML

	def RegisterExporter(pcName, pFunc)
		if NOT isList(@acProperties)
			@acProperties = []
		ok
		
		if NOT HasKey(@acProperties, "exporters")
			@acProperties["exporters"] = []
		ok
		
		aExporter = [
			:name = pcName,
			:callback = pFunc
		]
		
		@acProperties["exporters"] + aExporter

	def ExportUsing(pcName)
		if NOT HasKey(@acProperties, "exporters")
			return ""
		ok
		
		acExporters = @acProperties["exporters"]
		nLen = len(acExporters)
		
		for i = 1 to nLen
			aExporter = acExporters[i]
			if aExporter["name"] = pcName
				pFunc = aExporter["callback"]
				return call pFunc()
			ok
		end
		
		return ""

	def ListExporters()
		if NOT HasKey(@acProperties, "exporters")
			return []
		ok
		
		acNames = []
		acExporters = @acProperties["exporters"]
		nLen = len(acExporters)
		
		for i = 1 to nLen
			acNames + acExporters[i]["name"]
		end
		
		return acNames
	#------------------------------------------
	#  VISUALIZATION
	#------------------------------------------

	def Show()
		acDisplayNodes = This._PrepareDisplayNodes()
		This._ShowVerticalWithNodes(acDisplayNodes)


	def ShowXT(pacOptions)
		if isString(pacOptions) and pacOptions = ""
			pacOptions = []
		ok
		
		if NOT isList(pacOptions)
			StzRaise("Incorrect param type! pacOptions must be a list.")
		ok

		if len(pacOptions) = 0
			acDisplayNodes = This._PrepareDisplayNodes()
			return This._ShowVerticalWithNodes(acDisplayNodes)
		ok

		if NOT IsHashList(pacOptions)
			StzRaise("Incorrect param type! pacOptions must be a hashlist.")
		ok

		cOrientation = "vertical"
		if HasKey(pacOptions, "orientation")
			cOrientation = pacOptions["orientation"]
		ok
		
		bShowLegend = FALSE
		if HasKey(pacOptions, "Legend")
			bShowLegend = pacOptions["Legend"]
		ok
		
		acDisplayNodes = This._PrepareDisplayNodes()
		
		if cOrientation = "vertical"
			This._ShowVerticalWithNodes(acDisplayNodes)
		else
			This._ShowHorizontalWithNodes(acDisplayNodes)
		ok
		
		if bShowLegend
			acTable = [
				[ :Sign, :Meaning ]
			]

			acLegend = This.Legend()
			nLen = len(acLegend)
			for i = 1 to nLen
				acTable + acLegend[i]
			end

			? ""
			? "Legend:" + NL
			StzTableQ(acTable).Show()
		ok

	def ShowVertical()
		This.Show()

		def ShowV()
			This.Show()

	def ShowHorizontal()
		This.ShowXT([ :orientation = "horizontal" ])

		def ShowH()
			This.ShowXT([ :orientation = "horizontal" ])

	def _PrepareDisplayNodes()
		acBottlenecks = This.BottleneckNodes()
		acCyclic = This._GetCyclicNodes()
		acDisplayNodes = []
		
		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			aDisplayNode = [
				:id = aNode["id"],
				:label = aNode["label"],
				:properties = aNode["properties"]
			]
			
			cLabel = aNode["label"]
			bIsBottleneck = find(acBottlenecks, aNode["id"]) > 0
			bIsCyclic = find(acCyclic, aNode["id"]) > 0
			
			if bIsBottleneck and bIsCyclic
				aDisplayNode["label"] = "!~" + cLabel + "~!"
			but bIsBottleneck
				aDisplayNode["label"] = "!" + cLabel + "!"
			but bIsCyclic
				aDisplayNode["label"] = "~" + cLabel + "~"
			ok
			
			acDisplayNodes + aDisplayNode
		end
		
		return acDisplayNodes

	def _GetCyclicNodes()
		acCyclicNodes = []
		
		# Find all nodes that are part of strongly connected components (cycles)
		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			cNodeId = aNode["id"]
			acReachableFromNode = This._ReachableFromNode(cNodeId)
			
			# Remove starting node from reachable set
			acReachableWithoutStart = []
			nLen2 = len(acReachableFromNode)
			for j = 1 to nLen2
				cReachable = acReachableFromNode[j]
				if cReachable != cNodeId
					acReachableWithoutStart + cReachable
				ok
			end
			
			# If the node can reach itself through other nodes, it's in a cycle
			if find(acReachableWithoutStart, cNodeId) > 0
				if find(acCyclicNodes, cNodeId) = 0
					acCyclicNodes + cNodeId
				ok
			ok
		end

		return acCyclicNodes

	def _ReachableFromNode(pcStartNode)
		acReachable = []
		acVisited = []
		acQueue = [pcStartNode]
		acVisited + pcStartNode
		
		while len(acQueue) > 0
			cCurrent = acQueue[1]
			if len(acQueue) > 1
				acQueue = stzright(acQueue, len(acQueue) - 1)
			else
				acQueue = []
			ok
			acReachable + cCurrent
			
			nLen = len(@acEdges)
			for i = 1 to nLen
				aEdge = @acEdges[i]
				if aEdge["from"] = cCurrent
					cNext = aEdge["to"]
					if find(acVisited, cNext) = 0
						acVisited + cNext
						acQueue + cNext
					ok
				ok
			end
		end
		
		return acReachable

	def _GetDisplayLabel(pcNodeId, pacDisplayNodes)
		nLen = len(pacDisplayNodes)
		for i = 1 to nLen
			aNode = pacDisplayNodes[i]
			if aNode["id"] = pcNodeId
				return aNode["label"]
			ok
		end
		return ""

	def _ShowVerticalWithNodes(pacDisplayNodes)
		acRoots = []
		nNodeCount = len(@acNodes)
		for i = 1 to nNodeCount
			aNode = @acNodes[i]
			if len(This.Incoming(aNode["id"])) = 0
				acRoots + aNode["id"]
			ok
		end
		
		if len(acRoots) = 0
			acRoots + @acNodes[1]["id"]
		ok
		
		nRootIdx = 0
		nLen = len(acRoots)
		for i = 1 to nLen
			cRoot = acRoots[i]
			nRootIdx += 1
			acVisitedPath = []
			This._ShowVerticalBranchWithNodes(cRoot, acVisitedPath, 0, pacDisplayNodes)
			
			if nRootIdx < nLen
				? ""
				? "          ////"
				? ""
			ok
		end

	def _ShowVerticalBranchWithNodes(pcNodeId, pacVisitedPath, pnBranchDepth, pacDisplayNodes)
		cDisplayLabel = This._GetDisplayLabel(pcNodeId, pacDisplayNodes)
		cBoxed = BoxRound(cDisplayLabel)
		acLines = split(cBoxed, nl)
		nLen = len(acLines)
		
		for i = 1 to nLen
			cLine = acLines[i]
			? CenterAlignXT(cLine, 25, " ")
		end
		
		pacVisitedPath + pcNodeId
		acNeighbors = This.Neighbors(pcNodeId)
		
		if len(acNeighbors) = 0
			return
		ok
		
		nNeighborIdx = 0
		nLen = len(acNeighbors)
		for i = 1 to nLen
			cNext = acNeighbors[i]
			nNeighborIdx += 1
			
			if find(pacVisitedPath, cNext) = 0
				aEdge = This.Edge(pcNodeId, cNext)
				
				if len(acNeighbors) > 1 and nNeighborIdx > 1
					? ""
					? "          ////"
					? ""
					cDisplayLabel = This._GetDisplayLabel(pcNodeId, pacDisplayNodes)
					cBoxed = BoxRound(cDisplayLabel)
					acLines = split(cBoxed, nl)
					nLen2 = len(acLines)
					
					for j = 1 to nLen2
						cLine = acLines[j]
						if j = 1
							cTempLine = CenterAlignXT(cLine, 25, " ")
							cTempLine = TrimRight(cTempLine) + "  " + @cArrowUp
							? cTempLine
						but j = 2
							cTempLine = CenterAlignXT(cLine, 25, " ")
							cTempLine = TrimRight(cTempLine) + @cBoxHorizontal + @cBoxHorizontal + @cBoxBottomRight
							? cTempLine
						else
							? CenterAlignXT(cLine, 25, " ")
						ok
					end
				ok
				
				? CenterAlignXT(@cPipeChar, 25, " ")
				if aEdge["label"] != ""
					? CenterAlignXT(aEdge["label"], 25, " ")
					? CenterAlignXT(@cPipeChar, 25, " ")
				ok
				? CenterAlignXT(@cArrowDown, 25, " ")
				
				acCopyPath = pacVisitedPath
				This._ShowVerticalBranchWithNodes(cNext, acCopyPath, pnBranchDepth + 1, pacDisplayNodes)
				
			else
				aEdge = This.Edge(pcNodeId, cNext)
				cNodeLabel = This._GetDisplayLabel(cNext, pacDisplayNodes)
				cArrowLine = RepeatChar(" ", 12) + @cPipeChar + RepeatChar(" ", stzlen("[" + cNodeLabel + "]") + 7) + @cArrowUp
				
				? "            |            "
				? "      <" + @cCycleIndicator + ": " + aEdge["label"] + ">   "
				? cArrowLine
				? "            " + @cBoxBottomLeft + @cBoxHorizontal + @cBoxHorizontal + "> [" + cNodeLabel + "] " + @cBoxHorizontal + @cBoxHorizontal + @cBoxBottomRight
			ok
		end

	def _ShowHorizontalWithNodes(pacDisplayNodes)
		acRoots = []

		nLen = len(@acNodes)
		for i = 1 to nLen
			aNode = @acNodes[i]
			if len(This.Incoming(aNode["id"])) = 0
				acRoots + aNode["id"]
			ok
		end
		
		if len(acRoots) = 0
			acRoots + @acNodes[1]["id"]
		ok
		
		nLen = len(acRoots)
		for i = 1 to nLen
			cRoot = acRoots[i]
			acVisited = []
			acBoxLines = []
			acArrowLines = []
			This._ShowHorizontalBranchWithNodes(cRoot, acVisited, acBoxLines, acArrowLines, pacDisplayNodes)
			
			nLen2 = len(acBoxLines)
			for j = 1 to nLen2
				? acBoxLines[j]
			end
			
			cFeedback = This._BuildFeedbackLineWithNodes(acVisited, "horizontal", pacDisplayNodes)
			if cFeedback != ""
				? cFeedback
			ok
		end

	def _ShowHorizontalBranchWithNodes(pcNodeId, pacVisited, pacBoxLines, pacArrowLines, pacDisplayNodes)
		cDisplayLabel = This._GetDisplayLabel(pcNodeId, pacDisplayNodes)
		cBoxed = BoxRound(cDisplayLabel)
		acLines = split(cBoxed, nl)
		
		acNeighbors = This.Neighbors(pcNodeId)
		
		if len(pacBoxLines) = 0
			nLen = len(acLines)
			for i = 1 to nLen
				pacBoxLines + acLines[i]
			end
		else
			cConnector = ""
			if len(pacVisited) > 0
				cPrev = pacVisited[len(pacVisited)]
				aEdge = This.Edge(cPrev, pcNodeId)
				if aEdge != ""
					cConnector = @cConnectorDash + @cConnectorDash + aEdge["label"] + @cConnectorDash + @cConnectorDash + @cConnectorArrow
				ok
			ok
			
			nLen = len(acLines)
			for i = 1 to nLen
				if i = 2
					pacBoxLines[i] += cConnector + acLines[i]
				else
					pacBoxLines[i] += RepeatChar(" ", stzlen(cConnector)) + acLines[i]
				ok
			end
		ok
		
		pacVisited + pcNodeId
		
		if len(acNeighbors) > 0
			cNext = acNeighbors[1]
			aEdge = This.Edge(pcNodeId, cNext)
			
			if find(pacVisited, cNext) = 0
				This._ShowHorizontalBranchWithNodes(cNext, pacVisited, pacBoxLines, pacArrowLines, pacDisplayNodes)
			else
				pacArrowLines + [pcNodeId, cNext, aEdge["label"]]
			ok
		ok

	def _BuildFeedbackLineWithNodes(pacVisited, pcOrientation, pacDisplayNodes)
		cFeedback = ""
		nLen = len(@acEdges)
		
		for i = 1 to nLen
			aEdge = @acEdges[i]
			nToIdx = find(pacVisited, aEdge["to"])
			nFromIdx = find(pacVisited, aEdge["from"])
			
			if nToIdx > 0 and nFromIdx > 0 and nToIdx < nFromIdx
				if pcOrientation = "horizontal"
					cFeedback = This._BuildHorizontalFeedback(pacVisited, nToIdx, nFromIdx, aEdge, pacDisplayNodes)
				else
					cFeedback = This._BuildVerticalFeedback(pacVisited, nToIdx, nFromIdx, aEdge, pacDisplayNodes)
				ok
			ok
		end

		return cFeedback

	def _BuildVerticalFeedback(pacVisited, pnToIdx, pnFromIdx, paEdge, pacDisplayNodes)
		anBoxWidths = []
		nLen = len(pacVisited)
		for i = 1 to nLen
			cDisplayLabel = This._GetDisplayLabel(pacVisited[i], pacDisplayNodes)
			nBoxW = stzlen(cDisplayLabel) + 4
			anBoxWidths + nBoxW
		end
		
		nToPos = 0
		nToIdx_minus_1 = pnToIdx - 1
		for j = 1 to nToIdx_minus_1
			nToPos += anBoxWidths[j]
			if j < nLen
				cPrev = pacVisited[j]
				cNext = pacVisited[j + 1]
				aE = This.Edge(cPrev, cNext)
				if aE != ""
					nConnectorLen = stzlen(@cConnectorDash + @cConnectorDash + aE["label"] + @cConnectorDash + @cConnectorDash + @cConnectorArrow)
					nToPos += nConnectorLen
				ok
			ok
		end
		if pnToIdx > 0 and pnToIdx <= len(anBoxWidths)
			nToPos += floor(anBoxWidths[pnToIdx] / 2)
		ok
		
		nFromPos = 0
		nFromIdx_minus_1 = pnFromIdx - 1
		for j = 1 to nFromIdx_minus_1
			nFromPos += anBoxWidths[j]
			if j < nLen
				cPrev = pacVisited[j]
				cNext = pacVisited[j + 1]
				aE = This.Edge(cPrev, cNext)
				if aE != ""
					nConnectorLen = stzlen(@cConnectorDash + @cConnectorDash + aE["label"] + @cConnectorDash + @cConnectorDash + @cConnectorArrow)
					nFromPos += nConnectorLen
				ok
			ok
		end
		if pnFromIdx > 0 and pnFromIdx <= len(anBoxWidths)
			nFromPos += floor(anBoxWidths[pnFromIdx] / 2)
		ok
		
		nSpacing = floor(nFromPos - nToPos - 1)
		
		cFirstLine = RepeatChar(" ", nToPos) + @cArrowUp + RepeatChar(" ", nSpacing) + @cPipeChar
		nLineWidth = stzlen(cFirstLine)
		
		nLabelLen = stzlen(paEdge["label"])
		nContentWidth = nLineWidth - nToPos - 2
		nTotalDashes = nContentWidth - nLabelLen - 4
		nLeftDashes = floor(nTotalDashes / 2)
		nRightDashes = nTotalDashes - nLeftDashes						
		cSecondLine = RepeatChar(" ", nToPos) + @cBoxBottomLeft + RepeatChar(@cBoxHorizontal, nLeftDashes) + @cBoxHorizontal + " " + paEdge["label"] + " " + RepeatChar(@cBoxHorizontal, nRightDashes) + @cBoxBottomRight
		
		return cFirstLine + nl + cSecondLine

	def _BuildHorizontalFeedback(pacVisited, pnToIdx, pnFromIdx, paEdge, pacDisplayNodes)
		# For horizontal, we need to count actual characters from rendered output
		# Find positions by counting box widths in the actual visited sequence
		nToPos = 0
		nLen = len(pacVisited)
		
		# Count characters up to "to" node
		for i = 1 to pnToIdx - 1
			cLabel = This._GetDisplayLabel(pacVisited[i], pacDisplayNodes)
			nBoxWidth = stzlen(cLabel) + 4
			nToPos += nBoxWidth
			
			if i < nLen
				cPrev = pacVisited[i]
				cNext = pacVisited[i + 1]
				aE = This.Edge(cPrev, cNext)
				if aE != ""
					nConnectorWidth = stzlen(@cConnectorDash + @cConnectorDash + aE["label"] + @cConnectorDash + @cConnectorDash + @cConnectorArrow)
					nToPos += nConnectorWidth
				ok
			ok
		end
		nToPos += floor((stzlen(This._GetDisplayLabel(pacVisited[pnToIdx], pacDisplayNodes)) + 4) / 2)
		
		nFromPos = 0
		for i = 1 to pnFromIdx - 1
			cLabel = This._GetDisplayLabel(pacVisited[i], pacDisplayNodes)
			nBoxWidth = stzlen(cLabel) + 4
			nFromPos += nBoxWidth
			
			if i < nLen
				cPrev = pacVisited[i]
				cNext = pacVisited[i + 1]
				aE = This.Edge(cPrev, cNext)
				if aE != ""
					nConnectorWidth = stzlen(@cConnectorDash + @cConnectorDash + aE["label"] + @cConnectorDash + @cConnectorDash + @cConnectorArrow)
					nFromPos += nConnectorWidth
				ok
			ok
		end
		nFromPos += floor((stzlen(This._GetDisplayLabel(pacVisited[pnFromIdx], pacDisplayNodes)) + 4) / 2)
		
		nSpacing = floor(nFromPos - nToPos - 1)
		
		cFirstLine = RepeatChar(" ", nToPos) + @cArrowUp + RepeatChar(" ", nSpacing) + @cPipeChar
		nLineWidth = stzlen(cFirstLine)
		
		nLabelLen = stzlen(paEdge["label"])
		nContentWidth = nLineWidth - nToPos - 2
		nTotalDashes = nContentWidth - nLabelLen - 2
		nLeftDashes = floor(nTotalDashes / 2)
		nRightDashes = nTotalDashes - nLeftDashes						
		cSecondLine = RepeatChar(" ", nToPos) + @cBoxBottomLeft + RepeatChar(@cBoxHorizontal, nLeftDashes) + @cBoxHorizontal + paEdge["label"] + @cBoxHorizontal + RepeatChar(@cBoxHorizontal, nRightDashes) + @cBoxBottomRight
		
		# Adjust for width mismatch
		nDiff = stzlen(cSecondLine) - stzlen(cFirstLine)
		if nDiff > 0
			cSecondLine = substr(cSecondLine, @cBoxHorizontal + @cBoxBottomRight, @cBoxBottomRight)
		but nDiff < 0
			cSecondLine = substr(cSecondLine, @cBoxBottomRight, @cBoxHorizontal + @cBoxBottomRight)
		ok
		
		return cFirstLine + nl + cSecondLine


	def ShowWithLegend()
		This.ShowXT([ :Legend = TRUE ])

	def Legend()
		acBottlenecks = This.BottleneckNodes()
		acCyclic = This._GetCyclicNodes()
		aoLegend = []
		
		if len(acBottlenecks) > 0
			aoLegend[:bottleneck] = [ "!label!", "High connectivity hub (bottleneck)" ]
		ok
		
		if len(acCyclic) > 0
			aoLegend[:cyclic] = [ "~label~", "Participates in cycle" ]
		ok
		
		if len(acBottlenecks) > 0 and len(acCyclic) > 0
			aoLegend[:both] = [ "!~label~!", "Hub with cyclic dependency" ]
		ok
		
		if This.CyclicDependencies()
			aoLegend[:feedback] = [ "[...] ↑", "Feedback loop" ]
			aoLegend[:branch] = [ "////", "Branch separator (multiple paths)" ]
		ok
		
		if len(aoLegend) = 0
			aoLegend[:normal] = [ "label", "Regular node" ]
		ok
		
		return aoLegend

	def Explain()
		aoExplanation = [
			:general = [],
			:bottlenecks = [],
			:cycles = [],
			:metrics = []
		]
		
		acBottlenecks = This.BottleneckNodes()
		acCyclic = This._GetCyclicNodes()
		
		# General section
		aoExplanation[:general] + ("Graph: " + This.Id())
		aoExplanation[:general] + ("Nodes: " + len(@acNodes) + " | Edges: " + len(@acEdges))
		
		# Bottlenecks section
		if len(acBottlenecks) > 0
			nTotalDegree = 0
			nLen = len(@acNodes)
			for i = 1 to nLen
				aNode = @acNodes[i]
				nIncoming = len(This.Incoming(aNode["id"]))
				nOutgoing = len(This.Neighbors(aNode["id"]))
				nTotalDegree += nIncoming + nOutgoing
			end
			nAvgDegree = nTotalDegree / len(@acNodes)
			
			aoExplanation[:bottlenecks] + ("Bottleneck nodes: " + joinXT(acBottlenecks, ", "))
			aoExplanation[:bottlenecks] + ("Average degree: " + nAvgDegree)
			
			nLen = len(acBottlenecks)
			for i = 1 to nLen
				cNode = acBottlenecks[i]
				nIncoming = len(This.Incoming(cNode))
				nOutgoing = len(This.Neighbors(cNode))
				nDegree = nIncoming + nOutgoing
				aoExplanation[:bottlenecks] + ("  " + cNode + ": degree " + nDegree + " (above average)")
			end
		else
			nTotalDegree = 0
			nLen = len(@acNodes)
			for i = 1 to nLen
				aNode = @acNodes[i]
				nIncoming = len(This.Incoming(aNode["id"]))
				nOutgoing = len(This.Neighbors(aNode["id"]))
				nTotalDegree += nIncoming + nOutgoing
			end
			nAvgDegree = nTotalDegree / len(@acNodes)
			aoExplanation[:bottlenecks] + ("No bottlenecks (average degree = " + nAvgDegree + ")")
		ok
		
		# Cycles section
		if len(acCyclic) > 0
			aoExplanation[:cycles] + ("Cyclic nodes: " + join(acCyclic, ", "))
			nLen = len(acCyclic)
			for i = 1 to nLen
				cNode = acCyclic[i]
				aoExplanation[:cycles] + ("  " + cNode + " can reach itself")
			end
		ok
		
		if This.CyclicDependencies()
			aoExplanation[:cycles] + "WARNING: Circular dependencies detected"
		else
			if len(acCyclic) = 0
				aoExplanation[:cycles] + "No cycles - acyclic graph (DAG)"
			ok
		ok
		
		# Metrics section
		nDensity = This.NodeDensity()
		if nDensity = 0
			aoExplanation[:metrics] + "Density: 0% (no connections)"
		but nDensity < 25
			aoExplanation[:metrics] + ("Density: " + nDensity + "% (sparse)")
		but nDensity < 50
			aoExplanation[:metrics] + ("Density: " + nDensity + "% (moderate)")
		but nDensity < 75
			aoExplanation[:metrics] + ("Density: " + nDensity + "% (dense)")
		else
			aoExplanation[:metrics] + ("Density: " + nDensity + "% (very dense)")
		ok
		
		nLongest = This.LongestPath()
		if nLongest = 0
			aoExplanation[:metrics] + "Longest path: 0 hops (isolated)"
		but nLongest = 1
			aoExplanation[:metrics] + "Longest path: 1 hop"
		else
			aoExplanation[:metrics] + ("Longest path: " + nLongest + " hops")
		ok
		
		return aoExplanation
