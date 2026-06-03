# Narrative
# --------
# Example 11.2: Comparing :fastest vs :cheapest Profiles
#
# Extracted from stzgraphplannertest.ring, block #20.

load "../../stzBase.ring"

`
  CONCEPT: Different profiles optimize for different goals
  
  Same graph, same start/end points - but different strategies
  lead to different routes and different trade-offs.
`

pr()

oGraph = new stzGraph("delivery_network")
oGraph {
	AddNodeXTT("warehouse", "Main Warehouse", [:x = 0, :y = 0])
	AddNodeXTT("suburb_a", "Suburb A", [:x = 10, :y = 5])
	AddNodeXTT("suburb_b", "Suburb B", [:x = 15, :y = 10])
	AddNodeXTT("customer", "Customer Location", [:x = 25, :y = 20])
	
	# Route via suburb_a: short distance, heavy traffic
	AddEdgeXTT("warehouse", "suburb_a", "highway", [
		:distance = 12,
		:time = 25,  # Heavy traffic
		:cost = 10
	])
	AddEdgeXTT("suburb_a", "customer", "road", [
		:distance = 18,
		:time = 20,
		:cost = 15
	])
	
	# Route via suburb_b: longer distance, light traffic
	AddEdgeXTT("warehouse", "suburb_b", "backroad", [
		:distance = 20,
		:time = 20,  # Light traffic
		:cost = 8
	])
	AddEdgeXTT("suburb_b", "customer", "highway", [
		:distance = 15,
		:time = 15,
		:cost = 12
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Plan 1: Optimize for speed
	AddPlan("speed_focused")
	SetCurrentPlan("speed_focused")
	Walk(:From = "warehouse", :To = "customer")
	Using(:fastest)
	Execute()
	
	# Plan 2: Optimize for cost
	AddPlan("cost_focused")
	SetCurrentPlan("cost_focused")
	Walk(:From = "warehouse", :To = "customer")
	Using(:cheapest)
	Execute()
	
	# Compare the two strategies
	SetCurrentPlan("speed_focused")
	? @@NL( ExplainDifference("cost_focused") )
	#--> [
	# 	[ "plan1", "speed_focused" ],
	# 	[ "plan2", "cost_focused" ],
	# 	[ "same_path", TRUE ],
	# 	[
	# 		"route1",
	# 		[ "warehouse", "suburb_b", "customer" ]
	# 	],
	# 	[
	# 		"route2",
	# 		[ "warehouse", "suburb_b", "customer" ]
	# 	],
	# 	[ "diverge_at_step", 0 ],
	# 	[ "cost1", 35 ],
	# 	[ "cost2", 23 ],
	# 	[ "cheaper", "cost_focused" ]
	# ]

}

pf()
# Executed in 0.03 second(s) in Ring 1.25
