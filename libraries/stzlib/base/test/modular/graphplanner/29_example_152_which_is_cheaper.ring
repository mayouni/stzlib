# Narrative
# --------
# Example 15.2: Which Is Cheaper?
#
# Extracted from stzgraphplannertest.ring, block #29.

load "../../../stzBase.ring"

`
  CONCEPT: Quick comparison methods for decision support
  
  When you just need a quick answer: "which plan costs less?"
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

	SetCurrentPlan("budget")
	? WhichIsCheaper("rush")
	#--> rush
	
	# How much cheaper?
	? CostSaving("rush") # Or HowMutchCheaper()
	#--> 34.20

	# ~> You can now make informed decisions quickly
}

pf()
# Executed in 0.02 second(s) in Ring 1.25

#=============================================#
#  SECTION 16: REAL-WORLD INTEGRATED EXAMPLE  #
#=============================================#
