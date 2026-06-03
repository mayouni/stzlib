# Narrative
# --------
# Example 15.1: Comparing Two Strategies
#
# Extracted from stzgraphplannertest.ring, block #28.

load "../../stzBase.ring"

`
  CONCEPT: Compare plans to understand trade-offs
  
  Generate two plans with different optimization criteria,
  then compare them to see the differences.
`

pr()

oGraph = new stzGraph("trade_off")
oGraph {
	AddNode("factory")
	AddNode("process_premium")
	AddNode("process_standard")
	AddNode("shipping")
	
	# Premium process: expensive but fast
	AddEdgeXTT("factory", "process_premium", "flow", [
		:cost = 100,
		:time = 5,
		:quality = 10
	])
	AddEdgeXTT("process_premium", "shipping", "flow", [
		:cost = 50,
		:time = 3,
		:quality = 10
	])
	
	# Standard process: cheap but slow
	AddEdgeXTT("factory", "process_standard", "flow", [
		:cost = 30,
		:time = 15,
		:quality = 7
	])
	AddEdgeXTT("process_standard", "shipping", "flow", [
		:cost = 20,
		:time = 10,
		:quality = 7
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Plan A: Minimize cost (budget production)
	AddPlan("budget")
	Walk(:From = "factory", :To = "shipping")
	Using(:cheapest)
	Execute()
	
	# Plan B: Minimize time (rush order)
	AddPlan("rush")
	Walk(:From = "factory", :To = "shipping")
	Using(:fastest)
	Execute()
	
	# Compare them
	SetCurrentPlan("budget")
	? @@NL (ExplainDifferenceWith("rush") ) + NL
	#--> [
	# 	[ "plan1", "budget" ],
	# 	[ "plan2", "rush" ],
	# 	[ "same_path", FALSE ],
	# 	[
	# 		"route1",
	# 		[ "factory", "process_standard", "shipping" ]
	# 	],
	# 	[
			"route2",
	# 		[ "factory", "process_premium", "shipping" ]
	# 	],
	# 	[ "diverge_at_step", 2 ],
	# 	[ "cost1", 40.40 ],
	# 	[ "cost2", 6.20 ],
	# 	[ "cheaper", "rush" ]
	# ]

	# TRADE-OFF ANALYSIS
	? @@NL( ExplainTradeoffsAgainst("rush") ) # Or Tradeoffs("rush") or Compromises("rush")
	#--> [
	# 	[ "plan1", "budget" ],
	# 	[ "plan2", "rush" ],
	# 	[ "cost_winner", "rush" ],
	# 	[ "cost_savings", 34.20 ],
	# 	[ "length_winner", "tie" ],
	# 	[ "length_difference", 0 ],
	# 	[
	# 		"recommendation",
	# 		"Choose rush for cost optimization"
	# 	]
	# ]
}

pf()
# Executed in 0.02 second(s) in Ring 1.25
