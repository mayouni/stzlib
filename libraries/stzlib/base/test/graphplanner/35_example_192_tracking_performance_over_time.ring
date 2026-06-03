# Narrative
# --------
# Example 19.2: Tracking Performance Over Time
#
# Extracted from stzgraphplannertest.ring, block #35.

load "../../stzBase.ring"

`
  CONCEPT: Identify performance trends and degradation
  
  Monitor route performance as network conditions change.
`

pr()

oGraph = new stzGraph("performance_tracking")
oGraph {
	AddNode("depot")
	AddNode("hub")
	AddNode("customer")
	
	AddEdgeXTT("depot", "hub", "route", [:cost = 20, :time = 10])
	AddEdgeXTT("hub", "customer", "route", [:cost = 15, :time = 8])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Simulate 5 runs with increasing congestion
	for i = 1 to 5
		AddPlan("delivery_" + i)
		Walk(:From = "depot", :To = "customer")
		Minimize("cost")
		Execute()
		
		? Cost()
		#--> Run 1: 35, Run 2: 38, Run 3: 41, Run 4: 44, Run 5: 47
		
		# Simulate traffic buildup
		nCurrentCost = @oGraph.EdgeProperty("depot", "hub", "cost")
		@oGraph.SetEdgeProperty("depot", "hub", "cost", nCurrentCost + 3)
	next
	
	# Historical analysis
	? HistoryCount()
	#--> 5
	
	? HistoricalAverage("cost")
	#--> 41
	
	? BestHistoricalPlan("cost")
	#--> delivery_1
	
	? WorstHistoricalPlan("cost")
	#--> delivery_5
	
	# Latest run comparison
	SetCurrentPlan("delivery_5")
	oHistComp = CompareWithHistoryQ() # Get a tzHistoricalComparison object
	? @@NL( oHistComp.Explain() )
	#--> [
	# 	[ "current_plan", "delivery_5" ],
	# 	[ "cost", 47 ],
	# 	[ "steps", 3 ],
	# 	[ "historical_average_cost", 41 ],
	# 	[ "historical_average_steps", 3 ],
	# 	[
	# 		"observation",
	# 		"✗ Current plan is 14.63% worse than average"
	# 	],
	# 	[ "best_historical_plan", "delivery_1" ]
	# ]
}

pf()
# Executed in 0.03 second(s) in Ring 1.25

#==========================================#
#  SECTION 20: CONSTRAINT-BASED FILTERING  #
#==========================================#
