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
*/
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
