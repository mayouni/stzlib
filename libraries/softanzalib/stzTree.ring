load "stdlib.ring"

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

myTree {
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
	@aContent = []

	def Init(paTree)
		if NOT ( isList(paTree) and StzListQ(paTree).IsStzTree() )
			stzRaise([
				:Where	= "stzTree > Init(paTree)",
				:What	= "Can't create the stzTree object!",
				:Why	= "The value you provided (paTree) is not a well format list.",
				:Todo	= "Look to the examples in stzTreeTest.ring file and adjust your input accordingly."
			])
		ok

		@aContent = paTree

	def Content()
		return @aContent

	def Copy()
		return new stzTree( This.Content() )

	def Root()
		return aTree[1]

	def SetRoot(pcValue)
		if NOT isList(pcValue)
			aTree[1] = pcValue
			return TRUE
		else
			stzRaise("Can't set the root of the tree with a value of type LIST.")
		ok

	def Add(paPath,pValue)	// Add([0,2,1],"X")
		// TODO

	def Modify(paPath,pValue)
		// TODO
	
	def InsertBefore(paPath,pValue)
		// TODO

	def InsertAfter(paPath,pValue)
		// TODO

	def isNode(paPath)
		// TODO

	def GetNode(paPath)
		// TODO

	def GetTheNodeNumber(n)
		// TODO

	def GetNodes()
		// TODO

	def getElement(paPath)
		// TODO

	def getTheElementNumber(n)
		// TODO

	def GetElements()
		// TODO

	def isLeaf(paPath)
		// TODO

	def GetLeaf(paPath)
		// TODO

	def SetLeaf(paPath,pValue)
		// TODO

	def GetTheLeafNumber(n)
		// TODO

	def SetTheLeafNumber(n,pValue)
		// TODO

	def GetBranch(paPath)
		// TODO

	def GetNthBranch(n)
		// TODO
	
	def Clear()	// Removes all the elements of the tree
			// => The tree remains empty

		// TODO

	def RemoveElementByName(pcName)
		// TODO

	def RemoveElementByPath(paPath)
		// TODO

	def RemoveTheElementNumber(n)
		// TODO

	def RemoveNodeByName(pcName)
		// TODO

	def RemoveNodeByPayth(paPath)	// If paPath points to a Leaf
					// => does nothing

		// TODO

	def RemoveNodeByNumber(n)	// Idem
		// TODO
	
	def RemoveLeafByPath(paPath)
		// TODO

	def RemoveLeafByValue(pValue)	// Search for the value in Leafs,
					// and if found, Removes the leaf
		// TODO

	def RemoveLeafByNumber(n)
		// TODO

	def FindAll(pValue)
		// TODO

	def FindLeaf(pValue)	// Same as Find(pValue)
		// TODO

	def FindNode(pcNode)
		// TODO

	def FindElement(pValue)	// Returns False if it does not exists
				// And True otherwise. In this case,
				// it says also if it is a Leaf or Node,
				// and gives its Path.

		// TODO

	def show()
		? @@( This.Content() )
