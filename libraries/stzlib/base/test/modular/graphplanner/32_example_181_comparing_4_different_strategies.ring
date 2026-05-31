# Narrative
# --------
# Example 18.1: Comparing 4 Different Strategies
#
# Extracted from stzgraphplannertest.ring, block #32.

load "../../../stzBase.ring"

`
  CONCEPT: Compare multiple plans simultaneously
  
  Evaluate several strategies at once to find best
  performer under different criteria.
`

pr()

oGraph = new stzGraph("multi_strategy")
oGraph {
	AddNode("warehouse")
	AddNode("route_highway")
	AddNode("route_backroad")
	AddNode("route_express")
	AddNode("destination")
	
	# Highway: fast but expensive
	AddEdgeXTT("warehouse", "route_highway", "path", [
		:time = 10, :cost = 50, :distance = 20
	])
	AddEdgeXTT("route_highway", "destination", "path", [
		:time = 8, :cost = 40, :distance = 15
	])
	
	# Backroad: slow but cheap
	AddEdgeXTT("warehouse", "route_backroad", "path", [
		:time = 25, :cost = 15, :distance = 30
	])
	AddEdgeXTT("route_backroad", "destination", "path", [
		:time = 20, :cost = 10, :distance = 25
	])
	
	# Express: very fast, very expensive
	AddEdgeXTT("warehouse", "route_express", "path", [
		:time = 5, :cost = 80, :distance = 18
	])
	AddEdgeXTT("route_express", "destination", "path", [
		:time = 4, :cost = 60, :distance = 12
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Create 4 strategy plans
	AddPlan("ultra_fast")
	Walk(:From = "warehouse", :To = "destination")
	Using(:fastest)
	Execute()
	
	AddPlan("budget")
	Walk(:From = "warehouse", :To = "destination")
	Using(:cheapest)
	Execute()
	
	AddPlan("short_distance")
	Walk(:From = "warehouse", :To = "destination")
	Using(:shortest)
	Execute()
	
	AddPlan("balanced")
	Walk(:From = "warehouse", :To = "destination")
	Using(:balanced)
	Execute()
	
	# Compare all plans (get a comparison object from stzMultiPlanComparison)
	oMulti = CompareManyQ(["ultra_fast", "budget", "short_distance", "balanced"])
	
	? @@NL( oMulti.CompareAll() ) + NL
	#--> [
	# 	[ "total_plans", 4 ],
	# 	[
	# 		"plans",
	# 		[
	# 			[
	# 				[ "plan", "ultra_fast" ],
	# 				[ "cost", 15.30 ],
	# 				[ "steps", 3 ],
	# 				[
	# 					"route",
	# 					[ "warehouse", "route_express", "destination" ]
	# 				]
	# 			],
	# 			[
	# 				[ "plan", "budget" ],
	# 				[ "cost", 31 ],
	# 				[ "steps", 3 ],
	# 				[
	# 					"route",
	# 					[ "warehouse", "route_backroad", "destination" ]
	# 				]
	# 			],
	# 			[
	# 				[ "plan", "short_distance" ],
	# 				[ "cost", 30 ],
	# 				[ "steps", 3 ],
	# 				[
	# 					"route",
	# 					[ "warehouse", "route_express", "destination" ]
	# 				]
	# 			],
	# 			[
	# 				[ "plan", "balanced" ],
	# 				[ "cost", 42 ],
	# 				[ "steps", 3 ],
	# 				[
	# 					"route",
	# 					[ "warehouse", "route_backroad", "destination" ]
	# 				]
	# 			]
	# 		]
	# 	],
	# 	[ "best_by_cost", "ultra_fast" ],
	# 	[ "best_by_steps", "ultra_fast" ]
	# ]
	
	# Rank by cost
	? @@NL( oMulti.RankBy("cost") ) + NL
	#--> [
	#      [ "ultra_fast", 15.30 ],
	#      [ "short_distance", 30 ],
	#      [ "budget", 31 ],
	#      [ "balanced", 42 ]
	#    ]

	# Rank by steps
	? @@NL( oMulti.RankBy("steps") ) + NL
	#--> [
	# 	[ "ultra_fast", 3 ],
	# 	[ "budget", 3 ],
	# 	[ "short_distance", 3 ],
	# 	[ "balanced", 3 ]
	# ]

	# Complete ranking
	oMulti.ShowRankingTable()
	#-->
	`
	╭──────┬────────────────┬───────┬───────╮
	│ Rank │      Plan      │ Cost  │ Steps │
	├──────┼────────────────┼───────┼───────┤
	│    1 │ ultra_fast     │ 15.30 │     3 │
	│    2 │ short_distance │    30 │     3 │
	│    3 │ budget         │    31 │     3 │
	│    4 │ balanced       │    42 │     3 │
	╰──────┴────────────────┴───────┴───────╯
	`
	
	? NL + oMulti.BestBy("cost")
	#--> ultra_fast
	
	? oMulti.WorstBy("cost")
	#--> balanced
}

#WARNING #TODO Check this:
# The example creates routes to different intermediate nodes,
# not truly different paths to the same destination.
# This may confuse users about what's being compared.

pf()
# Executed in 0.09 second(s) in Ring 1.25
