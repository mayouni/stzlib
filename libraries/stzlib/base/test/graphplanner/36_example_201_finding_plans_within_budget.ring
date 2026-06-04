# Narrative
# --------
# Example 20.1: Finding Plans Within Budget
#
# Extracted from stzgraphplannertest.ring, block #36.

load "../../stzBase.ring"

`
  CONCEPT: Filter plans by constraints
  
  Create genuinely different routes, then filter by
  cost, avoided nodes, or other criteria.
`

pr()

oGraph = new stzGraph("filtered_network")
oGraph {
	AddNode("origin")
	AddNode("cheap_route")
	AddNode("expensive_route")
	AddNode("medium_route")
	AddNode("avoid_me")
	AddNode("destination")
	
	# Cheap: 15 total
	AddEdgeXTT("origin", "cheap_route", "path", [:cost = 10])
	AddEdgeXTT("cheap_route", "destination", "path", [:cost = 5])
	
	# Expensive through avoid_me: 80 total
	AddEdgeXTT("origin", "expensive_route", "path", [:cost = 50])
	AddEdgeXTT("expensive_route", "avoid_me", "path", [:cost = 20])
	AddEdgeXTT("avoid_me", "destination", "path", [:cost = 10])
	
	# Medium: 35 total
	AddEdgeXTT("origin", "medium_route", "path", [:cost = 20])
	AddEdgeXTT("medium_route", "destination", "path", [:cost = 15])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Force different routes
	AddPlan("plan_cheap")
	Walk(:From = "origin", :To = "destination")
	Minimize("cost")
	Execute()
	
	AddPlan("plan_via_avoid")
	Walk(:From = "origin", :To = "avoid_me")
	Minimize("cost")
	Execute()
	
	AddPlan("plan_via_medium")
	Walk(:From = "origin", :To = "medium_route")
	Minimize("cost")
	Execute()
	
	#-------------------------------
	? BoxRound("Filter: cost <= 50")
	#-------------------------------

	oFilter1 = FilterPlansQ([:maxCost = 50]) # get a stzPlanFilter object
	? oFilter1.Count()
	#--> 2
	
	? @@( oFilter1.Plans() ) + NL
	#--> [ "plan_cheap", "plan_via_medium" ]

	? @@NL( oFilter1.PlansXT() ) + NL
	#--> [
	# 	[
	# 		"constrains_applied",
	# 		[
	# 			[ "maxcost", 50 ]
	# 		]
	# 	],
	# 	[ "plans_matching_count", 2 ],
	# 	[
	# 		"plans_matching_details",
	# 		[
	# 			[
	# 				[ "plan", "plan_cheap" ],
	# 				[ "cost", 15 ],
	# 				[ "steps", 3 ],
	# 				[
	# 					"route",
	# 					[ "origin", "cheap_route", "destination" ]
	# 				]
	# 			],
	# 			[
	# 				[ "plan", "plan_via_medium" ],
	# 				[ "cost", 20 ],
	# 				[ "steps", 2 ],
	# 				[
	# 					"route",
	# 					[ "origin", "medium_route" ]
	# 				]
	# 			]
	# 		]
	# 	]
	# ]

	#-------------------------------
	? BoxRound("Filter: avoid node")
	#-------------------------------

	oFilter2 = PlansAvoidingQ("avoid_me")
	? oFilter2.Count()
	#--> 2
	
	? @@( oFilter2.Plans() ) + NL
	#--> [ "plan_cheap", "plan_via_medium" ]
	
	? @@NL( oFilter2.PlansXT() ) + NL
	#--> [
	# 	[
	# 		"constrains_applied",
	# 		[
	# 			[ "avoid", "avoid_me" ]
	# 		]
	# 	],
	# 	[ "plans_matching_count", 2 ],
	# 	[
	# 		"plans_matching_details",
	# 		[
	# 			[
	# 				[ "plan", "plan_cheap" ],
	# 				[ "cost", 15 ],
	# 				[ "steps", 3 ],
	# 				[
	# 					"route",
	# 					[ "origin", "cheap_route", "destination" ]
	# 				]
	# 			],
	# 			[
	# 				[ "plan", "plan_via_medium" ],
	# 				[ "cost", 20 ],
	# 				[ "steps", 2 ],
	# 				[
	# 					"route",
	# 					[ "origin", "medium_route" ]
	# 				]
	# 			]
	# 		]
	# 	]
	# ]

	#-------------------------------
	? BoxRound("Filter: cost >= 20")
	#-------------------------------

	oFilter3 = FilterPlansQ([:minCost = 20])
	? oFilter3.Count()
	#--> 2
	
	? @@(oFilter3.Plans()) + NL
	#--> [ "plan_via_avoid", "plan_via_medium" ]

	? @@NL(oFilter3.PlansXT())
	#--> [
	# 	[
	# 		"constrains_applied",
	# 		[
	# 			[ "mincost", 20 ]
	# 		]
	# 	],
	# 	[ "plans_matching_count", 2 ],
	# 	[
	# 		"plans_matching_details",
	# 		[
	# 			[
	# 				[ "plan", "plan_via_avoid" ],
	# 				[ "cost", 70 ],
	# 				[ "steps", 3 ],
	# 				[
	# 					"route",
	# 					[ "origin", "expensive_route", "avoid_me" ]
	# 				]
	# 			],
	# 			[
	# 				[ "plan", "plan_via_medium" ],
	# 				[ "cost", 20 ],
	# 				[ "steps", 2 ],
	# 				[
	# 					"route",
	# 					[ "origin", "medium_route" ]
	# 				]
	# 			]
	# 		]
	# 	]
	# ]

}

pf()
# Executed in 0.05 second(s) in Ring 1.25
