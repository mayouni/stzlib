# stzGraphView - Filtered View of Parent Graph
# Part of the Graph Module of Softanza library for Ring
#--------------------------------------------------------

# Inherits from stzGraph with additional capabilities:
# 
# - Filtered view - Shows only specified nodes from parent
# - Commit/Rollback - Changes can be applied or discarded
# - Change tracking - See what would be committed
# - Auto-commit mode - Optional immediate sync to parent

func StzGraphViewQ(oParent, acNodes)
	return new stzGraphView(oParent, acNodes)

# Holds an editable cut of a parent graph, with the nodes you chose, that you can commit back to the parent or throw away.
#
# A view is a stzGraph made from the chosen nodes of a parent and every edge between them, so
# everything stzGraph answers it answers about the cut. Edits stay in the view until Commit writes
# them into the parent; Rollback drops them. Changes says what a commit would do before it is done.
# The view is a snapshot: later changes of the parent do not reach it.
#
#   receiver   oP = new stzGraph("main") oP.AddNodeXT("a", "Alpha") oP.AddNodeXT("b", "Beta")
#              oP.AddNodeXT("c", "Gamma") oP.AddEdgeXT("a", "b", "ab") oP.AddEdgeXT("b", "c", "bc")
#              o1 = new stzGraphView(oP, [ "a", "b" ])
#   example    ? @@( o1.NodesIds() )
#              #--> [ "a", "b" ]
#              ? o1.IsView()
#              #--> 1
#              o1.AddNodeXT("z", "Zed")
#              ? @@( o1.Changes()[:nodesadded] )
#              #--> [ "z" ]
#              ? oP.NodeExists("z")
#              #--> 0
#              o1.Commit()
#              ? oP.NodeExists("z")
#              #--> 1
#   see        stzGraph, stzWorldGraph
class stzGraphView from stzGraph
	@oParentGraph
	@acIncludedNodes
	@bAutoCommit = 0
	
	# Builds a working copy of the chosen nodes of a graph, with the edges that run between them.
	#
	#   oParent    the stzGraph the view is cut from
	#   acNodes    the ids of the nodes to include, a list of text
	#   returns    nothing; the object is built
	#   note       the view is a snapshot: nodes added to the parent later do not appear in it; an
	#              id the parent does not hold is skipped
	#   warning    a first argument that is not a stzGraph raises error First parameter must be
	#              stzGraph!
	#   see        Commit, Rollback
	def init(oParent, acNodes)
		if NOT @IsStzGraph(oParent)
			stzraise("First parameter must be stzGraph!")
		ok
		
		@oParentGraph = ref(oParent)
		@acIncludedNodes = acNodes
		
		@cId = "view_" + UUID()
		@cGraphType = @oParentGraph.GraphType()
		
		@aNodes = This._FilteredNodes()
		@aEdges = This._FilteredEdges()
		
		@aConstraintRules = @oParentGraph.@aConstraintRules
		@aDerivationRules = @oParentGraph.@aDerivationRules
		@aValidationRules = @oParentGraph.@aValidationRules
		
		@bEnforceConstraints = @oParentGraph.@bEnforceConstraints
		@bAutoDerive = @oParentGraph.@bAutoDerive
	
	# TRUE if the graph is a view cut from a parent graph.
	#
	#   returns    TRUE, as 1; a stzGraph answers 0
	#   see        ParentGraph
	def IsView()
		return 1
	
	# The graph this view is cut from -- an OBJECT, hence Q.
	def ParentGraphQ()
		return @oParentGraph

	# Returns the name of the graph this view is cut from.
	#
	#   returns    the parent's name as text
	#   note       ParentGraphQ returns the parent graph object itself
	#   see        Commit, Changes
	#@ aka  ... and its NAME.
	def ParentGraph()
		return @oParentGraph.Name()
	
	# Writes the view's edits into the parent graph: node properties, new nodes and new edges.
	#
	#   returns    nothing; the parent changes
	#   note       a node or edge removed in the view is not removed in the parent; an edge is only
	#              added when both ends exist in the parent
	#   see        Rollback, Changes
	def Commit()
		# Update node properties
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cId_ = _aNode_[:id]
			
			if @oParentGraph.NodeExists(_cId_)
				if HasKey(_aNode_, :properties)
					@oParentGraph.SetNodeProperties(_cId_, _aNode_[:properties])
				ok
			else
				_cLabel_ = ""
				if HasKey(_aNode_, :label)
					_cLabel_ = _aNode_[:label]
				ok
				
				_aProps_ = []
				if HasKey(_aNode_, :properties)
					_aProps_ = _aNode_[:properties]
				ok
				
				@oParentGraph.AddNodeXTT(_cId_, _cLabel_, _aProps_)
			ok
		next
		
		# Sync edges
		_nLen_ = len(@aEdges)
		for i = 1 to _nLen_
			_aEdge_ = @aEdges[i]
			_cFrom_ = _aEdge_[:from]
			_cTo_ = _aEdge_[:to]
			
			if NOT @oParentGraph.EdgeExists(_cFrom_, _cTo_)
				_cLabel_ = ""
				if HasKey(_aEdge_, :label)
					_cLabel_ = _aEdge_[:label]
				ok
				
				_aProps_ = []
				if HasKey(_aEdge_, :properties)
					_aProps_ = _aEdge_[:properties]
				ok
				
				if @oParentGraph.NodeExists(_cFrom_) and @oParentGraph.NodeExists(_cTo_)
					@oParentGraph.AddEdgeXTT(_cFrom_, _cTo_, _cLabel_, _aProps_)
				ok
			ok
		next
	
	# Discards every edit made in the view and re-reads the nodes and edges from the parent.
	#
	#   returns    nothing; the view is rebuilt from the parent
	#   note       nodes added to the parent since the view was cut appear only if their id was in
	#              the list given to init
	#   see        Commit, Changes
	def Rollback()
		@aNodes = This._FilteredNodes()
		@aEdges = This._FilteredEdges()
	
	# Returns what a commit would do: the nodes whose properties or label differ from the parent and the nodes the parent lacks.
	#
	#   returns    a hash list with the keys nodesmodified and nodesadded, each a list of node ids
	#   note       edges are not reported; the keys are in lower case
	#   see        Commit, Rollback
	def Changes()
		_aChanges_ = [
			:nodesModified = [],
			:nodesAdded = []
		]
		
		_nLen_ = len(@aNodes)
		for i = 1 to _nLen_
			_aNode_ = @aNodes[i]
			_cId_ = _aNode_[:id]
			
			if @oParentGraph.NodeExists(_cId_)
				_aParentNode_ = @oParentGraph.Node(_cId_)
				if This._NodesDiffer(_aNode_, _aParentNode_)
					_aChanges_[:nodesModified] + _cId_
				ok
			else
				_aChanges_[:nodesAdded] + _cId_
			ok
		next
		
		return _aChanges_
	
	def _FilteredNodes()
		_aResult_ = []
		_nLen_ = len(@acIncludedNodes)
		
		for i = 1 to _nLen_
			_cNodeId_ = @acIncludedNodes[i]
			
			if @oParentGraph.NodeExists(_cNodeId_)
				_aNode_ = @oParentGraph.Node(_cNodeId_)
				
				_aNodeCopy_ = [
					:id = _aNode_[:id],
					:label = _aNode_[:label],
					:properties = []
				]
				
				if HasKey(_aNode_, :properties)
					_acKeys_ = keys(_aNode_[:properties])
					_nKeyLen_ = len(_acKeys_)
					
					for j = 1 to _nKeyLen_
						_cKey_ = _acKeys_[j]
						_aNodeCopy_[:properties][_cKey_] = _aNode_[:properties][_cKey_]
					next
				ok
				
				_aResult_ + _aNodeCopy_
			ok
		next
		
		return _aResult_
	
	def _FilteredEdges()
		_aResult_ = []
		_aEdges_ = @oParentGraph.Edges()
		_nLen_ = len(_aEdges_)
		
		for i = 1 to _nLen_
			_aEdge_ = _aEdges_[i]
			_cFrom_ = _aEdge_[:from]
			_cTo_ = _aEdge_[:to]
			
			if StzFindFirst(_cFrom_, @acIncludedNodes) > 0 and
			   StzFindFirst(_cTo_, @acIncludedNodes) > 0
				
				_aEdgeCopy_ = [
					:from = _cFrom_,
					:to = _cTo_,
					:label = _aEdge_[:label],
					:properties = []
				]
				
				if HasKey(_aEdge_, :properties)
					_acKeys_ = keys(_aEdge_[:properties])
					_nKeyLen_ = len(_acKeys_)
					
					for j = 1 to _nKeyLen_
						_cKey_ = _acKeys_[j]
						_aEdgeCopy_[:properties][_cKey_] = _aEdge_[:properties][_cKey_]
					next
				ok
				
				_aResult_ + _aEdgeCopy_
			ok
		next
		
		return _aResult_
	
	def _NodesDiffer(aNode1, aNode2)
		if aNode1[:label] != aNode2[:label]
			return 1
		ok
		
		if NOT HasKey(aNode1, :properties) and NOT HasKey(aNode2, :properties)
			return 0
		ok
		
		if HasKey(aNode1, :properties) != HasKey(aNode2, :properties)
			return 1
		ok
		
		_aProps1_ = aNode1[:properties]
		_aProps2_ = aNode2[:properties]
		
		_acKeys1_ = keys(_aProps1_)
		
		if len(_acKeys1_) != len(keys(_aProps2_))
			return 1
		ok
		
		_nLen_ = len(_acKeys1_)
		for i = 1 to _nLen_
			_cKey_ = _acKeys1_[i]
			
			if NOT HasKey(_aProps2_, _cKey_)
				return 1
			ok
			
			if _aProps1_[_cKey_] != _aProps2_[_cKey_]
				return 1
			ok
		next
		
		return 0
