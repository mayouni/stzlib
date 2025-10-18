#============================================#
#  stzGraph - FUNDAMENTAL GRAPH ABSTRACTION  #
#  Pure computational thinking construct     #
#============================================#

class stzGraph

	@cId = ""
	@aNodes = []
	@aEdges = []
	@aProperties = []

	def init(pId)
		@cId = pId
		@aNodes = []
		@aEdges = []
		@aProperties = []

	def Id()
		return @cId

	#------------------------------------------
	#  NODE OPERATIONS
	#------------------------------------------

	def AddNode(pcNodeId, pcLabel)
		This.AddNodeXT(pcNodeId, pcLabel, [])

	def AddNodeXT(pcNodeId, pcLabel, paProperties)
		aNode = [
			:id = pcNodeId,
			:label = pcLabel,
			:properties = iif(isList(paProperties), paProperties, [])
		]
		@aNodes + aNode

	def Node(pcNodeId)
		for aNode in @aNodes
			if HasKey(aNode, "id") and aNode["id"] = pcNodeId
				return aNode
			ok
		end

	def NodeExists(pcNodeId)
		return This.Node(pcNodeId) != ""

	def RemoveNode(pcNodeId)
		aNew = []
		for aNode in @aNodes
			if HasKey(aNode, "id") and aNode["id"] != pcNodeId
				aNew + aNode
			ok
		end
		@aNodes = aNew
		
		aNewEdges = []
		for aEdge in @aEdges
			if HasKey(aEdge, "from") and aEdge["from"] != pcNodeId and
			   HasKey(aEdge, "to") and aEdge["to"] != pcNodeId

				aNewEdges + aEdge
			ok
		end
		@aEdges = aNewEdges

	def AllNodes()
		return @aNodes

	def NodeCount()
		return len(@aNodes)

	#-------------------#
	#  EDGE OPERATIONS  #
	#-------------------#

	def AddEdge(pcFromId, pcToId, pcLabel)
		This.AddEdgeXT(pcFromId, pcToId, pcLabel, [])

	def AddEdgeXT(pcFromId, pcToId, pcLabel, paProperties)
		if NOT This.NodeExists(pcFromId) or NOT This.NodeExists(pcToId)
			return 0
		ok

		aEdge = [
			:from = pcFromId,
			:to = pcToId,
			:label = pcLabel,
			:properties = iif(isList(paProperties), paProperties, [])
		]
		@aEdges + aEdge
		return 1

	def Edge(pcFromId, pcToId)
	
		for aEdge in @aEdges
			if HasKey(aEdge, "from") and aEdge["from"] = pcFromId and
			   HasKey(aEdge, "to") and aEdge["to"] = pcToId
				return aEdge
			ok
		end

	def EdgeExists(pcFromId, pcToId)
		return This.Edge(pcFromId, pcToId) != ""

	def RemoveEdge(pcFromId, pcToId)
		aNew = []
		for aEdge in @aEdges
			if NOT ( HasKey(aEdge, "from") and aEdge["from"] = pcFromId and	
			   HasKey(aEdge, "to") and aEdge["to"] = pcToId )

				aNew + aEdge
			ok
		end
		@aEdges = aNew

	def AllEdges()
		return @aEdges

	def EdgeCount()
		return len(@aEdges)

	#---------------------------#
	#  TRAVERSAL & PATHFINDING  #
	#---------------------------#

	def PathExists(pcFromId, pcToId)
		if pcFromId = pcToId
			return 1
		ok
		aVisited = []
		return This.PrivatePathExistsDFS(pcFromId, pcToId, aVisited)

	def PrivatePathExistsDFS(pcCurrent, pcTarget, paVisited)
		if pcCurrent = pcTarget
			return 1
		ok

		if find(paVisited, pcCurrent) > 0
			return 0
		ok

		paVisited + pcCurrent

		for aEdge in @aEdges
			if HasKey(aEdge, "from") and aEdge["from"] = pcCurrent
				if HasKey(aEdge, "to") and
				   This.PrivatePathExistsDFS(aEdge["to"], pcTarget, paVisited)
					return 1
				ok
			ok
		end

		return 0

	def FindAllPaths(pcFromId, pcToId)
		aAllPaths = []
		aCurrentPath = [pcFromId]
		This.PrivateFindAllPathsDFS(pcFromId, pcToId, aCurrentPath, aAllPaths, 0)
		return aAllPaths
	
	def PrivateFindAllPathsDFS(pcCurrent, pcTarget, paCurrentPath, paAllPaths, pnDepth)
		
		if pnDepth > 10
			return
		ok
	
		if pcCurrent = pcTarget
			paAllPaths + paCurrentPath
			return
		ok
	
		for aEdge in @aEdges
			if HasKey(aEdge, "from") and aEdge["from"] = pcCurrent
				if HasKey(aEdge, "to")
					cNext = aEdge["to"]
					
					if find(paCurrentPath, cNext) = 0
						paCurrentPath + cNext
						This.PrivateFindAllPathsDFS(cNext, pcTarget, paCurrentPath, paAllPaths, pnDepth + 1)
						paCurrentPath = stzleft(paCurrentPath, len(paCurrentPath) - 1)
					ok
				ok
			ok
		end


	def Neighbors(pcNodeId)
		if CheckParams()
			if isList(pcNodeId) and StzListQ(pcNodeId).IsOfOrToNamedParam()
				pcNodeId = pcNodeId[2]
			ok
		ok

		aNeighbors = []
		for aEdge in @aEdges
			if HasKey(aEdge, "from") and aEdge["from"] = pcNodeId and
			   HasKey(aEdge, "to")
				aNeighbors + aEdge["to"]
			ok
		end
		return aNeighbors

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

		aIncoming = []
		for aEdge in @aEdges
			if HasKey(aEdge, "to") and aEdge["to"] = pcNodeId and
			   HasKey(aEdge, "from")
				aIncoming + aEdge["from"]
			ok
		end
		return aIncoming

		def IncomingTo(pcNodeId)
			return This.Incoming(pcNodeId)

	#------------------------------------------
	#  CYCLE DETECTION
	#------------------------------------------

	def CyclicDependencies()
		aVisited = []
		aRecStack = []

		for aNode in @aNodes
			if HasKey(aNode, "id") and find(aVisited, aNode["id"]) = 0
				if This.PrivateHasCycleDFS(aNode["id"], aVisited, aRecStack)
					return 1
				ok
			ok
		end

		return 0

	def PrivateHasCycleDFS(pNode, paVisited, pRecStack)
		paVisited + pNode
		pRecStack + pNode

		for aEdge in @aEdges
			if HasKey(aEdge, "from") and aEdge["from"] = pNode
				if HasKey(aEdge, "to") and find(paVisited, aEdge["to"]) = 0
					if This.PrivateHasCycleDFS(aEdge["to"], paVisited, pRecStack)
						return 1
					ok
				but find(pRecStack, aEdge["to"]) > 0
					return 1
				ok
			ok
		end

		nLen = len(pRecStack)
		if nLen > 1
			pRecStack = stzleft(pRecStack, len(pRecStack) - 1)
		ok

		return 0

	#------------------------------------------
	#  REACHABILITY & CONNECTIVITY
	#------------------------------------------

	def ReachableFrom(pcNodeId)
		aReachable = []
		aVisited = []
		This.PrivateReachableBFS(pcNodeId, aReachable, aVisited)
		return aReachable

	
	def PrivateReachableBFS(pcNodeId, pReachable, paVisited)
		aQueue = [pcNodeId]
		paVisited + pcNodeId
		nQueueLen = 1
	
		while nQueueLen > 0
			cCurrent = aQueue[1]
			if nQueueLen > 1
				aQueue = stzright(aQueue, nQueueLen - 1)
			else
				aQueue = []
			ok
			nQueueLen = nQueueLen - 1
			pReachable + cCurrent
	
			for cNeighbor in This.Neighbors(cCurrent)
				if find(paVisited, cNeighbor) = 0
					paVisited + cNeighbor
					aQueue + cNeighbor
					nQueueLen = nQueueLen + 1
				ok
			end
		end

	#------------------------------------------
	#  ANALYSIS METRICS
	#------------------------------------------

	def BottleneckNodes()
		aBottlenecks = []
		nTotalDegree = 0
		
		# Calculate average degree
		for aNode in @aNodes
			nIncoming = len(This.Incoming(aNode["id"]))
			nOutgoing = len(This.Neighbors(aNode["id"]))
			nTotalDegree += nIncoming + nOutgoing
		end
		
		nAvgDegree = nTotalDegree / len(@aNodes)
		
		# Mark nodes above average
		for aNode in @aNodes
			nIncoming = len(This.Incoming(aNode["id"]))
			nOutgoing = len(This.Neighbors(aNode["id"]))
			nDegree = nIncoming + nOutgoing
			
			if nDegree > nAvgDegree
				aBottlenecks + aNode["id"]
			ok
		end
		
		return aBottlenecks

	def NodeDensity()
		nNodes = len(@aNodes)
		nEdges = len(@aEdges)

		if nNodes <= 1
			return 0
		ok

		nMaxEdges = nNodes * (nNodes - 1)
		return (nEdges * 100) / nMaxEdges

	def LongestPath()
		nMax = 0

		for aNode in @aNodes
			aReachable = This.ReachableFrom(aNode["id"])
			nLength = len(aReachable) - 1

			if nLength > nMax
				nMax = nLength
			ok
		end

		return nMax

	#------------------------------------------
	#  VISUALIZATION
	#------------------------------------------

	def Show()
		aDisplayNodes = This.PrivatePrepareDisplayNodes()
		This.ShowVerticalWithNodes(aDisplayNodes)


	def ShowXT(paOptions)
		if isString(paOptions) and paOptions = ""
			paOptions = []
		ok
		
		if NOT isList(paOptions)
			StzRaise("Incorrect param type! paOptions must be a list.")
		ok

		if len(paOptions) = 0
			aDisplayNodes = This.PrivatePrepareDisplayNodes()
			return This.ShowVerticalWithNodes(aDisplayNodes)
		ok

		if NOT IsHashList(paOptions)
			StzRaise("Incorrect param type! paOptions must be a hashlist.")
		ok

		cOrientation = "vertical"
		if HasKey(paOptions, "orientation")
			cOrientation = paOptions["orientation"]
		ok
		
		bShowLegend = FALSE
		if HasKey(paOptions, "Legend")
			bShowLegend = paOptions["Legend"]
		ok
		
		aDisplayNodes = This.PrivatePrepareDisplayNodes()
		
		if cOrientation = "vertical"
			This.ShowVerticalWithNodes(aDisplayNodes)
		else
			This.ShowHorizontalWithNodes(aDisplayNodes)
		ok
		
		if bShowLegend
			aTable = [
				[ :Sign, :Meaning ]
			]

			aLegend = This.Legend()

			for aSign in aLegend
				aTable + aSign[2]
			end

			? ""
			? "Legend:" + NL
			StzTableQ(aTable).Show()
		ok

	def ShowVertical()
		This.Show()

		def ShowV()
			This.Show()

	def ShowHorizontal()
		This.ShowXT([ :orientation = "horizontal" ])

		def ShowH()
			This.ShowXT([ :orientation = "horizontal" ])

	def PrivatePrepareDisplayNodes()
		aBottlenecks = This.BottleneckNodes()
		aCyclic = This.PrivateGetCyclicNodes()
		aDisplayNodes = []
		
		for aNode in @aNodes
			aDisplayNode = [
				:id = aNode["id"],
				:label = aNode["label"],
				:properties = aNode["properties"]
			]
			
			cLabel = aNode["label"]
			lIsBottleneck = find(aBottlenecks, aNode["id"]) > 0
			lIsCyclic = find(aCyclic, aNode["id"]) > 0
			
			if lIsBottleneck and lIsCyclic
				aDisplayNode["label"] = "!~" + cLabel + "~!"
			but lIsBottleneck
				aDisplayNode["label"] = "!" + cLabel + "!"
			but lIsCyclic
				aDisplayNode["label"] = "~" + cLabel + "~"
			ok
			
			aDisplayNodes + aDisplayNode
		end
		
		return aDisplayNodes

	def PrivateGetCyclicNodes()
		aCyclicNodes = []
		
		# Find all nodes that are part of strongly connected components (cycles)
		for aNode in @aNodes
			if HasKey(aNode, "id")
				cNodeId = aNode["id"]
				aReachableFromNode = This.PrivateReachableFromNode(cNodeId)
				
				# Remove starting node from reachable set
				aReachableWithoutStart = []
				for cReachable in aReachableFromNode
					if cReachable != cNodeId
						aReachableWithoutStart + cReachable
					ok
				end
				
				# If the node can reach itself through other nodes, it's in a cycle
				if find(aReachableWithoutStart, cNodeId) > 0
					if find(aCyclicNodes, cNodeId) = 0
						aCyclicNodes + cNodeId
					ok
				ok
			ok
		end

		return aCyclicNodes

	def PrivateReachableFromNode(pcStartNode)
		aReachable = []
		aVisited = []
		aQueue = [pcStartNode]
		aVisited + pcStartNode
		
		while len(aQueue) > 0
			cCurrent = aQueue[1]
			if len(aQueue) > 1
				aQueue = stzright(aQueue, len(aQueue) - 1)
			else
				aQueue = []
			ok
			aReachable + cCurrent
			
			for aEdge in @aEdges
				if HasKey(aEdge, "from") and aEdge["from"] = cCurrent
					if HasKey(aEdge, "to")
						cNext = aEdge["to"]
						if find(aVisited, cNext) = 0
							aVisited + cNext
							aQueue + cNext
						ok
					ok
				ok
			end
		end
		
		return aReachable

	def PrivateGetDisplayLabel(pcNodeId, paDisplayNodes)
		for aNode in paDisplayNodes
			if HasKey(aNode, "id") and aNode["id"] = pcNodeId
				return aNode["label"]
			ok
		end
		return ""

	def ShowVerticalWithNodes(paDisplayNodes)
		aRoots = []
		nNodeCount = len(@aNodes)
		for i = 1 to nNodeCount
			aNode = @aNodes[i]
			if len(This.Incoming(aNode["id"])) = 0
				aRoots + aNode["id"]
			ok
		end
		
		if len(aRoots) = 0
			aRoots + @aNodes[1]["id"]
		ok
		
		nRootIdx = 0
		for cRoot in aRoots
			nRootIdx += 1
			aVisitedPath = []
			This.PrivateShowVerticalBranchWithNodes(cRoot, aVisitedPath, 0, paDisplayNodes)
			
			if nRootIdx < len(aRoots)
				? ""
				? "          ////"
				? ""
			ok
		end

	def PrivateShowVerticalBranchWithNodes(pcNodeId, paVisitedPath, pnBranchDepth, paDisplayNodes)
		cDisplayLabel = This.PrivateGetDisplayLabel(pcNodeId, paDisplayNodes)
		cBoxed = BoxRound(cDisplayLabel)
		aLines = StzStringQ(cBoxed).Split(nl)
		
		for cLine in aLines
			? CenterAlignXT(cLine, 25, " ")
		end
		
		paVisitedPath + pcNodeId
		aNeighbors = This.Neighbors(pcNodeId)
		
		if len(aNeighbors) = 0
			return
		ok
		
		nNeighborIdx = 0
		for cNext in aNeighbors
			nNeighborIdx += 1
			
			if find(paVisitedPath, cNext) = 0
				aEdge = This.Edge(pcNodeId, cNext)
				
				if len(aNeighbors) > 1 and nNeighborIdx > 1
					? ""
					? "          ////"
					? ""
					cDisplayLabel = This.PrivateGetDisplayLabel(pcNodeId, paDisplayNodes)
					cBoxed = BoxRound(cDisplayLabel)
					aLines = StzStringQ(cBoxed).Split(nl)
					
					for i = 1 to len(aLines)
						if i = 1
							cTempLine = CenterAlignXT(aLines[i], 25, " ")
							cTempLine = TrimRight(cTempLine) + "  ↑"
							? cTempLine
						but i = 2
							cTempLine = CenterAlignXT(aLines[i], 25, " ")
							cTempLine = TrimRight(cTempLine) +  + "──╯"
							? cTempLine
						else
							? CenterAlignXT(aLines[i], 25, " ")
						ok
					end
				ok
				
				? CenterAlignXT("|", 25, " ")
				if aEdge["label"] != ""
					? CenterAlignXT(aEdge["label"], 25, " ")
					? CenterAlignXT("|", 25, " ")
				ok
				? CenterAlignXT("v", 25, " ")
				
				aCopyPath = paVisitedPath
				This.PrivateShowVerticalBranchWithNodes(cNext, aCopyPath, pnBranchDepth + 1, paDisplayNodes)
				
			else
				aEdge = This.Edge(pcNodeId, cNext)
				cNodeLabel = This.PrivateGetDisplayLabel(cNext, paDisplayNodes)
				cArrowLine = RepeatChar(" ", 12) + "|" + RepeatChar(" ", stzlen("[" + cNodeLabel + "]") + 7) + "↑"
				
				? "            |            "
				? "      <CYCLE: " + aEdge["label"] + ">   "
				? cArrowLine
				? "            ╰──> [" + cNodeLabel + "] ──╯"
			ok
		end

	def ShowHorizontalWithNodes(paDisplayNodes)
		aRoots = []

		for aNode in @aNodes
			if len(This.Incoming(aNode["id"])) = 0
				aRoots + aNode["id"]
			ok
		end
		
		if len(aRoots) = 0
			aRoots + @aNodes[1]["id"]
		ok
		
		for cRoot in aRoots
			aVisited = []
			aBoxLines = []
			aArrowLines = []
			This.PrivateShowHorizontalBranchWithNodes(cRoot, aVisited, aBoxLines, aArrowLines, paDisplayNodes)
			
			for cLine in aBoxLines
				? cLine
			end
			
			cFeedback = This.PrivateBuildFeedbackLineWithNodes(aVisited, "horizontal", paDisplayNodes)
			if cFeedback != ""
				? cFeedback
			ok
		end

	def PrivateShowHorizontalBranchWithNodes(pcNodeId, paVisited, paBoxLines, paArrowLines, paDisplayNodes)
		cDisplayLabel = This.PrivateGetDisplayLabel(pcNodeId, paDisplayNodes)
		cBoxed = BoxRound(cDisplayLabel)
		aLines = StzStringQ(cBoxed).Split(nl)
		
		aNeighbors = This.Neighbors(pcNodeId)
		
		if len(paBoxLines) = 0
			for cLine in aLines
				paBoxLines + cLine
			end
		else
			cConnector = ""
			if len(paVisited) > 0
				cPrev = paVisited[len(paVisited)]
				aEdge = This.Edge(cPrev, pcNodeId)
				if aEdge != ""
					cConnector = "--" + aEdge["label"] + "-->"
				ok
			ok
			
			for i = 1 to len(aLines)
				if i = 2
					paBoxLines[i] += cConnector + aLines[i]
				else
					paBoxLines[i] += RepeatChar(" ", len(cConnector)) + aLines[i]
				ok
			end
		ok
		
		paVisited + pcNodeId
		
		if len(aNeighbors) > 0
			cNext = aNeighbors[1]
			aEdge = This.Edge(pcNodeId, cNext)
			cEdgeLabel = aEdge["label"]
			
			if find(paVisited, cNext) = 0
				This.PrivateShowHorizontalBranchWithNodes(cNext, paVisited, paBoxLines, paArrowLines, paDisplayNodes)
			else
				paArrowLines + [pcNodeId, cNext, cEdgeLabel]
			ok
		ok

	def PrivateBuildFeedbackLineWithNodes(paVisited, pcOrientation, paDisplayNodes)
		cFeedback = ""
		
		for aEdge in @aEdges
			if HasKey(aEdge, "from") and HasKey(aEdge, "to")
				if find(paVisited, aEdge["from"]) > 0 and find(paVisited, aEdge["to"]) > 0
					if find(paVisited, aEdge["to"]) < find(paVisited, aEdge["from"])
						nToIdx = find(paVisited, aEdge["to"])
						nFromIdx = find(paVisited, aEdge["from"])
						
						aBoxWidths = []
						for i = 1 to len(paVisited)
							cDisplayLabel = This.PrivateGetDisplayLabel(paVisited[i], paDisplayNodes)
							nBoxW = len(cDisplayLabel) + 4
							aBoxWidths + nBoxW
						end
						
						nToPos = 0
						for i = 1 to nToIdx - 1
							nToPos += aBoxWidths[i]
							if i < len(paVisited)
								cPrev = paVisited[i]
								cNext = paVisited[i + 1]
								aE = This.Edge(cPrev, cNext)
								if aE != ""
									nToPos += len("--" + aE["label"] + "-->")
								ok
							ok
						end
						nToPos += aBoxWidths[nToIdx] / 2
						
						nFromPos = 0
						for i = 1 to nFromIdx - 1
							nFromPos += aBoxWidths[i]
							if i < len(paVisited)
								cPrev = paVisited[i]
								cNext = paVisited[i + 1]
								aE = This.Edge(cPrev, cNext)
								if aE != ""
									nFromPos += len("--" + aE["label"] + "-->")
								ok
							ok
						end
						nFromPos += aBoxWidths[nFromIdx] / 2
						
						nSpacing = nFromPos - nToPos - 1
						
						cFirstLine = RepeatChar(" ", nToPos) + "↑" + RepeatChar(" ", nSpacing) + "|"
						nLineWidth = len(cFirstLine)
						
						nLabelLen = len(aEdge["label"])
						nContentWidth = nLineWidth - nToPos - 2
						nTotalDashes = nContentWidth - nLabelLen - 2
						nLeftDashes = nTotalDashes / 2
						nRightDashes = nTotalDashes - nLeftDashes						
						cSecondLine = RepeatChar(" ", nToPos) + "╰" + RepeatChar("─", nLeftDashes) + "─" + aEdge["label"] + "─" + RepeatChar("─", nRightDashes) + "╯"
						
						cFeedback = cFirstLine + nl + cSecondLine
						
					ok
				ok
			ok
		end

		if NOT pcOrientation = "horizontal"
			return cFeedback
		ok

		acSplits = @split(cFeedback, nl)
		nLenLine1 = stzlen(acSplits[1])
		nLenLine2 = stzlen(acSplits[2])
		
		nDiff = nLenLine2 - nLenLine1
		if nDiff = 0
			return cFeedback
		ok
		
		if nDiff > 0
			cLine2 = substr(acSplits[2], "─╯", "╯")
		else
			cLine2 = substr(acSplits[2], "╯", "─╯")
		ok
		
		return acSplits[1] + nl + cLine2


	def ShowWithLegend()
		This.ShowXT([ :Legend = TRUE ])

	def Legend()
		aBottlenecks = This.BottleneckNodes()
		aCyclic = This.PrivateGetCyclicNodes()
		aLegend = []
		
		if len(aBottlenecks) > 0
			aLegend[:bottleneck] = [ "!label!", "High connectivity hub (bottleneck)" ]
		ok
		
		if len(aCyclic) > 0
			aLegend[:cyclic] = [ "~label~", "Participates in cycle" ]
		ok
		
		if len(aBottlenecks) > 0 and len(aCyclic) > 0
			aLegend[:both] = [ "!~label~!", "Hub with cyclic dependency" ]
		ok
		
		if This.CyclicDependencies()
			aLegend[:feedback] = [ "[...] __↑", "Feedback loop" ]
			aLegend[:branch] = [ "////", "Branch separator (multiple paths)" ]
		ok
		
		if len(aLegend) = 0
			aLegend[:normal] = [ "label", "Regular node" ]
		ok
		
		return aLegend

	def Explain()
		aExplanation = [
			:general = [],
			:bottlenecks = [],
			:cycles = [],
			:metrics = []
		]
		
		aBottlenecks = This.BottleneckNodes()
		aCyclic = This.PrivateGetCyclicNodes()
		
		# General section
		aExplanation[:general] + ("Graph: " + This.Id())
		aExplanation[:general] + ("Nodes: " + len(@aNodes) + " | Edges: " + len(@aEdges))
		
		# Bottlenecks section
		if len(aBottlenecks) > 0
			nTotalDegree = 0
			for aNode in @aNodes
				nIncoming = len(This.Incoming(aNode["id"]))
				nOutgoing = len(This.Neighbors(aNode["id"]))
				nTotalDegree += nIncoming + nOutgoing
			end
			nAvgDegree = nTotalDegree / len(@aNodes)
			
			aExplanation[:bottlenecks] + ("Bottleneck nodes: " + JoinXT(aBottlenecks, ", "))
			aExplanation[:bottlenecks] + ("All nodes have average degree " + nAvgDegree)
			
			for cNode in aBottlenecks
				nIncoming = len(This.Incoming(cNode))
				nOutgoing = len(This.Neighbors(cNode))
				nDegree = nIncoming + nOutgoing
				aExplanation[:bottlenecks] + ("  " + cNode + ": degree " + nDegree + " (above average)")
			end
		else
			nTotalDegree = 0
			for aNode in @aNodes
				nIncoming = len(This.Incoming(aNode["id"]))
				nOutgoing = len(This.Neighbors(aNode["id"]))
				nTotalDegree += nIncoming + nOutgoing
			end
			nAvgDegree = nTotalDegree / len(@aNodes)
			aExplanation[:bottlenecks] + ("No bottlenecks (average degree = " + nAvgDegree + ")")
		ok
		
		# Cycles section
		if len(aCyclic) > 0
			aExplanation[:cycles] + ("Cyclic nodes: " + JoinXT(aCyclic, ", "))
			for cNode in aCyclic
				aExplanation[:cycles] + ("  " + cNode + " can reach itself")
			end
		ok
		
		if This.CyclicDependencies()
			aExplanation[:cycles] + "WARNING: Circular dependencies detected"
		else
			if len(aCyclic) = 0
				aExplanation[:cycles] + "No cycles - acyclic graph (DAG)"
			ok
		ok
		
		# Metrics section
		nDensity = This.NodeDensity()
		if nDensity = 0
			aExplanation[:metrics] + "Density: 0% (no connections)"
		but nDensity < 25
			aExplanation[:metrics] + ("Density: " + nDensity + "% (sparse)")
		but nDensity < 50
			aExplanation[:metrics] + ("Density: " + nDensity + "% (moderate)")
		but nDensity < 75
			aExplanation[:metrics] + ("Density: " + nDensity + "% (dense)")
		else
			aExplanation[:metrics] + ("Density: " + nDensity + "% (very dense)")
		ok
		
		nLongest = This.LongestPath()
		if nLongest = 0
			aExplanation[:metrics] + "Longest path: 0 hops (isolated)"
		but nLongest = 1
			aExplanation[:metrics] + "Longest path: 1 hop"
		else
			aExplanation[:metrics] + ("Longest path: " + nLongest + " hops")
		ok
		
		return aExplanation
