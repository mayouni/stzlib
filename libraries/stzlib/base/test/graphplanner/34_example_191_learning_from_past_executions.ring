# Narrative
# --------
# Example 19.1: Learning from Past Executions
#
# Extracted from stzgraphplannertest.ring, block #34.

load "../../stzBase.ring"

`
  CONCEPT: Compare current plans with historical data
  
  Track performance across executions to identify
  improvements or degradation.
`

pr()

oGraph = new stzGraph("evolving_network")
oGraph {
	AddNode("start")
	AddNode("mid1")
	AddNode("mid2")
	AddNode("end")
	
	AddEdgeXTT("start", "mid1", "path", [:cost = 10])
	AddEdgeXTT("start", "mid2", "path", [:cost = 15])
	AddEdgeXTT("mid1", "end", "path", [:cost = 20])
	AddEdgeXTT("mid2", "end", "path", [:cost = 8])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Attempt 1: Initial optimal route
	AddPlan("attempt1")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	? Cost()
	#--> 23
	
	? @@( Route() )
	#--> [ "start", "mid2", "end" ]
	
	# Network degrades - mid2 route congested
	@oGraph.SetEdgeProperty("mid2", "end", "cost", 25)
	
	# Attempt 2: Same plan, worse network
	AddPlan("attempt2")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	? Cost()
	#--> 30
	
	? @@( Route() )
	#--> [ "start", "mid1", "end" ] (switched routes!)
	
	# Network improves - mid1 route optimized
	@oGraph.SetEdgeProperty("mid1", "end", "cost", 12)
	
	# Attempt 3: Same plan, improved network
	AddPlan("attempt3")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	? Cost()
	#--> 22 (best yet!)
	
	? @@( Route() )
	#--> [ "start", "mid1", "end" ]
	
	# Historical analysis
	? HistoryCount()
	#--> 3
	
	? HistoricalAverage("cost")
	#--> 25
	
	? BestHistoricalPlan("cost")
	#--> attempt3
	
	# Compare current with history
	SetCurrentPlan("attempt3")
	oHistComp = CompareWithHistoryQ() # Get a stzHistoricalComparison object
	
	? @@NL( oHistComp.Explain() )
	#--> [
	# 	[ "current_plan", "attempt3" ],
	# 	[ "cost", 22 ],
	# 	[ "steps", 3 ],
	# 	[ "historical_average_cost", 25 ],
	# 	[ "historical_average_steps", 3 ],
	# 	[
	# 		"observation",
	# 		"✓ Current plan is 12% better than average"
	# 	],
	# 	[ "best_historical_plan", "attempt3" ]
	# ]
	
	? oHistComp.IsImprovement()
	#--> TRUE
	
	? oHistComp.ImprovementPercentage() # Or Improvement100()
	#--> 12
}

pf()
# Executed in 0.03 second(s) in Ring 1.25
