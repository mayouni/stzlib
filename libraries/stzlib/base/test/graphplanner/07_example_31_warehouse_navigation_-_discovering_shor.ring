# Narrative
# --------
# Example 3.1: Warehouse Navigation - Discovering Shortcuts
#
# Extracted from stzgraphplannertest.ring, block #7.

load "../../stzBase.ring"

 
`
  CONCEPT: A* automatically discovers shortcuts you define
  
  Warehouse layout:
    entrance -> receiving -> aisle_a -> aisle_b -> storage -> shelf_42
       10         15           12         10         10
  
  But there's a shortcut: receiving -> storage (25)
  
  Long route: 10 + 15 + 12 + 10 + 10 = 57
  Shortcut route: 10 + 25 + 10 = 45 ✓
  
  A* will compare both and choose the shortcut!
`

pr()

oGraph = new stzGraph("warehouse")
oGraph {
	# Node coordinates help with spatial heuristics
	AddNodeXTT("entrance", "Main Entrance", [:x = 0, :y = 0])
	AddNodeXTT("receiving", "Receiving Bay", [:x = 10, :y = 0])
	AddNodeXTT("aisle_a", "Aisle A", [:x = 20, :y = 0])
	AddNodeXTT("aisle_b", "Aisle B", [:x = 20, :y = 10])
	AddNodeXTT("storage", "Cold Storage", [:x = 30, :y = 10])
	AddNodeXTT("shelf_42", "Shelf 42", [:x = 40, :y = 10])
	AddNodeXTT("packing", "Packing Area", [:x = 40, :y = 20])
	AddNodeXTT("shipping", "Shipping Dock", [:x = 50, :y = 20])
	
	# The "normal" route through aisles
	AddEdgeXTT("entrance", "receiving", "hallway", [
		:distance = 10,
		:traffic = "low"
	])
	
	AddEdgeXTT("receiving", "aisle_a", "hallway", [
		:distance = 15,
		:traffic = "high"  # Congested but still on normal route
	])
	
	AddEdgeXTT("aisle_a", "aisle_b", "cross_aisle", [
		:distance = 12,
		:traffic = "low"
	])
	
	AddEdgeXTT("aisle_b", "storage", "hallway", [
		:distance = 10,
		:traffic = "medium"
	])
	
	AddEdgeXTT("storage", "shelf_42", "aisle", [
		:distance = 10,
		:traffic = "low"
	])
	
	AddEdgeXTT("shelf_42", "packing", "hallway", [
		:distance = 15,
		:traffic = "low"
	])
	
	AddEdgeXTT("packing", "shipping", "hallway", [
		:distance = 12,
		:traffic = "medium"
	])
	
	# The SHORTCUT that warehouse workers know about!
	AddEdgeXTT("receiving", "storage", "shortcut", [
		:distance = 25,
		:traffic = "low"
	])

	# Check the visual representation of the graph to better undersatnd it
	View()
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("shortcut")
	Walk(:FromNode = "entrance", :ToNode = "shelf_42")
	Minimizing(:for = "distance")
	Execute()

	? Cost()
	#--> 45 (used the shortcut!)

	? @@( Route() )
	#--> [ "entrance", "receiving", "storage", "shelf_42" ]
	# Skipped aisle_a and aisle_b entirely

	? @@NL( Explain() )
	#--> [
	# 	[ "plan", "shortcut" ],
	# 	[
	# 		"actions",
	# 		[
	# 			[
	# 				[ "from", "entrance" ],
	# 				[ "to", "receiving" ],
	# 				[ "cost", 10 ]
	# 			],
	# 			[
	# 				[ "from", "receiving" ],
	# 				[ "to", "storage" ],
	# 				[ "cost", 25 ]
	# 			],
	# 			[
	# 				[ "from", "storage" ],
	# 				[ "to", "shelf_42" ],
	# 				[ "cost", 10 ]
	# 			]
	# 		]
	# 	],
	# 	[ "total_cost", 45 ],
	# 	[
	# 		"route",
	# 		[
	# 			"entrance",
	# 			"receiving",
	# 			"storage",
	# 			"shelf_42"
	# 		]
	# 	],
	# 	[ "steps", 3 ]
	# ]


}

pf()
# Executed in 0.01 second(s) in Ring 1.24
