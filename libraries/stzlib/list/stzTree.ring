# stzTree - Softanza Tree Class
# Extending stzList to provide tree-specific capabilities


/*
NOTE: stzStree is different by design from the Tree class prvided by StdLib of Ring.

Name		Definition
------		-----------
Root		First element of the Tree.

Element		Generic name corresponding to the constitutents of a Tree.
		--> Root, Node or Leaf are elements of a Tree.

Node		Intermediate level, can have higher levels (also called "Parent"
		levels) and lower levels (also called "Child" levels).

		Remark: The root or the leaves correspond to specific nodes.

Branch		Section of the Tree that can define a path:
		from the root to a leaf, from a node to another node,
		from a node to a leaf, from the root to a node.

Leaf		Last element of the tree structure: there is no level below.

myTree() {
	Node1 {
		Node1.1 {
			Leaf1.1.1
		}

	Leaf2

	Node3 {
		Leaf3.1
		Leaf3.2
	}

	Node4 {
		Leaf1.4.1
	}

	Leaf5

	Show()
	Find("Leaf3.1") // ==> Path = [3,1]
}
*/

func StzTreeQ(paTree)
	return new stzTree(paTree)


class stzTree from stzList

	#--- INITIALIZATION ---#
	
	def init(paTree)
		if isList(paTree)
			super.init(paTree)
		else
			super.init([])
		ok

	#--- BASIC TREE STRUCTURE INFORMATION ---#
	
	def Root()
		if This.IsEmpty()
			return NULL
		ok
		
		return This.First()
	
	def IsLeaf(pPath)
		
		oItem = This.ItemAtPath(pPath)
		
		if NOT isList(oItem)
			return TRUE
		ok
		
		return FALSE

	def IsNode(pPath)

		if NOT This.IsValidPath(pPath)
			return FALSE
		ok

		oItem = This.ItemAtPath(pPath)
		
		if isList(oItem)
			return TRUE
		else
			return FALSE
		ok

	def AllLeaves()
		aResult = []
		
		for aPath in This.Paths()
			if This.IsLeaf(aPath)
				aResult + [ This.ItemAtPath(aPath), aPath ]
			ok
		next
		
		return aResult

	def CountLeaves()
		nResult = 0
		
		for aPath in This.Paths()
			if This.IsLeaf(aPath)
				nResult++
			ok
		next
		
		return nResult

	def AllNodes()
		aResult = []
		
		for aPath in This.Paths()
			if This.IsNode(aPath)
				aResult + [ This.ItemAtPath(aPath), aPath ]
			ok
		next
		
		return aResult

	def CountNodes()
		nResult = 0
		
		for aPath in This.Paths()
			if This.IsNode(aPath)
				nResult++
			ok
		next
		
		return nResult

	def Height()
		if This.IsEmpty()
			return 0
		ok
		
		return This.MaxPathDepth()

	def Width()
		if This.IsEmpty()
			return 0
		ok
		
		nMax = 0
		
		for aPath in This.Paths()
			if This.IsLeaf(aPath)
				if len(aPath) = 1
					nMax = max([nMax, aPath[1]])
				ok
			ok
		next
		
		return nMax

	#--- ELEMENT MANIPULATION ---#
	
	def AddLeaf(pItem, pParentPath)
		
		if NOT This.IsNode(pParentPath)
			return FALSE
		ok
		
		oParent = This.ItemAtPath(pParentPath)
		oParent + pItem
//		This.ReplaceItemAtPath(oParent, pParentPath)
		
		return TRUE

	def AddNode(pNode, pParentPath)

		if NOT This.IsNode(pParentPath)
			return FALSE
		ok
		
		if NOT isList(pNode)
			pNode = [pNode]
		ok
		
		oParent = This.ItemAtPath(pParentPath)
		oParent + pNode
		This.ReplaceItemAtPath(oParent, pParentPath)
		
		return TRUE

	def RemoveElement(pPath)
		This.RemoveItemAtPath(pPath)


	def RemoveElementByValue(pValue)
		aPaths = This.DeepFind(pValue)
		
		if len(aPaths) = 0
			return FALSE
		ok
		
		for aPath in aPaths
			This.RemoveItemAtPath(This.ItemAtPath(aPath), aPath)
		next
		
		return TRUE

	def ReplaceElement(pPath, pNewValue)

		This.ReplaceItemAtPath(This.ItemAtPath(pPath), pNewValue, pPath)


	#--- BRANCH OPERATIONS ---#
	
	def Branch(pStartPath, pEndPath)
		aResult = []
		
		# Check if paths exist
/*		if NOT This.ItemExistsAtPath(pStartPath) OR NOT This.ItemExistsAtPath(pEndPath)
			return aResult
		ok
*/		
		# Find common ancestor path
		aCommonPath = @CommonPath([pStartPath, pEndPath])
		
		if len(aCommonPath) = 0
			return aResult
		ok
		
		# Get all paths between start and end
		for aPath in This.Paths()
			if IsSubPathOf(aCommonPath, aPath) AND
			   IsSubPathOf(aPath, pStartPath) OR IsSubPathOf(aPath, pEndPath) OR 
			   aPath = pStartPath OR aPath = pEndPath
				aResult + [This.ItemAtPath(aPath), aPath]
			ok
		next
		
		return aResult

	def CopyBranch(pStartPath, pEndPath, pDestPath)
		aBranch = This.Branch(pStartPath, pEndPath)
		
		if len(aBranch) = 0
			return FALSE
		ok
		
		if NOT This.IsNode(pDestPath)
			return FALSE
		ok
		
		# Create a new subtree from the branch
		aNewTree = []
		
		for aPair in aBranch
			# TODO: Build the new tree structure
			# This is complex and would require recreating the structure 
			# at the new location with proper path adjustments
		next
		
		return TRUE

	#--- TRAVERSAL & VISUALIZATION ---#
	
	def Show()
		return This.DisplayAsTree()
	
	def DisplayAsTree()
		cResult = ""
		
		# Root level items
		for i = 1 to len(This.Content())
			cItem = This.Content()[i]
			
			if isList(cItem)
				cResult += "Node" + i + " {" + nl
				cResult += This.DisplaySubtree(cItem, 1)
				cResult += "}" + nl
			else
				cResult += "Leaf" + i + ": " + cItem + nl
			ok
		next
		
		return cResult

	def DisplaySubtree(pSubtree, nLevel)
		cResult = ""
		cIndent = ring_copy(char(9), nLevel)
		
		for i = 1 to len(pSubtree)
			cItem = pSubtree[i]
			
			if isList(cItem)
				cResult += cIndent + "Node" + i + " {" + nl
				cResult += This.DisplaySubtree(cItem, nLevel + 1)
				cResult += cIndent + "}" + nl
			else
				cResult += cIndent + "Leaf" + i + ": " + cItem + nl
			ok
		next
		
		return cResult

	#--- EXPANSION & COLLAPSE ---#
	
	def ExpandAll()
		# In a real application, this would manage a display state
		# For our implementation, we'll return the full tree structure
		return This.Show()
	
	def Expand(pPath)
		
		if NOT This.IsNode(pPath)
			return ""
		ok
		
		cResult = ""
		oSubtree = This.ItemAtPath(pPath)
		
		cResult = This.DisplaySubtree(oSubtree, 0)
		return cResult

	def CollapseAll()
		# In a real implementation, this would collapse the display
		# Here we just show the first level
		cResult = ""
		
		for i = 1 to len(This.Content())
			cItem = This.Content()[i]
			
			if isList(cItem)
				cResult += "Node" + i + " {...}" + nl
			else
				cResult += "Leaf" + i + ": " + cItem + nl
			ok
		next
		
		return cResult

	def Collapse(pPath)
		
		if NOT This.IsNode(pPath)
			return ""
		ok
		
		return "Node at " + @@(pPath) + " {...}"

	#--- ADVANCED SEARCH ---#
	
	def FindLeaves(pValue)
		aResult = []
		
		for aPath in This.Paths()
			if This.IsLeaf(aPath) AND This.ItemAtPath(aPath) = pValue
				aResult + aPath
			ok
		next
		
		return aResult

	def FindNodes(pValue)
		aResult = []
		
		for aPath in This.Paths()
			if This.IsNode(aPath) AND This.ItemAtPath(aPath) = pValue
				aResult + aPath
			ok
		next
		
		return aResult

	def FindInPath(pValue, pPath)
		
		# Expand the path to get all subpaths
		aExpandedPaths = This.ExpandPath(pPath)
		aResult = []
		
		for aSubPath in aExpandedPaths
			if This.ItemAtPath(aSubPath) = pValue
				aResult + aSubPath
			ok
		next
		
		return aResult

	#--- SORTING ---#
	
	def SortNodeChildren(pPath)
		
		if NOT This.IsNode(pPath)
			return FALSE
		ok
		
		# Get children paths
		aChildren = []
		
		for aChildPath in This.ExpandPath(pPath)
			if len(aChildPath) = len(pPath) + 1
				aChildren + aChildPath
			ok
		next
		
		# Sort children based on their string values
		aItems = []
		
		for aChildPath in aChildren
			aItems + This.ItemAtPath(aChildPath)
		next
		
		# Create a helper list for sorting
		aSortHelper = []
		
		for i = 1 to len(aItems)
			aSortHelper + [aItems[i], aChildren[i]]
		next
		
		# Sort the helper list

		aSorted = @SortOn(aSortHelper, 1)
		# Rebuild the sorted children
		oNode = []
		
		for aPair in aSorted
			if This.IsValidPath(aPair[2])
				oNode + This.ItemAtPath(aPair[2])
			ok
		next
		
		# Replace the node with sorted children
//		This.ReplaceItemAtPath(oNode, pPath)
		

	def SortSubtree(pPath)
	
		if NOT This.IsNode(pPath)
			return FALSE
		ok
		
		# First sort all subnodes recursively
		aExpandedPaths = This.ExpandPath(pPath)
		
		for aSubPath in aExpandedPaths
			if This.IsNode(aSubPath)
				This.SortNodeChildren(aSubPath)
			ok
		next
		
		# Finally sort the top node
		This.SortNodeChildren(pPath)
