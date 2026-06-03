# Narrative
# --------
# Graph Explanation #TODO #ERR
#
# Extracted from stzgraphtest.ring, block #33.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("ExplainTest")
oGraph {
	AddNode("A")
	AddNode("B")
	AddNode("C")
	
	Connect("A", :and = "B")
	Connect("B", "C")
	Connect("c", "a") #NOTE// You can use upper or lower node name
	
	? @@NL( Explain() )
}
#-->
'
[
	[
		"general",
		[ "Graph: ExplainTest", "Nodes: 3 | Edges: 3" ]
	],
	[
		"bottlenecks",
		[ "No bottlenecks (average degree = 2)" ]
	],
	[
		"cycles",
		[ "WARNING: Circular dependencies detected" ]
	],
	[
		"metrics",
		[
			"Density: 0.50% (sparse)",
			"Longest path: 2 hops"
		]
	],
	[
		"rules",
		[ "No rules applied" ]
	]
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.24
