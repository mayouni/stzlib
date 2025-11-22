#============================================#
#  stzGraph - FUNDAMENTAL GRAPH ABSTRACTION  #
#  Pure computational thinking construct     #
#============================================#

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

	def init(pcId)
		@cId = pcId
		@acNodes = []
		@acEdges = []
		@aRules = []
		@aNodesAffectedByRules = []
		@aEdgesAffectedByRules = []

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

	#------------------------------------------
	#  INSERT NODE BEFORE
	#------------------------------------------
	
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
	
	#------------------------------------------
	#  INSERT NODE AFTER
	#------------------------------------------
	
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
	
	#------------------------------------------
	#  INSERT MULTIPLE NODES
	#------------------------------------------
	
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

	#------------------------------------------
	#  NODE REPLACEMENT
	#------------------------------------------
	
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
	
	#------------------------------------------
	#  EDGE REPLACEMENT
	#------------------------------------------
	
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

	#------------------------------------------
	#  NODE REMOVAL
	#------------------------------------------
	
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
	
	#------------------------------------------
	#  EDGE REMOVAL
	#------------------------------------------
	
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
		nLen = len(@acEdges)
		for i = 1 to nLen
			aEdge = @acEdges[i]
			if aEdge["from"] = pcFromId and aEdge["to"] = pcToId
				return aEdge
			ok
		end
		stzraise("Inexistant edge!")

	def EdgeExists(pcFromId, pcToId)
		return This.Edge(pcFromId, pcToId) != ""

	def Edges()
		return @acEdges

	def EdgeCount()
		return len(@acEdges)

#------------------------------------------
#  NODE NAVIGATION
#------------------------------------------

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

	#------------------------------------------
	#  EDGE NAVIGATION
	#------------------------------------------
	
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

	#------------------------------------------
	#  BATCH UPDATE OPERATIONS
	#------------------------------------------
	
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

	#------------------------------------------
	#  COPY OPERATIONS
	#------------------------------------------
	
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

	#------------------------------------------
	#  MERGE OPERATIONS
	#------------------------------------------
	
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
		acAllProps = []
		aNodes = This.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			if HasKey(aNodes[i], "properties")
				acKeys = keys(aNodes[i]["properties"])
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
					@aNodes[i]["properties"] = []
				ok
				@aNodes[i]["properties"][cProperty] = pValue
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
		nLen = len(@acEdges)
		for i = 1 to nLen
			if @acEdges[i]["from"] = pFromId and @acEdges[i]["to"] = pToId
				if NOT HasKey(@acEdges[i], "properties")
					@acEdges[i]["properties"] = []
				ok
				@acEdges[i]["properties"][cProperty] = pValue
				return
			ok
		end
	
		def SetEdgePrope(pFromId, pToId, cProperty, pValue)
			return This.SetEdgeProperty(pFromId, pToId, cProperty, pValue)

	def EdgeProperty(pFromId, pToId, cProperty)
		aEdge = This.Edge(pFromId, pToId)
		
		if HasKey(aEdge, "properties") and HasKey(aEdge["properties"], cProperty)
			return aEdge["properties"][cProperty]
		else
			stzraise("Inexistant node key or/and property!")
		ok

		def EdgeProp(pFromId, pToId, cProperty)
			return This.EdgeProperty(pFromId, pToId, cProperty)

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

	#------------------------------------------
	#  1. INDEPENDENCE AND PARALLELIZATION
	#------------------------------------------

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

	#--------------------#
	#  RULES MANAGEMENT  #
	#--------------------#

	def AddRule(p)
		if isString(p)
			if HasKey(@aRules, p)
				return
			else
				stzraise("Rule '" + p + "' not found")
			ok
		but isObject(p) and ring_classname(p) = "stzrule"
			@aRules[p.@cRuleId] = p
		ok
	
		def AddRuleObject(oRule)
			This.AddRule(oRule)
	
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

	def ApplyRules()
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
				if oRule.Matches(aContext)
					aEffects = oRule.Effects()
					nEffLen = len(aEffects)
					
					for k = 1 to nEffLen
						cAspect = aEffects[k][1]
						pValue = aEffects[k][2]
						This.SetNodeProperty(cNodeId, cAspect, pValue)
					end
				ok
			end
			
			if HasKey(aNode, "properties")
				@aNodesAffectedByRules[cNodeId] = aNode["properties"]
			ok
		end
		
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
				if oRule.Matches(aContext)
					aEffects = oRule.Effects()
					nEffLen = len(aEffects)
					
					for k = 1 to nEffLen
						cAspect = aEffects[k][1]
						pValue = aEffects[k][2]
						This.SetEdgeProperty(aEdge["from"], aEdge["to"], cAspect, pValue)
					end
				ok
			end
			
			if HasKey(aEdge, "properties")
				@aEdgesAffectedByRules[cEdgeKey] = aEdge["properties"]
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
		aResult[:summary] = len(acRuleIds) + " rule(s) defined, " + 
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

	#------------------------------------#
	#  INFERENCE AND IMPLICIT KNOWLEDGE  #
	#------------------------------------#

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
			This.AddEdgeXT(aNewEdge[1], aNewEdge[2], "(inferred)")
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
			This.AddEdgeXT(aNewEdge[1], aNewEdge[2], "(inferred-symmetric)")
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

	#=== CUSTOM INFERENCE RULES

	def RegisterInferenceRule(pcRuleName, pFunc)
		if NOT isList(@acProperties)
			@acProperties = []
		ok
		
		cName = upper(pcRuleName)
		
		aRule = [
			:name = cName,
			:callback = pFunc
		]
		
		if NOT HasKey(@acProperties, "inferenceRules")
			@acProperties["inferenceRules"] = []
		ok
		
		@acProperties["inferenceRules"] + aRule
	
	def ApplyCustomInference(pcRuleName)
		if NOT HasKey(@acProperties, "inferenceRules")
			return 0
		ok
		
		acRules = @acProperties["inferenceRules"]
		cName = upper(pcRuleName)
		nLen = len(acRules)
		
		for i = 1 to nLen
			aRule = acRules[i]
			if aRule["name"] = cName
				pFunc = aRule["callback"]
				return call pFunc(this)
			ok
		end
		
		return 0
	
	def ApplyAllCustomInference()
		if NOT HasKey(@acProperties, "inferenceRules")
			return 0
		ok
		
		acRules = @acProperties["inferenceRules"]
		nTotalInferred = 0
		nLen = len(acRules)
		
		for i = 1 to nLen
			aRule = acRules[i]
			pFunc = aRule["callback"]
			nInferred = call pFunc()
			nTotalInferred += nInferred
		end
		
		return nTotalInferred
	
	def CustomInferenceRules()
		if NOT HasKey(@acProperties, "inferenceRules")
			return []
		ok
		
		acNames = []
		acRules = @acProperties["inferenceRules"]
		nLen = len(acRules)
		
		for i = 1 to nLen
			acNames + acRules[i]["name"]
		end
		
		return acNames

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

	#------------------------------------------
	#  NODE FINDING AND PATH OPERATIONS
	#------------------------------------------
	
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
			:nodes = This._CopyList(@aNodes),
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
				@aNodes = This._CopyList(aSnapshot["nodes"])
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
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
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
			nLen = len(@aNodes)
			for j = 1 to nLen
				if @aNodes[j]["id"] = aOldNode["id"]
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

	def Snapshots()
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
	#  METADATA OPERATIONS
	#------------------------------------------
	
	def SetNodeMetadata(pNodeId, aMetadata)
		@aNodeMetadata[pNodeId] = aMetadata
	
	def GetNodeMetadata(pNodeId)
		if HasKey(@aNodeMetadata, pNodeId)
			return @aNodeMetadata[pNodeId]
		ok
		return []
	
	def RemoveNodeMetadata(pNodeId)
		if HasKey(@aNodeMetadata, pNodeId)
			@aNodeMetadata[pNodeId] = NULL
		ok
	
	def UpdateNodeMetadata(pNodeId, cKey, pValue)
		if NOT HasKey(@aNodeMetadata, pNodeId)
			@aNodeMetadata[pNodeId] = []
		ok
		@aNodeMetadata[pNodeId][cKey] = pValue
	
	def SetEdgeMetadata(pFromId, pToId, aMetadata)
		cEdgeKey = pFromId + "->" + pToId
		@aEdgeMetadata[cEdgeKey] = aMetadata
	
	def GetEdgeMetadata(pFromId, pToId)
		cEdgeKey = pFromId + "->" + pToId
		if HasKey(@aEdgeMetadata, cEdgeKey)
			return @aEdgeMetadata[cEdgeKey]
		ok
		return []
	
	def RemoveEdgeMetadata(pFromId, pToId)
		cEdgeKey = pFromId + "->" + pToId
		if HasKey(@aEdgeMetadata, cEdgeKey)
			@aEdgeMetadata[cEdgeKey] = NULL
		ok
	
	def UpdateEdgeMetadata(pFromId, pToId, cKey, pValue)
		cEdgeKey = pFromId + "->" + pToId
		if NOT HasKey(@aEdgeMetadata, cEdgeKey)
			@aEdgeMetadata[cEdgeKey] = []
		ok
		@aEdgeMetadata[cEdgeKey][cKey] = pValue
	
	def RemoveAllMetadata()
		@aNodeMetadata = []
		@aEdgeMetadata = []
		@aNodeTags = []
		@aEdgeTags = []

	#------------------------------------------
	#  7. EXPORT AND INTEROPERABILITY
	#------------------------------------------

	def ToHashlist()
		return [
			:id = @cId,
			:nodes = @aNodes,
			:edges = @acEdges,
			:properties = @acProperties
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
					cYAML += "      - " + string(acProps[j]) + nl
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
			stzraise("Can't make the export!")
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
		
		stzraise("Can't make the export!")
		#TODO// Enhance the error messages

	def Exporters()
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

	#------------------------#
	#  VISUALISING IN ASCII  #
	#------------------------#

	def Show()
		oViz = new stzGraphAsciiVisualizer(This)
		oViz.Show()

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
		acLines = split(cBoxed, nl)
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
		acLines = split(cBoxed, nl)
		
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



class stzGraphRule
	@cRuleId
	@cConditionType
	@aConditionParams
	@aEffects
	
	def init(pcRuleId)
		@cRuleId = pcRuleId
		@aEffects = []
	
	def WhenPropertyExists(pcKey)
		@cConditionType = :property_exists
		@aConditionParams = [pcKey]

	def When(pcKey, pValue)
		if isList(pValue)
			oVal = StzListQ(pValue)
			if oVal.IsEqualsNamedParam()
				This.WhenPropertyEquals(pcKey, pValue[2])
				return
			but oVal.IsInRangeNamedParam() or oVal.IsInSectionNamedParam()
				This.WhenPropertyInRange(pcKey, pValue[2][1], pValue[2][2])
				return
			ok
		but isString(pValue)
			if pValue = "exists"
				This.WhenPropertyExists(pcKey)
				return
			ok
		ok
		stzraise("Unsupported syntax!")

	def WhenPropertyEquals(pcKey, pValue)
		@cConditionType = :property_equals
		@aConditionParams = [pcKey, pValue]

	def WhenPropertyInRange(pcKey, nMin, nMax)
		@cConditionType = :property_range
		@aConditionParams = [pcKey, nMin, nMax]
	
	def WhenTagExists(pcTag)
		@cConditionType = :tag_exists
		@aConditionParams = [pcTag]
	
	def Apply(cAspect, pValue)
		@aEffects + [cAspect, pValue]

	def Matches(aNodeOrEdge)
		switch @cConditionType
		on :property_exists
			cKey = @aConditionParams[1]
			if HasKey(aNodeOrEdge, "metadata")
				return HasKey(aNodeOrEdge["metadata"], cKey)
			ok
			if HasKey(aNodeOrEdge, "properties")
				return HasKey(aNodeOrEdge["properties"], cKey)
			ok
			return FALSE
		
		on :property_equals
			cKey = @aConditionParams[1]
			pValue = @aConditionParams[2]
			if HasKey(aNodeOrEdge, "metadata") and HasKey(aNodeOrEdge["metadata"], cKey)
				return aNodeOrEdge["metadata"][cKey] = pValue
			ok
			if HasKey(aNodeOrEdge, "properties") and HasKey(aNodeOrEdge["properties"], cKey)
				return aNodeOrEdge["properties"][cKey] = pValue
			ok
			return FALSE
		
		on :property_range
			cKey = @aConditionParams[1]
			nMin = @aConditionParams[2]
			nMax = @aConditionParams[3]
			nValue = NULL
			if HasKey(aNodeOrEdge, "metadata") and HasKey(aNodeOrEdge["metadata"], cKey)
				nValue = aNodeOrEdge["metadata"][cKey]
			but HasKey(aNodeOrEdge, "properties") and HasKey(aNodeOrEdge["properties"], cKey)
				nValue = aNodeOrEdge["properties"][cKey]
			ok
			if nValue != NULL
				return nValue >= nMin and nValue <= nMax
			ok
			return FALSE
		
		on :tag_exists
			cTag = @aConditionParams[1]
			if HasKey(aNodeOrEdge, "tags")
				return ring_find(aNodeOrEdge["tags"], cTag) > 0
			ok
			if HasKey(aNodeOrEdge, "properties") and HasKey(aNodeOrEdge["properties"], "tags")
				return ring_find(aNodeOrEdge["properties"]["tags"], cTag) > 0
			ok
			return FALSE
		off
		return FALSE
	
	def Effects()
		return @aEffects
