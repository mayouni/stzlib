# Narrative
# --------
# Example 4.2: Budget Constraints
#
# Extracted from stzgraphplannertest.ring, block #10.

load "../../../stzBase.ring"

  
`
  CONCEPT: Different optimization criteria yield different plans
  
  Premium path: start -> process_a -> end (cost: 150, quality: 10)
  Standard path: start -> process_b -> process_c -> end (cost: 75, quality: 7)
  
  When minimizing cost, planner chooses standard path.
`

pr()

oGraph = new stzGraph("budget_production")
oGraph {
	AddNode("start")
	AddNode("process_a")
	AddNode("process_b")
	AddNode("process_c")
	AddNode("end")
	
	# Expensive high-quality route
	AddEdgeXTT("start", "process_a", "premium", [
		:cost = 100,
		:quality = 10
	])
	AddEdgeXTT("process_a", "end", "finish", [
		:cost = 50,
		:quality = 10
	])
	
	# Cheaper standard route
	AddEdgeXTT("start", "process_b", "standard", [
		:cost = 30,
		:quality = 7
	])
	AddEdgeXTT("process_b", "process_c", "continue", [
		:cost = 25,
		:quality = 7
	])
	AddEdgeXTT("process_c", "end", "finish", [
		:cost = 20,
		:quality = 7
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("optim_cost")
	Walk(:From = "start", :To = "end")
	Minimizing("cost")  # Optimize for cost, not quality
	Execute()

	? Cost()
	#--> 75 (chose budget route: 30 + 25 + 20)

	? @@( Route() )
	#--> [ "start", "process_b", "process_c", "end" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 5: NETWORK ROUTING                #
#============================================#
