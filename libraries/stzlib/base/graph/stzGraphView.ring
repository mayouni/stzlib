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

class stzGraphView from stzGraph
	@oParentGraph
	@acIncludedNodes
	@bAutoCommit = FALSE
	
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
	
	def IsView()
		return TRUE
	
	def ParentGraph()
		return @oParentGraph
	
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
	
	def Rollback()
		@aNodes = This._FilteredNodes()
		@aEdges = This._FilteredEdges()
	
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
			
			if StzFindFirst(@acIncludedNodes, _cFrom_) > 0 and
			   StzFindFirst(@acIncludedNodes, _cTo_) > 0
				
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
			return TRUE
		ok
		
		if NOT HasKey(aNode1, :properties) and NOT HasKey(aNode2, :properties)
			return FALSE
		ok
		
		if HasKey(aNode1, :properties) != HasKey(aNode2, :properties)
			return TRUE
		ok
		
		_aProps1_ = aNode1[:properties]
		_aProps2_ = aNode2[:properties]
		
		_acKeys1_ = keys(_aProps1_)
		
		if len(_acKeys1_) != len(keys(_aProps2_))
			return TRUE
		ok
		
		_nLen_ = len(_acKeys1_)
		for i = 1 to _nLen_
			_cKey_ = _acKeys1_[i]
			
			if NOT HasKey(_aProps2_, _cKey_)
				return TRUE
			ok
			
			if _aProps1_[_cKey_] != _aProps2_[_cKey_]
				return TRUE
			ok
		next
		
		return FALSE
