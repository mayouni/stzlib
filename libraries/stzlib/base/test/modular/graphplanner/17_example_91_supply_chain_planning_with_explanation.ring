# Narrative
# --------
# Example 9.1: Supply Chain Planning with Explanation
#
# Extracted from stzgraphplannertest.ring, block #17.

load "../../../stzBase.ring"

`
  CONCEPT: Plans include human-readable explanations
  
  The Explain() method generates a narrative of the plan,
  useful for debugging and understanding decisions.
`

pr()

oGraph = new stzGraph("supply_chain")
oGraph {
	AddNodeXT("supplier", "Raw Material Supplier")
	AddNodeXT("factory", "Manufacturing Plant")
	AddNodeXT("warehouse", "Distribution Center")
	AddNodeXT("retail", "Retail Store")
	
	AddEdgeXTT("supplier", "factory", "shipping", [
		:cost = 1000,
		:days = 3
	])
	
	AddEdgeXTT("factory", "warehouse", "shipping", [
		:cost = 500,
		:days = 2
	])
	
	AddEdgeXTT("warehouse", "retail", "delivery", [
		:cost = 200,
		:days = 1
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("supply_chain_plan")
	Walk(:From = "supplier", :To = "retail")
	Minimizing("cost")
	Execute()

	? Cost()
	#--> 1700 	~> (1000 + 500 + 200)

	? @@NL( Explain() ) + NL
	#-->
	# [
	# 	[ "plan", "supply_chain_plan" ],
	# 	[
	# 		"actions",
	# 		[
	# 			[
	# 				[ "from", "supplier" ],
	# 				[ "to", "factory" ],
	# 				[ "cost", 1000 ]
	# 			],
	# 			[
	# 				[ "from", "factory" ],
	# 				[ "to", "warehouse" ],
	# 				[ "cost", 500 ]
	# 			],
	# 			[
	# 				[ "from", "warehouse" ],
	# 				[ "to", "retail" ],
	# 				[ "cost", 200 ]
	# 			]
	# 		]
	# 	],
	# 	[ "total_cost", 1700 ],
	# 	[
	# 		"route",
	# 		[
	# 			"supplier",
	# 			"factory",
	# 			"warehouse",
	# 			"retail"
	# 		]
	# 	],
	# 	[ "steps", 3 ]
	# ]

	? @@( Route() )
	#--> [ "supplier", "factory", "warehouse", "retail" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#============================================#
#  SECTION 10: ALGORITHM COMPARISON          #
#============================================#
