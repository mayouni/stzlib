# Narrative
# --------
# Example 17.1: Teaching A* Through Exploration
#
# Extracted from stzgraphplannertest.ring, block #31.

load "../../stzBase.ring"

`
  CONCEPT: Learn by using, not implementing
  
  Students explore pathfinding concepts without
  implementation details.
`

pr()

oGraph = new stzGraph("learning")
oGraph {
	AddNode("A")
	AddNode("B")
	AddNode("C")
	AddNode("D")
	
	AddEdgeXTT("A", "B", "path", [:cost = 1])
	AddEdgeXTT("A", "C", "path", [:cost = 4])
	AddEdgeXTT("B", "D", "path", [:cost = 5])
	AddEdgeXTT("C", "D", "path", [:cost = 1])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("learning_astar")
	Walk(:From = "A", :To = "D")
	Minimize("cost")
	Execute()

	# What route did A* find?
	? @@( Route() ) + NL
	#--> [ "a", "c", "d" ] (cost 5, not a->b->d cost 6)
	
	# Why this route?
	? @@NL( ExplainWhy("route") ) + NL
	#--> [
	# 	[ "plan", "learning_astar" ],
	# 	[ "total_cost", 5 ],
	# 	[ "nodes_explored", 4 ],
	# 	[
	# 		"optimized_for",
	# 		[
	# 			[
	# 				[ "direction", "minimize" ],
	# 				[ "property", "cost" ]
	# 			]
	# 		]
	# 	],
	# 	[
	# 		"route",
	# 		[ "a", "c", "d" ]
	# 	]
	# ]

	# Search efficiency?
	? @@NL( ExplainEfficiency() ) + NL
	#--> [
	# 	[ "plan", "learning_astar" ],
	# 	[ "nodes_explored", 4 ],
	# 	[ "path_length", 3 ],
	# 	[ "ratio", 1.33 ],
	# 	[ "assessment", "very efficient" ]
	# ]

	# Cost breakdown?
	? @@NL( ExplainCostBreakdown() )
	#--> [
	# 	[
	# 		[ "step", 1 ],
	# 		[ "from", "a" ],
	# 		[ "to", "c" ],
	# 		[
	# 			"criteria",
	# 			[
	# 				[
	# 					[ "property", "cost" ],
	# 					[ "value", 4 ],
	# 					[ "weight", 1 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 4 ]
	# 				]
	# 			]
	# 		],
	# 		[
	# 			[ "total", 4 ]
	# 		]
	# 	],
	# 	[
	# 		[ "step", 2 ],
	# 		[ "from", "c" ],
	# 		[ "to", "d" ],
	# 		[
	# 			"criteria",
	# 			[
	# 				[
	# 					[ "property", "cost" ],
	# 					[ "value", 1 ],
	# 					[ "weight", 1 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 1 ]
	# 				]
	# 			]
	# 		],
	# 		[
	# 			[ "total", 1 ]
	# 		]
	# 	]
	# ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#=====================================#
#  SECTION 18: MULTI-PLAN COMPARISON  #
#=====================================#
