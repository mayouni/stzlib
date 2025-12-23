#============================================#
#  stzGraph - Complete Implementation        #
#  Simplified rules, all methods preserved   #
#============================================#

load "stzGraphRule.ring"

$acGraphTypes = ["structural", "flow", "semantic", "dependency"]
$cDefaultGraphType = "structural"

$acGraphDefaultValidators = ["dag", "reachability", "completeness"]

func GraphTypes()
	return @acGraphTypes 

func DefaultGraphType()
	return @cDefaultGraphType

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

	func IsAStzGraph(pObj)
		return IsStzGraph(pObj)

	func IsStzGraphObject(pObj)
		return IsStzGraph(pObj)

class stzGraph

	@cId = ""
	@cGraphType = $cDefaultGraphType  # "structural", "flow", "semantic", "dependency"
	@aNodes = []
	@aEdges = []

	# Simplified rule storage - rules as hashlists
	@aRules = []  # [ [id, type, condition, effects], ... ]
	@aAffectedNodes = []  # [ [nodeId, [ruleIds]], ... ]
	@aAffectedEdges = []  # [ [edgeKey, [ruleIds]], ... ]
	
	@aProperties = []

	@bEnforceConstraints = FALSE

	def init(pcId)
		@cId = pcId

	def Id()
		return @cId

	def GraphType()
		return @cGraphType

	def SetGraphType(pcType)
		@cGraphType = lower(pcType)

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
	
		def IsAGraphObject()
			return 1

	#-------------------#
	#  NODE OPERATIONS  #
	#-------------------#

	def AddNode(pcNodeId)
		This.AddNodeXTT(pcNodeId, pcNodeId, [])

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

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		pcLabel = _NormalizeLabel(pcLabel)

		aNode = [
			:id = lower(pcNodeId),
			:label = pcLabel,
			:properties = iif(isList(pacProperties), pacProperties, [])
		]
		@aNodes + aNode

	def Node(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			if aNode["id"] = lower(pcNodeId)
				return aNode
			ok
		end
		stzraise("Node '" + pcNodeId + "' does not exist!")

		def NodeById(pcNodeId)
			return This.Node(pcNodeId)

	def NodeXT(pcNodeId)
		aNode = This.Node(pcNodeId)
		if HasKey(aNode, "properties")
			return aNode["properties"]
		ok
		return []

	def NodeExists(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		if ring_find(This.NodesIds(), pcNodeId) > 0
			return 1
		else
			return 0
		ok

		def HasNode(pcNodeId)
			return This.NodeExists(pcNodeId)

	def SetNodes(paNodes)
		@aNodes = paNodes
	
	def SetEdges(paEdges)
		@aEdges = paEdges

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

	#--

	def AddNodes(pacNodes)
		nLen = len(pacNodes)
		for i = 1 to nLen
			This.AddNode(pacNodes[i])
		next

	#----------------------#
	#  INSERT NODE BEFORE  #
	#----------------------#
	
	def InsertNodeBefore(pcTargetId, pcNewId)
		This.InsertNodeBeforeXTT(pcTargetId, pcNewId, pcNewId, [])

	def InsertNodeBeforeXT(pcTargetId, pcNewId, pcNewLabel)
		This.InsertNodeBeforeXTT(pcTargetId, pcNewId, pcNewLabel, [])
	
	def InsertNodeBeforeXTT(pcTargetId, pcNewId, pcNewLabel, paProps)
		aIncoming = []
		nLen = len(@aEdges)
		for i = 1 to nLen
			if @aEdges[i]["to"] = pcTargetId
				aIncoming + @aEdges[i]["from"]
			ok
		end
		
		This.AddNodeXTT(pcNewId, pcNewLabel, paProps)
		
		nLen = len(aIncoming)
		for i = 1 to nLen
			This.RemoveThisEdge(aIncoming[i], pcTargetId)
			This.Connect(aIncoming[i], pcNewId)
		end
		This.Connect(pcNewId, pcTargetId)

	#---------------------#
	#  INSERT NODE AFTER  #
	#---------------------#
	
	def InsertNodeAfter(pcTargetId, pcNewId)
		This.InsertNodeAfterXTT(pcTargetId, pcNewId, pcNewId, [])

	def InsertNodeAfterXT(pcTargetId, pcNewId, pcNewLabel)
		This.InsertNodeAfterXTT(pcTargetId, pcNewId, pcNewLabel, [])
	
	def InsertNodeAfterXTT(pcTargetId, pcNewId, pcNewLabel, paProps)
		aOutgoing = []
		nLen = len(@aEdges)
		for i = 1 to nLen
			if @aEdges[i]["from"] = pcTargetId
				aOutgoing + @aEdges[i]["to"]
			ok
		end
		
		This.AddNodeXTT(pcNewId, pcNewLabel, paProps)
		
		nLen = len(aOutgoing)
		for i = 1 to nLen
			This.RemoveThisEdge(pcTargetId, aOutgoing[i])
			This.Connect(pcNewId, aOutgoing[i])
		end
		This.Connect(pcTargetId, pcNewId)
	
	#-------------------------#
	#  INSERT MULTIPLE NODES  #
	#-------------------------#
	
	def InsertNodesBefore(pcTargetId, paNodes)
		nLen = len(paNodes)
		for i = 1 to nLen
			This.InsertNodeBefore(pcTargetId, paNodes[i][1], paNodes[i][2])
			pcTargetId = paNodes[i][1]
		end
	
	def InsertNodesAfter(pcTargetId, paNodes)
		nLen = len(paNodes)
		cLastId = pcTargetId
		for i = 1 to nLen
			This.InsertNodeAfter(cLastId, paNodes[i][1], paNodes[i][2])
			cLastId = paNodes[i][1]
		end

	#---------------#
	#  NODE REMOVAL #
	#---------------#
	
	def RemoveNodes()
		@aNodes = []
		@aEdges = []
		@aAffectedNodes = []
		@aAffectedEdges = []
	
		def RemoveAllNodes()
			This.RemoveNodes()
	
		def Clear()
			This.RemoveNodes()
	
	def RemoveTheseNodes(pacNodeIds)
		nLen = len(pacNodeIds)
		for i = 1 to nLen
			This.RemoveThisNode(pacNodeIds[i])
		end
	
	def RemoveThisNode(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		acNew = []
		nLen = len(@aNodes)
		for i = 1 to nLen
			if @aNodes[i]["id"] != pcNodeId
				acNew + @aNodes[i]
			ok
		end
		@aNodes = acNew
		
		This.RemoveEdgesConnectedTo(pcNodeId)
	
		def RemoveNode(pcNodeId)
			This.RemoveThisNode(pcNodeId)
	
	def RemoveNodeAt(pacPath)
		nLen = len(pacPath)
		if nLen = 0
			return
		ok
		
		cNodeId = pacPath[nLen]
		This.RemoveThisNode(cNodeId)
	
		def RemoveNodeAtPath(pacPath)
			This.RemoveNodeAt(pacPath)
	
	def RemoveNodesAt(paPaths)
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
	
		def RemoveNodesAtPaths(paPaths)
			This.RemoveNodesAt(paPaths)
	
	#----------------#
	#  EDGE REMOVAL  #
	#----------------#
	
	def RemoveEdges()
		@aEdges = []
		@aAffectedEdges = []
	
		def RemoveAllEdges()
			This.RemoveEdges()
	
		def ClearEdges()
			This.RemoveEdges()
	
	def RemoveThisEdge(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId)
				oList = new stzList(pcFromNodeId)
				if oList.IsFromNamedParam() or oList.IsFromNodeNamedParam()
					pcFromNodeId = pcFromNodeId[2]
				ok
			ok
			if isList(pcToNodeId)
				oList = new stzList(pcToNodeId)
				if oList.IsToNamedParam() or oList.IsToNodeNamedParam()
					pcToNodeId = pcToNodeId[2]
				ok
			ok
		ok

		acNew = []
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if NOT (aEdge["from"] = pcFromNodeId and aEdge["to"] = pcToNodeId)
				acNew + aEdge
			ok
		end
		@aEdges = acNew
	
		def RemoveEdge(pcFromNodeId, pcToNodeId)
			This.RemoveThisEdge(pcFromNodeId, pcToNodeId)

		def Disconnect(pcFromNodeId, pcToNodeId)
			This.RemoveThisEdge(pcFromNodeId, pcToNodeId)

	def RemoveEdgesConnectedTo(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		acNew = []
		nLen = len(@aEdges)
		
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if NOT (aEdge["from"] = pcNodeId or aEdge["to"] = pcNodeId)
				acNew + aEdge
			ok
		end
		
		@aEdges = acNew

	#-------------------#
	#  EDGE OPERATIONS  #
	#-------------------#

	def AddEdge(pcFromNodeId, pcToNodeId)
		This.AddEdgeXTT(pcFromNodeId, pcToNodeId, "", [])

		def Connect(pcFromNodeId, pcToNodeId)
			This.AddEdgeXTT(pcFromNodeId, pcToNodeId, "", [])

	def AddEdgeXT(pcFromNodeId, pcToNodeId, pcLabel)
		This.AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, [])

		def ConnectXT(pcFromNodeId, pcToNodeId, pcLabel)
			This.AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, [])

	def AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, pacProperties)
		if CheckParams()
			if isList(pcFromNodeId) and StzListQ(pcFromNodeId).IsNodeOrNodesOrFromOrFromNodeNamedParam()
				pcFromNodeId = pcFromNodeId[2]
			ok

			if isList(pcToNodeId) and StzListQ(pcToNodeId).IsAndOrToOrToNodeNamedParam()
				pcToNodeId = pcToNodeId[2]
			ok

			if isList(pcLabel) and StzListQ(pcLabel).IsWithOrLabelNamedParam()
				pcLabel = pcLabel[2]
			ok
		ok

		pcFromNodeId = lower(pcFromNodeId)
		pcToNodeId = lower(pcToNodeId)

		if NOT This.NodeExists(pcFromNodeId) or NOT This.NodeExists(pcToNodeId)
			stzraise("Cannot add edge: one or both nodes do not exist!")
		ok

		if This.EdgeExists(pcFromNodeId, pcToNodeId)
			stzraise("Edge already exists between '" + pcFromNodeId + "' and '" + pcToNodeId + "'!")
		ok

		pcLabel = _NormalizeLabel(pcLabel)

		aEdge = [
			:from = lower(pcFromNodeId),
			:to = lower(pcToNodeId),
			:label = pcLabel,
			:properties = iif(isList(pacProperties), pacProperties, [])
		]
		@aEdges + aEdge
		
		return 1

		def ConnectXTT(pcFromNodeId, pcToNodeId, pcLabel, pacProperties)
			This.AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, pacProperties)

	def Edge(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId)
				oList = new stzList(pcFromNodeId)
				if oList.IsFromNamedParam() or oList.IsFromNodeNamedParam()
					pcFromNodeId = pcFromNodeId[2]
				ok
			ok
			if isList(pcToNodeId)
				oList = new stzList(pcToNodeId)
				if oList.IsToNamedParam() or oList.IsToNodeNamedParam()
					pcToNodeId = pcToNodeId[2]
				ok
			ok
		ok

		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if aEdge["from"] = lower(pcFromNodeId) and aEdge["to"] = lower(pcToNodeId)
				return aEdge
			ok
		end
		stzraise("Inexistant edge!")

	def EdgeExists(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId)
				oList = new stzList(pcFromNodeId)
				if oList.IsFromNamedParam() or oList.IsFromNodeNamedParam()
					pcFromNodeId = pcFromNodeId[2]
				ok
			ok
			if isList(pcToNodeId)
				oList = new stzList(pcToNodeId)
				if oList.IsToNamedParam() or oList.IsToNodeNamedParam()
					pcToNodeId = pcToNodeId[2]
				ok
			ok
		ok

		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if aEdge["from"] = lower(pcFromNodeId) and aEdge["to"] = lower(pcToNodeId)
				return 1
			ok
		end
		return 0

		def HasEdge(pcFomId, pcToNodeId)
			return This.EdgeExists(pcFromNodeId, pcToNodeId)

	def Edges()
		return @aEdges

	def EdgeCount()
		return len(@aEdges)

	def EdgeCountBetween(pcFromNodeId, pcToNodeId)

		if CheckParams()
			if isList(pcFromNodeId) and StzListQ(pcFromNodeId).IsFromNamedParam()
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and StzListQ(pcToNodeId).IsToNamedParam()
				pcToNodeId = pcToNodeId[2]
			ok
		ok
	
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		nCount = 0
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if aEdge["from"] = lower(pcFromNodeId) and aEdge["to"] = lower(pcToNodeId)
				nCount++
			ok
		end
		return nCount
	
		def EdgesBetweenCount(pcFrom, pcTo)
			return This.EdgeCountBetween(pcFrom, pcTo)
	
	def EdgesBetween(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId) and StzListQ(pcFromNodeId).IsFromNamedParam()
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and StzListQ(pcToNodeId).IsToNamedParam()
				pcToNodeId = pcToNodeId[2]
			ok
		ok
	
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		aResult = []
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if aEdge["from"] = lower(pcFromNodeId) and aEdge["to"] = lower(pcToNodeId)
				aResult + [aEdge["from"], aEdge["label"], aEdge["to"]]
			ok
		end
		return aResult
	
		def AllEdgesBetween(pcFromNodeId, pcToNodeId)
			return This.EdgesBetween(pcFromNodeId, pcToNodeId)

	def RemoveEdgeByLabel(pcFromNodeId, pcToNodeId, pcLabel)
		if CheckParams()
			if isList(pcFromNodeId) and StzListQ(pcFromNodeId).IsFromNamedParam()
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and StzListQ(pcToNodeId).IsToNamedParam()
				pcToNodeId = pcToNodeId[2]
			ok
			if isList(pcLabel) and StzListQ(pcLabel).IsLabelNamedParam()
				pcLabel = pcLabel[2]
			ok
		ok
	
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		pcLabel = _NormalizeLabel(pcLabel)
		acNew = []
		nLen = len(@aEdges)
		bFound = FALSE
		
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if aEdge["from"] = lower(pcFromNodeId) and aEdge["to"] = lower(pcToNodeId) and lower(aEdge["label"]) = lower(pcLabel) and NOT bFound
				bFound = TRUE
				loop
			ok
			acNew + aEdge
		end
		
		@aEdges = acNew
	
		def RemoveEdgeWithLabel(pcFromNodeId, pcToNodeId, pcLabel)
			This.RemoveEdgeByLabel(pcFromNodeId, pcToNodeId, pcLabel)
	
		def DisconnectByLabel(pcFromNodeId, pcToNodeId, pcLabel)
			This.RemoveEdgeByLabel(pcFromNodeId, pcToNodeId, pcLabel)
	
	def RemoveAllEdgesBetween(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId) and StzListQ(pcFromNodeId).IsFromNamedParam()
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and StzListQ(pcToNodeId).IsToNamedParam()
				pcToNodeId = pcToNodeId[2]
			ok
		ok
	
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		acNew = []
		nLen = len(@aEdges)
		
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if NOT (aEdge["from"] = lower(pcFromNodeId) and aEdge["to"] = lower(pcToNodeId))
				acNew + aEdge
			ok
		end
		
		@aEdges = acNew
	
		def RemoveEdgesBetween(pcFromNodeId, pcToNodeId)
			This.RemoveAllEdgesBetween(pcFromNodeId, pcToNodeId)
	
		def DisconnectAll(pcFromNodeId, pcToNodeId)
			This.RemoveAllEdgesBetween(pcFromNodeId, pcToNodeId)

	#-------------------------------------------#
	#  BATCH UPDATE OPERATIONS USING FUNCTIONS  #
	#-------------------------------------------#
	
	def UpdateNodesF(pFunc)
		nLen = len(@aNodes)
		for i = 1 to nLen
			call pFunc(@aNodes[i])
		end

		def UpdateNodes(pFunc)
			This.UpdateNodesF(pFunc)
	
	def UpdateEdgesF(pFunc)
		nLen = len(@aEdges)
		for i = 1 to nLen
			call pFunc(@aEdges[i])
		end

		def UpdateEdges(pFunc)
			This.UpdateEdgesF(pFunc)

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
		
		aEdges = This.Edges()
		nLen = len(aEdges)
		for i = 1 to nLen
			if aEdges[i]["from"] = lower(pcNodeId)
				This.AddEdgeXTT(pcNewId, aEdges[i]["to"], aEdges[i]["label"], aEdges[i]["properties"])
			ok
		end

	#--------------------#
	#  MERGE OPERATIONS  #
	#--------------------#
	
	def MergeNodes(pacNodeIds, pcNewId, pcNewLabel)
		This.MergeNodesXT(pacNodeIds, pcNewId, pcNewLabel, [])
	
	def MergeNodesXT(pacNodeIds, pcNewId, pcNewLabel, paNewProps)

		if NOT _IsWellFormedId(pcNewId)
			stzraise("Incorrect Id! pcNewId must be one string without spaces.")
		ok

		pcNewLabel = _NormalizeLabel(pcNewLabel)

		if len(pacNodeIds) < 2
			return
		ok
		
		aIncoming = []
		aOutgoing = []
		
		nNodeLen = len(pacNodeIds)
		nEdgeLen = len(@aEdges)
		
		for i = 1 to nNodeLen
			cNodeId = pacNodeIds[i]
			
			for j = 1 to nEdgeLen
				aEdge = @aEdges[j]
				
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
		
		This.RemoveTheseNodes(pacNodeIds)
		This.AddNodeXTT(pcNewId, pcNewLabel, paNewProps)
		
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

	def SplitNode(pcNodeId, pcNewId1, pcNewId2)
		aNode = This.Node(pcNodeId)
		
		acIncoming = This.Incoming(pcNodeId)
		acOutgoing = This.Neighbors(pcNodeId)
		
		This.AddNodeXT(pcNewId1, aNode["label"] + " (1)")
		This.AddNodeXT(pcNewId2, aNode["label"] + " (2)")
		
		nLen = len(acIncoming)
		for i = 1 to nLen
			This.Connect(acIncoming[i], pcNewId1)
			This.Connect(acIncoming[i], pcNewId2)
		end
		
		nLen = len(acOutgoing)
		for i = 1 to nLen
			This.Connect(pcNewId1, acOutgoing[i])
			This.Connect(pcNewId2, acOutgoing[i])
		end
		
		This.RemoveThisNode(pcNodeId)

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

	def SetNodeProperty(pNodeId, cProperty, pValue)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok
		
		nLen = len(@aNodes)
		for i = 1 to nLen
			if @aNodes[i]["id"] = pNodeId
				if NOT HasKey(@aNodes[i], "properties")
					@aNodes[i]["properties"] = []
				ok
				@aNodes[i]["properties"][cProperty] = pValue
				aTemp = @aNodes[i]
				@aNodes[i] = aTemp
				return
			ok
		end
	
		def SetNodeProp(pNodeId, cProperty, pValue)
			This.SetNodeProperty(pNodeId, cProperty, pValue)

		def UpdateNodeProperty(pcNodeId, pcKey, pValue)
			This.SetNodeProperty(pcNodeId, pcKey, pValue)
		
		def UpdateNodeProp(pcNodeId, pcKey, pValue)
			This.SetNodeProperty(pcNodeId, pcKey, pValue)

	def SetNodeProperties(pcNodeId, aProperties)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		if NOT IsHashList(aProperties)
			StzRaise("aProperties must be a hashlist")
		ok
		
		nLen = len(aProperties)
		for i = 1 to nLen
			This.SetNodeProperty(pcNodeId, aProperties[i][1], aProperties[cKey])
		end
	
		def SetNodeProps(pNodeId, aProperties)
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
			return This.NodePropertiesXT(pcNodeId)

		def NodePropsXT(pcNodeId)
			return This.NodePropertiesXT(pcNodeId)

		def NodePropsAndTheirValues(pcNodeId)
			return This.NodePropertiesXT(pcNodeId)

	def NodeProperty(pNodeId, cProperty)
		aNode = This.Node(pNodeId)
		
		if HasKey(aNode, "properties") and HasKey(aNode["properties"], cProperty)
			return aNode["properties"][cProperty]
		else
			return NULL
		ok
	
		def NodeProp(pNodeId, cProperty)
			return This.NodeProperty(pNodeId, cProperty)

	def RemoveNodeProperties(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

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
		nLen = len(@aNodes)
		for i = 1 to nLen
			@aNodes[i]["properties"] = []
		end
		
		nLen = len(@aEdges)
		for i = 1 to nLen
			@aEdges[i]["properties"] = []
		end
	
		def ClearAllProperties()
			This.RemoveAllProperties()

	def SetEdgeProperty(pFromNodeId, pToNodeId, cProperty, pValue)
		if CheckParams()
			if isList(pFromNodeId)
				oList = new stzList(pFromNodeId)
				if oList.IsFromNamedParam() or oList.IsFromNodeNamedParam()
					pFromNodeId = pFromNodeId[2]
				ok
			ok
			if isList(pToNodeId)
				oList = new stzList(pToNodeId)
				if oList.IsToNamedParam() or oList.IsToNodeNamedParam()
					pToNodeId = pToNodeId[2]
				ok
			ok
		ok

		if NOT _IsWellFormedId(pFromNodeId)
			stzraise("Incorrect Id! pFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pToNodeId)
			stzraise("Incorrect Id! pToNodeId must be one string without spaces.")
		ok

		nLen = len(@aEdges)
		for i = 1 to nLen
			if @aEdges[i]["from"] = pFromNodeId and @aEdges[i]["to"] = pToNodeId
				if NOT HasKey(@aEdges[i], "properties")
					@aEdges[i] + ["properties", []]
				ok
				@aEdges[i]["properties"][cProperty] = pValue
				return
			ok
		end
	
		def SetEdgeProp(pFromNodeId, pToNodeId, cProperty, pValue)
			return This.SetEdgeProperty(pFromNodeId, pToNodeId, cProperty, pValue)

		def UpdateEdgeProperty(pcFrom, pcTo, pcKey, pValue)
			This.SetEdgeProperty(pcFrom, pcTo, pcKey, pValue)
		
		def UpdateEdgeProp(pcFrom, pcTo, pcKey, pValue)
			This.SetEdgeProperty(pcFrom, pcTo, pcKey, pValue)

	def EdgeProperty(pFromNodeId, pToNodeId, cProperty)
		aEdge = This.Edge(pFromNodeId, pToNodeId)
		
		if HasKey(aEdge, "properties") and HasKey(aEdge["properties"], cProperty)
			return aEdge["properties"][cProperty]
		else
			return NULL
		ok

		def EdgeProp(pFromNodeId, pToNodeId, cProperty)
			return This.EdgeProperty(pFromNodeId, pToNodeId, cProperty)

	def SetEdgeProperties(pcFromNodeId, pcToNodeId, aProperties)
		if CheckParams()
			if isList(pcFromNodeId)
				oList = new stzList(pcFromNodeId)
				if oList.IsFromNamedParam() or oList.IsFromNodeNamedParam()
					pcFromNodeId = pcFromNodeId[2]
				ok
			ok
			if isList(pcToNodeId)
				oList = new stzList(pcToNodeId)
				if oList.IsToNamedParam() or oList.IsToNodeNamedParam()
					pcToNodeId = pcToNodeId[2]
				ok
			ok
		ok

		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		if NOT IsHashList(aProperties)
			StzRaise("aProperties must be a hashlist")
		ok
		
		nLen = len(@aEdges)
		for i = 1 to nLen
			if @aEdges[i]["from"] = pcFromNodeId and @aEdges[i]["to"] = pcToNodeId
				if NOT HasKey(@aEdges[i], "properties")
					@aEdges[i] + ["properties", []]
				ok
				
				acKeys = keys(aProperties)
				nKeyLen = len(acKeys)
				for j = 1 to nKeyLen
					@aEdges[i]["properties"][acKeys[j]] = aProperties[acKeys[j]]
				end
				return
			ok
		end
	
		def SetEdgeProps(pcFromNodeId, pcToNodeId, aProperties)
			This.SetEdgeProperties(pcFromNodeId, pcToNodeId, aProperties)

	def EdgeProperties(pcFromNodeId, pcToNodeId)
		aEdge = This.Edge(pcFromNodeId, pcToNodeId)
		if HasKey(aEdge, "properties")
			return keys(aEdge["properties"])
		ok
		return []
	
		def EdgeProps(pcFromNodeId, pcToNodeId)
			return This.EdgeProperties(pcFromNodeId, pcToNodeId)

	def EdgePropertiesXT(pcFromNodeId, pcToNodeId)
		aEdge = This.Edge(pcFromNodeId, pcToNodeId)
		if HasKey(aEdge, "properties")
			return aEdge["properties"]
		ok
		return []
	
		def EdgePropsXT(pcFromNodeId, pcToNodeId)
			return This.EdgePropertiesXT(pcFromNodeId, pcToNodeId)

	#---------------------------#
	#  TRAVERSAL & PATHFINDING  #
	#---------------------------#

	def PathExists(pcFromNodeId, pcToNodeId)

		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		if pcFromNodeId = pcToNodeId
			return 1
		ok
		acVisited = []
		return This._PathExistsDFS(pcFromNodeId, pcToNodeId, acVisited)

	def _PathExistsDFS(pcCurrent, pcTarget, pacVisited)
		if pcCurrent = pcTarget
			return 1
		ok

		if ring_find(pacVisited, pcCurrent) > 0
			return 0
		ok

		pacVisited + pcCurrent

		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if aEdge["from"] = pcCurrent
				if This._PathExistsDFS(aEdge["to"], pcTarget, pacVisited)
					return 1
				ok
			ok
		end

		return 0

	#---

	def FirstNode()
		if len(@aNodes) = 0
			stzraise("Can't obtain a first node. The graphs contains no nodes at all!")
		ok
		return @aNodes[1]

	def FirstNodeId()
		return This.FirstNode()[:id]

	def LastNode()
		nLen = len(@aNodes)
		if nLen = 0
			stzraise("Can't obtain a first node. The graphs contains no nodes at all!")
		ok
		return @aNodes[nLen]

	def LastNodeId()
		return This.LastNode()[:id]

	#--

	def FindNode(pcNodeId)
		return This.PathsXT(This.FirstNodeId(), pcNodeId)

		def PathsTo(pcNodeId)
			if CheCkParams()
				if isList(pcNodeId) and StzListQ(pcNodeId).IsNodeNamedParam()
					pcNodeId = pcNodeId[2]
				ok
			ok

			return This.FindNode(pcNodeId)

		def PathsToNode(pcNodeId)
			return This.FindNode(pcNodeId)

	#--

	def Paths() #TODO// Returns all the possible paths in the graph
		stzraise("Not yet implemented!")

	def PathsXT(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId) and StzListQ(pcFromNodeId).IsFromOrFromNodeNamedParam()
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and StzListQ(pcToNodeId).IsToOrToNodeOrAndNamedParam()
				pcToNodeId = pcToNodeId[2]
			ok
		ok
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		acAllPaths = []
		acCurrentPath = [pcFromNodeId]
		This._FindAllPathsDFS(pcFromNodeId, pcToNodeId, acCurrentPath, acAllPaths, 0)
		return acAllPaths

		def PathsBetweenXT(pcFromNodeId, pcToNodeId)
			return This.PathsXT(pcFromNodeId, pcToNodeId)

	def Path(pcFromNodeId, pcToNodeId)
		acPaths = This.PathsXT(pcFromNodeId, pcToNodeId)
		if len(acPaths) > 0
			return acPaths[1]
		else
			return []
		ok

		def FirstPath(pcFromNodeId, pcToNodeId)
			return This.Path(pcFromNodeId, pcToNodeId)

		def FirstPathBetween(pcFromNodeId, pcToNodeId)
			return This.Path(pcFromNodeId, pcToNodeId)

		def PathBetween(pcFromNodeId, pcToNodeId)
			return This.Path(pcFromNodeId, pcToNodeId)

		def PathXT(pcFromNodeId, pcToNodeId)
			return This.Path(pcFromNodeId, pcToNodeId)

	def _FindAllPathsDFS(pcCurrent, pcTarget, pacCurrentPath, pacAllPaths, pnDepth)
		if pnDepth > 10
			return
		ok
	
		if pcCurrent = pcTarget
			pacAllPaths + pacCurrentPath
			return
		ok
	
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if aEdge["from"] = pcCurrent
				cNext = aEdge["to"]
				
				if ring_find(pacCurrentPath, cNext) = 0
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

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		acNeighbors = []
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
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

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		acIncoming = []
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
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

	def HasCyclicDependencies()
		acVisited = []
		acRecStack = []

		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			if ring_find(acVisited, aNode["id"]) = 0
				if This._HasCycleDFS(aNode["id"], acVisited, acRecStack)
					return 1
				ok
			ok
		end

		return 0

	def _HasCycleDFS(pcNode, pacVisited, pacRecStack)
		pacVisited + pcNode
		pacRecStack + pcNode

		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			if aEdge["from"] = pcNode

				if ring_find(pacVisited, aEdge["to"]) = 0
					if This._HasCycleDFS(aEdge["to"], pacVisited, pacRecStack)
						return 1
					ok

				but ring_find(pacRecStack, aEdge["to"]) > 0
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

				if ring_find(acVisited, cNeighbor) = 0
					acVisited + cNeighbor
					acQueue + cNeighbor
				ok
			end
			
			nQueueIdx += 1
		end
		
		return acReachable

		def ReachableFromNode(pcNodeId)
			return This.ReachableFrom(pcNodeId)

	#--------------------#
	#  ANALYSIS METRICS  #
	#--------------------#

	def BottleneckNodes()
		acBottlenecks = []
		nTotalDegree = 0
		
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			nIncoming = len(This.Incoming(aNode["id"]))
			nOutgoing = len(This.Neighbors(aNode["id"]))
			nTotalDegree += nIncoming + nOutgoing
		end
		
		nAvgDegree = nTotalDegree / len(@aNodes)
		
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
		nEdges = len(@aEdges)

		if nNodes <= 1
			return 0
		ok

		nMaxEdges = nNodes * (nNodes - 1)
		return nEdges / nMaxEdges

		def NodeDensity01()
			return This.NodeDensity()

		def Density()
			return This.NodeDensity()

		def Density01()
			return This.NodeDensity()

	def NodeDensity100()
		return This.NodeDensity() * 100

		def NodeDensityPercent()
			return This.NodeDensity100()

		def NodeDensityInPercentage()
			return This.NodeDensity100()

		def NodeDensityInPercent()
			return This.NodeDensity100()

		def Density100()
			return This.NodeDensity100()

	def IsSparse()
		return This.Density() < 0.5
	
	def IsDense()
		return This.Density() >= 0.5
	
	def DensityCategory()
		nDensity = This.Density()
		
		if nDensity = 0
			return "empty"
		but nDensity < 0.25
			return "very sparse"
		but nDensity < 0.5
			return "sparse"
		but nDensity < 0.75
			return "dense"
		else
			return "very dense"
		ok
	
		def DensityLevel()
			return This.DensityCategory()

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

	def CyclicNodes()
		acCyclicNodes = []
		
		acNodes = This.Nodes()
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
			next
			
			# If the node can reach itself through other nodes, it's in a cycle
			if ring_find(acReachableWithoutStart, cNodeId) > 0
				if ring_find(acCyclicNodes, cNodeId) = 0
					acCyclicNodes + cNodeId
				ok
			ok
		next

		return acCyclicNodes


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
				nNeighborLen = len(acNeighbors)
				for j = 1 to nNeighborLen
					cNeighbor1 = acNeighbors[j]
					acReachable1 = This.ReachableFrom(cNeighbor1)
					
					for k = j + 1 to nNeighborLen
						cNeighbor2 = acNeighbors[k]
						acReachable2 = This.ReachableFrom(cNeighbor2)
						
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
						
						bDisjoint = 1
						nCheck = len(acReachable1Clean)
						for m = 1 to nCheck
							if ring_find(acReachable2Clean, acReachable1Clean[m]) > 0
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

		def ParaBranches()
			return This.ParallelizableBranches()

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

	#------------------------------------------------#
	#  RICH QUERYING - BASED ON stzGraphQuery CLASS  #
	#------------------------------------------------#

	def Find(pcWhat)
		return new stzGraphQuery(This, pcWhat)

		def FindQ(pcWhat)
			return new stzGraphQuery(This, pcWhat)

	def NodesByType(pcType)
		return Find("nodes").Where("type", "=", pcType).Run()

	#--

	def NodesWhere(pcProp, pcOp, pVal)
		return This.Find("nodes").Where(pcProp, pcOp, pVal).Run()

		def NodesW(pcProp, pcOp, pVal)
			return This.NodesWhere(pcProp, pcOp, pVal)

	def EdgesWhere(pcProp, pcOp, pVal)
		return This.Find("edges").Where(pcProp, pcOp, pVal).Run()

		def EdgesW(pcProp, pcOp, pVal)
			return This.EdgesWhere(pcProp, pcOp, pVal)

	#--

	def NodesWhereF(pFunc)

		if NOT isFunction(pFunc)
			stzraise("Can't proceed! pFunc must be a valid function.")
		ok

		acResult = []
		nLen = len(@aNodes)

		for i = 1 to nLen
			bMatched = call pFunc(@aNodes[i])
			if bMatched
				acResult + @aNodes[i][:id]
			ok
		next

		return acResult

		def NodesWF(pFunc)
			return This.NodesWhereF(pFunc)

	def EdgesWhereF(pFunc)

		if NOT isFunction(pFunc)
			stzraise("Can't proceed! pFunc must be a valid function.")
		ok

		acResult = []
		nLen = len(@aEdges)

		for i = 1 to nLen
			bMatched = call pFunc(@aEdges[i])
			if bMatched
				acResult + [ @aEdges[i][:from], @aEdges[i][:to] ]
			ok
		next

		return acResult

		def EdgesWF(pFunc)
			return This.EdgesWhereF(pFunc)


	def PathsWhereF(pFunc)

		if NOT isFunction(pFunc)
			stzraise("Can't proceed! pFunc must be a valid function.")
		ok

		acResult = []
		acPaths = This.Paths() #TODO
		nLen = len(acPaths)

		for i = 1 to nLen
			bMatched = call pFunc(acPaths[i])
			if bMatched
				acResult + acPaths[i]
			ok
		next

		return acResult

		def PathsWF(pFunc)
			return This.PathsWhereF(pFunc)

	#--------------------#
	#  GRAPH ALGORITHMS  #
	#--------------------#

	def ShortestPath(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId) and StzListQ(pcFromNodeId).IsFromNamedParam()
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and StzListQ(pcToNodeId).IsToNamedParam()
				pcToNodeId = pcToNodeId[2]
			ok
		ok
	
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		if NOT This.NodeExists(pcFromNodeId) or NOT This.NodeExists(pcTo)
			return []
		ok
	
		if pcFromNodeId = pcToNodeId
			return [ pcFromNodeId ]
		ok
	
		_acQueue_ = [ pcFromNodeId ]
		_acVisited_ = [ pcFromNodeId ]
		_aParentMap_ = [ [ pcFromNodeId, "" ] ]
	
		while len(_acQueue_) > 0
			_cCurrent_ = _acQueue_[1]
			del(_acQueue_, 1)
			
			if _cCurrent_ = pcToNodeId
				_acPath_ = []
				_cNode_ = pcToNodeId
				
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

	def ShortestPathLength(pcFromNodeId, pcToNodeId)

		if CheckParams()
			if isList(pcFromNodeId) and StzListQ(pcFromNodeId).IsFromNamedParam()
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and StzListQ(pcToNodeId).IsToNamedParam()
				pcToNodeId = pcToNodeId[2]
			ok
		ok

		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		_acPath_ = This.ShortestPath(pcFromNodeId, pcTo)
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
		if len(@aNodes) <= 1
			return 1
		ok
		
		acVisited = []
		acQueue = [@aNodes[1][:id]]
		acVisited + @aNodes[1][:id]
		nIdx = 1
		
		while nIdx <= len(acQueue)
			cCurrent = acQueue[nIdx]
			
			acNeighbors = This.Neighbors(cCurrent)
			acIncoming = This.Incoming(cCurrent)
			
			for i = 1 to len(acNeighbors)
				cNext = acNeighbors[i]
				if ring_find(acVisited, cNext) = 0
					acVisited + cNext
					acQueue + cNext
				ok
			end
			
			for i = 1 to len(acIncoming)
				cNext = acIncoming[i]
				if ring_find(acVisited, cNext) = 0
					acVisited + cNext
					acQueue + cNext
				ok
			end
			
			nIdx += 1
		end
		
		return len(acVisited) = len(@aNodes)

	def ArticulationPoints()
		_acArticulation_ = []
		_aNodes_ = This.Nodes()
		
		_nOriginalComponents_ = len(This.ConnectedComponents())
		
		_nNodeLen_ = len(_aNodes_)
		for _i_ = 1 to _nNodeLen_
			_cNodeId_ = _aNodes_[_i_][:id]
			
			_aIncoming_ = This.Incoming(_cNodeId_)
			_aOutgoing_ = This.Neighbors(_cNodeId_)
			_aSavedEdges_ = []
			
			_aEdges_ = This.Edges()
			_nEdgeLen_ = len(_aEdges_)
			for _j_ = 1 to _nEdgeLen_
				_aEdge_ = _aEdges_[_j_]
				if _aEdge_[:from] = _cNodeId_ or _aEdge_[:to] = _cNodeId_
					_aSavedEdges_ + _aEdge_
				ok
			end
			
			_aNode_ = This.Node(_cNodeId_)
			This.RemoveThisNode(_cNodeId_)
			
			_nNewComponents_ = len(This.ConnectedComponents())
			
			This.AddNodeXTT(_cNodeId_, _aNode_[:label], _aNode_[:properties])
			_nSavedLen_ = len(_aSavedEdges_)
			for _j_ = 1 to _nSavedLen_
				_aEdge_ = _aSavedEdges_[_j_]
				This.AddEdgeXTT(_aEdge_[:from], _aEdge_[:to], _aEdge_[:label], _aEdge_[:properties])
			end
			
			if _nNewComponents_ > _nOriginalComponents_
				_acArticulation_ + _cNodeId_
			ok
		end
		
		return _acArticulation_

	def BetweennessCentrality(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
	
		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
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

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
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

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		_acOutgoing_ = This.Neighbors(pcNodeId)
		_acIncoming_ = This.Incoming(pcNodeId)
		_acAllNeighbors_ = []
		
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

		def ClusteringCoeff(pcNodeId)
			return This.ClusteringCoefficient(pcNodeId)

	def PathWeight(pacPath)
		nTotal = 0
		nLen = len(pacPath)
		
		for i = 1 to nLen - 1
			cFrom = pacPath[i]
			cTo = pacPath[i + 1]
			
			if This.EdgeExists(cFrom, cTo)
				pWeight = This.EdgeProperty(cFrom, cTo, "weight")
				if isNumber(pWeight)
					nTotal += pWeight
				ok
			ok
		end
		
		return nTotal

	#-------------------------------#
	#  EXPORT AND INTEROPERABILITY  #
	#-------------------------------#

	def ToHashlist()
		return [
			:id = @cId,
			:nodes = @aNodes,
			:edges = @aEdges,
			:properties = This.Properties()
		]

	def ExportToDOT()
		cDOT = "digraph " + This.Id() + " {" + nl
		cDOT += "  rankdir=TD;" + nl
		cDOT += "  node [shape=box];" + nl + nl
		
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			cId = aNode["id"]
			cLabel = aNode["label"]
			
			if left(cId, 1) = "@"
				cId = @substr(cId, 2, len(cId))
			ok
			
			cDOT += "  " + cId + " [label=" + '"' + cLabel + '"' + "];" + nl
		end
		
		cDOT += nl
		
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			cLabel = aEdge["label"]
			
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
		
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
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
			:edgeCount = len(@aEdges),
			:density = This.NodeDensity(),
			:longestPath = This.LongestPath(),
			:hasCycles = This.HasCyclicDependencies()
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
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			
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

		def Shwo()
			This.Show()

	def View()
		_oDot_ = new stzDotCode()
		_oDot_.SetCode(This.Dot())
		_oDot_.RunAndView()

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

	#------------------------#
	#  EXPLAINING THE GRAPH  #
	#------------------------#

	# Telling the story of the graph

	def Explain()
		aExplanation = [
			:general = [],
			:bottlenecks = [],
			:cycles = [],
			:metrics = [],
			:rules = []
		]
		
		acBottlenecks = This.BottleneckNodes()
		acCyclic = This.CyclicNodes()
		
		acNodes = This.Nodes()
		acEdges = This.Edges()
		
		# General section
		aExplanation[:general] + ("Graph: " + This.Id())
		aExplanation[:general] + ("Nodes: " + len(acNodes) + " | Edges: " + len(acEdges))
		
		# Bottlenecks section
		if len(acBottlenecks) > 0
			nTotalDegree = 0
			nLen = len(acNodes)
			for i = 1 to nLen
				aNode = acNodes[i]
				nIncoming = len(This.Incoming(aNode["id"]))
				nOutgoing = len(This.Neighbors(aNode["id"]))
				nTotalDegree += nIncoming + nOutgoing
			end
			nAvgDegree = nTotalDegree / len(acNodes)
			
			aExplanation[:bottlenecks] + ("Bottleneck nodes: " + joinXT(acBottlenecks, ", "))
			aExplanation[:bottlenecks] + ("Average degree: " + nAvgDegree)
			
			nLen = len(acBottlenecks)
			for i = 1 to nLen
				cNode = acBottlenecks[i]
				nIncoming = len(This.Incoming(cNode))
				nOutgoing = len(This.Neighbors(cNode))
				nDegree = nIncoming + nOutgoing
				aExplanation[:bottlenecks] + ("  " + cNode + ": degree " + nDegree + " (above average)")
			end
		else
			nTotalDegree = 0
			nLen = len(acNodes)
			for i = 1 to nLen
				aNode = acNodes[i]
				nIncoming = len(This.Incoming(aNode["id"]))
				nOutgoing = len(This.Neighbors(aNode["id"]))
				nTotalDegree += nIncoming + nOutgoing
			end
			nAvgDegree = nTotalDegree / len(acNodes)
			aExplanation[:bottlenecks] + ("No bottlenecks (average degree = " + nAvgDegree + ")")
		ok
		
		# Cycles section
		if len(acCyclic) > 0
			aExplanation[:cycles] + ("Cyclic nodes: " + join(acCyclic, ", "))
			nLen = len(acCyclic)
			for i = 1 to nLen
				cNode = acCyclic[i]
				aExplanation[:cycles] + ("  " + cNode + " can reach itself")
			end
		ok
		
		if This.HasCyclicDependencies()
			aExplanation[:cycles] + "WARNING: Circular dependencies detected"
		else
			if len(acCyclic) = 0
				aExplanation[:cycles] + "No cycles - acyclic graph (DAG)"
			ok
		ok
		
		# Metrics section
		nDensity = This.NodeDensity()
		if nDensity = 0
			aoExplanation[:metrics] + "Density: 0% (no connections)"
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
		
		# Rules section
		acRulesApplied = This.RulesApplied()
		if len(acRulesApplied) > 0
			aExplanation[:rules] + ("Rules applied: " + len(acRulesApplied))
			nLen = len(acRulesApplied)
			for i = 1 to nLen
				aExplanation[:rules] + ("  - " + acRulesApplied[i])
			end
		else
			aExplanation[:rules] + "No rules applied"
		ok
		
		return aExplanation

	# Telling the story of a particular path

	def ExplainPath(pcFrom, pcTo)
	    acPath = This.Path(pcFrom, pcTo)
	    aStory = []
	    nLen = len(acPath) - 1

	    for i = 1 to nLen
	        aEdge = This.Edge(acPath[i], acPath[i+1])
	        aStory + (acPath[i] + " → " + acPath[i+1])
		if aEdge[:label] != ""
			aStory[len(aStory)] +=  (" : because @" + acPath[i] + " " + substr(aEdge[:label], "_", " ") + " @" + acPath[i+1] )
		ok
	    next
	    
	    return aStory

	#-------------------#
	#  RULE MANAGEMENT  #
	#-------------------#
	
	def AddDerivationRule(pcName, pFunc, paParams, pcMessage, pcSeverity)
		@aRules + [
			:name = pcName,
			:type = :derivation,
			:function = pFunc,
			:params = paParams,
			:message = pcMessage,
			:severity = pcSeverity
		]
	
	def AddConstraintRule(pcName, pFunc, paParams, pcMessage, pcSeverity)
		@aRules + [
			:name = pcName,
			:type = :constraint,
			:function = pFunc,
			:params = paParams,
			:message = pcMessage,
			:severity = pcSeverity
		]
	
	def AddValidationRule(pcName, pFunc, paParams, pcMessage, pcSeverity)
		@aRules + [
			:name = pcName,
			:type = :validation,
			:function = pFunc,
			:params = paParams,
			:message = pcMessage,
			:severity = pcSeverity
		]
	
	def UseRules(paRules)
		nLen = len(paRules)
		for i = 1 to nLen
			aRule = paRules[i]
			cType = aRule[:type]
			
			if cType = :derivation
				This.AddDerivationRule(aRule[:name], aRule[:function], aRule[:params], aRule[:message], aRule[:severity])
			but cType = :constraint
				This.AddConstraintRule(aRule[:name], aRule[:function], aRule[:params], aRule[:message], aRule[:severity])
			but cType = :validation
				This.AddValidationRule(aRule[:name], aRule[:function], aRule[:params], aRule[:message], aRule[:severity])
			ok
		next
	
	def UseRulesFrom(pcTheme)
		if HasKey($GraphRules, pcTheme)
			This.UseRules($GraphRules[pcTheme])
		ok

	def ApplyDerivations()
		nAdded = 0
		nLen = len(@aRules)
		
		for i = 1 to nLen
			aRule = @aRules[i]
			if aRule[:type] != :derivation
				loop
			ok
			
			# Call derivation function with params
			pFunc = aRule[:function]
			paParams = aRule[:params]
			aNewEdges = call pFunc(This, paParams)
			
			# Add derived edges
			nEdgesLen = len(aNewEdges)
			for j = 1 to nEdgesLen
				aEdge = aNewEdges[j]
				cFrom = aEdge[1]
				cTo = aEdge[2]
				cLabel = aEdge[3]
				aProps = aEdge[4]
				
				if NOT This.EdgeExists(cFrom, cTo)
					This.AddEdgeXTT(cFrom, cTo, cLabel, aProps)
					nAdded++
					This._TrackRuleApplication(aRule[:name], :edge, cFrom + "->" + cTo)
				ok
			next
		next
		
		return nAdded
	
	def CheckConstraints(paOperationParams)
		aViolations = []
		nLen = len(@aRules)
		
		for i = 1 to nLen
			aRule = @aRules[i]
			if aRule[:type] != :constraint
				loop
			ok
			
			# Call constraint function with both params
			pFunc = aRule[:function]
			paRuleParams = aRule[:params]
			aResult = call pFunc(This, paRuleParams, paOperationParams)
			
			bBlocked = aResult[1]
			cMessage = aResult[2]
			
			if bBlocked
				aViolations + [
					:rule = aRule[:name],
					:message = iif(cMessage = "", aRule[:message], cMessage),
					:severity = aRule[:severity],
					:params = paOperationParams
				]
			ok
		next
		
		bSuccess = (len(aViolations) = 0)
		return [bSuccess, aViolations]
	
	def ValidateGraph()
		aViolations = []
		nLen = len(@aRules)
		
		for i = 1 to nLen
			aRule = @aRules[i]
			if aRule[:type] != :validation
				loop
			ok
			
			# Call validation function with params
			pFunc = aRule[:function]
			paParams = aRule[:params]
			aResult = call pFunc(This, paParams)
			
			bValid = aResult[1]
			cMessage = aResult[2]
			
			if NOT bValid
				aViolations + [
					:rule = aRule[:name],
					:message = iif(cMessage = "", aRule[:message], cMessage),
					:severity = aRule[:severity]
				]
			ok
		next
		
		bValid = (len(aViolations) = 0)
		return [bValid, aViolations]
	
	def RulesApplied()
		acRuleIds = []
		nLen = len(@aAffectedNodes)
		
		for i = 1 to nLen
			aEntry = @aAffectedNodes[i]
			nRulesLen = len(aEntry[2])
			for j = 1 to nRulesLen
				cRule = aEntry[2][j]
				if ring_find(acRuleIds, cRule) = 0
					acRuleIds + cRule
				ok
			next
		next
		
		nLen = len(@aAffectedEdges)
		for i = 1 to nLen
			aEntry = @aAffectedEdges[i]
			nRulesLen = len(aEntry[2])
			for j = 1 to nRulesLen
				cRule = aEntry[2][j]
				if ring_find(acRuleIds, cRule) = 0
					acRuleIds + cRule
				ok
			next
		next
		
		return acRuleIds
	
	def EnforceConstraints()
		@bEnforceConstraints = TRUE
	
	def DisableConstraints()
		@bEnforceConstraints = FALSE
	
	def RulesSummary()
		aSummary = [
			:derivations = [],
			:constraints = [],
			:validations = [],
			:applied = [],
			:violations = []
		]
		
		nLen = len(@aRules)
		for i = 1 to nLen
			aRule = @aRules[i]
			cType = aRule[:type]
			
			if cType = :derivation
				aSummary[:derivations] + aRule[:name]
			but cType = :constraint
				aSummary[:constraints] + aRule[:name]
			but cType = :validation
				aSummary[:validations] + aRule[:name]
			ok
		next
		
		aSummary[:applied] = This.RulesApplied()
		
		return aSummary
	
	def _TrackRuleApplication(pcRuleName, pcTargetType, pcTargetId)
		if pcTargetType = :node
			nPos = 0
			nLen = len(@aAffectedNodes)
			for i = 1 to nLen
				if @aAffectedNodes[i][1] = pcTargetId
					nPos = i
					exit
				ok
			next
			
			if nPos = 0
				@aAffectedNodes + [pcTargetId, [pcRuleName]]
			else
				if ring_find(@aAffectedNodes[nPos][2], pcRuleName) = 0
					@aAffectedNodes[nPos][2] + pcRuleName
				ok
			ok
			
		but pcTargetType = :edge
			nPos = 0
			nLen = len(@aAffectedEdges)
			for i = 1 to nLen
				if @aAffectedEdges[i][1] = pcTargetId
					nPos = i
					exit
				ok
			next
			
			if nPos = 0
				@aAffectedEdges + [pcTargetId, [pcRuleName]]
			else
				if ring_find(@aAffectedEdges[nPos][2], pcRuleName) = 0
					@aAffectedEdges[nPos][2] + pcRuleName
				ok
			ok
		ok

	#---------#
	#  MISC.  #
	#---------#

	#NOTE// I added those methods after including the GraphType attribute
	# So we can use it in a practical way to enforce the beahvir
	# of some features depending on the graph type (see examples at
	# the end of stzGraphTest.ring file)

	def CyclesAllowed()
	    return @cGraphType = "flow" or @cGraphType = "semantic"
	
	def ShouldAutoDerive()
	    return @cGraphType = "semantic"
	
	def ValidateByType()
	    if @cGraphType = "structural" and This.HasCyclicDependencies()
	        return [FALSE, "Cycles not allowed in structural graphs"]
	    ok
	    return [TRUE, ""]

	def UseDefaultDerivations()
	    # Register transitivity rule for semantic graphs
	    RegisterRule("semantic", "auto_transitivity", [
	        :type = :derivation,
	        :function = DerivationFunc_Transitivity(),
	        :params = [],
	        :message = "Transitive closure for semantic relations",
	        :severity = "info"
	    ])
	    This.UseRulesFrom("semantic")

	#--

	def _NormalizeLabel(pcLabel)
		pcLabel = substr(pcLabel, " ", "_")
		pcLabel = substr(pcLabel, NL, "_")

		def  _NormaliseLabel(pcLabel)
			return substr(pcLabel, " ", "_")

	def _IsWellFormedId(pcId)
		if NOT isString(pcId)
			return 0
		ok

		if substr(pcId, " ") > 0
			return 0
		ok

		if substr(pcId, NL) > 0
			return 0
		ok

		return 1

#========================================#
# stzGraphQuery - Keep Separate (Works)  #
#========================================#

class stzGraphQuery
	@oGraph
	@cTarget
	@aFilters = []
	
	def init(oGraph, cTarget)
		@oGraph = oGraph
		@cTarget = lower(cTarget)
		@aFilters = []
	
	def Where(pcKey, pCondition, pValue)
		@aFilters + [:where, pcKey, pCondition, pValue]
		return This
	
		def WhereQ(pcKey, pCondition, pValue)
			return This.Where(pcKey, pCondition, pValue)

	def Having(pcKey, pValue)
		@aFilters + [:where, pcKey, :equals, pValue]
		return This
	
		def HavingQ(pcKey, pValue)
			return This.Having(pcKey, pValue)

	def WithProperty(pcKey)
		@aFilters + [:hasprop, pcKey]
		return This

		def WithPropertyQ(pcKey)
			return This.WithProperty(pcKey)

	def WithTag(pcTag)
		@aFilters + [:tag, pcTag]
		return This
	
		def WithTagQ(pcTag)
			return This.WithTag(pcTag)

	def Run()
		if @cTarget = "nodes"
			return This._QueryNodes()
		but @cTarget = "edges"
			return This._QueryEdges()
		ok
		return []
	
		def Execute()
			return This.Run()
	
	def _QueryNodes()
		acResult = []
		aNodes = @oGraph.Nodes()
		
		for aNode in aNodes
			if This._NodeMatches(aNode)
				acResult + aNode[:id]
			ok
		end
		
		return acResult
	
	def _QueryEdges()
		acResult = []
		aEdges = @oGraph.Edges()
		
		for aEdge in aEdges
			if This._EdgeMatches(aEdge)
				acResult + [ aEdge[:from], aEdge[:to] ]
			ok
		end
		return acResult
	
	def _NodeMatches(aNode)
		for aFilter in @aFilters
			cType = aFilter[1]
			
			if cType = :where
				pcKey = aFilter[2]
				pCondition = aFilter[3]
				pValue = aFilter[4]
				
				pActual = This._GetNestedValue(aNode, pcKey)
				if pActual = NULL
					return FALSE
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return FALSE
				ok
				
			but cType = :hasprop
				pcKey = aFilter[2]
				if This._GetNestedValue(aNode, pcKey) = NULL
					return FALSE
				ok
				
			but cType = :tag
				pcTag = aFilter[2]
				if NOT HasKey(aNode, "properties") or 
				   NOT HasKey(aNode["properties"], "tags") or
				   ring_find(aNode["properties"]["tags"], pcTag) = 0
					return FALSE
				ok
			ok
		end
		return TRUE
	
	def _EdgeMatches(aEdge)
		for aFilter in @aFilters
			cType = aFilter[1]
			
			if cType = :where
				pcKey = aFilter[2]
				pCondition = aFilter[3]
				pValue = aFilter[4]
				
				pActual = This._GetNestedValue(aEdge, pcKey)
				if pActual = NULL
					return FALSE
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return FALSE
				ok
				
			but cType = :hasprop
				pcKey = aFilter[2]
				if This._GetNestedValue(aEdge, pcKey) = NULL
					return FALSE
				ok
				
			but cType = :tag
				pcTag = aFilter[2]
				if NOT HasKey(aEdge, "properties") or 
				   NOT HasKey(aEdge["properties"], "tags") or
				   ring_find(aEdge["properties"]["tags"], pcTag) = 0
					return FALSE
				ok
			ok
		end
		return TRUE
	
	def _GetNestedValue(aElement, pcKey)
		bIsNested = (substr(pcKey, ".") > 0)
		
		if bIsNested
			acPath = split(pcKey, ".")
			pValue = aElement
			
			if HasKey(aElement, acPath[1])
				pValue = aElement[acPath[1]]
				for i = 2 to len(acPath)
					if isList(pValue) and HasKey(pValue, acPath[i])
						pValue = pValue[acPath[i]]
					else
						return NULL
					ok
				end
				return pValue
				
			but HasKey(aElement, "properties")
				pValue = aElement["properties"]
				for i = 1 to len(acPath)
					if isList(pValue) and HasKey(pValue, acPath[i])
						pValue = pValue[acPath[i]]
					else
						return NULL
					ok
				end
				return pValue
			ok
			return NULL
		ok
		
		if HasKey(aElement, pcKey)
			return aElement[pcKey]
		but HasKey(aElement, "properties") and HasKey(aElement["properties"], pcKey)
			return aElement["properties"][pcKey]
		ok
		return NULL
	
	def _Matches(pActual, pCondition, pValue)
		cCond = lower(pCondition)
		
		if cCond = "equals" or cCond = ":equals" or cCond = "="
			return pActual = pValue
			
		but cCond = "greaterthan" or cCond = ":greaterthan" or cCond = ">"
			return isNumber(pActual) and isNumber(pValue) and pActual > pValue
			
		but cCond = "lessthan" or cCond = ":lessthan" or cCond = "<"
			return isNumber(pActual) and isNumber(pValue) and pActual < pValue
			
		but cCond = "contains" or cCond = ":contains"
			return isString(pActual) and isString(pValue) and 
			       substr(lower(pActual), lower(pValue)) > 0
			       
		but cCond = "insection" or cCond = ":insection" or cCond = "between" or cCond = ":between"
			return isNumber(pActual) and isList(pValue) and len(pValue) = 2 and
			       pActual >= pValue[1] and pActual <= pValue[2]
		ok
		return FALSE


#================================================#
# stzGraphAsciiVisualizer - Keep Separate
#================================================#

class stzGraphAsciiVisualizer
@oGraph

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
	
	def ShowVertical()
		This.Show()
	
		def ShowV()
			This.Show()
	
	def ShowHorizontal()
		acDisplayNodes = This._PrepareDisplayNodes()
		This._ShowHorizontalWithNodes(acDisplayNodes)
	
		def ShowH()
			This.ShowHorizontal()
	
	def _PrepareDisplayNodes()
		acBottlenecks = @oGraph.BottleneckNodes()
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
			bIsBottleneck = ring_find(acBottlenecks, aNode["id"]) > 0
			
			if bIsBottleneck
				aDisplayNode["label"] = "!" + cLabel + "!"
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
			
			if ring_find(pacVisitedPath, cNext) = 0
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
				cEdgeLabel = ""
				if aEdge != NULL and isString(aEdge["label"])
					cEdgeLabel = aEdge["label"]
				ok
				
				? "            |            "
				? "      <" + @cCycleIndicator + ": " + cEdgeLabel + ">   "
				? "            |                      " + @cArrowUp
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
			
			if ring_find(pacVisited, cNext) = 0
				This._ShowHorizontalBranchWithNodes(cNext, pacVisited, pacBoxLines, pacArrowLines, pacDisplayNodes)
			else
				pacArrowLines + [pcNodeId, cNext, aEdge["label"]]
			ok
		ok
