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
		oNode = [
			:id = pcNodeId,
			:label = pcLabel,
			:properties = iif(isList(paProperties), paProperties, [])
		]
		@aNodes + oNode

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

	#------------------------------------------
	#  EDGE OPERATIONS
	#------------------------------------------

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

	#------------------------------------------
	#  TRAVERSAL & PATHFINDING
	#------------------------------------------

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
	? "DEBUG: Depth=" + pnDepth + " Current=" + pcCurrent + " Path=" + @@(paCurrentPath)
	
	if pnDepth > 10
		? "DEBUG: DEPTH LIMIT EXCEEDED"
		return
	ok

	if pcCurrent = pcTarget
		? "DEBUG: FOUND PATH: " + @@(paCurrentPath)
		paAllPaths + paCurrentPath
		return
	ok

	for aEdge in @aEdges
		if HasKey(aEdge, "from") and aEdge["from"] = pcCurrent
			if HasKey(aEdge, "to")
				cNext = aEdge["to"]
				? "DEBUG: Checking edge " + pcCurrent + " -> " + cNext + " (in path: " + (find(paCurrentPath, cNext) > 0) + ")"
				
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
		nMaxDegree = 0

		for oNode in @aNodes
			nIncoming = len(This.Incoming(oNode["id"]))
			nOutgoing = len(This.Neighbors(oNode["id"]))
			nDegree = nIncoming + nOutgoing

			if nDegree > nMaxDegree
				nMaxDegree = nDegree
				aBottlenecks = [oNode["id"]]
			but nDegree = nMaxDegree and nDegree > 1
				aBottlenecks + oNode["id"]
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

		for oNode in @aNodes
			aReachable = This.ReachableFrom(oNode["id"])
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
		This.ShowVertical()

	def ShowXT(paOptions)
		if isString(paOptions) and paOptions = ""
			paOptions = []
		ok
		
		if NOT isList(paOptions)
			StzRaise("Incorrect param type! paOptions must be a list.")
		ok

		if len(paOptions) = 0
			return This.ShowVertical()
		ok

		if NOT IsHashList(paOptions)
			StzRaise("Incorrect param type! paOptions must be a hashlist.")
		ok

		cOrientation = "vertical"
		if HasKey(paOptions, "orientation")
			cOrientation = paOptions["orientation"]
		ok
		
		if cOrientation = "vertical"
			This.ShowVertical()
		else
			This.ShowHorizontal()
		ok

	def ShowVertical()
		aRoots = []
		nNodeCount = len(@aNodes)
		for i = 1 to nNodeCount
			oNode = @aNodes[i]
			if len(This.Incoming(oNode["id"])) = 0
				aRoots + oNode["id"]
			ok
		end
		
		if len(aRoots) = 0
			aRoots + @aNodes[1]["id"]
		ok
		
		for cRoot in aRoots
			aVisitedPath = []
			This.PrivateShowVerticalBranch(cRoot, aVisitedPath)
		end

		def ShowV()
			This.ShowVertical()

	def PrivateShowVerticalBranch(pcNodeId, paVisitedPath)
		oNode = This.Node(pcNodeId)
		cBoxed = BoxRound(oNode["label"])
		aLines = StzStringQ(cBoxed).Split(nl)
		for cLine in aLines
			? CenterAlignXT(cLine, 25, " ")
		end
		
		paVisitedPath + pcNodeId
		aNeighbors = This.Neighbors(pcNodeId)
		
		if len(aNeighbors) = 0
			return
		ok
		
		for cNext in aNeighbors
			if find(paVisitedPath, cNext) = 0
				aEdge = This.Edge(pcNodeId, cNext)
				? CenterAlignXT("|", 25, " ")
				if aEdge["label"] != ""
					? CenterAlignXT(aEdge["label"], 25, " ")
					? CenterAlignXT("|", 25, " ")
				ok
				? CenterAlignXT("v", 25, " ")
				
				aCopyPath = paVisitedPath
				This.PrivateShowVerticalBranch(cNext, aCopyPath)
			else
				# Back-edge detected (cycle)
				aEdge = This.Edge(pcNodeId, cNext)
				cNodeLabel = This.Node(cNext)["label"]
				cArrowLine = RepeatChar(" ", 12) + "|" + RepeatChar(" ", stzlen("[" + cNodeLabel + "]") + 7) + "↑"
				
				? "            |            "
				? "      <CYCLE: " + aEdge["label"] + ">   "
				? cArrowLine
				? "            ╰──> [" + cNodeLabel + "] ──╯"
			ok
		end

	def ShowHorizontal()	
		aRoots = []
		for oNode in @aNodes
			if len(This.Incoming(oNode["id"])) = 0
				aRoots + oNode["id"]
			ok
		end
		
		if len(aRoots) = 0
			aRoots + @aNodes[1]["id"]
		ok
		
		for cRoot in aRoots
			aVisited = []
			aBoxLines = []
			aArrowLines = []
			This.PrivateShowHorizontalBranch(cRoot, aVisited, aBoxLines, aArrowLines)
			
			# Print the box lines
			for cLine in aBoxLines
				? cLine
			end
			
			# Print feedback loop if exists
			cFeedback = This.PrivateBuildFeedbackLine(aVisited)
			if cFeedback != ""
				? cFeedback
			ok
		end

		def ShowH()
			This.ShowHorizontal()

	def PrivateShowHorizontalBranch(pcNodeId, paVisited, paBoxLines, paArrowLines)
		oNode = This.Node(pcNodeId)
		cBoxed = BoxRound(oNode["label"])
		aLines = StzStringQ(cBoxed).Split(nl)
		
		aNeighbors = This.Neighbors(pcNodeId)
		
		if len(paBoxLines) = 0
			for cLine in aLines
				paBoxLines + cLine
			end
		else
			# Get the connector from previous edge
			cConnector = ""
			if len(paVisited) > 0
				cPrev = paVisited[len(paVisited)]
				aEdge = This.Edge(cPrev, pcNodeId)
				if aEdge != ""
					cConnector = "--" + aEdge["label"] + "-->"
				ok
			ok
			
			# Add connector to all lines, but use spaces for top/bottom lines
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
				This.PrivateShowHorizontalBranch(cNext, paVisited, paBoxLines, paArrowLines)
			else
				# Mark feedback
				paArrowLines + [pcNodeId, cNext, cEdgeLabel]
			ok
		ok

	def PrivateBuildFeedbackLine(paVisited)
		cFeedback = ""
		
		for aEdge in @aEdges
			if HasKey(aEdge, "from") and HasKey(aEdge, "to")
				if find(paVisited, aEdge["from"]) > 0 and find(paVisited, aEdge["to"]) > 0
					if find(paVisited, aEdge["to"]) < find(paVisited, aEdge["from"])
						nToIdx = find(paVisited, aEdge["to"])
						nFromIdx = find(paVisited, aEdge["from"])
						
						# Calculate dynamic box width based on node labels
						aBoxWidths = []
						for i = 1 to len(paVisited)
							oNode = This.Node(paVisited[i])
							nBoxW = len(oNode["label"]) + 4
							aBoxWidths + nBoxW
						end
						
						# Compute target position
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
						
						# Compute source position
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
	
		# Adjust line lengths to match exactly
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

