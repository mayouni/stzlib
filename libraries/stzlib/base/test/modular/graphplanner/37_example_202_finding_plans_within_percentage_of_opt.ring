# Narrative
# --------
# Example 20.2: Finding Plans Within Percentage of Optimal
#
# Extracted from stzgraphplannertest.ring, block #37.

load "../../../stzBase.ring"

`
  CONCEPT: Tolerance-based filtering
  
  Find "good enough" solutions within percentage of optimal.
`

pr()

oGraph = new stzGraph("tolerance_test")
oGraph {
	AddNode("base")
	AddNode("option_a")
	AddNode("option_b")
	AddNode("option_c")
	AddNode("target")
	
	# Optimal: 40
	AddEdgeXTT("base", "option_a", "path", [:cost = 40])
	AddEdgeXTT("option_a", "target", "path", [:cost = 60])
	
	# Near-optimal: 45 (12.5% worse)
	AddEdgeXTT("base", "option_b", "path", [:cost = 45])
	AddEdgeXTT("option_b", "target", "path", [:cost = 60])
	
	# Suboptimal: 70 (75% worse)
	AddEdgeXTT("base", "option_c", "path", [:cost = 70])
	AddEdgeXTT("option_c", "target", "path", [:cost = 60])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Force different routes
	AddPlan("optimal")
	Walk(:From = "base", :To = "option_a")
	Minimize("cost")
	Execute()
	
	AddPlan("near_optimal")
	Walk(:From = "base", :To = "option_b")
	Minimize("cost")
	Execute()
	
	AddPlan("suboptimal")
	Walk(:From = "base", :To = "option_c")
	Minimize("cost")
	Execute()
	
	# Filter within 15% of optimal
	oFilter = PlansWithinQ(15, :of = "optimal") # get a stzPlanFilter object
	? oFilter.Count()
	#--> 2
	
	? @@( oFilter.Plans() ) + NL
	#--> [ "optimal", "near_optimal" ]
	
	? @@NL( oFilter.PlansXT() ) + NL
	#--> [
	# 	[
	# 		"constrains_applied",
	# 		[
	# 			[ "maxcost", 46 ]
	# 		]
	# 	],
	# 	[ "plans_matching_count", 2 ],
	# 	[
	# 		"plans_matching_details",
	# 		[
	# 			[
	# 				[ "plan", "optimal" ],
	# 				[ "cost", 40 ],
	# 				[ "steps", 2 ],
	# 				[
	# 					"route",
	# 					[ "base", "option_a" ]
	# 				]
	# 			],
	# 			[
	# 				[ "plan", "near_optimal" ],
	# 				[ "cost", 45 ],
	# 				[ "steps", 2 ],
	# 				[
	# 					"route",
	# 					[ "base", "option_b" ]
	# 				]
	# 			]
	# 		]
	# 	]
	# ]

	? oFilter.BestBy("cost") + NL
	#--> optimal
	
	oFilter.ShowRankingTable()
	#-->
	`
	╭──────┬──────────────┬──────┬───────╮
	│ Rank │     Plan     │ Cost │ Steps │
	├──────┼──────────────┼──────┼───────┤
	│    1 │ optimal      │   40 │     2 │
	│    2 │ near_optimal │   45 │     2 │
	╰──────┴──────────────┴──────┴───────╯
	`
}

pf()
# Executed in 0.04 second(s) in Ring 1.25
