#============================================#
#  stzGraph - Complete Implementation        #
#  Simplified rules, all methods preserved   #
#============================================#

# The file contains some other classes used by the main class:
# stzGraphFinder, stzGraphAsciiVisualizer, and stzGraphComparison

#TODO Abstract the simulation feature in a distinc stzGraphSimulator class

$acGraphTypes = ["structural", "flow", "semantic", "dependency"]
$cDefaultGraphType = "structural"

$acGraphDefaultValidators = ["dag", "reachability", "completeness"]

func StzGraphQ(cGraphName)
	return new stzGraph(cGraphName)

func StzGraphTypes()
	return @acGraphTypes

	func GraphTypes()
		return StzGraphTypes()

func StzDefaultGraphType()
	return @cDefaultGraphType

	func DefaultGraphType()
		return StzDefaultGraphType()

func StzGraphDefaultValidators()
	return $acGraphDefaultValidators

	func GraphDefaultValidators()
		return StzGraphDefaultValidators()

	func DefaultGraphValidators()
		return StzGraphDefaultValidators()

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

class stzGraph from stzObject

	@cId = ""
	@cGraphType = $cDefaultGraphType  # "structural", "flow", "semantic", "dependency"
	@aNodes = []
	@aEdges = []

	# Node-id -> position index, so NodeExists() is O(1).
	#
	# It used to rebuild the WHOLE id list with NodesIds() and linear-scan it
	# on every call, and AddEdge calls NodeExists TWICE per edge -- so
	# building a graph was O(n^2): 1000 edges took 13.39s.
	#
	# The engine hash map is used rather than a Ring hash list on purpose: it
	# compares keys BYTE-EXACTLY, where Ring's own hashlist indexer silently
	# misses multibyte keys once the list lives in an object attribute.
	@pNodeIdx = NULL
	@nNodeIdxCount = -1
	@bNodeIdxStale = TRUE

	# Same story for edges, and this one was the bigger half. EdgeExists
	# walked every edge -- calling StzLower on BOTH arguments inside the loop,
	# so two engine calls per edge examined -- and AddEdge asks it about an
	# edge that by definition is NOT there yet, so every add scanned the whole
	# list. Adding E edges was O(E^2).
	@pEdgeIdx = NULL
	@nEdgeIdxCount = -1
	@bEdgeIdxStale = TRUE

	# Simplified rule storage - rules as hashlists
	@aConstraintRules = []
	@aDerivationRules = []
	@aValidationRules = []
	@aAffectedNodes = []
	@aAffectedEdges = []

	@acValidators = $acGraphDefaultValidators

	@aProperties = []

	@bEnforceConstraints = TRUE
	@bAutoDerive = FALSE # Default: manual derivation

	@aLastValidationResult = []

	@pEngineGraph = NULL
	@bEngineStale = TRUE

	# The arrow the path/impact explanations draw with, built from RAW
	# UTF-8 BYTES so the source stays pure-ASCII. Written as a literal it
	# gets double-encoded the next time an editor reads the file as cp1252
	# and re-saves it as UTF-8 -- which had already happened here: every
	# explanation printed a garbled run instead of an arrow.
	@cArrowRight = char(226) + char(134) + char(146)   # U+2192

	def init(pcName)
		if CheckParams()
			if NOT isString(pcName)
				stzraise("Incorrect param type! pcName must be a string.")
			ok
		ok

		if NOT _IsWellFormedId(pcName)
			stzraise("Inncorrect Id! pcName must be a string without spaces nor new lines.")
		ok

		@cId = StzLower(pcName)

	#--------------------------#
	#  ENGINE ADAPTER LAYER    #
	#--------------------------#

	def _EngineAvailable()
		# The engine functions are registered NATIVELY by the DLL's
		# ringlib_init (not as Ring funcs), so isFunction() can't see them
		# -- using it here silently disabled the ENTIRE engine graph path
		# and forced every op onto the slow pure-Ring fallbacks. Detect via
		# the loader handle ($pStzGraphHandle, set in engine/stz_graph.ring).
		return isPointer($pStzGraphHandle)

	def _EngineHandle()
		return @pEngineGraph

	def _InvalidateEngine()
		@bEngineStale = TRUE

	def _FreeEngine()
		if @pEngineGraph != NULL
			StzEngineGraphFree(@pEngineGraph)
			@pEngineGraph = NULL
		ok
		@bEngineStale = TRUE

	def _EnsureEngine()
		if NOT This._EngineAvailable()
			return FALSE
		ok

		if @pEngineGraph != NULL and NOT @bEngineStale
			return TRUE
		ok

		if @pEngineGraph != NULL
			StzEngineGraphFree(@pEngineGraph)
			@pEngineGraph = NULL
		ok

		@pEngineGraph = StzEngineGraphCreate(1)

		_nNodeLen_ = len(@aNodes)
		for _iEng_ = 1 to _nNodeLen_
			StzEngineGraphAddNode(@pEngineGraph, @aNodes[_iEng_][:id])
			# Push (x,y) coordinates to the engine when the node carries them
			# in its properties -- this powers the engine A* heuristic.
			_aNP_ = @aNodes[_iEng_][:properties]
			if isList(_aNP_) and HasKey(_aNP_, "x") and HasKey(_aNP_, "y")
				StzEngineGraphSetCoords(@pEngineGraph, @aNodes[_iEng_][:id], _aNP_[:x], _aNP_[:y])
			ok
		next

		_nEdgeLen_ = len(@aEdges)
		for _iEng_ = 1 to _nEdgeLen_
			# Pass a real edge weight when the edge carries one in its
			# properties (:weight); default 1.0. This lets the engine's
			# Dijkstra reflect weighted edges, not just hop count.
			_nW_ = 1.0
			_aEP_ = @aEdges[_iEng_][:properties]
			if isList(_aEP_) and HasKey(_aEP_, "weight")
				_nW_ = _aEP_[:weight]
			ok
			StzEngineGraphAddEdge(@pEngineGraph, @aEdges[_iEng_][:from], @aEdges[_iEng_][:to], _nW_)
			# Push an edge :cost (for min-cost-max-flow) when present.
			if isList(_aEP_) and HasKey(_aEP_, "cost")
				StzEngineGraphSetEdgeCost(@pEngineGraph, @aEdges[_iEng_][:from], @aEdges[_iEng_][:to], _aEP_[:cost])
			ok
		next

		@bEngineStale = FALSE
		return TRUE

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
		@cGraphType = StzLower(pcType)

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

		_aNode_ = [
			:id = StzLower(pcNodeId),
			:label = pcLabel,
			:properties = iif(isList(pacProperties), pacProperties, [])
		]
		@aNodes + _aNode_

		# Same as for edges: extend the index rather than invalidating it.
		if @pNodeIdx != NULL and NOT @bNodeIdxStale
			if @nNodeIdxCount = len(@aNodes) - 1
				StzEngineHashMapPutInt(@pNodeIdx, _aNode_[:id], len(@aNodes))
				@nNodeIdxCount = len(@aNodes)
			ok
		ok

		# Push the node into the LIVE engine graph rather than discarding it.
		if @pEngineGraph != NULL and NOT @bEngineStale
			StzEngineGraphAddNode(@pEngineGraph, _aNode_[:id])

			_aAnP_ = _aNode_[:properties]
			if isList(_aAnP_) and HasKey(_aAnP_, "x") and HasKey(_aAnP_, "y")
				StzEngineGraphSetCoords(@pEngineGraph, _aNode_[:id], _aAnP_[:x], _aAnP_[:y])
			ok
		else
			This._InvalidateEngine()
		ok

	def Node(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			if _aNode_["id"] = StzLower(pcNodeId)
				return _aNode_
			ok
		end
		stzraise("Node '" + pcNodeId + "' does not exist!")

		def NodeById(pcNodeId)
			return This.Node(pcNodeId)

	def NodeXT(pcNodeId)
		_aNode_ = This.Node(pcNodeId)
		if HasKey(_aNode_, "properties")
			return _aNode_["properties"]
		ok
		return []

	def NodeExists(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		_cNeId_ = StzLower(pcNodeId)

		This._EnsureNodeIndex()

		if @pNodeIdx != NULL
			return StzEngineHashMapHasKey(@pNodeIdx, _cNeId_)
		ok

		# Fallback when the engine map is unavailable: the original scan.
		if StzFindFirst(_cNeId_, This.NodesIds()) > 0
			return 1
		else
			return 0
		ok

	# Builds the node-id index on demand, and rebuilds it when @aNodes has
	# changed. Length is the cheap staleness signal -- every bulk assignment
	# either clears the list or shortens it -- and SetNodes(), which can swap
	# a same-length list, marks the index stale explicitly.
	def _EnsureNodeIndex()
		_nNiLen_ = len(@aNodes)

		if @pNodeIdx != NULL and @nNodeIdxCount = _nNiLen_ and NOT @bNodeIdxStale
			return
		ok

		if @pNodeIdx != NULL
			StzEngineHashMapFree(@pNodeIdx)
			@pNodeIdx = NULL
		ok

		@pNodeIdx = StzEngineHashMapNew()

		if @pNodeIdx = NULL
			return
		ok

		for _iNi_ = 1 to _nNiLen_
			StzEngineHashMapPutInt(@pNodeIdx, @aNodes[_iNi_][:id], _iNi_)
		next

		@nNodeIdxCount = _nNiLen_
		@bNodeIdxStale = FALSE

		def HasNode(pcNodeId)
			return This.NodeExists(pcNodeId)

	def SetNodes(paNodes)
		@aNodes = paNodes
		# Length alone cannot detect a same-length swap, so say so outright.
		@bNodeIdxStale = TRUE
	
	def SetEdges(paEdges)
		@aEdges = paEdges
		# Length alone cannot detect a same-length swap.
		@bEdgeIdxStale = TRUE

	def Nodes()
		return @aNodes

	def NodesIds()
		_nLen_ = len(@aNodes)
		_acResult_ = []

		for i = 1 to _nLen_
			_acResult_ + @aNodes[i][:id]
		next

		return _acResult_

		def NodesNames()
			return This.NodesIds()

	def NodesCount()
		return len(@aNodes)

		def NodeCount()
			return len(@aNodes)

		def HowManyNodes()
			return len(@aNodes)

		def HowManyNode()
			return len(@aNodes)

		def NumberOfNodes()
			return len(@aNodes)

	#--

	def AddNodes(pacNodes)
		_nLen_ = len(pacNodes)
		for i = 1 to _nLen_
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
		_aIncoming_ = []
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			if @aEdges[i]["to"] = pcTargetId
				_aIncoming_ + @aEdges[i]["from"]
			ok
		end
		
		This.AddNodeXTT(pcNewId, pcNewLabel, paProps)
		
		_nLen_ = len(_aIncoming_)
		for i = 1 to _nLen_
			This.RemoveThisEdge(_aIncoming_[i], pcTargetId)
			This.Connect(_aIncoming_[i], pcNewId)
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
		_aOutgoing_ = []
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			if @aEdges[i]["from"] = pcTargetId
				_aOutgoing_ + @aEdges[i]["to"]
			ok
		end
		
		This.AddNodeXTT(pcNewId, pcNewLabel, paProps)
		
		_nLen_ = len(_aOutgoing_)
		for i = 1 to _nLen_
			This.RemoveThisEdge(pcTargetId, _aOutgoing_[i])
			This.Connect(pcNewId, _aOutgoing_[i])
		end
		This.Connect(pcTargetId, pcNewId)
	
	#-------------------------#
	#  INSERT MULTIPLE NODES  #
	#-------------------------#
	
	def InsertNodesBefore(pcTargetId, paNodes)
		_nLen_ = len(paNodes)
		for i = 1 to _nLen_
			This.InsertNodeBefore(pcTargetId, paNodes[i][1], paNodes[i][2])
			pcTargetId = paNodes[i][1]
		end
	
	def InsertNodesAfter(pcTargetId, paNodes)
		_nLen_ = len(paNodes)
		_cLastId_ = pcTargetId
		for i = 1 to _nLen_
			This.InsertNodeAfter(_cLastId_, paNodes[i][1], paNodes[i][2])
			_cLastId_ = paNodes[i][1]
		end

	#---------------#
	#  NODE REMOVAL #
	#---------------#
	
	def RemoveNodes()
		@aNodes = []
		@aEdges = []
		@aAffectedNodes = []
		@aAffectedEdges = []
		This._InvalidateEngine()

		def RemoveAllNodes()
			This.RemoveNodes()
	
		def Clear()
			This.RemoveNodes()
	
	def RemoveTheseNodes(pacNodeIds)
		_nLen_ = len(pacNodeIds)
		for i = 1 to _nLen_
			This.RemoveThisNode(pacNodeIds[i])
		end
	
	def RemoveThisNode(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		_acNew_ = []
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			if @aNodes[i]["id"] != pcNodeId
				_acNew_ + @aNodes[i]
			ok
		end
		@aNodes = _acNew_

		This.RemoveEdgesConnectedTo(pcNodeId)
		This._InvalidateEngine()

		def RemoveNode(pcNodeId)
			This.RemoveThisNode(pcNodeId)
	
	def RemoveNodeAt(pacPath)
		_nLen_ = len(pacPath)
		if _nLen_ = 0
			return
		ok
		
		_cNodeId_ = pacPath[_nLen_]
		This.RemoveThisNode(_cNodeId_)
	
		def RemoveNodeAtPath(pacPath)
			This.RemoveNodeAt(pacPath)
	
	def RemoveNodesAt(paPaths)
		_acToRemove_ = []
		_nLenPaths_ = len(paPaths)
		
		for i = 1 to _nLenPaths_
			_acPath_ = paPaths[i]
			_nLen_ = len(_acPath_)
			if _nLen_ > 0
				_cNodeId_ = StzLower(_acPath_[_nLen_])
				if StzFindFirst(_cNodeId_, _acToRemove_) = 0
					_acToRemove_ + _cNodeId_
				ok
			ok
		end
		
		This.RemoveTheseNodes(_acToRemove_)
	
		def RemoveNodesAtPaths(paPaths)
			This.RemoveNodesAt(paPaths)
	
	#----------------#
	#  EDGE REMOVAL  #
	#----------------#
	
	def RemoveEdges()
		@aEdges = []
		@aAffectedEdges = []
		This._InvalidateEngine()

		def RemoveAllEdges()
			This.RemoveEdges()
	
		def ClearEdges()
			This.RemoveEdges()
	
	def RemoveThisEdge(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId)
				_oList_ = new stzList(pcFromNodeId)
				if _oList_.IsFromNamedParam() or _oList_.IsFromNodeNamedParam()
					pcFromNodeId = pcFromNodeId[2]
				ok
			ok
			if isList(pcToNodeId)
				_oList_ = new stzList(pcToNodeId)
				if _oList_.IsToNamedParam() or _oList_.IsToNodeNamedParam()
					pcToNodeId = pcToNodeId[2]
				ok
			ok
		ok

		# Node ids (and edge from/to) are stored StzLower-normalised --
		# match the same way the rest of stzGraph does (AddEdge, the
		# edge-exists check), else a caller passing original casing
		# (e.g. stzKnowledgeGraph.RemoveFact) removes nothing.
		pcFromNodeId = StzLower(pcFromNodeId)
		pcToNodeId = StzLower(pcToNodeId)

		_acNew_ = []
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if NOT (_aEdge_["from"] = pcFromNodeId and _aEdge_["to"] = pcToNodeId)
				_acNew_ + _aEdge_
			ok
		end
		@aEdges = _acNew_
		This._InvalidateEngine()

		def RemoveEdge(pcFromNodeId, pcToNodeId)
			This.RemoveThisEdge(pcFromNodeId, pcToNodeId)

		def Disconnect(pcFromNodeId, pcToNodeId)
			This.RemoveThisEdge(pcFromNodeId, pcToNodeId)

	def RemoveEdgesConnectedTo(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		_acNew_ = []
		_nLen_ = len(@aEdges)
		
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if NOT (_aEdge_["from"] = pcNodeId or _aEdge_["to"] = pcNodeId)
				_acNew_ + _aEdge_
			ok
		end
		
		@aEdges = _acNew_

	#--------------------------------#
	#  ENABLING OR DISABLING CHECKS  #
	#--------------------------------#

	 # Control flags
	 def EnableConstraints()
	        @bEnforceConstraints = TRUE

		def EnforceConstraints()
			@bEnforceConstraints = TRUE

	 def DisableConstraints()
	        @bEnforceConstraints = FALSE

	def ConstraintsEnabled()
		return @bEnforceConstraints

	#--

	 def EnableAutoDerive()
	        @bAutoDerive = TRUE

		def EnforceAutoDerive()
			@bAutoDerive = TRUE

	 def DisableAutoDerive()
	        @bAutoDerive = FALSE

	def AutoDeriveEnabled()
		return @bAutoDerive

	# Temporarily bypass rules

	def WithoutConstraints(pFunc)
		if NOT @IsFunction(pFunc)
			stzraise("Parameter must be a function!")
		ok
	
		# Save current state
		_bOldState_ = @bEnforceConstraints
		
		# Disable constraints temporarily
		@bEnforceConstraints = FALSE
		
		# Execute the provided function
		call pFunc(This)
		
		# Restore original state
		@bEnforceConstraints = _bOldState_

	
		def BypassingConstraints(pFunc)
			This.WithoutConstraints(pFunc)
	    
	#----------------------#
	#  PRE-FLIGHT METHODS  #
	#----------------------#

	 # Pre-flight checks (non-mutating)
	def CanAddEdge(pcFrom, pcTo, pcLabel)
		if CheckParams()
			if isList(pcFrom) and IsFromOrFromNodeNamedParamList(pcFrom)
				pcFrom = pcFrom[2]
			ok
			if isList(pcTo) and IsToOrToNodeNamedParamList(pcTo)
				pcTo = pcTo[2]
			ok
			if isList(pcLabel) and IsWithOrLabelNamedParamList(pcLabel)
				pcLabel = pcLabel[2]
			ok
		ok
	
		# Basic checks
		if NOT This.NodeExists(pcFrom) or NOT This.NodeExists(pcTo)
			return FALSE
		ok
	
		if This.EdgeExists(pcFrom, pcTo)
			return FALSE
		ok
	
		# Constraint checks
		_aCheck_ = This.CheckConstraintRules([
			:from = pcFrom,
			:to = pcTo,
			:label = pcLabel
		])
	
		return _aCheck_[1]
	        
	def WhyCannotAddEdge(pcFromNodeId, pcToNodeId, pcLabel)
		if CheckParams()
			if isList(pcFromNodeId) and IsFromOrFromNodeNamedParamList(pcFromNodeId)
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and IsToOrToNodeNamedParamList(pcToNodeId)
				pcToNodeId = pcToNodeId[2]
			ok
			if isList(pcLabel) and IsWithOrLabelNamedParamList(pcLabel)
				pcLabel = pcLabel[2]
			ok
		ok
	
		pcFromNodeId = StzLower(pcFromNodeId)
		pcToNodeId = StzLower(pcToNodeId)

		# Check basic preconditions first
		if NOT This.NodeExists(pcFromNodeId)
			return "Node '" + pcFromNodeId + "' does not exist"
		ok
	
		if NOT This.NodeExists(pcToNodeId)
			return "Node '" + pcToNodeId + "' does not exist"
		ok
	
		if This.EdgeExists(pcFromNodeId, pcToNodeId)
			return "Edge already exists between '" + pcFromNodeId + "' and '" + pcToNodeId + "'"
		ok
	
		# Check constraints
		_aCheck_ = This.CheckConstraintRules([
			:from = pcFromNodeId,
			:to = pcToNodeId,
			:label = pcLabel
		])
	
		if _aCheck_[1]  # Allowed
			return "Edge can be added"
		ok
	
		# Build detailed explanation of violations
		_aViolations_ = _aCheck_[2]
		_cReasons_ = "Cannot add edge:" + NL
		
		_nLen_ = len(_aViolations_)
		for i = 1 to _nLen_
			_aV_ = _aViolations_[i]
			_cReasons_ += "  • [" + _aV_[:severity] + "] " + _aV_[:rule] + ": " + _aV_[:message] + NL
		next
	
		return _cReasons_
	
		def WhyCannotConnect(pcFromNodeId, pcToNodeId, pcLabel)
			return This.WhyCannotAddEdge(pcFromNodeId, pcToNodeId, pcLabel)

	#-------------------#
	#  EDGE OPERATIONS  #
	#-------------------#

	def AddEdge(pcFromNodeId, pcToNodeId)
		This.AddEdgeXTT(pcFromNodeId, pcToNodeId, "", [])

		def Connect(pcFromNodeId, pcToNodeId)
			if CheckParams()

				if isList(pcToNodeId) and len(pcToNodeId) = 2 and isString(pcToNodeId[1]) and StzFindFirst(StzLower(pcToNodeId[1]), ["to","tonode","tonodes","and","andnode","andnodes"]) > 0
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
		
		_nLen_ = len(paNodes)
		if _nLen_ < 2
			StzRaise("ConnectSequence requires at least 2 nodes.")
		ok
		
		for i = 1 to _nLen_ - 1
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
		
		_nLen_ = len(paNodesAndLabels)
		
		# Must be odd number: node1, label1, node2, label2, ..., nodeN
		if _nLen_ % 2 = 0
			StzRaise("List must have odd length: [node1, label1, node2, label2, ..., lastNode]")
		ok
		
		if _nLen_ < 3
			StzRaise("ConnectSequenceXT requires at least 3 items: [node1, label, node2]")
		ok
		
		# Process pairs: node, label, node
		for i = 1 to _nLen_ - 2 step 2
			_cFrom_ = paNodesAndLabels[i]
			_cLabel_ = paNodesAndLabels[i + 1]
			_cTo_ = paNodesAndLabels[i + 2]
			
			This.ConnectXT(_cFrom_, _cTo_, _cLabel_)
		end
	
		def ConnectInSequenceXT(paNodesAndLabels)
			This.ConnectSequenceXT(paNodesAndLabels)
	
		def ConnectManyXT(paNodesAndLabels)
			This.ConnectSequenceXT(paNodesAndLabels)

	def AddEdges(pcFromNodeId, pacToNodesIds)
		_nLen_ = len(pacToNodesIds)
		for i = 1 to _nLen_
			This.AddEdgeXTT(pcFromNodeId, pacToNodesIds[i], "", [])
		next

		def ConnectToMany(pcFromNodeId, pacToNodesIds)
			This.AddEdges(pcFromNodeId, pacToNodesIds)

	def AddEdgeXT(pcFromNodeId, pcToNodeId, pcLabel)
		This.AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, [])

		def ConnectXT(pcFromNodeId, pcToNodeId, pcLabel)
			This.AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, [])

	def AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, pacProperties)
		# Parameter validation
		if CheckParams()
			if isList(pcFromNodeId) and IsNodeOrNodesOrFromOrFromNodeNamedParamList(pcFromNodeId)
				pcFromNodeId = pcFromNodeId[2]
			ok
	
			if isList(pcToNodeId) and IsToOrToNodeOrAndOrAndNodeNamedParamList(pcToNodeId)
				pcToNodeId = pcToNodeId[2]
			ok
	
			if isList(pcLabel) and IsWithOrLabelNamedParamList(pcLabel)
				pcLabel = pcLabel[2]
			ok
		ok
	
		if isList(pcToNodeId)
			This.AddEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)
			return
		ok

		pcFromNodeId = StzLower(pcFromNodeId)
		pcToNodeId = StzLower(pcToNodeId)

		# Validate nodes exist
		if NOT This.NodeExists(pcFromNodeId) or NOT This.NodeExists(pcToNodeId)
			stzraise("Cannot add edge: one or both nodes do not exist!")
		ok
	
		# Check if edge already exists
		if This.EdgeExists(pcFromNodeId, pcToNodeId)
			stzraise("Edge already exists between '" + pcFromNodeId + "' and '" + pcToNodeId + "'!")
		ok
		#TODO// Should we support multiple edges between two nodes?

		# CONSTRAINT CHECK - Execute before mutation
		if @bEnforceConstraints
			_aCheck_ = This.CheckConstraintRules([
				:from = pcFromNodeId,
				:to = pcToNodeId,
				:label = pcLabel,
				:properties = pacProperties
			])
			
			if NOT _aCheck_[1]  # Blocked by constraints
				_aViolations_ = _aCheck_[2]
				_cMsg_ = "Cannot add edge - constraint violation: "
				_nLen_ = len(_aViolations_)
				for i = 1 to _nLen_
					_cMsg_ += _aViolations_[i][:message]
					if i < _nLen_
						_cMsg_ += "; "
					ok
				next
				stzraise(_cMsg_)
			ok
		ok
	
		# Normalize label
		pcLabel = _NormalizeLabel(pcLabel)
	
		# Add edge
		_aEdge_ = [
			:from = StzLower(pcFromNodeId),
			:to = StzLower(pcToNodeId),
			:label = pcLabel,
			:properties = iif(isList(pacProperties), pacProperties, [])
		]
		@aEdges + _aEdge_

		# Keep the index IN STEP with the append. Letting it go stale and
		# rebuild on the next lookup costs O(E) per added edge, which is
		# exactly the quadratic the index was added to remove.
		if @pEdgeIdx != NULL and NOT @bEdgeIdxStale
			if @nEdgeIdxCount = len(@aEdges) - 1
				StzEngineHashMapPutInt(@pEdgeIdx,
					_aEdge_[:from] + char(1) + _aEdge_[:to], len(@aEdges))
				@nEdgeIdxCount = len(@aEdges)
			ok
		ok

		# Push the edge into the LIVE engine graph rather than discarding it.
		#
		# _InvalidateEngine() makes the next query rebuild the entire engine
		# graph, node by node and edge by edge. So the loop every incremental
		# build actually runs -- add an edge, ask a question, add an edge --
		# cost O(V+E) per step. 800 edges built that way took 309.74s.
		if @pEngineGraph != NULL and NOT @bEngineStale
			_aAeP_ = _aEdge_[:properties]

			_nAeW_ = 1.0
			if isList(_aAeP_) and HasKey(_aAeP_, "weight")
				_nAeW_ = _aAeP_[:weight]
			ok

			StzEngineGraphAddEdge(@pEngineGraph, _aEdge_[:from], _aEdge_[:to], _nAeW_)

			if isList(_aAeP_) and HasKey(_aAeP_, "cost")
				StzEngineGraphSetEdgeCost(@pEngineGraph,
					_aEdge_[:from], _aEdge_[:to], _aAeP_[:cost])
			ok
		else
			This._InvalidateEngine()
		ok

		# AUTO-DERIVATION - Execute after mutation
		if @bAutoDerive
			This.ApplyDerivationRules()
		ok
		
		return 1
	
		def ConnectXTT(pcFromNodeId, pcToNodeId, pcLabel, pacProperties)
			This.AddEdgeXTT(pcFromNodeId, pcToNodeId, pcLabel, pacProperties)
	
	def AddEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)
		_nLen_ = len(paToNodesIdsAndLabelsAndProps)
		for i = 1 to _nLen_
			This.AddEdgeXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps[i])
		next

		def ConnectEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)
			This.AddEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)

	def Edge(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId)
				_oList_ = new stzList(pcFromNodeId)
				if _oList_.IsFromNamedParam() or _oList_.IsFromNodeNamedParam()
					pcFromNodeId = pcFromNodeId[2]
				ok
			ok
			if isList(pcToNodeId)
				_oList_ = new stzList(pcToNodeId)
				if _oList_.IsToNamedParam() or _oList_.IsToNodeNamedParam()
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

		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = StzLower(pcFromNodeId) and _aEdge_["to"] = StzLower(pcToNodeId)
				return _aEdge_
			ok
		end
		stzraise("Inexistant edge!")

	def EdgeExists(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId)
				_oList_ = new stzList(pcFromNodeId)
				if _oList_.IsFromNamedParam() or _oList_.IsFromNodeNamedParam()
					pcFromNodeId = pcFromNodeId[2]
				ok
			ok
			if isList(pcToNodeId)
				_oList_ = new stzList(pcToNodeId)
				if _oList_.IsToNamedParam() or _oList_.IsToNodeNamedParam()
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

		# Fold ONCE, not once per edge examined.
		_cEeFrom_ = StzLower(pcFromNodeId)
		_cEeTo_ = StzLower(pcToNodeId)

		This._EnsureEdgeIndex()

		if @pEdgeIdx != NULL
			return StzEngineHashMapHasKey(@pEdgeIdx, _cEeFrom_ + char(1) + _cEeTo_)
		ok

		# Fallback when the engine map is unavailable: the original scan,
		# with the case folding hoisted out of the loop.
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = _cEeFrom_ and _aEdge_["to"] = _cEeTo_
				return 1
			ok
		end
		return 0

		def HasEdge(pcFromNodeId, pcToNodeId)
			return This.EdgeExists(pcFromNodeId, pcToNodeId)

	# Builds the (from,to) index on demand, rebuilding when @aEdges changed.
	# char(1) is the joiner: node ids are well-formed (no spaces, no control
	# characters), so it cannot collide with a real id.
	def _EnsureEdgeIndex()
		_nEiLen_ = len(@aEdges)

		if @pEdgeIdx != NULL and @nEdgeIdxCount = _nEiLen_ and NOT @bEdgeIdxStale
			return
		ok

		if @pEdgeIdx != NULL
			StzEngineHashMapFree(@pEdgeIdx)
			@pEdgeIdx = NULL
		ok

		@pEdgeIdx = StzEngineHashMapNew()

		if @pEdgeIdx = NULL
			return
		ok

		for _iEi_ = 1 to _nEiLen_
			StzEngineHashMapPutInt(@pEdgeIdx,
				@aEdges[_iEi_]["from"] + char(1) + @aEdges[_iEi_]["to"], _iEi_)
		next

		@nEdgeIdxCount = _nEiLen_
		@bEdgeIdxStale = FALSE

	def Edges()
		return @aEdges

	def EdgesCount()
		return len(@aEdges)

		def EdgeCount()
			return len(@aEdges)

		def HowManyEdges()
			return len(@aEdges)

		def HowManyEdge()
			return len(@aEdges)

		def NumberOfEdges()
			return len(@aEdges)

	def EdgeCountBetween(pcFromNodeId, pcToNodeId)

		if CheckParams()
			if isList(pcFromNodeId) and IsFromNamedParamList(pcFromNodeId)
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and IsToNamedParamList(pcToNodeId)
				pcToNodeId = pcToNodeId[2]
			ok
		ok
	
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		_nCount_ = 0
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = StzLower(pcFromNodeId) and _aEdge_["to"] = StzLower(pcToNodeId)
				_nCount_++
			ok
		end
		return _nCount_
	
		def EdgesBetweenCount(pcFrom, pcTo)
			return This.EdgeCountBetween(pcFrom, pcTo)
	
	def EdgesBetween(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId) and IsFromNamedParamList(pcFromNodeId)
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and IsToNamedParamList(pcToNodeId)
				pcToNodeId = pcToNodeId[2]
			ok
		ok
	
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		_aResult_ = []
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = StzLower(pcFromNodeId) and _aEdge_["to"] = StzLower(pcToNodeId)
				_aResult_ + [_aEdge_["from"], _aEdge_["label"], _aEdge_["to"]]
			ok
		end
		return _aResult_
	
		def AllEdgesBetween(pcFromNodeId, pcToNodeId)
			return This.EdgesBetween(pcFromNodeId, pcToNodeId)

	def RemoveEdgeByLabel(pcFromNodeId, pcToNodeId, pcLabel)
		if CheckParams()
			if isList(pcFromNodeId) and IsFromNamedParamList(pcFromNodeId)
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and IsToNamedParamList(pcToNodeId)
				pcToNodeId = pcToNodeId[2]
			ok
			if isList(pcLabel) and IsLabelNamedParamList(pcLabel)
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
		_acNew_ = []
		_nLen_ = len(@aEdges)
		_bFound_ = FALSE
		
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = StzLower(pcFromNodeId) and _aEdge_["to"] = StzLower(pcToNodeId) and StzLower(_aEdge_["label"]) = StzLower(pcLabel) and NOT _bFound_
				_bFound_ = TRUE
				loop
			ok
			_acNew_ + _aEdge_
		end
		
		@aEdges = _acNew_
	
		def RemoveEdgeWithLabel(pcFromNodeId, pcToNodeId, pcLabel)
			This.RemoveEdgeByLabel(pcFromNodeId, pcToNodeId, pcLabel)
	
		def DisconnectByLabel(pcFromNodeId, pcToNodeId, pcLabel)
			This.RemoveEdgeByLabel(pcFromNodeId, pcToNodeId, pcLabel)
	
	def RemoveAllEdgesBetween(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId) and IsFromNamedParamList(pcFromNodeId)
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and IsToNamedParamList(pcToNodeId)
				pcToNodeId = pcToNodeId[2]
			ok
		ok
	
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		_acNew_ = []
		_nLen_ = len(@aEdges)
		
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if NOT (_aEdge_["from"] = StzLower(pcFromNodeId) and _aEdge_["to"] = StzLower(pcToNodeId))
				_acNew_ + _aEdge_
			ok
		end
		
		@aEdges = _acNew_
	
		def RemoveEdgesBetween(pcFromNodeId, pcToNodeId)
			This.RemoveAllEdgesBetween(pcFromNodeId, pcToNodeId)
	
		def DisconnectAll(pcFromNodeId, pcToNodeId)
			This.RemoveAllEdgesBetween(pcFromNodeId, pcToNodeId)

	#-------------------------------------------#
	#  BATCH UPDATE OPERATIONS USING FUNCTIONS  #
	#-------------------------------------------#
	
	def UpdateNodesF(pFunc)
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			call pFunc(@aNodes[i])
		end

		def UpdateNodes(pFunc)
			This.UpdateNodesF(pFunc)
	
	def UpdateEdgesF(pFunc)
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			call pFunc(@aEdges[i])
		end

		def UpdateEdges(pFunc)
			This.UpdateEdgesF(pFunc)

	#-------------------#
	#  COPY OPERATIONS  #
	#-------------------#
	
	def CopyNode(pcNodeId)
		_aNode_ = This.Node(pcNodeId)
		_aCopy_ = [
			:id = _aNode_["id"],
			:label = _aNode_["label"],
			:properties = []
		]
		
		if HasKey(_aNode_, "properties")
			_acKeys_ = keys(_aNode_["properties"])
			_nLen_ = len(_acKeys_)
			for i = 1 to _nLen_
				_aCopy_["properties"][_acKeys_[i]] = _aNode_["properties"][_acKeys_[i]]
			end
		ok
		
		return _aCopy_
	
	def DuplicateNode(pcNodeId, pcNewId)
		_aCopy_ = This.CopyNode(pcNodeId)
		_aCopy_["id"] = pcNewId
		This.AddNodeXTT(_aCopy_["id"], _aCopy_["label"], _aCopy_["properties"])
	
		def CloneNode(pcNodeId, pcNewId)
			This.DuplicateNode(pcNodeId, pcNewId)
	
	def DuplicateNodeWithEdges(pcNodeId, pcNewId)
		This.DuplicateNode(pcNodeId, pcNewId)
		
		_aEdges_ = This.Edges()
		_nLen_ = len(_aEdges_)
		for i = 1 to _nLen_
			if _aEdges_[i]["from"] = StzLower(pcNodeId)
				This.AddEdgeXTT(pcNewId, _aEdges_[i]["to"], _aEdges_[i]["label"], _aEdges_[i]["properties"])
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
		
		_aIncoming_ = []
		_aOutgoing_ = []
		
		_nNodeLen_ = len(pacNodeIds)
		_nEdgeLen_ = len(@aEdges)
		
		for i = 1 to _nNodeLen_
			_cNodeId_ = pacNodeIds[i]
			
			for j = 1 to _nEdgeLen_
				_aEdge_ = @aEdges[j]
				
				if _aEdge_["to"] = _cNodeId_
					if StzFindFirst(_aEdge_["from"], _aIncoming_) = 0 and StzFindFirst(_aEdge_["from"], pacNodeIds) = 0
						_aIncoming_ + _aEdge_["from"]
					ok
				ok
				
				if _aEdge_["from"] = _cNodeId_
					if StzFindFirst(_aEdge_["to"], _aOutgoing_) = 0 and StzFindFirst(_aEdge_["to"], pacNodeIds) = 0
						_aOutgoing_ + _aEdge_["to"]
					ok
				ok
			end
		end
		
		This.RemoveTheseNodes(pacNodeIds)
		This.AddNodeXTT(pcNewId, pcNewLabel, paNewProps)
		
		_nLen_ = len(_aIncoming_)
		for i = 1 to _nLen_
			This.Connect(_aIncoming_[i], pcNewId)
		end
		
		_nLen_ = len(_aOutgoing_)
		for i = 1 to _nLen_
			This.Connect(pcNewId, _aOutgoing_[i])
		end
	
		def CombineNodes(pacNodeIds, pcNewId, pcNewLabel)
			This.MergeNodes(pacNodeIds, pcNewId, pcNewLabel)

	def SplitNode(pcNodeId, pcNewId1, pcNewId2)
		_aNode_ = This.Node(pcNodeId)
		
		_acIncoming_ = This.Incoming(pcNodeId)
		_acOutgoing_ = This.Neighbors(pcNodeId)
		
		This.AddNodeXT(pcNewId1, _aNode_["label"] + " (1)")
		This.AddNodeXT(pcNewId2, _aNode_["label"] + " (2)")
		
		_nLen_ = len(_acIncoming_)
		for i = 1 to _nLen_
			This.Connect(_acIncoming_[i], pcNewId1)
			This.Connect(_acIncoming_[i], pcNewId2)
		end
		
		_nLen_ = len(_acOutgoing_)
		for i = 1 to _nLen_
			This.Connect(pcNewId1, _acOutgoing_[i])
			This.Connect(pcNewId2, _acOutgoing_[i])
		end
		
		This.RemoveThisNode(pcNodeId)

	#----------------------------#
	#  MANAGING NODE PROPERTIES  #
	#----------------------------#

	def Properties()
		if NOT isList(@aNodes) or len(@aNodes) = 0
			return []
		ok
		
		_acAllProps_ = []
		_nLen_ = len(@aNodes)
		
		for i = 1 to _nLen_
			if HasKey(@aNodes[i], "properties") and isList(@aNodes[i]["properties"])
				_acKeys_ = keys(@aNodes[i]["properties"])
				_nKeyLen_ = len(_acKeys_)
				for j = 1 to _nKeyLen_
					if StzFindFirst(_acAllProps_, _acKeys_[j]) = 0
						_acAllProps_ + _acKeys_[j]
					ok
				end
			ok
		end
		
		return _acAllProps_
	
		def Props()
			return This.Properties()

	def PropertiesXT()
		_aResult_ = []
		_aNodes_ = This.Nodes()
		_nLen_ = len(_aNodes_)
		
		for i = 1 to _nLen_
			if HasKey(_aNodes_[i], "properties")
				_aProps_ = _aNodes_[i]["properties"]
				_acKeys_ = keys(_aProps_)
				_nKeyLen_ = len(_acKeys_)
				
				for j = 1 to _nKeyLen_
					_cKey_ = _acKeys_[j]
					pValue = _aProps_[_cKey_]
					
					_nFound_ = 0
					_nResultLen_ = len(_aResult_)
					for k = 1 to _nResultLen_
						if _aResult_[k][1] = _cKey_
							_nFound_ = k
							exit
						ok
					end
					
					if _nFound_ > 0
						if StzFindFirst(pValue, _aResult_[_nFound_][2]) = 0
							_aResult_[_nFound_][2] + pValue
						ok
					else
						_aResult_ + [_cKey_, [pValue]]
					ok
				end
			ok
		end
		
		return _aResult_
	
		def PropsXT()
			return This.PropertiesXT()
	
		def PropsAndTheirValues()
			return This.PropertiesXT()

	# The label a node SHOWS, as opposed to the id it is known by.
	#
	# A node could only ever be labelled at birth, via AddNodeXT(id, label);
	# there was no way to say it afterwards, and no way to ask. So a format
	# that reads a node first and learns its label a line later (.stzsim's
	# `add node X` / `label: "..."`) had nowhere to put it.

	def SetNodeLabel(pcNodeId, pcLabel)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		# Same normalisation AddNodeXTT applies: a label carries no spaces
		# and no newlines. A label set here must obey the class's own rule,
		# not a looser one.
		_cLbl_ = _NormalizeLabel("" + pcLabel)

		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			if @aNodes[i]["id"] = pcNodeId
				@aNodes[i]["label"] = _cLbl_
				_aTemp_ = @aNodes[i]
				@aNodes[i] = _aTemp_
				return
			ok
		end

		stzraise("Node '" + pcNodeId + "' does not exist.")

	def NodeLabel(pcNodeId)
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			if @aNodes[i]["id"] = pcNodeId
				return @aNodes[i]["label"]
			ok
		end

		stzraise("Node '" + pcNodeId + "' does not exist.")

	def SetNodeProperty(pcNodeId, cProperty, pValue)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok
		
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			if @aNodes[i]["id"] = pcNodeId
				if NOT HasKey(@aNodes[i], "properties")
					@aNodes[i]["properties"] = []
				ok
				@aNodes[i]["properties"][cProperty] = pValue
				_aTemp_ = @aNodes[i]
				@aNodes[i] = _aTemp_
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
		
		_nLen_ = len(aProperties)
		for i = 1 to _nLen_
			This.SetNodeProperty(pcNodeId, aProperties[i][1], aProperties[i][2])
		end
	
		def SetNodeProps(pcNodeId, aProperties)
			This.SetNodeProperties(pcNodeId, aProperties)

	def NodeProperties(pcNodeId)
		_aNode_ = This.Node(pcNodeId)

		if HasKey(_aNode_, "properties")
			return keys(_aNode_["properties"])
		ok
		return []
	
		def NodeProps(pcNodeId)
			return This.NodeProperties(pcNodeId)

	def NodePropertiesXT(pcNodeId)
		_aNode_ = This.Node(pcNodeId)
		if HasKey(_aNode_, "properties")
			return _aNode_["properties"]
		ok
		return []
	
		def NodePropertiesAndTheirValues(pcNodeId)
			return This.NodePropertiesXT(pcNodeId)

		def NodePropsXT(pcNodeId)
			return This.NodePropertiesXT(pcNodeId)

		def NodePropsAndTheirValues(pcNodeId)
			return This.NodePropertiesXT(pcNodeId)

	def NodeProperty(pcNodeId, cProperty)
		_aNode_ = This.Node(pcNodeId)
	
		if HasKey(_aNode_, "properties") and HasKey(_aNode_["properties"], cProperty)
			return _aNode_["properties"][cProperty]
		ok
	
		def NodeProp(pcNodeId, cProperty)
			return This.NodeProperty(pcNodeId, cProperty)

	def RemoveNodeProperties(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
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
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			@aNodes[i]["properties"] = []
		end
		
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			@aEdges[i]["properties"] = []
		end
	
		def ClearAllProperties()
			This.RemoveAllProperties()

	def SetEdgeProperty(pFromNodeId, pToNodeId, cProperty, pValue)
		if CheckParams()
			if isList(pFromNodeId)
				_oList_ = new stzList(pFromNodeId)
				if _oList_.IsFromNamedParam() or _oList_.IsFromNodeNamedParam()
					pFromNodeId = pFromNodeId[2]
				ok
			ok
			if isList(pToNodeId)
				_oList_ = new stzList(pToNodeId)
				if _oList_.IsToNamedParam() or _oList_.IsToNodeNamedParam()
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

		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
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
		_aEdge_ = This.Edge(pFromNodeId, pToNodeId)
		
		if HasKey(_aEdge_, "properties") and HasKey(_aEdge_["properties"], cProperty)
			return _aEdge_["properties"][cProperty]
		else
			stzraise("This edge propert (' + cProperty + ') does not exist!")
		ok

		def EdgeProp(pFromNodeId, pToNodeId, cProperty)
			return This.EdgeProperty(pFromNodeId, pToNodeId, cProperty)

	def SetEdgeProperties(pcFromNodeId, pcToNodeId, aProperties)
		if CheckParams()
			if isList(pcFromNodeId)
				_oList_ = new stzList(pcFromNodeId)
				if _oList_.IsFromNamedParam() or _oList_.IsFromNodeNamedParam()
					pcFromNodeId = pcFromNodeId[2]
				ok
			ok
			if isList(pcToNodeId)
				_oList_ = new stzList(pcToNodeId)
				if _oList_.IsToNamedParam() or _oList_.IsToNodeNamedParam()
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
		
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			if @aEdges[i]["from"] = pcFromNodeId and @aEdges[i]["to"] = pcToNodeId
				if NOT HasKey(@aEdges[i], "properties")
					@aEdges[i] + ["properties", []]
				ok
				
				_acKeys_ = keys(aProperties)
				_nKeyLen_ = len(_acKeys_)
				for j = 1 to _nKeyLen_
					@aEdges[i]["properties"][_acKeys_[j]] = aProperties[_acKeys_[j]]
				end
				return
			ok
		end
	
		def SetEdgeProps(pcFromNodeId, pcToNodeId, aProperties)
			This.SetEdgeProperties(pcFromNodeId, pcToNodeId, aProperties)

	def EdgeProperties(pcFromNodeId, pcToNodeId)
		_aEdge_ = This.Edge(pcFromNodeId, pcToNodeId)
		if HasKey(_aEdge_, "properties")
			return keys(_aEdge_["properties"])
		ok
		return []
	
		def EdgeProps(pcFromNodeId, pcToNodeId)
			return This.EdgeProperties(pcFromNodeId, pcToNodeId)

	def EdgePropertiesXT(pcFromNodeId, pcToNodeId)
		_aEdge_ = This.Edge(pcFromNodeId, pcToNodeId)
		if HasKey(_aEdge_, "properties")
			return _aEdge_["properties"]
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

		if This._EnsureEngine()
			return StzEngineGraphPathExists(@pEngineGraph, StzLower(pcFromNodeId), StzLower(pcToNodeId))
		ok

		_acVisited_ = []
		return This._PathExistsDFS(pcFromNodeId, pcToNodeId, _acVisited_)

	def _PathExistsDFS(pcCurrent, pcTarget, pacVisited)
		if pcCurrent = pcTarget
			return 1
		ok

		if StzFindFirst(pcCurrent, pacVisited) > 0
			return 0
		ok

		pacVisited + pcCurrent

		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = pcCurrent
				if This._PathExistsDFS(_aEdge_["to"], pcTarget, pacVisited)
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
		_nLen_ = len(@aNodes)
		if _nLen_ = 0
			stzraise("Can't obtain a first node. The graphs contains no nodes at all!")
		ok
		return @aNodes[_nLen_]

	def LastNodeId()
		return This.LastNode()[:id]

	def NthNode(n)
		if not isNumber(n)
			stzraise("Incorrect param type! n must be a number.")
		ok

		return @aNodes[n]

		def NodeAt(n)
			return This.NthNode(n)

		def NodeAtPosition(n)
			return This.NthNode(n)

	def NodePosition(pcNodeId)
		return StzFindFirst(StzLower(pcNodeId), This.NodesIds())

	#--

	def FindNode(pcNodeId)
		return This.PathsXT(This.FirstNodeId(), pcNodeId)

		def PathsTo(pcNodeId)
			if CheCkParams()
				if isList(pcNodeId) and IsNodeNamedParamList(pcNodeId)
					pcNodeId = pcNodeId[2]
				ok
			ok

			return This.FindNode(pcNodeId)

		def PathsToNode(pcNodeId)
			return This.FindNode(pcNodeId)

	#--

	def Paths()

		# All simple paths between every ORDERED pair of nodes
		# (S0, 2026-07-14: was raising "Not yet implemented!"; this also
		# revives PathsWhereF which folds over it. NOTE: all-simple-paths
		# enumeration is exponential by nature -- fine for the small/mid
		# graphs the API targets.)

		_acAll_ = []
		_acIds_ = This.NodesIds()
		_nIds_ = len(_acIds_)

		for _i_ = 1 to _nIds_
			for _j_ = 1 to _nIds_
				if _i_ != _j_
					_acPairPaths_ = This.PathsXT(_acIds_[_i_], _acIds_[_j_])
					_nPair_ = len(_acPairPaths_)
					for _k_ = 1 to _nPair_
						_acAll_ + _acPairPaths_[_k_]
					next
				ok
			next
		next

		return _acAll_

	def PathsXT(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId) and IsFromOrFromNodeNamedParamList(pcFromNodeId)
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and IsToOrToNodeOrAndNamedParamList(pcToNodeId)
				pcToNodeId = pcToNodeId[2]
			ok
		ok
		if NOT _IsWellFormedId(pcFromNodeId)
			stzraise("Incorrect Id! pcFromNodeId must be one string without spaces.")
		ok

		if NOT _IsWellFormedId(pcToNodeId)
			stzraise("Incorrect Id! pcToNodeId must be one string without spaces.")
		ok

		_acAllPaths_ = []
		_acCurrentPath_ = [pcFromNodeId]
		This._FindAllPathsDFS(pcFromNodeId, pcToNodeId, _acCurrentPath_, _acAllPaths_, 0)
		return _acAllPaths_

		def PathsBetweenXT(pcFromNodeId, pcToNodeId)
			return This.PathsXT(pcFromNodeId, pcToNodeId)

	def Path(pcFromNodeId, pcToNodeId)
		_acPaths_ = This.PathsXT(pcFromNodeId, pcToNodeId)
		if len(_acPaths_) > 0
			return _acPaths_[1]
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
	
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = pcCurrent
				_cNext_ = _aEdge_["to"]

				if StzFindFirst(_cNext_, pacCurrentPath) = 0
					# Thread a fresh copy down the branch instead of
					# mutate-then-backtrack. Two reasons:
					#  (1) the old backtrack used stzleft() -- a STRING
					#      op -- on a list, which panicked the string
					#      engine (@intFromFloat out of bounds);
					#  (2) Ring passes lists by reference, so appending
					#      to the shared path and later storing it in
					#      pacAllPaths aliased every stored path. A
					#      per-branch copy makes each stored path its own.
					_aNextPath_ = []
					_nCur_ = len(pacCurrentPath)
					for _j_ = 1 to _nCur_
						_aNextPath_ + pacCurrentPath[_j_]
					next
					_aNextPath_ + _cNext_
					This._FindAllPathsDFS(_cNext_, pcTarget, _aNextPath_, pacAllPaths, pnDepth + 1)
				ok
			ok
		end

	def Neighbors(pcNodeId)

		if CheckParams()
			if isList(pcNodeId) and IsOfOrToNamedParamList(pcNodeId)
				pcNodeId = pcNodeId[2]
			ok
		ok

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		if This._EnsureEngine()
			_cEngResult_ = StzEngineGraphNeighbors(@pEngineGraph, StzLower(pcNodeId))
			return _cEngResult_
		ok

		# Edge from/to are StzLower-normalised; the engine path above
		# already lowercases, so the pure-Ring fallback must too -- else
		# Neighbors("A") finds nothing while Neighbors("a") works.
		_cFrom_ = StzLower(pcNodeId)
		_acNeighbors_ = []
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = _cFrom_
				_acNeighbors_ + _aEdge_["to"]
			ok
		end
		return _acNeighbors_

		def NeighborsTo(pcNodeId)
			return This.Neighbors(pcNodeId)

		def NeighborsOf(pcNodeId)
			return This.Neighbors(pcNodeId)

	def Incoming(pcNodeId)
		if CheckParams()
			if isList(pcNodeId) and IsToNamedParamList(pcNodeId)
				pcNodeId = pcNodeId[2]
			ok
		ok

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		_acIncoming_ = []
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["to"] = pcNodeId
				_acIncoming_ + _aEdge_["from"]
			ok
		end
		return _acIncoming_

		def IncomingTo(pcNodeId)
			return This.Incoming(pcNodeId)

	#-------------------#
	#  CYCLE DETECTION  #
	#-------------------#

	def HasCyclicDependencies()

		if This._EnsureEngine()
			return StzEngineGraphHasCycle(@pEngineGraph)
		ok

		_acVisited_ = []
		_acRecStack_ = []

		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			if StzFindFirst(_acVisited_, _aNode_["id"]) = 0
				if This._HasCycleDFS(_aNode_["id"], _acVisited_, _acRecStack_)
					return 1
				ok
			ok
		end

		return 0

	def _HasCycleDFS(pcNode, pacVisited, pacRecStack)
		pacVisited + pcNode
		pacRecStack + pcNode

		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = pcNode

				if StzFindFirst(_aEdge_["to"], pacVisited) = 0
					if This._HasCycleDFS(_aEdge_["to"], pacVisited, pacRecStack)
						return 1
					ok

				but StzFindFirst(_aEdge_["to"], pacRecStack) > 0
					return 1
				ok
			ok
		end

		_nLen_ = len(pacRecStack)
		if _nLen_ > 1
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

		if This._EnsureEngine()
			_cEngResult_ = StzEngineGraphReachable(@pEngineGraph, StzLower(pcNodeId))
			return _cEngResult_
		ok

		_acReachable_ = []
		_acVisited_ = []
		_acQueue_ = [pcNodeId]
		_acVisited_ + pcNodeId
		_nQueueIdx_ = 1
	
		while _nQueueIdx_ <= len(_acQueue_)
			_cCurrent_ = _acQueue_[_nQueueIdx_]
			_acReachable_ + _cCurrent_
			
			_acNeighbors_ = This.Neighbors(_cCurrent_)
			_nLen_ = len(_acNeighbors_)
			for i = 1 to _nLen_
				_cNeighbor_ = _acNeighbors_[i]

				if StzFindFirst(_cNeighbor_, _acVisited_) = 0
					_acVisited_ + _cNeighbor_
					_acQueue_ + _cNeighbor_
				ok
			end
			
			_nQueueIdx_ += 1
		end
		
		return _acReachable_

		def ReachableFromNode(pcNodeId)
			return This.ReachableFrom(pcNodeId)

	#--------------------#
	#  ANALYSIS METRICS  #
	#--------------------#

	def BottleneckNodes()
		_acBottlenecks_ = []
		_nTotalDegree_ = 0
		
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_nIncoming_ = len(This.Incoming(_aNode_["id"]))
			_nOutgoing_ = len(This.Neighbors(_aNode_["id"]))
			_nTotalDegree_ += _nIncoming_ + _nOutgoing_
		end
		
		_nAvgDegree_ = _nTotalDegree_ / len(@aNodes)
		
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_nIncoming_ = len(This.Incoming(_aNode_["id"]))
			_nOutgoing_ = len(This.Neighbors(_aNode_["id"]))
			_nDegree_ = _nIncoming_ + _nOutgoing_
			
			if _nDegree_ > _nAvgDegree_
				_acBottlenecks_ + _aNode_["id"]
			ok
		end
		
		return _acBottlenecks_

	#---

	def NodeDensity()
		_nNodes_ = len(@aNodes)
		_nEdges_ = len(@aEdges)

		if _nNodes_ <= 1
			return 0
		ok

		_nMaxEdges_ = _nNodes_ * (_nNodes_ - 1)
		return _nEdges_ / _nMaxEdges_

		def NodeDensity01()
			return This.NodeDensity()

		def Density()
			return This.NodeDensity()

		def Density01()
			return This.NodeDensity()

		#--

		def DirectedNodeDensity()
			return This.NodeDensity()

		def DirectedNodeDensity01()
			return This.NodeDensity()

		def DirectedDensity()
			return This.NodeDensity()

		def DirectedDensity01()
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

		#--

		def DirectedNodeDensity100()
			return This.NodeDensity100()

		def DirectedNodeDensityPercent()
			return This.NodeDensity100()

		def DirectedNodeDensityInPercentage()
			return This.NodeDensity100()

		def DirectedNodeDensityInPercent()
			return This.NodeDensity100()

		def DirectedDensity100()
			return This.NodeDensity100()

	#---

	def UndirectedNodeDensity()
		_nNodes_ = len(@aNodes)
		_nEdges_ = len(@aEdges)

		if _nNodes_ <= 1
			return 0
		ok

		_nMaxEdges_ = (_nNodes_ * (_nNodes_ - 1)) / 2
		return _nEdges_ / _nMaxEdges_

		def UndirectedNodeDensity01()
			return This.UndirectedNodeDensity()

		def UndirectedDensity()
			return This.UndirectedNodeDensity()

		def UndirectedDensity01()
			return This.UndirectedNodeDensity()

	def UndirectedNodeDensity100()
		return This.UndirectedNodeDensity() * 100

		def UndirectedNodeDensityPercent()
			return This.UndirectedNodeDensity100()

		def UndirectedNodeDensityInPercentage()
			return This.UndirectedNodeDensity100()

		def UndirectedNodeDensityInPercent()
			return This.UndirectedNodeDensity100()

		def UndirectedDensity100()
			return This.UndirectedNodeDensity100()

	#--

	def IsSparse()
		return This.Density() < 0.5
	
	def IsDense()
		return This.Density() >= 0.5
	
	def DensityCategory()
		_nDensity_ = This.Density()
		
		if _nDensity_ = 0
			return "empty"
		but _nDensity_ < 0.25
			return "very sparse"
		but _nDensity_ < 0.5
			return "sparse"
		but _nDensity_ < 0.75
			return "dense"
		else
			return "very dense"
		ok
	
		def DensityLevel()
			return This.DensityCategory()

	def LongestPath()
		_nMax_ = 0

		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_acReachable_ = This.ReachableFrom(_aNode_["id"])
			_nLength_ = len(_acReachable_) - 1

			if _nLength_ > _nMax_
				_nMax_ = _nLength_
			ok
		end

		return _nMax_

	def CyclicNodes()
		_acCyclicNodes_ = []
		
		_acNodes_ = This.Nodes()
		_nLen_ = len(_acNodes_)

		for i = 1 to _nLen_
			_aNode_ = _acNodes_[i]
			_cNodeId_ = _aNode_["id"]
			_acReachableFromNode_ = This.ReachableFromNode(_cNodeId_)
			
			# Remove starting node from reachable set
			_acReachableWithoutStart_ = []
			_nLen2_ = len(_acReachableFromNode_)
			for j = 1 to _nLen2_
				_cReachable_ = _acReachableFromNode_[j]
				if _cReachable_ != _cNodeId_
					_acReachableWithoutStart_ + _cReachable_
				ok
			next
			
			# If the node can reach itself through other nodes, it's in a cycle
			if StzFindFirst(_cNodeId_, _acReachableWithoutStart_) > 0
				if StzFindFirst(_cNodeId_, _acCyclicNodes_) = 0
					_acCyclicNodes_ + _cNodeId_
				ok
			ok
		next

		return _acCyclicNodes_

	#---------------------------------------#
	#  1. INDEPENDENCE AND PARALLELIZATION  #
	#---------------------------------------#

	def ParallelizableBranches()
		_acBranches_ = []
		_nLen_ = len(@aNodes)
		
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cNodeId_ = _aNode_["id"]
			_acNeighbors_ = This.Neighbors(_cNodeId_)
			
			if len(_acNeighbors_) > 1
				_nNeighborLen_ = len(_acNeighbors_)
				for j = 1 to _nNeighborLen_
					_cNeighbor1_ = _acNeighbors_[j]
					_acReachable1_ = This.ReachableFrom(_cNeighbor1_)
					
					for k = j + 1 to _nNeighborLen_
						_cNeighbor2_ = _acNeighbors_[k]
						_acReachable2_ = This.ReachableFrom(_cNeighbor2_)
						
						_acReachable1Clean_ = []
						_acReachable2Clean_ = []
						
						_nLen1_ = len(_acReachable1_)
						for m = 1 to _nLen1_
							if _acReachable1_[m] != _cNeighbor1_
								_acReachable1Clean_ + _acReachable1_[m]
							ok
						end
						
						_nLen2_ = len(_acReachable2_)
						for m = 1 to _nLen2_
							if _acReachable2_[m] != _cNeighbor2_
								_acReachable2Clean_ + _acReachable2_[m]
							ok
						end
						
						_bDisjoint_ = 1
						_nCheck_ = len(_acReachable1Clean_)
						for m = 1 to _nCheck_
							if StzFindFirst(_acReachable2Clean_, _acReachable1Clean_[m]) > 0
								_bDisjoint_ = 0
								exit
							ok
						end
						
						if _bDisjoint_
							_acBranches_ + [_cNeighbor1_, _cNeighbor2_]
						ok
					end
				end
			ok
		end
		
		return _acBranches_

		def ParaBranches()
			return This.ParallelizableBranches()

	def DependencyFreeNodes()
		_acDependencyFree_ = []
		_nLen_ = len(@aNodes)
		
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cNodeId_ = _aNode_["id"]
			_acIncoming_ = This.Incoming(_cNodeId_)
			
			if len(_acIncoming_) = 0
				_acDependencyFree_ + _cNodeId_
			ok
		end
		
		return _acDependencyFree_

	#-----------------------------#
	#  2. CRITICALITY AND IMPACT  #
	#-----------------------------#

	def ImpactOf(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		
		_acReachable_ = This.ReachableFrom(pcNodeId)
		return len(_acReachable_) - 1
	
	def FailureScope(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return []
		ok
		
		_acReachable_ = This.ReachableFrom(pcNodeId)
		_acScope_ = []
		
		_nLen_ = len(_acReachable_)
		for i = 1 to _nLen_
			_cNode_ = _acReachable_[i]
			if _cNode_ != pcNodeId
				_acScope_ + _cNode_
			ok
		end
	
		return _acScope_

	def NodeCriticality()
		_acCriticality_ = []
		_nLen_ = len(@aNodes)
		
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cNodeId_ = _aNode_["id"]
			_nIncoming_ = len(This.Incoming(_cNodeId_))
			_nOutgoing_ = len(This.Neighbors(_cNodeId_))
			_nTotalDegree_ = _nIncoming_ + _nOutgoing_
			
			_acCriticality_ + [
				:id = _cNodeId_,
				:criticality = _nTotalDegree_
			]
		end
		
		return _acCriticality_

	def MostCriticalNodes(pnCount)
		if isNULL(pnCount)
			pnCount = 5
		ok
		
		_acCriticality_ = This.NodeCriticality()
		_nLen_ = len(_acCriticality_)
		
		for i = 1 to _nLen_ - 1
			_nMaxIdx_ = i
			for j = i + 1 to _nLen_
				if _acCriticality_[j]["criticality"] > _acCriticality_[_nMaxIdx_]["criticality"]
					_nMaxIdx_ = j
				ok
			end
			
			if _nMaxIdx_ != i
				_aTemp_ = _acCriticality_[i]
				_acCriticality_[i] = _acCriticality_[_nMaxIdx_]
				_acCriticality_[_nMaxIdx_] = _aTemp_
			ok
		end
	
		_acResult_ = []
		_nLimit_ = @Min([pnCount, _nLen_])
		for i = 1 to _nLimit_
			_acResult_ + _acCriticality_[i]["id"]
		end
		
		return _acResult_

	#-------------------------------------------------#
	#  RICH QUERYING - BASED ON stzGraphFinder CLASS  #
	#-------------------------------------------------#

	# Opens a rich query on the graph. The finder is an OBJECT, so it
	# carries the Q -- there is no data-shaped twin of a query builder.
	def FindQ(pcWhat)
		return new stzGraphFinder(This, pcWhat)

	def NodesByType(pcType)
		return This.FindQ("nodes").Where("type", "=", pcType).Run()

	#--

	def NodesWhere(pcProp, pcOp, pVal)
		return This.FindQ("nodes").Where(pcProp, pcOp, pVal).Run()

		def NodesW(pcProp, pcOp, pVal)
			return This.NodesWhere(pcProp, pcOp, pVal)

	def NodesByProperty(pcProp, pVal)
		return This.FindQ("nodes").Where(pcProp, "=", pVal).Run()

	def EdgesWhere(pcProp, pcOp, pVal)
		return This.FindQ("edges").Where(pcProp, pcOp, pVal).Run()

		def EdgesW(pcProp, pcOp, pVal)
			return This.EdgesWhere(pcProp, pcOp, pVal)

	def EdgesByProperty(pcProp, pVal)
		return This.FindQ("edges").Where(pcProp, "=", pVal).Run()

	#--

	def NodesWhereF(pFunc)

		if NOT @IsFunction(pFunc)
			stzraise("Can't proceed! pFunc must be a valid function.")
		ok

		_acResult_ = []
		_nLen_ = len(@aNodes)

		for i = 1 to _nLen_
			_bMatched_ = call pFunc(@aNodes[i])
			if _bMatched_
				_acResult_ + @aNodes[i][:id]
			ok
		next

		return _acResult_

		def NodesWF(pFunc)
			return This.NodesWhereF(pFunc)

	def EdgesWhereF(pFunc)

		if NOT @IsFunction(pFunc)
			stzraise("Can't proceed! pFunc must be a valid function.")
		ok

		_acResult_ = []
		_nLen_ = len(@aEdges)

		for i = 1 to _nLen_
			_bMatched_ = call pFunc(@aEdges[i])
			if _bMatched_
				_acResult_ + [ @aEdges[i][:from], @aEdges[i][:to] ]
			ok
		next

		return _acResult_

		def EdgesWF(pFunc)
			return This.EdgesWhereF(pFunc)


	def PathsWhereF(pFunc)

		if NOT @IsFunction(pFunc)
			stzraise("Can't proceed! pFunc must be a valid function.")
		ok

		_acResult_ = []
		_acPaths_ = This.Paths()
		_nLen_ = len(_acPaths_)

		for i = 1 to _nLen_
			_bMatched_ = call pFunc(_acPaths_[i])
			if _bMatched_
				_acResult_ + _acPaths_[i]
			ok
		next

		return _acResult_

		def PathsWF(pFunc)
			return This.PathsWhereF(pFunc)

	#---------------------------------------------------#
	#  ADVANCED QURYIES - BASED ON stzGraphQuery class  #
	#---------------------------------------------------#

	def QueryQ()
		return new stzGraphQuery(This)

	#--------------------#
	#  GRAPH ALGORITHMS  #
	#--------------------#

	def ShortestPath(pcFromNodeId, pcToNodeId)
		if CheckParams()
			if isList(pcFromNodeId) and IsFromNamedParamList(pcFromNodeId)
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and IsToNamedParamList(pcToNodeId)
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

		if This._EnsureEngine()
			_cEngResult_ = StzEngineGraphShortestPath(@pEngineGraph, StzLower(pcFromNodeId), StzLower(pcToNodeId))
			_aEngPath_ = _cEngResult_
			if len(_aEngPath_) > 0
				return _aEngPath_
			ok
			# Engine returned no path -- fall through to the BFS
			# fallback below so a path that exists in the in-memory
			# edges still gets found.
		ok

		# BFS works against lowercased ids because Neighbors() and
		# the edge store use StzLower internally. Lowercase the
		# bounds so the equality check at the destination hits.
		_cFromId_ = StzLower(pcFromNodeId)
		_cToId_   = StzLower(pcToNodeId)

		_acQueue_ = [ _cFromId_ ]
		_acVisited_ = [ _cFromId_ ]
		_aParentMap_ = [ [ _cFromId_, "" ] ]

		while len(_acQueue_) > 0
			_cCurrent_ = _acQueue_[1]
			del(_acQueue_, 1)

			if _cCurrent_ = _cToId_
				_acPath_ = []
				_cNode_ = _cToId_
				
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

				if StzFindFirst(_cNeighbor_, _acVisited_) = 0
					_acVisited_ + _cNeighbor_
					_acQueue_ + _cNeighbor_
					_aParentMap_ + [_cNeighbor_, _cCurrent_]
				ok
			end
		end
	
		return []

	# Breadth-first visit order from a node (engine-backed).
	def BFS(pcNodeId)
		if isList(pcNodeId) and IsFromNamedParamList(pcNodeId)
			pcNodeId = pcNodeId[2]
		ok
		if NOT This.NodeExists(pcNodeId)
			return []
		ok
		if This._EnsureEngine()
			return StzEngineGraphBFS(@pEngineGraph, StzLower(pcNodeId))
		ok
		return []

		def BreadthFirst(pcNodeId)
			return This.BFS(pcNodeId)

	# Depth-first visit order from a node (engine-backed).
	def DFS(pcNodeId)
		if isList(pcNodeId) and IsFromNamedParamList(pcNodeId)
			pcNodeId = pcNodeId[2]
		ok
		if NOT This.NodeExists(pcNodeId)
			return []
		ok
		if This._EnsureEngine()
			return StzEngineGraphDFS(@pEngineGraph, StzLower(pcNodeId))
		ok
		return []

		def DepthFirst(pcNodeId)
			return This.DFS(pcNodeId)

	# TRUE if the graph is 2-colourable (bipartite). Engine-backed.
	def IsBipartite()
		if This._EnsureEngine()
			return StzEngineGraphIsBipartite(@pEngineGraph) = 1
		ok
		return FALSE

	# Strongly connected components (directed) as a list of node-id groups.
	# Two nodes share a group iff each is reachable from the other. Engine
	# (Kosaraju). Returns [] if the engine is unavailable.
	def StronglyConnectedComponents()
		if This._EnsureEngine()
			# The engine bridge builds the grouped list (list of node-id
			# lists) entirely Zig-side -- returned ready, no Ring looping.
			return StzEngineGraphStronglyConnectedComponents(@pEngineGraph)
		ok
		return []

		def SCC()
			return This.StronglyConnectedComponents()

	# Number of strongly connected components. Engine-backed.
	def NumberOfStronglyConnectedComponents()
		if This._EnsureEngine()
			return StzEngineGraphNumberOfSCC(@pEngineGraph)
		ok
		return 0

		def NumberOfSCC()
			return This.NumberOfStronglyConnectedComponents()

	# Total weight of a minimum spanning tree over the undirected version
	# of the graph (-1 if empty or not connected). Engine (Kruskal).
	def MSTWeight()
		if This._EnsureEngine()
			return StzEngineGraphMSTWeight(@pEngineGraph)
		ok
		return -1

		def MinimumSpanningTreeWeight()
			return This.MSTWeight()

	# Minimum spanning tree as a list of [fromNode, toNode, weight] edges.
	# Engine (Kruskal); built Zig-side. [] if not connected/empty.
	def MSTEdges()
		if This._EnsureEngine()
			return StzEngineGraphMSTEdges(@pEngineGraph)
		ok
		return []

		def MinimumSpanningTreeEdges()
			return This.MSTEdges()

	# Articulation points (cut vertices) -- nodes whose removal disconnects
	# the (undirected) graph. Engine (Tarjan low-link). List of node ids.
	def ArticulationPoints()
		if This._EnsureEngine()
			return StzEngineGraphArticulationPoints(@pEngineGraph)
		ok
		return []

		def CutVertices()
			return This.ArticulationPoints()

	# Bridges (cut edges) -- edges whose removal disconnects the (undirected)
	# graph. Engine (Tarjan low-link). List of [u, v] node-id pairs.
	def Bridges()
		if This._EnsureEngine()
			return StzEngineGraphBridges(@pEngineGraph)
		ok
		return []

		def CutEdges()
			return This.Bridges()

	# Weighted shortest path (Dijkstra over edge :weight properties,
	# default 1.0). Returns the node-id path; [] if unreachable.
	def WeightedShortestPath(pcFromNodeId, pcToNodeId)
		if isList(pcFromNodeId) and IsFromNamedParamList(pcFromNodeId)
			pcFromNodeId = pcFromNodeId[2]
		ok
		if isList(pcToNodeId) and IsToNamedParamList(pcToNodeId)
			pcToNodeId = pcToNodeId[2]
		ok
		if NOT This.NodeExists(pcFromNodeId) or NOT This.NodeExists(pcToNodeId)
			return []
		ok
		if This._EnsureEngine()
			return StzEngineGraphDijkstra(@pEngineGraph, StzLower(pcFromNodeId), StzLower(pcToNodeId))
		ok
		return This.ShortestPath(pcFromNodeId, pcToNodeId)

		def DijkstraPath(pcFromNodeId, pcToNodeId)
			return This.WeightedShortestPath(pcFromNodeId, pcToNodeId)

	# Total weight of the minimum-weight path (-1 if unreachable).
	def WeightedShortestPathLength(pcFromNodeId, pcToNodeId)
		if isList(pcFromNodeId) and IsFromNamedParamList(pcFromNodeId)
			pcFromNodeId = pcFromNodeId[2]
		ok
		if isList(pcToNodeId) and IsToNamedParamList(pcToNodeId)
			pcToNodeId = pcToNodeId[2]
		ok
		if NOT This.NodeExists(pcFromNodeId) or NOT This.NodeExists(pcToNodeId)
			return -1
		ok
		if This._EnsureEngine()
			return StzEngineGraphDijkstraDistance(@pEngineGraph, StzLower(pcFromNodeId), StzLower(pcToNodeId))
		ok
		return -1

		def DijkstraDistance(pcFromNodeId, pcToNodeId)
			return This.WeightedShortestPathLength(pcFromNodeId, pcToNodeId)

	def ShortestPathLength(pcFromNodeId, pcToNodeId)

		if CheckParams()
			if isList(pcFromNodeId) and IsFromNamedParamList(pcFromNodeId)
				pcFromNodeId = pcFromNodeId[2]
			ok
			if isList(pcToNodeId) and IsToNamedParamList(pcToNodeId)
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
		# Iterative flood fill with a hash-set of visited nodes.
		#
		# TWO things were wrong with the recursive version this replaces:
		#
		#  - It recursed once per node in the component, so a 1000-node chain
		#    blew the stack outright (R4 Stack Overflow). Depth is now bounded
		#    by an explicit stack on the heap.
		#  - "Visited" was a Ring LIST scanned linearly at every step, making
		#    the whole walk quadratic: 250 nodes 0.21s, 500 nodes 0.70s.
		#
		# NOT a third fault, though it reads like one: the inner test was
		# written list-first, StzFindFirst(pacVisited, neighbour). That looks
		# like a needle-first violation, but StzFindFirst is POLYMORPHIC over
		# lists -- both argument orders resolve, and the list-first form
		# detects membership correctly (verified on a cycle, which would
		# never terminate if it did not). Style inconsistency, not a bug.
		#
		# The engine's connected-components returns a COUNT, not the grouping
		# (that is what NumberOfConnectedComponents uses), so the walk stays
		# here -- but it follows Neighbors() exactly as before, keeping the
		# original out-edge reachability semantics.

		_aCcComponents_ = []
		_aCcNodes_ = This.Nodes()
		_nCcLen_ = len(_aCcNodes_)

		_pCcSeen_ = StzEngineHashMapNew()
		_acCcSeenList_ = []

		for _iCc_ = 1 to _nCcLen_
			_cCcId_ = _aCcNodes_[_iCc_][:id]

			if This._CcSeen(_pCcSeen_, _acCcSeenList_, _cCcId_)
				loop
			ok

			_acCcComp_ = []
			_acCcStack_ = [ _cCcId_ ]

			while len(_acCcStack_) > 0
				_cCcCur_ = _acCcStack_[ len(_acCcStack_) ]
				ring_del(_acCcStack_, len(_acCcStack_))

				if This._CcSeen(_pCcSeen_, _acCcSeenList_, _cCcCur_)
					loop
				ok

				if _pCcSeen_ != NULL
					StzEngineHashMapPutInt(_pCcSeen_, _cCcCur_, 1)
				else
					_acCcSeenList_ + _cCcCur_
				ok

				_acCcComp_ + _cCcCur_

				_acCcNb_ = This.Neighbors(_cCcCur_)
				_nCcNb_ = len(_acCcNb_)

				# Push neighbours in REVERSE so the stack pops them in their
				# natural order -- that reproduces the visit order of the
				# recursion this replaces, which callers may rely on.
				for _jCc_ = _nCcNb_ to 1 step -1
					if NOT This._CcSeen(_pCcSeen_, _acCcSeenList_, _acCcNb_[_jCc_])
						_acCcStack_ + _acCcNb_[_jCc_]
					ok
				next
			end

			_aCcComponents_ + _acCcComp_
		next

		if _pCcSeen_ != NULL
			StzEngineHashMapFree(_pCcSeen_)
		ok

		return _aCcComponents_

	# Membership in the visited set: the engine map when it is available,
	# else a needle-first scan of the fallback list.
	def _CcSeen(pSeenMap, pacSeenList, pcId)
		if pSeenMap != NULL
			return StzEngineHashMapHasKey(pSeenMap, pcId)
		ok

		if StzFindFirst(pcId, pacSeenList) > 0
			return TRUE
		ok

		return FALSE

	#---------------------------------#
	#  ENGINE-BACKED GRAPH METHODS    #
	#---------------------------------#

	def TopologicalSort()
		if This._EnsureEngine()
			_cEngResult_ = StzEngineGraphTopologicalSort(@pEngineGraph)
			return _cEngResult_
		ok
		return []

	def InDegree(pcNodeId)
		if This._EnsureEngine()
			return StzEngineGraphInDegree(@pEngineGraph, StzLower(pcNodeId))
		ok
		return len(This.Incoming(pcNodeId))

	def OutDegree(pcNodeId)
		if This._EnsureEngine()
			return StzEngineGraphOutDegree(@pEngineGraph, StzLower(pcNodeId))
		ok
		return len(This.Neighbors(pcNodeId))

	def NumberOfConnectedComponents()
		if This._EnsureEngine()
			return StzEngineGraphConnectedComponents(@pEngineGraph)
		ok
		return len(This.ConnectedComponents())

	def IsConnected()
		if len(@aNodes) <= 1
			return 1
		ok
		
		_acVisited_ = []
		_acQueue_ = [@aNodes[1][:id]]
		_acVisited_ + @aNodes[1][:id]
		_nIdx_ = 1
		
		while _nIdx_ <= len(_acQueue_)
			_cCurrent_ = _acQueue_[_nIdx_]
			
			_acNeighbors_ = This.Neighbors(_cCurrent_)
			_acIncoming_ = This.Incoming(_cCurrent_)
			
			_nNeighborsLen_ = len(_acNeighbors_)
			for i = 1 to _nNeighborsLen_
				_cNext_ = _acNeighbors_[i]
				if StzFindFirst(_cNext_, _acVisited_) = 0
					_acVisited_ + _cNext_
					_acQueue_ + _cNext_
				ok
			end
			
			_nIncomingLen_ = len(_acIncoming_)
			for i = 1 to _nIncomingLen_
				_cNext_ = _acIncoming_[i]
				if StzFindFirst(_cNext_, _acVisited_) = 0
					_acVisited_ + _cNext_
					_acQueue_ + _cNext_
				ok
			end
			
			_nIdx_ += 1
		end
		
		return len(_acVisited_) = len(@aNodes)

	# (ArticulationPoints is now engine-backed -- see the def above.)

	# Betweenness centrality (Brandes, unweighted) -- computed entirely in the
	# Zig engine. Returns the value for pcNodeId (0 if absent).
	def BetweennessCentrality(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok
		if This._EnsureEngine()
			return StzEngineGraphBetweennessOf(@pEngineGraph, StzLower(pcNodeId))
		ok
		return 0

	# Betweenness for every node as a list of [ id, value ] pairs.
	def BetweennessCentralityAll()
		if This._EnsureEngine()
			return StzEngineGraphBetweennessAll(@pEngineGraph)
		ok
		return []

	# Closeness centrality (engine-backed): reachable / sum(distances).
	# Returns the value for pcNodeId (0 if absent or isolated).
	def ClosenessCentrality(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok
		if This._EnsureEngine()
			return StzEngineGraphClosenessOf(@pEngineGraph, StzLower(pcNodeId))
		ok
		return 0

	# Closeness for every node as a list of [ id, value ] pairs.
	def ClosenessCentralityAll()
		if This._EnsureEngine()
			return StzEngineGraphClosenessAll(@pEngineGraph)
		ok
		return []

	# k-core: core number of pcNodeId -- the largest k for which the node
	# survives in the k-core of the undirected view. Engine (Batagelj-Zaversnik).
	def CoreNumber(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		if This._EnsureEngine()
			return StzEngineGraphCoreNumberOf(@pEngineGraph, StzLower(pcNodeId))
		ok
		return 0

		def KCoreNumber(pcNodeId)
			return This.CoreNumber(pcNodeId)

	# Core number for every node as a list of [ id, value ] pairs.
	def CoreNumbers()
		if This._EnsureEngine()
			return StzEngineGraphCoreNumbersAll(@pEngineGraph)
		ok
		return []

		def CoreNumbersAll()
			return This.CoreNumbers()

	# PageRank (power iteration, damping 0.85) of pcNodeId. Engine-backed.
	def PageRank(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		if This._EnsureEngine()
			return StzEngineGraphPageRankOf(@pEngineGraph, StzLower(pcNodeId))
		ok
		return 0

	# PageRank for every node as a list of [ id, value ] pairs.
	def PageRankAll()
		if This._EnsureEngine()
			return StzEngineGraphPageRankAll(@pEngineGraph)
		ok
		return []

	# A* shortest path (engine-backed). Uses edge weights plus a coordinate
	# heuristic when nodes carry :x and :y properties (Euclidean by default);
	# with no coordinates it degrades gracefully to a Dijkstra-equivalent.
	# Returns the path as a list of node ids ([] if none).
	def AStarPath(pcStart, pcGoal)
		return This._AStarMode(pcStart, pcGoal, 1)

		def AStar(pcStart, pcGoal)
			return This.AStarPath(pcStart, pcGoal)

		def AStarShortestPath(pcStart, pcGoal)
			return This.AStarPath(pcStart, pcGoal)

	# A* with the Manhattan (taxicab) heuristic.
	def AStarPathManhattan(pcStart, pcGoal)
		return This._AStarMode(pcStart, pcGoal, 2)

	# A* with an auto-scaled ADMISSIBLE coordinate heuristic -- use when edge
	# weights are not unit geometric distance (the heuristic is scaled by the
	# minimum edge cost-per-distance ratio so the path stays optimal). nMode
	# 1 = Euclidean coords, 2 = Manhattan.
	def AStarPathWeighted(pcStart, pcGoal, nMode)
		if NOT (This.NodeExists(pcStart) and This.NodeExists(pcGoal))
			return []
		ok
		if This._EnsureEngine()
			return StzEngineGraphAStarWeighted(@pEngineGraph, StzLower(pcStart), StzLower(pcGoal), nMode)
		ok
		return []

	def _AStarMode(pcStart, pcGoal, nMode)
		if NOT (This.NodeExists(pcStart) and This.NodeExists(pcGoal))
			return []
		ok
		if This._EnsureEngine()
			return StzEngineGraphAStar(@pEngineGraph, StzLower(pcStart), StzLower(pcGoal), nMode)
		ok
		return []

	# Override the (engine) weight of a directed edge. Used by stzGraphPlanner
	# to push per-optimisation transition costs before an engine A* search.
	# Returns 1 on success, 0 if the edge is unknown.
	def SetEdgeWeight(pcFrom, pcTo, nWeight)
		if This._EnsureEngine()
			return StzEngineGraphSetEdgeWeight(@pEngineGraph, StzLower(pcFrom), StzLower(pcTo), nWeight)
		ok
		return 0

	# Engine A* for planners: one search returns [ routeList, exploredList ]
	# (the explored/closed order powers explainability metrics). nMode 0 is
	# Dijkstra/UCS -- optimal for any non-negative edge cost.
	def AStarPlan(pcStart, pcGoal, nMode)
		if NOT (This.NodeExists(pcStart) and This.NodeExists(pcGoal))
			return [ [], [] ]
		ok
		if This._EnsureEngine()
			return StzEngineGraphAStarPlan(@pEngineGraph, StzLower(pcStart), StzLower(pcGoal), nMode)
		ok
		return [ [], [] ]

	# Diameter = longest shortest path over all reachable pairs (engine,
	# all-pairs BFS). Replaces the old O(V^2 * BFS) pure-Ring double loop.
	def Diameter()
		if This._EnsureEngine()
			return StzEngineGraphDiameter(@pEngineGraph)
		ok
		return 0

	# Radius = smallest eccentricity among nodes that reach others.
	def Radius()
		if This._EnsureEngine()
			return StzEngineGraphRadius(@pEngineGraph)
		ok
		return 0

	# Eccentricity of a node = its longest shortest path to any reachable node.
	def Eccentricity(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		if This._EnsureEngine()
			return StzEngineGraphEccentricityOf(@pEngineGraph, StzLower(pcNodeId))
		ok
		return 0

	# Eccentricity for every node as a list of [ id, value ] pairs.
	def Eccentricities()
		if This._EnsureEngine()
			return StzEngineGraphEccentricitiesAll(@pEngineGraph)
		ok
		return []

	# Mean shortest-path length over all reachable pairs (engine, all-pairs BFS).
	def AveragePathLength()
		if This._EnsureEngine()
			return StzEngineGraphAveragePathLength(@pEngineGraph)
		ok
		return 0

	# Maximum flow from pcSource to pcSink (Edmonds-Karp, engine). Edge :weight
	# is the capacity (default 1). Returns the flow value.
	def MaxFlow(pcSource, pcSink)
		if NOT (This.NodeExists(pcSource) and This.NodeExists(pcSink))
			return 0
		ok
		if This._EnsureEngine()
			return StzEngineGraphMaxFlow(@pEngineGraph, StzLower(pcSource), StzLower(pcSink))
		ok
		return 0

		def MaximumFlow(pcSource, pcSink)
			return This.MaxFlow(pcSource, pcSink)

	# Minimum cut between pcSource and pcSink: the saturated edges crossing the
	# cut, as a list of [from, to] id pairs (max-flow / min-cut). Engine.
	def MinCut(pcSource, pcSink)
		if NOT (This.NodeExists(pcSource) and This.NodeExists(pcSink))
			return []
		ok
		if This._EnsureEngine()
			return StzEngineGraphMinCut(@pEngineGraph, StzLower(pcSource), StzLower(pcSink))
		ok
		return []

		def MinimumCut(pcSource, pcSink)
			return This.MinCut(pcSource, pcSink)

	# Community detection (label propagation, engine, undirected view).
	# Returns a list of communities, each a list of node ids.
	def Communities()
		if This._EnsureEngine()
			return StzEngineGraphCommunities(@pEngineGraph)
		ok
		return []

		def DetectCommunities()
			return This.Communities()

	def NumberOfCommunities()
		if This._EnsureEngine()
			return StzEngineGraphNumberOfCommunities(@pEngineGraph)
		ok
		return 0

	# Min-cost max-flow from pcSource to pcSink. Edge :weight is capacity,
	# edge :cost is per-unit cost. Returns [ flowValue, totalCost ]. Engine
	# (successive shortest paths).
	def MinCostMaxFlow(pcSource, pcSink)
		if NOT (This.NodeExists(pcSource) and This.NodeExists(pcSink))
			return [ 0, 0 ]
		ok
		if This._EnsureEngine()
			return StzEngineGraphMinCostMaxFlow(@pEngineGraph, StzLower(pcSource), StzLower(pcSink))
		ok
		return [ 0, 0 ]

		def MinCostFlow(pcSource, pcSink)
			return This.MinCostMaxFlow(pcSource, pcSink)

	# Local clustering coefficient (engine, undirected view): edges among a
	# node's neighbours / possible such edges. Replaces the old O(k^2)
	# pure-Ring EdgeExists double loop.
	def ClusteringCoefficient(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok
		if This._EnsureEngine()
			return StzEngineGraphClusteringOf(@pEngineGraph, StzLower(pcNodeId))
		ok
		return 0

		def ClusteringCoeff(pcNodeId)
			return This.ClusteringCoefficient(pcNodeId)

	# Local clustering coefficient for every node as [ id, value ] pairs.
	def ClusteringCoefficients()
		if This._EnsureEngine()
			return StzEngineGraphClusteringAll(@pEngineGraph)
		ok
		return []

	def PathWeight(pacPath)
		_nTotal_ = 0
		_nLen_ = len(pacPath)
		
		for i = 1 to _nLen_ - 1
			_cFrom_ = pacPath[i]
			_cTo_ = pacPath[i + 1]
			
			if This.EdgeExists(_cFrom_, _cTo_)
				pWeight = This.EdgeProperty(_cFrom_, _cTo_, "weight")
				if isNumber(pWeight)
					_nTotal_ += pWeight
				ok
			ok
		end
		
		return _nTotal_

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
		_cDOT_ = "digraph " + This.Id() + " {" + nl
		_cDOT_ += "  rankdir=TD;" + nl
		_cDOT_ += "  node [shape=box];" + nl + nl
		
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cName_ = _aNode_["id"]
			_cLabel_ = _aNode_["label"]
			
			if StzLeft(_cName_, 1) = "@"
				_cName_ = StzMid(_cName_, 2, stzlen(_cName_) - 1)
			ok

			_cDOT_ += "  " + _cName_ + " [label=" + '"' + _cLabel_ + '"' + "];" + nl
		end

		_cDOT_ += nl

		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			_cFrom_ = _aEdge_["from"]
			_cTo_ = _aEdge_["to"]
			_cLabel_ = _aEdge_["label"]

			if StzLeft(_cFrom_, 1) = "@"
				_cFrom_ = StzMid(_cFrom_, 2, stzlen(_cFrom_) - 1)
			ok
			if StzLeft(_cTo_, 1) = "@"
				_cTo_ = StzMid(_cTo_, 2, stzlen(_cTo_) - 1)
			ok
			
			_cDOT_ += "  " + _cFrom_ + " -> " + _cTo_
			if _cLabel_ != ""
				_cDOT_ += " [label=" + '"' + _cLabel_ + '"' + "]"
			ok
			_cDOT_ += ";" + nl
		end
		
		_cDOT_ += "}" + nl
		return _cDOT_
	
		def ExportToDotQ()
			_oDotCode_ = new stzDotCode()
			_oDotCode_.SetCode(This.ExportToDot())
			return _oDotCode_

		def Dot()
			return This.ExportToDot()

			def DotQ()
				return This.ExportToDotQ()

		def ToDot()
			return This.ExportToDot()

			def ToDotQ()
				return This.ExportToDotQ()

	def ExportToJSON()
		_acNodes_ = []
		_acEdges_ = []
		
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cName_ = _aNode_["id"]
			if StzLeft(_cName_, 1) = "@"
				_cName_ = StzMid(_cName_, 2, stzlen(_cName_) - 2)
			ok
			_acNodes_ + [
				:id = _cName_,
				:label = _aNode_["label"],
				:properties = _aNode_["properties"]
			]
		end
		
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			_cFrom_ = _aEdge_["from"]
			_cTo_ = _aEdge_["to"]
			if StzLeft(_cFrom_, 1) = "@"
				_cFrom_ = StzMid(_cFrom_, 2, stzlen(_cFrom_) - 2)
			ok
			if StzLeft(_cTo_, 1) = "@"
				_cTo_ = StzMid(_cTo_, 2, stzlen(_cTo_) - 2)
			ok
			_acEdges_ + [
				:from = _cFrom_,
				:to = _cTo_,
				:label = _aEdge_["label"],
				:properties = _aEdge_["properties"]
			]
		end
		
		_cJSON_ = "{" + nl
		_cJSON_ += '  "id": "' + This.Id() + '",' + nl
		_cJSON_ += '  "nodes": [' + nl
		
		_nLen_ = len(_acNodes_)
		for i = 1 to _nLen_
			_cJSON_ += '    ' + @ToJSON(_acNodes_[i])
			if i < _nLen_
				_cJSON_ += ","
			ok
			_cJSON_ += nl
		end
		
		_cJSON_ += '  ],' + nl
		_cJSON_ += '  "edges": [' + nl
		
		_nLen_ = len(_acEdges_)
		for i = 1 to _nLen_
			_cJSON_ += '    ' + @ToJSON(_acEdges_[i])
			if i < _nLen_
				_cJSON_ += ","
			ok
			_cJSON_ += nl
		end
		
		_cJSON_ += '  ],' + nl
		_cJSON_ += '  "metrics": ' + @ToJSON([
			:nodeCount = len(@aNodes),
			:edgeCount = len(@aEdges),
			:density = This.NodeDensity(),
			:longestPath = This.LongestPath(),
			:hasCycles = This.HasCyclicDependencies()
		]) + nl
		_cJSON_ += "}"
		
		return _cJSON_

		def Json()
			return This.ExportToJson()

		def ToJson()
			return This.ExportToJson()

	def ExportToYAML()
		_cYAML_ = "graph: " + This.Id() + nl
		_cYAML_ += "nodes:" + nl
		
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cName_ = _aNode_["id"]
			
			if StzLeft(_cName_, 1) = "@"
				_cName_ = StzMid(_cName_, 2, stzlen(_cName_) - 1)
			ok

			_cYAML_ += "  - id: " + _cName_ + nl
			_cYAML_ += "    label: " + _aNode_["label"] + nl
			if len(_aNode_["properties"]) > 0
				_cYAML_ += "    properties:" + nl
				_acProps_ = _aNode_["properties"]
				_nPropLen_ = len(_acProps_)
				for j = 1 to _nPropLen_
					_cYAML_ += "      - " + string(_acProps_[j][1]) + nl
				end
			ok
		end
		
		_cYAML_ += nl + "edges:" + nl
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			_cFrom_ = _aEdge_["from"]
			_cTo_ = _aEdge_["to"]
			
			if StzLeft(_cFrom_, 1) = "@"
				_cFrom_ = StzMid(_cFrom_, 2, stzlen(_cFrom_) - 1)
			ok
			if StzLeft(_cTo_, 1) = "@"
				_cTo_ = StzMid(_cTo_, 2, stzlen(_cTo_) - 1)
			ok

			_cYAML_ += "  - from: " + _cFrom_ + nl
			_cYAML_ += "    to: " + _cTo_ + nl
			_cYAML_ += "    label: " + _aEdge_["label"] + nl
		end
		
		return _cYAML_
	
		def Yaml()
			return This.ExportToYaml()

		def ToYaml()
			return This.ExportToYaml()

	#------------------#
	#  GRAPHML FORMAT  #
	#------------------#

	def ExportToGraphML()
		_cXML_ = '<?xml version="1.0" encoding="UTF-8"?>' + NL
		_cXML_ += '<graphml xmlns="http://graphml.graphdrawing.org/xmlns"' + NL
		_cXML_ += '         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + NL
		_cXML_ += '         xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns' + NL
		_cXML_ += '         http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">' + NL + NL
		
		# Define keys for properties
		_cXML_ += '  <key id="label" for="node" attr.name="label" attr.type="string"/>' + NL
		_cXML_ += '  <key id="type" for="graph" attr.name="type" attr.type="string"/>' + NL
		_cXML_ += '  <key id="edge_label" for="edge" attr.name="label" attr.type="string"/>' + NL
		
		# Add custom property keys
		_aAllProps_ = This.PropertiesXT()
		_nLen_ = len(_aAllProps_)
		for i = 1 to _nLen_
			_cPropKey_ = _aAllProps_[i][1]
			_cXML_ += '  <key id="prop_' + _cPropKey_ + '" for="node" attr.name="' + _cPropKey_ + '" attr.type="string"/>' + NL
		next
		_cXML_ += NL
		
		# Graph element
		_cXML_ += '  <graph id="' + @cId + '" edgedefault="directed">' + NL
		_cXML_ += '    <data key="type">' + @cGraphType + '</data>' + NL + NL
		
		# Nodes
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cXML_ += '    <node id="' + This._XMLEscape(_aNode_[:id]) + '">' + NL
			_cXML_ += '      <data key="label">' + This._XMLEscape(_aNode_[:label]) + '</data>' + NL
			
			if HasKey(_aNode_, :properties) and len(_aNode_[:properties]) > 0
				_aProps_ = _aNode_[:properties]
				_acKeys_ = keys(_aProps_)
				_nKeyLen_ = len(_acKeys_)
				for j = 1 to _nKeyLen_
					_cKey_ = _acKeys_[j]
					pVal = _aProps_[_cKey_]
					_cXML_ += '      <data key="prop_' + _cKey_ + '">' + This._XMLEscape(This._ValueToString(pVal)) + '</data>' + NL
				next
			ok
			
			_cXML_ += '    </node>' + NL
		next
		_cXML_ += NL
		
		# Edges
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			_cXML_ += '    <edge id="e' + i + '" source="' + This._XMLEscape(_aEdge_[:from]) + '" target="' + This._XMLEscape(_aEdge_[:to]) + '">' + NL
			
			if _aEdge_[:label] != ""
				_cXML_ += '      <data key="edge_label">' + This._XMLEscape(_aEdge_[:label]) + '</data>' + NL
			ok
			
			if HasKey(_aEdge_, :properties) and len(_aEdge_[:properties]) > 0
				_aProps_ = _aEdge_[:properties]
				_acKeys_ = keys(_aProps_)
				_nKeyLen_ = len(_acKeys_)
				for j = 1 to _nKeyLen_
					_cKey_ = _acKeys_[j]
					pVal = _aProps_[_cKey_]
					_cXML_ += '      <data key="prop_' + _cKey_ + '">' + This._XMLEscape(This._ValueToString(pVal)) + '</data>' + NL
				next
			ok
			
			_cXML_ += '    </edge>' + NL
		next
		
		_cXML_ += '  </graph>' + NL
		_cXML_ += '</graphml>' + NL
		
		return _cXML_
	
		def ToGraphML()
			return This.ExportToGraphML()
	
		def AsGraphML()
			return This.ExportToGraphML()
	
	def SaveToGraphML(pcPath)
		_cContent_ = This.ExportToGraphML()
		write(pcPath, _cContent_)
	
		def SaveAsGraphML(pcPath)
			This.SaveToGraphML(pcPath)
	
	def LoadFromGraphML(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		_cContent_ = read(pcPath)
		This._ParseGraphML(_cContent_)
	
		def LoadGraphML(pcPath)
			This.LoadFromGraphML(pcPath)
	
		def ImportFromGraphML(pcPath)
			This.LoadFromGraphML(pcPath)
	
		def ImportGraphML(pcPath)
			This.LoadFromGraphML(pcPath)
	
	def _ParseGraphML(_cXML_)
		# Clear current graph
		@aNodes = []
		@aEdges = []
		
		# Extract graph id
		_nPos_ = StzFindFirst('<graph id="', _cXML_)
		if _nPos_ > 0
			_cRest_ = StzMid(_cXML_, 11, stzlen(_cXML_) - 10)
			_nEnd_ = StzFindFirst('"', _cRest_)
			if _nEnd_ > 0
				@cId = StzMid(_cRest_, 1, _nEnd_ - 1)
			ok
		ok

		# Extract graph type
		_nPos_ = StzFindFirst('<data key="type">', _cXML_)
		if _nPos_ > 0
			_cRest_ = StzMid(_cXML_, 17, stzlen(_cXML_) - 16)
			_nEnd_ = StzFindFirst('</data>', _cRest_)
			if _nEnd_ > 0
				@cGraphType = trim(StzMid(_cRest_, 1, _nEnd_ - 1))
			ok
		ok

		# Parse nodes
		_cRemaining_ = _cXML_
		while TRUE
			_nNodeStart_ = StzFindFirst('<node id="', _cRemaining_)
			if _nNodeStart_ = 0
				exit
			ok

			_cRemaining_ = StzMid(_cRemaining_, 10, stzlen(_cRemaining_) - 9)
			_nIdEnd_ = StzFindFirst('"', _cRemaining_)
			_cNodeId_ = StzMid(_cRemaining_, 1, _nIdEnd_ - 1)

			_nNodeEnd_ = StzFindFirst('</node>', _cRemaining_)
			_cNodeBlock_ = StzMid(_cRemaining_, 1, _nNodeEnd_ - 1)

			# Extract label
			_cLabel_ = _cNodeId_
			_nLabelPos_ = StzFindFirst('<data key="label">', _cNodeBlock_)
			if _nLabelPos_ > 0
				_cLabelRest_ = StzMid(_cNodeBlock_, 18, stzlen(_cNodeBlock_) - 17)
				_nLabelEnd_ = StzFindFirst('</data>', _cLabelRest_)
				if _nLabelEnd_ > 0
					_cLabel_ = This._XMLUnescape(StzMid(_cLabelRest_, 1, _nLabelEnd_ - 1))
				ok
			ok

			# Extract properties
			_aProps_ = []
			_cPropBlock_ = _cNodeBlock_
			while TRUE
				_nPropPos_ = StzFindFirst('<data key="prop_', _cPropBlock_)
				if _nPropPos_ = 0
					exit
				ok

				_cPropBlock_ = StzMid(_cPropBlock_, 16, stzlen(_cPropBlock_) - 15)
				_nKeyEnd_ = StzFindFirst('">', _cPropBlock_)
				_cPropKey_ = StzMid(_cPropBlock_, 1, _nKeyEnd_ - 1)

				_cPropBlock_ = StzMid(_cPropBlock_, _nKeyEnd_ + 2, stzlen(_cPropBlock_) - _nKeyEnd_ - 1)
				_nValEnd_ = StzFindFirst('</data>', _cPropBlock_)
				_cPropVal_ = This._XMLUnescape(StzMid(_cPropBlock_, 1, _nValEnd_ - 1))

				_aProps_ + [_cPropKey_, This._StringToValue(_cPropVal_)]
			end

			This.AddNodeXTT(_cNodeId_, _cLabel_, _aProps_)
			_cRemaining_ = StzMid(_cRemaining_, 7, stzlen(_cRemaining_) - 6)
		end

		# Parse edges
		_cRemaining_ = _cXML_
		while TRUE
			_nEdgeStart_ = StzFindFirst('<edge ', _cRemaining_)
			if _nEdgeStart_ = 0
				exit
			ok

			_cRemaining_ = StzMid(_cRemaining_, 6, stzlen(_cRemaining_) - 5)

			# Extract source
			_nSourcePos_ = StzFindFirst('source="', _cRemaining_)
			_cRemaining_ = StzMid(_cRemaining_, 8, stzlen(_cRemaining_) - 7)
			_nSourceEnd_ = StzFindFirst('"', _cRemaining_)
			_cSource_ = StzMid(_cRemaining_, 1, _nSourceEnd_ - 1)

			# Extract target
			_nTargetPos_ = StzFindFirst('target="', _cRemaining_)
			_cRemaining_ = StzMid(_cRemaining_, 8, stzlen(_cRemaining_) - 7)
			_nTargetEnd_ = StzFindFirst('"', _cRemaining_)
			_cTarget_ = StzMid(_cRemaining_, 1, _nTargetEnd_ - 1)

			_nEdgeEnd_ = StzFindFirst('</edge>', _cRemaining_)
			_cEdgeBlock_ = StzMid(_cRemaining_, 1, _nEdgeEnd_ - 1)

			# Extract edge label
			_cEdgeLabel_ = ""
			_nLabelPos_ = StzFindFirst('<data key="edge_label">', _cEdgeBlock_)
			if _nLabelPos_ > 0
				_cLabelRest_ = StzMid(_cEdgeBlock_, 23, stzlen(_cEdgeBlock_) - 22)
				_nLabelEnd_ = StzFindFirst('</data>', _cLabelRest_)
				if _nLabelEnd_ > 0
					_cEdgeLabel_ = This._XMLUnescape(StzMid(_cLabelRest_, 1, _nLabelEnd_ - 1))
				ok
			ok

			# Extract edge properties
			_aProps_ = []
			_cPropBlock_ = _cEdgeBlock_
			while TRUE
				_nPropPos_ = StzFindFirst('<data key="prop_', _cPropBlock_)
				if _nPropPos_ = 0
					exit
				ok

				_cPropBlock_ = StzMid(_cPropBlock_, 16, stzlen(_cPropBlock_) - 15)
				_nKeyEnd_ = StzFindFirst('">', _cPropBlock_)
				_cPropKey_ = StzMid(_cPropBlock_, 1, _nKeyEnd_ - 1)

				_cPropBlock_ = StzMid(_cPropBlock_, 2, stzlen(_cPropBlock_) - 1)
				_nValEnd_ = StzFindFirst('</data>', _cPropBlock_)
				_cPropVal_ = This._XMLUnescape(StzMid(_cPropBlock_, 1, _nValEnd_ - 1))

				_aProps_ + [_cPropKey_, This._StringToValue(_cPropVal_)]
			end

			This.AddEdgeXTT(_cSource_, _cTarget_, _cEdgeLabel_, _aProps_)
			_cRemaining_ = StzMid(_cRemaining_, 7, stzlen(_cRemaining_) - 6)
		end
	
	def _XMLEscape(_cText_)
		if NOT isString(_cText_)
			return ""
		ok
		
		_cText_ = StzReplace(_cText_, "&", "&amp;")
		_cText_ = StzReplace(_cText_, "<", "&lt;")
		_cText_ = StzReplace(_cText_, ">", "&gt;")
		_cText_ = StzReplace(_cText_, '"', "&quot;")
		_cText_ = StzReplace(_cText_, "'", "&apos;")
		return _cText_

	def _XMLUnescape(_cText_)
		if NOT isString(_cText_)
			return ""
		ok

		_cText_ = StzReplace(_cText_, "&amp;", "&")
		_cText_ = StzReplace(_cText_, "&lt;", "<")
		_cText_ = StzReplace(_cText_, "&gt;", ">")
		_cText_ = StzReplace(_cText_, "&quot;", '"')
		_cText_ = StzReplace(_cText_, "&apos;", "'")
		return _cText_
	
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
	
	def _StringToValue(_cValue_)
		if StzLeft(_cValue_, 1) = "[" and StzRight(_cValue_, 1) = "]"

			_cInner_ = StzMid(_cValue_, 2, stzlen(_cValue_) - 2)
			if _cInner_ = ""
				return []
			ok

			_acParts_ = @split(_cInner_, ",")
			_aResult_ = []
			_nLen_ = len(_acParts_)

			for i = 1 to _nLen_
				_aResult_ + trim(_acParts_[i])
			next

			return _aResult_
		ok

		if isdigit(_cValue_) or (StzLeft(_cValue_, 1) = "-" and stzlen(_cValue_) > 1 and isdigit(StzMid(_cValue_, 2, 1)))
			return 0 + _cValue_
		ok
		
		return _cValue_

	#------------------------#
	#  VISUALISING IN ASCII  #
	#------------------------#

	def Show()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		_oViz_.Show()

		def Shwo()
			This.Show()

	# The same picture as DATA, for a file, a report, or a test.
	# Show() prints it; these hand it back.
	def AsciiArt()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		return _oViz_.AsciiArt()

	def AsciiArtHorizontal()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		return _oViz_.AsciiArtHorizontal()

	def View()
		_oDot_ = new stzDotCode()
		_oDot_.SetCode(This.Dot())
		_oDot_.RunAndView()

		#< @FunctionAlternativeForm

		def Veiw()
			This.View()

		#>

	def ShowHorizontal()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		_oViz_.ShowHorizontal()

		def ShowH()
			This.ShowHorizontal()

	def ShowVertical()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		_oViz_.ShowVertical()

		def ShowV()
			This.ShowVertical()

	#------------------------#
	#  EXPLAINING THE GRAPH  #
	#------------------------#

	# Telling the story of the graph

	def Explain()
		_aExplanation_ = [
			:general = [],
			:bottlenecks = [],
			:cycles = [],
			:metrics = [],
			:rules = []
		]
		
		_acBottlenecks_ = This.BottleneckNodes()
		_acCyclic_ = This.CyclicNodes()
		
		_acNodes_ = This.Nodes()
		_acEdges_ = This.Edges()
		
		# General section
		_aExplanation_[:general] + ("Graph: " + This.Id())
		_aExplanation_[:general] + ("Nodes: " + len(_acNodes_) + " | Edges: " + len(_acEdges_))
		
		# Bottlenecks section
		if len(_acBottlenecks_) > 0
			_nTotalDegree_ = 0
			_nLen_ = len(_acNodes_)
			for i = 1 to _nLen_
				_aNode_ = _acNodes_[i]
				_nIncoming_ = len(This.Incoming(_aNode_["id"]))
				_nOutgoing_ = len(This.Neighbors(_aNode_["id"]))
				_nTotalDegree_ += _nIncoming_ + _nOutgoing_
			end
			_nAvgDegree_ = _nTotalDegree_ / len(_acNodes_)
			
			_aExplanation_[:bottlenecks] + ("Bottleneck nodes: " + joinXT(_acBottlenecks_, ", "))
			_aExplanation_[:bottlenecks] + ("Average degree: " + _nAvgDegree_)
			
			_nLen_ = len(_acBottlenecks_)
			for i = 1 to _nLen_
				_cNode_ = _acBottlenecks_[i]
				_nIncoming_ = len(This.Incoming(_cNode_))
				_nOutgoing_ = len(This.Neighbors(_cNode_))
				_nDegree_ = _nIncoming_ + _nOutgoing_
				_aExplanation_[:bottlenecks] + ("  " + _cNode_ + ": degree " + _nDegree_ + " (above average)")
			end
		else
			_nTotalDegree_ = 0
			_nLen_ = len(_acNodes_)
			for i = 1 to _nLen_
				_aNode_ = _acNodes_[i]
				_nIncoming_ = len(This.Incoming(_aNode_["id"]))
				_nOutgoing_ = len(This.Neighbors(_aNode_["id"]))
				_nTotalDegree_ += _nIncoming_ + _nOutgoing_
			end
			_nAvgDegree_ = _nTotalDegree_ / len(_acNodes_)
			_aExplanation_[:bottlenecks] + ("No bottlenecks (average degree = " + _nAvgDegree_ + ")")
		ok
		
		# Cycles section
		if len(_acCyclic_) > 0
			_aExplanation_[:cycles] + ("Cyclic nodes: " + join(_acCyclic_, ", "))
			_nLen_ = len(_acCyclic_)
			for i = 1 to _nLen_
				_cNode_ = _acCyclic_[i]
				_aExplanation_[:cycles] + ("  " + _cNode_ + " can reach itself")
			end
		ok
		
		if This.HasCyclicDependencies()
			_aExplanation_[:cycles] + "WARNING: Circular dependencies detected"
		else
			if len(_acCyclic_) = 0
				_aExplanation_[:cycles] + "No cycles - acyclic graph (DAG)"
			ok
		ok
		
		# Metrics section
		_nDensity_ = This.NodeDensity()
		if _nDensity_ = 0
			aoExplanation[:metrics] + "Density: 0% (no connections)"
		but _nDensity_ < 25
			_aExplanation_[:metrics] + ("Density: " + _nDensity_ + "% (sparse)")
		but _nDensity_ < 50
			_aExplanation_[:metrics] + ("Density: " + _nDensity_ + "% (moderate)")
		but _nDensity_ < 75
			_aExplanation_[:metrics] + ("Density: " + _nDensity_ + "% (dense)")
		else
			_aExplanation_[:metrics] + ("Density: " + _nDensity_ + "% (very dense)")
		ok
		
		_nLongest_ = This.LongestPath()
		if _nLongest_ = 0
			_aExplanation_[:metrics] + "Longest path: 0 hops (isolated)"
		but _nLongest_ = 1
			_aExplanation_[:metrics] + "Longest path: 1 hop"
		else
			_aExplanation_[:metrics] + ("Longest path: " + _nLongest_ + " hops")
		ok
		
		# Rules section
		_acRulesApplied_ = This.RulesApplied()
		if len(_acRulesApplied_) > 0
			_aExplanation_[:rules] + ("Rules applied: " + len(_acRulesApplied_))
			_nLen_ = len(_acRulesApplied_)
			for i = 1 to _nLen_
				_aExplanation_[:rules] + ("  - " + _acRulesApplied_[i])
			end
		else
			_aExplanation_[:rules] + "No rules applied"
		ok
		
		return _aExplanation_

	# Telling the story of a particular path

	def ExplainPath(pcFrom, pcTo)
	    _acPath_ = This.Path(pcFrom, pcTo)
	    _aStory_ = []
	    _nLen_ = len(_acPath_) - 1

	    for i = 1 to _nLen_
	        _aEdge_ = This.Edge(_acPath_[i], _acPath_[i+1])
	        _aStory_ + (_acPath_[i] + " " + @cArrowRight + " " + _acPath_[i+1])
		if _aEdge_[:label] != ""
			_aStory_[len(_aStory_)] +=  (" : because {" + _acPath_[i] + "} " + StzReplace(_aEdge_[:label], "_", " ") + " {" + _acPath_[i+1] + "}" )
		ok
	    next
	    
	    return _aStory_

	#-------------------#
	#  RULE MANAGEMENT  #
	#-------------------#
	
	def UseRulesFrom(pcRuleGroup)
		if HasKey($aGraphRules, pcRuleGroup)
			_aRules_ = $aGraphRules[pcRuleGroup]
			_nRules2Len_ = len(_aRules_)
			for _iLoopRules2_ = 1 to _nRules2Len_
				_aRule_ = _aRules_[_iLoopRules2_]
				This._AddUniqueRule(_aRule_)
			next
		ok
	
	def _AddUniqueRule(_aRule_)
		# The ONE door a rule enters by, whatever brought it: a rule group
		# ($aGraphRules, via UseRulesFrom) or a .stzrulz file (via
		# _ParseStzRulz). It routes the rule into its typed store and
		# refuses a name already taken in that store.
		#
		# The type arrives in whatever case its author wrote: .stzrulz files
		# say `type: validation`, the RegisterRuleInGroup examples say
		# `:type = :constraint`, and the stores are named :Constraint /
		# :Derivation / :Validation. Ring's `=` on strings is CASE-SENSITIVE
		# (verified: "validation" = "Validation" -> 0), so comparing those
		# forms directly dropped every lower-case rule in SILENCE -- no
		# raise, no count, just no rule. Fold the case once, here, and the
		# dialects meet.

		_cName_ = _aRule_[:name]
		_cType_ = StzLower("" + _aRule_[:type])

		if _cType_ = "constraint"
			if NOT This._HasRuleNamed(@aConstraintRules, _cName_)
				@aConstraintRules + _aRule_
			ok

		but _cType_ = "derivation"
			if NOT This._HasRuleNamed(@aDerivationRules, _cName_)
				@aDerivationRules + _aRule_
			ok

		but _cType_ = "validation"
			if NOT This._HasRuleNamed(@aValidationRules, _cName_)
				@aValidationRules + _aRule_
			ok
		ok

	def _HasRuleNamed(_aRuleList_, _cName_)
		_nLen_ = len(_aRuleList_)
		for i = 1 to _nLen_
			if _aRuleList_[i][:name] = _cName_
				return TRUE
			ok
		next
		return FALSE

	def _IsKnownRuleType(pcType)
		_cT_ = StzLower("" + pcType)
		return _cT_ = "constraint" or _cT_ = "derivation" or _cT_ = "validation"

	def ApplyDerivationRules()
		This.ApplyDerivationRulesXT()

	def ApplyDerivationRulesXT()
		# Temporarily disable constraints during derivation
		_bOldState_ = @bEnforceConstraints
		@bEnforceConstraints = FALSE  # Bypass constraints during derivation
		
		_aEdgesAdded_ = []
		_nLen_ = len(@aDerivationRules)
		
		for i = 1 to _nLen_
			_aRule_ = @aDerivationRules[i]
			pFunc = _aRule_[:function]
			paParams = _aRule_[:params]
			_aNewEdges_ = call pFunc(This, paParams)
			
			_nEdgesLen_ = len(_aNewEdges_)
			for j = 1 to _nEdgesLen_
				_aEdge_ = _aNewEdges_[j]
				if NOT This.EdgeExists(_aEdge_[1], _aEdge_[2])
					This.AddEdgeXTT(_aEdge_[1], _aEdge_[2], _aEdge_[3], _aEdge_[4])
					_aEdgesAdded_ + _aEdge_
					This._TrackRuleApplication(_aRule_[:name], :edge, _aEdge_[1] + "->" + _aEdge_[2])
				ok
			next
		next
		
		@bEnforceConstraints = _bOldState_
		
		_aResult_ = [
			:edgesAdded = _aEdgesAdded_,
			:rulesApplied = @aDerivationRules
		]
	
		return _aResult_

	def CheckConstraintRules(paOperationParams)  # Was: CheckConstraints
		_aViolations_ = []
		_nLen_ = len(@aConstraintRules)  # Changed
		
		for i = 1 to _nLen_
			_aRule_ = @aConstraintRules[i]  # Changed
			
			pFunc = _aRule_[:function]
			paRuleParams = _aRule_[:params]
			_aResult_ = call pFunc(This, paRuleParams, paOperationParams)
			
			_bBlocked_ = _aResult_[1]
			_cMessage_ = _aResult_[2]
			
			if _bBlocked_
				_aViolations_ + [
					:rule = _aRule_[:name],
					:message = iif(_cMessage_ = "", _aRule_[:message], _cMessage_),
					:severity = _aRule_[:severity],
					:params = paOperationParams
				]
			ok
		next
		
		_bSuccess_ = (len(_aViolations_) = 0)
		return [_bSuccess_, _aViolations_]

	def RulesApplied()
		_acResult_ = []
		
		_nAffectedNodes1Len_ = len(@aAffectedNodes)
		for _iLoopAffectedNodes1_ = 1 to _nAffectedNodes1Len_
			_aAffected_ = @aAffectedNodes[_iLoopAffectedNodes1_]
			_aAffected22_ = _aAffected_[2]
			_nAffected22Len_ = len(_aAffected22_)
			for _iLoopAffected22_ = 1 to _nAffected22Len_
				_cRule_ = _aAffected22_[_iLoopAffected22_]
				if StzFindFirst(_cRule_, _acResult_) = 0
					_acResult_ + _cRule_
				ok
			next
		next
		
		_nAffectedEdges1Len_ = len(@aAffectedEdges)
		for _iLoopAffectedEdges1_ = 1 to _nAffectedEdges1Len_
			_aAffected_ = @aAffectedEdges[_iLoopAffectedEdges1_]
			_aAffected21_ = _aAffected_[2]
			_nAffected21Len_ = len(_aAffected21_)
			for _iLoopAffected21_ = 1 to _nAffected21Len_
				_cRule_ = _aAffected21_[_iLoopAffected21_]
				if StzFindFirst(_cRule_, _acResult_) = 0
					_acResult_ + _cRule_
				ok
			next
		next
		
		return _acResult_

	# Every rule this graph carries, of every type, in one list.
	#
	# This is a READING of the three typed stores, never a fourth store.
	# The .stzrulz code used to write to an @aRules attribute that was
	# never declared -- so exporting raised R24 and the format had, in
	# fact, never run. A real @aRules would have to be kept in step with
	# @aConstraintRules / @aDerivationRules / @aValidationRules on every
	# path that touches a rule; the day one path forgot, the file and the
	# graph would disagree and nothing would say so. Derive instead: the
	# typed stores are the truth, and this just reads them.

	def Rules()
		_aAll_ = []

		_nLen_ = len(@aConstraintRules)
		for i = 1 to _nLen_
			_aAll_ + @aConstraintRules[i]
		next

		_nLen_ = len(@aDerivationRules)
		for i = 1 to _nLen_
			_aAll_ + @aDerivationRules[i]
		next

		_nLen_ = len(@aValidationRules)
		for i = 1 to _nLen_
			_aAll_ + @aValidationRules[i]
		next

		return _aAll_

	def NumberOfRules()
		return len(This.Rules())

	def RulesSummary()
		_aSummary_ = [
			:Constraint = [],
			:Derivation = [],
			:Validation = [],
			:applied = []
		]
		
		_nLen_ = len(@aConstraintRules)
		for i = 1 to _nLen_
			_aSummary_[:Constraint] + @aConstraintRules[i][:name]
		next
		
		_nLen_ = len(@aDerivationRules)
		for i = 1 to _nLen_
			_aSummary_[:Derivation] + @aDerivationRules[i][:name]
		next
		
		_nLen_ = len(@aValidationRules)
		for i = 1 to _nLen_
			_aSummary_[:Validation] + @aValidationRules[i][:name]
		next
		
		_aSummary_[:applied] = This.RulesApplied()
		
		return _aSummary_
	
	def _TrackRuleApplication(pcRuleName, pcTargetType, pcTargetId)
		if pcTargetType = :node
			_nPos_ = 0
			_nLen_ = len(@aAffectedNodes)
			for i = 1 to _nLen_
				if @aAffectedNodes[i][1] = pcTargetId
					_nPos_ = i
					exit
				ok
			next
			
			if _nPos_ = 0
				@aAffectedNodes + [pcTargetId, [pcRuleName]]
			else
				if StzFindFirst(pcRuleName, @aAffectedNodes[_nPos_][2]) = 0
					@aAffectedNodes[_nPos_][2] + pcRuleName
				ok
			ok
			
		but pcTargetType = :edge
			_nPos_ = 0
			_nLen_ = len(@aAffectedEdges)
			for i = 1 to _nLen_
				if @aAffectedEdges[i][1] = pcTargetId
					_nPos_ = i
					exit
				ok
			next
			
			if _nPos_ = 0
				@aAffectedEdges + [pcTargetId, [pcRuleName]]
			else
				if StzFindFirst(pcRuleName, @aAffectedEdges[_nPos_][2]) = 0
					@aAffectedEdges[_nPos_][2] + pcRuleName
				ok
			ok
		ok


	    def ClearRules()
	        @aConstraintRules = []
	        @aDerivationRules = []
	        @aValidationRules = []
	        @aAffectedNodes = []
	        @aAffectedEdges = []
	    
	    # Clear specific type
	    def ClearConstraintRules()
	        @aConstraintRules = []
	        
	    def ClearDerivationRules()
	        @aDerivationRules = []
	        
	    def ClearValidationRules()
	        @aValidationRules = []
	    
	    # Remove specific rule
	    def RemoveRule(_cRuleName_)
		_cRuleName_ = UPPER(_cRuleName_)
	        # Search all three lists
	        @aConstraintRules = This._RemoveRuleFromList(@aConstraintRules, _cRuleName_)
	        @aDerivationRules = This._RemoveRuleFromList(@aDerivationRules, _cRuleName_)
	        @aValidationRules = This._RemoveRuleFromList(@aValidationRules, _cRuleName_)
	    
	    def _RemoveRuleFromList(_aRules_, _cName_)
		_cName_ = UPPER(_cName_)
	        _aNew_ = []
	        _nRules1Len_ = len(_aRules_)
	        for _iLoopRules1_ = 1 to _nRules1Len_
	        	_aRule_ = _aRules_[_iLoopRules1_]
	            if _aRule_[:name] != _cName_
	                _aNew_ + _aRule_
	            ok
	        next
	        return _aNew_
	    
	    # Check if rule loaded
	def HasRule(pcRuleName)
		if NOT isString(pcRuleName)
			stzraise("Rule name must be a string!")
		ok
	
		pcRuleName = UPPER(pcRuleName)

		# Check Constraint rules
		_nLen_ = len(@aConstraintRules)
		for i = 1 to _nLen_
			if @aConstraintRules[i][:name] = pcRuleName
				return TRUE
			ok
		next
	
		# Check Derivation rules
		_nLen_ = len(@aDerivationRules)
		for i = 1 to _nLen_
			if StzLower(@aDerivationRules[i][:name]) = pcRuleName
				return TRUE
			ok
		next
	
		# Check Validation rules
		_nLen_ = len(@aValidationRules)
		for i = 1 to _nLen_
			if StzLower(@aValidationRules[i][:name]) = pcRuleName
				return TRUE
			ok
		next
	
		return FALSE
	
		def ContainsRule(pcRuleName)
			return This.HasRule(pcRuleName)
	    
	    # List active rules
	    def ActiveRules()
	        _acAll_ = []
	        _nConstraintRules1Len_ = len(@aConstraintRules)
	        for _iLoopConstraintRules1_ = 1 to _nConstraintRules1Len_
	        	_aRule_ = @aConstraintRules[_iLoopConstraintRules1_]
	            _acAll_ + [:Constraint, _aRule_[:name]]
	        next
	        _nDerivationRules1Len_ = len(@aDerivationRules)
	        for _iLoopDerivationRules1_ = 1 to _nDerivationRules1Len_
	        	_aRule_ = @aDerivationRules[_iLoopDerivationRules1_]
	            _acAll_ + [:Derivation, _aRule_[:name]]
	        next
	        _nValidationRules1Len_ = len(@aValidationRules)
	        for _iLoopValidationRules1_ = 1 to _nValidationRules1Len_
	        	_aRule_ = @aValidationRules[_iLoopValidationRules1_]
	            _acAll_ + [:Validation, _aRule_[:name]]
	        next
	        return _acAll_

	#--------------#
	#  VALIDATION  #
	#--------------#

	def Validators()
		return @acValidators

	def Validate()
		return This.ValidateXT(@acValidators)

	def ValidateXT(paValidators)
		if isString(paValidators)
			return This._ValidateSingle(paValidators)
		but isList(paValidators)
			return This._ValidateMultiple(paValidators)
		ok

	def ValidateDAG()
		return This.ValidateXT(:DAG)

	def ValidateReachability()
		return This.ValidateXT(:Reachability)

	def ValidateCompleteness()
		return This.ValidateXT(:Completeness)

	def _ValidateSingle(pcValidator)
		_cValidator_ = StzLower(pcValidator)
		
		# Load rules (additive)
		This.UseRulesFrom(_cValidator_)
		
		# Run validation
		_aViolations_ = []
		_acRulesChecked_ = []
		
		_nLen_ = len(@aValidationRules)
		for i = 1 to _nLen_
			_aRule_ = @aValidationRules[i]
			_acRulesChecked_ + _aRule_[:name]
			
			pFunc = _aRule_[:function]
			paParams = _aRule_[:params]
			_aResult_ = call pFunc(This, paParams)
			
			_bValid_ = _aResult_[1]
			_cMessage_ = _aResult_[2]
			
			if NOT _bValid_
				_aViolations_ + [
					:rule = _aRule_[:name],
					:message = iif(_cMessage_ = "", _aRule_[:message], _cMessage_),
					:severity = _aRule_[:severity]
				]
			ok
		next
		
		if len(_aViolations_) > 0
			_acIssues_ = This._FlattenViolations(_aViolations_)
			_acAffected_ = This._ExtractAffectedNodes(_aViolations_)
			
			return [
				:status = "fail",
				:ruleGroup = _cValidator_,
				:issueCount = len(_aViolations_),
				:issues = _acIssues_,
				:affectedNodes = _acAffected_
			]
		ok
		
		# Add before final return in _ValidateSingle:
		_bValid_ = (len(_aViolations_) = 0)
		@aLastValidationResult = [_bValid_, _aViolations_, _acRulesChecked_]
		
		return [
			:status = "pass",
			:ruleGroup = _cValidator_,
			:issueCount = 0,
			:issues = [],
			:affectedNodes = []
		]
	
	def _ValidateMultiple(pacValidators)
		_aResults_ = []
		_nFailed_ = 0
		_nTotal_ = 0
		
		_nPacValidators1Len_ = len(pacValidators)
		for _iLoopPacValidators1_ = 1 to _nPacValidators1Len_
			_cValidator_ = pacValidators[_iLoopPacValidators1_]
			_aResult_ = This._ValidateSingle(_cValidator_)
			_aResults_ + _aResult_
			
			if _aResult_[:status] = "fail"
				_nFailed_++
			ok
			_nTotal_ += _aResult_[:issueCount]
		end
		
		return [
			:status = iif(_nFailed_ > 0, "fail", "pass"),
			:validatorsRun = len(pacValidators),
			:validatorsFailed = _nFailed_,
			:totalIssues = _nTotal_,
			:results = _aResults_,
			:affectedNodes = This._MergeAffectedNodes(_aResults_)
		]
	
	def _FlattenViolations(_aViolations_)
		_acIssues_ = []
		_nViolations2Len_ = len(_aViolations_)
		for _iLoopViolations2_ = 1 to _nViolations2Len_
			_aViolation_ = _aViolations_[_iLoopViolations2_]
			if HasKey(_aViolation_, :message)
				pMsg = _aViolation_[:message]
				
				if isList(pMsg)
					_nMsg2Len_ = len(pMsg)
					for _iLoopMsg2_ = 1 to _nMsg2Len_
						_aSubViolation_ = pMsg[_iLoopMsg2_]
						if isList(_aSubViolation_) and HasKey(_aSubViolation_, :message)
							_acIssues_ + _aSubViolation_[:message]
						but isString(_aSubViolation_)
							_acIssues_ + _aSubViolation_
						ok
					next
				but isString(pMsg)
					_acIssues_ + pMsg
				ok
			ok
		end
		return _acIssues_
	
	def _ExtractAffectedNodes(_aViolations_)
		_acNodes_ = []
		_nViolations1Len_ = len(_aViolations_)
		for _iLoopViolations1_ = 1 to _nViolations1Len_
			_aViolation_ = _aViolations_[_iLoopViolations1_]
			if HasKey(_aViolation_, :message)
				pMsg = _aViolation_[:message]
				
				if isList(pMsg)
					_nMsg1Len_ = len(pMsg)
					for _iLoopMsg1_ = 1 to _nMsg1Len_
						_aSubViolation_ = pMsg[_iLoopMsg1_]
						if isList(_aSubViolation_) and 
						   HasKey(_aSubViolation_, :params) and 
						   HasKey(_aSubViolation_[:params], :node)
							_cNode_ = _aSubViolation_[:params][:node]
							if StzFindFirst(_cNode_, _acNodes_) = 0
								_acNodes_ + _cNode_
							ok
						ok
					next
				ok
				
				if HasKey(_aViolation_, :params) and 
				   HasKey(_aViolation_[:params], :node)
					_cNode_ = _aViolation_[:params][:node]
					if StzFindFirst(_cNode_, _acNodes_) = 0
						_acNodes_ + _cNode_
					ok
				ok
			ok
		end
		return _acNodes_
	
	def _MergeAffectedNodes(_aResults_)
		_acAll_ = []
		_nResults1Len_ = len(_aResults_)
		for _iLoopResults1_ = 1 to _nResults1Len_
			_aResult_ = _aResults_[_iLoopResults1_]
			if HasKey(_aResult_, :affectedNodes)
				_aResultaffectedNodes1_ = _aResult_[:affectedNodes]
				_nResultaffectedNodes1Len_ = len(_aResultaffectedNodes1_)
				for _iLoopResultaffectedNodes1_ = 1 to _nResultaffectedNodes1Len_
					_cNode_ = _aResultaffectedNodes1_[_iLoopResultaffectedNodes1_]
					if StzFindFirst(_cNode_, _acAll_) = 0
						_acAll_ + _cNode_
					ok
				end
			ok
		end
		return _acAll_
	
	def ValidationSummary()
		if len(@aLastValidationResult) = 0
			return [:status = "not_run", :message = "No validation run yet"]
		ok
		
		_bValid_ = @aLastValidationResult[1]
		_aViolations_ = @aLastValidationResult[2]
		_acChecked_ = @aLastValidationResult[3]
		
		return [
			:status = iif(_bValid_, "pass", "fail"),
			:rules_applied = _acChecked_,
			:violations = _aViolations_,
			:violation_count = len(_aViolations_),
			:passed = _bValid_
		]
	
		def ValidationResult()
			return This.ValidationSummary()
	
		def Validation()
			return This.ValidationSummary()
	
		def ValidationXT()
			return This.ValidationSummary()

		def LastValidation()
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
		
		_aDiff_ = [
			:summary = This._CompareSummary(oOtherGraph),
			:nodes = This._CompareNodes(oOtherGraph),
			:edges = This._CompareEdges(oOtherGraph),
			:metrics = This._CompareMetrics(oOtherGraph),
			:topology = This._CompareTopology(oOtherGraph),
			:impact = This._CompareImpact(oOtherGraph),
			:explanation = This._GenerateExplanation(oOtherGraph)
		]
		
		return _aDiff_

		def DiffWith(oOtherGraph)
			return This.CompareWith(oOtherGraph)

		def Diff(oOtherGraph)
			return This.CompareWith(oOtherGraph)

	#-----------------------------#
	#  MULTIPLE GRAPH COMPARISON  #
	#-----------------------------#

	def CompareWithMany(paoGraphs)
		# Accept either list of graphs or hashlist with names
		_aGraphs_ = []
		
		if isList(paoGraphs) and len(paoGraphs) > 0
			if isList(paoGraphs[1]) and len(paoGraphs[1]) = 2 and isString(paoGraphs[1][1])
				# Hashlist format: [ ["name1", oGraph1], ["name2", oGraph2] ]
				_aGraphs_ = paoGraphs
			else
				# Simple list: auto-generate names
				_nLen_ = len(paoGraphs)
				for i = 1 to _nLen_
					_aGraphs_ + ["Variation_" + i, paoGraphs[i]]
				next
			ok
		ok
		
		if len(_aGraphs_) = 0
			stzraise("No graphs provided for comparison!")
		ok
		
		# Build comparison matrix
		_aComparisons_ = []
		_nLen_ = len(_aGraphs_)
		
		for i = 1 to _nLen_
			_cName_ = _aGraphs_[i][1]
			_oGraph_ = _aGraphs_[i][2]
			
			if NOT @IsStzGraph(_oGraph_)
				stzraise("Item " + i + " is not a valid stzGraph object!")
			ok
			
			_aDiff_ = This.CompareWith(_oGraph_)
			
			# Extract key metrics for tabular view
			_aRow_ = [
				:name = _cName_,
				:nodesAdded = _aDiff_[:summary][:nodesAdded],
				:nodesRemoved = _aDiff_[:summary][:nodesRemoved],
				:edgesAdded = _aDiff_[:summary][:edgesAdded],
				:edgesRemoved = _aDiff_[:summary][:edgesRemoved],
				:densityChange = _aDiff_[:metrics][:density][:change],
				:hasCycles = _aDiff_[:metrics][:hasCycles][:to],
				:bottleneckChange = _aDiff_[:topology][:bottlenecks][:change],
				:explanation = _aDiff_[:explanation][1]  # First explanation line
			]
			
			_aComparisons_ + _aRow_
		next
		
		_aResult_ = [
			:comparisons = _aComparisons_,
			:baseline = This.Id(),
			:count = len(_aComparisons_)
		]

		return _aResult_

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
		
		_aComparisons_ = aComparison[:comparisons]
		_nLen_ = len(_aComparisons_)
		
		# Build header row with variation names
		_aHeader_ = ["Metric"]
		for i = 1 to _nLen_
			_aHeader_ + _aComparisons_[i][:name]
		next
		
		# Build metric rows (transposed)
		_aTableData_ = [_aHeader_]
		
		# Nodes Added row
		_aRow_ = ["NodesAdded"]
		for i = 1 to _nLen_
			_aRow_ + _aComparisons_[i][:nodesAdded]
		next
		_aTableData_ + _aRow_
		
		# Nodes Removed row
		_aRow_ = ["NodesRemoved"]
		for i = 1 to _nLen_
			_aRow_ + _aComparisons_[i][:nodesRemoved]
		next
		_aTableData_ + _aRow_
		
		# Edges Added row
		_aRow_ = ["EdgesAdded"]
		for i = 1 to _nLen_
			_aRow_ + _aComparisons_[i][:edgesAdded]
		next
		_aTableData_ + _aRow_
		
		# Edges Removed row
		_aRow_ = ["EdgesRemoved"]
		for i = 1 to _nLen_
			_aRow_ + _aComparisons_[i][:edgesRemoved]
		next
		_aTableData_ + _aRow_
		
		# Density Change row
		_aRow_ = ["DensityChange"]
		for i = 1 to _nLen_
			_aRow_ + _aComparisons_[i][:densityChange]
		next
		_aTableData_ + _aRow_
		
		# Has Cycles row
		_aRow_ = ["HasCycles"]
		for i = 1 to _nLen_
			_aRow_ + _aComparisons_[i][:hasCycles]
		next
		_aTableData_ + _aRow_
		
		# Bottleneck Change row
		_aRow_ = ["BottleneckChange"]
		for i = 1 to _nLen_
			_aRow_ + _aComparisons_[i][:bottleneckChange]
		next
		_aTableData_ + _aRow_
		
		return _aTableData_

	#-----------------------------#
	#  GRAPH COMPARISON HELPERS   #
	#-----------------------------#

	def _CompareSummary(oOtherGraph)
		_acBaselineIds_ = This.NodesIds()
		_acVariationIds_ = oOtherGraph.NodesIds()
		
		_acAdded_ = []
		_acRemoved_ = []
		_nLen_ = len(_acVariationIds_)
		for i = 1 to _nLen_
			if StzFindFirst(_acBaselineIds_, _acVariationIds_[i]) = 0
				_acAdded_ + _acVariationIds_[i]
			ok
		next
		
		_nLen_ = len(_acBaselineIds_)
		for i = 1 to _nLen_
			if StzFindFirst(_acVariationIds_, _acBaselineIds_[i]) = 0
				_acRemoved_ + _acBaselineIds_[i]
			ok
		next
		
		# Count edge changes
		_aEdgeDiff_ = This._CompareEdges(oOtherGraph)
		
		# Count property changes
		_nPropsChanged_ = 0
		_aNodeDiff_ = This._CompareNodes(oOtherGraph)
		if HasKey(_aNodeDiff_, :modified)
			_nPropsChanged_ = len(_aNodeDiff_[:modified])
		ok
		
		return [
			:nodesAdded = len(_acAdded_),
			:nodesRemoved = len(_acRemoved_),
			:edgesAdded = len(_aEdgeDiff_[:added]),
			:edgesRemoved = len(_aEdgeDiff_[:removed]),
			:propertiesChanged = _nPropsChanged_
		]

	def _CompareNodes(oOtherGraph)
		_acBaselineIds_ = This.NodesIds()
		_acVariationIds_ = oOtherGraph.NodesIds()
		
		_acAdded_ = []
		_acRemoved_ = []
		_aModified_ = []
		
		# Find added nodes
		_nLen_ = len(_acVariationIds_)
		for i = 1 to _nLen_
			if StzFindFirst(_acBaselineIds_, _acVariationIds_[i]) = 0
				_acAdded_ + _acVariationIds_[i]
			ok
		next
		
		# Find removed nodes
		_nLen_ = len(_acBaselineIds_)
		for i = 1 to _nLen_
			if StzFindFirst(_acVariationIds_, _acBaselineIds_[i]) = 0
				_acRemoved_ + _acBaselineIds_[i]
			ok
		next
		
		# Find modified nodes (common nodes with property changes)
		_nLen_ = len(_acBaselineIds_)
		for i = 1 to _nLen_
			_cNodeId_ = _acBaselineIds_[i]
			if StzFindFirst(_cNodeId_, _acVariationIds_) > 0
				_aBaseNode_ = This.Node(_cNodeId_)
				_aVarNode_ = oOtherGraph.Node(_cNodeId_)
				
				_aChanges_ = []
				
				# Compare properties
				if HasKey(_aBaseNode_, :properties) or HasKey(_aVarNode_, :properties)
					_aBaseProps_ = []
					_aVarProps_ = []
					
					if HasKey(_aBaseNode_, :properties)
						_aBaseProps_ = _aBaseNode_[:properties]
					ok
					if HasKey(_aVarNode_, :properties)
						_aVarProps_ = _aVarNode_[:properties]
					ok
					
					# Check for changed/added properties
					_acVarKeys_ = keys(_aVarProps_)
					_nKeyLen_ = len(_acVarKeys_)
					for j = 1 to _nKeyLen_
						_cKey_ = _acVarKeys_[j]
						pVarVal = _aVarProps_[_cKey_]
						
						if HasKey(_aBaseProps_, _cKey_)
							pBaseVal = _aBaseProps_[_cKey_]
							if pBaseVal != pVarVal
								_aChanges_ + [:property, _cKey_, pBaseVal, pVarVal]
							ok
						else
							_aChanges_ + [:property, _cKey_, NULL, pVarVal]
						ok
					next
					
					# Check for removed properties
					_acBaseKeys_ = keys(_aBaseProps_)
					_nKeyLen_ = len(_acBaseKeys_)
					for j = 1 to _nKeyLen_
						_cKey_ = _acBaseKeys_[j]
						if NOT HasKey(_aVarProps_, _cKey_)
							_aChanges_ + [:property, _cKey_, _aBaseProps_[_cKey_], NULL]
						ok
					next
				ok
				
				if len(_aChanges_) > 0
					_aModified_ + [_cNodeId_, _aChanges_]
				ok
			ok
		next
		
		return [
			:added = _acAdded_,
			:removed = _acRemoved_,
			:modified = _aModified_
		]

	def _CompareEdges(oOtherGraph)

		# Diff edges by their IDENTITY -- "from -> to" -- exactly as
		# _CompareNodes diffs nodes by their id STRINGS.
		#
		# This used to take a set difference over the raw edge HASHLISTS.
		# It could never match anything: Ring's `=` on lists is false even
		# for structurally identical ones (verified: `[1,2] = [1,2]` -> 0,
		# and ring_find() over a list of hashlists finds nothing, not even
		# the very object it was handed). So every edge came back as BOTH
		# added AND removed, for any two graphs. .stzsim inherited the lie
		# whole: a simulation between two graphs emitted
		#     add edge ceo -> cfo
		#     remove edge ceo -> cfo
		# for an edge that had never moved -- and applying it then raised
		# "Edge already exists". Node ids carry no spaces (_IsWellFormedId),
		# so " -> " is an unambiguous key.

		_aMine_ = This.Edges()
		_aTheirs_ = oOtherGraph.Edges()

		_acMineKeys_ = []
		_nLen_ = len(_aMine_)
		for i = 1 to _nLen_
			_acMineKeys_ + ( _aMine_[i][:from] + " -> " + _aMine_[i][:to] )
		next

		_acTheirsKeys_ = []
		_nLen_ = len(_aTheirs_)
		for i = 1 to _nLen_
			_acTheirsKeys_ + ( _aTheirs_[i][:from] + " -> " + _aTheirs_[i][:to] )
		next

		# ADDED: in the other graph, not in this one
		_aAdded_ = []
		_nLen_ = len(_aTheirs_)
		for i = 1 to _nLen_
			if StzFindFirst(_acMineKeys_, _acTheirsKeys_[i]) = 0
				_aAdded_ + _aTheirs_[i]
			ok
		next

		# REMOVED: in this graph, not in the other
		_aRemoved_ = []
		_nLen_ = len(_aMine_)
		for i = 1 to _nLen_
			if StzFindFirst(_acTheirsKeys_, _acMineKeys_[i]) = 0
				_aRemoved_ + _aMine_[i]
			ok
		next

		# MODIFIED: the same edge, relabelled
		_aModified_ = []
		_nLen_ = len(_aMine_)
		for i = 1 to _nLen_
			_nAt_ = StzFindFirst(_acTheirsKeys_, _acMineKeys_[i])
			if _nAt_ > 0
				if _aMine_[i][:label] != _aTheirs_[_nAt_][:label]
					_aModified_ + [
						:edge = _acMineKeys_[i],
						:from = _aMine_[i][:label],
						:to = _aTheirs_[_nAt_][:label]
					]
				ok
			ok
		next

		_aResult_ = [
			:added = _aAdded_,
			:removed = _aRemoved_,
			:modified = _aModified_
		]

		return _aResult_

	def _CompareMetrics(oOtherGraph)
		# Node count
		_nBaseNodes_ = This.NodeCount()
		_nVarNodes_ = oOtherGraph.NodeCount()
		
		# Edge count
		_nBaseEdges_ = This.EdgeCount()
		_nVarEdges_ = oOtherGraph.EdgeCount()
		
		# Density
		_nBaseDensity_ = This.NodeDensity()
		_nVarDensity_ = oOtherGraph.NodeDensity()
		
		# Longest path
		_nBasePath_ = This.LongestPath()
		_nVarPath_ = oOtherGraph.LongestPath()
		
		# Cycles
		_bBaseCycles_ = This.HasCyclicDependencies()
		_bVarCycles_ = oOtherGraph.HasCyclicDependencies()
		
		# Average degree
		_nBaseAvgDegree_ = 0
		if _nBaseNodes_ > 0
			_nBaseAvgDegree_ = (_nBaseEdges_ * 2.0) / _nBaseNodes_
		ok
		_nVarAvgDegree_ = 0
		if _nVarNodes_ > 0
			_nVarAvgDegree_ = (_nVarEdges_ * 2.0) / _nVarNodes_
		ok
		
		return [
			:nodeCount = This._MetricChange(_nBaseNodes_, _nVarNodes_),
			:edgeCount = This._MetricChange(_nBaseEdges_, _nVarEdges_),
			:density = This._MetricChange(_nBaseDensity_, _nVarDensity_),
			:longestPath = This._MetricChange(_nBasePath_, _nVarPath_),
			:hasCycles = This._BooleanChange(_bBaseCycles_, _bVarCycles_),
			:avgDegree = This._MetricChange(_nBaseAvgDegree_, _nVarAvgDegree_)
		]

	def _CompareTopology(oOtherGraph)
		# Bottlenecks
		_acBaseBottlenecks_ = This.BottleneckNodes()
		_acVarBottlenecks_ = oOtherGraph.BottleneckNodes()
		_cBottleneckChange_ = "unchanged"
		_nDelta_ = len(_acVarBottlenecks_) - len(_acBaseBottlenecks_)
		if _nDelta_ > 0
			_cBottleneckChange_ = "increased"
		but _nDelta_ < 0
			_cBottleneckChange_ = "reduced"
		ok
		
		# Connected components
		_nBaseComponents_ = len(This.ConnectedComponents())
		_nVarComponents_ = len(oOtherGraph.ConnectedComponents())
		_cComponentChange_ = "unchanged"
		if _nVarComponents_ > _nBaseComponents_
			_cComponentChange_ = "fragmented"
		but _nVarComponents_ < _nBaseComponents_
			_cComponentChange_ = "merged"
		ok
		
		# Isolated nodes
		_acBaseIsolated_ = []
		_acBaseIds_ = This.NodesIds()
		_nLen_ = len(_acBaseIds_)
		for i = 1 to _nLen_
			_cName_ = _acBaseIds_[i]
			if len(This.Neighbors(_cName_)) = 0 and len(This.Incoming(_cName_)) = 0
				_acBaseIsolated_ + _cName_
			ok
		next
		
		_acVarIsolated_ = []
		_acVarIds_ = oOtherGraph.NodesIds()
		_nLen_ = len(_acVarIds_)
		for i = 1 to _nLen_
			_cName_ = _acVarIds_[i]
			if len(oOtherGraph.Neighbors(_cName_)) = 0 and len(oOtherGraph.Incoming(_cName_)) = 0
				_acVarIsolated_ + _cName_
			ok
		next
		
		_cIsolatedChange_ = "unchanged"
		if len(_acVarIsolated_) > len(_acBaseIsolated_)
			_cIsolatedChange_ = "increased"
		but len(_acVarIsolated_) < len(_acBaseIsolated_)
			_cIsolatedChange_ = "reduced"
		ok
		
		return [
			:bottlenecks = [
				:from = _acBaseBottlenecks_,
				:to = _acVarBottlenecks_,
				:change = _cBottleneckChange_,
				:delta = _nDelta_
			],
			:connectedComponents = [
				:from = _nBaseComponents_,
				:to = _nVarComponents_,
				:change = _cComponentChange_
			],
			:isolatedNodes = [
				:from = _acBaseIsolated_,
				:to = _acVarIsolated_,
				:change = _cIsolatedChange_
			]
		]

	def _CompareImpact(oOtherGraph)
		_acReachabilityChanges_ = []
		_acCriticalityChanges_ = []
		
		# Compare reachability for common nodes
		_acBaseIds_ = This.NodesIds()
		_acVarIds_ = oOtherGraph.NodesIds()
		
		_nLen_ = len(_acBaseIds_)
		for i = 1 to _nLen_
			_cNodeId_ = _acBaseIds_[i]
			
			# Only analyze nodes that exist in both graphs
			if StzFindFirst(_cNodeId_, _acVarIds_) > 0
				# Check reachability changes
				_acBaseReachable_ = This.ReachableFrom(_cNodeId_)
				_acVarReachable_ = oOtherGraph.ReachableFrom(_cNodeId_)
				
				if len(_acVarReachable_) > len(_acBaseReachable_)
					_nDiff_ = len(_acVarReachable_) - len(_acBaseReachable_)
					_acReachabilityChanges_ + [_cNodeId_, "Can now reach " + _nDiff_ + " more node(s)"]

				but len(_acVarReachable_) < len(_acBaseReachable_)
					_nDiff_ = len(_acBaseReachable_) - len(_acVarReachable_)
					_acReachabilityChanges_ + [_cNodeId_, "Can now reach " + _nDiff_ + " fewer node(s)"]
				ok
				
				# Check criticality (degree) changes
				_nBaseDegree_ = len(This.Neighbors(_cNodeId_)) + len(This.Incoming(_cNodeId_))
				_nVarDegree_ = len(oOtherGraph.Neighbors(_cNodeId_)) + len(oOtherGraph.Incoming(_cNodeId_))
				
				if _nVarDegree_ > _nBaseDegree_
					_acCriticalityChanges_ + [_cNodeId_, "Criticality increased (degree " + _nBaseDegree_ + " " + @cArrowRight + " " + _nVarDegree_ + ")"]
				but _nVarDegree_ < _nBaseDegree_
					_acCriticalityChanges_ + [_cNodeId_, "Criticality decreased (degree " + _nBaseDegree_ + " " + @cArrowRight + " " + _nVarDegree_ + ")"]
				ok
			ok
		next
		
		# Check for newly added critical nodes
		_nLen_ = len(_acVarIds_)
		for i = 1 to _nLen_
			_cNodeId_ = _acVarIds_[i]
			if StzFindFirst(_cNodeId_, _acBaseIds_) = 0
				_nDegree_ = len(oOtherGraph.Neighbors(_cNodeId_)) + len(oOtherGraph.Incoming(_cNodeId_))
				if _nDegree_ >= 3
					_acCriticalityChanges_ + [_cNodeId_, "New critical node (degree " + _nDegree_ + ")"]
				ok
			ok
		next
		
		return [
			:reachabilityChanges = _acReachabilityChanges_,
			:criticalityChanges = _acCriticalityChanges_
		]

	def _GenerateExplanation(oOtherGraph)
		_acExplanation_ = []
		
		_aSummary_ = This._CompareSummary(oOtherGraph)
		_aMetrics_ = This._CompareMetrics(oOtherGraph)
		_aTopology_ = This._CompareTopology(oOtherGraph)
		
		# Structural changes
		if _aSummary_[:nodesAdded] > 0 or _aSummary_[:edgesAdded] > 0
			_cMsg_ = ""
			if _aSummary_[:nodesAdded] > 0 and _aSummary_[:edgesAdded] > 0
				_cMsg_ = "Added " + _aSummary_[:nodesAdded] + " node(s) and " + _aSummary_[:edgesAdded] + " edge(s)"
			but _aSummary_[:nodesAdded] > 0
				_cMsg_ = "Added " + _aSummary_[:nodesAdded] + " node(s)"
			but _aSummary_[:edgesAdded] > 0
				_cMsg_ = "Added " + _aSummary_[:edgesAdded] + " edge(s)"
			ok
			_acExplanation_ + _cMsg_
		ok
		
		if _aSummary_[:nodesRemoved] > 0 or _aSummary_[:edgesRemoved] > 0
			_cMsg_ = ""
			if _aSummary_[:nodesRemoved] > 0 and _aSummary_[:edgesRemoved] > 0
				_cMsg_ = "Removed " + _aSummary_[:nodesRemoved] + " node(s) and " + _aSummary_[:edgesRemoved] + " edge(s)"
			but _aSummary_[:nodesRemoved] > 0
				_cMsg_ = "Removed " + _aSummary_[:nodesRemoved] + " node(s)"
			but _aSummary_[:edgesRemoved] > 0
				_cMsg_ = "Removed " + _aSummary_[:edgesRemoved] + " edge(s)"
			ok
			_acExplanation_ + _cMsg_
		ok
		
		if _aSummary_[:propertiesChanged] > 0
			_acExplanation_ + ("Modified " + _aSummary_[:propertiesChanged] + " node propertie(s)")
		ok
		
		# Metrics changes
		if _aMetrics_[:density][:change] != "unchanged"
			_acExplanation_ + ("Density " + _aMetrics_[:density][:change])
		ok
		
		# Topology changes
		if _aTopology_[:bottlenecks][:change] != "unchanged"
			if _aTopology_[:bottlenecks][:change] = "reduced"
				_acExplanation_ + ("Bottlenecks reduced (improvement)")
			else
				_acExplanation_ + ("Bottlenecks " + _aTopology_[:bottlenecks][:change])
			ok
		ok
		
		# Cycles
		if _aMetrics_[:hasCycles][:from] = FALSE and _aMetrics_[:hasCycles][:to] = TRUE
			_acExplanation_ + "Warning: Cycles introduced"
		but _aMetrics_[:hasCycles][:from] = TRUE and _aMetrics_[:hasCycles][:to] = FALSE
			_acExplanation_ + "Cycles removed (now acyclic)"
		ok
		
		# Connectivity
		if _aTopology_[:connectedComponents][:change] = "fragmented"
			_acExplanation_ + "Warning: Graph became fragmented"
		but _aTopology_[:connectedComponents][:change] = "merged"
			_acExplanation_ + "Components merged (better connectivity)"
		ok
		
		if len(_acExplanation_) = 0
			_acExplanation_ + "No significant changes detected"
		ok
		
		return _acExplanation_

	def _MetricChange(pFrom, pTo)
		_nDelta_ = pTo - pFrom
		_cChange_ = This._CalculateChange(pFrom, pTo)
		
		return [
			:from = pFrom,
			:to = pTo,
			:change = _cChange_,
			:delta = _nDelta_
		]

	def _BooleanChange(bFrom, bTo)
		_cChange_ = "unchanged"
		if bFrom != bTo
			if bTo
				_cChange_ = "now TRUE"
			else
				_cChange_ = "now FALSE"
			ok
		ok
		
		return [
			:from = iff(bFrom, "TRUE", "FALSE"),
			:to = iff(bTo, "TRUE", "FALSE"),
			:change = _cChange_
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
			
			_nDelta_ = pTo - pFrom
			_nPercent_ = (_nDelta_ / pFrom) * 100
			
			if _nPercent_ > 0.5
				return "+" + _nPercent_ + "%"
			but _nPercent_ < -0.5
				return ""+ _nPercent_ + "%"
			else
				return "unchanged"
			ok
		ok
		
		return "unchanged"
	
	#=======================================#
	#  SERIALIZATION - FILE FORMAT SUPPORT  #
	#=======================================#
	
	def LoadFrom(pcPath)
		_cExtension_ = @split(pcPath, ".")[2]

		switch _cExtension_
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
		_cExtension_ = @split(pcPath, ".")[2]

		switch _cExtension_
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
		_cOutput_ = 'graph "' + @cId + '"' + NL
		_cOutput_ += '    type: ' + @cGraphType + NL + NL
		
		# Nodes section
		#
		# A node carries its LABEL the same way an edge does -- quoted,
		# after the id:  ceo "CEO". Written only when it says something
		# the id does not, so a file of plain ids stays a file of plain
		# ids (and every .stzgraf written before labels existed still
		# reads).
		_cOutput_ += "nodes" + NL
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_cOutput_ += "    " + @aNodes[i][:id]
			if @aNodes[i][:label] != "" and @aNodes[i][:label] != @aNodes[i][:id]
				_cOutput_ += ' "' + @aNodes[i][:label] + '"'
			ok
			_cOutput_ += NL
		next
		_cOutput_ += NL
		
		# Edges section
		_cOutput_ += "edges" + NL
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			_cOutput_ += "    " + _aEdge_[:from] + " -> " + _aEdge_[:to]
			if _aEdge_[:label] != ""
				_cOutput_ += ' "' + _aEdge_[:label] + '"'
			ok
			_cOutput_ += NL
		next
		
		# Properties section
		if This._HasNodeProperties()
			_cOutput_ += NL + "properties" + NL
			_nLen_ = len(@aNodes)
			for i = 1 to _nLen_
				_aNode_ = @aNodes[i]
				if HasKey(_aNode_, :properties) and len(_aNode_[:properties]) > 0
					_cOutput_ += "    " + _aNode_[:id] + NL
					_aProps_ = _aNode_[:properties]
					_acKeys_ = keys(_aProps_)
					_nKeyLen_ = len(_acKeys_)
					for j = 1 to _nKeyLen_
						_cKey_ = _acKeys_[j]
						pVal = _aProps_[_cKey_]
						_cOutput_ += "        " + _cKey_ + ": " + This._FormatValue(pVal) + NL
					next
					_cOutput_ += NL
				ok
			next
		ok
		
		return _cOutput_
	
		def ToStzGraf()
			return This.ExportToStzGraf()
	
		def AsStzGraf()
			return This.ExportToStzGraf()
	
	def SaveToStzGraf(pcPath)
		_cContent_ = This.ExportToStzGraf()
		write(pcPath, _cContent_)
	
		def SaveAsStzGraf(pcPath)
			This.SaveToStzGraf(pcPath)
	
	def LoadFromStzGraf(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		_cContent_ = read(pcPath)
		This._ParseStzGraf(_cContent_)
	
		def LoadStzGraf(pcPath)
			This.LoadFromStzGraf(pcPath)
	
	def _ParseStzGraf(_cContent_)
		# Clear current graph
		@aNodes = []
		@aEdges = []
		
		_acLines_ = split(_cContent_, NL)
		_cSection_ = ""
		_cCurrentNode_ = ""
		_nLen_ = len(_acLines_)
		
		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			
			if _cLine_ = "" or StzLeft(_cLine_, 1) = "#"
				loop
			ok

			# Parse graph declaration
			if StzLeft(_cLine_, 5) = "graph"
				_nPos_ = StzFindFirst('"', _cLine_)
				if _nPos_ > 0
					_cQuoted_ = StzMid(_cLine_, _nPos_ + 1, stzlen(_cLine_) - _nPos_)
					_nEnd_ = StzFindFirst('"', _cQuoted_)
					if _nEnd_ > 0
						@cId = StzMid(_cQuoted_, 1, _nEnd_ - 1)
					ok
				ok
				loop
			ok

			# Parse type
			if StzFindFirst("type:", _cLine_) > 0
				_nPos_ = StzFindFirst(":", _cLine_)
				@cGraphType = trim(StzMid(_cLine_, _nPos_ + 1, stzlen(_cLine_) - _nPos_))
				loop
			ok
			
			# Section headers
			if _cLine_ = "nodes"
				_cSection_ = "nodes"
				loop

			but _cLine_ = "edges"
				_cSection_ = "edges"
				loop

			but _cLine_ = "properties"
				_cSection_ = "properties"
				loop
			ok
			
			# Parse content based on section
			if _cSection_ = "nodes"
				_cNodeId_ = trim(_cLine_)
				if _cNodeId_ != ""
					# An optional quoted LABEL may follow the id, as on an
					# edge:   ceo "CEO"
					_nQuote_ = StzFindFirst('"', _cNodeId_)
					if _nQuote_ > 0
						_cNodeLabel_ = StzMid(_cNodeId_, _nQuote_ + 1, stzlen(_cNodeId_) - _nQuote_)
						_nEndQuote_ = StzFindFirst('"', _cNodeLabel_)
						if _nEndQuote_ > 0
							_cNodeLabel_ = StzMid(_cNodeLabel_, 1, _nEndQuote_ - 1)
						ok
						_cNodeId_ = trim(StzMid(_cNodeId_, 1, _nQuote_ - 1))
						This.AddNodeXT(_cNodeId_, _cNodeLabel_)
					else
						This.AddNode(_cNodeId_)
					ok
				ok

			but _cSection_ = "edges"
				if StzFindFirst("->", _cLine_) > 0
					_acParts_ = @split(_cLine_, "->")
					if len(_acParts_) >= 2
						_cFrom_ = trim(_acParts_[1])
						_cRest_ = trim(_acParts_[2])

						# Check for label in quotes
						_nQuote_ = StzFindFirst('"', _cRest_)
						if _nQuote_ > 0
							_cTo_ = trim(StzMid(_cRest_, 1, _nQuote_ - 1))
							_cLabel_ = StzMid(_cRest_, _nQuote_ + 1, stzlen(_cRest_) - _nQuote_)
							_nEndQuote_ = StzFindFirst('"', _cLabel_)
							if _nEndQuote_ > 0
								_cLabel_ = StzMid(_cLabel_, 1, _nEndQuote_ - 1)
								This.AddEdgeXT(_cFrom_, _cTo_, _cLabel_)
							else
								This.AddEdge(_cFrom_, _cTo_)
							ok
						else
							_cTo_ = _cRest_
							This.AddEdge(_cFrom_, _cTo_)
						ok
					ok
				ok
				
			but _cSection_ = "properties"
				# INDENT tells a node name from one of its properties:
				#
				#     properties
				#         warehouse_ny          <- 4 spaces: the node
				#             capacity: 50000   <- 8 spaces: its property
				#
				# This used to be counted by walking the line char by char
				# with StzMid(line, j, 2) -- which asks for TWO chars and so
				# never equalled " ", leaving the indent stuck at 0. Every
				# property line was then read as a node NAME, and no property
				# was ever set: LoadFromStzGraf() returned "" for every one of
				# them (test 83 recorded exactly that, "Should return 50000
				# but returned ''"). Count with the engine instead -- and a
				# per-char loop in a class method is a VM-corruption trap
				# besides.

				_nIndent_ = stzlen(_acLines_[i]) - stzlen(StzTrimLeft(_acLines_[i]))

				if _nIndent_ <= 4
					_cCurrentNode_ = trim(_cLine_)
				else
					# Property line
					if StzFindFirst(":", _cLine_) > 0
						_acParts_ = @split(_cLine_, ":")
						if len(_acParts_) >= 2
							_cKey_ = trim(_acParts_[1])
							_cVal_ = trim(_acParts_[2])
							pValue = This._ParseValue(_cVal_)
							This.SetNodeProperty(_cCurrentNode_, _cKey_, pValue)
						ok
					ok
				ok
			ok
		next
	
	#------------------#
	#  .stzrulz FORMAT #
	#------------------#
	
	def ExportToStzRulz()
		_cOutput_ = 'ruleset "' + @cId + ' Rules"' + NL
		_cOutput_ += '    ruleGroup: ' + @cGraphType + NL
		_cOutput_ += '    version: 1.0' + NL + NL
		
		_cOutput_ += "rules" + NL + NL
		
		_aRules_ = This.Rules()
		_nLen_ = len(_aRules_)
		for i = 1 to _nLen_
			_aRule_ = _aRules_[i]

			_cOutput_ += "    rule " + _aRule_[:name] + NL
			_cOutput_ += "        type: " + _aRule_[:type] + NL
			_cOutput_ += "        severity: " + _aRule_[:severity] + NL
			_cOutput_ += "        function: " + This._GetFunctionName(_aRule_[:function]) + NL
			
			if len(_aRule_[:params]) > 0
				_cOutput_ += "        params" + NL
				_aParams_ = _aRule_[:params]
				_acKeys_ = keys(_aParams_)
				_nKeyLen_ = len(_acKeys_)
				for j = 1 to _nKeyLen_
					_cKey_ = _acKeys_[j]
					pVal = _aParams_[_cKey_]
					_cOutput_ += "            " + _cKey_ + ": " + This._FormatValue(pVal) + NL
				next
			ok
			
			_cOutput_ += "        message" + NL
			_cOutput_ += '            "' + _aRule_[:message] + '"' + NL
			_cOutput_ += NL
		next
		
		return _cOutput_
	
		def ToStzRulz()
			return This.ExportToStzRulz()
	
		def AsStzRulz()
			return This.ExportToStzRulz()
	
	def SaveToStzRulz(pcPath)
		_cContent_ = This.ExportToStzRulz()
		write(pcPath, _cContent_)
	
		def SaveAsStzRulz(pcPath)
			This.SaveToStzRulz(pcPath)
	
	def LoadFromStzRulz(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		_cContent_ = read(pcPath)
		This._ParseStzRulz(_cContent_)
	
		def LoadStzRulz(pcPath)
			This.LoadFromStzRulz(pcPath)
	
	def _ParseStzRulz(_cContent_)
		# Loads rule properties and links to functions from .stzrulf files
		_acLines_ = split(_cContent_, NL)
		_cSection_ = ""
		_aCurrentRule_ = []
		_cCurrentKey_ = ""
		_nLen_ = len(_acLines_)
		
		for i = 1 to _nLen_
			_cLine_ = _acLines_[i]
			_cTrimmed_ = trim(_cLine_)
			
			if _cTrimmed_ = "" or StzLeft(_cTrimmed_, 1) = "#"
				loop
			ok

			if _cTrimmed_ = "rules"
				_cSection_ = "rules"
				loop
			ok

			if _cSection_ = "rules"
				if StzLeft(_cTrimmed_, 4) = "rule"
					# Save previous rule
					if len(_aCurrentRule_) > 0
						This._AdmitParsedRule(_aCurrentRule_)
					ok

					# Start new rule
					_cName_ = trim(StzMid(_cTrimmed_, 6, stzlen(_cTrimmed_) - 5))
					_aCurrentRule_ = [
						:name = _cName_,
						:type = "",
						:function = "",
						:params = [],
						:message = "",
						:severity = ""
					]

				but StzFindFirst("type:", _cTrimmed_) = 1
					_aCurrentRule_[:type] = trim(StzMid(_cTrimmed_, 6, stzlen(_cTrimmed_) - 5))

				but StzFindFirst("severity:", _cTrimmed_) = 1
					_aCurrentRule_[:severity] = trim(StzMid(_cTrimmed_, 11, stzlen(_cTrimmed_) - 10))

				but StzFindFirst("function:", _cTrimmed_) = 1
					_cFuncName_ = trim(StzMid(_cTrimmed_, 11, stzlen(_cTrimmed_) - 10))
					_aCurrentRule_[:function] = This._ResolveFunctionName(_cFuncName_)

				but _cTrimmed_ = "params"
					_cCurrentKey_ = "params"

				but _cTrimmed_ = "message"
					_cCurrentKey_ = "message"

				but _cCurrentKey_ = "params" and StzFindFirst(":", _cTrimmed_) > 0
					_acParts_ = @split(_cTrimmed_, ":")
					if len(_acParts_) >= 2
						_cKey_ = trim(_acParts_[1])
						_cVal_ = trim(_acParts_[2])
						_aCurrentRule_[:params][_cKey_] = This._ParseValue(_cVal_)
					ok
					
				but _cCurrentKey_ = "message"
					_cMsg_ = trim(_cTrimmed_)
					if StzLeft(_cMsg_, 1) = '"' and StzRight(_cMsg_, 1) = '"'
						_cMsg_ = StzMid(_cMsg_, 2, stzlen(_cMsg_) - 2)
					ok
					_aCurrentRule_[:message] = _cMsg_
				ok
			ok
		next
		
		# Save last rule
		if len(_aCurrentRule_) > 0
			This._AdmitParsedRule(_aCurrentRule_)
		ok

	def _AdmitParsedRule(_aRule_)
		# A rule read off a FILE goes in by the same door as a rule read off
		# a rule group -- _AddUniqueRule types it and dedups it. The one
		# thing we add here is that a file can be malformed in a way a
		# registration cannot: an unknown (or missing) type. Say so, loudly.
		# _AddUniqueRule would simply not route it, and the rule would go
		# missing without a word.

		if NOT This._IsKnownRuleType(_aRule_[:type])
			stzraise("Unknown rule type '" + _aRule_[:type] + "' for rule '" +
				 _aRule_[:name] + "' -- expected constraint, derivation or validation.")
		ok

		This._AddUniqueRule(_aRule_)

	#------------------#
	#  .stzrulf FORMAT #
	#------------------#
	
	def LoadRuleFunctionsFrom(pcPath)
		# A .stzrulf file is pure Ring code: it defines custom rule
		# functions and registers them into a rule group, which
		# UseRulesFrom() then pulls into this graph.
		#
		# `load pcPath` CANNOT do this. Ring's load is a COMPILE-TIME
		# directive, so handing it a variable is silently a no-op -- this
		# method used to report success while defining nothing and
		# registering nothing (verified: isfunction() -> 0 and the rule
		# groups unchanged, right after a "successful" call). Going
		# through eval() makes load see a literal at ITS compile time,
		# which is the only way to reach a path known at run time.
		#
		# NOTE for .stzrulf authors: put the RegisterRuleInGroup() calls
		# ABOVE the func definitions. In Ring, statements written after a
		# func belong to that func's body -- register below and the
		# registration never runs.

		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok

		if StzFindFirst("'", pcPath) > 0
			stzraise("A .stzrulf path may not contain a quote: " + pcPath)
		ok

		# Load it ONCE per process. A .stzrulf defines functions, and
		# defining one twice is C22 "Function redefinition" -- a COMPILE
		# error try/catch cannot catch, which takes the program down. Two
		# graphs asking for the same custom rules is ordinary, so a repeat
		# load is a quiet no-op: the functions are already here, and the
		# rules are already in their group for UseRulesFrom() to pull.

		_cKey_ = StzLower("" + pcPath)
		if ring_find($acStzRulfLoaded, _cKey_) > 0
			return
		ok
		$acStzRulfLoaded + _cKey_

		eval("load '" + pcPath + "'")

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
	
	def _ResolveFunctionName(_cFuncName_)
		# Resolve function name to actual function object
		if _cFuncName_ = "DerivationFunc_Transitivity"
			return DerivationFunc_Transitivity()

		but _cFuncName_ = "DerivationFunc_Symmetry"
			return DerivationFunc_Symmetry()

		but _cFuncName_ = "DerivationFunc_Hierarchy"
			return DerivationFunc_Hierarchy()

		but _cFuncName_ = "ConstraintFunc_NoSelfLoop"
			return ConstraintFunc_NoSelfLoop()

		but _cFuncName_ = "ConstraintFunc_MaxDegree"
			return ConstraintFunc_MaxDegree()

		but _cFuncName_ = "ConstraintFunc_NoCycles"
			return ConstraintFunc_NoCycles()

		but _cFuncName_ = "ConstraintFunc_Separation"
			return ConstraintFunc_Separation()

		but _cFuncName_ = "ConstraintFunc_PropertyMismatch"
			return ConstraintFunc_PropertyMismatch()

		but _cFuncName_ = "ValidationFunc_IsAcyclic"
			return ValidationFunc_IsAcyclic()

		but _cFuncName_ = "ValidationFunc_IsConnected"
			return ValidationFunc_IsConnected()

		but _cFuncName_ = "ValidationFunc_MaxNodes"
			return ValidationFunc_MaxNodes()

		but _cFuncName_ = "ValidationFunc_DensityRange"
			return ValidationFunc_DensityRange()

		but _cFuncName_ = "ValidationFunc_NoBottlenecks"
			return ValidationFunc_NoBottlenecks()

		but _cFuncName_ = "ValidationFunc_AllNodesReachable"
			return ValidationFunc_AllNodesReachable()

		else
			stzraise("Can't resolve function name!")
		ok
	
	#------------------#
	#  .stzsim FORMAT  #
	#------------------#
	
	def ExportToStzSim(oBaselineGraph)
		_cOutput_ = 'simulation "' + @cId + ' Comparison"' + NL
		_cOutput_ += '    description: "Changes from baseline"' + NL
		_cOutput_ += '    date: ' + Date() + NL + NL
		
		# Compare and generate changes
		_aDiff_ = oBaselineGraph.CompareWith(This)
		
		_cOutput_ += "changes" + NL + NL
		
		# Node changes
		_aNodeDiff_ = _aDiff_[:nodes]
		
		if len(_aNodeDiff_[:added]) > 0
			_nLen_ = len(_aNodeDiff_[:added])
			for i = 1 to _nLen_
				_cNodeId_ = _aNodeDiff_[:added][i]
				_aNode_ = This.Node(_cNodeId_)
				_cOutput_ += "    add node " + _cNodeId_ + NL
				_cOutput_ += '        label: "' + _aNode_[:label] + '"' + NL
			next
			_cOutput_ += NL
		ok
		
		if len(_aNodeDiff_[:removed]) > 0
			_nLen_ = len(_aNodeDiff_[:removed])
			for i = 1 to _nLen_
				_cOutput_ += "    remove node " + _aNodeDiff_[:removed][i] + NL
			next
			_cOutput_ += NL
		ok
		
		# Edge changes
		_aEdgeDiff_ = _aDiff_[:edges]
		
		if len(_aEdgeDiff_[:added]) > 0
			_nLen_ = len(_aEdgeDiff_[:added])
			for i = 1 to _nLen_
				_aEdge_ = _aEdgeDiff_[:added][i]
				_cOutput_ += "    add edge " + _aEdge_[:from] + " -> " + _aEdge_[:to] + NL
			next
			_cOutput_ += NL
		ok
		
		if len(_aEdgeDiff_[:removed]) > 0
			_nLen_ = len(_aEdgeDiff_[:removed])
			for i = 1 to _nLen_
				_aEdge_ = _aEdgeDiff_[:removed][i]
				_cOutput_ += "    remove edge " + _aEdge_[:from] + " -> " + _aEdge_[:to] + NL
			next
			_cOutput_ += NL
		ok
		
		# Metrics section
		_cOutput_ += "metrics" + NL + NL
		_aMetrics_ = _aDiff_[:metrics]
		
		_cOutput_ += "    density: " + _aMetrics_[:density][:from] + " -> " + _aMetrics_[:density][:to] + NL
		_cOutput_ += "    nodeCount: " + _aMetrics_[:nodeCount][:from] + " -> " + _aMetrics_[:nodeCount][:to] + NL
		_cOutput_ += "    edgeCount: " + _aMetrics_[:edgeCount][:from] + " -> " + _aMetrics_[:edgeCount][:to] + NL
		_cOutput_ += "    hasCycles: " + _aMetrics_[:hasCycles][:from] + " -> " + _aMetrics_[:hasCycles][:to] + NL
		
		return _cOutput_
	
		def ToStzSim(oBaselineGraph)
			return This.ExportToStzSim(oBaselineGraph)
	
		def AsStzSim(oBaselineGraph)
			return This.ExportToStzSim(oBaselineGraph)
	
	def SaveToStzSim(pcPath, oBaselineGraph)
		_cContent_ = This.ExportToStzSim(oBaselineGraph)
		write(pcPath, _cContent_)
	
		def SaveAsStzSim(pcPath, oBaselineGraph)
			This.SaveToStzSim(pcPath, oBaselineGraph)
	
	def ApplySimulation(cSimContent)
		# Parse and apply changes from .stzsim format
		_acLines_ = split(cSimContent, NL)
		_cSection_ = ""
		_cSimNode_ = ""      # the node most recently added -- a label line follows it
		_nLen_ = len(_acLines_)
		
		for i = 1 to _nLen_
			_cLine_ = _acLines_[i]
			_cTrimmed_ = trim(_cLine_)
			
			if _cTrimmed_ = "" or StzLeft(_cTrimmed_, 1) = "#"
				loop
			ok

			if _cTrimmed_ = "changes"
				_cSection_ = "changes"
				loop
			but _cTrimmed_ = "metrics"
				exit  # Stop at metrics section
			ok

			if _cSection_ = "changes"
				if StzFindFirst("add node ", _cTrimmed_) = 1
					_cNodeId_ = trim(StzMid(_cTrimmed_, 10, stzlen(_cTrimmed_) - 9))
					if NOT This.NodeExists(_cNodeId_)
						This.AddNode(_cNodeId_)
					ok
					_cSimNode_ = _cNodeId_

				# ExportToStzSim WRITES a label under every added node:
				#
				#     add node risk_officer
				#         label: "Risk Officer"
				#
				# ... and nothing here ever read it back, so a simulation
				# round-trip quietly renamed the node to its id. The label
				# belongs to the node just named above.

				but StzFindFirst("label:", _cTrimmed_) = 1 and _cSimNode_ != ""
					_cLbl_ = trim(StzMid(_cTrimmed_, 7, stzlen(_cTrimmed_) - 6))
					if StzLeft(_cLbl_, 1) = '"' and StzRight(_cLbl_, 1) = '"'
						_cLbl_ = StzMid(_cLbl_, 2, stzlen(_cLbl_) - 2)
					ok
					if _cLbl_ != "" and This.NodeExists(_cSimNode_)
						This.SetNodeLabel(_cSimNode_, _cLbl_)
					ok

				but StzFindFirst("remove node ", _cTrimmed_) = 1
					_cNodeId_ = trim(StzMid(_cTrimmed_, 13, stzlen(_cTrimmed_) - 12))
					if This.NodeExists(_cNodeId_)
						This.RemoveThisNode(_cNodeId_)
					ok

				but StzFindFirst("add edge ", _cTrimmed_) = 1
					_cRest_ = trim(StzMid(_cTrimmed_, 10, stzlen(_cTrimmed_) - 9))
					if StzFindFirst("->", _cRest_) > 0
						_acParts_ = split(_cRest_, "->")
						if len(_acParts_) >= 2
							_cFrom_ = trim(_acParts_[1])
							_cTo_ = trim(_acParts_[2])
							# An edge already there is nothing to do -- AddEdge
							# RAISES on a duplicate, and a simulation must be
							# applyable to a graph that already has part of it
							# (the same guard `add node` has always had).
							if This.NodeExists(_cFrom_) and This.NodeExists(_cTo_)
								if NOT This.EdgeExists(_cFrom_, _cTo_)
									This.AddEdge(_cFrom_, _cTo_)
								ok
							ok
						ok
					ok
					
				but StzFindFirst("remove edge ", _cTrimmed_) = 1
					_cRest_ = trim(StzMid(_cTrimmed_, 13, stzlen(_cTrimmed_) - 12))
					if StzFindFirst("->", _cRest_) > 0
						_acParts_ = @split(_cRest_, "->")
						if len(_acParts_) >= 2
							_cFrom_ = trim(_acParts_[1])
							_cTo_ = trim(_acParts_[2])
							This.RemoveThisEdge(_cFrom_, _cTo_)
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
		_nLen_ = len(@aNodes)

		for i = 1 to _nLen_
			if HasKey(@aNodes[i], :properties) and len(@aNodes[i][:properties]) > 0
				return TRUE
			ok
		next

		return FALSE
	
	def _FormatValue(pValue)
		if isString(pValue)
			if StzFindFirst(" ", pValue) > 0 or StzFindFirst(":", pValue) > 0
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
	
	def _ParseValue(_cValue_)
		_cValue_ = trim(_cValue_)
		
		# Remove quotes if present
		if StzLeft(_cValue_, 1) = '"' and
		   StzRight(_cValue_, 1) = '"'

			return StzMid(_cValue_, 2, stzlen(_cValue_) - 2)
		ok

		# Try to parse as number
		#
		# Ring's isdigit() judges ONE CHARACTER, so isdigit("50000") is
		# FALSE (verified) and this branch never fired: every numeric
		# property came back as a STRING -- capacity "50000", not 50000.
		# Test 83 has said so all along ("Should return 50000"). The
		# library's own predicate reads a whole string, decimals and a
		# leading minus included; it calls "" a number, so guard that.

		if _cValue_ != "" and StzIsNumberOrNumberInString(_cValue_)
			return 0 + _cValue_
		ok

		# Try to parse as boolean
		if StzLower(_cValue_) = "true"
			return TRUE

		but StzLower(_cValue_) = "false"
			return FALSE
		ok

		# Try to parse as list
		if StzLeft(_cValue_, 1) = "[" and StzRight(_cValue_, 1) = "]"

			_cInner_ = StzMid(_cValue_, 2, stzlen(_cValue_) - 2)
			if _cInner_ = ""
				return []
			ok

			_acParts_ = @split(_cInner_, ",")
			_aResult_ = []
			_nLen_ = len(_acParts_)
			for i = 1 to _nLen_
				_aResult_ + This._ParseValue(trim(_acParts_[i]))
			next
			return _aResult_
		ok
		
		# Default: return as string
		return _cValue_
	
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
		pcLabel = StzReplace(pcLabel, " ", "_")
		pcLabel = StzReplace(pcLabel, NL, "_")
		return pcLabel

		def  _NormaliseLabel(pcLabel)
			return StzReplace(pcLabel, " ", "_")

	def _IsWellFormedId(pcName)
		if NOT isString(pcName)
			return 0
		ok

		if StzFindFirst(" ", pcName) > 0
			return 0
		ok

		if StzFindFirst(NL, pcName) > 0
			return 0
		ok

		return 1

class stzGraphFinder from stzObject
	# Basic Finder of Nodes ane Edges
	# Used by the FindQ() method in stzGraph
	# For advanced queries use stzGraphQuery class

	@oGraph
	@cTarget
	@aFilters = []
	
	def init(_oGraph_, _cTarget_)
		@oGraph = _oGraph_
		@cTarget = StzLower(_cTarget_)
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
		_acResult_ = []
		_aNodes_ = @oGraph.Nodes()
		
		_nNodes1Len_ = len(_aNodes_)
		for _iLoopNodes1_ = 1 to _nNodes1Len_
			_aNode_ = _aNodes_[_iLoopNodes1_]
			if This._NodeMatches(_aNode_)
				_acResult_ + _aNode_[:id]
			ok
		end
		
		return _acResult_
	
	def _QueryEdges()
		_acResult_ = []
		_aEdges_ = @oGraph.Edges()
		
		_nEdges1Len_ = len(_aEdges_)
		for _iLoopEdges1_ = 1 to _nEdges1Len_
			_aEdge_ = _aEdges_[_iLoopEdges1_]
			if This._EdgeMatches(_aEdge_)
				_acResult_ + [ _aEdge_[:from], _aEdge_[:to] ]
			ok
		end
		return _acResult_
	
	def _NodeMatches(_aNode_)
		_nFilters2Len_ = len(@aFilters)
		for _iLoopFilters2_ = 1 to _nFilters2Len_
			_aFilter_ = @aFilters[_iLoopFilters2_]
			_cType_ = _aFilter_[1]
			
			if _cType_ = :where
				pcKey = _aFilter_[2]
				pCondition = _aFilter_[3]
				pValue = _aFilter_[4]
				
				pActual = This._GetNestedValue(_aNode_, pcKey)
				if pActual = ""
					return FALSE
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return FALSE
				ok
				
			but _cType_ = :hasprop
				pcKey = _aFilter_[2]
				if This._GetNestedValue(_aNode_, pcKey) = ""
					return FALSE
				ok
				
			but _cType_ = :tag
				pcTag = _aFilter_[2]
				if NOT HasKey(_aNode_, "properties") or 
				   NOT HasKey(_aNode_["properties"], "tags") or
				   StzFindFirst(pcTag, _aNode_["properties"]["tags"]) = 0
					return FALSE
				ok
			ok
		end
		return TRUE
	
	def _EdgeMatches(_aEdge_)
		_nFilters1Len_ = len(@aFilters)
		for _iLoopFilters1_ = 1 to _nFilters1Len_
			_aFilter_ = @aFilters[_iLoopFilters1_]
			_cType_ = _aFilter_[1]
			
			if _cType_ = :where
				pcKey = _aFilter_[2]
				pCondition = _aFilter_[3]
				pValue = _aFilter_[4]
				
				pActual = This._GetNestedValue(_aEdge_, pcKey)
				if pActual = ""
					return FALSE
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return FALSE
				ok
				
			but _cType_ = :hasprop
				pcKey = _aFilter_[2]
				if This._GetNestedValue(_aEdge_, pcKey) = ""
					return FALSE
				ok
				
			but _cType_ = :tag
				pcTag = _aFilter_[2]
				if NOT HasKey(_aEdge_, "properties") or 
				   NOT HasKey(_aEdge_["properties"], "tags") or
				   StzFindFirst(pcTag, _aEdge_["properties"]["tags"]) = 0
					return FALSE
				ok
			ok
		end
		return TRUE
	
	def _GetNestedValue(aElement, pcKey)
		_bIsNested_ = (StzFindFirst(".", pcKey) > 0)
		
		if _bIsNested_
			_acPath_ = split(pcKey, ".")
			pValue = aElement
			
			if HasKey(aElement, _acPath_[1])
				pValue = aElement[_acPath_[1]]
				_nPathLen_3 = len(_acPath_)
				for i = 2 to _nPathLen_3
					if isList(pValue) and HasKey(pValue, _acPath_[i])
						pValue = pValue[_acPath_[i]]
					else
						return "" # TODO Is it safer to raise an error?
					ok
				end
				return pValue
				
			but HasKey(aElement, "properties")
				pValue = aElement["properties"]
				_nPathLen_2 = len(_acPath_)
				for i = 1 to _nPathLen_2
					if isList(pValue) and HasKey(pValue, _acPath_[i])
						pValue = pValue[_acPath_[i]]
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
		_cCond_ = StzLower(pCondition)
		
		if _cCond_ = "equals" or _cCond_ = ":equals" or _cCond_ = "="
			return pActual = pValue
			
		but _cCond_ = "greaterthan" or _cCond_ = ":greaterthan" or _cCond_ = ">"
			return isNumber(pActual) and isNumber(pValue) and pActual > pValue
			
		but _cCond_ = "lessthan" or _cCond_ = ":lessthan" or _cCond_ = "<"
			return isNumber(pActual) and isNumber(pValue) and pActual < pValue
			
		but _cCond_ = "contains" or _cCond_ = ":contains"
			return isString(pActual) and isString(pValue) and 
			       StzFindFirst(StzLower(pValue), StzLower(pActual)) > 0
			       
		but _cCond_ = "insection" or _cCond_ = ":insection" or _cCond_ = "between" or _cCond_ = ":between"
			return isNumber(pActual) and isList(pValue) and len(pValue) = 2 and
			       pActual >= pValue[1] and pActual <= pValue[2]
		ok
		return FALSE


class stzGraphAsciiVisualizer from stzObject
	@oGraph

	@cBoxTopLeft = char(226) + char(149) + char(173)   # U+256D
	@cBoxTopRight = char(226) + char(149) + char(174)   # U+256E
	@cBoxBottomLeft = char(226) + char(149) + char(176)   # U+2570
	@cBoxBottomRight = char(226) + char(149) + char(175)   # U+256F
	@cBoxHorizontal = char(226) + char(148) + char(128)   # U+2500
	@cBoxVertical = char(226) + char(148) + char(130)   # U+2502
	@cArrowDown = "v"
	@cArrowUp = char(226) + char(134) + char(145)   # U+2191
	@cPipeChar = "|"
	@cBranchSeparator = "////"
	@cCycleIndicator = "CYCLE"
	@cConnectorDash = "-"
	@cConnectorArrow = ">"
	
	# The art can be RETURNED, not only printed.
	#
	# Every line used to go straight to `?`, so a graph's picture could only
	# ever land on a console: it could not be written to a file, put in a
	# report, served, or ASSERTED ON -- which is exactly how the box glyphs
	# stayed double-encoded for months while printing garbage without ever
	# raising. stzFolder settled this long ago with GenerateVizTreeString();
	# the graph gets the same courtesy. Show() still prints, byte for byte.
	@bCapture = FALSE
	@cBuffer = ""

	def init(poGraph)
		@oGraph = poGraph

	# Prints, or buffers -- the ONE door every line of the art goes through.
	def _Emit(pcLine)
		if @bCapture
			@cBuffer += pcLine + NL
		else
			? pcLine
		ok

	# The art as DATA -- the vertical picture, as a string.
	def AsciiArt()
		return This._Captured(:vertical)

	# ... and the horizontal one.
	def AsciiArtHorizontal()
		return This._Captured(:horizontal)

	def _Captured(pcMode)
		@bCapture = TRUE
		@cBuffer = ""

		if pcMode = :horizontal
			This.ShowHorizontal()
		else
			This.Show()
		ok

		@bCapture = FALSE
		return @cBuffer
	
	def Show()
		_acDisplayNodes_ = This._PrepareDisplayNodes()
		This._ShowVerticalWithNodes(_acDisplayNodes_)
	
	def ShowVertical()
		This.Show()
	
		def ShowV()
			This.Show()
	
	def ShowHorizontal()
		_acDisplayNodes_ = This._PrepareDisplayNodes()
		This._ShowHorizontalWithNodes(_acDisplayNodes_)
	
		def ShowH()
			This.ShowHorizontal()
	
	def _PrepareDisplayNodes()
		_acBottlenecks_ = @oGraph.BottleneckNodes()
		_acDisplayNodes_ = []
		
		_acNodes_ = @oGraph.Nodes()
		_nLen_ = len(_acNodes_)
		for i = 1 to _nLen_
			_aNode_ = _acNodes_[i]
			_aDisplayNode_ = [
				:id = _aNode_["id"],
				:label = _aNode_["label"],
				:properties = _aNode_["properties"]
			]
			
			_cLabel_ = _aNode_["label"]
			_bIsBottleneck_ = StzFindFirst(_acBottlenecks_, _aNode_["id"]) > 0
			
			if _bIsBottleneck_
				_aDisplayNode_["label"] = "!" + _cLabel_ + "!"
			ok
			
			_acDisplayNodes_ + _aDisplayNode_
		end
		
		return _acDisplayNodes_
	
	def _GetDisplayLabel(pcNodeId, pacDisplayNodes)
		_nLen_ = len(pacDisplayNodes)
		for i = 1 to _nLen_
			_aNode_ = pacDisplayNodes[i]
			if _aNode_["id"] = pcNodeId
				return _aNode_["label"]
			ok
		end
		return ""
	
	def _ShowVerticalWithNodes(pacDisplayNodes)
		_acRoots_ = []
		_acNodes_ = @oGraph.Nodes()
		_nNodeCount_ = len(_acNodes_)
		for i = 1 to _nNodeCount_
			_aNode_ = _acNodes_[i]
			if len(@oGraph.Incoming(_aNode_["id"])) = 0
				_acRoots_ + _aNode_["id"]
			ok
		end
		
		if len(_acRoots_) = 0
			_acRoots_ + _acNodes_[1]["id"]
		ok
		
		_nRootIdx_ = 0
		_nLen_ = len(_acRoots_)
		for i = 1 to _nLen_
			_cRoot_ = _acRoots_[i]
			_nRootIdx_ += 1
			_acVisitedPath_ = []
			This._ShowVerticalBranchWithNodes(_cRoot_, _acVisitedPath_, 0, pacDisplayNodes)
			
			if _nRootIdx_ < _nLen_
				This._Emit("")
				This._Emit("          ////")
				This._Emit("")
			ok
		end
	
	def _ShowVerticalBranchWithNodes(pcNodeId, pacVisitedPath, pnBranchDepth, pacDisplayNodes)
		_cDisplayLabel_ = This._GetDisplayLabel(pcNodeId, pacDisplayNodes)
		_cBoxed_ = BoxRound(_cDisplayLabel_)
		_acLines_ = @split(_cBoxed_, nl)
		_nLen_ = len(_acLines_)
		
		for i = 1 to _nLen_
			_cLine_ = _acLines_[i]
			This._Emit(CenterAlignXT(_cLine_, 25, " "))
		end
		
		pacVisitedPath + pcNodeId
		_acNeighbors_ = @oGraph.Neighbors(pcNodeId)
		
		if len(_acNeighbors_) = 0
			return
		ok
		
		_nNeighborIdx_ = 0
		_nLen_ = len(_acNeighbors_)
		for i = 1 to _nLen_
			_cNext_ = _acNeighbors_[i]
			_nNeighborIdx_ += 1
			
			if StzFindFirst(_cNext_, pacVisitedPath) = 0
				_aEdge_ = @oGraph.Edge(pcNodeId, _cNext_)
				
				if len(_acNeighbors_) > 1 and _nNeighborIdx_ > 1
					This._Emit("")
					This._Emit("          ////")
					This._Emit("")
					_cDisplayLabel_ = This._GetDisplayLabel(pcNodeId, pacDisplayNodes)
					_cBoxed_ = BoxRound(_cDisplayLabel_)
					_acLines_ = @split(_cBoxed_, nl)
					_nLen2_ = len(_acLines_)
					
					for j = 1 to _nLen2_
						_cLine_ = _acLines_[j]
						if j = 1
							_cTempLine_ = CenterAlignXT(_cLine_, 25, " ")
							_cTempLine_ = TrimRight(_cTempLine_) + "  " + @cArrowUp
							This._Emit(_cTempLine_)
						but j = 2
							_cTempLine_ = CenterAlignXT(_cLine_, 25, " ")
							_cTempLine_ = TrimRight(_cTempLine_) + @cBoxHorizontal + @cBoxHorizontal + @cBoxBottomRight
							This._Emit(_cTempLine_)
						else
							This._Emit(CenterAlignXT(_cLine_, 25, " "))
						ok
					end
				ok
				
				This._Emit(CenterAlignXT(@cPipeChar, 25, " "))
				if _aEdge_["label"] != ""
					This._Emit(CenterAlignXT(_aEdge_["label"], 25, " "))
					This._Emit(CenterAlignXT(@cPipeChar, 25, " "))
				ok
				This._Emit(CenterAlignXT(@cArrowDown, 25, " "))
				
				_acCopyPath_ = pacVisitedPath
				This._ShowVerticalBranchWithNodes(_cNext_, _acCopyPath_, pnBranchDepth + 1, pacDisplayNodes)
				
			else
				_aEdge_ = @oGraph.Edge(pcNodeId, _cNext_)
				_cNodeLabel_ = This._GetDisplayLabel(_cNext_, pacDisplayNodes)
				_cEdgeLabel_ = ""
				if _aEdge_ != NULL and isString(_aEdge_["label"])
					_cEdgeLabel_ = _aEdge_["label"]
				ok
				
				This._Emit("            |            ")
				This._Emit("      <" + @cCycleIndicator + ": " + _cEdgeLabel_ + ">   ")
				This._Emit("            |                      " + @cArrowUp)
				This._Emit("            " + @cBoxBottomLeft + @cBoxHorizontal + @cBoxHorizontal + "> [" + _cNodeLabel_ + "] " + @cBoxHorizontal + @cBoxHorizontal + @cBoxBottomRight)
			ok
		end
	
	def _ShowHorizontalWithNodes(pacDisplayNodes)
		_acRoots_ = []
	
		_acNodes_ = @oGraph.Nodes()
		_nLen_ = len(_acNodes_)
		for i = 1 to _nLen_
			_aNode_ = _acNodes_[i]
			if len(@oGraph.Incoming(_aNode_["id"])) = 0
				_acRoots_ + _aNode_["id"]
			ok
		end
		
		if len(_acRoots_) = 0
			_acRoots_ + _acNodes_[1]["id"]
		ok
		
		_nLen_ = len(_acRoots_)
		for i = 1 to _nLen_
			_cRoot_ = _acRoots_[i]
			_acVisited_ = []
			_acBoxLines_ = []
			_acArrowLines_ = []
			This._ShowHorizontalBranchWithNodes(_cRoot_, _acVisited_, _acBoxLines_, _acArrowLines_, pacDisplayNodes)
			
			_nLen2_ = len(_acBoxLines_)
			for j = 1 to _nLen2_
				This._Emit(_acBoxLines_[j])
			end
		end
	
	def _ShowHorizontalBranchWithNodes(pcNodeId, pacVisited, pacBoxLines, pacArrowLines, pacDisplayNodes)
		_cDisplayLabel_ = This._GetDisplayLabel(pcNodeId, pacDisplayNodes)
		_cBoxed_ = BoxRound(_cDisplayLabel_)
		_acLines_ = @split(_cBoxed_, nl)
		
		_acNeighbors_ = @oGraph.Neighbors(pcNodeId)
		
		if len(pacBoxLines) = 0
			_nLen_ = len(_acLines_)
			for i = 1 to _nLen_
				pacBoxLines + _acLines_[i]
			end
		else
			_cConnector_ = ""
			if len(pacVisited) > 0
				_cPrev_ = pacVisited[len(pacVisited)]
				_aEdge_ = @oGraph.Edge(_cPrev_, pcNodeId)
				if _aEdge_ != ""
					_cConnector_ = @cConnectorDash + @cConnectorDash + _aEdge_["label"] + @cConnectorDash + @cConnectorDash + @cConnectorArrow
				ok
			ok
			
			_nLen_ = len(_acLines_)
			for i = 1 to _nLen_
				if i = 2
					pacBoxLines[i] += _cConnector_ + _acLines_[i]
				else
					pacBoxLines[i] += RepeatChar(" ", stzlen(_cConnector_)) + _acLines_[i]
				ok
			end
		ok
		
		pacVisited + pcNodeId
		
		if len(_acNeighbors_) > 0
			_cNext_ = _acNeighbors_[1]
			_aEdge_ = @oGraph.Edge(pcNodeId, _cNext_)
			
			if StzFindFirst(_cNext_, pacVisited) = 0
				This._ShowHorizontalBranchWithNodes(_cNext_, pacVisited, pacBoxLines, pacArrowLines, pacDisplayNodes)
			else
				pacArrowLines + [pcNodeId, _cNext_, _aEdge_["label"]]
			ok
		ok

class stzGraphComparison from stzObject
	@oBaselineGraph
	@aGraphs = []
	@aComparisonData = []
	# Built from raw UTF-8 bytes -- see @cArrowRight in stzGraph.
	@cBullet = char(226) + char(128) + char(162)   # U+2022

	
	def init(oBaseline, paoGraphs)
		@oBaselineGraph = oBaseline
		
		# Normalize input
		if isList(paoGraphs) and len(paoGraphs) > 0
			if isList(paoGraphs[1]) and len(paoGraphs[1]) = 2 and isString(paoGraphs[1][1])
				@aGraphs = paoGraphs
			else
				_nLen_ = len(paoGraphs)
				for i = 1 to _nLen_
					@aGraphs + ["V" + i, paoGraphs[i]]
				next
			ok
		ok
		
		# Perform comparisons
		This._BuildComparisons()
	
	def _BuildComparisons()
		@aComparisonData = @oBaselineGraph.CompareWithMany(@aGraphs)
	
	def ToStzTable()
		_aTableData_ = @oBaselineGraph._ToStzTableData(@aComparisonData)
		return new stzTable(_aTableData_)
	
		def AsStzTable()
			return This.ToStzTable()
	
		def AsTable()
			return This.ToStzTable()
	
	def Show()
		_oTable_ = This.ToStzTable()
		_oTable_.Show()
	
		def Display()
			This.Show()
	
	def Data()
		return @aComparisonData
	
		def Content()

	def Comparisons()
		return @aComparisonData[:comparisons]
	
	def Summary()
		_cResult_ = ""
		_cResult_ += "Baseline: " + @aComparisonData[:baseline] + NL
		_cResult_ += "Variations compared: " + @aComparisonData[:count] + NL + NL
		
		_aComps_ = @aComparisonData[:comparisons]
		_nLen_ = len(_aComps_)
		
		for i = 1 to _nLen_
			_aComp_ = _aComps_[i]
			_cResult_ += @cBullet + " " + _aComp_[:name] + ": " + _aComp_[:explanation] + NL
		next
		
		return _cResult_
	
	def MostImpactful()
		# Returns variation with most total changes
		_aComps_ = @aComparisonData[:comparisons]
		_nMaxImpact_ = 0
		_cMaxName_ = ""
		
		_nLen_ = len(_aComps_)
		for i = 1 to _nLen_
			_aComp_ = _aComps_[i]
			_nImpact_ = _aComp_[:nodesAdded] + _aComp_[:nodesRemoved] + 
			          _aComp_[:edgesAdded] + _aComp_[:edgesRemoved]
			
			if _nImpact_ > _nMaxImpact_
				_nMaxImpact_ = _nImpact_
				_cMaxName_ = _aComp_[:name]
			ok
		next
		
		return _cMaxName_
	
	def LeastImpactful()
		# Returns variation with fewest total changes
		_aComps_ = @aComparisonData[:comparisons]
		_nMinImpact_ = 999999
		_cMinName_ = ""
		
		_nLen_ = len(_aComps_)
		for i = 1 to _nLen_
			_aComp_ = _aComps_[i]
			_nImpact_ = _aComp_[:nodesAdded] + _aComp_[:nodesRemoved] + 
			          _aComp_[:edgesAdded] + _aComp_[:edgesRemoved]
			
			if _nImpact_ < _nMinImpact_
				_nMinImpact_ = _nImpact_
				_cMinName_ = _aComp_[:name]
			ok
		next
		
		return _cMinName_
	
	def WithCycles()
		# Returns names of variations that introduce cycles
		_aComps_ = @aComparisonData[:comparisons]
		_acResult_ = []
		
		_nLen_ = len(_aComps_)
		for i = 1 to _nLen_
			if _aComps_[i][:hasCycles] = TRUE
				_acResult_ + _aComps_[i][:name]
			ok
		next
		
		return _acResult_
	
	def WithoutCycles()
		# Returns names of variations that remain acyclic
		_aComps_ = @aComparisonData[:comparisons]
		_acResult_ = []
		
		_nLen_ = len(_aComps_)
		for i = 1 to _nLen_
			if _aComps_[i][:hasCycles] = FALSE
				_acResult_ + _aComps_[i][:name]
			ok
		next
		
		return _acResult_
	
	def ByMetric(cMetric)
		# Sort variations by specified metric
		# Supported: :nodesAdded, :edgesAdded, etc.
		_aComps_ = @aComparisonData[:comparisons]
		
		if NOT HasKey(_aComps_[1], cMetric)
			stzraise("Unknown metric: " + cMetric)
		ok
		
		# Simple bubble sort
		_nLen_ = len(_aComps_)
		for i = 1 to _nLen_ - 1
			for j = i + 1 to _nLen_
				if _aComps_[j][cMetric] > _aComps_[i][cMetric]
					_aTemp_ = _aComps_[i]
					_aComps_[i] = _aComps_[j]
					_aComps_[j] = _aTemp_
				ok
			next
		next
		
		_acResult_ = []
		_nLen_ = len(_aComps_)
		for i = 1 to _nLen_
			_acResult_ + _aComps_[i][:name]
		next
		
		return _acResult_
	
	def Recommend()
		# Simple recommendation logic
		_aComps_ = @aComparisonData[:comparisons]
		
		# Find variation with:
		# - No cycles
		# - Positive density change
		# - Reduced bottlenecks
		
		_nBestScore_ = -999
		_cBestName_ = ""
		
		_nLen_ = len(_aComps_)
		for i = 1 to _nLen_
			_aComp_ = _aComps_[i]
			_nScore_ = 0
			
			# No cycles: +10
			if _aComp_[:hasCycles] = FALSE
				_nScore_ += 10
			ok
			
			# Reduced bottlenecks: +5
			if _aComp_[:bottleneckChange] = "reduced"
				_nScore_ += 5
			ok
			
			# Positive density change: +3
			_cDensity_ = _aComp_[:densityChange]
			if isString(_cDensity_) and StzFindFirst("+", _cDensity_) > 0
				_nScore_ += 3
			ok
			
			# Fewer nodes removed than added: +2
			if _aComp_[:nodesRemoved] < _aComp_[:nodesAdded]
				_nScore_ += 2
			ok
			
			if _nScore_ > _nBestScore_
				_nBestScore_ = _nScore_
				_cBestName_ = _aComp_[:name]
			ok
		next
		
		return [
			:recommended = _cBestName_,
			:reason = "Best balance of structure, connectivity, and acyclicity"
		]
