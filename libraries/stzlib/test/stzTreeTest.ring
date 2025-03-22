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

/* === GETTING NODES IN A PATH

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

/*=== NODE() and NODEAT()

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

/* === REMOVING NODES AND LEAFS
*/

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
*
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

# Remove a leaf from a branch

o1.RemoveLeafAt("family.jpg", "[:root][:pictures][:personal]")
? @@( o1.LeafsAt("[:root][:pictures][:personal]") ) + NL
#--> [ "vacation.jpg" ]

# Remove multiple leafs from a branch

o1.RemoveLeafsAt([ "ProjectA.txt", "ProjectC.txt" ], "[:root][:projects]")
? @@( o1.LeafsAt("[:root][:projects]") ) + NL
#--> [ "ProjectB.txt" ]

# Remove a node errrrr

o1.RemoveNodeAt("[:root][:pictures][:professional]")
? @@( o1.Nodes() ) + NL
#--> [ "root", "documents", "projects", "pictures", "personal" ]

# Verify node is removed by checking if its content exists
? "Verifying 'team.jpg' no longer exists..."
? @@( o1.FindLeaf("team.jpg") ) + NL
#--> [ ]

# Remove root level leaf
? "Removing 'unclassified.doc' from root..."
o1.RemoveLeafAt("unclassified.doc", "[:root]")
? @@( o1.LeafsAt("[:root]") ) + NL
#--> [ "readme.txt", [ 1, 2, 3 ] ]

# Show final tree structure after removals
? "Final tree structure after removals:"
? o1.Show()

pf()
# Executed in 0.08 second(s) in Ring 1.22

/* === REPLACING NODES AND LEAFS

pr()

o1 = new stzTree(
	:root = [
		:documents = [
			"Resume.docx",
			"Cover_Letter.docx"
		],
		
		:projects = [
			"ProjectA.txt",
			"ProjectB.txt"
		],

		:pictures = [
			:personal = [
				"vacation.jpg",
				"family.jpg"
			]
		]
	]
)

# Replace a leaf in a branch
? "Replacing 'Resume.docx' with 'Updated_Resume.pdf'..."
o1.ReplaceLeafAt("Resume.docx", "Updated_Resume.pdf", "[:root][:documents]")
? @@( o1.LeafsAt("[:root][:documents]") ) + NL
#--> [ "Updated_Resume.pdf", "Cover_Letter.docx" ]

# Replace multiple leafs
? "Replacing project files with new versions..."
o1.ReplaceLeafsAt(
    [ "ProjectA.txt", "ProjectB.txt" ],
    [ "Project_2023.txt", "Project_2024.txt" ],
    "[:root][:projects]"
)
? @@( o1.LeafsAt("[:root][:projects]") ) + NL
#--> [ "Project_2023.txt", "Project_2024.txt" ]

# Replace an entire node
? "Replacing 'personal' node with 'archived'..."
o1.ReplaceNodeAt(
    "[:root][:pictures][:personal]",
    :archived = [ "old_photo1.jpg", "old_photo2.jpg" ]
)

? @@( o1.Nodes() ) + NL
#--> [ "root", "documents", "projects", "pictures", "archived" ]

# Verify the old content is gone
? "Verifying 'vacation.jpg' no longer exists..."
? @@( o1.FindLeaf("vacation.jpg") ) + NL
#--> [ ]

# Verify the new content exists
? "Verifying new content exists at the new node location..."
? @@( o1.LeafsAt("[:root][:pictures][:archived]") ) + NL
#--> [ "old_photo1.jpg", "old_photo2.jpg" ]

# Replace a node with a more complex structure
? "Replacing 'pictures' with 'media' containing nested nodes..."
o1.ReplaceNodeAt(
    "[:root][:pictures]",
    :media = [
        :images = [
            "photo1.png",
            "photo2.png"
        ],
        :videos = [
            "clip1.mp4",
            "clip2.mp4"
        ]
    ]
)

? @@( o1.Nodes() ) + NL
#--> [ "root", "documents", "projects", "media", "images", "videos" ]

? "Content of images node:"
? @@( o1.LeafsAt("[:root][:media][:images]") ) + NL
#--> [ "photo1.png", "photo2.png" ]

? "Content of videos node:"
? @@( o1.LeafsAt("[:root][:media][:videos]") ) + NL
#--> [ "clip1.mp4", "clip2.mp4" ]

# Final Tree Structure
? "Final tree structure after replacements:"
? o1.Show()

pf()
# Executed in 0.07 second(s) in Ring 1.22
