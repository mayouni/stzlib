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
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			cId = aNode[:id]
			
			if @oParentGraph.NodeExists(cId)
				if HasKey(aNode, :properties)
					@oParentGraph.SetNodeProperties(cId, aNode[:properties])
				ok
			else
				cLabel = ""
				if HasKey(aNode, :label)
					cLabel = aNode[:label]
				ok
				
				aProps = []
				if HasKey(aNode, :properties)
					aProps = aNode[:properties]
				ok
				
				@oParentGraph.AddNodeXTT(cId, cLabel, aProps)
			ok
		next
		
		# Sync edges
		nLen = len(@aEdges)
		for i = 1 to nLen
			aEdge = @aEdges[i]
			cFrom = aEdge[:from]
			cTo = aEdge[:to]
			
			if NOT @oParentGraph.EdgeExists(cFrom, cTo)
				cLabel = ""
				if HasKey(aEdge, :label)
					cLabel = aEdge[:label]
				ok
				
				aProps = []
				if HasKey(aEdge, :properties)
					aProps = aEdge[:properties]
				ok
				
				if @oParentGraph.NodeExists(cFrom) and @oParentGraph.NodeExists(cTo)
					@oParentGraph.AddEdgeXTT(cFrom, cTo, cLabel, aProps)
				ok
			ok
		next
	
	def Rollback()
		@aNodes = This._FilteredNodes()
		@aEdges = This._FilteredEdges()
	
	def Changes()
		aChanges = [
			:nodesModified = [],
			:nodesAdded = []
		]
		
		nLen = len(@aNodes)
		for i = 1 to nLen
			aNode = @aNodes[i]
			cId = aNode[:id]
			
			if @oParentGraph.NodeExists(cId)
				aParentNode = @oParentGraph.Node(cId)
				if This._NodesDiffer(aNode, aParentNode)
					aChanges[:nodesModified] + cId
				ok
			else
				aChanges[:nodesAdded] + cId
			ok
		next
		
		return aChanges
	
	def _FilteredNodes()
		aResult = []
		nLen = len(@acIncludedNodes)
		
		for i = 1 to nLen
			cNodeId = @acIncludedNodes[i]
			
			if @oParentGraph.NodeExists(cNodeId)
				aNode = @oParentGraph.Node(cNodeId)
				
				aNodeCopy = [
					:id = aNode[:id],
					:label = aNode[:label],
					:properties = []
				]
				
				if HasKey(aNode, :properties)
					acKeys = keys(aNode[:properties])
					nKeyLen = len(acKeys)
					
					for j = 1 to nKeyLen
						cKey = acKeys[j]
						aNodeCopy[:properties][cKey] = aNode[:properties][cKey]
					next
				ok
				
				aResult + aNodeCopy
			ok
		next
		
		return aResult
	
	def _FilteredEdges()
		aResult = []
		aEdges = @oParentGraph.Edges()
		nLen = len(aEdges)
		
		for i = 1 to nLen
			aEdge = aEdges[i]
			cFrom = aEdge[:from]
			cTo = aEdge[:to]
			
			if ring_find(@acIncludedNodes, cFrom) > 0 and
			   ring_find(@acIncludedNodes, cTo) > 0
				
				aEdgeCopy = [
					:from = cFrom,
					:to = cTo,
					:label = aEdge[:label],
					:properties = []
				]
				
				if HasKey(aEdge, :properties)
					acKeys = keys(aEdge[:properties])
					nKeyLen = len(acKeys)
					
					for j = 1 to nKeyLen
						cKey = acKeys[j]
						aEdgeCopy[:properties][cKey] = aEdge[:properties][cKey]
					next
				ok
				
				aResult + aEdgeCopy
			ok
		next
		
		return aResult
	
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
		
		aProps1 = aNode1[:properties]
		aProps2 = aNode2[:properties]
		
		acKeys1 = keys(aProps1)
		
		if len(acKeys1) != len(keys(aProps2))
			return TRUE
		ok
		
		nLen = len(acKeys1)
		for i = 1 to nLen
			cKey = acKeys1[i]
			
			if NOT HasKey(aProps2, cKey)
				return TRUE
			ok
			
			if aProps1[cKey] != aProps2[cKey]
				return TRUE
			ok
		next
		
		return FALSE
