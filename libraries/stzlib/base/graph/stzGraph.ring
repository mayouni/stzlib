#============================================#
#  stzGraph - Complete Implementation        #
#  Simplified rules, all methods preserved   #
#============================================#

# The file contains some other classes used by the main class:
# stzGraphFinder, stzGraphAsciiVisualizer, and stzGraphComparison

#TODO Abstract the simulation feature in a distinc stzGraphSimulator class

$acGraphTypes = ["structural", "flow", "semantic", "dependency"]
$cDefaultGraphType = "structural"

# "bottleneck" joined this list when the bottleneck rule left :completeness
# for a group named after what it measures (see stzGraphRule.ring). Adding it
# here is what keeps the move behaviour-neutral for a default Validate():
# the same properties are still checked, each now under an honest name.
$acGraphDefaultValidators = ["dag", "reachability", "completeness", "bottleneck"]

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

# Holds a directed graph of named nodes and labelled edges, and answers questions about its paths, metrics, rules and changes.
#
# A node has an id (folded to lowercase, no space), a label and properties; an edge runs from one
# node to another with a label and properties. The graph is simple: a second edge between the same
# ordered pair is refused. Paths, components and the centrality metrics run in the engine, on a copy
# that is rebuilt after most changes (a few removal methods do not refresh it, see their warnings).
# Rules come in two forms: the three typed stores filled by UseRulesFrom, and attached stzGraphRule
# objects judged by CheckRules. The graph reads and writes .stzgraf, .stzrulz and .stzsim files and
# writes DOT, JSON, YAML and GraphML; reading GraphML back is broken today. Many methods fold an id
# to lowercase and some do not (the removals, Incoming, SetNodeProperty), so ids are safest given in
# lowercase. The file also holds stzGraphFinder, stzGraphAsciiVisualizer and stzGraphComparison,
# which the graph builds for you. A number of methods carry a warning today.
#
#   receiver   o1 = new stzGraph("g1"); o1.AddNodeXT("a", "Alpha"); o1.AddNodeXT("b", "Beta");
#              o1.AddNodeXT("c", "Gamma"); o1.Connect("a", "b"); o1.Connect("b", "c")
#   example    ? @@( o1.ShortestPath("a", "c") )
#              #--> [ "a", "b", "c" ]
#   see        stzGraphFinder, stzGraphComparison, stzKnowledgeGraph, stzGraphRule
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
	@pNodeIdx = ""
	@nNodeIdxCount = -1
	@bNodeIdxStale = 1

	# Same story for edges, and this one was the bigger half. EdgeExists
	# walked every edge -- calling StzLower on BOTH arguments inside the loop,
	# so two engine calls per edge examined -- and AddEdge asks it about an
	# edge that by definition is NOT there yet, so every add scanned the whole
	# list. Adding E edges was O(E^2).
	@pEdgeIdx = ""
	@nEdgeIdxCount = -1
	@bEdgeIdxStale = 1

	# Simplified rule storage - rules as hashlists
	@aConstraintRules = []
	@aDerivationRules = []
	@aValidationRules = []
	@aAffectedNodes = []
	@aAffectedEdges = []

	# The graph's OWN object-rules (stzGraphRule) -- the Softanza orientation:
	# a rule is attached to the graph and becomes part of ITS logic, so you
	# check/report from the graph (g.AddRule(r); g.CheckRules(); g.RulesReport()),
	# never rule.Check(g). A lazily-created stzGraphRuleSet holds them.
	@oOwnRuleSet = ""

	@acValidators = $acGraphDefaultValidators

	@aProperties = []

	@bEnforceConstraints = 1
	@bAutoDerive = 0 # Default: manual derivation

	@aLastValidationResult = []

	@pEngineGraph = ""
	@bEngineStale = 1

	# The arrow the path/impact explanations draw with, built from RAW
	# UTF-8 BYTES so the source stays pure-ASCII. Written as a literal it
	# gets double-encoded the next time an editor reads the file as cp1252
	# and re-saves it as UTF-8 -- which had already happened here: every
	# explanation printed a garbled run instead of an arrow.
	@cArrowRight = char(226) + char(134) + char(146)   # U+2192

	# Builds an empty graph with the given id, folded to lowercase; an id holding a space or a line break raises an error.
	#
	#   pcName     the graph id, as text, without spaces or line breaks
	#   returns    nothing; the object is built
	#   note       the graph starts as type "structural", with no node and no edge
	#   see        Id, SetGraphType
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

	# Public doorway to the engine-resident graph, so a collaborator (the
	# graphics face, a future analytics face) can hand the HANDLE to an
	# engine metric instead of marshalling a copy of the adjacency.
	def HasEngine()
		return This._EnsureEngine()

	# Returns the handle of the engine graph that backs the fast algorithms, building it first when it is missing or out of date.
	#
	#   returns    the engine handle
	#   note       the handle is rebuilt after most changes, so ask again instead of keeping it
	#   see        Neighbors, PathExists
	def EngineHandle()
		This._EnsureEngine()
		return @pEngineGraph

	def _InvalidateEngine()
		@bEngineStale = 1

	def _FreeEngine()
		if @pEngineGraph != ""
			StzEngineGraphFree(@pEngineGraph)
			@pEngineGraph = ""
		ok
		@bEngineStale = 1

	def _EnsureEngine()
		if NOT This._EngineAvailable()
			return 0
		ok

		if @pEngineGraph != "" and NOT @bEngineStale
			return 1
		ok

		if @pEngineGraph != ""
			StzEngineGraphFree(@pEngineGraph)
			@pEngineGraph = ""
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

		@bEngineStale = 0
		return 1

	# Returns an independent graph holding the same nodes and edges; adding or removing nodes in it never reaches the original.
	#
	#   returns    a stzGraph
	#   see        Id
	def Copy()
		_oCopy_ = This
		_oCopy_._DetachEngineCaches()
		return _oCopy_

	# A COPY MUST NOT INHERIT THE ORIGINAL'S ENGINE CACHES.
	#
	# @pNodeIdx, @pEdgeIdx and @pEngineGraph are engine HANDLES. Ring copies
	# them by value, so a plain copy ends up sharing the original's index
	# while owning its own @aNodes -- and AddNodeXTT writes new keys straight
	# into that shared map. A node added to the COPY therefore appeared to
	# exist in the ORIGINAL:
	#
	#     oVar = oBase.Copy()
	#     oVar.AddNodeXT("risk_officer", "Risk Officer")
	#     oBase.NodeExists("risk_officer")   --> 1, on a graph of two nodes
	#
	# The staleness check cannot catch it: it compares @nNodeIdxCount against
	# len(@aNodes), and both are still 2 on the original. Only the shared map
	# grew.
	#
	# How it surfaced: ApplySimulation asked NodeExists before adding, was
	# told the node was already there, skipped the AddNode -- and SetNodeLabel,
	# which scans @aNodes honestly, then raised "Node 'risk_officer' does not
	# exist." The error named the one place that was telling the truth.
	#
	# The handles are dropped, not freed: the ORIGINAL still owns them and
	# frees them. Both sides now rebuild lazily from their own lists, which
	# also closes the double-free that two owners of one handle imply.
	def _DetachEngineCaches()
		@pNodeIdx = ""
		@nNodeIdxCount = -1
		@bNodeIdxStale = 1

		@pEdgeIdx = ""
		@nEdgeIdxCount = -1
		@bEdgeIdxStale = 1

		@pEngineGraph = ""
		@bEngineStale = 1

	# Returns the id the graph was given, in lowercase.
	#
	#   returns    text
	#   see        Name, SetGraphType
	def Id()
		return @cId

		# Returns the graph id, the same text as the id accessor.
		#
		#   returns    text
		#   see        Id
		def Name()
			return @cId

	# Returns the graph type: "structural" until SetGraphType says otherwise.
	#
	#   returns    text
	#   see        SetGraphType, CyclesAllowed
	def GraphType()
		return @cGraphType

	# Sets the graph type, folded to lowercase; any text is accepted, but only structural, flow and semantic change the checks.
	#
	#   returns    nothing; the graph changes
	#   see        GraphType, CyclesAllowed, ShouldAutoDerive
	def SetGraphType(pcType)
		@cGraphType = StzLower(pcType)

	# TRUE if the receiver is a graph, which a stzGraph always is.
	#
	#   returns    TRUE
	#   see        IsStzGraph
	def IsGraph()
		return 1

		# TRUE if the receiver is a graph, spelled with an article; always TRUE for a stzGraph.
		#
		#   returns    TRUE
		#   see        IsGraph
		def IsAGraph()
			return 1

		# TRUE if the receiver is a stzGraph, which it always is; the test tells graphs from other objects.
		#
		#   returns    TRUE
		#   see        IsGraph
		def IsStzGraph()
			return 1
	
		# TRUE if the receiver is a stzGraph, spelled with an article; always TRUE here.
		#
		#   returns    TRUE
		#   see        IsStzGraph
		def IsAStzGraph()
			return 1
	
		# TRUE if the receiver is a stzGraph object; always TRUE for a graph.
		#
		#   returns    TRUE
		#   see        IsStzGraph
		def IsStzGraphObject()
			return 1
	
		# TRUE if the receiver is a stzGraph object, spelled with an article; always TRUE here.
		#
		#   returns    TRUE
		#   see        IsStzGraphObject
		def IsAStzGraphObject()
			return 1
	
		# TRUE if the receiver is a graph object; always TRUE for a stzGraph.
		#
		#   returns    TRUE
		#   see        IsGraph
		def IsGraphObject()
			return 1
	
		# TRUE if the receiver is a graph object, spelled with an article; always TRUE here.
		#
		#   returns    TRUE
		#   see        IsGraphObject
		def IsAGraphObject()
			return 1

	#-------------------#
	#  NODE OPERATIONS  #
	#-------------------#

	# Adds a node labelled with its own id at the end of the node list; an id already in use is added again without complaint.
	#
	#   pcNodeId   the node id, folded to lowercase
	#   returns    nothing; the graph changes
	#   note       for a label or properties call AddNodeXT or AddNodeXTT
	#   warning    the id is not checked against the existing nodes, so a second node with the same
	#              id is appended
	#   see        AddNodes, NodeExists
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
		if @pNodeIdx != "" and NOT @bNodeIdxStale
			if @nNodeIdxCount = len(@aNodes) - 1
				StzEngineHashMapPutInt(@pNodeIdx, _aNode_[:id], len(@aNodes))
				@nNodeIdxCount = len(@aNodes)
			ok
		ok

		# Push the node into the LIVE engine graph rather than discarding it.
		if @pEngineGraph != "" and NOT @bEngineStale
			StzEngineGraphAddNode(@pEngineGraph, _aNode_[:id])

			_aAnP_ = _aNode_[:properties]
			if isList(_aAnP_) and HasKey(_aAnP_, "x") and HasKey(_aAnP_, "y")
				StzEngineGraphSetCoords(@pEngineGraph, _aNode_[:id], _aAnP_[:x], _aAnP_[:y])
			ok
		else
			This._InvalidateEngine()
		ok

	# Returns the node with that id as a hash list [ :id, :label, :properties ]; the id is matched in lowercase.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a hash list; raises an error when the node does not exist
	#   see        NodeLabel, NodeProperties
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

	# TRUE if a node has that id; the id is matched in lowercase.
	#
	#   pcNodeId   The node id, as text.
	#   returns    TRUE or FALSE
	#   see        EdgeExists, NodePosition
	def NodeExists(pcNodeId)

		if NOT _IsWellFormedId(pcNodeId)
			stzraise("Incorrect Id! pcNodeId must be one string without spaces nor new lines.")
		ok

		_cNeId_ = StzLower(pcNodeId)

		This._EnsureNodeIndex()

		if @pNodeIdx != ""
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

		if @pNodeIdx != "" and @nNodeIdxCount = _nNiLen_ and NOT @bNodeIdxStale
			return
		ok

		if @pNodeIdx != ""
			StzEngineHashMapFree(@pNodeIdx)
			@pNodeIdx = ""
		ok

		@pNodeIdx = StzEngineHashMapNew()

		if @pNodeIdx = ""
			return
		ok

		for _iNi_ = 1 to _nNiLen_
			StzEngineHashMapPutInt(@pNodeIdx, @aNodes[_iNi_][:id], _iNi_)
		next

		@nNodeIdxCount = _nNiLen_
		@bNodeIdxStale = 0

		def HasNode(pcNodeId)
			return This.NodeExists(pcNodeId)

	# Replaces the whole node list by the given one, without any check; the edges are left as they are.
	#
	#   paNodes    the nodes, each a hash list [ :id, :label, :properties ]
	#   returns    nothing; the graph changes
	#   warning    the engine copy used by Neighbors, ReachableFrom and the metrics is not
	#              refreshed, and the edges are not checked against the new nodes
	#   see        SetEdges, AddNodes
	def SetNodes(paNodes)
		@aNodes = paNodes
		# Length alone cannot detect a same-length swap, so say so outright.
		@bNodeIdxStale = 1
	
	# Replaces the whole edge list by the given one, without any check; the nodes are left as they are.
	#
	#   paEdges    The edges, each a hash list [ :from, :to, :label, :properties ].
	#   returns    nothing; the graph changes
	#   note       EdgeExists, Edges and Path read the new list at once
	#   warning    the engine copy used by Neighbors, ReachableFrom and the metrics is not
	#              refreshed, so they keep answering from the old edges
	#   see        SetNodes
	def SetEdges(paEdges)
		@aEdges = paEdges
		# Length alone cannot detect a same-length swap.
		@bEdgeIdxStale = 1

	# Returns every node as a hash list [ :id, :label, :properties ], in the order they were added.
	#
	#   returns    a list of hash lists
	#   see        NodesIds, Edges
	def Nodes()
		return @aNodes

	# Returns the ids of all nodes, in the order they were added.
	#
	#   returns    a list of text
	#   see        Nodes
	def NodesIds()
		_nLen_ = len(@aNodes)
		_acResult_ = []

		for i = 1 to _nLen_
			_acResult_ + @aNodes[i][:id]
		next

		return _acResult_

		def NodesNames()
			return This.NodesIds()

	# Returns how many nodes the graph holds.
	#
	#   returns    a number
	#   see        EdgesCount, NodeCount
	def NodesCount()
		return len(@aNodes)

		# Returns the number of nodes held; the same answer as the plural spelling.
		#
		#   returns    a number
		#   see        NodesCount
		def NodeCount()
			return len(@aNodes)

		# Returns the count of nodes, phrased as a question.
		#
		#   returns    a number
		#   see        NodesCount
		def HowManyNodes()
			return len(@aNodes)

		# Returns the count of nodes, in the singular form of the question.
		#
		#   returns    a number
		#   see        HowManyNodes
		def HowManyNode()
			return len(@aNodes)

		# Returns the node total, 0 for an empty graph.
		#
		#   returns    a number
		#   see        NodesCount
		def NumberOfNodes()
			return len(@aNodes)

	# Adds one node per id, each labelled with its own id, in the order given.
	#
	#   pacNodes   The node ids to add, as a list of text.
	#   returns    nothing; the graph changes
	#   see        AddNode
	#@ aka  --
	def AddNodes(pacNodes)
		_nLen_ = len(pacNodes)
		for i = 1 to _nLen_
			This.AddNode(pacNodes[i])
		next

	#----------------------#
	#  INSERT NODE BEFORE  #
	#----------------------#
	
	# Adds a node on every route into an existing node: the edges that arrived there now arrive at the new node, which points to the existing one.
	#
	#   pcTargetId   The id of the existing node to insert next to.
	#   pcNewId      The id of the new node, as text.
	#   returns      nothing; the graph changes
	#   note         call InsertNodeBeforeXT or InsertNodeBeforeXTT for a label or properties
	#   warning      the existing id must be given in lowercase, and the re-routed edges lose their
	#                labels and properties
	#   see          InsertNodeAfter, Connect
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
	
	# Adds a node on every route out of an existing node: the edges that left there now leave the new node, which the existing one points to.
	#
	#   pcTargetId   The id of the existing node to insert next to.
	#   pcNewId      The id of the new node, as text.
	#   returns      nothing; the graph changes
	#   note         call InsertNodeAfterXT or InsertNodeAfterXTT for a label or properties
	#   warning      the existing id must be given in lowercase, and the re-routed edges lose their
	#                labels and properties
	#   see          InsertNodeBefore, Connect
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
	
	# Raises error R20 today instead of inserting a chain of nodes in front of an existing node.
	#
	#   pcTargetId   The id of the existing node to insert next to.
	#   paNodes      the nodes to insert, each a pair [ id, label ]
	#   returns      nothing today
	#   note         call InsertNodeBefore once per node instead
	#   warning      known defect: it calls InsertNodeBefore with three arguments, but that method
	#                takes two, so even a valid list of pairs raises R20
	#   see          InsertNodeBefore
	def InsertNodesBefore(pcTargetId, paNodes)
		_nLen_ = len(paNodes)
		for i = 1 to _nLen_
			This.InsertNodeBefore(pcTargetId, paNodes[i][1], paNodes[i][2])
			pcTargetId = paNodes[i][1]
		end
	
	# Raises error R20 today instead of inserting a chain of nodes behind an existing node.
	#
	#   pcTargetId   The id of the existing node to insert next to.
	#   paNodes      the nodes to insert, each a pair [ id, label ]
	#   returns      nothing today
	#   note         call InsertNodeAfter once per node instead
	#   warning      known defect: it calls InsertNodeAfter with three arguments, but that method
	#                takes two, so even a valid list of pairs raises R20
	#   see          InsertNodeAfter
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
	
	# Removes every node and every edge, and forgets which rules were applied; the id, type and rules stay.
	#
	#   returns    nothing; the graph is emptied
	#   see        Clear, RemoveEdges
	def RemoveNodes()
		@aNodes = []
		@aEdges = []
		@aAffectedNodes = []
		@aAffectedEdges = []
		This._InvalidateEngine()

		# Empties the graph of nodes and edges; another spelling of the clearing call.
		#
		#   returns    nothing; the graph is emptied
		#   see        RemoveNodes
		def RemoveAllNodes()
			This.RemoveNodes()
	
		# Empties the graph of all its nodes and edges, keeping its id, type and rules.
		#
		#   returns    nothing; the graph is emptied
		#   see        RemoveNodes
		def Clear()
			This.RemoveNodes()
	
	# Removes each listed node together with its edges.
	#
	#   pacNodeIds   The node ids, as a list of text.
	#   returns      nothing; the graph changes
	#   see          RemoveThisNode
	def RemoveTheseNodes(pacNodeIds)
		_nLen_ = len(pacNodeIds)
		for i = 1 to _nLen_
			This.RemoveThisNode(pacNodeIds[i])
		end
	
	# Removes a node and every edge that starts or ends at it; an id that matches no node is ignored.
	#
	#   pcNodeId   the node id, exactly as stored (lowercase)
	#   returns    nothing; the graph changes
	#   warning    the id is not folded to lowercase, so "A" removes nothing from a node stored as
	#              "a", and no error says so
	#   see        RemoveTheseNodes, RemoveEdgesConnectedTo
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

		# Removes a node and its edges; another spelling of the removal call.
		#
		#   pcNodeId   the node id, exactly as stored (lowercase)
		#   returns    nothing; the graph changes
		#   warning    the id is not folded to lowercase, so "A" removes nothing from a node stored
		#              as "a"
		#   see        RemoveThisNode
		def RemoveNode(pcNodeId)
			This.RemoveThisNode(pcNodeId)
	
	# Removes the node named by the last id of a path, together with its edges.
	#
	#   pacPath    A path as a list of node ids; the last id names the node.
	#   returns    nothing; the graph changes
	#   note       an empty path does nothing
	#   warning    the id is used as written, so a path ending in "B" does not remove node "b"
	#   see        RemoveNodesAt, RemoveThisNode
	def RemoveNodeAt(pacPath)
		_nLen_ = len(pacPath)
		if _nLen_ = 0
			return
		ok
		
		_cNodeId_ = pacPath[_nLen_]
		This.RemoveThisNode(_cNodeId_)
	
		# Removes the node at the end of a path, with its edges; another spelling of the path removal.
		#
		#   pacPath    A path as a list of node ids; the last id names the node.
		#   returns    nothing; the graph changes
		#   warning    the id is used as written, so a path ending in "B" does not remove node "b"
		#   see        RemoveNodeAt
		def RemoveNodeAtPath(pacPath)
			This.RemoveNodeAt(pacPath)
	
	# Removes the node named by the last id of each path, with its edges; the ids are folded to lowercase first.
	#
	#   paPaths    A list of paths, each a list of node ids; the last id of each path names the
	#              node.
	#   returns    nothing; the graph changes
	#   see        RemoveNodeAt
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
	
		# Removes the node at the end of each path, with its edges; another spelling of the multi-path removal.
		#
		#   paPaths    A list of paths, each a list of node ids; the last id of each path names the
		#              node.
		#   returns    nothing; the graph changes
		#   see        RemoveNodesAt
		def RemoveNodesAtPaths(paPaths)
			This.RemoveNodesAt(paPaths)
	
	#----------------#
	#  EDGE REMOVAL  #
	#----------------#
	
	# Removes every edge and keeps the nodes.
	#
	#   returns    nothing; the graph changes
	#   see        RemoveNodes, RemoveThisEdge
	def RemoveEdges()
		@aEdges = []
		@aAffectedEdges = []
		This._InvalidateEngine()

		# Removes all the edges and keeps the nodes; another spelling of the edge clearing.
		#
		#   returns    nothing; the graph changes
		#   see        RemoveEdges
		def RemoveAllEdges()
			This.RemoveEdges()
	
		# Clears the edges and keeps the nodes.
		#
		#   returns    nothing; the graph changes
		#   see        RemoveEdges
		def ClearEdges()
			This.RemoveEdges()
	
	# Removes the edge from one node to another; the ids are folded to lowercase, and a missing edge is ignored.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        nothing; the graph changes
	#   see            RemoveEdgesBetween, RemoveEdgeByLabel, Disconnect
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

		# Removes the edge from one node to another; another spelling of the edge removal.
		#
		#   pcFromNodeId   The id of the node the edge starts from.
		#   pcToNodeId     The id of the node the edge ends at.
		#   returns        nothing; the graph changes
		#   see            RemoveThisEdge
		def RemoveEdge(pcFromNodeId, pcToNodeId)
			This.RemoveThisEdge(pcFromNodeId, pcToNodeId)

		# Cuts the link from one node to another, the counterpart of Connect.
		#
		#   pcFromNodeId   The id of the node the edge starts from.
		#   pcToNodeId     The id of the node the edge ends at.
		#   returns        nothing; the graph changes
		#   see            Connect, RemoveThisEdge
		def Disconnect(pcFromNodeId, pcToNodeId)
			This.RemoveThisEdge(pcFromNodeId, pcToNodeId)

	# Removes every edge that starts or ends at a node, and keeps the node itself.
	#
	#   pcNodeId   The node id, as text.
	#   returns    nothing; the graph changes
	#   warning    the id is not folded to lowercase, and the engine copy is not refreshed, so
	#              Neighbors and ReachableFrom keep answering from the old edges until another
	#              change
	#   see        RemoveThisNode
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

	 # Turns constraint checking on, so that every edge added is first tested against the constraint rules.
	 #
	 #   returns    nothing; the setting changes
	 #   see        DisableConstraints, ConstraintsEnabled, WithoutConstraints
	 #@ aka  Control flags
	 def EnableConstraints()
	        @bEnforceConstraints = 1

		# Turns constraint checking on; another spelling of the switch-on call.
		#
		#   returns    nothing; the setting changes
		#   see        EnableConstraints
		def EnforceConstraints()
			@bEnforceConstraints = 1

	 # Turns constraint checking off, so edges are added without testing the constraint rules.
	 #
	 #   returns    nothing; the setting changes
	 #   see        EnableConstraints, WithoutConstraints
	 def DisableConstraints()
	        @bEnforceConstraints = 0

	# TRUE if constraint rules are tested when an edge is added; they are by default.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        EnableConstraints
	def ConstraintsEnabled()
		return @bEnforceConstraints

	 # Turns automatic derivation on, so that the derivation rules run after every edge added.
	 #
	 #   returns    nothing; the setting changes
	 #   see        DisableAutoDerive, ApplyDerivationRules
	 #@ aka  --
	 def EnableAutoDerive()
	        @bAutoDerive = 1

		# Turns automatic derivation on; another spelling of the switch-on call.
		#
		#   returns    nothing; the setting changes
		#   see        EnableAutoDerive
		def EnforceAutoDerive()
			@bAutoDerive = 1

	 # Turns automatic derivation off, the default, so derivation rules run only when asked.
	 #
	 #   returns    nothing; the setting changes
	 #   see        EnableAutoDerive
	 def DisableAutoDerive()
	        @bAutoDerive = 0

	# TRUE if derivation rules run after every edge added; they do not by default.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        EnableAutoDerive
	def AutoDeriveEnabled()
		return @bAutoDerive

	# Calls a function with the graph as its only argument while constraint checking is off, then restores the earlier setting.
	#
	#   pFunc      a function that takes the graph, as an anonymous function or a function name
	#   returns    nothing
	#   warning    if the function raises an error the checking stays off, because the earlier
	#              setting is restored only after the call returns
	#   see        BypassingConstraints, DisableConstraints
	#@ aka  Temporarily bypass rules
	def WithoutConstraints(pFunc)
		if NOT @IsFunction(pFunc)
			stzraise("Parameter must be a function!")
		ok
	
		# Save current state
		_bOldState_ = @bEnforceConstraints
		
		# Disable constraints temporarily
		@bEnforceConstraints = 0
		
		# Execute the provided function
		call pFunc(This)
		
		# Restore original state
		@bEnforceConstraints = _bOldState_

	
		# Runs a function on the graph with constraint checking off; another spelling of the temporary bypass.
		#
		#   pFunc      a function that takes the graph, as an anonymous function or a function name
		#   returns    nothing
		#   warning    if the function raises an error the checking stays off
		#   see        WithoutConstraints
		def BypassingConstraints(pFunc)
			This.WithoutConstraints(pFunc)
	    
	#----------------------#
	#  PRE-FLIGHT METHODS  #
	#----------------------#

	# TRUE if an edge could be added from one node to the other: both exist, no edge is there yet and no constraint rule objects.
	#
	#   pcFrom     The id of the node the edge starts from.
	#   pcTo       The id of the node the edge ends at.
	#   returns    TRUE or FALSE
	#   see        WhyCannotAddEdge, AddEdge
	#@ aka  Pre-flight checks (non-mutating)
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
			return 0
		ok
	
		if This.EdgeExists(pcFrom, pcTo)
			return 0
		ok
	
		# Constraint checks
		_aCheck_ = This.CheckConstraintRules([
			:from = pcFrom,
			:to = pcTo,
			:label = pcLabel
		])
	
		return _aCheck_[1]
	        
	# Returns a sentence saying that the edge can be added, or why not: a missing node, an existing edge or the rules it breaks.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        text; "Edge can be added" when nothing stands in the way
	#   see            CanAddEdge
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
		_cReasons_ = "Cannot add edge:" + char(10)
		
		_nLen_ = len(_aViolations_)
		for i = 1 to _nLen_
			_aV_ = _aViolations_[i]
			_cReasons_ += "  • [" + _aV_[:severity] + "] " + _aV_[:rule] + ": " + _aV_[:message] + char(10)
		next
	
		return _cReasons_
	
		def WhyCannotConnect(pcFromNodeId, pcToNodeId, pcLabel)
			return This.WhyCannotAddEdge(pcFromNodeId, pcToNodeId, pcLabel)

	#-------------------#
	#  EDGE OPERATIONS  #
	#-------------------#

	# Adds an unlabelled edge from one node to another; raises an error when a node is missing, the edge exists or a constraint rule blocks it.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        nothing; the graph changes
	#   note           stzGraph is a simple graph, so a second edge between the same pair is
	#                  refused; for a label or properties call AddEdgeXT or AddEdgeXTT
	#   see            Connect, ConnectIfAbsent, EdgeExists
	def AddEdge(pcFromNodeId, pcToNodeId)
		This.AddEdgeXTT(pcFromNodeId, pcToNodeId, "", [])

		# Adds an unlabelled edge from one node to another; a list as the target adds one edge to each node of the list.
		#
		#   pcFromNodeId   The id of the node the edge starts from.
		#   pcToNodeId     The id of the node the edge ends at.
		#   returns        nothing; the graph changes
		#   note           a duplicate edge, a missing node or a blocking rule raises an error
		#   see            AddEdge, ConnectIfAbsent
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

	# Adds the edge unless it already exists, and says which happened; a missing node or a blocking rule still raises an error.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        1 when the edge was added, 0 when it was already there
	#   see            Connect, EdgeExists
	#@ aka  CONNECT UNLESS THE EDGE IS ALREADY THERE. Returns TRUE if it added the edge, FALSE if it was already present.
	def ConnectIfAbsent(pcFromNodeId, pcToNodeId)
		if This.EdgeExists(pcFromNodeId, pcToNodeId)
			return 0
		ok
		This.AddEdgeXTT(pcFromNodeId, pcToNodeId, "", [])
		return 1

		def AddEdgeIfAbsent(pcFromNodeId, pcToNodeId)
			return This.ConnectIfAbsent(pcFromNodeId, pcToNodeId)

		def ConnectIfNotConnected(pcFromNodeId, pcToNodeId)
			return This.ConnectIfAbsent(pcFromNodeId, pcToNodeId)

	# Chains the nodes in the given order, with one edge from each to the next; fewer than two ids raises an error.
	#
	#   paNodes    the node ids, in the order they are chained
	#   returns    nothing; the graph changes
	#   note       for labels between the nodes call ConnectSequenceXT
	#   see        ConnectInSequence, Connect
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
	
		# Chains the nodes in the given order; another spelling of the chaining call.
		#
		#   paNodes    the node ids, in the order they are chained
		#   returns    nothing; the graph changes
		#   see        ConnectSequence
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

	# Adds one edge from a node to each of the listed nodes, in order.
	#
	#   pcFromNodeId    The id of the node the edge starts from.
	#   pacToNodesIds   The ids of the nodes the edges end at, as a list of text.
	#   returns         nothing; the graph changes
	#   see             ConnectToMany, Connect
	def AddEdges(pcFromNodeId, pacToNodesIds)
		_nLen_ = len(pacToNodesIds)
		for i = 1 to _nLen_
			This.AddEdgeXTT(pcFromNodeId, pacToNodesIds[i], "", [])
		next

		# Links one node to each of several others; another spelling of the multi-edge call.
		#
		#   pcFromNodeId    The id of the node the edge starts from.
		#   pacToNodesIds   The ids of the nodes the edges end at, as a list of text.
		#   returns         nothing; the graph changes
		#   see             AddEdges
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
			This.AddEdgesXTT(pcFromNodeId, $paToNodesIdsAndLabelsAndProps)
			return
		ok

		pcFromNodeId = StzLower(pcFromNodeId)
		pcToNodeId = StzLower(pcToNodeId)

		# Validate nodes exist
		if NOT This.NodeExists(pcFromNodeId) or NOT This.NodeExists(pcToNodeId)
			stzraise("Cannot add edge: one or both nodes do not exist!")
		ok
	
		# Check if edge already exists
		#
		# THE REFUSAL NOW SAYS WHAT TO DO. "Edge already exists" states the
		# fact and leaves the caller to guess whether it is a bug in their
		# code, a missing guard, or a limit of the model -- and it is the
		# third. stzGraph is a SIMPLE graph BY DECISION (see ConnectIfAbsent
		# above): a second arrow between one pair is refused because a
		# silently doubled edge corrupts every count, every path and every
		# metric that walks the adjacency.
		#
		# A self-loop is allowed and is NOT this case, so it is worth saying
		# so -- the message used to read "already exists between 'b' and
		# 'b'", which sounds like self-loops are banned when only the SECOND
		# one is.
		if This.EdgeExists(pcFromNodeId, pcToNodeId)
			if StzLower("" + pcFromNodeId) = StzLower("" + pcToNodeId)
				stzraise("'" + pcFromNodeId + "' already has a self-loop. " +
					"One is allowed and is drawn as a loop; a second would " +
					"be a parallel edge, which this model refuses.")
			ok
			stzraise("There is already an edge from '" + pcFromNodeId +
				"' to '" + pcToNodeId + "'. stzGraph is a SIMPLE graph -- " +
				"parallel edges are refused so that counts, paths and " +
				"metrics stay true. Use ConnectIfAbsent() to add only when " +
				"missing, SetEdgeLabel()/SetEdgeProperty() to enrich the " +
				"edge that is there, or model the second relation as its " +
				"own node if both must exist at once.")
		ok

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
		if @pEdgeIdx != "" and NOT @bEdgeIdxStale
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
		if @pEngineGraph != "" and NOT @bEngineStale
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

		# Raises error R19 today instead of adding edges to several nodes, each with its own label and properties.
		#
		#   pcFromNodeId                    The id of the node the edge starts from.
		#   paToNodesIdsAndLabelsAndProps   The target nodes, each with its label and properties.
		#   returns                         nothing today
		#   note                            AddEdges adds the unlabelled version; AddEdgeXTT adds
		#                                   one edge with a label and properties
		#   warning                         known defect: it calls AddEdgeXTT with two arguments
		#                                   where four are needed, so any non-empty list raises R19,
		#                                   and an empty list does nothing
		#   see                             AddEdges
		def ConnectEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)
			This.AddEdgesXTT(pcFromNodeId, paToNodesIdsAndLabelsAndProps)

	# Returns the edge from one node to another as a hash list [ :from, :to, :label, :properties ]; raises "Inexistant edge!" when there is none.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        a hash list
	#   see            EdgeExists, EdgesBetween
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

	# TRUE if there is an edge from the first node to the second, in that direction; the ids are matched in lowercase.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        TRUE or FALSE
	#   see            Edge, PathExists, NodeExists
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

		if @pEdgeIdx != ""
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

		if @pEdgeIdx != "" and @nEdgeIdxCount = _nEiLen_ and NOT @bEdgeIdxStale
			return
		ok

		if @pEdgeIdx != ""
			StzEngineHashMapFree(@pEdgeIdx)
			@pEdgeIdx = ""
		ok

		@pEdgeIdx = StzEngineHashMapNew()

		if @pEdgeIdx = ""
			return
		ok

		for _iEi_ = 1 to _nEiLen_
			StzEngineHashMapPutInt(@pEdgeIdx,
				@aEdges[_iEi_]["from"] + char(1) + @aEdges[_iEi_]["to"], _iEi_)
		next

		@nEdgeIdxCount = _nEiLen_
		@bEdgeIdxStale = 0

	# Returns every edge as a hash list [ :from, :to, :label, :properties ], in the order they were added.
	#
	#   returns    a list of hash lists
	#   see        Nodes, EdgesBetween
	def Edges()
		return @aEdges

	# Returns how many edges the graph holds.
	#
	#   returns    a number
	#   see        NodesCount, EdgeCount
	def EdgesCount()
		return len(@aEdges)

		# Returns the number of edges held; the same answer as the plural spelling.
		#
		#   returns    a number
		#   see        EdgesCount
		def EdgeCount()
			return len(@aEdges)

		# Returns the count of edges, phrased as a question.
		#
		#   returns    a number
		#   see        EdgesCount
		def HowManyEdges()
			return len(@aEdges)

		# Returns the count of edges, in the singular form of the question.
		#
		#   returns    a number
		#   see        HowManyEdges
		def HowManyEdge()
			return len(@aEdges)

		# Returns the edge total, 0 when there is none.
		#
		#   returns    a number
		#   see        EdgesCount
		def NumberOfEdges()
			return len(@aEdges)

	# Returns how many edges run from the first node to the second, which is 0 or 1 in a simple graph.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        a number
	#   see            EdgesBetween, EdgeExists
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
	
	# Returns the edges from one node to another as [ from, label, to ] triples; [ ] when there is none.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        a list of triples
	#   see            Edge, EdgeCountBetween
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

	# Removes the first edge from one node to another that carries the label; the ids and the label are matched in lowercase.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        nothing; the graph changes
	#   warning        the engine copy is not refreshed, so Neighbors and ReachableFrom keep
	#                  answering from the old edges until another change
	#   see            RemoveThisEdge
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
		_bFound_ = 0
		
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			if _aEdge_["from"] = StzLower(pcFromNodeId) and _aEdge_["to"] = StzLower(pcToNodeId) and StzLower(_aEdge_["label"]) = StzLower(pcLabel) and NOT _bFound_
				_bFound_ = 1
				loop
			ok
			_acNew_ + _aEdge_
		end
		
		@aEdges = _acNew_
	
		# Removes the edge with that label between two nodes; another spelling of the label-based removal.
		#
		#   pcFromNodeId   The id of the node the edge starts from.
		#   pcToNodeId     The id of the node the edge ends at.
		#   returns        nothing; the graph changes
		#   warning        the engine copy is not refreshed, so Neighbors and ReachableFrom keep
		#                  answering from the old edges until another change
		#   see            RemoveEdgeByLabel
		def RemoveEdgeWithLabel(pcFromNodeId, pcToNodeId, pcLabel)
			This.RemoveEdgeByLabel(pcFromNodeId, pcToNodeId, pcLabel)
	
		# Cuts the link with that label between two nodes, the counterpart of connecting with a label.
		#
		#   pcFromNodeId   The id of the node the edge starts from.
		#   pcToNodeId     The id of the node the edge ends at.
		#   returns        nothing; the graph changes
		#   warning        the engine copy is not refreshed, so Neighbors and ReachableFrom keep
		#                  answering from the old edges until another change
		#   see            RemoveEdgeByLabel
		def DisconnectByLabel(pcFromNodeId, pcToNodeId, pcLabel)
			This.RemoveEdgeByLabel(pcFromNodeId, pcToNodeId, pcLabel)
	
	# Removes every edge from one node to another; the ids are matched in lowercase.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        nothing; the graph changes
	#   warning        the engine copy is not refreshed, so Neighbors and ReachableFrom keep
	#                  answering from the old edges until another change
	#   see            RemoveThisEdge, RemoveEdgeByLabel
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
	
		# Removes the edges from one node to another; another spelling of the multi-edge removal.
		#
		#   pcFromNodeId   The id of the node the edge starts from.
		#   pcToNodeId     The id of the node the edge ends at.
		#   returns        nothing; the graph changes
		#   warning        the engine copy is not refreshed, so Neighbors and ReachableFrom keep
		#                  answering from the old edges until another change
		#   see            RemoveAllEdgesBetween
		def RemoveEdgesBetween(pcFromNodeId, pcToNodeId)
			This.RemoveAllEdgesBetween(pcFromNodeId, pcToNodeId)
	
		# Cuts every link from one node to another; another spelling of the multi-edge removal.
		#
		#   pcFromNodeId   The id of the node the edge starts from.
		#   pcToNodeId     The id of the node the edge ends at.
		#   returns        nothing; the graph changes
		#   warning        the engine copy is not refreshed, so Neighbors and ReachableFrom keep
		#                  answering from the old edges until another change
		#   see            RemoveAllEdgesBetween
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

		# Calls a function once for each node, handing it the node's hash list so it can change the node in place.
		#
		#   pFunc      a function that takes one node hash list, as an anonymous function or a
		#              function name
		#   returns    nothing; the nodes change
		#   see        UpdateEdges, SetNodeProperty
		def UpdateNodes(pFunc)
			This.UpdateNodesF(pFunc)
	
	def UpdateEdgesF(pFunc)
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			call pFunc(@aEdges[i])
		end

		# Calls a function once for each edge, handing it the edge's hash list so it can change the edge in place.
		#
		#   pFunc      a function that takes one edge hash list, as an anonymous function or a
		#              function name
		#   returns    nothing; the edges change
		#   see        UpdateNodes, SetEdgeProperty
		def UpdateEdges(pFunc)
			This.UpdateEdgesF(pFunc)

	#-------------------#
	#  COPY OPERATIONS  #
	#-------------------#
	
	# Returns a copy of a node as a hash list [ :id, :label, :properties ], leaving the graph unchanged.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a hash list; raises an error when the node does not exist
	#   see        DuplicateNode, Node
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
	
	# Adds a second node with the label and properties of an existing node, under a new id; no edge is copied.
	#
	#   pcNodeId   The node id, as text.
	#   pcNewId    The id of the new node, as text.
	#   returns    nothing; the graph changes
	#   see        DuplicateNodeWithEdges, CopyNode
	def DuplicateNode(pcNodeId, pcNewId)
		_aCopy_ = This.CopyNode(pcNodeId)
		_aCopy_["id"] = pcNewId
		This.AddNodeXTT(_aCopy_["id"], _aCopy_["label"], _aCopy_["properties"])
	
		# Adds a second node like an existing one under a new id; another spelling of the duplication call.
		#
		#   pcNodeId   The node id, as text.
		#   pcNewId    The id of the new node, as text.
		#   returns    nothing; the graph changes
		#   see        DuplicateNode
		def CloneNode(pcNodeId, pcNewId)
			This.DuplicateNode(pcNodeId, pcNewId)
	
	# Adds a node like an existing one under a new id, and copies the edges that leave the existing node; the edges that arrive are not copied.
	#
	#   pcNodeId   The node id, as text.
	#   pcNewId    The id of the new node, as text.
	#   returns    nothing; the graph changes
	#   see        DuplicateNode
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
	
	# Replaces the listed nodes by one new node, to which their outside in-edges and out-edges are re-pointed; the new edges carry no label.
	#
	#   pacNodeIds   The node ids, as a list of text.
	#   pcNewId      The id of the new node, as text.
	#   pcNewLabel   The label of the new node.
	#   returns      nothing; the graph changes
	#   warning      fewer than two ids does nothing, and the new node has no properties, only the
	#                label given
	#   see          CombineNodes, SplitNode
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
	
		# Fuses the listed nodes into one new node; another spelling of the merge.
		#
		#   pacNodeIds   The node ids, as a list of text.
		#   pcNewId      The id of the new node, as text.
		#   pcNewLabel   The label of the new node.
		#   returns      nothing; the graph changes
		#   warning      fewer than two ids does nothing, and the new edges carry no label
		#   see          MergeNodes
		def CombineNodes(pacNodeIds, pcNewId, pcNewLabel)
			This.MergeNodes(pacNodeIds, pcNewId, pcNewLabel)

	# Replaces a node by two new nodes labelled with the old label plus (1) and (2), each linked to all the former neighbours.
	#
	#   pcNodeId   The node id, as text.
	#   pcNewId1   The id of the first new node.
	#   pcNewId2   The id of the second new node.
	#   returns    nothing; the graph changes
	#   warning    the new edges carry no label and the new nodes carry no properties
	#   see        MergeNodes
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

	# Returns the distinct property names found on the nodes, in order of first appearance; [ ] when there are none.
	#
	#   returns    a list of text
	#   see        NodeProperties
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

	# Changes the label of a node; line breaks in the label become underscores, spaces stay; raises an error when the node is absent.
	#
	#   pcNodeId   The node id, as text.
	#   returns    nothing; the graph changes
	#   warning    the id is not folded to lowercase, so "A" raises "does not exist" for a node
	#              stored as "a"
	#   see        NodeLabel, SetNodeProperty
	#@ aka  The label a node SHOWS, as opposed to the id it is known by.
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

	# Returns the label of a node; raises an error when the node does not exist.
	#
	#   pcNodeId   The node id, as text.
	#   returns    text
	#   warning    the id is not folded to lowercase, so "A" raises "does not exist" for a node
	#              stored as "a"
	#   see        SetNodeLabel, Node
	def NodeLabel(pcNodeId)
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			if @aNodes[i]["id"] = pcNodeId
				return @aNodes[i]["label"]
			ok
		end

		stzraise("Node '" + pcNodeId + "' does not exist.")

	# Sets one property of a node, creating it when absent.
	#
	#   pcNodeId    The node id, as text.
	#   cProperty   The property name, as text.
	#   returns     nothing; the node changes
	#   warning     the id is not folded to lowercase and an id that matches no node is ignored
	#               silently, so "A" or an unknown id sets nothing and raises nothing
	#   see         NodeProperty, SetNodeProperties
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
	
		# Sets one property of a node; a short spelling of the property setter.
		#
		#   pcNodeId    The node id, as text.
		#   cProperty   The property name, as text.
		#   returns     nothing; the node changes
		#   warning     the id is not folded to lowercase and an unknown id is ignored silently
		#   see         SetNodeProperty
		def SetNodeProp(pcNodeId, cProperty, pValue)
			This.SetNodeProperty(pcNodeId, cProperty, pValue)

		# Sets one property of a node, replacing its value when it exists; another spelling of the setter.
		#
		#   pcNodeId   The node id, as text.
		#   returns    nothing; the node changes
		#   warning    the id is not folded to lowercase and an unknown id is ignored silently
		#   see        SetNodeProperty
		def UpdateNodeProperty(pcNodeId, pcKey, pValue)
			This.SetNodeProperty(pcNodeId, pcKey, pValue)
		
		# Sets one property of a node, replacing its value; the short spelling of the update.
		#
		#   pcNodeId   The node id, as text.
		#   returns    nothing; the node changes
		#   warning    the id is not folded to lowercase and an unknown id is ignored silently
		#   see        SetNodeProperty
		def UpdateNodeProp(pcNodeId, pcKey, pValue)
			This.SetNodeProperty(pcNodeId, pcKey, pValue)

	# Sets several properties of a node from a hash list; a value that is not a hash list raises an error.
	#
	#   pcNodeId      The node id, as text.
	#   aProperties   The properties, as a hash list [ :name = value, ... ].
	#   returns       nothing; the node changes
	#   warning       the id is not folded to lowercase and an unknown id is ignored silently
	#   see           SetNodeProperty, NodeProperties
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
	
		# Sets several properties of a node from a hash list; the short spelling of the multi-property setter.
		#
		#   pcNodeId      The node id, as text.
		#   aProperties   The properties, as a hash list [ :name = value, ... ].
		#   returns       nothing; the node changes
		#   warning       the id is not folded to lowercase and an unknown id is ignored silently
		#   see           SetNodeProperties
		def SetNodeProps(pcNodeId, aProperties)
			This.SetNodeProperties(pcNodeId, aProperties)

	# Returns the names of the properties a node carries, in order; [ ] when it has none.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a list of text
	#   see        NodeProperty, Properties
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

	# Returns the value of one property of a node; empty text when the node has no such property.
	#
	#   pcNodeId    The node id, as text.
	#   cProperty   The property name, as text.
	#   returns     the value, or empty text
	#   see         NodeProperties, SetNodeProperty
	def NodeProperty(pcNodeId, cProperty)
		_aNode_ = This.Node(pcNodeId)
	
		if HasKey(_aNode_, "properties") and HasKey(_aNode_["properties"], cProperty)
			return _aNode_["properties"][cProperty]
		ok
	
		def NodeProp(pcNodeId, cProperty)
			return This.NodeProperty(pcNodeId, cProperty)

	# Removes all the properties of one node.
	#
	#   pcNodeId   The node id, as text.
	#   returns    nothing; the node changes
	#   warning    the id is not folded to lowercase and an unknown id is ignored silently
	#   see        RemoveAllProperties
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
	
		# Clears the properties of one node; another spelling of the removal.
		#
		#   pcNodeId   The node id, as text.
		#   returns    nothing; the node changes
		#   warning    the id is not folded to lowercase and an unknown id is ignored silently
		#   see        RemoveNodeProperties
		def ClearNodeProperties(pcNodeId)
			This.RemoveNodeProperties(pcNodeId)
	
		# Removes all the properties of one node; the short spelling.
		#
		#   pcNodeId   The node id, as text.
		#   returns    nothing; the node changes
		#   warning    the id is not folded to lowercase and an unknown id is ignored silently
		#   see        RemoveNodeProperties
		def RemoveNodeProps(pcNodeId)
			This.RemoveNodeProperties(pcNodeId)
	
		# Clears the properties of one node; the short spelling of the clearing.
		#
		#   pcNodeId   The node id, as text.
		#   returns    nothing; the node changes
		#   warning    the id is not folded to lowercase and an unknown id is ignored silently
		#   see        RemoveNodeProperties
		def ClearNodeProps(pcNodeId)
			This.RemoveNodeProperties(pcNodeId)

	# Removes the properties of every node and every edge, leaving ids, labels and links.
	#
	#   returns    nothing; the graph changes
	#   see        RemoveNodeProperties
	def RemoveAllProperties()
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			@aNodes[i]["properties"] = []
		end
		
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			@aEdges[i]["properties"] = []
		end
	
		# Clears the properties of all nodes and edges; another spelling of the global removal.
		#
		#   returns    nothing; the graph changes
		#   see        RemoveAllProperties
		def ClearAllProperties()
			This.RemoveAllProperties()

	# Sets one property of an existing edge; an edge that does not exist is ignored silently.
	#
	#   pFromNodeId   The id of the node the edge starts from.
	#   pToNodeId     The id of the node the edge ends at.
	#   cProperty     The property name, as text.
	#   returns       nothing; the edge changes
	#   warning       the ids are not folded to lowercase, so "A" and "B" set nothing on an edge
	#                 stored as a to b, and no error says so
	#   see           EdgeProperty, SetEdgeProperties
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

		# Sets one property of an existing edge, replacing its value; another spelling of the setter.
		#
		#   pcFrom     The id of the node the edge starts from.
		#   pcTo       The id of the node the edge ends at.
		#   returns    nothing; the edge changes
		#   warning    the ids are not folded to lowercase and a missing edge is ignored silently
		#   see        SetEdgeProperty
		def UpdateEdgeProperty(pcFrom, pcTo, pcKey, pValue)
			This.SetEdgeProperty(pcFrom, pcTo, pcKey, pValue)
		
		# Sets one property of an existing edge; the short spelling of the update.
		#
		#   pcFrom     The id of the node the edge starts from.
		#   pcTo       The id of the node the edge ends at.
		#   returns    nothing; the edge changes
		#   warning    the ids are not folded to lowercase and a missing edge is ignored silently
		#   see        SetEdgeProperty
		def UpdateEdgeProp(pcFrom, pcTo, pcKey, pValue)
			This.SetEdgeProperty(pcFrom, pcTo, pcKey, pValue)

	# Returns the value of one property of an edge; raises an error when the edge or the property is missing.
	#
	#   pFromNodeId   The id of the node the edge starts from.
	#   pToNodeId     The id of the node the edge ends at.
	#   cProperty     The property name, as text.
	#   returns       the value
	#   warning       the error text for a missing property shows the unexpanded words ' + cProperty
	#                 + ' instead of the name
	#   see           SetEdgeProperty, EdgeProperties
	def EdgeProperty(pFromNodeId, pToNodeId, cProperty)
		_aEdge_ = This.Edge(pFromNodeId, pToNodeId)
		
		if HasKey(_aEdge_, "properties") and HasKey(_aEdge_["properties"], cProperty)
			return _aEdge_["properties"][cProperty]
		else
			stzraise("This edge propert (' + cProperty + ') does not exist!")
		ok

		def EdgeProp(pFromNodeId, pToNodeId, cProperty)
			return This.EdgeProperty(pFromNodeId, pToNodeId, cProperty)

	# Sets several properties of an existing edge from a hash list; a value that is not a hash list raises an error.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   aProperties    The properties, as a hash list [ :name = value, ... ].
	#   returns        nothing; the edge changes
	#   warning        the ids are not folded to lowercase and a missing edge is ignored silently
	#   see            SetEdgeProperty, EdgeProperties
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
	
		# Sets several properties of an existing edge; the short spelling of the multi-property setter.
		#
		#   pcFromNodeId   The id of the node the edge starts from.
		#   pcToNodeId     The id of the node the edge ends at.
		#   aProperties    The properties, as a hash list [ :name = value, ... ].
		#   returns        nothing; the edge changes
		#   warning        the ids are not folded to lowercase and a missing edge is ignored
		#                  silently
		#   see            SetEdgeProperties
		def SetEdgeProps(pcFromNodeId, pcToNodeId, aProperties)
			This.SetEdgeProperties(pcFromNodeId, pcToNodeId, aProperties)

	# Returns the names of the properties an edge carries; raises "Inexistant edge!" when there is no such edge.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        a list of text
	#   see            EdgeProperty, SetEdgeProperty
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

	# Returns a stzCanvas drawing of the graph, with node sizes and colours computed from the graph's own shape.
	#
	#   paOptions   The canvas options as a hash list, such as [ :Layout = :Hierarchical, :SizeBy =
	#               :Impact ].
	#   returns     a stzCanvas
	#   note        options: :Layout = :Hierarchical or :Force; :SizeBy and :ColorBy = :Impact,
	#               :Depth, :Degree, :InDegree or :OutDegree; ToCanvasQ is the chaining form
	#   see         GraphCanvas, Show
	#@ aka  The doorway to the graphics plane: a graph hands back a CANVAS whose node sizes and colours are computed from the graph's own shape. oG.ToCanvasQ([ :Layout = :Hierarchical, :SizeBy = :Impact ]) It answers an stzCanvas, so ToSVG() and ToPNG() come with it.
	def ToCanvas(paOptions)
		_o_ = new stzGraphCanvas(This, paOptions)
		return _o_.ToCanvas()

	def ToCanvasQ(paOptions)
		return This.ToCanvas(paOptions)

	# Returns the stzGraphCanvas behind the drawing, for its metrics and node positions rather than only the picture.
	#
	#   paOptions   The canvas options as a hash list, such as [ :Layout = :Hierarchical, :SizeBy =
	#               :Impact ].
	#   returns     a stzGraphCanvas
	#   note        takes the same options as ToCanvas
	#   see         ToCanvas
	#@ aka  The face itself, when a caller wants the metrics or the positions rather than only the drawing.
	def GraphCanvas(paOptions)
		return new stzGraphCanvas(This, paOptions)

	# TRUE if the second node can be reached from the first by following edges; a node reaches itself.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        TRUE or FALSE
	#   see            ReachableFrom, EdgeExists, ShortestPath
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

	# Returns the first node added, as a hash list [ :id, :label, :properties ]; raises an error on a graph with no node.
	#
	#   returns    a hash list
	#   see        FirstNodeId, LastNode
	#---
	def FirstNode()
		if len(@aNodes) = 0
			stzraise("Can't obtain a first node. The graphs contains no nodes at all!")
		ok
		return @aNodes[1]

	# Returns the id of the first node added; raises an error on a graph with no node.
	#
	#   returns    text
	#   see        FirstNode
	def FirstNodeId()
		return This.FirstNode()[:id]

	# Returns the last node added, as a hash list; raises an error on a graph with no node.
	#
	#   returns    a hash list
	#   see        LastNodeId, FirstNode
	def LastNode()
		_nLen_ = len(@aNodes)
		if _nLen_ = 0
			stzraise("Can't obtain a first node. The graphs contains no nodes at all!")
		ok
		return @aNodes[_nLen_]

	# Returns the id of the last node added; raises an error on a graph with no node.
	#
	#   returns    text
	#   see        LastNode
	def LastNodeId()
		return This.LastNode()[:id]

	# Returns the node at a position, counted from 1 in the order added; a position of 0 or past the end raises error R2.
	#
	#   n          The position of the node; 1 is the first.
	#   returns    a hash list
	#   see        NodePosition, FirstNode
	def NthNode(n)
		if not isNumber(n)
			stzraise("Incorrect param type! n must be a number.")
		ok

		return @aNodes[n]

		def NodeAt(n)
			return This.NthNode(n)

		def NodeAtPosition(n)
			return This.NthNode(n)

	# Returns the position of a node in the node list, counted from 1; 0 when the node does not exist.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number
	#   see        NthNode, NodeExists
	def NodePosition(pcNodeId)
		# The index already maps id -> POSITION, which is exactly this
		# question. Missed when NodeExists was indexed: this one kept
		# rebuilding the whole id list with NodesIds() and scanning it.
		# The engine map returns 0 for an absent key, same as the scan did.

		_cNpId_ = StzLower(pcNodeId)

		This._EnsureNodeIndex()

		if @pNodeIdx != ""
			return StzEngineHashMapGetInt(@pNodeIdx, _cNpId_)
		ok

		return StzFindFirst(_cNpId_, This.NodesIds())

	# Returns every simple path from the first node to the given node, as lists of ids; a path of more than 10 edges is not found.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a list of paths
	#   see        Path, Paths, PathExists
	#@ aka  --
	def FindNode(pcNodeId)
		return This.PathsXT(This.FirstNodeId(), pcNodeId)

		# Returns every simple path from the first node to the given node; another spelling of the path search.
		#
		#   pcNodeId   The node id, as text.
		#   returns    a list of paths
		#   see        FindNode
		def PathsTo(pcNodeId)
			if CheCkParams()
				if isList(pcNodeId) and IsNodeNamedParamList(pcNodeId)
					pcNodeId = pcNodeId[2]
				ok
			ok

			return This.FindNode(pcNodeId)

		def PathsToNode(pcNodeId)
			return This.FindNode(pcNodeId)

	# Returns every simple path between every ordered pair of distinct nodes, as lists of ids; the answer grows fast with the graph.
	#
	#   returns    a list of paths
	#   note       enumerating all simple paths is exponential, so use it on small graphs
	#   warning    the search gives up beyond 10 edges, so longer paths are missing
	#   see        Path, PathsWhereF
	#@ aka  --
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

	# Returns the first path found from one node to another, following the edges in the order added; it is not always the shortest.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        a list of node ids; [ ] when none is found
	#   warning        a path of more than 10 edges is not found, even when PathExists says the node
	#                  is reachable
	#   see            ShortestPath, PathExists, FindNode
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

	# Returns the ids of the nodes that a node points to, in the order its edges were added.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a list of text; [ ] for a node without out-edges
	#   see        Incoming, ReachableFrom
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

	# Returns the ids of the nodes that point to a node, in the order their edges were added.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a list of text; [ ] when nothing points to it
	#   warning    the id is not folded to lowercase, so "C" finds nothing for a node stored as "c"
	#   see        Neighbors, InDegree
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

	# TRUE if the graph holds a directed cycle, a self-loop included.
	#
	#   returns    TRUE or FALSE
	#   see        CyclicNodes, TopologicalSort, IsConnected
	def HasCyclicDependencies()

		if This._EnsureEngine()
			return StzEngineGraphHasCycle(@pEngineGraph)
		ok

		# THE PURE-RING FALLBACK. It only runs when the graph engine DLL is
		# absent, which is why the three defects fixed below (2026-08-07)
		# survived: every measurement of this method was really measuring
		# StzEngineGraphHasCycle above it. Forced onto this branch, the
		# fallback did not return a wrong answer -- it RAISED, on the first
		# graph of any shape, so it had never produced a verdict at all.

		_acVisited_ = []
		_acRecStack_ = []

		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]

			# (1) StzFindFirst is NEEDLE-FIRST -- StzFindFirst(item, list).
			# This read (list, item), so it searched the visited LIST inside
			# the node id STRING and answered 0 forever. The DFS therefore
			# re-ran from every node: O(V) redundant traversals, and the
			# answer only stayed right because the DFS is idempotent.
			if StzFindFirst(_aNode_["id"], _acVisited_) = 0
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

		# (2) The pop called stzleft() -- a STRING op -- on a list. That is
		# an R21 straight out of StzLeft's "" + _cStr_ widening, and it fired
		# on the FIRST node popped, so nothing downstream ever ran. Exactly
		# the bug already fixed in _FindAllPathsDFS (see the note at ~1990);
		# this sibling was missed.
		#
		# (3) Even spelled with a list op it would not have worked: Ring
		# passes lists by REFERENCE, so REBINDING pacRecStack to a new list
		# pointed the local elsewhere and left the caller's stack untouched.
		# The stack could then only grow, and a re-convergent (diamond)
		# graph would report a cycle it does not have. ring_del() pops the
		# caller's list in place -- the idiom already used at ~2952.
		#
		# The guard is > 0, not > 1: at depth 1 the stack holds exactly the
		# node being left, and leaving it must clear it. Keeping that last
		# entry made the NEXT root see a stale ancestor.
		_nLen_ = len(pacRecStack)
		if _nLen_ > 0
			ring_del(pacRecStack, _nLen_)
		ok

		return 0

	#-------------------------------#
	#  REACHABILITY & CONNECTIVITY  #
	#-------------------------------#

	# Returns the ids of the other nodes you can reach by following edges from a node; the start node is never listed.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a list of text, in node order; [ ] when the node is unknown
	#   see        PathExists, ImpactOf, Neighbors
	#@ aka  THE OTHER NODES YOU CAN GET TO FROM pcNodeId, FOLLOWING OUT-EDGES.
	def ReachableFrom(pcNodeId)
		# Both implementations below now agree on that definition AND on the order
		# of the result (node-insertion order). They did not: the engine excluded
		# the start node while the pure-Ring fallback INCLUDED it and returned
		# BFS-discovery order, so the same call answered ["b"] or ["a","b"]
		# depending on whether the graph DLL happened to be loaded (measured
		# 2026-08-07). The engine is the shipped path, so it defines the contract.
		if NOT This.NodeExists(pcNodeId)
			return []
		ok

		if This._EnsureEngine()
			_cEngResult_ = StzEngineGraphReachable(@pEngineGraph, StzLower(pcNodeId))
			return _cEngResult_
		ok

		_acVisited_ = []
		_acQueue_ = [pcNodeId]
		_acVisited_ + pcNodeId
		_nQueueIdx_ = 1

		while _nQueueIdx_ <= len(_acQueue_)
			_cCurrent_ = _acQueue_[_nQueueIdx_]

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

		# Emit in node-insertion order, minus the start node -- the engine
		# walks its node array and skips `i == start`, and @aNodes is the
		# array it was built from, so this is the same list in the same order.
		_acReachable_ = []
		_cStart_ = StzLower(pcNodeId)
		_nNodesLen_ = len(@aNodes)
		for i = 1 to _nNodesLen_
			_cId_ = @aNodes[i][:id]
			if _cId_ != _cStart_ and StzFindFirst(_cId_, _acVisited_) > 0
				_acReachable_ + _cId_
			ok
		next

		return _acReachable_

		def ReachableFromNode(pcNodeId)
			return This.ReachableFrom(pcNodeId)

	#--------------------#
	#  ANALYSIS METRICS  #
	#--------------------#

	# Returns the ids of the nodes whose in-degree plus out-degree is above the average over all nodes.
	#
	#   returns    a list of text
	#   warning    raises error R1 (divide by zero) on a graph without nodes, which also stops Show,
	#              AsciiArt and Explain on an empty graph
	#   see        NodeCriticality, MostCriticalNodes
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

	# Returns the share of possible directed edges that exist: edges divided by n times n-1; 0 for fewer than two nodes.
	#
	#   returns    a number between 0 and 1
	#   see        NodeDensity100, UndirectedNodeDensity, DensityCategory
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

	# Returns the directed density as a percentage, from 0 to 100.
	#
	#   returns    a number
	#   see        NodeDensity
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

	# Returns edges divided by the number of node pairs, n times n-1 over 2, as if edges had no direction.
	#
	#   returns    a number; above 1 when edges run both ways
	#   see        NodeDensity
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

	# Returns the undirected density as a percentage.
	#
	#   returns    a number
	#   see        UndirectedNodeDensity
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

	# TRUE if the directed density is below 0.5.
	#
	#   returns    TRUE or FALSE
	#   see        IsDense, DensityCategory
	#@ aka  --
	def IsSparse()
		return This.Density() < 0.5
	
	# TRUE if the directed density is 0.5 or more.
	#
	#   returns    TRUE or FALSE
	#   see        IsSparse, DensityCategory
	def IsDense()
		return This.Density() >= 0.5
	
	# Returns a word for the density: "empty" at 0, then "very sparse" below 0.25, "sparse" below 0.5, "dense" below 0.75, else "very dense".
	#
	#   returns    text
	#   see        NodeDensity, IsSparse
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

	# Returns the largest number of nodes reachable from any one node, which is not the hop count of the longest path.
	#
	#   returns    a number
	#   warning    known defect: the name promises a path length, but the body counts reachable
	#              nodes, so a node that reaches two branches of two nodes each answers 4, though no
	#              path is longer than 2 hops
	#   see        ImpactOf, ShortestPathLength, Diameter
	def LongestPath()
		_nMax_ = 0

		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			# same correction as ImpactOf: ReachableFrom does not include
			# the start node, so the -1 was subtracting nothing real
			_acReachable_ = This.ReachableFrom(_aNode_["id"])
			_nLength_ = len(_acReachable_)

			if _nLength_ > _nMax_
				_nMax_ = _nLength_
			ok
		end

		return _nMax_

	# Returns an empty list today instead of the ids of the nodes that lie on a cycle.
	#
	#   returns    [ ] today, even for a graph with a cycle
	#   warning    known defect: it looks for the node among the nodes it reaches, but ReachableFrom
	#              never lists the start node, so the test is never true; use HasCyclicDependencies
	#              for the graph
	#   see        HasCyclicDependencies, ReachableFrom
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

	# Returns pairs [ a, b ] of out-neighbours of one node whose onward reach shares no node, so the two branches could run in parallel.
	#
	#   returns    a list of pairs of ids; [ ] when every pair overlaps
	#   see        ReachableFrom, DependencyFreeNodes
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

	# Returns the ids of the nodes that nothing points to, the ones that depend on no other.
	#
	#   returns    a list of text
	#   see        Incoming, ImpactOf
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

	# Returns how many nodes a node can reach, the nodes that fail with it; 0 for an unknown node.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number
	#   see        FailureScope, ReachableFrom
	def ImpactOf(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		
		# ReachableFrom EXCLUDES the start node -- both the engine path and
		# the Ring fallback skip it, and say so. Subtracting one for a self
		# entry that is not there undercounted every impact by exactly one,
		# and answered -1 for a node that reaches nothing. A count cannot be
		# negative, which is what made it findable.
		return len(This.ReachableFrom(pcNodeId))

	# Returns the ids of the nodes that depend on a node, those it reaches; [ ] for an unknown node.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a list of text
	#   see        ImpactOf, ReachableFrom
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

	# Returns one hash list [ :id, :criticality ] per node, the criticality being its in-degree plus out-degree.
	#
	#   returns    a list of hash lists
	#   see        MostCriticalNodes, BottleneckNodes
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

	# Returns the ids of the nodes with the highest in-plus-out degree, the most critical first.
	#
	#   pnCount    How many nodes to return; 5 when empty.
	#   returns    a list of text, at most the count asked for
	#   note       an empty count means 5
	#   see        NodeCriticality, BottleneckNodes
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

	# Returns a stzGraphFinder on the nodes or the edges, to chain Where, Having, WithProperty and WithTag, then Run.
	#
	#   pcWhat     What to search: "nodes" or "edges".
	#   returns    a stzGraphFinder
	#   see        NodesWhere, EdgesWhere, QueryQ
	#@ aka  Opens a rich query on the graph. The finder is an OBJECT, so it carries the Q -- there is no data-shaped twin of a query builder.
	def FindQ(pcWhat)
		return new stzGraphFinder(This, pcWhat)

	# Returns the ids of the nodes whose :type property equals the given text.
	#
	#   returns    a list of ids
	#   see        NodesByProperty, NodesWhere
	def NodesByType(pcType)
		return This.FindQ("nodes").Where("type", "=", pcType).Run()

	# Returns the ids of the nodes whose property meets a comparison, such as priority > 5; label and id can be tested too.
	#
	#   pcProp     The property to test, as text; label, id and the node's own properties are
	#              accepted.
	#   pcOp       The comparison, such as "=", ">", "<", "contains" or "between".
	#   returns    a list of ids
	#   note       NodesW is the short spelling
	#   see        NodesByProperty, FindQ
	#@ aka  --
	def NodesWhere(pcProp, pcOp, pVal)
		return This.FindQ("nodes").Where(pcProp, pcOp, pVal).Run()

		def NodesW(pcProp, pcOp, pVal)
			return This.NodesWhere(pcProp, pcOp, pVal)

	# Returns the ids of the nodes whose property equals the value.
	#
	#   pcProp     The property to test, as text; label, id and the node's own properties are
	#              accepted.
	#   returns    a list of ids
	#   see        NodesWhere, NodesByType
	def NodesByProperty(pcProp, pVal)
		return This.FindQ("nodes").Where(pcProp, "=", pVal).Run()

	# Returns the [ from, to ] pairs of the edges whose property or label meets a comparison, such as weight > 2.
	#
	#   pcProp     The property to test, as text; label, id and the node's own properties are
	#              accepted.
	#   pcOp       The comparison, such as "=", ">", "<", "contains" or "between".
	#   returns    a list of [ from, to ] pairs
	#   note       EdgesW is the short spelling
	#   see        EdgesByProperty, FindQ
	def EdgesWhere(pcProp, pcOp, pVal)
		return This.FindQ("edges").Where(pcProp, pcOp, pVal).Run()

		def EdgesW(pcProp, pcOp, pVal)
			return This.EdgesWhere(pcProp, pcOp, pVal)

	# Returns the [ from, to ] pairs of the edges whose property or label equals the value.
	#
	#   pcProp     The property to test, as text; label, id and the node's own properties are
	#              accepted.
	#   returns    a list of [ from, to ] pairs
	#   see        EdgesWhere
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


	# Returns the paths of Paths for which a function answers TRUE.
	#
	#   pFunc      a function that takes one path, a list of ids, and returns TRUE or FALSE
	#   returns    a list of paths
	#   note       the function is called once per path of the whole graph
	#   see        Paths
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

	# Returns a stzGraphQuery on this graph, for queries the finder cannot express.
	#
	#   returns    a stzGraphQuery
	#   see        FindQ
	def QueryQ()
		return new stzGraphQuery(This)

	#--------------------#
	#  GRAPH ALGORITHMS  #
	#--------------------#

	# Returns the path with the fewest edges from one node to another, as ids; [ ] when there is none or an id is unknown.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        a list of node ids
	#   note           the same node twice answers a path of that one node
	#   see            Path, ShortestPathLength, WeightedShortestPath
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

	# Returns the node ids in breadth-first visit order from a node, the start first; [ ] when the node is unknown.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a list of text
	#   see        DFS, ReachableFrom
	#@ aka  Breadth-first visit order from a node (engine-backed).
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

	# Returns the node ids in depth-first visit order from a node, the start first; [ ] when the node is unknown.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a list of text
	#   see        BFS, ReachableFrom
	#@ aka  Depth-first visit order from a node (engine-backed).
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

	# TRUE if the nodes can be split into two groups so that every edge joins the two, reading edges without direction.
	#
	#   returns    TRUE or FALSE; TRUE for an empty graph
	#   see        IsConnected, Communities
	#@ aka  TRUE if the graph is 2-colourable (bipartite). Engine-backed.
	def IsBipartite()
		if This._EnsureEngine()
			return StzEngineGraphIsBipartite(@pEngineGraph) = 1
		ok
		return 0

	# Returns the groups of nodes that all reach one another, as lists of ids; a node on no cycle forms a group of its own.
	#
	#   returns    a list of lists of text
	#   see        NumberOfStronglyConnectedComponents, CyclicNodes
	#@ aka  Strongly connected components (directed) as a list of node-id groups. Two nodes share a group iff each is reachable from the other. Engine (Kosaraju). Returns [] if the engine is unavailable.
	def StronglyConnectedComponents()
		if This._EnsureEngine()
			# The engine bridge builds the grouped list (list of node-id
			# lists) entirely Zig-side -- returned ready, no Ring looping.
			return StzEngineGraphStronglyConnectedComponents(@pEngineGraph)
		ok
		return []

		def SCC()
			return This.StronglyConnectedComponents()

	# Returns how many groups of mutually reachable nodes the graph has.
	#
	#   returns    a number
	#   see        StronglyConnectedComponents
	#@ aka  Number of strongly connected components. Engine-backed.
	def NumberOfStronglyConnectedComponents()
		if This._EnsureEngine()
			return StzEngineGraphNumberOfSCC(@pEngineGraph)
		ok
		return 0

		def NumberOfSCC()
			return This.NumberOfStronglyConnectedComponents()

	# Returns the total weight of a minimum spanning tree over the undirected graph, using the :weight property, 1 by default.
	#
	#   returns    a number; -1 when the graph has no edge or is not connected
	#   see        MSTEdges
	#@ aka  Total weight of a minimum spanning tree over the undirected version of the graph (-1 if empty or not connected). Engine (Kruskal).
	def MSTWeight()
		if This._EnsureEngine()
			return StzEngineGraphMSTWeight(@pEngineGraph)
		ok
		return -1

		def MinimumSpanningTreeWeight()
			return This.MSTWeight()

	# Returns the edges of a minimum spanning tree as [ from, to, weight ] triples; a graph in several pieces gives a forest.
	#
	#   returns    a list of triples; [ ] when there is no edge
	#   note       the pair order is the engine's and may be the reverse of the edge's direction
	#   see        MSTWeight
	#@ aka  Minimum spanning tree as a list of [fromNode, toNode, weight] edges. Engine (Kruskal); built Zig-side. [] if not connected/empty.
	def MSTEdges()
		if This._EnsureEngine()
			return StzEngineGraphMSTEdges(@pEngineGraph)
		ok
		return []

		def MinimumSpanningTreeEdges()
			return This.MSTEdges()

	# Returns the ids of the nodes whose removal would split the graph, reading edges without direction.
	#
	#   returns    a list of text
	#   see        Bridges, ConnectedComponents
	#@ aka  Articulation points (cut vertices) -- nodes whose removal disconnects the (undirected) graph. Engine (Tarjan low-link). List of node ids.
	def ArticulationPoints()
		if This._EnsureEngine()
			return StzEngineGraphArticulationPoints(@pEngineGraph)
		ok
		return []

		def CutVertices()
			return This.ArticulationPoints()

	# Returns the edges whose removal would split the graph, as [ u, v ] pairs, reading edges without direction.
	#
	#   returns    a list of pairs of ids
	#   see        ArticulationPoints
	#@ aka  Bridges (cut edges) -- edges whose removal disconnects the (undirected) graph. Engine (Tarjan low-link). List of [u, v] node-id pairs.
	def Bridges()
		if This._EnsureEngine()
			return StzEngineGraphBridges(@pEngineGraph)
		ok
		return []

		def CutEdges()
			return This.Bridges()

	# Returns the cheapest path from one node to another by the :weight of the edges, 1 when an edge has none, as ids.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        a list of node ids; [ ] when none or unknown
	#   see            ShortestPath, WeightedShortestPathLength, AStarPath
	#@ aka  Weighted shortest path (Dijkstra over edge :weight properties, default 1.0). Returns the node-id path; [] if unreachable.
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

	# Returns the total weight of the cheapest path from one node to another, by the :weight of the edges.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        a number; -1 when unreachable or unknown
	#   see            WeightedShortestPath, SetEdgeWeight
	#@ aka  Total weight of the minimum-weight path (-1 if unreachable).
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

	# Returns the number of edges on the shortest path from one node to another.
	#
	#   pcFromNodeId   The id of the node the edge starts from.
	#   pcToNodeId     The id of the node the edge ends at.
	#   returns        a number; 0 when there is no path, which cannot be told from the same node
	#   see            ShortestPath, Diameter
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

	# Returns the groups of nodes found by walking out-edges from each node not seen yet, as lists of ids, in node order.
	#
	#   returns    a list of lists of text
	#   warning    edges are followed in their direction only, so b to a and c to a give three
	#              groups, although IsConnected, which ignores direction, answers TRUE
	#   see        NumberOfConnectedComponents, IsConnected, StronglyConnectedComponents
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

				if _pCcSeen_ != ""
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

		if _pCcSeen_ != ""
			StzEngineHashMapFree(_pCcSeen_)
		ok

		return _aCcComponents_

	# Membership in the visited set: the engine map when it is available,
	# else a needle-first scan of the fallback list.
	def _CcSeen(pSeenMap, pacSeenList, pcId)
		if pSeenMap != ""
			return StzEngineHashMapHasKey(pSeenMap, pcId)
		ok

		if StzFindFirst(pcId, pacSeenList) > 0
			return 1
		ok

		return 0

	#---------------------------------#
	#  ENGINE-BACKED GRAPH METHODS    #
	#---------------------------------#

	# Returns the node ids ordered so that every node comes before the nodes it points to; [ ] when the graph has a cycle.
	#
	#   returns    a list of text
	#   see        HasCyclicDependencies, DependencyFreeNodes
	def TopologicalSort()
		if This._EnsureEngine()
			_cEngResult_ = StzEngineGraphTopologicalSort(@pEngineGraph)
			return _cEngResult_
		ok
		return []

	# Returns how many edges arrive at a node; the id is matched in lowercase, and an unknown node gives 0.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number
	#   see        OutDegree, Incoming
	def InDegree(pcNodeId)
		if This._EnsureEngine()
			return StzEngineGraphInDegree(@pEngineGraph, StzLower(pcNodeId))
		ok
		return len(This.Incoming(pcNodeId))

	# Returns how many edges leave a node; the id is matched in lowercase, and an unknown node gives 0.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number
	#   see        InDegree, Neighbors
	def OutDegree(pcNodeId)
		if This._EnsureEngine()
			return StzEngineGraphOutDegree(@pEngineGraph, StzLower(pcNodeId))
		ok
		return len(This.Neighbors(pcNodeId))

	# Returns how many groups ConnectedComponents finds, counted by the engine, following edge direction.
	#
	#   returns    a number
	#   see        ConnectedComponents, IsConnected
	def NumberOfConnectedComponents()
		if This._EnsureEngine()
			return StzEngineGraphConnectedComponents(@pEngineGraph)
		ok
		return len(This.ConnectedComponents())

	# TRUE if every node can be reached from the first when edges are read without direction; one node or none is connected.
	#
	#   returns    TRUE or FALSE
	#   see        ConnectedComponents, PathExists
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

	# Returns how often a node lies on the shortest paths between other node pairs, computed by the engine; 0 for an unknown node.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number
	#   see        BetweennessCentralityAll, ClosenessCentrality
	#@ aka  (ArticulationPoints is now engine-backed -- see the def above.)
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

	# Returns the betweenness of every node as [ id, value ] pairs, in node order.
	#
	#   returns    a list of [ id, value ] pairs
	#   see        BetweennessCentrality
	#@ aka  Betweenness for every node as a list of [ id, value ] pairs.
	def BetweennessCentralityAll()
		if This._EnsureEngine()
			return StzEngineGraphBetweennessAll(@pEngineGraph)
		ok
		return []

	# Returns how close a node is to the nodes it reaches: reachable count over the sum of distances; 0 when unknown or isolated.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number
	#   see        ClosenessCentralityAll, BetweennessCentrality
	#@ aka  Closeness centrality (engine-backed): reachable / sum(distances). Returns the value for pcNodeId (0 if absent or isolated).
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

	# Returns the closeness of every node as [ id, value ] pairs, in node order.
	#
	#   returns    a list of [ id, value ] pairs
	#   see        ClosenessCentrality
	#@ aka  Closeness for every node as a list of [ id, value ] pairs.
	def ClosenessCentralityAll()
		if This._EnsureEngine()
			return StzEngineGraphClosenessAll(@pEngineGraph)
		ok
		return []

	# Returns the core number of a node: the largest k for which it stays in the k-core of the undirected view; 0 for an unknown node.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number
	#   see        CoreNumbers
	#@ aka  k-core: core number of pcNodeId -- the largest k for which the node survives in the k-core of the undirected view. Engine (Batagelj-Zaversnik).
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

	# Returns the core number of every node as [ id, value ] pairs, in node order.
	#
	#   returns    a list of [ id, value ] pairs
	#   see        CoreNumber
	#@ aka  Core number for every node as a list of [ id, value ] pairs.
	def CoreNumbers()
		if This._EnsureEngine()
			return StzEngineGraphCoreNumbersAll(@pEngineGraph)
		ok
		return []

		def CoreNumbersAll()
			return This.CoreNumbers()

	# Returns the PageRank score of a node, by power iteration with damping 0.85; 0 for an unknown node.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number
	#   see        PageRankAll
	#@ aka  PageRank (power iteration, damping 0.85) of pcNodeId. Engine-backed.
	def PageRank(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		if This._EnsureEngine()
			return StzEngineGraphPageRankOf(@pEngineGraph, StzLower(pcNodeId))
		ok
		return 0

	# Returns the PageRank score of every node as [ id, value ] pairs, in node order.
	#
	#   returns    a list of [ id, value ] pairs
	#   see        PageRank
	#@ aka  PageRank for every node as a list of [ id, value ] pairs.
	def PageRankAll()
		if This._EnsureEngine()
			return StzEngineGraphPageRankAll(@pEngineGraph)
		ok
		return []

	# Returns the cheapest path from a start to a goal by A*, using the :weight of edges and the :x and :y of nodes as the heuristic when present.
	#
	#   pcStart    The id of the node the search starts from.
	#   pcGoal     The id of the goal node, where the search ends.
	#   returns    a list of node ids; [ ] when none or unknown
	#   note       without coordinates it behaves like the weighted shortest path
	#   see        AStarPathManhattan, AStarPathWeighted, WeightedShortestPath
	#@ aka  A* shortest path (engine-backed). Uses edge weights plus a coordinate heuristic when nodes carry :x and :y properties (Euclidean by default); with no coordinates it degrades gracefully to a Dijkstra-equivalent. Returns the path as a list of node ids ([] if none).
	def AStarPath(pcStart, pcGoal)
		return This._AStarMode(pcStart, pcGoal, 1)

		def AStar(pcStart, pcGoal)
			return This.AStarPath(pcStart, pcGoal)

		def AStarShortestPath(pcStart, pcGoal)
			return This.AStarPath(pcStart, pcGoal)

	# Returns the cheapest path from a start to a goal by A* with the Manhattan heuristic over the :x and :y of nodes.
	#
	#   pcStart    The id of the node the search starts from.
	#   pcGoal     The id of the goal node, where the search ends.
	#   returns    a list of node ids; [ ] when none or unknown
	#   see        AStarPath
	#@ aka  A* with the Manhattan (taxicab) heuristic.
	def AStarPathManhattan(pcStart, pcGoal)
		return This._AStarMode(pcStart, pcGoal, 2)

	# Returns the cheapest path by A* with a heuristic scaled to the edge weights, so the path stays optimal when weights are not distances.
	#
	#   pcStart    The id of the node the search starts from.
	#   pcGoal     The id of the goal node, where the search ends.
	#   nMode      The heuristic: 1 for Euclidean distance between the :x and :y coordinates, 2 for
	#              Manhattan.
	#   returns    a list of node ids; [ ] when none or unknown
	#   see        AStarPath, AStarPlan
	#@ aka  A* with an auto-scaled ADMISSIBLE coordinate heuristic -- use when edge weights are not unit geometric distance (the heuristic is scaled by the minimum edge cost-per-distance ratio so the path stays optimal). nMode 1 = Euclidean coords, 2 = Manhattan.
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

	# Overrides the weight of an edge in the engine copy only, the stored :weight property staying as it is.
	#
	#   pcFrom     The id of the node the edge starts from.
	#   pcTo       The id of the node the edge ends at.
	#   nWeight    The new weight, as a number.
	#   returns    1 when the edge is known, 0 when it is not
	#   warning    the override is lost when the engine copy is rebuilt, which most graph changes
	#              cause, and the ids are matched in lowercase
	#   see        WeightedShortestPath, SetEdgeProperty
	#@ aka  Override the (engine) weight of a directed edge. Used by stzGraphPlanner to push per-optimisation transition costs before an engine A* search. Returns 1 on success, 0 if the edge is unknown.
	def SetEdgeWeight(pcFrom, pcTo, nWeight)
		if This._EnsureEngine()
			return StzEngineGraphSetEdgeWeight(@pEngineGraph, StzLower(pcFrom), StzLower(pcTo), nWeight)
		ok
		return 0

	# Returns the route and the explored nodes of one A* search as [ route, explored ], mode 0 being plain Dijkstra.
	#
	#   pcStart    The id of the node the search starts from.
	#   pcGoal     The id of the goal node, where the search ends.
	#   nMode      The heuristic: 1 for Euclidean distance between the :x and :y coordinates, 2 for
	#              Manhattan.
	#   returns    a list of two lists of ids; [ [ ], [ ] ] when a node is unknown
	#   note       when the goal cannot be reached the route is [ ] and the explored list still
	#              shows the nodes visited
	#   see        AStarPath
	#@ aka  Engine A* for planners: one search returns [ routeList, exploredList ] (the explored/closed order powers explainability metrics). nMode 0 is Dijkstra/UCS -- optimal for any non-negative edge cost.
	def AStarPlan(pcStart, pcGoal, nMode)
		if NOT (This.NodeExists(pcStart) and This.NodeExists(pcGoal))
			return [ [], [] ]
		ok
		if This._EnsureEngine()
			return StzEngineGraphAStarPlan(@pEngineGraph, StzLower(pcStart), StzLower(pcGoal), nMode)
		ok
		return [ [], [] ]

	# Returns the longest of all the shortest paths between reachable pairs, counted in edges.
	#
	#   returns    a number; 0 for a graph without edges
	#   see        Radius, Eccentricity, AveragePathLength
	#@ aka  Diameter = longest shortest path over all reachable pairs (engine, all-pairs BFS). Replaces the old O(V^2 * BFS) pure-Ring double loop.
	def Diameter()
		if This._EnsureEngine()
			return StzEngineGraphDiameter(@pEngineGraph)
		ok
		return 0

	# Returns the smallest eccentricity among the nodes that reach others.
	#
	#   returns    a number
	#   see        Diameter, Eccentricity
	#@ aka  Radius = smallest eccentricity among nodes that reach others.
	def Radius()
		if This._EnsureEngine()
			return StzEngineGraphRadius(@pEngineGraph)
		ok
		return 0

	# Returns the length in edges of the longest shortest path from a node to any node it reaches; 0 for an unknown node.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number
	#   see        Eccentricities, Diameter
	#@ aka  Eccentricity of a node = its longest shortest path to any reachable node.
	def Eccentricity(pcNodeId)
		if NOT This.NodeExists(pcNodeId)
			return 0
		ok
		if This._EnsureEngine()
			return StzEngineGraphEccentricityOf(@pEngineGraph, StzLower(pcNodeId))
		ok
		return 0

	# Returns the eccentricity of every node as [ id, value ] pairs, in node order.
	#
	#   returns    a list of [ id, value ] pairs
	#   see        Eccentricity
	#@ aka  Eccentricity for every node as a list of [ id, value ] pairs.
	def Eccentricities()
		if This._EnsureEngine()
			return StzEngineGraphEccentricitiesAll(@pEngineGraph)
		ok
		return []

	# Returns the mean length of the shortest paths over all reachable pairs of nodes.
	#
	#   returns    a number
	#   see        Diameter
	#@ aka  Mean shortest-path length over all reachable pairs (engine, all-pairs BFS).
	def AveragePathLength()
		if This._EnsureEngine()
			return StzEngineGraphAveragePathLength(@pEngineGraph)
		ok
		return 0

	# Returns the maximum flow from a source to a sink, taking the :weight of each edge as its capacity, 1 by default.
	#
	#   pcSource   The id of the node the flow starts from.
	#   pcSink     The id of the node the flow ends at.
	#   returns    a number; 0 when a node is unknown or no flow can pass
	#   see        MinCut, MinCostMaxFlow
	#@ aka  Maximum flow from pcSource to pcSink (Edmonds-Karp, engine). Edge :weight is the capacity (default 1). Returns the flow value.
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

	# Returns the saturated edges that separate the sink from the source, as [ from, to ] pairs, by max-flow and min-cut.
	#
	#   pcSource   The id of the node the flow starts from.
	#   pcSink     The id of the node the flow ends at.
	#   returns    a list of pairs of ids; [ ] when a node is unknown
	#   see        MaxFlow
	#@ aka  Minimum cut between pcSource and pcSink: the saturated edges crossing the cut, as a list of [from, to] id pairs (max-flow / min-cut). Engine.
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

	# Returns the communities found by label propagation on the undirected view, as lists of node ids.
	#
	#   returns    a list of lists of text
	#   see        NumberOfCommunities, ConnectedComponents
	#@ aka  Community detection (label propagation, engine, undirected view). Returns a list of communities, each a list of node ids.
	def Communities()
		if This._EnsureEngine()
			return StzEngineGraphCommunities(@pEngineGraph)
		ok
		return []

		def DetectCommunities()
			return This.Communities()

	# Returns how many communities label propagation finds.
	#
	#   returns    a number
	#   see        Communities
	def NumberOfCommunities()
		if This._EnsureEngine()
			return StzEngineGraphNumberOfCommunities(@pEngineGraph)
		ok
		return 0

	# Returns the maximum flow from a source to a sink and its cost, :weight being the capacity and :cost the price per unit.
	#
	#   pcSource   The id of the node the flow starts from.
	#   pcSink     The id of the node the flow ends at.
	#   returns    a pair [ flow, cost ]; [ 0, 0 ] when a node is unknown
	#   see        MaxFlow
	#@ aka  Min-cost max-flow from pcSource to pcSink. Edge :weight is capacity, edge :cost is per-unit cost. Returns [ flowValue, totalCost ]. Engine (successive shortest paths).
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

	# Returns the share of the possible links among a node's neighbours that exist, on the undirected view; 0 for an unknown node.
	#
	#   pcNodeId   The node id, as text.
	#   returns    a number between 0 and 1
	#   see        ClusteringCoefficients
	#@ aka  Local clustering coefficient (engine, undirected view): edges among a node's neighbours / possible such edges. Replaces the old O(k^2) pure-Ring EdgeExists double loop.
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

	# Returns the clustering coefficient of every node as [ id, value ] pairs, in node order.
	#
	#   returns    a list of [ id, value ] pairs
	#   see        ClusteringCoefficient
	#@ aka  Local clustering coefficient for every node as [ id, value ] pairs.
	def ClusteringCoefficients()
		if This._EnsureEngine()
			return StzEngineGraphClusteringAll(@pEngineGraph)
		ok
		return []

	# Returns the sum of the :weight of the edges along a path; a step with no edge in the graph is skipped.
	#
	#   pacPath    A path as a list of node ids; the last id names the node.
	#   returns    a number
	#   warning    an edge on the path that has no :weight property raises an error, because the
	#              weight is read with EdgeProperty
	#   see        WeightedShortestPathLength, EdgeProperty
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

	# Returns the graph as one hash list [ :id, :nodes, :edges, :properties ], for conversion or inspection.
	#
	#   returns    a hash list
	#   see        ExportToJSON, Nodes, Edges
	def ToHashlist()
		return [
			:id = @cId,
			:nodes = @aNodes,
			:edges = @aEdges,
			:properties = This.Properties()
		]

	# Returns the graph as Graphviz DOT text, one box per node and one arrow per edge with its label.
	#
	#   returns    text
	#   note       ToDot is another spelling and ExportToDotQ chains a stzDotCode
	#   see        Display, ToCanvas
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

	# Returns the graph as JSON text holding its id, nodes, edges and a metrics block with counts, density, longest path and cycles.
	#
	#   returns    text
	#   note       the metrics block uses the density and the longest path of this class, so it
	#              inherits their limits
	#   see        ExportToYAML, ToHashlist
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

	# Returns the graph as YAML text with its nodes, edges and the names of the node properties.
	#
	#   returns    text
	#   note       node property values and edge properties are not written, only the node property
	#              names
	#   see        ExportToJSON
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

	# Returns the graph as GraphML text, with node labels, edge labels and properties written as data keys.
	#
	#   returns    text
	#   note       LoadFromGraphML cannot read this text back today
	#   see        SaveToGraphML, ExportToDOT
	def ExportToGraphML()
		_cXML_ = '<?xml version="1.0" encoding="UTF-8"?>' + char(10)
		_cXML_ += '<graphml xmlns="http://graphml.graphdrawing.org/xmlns"' + char(10)
		_cXML_ += '         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + char(10)
		_cXML_ += '         xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns' + char(10)
		_cXML_ += '         http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">' + char(10) + char(10)
		
		# Define keys for properties
		_cXML_ += '  <key id="label" for="node" attr.name="label" attr.type="string"/>' + char(10)
		_cXML_ += '  <key id="type" for="graph" attr.name="type" attr.type="string"/>' + char(10)
		_cXML_ += '  <key id="edge_label" for="edge" attr.name="label" attr.type="string"/>' + char(10)
		
		# Add custom property keys
		_aAllProps_ = This.PropertiesXT()
		_nLen_ = len(_aAllProps_)
		for i = 1 to _nLen_
			_cPropKey_ = _aAllProps_[i][1]
			_cXML_ += '  <key id="prop_' + _cPropKey_ + '" for="node" attr.name="' + _cPropKey_ + '" attr.type="string"/>' + char(10)
		next
		_cXML_ += char(10)
		
		# Graph element
		_cXML_ += '  <graph id="' + @cId + '" edgedefault="directed">' + char(10)
		_cXML_ += '    <data key="type">' + @cGraphType + '</data>' + char(10) + char(10)
		
		# Nodes
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cXML_ += '    <node id="' + This._XMLEscape(_aNode_[:id]) + '">' + char(10)
			_cXML_ += '      <data key="label">' + This._XMLEscape(_aNode_[:label]) + '</data>' + char(10)
			
			if HasKey(_aNode_, :properties) and len(_aNode_[:properties]) > 0
				_aProps_ = _aNode_[:properties]
				_acKeys_ = keys(_aProps_)
				_nKeyLen_ = len(_acKeys_)
				for j = 1 to _nKeyLen_
					_cKey_ = _acKeys_[j]
					pVal = _aProps_[_cKey_]
					_cXML_ += '      <data key="prop_' + _cKey_ + '">' + This._XMLEscape(This._ValueToString(pVal)) + '</data>' + char(10)
				next
			ok
			
			_cXML_ += '    </node>' + char(10)
		next
		_cXML_ += char(10)
		
		# Edges
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			_cXML_ += '    <edge id="e' + i + '" source="' + This._XMLEscape(_aEdge_[:from]) + '" target="' + This._XMLEscape(_aEdge_[:to]) + '">' + char(10)
			
			if _aEdge_[:label] != ""
				_cXML_ += '      <data key="edge_label">' + This._XMLEscape(_aEdge_[:label]) + '</data>' + char(10)
			ok
			
			if HasKey(_aEdge_, :properties) and len(_aEdge_[:properties]) > 0
				_aProps_ = _aEdge_[:properties]
				_acKeys_ = keys(_aProps_)
				_nKeyLen_ = len(_acKeys_)
				for j = 1 to _nKeyLen_
					_cKey_ = _acKeys_[j]
					pVal = _aProps_[_cKey_]
					_cXML_ += '      <data key="prop_' + _cKey_ + '">' + This._XMLEscape(This._ValueToString(pVal)) + '</data>' + char(10)
				next
			ok
			
			_cXML_ += '    </edge>' + char(10)
		next
		
		_cXML_ += '  </graph>' + char(10)
		_cXML_ += '</graphml>' + char(10)
		
		return _cXML_
	
		def ToGraphML()
			return This.ExportToGraphML()
	
		def AsGraphML()
			return This.ExportToGraphML()
	
	# Writes the graph to a file as GraphML text, replacing any file there.
	#
	#   returns    nothing; a file is written
	#   see        ExportToGraphML, LoadFromGraphML
	def SaveToGraphML(pcPath)
		_cContent_ = This.ExportToGraphML()
		write(pcPath, _cContent_)
	
		# Writes the graph to a GraphML file; another spelling of the save.
		#
		#   returns    nothing; a file is written
		#   see        SaveToGraphML
		def SaveAsGraphML(pcPath)
			This.SaveToGraphML(pcPath)
	
	# Raises error "Incorrect Id" today instead of reading a GraphML file into the graph, and leaves odd nodes behind.
	#
	#   returns    nothing useful today
	#   note       LoadFromStzGraf reads back a graph written by SaveToStzGraf, within the limits of
	#              its own warning
	#   warning    known defect: the parser cuts the text at fixed positions instead of the
	#              positions it finds, so even a file written by SaveToGraphML yields garbled ids
	#              such as "sion=" and raises; the graph is left with those nodes
	#   see        ExportToGraphML, LoadFromStzGraf
	def LoadFromGraphML(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		_cContent_ = read(pcPath)
		This._ParseGraphML(_cContent_)
	
		# Raises error "Incorrect Id" today instead of reading a GraphML file into the graph.
		#
		#   returns    nothing useful today
		#   warning    known defect: it only calls LoadFromGraphML, whose parser fails on every file
		#              written by SaveToGraphML and leaves garbled nodes behind
		#   see        LoadFromGraphML
		def LoadGraphML(pcPath)
			This.LoadFromGraphML(pcPath)
	
		# Raises error "Incorrect Id" today instead of importing a GraphML file into the graph.
		#
		#   returns    nothing useful today
		#   warning    known defect: it only calls LoadFromGraphML, whose parser fails on every file
		#              written by SaveToGraphML and leaves garbled nodes behind
		#   see        LoadFromGraphML
		def ImportFromGraphML(pcPath)
			This.LoadFromGraphML(pcPath)
	
		# Raises error "Incorrect Id" today instead of importing a GraphML file into the graph.
		#
		#   returns    nothing useful today
		#   warning    known defect: it only calls LoadFromGraphML, whose parser fails on every file
		#              written by SaveToGraphML and leaves garbled nodes behind
		#   see        LoadFromGraphML
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
		while 1
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
			while 1
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
		while 1
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
			while 1
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

	# Prints the graph as boxes and arrows in the console, vertically, with the bottleneck nodes marked by exclamation marks.
	#
	#   returns    nothing; text is printed
	#   note       raises error R1 on a graph without nodes
	#   see        AsciiArt, ShowHorizontal, BottleneckNodes
	def Show()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		_oViz_.Show()

		# Prints the graph as boxes and arrows; a misspelled alternative form of the display call.
		#
		#   returns    nothing; text is printed
		#   see        Show
		def Shwo()
			This.Show()

	# Returns the vertical picture of the graph as text instead of printing it, the same drawing the display call prints.
	#
	#   returns    text; each line ends with a line break
	#   warning    raises error R1 on a graph without nodes
	#   see        Show, AsciiArtHorizontal
	#@ aka  The same picture as DATA, for a file, a report, or a test. Show() prints it; these hand it back.
	def AsciiArt()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		return _oViz_.AsciiArt()

	# Returns the horizontal picture of the graph as text: boxes in a row joined by labelled arrows.
	#
	#   returns    text
	#   warning    raises error R1 on a graph without nodes
	#   see        ShowHorizontal, AsciiArt
	def AsciiArtHorizontal()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		return _oViz_.AsciiArtHorizontal()

	# Returns the graph as a rendition value of kind graph, holding its DOT text, for a consumer to lay out.
	#
	#   returns    a rendition hash list [ :kind, :mime, :content, :locator, :title ]
	#   see        RenditionAs, RenditionKinds
	#@ aka  DISPLAY, not View -- the same correction as stzDiagram's, and for the same reason: `View` is a NOUN in this module (stzGraphView, ToView(), IsView()) meaning a filtered projection of the graph. Using it as a verb for "open a window" made one word mean two things in one namespace. Both older spellings are kept as alternative forms, since stzOrgChart and stzWorkflow call View() internally. -- A VALU
	def Rendition()
		return This.RenditionAs(:graph)

	# Returns the kinds of rendition a graph can give: graph and text.
	#
	#   returns    a list of text
	#   see        RenditionAs
	def RenditionKinds()
		return [ :graph, :text ]

	# Returns the graph as a rendition of the given kind: graph holds the DOT text, text holds a one-line count of nodes and edges.
	#
	#   pcKind     The kind of rendition: "graph" or "text".
	#   returns    a rendition hash list
	#   warning    any other kind raises an error
	#   see        Rendition, RenditionKinds
	def RenditionAs(pcKind)
		_k_ = StzLower(ring_trim("" + pcKind))
		if _k_ = "graph"
			return StzRendition(:graph, "text/vnd.graphviz", This.Dot(), "",
				"" + This.NumberOfNodes() + " nodes and " + This.NumberOfEdges() + " edges")
		but _k_ = "text"
			return StzRendition(:text, "text/plain",
				"" + This.NumberOfNodes() + " nodes, " + This.NumberOfEdges() + " edges",
				"", "what this graph holds")
		ok
		stzraise("stzGraph.RenditionAs: '" + _k_ + "' is not a way a graph shows " +
			"itself -- graph or text.")

	# Writes the graph as DOT code and opens it in the external Graphviz viewer; it returns nothing.
	#
	#   returns    nothing; a viewer is started
	#   note       not checked here: it starts an external Graphviz viewer
	#   see        Show, ExportToDOT
	def Display()
		_oDot_ = new stzDotCode()
		_oDot_.SetCode(This.Dot())
		_oDot_.RunAndView()

		# Opens the graph in the external Graphviz viewer; an alternative form of the display call.
		#
		#   returns    nothing; a viewer is started
		#   note       not checked here: it starts an external Graphviz viewer
		#   see        Display
		#< @FunctionAlternativeForm
		def View()
			This.Display()

		# Opens the graph in the external Graphviz viewer; a misspelled alternative form of the display call.
		#
		#   returns    nothing; a viewer is started
		#   note       not checked here: it starts an external Graphviz viewer
		#   see        Display
		def Veiw()
			This.Display()

	# Prints the graph in the console as a row of boxes joined by labelled arrows.
	#
	#   returns    nothing; text is printed
	#   note       raises error R1 on a graph without nodes
	#   see        ShowH, AsciiArtHorizontal
		#>
	def ShowHorizontal()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		_oViz_.ShowHorizontal()

		# Prints the graph as a row of boxes; the short spelling of the horizontal display.
		#
		#   returns    nothing; text is printed
		#   see        ShowHorizontal
		def ShowH()
			This.ShowHorizontal()

	# Prints the graph as a column of boxes joined by arrows, the default layout of the display.
	#
	#   returns    nothing; text is printed
	#   see        Show, ShowV
	def ShowVertical()
		_oViz_ = new stzGraphAsciiVisualizer(This)
		_oViz_.ShowVertical()

		# Prints the graph as a column of boxes; the short spelling of the vertical display.
		#
		#   returns    nothing; text is printed
		#   see        ShowVertical
		def ShowV()
			This.ShowVertical()

	#------------------------#
	#  EXPLAINING THE GRAPH  #
	#------------------------#

	# Returns a hash list of short sentences about the graph in five sections: general, bottlenecks, cycles, metrics and rules.
	#
	#   returns    a hash list [ :general, :bottlenecks, :cycles, :metrics, :rules ] of lists of
	#              text
	#   note       the longest-path line inherits the limits of LongestPath
	#   warning    the density line prints the 0-to-1 ratio followed by a percent sign, so 0.20
	#              reads as 0.20%; raises error R1 on an empty graph and R5 on a graph with nodes
	#              but no edge
	#   see        ExplainPath, BottleneckNodes, NodeDensity
	#@ aka  Telling the story of the graph
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
			$aoExplanation[:metrics] + "Density: 0% (no connections)"
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

	# Returns one sentence per edge of the first path found between two nodes, with the edge label as the reason; [ ] when there is no path.
	#
	#   pcFrom     The id of the node the edge starts from.
	#   pcTo       The id of the node the edge ends at.
	#   returns    a list of text
	#   note       a path of more than 10 edges is not found, as for Path
	#   see        Path, Explain
	#@ aka  Telling the story of a particular path
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
	
	# Loads the rules of a registered group into the graph, each into its constraint, derivation or validation store; known names are skipped.
	#
	#   pcRuleGroup   the group name, such as dag or semantic
	#   returns       nothing; the graph changes
	#   note          an unknown group name does nothing and raises nothing
	#   see           AddRule, ActiveRules, ApplyDerivationRules
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
				return 1
			ok
		next
		return 0

	def _IsKnownRuleType(pcType)
		_cT_ = StzLower("" + pcType)
		return _cT_ = "constraint" or _cT_ = "derivation" or _cT_ = "validation"

	# Runs the derivation rules once and adds the edges they give; it returns nothing, where ApplyDerivationRulesXT returns what happened.
	#
	#   returns    nothing; edges may be added
	#   see        ApplyDerivationRulesXT, EnableAutoDerive, UseRulesFrom
	def ApplyDerivationRules()
		This.ApplyDerivationRulesXT()

	def ApplyDerivationRulesXT()
		# Temporarily disable constraints during derivation
		_bOldState_ = @bEnforceConstraints
		@bEnforceConstraints = 0  # Bypass constraints during derivation
		
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

	# Tests an edge about to be added against every constraint rule and returns whether it is allowed with the violations found.
	#
	#   paOperationParams   The operation to test, as a hash list [ :from = id, :to = id, :label =
	#                       text ].
	#   returns             a pair [ allowed, violations ]: allowed is TRUE or FALSE, violations a
	#                       list of hash lists [ :rule, :message, :severity, :params ]
	#   see                 CanAddEdge, WhyCannotAddEdge
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

	# Returns the names of the rules that have added edges to the graph, each listed once.
	#
	#   returns    a list of text
	#   see        RulesSummary, ApplyDerivationRules
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

	  #-------------------------------------------------------------#
	 #  THE GRAPH OWNS ITS RULES (Softanza orientation)            #
	#-------------------------------------------------------------#
	#
	# You attach a rule to the graph, and it becomes part of the graph's own
	# logic. Then you query / run / report FROM the graph -- the scope stays on
	# the graph, never inverts to rule.Check(graph).
	#
	#   g.AddRule( new stzGraphRule("no-orphan").WhenQ(...).ThenViolationQ(...) )
	#   g.UseRuleSet( StzAgentRuleSetQ() )      # attach a whole set's rules
	#   ? g.CheckRules()                        # the graph checks ITSELF
	#   ? g.RulesAreSound()
	#   g.RulesReport()

	def _OwnRuleSet()
		if @oOwnRuleSet = ""
			@oOwnRuleSet = new stzGraphRuleSet("" + @cId)
		ok
		return @oOwnRuleSet

	# Attaches one stzGraphRule object to the graph, so that CheckRules judges it; the Q form returns the graph.
	#
	#   poRule     The stzGraphRule to attach.
	#   returns    nothing; the graph changes
	#   note       these attached rule objects are kept apart from the three stores that
	#              UseRulesFrom fills
	#   see        UseRuleSet, CheckRules, AttachedRules
	#@ aka  Attach one rule. Plain does the act; the Q form chains (Q convention).
	def AddRule(poRule)
		This._OwnRuleSet().AddRule(poRule)

		def AddRuleQ(poRule)
			This.AddRule(poRule)
			return This

	# Attaches every rule of a stzGraphRuleSet to the graph.
	#
	#   poRuleSet   The stzGraphRuleSet whose rules are attached.
	#   returns     nothing; the graph changes
	#   note        raises error R13 when the argument is not an object
	#   see         AddRule, CheckRules
	#@ aka  Attach every rule of a set (e.g. a domain rule set) to this graph.
	def UseRuleSet(poRuleSet)
		_aR_ = poRuleSet.Rules()
		_n_ = len(_aR_)
		for _i_ = 1 to _n_
			This._OwnRuleSet().AddRule(_aR_[_i_])
		next

		def UseRuleSetQ(poRuleSet)
			This.UseRuleSet(poRuleSet)
			return This

	# Makes the graph check itself against its attached rule objects and returns the findings.
	#
	#   returns    a list of hash lists [ :rule, :subject, :where, :severity, :message ]; [ ] when
	#              nothing is attached or found
	#   see        AddRule, RulesAreSound, RulesReport
	#@ aka  The graph checks ITSELF against its attached rules. Returns unified findings [ :rule, :subject, :where, :severity, :message ].
	def CheckRules()
		if @oOwnRuleSet = ""
			return []
		ok
		return @oOwnRuleSet.Check(This)

	# TRUE if the attached rules find no error; warnings alone do not make the graph unsound.
	#
	#   returns    TRUE or FALSE
	#   see        CheckRules, RulesReport
	#@ aka  SOUND IS NO ERROR, not no finding -- StzFindingsAreSound is the house's one answer, and this line counted findings until 2026-09-11. A code graph carrying only warning-severity findings (thirteen of stzCodeRules' rules are warnings) read as not sound, which is the opposite of what setting a rule to warning means.
	def RulesAreSound()
		return StzFindingsAreSound(This.CheckRules())

	# Returns the rule objects attached to the graph.
	#
	#   returns    a list of stzGraphRule objects
	#   see        AddRule, AttachedRuleNamed, NumberOfAttachedRules
	def AttachedRules()
		return This._OwnRuleSet().Rules()

	# Returns how many rule objects are attached to the graph.
	#
	#   returns    a number
	#   see        AttachedRules
	def NumberOfAttachedRules()
		if @oOwnRuleSet = ""
			return 0
		ok
		return @oOwnRuleSet.NumberOfRules()

	# Returns the attached rule object that has the given name.
	#
	#   pcName     the rule name, as text
	#   returns    a stzGraphRule object; empty text when none matches
	#   see        AttachedRules
	def AttachedRuleNamed(pcName)
		return This._OwnRuleSet().RuleNamed(pcName)

	# Prints the findings of the attached rules, grouped by domain with a verdict, and returns the graph.
	#
	#   returns    the graph itself
	#   see        CheckRules, RulesAreSound
	#@ aka  Print the graph's own rule findings, grouped and gated -- via stzRuleReport (the graph collects itself into it, then shows it).
	def RulesReport()
		_oRep_ = new stzRuleReport("" + @cId)
		_oRep_.Ingest(This.CheckRules())
		_oRep_.Report()
		return This

	# Detaches every attached rule object and returns the graph.
	#
	#   returns    the graph itself
	#   see        AddRule, AttachedRules
	def ClearAttachedRules()
		@oOwnRuleSet = ""
		return This

	# Returns every rule held in the three stores, constraint then derivation then validation, as hash lists.
	#
	#   returns    a list of hash lists [ :name, :type, :function, :params, :message, :severity ]
	#   see        NumberOfRules, RulesSummary, ActiveRules
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

	# Returns how many rules the three stores hold; the attached rule objects are not counted.
	#
	#   returns    a number
	#   see        Rules, NumberOfAttachedRules
	def NumberOfRules()
		return len(This.Rules())

	# Returns the rule names by store, as a hash list [ :constraint, :derivation, :validation, :applied ] of lists of text.
	#
	#   returns    a hash list
	#   see        Rules, ActiveRules, RulesApplied
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


	    # Empties the constraint, derivation and validation stores and forgets which rules were applied.
	    #
	    #   returns    nothing; the graph changes
	    #   see        ClearConstraintRules, RemoveRule
	    def ClearRules()
	        @aConstraintRules = []
	        @aDerivationRules = []
	        @aValidationRules = []
	        @aAffectedNodes = []
	        @aAffectedEdges = []
	    
	    # Empties the constraint store only, so edges are no longer tested against it.
	    #
	    #   returns    nothing; the graph changes
	    #   see        ClearRules
	    #@ aka  Clear specific type
	    def ClearConstraintRules()
	        @aConstraintRules = []
	        
	    # Empties the derivation store only.
	    #
	    #   returns    nothing; the graph changes
	    #   see        ClearRules
	    def ClearDerivationRules()
	        @aDerivationRules = []
	        
	    # Empties the validation store only.
	    #
	    #   returns    nothing; the graph changes
	    #   see        ClearRules
	    def ClearValidationRules()
	        @aValidationRules = []
	    
	    # Removes the rule with that name from all three stores; the name is folded to upper case before the match.
	    #
	    #   _cRuleName_   The name of the rule to remove, as text; case is ignored.
	    #   returns       nothing; the graph changes
	    #   warning       rule names registered through a group are stored in upper case, and a name
	    #                 loaded from a file keeps its own case, so a lowercase file rule is not
	    #                 found
	    #   see           HasRule, ClearRules
	    #@ aka  Remove specific rule
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
	    
	# TRUE if a constraint rule has that name; the name is folded to upper case first.
	#
	#   pcRuleName   The rule name, as text.
	#   returns      TRUE or FALSE
	#   warning      known defect: derivation and validation rules are never found, because their
	#                names are lowered before the comparison with an upper-case name, so a rule that
	#                is loaded can still answer FALSE
	#   see          RemoveRule, ActiveRules
	#@ aka  Check if rule loaded
	def HasRule(pcRuleName)
		if NOT isString(pcRuleName)
			stzraise("Rule name must be a string!")
		ok
	
		pcRuleName = UPPER(pcRuleName)

		# Check Constraint rules
		_nLen_ = len(@aConstraintRules)
		for i = 1 to _nLen_
			if @aConstraintRules[i][:name] = pcRuleName
				return 1
			ok
		next
	
		# Check Derivation rules
		_nLen_ = len(@aDerivationRules)
		for i = 1 to _nLen_
			if StzLower(@aDerivationRules[i][:name]) = pcRuleName
				return 1
			ok
		next
	
		# Check Validation rules
		_nLen_ = len(@aValidationRules)
		for i = 1 to _nLen_
			if StzLower(@aValidationRules[i][:name]) = pcRuleName
				return 1
			ok
		next
	
		return 0
	
		def ContainsRule(pcRuleName)
			return This.HasRule(pcRuleName)
	    
	    # Returns the loaded rules as [ type, name ] pairs, constraints first, then derivations, then validations.
	    #
	    #   returns    a list of pairs of text
	    #   see        Rules, HasRule
	    #@ aka  List active rules
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

	# Returns the names of the rule groups that Validate runs by default: dag, reachability, completeness and bottleneck.
	#
	#   returns    a list of text
	#   see        Validate
	def Validators()
		return @acValidators

	# Loads and runs the default rule groups and returns an overall verdict with one result per group.
	#
	#   returns    a hash list [ :status, :validatorsrun, :validatorsfailed, :totalissues, :results,
	#              :affectednodes ]
	#   note       the rules of each group are added to the graph's validation store as a side
	#              effect
	#   see        ValidateDAG, ValidateReachability, ValidateCompleteness, Validators
	def Validate()
		return This.ValidateXT(@acValidators)

	def ValidateXT(paValidators)
		if isString(paValidators)
			return This._ValidateSingle(paValidators)
		but isList(paValidators)
			return This._ValidateMultiple(paValidators)
		ok

	# Runs the dag rule group and returns its verdict: pass when the graph has no cycle.
	#
	#   returns    a hash list [ :status, :rulegroup, :domain, :issuecount, :issues, :affectednodes
	#              ]
	#   see        Validate, HasCyclicDependencies
	def ValidateDAG()
		return This.ValidateXT(:DAG)

	# Runs the reachability rule group and returns its verdict: pass when the graph is connected.
	#
	#   returns    a hash list [ :status, :rulegroup, :domain, :issuecount, :issues, :affectednodes
	#              ]
	#   see        Validate, IsConnected
	def ValidateReachability()
		return This.ValidateXT(:Reachability)

	# Runs the completeness rule group and returns its verdict: pass when the graph is connected and has no orphan node.
	#
	#   returns    a hash list [ :status, :rulegroup, :domain, :issuecount, :issues, :affectednodes
	#              ]
	#   see        Validate, DependencyFreeNodes
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
			
			# :domain mirrors :ruleGroup because stzWorkflow's own validators
			# name this same field :domain. Emitting both means a caller that
			# validates across the two classes no longer has to know which one
			# answered. Neither key is removed.
			return [
				:status = "fail",
				:ruleGroup = _cValidator_,
				:domain = _cValidator_,
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
			:domain = _cValidator_,
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
	
	# Returns the record of the last validation that passed; before any pass it answers that none has run.
	#
	#   returns    a hash list [ :status, :rules_applied, :violations, :violation_count, :passed ]
	#              or [ :status, :message ]
	#   warning    known defect: a failed validation is never recorded, so after a failure the
	#              summary still shows the older pass, or none has run, and its violations list is
	#              always empty
	#   see        Validate, Anomalies
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

	# Returns the violations of the last recorded validation, which is always an empty list today.
	#
	#   returns    a list; empty text before any validation passed
	#   warning    known defect: only passing validations are recorded, so this can never list a
	#              violation; read the issues of Validate instead
	#   see        ValidationSummary, Validate
	def Anomalies()
		return This.ValidationSummary()[:violations]

		def Issues()
			return This.Anomalies()

		def Violations()
			return This.Anomalies()

	#====================#
	#  GRAPH COMPARISON  #
	#====================#

	# Compares this graph with another and returns what changed: summary, nodes, edges, metrics, topology, impact and an explanation.
	#
	#   oOtherGraph   The stzGraph to compare with.
	#   returns       a hash list [ :summary, :nodes, :edges, :metrics, :topology, :impact,
	#                 :explanation ]; raises an error when the argument is not a stzGraph
	#   note          edges are compared by their from and to ids, and a changed label shows under
	#                 modified
	#   see           CompareWithManyQR, ExportToStzSim
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

		# Compares this graph with several others and returns the result as the kind asked for.
		#
		#   paoGraphs      The graphs to compare with: [ g1, g2 ] or named, [ [ "name", g1 ], ... ].
		#   pcReturnType   The kind of answer wanted: :stzGraphComparison, :stzHashList or
		#                  :stzListOfLists.
		#   returns        a stzGraphComparison, a stzHashList or a stzListOfLists; any other kind
		#                  raises an error
		#   see            CompareWith, stzGraphComparison
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
							_aChanges_ + [:property, _cKey_, "", pVarVal]
						ok
					next
					
					# Check for removed properties
					_acBaseKeys_ = keys(_aBaseProps_)
					_nKeyLen_ = len(_acBaseKeys_)
					for j = 1 to _nKeyLen_
						_cKey_ = _acBaseKeys_[j]
						if NOT HasKey(_aVarProps_, _cKey_)
							_aChanges_ + [:property, _cKey_, _aBaseProps_[_cKey_], ""]
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
		if _aMetrics_[:hasCycles][:from] = 0 and _aMetrics_[:hasCycles][:to] = 1
			_acExplanation_ + "Warning: Cycles introduced"
		but _aMetrics_[:hasCycles][:from] = 1 and _aMetrics_[:hasCycles][:to] = 0
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
	
	# Loads the graph from a file, choosing the reader by the extension: graf, rulz or graphml; any other raises an error.
	#
	#   returns    nothing; the graph changes
	#   warning    the extension is read as the second dot-separated piece of the path, so a path
	#              such as ./g.graf or one with an extra dot raises "Unsupported file format"; the
	#              graphml reader fails today
	#   see        SaveTo, LoadFromStzGraf, LoadFromStzRulz
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

	# Saves the graph to a file, choosing the writer by the extension: graf, rulz or graphml; any other raises an error.
	#
	#   returns    nothing; a file is written
	#   warning    the extension is read as the second dot-separated piece of the path, so a path
	#              such as ./g.graf or one with an extra dot raises "Unsupported file format"
	#   see        LoadFrom, SaveToStzGraf
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
	
	# Returns the graph as .stzgraf text: its id and type, the nodes with their labels, the edges with their labels and the node properties.
	#
	#   returns    text
	#   note       edge properties are not written
	#   see        SaveToStzGraf, LoadFromStzGraf
	def ExportToStzGraf()
		_cOutput_ = 'graph "' + @cId + '"' + char(10)
		_cOutput_ += '    type: ' + @cGraphType + char(10) + char(10)
		
		# Nodes section
		#
		# A node carries its LABEL the same way an edge does -- quoted,
		# after the id:  ceo "CEO". Written only when it says something
		# the id does not, so a file of plain ids stays a file of plain
		# ids (and every .stzgraf written before labels existed still
		# reads).
		_cOutput_ += "nodes" + char(10)
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_cOutput_ += "    " + @aNodes[i][:id]
			if @aNodes[i][:label] != "" and @aNodes[i][:label] != @aNodes[i][:id]
				_cOutput_ += ' "' + @aNodes[i][:label] + '"'
			ok
			_cOutput_ += char(10)
		next
		_cOutput_ += char(10)
		
		# Edges section
		_cOutput_ += "edges" + char(10)
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			_cOutput_ += "    " + _aEdge_[:from] + " -> " + _aEdge_[:to]
			if _aEdge_[:label] != ""
				_cOutput_ += ' "' + _aEdge_[:label] + '"'
			ok
			_cOutput_ += char(10)
		next
		
		# Properties section
		if This._HasNodeProperties()
			_cOutput_ += char(10) + "properties" + char(10)
			_nLen_ = len(@aNodes)
			for i = 1 to _nLen_
				_aNode_ = @aNodes[i]
				if HasKey(_aNode_, :properties) and len(_aNode_[:properties]) > 0
					_cOutput_ += "    " + _aNode_[:id] + char(10)
					_aProps_ = _aNode_[:properties]
					_acKeys_ = keys(_aProps_)
					_nKeyLen_ = len(_acKeys_)
					for j = 1 to _nKeyLen_
						_cKey_ = _acKeys_[j]
						pVal = _aProps_[_cKey_]
						_cOutput_ += "        " + _cKey_ + ": " + This._FormatValue(pVal) + char(10)
					next
					_cOutput_ += char(10)
				ok
			next
		ok
		
		return _cOutput_
	
		def ToStzGraf()
			return This.ExportToStzGraf()
	
		def AsStzGraf()
			return This.ExportToStzGraf()
	
	# Writes the graph to a .stzgraf file, replacing any file there.
	#
	#   returns    nothing; a file is written
	#   see        ExportToStzGraf, LoadFromStzGraf
	def SaveToStzGraf(pcPath)
		_cContent_ = This.ExportToStzGraf()
		write(pcPath, _cContent_)
	
		# Writes the graph to a .stzgraf file; another spelling of the save.
		#
		#   returns    nothing; a file is written
		#   see        SaveToStzGraf
		def SaveAsStzGraf(pcPath)
			This.SaveToStzGraf(pcPath)
	
	# Replaces the graph's nodes and edges by those of a .stzgraf file; raises an error when the file is missing.
	#
	#   returns    nothing; the graph changes
	#   warning    a node property whose line contains type: overwrites the graph type, so a graph
	#              saved as structural reads back as task when a node has that property; edge
	#              properties are not restored
	#   see        SaveToStzGraf, LoadFrom
	def LoadFromStzGraf(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		_cContent_ = read(pcPath)
		This._ParseStzGraf(_cContent_)
	
		# Replaces the graph by the content of a .stzgraf file; another spelling of the load.
		#
		#   returns    nothing; the graph changes
		#   warning    a node property whose line contains type: overwrites the graph type; edge
		#              properties are not restored
		#   see        LoadFromStzGraf
		def LoadStzGraf(pcPath)
			This.LoadFromStzGraf(pcPath)
	
	def _ParseStzGraf(_cContent_)
		# Clear current graph
		@aNodes = []
		@aEdges = []
		
		_acLines_ = split(_cContent_, char(10))
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
	
	# Returns the graph's rules as .stzrulz text: a rule set header, then each rule with type, severity, function name, parameters and message.
	#
	#   returns    text
	#   see        SaveToStzRulz, LoadFromStzRulz
	def ExportToStzRulz()
		_cOutput_ = 'ruleset "' + @cId + ' Rules"' + char(10)
		_cOutput_ += '    ruleGroup: ' + @cGraphType + char(10)
		_cOutput_ += '    version: 1.0' + char(10) + char(10)
		
		_cOutput_ += "rules" + char(10) + char(10)
		
		_aRules_ = This.Rules()
		_nLen_ = len(_aRules_)
		for i = 1 to _nLen_
			_aRule_ = _aRules_[i]

			_cOutput_ += "    rule " + _aRule_[:name] + char(10)
			_cOutput_ += "        type: " + _aRule_[:type] + char(10)
			_cOutput_ += "        severity: " + _aRule_[:severity] + char(10)
			_cOutput_ += "        function: " + This._GetFunctionName(_aRule_[:function]) + char(10)
			
			if len(_aRule_[:params]) > 0
				_cOutput_ += "        params" + char(10)
				_aParams_ = _aRule_[:params]
				_acKeys_ = keys(_aParams_)
				_nKeyLen_ = len(_acKeys_)
				for j = 1 to _nKeyLen_
					_cKey_ = _acKeys_[j]
					pVal = _aParams_[_cKey_]
					_cOutput_ += "            " + _cKey_ + ": " + This._FormatValue(pVal) + char(10)
				next
			ok
			
			_cOutput_ += "        message" + char(10)
			_cOutput_ += '            "' + _aRule_[:message] + '"' + char(10)
			_cOutput_ += char(10)
		next
		
		return _cOutput_
	
		def ToStzRulz()
			return This.ExportToStzRulz()
	
		def AsStzRulz()
			return This.ExportToStzRulz()
	
	# Writes the graph's rules to a .stzrulz file, replacing any file there.
	#
	#   returns    nothing; a file is written
	#   see        ExportToStzRulz, LoadFromStzRulz
	def SaveToStzRulz(pcPath)
		_cContent_ = This.ExportToStzRulz()
		write(pcPath, _cContent_)
	
		# Writes the graph's rules to a .stzrulz file; another spelling of the save.
		#
		#   returns    nothing; a file is written
		#   see        SaveToStzRulz
		def SaveAsStzRulz(pcPath)
			This.SaveToStzRulz(pcPath)
	
	# Adds the rules declared in a .stzrulz file to the graph; a rule of an unknown type raises an error.
	#
	#   returns    nothing; the graph changes
	#   note       a rule that names a custom function needs LoadRuleFunctionsFrom first
	#   see        SaveToStzRulz, LoadRuleFunctionsFrom
	def LoadFromStzRulz(pcPath)
		if NOT fexists(pcPath)
			stzraise("File not found: " + pcPath)
		ok
		
		_cContent_ = read(pcPath)
		This._ParseStzRulz(_cContent_)
	
		# Adds the rules declared in a .stzrulz file to the graph; another spelling of the load.
		#
		#   returns    nothing; the graph changes
		#   see        LoadFromStzRulz
		def LoadStzRulz(pcPath)
			This.LoadFromStzRulz(pcPath)
	
	def _ParseStzRulz(_cContent_)
		# Loads rule properties and links to functions from .stzrulf files
		_acLines_ = split(_cContent_, char(10))
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
	
	# Loads a .stzrulf file of custom rule functions into the program, once per path; a missing file or a path with a quote raises an error.
	#
	#   returns    nothing; functions are defined
	#   note       put the group registrations above the func definitions in the file
	#   see        LoadFromStzRulz, UseRulesFrom
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

		# Loads a .stzrulf file of custom rule functions; another spelling of the function load.
		#
		#   returns    nothing; functions are defined
		#   see        LoadRuleFunctionsFrom
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
	
	# Returns a .stzsim simulation: the node and edge changes that turn the baseline graph into this one, with a few metrics.
	#
	#   oBaselineGraph   The baseline stzGraph that the changes are measured from.
	#   returns          text
	#   see              ApplySimulation, SaveToStzSim, CompareWith
	def ExportToStzSim(oBaselineGraph)
		_cOutput_ = 'simulation "' + @cId + ' Comparison"' + char(10)
		_cOutput_ += '    description: "Changes from baseline"' + char(10)
		_cOutput_ += '    date: ' + Date() + char(10) + char(10)
		
		# Compare and generate changes
		_aDiff_ = oBaselineGraph.CompareWith(This)
		
		_cOutput_ += "changes" + char(10) + char(10)
		
		# Node changes
		_aNodeDiff_ = _aDiff_[:nodes]
		
		if len(_aNodeDiff_[:added]) > 0
			_nLen_ = len(_aNodeDiff_[:added])
			for i = 1 to _nLen_
				_cNodeId_ = _aNodeDiff_[:added][i]
				_aNode_ = This.Node(_cNodeId_)
				_cOutput_ += "    add node " + _cNodeId_ + char(10)
				_cOutput_ += '        label: "' + _aNode_[:label] + '"' + char(10)
			next
			_cOutput_ += char(10)
		ok
		
		if len(_aNodeDiff_[:removed]) > 0
			_nLen_ = len(_aNodeDiff_[:removed])
			for i = 1 to _nLen_
				_cOutput_ += "    remove node " + _aNodeDiff_[:removed][i] + char(10)
			next
			_cOutput_ += char(10)
		ok
		
		# Edge changes
		_aEdgeDiff_ = _aDiff_[:edges]
		
		if len(_aEdgeDiff_[:added]) > 0
			_nLen_ = len(_aEdgeDiff_[:added])
			for i = 1 to _nLen_
				_aEdge_ = _aEdgeDiff_[:added][i]
				_cOutput_ += "    add edge " + _aEdge_[:from] + " -> " + _aEdge_[:to] + char(10)
			next
			_cOutput_ += char(10)
		ok
		
		if len(_aEdgeDiff_[:removed]) > 0
			_nLen_ = len(_aEdgeDiff_[:removed])
			for i = 1 to _nLen_
				_aEdge_ = _aEdgeDiff_[:removed][i]
				_cOutput_ += "    remove edge " + _aEdge_[:from] + " -> " + _aEdge_[:to] + char(10)
			next
			_cOutput_ += char(10)
		ok
		
		# Metrics section
		_cOutput_ += "metrics" + char(10) + char(10)
		_aMetrics_ = _aDiff_[:metrics]
		
		_cOutput_ += "    density: " + _aMetrics_[:density][:from] + " -> " + _aMetrics_[:density][:to] + char(10)
		_cOutput_ += "    nodeCount: " + _aMetrics_[:nodeCount][:from] + " -> " + _aMetrics_[:nodeCount][:to] + char(10)
		_cOutput_ += "    edgeCount: " + _aMetrics_[:edgeCount][:from] + " -> " + _aMetrics_[:edgeCount][:to] + char(10)
		_cOutput_ += "    hasCycles: " + _aMetrics_[:hasCycles][:from] + " -> " + _aMetrics_[:hasCycles][:to] + char(10)
		
		return _cOutput_
	
		def ToStzSim(oBaselineGraph)
			return This.ExportToStzSim(oBaselineGraph)
	
		def AsStzSim(oBaselineGraph)
			return This.ExportToStzSim(oBaselineGraph)
	
	# Writes the simulation of changes from a baseline graph to a .stzsim file, replacing any file there.
	#
	#   oBaselineGraph   The baseline stzGraph that the changes are measured from.
	#   returns          nothing; a file is written
	#   see              ExportToStzSim, ApplySimulation
	def SaveToStzSim(pcPath, oBaselineGraph)
		_cContent_ = This.ExportToStzSim(oBaselineGraph)
		write(pcPath, _cContent_)
	
		# Writes the simulation of changes from a baseline graph to a .stzsim file; another spelling of the save.
		#
		#   oBaselineGraph   The baseline stzGraph that the changes are measured from.
		#   returns          nothing; a file is written
		#   see              SaveToStzSim
		def SaveAsStzSim(pcPath, oBaselineGraph)
			This.SaveToStzSim(pcPath, oBaselineGraph)
	
	# Applies the changes of a .stzsim text to the graph: add or remove nodes and edges, and set the labels of added nodes.
	#
	#   cSimContent   The text of a .stzsim simulation, as ExportToStzSim writes it.
	#   returns       nothing; the graph changes
	#   note          a node or edge that is already there is left alone, and the metrics section is
	#                 ignored
	#   see           ExportToStzSim, ApplyStzSim
	def ApplySimulation(cSimContent)
		# Parse and apply changes from .stzsim format
		_acLines_ = split(cSimContent, char(10))
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
	
		# Applies the changes of a .stzsim text to the graph; another spelling of the simulation.
		#
		#   cSimContent   The text of a .stzsim simulation, as ExportToStzSim writes it.
		#   returns       nothing; the graph changes
		#   see           ApplySimulation
		def ApplyStzSim(cSimContent)
			This.ApplySimulation(cSimContent)
	
	#--------------------#
	#  HELPER FUNCTIONS  #
	#--------------------#
	
	def _HasNodeProperties()
		_nLen_ = len(@aNodes)

		for i = 1 to _nLen_
			if HasKey(@aNodes[i], :properties) and len(@aNodes[i][:properties]) > 0
				return 1
			ok
		next

		return 0
	
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
			return 1

		but StzLower(_cValue_) = "false"
			return 0
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

	# TRUE if the graph type is flow or semantic, the types in which cycles are acceptable.
	#
	#   returns    TRUE or FALSE
	#   see        ValidateByType, GraphType
	#@ aka  NOTE// I added those methods after including the GraphType attribute So we can use it in a practical way to enforce the beahvir of some features depending on the graph type (see examples at the end of stzGraphTest.ring file)
	def CyclesAllowed()
	    return @cGraphType = "flow" or @cGraphType = "semantic"
	
	# TRUE if the graph type is semantic, the type that derives edges by itself.
	#
	#   returns    TRUE or FALSE
	#   see        EnableAutoDerive, GraphType
	def ShouldAutoDerive()
	    return @cGraphType = "semantic"
	
	# Checks the graph against its type: a structural graph with a cycle is refused.
	#
	#   returns    a pair [ allowed, message ]: [ 1, "" ] when fine
	#   see        CyclesAllowed, HasCyclicDependencies
	def ValidateByType()
	    if @cGraphType = "structural" and This.HasCyclicDependencies()
	        return [0, "Cycles not allowed in structural graphs"]
	    ok
	    return [1, ""]

	# Registers the transitivity rule in the semantic group and loads that group into the graph.
	#
	#   returns    nothing; the graph changes
	#   note       the semantic group's other rules, such as the connectivity validation, come with
	#              it
	#   see        UseRulesFrom, ApplyDerivationRules
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

	# char(10), NOT the NL constant. Ring is case-insensitive, so a CALLER
	# who writes `nL = len(cPixels)` silently overwrites the global NL --
	# and this method then asks StzReplace to find a NUMBER, which raises
	# inside the string layer with nothing pointing back at the caller's
	# variable. A library must not be destroyable by a name its user
	# reasonably chose. Reproduced in eight lines: one graph, one AddNode,
	# one `nL = 1254400` between them.
	# A LABEL IS DISPLAY TEXT. It used to have its SPACES replaced by
	# underscores, which is hygiene for an ID and damage to a label: the
	# documentation's own screenshots read "VP Sales" while the library
	# rendered "VP_Sales". Both tiers were affected, because the dot writer
	# emits labels QUOTED (`label="..."`) and never needed the substitution
	# in the first place.
	#
	# The NEWLINE substitution stays: an unescaped newline inside a quoted
	# dot label breaks the statement it sits in.
	#
	# THE COMMENT ABOVE WAS WRITTEN AND THE LINE WAS NOT REMOVED. For a while
	# this block described the fix while `StzReplace(_cNl_, " ", "_")` sat two
	# lines below it, so the prose said "VP Sales" and the render still said
	# "VP_Sales". It was found by drawing a 40-node diagram and READING it --
	# no guard could have caught it, because test 32's own expected output had
	# been transcribed FROM the buggy render (it feeds "Node 1" and recorded
	# `Node_1`), and the narration path in ExplainPath quietly replaced the
	# underscores back with spaces, hiding the damage exactly where a human
	# would have read it. A bug with a downstream compensation and a
	# self-confirming expectation is invisible to the whole suite.
	#
	# These two were written as alternative FORMS of each other and were not:
	# the US spelling replaced only newlines, the UK spelling only spaces, and
	# since every one of the five call sites uses the US name, the UK one was
	# dead code carrying the other half of the job. A label set through any
	# door kept its spaces.
	#
	# The alias now DELEGATES rather than reimplementing. Two spellings of one
	# rule are two places for it to drift, and this is what that drift looks
	# like when it lands.
	def _NormalizeLabel(pcLabel)
		_cNl_ = StzReplace("" + pcLabel, char(10), "_")
		return StzReplace(_cNl_, char(13), "_")

		def  _NormaliseLabel(pcLabel)
			return This._NormalizeLabel(pcLabel)

	def _IsWellFormedId(pcName)
		if NOT isString(pcName)
			return 0
		ok

		if StzFindFirst(" ", pcName) > 0
			return 0
		ok

		if StzFindFirst(char(10), pcName) > 0
			return 0
		ok

		return 1

# Filters the nodes or the edges of a graph by key, comparison and property, then answers the ids that match.
#
# Built by stzGraph.FindQ and chained: each filter call adds a condition and returns the finder, and
# Run answers the elements that pass every condition, node ids for a node search and [ from, to ]
# pairs for an edge search. A key is looked up on the element first (id, label, from, to) and then
# among its properties, and dots reach nested values. For queries it cannot express, use
# stzGraphQuery.
#
#   receiver   g1 = new stzGraph("g1"); g1.AddNodeXTT("a", "Alpha", [ :priority = 10 ]);
#              g1.AddNodeXTT("b", "Beta", [ :priority = 5 ]); o1 = g1.FindQ("nodes")
#   example    ? @@( o1.Where("priority", ">", 7).Run() )
#              #--> [ "a" ]
#   see        stzGraph, stzGraphQuery
class stzGraphFinder from stzObject
	# Basic Finder of Nodes ane Edges
	# Used by the FindQ() method in stzGraph
	# For advanced queries use stzGraphQuery class

	@oGraph
	@cTarget
	@aFilters = []
	
	# Builds a finder over the nodes or the edges of a graph, with no filter yet; any target other than nodes or edges finds nothing.
	#
	#   _oGraph_    the stzGraph to search
	#   _cTarget_   what to search, "nodes" or "edges", case ignored
	#   returns     nothing; the object is built
	#   note        stzGraph.FindQ builds one for you
	#   see         Run
	def init(_oGraph_, _cTarget_)
		@oGraph = _oGraph_
		@cTarget = StzLower(_cTarget_)
		@aFilters = []
	
	# Adds a filter that keeps the elements whose key meets a comparison with the value, and returns the finder so calls chain.
	#
	#   pcKey        the key to test: id, label, from, to or a property name, with dots for nested
	#                values
	#   pCondition   the comparison: "=", ">", "<", "contains", "between" or the :equals,
	#                :greaterthan, :lessthan, :insection forms
	#   pValue       the value to compare with, or a pair [ low, high ] for between
	#   returns      the finder itself
	#   note         filters accumulate, and an element must pass all of them; an unknown comparison
	#                matches nothing
	#   see          Having, WithProperty, Run
	def Where(pcKey, pCondition, pValue)
		@aFilters + [:where, pcKey, pCondition, pValue]
		return This
	
		def WhereQ(pcKey, pCondition, pValue)
			return This.Where(pcKey, pCondition, pValue)

	# Adds a filter that keeps the elements whose key equals the value, and returns the finder so calls chain.
	#
	#   pcKey      the key to test, such as a property name
	#   pValue     the value it must equal
	#   returns    the finder itself
	#   note       a key that the element does not have fails the filter
	#   see        Where, WithProperty, Run
	def Having(pcKey, pValue)
		@aFilters + [:where, pcKey, :equals, pValue]
		return This
	
		def HavingQ(pcKey, pValue)
			return This.Having(pcKey, pValue)

	# Adds a filter that keeps the elements that carry the given property, and returns the finder so calls chain.
	#
	#   pcKey      the property name that must be present
	#   returns    the finder itself
	#   see        Having, Where, Run
	def WithProperty(pcKey)
		@aFilters + [:hasprop, pcKey]
		return This

		def WithPropertyQ(pcKey)
			return This.WithProperty(pcKey)

	# Adds a filter that keeps the elements whose :tags property lists the tag, and returns the finder so calls chain.
	#
	#   pcTag      The tag to look for among the :tags property.
	#   returns    the finder itself
	#   note       the tags must be a list stored in a property called tags
	#   see        WithProperty, Where, Run
	def WithTag(pcTag)
		@aFilters + [:tag, pcTag]
		return This
	
		def WithTagQ(pcTag)
			return This.WithTag(pcTag)

	# Applies the filters and returns the matches: node ids for a node search, [ from, to ] pairs for an edge search.
	#
	#   returns    a list of ids or of [ from, to ] pairs
	#   note       the filters stay in the finder, so a filter added after one Run narrows the next
	#              Run
	#   see        Where, Having
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
					return 0
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return 0
				ok
				
			but _cType_ = :hasprop
				pcKey = _aFilter_[2]
				if This._GetNestedValue(_aNode_, pcKey) = ""
					return 0
				ok
				
			but _cType_ = :tag
				pcTag = _aFilter_[2]
				if NOT HasKey(_aNode_, "properties") or 
				   NOT HasKey(_aNode_["properties"], "tags") or
				   StzFindFirst(pcTag, _aNode_["properties"]["tags"]) = 0
					return 0
				ok
			ok
		end
		return 1
	
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
					return 0
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return 0
				ok
				
			but _cType_ = :hasprop
				pcKey = _aFilter_[2]
				if This._GetNestedValue(_aEdge_, pcKey) = ""
					return 0
				ok
				
			but _cType_ = :tag
				pcTag = _aFilter_[2]
				if NOT HasKey(_aEdge_, "properties") or 
				   NOT HasKey(_aEdge_["properties"], "tags") or
				   StzFindFirst(pcTag, _aEdge_["properties"]["tags"]) = 0
					return 0
				ok
			ok
		end
		return 1
	
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
		return 0


# Draws a graph in the console as boxed labels joined by arrows, vertically or horizontally, or hands the drawing back as text.
#
# Built by stzGraph.Show and AsciiArt, or on its own over a graph. The vertical drawing starts a
# tree at every node that nothing points to and writes a CYCLE marker where a path comes back; the
# horizontal drawing follows the first out-edge of each node. Nodes whose degree is above the
# average are wrapped in exclamation marks. The Show forms print and the AsciiArt forms return the
# same text. A graph with no node raises error R1.
#
#   receiver   g1 = new stzGraph("g1"); g1.AddNodeXT("a", "Alpha"); g1.AddNodeXT("b", "Beta");
#              g1.Connect("a", "b"); o1 = new stzGraphAsciiVisualizer(g1)
#   example    ? o1.AsciiArtHorizontal() != ""
#              #--> 1
#   see        stzGraph
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
	@bCapture = 0
	@cBuffer = ""

	# Builds a drawing helper bound to a graph; nothing is drawn until one of the show or art calls.
	#
	#   poGraph    The stzGraph to draw.
	#   returns    nothing; the object is built
	#   note       stzGraph.Show builds one for you
	#   see        stzGraph.Show, AsciiArt
	def init(poGraph)
		@oGraph = poGraph

	# Prints, or buffers -- the ONE door every line of the art goes through.
	def _Emit(pcLine)
		if @bCapture
			@cBuffer += pcLine + char(10)
		else
			? pcLine
		ok

	# Returns the vertical drawing as text instead of printing it: boxed labels joined by arrows, one tree per node nothing points to.
	#
	#   returns    text; each line ends with a line break
	#   note       nodes above the average degree wear exclamation marks, and a graph with no node
	#              raises error R1
	#   see        Show, AsciiArtHorizontal
	#@ aka  The art as DATA -- the vertical picture, as a string.
	def AsciiArt()
		return This._Captured(:vertical)

	# Returns the horizontal drawing as text: boxes in a row joined by arrows that carry the edge labels.
	#
	#   returns    text
	#   note       only the first out-edge of each node is followed, and a graph with no node raises
	#              error R1
	#   see        ShowHorizontal, AsciiArt
	#@ aka  ... and the horizontal one.
	def AsciiArtHorizontal()
		return This._Captured(:horizontal)

	def _Captured(pcMode)
		@bCapture = 1
		@cBuffer = ""

		if pcMode = :horizontal
			This.ShowHorizontal()
		else
			This.Show()
		ok

		@bCapture = 0
		return @cBuffer
	
	# Prints the vertical drawing: boxed labels joined by arrows and edge labels, a CYCLE marker where a path comes back.
	#
	#   returns    nothing; text is printed
	#   note       the bottleneck nodes are wrapped in exclamation marks, and a graph with no node
	#              raises error R1
	#   see        AsciiArt, ShowHorizontal
	def Show()
		_acDisplayNodes_ = This._PrepareDisplayNodes()
		This._ShowVerticalWithNodes(_acDisplayNodes_)
	
	# Prints the vertical drawing; the explicit spelling of the default display.
	#
	#   returns    nothing; text is printed
	#   see        Show
	def ShowVertical()
		This.Show()
	
		# Prints the vertical drawing; the short spelling of the vertical display.
		#
		#   returns    nothing; text is printed
		#   see        ShowVertical
		def ShowV()
			This.Show()
	
	# Prints the horizontal drawing: a row of boxes joined by arrows that carry the edge labels.
	#
	#   returns    nothing; text is printed
	#   see        AsciiArtHorizontal, Show
	def ShowHorizontal()
		_acDisplayNodes_ = This._PrepareDisplayNodes()
		This._ShowHorizontalWithNodes(_acDisplayNodes_)
	
		# Prints the horizontal drawing; the short spelling of the horizontal display.
		#
		#   returns    nothing; text is printed
		#   see        ShowHorizontal
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
				if _aEdge_ != "" and isString(_aEdge_["label"])
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

# Compares a baseline graph with several variations and ranks them by what changed: nodes, edges, density, cycles and bottlenecks.
#
# Built by stzGraph.CompareWithManyQR(..., :stzGraphComparison) or directly. It runs the comparison
# once when built and answers from the stored rows: Summary for a text report, MostImpactful and
# LeastImpactful, ByMetric to sort, Recommend for a suggestion, ToStzTable for a table. The cycle
# questions (WithCycles, WithoutCycles) and the acyclic bonus of Recommend do not work today; see
# their warnings.
#
#   receiver   g1 = new stzGraph("g1"); g1.AddNode("a"); g1.AddNode("b"); g1.Connect("a", "b"); o1 =
#              new stzGraphComparison(g1, [ g1 ])
#   example    ? o1.LeastImpactful()
#              #--> V1
#   see        stzGraph, stzTable
class stzGraphComparison from stzObject
	@oBaselineGraph
	@aGraphs = []
	@aComparisonData = []
	# Built from raw UTF-8 bytes -- see @cArrowRight in stzGraph.
	@cBullet = char(226) + char(128) + char(162)   # U+2022

	
	# Compares a baseline graph with each variation at once and keeps the results; variations are named V1, V2 and so on unless given as pairs.
	#
	#   oBaseline   the baseline stzGraph
	#   paoGraphs   the variations: [ g1, g2 ] or named [ [ "name", g1 ], ... ]
	#   returns     nothing; the object is built
	#   note        the comparison runs when the object is built
	#   see         stzGraph.CompareWithManyQR, Data
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
	
	# Returns the comparison as a stzTable with one column per variation and one row per metric, such as NodesAdded and HasCycles.
	#
	#   returns    a stzTable
	#   see        Show, Data
	def ToStzTable()
		_aTableData_ = @oBaselineGraph._ToStzTableData(@aComparisonData)
		return new stzTable(_aTableData_)
	
		def AsStzTable()
			return This.ToStzTable()
	
		def AsTable()
			return This.ToStzTable()
	
	# Prints the comparison table, one column per variation, in the console.
	#
	#   returns    nothing; a table is printed
	#   see        ToStzTable, Display
	def Show()
		_oTable_ = This.ToStzTable()
		_oTable_.Show()
	
		# Prints the comparison table; another spelling of the display call.
		#
		#   returns    nothing; a table is printed
		#   see        Show
		def Display()
			This.Show()
	
	# Returns the whole comparison as a hash list holding the rows, the baseline id and the count of variations.
	#
	#   returns    a hash list [ :comparisons, :baseline, :count ]
	#   see        Comparisons, Summary
	def Data()
		return @aComparisonData
	
		# Returns nothing today instead of the comparison data.
		#
		#   returns    nothing today
		#   warning    known defect: the body is empty, so the call answers empty text; Data returns
		#              the comparison
		#   see        Data
		def Content()

	# Returns one hash list per variation with its name and its counts of nodes and edges added and removed.
	#
	#   returns    a list of hash lists [ :name, :nodesadded, :nodesremoved, :edgesadded,
	#              :edgesremoved, :densitychange, :hascycles, :bottleneckchange, :explanation ]
	#   see        Data, Summary
	def Comparisons()
		return @aComparisonData[:comparisons]
	
	# Returns a text report naming the baseline and the count of variations, with one bulleted line per variation explaining its change.
	#
	#   returns    text, one line per variation
	#   see        Comparisons, Recommend
	def Summary()
		_cResult_ = ""
		_cResult_ += "Baseline: " + @aComparisonData[:baseline] + char(10)
		_cResult_ += "Variations compared: " + @aComparisonData[:count] + char(10) + char(10)
		
		_aComps_ = @aComparisonData[:comparisons]
		_nLen_ = len(_aComps_)
		
		for i = 1 to _nLen_
			_aComp_ = _aComps_[i]
			_cResult_ += @cBullet + " " + _aComp_[:name] + ": " + _aComp_[:explanation] + char(10)
		next
		
		return _cResult_
	
	# Returns the name of the variation with the most node and edge changes, added plus removed; empty when none changed anything.
	#
	#   returns    text; empty when every variation is unchanged
	#   see        LeastImpactful, ByMetric
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
	
	# Returns the name of the variation with the fewest node and edge changes, the first one on a tie.
	#
	#   returns    text
	#   see        MostImpactful, ByMetric
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
	
	# Returns an empty list today instead of the names of the variations that contain a cycle.
	#
	#   returns    [ ] today, even when a variation has a cycle
	#   warning    known defect: the rows hold the text TRUE or FALSE in the cycle field, and the
	#              body tests it against the number 1
	#   see        WithoutCycles, Recommend
	def WithCycles()
		# Returns names of variations that introduce cycles
		_aComps_ = @aComparisonData[:comparisons]
		_acResult_ = []
		
		_nLen_ = len(_aComps_)
		for i = 1 to _nLen_
			if _aComps_[i][:hasCycles] = 1
				_acResult_ + _aComps_[i][:name]
			ok
		next
		
		return _acResult_
	
	# Returns an empty list today instead of the names of the variations that stay acyclic.
	#
	#   returns    [ ] today, even when a variation is acyclic
	#   warning    known defect: the rows hold the text TRUE or FALSE in the cycle field, and the
	#              body tests it against the number 0
	#   see        WithCycles, Recommend
	def WithoutCycles()
		# Returns names of variations that remain acyclic
		_aComps_ = @aComparisonData[:comparisons]
		_acResult_ = []
		
		_nLen_ = len(_aComps_)
		for i = 1 to _nLen_
			if _aComps_[i][:hasCycles] = 0
				_acResult_ + _aComps_[i][:name]
			ok
		next
		
		return _acResult_
	
	# Returns the variation names from the highest to the lowest value of one column, such as :nodesAdded; an unknown column raises an error.
	#
	#   cMetric    The metric to sort by, such as :nodesAdded, :edgesAdded or :hasCycles.
	#   returns    a list of text
	#   note       on a text column such as the density change the order is the text order
	#   see        Comparisons, MostImpactful
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
	
	# Scores each variation and returns the best with a reason; the score rewards fewer bottlenecks, denser links and added nodes over removed.
	#
	#   returns    a hash list [ :recommended, :reason ]
	#   warning    the acyclic bonus of 10 points is never awarded because the cycle field holds
	#              text, so a variation with a cycle can win, and the reason text is the same for
	#              every answer
	#   see        WithoutCycles, MostImpactful
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
			if _aComp_[:hasCycles] = 0
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
