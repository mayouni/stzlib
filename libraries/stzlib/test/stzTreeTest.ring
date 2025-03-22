load "../max/stzmax.ring"

/*---

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
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

o1 = new stzTree(
	:root = [

		:documents = [
			"resume.docx",
			"cover_letter.docx"
		],

		:projects = [
			"ProjA.txt",
			"ProjB.txt",
			"ProjC.txt"
		],

		"tempo.doc",

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

? o1.Show()
#--> [
#	"root",
#	[
#		[
#			"documents",
#			[ "resume.docx", "cover_letter.docx" ]
#		],
#		[
#			"projects",
#			[ "ProjA.txt", "ProjB.txt", "ProjC.txt" ]
#		],
#		"tempo.doc",
#		[
#			"pictures",
#			[
#				[
#					"personal",
#					[ "vacation.jpg", "family.jpg" ]
#				],
#				[
#					"professional",
#					[ "team.jpg", "snapshot.jpg" ]
#				],
#				"other.jpg"
#			]
#		],
#		"readme.txt",
#		[ 1, 2, 3 ]
#	]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*=== BRANCHES

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

? @@( o1.Branch('[:root][:projects]') ) + NL
#--> [ "ProjectA.txt", "ProjectB.txt", "ProjectC.txt" ]

? o1.Branches()
#--> [
#	'[:root]',
#	'[:root][:documents]',
#	'[:root][:projects]',
#	'[:root][:pictures]',
#	'[:root][:pictures][:personal]',
#	'[:root][:pictures][:professional]'
# ]

? @@( o1.Branch('[:root][:pictures][:professional]') )
#--> [ "team.jpg", "snapshot.jpg" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*=== NODES

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

? o1.Nodes()
#--> [
#	'root',		
#	'documents',
#	'projects',
#	'pictures',
#	'personal',
#	'professional'
# ]

? @@NL( o1.NodesXT() ) + NL # Or NodesAndTheirBranches()
#--> [
#	[ 'root', 	  '[:root]' ],
#	[ 'documents',	  '[:root][:documents]' ],
#	[ 'projects',	  '[:root][:projects]' ],
#	[ 'pictures',	  '[:root][:pictures]' ],
#	[ 'personal',	  '[:root][:pictures][:personal]' ],
#	[ 'professional', '[:root][:pictures][:professional]' ]
# ]

? o1.FindNode(:professional) + NL # returns the branch leading to that node
#--> '[:root][:pictures][:professional]'

? @@( o1.Node(:professional) ) + NL
#--> [ "team.jpg", "snapshot.jpg" ]

? o1.FindNodes([ :documents, :professional ])
#--> [
#	"[:root][:documents]",
#	"[:root][:pictures][:professional]"
# ]

? @@NL( o1.Node(:Picture) )
#--> NULL

? @@NL( o1.Node(:Pictures) )
#--> [
#	[
#		"personal",
#		[ "vacation.jpg", "family.jpg" ]
#	],
#	[
#		"professional",
#		[ "team.jpg", "snapshot.jpg" ]
#	],
#	"other.jpg"
# ]

pf()
# Executed in 0.05 second(s) in Ring 1.22

/* === LEAFS

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

? @@NL( o1.Leafs() )
#--> [
#	"Resume.docx",
#	"Cover_Letter.docx",
#	"ProjectA.txt",
#	"ProjectB.txt",
#	"ProjectC.txt",
#	"unclassified.doc",
#	"vacation.jpg",
#	"family.jpg",
#	"team.jpg",
#	"snapshot.jpg",
#	"other.jpg",
#	"readme.txt",
#	[ 1, 2, 3 ]
# ]

? @@NL( o1.LeafsXT() ) + NL
#--> [
#	[ "Resume.docx", [ "[:root][:documents]" ] ],
#	[ "Cover_Letter.docx", [ "[:root][:documents]" ] ],
#	[ "ProjectA.txt", [ "[:root][:projects]" ] ],
#	[ "ProjectB.txt", [ "[:root][:projects]" ] ],
#	[ "ProjectC.txt", [ "[:root][:projects]" ] ],
#	[ "unclassified.doc", [ "[:root]" ] ],
#	[ "vacation.jpg", [ "[:root][:pictures][:personal]" ] ],
#	[ "family.jpg", [ "[:root][:pictures][:personal]" ] ],
#	[ "team.jpg", [ "[:root][:pictures][:professional]" ] ],
#	[ "snapshot.jpg", [ "[:root][:pictures][:professional]" ] ],
#	[ "other.jpg", [ "[:root][:pictures]" ] ],
#	[ "readme.txt", [ "[:root]" ] ],
#	[ [ 1, 2, 3 ], [ "[:root]" ] ]
# ]

? @@( o1.FindLeaf("team.jpg") ) + NL
#--> [ "[:root][:pictures][:professional]" ]

? @@( o1.FindLeaf("snapshot.jpg") ) + NL
#--> [ "[:root][:pictures][:professional]" ]

? @@NL( o1.FindLeafs([ "Resume.docx", "team.jpg" ]) ) + NL
#--> [
#	[ "[:root][:documents]" ],
#	[ "[:root][:pictures][:professional]" ]
# ]

? @@( o1.LeafsAt("[:root][:pictures][:professional]") ) # Equivalent to Branch()
#--> [ "team.jpg", "snapshot.jpg" ]

pf()
# Executed in 0.24 second(s) in Ring 1.22

/* === ADDING NODES AND LEAFS

pr()

o1 = new stzTree(
	:root = [
		:documents = [
			"Resume.docx",
			"Cover_Letter.docx"
		],
		
		:projects = []
	]
)

o1.AddLeafAt("NewDocument.pdf", "[:root][:documents]")
? @@( o1.Branch("[:root][:documents]") ) + NL
#--> [
#	"Resume.docx",
#	"Cover_Letter.docx",
#	"NewDocument.pdf"
# ]

o1.AddNodeAt(:media = [ "video.mp4", "audio.mp3" ], "[:root]")
? o1.Nodes()
#--> [ "root", "documents", "projects", "media" ]

? @@( o1.Branch("[:root][:media]") ) + NL
#--> [ "video.mp4", "audio.mp3" ]


# Adding an empty node and then adding content to it...

o1.AddNodeAt(:archived = [], "[:root]")
o1.AddLeafAt("OldFile.txt", "[:root][:archived]")
? @@( o1.Branch("[:root][:archived]") ) + NL
#--> [ "OldFile.txt" ]

# Adding a nested node structure...

o1.AddNodeAt(:images = [], "[:root][:media]")
o1.AddLeafAt("photo.jpg", "[:root][:media][:images]")
? @@( o1.LeafsAt("[:root][:media][:images]") ) + NL
#--> [ "photo.jpg" ]

# Final Tree Structure
? o1.Show()
#--> [
#	"root",
#	[
#		[
#			"documents",
#			[ "Resume.docx", "Cover_Letter.docx", "NewDocument.pdf" ]
#		],
#		[
#			"projects",
#			[ ]
#		],
#		[
#			"media",
#			[
#				"video.mp4",
#				"audio.mp3",
#				[
#					"images",
#					[ "photo.jpg" ]
#				]
#			]
#		],
#		[
#			"archived",
#			[ "OldFile.txt" ]
#		]
#	]
# ]

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*=== GETTING NODES IN A PATH

pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "...", :node11 = [ "..." ] ],
		:node2 = [ "..." ],
		:node3 = [ "..." ]
	]
)

? @@( o1.NodesInPath('[:root]') )
#--> [ ":root" ]

? @@( o1.NodesInPath('[:root][:node1][:node11]') )
#--> [ ":root", ":node1", ":node11" ]

? o1.NthNodeInPath(2, '[:root][:node1][:node11]')
#--> ':node1'

? o1.LastNodeInPath('[:root][:node1][:node11]')
#--> ':node11'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*=== Node() and NodeAt()

pr()
o1 = new stzTree(
	:root = [
		:node1 = [ "...", :node11 = [ "..." ] ],
		:node2 = [ "..." ],
		:node3 = [ "..." ]
	]
)

? @@( o1.Node(:node2) )
#--> [ "..." ]

? @@( o1.NodeAt('[:root][:node2]') )
#--> [ "..." ]

pf()
# Executed in 0.03 second(s) in Ring 1.22

/* === REMOVING NODES

pr()
o1 = new stzTree(
	:root = [
		:node1 = [ "...", :node11 = [ "..." ] ],
		:node2 = [ "..." ],
		:node3 = [ "..." ]
	]
)

o1.RemoveNodeAt('[:root][:node2]')
o1.RemoveNode(:node3)
o1.RemoveNode(:node11)

o1.Show()
#--> [
#	"root",
#	[
#		[
#			"node1",
#			[ "..." ]
#		]
#	]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*---

pr()
o1 = new stzTree(
	:root = [
		:node1 = [ "...", :node11 = [ "..." ] ],
		:node2 = [ "..." ],
		:node3 = [ "..." ]
	]
)

o1.RemoveTheseNodes([:node11, :node2, :node3 ])
#--> [
#	"root",
#	[
#		[
#			"node1",
#			[ "..." ]
#		]
#	]
# ]

o1.Show()
# Executed in 0.05 second(s) in Ring 1.22

pf()
# Executed in 0.05 second(s) in Ring 1.22

/*=== GETTING LEAFS (itEMS) BY NODE AND BY BRANCH

pr()
o1 = new stzTree(
	:root = [
		:node1 = [ "...", :node11 = [ "A", "B", "C" ] ],
		:node2 = [ "..." ],
		:node3 = [ "..." ]
	]
)

? @@( o1.LeafsInNode(:node11) ) # OR ItemsInNode()
#--> [ "A", "B", "C" ]

? @@( o1.LeafsAt('[:root][:node1][:node11]') ) # Or ItemsAt()
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*=== REMOVING LEAFS (ITEMS)

pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

o1.RemoveLeaf("X") # Or RemoveItem()
o1.Show()
#--> [
#	"root",
#	[
#		[
#			"node1",
#			[
#				[
#					"node11",
#					[ "A", "B", "C", "D" ]
#				]
#			]
#		],
#		[
#			"node2",
#			[ 1, 2, 3 ]
#		],
#		[
#			"node3",
#			[ 4, 5 ]
#		]
#	]
# ]

o1.RemoveLeafAt("B", '[:root][:node1][:node11]')
? @@(o1.Node(:node11))
#--> [ "A", "C", "D" ]

o1.RemoveLeafInNode("A", :node11)
? @@(o1.Node(:node11))
#--> [ "C", "D" ]

o1.RemoveTheseLeafsAt([ "C", "D" ], '[:root][:node1][:node11]')
? @@(o1.Node(:node11))
#--> [ ]

o1.RemoveLeafs()
o1.Show()
#--> [
#	"root",
#	[
#		[
#			"node1",
#			[
#				[
#					"node11",
#					[ ]
#				]
#			]
#		],
#		[
#			"node2",
#			[ ]
#		],
#		[
#			"node3",
#			[ ]
#		]
#	]
# ]

pf()
# Executed in 0.19 second(s) in Ring 1.22

/*=== REPLACING NODES AND LEAFS (ITEMS)

# The tests in this section cover:
# - Node replacement at various levels of the tree
# - Leaf replacement with different targeting strategies (global, specific branch, specific node)
# - Case-sensitive vs case-insensitive replacements
# - Multiple replacements at once
# - Replacing all leafs with a single value
# - Working with both string and numeric values

/*--
*/
pr()

# Set up a test tree
o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

? "INITIAL TREE STRUCTURE:"
o1.Show()


? "============================================"
? "TESTING REPLACE NODE METHODS"
? "============================================"

# Testing ReplaceNode()
? "Replacing node11 with new node test1:"
o1.ReplaceNode("node11", [ "test1", [ "new1", "new2" ] ])
? @@(o1.Node("test1"))
#--> [ "new1", "new2" ]

# Testing ReplaceNodeAt()
? "Replacing node3 using branch path:"
o1.ReplaceNodeAt([ "node3new", [ "hello", "world" ] ], '[:root][:node3]')
? @@(o1.Node("node3new"))
#--> [ "hello", "world" ]

? "============================================"
? "TESTING REPLACE LEAF METHODS"
? "============================================"

# Testing ReplaceLeaf() - replaces all occurrences
? "Replacing all 'X' with 'REPLACED':"
o1.ReplaceLeaf("X", "REPLACED")
o1.Show()
/*
Tree with all X replaced by REPLACED
*/

# Reset tree for next tests
o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

# Testing ReplaceLeafAt() - specific location
? "Replacing 'B' with 'BETA' at specific branch:"
o1.ReplaceLeafAt("B", "BETA", '[:root][:node1][:node11]')
? @@(o1.NodeAt('[:root][:node1][:node11]'))
#--> [ "A", "BETA", "C", "D", "X" ]

# Testing ReplaceLeafInNode() - by node name
? "Replacing 'A' with 'ALPHA' in node11:"
o1.ReplaceLeafInNode("A", "ALPHA", "node11")
? @@(o1.Node("node11"))
#--> [ "ALPHA", "BETA", "C", "D", "X" ]

# Testing ReplaceTheseLeafs() - multiple at once
? "Replacing multiple items at once:"
o1.ReplaceTheseLeafs([ "C", "D" ], [ "GAMMA", "DELTA" ])
? @@(o1.Node("node11"))
#--> [ "ALPHA", "BETA", "GAMMA", "DELTA", "X" ]

# Testing ReplaceLeafCS() - with case sensitivity
? "Replacing with case sensitivity:"
o1 = new stzTree(
	:root = [
		:node1 = [ "x", "X", :node11 = [ "a", "A" ] ]
	]
)

? "Case sensitive (default):"
o1.ReplaceLeaf("x", "replaced-lowercase")
? @@(o1.NodeAt('[:root][:node1]'))
#--> [ "replaced-lowercase", "X", ["node11", ["a", "A"]] ]

? "Case insensitive:"
o1.ReplaceLeafCS("a", "replaced-a", FALSE)
? @@(o1.NodeAt('[:root][:node1][:node11]'))
#--> [ "replaced-a", "replaced-a" ]

# Testing ReplaceAllLeafsWith() - change all leafs
? "Replacing all leafs with single value:"
o1 = new stzTree(
	:root = [
		:node1 = [ "one", "two", :node11 = [ "three", "four" ] ],
		:node2 = [ "five", "six" ]
	]
)

o1.ReplaceAllLeafsWith("ALL-SAME")
o1.Show()
/*
All leaf nodes replaced with "ALL-SAME"
*/

# Test with numbers
? "Testing with numeric values:"
o1 = new stzTree(
	:root = [
		:node1 = [ 1, 2, :node11 = [ 3, 4 ] ],
		:node2 = [ 5, 6 ]
	]
)

o1.ReplaceLeaf(3, 333)
? @@(o1.Node("node11"))
#--> [ 333, 4 ]

o1.ReplaceTheseLeafs([ 1, 5 ], [ 111, 555 ])
? @@(o1.NodeAt('[:root][:node1]'))
#--> [ 111, 2, ["node11", [333, 4]] ]
? @@(o1.NodeAt('[:root][:node2]'))
#--> [ 555, 6 ]

pf()
