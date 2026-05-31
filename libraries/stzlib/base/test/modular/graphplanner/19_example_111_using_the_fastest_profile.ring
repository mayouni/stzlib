# Narrative
# --------
# Example 11.1: Using the :fastest Profile
#
# Extracted from stzgraphplannertest.ring, block #19.

load "../../../stzBase.ring"

`
  CONCEPT: Profiles encode common optimization strategies
  
  The :fastest profile optimizes for:
  - time (weight 0.7)
  - distance (weight 0.3)
  
  This is perfect for delivery services during rush hour.
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
	AddPlan("fast_delivery")
	Walk(:From = "warehouse", :To = "customer")
	Using(:fastest)  # Uses the predefined :fastest profile
	Execute()

	? Cost()
	#--> 25 (Lower cost due to time optimization)
	
	? @@( Route() ) + NL
	#--> [ "warehouse", "suburb_b", "customer" ]
	# Chose suburb_b route (lighter traffic)
	
	? @@NL( Explain() )
	#--> [
	# 	[ "plan", "fast_delivery" ],
	# 	[
	# 		"actions",
	# 		[
	# 			[
	# 				[ "from", "warehouse" ],
	# 				[ "to", "suburb_b" ],
	# 				[ "cost", 20 ]
	# 			],
	# 			[
	# 				[ "from", "suburb_b" ],
	# 				[ "to", "customer" ],
	# 				[ "cost", 15 ]
	# 			]
	# 		]
	# 	],
	# 	[ "total_cost", 35 ],
	# 	[
	# 		"route",
	# 		[ "warehouse", "suburb_b", "customer" ]
	# 	],
	# 	[ "steps", 2 ]
	#  ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.25
