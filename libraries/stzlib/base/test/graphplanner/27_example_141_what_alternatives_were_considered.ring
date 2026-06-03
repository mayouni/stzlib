# Narrative
# --------
# Example 14.1: What Alternatives Were Considered?
#
# Extracted from stzgraphplannertest.ring, block #27.

load "../../stzBase.ring"

`
  CONCEPT: See the decision points in the search
  
  At each node with multiple neighbors, the planner made
  a choice. ExplainAlternatives() shows these decision points.
`

pr()

oGraph = new stzGraph("choices")
oGraph {
	AddNode("start")
	AddNode("fork_left")
	AddNode("fork_right")
	AddNode("junction_a")
	AddNode("junction_b")
	AddNode("end")
	
	# Multiple paths from start
	AddEdgeXTT("start", "fork_left", "path", [:cost = 5])
	AddEdgeXTT("start", "fork_right", "path", [:cost = 8])
	
	# Fork_left has options
	AddEdgeXTT("fork_left", "junction_a", "path", [:cost = 10])
	AddEdgeXTT("fork_left", "junction_b", "path", [:cost = 3])
	
	# Both junctions reach end
	AddEdgeXTT("junction_a", "end", "path", [:cost = 2])
	AddEdgeXTT("junction_b", "end", "path", [:cost = 5])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("explore_choices")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()

	# ALTERNATIVES EXPLORED
	? @@NL( Alternatives() ) + NL # Or ExplainAlternatives()
	#--> [
	# 	[ "plan", "explore_choices" ],
	# 	[
	# 		"decision_points",
	# 		[
	# 			[
	# 				[ "node", "start" ],
	# 				[ "chosen", "fork_left" ],
	# 				[ "total_options", 2 ]
	# 			],
	# 			[
	# 				[ "node", "fork_left" ],
	# 				[ "chosen", "junction_a" ],
	# 				[ "total_options", 2 ]
	# 			]
	# 		]
	# 	]
	# ]
	
	# Final route:
	? @@( Route() )
	#--> [ "start", "fork_left", "junction_b", "end" ]

	# Total cost:
	? Cost()
	#--> 13
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#===============================#
#  SECTION 15: PLAN COMPARISON  #
#===============================#
