# Narrative
# --------
# Example 20.3: Complex Multi-Constraint Filtering
#
# Extracted from stzgraphplannertest.ring, block #38.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

`
  CONCEPT: Combine multiple constraints
  
  Real-world: "Find plans under $50 that avoid downtown
  and have fewer than 5 steps."
`

pr()

oGraph = new stzGraph("complex_filter")
oGraph {
	AddNode("start")
	AddNode("downtown")
	AddNode("suburbs")
	AddNode("industrial")
	AddNode("end")
	
	# Downtown: cheap but risky
	AddEdgeXTT("start", "downtown", "path", [:cost = 15])
	AddEdgeXTT("downtown", "end", "path", [:cost = 10])
	
	# Suburbs: moderate
	AddEdgeXTT("start", "suburbs", "path", [:cost = 25])
	AddEdgeXTT("suburbs", "end", "path", [:cost = 20])
	
	# Industrial: safe but longer
	AddEdgeXTT("start", "industrial", "path", [:cost = 30])
	AddEdgeXTT("industrial", "suburbs", "path", [:cost = 10])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Force different routes
	AddPlan("through_downtown")
	Walk(:From = "start", :To = "downtown")
	Minimize("cost")
	Execute()
	
	AddPlan("through_suburbs")
	Walk(:From = "start", :To = "suburbs")
	Minimize("cost")
	Execute()
	
	AddPlan("through_industrial")
	Walk(:From = "start", :To = "industrial")
	Minimize("cost")
	Execute()
	
	# Multi-constraint filter
	oFilter = FilterPlansQ([
		:maxCost = 50,
		:avoid = "downtown",
		:maxSteps = 4
	])
	
	? oFilter.Count() + NL
	#--> 2 (excludes through_downtown)
	
	? @@( oFilter.Plans() ) + NL
	#--> [ "through_suburbs", "through_industrial" ]
	
	? @@NL( oFilter.PlansXT() ) + NL
	#--> [
	# 	[
	# 		"constrains_applied",
	# 		[
	# 			[ "maxcost", 50 ],
	# 			[ "avoid", "downtown" ],
	# 			[ "maxsteps", 4 ]
	# 		]
	# 	],
	# 	[ "plans_matching_count", 2 ],
	# 	[
	# 		"plans_matching_details",
	# 		[
	# 			[
	# 				[ "plan", "through_suburbs" ],
	# 				[ "cost", 25 ],
	# 				[ "steps", 2 ],
	# 				[
	# 					"route",
	# 					[ "start", "suburbs" ]
	# 				]
	# 			],
	# 			[
	# 				[ "plan", "through_industrial" ],
	# 				[ "cost", 30 ],
	# 				[ "steps", 2 ],
	# 				[
	# 					"route",
	# 					[ "start", "industrial" ]
	# 				]
	# 			]
	# 		]
	# 	]
	# ]

	? oFilter.BestBy("cost")
	#--> through_suburbs
}

pf()
# Executed in 0.02 second(s) in Ring 1.25
