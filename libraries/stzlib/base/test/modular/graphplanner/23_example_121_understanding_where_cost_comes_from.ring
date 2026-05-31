# Narrative
# --------
# Example 12.1: Understanding Where Cost Comes From
#
# Extracted from stzgraphplannertest.ring, block #23.

load "../../../stzBase.ring"

`
  CONCEPT: Transparency through detailed breakdowns
  
  When a plan has high cost, you need to see exactly where
  that cost is accumulated step by step.
`

pr()

oGraph = new stzGraph("complex_route")
oGraph {
	AddNode("start")
	AddNode("point_a")
	AddNode("point_b")
	AddNode("end")
	
	AddEdgeXTT("start", "point_a", "road", [
		:distance = 10,
		:traffic = 2
	])
	AddEdgeXTT("point_a", "point_b", "road", [
		:distance = 15,
		:traffic = 8  # Heavy congestion here!
	])
	AddEdgeXTT("point_b", "end", "road", [
		:distance = 5,
		:traffic = 1
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("route_analysis")
	Walk(:From = "start", :To = "end")
	Minimize("distance")
	Minimize("traffic")
	Execute()

	? @@NL( CostBreakdown() )
	#--> [
	# 	[
	# 		[ "step", 1 ],
	# 		[ "from", "start" ],
	# 		[ "to", "point_a" ],
	# 		[
	# 			"criteria",
	# 			[
	# 				[
	# 					[ "property", "distance" ],
	# 					[ "value", 10 ],
	# 					[ "weight", 1 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 10 ]
	# 				],
	# 				[
	# 					[ "property", "traffic" ],
	# 					[ "value", 2 ],
	# 					[ "weight", 1 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 2 ]
	# 				]
	# 			]
	# 		],
	# 		[
	# 			[ "total", 12 ]
	# 		]
	# 	],
	# 	[
	# 		[ "step", 2 ],
	# 		[ "from", "point_a" ],
	# 		[ "to", "point_b" ],
	# 		[
	# 			"criteria",
	# 			[
	# 				[
	# 					[ "property", "distance" ],
	# 					[ "value", 15 ],
	# 					[ "weight", 1 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 15 ]
	# 				],
	# 				[
	# 					[ "property", "traffic" ],
	# 					[ "value", 8 ],
	# 					[ "weight", 1 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 8 ]
	# 				]
	# 			]
	# 		],
	# 		[
	# 			[ "total", 23 ]
	# 		]
	# 	],
	# 	[
	# 		[ "step", 3 ],
	# 		[ "from", "point_b" ],
	# 		[ "to", "end" ],
	# 		[
	# 			"criteria",
	# 			[
	# 				[
	# 					[ "property", "distance" ],
	# 					[ "value", 5 ],
	# 					[ "weight", 1 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 5 ]
	# 				],
	# 				[
	# 					[ "property", "traffic" ],
	# 					[ "value", 1 ],
	# 					[ "weight", 1 ],
	# 					[ "direction", "minimize" ],
	# 					[ "contribution", 1 ]
	# 				]
	# 			]
	# 		],
	# 		[
	# 			[ "total", 6 ]
	# 		]
	# 	]
	# ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.25
