load "../max/stzmax.ring"


/*--- Example 1: Creating and Exploring a Tree

pr()

o1 = new stzTree([
	"Root",
	[
		"Node1.1",
		[
			"Leaf1.1.1"
		]
	],
	"Node2",
	[
		"Leaf2.1",
		"Leaf2.2",
		"Leaf2.3"
	],
	[
		"Leaf3.1",
		"Leaf3.2"
	],
	"Leaf4"
])
	
# Display the tree

? o1.Show()
#--> Executed in 0.02 second(s) in Ring 1.22

pf()

/*---
*/
pr()

? IsTree(
	:root = [

		:documents = [
			"Resume.docx",
			"Cover_Letter.docx"
		],

		:projects = [
			"ProjectA.txt",
			"ProjectB.txt",
			"ProjectC.txt"
		],

		"unclassified.doc",

		:pictures = [

			:personal = [
				"vacation.jpg",
				"family.jpg"
			],

			:professional = [
				"team.jpg",
				"snapshot.jpg"
			],

			"other.jpg"
		],

		"readme.txt",
		[ 1, 2, 3 ]
	]
)

pf()

/*---

pr()

o1 = new stzTree(
	:root = [

		:documents = [
			"Resume.docx",
			"Cover_Letter.docx"
		],

		:projects = [
			"ProjectA.txt",
			"ProjectB.txt",
			"ProjectC.txt"
		],

		:pictures = [

			:personal = [
				"vacation.jpg",
				"family.jpg"
			],

			:professional = [
				"team.jpg",
				"snapshot.jpg"
			],

			"other.jpg"
		],

		"readme.txt",
		[ 1, 2, 3 ]
	]
)

? @@( o1.FindLeaves() ) + NL

? @@( o1.FindNodes() )

pf()

/*---

pr()

o1 = new stzTree([
	"Root",
	[
		"Node1.1",
		[
			"Leaf1.1.1"
		]
	],
	"Node2",
	[
		"Leaf2.1",
		"Leaf2.2",
		"Leaf2.3"
	],
	[
		"Leaf3.1",
		"Leaf3.2"
	],
	"Leaf4"
])


# Basic information

? o1.Hight() # Or Depth in nested list semantics
#--> 3

? o1.Width() # Or LenOfLongestPath() in list semantics
#--> 3

? o1.CountLeaves()
#--> 10

? o1.CountNodes()
#--> 4
	
pf()
# Executed in 1.96 second(s) in Ring 1.22

/*---

pr()

o1 = new stzTree([
	"Root",
	[
		"Node1.1",
		[
			"Leaf1.1.1"
		]
	],
	"Node2",
	[
		"Leaf2.1",
		"Leaf2.2",
		"Leaf2.3"
	],
	[
		"Leaf3.1",
		"Leaf3.2"
	],
	"Leaf4"
])
	
	
# Check element types

? o1.IsLeaf([1])
? o1.IsNode([2])
? o1.IsLeaf([3])
? o1.IsNode([4])

pf()
# Executed in 0.34 second(s) in Ring 1.22

/*---

pr()

o1 = new stzTree([
	"Root",
	[
		"Node1.1",
		[
			"Leaf1.1.1"
		]
	],
	"Node2",
	[
		"Leaf2.1",
		"Leaf2.2",
		"Leaf2.3"
	],
	[
		"Leaf3.1",
		"Leaf3.2"
	],
	"Leaf4"
])
	
# Get all leaves

? @@NL( o1.Leaves() )
#--> [
#	"Root",
#	"Node1.1",
#	"Leaf1.1.1",
#	"Node2",
#	"Leaf2.1",
#	"Leaf2.2",
#	"Leaf2.3",
#	"Leaf3.1",
#	"Leaf3.2",
#	"Leaf4"
# ]

pf()
# Executed in 0.95 second(s) in Ring 1.22

/*---

pr()

o1 = new stzTree([
	"Root",
	[
		"Node1.1",
		[
			"Leaf1.1.1"
		]
	],
	"Node2",
	[
		"Leaf2.1",
		"Leaf2.2",
		"Leaf2.3"
	],
	[
		"Leaf3.1",
		"Leaf3.2"
	],
	"Leaf4"
])
	
# Get all nodes

? @@NL( o1.Nodes() )
#--> [
#	[
#		"Node1.1",
#		[ "Leaf1.1.1" ]
#	],
#	[ "Leaf1.1.1" ],
#	[ "Leaf2.1", "Leaf2.2", "Leaf2.3" ],
#	[ "Leaf3.1", "Leaf3.2" ]
# ]

pf()

/*=============

func Example2()
	? "=== Example 2: Manipulating Tree Elements ==="
	
	# Create a tree
	oTree = new stzTree([
		"Root",
		[
			"Documents",
			"Resume.docx",
			"Cover_Letter.docx",
			[
				"Projects",
				"ProjectA.txt",
				"ProjectB.txt"
			]
		],
		[
			"Pictures",
			"Vacation.jpg",
			"Family.jpg"
		]
	])
	
	? "Original Tree:"
	? oTree.Show()
	
	# Add a leaf
	? "Adding a leaf 'ProfilePic.jpg' to 'Pictures'..."
	oTree.AddLeaf("ProfilePic.jpg", [3])
	
	# Add a node
	? "Adding a node 'Videos' with content..."
	oTree.AddNode(["Videos", "Birthday.mp4"], [])
	
	? "After additions:"
	? oTree.Show()
	
	# Replace an element
	? "Replacing 'Resume.docx' with 'Resume_2023.docx'..."
	aPath = oTree.DeepFind("Resume.docx")[1]
//	oTree.ReplaceElement(aPath, "Resume_2023.docx")
	
	# Remove an element
	? "Removing 'Cover_Letter.docx'..."
	oTree.RemoveElementByValue("Cover_Letter.docx")
	
	? "Final Tree after modifications:"
	? oTree.Show()

func Example3()
	? "=== Example 3: Working with Branches ==="
	
	# Create a tree
	oTree = new stzTree([
		"FileSystem",
		[
			"Users",
			[
				"Alice",
				"Documents",
				"Pictures",
				"Music"
			],
			[
				"Bob",
				"Videos",
				"Downloads"
			]
		],
		[
			"System",
			"Logs",
			"Config"
		]
	])
	
	? "Tree Structure:"
	? oTree.Show()
	
	# Get a branch from Users/Alice to Users/Bob
	? "Branch from Alice to Bob:"
	aBranch = oTree.Branch([2, 1], [2, 2])
	
	for item in aBranch
		? "- Element at path " + @@(item[2])
	next
	
	# Expanding a specific path
	? "Expanding Users node [2]:"
	? oTree.Expand([2])
	
	# Collapsing the tree
	? "Collapsed Tree:"
	? oTree.CollapseAll()

func Example4()
	? "=== Example 4: Advanced Search and Navigation ==="
	
	# Create a tree with repeated values
	oTree = new stzTree([
		"Root",
		[
			"Folder1",
			"Document.txt",
			"Image.jpg",
			[
				"SubFolder1",
				"Document.txt",
				"Script.py"
			]
		],
		[
			"Folder2",
			"Document.txt",
			[
				"SubFolder2",
				"Config.json"
			]
		]
	])
	
	? "Tree Structure:"
	? oTree.Show()
	
	# Find all occurrences of "Document.txt"
	? "Finding all 'Document.txt' files:"
	aPaths = oTree.DeepFind("Document.txt")
	
	for aPath in aPaths
		? "- Found at path: " + @@(aPath)
	next
	
	# Find items in a specific path
	? "Finding 'Document.txt' within Folder1:"
	aPaths = oTree.FindInPath("Document.txt", [2])
	
	for aPath in aPaths
		? "- Found at path: " + @@(aPath)
	next
	
	# Find all leaves with a specific value
	? "All leaves named 'Document.txt':"
	aPaths = oTree.FindLeaves("Document.txt")
	
	for aPath in aPaths
		? "- Found at path: " + @@(aPath)
	next

func Example5()
	? "=== Example 5: Sorting Tree Elements ==="
	
	# Create a tree with unsorted elements
	oTree = new stzTree([
		"Library",
		[
			"Fiction",
			"Z-Author",
			"C-Author",
			"A-Author",
			[
				"SciFi",
				"Star Wars",
				"Dune",
				"Foundation"
			]
		],
		[
			"Non-Fiction",
			"History",
			"Biography",
			"Science"
		]
	])
	
	? "Original Unsorted Tree:"
	? oTree.Show()
	
	# Sort children of the Fiction node
	? "Sorting Fiction node children..."
	oTree.SortNodeChildren([2])
	
	? "After sorting Fiction node:"
	? oTree.Show()
	
	# Sort the entire SciFi subtree
	? "Sorting SciFi subtree..."
	oTree.SortSubtree([2, 4])
	
	? "After sorting SciFi subtree:"
	? oTree.Show()
	
	# Sort the entire tree
	? "Sorting entire tree..."
	oTree.SortSubtree([])
	
	? "Final sorted tree:"
	? oTree.Show()
