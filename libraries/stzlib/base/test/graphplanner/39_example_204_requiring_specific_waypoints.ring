# Narrative
# --------
# Example 20.4: Requiring Specific Waypoints
#
# Extracted from stzgraphplannertest.ring, block #39.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

`
  CONCEPT: Plans must pass through certain nodes
  
  Ensure plan visits specific location (e.g., delivery
  truck must stop at distribution center).
`

pr()

oGraph = new stzGraph("waypoint_test")
oGraph {
	AddNode("warehouse")
	AddNode("distribution_center")
	AddNode("direct_route")
	AddNode("customer")
	
	# Direct: skips distribution
	AddEdgeXTT("warehouse", "direct_route", "path", [:cost = 20])
	AddEdgeXTT("direct_route", "customer", "path", [:cost = 15])
	
	# Via distribution
	AddEdgeXTT("warehouse", "distribution_center", "path", [:cost = 25])
	AddEdgeXTT("distribution_center", "customer", "path", [:cost = 20])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Direct route
	AddPlan("direct")
	Walk(:From = "warehouse", :To = "customer")
	Minimize("cost")
	Execute()
	
	# Force via distribution
	AddPlan("via_dc")
	Walk(:From = "warehouse", :To = "distribution_center")
	Minimize("cost")
	Execute()
	
	# Filter requiring waypoint
	oFilter = PlansRequiringQ("distribution_center")
	? oFilter.Count()
	#--> 1
	
	? @@( oFilter.Plans() ) + NL
	#--> [ "via_dc" ]

	? @@NL( oFilter.PlansXT() )
	#--> [
	# 	[
	# 		"constrains_applied",
	# 		[
	# 			[ "requires", "distribution_center" ]
	# 		]
	# 	],
	# 	[ "plans_matching_count", 1 ],
	# 	[
	# 		"plans_matching_details",
	# 		[
	# 			[
	# 				[ "plan", "via_dc" ],
	# 				[ "cost", 25 ],
	# 				[ "steps", 2 ],
	# 				[
	# 					"route",
	# 					[ "warehouse", "distribution_center" ]
	# 				]
	# 			]
	# 		]
	# 	]
	# ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.25
