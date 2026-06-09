# Narrative
# --------
# Example 12.2: Profile Cost Breakdown
#
# Extracted from stzgraphplannertest.ring, block #24.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

`
  CONCEPT: Profiles with weighted criteria show how weights affect cost
  
  When using :fastest profile, see how time and distance
  contributions are weighted differently (0.7 vs 0.3).
`

pr()

oGraph = new stzGraph("weighted_route")
oGraph {
	AddNode("origin")
	AddNode("waypoint")
	AddNode("goal")
	
	AddEdgeXTT("origin", "waypoint", "path", [
		:time = 20,
		:distance = 10
	])
	AddEdgeXTT("waypoint", "goal", "path", [
		:time = 15,
		:distance = 25
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("weighted_analysis")
	Walk(:From = "origin", :To = "goal")
	Using(:fastest)  # time=0.7, distance=0.3
	Execute()

	? @@NL( CostBreakdown() ) # Or ExplainBreakDown()
	#--> [
	# 	[
	# 		[ "step", 1 ],
	# 		[ "from", "origin" ],
	# 		[ "to", "waypoint" ],
	# 		[
	# 			"criteria",
	# 			[
	# 				[
	# 					[ "property", "time" ],
	# 					[ "value", 20 ],
	# 					[ "weight", 0.70 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 14 ]
	# 				],
	# 				[
	# 					[ "property", "distance" ],
	# 					[ "value", 10 ],
	# 					[ "weight", 0.30 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 3 ]
	# 				]
	# 			]
	# 		],
	# 		[
	# 			[ "total", 17 ]
	# 		]
	# 	],
	# 	[
	# 		[ "step", 2 ],
	# 		[ "from", "waypoint" ],
	# 		[ "to", "goal" ],
	# 		[
	# 			"criteria",
	# 			[
	# 				[
	# 					[ "property", "time" ],
	# 					[ "value", 15 ],
	# 					[ "weight", 0.70 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 10.50 ]
	# 				],
	# 				[
	# 					[ "property", "distance" ],
	# 					[ "value", 25 ],
	# 					[ "weight", 0.30 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 7.50 ]
	# 				]
	# 			]
	# 		],
	# 		[
	# 			[ "total", 18 ]
	# 		]
	# 	]
	# ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#==============================#
#  SECTION 13: EXPLAINING WHY  #
#==============================#
