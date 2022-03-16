load "stdlib.ring"
/*
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

/*
cTree = "
	Skills
		Writing
		Programming
	Places
		Africa
			Tunisia
			Algeria
			Morroco
		Europe
			France
			Italy
			Spain
	Misc
		Name
		Job
		Age
"

myTree =
[ 
	:Root = "Mansour",
		:Skills = [
			"Wrinting",
			"Programming"
		],
	
		:Places = [
			:Africa = [
				"Tunisia",
				"Algeria",
				"Marocoo"
			],
	
			:Europe = [
				"France",
				"Spain",
				"Italy"
			]
		],
	
		:Misc = [
			"Name",
			"Job",
			"Age"
		]
	
]

? myTree[:Places][:Africa][1]
? find(myTree, "Programming")

oTree = new stzTree {
	AddNode("Skills") {
		AddLeaf("Programming")
		AddLeaf("Writing")
	}

	AddNode("Places") {
		AddNode("Africa") {
			AddLeaf("Tunisia")
			AddLeaf("Algeria")
			AddLeaf("Marrocco")
		}

		AddNode("Europe") {
			AddLeaf("France")
			AddLeaf("Spain")
			AddLeaf("Italy")
		}
	}

	
}



oTree = new stzTree(myTree)
oTree.Show()
*/

class stzTree from stzObject
	aTree = []

	def Init(paTree)
		if len(paTree) = 0
			stzRaise("Can't initialise the tree. The list you provided is empty!")
		ok

		if isList( paTree[1] )
			stzRaise("Can't initialise the tree. The root must not be a list.")
		ok

		aTree = paTree

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
	def Modify(paPath,pValue)
	
	def InsertBefore(paPath,pValue)
	def InsertAfter(paPath,pValue)


	def isNode(paPath)

	def GetNode(paPath)

	def GetTheNodeNumber(n)

	def GetNodes()

	def getElement(paPath)

	def getTheElementNumber(n)

	def GetElements()

	def isLeaf(paPath)
	def GetLeaf(paPath)
	def SetLeaf(paPath,pValue)
	def GetTheLeafNumber(n)
	def SetTheLeafNumber(n,pValue)

	def GetBranch(paPath)
	def GetTheBranchNumber(n)
	
	def Clear()	// Removes all the elements of the tree
			// => The tree remains empty

	def RemoveElementByName(pcName)
	def RemoveElementByPath(paPath)
	def RemoveTheElementNumber(n)

	def RemoveNodeByName(pcName)
	def RemoveNodeByPayth(paPath)	// If paPath points to a Leaf
					// => Return FALSE
	def RemoveNodeByNumber(n)	// Idem
	
	def RemoveLeafByPath(paPath)
	def RemoveLeafByValue(pValue)	// Search for the value in Leafs,
				// and if found, Removes the leaf
	def RemoveLeafByNumber(n)

	def FindAll(pValue)
	def FindLeaf(pValue)	// Same as Find(pValue)
	def FindNode(pcNode)
	def FindElement(pValue)	// Returns False if it does not exists
				// And True otherwise. In this case,
				// it says also if it is a Leaf or Node,
				// and gives its Path.
	def show()
		? aTree
