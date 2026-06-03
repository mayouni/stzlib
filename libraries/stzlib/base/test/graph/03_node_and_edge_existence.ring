# Narrative
# --------
# Node and Edge Existence
#
# Extracted from stzgraphtest.ring, block #3.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("ExistenceTest")
oGraph {
	AddNode("a")
	AddNode("b")
	Connect("a", "b")
	
	? @@NL( Nodes() )
	#-->
	'
	[
		[
			[ "id", "a" ],
			[ "label", "a" ],
			[ "props", [  ] ]
		],
		[
			[ "id", "b" ],
			[ "label", "b" ],
			[ "properties", [  ] ]
		]
	]
	'

	? HasNode("a")         #--> TRUE
	? HasNode("missing")   #--> FALSE

	? ""

	? @@NL( Edges() )
	#-->
	'
	[
		[
			[ "from", "a" ],
			[ "to", "b" ],
			[ "label", "" ],
			[ "properties", [  ] ]
		]
	]
	'

	? EdgeExists("a", "b") #--> TRUE
	? EdgeExists("b", "a") #--> FALSE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
