# Narrative
# --------
# Skip and Limit
#
# Extracted from stzgraphquerytest.ring, block #17.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:rank = 1])
	AddNodeXTT("bob", "Employee", [:rank = 2])
	AddNodeXTT("carol", "Employee", [:rank = 3])
	AddNodeXTT("dave", "Employee", [:rank = 4])
}

StzGraphQueryQ(oGraph) {
	Match([:node = "n"])
	OrderBy("n.rank", :InAscending)
	Skip(1)
	LimitQ(2)

	aResults = Select("n")
}

? len(aResults)
#--> 2

? @@( aResults[1]["n"][:id] )
#--> "bob"

? @@NL( aResults )
#-->
`
[
	[
		[
			"n",
			[
				[ "id", "bob" ],
				[ "label", "Employee" ],
				[
					"properties",
					[
						[ "rank", 2 ]
					]
				]
			]
		]
	],
	[
		[
			"n",
			[
				[ "id", "carol" ],
				[ "label", "Employee" ],
				[
					"properties",
					[
						[ "rank", 3 ]
					]
				]
			]
		]
	]
]
`

pf()
# Executed in 0.02 second(s) in Ring 1.26

#-------------------#
#  CREATE PATTERNS  #
#-------------------#
