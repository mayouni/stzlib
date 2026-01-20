#============================================#
#  stzGraph - Complete Implementation        #
#  Simplified rules, all methods preserved   #
#============================================#

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

	#--

	func @IsStzGraph(pObj)
		return IsStzGraph(pObj)

	func @IsAStzGraph(pObj)
		return IsStzGraph(pObj)

	func @IsStzGraphObject(pObj)
		return IsStzGraph(pObj)

class stzGraph

	@cId = ""
	@cGraphType = $cDefaultGraphType  # "structural", "flow", "semantic", "dependency"
	@aNodes = []
	@aEdges = []

	# Simplified rule storage - rules as hashlists
	@aCheckBeforeActingRules = []
	@aReactAfterActingRules = []
	@aValidateGraphSateRules = []
	@aAffectedNodes = []
	@aAffectedEdges = []

	@acFinalStateValidators = $acGraphDefaultValidators

	@aProperties = []

	@bEnforceConstraints = FALSE
	@aLastValidationResult = []

	def init(pcName)
		if CheckParams()
			if NOT isString(pcName)
				stzraise("Incorrect param type! pcName must be a string.")
			ok
		ok

		if NOT _IsWellFormedId(pcName)
			stzraise("Inncorrect Id! pcName must be a string without spaces nor new lines.")
		ok

		@cId = lower(pcName)

	def Copy()
		_oCopy_ = This
		return _oCopy_

	def Id()
		return @cId

		def Name()
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

		if ring_find(This.NodesIds(), lower(pcNodeId)) > 0
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

		def NodesNames()
			return This.NodesIds()

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
				cNodeId = lower(acPath[nLen])
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
			if CheckParams()

				if isList(pcToNodeId) and
				   StzListQ(pcToNodeId).IsToOrToNodeOrToNodesNamedParam()
					pcToNodeId = pcToNodeId[2]
				ok

			ok

			if isList(pcToNodeId)
				This.AddEdges(pcFromNodeId, pcToNodeId)
				return
			ok

			This.AddEdgeXTT(pcFromNodeId, pcToNodeId, "", [])

	def ConnectSequence(paNodes)
		if NOT isList(paNodes)
			StzRaise("Incorrect param! paNodes must be a list.")
		ok
		
		nLen = len(paNodes)
		if nLen < 2
			StzRaise("ConnectSequence requires at least 2 nodes.")
		ok
		
		for i = 1 to nLen - 1
			This.Connect(paNodes[i], paNodes[i + 1])
		end
	
		def ConnectInSequence(paNodes)
			This.ConnectSequence(paNodes)
	
		def ConnectMany(paNodes)
			This.ConnectSequence(paNodes)

	def ConnectSequenceXT(paNodesAndLabels)
		if NOT isList(paNodesAndLabels)
			StzRaise("Incorrect param! paNodesAndLabels must be a list.")
		ok
		
		nLen = len(paNodesAndLabels)
		
		# Must be odd number: node1, label1, node2, label2, ..., nodeN
		if nLen % 2 = 0
			StzRaise("List must have odd length: [node1, label1, node2, label2, ..., lastNode]")
		ok
		
		if nLen < 3
			StzRaise("ConnectSequenceXT requires at least 3 items: [node1, label, node2]")
		ok
		
		# Process pairs: node, label, node
		for i = 1 to nLen - 2 step 2
			cFrom = paNodesAndLabels[i]
			cLabel = paNodesAndLabels[i + 1]
			cTo = paNodesAndLabels[i + 2]
			
			This.ConnectXT(cFrom, cTo, cLabel)
		end
	
		def ConnectInSequenceXT(paNodesAndLabels)
			This.ConnectSequenceXT(paNodesAndLabels)
	
		def ConnectManyXT(paNodesAndLabels)
			This.ConnectSequenceXT(paNodesAndLabels)

	def AddEdges(pcFromNodeId, pacToNodesIds)
		nLen = len(pacToNodesIds)
		for i = 1 to nLen
			This.AddEdgeXTT(pcFromNodeId, pacToNodesIds[i], "", [])
		next

		def ConnectToMany(pcFromNodeId, pacToNodesIds)
			This.AddEdges(pcFromNodeId, pacToNodesIds)

	def AddEdgeXT(pcFromNodeId, pcToNodeId, pcLabel)
		This.AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, [])

		def ConnectXT(pcFromNodeId, pcToNodeId, pcLabel)
			This.AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, [])

	def AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, pacProperties)
		if CheckParams()
			if isList(pcFromNodeId) and StzListQ(pcFromNodeId).IsNodeOrNodesOrFromOrFromNodeNamedParam()
				pcFromNodeId = pcFromNodeId[2]
			ok

			if isList(pcToNodeId)
				This.AddEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)
				return
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

	def AddEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)
		nLen = len(paToNodesIdsAndLabelsAndProps)
		for i = 1 to nLen
			This.AddEdgeXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps[i])
		next

		def ConnectEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)
			This.AddEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)

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

	def SetNodeProperty(pcNodeId, cProperty, pValue)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok
		
		nLen = len(@aNodes)
		for i = 1 to nLen
			if @aNodes[i]["id"] = pcNodeId
				if NOT HasKey(@aNodes[i], "properties")
					@aNodes[i]["properties"] = []
				ok
				@aNodes[i]["properties"][cProperty] = pValue
				aTemp = @aNodes[i]
				@aNodes[i] = aTemp
				return
			ok
		end
	
		def SetNodeProp(pcNodeId, cProperty, pValue)
			This.SetNodeProperty(pcNodeId, cProperty, pValue)

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
			This.SetNodeProperty(pcNodeId, aProperties[i][1], aProperties[i][2])
		end
	
		def SetNodeProps(pcNodeId, aProperties)
			This.SetNodeProperties(pcNodeId, aProperties)

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

	def NodeProperty(pcNodeId, cProperty)
		aNode = This.Node(pcNodeId)
	
		if HasKey(aNode, "properties") and HasKey(aNode["properties"], cProperty)
			return aNode["properties"][cProperty]
		ok
	
		def NodeProp(pcNodeId, cProperty)
			return This.NodeProperty(pcNodeId, cProperty)

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
			stzraise("This edge propert (' + cProperty + ') does not exist!")
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

	def NodesByProperty(pcProp, pVal)
		return This.Find("nodes").Where(pcProp, "=", pVal).Run()

	def EdgesWhere(pcProp, pcOp, pVal)
		return This.Find("edges").Where(pcProp, pcOp, pVal).Run()

		def EdgesW(pcProp, pcOp, pVal)
			return This.EdgesWhere(pcProp, pcOp, pVal)

	def EdgesByProperty(pcProp, pVal)
		return This.Find("edges").Where(pcProp, "=", pVal).Run()

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

		if NOT This.NodeExists(pcFromNodeId) or NOT This.NodeExists(pcToNodeId)
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
				
				while _cNode_ != ""
					_acPath_ + _cNode_
					
					_cParent_ = ""
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

		_acPath_ = This.ShortestPath(pcFromNodeId, pcToNodeId)
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
			cName = aNode["id"]
			cLabel = aNode["label"]
			
			if left(cName, 1) = "@"
				cName = @substr(cName, 2, stzlen(cName))
			ok
			
			cDOT += "  " + cName + " [label=" + '"' + cLabel + '"' + "];" + nl
		end
		
		cDOT += nl
		
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			cLabel = aEdge["label"]
			
			if left(cFrom, 1) = "@"
				cFrom = @substr(cFrom, 2, stzlen(cFrom))
			ok
			if left(cTo, 1) = "@"
				cTo = @substr(cTo, 2, stzlen(cTo))
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
			cName = aNode["id"]
			if @substr(cName, 1, 1) = "@"
				cName = @substr(cName, 2, stzlen(cName) - 1)
			ok
			acNodes + [
				:id = cName,
				:label = aNode["label"],
				:properties = aNode["properties"]
			]
		end
		
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			if @substr(cFrom, 1, 1) = "@"
				cFrom = @substr(cFrom, 2, stzlen(cFrom) - 1)
			ok
			if @substr(cTo, 1, 1) = "@"
				cTo = @substr(cTo, 2, stzlen(cTo) - 1)
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
			cName = aNode["id"]
			
			if left(cName, 1) = "@"
				cName = @substr(cName, 2, stzlen(cName))
			ok
			
			cYAML += "  - id: " + cName + nl
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
				cFrom = @substr(cFrom, 2, stzlen(cFrom))
			ok
			if left(cTo, 1) = "@"
				cTo = @substr(cTo, 2, stzlen(cTo))
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

	#------------------#
	#  GRAPHML FORMAT  #
	#------------------#

	def ExportToGraphML()
		cXML = '<?xml version="1.0" encoding="UTF-8"?>' + NL
		cXML += '<graphml xmlns="http://graphml.graphdrawing.org/xmlns"' + NL
		cXML += '         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + NL
		cXML += '         xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns' + NL
		cXML += '         http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">' + NL + NL
		
		# Define keys for properties
		cXML += '  <key id="label" for="node" attr.name="label" attr.type="string"/>' + NL
		cXML += '  <key id="type" for="graph" attr.name="type" attr.type="string"/>' + NL
		cXML += '  <key id="edge_label" for="edge" attr.name="label" attr.type="string"/>' + NL
		
		# Add custom property keys
		aAllProps = This.PropertiesXT()
		nLen = len(aAllProps)
		for i = 1 to nLen
			cPropKey = aAllProps[i][1]
			cXML += '  <key id="prop_' + cPropKey + '" for="node" attr.name="' + cPropKey + '" attr.type="string"/>' + NL
		next
		cXML += NL
		
		# Graph element
		cXML += '  <graph id="' + @cId + '" edgedefault="directed">' + NL
		cXML += '    <data key="type">' + @cGraphType + '</data>' + NL + NL
		
		# Nodes
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			cXML += '    <node id="' + This._XMLEscape(aNode[:id]) + '">' + NL
			cXML += '      <data key="label">' + This._XMLEscape(aNode[:label]) + '</data>' + NL
			
			if HasKey(aNode, :properties) and len(aNode[:properties]) > 0
				aProps = aNode[:properties]
				acKeys = keys(aProps)
				nKeyLen = len(acKeys)
				for j = 1 to nKeyLen
					cKey = acKeys[j]
					pVal = aProps[cKey]
					cXML += '      <data key="prop_' + cKey + '">' + This._XMLEscape(This._ValueToString(pVal)) + '</data>' + NL
				next
			ok
			
			cXML += '    </node>' + NL
		next
		cXML += NL
		
		# Edges
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			cXML += '    <edge id="e' + i + '" source="' + This._XMLEscape(aEdge[:from]) + '" target="' + This._XMLEscape(aEdge[:to]) + '">' + NL
			
			if aEdge[:label] != ""
				cXML += '      <data key="edge_label">' + This._XMLEscape(aEdge[:label]) + '</data>' + NL
			ok
			
			if HasKey(aEdge, :properties) and len(aEdge[:properties]) > 0
				aProps = aEdge[:properties]
				acKeys = keys(aProps)
				nKeyLen = len(acKeys)
				for j = 1 to nKeyLen
					cKey = acKeys[j]
					pVal = aProps[cKey]
					cXML += '      <data key="prop_' + cKey + '">' + This._XMLEscape(This._ValueToString(pVal)) + '</data>' + NL
				next
			ok
			
			cXML += '    </edge>' + NL
		next
		
		cXML += '  </graph>' + NL
		cXML += '</graphml>' + NL
		
		return cXML
	
		def ToGraphML()
			return This.ExportToGraphML()
	
		def AsGraphML()
			return This.ExportToGraphML()
	
	def SaveToGraphML(pcPath)
		cContent = This.ExportToGraphML()
		write(pcPath, cContent)
	
		def SaveAsGraphML(pcPath)
			This.SaveToGraphML(pcPath)
	
	def LoadFromGraphML(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		cContent = read(pcPath)
		This._ParseGraphML(cContent)
	
		def LoadGraphML(pcPath)
			This.LoadFromGraphML(pcPath)
	
		def ImportFromGraphML(pcPath)
			This.LoadFromGraphML(pcPath)
	
		def ImportGraphML(pcPath)
			This.LoadFromGraphML(pcPath)
	
	def _ParseGraphML(cXML)
		# Clear current graph
		@aNodes = []
		@aEdges = []
		
		# Extract graph id
		nPos = substr(cXML, '<graph id="')
		if nPos > 0
			cRest = @substr(cXML, 11, stzlen(cXML))
			nEnd = substr(cRest, '"')
			if nEnd > 0
				@cId = @substr(cRest, 1, nEnd - 1)
			ok
		ok
		
		# Extract graph type
		nPos = substr(cXML, '<data key="type">')
		if nPos > 0
			cRest = @substr(cXML, 17, stzlen(cXML))
			nEnd = substr(cRest, '</data>')
			if nEnd > 0
				@cGraphType = trim(@substr(cRest, 1, nEnd - 1))
			ok
		ok
		
		# Parse nodes
		cRemaining = cXML
		while TRUE
			nNodeStart = substr(cRemaining, '<node id="')
			if nNodeStart = 0
				exit
			ok
			
			cRemaining = @substr(cRemaining, 10, stzlen(cRemaining))
			nIdEnd = substr(cRemaining, '"')
			cNodeId = @substr(cRemaining, 1, nIdEnd - 1)
			
			nNodeEnd = substr(cRemaining, '</node>')
			cNodeBlock = @substr(cRemaining, 1, nNodeEnd - 1)
			
			# Extract label
			cLabel = cNodeId
			nLabelPos = substr(cNodeBlock, '<data key="label">')
			if nLabelPos > 0
				cLabelRest = @substr(cNodeBlock, 18, stzlen(cNodeBlock))
				nLabelEnd = substr(cLabelRest, '</data>')
				if nLabelEnd > 0
					cLabel = This._XMLUnescape(@substr(cLabelRest, 1, nLabelEnd - 1))
				ok
			ok
			
			# Extract properties
			aProps = []
			cPropBlock = cNodeBlock
			while TRUE
				nPropPos = substr(cPropBlock, '<data key="prop_')
				if nPropPos = 0
					exit
				ok
				
				cPropBlock = @substr(cPropBlock, 16, stzlen(cPropBlock))
				nKeyEnd = substr(cPropBlock, '">')
				cPropKey = @substr(cPropBlock, 1, nKeyEnd - 1)
				
				cPropBlock = @substr(cPropBlock, nKeyEnd + 2, stzlen(cPropBlock))
				nValEnd = substr(cPropBlock, '</data>')
				cPropVal = This._XMLUnescape(@substr(cPropBlock, 1, nValEnd - 1))
				
				aProps + [cPropKey, This._StringToValue(cPropVal)]
			end
			
			This.AddNodeXTT(cNodeId, cLabel, aProps)
			cRemaining = @substr(cRemaining, 7, stzlen(cRemaining))
		end
		
		# Parse edges
		cRemaining = cXML
		while TRUE
			nEdgeStart = substr(cRemaining, '<edge ')
			if nEdgeStart = 0
				exit
			ok
			
			cRemaining = @substr(cRemaining, 6, stzlen(cRemaining))
			
			# Extract source
			nSourcePos = substr(cRemaining, 'source="')
			cRemaining = @substr(cRemaining, 8, stzlen(cRemaining))
			nSourceEnd = substr(cRemaining, '"')
			cSource = @substr(cRemaining, 1, nSourceEnd - 1)
			
			# Extract target
			nTargetPos = substr(cRemaining, 'target="')
			cRemaining = @substr(cRemaining, 8, stzlen(cRemaining))
			nTargetEnd = substr(cRemaining, '"')
			cTarget = @substr(cRemaining, 1, nTargetEnd - 1)
			
			nEdgeEnd = substr(cRemaining, '</edge>')
			cEdgeBlock = @substr(cRemaining, 1, nEdgeEnd - 1)
			
			# Extract edge label
			cEdgeLabel = ""
			nLabelPos = substr(cEdgeBlock, '<data key="edge_label">')
			if nLabelPos > 0
				cLabelRest = @substr(cEdgeBlock, 23, stzlen(cEdgeBlock))
				nLabelEnd = substr(cLabelRest, '</data>')
				if nLabelEnd > 0
					cEdgeLabel = This._XMLUnescape(@substr(cLabelRest, 1, nLabelEnd - 1))
				ok
			ok
			
			# Extract edge properties
			aProps = []
			cPropBlock = cEdgeBlock
			while TRUE
				nPropPos = substr(cPropBlock, '<data key="prop_')
				if nPropPos = 0
					exit
				ok
				
				cPropBlock = @substr(cPropBlock, 16, stzlen(cPropBlock))
				nKeyEnd = substr(cPropBlock, '">')
				cPropKey = @substr(cPropBlock, 1, nKeyEnd - 1)
				
				cPropBlock = @substr(cPropBlock, 2, stzlen(cPropBlock))
				nValEnd = substr(cPropBlock, '</data>')
				cPropVal = This._XMLUnescape(@substr(cPropBlock, 1, nValEnd - 1))
				
				aProps + [cPropKey, This._StringToValue(cPropVal)]
			end
			
			This.AddEdgeXTT(cSource, cTarget, cEdgeLabel, aProps)
			cRemaining = @substr(cRemaining, 7, stzlen(cRemaining))
		end
	
	def _XMLEscape(cText)
		if NOT isString(cText)
			return ""
		ok
		
		cText = substr(cText, "&", "&amp;")
		cText = substr(cText, "<", "&lt;")
		cText = substr(cText, ">", "&gt;")
		cText = substr(cText, '"', "&quot;")
		cText = substr(cText, "'", "&apos;")
		return cText
	
	def _XMLUnescape(cText)
		if NOT isString(cText)
			return ""
		ok
		
		cText = substr(cText, "&amp;", "&")
		cText = substr(cText, "&lt;", "<")
		cText = substr(cText, "&gt;", ">")
		cText = substr(cText, "&quot;", '"')
		cText = substr(cText, "&apos;", "'")
		return cText
	
	def _ValueToString(pValue)
		if isString(pValue)
			return pValue

		but isNumber(pValue)
			return "" + pValue

		but isList(pValue)
			return "[" + JoinXT(pValue, ",") + "]"
		else
			return ""
		ok
	
	def _StringToValue(cValue)
		if left(cValue, 1) = "[" and right(cValue, 1) = "]"

			cInner = @substr(cValue, 2, stzlen(cValue) - 2)
			if cInner = ""
				return []
			ok

			acParts = @split(cInner, ",")
			aResult = []
			nLen = len(acParts)

			for i = 1 to nLen
				aResult + trim(acParts[i])
			next

			return aResult
		ok
		
		if isdigit(cValue) or (left(cValue, 1) = "-" and stzlen(cValue) > 1 and isdigit(@substr(cValue, 2, 1)))
			return 0 + cValue
		ok
		
		return cValue

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
	        aStory + (acPath[i] + " â†’ " + acPath[i+1])
		if aEdge[:label] != ""
			aStory[len(aStory)] +=  (" : because {" + acPath[i] + "} " + substr(aEdge[:label], "_", " ") + " {" + acPath[i+1] + "}" )
		ok
	    next
	    
	    return aStory

	#-------------------#
	#  RULE MANAGEMENT  #
	#-------------------#
	
	def UseRulesFrom(pcRuleGroup)
		if HasKey($aGraphRules, pcRuleGroup)
			aRules = $aGraphRules[pcRuleGroup]
			for aRule in aRules
				This._AddUniqueRule(aRule)
			next
		ok
	
	def _AddUniqueRule(aRule)
		# Check if rule already exists
		cName = aRule[:name]
		cType = aRule[:type]
		
		# Get appropriate rule list
		aRuleList = NULL
		if cType = :CheckBeforeActing
			aRuleList = @aCheckBeforeActingRules
		but cType = :ReactAfterActing
			aRuleList = @aReactAfterActingRules
		but cType = :ValidateGraphSate
			aRuleList = @aValidateGraphSateRules
		ok
		
		if aRuleList != NULL
			# Check if already exists
			for aExisting in aRuleList
				if aExisting[:name] = cName
					return  # Already added
				ok
			next
			
			# Add to appropriate list
			if cType = :CheckBeforeActing
				@aCheckBeforeActingRules + aRule
			but cType = :ReactAfterActing
				@aReactAfterActingRules + aRule
			but cType = :ValidateGraphSate
				@aValidateGraphSateRules + aRule
			ok
		ok

	def ApplyConstructionRules()  # Was: ApplyDerivations
		nAdded = 0
		nLen = len(@aReactAfterActingRules)  # Changed
		
		for i = 1 to nLen
			aRule = @aReactAfterActingRules[i]  # Changed
			
			pFunc = aRule[:function]
			paParams = aRule[:params]
			aNewEdges = call pFunc(This, paParams)
			
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
	
	def CheckDesignRules(paOperationParams)  # Was: CheckConstraints
		aViolations = []
		nLen = len(@aCheckBeforeActingRules)  # Changed
		
		for i = 1 to nLen
			aRule = @aCheckBeforeActingRules[i]  # Changed
			
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
	
	def RulesSummary()
		aSummary = [
			:design = [],
			:construction = [],
			:finalstate = [],
			:applied = []
		]
		
		nLen = len(@aCheckBeforeActingRules)
		for i = 1 to nLen
			aSummary[:design] + @aCheckBeforeActingRules[i][:name]
		next
		
		nLen = len(@aReactAfterActingRules)
		for i = 1 to nLen
			aSummary[:construction] + @aReactAfterActingRules[i][:name]
		next
		
		nLen = len(@aValidateGraphSateRules)
		for i = 1 to nLen
			aSummary[:finalstate] + @aValidateGraphSateRules[i][:name]
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

	#--------------#
	#  VALIDATION  #
	#--------------#

	def Validate()
		return This.ValidateFinalState()
	
	def ValidateXT(paValidators)
		return This.ValidateFinalStateXT(paValidators)

	def ValidateFinalState()
		return This.ValidateFinalStateXT(@acFinalStateValidators)
	
	def ValidateFinalStateXT(paValidators)
		if isString(paValidators)
			return This._ValidateSingle(paValidators)
		but isList(paValidators)
			return This._ValidateMultiple(paValidators)
		ok
	
	def _ValidateSingle(pcValidator)
		cValidator = lower(pcValidator)
		
		# Load rules (additive)
		This.UseRulesFrom(cValidator)
		
		# Run validation
		aViolations = []
		acRulesChecked = []
		
		nLen = len(@aValidateGraphSateRules)
		for i = 1 to nLen
			aRule = @aValidateGraphSateRules[i]
			acRulesChecked + aRule[:name]
			
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
		
		if len(aViolations) > 0
			acIssues = This._FlattenViolations(aViolations)
			acAffected = This._ExtractAffectedNodes(aViolations)
			
			return [
				:status = "fail",
				:domain = cValidator,
				:issueCount = len(aViolations),
				:issues = acIssues,
				:affectedNodes = acAffected
			]
		ok
		
		# Add before final return in _ValidateSingle:
		bValid = (len(aViolations) = 0)
		@aLastValidationResult = [bValid, aViolations, acRulesChecked]
		
		return [
			:status = "pass",
			:domain = cValidator,
			:issueCount = 0,
			:issues = [],
			:affectedNodes = []
		]
	
	def _ValidateMultiple(pacValidators)
		aResults = []
		nFailed = 0
		nTotal = 0
		
		for cValidator in pacValidators
			aResult = This._ValidateSingle(cValidator)
			aResults + aResult
			
			if aResult[:status] = "fail"
				nFailed++
			ok
			nTotal += aResult[:issueCount]
		end
		
		return [
			:status = iif(nFailed > 0, "fail", "pass"),
			:validatorsRun = len(pacValidators),
			:validatorsFailed = nFailed,
			:totalIssues = nTotal,
			:results = aResults,
			:affectedNodes = This._MergeAffectedNodes(aResults)
		]
	
	def _FlattenViolations(aViolations)
		acIssues = []
		for aViolation in aViolations
			if HasKey(aViolation, :message)
				pMsg = aViolation[:message]
				
				if isList(pMsg)
					for aSubViolation in pMsg
						if isList(aSubViolation) and HasKey(aSubViolation, :message)
							acIssues + aSubViolation[:message]
						but isString(aSubViolation)
							acIssues + aSubViolation
						ok
					next
				but isString(pMsg)
					acIssues + pMsg
				ok
			ok
		end
		return acIssues
	
	def _ExtractAffectedNodes(aViolations)
		acNodes = []
		for aViolation in aViolations
			if HasKey(aViolation, :message)
				pMsg = aViolation[:message]
				
				if isList(pMsg)
					for aSubViolation in pMsg
						if isList(aSubViolation) and 
						   HasKey(aSubViolation, :params) and 
						   HasKey(aSubViolation[:params], :node)
							cNode = aSubViolation[:params][:node]
							if ring_find(acNodes, cNode) = 0
								acNodes + cNode
							ok
						ok
					next
				ok
				
				if HasKey(aViolation, :params) and 
				   HasKey(aViolation[:params], :node)
					cNode = aViolation[:params][:node]
					if ring_find(acNodes, cNode) = 0
						acNodes + cNode
					ok
				ok
			ok
		end
		return acNodes
	
	def _MergeAffectedNodes(aResults)
		acAll = []
		for aResult in aResults
			if HasKey(aResult, :affectedNodes)
				for cNode in aResult[:affectedNodes]
					if ring_find(acAll, cNode) = 0
						acAll + cNode
					ok
				end
			ok
		end
		return acAll
	
	def ValidationSummary()
		if len(@aLastValidationResult) = 0
			return [:status = "not_run", :message = "No validation run yet"]
		ok
		
		bValid = @aLastValidationResult[1]
		aViolations = @aLastValidationResult[2]
		acChecked = @aLastValidationResult[3]
		
		return [
			:status = iif(bValid, "pass", "fail"),
			:rules_applied = acChecked,
			:violations = aViolations,
			:violation_count = len(aViolations),
			:passed = bValid
		]
	
		def ValidationResult()
			return This.ValidationSummary()
	
		def Validation()
			return This.ValidationSummary()
	
		def ValidationXT()
			return This.ValidationSummary()

	def Anomalies()
		return This.ValidationSummary()[:violations]

		def Issues()
			return This.Anomalies()

		def Violations()
			return This.Anomalies()

	#====================#
	#  GRAPH COMPARISON  #
	#====================#

	def CompareWith(oOtherGraph)
		if NOT @IsStzGraph(oOtherGraph)
			stzraise("Parameter must be a stzGraph object!")
		ok
		
		aDiff = [
			:summary = This._CompareSummary(oOtherGraph),
			:nodes = This._CompareNodes(oOtherGraph),
			:edges = This._CompareEdges(oOtherGraph),
			:metrics = This._CompareMetrics(oOtherGraph),
			:topology = This._CompareTopology(oOtherGraph),
			:impact = This._CompareImpact(oOtherGraph),
			:explanation = This._GenerateExplanation(oOtherGraph)
		]
		
		return aDiff

		def DiffWith(oOtherGraph)
			return This.CompareWith(oOtherGraph)

		def Diff(oOtherGraph)
			return This.CompareWith(oOtherGraph)

	#-----------------------------#
	#  MULTIPLE GRAPH COMPARISON  #
	#-----------------------------#

	def CompareWithMany(paoGraphs)
		# Accept either list of graphs or hashlist with names
		aGraphs = []
		
		if isList(paoGraphs) and len(paoGraphs) > 0
			if isList(paoGraphs[1]) and len(paoGraphs[1]) = 2 and isString(paoGraphs[1][1])
				# Hashlist format: [ ["name1", oGraph1], ["name2", oGraph2] ]
				aGraphs = paoGraphs
			else
				# Simple list: auto-generate names
				nLen = len(paoGraphs)
				for i = 1 to nLen
					aGraphs + ["Variation_" + i, paoGraphs[i]]
				next
			ok
		ok
		
		if len(aGraphs) = 0
			stzraise("No graphs provided for comparison!")
		ok
		
		# Build comparison matrix
		aComparisons = []
		nLen = len(aGraphs)
		
		for i = 1 to nLen
			cName = aGraphs[i][1]
			oGraph = aGraphs[i][2]
			
			if NOT @IsStzGraph(oGraph)
				stzraise("Item " + i + " is not a valid stzGraph object!")
			ok
			
			aDiff = This.CompareWith(oGraph)
			
			# Extract key metrics for tabular view
			aRow = [
				:name = cName,
				:nodesAdded = aDiff[:summary][:nodesAdded],
				:nodesRemoved = aDiff[:summary][:nodesRemoved],
				:edgesAdded = aDiff[:summary][:edgesAdded],
				:edgesRemoved = aDiff[:summary][:edgesRemoved],
				:densityChange = aDiff[:metrics][:density][:change],
				:hasCycles = aDiff[:metrics][:hasCycles][:to],
				:bottleneckChange = aDiff[:topology][:bottlenecks][:change],
				:explanation = aDiff[:explanation][1]  # First explanation line
			]
			
			aComparisons + aRow
		next
		
		aResult = [
			:comparisons = aComparisons,
			:baseline = This.Id(),
			:count = len(aComparisons)
		]

		return aResult

		#< @FunctionFluentForms

		def CompareWithManyQ(paoGraphs)
			return new stzList(This.CompareWithMany(paoGraphs))

		def CompareWithManyQR(paoGraphs, pcReturnType)
			switch pcReturnType
			on :stzGraphComparison
				return new stzGraphComparison(This, paoGraphs)

			on :stzHashList
				return new stzHashList(This.CompareWithMany(paoGraphs))

			on :stzListOfLists
				return new stzListOfLists(This.CompareWithMany(paoGraphs))

			other
				stzraise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CompareMany(paoGraphs)
			return This.CompareWithMany(paoGraphs)

			def CompareManyQ(paoGraphs)
				return return new stzList(This.CompareWithMany(paoGraphs))
	
			def CompareManyQR(paoGraphs, pcReturnType)
				return This.CompareWithManyQR(paoGraphs, pcReturnType)
	
		def DiffMany(paoGraphs)
			return This.CompareWithMany(paoGraphs)

			def DiffManyQ(paoGraphs)
				return return new stzList(This.CompareWithMany(paoGraphs))
	
			def DiffManyQR(paoGraphs, pcReturnType)
				return This.CompareWithManyQR(paoGraphs, pcReturnType)
	
		def DiffWithMany(paoGraphs)
			return This.CompareWithMany(paoGraphs)

			def DiffWithManyQ(paoGraphs)
				return return new stzList(This.CompareWithMany(paoGraphs))

			def diffManyWithQR(paoGraphs, pcReturnType)
				return This.CompareWithManyQR(paoGraphs, pcReturnType)
	
		#>


	#------------------------------------------#
	#  GRAPH COMPARISON VISUALIZATION SUPPORT  #
	#------------------------------------------#

	def _ToStzTableData(aComparison)
		# Convert comparison result to stzTable format - TRANSPOSED
		if NOT (isList(aComparison) and HasKey(aComparison, :comparisons))
			stzraise("Invalid comparison format!")
		ok
		
		aComparisons = aComparison[:comparisons]
		nLen = len(aComparisons)
		
		# Build header row with variation names
		aHeader = ["Metric"]
		for i = 1 to nLen
			aHeader + aComparisons[i][:name]
		next
		
		# Build metric rows (transposed)
		aTableData = [aHeader]
		
		# Nodes Added row
		aRow = ["NodesAdded"]
		for i = 1 to nLen
			aRow + aComparisons[i][:nodesAdded]
		next
		aTableData + aRow
		
		# Nodes Removed row
		aRow = ["NodesRemoved"]
		for i = 1 to nLen
			aRow + aComparisons[i][:nodesRemoved]
		next
		aTableData + aRow
		
		# Edges Added row
		aRow = ["EdgesAdded"]
		for i = 1 to nLen
			aRow + aComparisons[i][:edgesAdded]
		next
		aTableData + aRow
		
		# Edges Removed row
		aRow = ["EdgesRemoved"]
		for i = 1 to nLen
			aRow + aComparisons[i][:edgesRemoved]
		next
		aTableData + aRow
		
		# Density Change row
		aRow = ["DensityChange"]
		for i = 1 to nLen
			aRow + aComparisons[i][:densityChange]
		next
		aTableData + aRow
		
		# Has Cycles row
		aRow = ["HasCycles"]
		for i = 1 to nLen
			aRow + aComparisons[i][:hasCycles]
		next
		aTableData + aRow
		
		# Bottleneck Change row
		aRow = ["BottleneckChange"]
		for i = 1 to nLen
			aRow + aComparisons[i][:bottleneckChange]
		next
		aTableData + aRow
		
		return aTableData

	#-----------------------------#
	#  GRAPH COMPARISON HELPERS   #
	#-----------------------------#

	def _CompareSummary(oOtherGraph)
		acBaselineIds = This.NodesIds()
		acVariationIds = oOtherGraph.NodesIds()
		
		acAdded = []
		acRemoved = []
		nLen = len(acVariationIds)
		for i = 1 to nLen
			if ring_find(acBaselineIds, acVariationIds[i]) = 0
				acAdded + acVariationIds[i]
			ok
		next
		
		nLen = len(acBaselineIds)
		for i = 1 to nLen
			if ring_find(acVariationIds, acBaselineIds[i]) = 0
				acRemoved + acBaselineIds[i]
			ok
		next
		
		# Count edge changes
		aEdgeDiff = This._CompareEdges(oOtherGraph)
		
		# Count property changes
		nPropsChanged = 0
		aNodeDiff = This._CompareNodes(oOtherGraph)
		if HasKey(aNodeDiff, :modified)
			nPropsChanged = len(aNodeDiff[:modified])
		ok
		
		return [
			:nodesAdded = len(acAdded),
			:nodesRemoved = len(acRemoved),
			:edgesAdded = len(aEdgeDiff[:added]),
			:edgesRemoved = len(aEdgeDiff[:removed]),
			:propertiesChanged = nPropsChanged
		]

	def _CompareNodes(oOtherGraph)
		acBaselineIds = This.NodesIds()
		acVariationIds = oOtherGraph.NodesIds()
		
		acAdded = []
		acRemoved = []
		aModified = []
		
		# Find added nodes
		nLen = len(acVariationIds)
		for i = 1 to nLen
			if ring_find(acBaselineIds, acVariationIds[i]) = 0
				acAdded + acVariationIds[i]
			ok
		next
		
		# Find removed nodes
		nLen = len(acBaselineIds)
		for i = 1 to nLen
			if ring_find(acVariationIds, acBaselineIds[i]) = 0
				acRemoved + acBaselineIds[i]
			ok
		next
		
		# Find modified nodes (common nodes with property changes)
		nLen = len(acBaselineIds)
		for i = 1 to nLen
			cNodeId = acBaselineIds[i]
			if ring_find(acVariationIds, cNodeId) > 0
				aBaseNode = This.Node(cNodeId)
				aVarNode = oOtherGraph.Node(cNodeId)
				
				aChanges = []
				
				# Compare properties
				if HasKey(aBaseNode, :properties) or HasKey(aVarNode, :properties)
					aBaseProps = []
					aVarProps = []
					
					if HasKey(aBaseNode, :properties)
						aBaseProps = aBaseNode[:properties]
					ok
					if HasKey(aVarNode, :properties)
						aVarProps = aVarNode[:properties]
					ok
					
					# Check for changed/added properties
					acVarKeys = keys(aVarProps)
					nKeyLen = len(acVarKeys)
					for j = 1 to nKeyLen
						cKey = acVarKeys[j]
						pVarVal = aVarProps[cKey]
						
						if HasKey(aBaseProps, cKey)
							pBaseVal = aBaseProps[cKey]
							if pBaseVal != pVarVal
								aChanges + [:property, cKey, pBaseVal, pVarVal]
							ok
						else
							aChanges + [:property, cKey, NULL, pVarVal]
						ok
					next
					
					# Check for removed properties
					acBaseKeys = keys(aBaseProps)
					nKeyLen = len(acBaseKeys)
					for j = 1 to nKeyLen
						cKey = acBaseKeys[j]
						if NOT HasKey(aVarProps, cKey)
							aChanges + [:property, cKey, aBaseProps[cKey], NULL]
						ok
					next
				ok
				
				if len(aChanges) > 0
					aModified + [cNodeId, aChanges]
				ok
			ok
		next
		
		return [
			:added = acAdded,
			:removed = acRemoved,
			:modified = aModified
		]

	def _CompareEdges(oOtherGraph)

		aEdges = This.Edges()
		oOtherEdges = new stzList(oOtherGraph.Edges())
		_aDiff_ = oOtherEdges.DifferenceWithXT(aEdges)

		_aResult_ = [
			:added = _aDiff_[:added],
			:removed = _aDiff_[:removed],
			:modified = _aDiff_[:modified]
		]

		return _aResult_

	def _CompareMetrics(oOtherGraph)
		# Node count
		nBaseNodes = This.NodeCount()
		nVarNodes = oOtherGraph.NodeCount()
		
		# Edge count
		nBaseEdges = This.EdgeCount()
		nVarEdges = oOtherGraph.EdgeCount()
		
		# Density
		nBaseDensity = This.NodeDensity()
		nVarDensity = oOtherGraph.NodeDensity()
		
		# Longest path
		nBasePath = This.LongestPath()
		nVarPath = oOtherGraph.LongestPath()
		
		# Cycles
		bBaseCycles = This.HasCyclicDependencies()
		bVarCycles = oOtherGraph.HasCyclicDependencies()
		
		# Average degree
		nBaseAvgDegree = 0
		if nBaseNodes > 0
			nBaseAvgDegree = (nBaseEdges * 2.0) / nBaseNodes
		ok
		nVarAvgDegree = 0
		if nVarNodes > 0
			nVarAvgDegree = (nVarEdges * 2.0) / nVarNodes
		ok
		
		return [
			:nodeCount = This._MetricChange(nBaseNodes, nVarNodes),
			:edgeCount = This._MetricChange(nBaseEdges, nVarEdges),
			:density = This._MetricChange(nBaseDensity, nVarDensity),
			:longestPath = This._MetricChange(nBasePath, nVarPath),
			:hasCycles = This._BooleanChange(bBaseCycles, bVarCycles),
			:avgDegree = This._MetricChange(nBaseAvgDegree, nVarAvgDegree)
		]

	def _CompareTopology(oOtherGraph)
		# Bottlenecks
		acBaseBottlenecks = This.BottleneckNodes()
		acVarBottlenecks = oOtherGraph.BottleneckNodes()
		cBottleneckChange = "unchanged"
		nDelta = len(acVarBottlenecks) - len(acBaseBottlenecks)
		if nDelta > 0
			cBottleneckChange = "increased"
		but nDelta < 0
			cBottleneckChange = "reduced"
		ok
		
		# Connected components
		nBaseComponents = len(This.ConnectedComponents())
		nVarComponents = len(oOtherGraph.ConnectedComponents())
		cComponentChange = "unchanged"
		if nVarComponents > nBaseComponents
			cComponentChange = "fragmented"
		but nVarComponents < nBaseComponents
			cComponentChange = "merged"
		ok
		
		# Isolated nodes
		acBaseIsolated = []
		acBaseIds = This.NodesIds()
		nLen = len(acBaseIds)
		for i = 1 to nLen
			cName = acBaseIds[i]
			if len(This.Neighbors(cName)) = 0 and len(This.Incoming(cName)) = 0
				acBaseIsolated + cName
			ok
		next
		
		acVarIsolated = []
		acVarIds = oOtherGraph.NodesIds()
		nLen = len(acVarIds)
		for i = 1 to nLen
			cName = acVarIds[i]
			if len(oOtherGraph.Neighbors(cName)) = 0 and len(oOtherGraph.Incoming(cName)) = 0
				acVarIsolated + cName
			ok
		next
		
		cIsolatedChange = "unchanged"
		if len(acVarIsolated) > len(acBaseIsolated)
			cIsolatedChange = "increased"
		but len(acVarIsolated) < len(acBaseIsolated)
			cIsolatedChange = "reduced"
		ok
		
		return [
			:bottlenecks = [
				:from = acBaseBottlenecks,
				:to = acVarBottlenecks,
				:change = cBottleneckChange,
				:delta = nDelta
			],
			:connectedComponents = [
				:from = nBaseComponents,
				:to = nVarComponents,
				:change = cComponentChange
			],
			:isolatedNodes = [
				:from = acBaseIsolated,
				:to = acVarIsolated,
				:change = cIsolatedChange
			]
		]

	def _CompareImpact(oOtherGraph)
		acReachabilityChanges = []
		acCriticalityChanges = []
		
		# Compare reachability for common nodes
		acBaseIds = This.NodesIds()
		acVarIds = oOtherGraph.NodesIds()
		
		nLen = len(acBaseIds)
		for i = 1 to nLen
			cNodeId = acBaseIds[i]
			
			# Only analyze nodes that exist in both graphs
			if ring_find(acVarIds, cNodeId) > 0
				# Check reachability changes
				acBaseReachable = This.ReachableFrom(cNodeId)
				acVarReachable = oOtherGraph.ReachableFrom(cNodeId)
				
				if len(acVarReachable) > len(acBaseReachable)
					nDiff = len(acVarReachable) - len(acBaseReachable)
					acReachabilityChanges + [cNodeId, "Can now reach " + nDiff + " more node(s)"]

				but len(acVarReachable) < len(acBaseReachable)
					nDiff = len(acBaseReachable) - len(acVarReachable)
					acReachabilityChanges + [cNodeId, "Can now reach " + nDiff + " fewer node(s)"]
				ok
				
				# Check criticality (degree) changes
				nBaseDegree = len(This.Neighbors(cNodeId)) + len(This.Incoming(cNodeId))
				nVarDegree = len(oOtherGraph.Neighbors(cNodeId)) + len(oOtherGraph.Incoming(cNodeId))
				
				if nVarDegree > nBaseDegree
					acCriticalityChanges + [cNodeId, "Criticality increased (degree " + nBaseDegree + " â†’ " + nVarDegree + ")"]
				but nVarDegree < nBaseDegree
					acCriticalityChanges + [cNodeId, "Criticality decreased (degree " + nBaseDegree + " â†’ " + nVarDegree + ")"]
				ok
			ok
		next
		
		# Check for newly added critical nodes
		nLen = len(acVarIds)
		for i = 1 to nLen
			cNodeId = acVarIds[i]
			if ring_find(acBaseIds, cNodeId) = 0
				nDegree = len(oOtherGraph.Neighbors(cNodeId)) + len(oOtherGraph.Incoming(cNodeId))
				if nDegree >= 3
					acCriticalityChanges + [cNodeId, "New critical node (degree " + nDegree + ")"]
				ok
			ok
		next
		
		return [
			:reachabilityChanges = acReachabilityChanges,
			:criticalityChanges = acCriticalityChanges
		]

	def _GenerateExplanation(oOtherGraph)
		acExplanation = []
		
		aSummary = This._CompareSummary(oOtherGraph)
		aMetrics = This._CompareMetrics(oOtherGraph)
		aTopology = This._CompareTopology(oOtherGraph)
		
		# Structural changes
		if aSummary[:nodesAdded] > 0 or aSummary[:edgesAdded] > 0
			cMsg = ""
			if aSummary[:nodesAdded] > 0 and aSummary[:edgesAdded] > 0
				cMsg = "Added " + aSummary[:nodesAdded] + " node(s) and " + aSummary[:edgesAdded] + " edge(s)"
			but aSummary[:nodesAdded] > 0
				cMsg = "Added " + aSummary[:nodesAdded] + " node(s)"
			but aSummary[:edgesAdded] > 0
				cMsg = "Added " + aSummary[:edgesAdded] + " edge(s)"
			ok
			acExplanation + cMsg
		ok
		
		if aSummary[:nodesRemoved] > 0 or aSummary[:edgesRemoved] > 0
			cMsg = ""
			if aSummary[:nodesRemoved] > 0 and aSummary[:edgesRemoved] > 0
				cMsg = "Removed " + aSummary[:nodesRemoved] + " node(s) and " + aSummary[:edgesRemoved] + " edge(s)"
			but aSummary[:nodesRemoved] > 0
				cMsg = "Removed " + aSummary[:nodesRemoved] + " node(s)"
			but aSummary[:edgesRemoved] > 0
				cMsg = "Removed " + aSummary[:edgesRemoved] + " edge(s)"
			ok
			acExplanation + cMsg
		ok
		
		if aSummary[:propertiesChanged] > 0
			acExplanation + ("Modified " + aSummary[:propertiesChanged] + " node propertie(s)")
		ok
		
		# Metrics changes
		if aMetrics[:density][:change] != "unchanged"
			acExplanation + ("Density " + aMetrics[:density][:change])
		ok
		
		# Topology changes
		if aTopology[:bottlenecks][:change] != "unchanged"
			if aTopology[:bottlenecks][:change] = "reduced"
				acExplanation + ("Bottlenecks reduced (improvement)")
			else
				acExplanation + ("Bottlenecks " + aTopology[:bottlenecks][:change])
			ok
		ok
		
		# Cycles
		if aMetrics[:hasCycles][:from] = FALSE and aMetrics[:hasCycles][:to] = TRUE
			acExplanation + "Warning: Cycles introduced"
		but aMetrics[:hasCycles][:from] = TRUE and aMetrics[:hasCycles][:to] = FALSE
			acExplanation + "Cycles removed (now acyclic)"
		ok
		
		# Connectivity
		if aTopology[:connectedComponents][:change] = "fragmented"
			acExplanation + "Warning: Graph became fragmented"
		but aTopology[:connectedComponents][:change] = "merged"
			acExplanation + "Components merged (better connectivity)"
		ok
		
		if len(acExplanation) = 0
			acExplanation + "No significant changes detected"
		ok
		
		return acExplanation

	def _MetricChange(pFrom, pTo)
		nDelta = pTo - pFrom
		cChange = This._CalculateChange(pFrom, pTo)
		
		return [
			:from = pFrom,
			:to = pTo,
			:change = cChange,
			:delta = nDelta
		]

	def _BooleanChange(bFrom, bTo)
		cChange = "unchanged"
		if bFrom != bTo
			if bTo
				cChange = "now TRUE"
			else
				cChange = "now FALSE"
			ok
		ok
		
		return [
			:from = iff(bFrom, "TRUE", "FALSE"),
			:to = iff(bTo, "TRUE", "FALSE"),
			:change = cChange
		]

	def _CalculateChange(pFrom, pTo)
		if isNumber(pFrom) and isNumber(pTo)
			if pFrom = 0
				if pTo = 0
					return "unchanged"
				else
					return "+100%"
				ok
			ok
			
			nDelta = pTo - pFrom
			nPercent = (nDelta / pFrom) * 100
			
			if nPercent > 0.5
				return "+" + nPercent + "%"
			but nPercent < -0.5
				return ""+ nPercent + "%"
			else
				return "unchanged"
			ok
		ok
		
		return "unchanged"
	
	#=======================================#
	#  SERIALIZATION - FILE FORMAT SUPPORT  #
	#=======================================#
	
	def LoadFrom(pcPath)
		cExtension = @split(pcPath, ".")[2]

		switch cExtension
		on "graf"
			LoadFromStzGraf(pcPath)

		on "rulz"
			LoadFromStzRulz(pcPath)

		on "graphml"
			LoadFromGraphML(pcPath)

		other
			stzraise("Unsupported file format.")
		off

	def SaveTo(pcPath)
		cExtension = @split(pcPath, ".")[2]

		switch cExtension
		on "graf"
			SaveToStzGraf(pcPath)

		on "rulz"
			SaveToStzRulz(pcPath)

		on "graphml"
			SavetoGraphML(pcPath)

		other
			stzraise("Unsupported file format.")
		off

	#------------------#
	#  .stzgraf FORMAT #
	#------------------#
	
	def ExportToStzGraf()
		cOutput = 'graph "' + @cId + '"' + NL
		cOutput += '    type: ' + @cGraphType + NL + NL
		
		# Nodes section
		cOutput += "nodes" + NL
		nLen = len(@aNodes)
		for i = 1 to nLen
			cOutput += "    " + @aNodes[i][:id] + NL
		next
		cOutput += NL
		
		# Edges section
		cOutput += "edges" + NL
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			cOutput += "    " + aEdge[:from] + " -> " + aEdge[:to]
			if aEdge[:label] != ""
				cOutput += ' "' + aEdge[:label] + '"'
			ok
			cOutput += NL
		next
		
		# Properties section
		if This._HasNodeProperties()
			cOutput += NL + "properties" + NL
			nLen = len(@aNodes)
			for i = 1 to nLen
				aNode = @aNodes[i]
				if HasKey(aNode, :properties) and len(aNode[:properties]) > 0
					cOutput += "    " + aNode[:id] + NL
					aProps = aNode[:properties]
					acKeys = keys(aProps)
					nKeyLen = len(acKeys)
					for j = 1 to nKeyLen
						cKey = acKeys[j]
						pVal = aProps[cKey]
						cOutput += "        " + cKey + ": " + This._FormatValue(pVal) + NL
					next
					cOutput += NL
				ok
			next
		ok
		
		return cOutput
	
		def ToStzGraf()
			return This.ExportToStzGraf()
	
		def AsStzGraf()
			return This.ExportToStzGraf()
	
	def SaveToStzGraf(pcPath)
		cContent = This.ExportToStzGraf()
		write(pcPath, cContent)
	
		def SaveAsStzGraf(pcPath)
			This.SaveToStzGraf(pcPath)
	
	def LoadFromStzGraf(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		cContent = read(pcPath)
		This._ParseStzGraf(cContent)
	
		def LoadStzGraf(pcPath)
			This.LoadFromStzGraf(pcPath)
	
	def _ParseStzGraf(cContent)
		# Clear current graph
		@aNodes = []
		@aEdges = []
		
		acLines = split(cContent, NL)
		cSection = ""
		cCurrentNode = ""
		nLen = len(acLines)
		
		for i = 1 to nLen
			cLine = trim(acLines[i])
			
			if cLine = "" or left(cLine, 1) = "#"
				loop
			ok
			
			# Parse graph declaration
			if left(cLine, 5) = "graph"
				nPos = substr(cLine, '"')
				if nPos > 0
					cQuoted = @substr(cLine, nPos + 1, stzlen(cLine))
					nEnd = substr(cQuoted, '"')
					if nEnd > 0
						@cId = @substr(cQuoted, 1, nEnd - 1)
					ok
				ok
				loop
			ok
			
			# Parse type
			if substr(cLine, "type:") > 0
				nPos = substr(cLine, ":")
				@cGraphType = trim(@substr(cLine, nPos + 1, stzlen(cLine)))
				loop
			ok
			
			# Section headers
			if cLine = "nodes"
				cSection = "nodes"
				loop

			but cLine = "edges"
				cSection = "edges"
				loop

			but cLine = "properties"
				cSection = "properties"
				loop
			ok
			
			# Parse content based on section
			if cSection = "nodes"
				cNodeId = trim(cLine)
				if cNodeId != ""
					This.AddNode(cNodeId)
				ok
				
			but cSection = "edges"
				if substr(cLine, "->") > 0
					acParts = @split(cLine, "->")
					if len(acParts) >= 2
						cFrom = trim(acParts[1])
						cRest = trim(acParts[2])
						
						# Check for label in quotes
						nQuote = substr(cRest, '"')
						if nQuote > 0
							cTo = trim(@substr(cRest, 1, nQuote - 1))
							cLabel = @substr(cRest, nQuote + 1, stzlen(cRest))
							nEndQuote = substr(cLabel, '"')
							if nEndQuote > 0
								cLabel = @substr(cLabel, 1, nEndQuote - 1)
								This.AddEdgeXT(cFrom, cTo, cLabel)
							else
								This.AddEdge(cFrom, cTo)
							ok
						else
							cTo = cRest
							This.AddEdge(cFrom, cTo)
						ok
					ok
				ok
				
			but cSection = "properties"
				# Check if this is a node name (no indentation or single indent)
				nIndent = 0
				nLen2 = len(acLines[i])
				for j = 1 to nLen2
					_c_ = @substr(acLines[i], j, j+1)
					if _c_ = " " or _c_ = TAB
						nIndent++
					else
						exit
					ok
				next
				
				if nIndent <= 4
					cCurrentNode = trim(cLine)
				else
					# Property line
					if substr(cLine, ":") > 0
						acParts = @split(cLine, ":")
						if len(acParts) >= 2
							cKey = trim(acParts[1])
							cVal = trim(acParts[2])
							pValue = This._ParseValue(cVal)
							This.SetNodeProperty(cCurrentNode, cKey, pValue)
						ok
					ok
				ok
			ok
		next
	
	#------------------#
	#  .stzrulz FORMAT #
	#------------------#
	
	def ExportToStzRulz()
		cOutput = 'ruleset "' + @cId + ' Rules"' + NL
		cOutput += '    domain: ' + @cGraphType + NL
		cOutput += '    version: 1.0' + NL + NL
		
		cOutput += "rules" + NL + NL
		
		nLen = len(@aRules)
		for i = 1 to nLen
			aRule = @aRules[i]
			
			cOutput += "    rule " + aRule[:name] + NL
			cOutput += "        type: " + aRule[:type] + NL
			cOutput += "        severity: " + aRule[:severity] + NL
			cOutput += "        function: " + This._GetFunctionName(aRule[:function]) + NL
			
			if len(aRule[:params]) > 0
				cOutput += "        params" + NL
				aParams = aRule[:params]
				acKeys = keys(aParams)
				nKeyLen = len(acKeys)
				for j = 1 to nKeyLen
					cKey = acKeys[j]
					pVal = aParams[cKey]
					cOutput += "            " + cKey + ": " + This._FormatValue(pVal) + NL
				next
			ok
			
			cOutput += "        message" + NL
			cOutput += '            "' + aRule[:message] + '"' + NL
			cOutput += NL
		next
		
		return cOutput
	
		def ToStzRulz()
			return This.ExportToStzRulz()
	
		def AsStzRulz()
			return This.ExportToStzRulz()
	
	def SaveToStzRulz(pcPath)
		cContent = This.ExportToStzRulz()
		write(pcPath, cContent)
	
		def SaveAsStzRulz(pcPath)
			This.SaveToStzRulz(pcPath)
	
	def LoadFromStzRulz(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		cContent = read(pcPath)
		This._ParseStzRulz(cContent)
	
		def LoadStzRulz(pcPath)
			This.LoadFromStzRulz(pcPath)
	
	def _ParseStzRulz(cContent)
		# Loads rule properties and links to functions from .stzrulf files
		acLines = split(cContent, NL)
		cSection = ""
		aCurrentRule = []
		cCurrentKey = ""
		nLen = len(acLines)
		
		for i = 1 to nLen
			cLine = acLines[i]
			cTrimmed = trim(cLine)
			
			if cTrimmed = "" or left(cTrimmed, 1) = "#"
				loop
			ok
			
			if cTrimmed = "rules"
				cSection = "rules"
				loop
			ok
			
			if cSection = "rules"
				if left(cTrimmed, 4) = "rule"
					# Save previous rule
					if len(aCurrentRule) > 0
						@aRules + aCurrentRule
					ok
					
					# Start new rule
					cName = trim(@substr(cTrimmed, 6, stzlen(cTrimmed)))
					aCurrentRule = [
						:name = cName,
						:type = "",
						:function = "",
						:params = [],
						:message = "",
						:severity = ""
					]
					
				but substr(cTrimmed, "type:") = 1
					aCurrentRule[:type] = trim(@substr(cTrimmed, 6, stzlen(cTrimmed)))
					
				but substr(cTrimmed, "severity:") = 1
					aCurrentRule[:severity] = trim(@substr(cTrimmed, 11, stzlen(cTrimmed)))
					
				but substr(cTrimmed, "function:") = 1
					cFuncName = trim(@substr(cTrimmed, 11, stzlen(cTrimmed)))
					aCurrentRule[:function] = This._ResolveFunctionName(cFuncName)
					
				but cTrimmed = "params"
					cCurrentKey = "params"
					
				but cTrimmed = "message"
					cCurrentKey = "message"
					
				but cCurrentKey = "params" and substr(cTrimmed, ":") > 0
					acParts = @split(cTrimmed, ":")
					if len(acParts) >= 2
						cKey = trim(acParts[1])
						cVal = trim(acParts[2])
						aCurrentRule[:params][cKey] = This._ParseValue(cVal)
					ok
					
				but cCurrentKey = "message"
					cMsg = trim(cTrimmed)
					if left(cMsg, 1) = '"' and right(cMsg, 1) = '"'
						cMsg = @substr(cMsg, 2, stzlen(cMsg) - 2)
					ok
					aCurrentRule[:message] = cMsg
				ok
			ok
		next
		
		# Save last rule
		if len(aCurrentRule) > 0
			@aRules + aCurrentRule
		ok

	#------------------#
	#  .stzrulf FORMAT #
	#------------------#
	
	def LoadRuleFunctionsFrom(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		# Load and execute the .stzrulf file to register functions
		load pcPath
	
		def LoadStzRulf(pcPath)
			This.LoadRuleFunctionsFrom(pcPath)
	
	def _GetFunctionName(pFunc)
		# Try to match against known built-in functions
		if pFunc = DerivationFunc_Transitivity()
			return "DerivationFunc_Transitivity"
		but pFunc = DerivationFunc_Symmetry()
			return "DerivationFunc_Symmetry"
		but pFunc = DerivationFunc_Hierarchy()
			return "DerivationFunc_Hierarchy"
		but pFunc = ConstraintFunc_NoSelfLoop()
			return "ConstraintFunc_NoSelfLoop"
		but pFunc = ConstraintFunc_MaxDegree()
			return "ConstraintFunc_MaxDegree"
		but pFunc = ConstraintFunc_NoCycles()
			return "ConstraintFunc_NoCycles"
		but pFunc = ConstraintFunc_Separation()
			return "ConstraintFunc_Separation"
		but pFunc = ConstraintFunc_PropertyMismatch()
			return "ConstraintFunc_PropertyMismatch"
		but pFunc = ValidationFunc_IsAcyclic()
			return "ValidationFunc_IsAcyclic"
		but pFunc = ValidationFunc_IsConnected()
			return "ValidationFunc_IsConnected"
		but pFunc = ValidationFunc_MaxNodes()
			return "ValidationFunc_MaxNodes"
		but pFunc = ValidationFunc_DensityRange()
			return "ValidationFunc_DensityRange"
		but pFunc = ValidationFunc_NoBottlenecks()
			return "ValidationFunc_NoBottlenecks"
		but pFunc = ValidationFunc_AllNodesReachable()
			return "ValidationFunc_AllNodesReachable"
		else
			return "CustomFunction"
		ok
	
	def _ResolveFunctionName(cFuncName)
		# Resolve function name to actual function object
		if cFuncName = "DerivationFunc_Transitivity"
			return DerivationFunc_Transitivity()

		but cFuncName = "DerivationFunc_Symmetry"
			return DerivationFunc_Symmetry()

		but cFuncName = "DerivationFunc_Hierarchy"
			return DerivationFunc_Hierarchy()

		but cFuncName = "ConstraintFunc_NoSelfLoop"
			return ConstraintFunc_NoSelfLoop()

		but cFuncName = "ConstraintFunc_MaxDegree"
			return ConstraintFunc_MaxDegree()

		but cFuncName = "ConstraintFunc_NoCycles"
			return ConstraintFunc_NoCycles()

		but cFuncName = "ConstraintFunc_Separation"
			return ConstraintFunc_Separation()

		but cFuncName = "ConstraintFunc_PropertyMismatch"
			return ConstraintFunc_PropertyMismatch()

		but cFuncName = "ValidationFunc_IsAcyclic"
			return ValidationFunc_IsAcyclic()

		but cFuncName = "ValidationFunc_IsConnected"
			return ValidationFunc_IsConnected()

		but cFuncName = "ValidationFunc_MaxNodes"
			return ValidationFunc_MaxNodes()

		but cFuncName = "ValidationFunc_DensityRange"
			return ValidationFunc_DensityRange()

		but cFuncName = "ValidationFunc_NoBottlenecks"
			return ValidationFunc_NoBottlenecks()

		but cFuncName = "ValidationFunc_AllNodesReachable"
			return ValidationFunc_AllNodesReachable()

		else
			stzraise("Can't resolve function name!")
		ok
	
	#------------------#
	#  .stzsim FORMAT  #
	#------------------#
	
	def ExportToStzSim(oBaselineGraph)
		cOutput = 'simulation "' + @cId + ' Comparison"' + NL
		cOutput += '    description: "Changes from baseline"' + NL
		cOutput += '    date: ' + Date() + NL + NL
		
		# Compare and generate changes
		aDiff = oBaselineGraph.CompareWith(This)
		
		cOutput += "changes" + NL + NL
		
		# Node changes
		aNodeDiff = aDiff[:nodes]
		
		if len(aNodeDiff[:added]) > 0
			nLen = len(aNodeDiff[:added])
			for i = 1 to nLen
				cNodeId = aNodeDiff[:added][i]
				aNode = This.Node(cNodeId)
				cOutput += "    add node " + cNodeId + NL
				cOutput += '        label: "' + aNode[:label] + '"' + NL
			next
			cOutput += NL
		ok
		
		if len(aNodeDiff[:removed]) > 0
			nLen = len(aNodeDiff[:removed])
			for i = 1 to nLen
				cOutput += "    remove node " + aNodeDiff[:removed][i] + NL
			next
			cOutput += NL
		ok
		
		# Edge changes
		aEdgeDiff = aDiff[:edges]
		
		if len(aEdgeDiff[:added]) > 0
			nLen = len(aEdgeDiff[:added])
			for i = 1 to nLen
				aEdge = aEdgeDiff[:added][i]
				cOutput += "    add edge " + aEdge[:from] + " -> " + aEdge[:to] + NL
			next
			cOutput += NL
		ok
		
		if len(aEdgeDiff[:removed]) > 0
			nLen = len(aEdgeDiff[:removed])
			for i = 1 to nLen
				aEdge = aEdgeDiff[:removed][i]
				cOutput += "    remove edge " + aEdge[:from] + " -> " + aEdge[:to] + NL
			next
			cOutput += NL
		ok
		
		# Metrics section
		cOutput += "metrics" + NL + NL
		aMetrics = aDiff[:metrics]
		
		cOutput += "    density: " + aMetrics[:density][:from] + " -> " + aMetrics[:density][:to] + NL
		cOutput += "    nodeCount: " + aMetrics[:nodeCount][:from] + " -> " + aMetrics[:nodeCount][:to] + NL
		cOutput += "    edgeCount: " + aMetrics[:edgeCount][:from] + " -> " + aMetrics[:edgeCount][:to] + NL
		cOutput += "    hasCycles: " + aMetrics[:hasCycles][:from] + " -> " + aMetrics[:hasCycles][:to] + NL
		
		return cOutput
	
		def ToStzSim(oBaselineGraph)
			return This.ExportToStzSim(oBaselineGraph)
	
		def AsStzSim(oBaselineGraph)
			return This.ExportToStzSim(oBaselineGraph)
	
	def SaveToStzSim(pcPath, oBaselineGraph)
		cContent = This.ExportToStzSim(oBaselineGraph)
		write(pcPath, cContent)
	
		def SaveAsStzSim(pcPath, oBaselineGraph)
			This.SaveToStzSim(pcPath, oBaselineGraph)
	
	def ApplySimulation(cSimContent)
		# Parse and apply changes from .stzsim format
		acLines = split(cSimContent, NL)
		cSection = ""
		nLen = len(acLines)
		
		for i = 1 to nLen
			cLine = acLines[i]
			cTrimmed = trim(cLine)
			
			if cTrimmed = "" or left(cTrimmed, 1) = "#"
				loop
			ok
			
			if cTrimmed = "changes"
				cSection = "changes"
				loop
			but cTrimmed = "metrics"
				exit  # Stop at metrics section
			ok
			
			if cSection = "changes"
				if substr(cTrimmed, "add node ") = 1
					cNodeId = trim(@substr(cTrimmed, 10, stzlen(cTrimmed)))
					if NOT This.NodeExists(cNodeId)
						This.AddNode(cNodeId)
					ok
					
				but substr(cTrimmed, "remove node ") = 1
					cNodeId = trim(@substr(cTrimmed, 13, stzlen(cTrimmed)))
					if This.NodeExists(cNodeId)
						This.RemoveThisNode(cNodeId)
					ok
					
				but substr(cTrimmed, "add edge ") = 1
					cRest = trim(@substr(cTrimmed, 10, stzlen(cTrimmed)))
					if substr(cRest, "->") > 0
						acParts = split(cRest, "->")
						if len(acParts) >= 2
							cFrom = trim(acParts[1])
							cTo = trim(acParts[2])
							if This.NodeExists(cFrom) and This.NodeExists(cTo)
								This.AddEdge(cFrom, cTo)
							ok
						ok
					ok
					
				but substr(cTrimmed, "remove edge ") = 1
					cRest = trim(@substr(cTrimmed, 13, stzlen(cTrimmed)))
					if substr(cRest, "->") > 0
						acParts = @split(cRest, "->")
						if len(acParts) >= 2
							cFrom = trim(acParts[1])
							cTo = trim(acParts[2])
							This.RemoveThisEdge(cFrom, cTo)
						ok
					ok
				ok
			ok
		next
	
		def ApplyStzSim(cSimContent)
			This.ApplySimulation(cSimContent)
	
	#--------------------#
	#  HELPER FUNCTIONS  #
	#--------------------#
	
	def _HasNodeProperties()
		nLen = len(@aNodes)

		for i = 1 to nLen
			if HasKey(@aNodes[i], :properties) and len(@aNodes[i][:properties]) > 0
				return TRUE
			ok
		next

		return FALSE
	
	def _FormatValue(pValue)
		if isString(pValue)
			if substr(pValue, " ") > 0 or substr(pValue, ":") > 0
				return '"' + pValue + '"'
			else
				return pValue
			ok

		but isNumber(pValue)
			return "" + pValue

		but isList(pValue)
			return "[" + JoinXT(pValue, ", ") + "]"
		else
			return '""'
		ok
	
	def _ParseValue(cValue)
		cValue = trim(cValue)
		
		# Remove quotes if present
		if left(cValue, 1) = '"' and
		   right(cValue, 1) = '"'

			return @substr(cValue, 2, stzlen(cValue) - 2)
		ok
		
		# Try to parse as number
		if isdigit(cValue) or (left(cValue, 1) = "-" and
					isdigit(@substr(cValue, 2, 3)))

			return 0 + cValue
		ok
		
		# Try to parse as boolean
		if lower(cValue) = "true"
			return TRUE

		but lower(cValue) = "false"
			return FALSE
		ok
		
		# Try to parse as list
		if left(cValue, 1) = "[" and right(cValue, 1) = "]"

			cInner = @substr(cValue, 2, stzlen(cValue) - 2)
			if cInner = ""
				return []
			ok

			acParts = @split(cInner, ",")
			aResult = []
			nLen = len(acParts)
			for i = 1 to nLen
				aResult + This._ParseValue(trim(acParts[i]))
			next
			return aResult
		ok
		
		# Default: return as string
		return cValue
	
	#=========#
	#  MISC.  #
	#=========#

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
		return pcLabel

		def  _NormaliseLabel(pcLabel)
			return substr(pcLabel, " ", "_")

	def _IsWellFormedId(pcName)
		if NOT isString(pcName)
			return 0
		ok

		if substr(pcName, " ") > 0
			return 0
		ok

		if substr(pcName, NL) > 0
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
				if pActual = ""
					return FALSE
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return FALSE
				ok
				
			but cType = :hasprop
				pcKey = aFilter[2]
				if This._GetNestedValue(aNode, pcKey) = ""
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
				if pActual = ""
					return FALSE
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return FALSE
				ok
				
			but cType = :hasprop
				pcKey = aFilter[2]
				if This._GetNestedValue(aEdge, pcKey) = ""
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
						return "" # TODO Is it safer to raise an error?
					ok
				end
				return pValue
				
			but HasKey(aElement, "properties")
				pValue = aElement["properties"]
				for i = 1 to len(acPath)
					if isList(pValue) and HasKey(pValue, acPath[i])
						pValue = pValue[acPath[i]]
					else
						return "" # TODO Is it safer to raise an error?
					ok
				end
				return pValue
			ok
			return "" # TODO Is it safer to raise an error?
		ok
		
		if HasKey(aElement, pcKey)
			return aElement[pcKey]

		but HasKey(aElement, "properties") and HasKey(aElement["properties"], pcKey)
			return aElement["properties"][pcKey]
		ok
		return "" # TODO Is it safer to raise an error?
	
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


#==========================#
# stzGraphAsciiVisualizer
#==========================#

class stzGraphAsciiVisualizer
	@oGraph

	@cBoxTopLeft = "â•­"
	@cBoxTopRight = "â•®"
	@cBoxBottomLeft = "â•°"
	@cBoxBottomRight = "â•¯"
	@cBoxHorizontal = "â”€"
	@cBoxVertical = "â”‚"
	@cArrowDown = "v"
	@cArrowUp = "â†‘"
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


#================================================#
# stzGraphComparison - Fluent Comparison   #
#================================================#

class stzGraphComparison
	@oBaselineGraph
	@aGraphs = []
	@aComparisonData = []
	
	def init(oBaseline, paoGraphs)
		@oBaselineGraph = oBaseline
		
		# Normalize input
		if isList(paoGraphs) and len(paoGraphs) > 0
			if isList(paoGraphs[1]) and len(paoGraphs[1]) = 2 and isString(paoGraphs[1][1])
				@aGraphs = paoGraphs
			else
				nLen = len(paoGraphs)
				for i = 1 to nLen
					@aGraphs + ["V" + i, paoGraphs[i]]
				next
			ok
		ok
		
		# Perform comparisons
		This._BuildComparisons()
	
	def _BuildComparisons()
		@aComparisonData = @oBaselineGraph.CompareWithMany(@aGraphs)
	
	def ToStzTable()
		aTableData = @oBaselineGraph._ToStzTableData(@aComparisonData)
		return new stzTable(aTableData)
	
		def AsStzTable()
			return This.ToStzTable()
	
		def AsTable()
			return This.ToStzTable()
	
	def Show()
		oTable = This.ToStzTable()
		oTable.Show()
	
		def Display()
			This.Show()
	
	def Data()
		return @aComparisonData
	
		def Content()

	def Comparisons()
		return @aComparisonData[:comparisons]
	
	def Summary()
		cResult = ""
		cResult += "Baseline: " + @aComparisonData[:baseline] + NL
		cResult += "Variations compared: " + @aComparisonData[:count] + NL + NL
		
		aComps = @aComparisonData[:comparisons]
		nLen = len(aComps)
		
		for i = 1 to nLen
			aComp = aComps[i]
			cResult += "â€¢ " + aComp[:name] + ": " + aComp[:explanation] + NL
		next
		
		return cResult
	
	def MostImpactful()
		# Returns variation with most total changes
		aComps = @aComparisonData[:comparisons]
		nMaxImpact = 0
		cMaxName = ""
		
		nLen = len(aComps)
		for i = 1 to nLen
			aComp = aComps[i]
			nImpact = aComp[:nodesAdded] + aComp[:nodesRemoved] + 
			          aComp[:edgesAdded] + aComp[:edgesRemoved]
			
			if nImpact > nMaxImpact
				nMaxImpact = nImpact
				cMaxName = aComp[:name]
			ok
		next
		
		return cMaxName
	
	def LeastImpactful()
		# Returns variation with fewest total changes
		aComps = @aComparisonData[:comparisons]
		nMinImpact = 999999
		cMinName = ""
		
		nLen = len(aComps)
		for i = 1 to nLen
			aComp = aComps[i]
			nImpact = aComp[:nodesAdded] + aComp[:nodesRemoved] + 
			          aComp[:edgesAdded] + aComp[:edgesRemoved]
			
			if nImpact < nMinImpact
				nMinImpact = nImpact
				cMinName = aComp[:name]
			ok
		next
		
		return cMinName
	
	def WithCycles()
		# Returns names of variations that introduce cycles
		aComps = @aComparisonData[:comparisons]
		acResult = []
		
		nLen = len(aComps)
		for i = 1 to nLen
			if aComps[i][:hasCycles] = TRUE
				acResult + aComps[i][:name]
			ok
		next
		
		return acResult
	
	def WithoutCycles()
		# Returns names of variations that remain acyclic
		aComps = @aComparisonData[:comparisons]
		acResult = []
		
		nLen = len(aComps)
		for i = 1 to nLen
			if aComps[i][:hasCycles] = FALSE
				acResult + aComps[i][:name]
			ok
		next
		
		return acResult
	
	def ByMetric(cMetric)
		# Sort variations by specified metric
		# Supported: :nodesAdded, :edgesAdded, etc.
		aComps = @aComparisonData[:comparisons]
		
		if NOT HasKey(aComps[1], cMetric)
			stzraise("Unknown metric: " + cMetric)
		ok
		
		# Simple bubble sort
		nLen = len(aComps)
		for i = 1 to nLen - 1
			for j = i + 1 to nLen
				if aComps[j][cMetric] > aComps[i][cMetric]
					aTemp = aComps[i]
					aComps[i] = aComps[j]
					aComps[j] = aTemp
				ok
			next
		next
		
		acResult = []
		nLen = len(aComps)
		for i = 1 to nLen
			acResult + aComps[i][:name]
		next
		
		return acResult
	
	def Recommend()
		# Simple recommendation logic
		aComps = @aComparisonData[:comparisons]
		
		# Find variation with:
		# - No cycles
		# - Positive density change
		# - Reduced bottlenecks
		
		nBestScore = -999
		cBestName = ""
		
		nLen = len(aComps)
		for i = 1 to nLen
			aComp = aComps[i]
			nScore = 0
			
			# No cycles: +10
			if aComp[:hasCycles] = FALSE
				nScore += 10
			ok
			
			# Reduced bottlenecks: +5
			if aComp[:bottleneckChange] = "reduced"
				nScore += 5
			ok
			
			# Positive density change: +3
			cDensity = aComp[:densityChange]
			if isString(cDensity) and substr(cDensity, "+") > 0
				nScore += 3
			ok
			
			# Fewer nodes removed than added: +2
			if aComp[:nodesRemoved] < aComp[:nodesAdded]
				nScore += 2
			ok
			
			if nScore > nBestScore
				nBestScore = nScore
				cBestName = aComp[:name]
			ok
		next
		
		return [
			:recommended = cBestName,
			:reason = "Best balance of structure, connectivity, and acyclicity"
		]
