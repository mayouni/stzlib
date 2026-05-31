# Narrative
# --------
# Example 13.1: Why Was This Route Chosen?
#
# Extracted from stzgraphplannertest.ring, block #25.

load "../../../stzBase.ring"

`
  CONCEPT: Plans should explain their reasoning
  
  When the planner makes a decision, you should be able to
  ask "why?" and get a clear answer about the optimization
  criteria and exploration process.
`

pr()

oGraph = new stzGraph("decision")
oGraph {
	AddNode("base")
	AddNode("option_a")
	AddNode("option_b")
	AddNode("target")
	
	AddEdgeXTT("base", "option_a", "path", [:cost = 10])
	AddEdgeXTT("base", "option_b", "path", [:cost = 5])
	AddEdgeXTT("option_a", "target", "path", [:cost = 3])
	AddEdgeXTT("option_b", "target", "path", [:cost = 15])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("decision_route")
	Walk(:From = "base", :To = "target")
	Minimize("cost")
	Execute()

	# WHY THIS ROUTE?
	? @@NL( ExplainWhy("route") ) + NL # Or Why()
	#--> [
	# 	[ "plan", "decision_route" ],
	# 	[ "total_cost", 13 ],
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
	# 		[ "base", "option_a", "target" ]
	# 	]
	# ]
	
	# Chosen path:
	? @@( Route() )
	#--> [ "base", "option_a", "target" ]

	# ~> Chose option_a even though option_b starts cheaper,
	# because total route through option_a is cheaper (13 vs 20)
}

pf()
# Executed in 0.01 second(s) in Ring 1.25
