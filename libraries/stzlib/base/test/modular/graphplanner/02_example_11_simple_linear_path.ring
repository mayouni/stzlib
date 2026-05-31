# Narrative
# --------
# Example 1.1: Simple Linear Path
#
# Extracted from stzgraphplannertest.ring, block #2.

load "../../../stzBase.ring"

`
  CONCEPT: A* guarantees finding the shortest path
  
  Graph structure:
    A ---10--- B ---10--- C
  
  The path is obvious here, but A* will explore it
  systematically, building up cost as it goes.
`

pr()

oGraph = new stzGraph("linear")
oGraph {
	AddNodeXTT("A", "Start Point", [:x = 0, :y = 0])
	AddNodeXTT("B", "Middle Point", [:x = 10, :y = 0])
	AddNodeXTT("C", "End Point", [:x = 20, :y = 0])
	
	AddEdgeXTT("A", "B", "road", [:distance = 10])
	AddEdgeXTT("B", "C", "road", [:distance = 10])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {

	AddPlan("linear_path") # You can add many plans
	# The current stzGraphPlanner object is set automatically to
	# the first plan created.
	# But you can set it explicitely by SetCurrentPlan(cPlanName).
	# And you can the current plan by CurrentPlan()

	WalkFrom("A", :To = "C")
	Minimizing("distance") # Or MinimizeXT("distance", :InPlan = "linear_path")

	Execute() # Or ExecuteXT("linear_path")

	? Cost()
	#--> 20

	? @@( Route() ) # Or States()
	#--> [ "a", "b", "c" ]

	? @@NL( Explain() )
	#--> [
	# 	[ "plan", "linear_path" ],
	# 	[
	# 		"actions",
	# 		[
	# 			[
	# 				[ "from", "a" ],
	# 				[ "to", "b" ],
	# 				[ "cost", 10 ]
	# 			],
	# 			[
	# 				[ "from", "b" ],
	# 				[ "to", "c" ],
	# 				[ "cost", 10 ]
	# 			]
	# 		]
	# 	],
	# 	[ "total_cost", 20 ],
	# 	[
	# 		"route",
	# 		[ "a", "b", "c" ]
	# 	],
	# 	[ "steps", 2 ]
	# ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.25
