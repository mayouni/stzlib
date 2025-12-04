#============================================#
#  stzGraph - FUNDAMENTAL GRAPH ABSTRACTION  #
#  Pure computational thinking construct     #
#============================================#

#NOTE Take inspiration from this article:
# https://medium.com/data-science/graphs-with-python-overview-and-best-libraries-a92aa485c2f8

$acGraphDefaultValidators = ["dag", "reachability", "completeness"]

func GraphDefaultValidators()
	return $acGraphDefaultValidators

	func DefaultGraphValidators()
		return $acGraphDefaultValidators

func IsStzGraph(pObj)
	if isObject(pObj) and classname(pObj) = "stzgraph"
		return 1
	else
		return 0
	ok

	#--

	func IsAStzGraph(pObj)
		return IsStzGraph(pObj)

	func IsStzGraphObject(pObj)
		return IsStzGraph(pObj)

	func IsAStzGraphObject(pObj)
		return IsStzGraph(pObj)

	func IsGraphObject(pObj)
		return IsStzGraph(pObj)

	func IsAGraphObject(oObj)
		return IsStzGraph(pObj)

	#--

	func @IsStzGraph(pObj)
		return IsStzGraph(pObj)

	func @IsAStzGraph(pObj)
		return IsStzGraph(pObj)

	func @IsStzGraphObject(pObj)
		return This.IsStzGraph(pObj)

	func @IsAStzGraphObject(pObj)
		return IsStzGraph(pObj)

	func @IsGraphObject(pObj)
		return IsStzGraph(pObj)

	func @IsAGraphObject(oObj)
		return IsStzGraph(pObj)


class stzGraph

	@cId = ""
	@aNodes = []
	@acEdges = []

	# Rule system
	@aRules = []
	@aNodesAffectedByRules = []
	@aEdgesAffectedByRules = []

	@aProperties = []

	@acValidators = $acGraphDefaultValidators

	@oRuleEngine = ""
	@acLoadedRuleBases = []

	@oSimulationEngine = ""

	def init(pcId)
		@cId = pcId
		@acNodes = []
		@acEdges = []
		@aRules = []
		@aNodesAffectedByRules = []
		@aEdgesAffectedByRules = []
		@aProperties = []

		# Auto-load default structural rules
		This.LoadRuleBase("graph")


	def Id()
		return @cId

	def IsGraph()
		return 1

		def IsAGraph()
			return 1

		def IsStzGraph()
			return 1
	
		def IsAStzGraph()
			return 1
	
		def IsStzGraphObject()
			return 1
	
		def IsAStzGraphObject()
			return 1
	
		def IsGraphObject()
			return 1
	
		def IsAGraphObjec()
			return 1

	#-------------------#
	#  NODE OPERATIONS  #
	#-------------------#

	def AddNode(pcNodeId)
		This.AddNodeXT(pcNodeId, pcNodeId)

	def AddNodeXT(pcNodeId, pcLabel)
		This.AddNodeXTT(pcNodeId, pcLabel, [])

	def AddNodeXTT(pcNodeId, pcLabel, pacProperties)

		if CheckParams()
			if NOT (isString(pcNodeId) and isString(pcLabel))
				stzraise("Incorrect param types! pcNodeId and pcLabel must be both strings.")
			ok
		ok

		if NOT (isList(pacProperties) and @IsHashList(pacProperties))
			stzraise("Incorrect param type! pacProperties must be a hashlist.")
		ok

		aNode = [
			:id = pcNodeId,
			:label = pcLabel,
			:properties = iif(isList(pacProperties), pacProperties, [])
		]
		@aNodes + aNode

	def Node(pcNodeId)
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			if aNode["id"] = pcNodeId
				return aNode
			ok
		end
		stzraise("Node '" + pcNodeId + "' does not exist!")

	def NodeExists(pcNodeId)
		if ring_find( This.NodesIds(), pcNodeId) > 0
			return 1
		else
			return 0
		ok

	def SetNodes(paNodes)
		@aNodes = paNodes
	
	def SetEdges(paEdges)
		@acEdges = paEdges

	def Nodes()
		return @aNodes

	def NodesIds()
		nLen = len(@aNodes)
		acResult = []

		for i = 1 to nLen
			acResult + @aNodes[i][:id]
		next

		return acResult

	def NodeCount()
		return len(@aNodes)

	#----------------------#
	#  INSERT NODE BEFORE  #
	#----------------------#
	
	def InsertNodeBefore(pcTargetId, pcNewId, pcNewLabel)
		This.InsertNodeBeforeXT(pcTargetId, pcNewId, pcNewLabel, [])
	
	def InsertNodeBeforeXT(pcTargetId, pcNewId, pcNewLabel, paProps)
		# Get incoming edges to target
		aIncoming = []
		nLen = len(@acEdges)
		for i = 1 to nLen
			if @acEdges[i]["to"] = pcTargetId
				aIncoming + @acEdges[i]["from"]
			ok
		end
		
		# Add new node
		This.AddNodeXTT(pcNewId, pcNewLabel, paProps)
		
		# Reconnect: incoming -> new -> target
		nLen = len(aIncoming)
		for i = 1 to nLen
			This.RemoveThisEdge(aIncoming[i], pcTargetId)
			This.Connect(aIncoming[i], pcNewId)
		end
		This.Connect(pcNewId, pcTargetId)
	
	def InsertNodeBeforeAt(pacPath, pcNewId, pcNewLabel)
		This.InsertNodeBeforeAtXT(pacPath, pcNewId, pcNewLabel, [])
	
	def InsertNodeBeforeAtXT(pacPath, pcNewId, pcNewLabel, paProps)
		nLen = len(pacPath)
		if nLen = 0
			return
		ok
		cTargetId = pacPath[nLen]
		This.InsertNodeBeforeXT(cTargetId, pcNewId, pcNewLabel, paProps)
	
	#---------------------#
	#  INSERT NODE AFTER  #
	#---------------------#
	
	def InsertNodeAfter(pcTargetId, pcNewId, pcNewLabel)
		This.InsertNodeAfterXT(pcTargetId, pcNewId, pcNewLabel, [])
	
	def InsertNodeAfterXT(pcTargetId, pcNewId, pcNewLabel, paProps)
		# Get outgoing edges from target
		aOutgoing = []
		nLen = len(@acEdges)
		for i = 1 to nLen
			if @acEdges[i]["from"] = pcTargetId
				aOutgoing + @acEdges[i]["to"]
			ok
		end
		
		# Add new node
		This.AddNodeXTT(pcNewId, pcNewLabel, paProps)
		
		# Reconnect: target -> new -> outgoing
		nLen = len(aOutgoing)
		for i = 1 to nLen
			This.RemoveThisEdge(pcTargetId, aOutgoing[i])
			This.Connect(pcNewId, aOutgoing[i])
		end
		This.Connect(pcTargetId, pcNewId)
	
	def InsertNodeAfterAt(pacPath, pcNewId, pcNewLabel)
		This.InsertNodeAfterAtXT(pacPath, pcNewId, pcNewLabel, [])
	
	def InsertNodeAfterAtXT(pacPath, pcNewId, pcNewLabel, paProps)
		nLen = len(pacPath)
		if nLen = 0
			return
		ok
		cTargetId = pacPath[nLen]
		This.InsertNodeAfterXT(cTargetId, pcNewId, pcNewLabel, paProps)
	
	#-------------------------#
	#  INSERT MULTIPLE NODES  #
	#-------------------------#
	
	def InsertNodesBefore(pcTargetId, paNodes)
		# paNodes = [ ["id1", "label1"], ["id2", "label2"], ... ]
		nLen = len(paNodes)
		for i = 1 to nLen
			This.InsertNodeBefore(pcTargetId, paNodes[i][1], paNodes[i][2])
			pcTargetId = paNodes[i][1]  # Chain insertions
		end
	
	def InsertNodesAfter(pcTargetId, paNodes)
		nLen = len(paNodes)
		cLastId = pcTargetId
		for i = 1 to nLen
			This.InsertNodeAfter(cLastId, paNodes[i][1], paNodes[i][2])
			cLastId = paNodes[i][1]
		end

	#--------------------#
	#  NODE REPLACEMENT  #
	#--------------------#
	
	# Replace all nodes with new set
	def ReplaceNodes(paNewNodes)
		@aNodes = paNewNodes
		@acEdges = []
		@aNodeEnhancements = []
		@aEdgeEnhancements = []
	
		def ReplaceAllNodes(paNewNodes)
			This.ReplaceNodes(paNewNodes)
	
	# Replace specific node (preserve label & properties)
	def ReplaceThisNode(pcOldId, pcNewId)
		aNode = This.Node(pcOldId)
		This.ReplaceThisNodeXTT(pcOldId, pcNewId, aNode["label"], aNode["properties"])
	
		def ReplaceNode(pcOldId, pcNewId)
			This.ReplaceThisNode(pcOldId, pcNewId)
	
	# Replace node with new label
	def ReplaceThisNodeXT(pcOldId, pcNewId, pcNewLabel)
		aNode = This.Node(pcOldId)
		This.ReplaceThisNodeXTT(pcOldId, pcNewId, pcNewLabel, aNode["properties"])
	
		def ReplaceNodeXT(pcOldId, pcNewId, pcNewLabel)
			This.ReplaceThisNodeXT(pcOldId, pcNewId, pcNewLabel)
	
	# Replace node with everything
	def ReplaceThisNodeXTT(pcOldId, pcNewId, pcNewLabel, paNewProps)
		if NOT This.HasNode(pcOldId)
			stzraise("Node '" + pcOldId + "' does not exist!")
		ok
		
		# Collect edges
		aIncoming = []
		aOutgoing = []
		
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] = pcOldId
				aOutgoing + [aEdge["to"], aEdge["label"], aEdge["properties"]]
			ok
			if aEdge["to"] = pcOldId
				aIncoming + [aEdge["from"], aEdge["label"], aEdge["properties"]]
			ok
		end
		
		# Replace
		This.RemoveThisNode(pcOldId)
		This.AddNodeXTT(pcNewId, pcNewLabel, paNewProps)
		
		# Restore edges
		nLen = len(aIncoming)
		for i = 1 to nLen
			This.AddEdgeXTT(aIncoming[i][1], pcNewId, aIncoming[i][2], aIncoming[i][3])
		end
		
		nLen = len(aOutgoing)
		for i = 1 to nLen
			This.AddEdgeXTT(pcNewId, aOutgoing[i][1], aOutgoing[i][2], aOutgoing[i][3])
		end
	
		def ReplaceNodeXTT(pcOldId, pcNewId, pcNewLabel, paNewProps)
			This.ReplaceThisNodeXTT(pcOldId, pcNewId, pcNewLabel, paNewProps)
	
	# Replace multiple nodes
	def ReplaceTheseNodes(paReplacements)
		# paReplacements = [ ["old1", "new1"], ["old2", "new2"], ... ]
		nLen = len(paReplacements)
		for i = 1 to nLen
			This.ReplaceThisNode(paReplacements[i][1], paReplacements[i][2])
		end
	
	#--------------------#
	#  EDGE REPLACEMENT  #
	#--------------------#
	
	# Replace all edges
	def ReplaceEdges(paNewEdges)
		@acEdges = paNewEdges
		@aEdgeEnhancements = []
	
		def ReplaceAllEdges(paNewEdges)
			This.ReplaceEdges(paNewEdges)
	
	# Replace edge (preserve label & properties)
	def ReplaceThisEdge(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo)
		aEdge = This.Edge(pcOldFrom, pcOldTo)
		This.ReplaceThisEdgeXTT(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo, aEdge["label"], aEdge["properties"])
	
		def ReplaceEdge(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo)
			This.ReplaceThisEdge(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo)
	
	# Replace edge with new label
	def ReplaceThisEdgeXT(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo, pcNewLabel)
		aEdge = This.Edge(pcOldFrom, pcOldTo)
		This.ReplaceThisEdgeXTT(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo, pcNewLabel, aEdge["properties"])
	
		def ReplaceEdgeXT(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo, pcNewLabel)
			This.ReplaceThisEdgeXT(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo, pcNewLabel)
	
	# Replace edge completely
	def ReplaceThisEdgeXTT(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo, pcNewLabel, paNewProps)
		if NOT This.EdgeExists(pcOldFrom, pcOldTo)
			stzraise("Edge '" + pcOldFrom + "->" + pcOldTo + "' does not exist!")
		ok
		
		This.RemoveThisEdge(pcOldFrom, pcOldTo)
		This.AddEdgeXTT(pcNewFrom, pcNewTo, pcNewLabel, paNewProps)
	
		def ReplaceEdgeXTT(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo, pcNewLabel, paNewProps)
			This.ReplaceThisEdgeXTT(pcOldFrom, pcOldTo, pcNewFrom, pcNewTo, pcNewLabel, paNewProps)
	
	#--- REPLACE NODE AT PATH
	
	def ReplaceNodeAt(pacPath, pcNewId)
		nLen = len(pacPath)
		if nLen = 0
			return
		ok
		
		cOldId = pacPath[nLen]
		This.ReplaceThisNode(cOldId, pcNewId)
	
	def ReplaceNodeAtXT(pacPath, pcNewId, pcNewLabel)
		nLen = len(pacPath)
		if nLen = 0
			return
		ok
		
		cOldId = pacPath[nLen]
		This.ReplaceThisNodeXT(cOldId, pcNewId, pcNewLabel)
	
	def ReplaceNodeAtXTT(pacPath, pcNewId, pcNewLabel, paNewProps)
		nLen = len(pacPath)
		if nLen = 0
			return
		ok
		
		cOldId = pacPath[nLen]
		This.ReplaceThisNodeXTT(cOldId, pcNewId, pcNewLabel, paNewProps)

	#---------------#
	#  NODE REMOVAL #
	#---------------#
	
	# Remove all nodes (and their edges)
	def RemoveNodes()
		@acNodes = []
		@acEdges = []
		@aNodesAffectedByRules = []
		@aEdgesAffectedByRules = []
	
		def RemoveAllNodes()
			This.RemoveNodes()
	
		def Clear()
			This.RemoveNodes()
	
	# Remove specific nodes
	def RemoveTheseNodes(pacNodeIds)
		nLen = len(pacNodeIds)
		for i = 1 to nLen
			This.RemoveThisNode(pacNodeIds[i])
		end
	
	# Remove single node
	def RemoveThisNode(pcNodeId)
		# Remove from nodes
		acNew = []
		nLen = len(@aNodes)
		for i = 1 to nLen
			if @aNodes[i]["id"] != pcNodeId
				acNew + @aNodes[i]
			ok
		end
		@aNodes = acNew
		
		# Remove its edges
		This.RemoveEdgesConnectedTo(pcNodeId)
	
		def RemoveNode(pcNodeId)
			This.RemoveThisNode(pcNodeId)
	
	#--- REMOVE NODE AT PATH
	
	def RemoveNodeAt(pacPath)
		# pacPath = ["n1", "n2", "target"]
		nLen = len(pacPath)
		if nLen = 0
			return
		ok
		
		cNodeId = pacPath[nLen]  # Last node in path
		This.RemoveThisNode(cNodeId)
	
		def RemoveNodeAtPosition(pacPath)
			This.RemoveNodeAt(pacPath)
	
	def RemoveNodesAt(paPaths)
		# paPaths = [ ["n1", "target1"], ["n2", "n3", "target2"], ... ]
		acToRemove = []
		nLenPaths = len(paPaths)
		
		for i = 1 to nLenPaths
			acPath = paPaths[i]
			nLen = len(acPath)
			if nLen > 0
				cNodeId = acPath[nLen]
				if ring_find(acToRemove, cNodeId) = 0
					acToRemove + cNodeId
				ok
			ok
		end
		
		This.RemoveTheseNodes(acToRemove)
	
		def RemoveNodesAtPositions(paPaths)
			This.RemoveNodesAt(paPaths)
	
	#----------------#
	#  EDGE REMOVAL  #
	#----------------#
	
	# Remove all edges
	def RemoveEdges()
		@acEdges = []
		@aEdgesAffectedByRules = []
	
		def RemoveAllEdges()
			This.RemoveEdges()
	
		def ClearEdges()
			This.RemoveEdges()
	
	# Remove single edge
	def RemoveThisEdge(pcFromId, pcToId)
		acNew = []
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if NOT (aEdge["from"] = pcFromId and aEdge["to"] = pcToId)
				acNew + aEdge
			ok
		end
		@acEdges = acNew
	
		def RemoveEdge(pcFromId, pcToId)
			This.RemoveThisEdge(pcFromId, pcToId)

		def Disconnect(pcFromId, pcToId)
			This.RemoveThisEdge(pcFromId, pcToId)

	def RemoveEdgesConnectedTo(pcNodeId)
		acNew = []
		nLen = len(@acEdges)
		
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if NOT (aEdge["from"] = pcNodeId or aEdge["to"] = pcNodeId)
				acNew + aEdge
			ok
		end
		
		@acEdges = acNew

	#-------------------#
	#  EDGE OPERATIONS  #
	#-------------------#

	def AddEdge(pcFromId, pcToId)
		This.AddEdgeXTT(pcFromId, pcToId, "", [])

		def Connect(pcFromId, pcToId)
			This.AddEdgeXTT(pcFromId, pcToId, "", [])

	def AddEdgeXT(pcFromId, pcToId, pcLabel)
		This.AddEdgeXTT(pcFromId, pcToId, pcLabel, [])

		def ConnectXT(pcFromId, pcToId, pcLabel)
			This.AddEdgeXTT(pcFromId, pcToId, pcLabel, [])

	def AddEdgeXTT(pcFromId, pcToId, pcLabel, pacProperties)
		if CheckParams()
			if isList(pcFromId) and StzListQ(pcFromId).IsFromNamedParam()
				pcFromId = pcFromId[2]
			ok

			if isList(pcToId) and StzListQ(pcToId).IsToNamedParam()
				pcToId = pcToId[2]
			ok

			if isList(pcLabel) and StzListQ(pcLabel).IsWithOrLabelNamedParam()
				pcLabel = pcLabel[2]
			ok		
		ok

		if NOT This.NodeExists(pcFromId) or NOT This.NodeExists(pcToId)
			return 0
		ok

		if This.EdgeExists(pcFromId, pcToId)
			return 0  # Don't add duplicate
		ok

		aEdge = [
			:from = pcFromId,
			:to = pcToId,
			:label = pcLabel,
			:properties = iif(isList(pacProperties), pacProperties, [])
		]
		@acEdges + aEdge
		return 1

		def ConnectXTT(pcFromId, pcToId, pcLabel, pacProperties)
			This.AddEdgeXTT(pcFromId, pcToId, pcLabel, pacProperties)

	def Edge(pcFromId, pcToId)
		if CheckParams()
			if isList(pcFromId)
				oList = new stzList(pcFromId)
				if oList.IsFromNamedParam() or oList.IsFromNodeNamedParam()
					pcFromId = pcFromId[2]
				ok
			ok
			if isList(pcToId)
				oList = new stzList(pcToId)
				if oList.IsToNamedParam() or oList.IsToNodeNamedParam()
					pcToId = pcToId[2]
				ok
			ok
		ok

		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] = pcFromId and aEdge["to"] = pcToId
				return aEdge
			ok
		end
		stzraise("Inexistant edge!")

	def EdgeExists(pcFromId, pcToId)
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] = pcFromId and aEdge["to"] = pcToId
				return 1
			ok
		end
		return 0

	def Edges()
		return @acEdges

	def EdgeCount()
		return len(@acEdges)

	#-------------------#
	#  NODE NAVIGATION  #
	#-------------------#
	
	def FirstNode()
		if len(@aNodes) > 0
			return @aNodes[1]
		ok
		return []
	
	def LastNode()
		nLen = len(@aNodes)
		if nLen > 0
			return @aNodes[nLen]
		ok
		return []
	
	def NodeAt(n)
		if n > 0 and n <= len(@aNodes)
			return @aNodes[n]
		ok
		return []
	
		def NthNode(n)
			return This.NodeAt(n)
	
	def NodePosition(pcNodeId)
		nLen = len(@aNodes)
		for i = 1 to nLen
			if @aNodes[i]["id"] = pcNodeId
				return i
			ok
		end
		return 0

	def PositionOfNode(pcNodeId)
		return This.NodePosition(pcNodeId)

	#-------------------#
	#  EDGE NAVIGATION  #
	#-------------------#
	
	def FirstEdge()
		if len(@acEdges) > 0
			return @acEdges[1]
		ok
		return []
	
	def LastEdge()
		nLen = len(@acEdges)
		if nLen > 0
			return @acEdges[nLen]
		ok
		return []
	
	def EdgeAt(n)
		if n > 0 and n <= len(@acEdges)
			return @acEdges[n]
		ok
		return []
	
		def NthEdge(n)
			return This.EdgeAt(n)
	
	def EdgePosition(pcFrom, pcTo)
		nLen = len(@acEdges)
		for i = 1 to nLen
			if @acEdges[i]["from"] = pcFrom and @acEdges[i]["to"] = pcTo
				return i
			ok
		end
		return 0
	
		def PositionOfEdge(pcFrom, pcTo)
			return This.EdgePosition(pcFrom, pcTo)

	#---------------------------#
	#  BATCH UPDATE OPERATIONS  #
	#---------------------------#
	
	def UpdateNodes(pFunc)
		nLen = len(@aNodes)
		for i = 1 to nLen
			call pFunc(@aNodes[i])
		end
	
	def UpdateEdges(pFunc)
		nLen = len(@acEdges)
		for i = 1 to nLen
			call pFunc(@acEdges[i])
		end

	#-------------------#
	#  COPY OPERATIONS  #
	#-------------------#
	
	def CopyNode(pcNodeId)
		aNode = This.Node(pcNodeId)
		aCopy = [
			:id = aNode["id"],
			:label = aNode["label"],
			:properties = []
		]
		
		if HasKey(aNode, "properties")
			acKeys = keys(aNode["properties"])
			nLen = len(acKeys)
			for i = 1 to nLen
				aCopy["properties"][acKeys[i]] = aNode["properties"][acKeys[i]]
			end
		ok
		
		return aCopy
	
	def DuplicateNode(pcNodeId, pcNewId)
		aCopy = This.CopyNode(pcNodeId)
		aCopy["id"] = pcNewId
		This.AddNodeXTT(aCopy["id"], aCopy["label"], aCopy["properties"])
	
		def CloneNode(pcNodeId, pcNewId)
			This.DuplicateNode(pcNodeId, pcNewId)
	
	def DuplicateNodeWithEdges(pcNodeId, pcNewId)
		This.DuplicateNode(pcNodeId, pcNewId)
		
		# Copy outgoing edges
		aEdges = This.Edges()
		nLen = len(aEdges)
		for i = 1 to nLen
			if aEdges[i]["from"] = pcNodeId
				This.AddEdgeXTT(pcNewId, aEdges[i]["to"], aEdges[i]["label"], aEdges[i]["properties"])
			ok
		end

	#--------------------#
	#  MERGE OPERATIONS  #
	#--------------------#
	
	def MergeNodes(pacNodeIds, pcNewId, pcNewLabel)
		This.MergeNodesXT(pacNodeIds, pcNewId, pcNewLabel, [])
	
	def MergeNodesXT(pacNodeIds, pcNewId, pcNewLabel, paNewProps)
		if len(pacNodeIds) < 2
			return
		ok
		
		# Collect all unique incoming and outgoing connections
		aIncoming = []
		aOutgoing = []
		
		nNodeLen = len(pacNodeIds)
		nEdgeLen = len(@acEdges)
		
		for i = 1 to nNodeLen
			cNodeId = pacNodeIds[i]
			
			for j = 1 to nEdgeLen
				aEdge = @acEdges[j]
				
				if aEdge["to"] = cNodeId
					if ring_find(aIncoming, aEdge["from"]) = 0 and ring_find(pacNodeIds, aEdge["from"]) = 0
						aIncoming + aEdge["from"]
					ok
				ok
				
				if aEdge["from"] = cNodeId
					if ring_find(aOutgoing, aEdge["to"]) = 0 and ring_find(pacNodeIds, aEdge["to"]) = 0
						aOutgoing + aEdge["to"]
					ok
				ok
			end
		end
		
		# Remove old nodes
		This.RemoveTheseNodes(pacNodeIds)
		
		# Add merged node
		This.AddNodeXTT(pcNewId, pcNewLabel, paNewProps)
		
		# Reconnect edges
		nLen = len(aIncoming)
		for i = 1 to nLen
			This.Connect(aIncoming[i], pcNewId)
		end
		
		nLen = len(aOutgoing)
		for i = 1 to nLen
			This.Connect(pcNewId, aOutgoing[i])
		end
	
		def CombineNodes(pacNodeIds, pcNewId, pcNewLabel)
			This.MergeNodes(pacNodeIds, pcNewId, pcNewLabel)

	#----------------------------#
	#  MANAGING NODE PROPERTIES  #
	#----------------------------#

	def Properties()
		if NOT isList(@aNodes) or len(@aNodes) = 0
			return []
		ok
		
		acAllProps = []
		nLen = len(@aNodes)
		
		for i = 1 to nLen
			if HasKey(@aNodes[i], "properties") and isList(@aNodes[i]["properties"])
				acKeys = keys(@aNodes[i]["properties"])
				nKeyLen = len(acKeys)
				for j = 1 to nKeyLen
					if ring_find(acAllProps, acKeys[j]) = 0
						acAllProps + acKeys[j]
					ok
				end
			ok
		end
		
		return acAllProps
	
		def Props()
			return This.Properties()

	def PropertiesXT()
		aResult = []
		aNodes = This.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			if HasKey(aNodes[i], "properties")
				aProps = aNodes[i]["properties"]
				acKeys = keys(aProps)
				nKeyLen = len(acKeys)
				
				for j = 1 to nKeyLen
					cKey = acKeys[j]
					pValue = aProps[cKey]
					
					# Find or create entry
					nFound = 0
					nResultLen = len(aResult)
					for k = 1 to nResultLen
						if aResult[k][1] = cKey
							nFound = k
							exit
						ok
					end
					
					if nFound > 0
						if ring_find(aResult[nFound][2], pValue) = 0
							aResult[nFound][2] + pValue
						ok
					else
						aResult + [cKey, [pValue]]
					ok
				end
			ok
		end
		
		return aResult
	
		def PropsXT()
			return This.PropertiesXT()
	
		def PropsAndTheirValues()
			return This.PropertiesXT()

	#--

	def SetNodeProperty(pNodeId, cProperty, pValue)
	    nLen = len(@aNodes)
	    for i = 1 to nLen
	        if @aNodes[i]["id"] = pNodeId
	            if NOT HasKey(@aNodes[i], "properties")
	                @aNodes[i] + ["properties", []]
	            ok
	            @aNodes[i]["properties"][cProperty] = pValue
	            @aNodes[i] = @aNodes[i]  # Force write-back
	            return
	        ok
	    end
	
		def SetNodeProp(pNodeId, cProperty, pValue)
			This.SetNodeProperty(pNodeId, cProperty, pValue)

	def SetNodeProperties(pNodeId, aProperties)
		if NOT IsHashList(aProperties)
			StzRaise("aProperties must be a hashlist")
		ok
		
		for cKey in keys(aProperties)
			This.SetNodeProperty(pNodeId, cKey, aProperties[cKey])
		end
	
		def SetNodePropes(pNodeId, aProperties)
			This.SetNodeProperties(pNodeId, aProperties)

		def UpdateNodeProperty(pcNodeId, pcKey, pValue)
			This.SetNodeProperty(pcNodeId, pcKey, pValue)
		
		def UpdateNodeProp(pcNodeId, pcKey, pValue)
			This.SetNodeProperty(pcNodeId, pcKey, pValue)
	
	def NodeProperties(pcNodeId)
		aNode = This.Node(pcNodeId)
		if HasKey(aNode, "properties")
			return keys(aNode["properties"])
		ok
		return []
	
		def NodeProps(pcNodeId)
			return This.NodeProperties(pcNodeId)

	def NodePropertiesXT(pcNodeId)
		aNode = This.Node(pcNodeId)
		if HasKey(aNode, "properties")
			return aNode["properties"]
		ok
		return []
	
		def NodePropertiesAndTheirValues(pcNodeId)
			return This.NodeProperties(pcNodeId)

		def NodePropsXT(pcNodeId)
			return This.NodeProperties(pcNodeId)

		def NodePropsAndTheirValues(pcNodeId)
			return This.NodeProperties(pcNodeId)

	def NodeProperty(pNodeId, cProperty)
		aNode = This.Node(pNodeId)
		
		if HasKey(aNode, "properties") and HasKey(aNode["properties"], cProperty)
			return aNode["properties"][cProperty]
	
		else
			stzraise("Inexistant node key or/and property!")
		ok
	
		def NodeProp(pNodeId, cProperty)
			return This.NodeProperty(pNodeId, cProperty)

	def SetEdgeProperty(pFromId, pToId, cProperty, pValue)
		if CheckParams()
			if isList(pFromId)
				oList = new stzList(pFromId)
				if oList.IsFromNamedParam() or oList.IsFromNodeNamedParam()
					pFromId = pFromId[2]
				ok
			ok
			if isList(pToId)
				oList = new stzList(pToId)
				if oList.IsToNamedParam() or oList.IsToNodeNamedParam()
					pToId = pToId[2]
				ok
			ok
		ok

		nLen = len(@acEdges)
		for i = 1 to nLen
			if @acEdges[i]["from"] = pFromId and @acEdges[i]["to"] = pToId
				if NOT HasKey(@acEdges[i], "properties")
					@acEdges[i] + ["properties", []]
				ok
				@acEdges[i]["properties"][cProperty] = pValue
				return
			ok
		end
	
		def SetEdgeProp(pFromId, pToId, cProperty, pValue)
			return This.SetEdgeProperty(pFromId, pToId, cProperty, pValue)

		def UpdateEdgeProperty(pcFrom, pcTo, pcKey, pValue)
			This.SetEdgeProperty(pcFrom, pcTo, pcKey, pValue)
		
		def UpdateEdgeProp(pcFrom, pcTo, pcKey, pValue)
			This.SetEdgeProperty(pcFrom, pcTo, pcKey, pValue)


	def EdgeProperty(pFromId, pToId, cProperty)
		aEdge = This.Edge(pFromId, pToId)
		
		if HasKey(aEdge, "properties") and HasKey(aEdge["properties"], cProperty)
			return aEdge["properties"][cProperty]
		else
			stzraise("Inexistant node key or/and property!")
		ok

		def EdgeProp(pFromId, pToId, cProperty)
			return This.EdgeProperty(pFromId, pToId, cProperty)

	def SetEdgeProperties(pcFrom, pcTo, aProperties)
		if CheckParams()
			if isList(pcFrom)
				oList = new stzList(pcFrom)
				if oList.IsFromNamedParam() or oList.IsFromNodeNamedParam()
					pcFrom = pcFrom[2]
				ok
			ok
			if isList(pcTo)
				oList = new stzList(pcTo)
				if oList.IsToNamedParam() or oList.IsToNodeNamedParam()
					pcTo = pcTo[2]
				ok
			ok
		ok

		if NOT IsHashList(aProperties)
			StzRaise("aProperties must be a hashlist")
		ok
		
		nLen = len(@acEdges)
		for i = 1 to nLen
			if @acEdges[i]["from"] = pcFrom and @acEdges[i]["to"] = pcTo
				if NOT HasKey(@acEdges[i], "properties")
					@acEdges[i] + ["properties", []]
				ok
				
				# Directly merge properties
				acKeys = keys(aProperties)
				nKeyLen = len(acKeys)
				for j = 1 to nKeyLen
					@acEdges[i]["properties"][acKeys[j]] = aProperties[acKeys[j]]
				end
				return
			ok
		end
	
		def SetEdgeProps(pcFrom, pcTo, aProperties)
			This.SetEdgeProperties(pcFrom, pcTo, aProperties)

	def EdgeProperties(pcFrom, pcTo)
		aEdge = This.Edge(pcFrom, pcTo)
		if HasKey(aEdge, "properties")
			return keys(aEdge["properties"])
		ok
		return []
	
		def EdgeProps(pcFrom, pcTo)
			return This.EdgeProperties(pcFrom, pcTo)

	def EdgePropertiesXT(pcFrom, pcTo)
		aEdge = This.Edge(pcFrom, pcTo)
		if HasKey(aEdge, "properties")
			return aEdge["properties"]
		ok
		return []
	
		def EdgePropsXT(pcFrom, pcTo)
			return This.EdgePropertiesXT(pcFrom, pcTo)

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

	def Path(pcFromId, pcToId)
		acPaths = This.FindAllPaths(pcFromId, pcToId)
		_nLenPaths_ = len(acPaths)
		if _nLenPaths_ > 0
			return acPaths[1]
		else
			return []
		ok

		def FirstPath(pcFromId, pcToId)
			return This.Path(pcFromId, pcToId)

		def FirstPathBetween(pcFromId, pcToId)
			return This.Path(pcFromId, pcToId)

		def PathBetween(pcFromId, pcToId)
			return This.Path(pcFromId, pcToId)

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

	#-------------------#
	#  CYCLE DETECTION  #
	#-------------------#

	def CyclicDependencies()
		acVisited = []
		acRecStack = []

		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
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

	#-------------------------------#
	#  REACHABILITY & CONNECTIVITY  #
	#-------------------------------#

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

	#--------------------#
	#  ANALYSIS METRICS  #
	#--------------------#

	def BottleneckNodes()
		acBottlenecks = []
		nTotalDegree = 0
		
		# Calculate average degree
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			nIncoming = len(This.Incoming(aNode["id"]))
			nOutgoing = len(This.Neighbors(aNode["id"]))
			nTotalDegree += nIncoming + nOutgoing
		end
		
		nAvgDegree = nTotalDegree / len(@aNodes)
		
		# Mark nodes above average
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			nIncoming = len(This.Incoming(aNode["id"]))
			nOutgoing = len(This.Neighbors(aNode["id"]))
			nDegree = nIncoming + nOutgoing
			
			if nDegree > nAvgDegree
				acBottlenecks + aNode["id"]
			ok
		end
		
		return acBottlenecks

	def NodeDensity()
		nNodes = len(@aNodes)
		nEdges = len(@acEdges)

		if nNodes <= 1
			return 0
		ok

		nMaxEdges = nNodes * (nNodes - 1)
		return (nEdges * 100) / nMaxEdges

	def LongestPath()
		nMax = 0

		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			acReachable = This.ReachableFrom(aNode["id"])
			nLength = len(acReachable) - 1

			if nLength > nMax
				nMax = nLength
			ok
		end

		return nMax

	#---------------------------------------#
	#  1. INDEPENDENCE AND PARALLELIZATION  #
	#---------------------------------------#

	def ParallelizableBranches()
		acBranches = []
		nLen = len(@aNodes)
		
		for i = 1 to nLen
			aNode = @aNodes[i]
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
		nLen = len(@aNodes)
		
		for i = 1 to nLen
			aNode = @aNodes[i]
			cNodeId = aNode["id"]
			acIncoming = This.Incoming(cNodeId)
			
			if len(acIncoming) = 0
				acDependencyFree + cNodeId
			ok
		end
		
		return acDependencyFree

	#-----------------------------#
	#  2. CRITICALITY AND IMPACT  #
	#-----------------------------#

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
		nLen = len(@aNodes)
		
		for i = 1 to nLen
			aNode = @aNodes[i]
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

	#---------------------------------#
	#  3. CONSTRAINTS AND VALIDATION  #
	#---------------------------------#
	
	def CheckConstraints()
	        if @oRuleEngine != NULL
	            return @oRuleEngine.CheckConstraints()
	        ok
	        return [ :status = "pass" ]

	def AddConstraint(pcConstraintType)
		if NOT HasKey(@aProperties, pcConstraintType)
			@aProperties = []
		ok
		
		cType = upper(pcConstraintType)
		
		aConstraint = [
			:type = cType,
			:violations = []
		]
		
		if NOT HasKey(@aProperties, "constraints")
			@aProperties + ["constraints", []]
		ok
		
		@aProperties["constraints"] + aConstraint
	
	def ValidateConstraints()
	    if NOT HasKey(@aProperties, "constraints")
	        return [
	            :status = "pass",
	            :domain = "constraints",
	            :issueCount = 0,
	            :issues = [],
	            :affectedNodes = []
	        ]
	    ok
	    
	    aIssues = []
	    acAffected = []
	    nLen = len(@aProperties["constraints"])
	    
	    for i = 1 to nLen
	        @aProperties["constraints"][i]["violations"] = []
	        cType = @aProperties["constraints"][i]["type"]
	        
	        bValid = This._EvaluateConstraint(cType)
	        
	        if NOT bValid
	            cIssue = "Constraint failed: " + cType
	            aIssues + cIssue
	            @aProperties["constraints"][i]["violations"] + cIssue
	        ok
	    end
	    
	    return [
	        :status = iif(len(aIssues) = 0, "pass", "fail"),
	        :domain = "constraints",
	        :issueCount = len(aIssues),
	        :issues = aIssues,
	        :affectedNodes = acAffected
	    ]
	
	def _EvaluateConstraint(pcType)
	    if pcType = "ACYCLIC" or pcType = "NO_CYCLES"
	        return NOT This.CyclicDependencies()
	    ok
	    
	    if pcType = "CONNECTED"
	        return This._IsConnected()
	    ok
	    
	    return 1
	
	def _IsConnected()
	    if len(@aNodes) <= 1
	        return 1
	    ok
	    
	    acVisited = []
	    acQueue = [@aNodes[1]["id"]]
	    acVisited + @aNodes[1]["id"]
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
	    
	    return len(acVisited) = len(@aNodes)
	
	def ConstraintViolations()
		
		if NOT HasKey(@aProperties, "constraints")
			return []
		ok
		
		acViolations = []
		acConstraints = @aProperties["constraints"]
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

	#---------------------#
	#  RULE ENGINE MGMT   #
	#---------------------#
    
	def LoadRuleBase(pRuleBase)
		if @oRuleEngine = NULL
			@oRuleEngine = new stzGraphRuleEngine(This)
		ok
	
		@oRuleEngine.AddRuleBase(pRuleBase)
	
		if isString(pRuleBase)
			@acLoadedRuleBases + pRuleBase
		but isObject(pRuleBase)
			@acLoadedRuleBases + pRuleBase.Name()
		ok
	
	def RuleEngine()
		return @oRuleEngine
	
	def LoadedRuleBases()
		return @acLoadedRuleBases
    
	#------------------------------#
	#  stzGraph - Rule Management  #
	#------------------------------#
	
	def SetRule(p)
		if isString(p)
			if HasKey(@aRules, p)
				return
			else
				stzraise("Rule '" + p + "' not found")
			ok
		but isObject(p) and ring_classname(p) = "stzgraphrule"
			p.SetGraph(This)  # Pass graph reference to rule
			@aRules[p.@cRuleId] = p
		ok
	
		def SetRuleObject(oRule)
			This.SetRule(oRule)
	
	def SetRuleXT(p, pcType)
		if isString(p)
			stzraise("Cannot set type for non-existent rule '" + p + "'")
		ok
		
		if isObject(p) and ring_classname(p) = "stzgraphrule"
			p.SetRuleType(pcType)
			p.SetGraph(This)  # Pass graph reference to rule
			@aRules[p.@cRuleId] = p
		ok
	
	def RemoveRule(p)
		if isString(p)
			@aRules[p] = NULL
		but isObject(p)
			@aRules[p.@cRuleId] = NULL
		ok
	
	def Rule(pcRuleId)
		return @aRules[pcRuleId]
	
		def RuleObject(pcRuleId)
			return This.Rule(pcRuleId)
	
	def Rules()
		return @aRules
	
		def RuleObjects()
			return @aRules
	
	def RulesByType(pcType)
		acResult = []
		acRuleIds = keys(@aRules)
		nLen = len(acRuleIds)
		
		for i = 1 to nLen
			cRuleId = acRuleIds[i]
			oRule = @aRules[cRuleId]
			cRuleType = oRule.RuleType()
			
			if pcType = "" or lower(pcType) = cRuleType
				acResult + cRuleId
			ok
		end
		
		return acResult
	
	def RulesObjectsByType(pcType)
		aoResult = []
		acRuleIds = keys(@aRules)
		nLen = len(acRuleIds)
		
		for i = 1 to nLen
			cRuleId = acRuleIds[i]
			oRule = @aRules[cRuleId]
			cRuleType = oRule.RuleType()
			
			if pcType = "" or lower(pcType) = cRuleType
				aoResult + oRule
			ok
		end
		
		return aoResult
	
	#-------------------------------#
	#  stzGraph - Rule Application  #
	#-------------------------------#
	
	def ApplyRules()
		This.ApplyRulesByType("")
	
	def ApplyRulesByType(pcType)
		aNodes = This.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			aNode = aNodes[i]
			cNodeId = aNode["id"]
			aContext = This._BuildRuleContext(aNode)
			
			acRuleIds = keys(@aRules)
			nRuleLen = len(acRuleIds)
			
			for j = 1 to nRuleLen
				oRule = @aRules[acRuleIds[j]]
				
				# Filter by type if specified
				if pcType != ""
					cRuleType = oRule.RuleType()
					if lower(pcType) != cRuleType
						loop
					ok
				ok
				
				# Special handling for pathexists condition
				if oRule.ConditionType() = :pathexists
					aParams = oRule.ConditionParams()
					if This.PathExists(aParams[1], aParams[2])
						This._ApplyEffects(oRule, "node", cNodeId)
					ok
				else
					if oRule.Matches(aContext)
						This._ApplyEffects(oRule, "node", cNodeId)
					ok
				ok
			end
			
			if HasKey(aNode, "properties")
				@aNodesAffectedByRules[cNodeId] = aNode["properties"]
			ok
		end
		
		# Same for edges
		aEdges = This.Edges()
		nLen = len(aEdges)
		
		for i = 1 to nLen
			aEdge = aEdges[i]
			cEdgeKey = aEdge["from"] + "->" + aEdge["to"]
			aContext = This._BuildRuleContext(aEdge)
			
			acRuleIds = keys(@aRules)
			nRuleLen = len(acRuleIds)
			
			for j = 1 to nRuleLen
				oRule = @aRules[acRuleIds[j]]
				
				if pcType != ""
					cRuleType = oRule.RuleType()
					if lower(pcType) != cRuleType
						loop
					ok
				ok
				
				# Special handling for pathexists condition
				if oRule.ConditionType() = :pathexists
					aParams = oRule.ConditionParams()
					if This.PathExists(aParams[1], aParams[2])
						This._ApplyEffects(oRule, "edge", [aEdge["from"], aEdge["to"]])
					ok
				else
					if oRule.Matches(aContext)
						This._ApplyEffects(oRule, "edge", [aEdge["from"], aEdge["to"]])
					ok
				ok
			end
			
			if HasKey(aEdge, "properties")
				@aEdgesAffectedByRules[cEdgeKey] = aEdge["properties"]
			ok
		end
	
	def _ApplyEffects(oRule, cElementType, pElementId)
		aEffects = oRule.Effects()
		nLen = len(aEffects)
		
		for i = 1 to nLen
			cAspect = aEffects[i][1]
			pValue = aEffects[i][2]
			
			# Inference effects
			if cAspect = "addedge"
				This.AddEdge(pValue[1], pValue[2])
				loop
			ok
			
			if cAspect = "addproperty"
				if cElementType = "node"
					This.SetNodeProperty(pElementId, pValue[1], pValue[2])
				but cElementType = "edge"
					This.SetEdgeProperty(pElementId[1], pElementId[2], pValue[1], pValue[2])
				ok
				loop
			ok
			
			# Validation effects
			if cAspect = "isvalid" or cAspect = "violation"
				if cElementType = "node"
					This.SetNodeProperty(pElementId, cAspect, pValue)
				but cElementType = "edge"
					This.SetEdgeProperty(pElementId[1], pElementId[2], cAspect, pValue)
				ok
				loop
			ok
			
			# Generic property setting
			if cElementType = "node"
				This.SetNodeProperty(pElementId, cAspect, pValue)
			but cElementType = "edge"
				This.SetEdgeProperty(pElementId[1], pElementId[2], cAspect, pValue)
			ok
		end
		
	def _BuildRuleContext(aNodeOrEdge)
		aContext = aNodeOrEdge
		
		if HasKey(aNodeOrEdge, "properties") and aNodeOrEdge["properties"] != NULL
			aContext["metadata"] = aNodeOrEdge["properties"]
			aContext["tags"] = []
			if HasKey(aNodeOrEdge["properties"], "tags")
				aContext["tags"] = aNodeOrEdge["properties"]["tags"]
			ok
		ok
		
		return aContext

	#--------------------------#
	#  RULES ANALYSIS METHODS  #
	#--------------------------#

	def RulesApplied()
		aResult = [
			:hasEffects = FALSE,
			:summary = "",
			:rules = []
		]
		
		bHasEffects = (len(@aNodesAffectedByRules) > 0 or len(@aEdgesAffectedByRules) > 0)
		aResult[:hasEffects] = bHasEffects
		
		if NOT bHasEffects
			aResult[:summary] = "No rules matched any elements."
			return aResult
		ok
		
		acRuleIds = keys(@aRules)
		aResult[:summary] = ''+ len(acRuleIds) + " rule(s) defined, " + 
		                     (len(@aNodesAffectedByRules) + len(@aEdgesAffectedByRules)) + " element(s) affected"
		
		nLenRules = len(acRuleIds)
		for i = 1 to nLenRules
			cRuleId = acRuleIds[i]
			oRule = @aRules[cRuleId]
			
			acAffectedNodes = This.NodesAffectedByRule(cRuleId)
			acAffectedEdges = This.EdgesAffectedByRule(cRuleId)
			
			bRuleMatched = (len(acAffectedNodes) > 0 or len(acAffectedEdges) > 0)
			
			if bRuleMatched
				aRuleInfo = [
					:id = cRuleId,
					:condition = oRule.@cConditionType,
					:conditionParams = oRule.@aConditionParams,
					:effects = oRule.Effects(),
					:affectedNodes = acAffectedNodes,
					:affectedEdges = acAffectedEdges,
					:matchCount = len(acAffectedNodes) + len(acAffectedEdges)
				]
				aResult[:rules] + aRuleInfo
			ok
		end
		
		return aResult

	# Get all nodes affected by any rule
	def NodesAffectedByRules()
		return keys(@aNodesAffectedByRules)
	
		def NodesAffected()
			return This.NodesAffectedByRules()
	
		def AffectedNodes()
			return This.NodesAffectedByRules()

	# Get nodes affected by specific rule

	def NodesAffectedByRule(pcRuleId)
		oRule = This.Rule(pcRuleId)
		if oRule = NULL
			return []
		ok
		return This.NodesAffectedByRuleObject(oRule)
	
	def NodesAffectedByRuleObject(oRule)
		acAffected = []
		acNodeIds = keys(@aNodesAffectedByRules)
		nLen = len(acNodeIds)
		
		for i = 1 to nLen
			aNode = This.Node(acNodeIds[i])
			aContext = This._BuildRuleContext(aNode)
			if oRule.Matches(aContext)
				acAffected + acNodeIds[i]
			ok
		end
		
		return acAffected

	# Get nodes affected by multiple rules
	def NodesAffectedByTheseRules(paoRules)
		
		acAffected = []
		acNodeIds = keys(@aNodesAffectedByRules)
		nNodeLen = len(acNodeIds)
		
		for i = 1 to nNodeLen
			aNode = This.Node(acNodeIds[i])
			aContext = This._BuildRuleContext(aNode)
			
			# Check if any of the provided rules match
			nRuleLen = len(paoRules)
			for j = 1 to nRuleLen
				if paoRules[j].Matches(aContext)
					if find(acAffected, acNodeIds[i]) = 0
						acAffected + acNodeIds[i]
					ok
					exit  # Node matched, no need to check more rules
				ok
			end
		end
		
		return acAffected
	
		def NodesAffectedByRulesIn(paoRules)
			return This.NodesAffectedByTheseRules(paoRules)
	
	# Get nodes NOT affected by any rule
	def NodesNotAffectedByRules()
	
		acAllNodes = []
		aNodes = This.Nodes()
		nLen = len(aNodes)
		for i = 1 to nLen
			acAllNodes + aNodes[i]["id"]
		end
		
		acAffected = keys(@aNodesAffectedByRules)
		acNotAffected = []
		
		nLen = len(acAllNodes)
		for i = 1 to nLen
			if find(acAffected, acAllNodes[i]) = 0
				acNotAffected + acAllNodes[i]
			ok
		end
		
		return acNotAffected
	
		def NodesNotAffected()
			return This.NodesNotAffectedByRules()
	
		def UnaffectedNodes()
			return This.NodesNotAffectedByRules()
	
	#--- EDGES
	
	def EdgesAffectedByRules()
		return keys(@aEdgesAffectedByRules)
	
		def EdgesAffected()
			return This.EdgesAffectedByRules()
	
		def AffectedEdges()
			return This.EdgesAffectedByRules()
	
	def EdgesAffectedByRule(pRule)
		if isString(pRule)
			pRule = This.RuleObject(pRule)
		ok

		acAffected = []
		acEdgeKeys = keys(@aEdgesAffectedByRules)
		nLen = len(acEdgeKeys)
		
		for i = 1 to nLen
			acParts = @split(acEdgeKeys[i], "->")
			aEdge = This.Edge(acParts[1], acParts[2])
			aContext = This._BuildRuleContext(aEdge)

			if pRule.Matches(aContext)
				acAffected + acEdgeKeys[i]
			ok
		end
		
		return acAffected
	
		def EdgesAffectedBy(pRule)
			return This.EdgesAffectedByRule(pRule)
	
	def EdgesAffectedByTheseRules(paoRules)
		
		acAffected = []
		acEdgeKeys = keys(@aEdgesAffectedByRules)
		nEdgeLen = len(acEdgeKeys)
		
		for i = 1 to nEdgeLen
			acParts = @split(acEdgeKeys[i], "->")
			aEdge = This.Edge(acParts[1], acParts[2])
			aContext = This._BuildRuleContext(aEdge)
			
			nRuleLen = len(paoRules)
			for j = 1 to nRuleLen
				if paoRules[j].Matches(aContext)
					if find(acAffected, acEdgeKeys[i]) = 0
						acAffected + acEdgeKeys[i]
					ok
					exit
				ok
			end
		end
		
		return acAffected
	
		def EdgesAffectedByRulesIn(paoRules)
			return This.EdgesAffectedByTheseRules(paoRules)
	
	def EdgesNotAffectedByRules()
		
		acAllEdges = []
		aEdges = This.Edges()
		nLen = len(aEdges)
		for i = 1 to nLen
			acAllEdges + (aEdges[i]["from"] + "->" + aEdges[i]["to"])
		end
		
		acAffected = keys(@aEdgesAffectedByRules)
		acNotAffected = []
		
		nLen = len(acAllEdges)
		for i = 1 to nLen
			if find(acAffected, acAllEdges[i]) = 0
				acNotAffected + acAllEdges[i]
			ok
		end
		
		return acNotAffected
	
		def EdgesNotAffected()
			return This.EdgesNotAffectedByRules()
	
		def UnaffectedEdges()
			return This.EdgesNotAffectedByRules()
	
	#--- COMBINED
	
	def ElementsAffectedByRules()
		return [
			:nodes = This.NodesAffectedByRules(),
			:edges = This.EdgesAffectedByRules()
		]
	
		def AffectedElements()
			return This.ElementsAffectedByRules()
	
	def ElementsNotAffectedByRules()
		return [
			:nodes = This.NodesNotAffectedByRules(),
			:edges = This.EdgesNotAffectedByRules()
		]
	
		def UnaffectedElements()
			return This.ElementsNotAffectedByRules()

	#-------------#
	#  INFERENCE  #
	#-------------#

	def ApplyInference()
	        if @oRuleEngine != NULL
	            return @oRuleEngine.ApplyInference()
	        ok
	        return 0

	def AddInferenceRule(pcRuleType)
		if NOT HasKey(@aProperties, pcRuleType)
			@aProperties = []
		ok
		
		cType = upper(pcRuleType)
		
		aRule = [
			:type = cType,
			:inferredEdges = []
		]
		
		if NOT HasKey(@aProperties, :InferenceRules)
			@aProperties + ["inferenceRules", []]
		ok
		
		@aProperties[:InferenceRules] + aRule


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
			This.AddEdgeXT(aNewEdge[1], aNewEdge[2], "(inferred)")
		end
		
		return nInferred

	def _ApplySymmetry(paRule)

	    _nResult_ = 0
	    acNewEdges = []
	    nEdgeLen = len(@acEdges)
	    
	    # Only process existing edges (ignore those added during this call)
	    for i = 1 to nEdgeLen
	        aEdge = @acEdges[i]
	        
	        # Skip already inferred edges
	        if substr(aEdge["label"], "(inferred") > 0
	            loop
	        ok
	        
	        cFrom = aEdge["from"]
	        cTo = aEdge["to"]
	        
	        if NOT This.EdgeExists(cTo, cFrom)
	            if ring_find(acNewEdges, [cTo, cFrom]) = 0
	                acNewEdges + [cTo, cFrom]
	                _nResult_ += 1
	            ok
	        ok
	    end
	    
	    nNewLen = len(acNewEdges)
	    for i = 1 to nNewLen
	        aNewEdge = acNewEdges[i]
	        This.AddEdgeXT(aNewEdge[1], aNewEdge[2], "(inferred-symmetric)")
	    end

	    return _nResult_

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
			This.AddEdgeXT(aNewEdge[1], aNewEdge[2], "(inferred-composed)")
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

	#--------------#
	#  VALIDATION  #
	#--------------#

	def Validators()
		return @acValidators

	def SetValidators(pacValidators)
		@acValidators = pacValidators

	def Validate()
	        if @oRuleEngine = NULL
	            return [ :status = "pass", :issues = [] ]
	        ok
	        
	        return @oRuleEngine.Validate("validation")
	    
	def ValidateXT(pValidator)
	        if isString(pValidator)
	            return This.ValidateDomain(pValidator)
	        but isList(pValidator)
	            aResults = []
	            for cDomain in pValidator
	                aResults + This.ValidateDomain(cDomain)
	            end
	            return This._AggregateMultiResults(aResults)
	        ok
	    
	def ValidateDomain(pcDomain)
	        if @oRuleEngine = NULL
	            return [ :status = "pass", :domain = pcDomain, :issues = [] ]
	        ok
	        
	        return @oRuleEngine.ValidateDomain(lower(pcDomain))
	    
	def IsValid()
	        aResult = This.Validate()
	        return aResult[:status] = "pass"
	    
	def IsValidXT(pValidator)
	        aResult = This.ValidateXT(pValidator)
	        return aResult[:status] = "pass"

	def _ValidateSingle(pcValidator)
		switch lower(pcValidator)
		on "dag"
			return This._ValidateDAG()
		on "reachability"
			return This._ValidateReachability()
		on "completeness"
			return This._ValidateCompleteness()
		on "constraints"
			return This.ValidateConstraints()
		other
			# User-defined validator
			cMethodName = "Validate" + pcValidator
			if SystemMethod(This, cMethodName)
				return call SystemMethod(This, cMethodName)
			else
				return [
					:status = "error",
					:domain = pcValidator,
					:issueCount = 0,
					:issues = ["Unknown validator: " + pcValidator],
					:affectedNodes = []
				]
			ok
		off

	def _ValidateDAG()
		bIsDAG = NOT This.CyclicDependencies()
		acAffected = []
		
		if NOT bIsDAG
			oAnalyzer = new stzGraphAnalyzer(This)
			acAffected = oAnalyzer.CyclicNodes()
		ok
		
		return [
			:status = iif(bIsDAG, "pass", "fail"),
			:domain = "dag",
			:issueCount = iif(bIsDAG, 0, 1),
			:issues = iif(bIsDAG, [], ["Graph contains cycles"]),
			:affectedNodes = acAffected
		]
	
	def _ValidateReachability()
		acStartNodes = This.NodesByType("start")
		acEndpointNodes = This.NodesByType("endpoint")
		aIssues = []
		acAffected = []
		
		nEndLen = len(acEndpointNodes)
		for i = 1 to nEndLen
			bReachable = FALSE
			nStartLen = len(acStartNodes)
			for j = 1 to nStartLen
				if This.PathExists(acStartNodes[j], acEndpointNodes[i])
					bReachable = TRUE
					exit
				ok
			end
			if NOT bReachable
				aIssues + "Endpoint unreachable: " + acEndpointNodes[i]
				acAffected + acEndpointNodes[i]
			ok
		end
	
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "reachability",
			:issueCount = len(aIssues),
			:issues = aIssues,
			:affectedNodes = acAffected
		]
	
	def _ValidateCompleteness()
		aIssues = []
		acAffected = []
		acDecisions = This.NodesByType("decision")
		nLen = len(acDecisions)

		for i = 1 to nLen
			if len(This.Neighbors(acDecisions[i])) < 2
				aIssues + "Decision node has fewer than 2 paths: " + acDecisions[i]
				acAffected + acDecisions[i]
			ok
		end
	
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "completeness",
			:issueCount = len(aIssues),
			:issues = aIssues,
			:affectedNodes = acAffected
		]

	#--------------------#
	#  5. RICH QUERYING  #
	#--------------------#

	def Query(pcPattern)
		if isString(pcPattern)
			return This._QueryByString(pcPattern)
		ok
		
		if isList(pcPattern)
			return This._QueryByList(pcPattern)
		ok
		
		return []

	# Query nodes with property
	def NodesWithProperty(pcProperty)
		acResult = []
		nLen = len(@aNodes)
		
		for i = 1 to nLen
			aNode = @aNodes[i]
			if HasKey(aNode, "properties") and HasKey(aNode["properties"], pcProperty)
				acResult + aNode["id"]
			ok
		end
		
		return acResult
	

	# Query nodes with property value or condition
	def NodesWithPropertyXT(pcProperty, pValue)
		acResult = []
		
		# Handle named parameters
		bIsInSection = FALSE
		nMin = 0
		nMax = 0
		pCompareValue = pValue
		
		if isList(pValue)
			oVal = new stzList(pValue)
			
			if oVal.IsInSectionOrBetweenNamedParam()
				bIsInSection = TRUE
				nMin = pValue[2][1]
				nMax = pValue[2][2]
			else
				pCompareValue = pValue
			ok
		ok
		
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			
			if HasKey(aNode, "properties") and HasKey(aNode["properties"], pcProperty)
				pNodeValue = aNode["properties"][pcProperty]
				
				if bIsInSection
					if isNumber(pNodeValue) and pNodeValue >= nMin and pNodeValue <= nMax
						acResult + aNode["id"]
					ok
				else
					if pNodeValue = pCompareValue
						acResult + aNode["id"]
					ok
				ok
			ok
		end
		
		return acResult	
	
	# Query nodes with any tag
	def NodesWithAnyTag(paTags)
		acResult = []
		nLen = len(@aNodes)
		
		for i = 1 to nLen
			aNode = @aNodes[i]
			
			if HasKey(aNode, "properties") and HasKey(aNode["properties"], "tags")
				aNodeTags = aNode["properties"]["tags"]
				
				nTagLen = len(paTags)
				for j = 1 to nTagLen
					if ring_find(aNodeTags, paTags[j]) > 0
						if ring_find(acResult, aNode["id"]) = 0
							acResult + aNode["id"]
						ok
						exit
					ok
				end
			ok
		end
		
		return acResult


	def _QueryByString(pcPattern)
		acResults = []
		
		if substr(pcPattern, "find_nodes_")
			cNodeType = substr(pcPattern, "find_nodes_", "")
			acResults = This._FindNodesByPattern(cNodeType)
		ok
		
		if substr(pcPattern, "find_paths_")
			acParts = @split(pcPattern, "_to_")
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
		nLen = len(@aNodes)
		
		for i = 1 to nLen
			aNode = @aNodes[i]
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
		nLen = len(@aNodes)
		
		for i = 1 to nLen
			aNode = @aNodes[i]
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
		next
		
		return acFound

	#------------------------------------#
	#  NODE FINDING AND PATH OPERATIONS  #
	#------------------------------------#
	
	def HasNode(pcNodeId)
		return This.NodeExists(pcNodeId)
	
	def FindNode(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return []
		ok
		
		# Find all paths leading to this node
		acAllPaths = []
		acRoots = This.DependencyFreeNodes()
		
		if len(acRoots) = 0
			# If no root nodes, use all nodes as potential starts
			acRoots = []
			nLen = len(@aNodes)
			for i = 1 to nLen
				acRoots + @aNodes[i]["id"]
			end
		ok
		
		# Find paths from each root to target node
		nLen = len(acRoots)
		for i = 1 to nLen
			cRoot = acRoots[i]
			if cRoot != pcNodeId
				acPaths = This.FindAllPaths(cRoot, pcNodeId)
				nPathLen = len(acPaths)
				for j = 1 to nPathLen
					acAllPaths + acPaths[j]
				end
			ok
		end
		
		# If node is a root itself or isolated, return single-element path
		if len(acAllPaths) = 0
			acAllPaths + [pcNodeId]
		ok
		
		return acAllPaths
	
		def PathsTo(pcNodeId)
			return This.FindNode(pcNodeId)
	
		def PathsToNode(pcNodeId)
			return This.FindNode(pcNodeId)

	def FindPathsMatching(pFunc)
		acMatchingPaths = []
		nNodeLen = len(@aNodes)
		
		for i = 1 to nNodeLen
			for j = 1 to nNodeLen
				aNodeI = @aNodes[i]
				aNodeJ = @aNodes[j]
				
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

	def NodesByType(pType)
		aFound = []
		for aNode in This.Nodes()
			if HasKey(aNode, "properties") and 
			   HasKey(aNode["properties"], "type") and
			   aNode["properties"]["type"] = pType
				aFound + aNode["id"]
			ok
		end
		return aFound
	
	def NodesByProperty(pProperty, pValue)
		aFound = []
		for aNode in This.Nodes()
			if HasKey(aNode, "properties") and 
			   HasKey(aNode["properties"], pProperty)
				
				propVal = aNode["properties"][pProperty]
				
				# Handle string/symbol comparison
				bMatch = FALSE
				if propVal = pValue
					bMatch = TRUE
				but isString(propVal) and isString(pValue)
					if lower(propVal) = lower(pValue)
						bMatch = TRUE
					ok
				ok
				
				if bMatch
					aFound + aNode["id"]
				ok
			ok
		end
		return aFound

		def NodesByProp(pProperty, pValue)
			return This.NodesByProperty(pProperty, pValue)
	
	def EdgesByProperty(pProperty, pValue)
		aFound = []
		for aEdge in This.Edges()
			if HasKey(aEdge, "properties") and 
			   HasKey(aEdge["properties"], pProperty) and
			   aEdge["properties"][pProperty] = pValue
				aFound + [aEdge["from"], aEdge["to"]]
			ok
		end
		return aFound

		def EdgesByProp(pProperty, pValue)
			return This.EdgesByProperty(pProperty, pValue)
	
	def RemoveNodeProperties(pcNodeId)
		nLen = len(@aNodes)
		for i = 1 to nLen
			if @aNodes[i]["id"] = pcNodeId
				@aNodes[i]["properties"] = []
				return
			ok
		end
	
		def ClearNodeProperties(pcNodeId)
			This.RemoveNodeProperties(pcNodeId)
	
		def RemoveNodeProps(pcNodeId)
			This.RemoveNodeProperties(pcNodeId)
	
		def ClearNodeProps(pcNodeId)
			This.RemoveNodeProperties(pcNodeId)

	def RemoveAllProperties()
		# Clear node properties
		nLen = len(@aNodes)
		for i = 1 to nLen
			@aNodes[i]["properties"] = []
		end
		
		# Clear edge properties
		nLen = len(@acEdges)
		for i = 1 to nLen
			@acEdges[i]["properties"] = []
		end
	
		def ClearAllProperties()
			This.RemoveAllProperties()

	#--------------------------#
	#  PROPERTY-BASED QUERIES  #
	#--------------------------#
	
	def NodesWith(pcKey, pValue)
	    if isList(pValue) and len(pValue) = 2 and isString(pValue[1])
	        cOperator = pValue[1]
	
	        switch cOperator
	        on "equals"
	            return This.NodesWithPropertyValue(pcKey, pValue[2])
	        on "insection"
	            return This.NodesWithPropertyInSection(pcKey, pValue[2][1], pValue[2][2])
	        off
	    ok
	
	    stzraise("Unsupported condition syntax!")
	
	def NodesWithPropertyValue(pcKey, pValue)
	    if CheckParams()
	        if isList(pValue) and StzListQ(pValue).IsInSectionNamedParam() and
	           len(pValue) = 2 and isNumber(pValue) and isNumber(pValue)
	
	            return This.NodesWithPropertyInSection(pcKey, pValue[1], pValue[2])
	        ok
	    ok
	
	    acResult = []
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        if HasKey(aNode, "properties") and 
	           HasKey(aNode["properties"], pcKey) and
	           aNode["properties"][pcKey] = pValue
	
	            acResult + aNode["id"]
	        ok
	    end
	    
	    return acResult
	
	    def NodesWhereProperty(pcKey, pValue)
	        return This.NodesWithPropertyValue(pcKey, pValue)
	
	def NodesWithPropertyInSection(pcKey, pnMin, pnMax)
	    acResult = []
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        if HasKey(aNode, "properties") and 
	           HasKey(aNode["properties"], pcKey)
	            nValue = aNode["properties"][pcKey]
	            if isNumber(nValue) and nValue >= pnMin and nValue <= pnMax
	                acResult + aNode["id"]
	            ok
	        ok
	    end
	    
	    return acResult
	
	    def NodesWherePropertyInSection(pcKey, pnMin, pnMax)
	        return This.NodesWithPropertyInSection(pcKey, pnMin, pnMax)
	
	def EdgesWithProperty(pcKey)
	    acResult = []
	    aEdges = This.Edges()
	    nLen = len(aEdges)
	    
	    for i = 1 to nLen
	        aEdge = aEdges[i]
	        if HasKey(aEdge, "properties") and 
	           HasKey(aEdge["properties"], pcKey)
	            acResult + (aEdge["from"] + "->" + aEdge["to"])
	        ok
	    end
	    
	    return acResult
	
	    def EdgesHavingProperty(pcKey)
	        return This.EdgesWithProperty(pcKey)
	
	def EdgesWithPropertyValue(pcKey, pValue)
	    acResult = []
	    aEdges = This.Edges()
	    nLen = len(aEdges)
	    
	    for i = 1 to nLen
	        aEdge = aEdges[i]
	        if HasKey(aEdge, "properties") and 
	           HasKey(aEdge["properties"], pcKey) and
	           aEdge["properties"][pcKey] = pValue
	            acResult + (aEdge["from"] + "->" + aEdge["to"])
	        ok
	    end
	    
	    return acResult
	
	    def EdgesWhereProperty(pcKey, pValue)
	        return This.EdgesWithPropertyValue(pcKey, pValue)

	#---------------------#
	#  TAG-BASED QUERIES  #
	#---------------------#
	
	def TaggedNodes()
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        if HasKey(aNode, "properties") and 
	           HasKey(aNode["properties"], "tags") and
	           len(aNode["properties"]["tags"]) > 0
	            return TRUE
	        ok
	    end
	    
	    return FALSE
	
	    def NodesWithTags()
	        return This.TaggedNodes()
	
	    def NodesTagged()
	        return This.TaggedNodes()
	
	def NodesWithTag(pcTag)
	    if CheckParams()
	        if isList(pcTag)
	            return This.NodesWithTheseTags(pcTag)
	        ok
	    ok
	
	    acResult = []
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        if HasKey(aNode, "properties") and 
	           HasKey(aNode["properties"], "tags")
	            aTags = aNode["properties"]["tags"]
	            if ring_find(aTags, pcTag) > 0
	                acResult + aNode["id"]
	            ok
	        ok
	    end
	    
	    return acResult
	
	    def NodesTaggedWith(pcTag)
	        return This.NodesWithTag(pcTag)

	
	def NodesWithTheseTags(pacTags)
	    acResult = []
	    aNodes = This.Nodes()
	    nNodeLen = len(aNodes)
	    
	    for i = 1 to nNodeLen
	        aNode = aNodes[i]
	        if HasKey(aNode, "properties") and 
	           HasKey(aNode["properties"], "tags")
	            aTags = aNode["properties"]["tags"]
	            bHasAll = TRUE
	            
	            nTagLen = len(pacTags)
	            for j = 1 to nTagLen
	                if ring_find(aTags, pacTags[j]) = 0
	                    bHasAll = FALSE
	                    exit
	                ok
	            end
	            
	            if bHasAll
	                acResult + aNode["id"]
	            ok
	        ok
	    end
	    
	    return acResult
	
	def NodesWithAnyOfTheseTags(pacTags)
	    acResult = []
	    aNodes = This.Nodes()
	    nNodeLen = len(aNodes)
	    
	    for i = 1 to nNodeLen
	        aNode = aNodes[i]
	        if HasKey(aNode, "properties") and 
	           HasKey(aNode["properties"], "tags")
	            aTags = aNode["properties"]["tags"]
	            
	            nTagLen = len(pacTags)
	            for j = 1 to nTagLen
	                if ring_find(aTags, pacTags[j]) > 0
	                    acResult + aNode["id"]
	                    exit
	                ok
	            end
	        ok
	    end
	    
	    return acResult
	
	    def NodesTaggedWithAnyOfThese(pacTags)
	        return This.NodesWithAnyOfTheseTags(pacTags)
	
	def EdgesWithTag(pcTag)
	    acResult = []
	    aEdges = This.Edges()
	    nLen = len(aEdges)
	    
	    for i = 1 to nLen
	        aEdge = aEdges[i]
	        if HasKey(aEdge, "properties") and 
	           HasKey(aEdge["properties"], "tags")
	            aTags = aEdge["properties"]["tags"]
	            if ring_find(aTags, pcTag) > 0
	                acResult + (aEdge["from"] + "->" + aEdge["to"])
	            ok
	        ok
	    end
	    
	    return acResult
	
	    def EdgesTaggedWith(pcTag)
	        return This.EdgesWithTag(pcTag)
	
	    def EdgesHavingTag(pcTag)
	        return This.EdgesWithTag(pcTag)

	#--------------#
	#  SIMULATION  #
	#--------------#

	def CreateSimulation(pcId)
	        oSim = new stzGraphSimulation(pcId)
	        oSim.SetGraph(This)
	        return oSim
	    
	def LoadSimulation(pSource)
	        if isString(pSource)
	            # Load from file
	            oParser = new stzSimulationParser()
	            oSim = oParser.ParseFile(pSource)
	            oSim.SetGraph(This)
	            return oSim
	        but isObject(pSource)
	            pSource.SetGraph(This)
	            return pSource
	        ok
	    
	def RunSimulation(pSim)
	        if isString(pSim)
	            # Load and run
	            oSim = This.LoadSimulation(pSim)
	            return oSim.Run()
	        but isObject(pSim)
	            pSim.SetGraph(This)
	            return pSim.Run()
	        ok

	#-------------------------------#
	#  EXPORT AND INTEROPERABILITY  #
	#-------------------------------#

	def ToHashlist()
		return [
			:id = @cId,
			:nodes = @aNodes,
			:edges = @acEdges,
			:properties = This.Properties()
		]

	def ExportToDOT()
		cDOT = "digraph " + This.Id() + " {" + nl
		cDOT += "  rankdir=LR;" + nl
		cDOT += "  node [shape=box];" + nl + nl
		
		# Export nodes
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			cId = aNode["id"]
			cLabel = aNode["label"]
			
			# Remove @ prefix if present
			if left(cId, 1) = "@"
				cId = @substr(cId, 2, len(cId))
			ok
			
			cDOT += "  " + cId + " [label=" + '"' + cLabel + '"' + "];" + nl
		end
		
		cDOT += nl
		
		# Export edges
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			cLabel = aEdge["label"]
			
			# Remove @ prefix if present
			if left(cFrom, 1) = "@"
				cFrom = @substr(cFrom, 2, len(cFrom))
			ok
			if left(cTo, 1) = "@"
				cTo = @substr(cTo, 2, len(cTo))
			ok
			
			cDOT += "  " + cFrom + " -> " + cTo
			if cLabel != ""
				cDOT += " [label=" + '"' + cLabel + '"' + "]"
			ok
			cDOT += ";" + nl
		end
		
		cDOT += "}" + nl
		return cDOT
	
		def ExportToDotQ()
			oDotCode = new stzDotCode()
			oDotCode.SetCode(This.ExportToDot())
			return oDotCode

		def Dot()
			return This.ExportToDot()

			def DotQ()
				return This.ExportToDotQ()

		def ToDot()
			return This.ExportToDot()

			def ToDotQ()
				return This.ExportToDotQ()

	def ExportToJSON()
		acNodes = []
		acEdges = []
		
		# Process nodes and remove @ prefix
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			cId = aNode["id"]
			if substr(cId, 1, 1) = "@"
				cId = substr(cId, 2, len(cId) - 1)
			ok
			acNodes + [
				:id = cId,
				:label = aNode["label"],
				:properties = aNode["properties"]
			]
		end
		
		# Process edges and remove @ prefix
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			if substr(cFrom, 1, 1) = "@"
				cFrom = substr(cFrom, 2, len(cFrom) - 1)
			ok
			if substr(cTo, 1, 1) = "@"
				cTo = substr(cTo, 2, len(cTo) - 1)
			ok
			acEdges + [
				:from = cFrom,
				:to = cTo,
				:label = aEdge["label"],
				:properties = aEdge["properties"]
			]
		end
		
		cJSON = "{" + nl
		cJSON += '  "id": "' + This.Id() + '",' + nl
		cJSON += '  "nodes": [' + nl
		
		nLen = len(acNodes)
		for i = 1 to nLen
			cJSON += '    ' + @ToJSON(acNodes[i])
			if i < nLen
				cJSON += ","
			ok
			cJSON += nl
		end
		
		cJSON += '  ],' + nl
		cJSON += '  "edges": [' + nl
		
		nLen = len(acEdges)
		for i = 1 to nLen
			cJSON += '    ' + @ToJSON(acEdges[i])
			if i < nLen
				cJSON += ","
			ok
			cJSON += nl
		end
		
		cJSON += '  ],' + nl
		cJSON += '  "metrics": ' + @ToJSON([
			:nodeCount = len(@aNodes),
			:edgeCount = len(@acEdges),
			:density = This.NodeDensity(),
			:longestPath = This.LongestPath(),
			:hasCycles = This.CyclicDependencies()
		]) + nl
		cJSON += "}"
		
		return cJSON

		def Json()
			return This.ExportToJson()

		def ToJson()
			return This.ExportToJson()

	def ExportToYAML()
		cYAML = "graph: " + This.Id() + nl
		cYAML += "nodes:" + nl
		
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			cId = aNode["id"]
			
			# Remove @ prefix if present
			if left(cId, 1) = "@"
				cId = @substr(cId, 2, len(cId))
			ok
			
			cYAML += "  - id: " + cId + nl
			cYAML += "    label: " + aNode["label"] + nl
			if len(aNode["properties"]) > 0
				cYAML += "    properties:" + nl
				acProps = aNode["properties"]
				nPropLen = len(acProps)
				for j = 1 to nPropLen
					cYAML += "      - " + string(acProps[j][1]) + nl
				end
			ok
		end
		
		cYAML += nl + "edges:" + nl
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			
			# Remove @ prefix if present
			if left(cFrom, 1) = "@"
				cFrom = @substr(cFrom, 2, len(cFrom))
			ok
			if left(cTo, 1) = "@"
				cTo = @substr(cTo, 2, len(cTo))
			ok
			
			cYAML += "  - from: " + cFrom + nl
			cYAML += "    to: " + cTo + nl
			cYAML += "    label: " + aEdge["label"] + nl
		end
		
		return cYAML
	
		def Yaml()
			return This.ExportToYaml()

		def ToYaml()
			return This.ExportToYaml()

	#------------------------#
	#  VISUALISING IN ASCII  #
	#------------------------#

	def Show()
		oViz = new stzGraphAsciiVisualizer(This)
		oViz.Show()

	def View() #TODO // Make it possible by deleagating to stzDiagram
		stzraise("Unavailable method for stzGrap! Use Show() instead.")

	def ShowHorizontal()
		oViz = new stzGraphAsciiVisualizer(This)
		oViz.ShowHorizontal()

		def ShowH()
			This.ShowHorizontal()

	def ShowVertical()
		oViz = new stzGraphAsciiVisualizer(This)
		oViz.ShowVertical()

		def ShowV()
			This.ShowVertical()

	def ShowWithLegend()
		oViz = new stzGraphAsciiVisualizer(This)
		oViz.ShowWithLegend()

	def ShowXT(paOptions)
		oViz = new stzGraphAsciiVisualizer(This)
		oViz.Show(paOptions)

	def Explain()
		oViz = new stzGraphExplainer(This)
		return oViz.Explain()

	#--------------------#
	#  GRAPH ALGORITHMS  #
	#--------------------#

	def ShortestPath(pcFrom, pcTo)
	    if CheckParams()
	        if isList(pcFrom) and StzListQ(pcFrom).IsFromNamedParam()
	            pcFrom = pcFrom[2]
	        ok
	        if isList(pcTo) and StzListQ(pcTo).IsToNamedParam()
	            pcTo = pcTo[2]
	        ok
	    ok
	
	    if NOT This.NodeExists(pcFrom) or NOT This.NodeExists(pcTo)
	        return []
	    ok
	
	    if pcFrom = pcTo
	        return [pcFrom]
	    ok
	
	    _acQueue_ = [pcFrom]
	    _acVisited_ = [pcFrom]
	    _aParentMap_ = [ [pcFrom, NULL] ]
	
	    while len(_acQueue_) > 0
	        _cCurrent_ = _acQueue_[1]
	        del(_acQueue_, 1)
	        
	        if _cCurrent_ = pcTo
	            _acPath_ = []
	            _cNode_ = pcTo
	            
	            while _cNode_ != NULL
	                _acPath_ + _cNode_
	                
	                _cParent_ = NULL
	                _nMapLen_ = len(_aParentMap_)
	                for _j_ = 1 to _nMapLen_
	                    if _aParentMap_[_j_][1] = _cNode_
	                        _cParent_ = _aParentMap_[_j_][2]
	                        exit
	                    ok
	                end
	                _cNode_ = _cParent_
	            end
	            
	            _acReversed_ = []
	            _nPathLen_ = len(_acPath_)
	            for _k_ = _nPathLen_ to 1 step -1
	                _acReversed_ + _acPath_[_k_]
	            end
	            
	            return _acReversed_
	        ok
	
	        _acNeighbors_ = This.Neighbors(_cCurrent_)
	        _nNeighLen_ = len(_acNeighbors_)
	        for _i_ = 1 to _nNeighLen_
	            _cNeighbor_ = _acNeighbors_[_i_]
	            if ring_find(_acVisited_, _cNeighbor_) = 0
	                _acVisited_ + _cNeighbor_
	                _acQueue_ + _cNeighbor_
	                _aParentMap_ + [_cNeighbor_, _cCurrent_]
	            ok
	        end
	    end
	
	    return []

	def _GetParent(paParents, pcNode)
		_nLen_ = len(paParents)
		for _i_ = 1 to _nLen_
			if paParents[_i_][1] = pcNode
				return paParents[_i_][2]
			ok
		end
		return NULL

	def ShortestPathLength(pcFrom, pcTo)
		if CheckParams()
			if isList(pcFrom) and StzListQ(pcFrom).IsFromNamedParam()
				pcFrom = pcFrom[2]
			ok
			if isList(pcTo) and StzListQ(pcTo).IsToNamedParam()
				pcTo = pcTo[2]
			ok
		ok

		_acPath_ = This.ShortestPath(pcFrom, pcTo)
		if len(_acPath_) = 0
			return 0
		ok
		return len(_acPath_) - 1

	def ConnectedComponents()
		_aComponents_ = []
		_acVisited_ = []
		_aNodes_ = This.Nodes()
		
		_nNodeLen_ = len(_aNodes_)
		for _i_ = 1 to _nNodeLen_
			_cNodeId_ = _aNodes_[_i_][:id]
			
			if ring_find(_acVisited_, _cNodeId_) = 0
				_acComponent_ = []
				This._ExploreComponent(_cNodeId_, _acVisited_, _acComponent_)
				_aComponents_ + _acComponent_
			ok
		end
		
		return _aComponents_

	def _ExploreComponent(pcNode, pacVisited, pacComponent)
		pacVisited + pcNode
		pacComponent + pcNode
		
		_acNeighbors_ = This.Neighbors(pcNode)
		_nLen_ = len(_acNeighbors_)
		for _i_ = 1 to _nLen_
			if ring_find(pacVisited, _acNeighbors_[_i_]) = 0
				This._ExploreComponent(_acNeighbors_[_i_], pacVisited, pacComponent)
			ok
		end

	def IsConnected()
		_aComponents_ = This.ConnectedComponents()
		return len(_aComponents_) = 1

	def ArticulationPoints()
		_acArticulation_ = []
		_aNodes_ = This.Nodes()
		
		# Get original component count
		_nOriginalComponents_ = len(This.ConnectedComponents())
		
		_nNodeLen_ = len(_aNodes_)
		for _i_ = 1 to _nNodeLen_
			_cNodeId_ = _aNodes_[_i_][:id]
			
			# Save edges
			_aIncoming_ = This.Incoming(_cNodeId_)
			_aOutgoing_ = This.Neighbors(_cNodeId_)
			_aSavedEdges_ = []
			
			# Save all edges connected to this node
			_aEdges_ = This.Edges()
			_nEdgeLen_ = len(_aEdges_)
			for _j_ = 1 to _nEdgeLen_
				_aEdge_ = _aEdges_[_j_]
				if _aEdge_[:from] = _cNodeId_ or _aEdge_[:to] = _cNodeId_
					_aSavedEdges_ + _aEdge_
				ok
			end
			
			# Temporarily remove node
			_aNode_ = This.Node(_cNodeId_)
			This.RemoveThisNode(_cNodeId_)
			
			# Check if graph is now more fragmented
			_nNewComponents_ = len(This.ConnectedComponents())
			
			# Restore node and edges
			This.AddNodeXTT(_cNodeId_, _aNode_[:label], _aNode_[:properties])
			_nSavedLen_ = len(_aSavedEdges_)
			for _j_ = 1 to _nSavedLen_
				_aEdge_ = _aSavedEdges_[_j_]
				This.AddEdgeXTT(_aEdge_[:from], _aEdge_[:to], _aEdge_[:label], _aEdge_[:properties])
			end
			
			# If components increased, it's an articulation point
			if _nNewComponents_ > _nOriginalComponents_
				_acArticulation_ + _cNodeId_
			ok
		end
		
		return _acArticulation_

	def BetweennessCentrality(pcNodeId)
	    if NOT This.NodeExists(pcNodeId)
	        return 0
	    ok
	
	    _nCentrality_ = 0
	    _aNodes_ = This.Nodes()
	    _nNodeCount_ = len(_aNodes_)
	    
	    for _i_ = 1 to _nNodeCount_
	        _cSource_ = _aNodes_[_i_][:id]
	        if _cSource_ = pcNodeId
	            loop
	        ok
	        
	        for _j_ = 1 to _nNodeCount_
	            _cTarget_ = _aNodes_[_j_][:id]
	            if _cTarget_ = pcNodeId or _cTarget_ = _cSource_
	                loop
	            ok
	            
	            _acPath_ = This.ShortestPath(_cSource_, _cTarget_)
	            
	            if len(_acPath_) = 0
	                loop
	            ok
	            
	            _bInPath_ = FALSE
	            _nPathLen_ = len(_acPath_)
	            for _k_ = 2 to _nPathLen_ - 1
	                if _acPath_[_k_] = pcNodeId
	                    _bInPath_ = TRUE
	                    exit
	                ok
	            end
	            
	            if _bInPath_
	                _nCentrality_++
	            ok
	        end
	    end
	    
	    _nTotalPairs_ = (_nNodeCount_ - 1) * (_nNodeCount_ - 2)
	    
	    if _nTotalPairs_ = 0
	        return 0
	    ok
	    
	    return _nCentrality_ / _nTotalPairs_
	
	def ClosenessCentrality(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok

		_nTotalDistance_ = 0
		_nReachable_ = 0
		_aNodes_ = This.Nodes()
		
		_nNodeLen_ = len(_aNodes_)
		for _i_ = 1 to _nNodeLen_
			_cTarget_ = _aNodes_[_i_][:id]
			if _cTarget_ != pcNodeId
				_nDist_ = This.ShortestPathLength(pcNodeId, _cTarget_)
				if _nDist_ > 0
					_nTotalDistance_ += _nDist_
					_nReachable_++
				ok
			ok
		end
		
		if _nReachable_ = 0
			return 0
		ok
		
		return _nReachable_ / _nTotalDistance_

	def Diameter()
		_nMaxDist_ = 0
		_aNodes_ = This.Nodes()
		_nNodeLen_ = len(_aNodes_)
		
		for _i_ = 1 to _nNodeLen_
			for _j_ = _i_ + 1 to _nNodeLen_
				_nDist_ = This.ShortestPathLength(_aNodes_[_i_][:id], _aNodes_[_j_][:id])
				if _nDist_ > _nMaxDist_
					_nMaxDist_ = _nDist_
				ok
			end
		end
		
		return _nMaxDist_

	def AveragePathLength()
		_nTotalDist_ = 0
		_nPairs_ = 0
		_aNodes_ = This.Nodes()
		_nNodeLen_ = len(_aNodes_)
		
		for _i_ = 1 to _nNodeLen_
			for _j_ = _i_ + 1 to _nNodeLen_
				_nDist_ = This.ShortestPathLength(_aNodes_[_i_][:id], _aNodes_[_j_][:id])
				if _nDist_ > 0
					_nTotalDist_ += _nDist_
					_nPairs_++
				ok
			end
		end
		
		if _nPairs_ = 0
			return 0
		ok
		
		return _nTotalDist_ / _nPairs_

	def ClusteringCoefficient(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok

		# Get all neighbors (both incoming and outgoing)
		_acOutgoing_ = This.Neighbors(pcNodeId)
		_acIncoming_ = This.Incoming(pcNodeId)
		_acAllNeighbors_ = []
		
		# Combine and deduplicate
		_nLen_ = len(_acOutgoing_)
		for _i_ = 1 to _nLen_
			_acAllNeighbors_ + _acOutgoing_[_i_]
		end
		_nLen_ = len(_acIncoming_)
		for _i_ = 1 to _nLen_
			if ring_find(_acAllNeighbors_, _acIncoming_[_i_]) = 0
				_acAllNeighbors_ + _acIncoming_[_i_]
			ok
		end
		
		_nNeighborCount_ = len(_acAllNeighbors_)
		
		if _nNeighborCount_ < 2
			return 0
		ok

		# Count connections between neighbors
		_nConnections_ = 0
		for _i_ = 1 to _nNeighborCount_
			for _j_ = _i_ + 1 to _nNeighborCount_
				if This.EdgeExists(_acAllNeighbors_[_i_], _acAllNeighbors_[_j_]) or
				   This.EdgeExists(_acAllNeighbors_[_j_], _acAllNeighbors_[_i_])
					_nConnections_++
				ok
			end
		end
		
		_nPossible_ = (_nNeighborCount_ * (_nNeighborCount_ - 1)) / 2
		return _nConnections_ / _nPossible_



	#-----------------------#
	#  STZGRAF FILE FORMAT  #
	#-----------------------#

	def ImportGraf(pSource)
		if isString(pSource)
			if right(pSource, 8) = ".stzgraf"
				oParser = new stzGrafParser()
				oLoaded = oParser.ParseFile(pSource)
			else
				oParser = new stzGrafParser()
				oLoaded = oParser.Parse(pSource)
			ok
			
			# Merge into this graph
			This._MergeGraph(oLoaded)
		ok
	
		def LoadGraf(pSource)
			This.ImportGraf(pSource)

	def _MergeGraph(oOther)
		# Add all nodes
		aNodes = oOther.Nodes()
		for aNode in aNodes
			This.AddNodeXTT(aNode["id"], aNode["label"], aNode["properties"])
		end
		
		# Add all edges
		aEdges = oOther.Edges()
		for aEdge in aEdges
			This.AddEdgeXTT(aEdge["from"], aEdge["to"], aEdge["label"], aEdge["properties"])
		end
	
	def ExportToGraf()
		cGraf = 'graph "' + @cId + '"' + NL
		cGraf += '    type: directed' + NL + NL
		
		cGraf += 'nodes' + NL
		for aNode in @aNodes
			cGraf += '    ' + aNode["id"] + NL
		end
		cGraf += NL
		
		cGraf += 'edges' + NL
		for aEdge in @acEdges
			cGraf += '    ' + aEdge["from"] + ' -> ' + aEdge["to"] + NL
		end
		cGraf += NL
		
		# Properties
		cGraf += 'properties' + NL
		for aNode in @aNodes
			if len(aNode["properties"]) > 0
				cGraf += '    ' + aNode["id"] + NL
				acKeys = keys(aNode["properties"])
				for cKey in acKeys
					pValue = aNode["properties"][cKey]
					cGraf += '        ' + cKey + ': '
					if isString(pValue)
						cGraf += '"' + pValue + '"'
					else
						cGraf += pValue
					ok
					cGraf += NL
				end
			ok
		end
		
		return cGraf
	
	def WriteToGrafFile(pcFilename)
		if right(pcFileName, 8) != ".stzgraf"
			pcFileName += ".stzgraf"
		ok
		write(pcFilename, This.ExportToGraf())

		def WriteGraf(pcFileName)
			This.WriteToGrafFile(pcFilename)


class stzGraphAnalyzer

	@oGraph

	def init(poGraph)
		@oGraph = poGraph

	def CyclicNodes()
		acCyclicNodes = []
		
		acNodes = @oGraph.Nodes()
		nLen = len(acNodes)
		for i = 1 to nLen
			aNode = acNodes[i]
			cNodeId = aNode["id"]
			acReachableFromNode = This.ReachableFromNode(cNodeId)
			
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

	def ReachableFromNode(pcStartNode)
		acReachable = []
		acVisited = []
		acQueue = [pcStartNode]
		acVisited + pcStartNode
		
		acEdges = @oGraph.Edges()
		
		while len(acQueue) > 0
			cCurrent = acQueue[1]
			if len(acQueue) > 1
				acQueue = stzright(acQueue, len(acQueue) - 1)
			else
				acQueue = []
			ok
			acReachable + cCurrent
			
			nLen = len(acEdges)
			for i = 1 to nLen
				aEdge = acEdges[i]
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

class stzGraphExplainer

	@oGraph

	def init(poGraph)
		@oGraph = poGraph

	def Explain()
		aoExplanation = [
			:general = [],
			:bottlenecks = [],
			:cycles = [],
			:metrics = []
		]
		
		acBottlenecks = @oGraph.BottleneckNodes()
		oAnalyzer = new stzGraphAnalyzer(@oGraph)
		acCyclic = oAnalyzer.CyclicNodes()
		
		acNodes = @oGraph.Nodes()
		acEdges = @oGraph.Edges()
		
		# General section
		aoExplanation[:general] + ("Graph: " + @oGraph.Id())
		aoExplanation[:general] + ("Nodes: " + len(acNodes) + " | Edges: " + len(acEdges))
		
		# Bottlenecks section
		if len(acBottlenecks) > 0
			nTotalDegree = 0
			nLen = len(acNodes)
			for i = 1 to nLen
				aNode = acNodes[i]
				nIncoming = len(@oGraph.Incoming(aNode["id"]))
				nOutgoing = len(@oGraph.Neighbors(aNode["id"]))
				nTotalDegree += nIncoming + nOutgoing
			end
			nAvgDegree = nTotalDegree / len(acNodes)
			
			aoExplanation[:bottlenecks] + ("Bottleneck nodes: " + joinXT(acBottlenecks, ", "))
			aoExplanation[:bottlenecks] + ("Average degree: " + nAvgDegree)
			
			nLen = len(acBottlenecks)
			for i = 1 to nLen
				cNode = acBottlenecks[i]
				nIncoming = len(@oGraph.Incoming(cNode))
				nOutgoing = len(@oGraph.Neighbors(cNode))
				nDegree = nIncoming + nOutgoing
				aoExplanation[:bottlenecks] + ("  " + cNode + ": degree " + nDegree + " (above average)")
			end
		else
			nTotalDegree = 0
			nLen = len(acNodes)
			for i = 1 to nLen
				aNode = acNodes[i]
				nIncoming = len(@oGraph.Incoming(aNode["id"]))
				nOutgoing = len(@oGraph.Neighbors(aNode["id"]))
				nTotalDegree += nIncoming + nOutgoing
			end
			nAvgDegree = nTotalDegree / len(acNodes)
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
		
		if @oGraph.CyclicDependencies()
			aoExplanation[:cycles] + "WARNING: Circular dependencies detected"
		else
			if len(acCyclic) = 0
				aoExplanation[:cycles] + "No cycles - acyclic graph (DAG)"
			ok
		ok
		
		# Metrics section
		nDensity = @oGraph.NodeDensity()
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
		
		nLongest = @oGraph.LongestPath()
		if nLongest = 0
			aoExplanation[:metrics] + "Longest path: 0 hops (isolated)"
		but nLongest = 1
			aoExplanation[:metrics] + "Longest path: 1 hop"
		else
			aoExplanation[:metrics] + ("Longest path: " + nLongest + " hops")
		ok
		
		return aoExplanation

class stzGraphAsciiVisualizer

	@oGraph
	
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

	def init(poGraph)
		@oGraph = poGraph

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
		acBottlenecks = @oGraph.BottleneckNodes()
		oAnalyzer = new stzGraphAnalyzer(@oGraph)
		acCyclic = oAnalyzer.CyclicNodes()
		acDisplayNodes = []
		
		acNodes = @oGraph.Nodes()
		nLen = len(acNodes)
		for i = 1 to nLen
			aNode = acNodes[i]
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
		acNodes = @oGraph.Nodes()
		nNodeCount = len(acNodes)
		for i = 1 to nNodeCount
			aNode = acNodes[i]
			if len(@oGraph.Incoming(aNode["id"])) = 0
				acRoots + aNode["id"]
			ok
		end
		
		if len(acRoots) = 0
			acRoots + acNodes[1]["id"]
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
		acLines = @split(cBoxed, nl)
		nLen = len(acLines)
		
		for i = 1 to nLen
			cLine = acLines[i]
			? CenterAlignXT(cLine, 25, " ")
		end
		
		pacVisitedPath + pcNodeId
		acNeighbors = @oGraph.Neighbors(pcNodeId)
		
		if len(acNeighbors) = 0
			return
		ok
		
		nNeighborIdx = 0
		nLen = len(acNeighbors)
		for i = 1 to nLen
			cNext = acNeighbors[i]
			nNeighborIdx += 1
			
			if find(pacVisitedPath, cNext) = 0
				aEdge = @oGraph.Edge(pcNodeId, cNext)
				
				if len(acNeighbors) > 1 and nNeighborIdx > 1
					? ""
					? "          ////"
					? ""
					cDisplayLabel = This._GetDisplayLabel(pcNodeId, pacDisplayNodes)
					cBoxed = BoxRound(cDisplayLabel)
					acLines = @split(cBoxed, nl)
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
				aEdge = @oGraph.Edge(pcNodeId, cNext)
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

		acNodes = @oGraph.Nodes()
		nLen = len(acNodes)
		for i = 1 to nLen
			aNode = acNodes[i]
			if len(@oGraph.Incoming(aNode["id"])) = 0
				acRoots + aNode["id"]
			ok
		end
		
		if len(acRoots) = 0
			acRoots + acNodes[1]["id"]
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
		acLines = @split(cBoxed, nl)
		
		acNeighbors = @oGraph.Neighbors(pcNodeId)
		
		if len(pacBoxLines) = 0
			nLen = len(acLines)
			for i = 1 to nLen
				pacBoxLines + acLines[i]
			end
		else
			cConnector = ""
			if len(pacVisited) > 0
				cPrev = pacVisited[len(pacVisited)]
				aEdge = @oGraph.Edge(cPrev, pcNodeId)
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
			aEdge = @oGraph.Edge(pcNodeId, cNext)
			
			if find(pacVisited, cNext) = 0
				This._ShowHorizontalBranchWithNodes(cNext, pacVisited, pacBoxLines, pacArrowLines, pacDisplayNodes)
			else
				pacArrowLines + [pcNodeId, cNext, aEdge["label"]]
			ok
		ok

	def _BuildFeedbackLineWithNodes(pacVisited, pcOrientation, pacDisplayNodes)
		cFeedback = ""
		acEdges = @oGraph.Edges()
		nLen = len(acEdges)
		
		for i = 1 to nLen
			aEdge = acEdges[i]
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
				aE = @oGraph.Edge(cPrev, cNext)
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
				aE = @oGraph.Edge(cPrev, cNext)
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
		nToPos = 0
		nLen = len(pacVisited)
		
		for i = 1 to pnToIdx - 1
			cLabel = This._GetDisplayLabel(pacVisited[i], pacDisplayNodes)
			nBoxWidth = stzlen(cLabel) + 4
			nToPos += nBoxWidth
			
			if i < nLen
				cPrev = pacVisited[i]
				cNext = pacVisited[i + 1]
				aE = @oGraph.Edge(cPrev, cNext)
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
				aE = @oGraph.Edge(cPrev, cNext)
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
		This.ShowXT([ :Lengend = 1 ])

	def Legend()
		acBottlenecks = @oGraph.BottleneckNodes()
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
		
		if @oGraph.CyclicDependencies()
			aoLegend[:feedback] = [ "[...] ↑", "Feedback loop" ]
			aoLegend[:branch] = [ "////", "Branch separator (multiple paths)" ]
		ok
		
		if len(aoLegend) = 0
			aoLegend[:normal] = [ "label", "Regular node" ]
		ok
		
		return aoLegend

#============================================#
#  stzGrafParser - *.stzgraf Format Parser   #
#  Pure graph structure (no domain semantics)#
#============================================#

class stzGrafParser
	
	def init()

	def ParseFile(pcFilename)
		cContent = read(pcFilename)
		return This.Parse(cContent)
	
	def Parse(pcContent)
		oGraph = NULL
		acLines = split(pcContent, NL)
		cSection = ""
		cCurrentNode = ""
		aCurrentProps = []
		
		for cLine in acLines
			cLine = trim(cLine)
			
			if cLine = "" or left(cLine, 1) = "#"
				loop
			ok
			
			# Graph header
			if substr(cLine, "graph ")
				cId = This._ExtractQuoted(cLine)
				oGraph = new stzGraph(cId)
				
			but substr(cLine, "type:")
				# directed, undirected (ignore for now, assume directed)
			
			# Sections
			but cLine = "nodes"
				cSection = "nodes"
				
			but cLine = "edges"
				cSection = "edges"
				
			but cLine = "properties"
				cSection = "properties"
			
			# Parse nodes (just IDs)
			but cSection = "nodes" and NOT substr(cLine, ":")
				oGraph.AddNode(cLine)
			
			# Parse edges
			but cSection = "edges" and substr(cLine, "->")
				aParts = split(cLine, "->")
				cFrom = trim(aParts[1])
				cTo = trim(aParts[2])
				oGraph.Connect(cFrom, cTo)
			
			# Parse properties
			but cSection = "properties"
				if NOT substr(cLine, ":")
					# Node ID
					if cCurrentNode != "" and len(aCurrentProps) > 0
						This._ApplyProperties(oGraph, cCurrentNode, aCurrentProps)
					ok
					cCurrentNode = cLine
					aCurrentProps = []
				else
					# Property: value
					aParts = split(cLine, ":")
					cKey = trim(aParts[1])
					cValue = trim(aParts[2])
					aCurrentProps + [cKey, This._ParseValue(cValue)]
				ok
			ok
		end
		
		# Add last item that wasn't flushed
		 if cCurrentSection = "nodes" and cCurrentItem != ""
		        This._AddNode(oGraph, cCurrentItem, aCurrentProps)
		ok
		
		if cCurrentSection = "positions" and cCurrentId != ""
		        This._AddPosition(oOrg, cCurrentId, aCurrentProps)
		ok

		# Apply last node's properties
		if cCurrentNode != "" and len(aCurrentProps) > 0
			This._ApplyProperties(oGraph, cCurrentNode, aCurrentProps)
		ok
		
		return oGraph
	
	def _ApplyProperties(oGraph, pcNodeId, paProps)
		nLen = len(paProps)
		for i = 1 to nLen step 2
			cKey = paProps[i]
			pValue = paProps[i + 1]
			oGraph.SetNodeProperty(pcNodeId, cKey, pValue)
		end
	
	def _ParseValue(cValue)
		# Try number
		if isdigit(cValue)
			return 0 + cValue
		ok
		
		# Remove quotes
		if left(cValue, 1) = '"' and right(cValue, 1) = '"'
			return @substr(cValue, 2, len(cValue) - 1)
		ok
		
		return cValue
	
	def _ExtractQuoted(cLine)
		nStart = substr(cLine, '"')
		if nStart = 0 return "" ok
		nEnd = @substr(cLine, nStart + 1, len(cLine))
		nEnd = substr(nEnd, '"')
		return @substr(cLine, nStart + 1, nStart + nEnd - 1)
