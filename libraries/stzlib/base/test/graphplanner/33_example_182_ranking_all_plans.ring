# Narrative
# --------
# Example 18.2: Ranking All Plans
#
# Extracted from stzgraphplannertest.ring, block #33.

load "../../stzBase.ring"

`
  CONCEPT: Automatic ranking of all executed plans
  
  RankPlansBy() automatically ranks without specifying
  which plans to compare.
`

pr()

oGraph = new stzGraph("multi_strategy")
oGraph {
	AddNode("warehouse")
	AddNode("route_highway")
	AddNode("route_backroad")
	AddNode("route_express")
	AddNode("destination")
	
	AddEdgeXTT("warehouse", "route_highway", "path", [
		:time = 10, :cost = 50, :distance = 20
	])
	AddEdgeXTT("route_highway", "destination", "path", [
		:time = 8, :cost = 40, :distance = 15
	])
	
	AddEdgeXTT("warehouse", "route_backroad", "path", [
		:time = 25, :cost = 15, :distance = 30
	])
	AddEdgeXTT("route_backroad", "destination", "path", [
		:time = 20, :cost = 10, :distance = 25
	])
	
	AddEdgeXTT("warehouse", "route_express", "path", [
		:time = 5, :cost = 80, :distance = 18
	])
	AddEdgeXTT("route_express", "destination", "path", [
		:time = 4, :cost = 60, :distance = 12
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Execute plans
	AddPlan("ultra_fast")
	Walk(:From = "warehouse", :To = "destination")
	Using(:fastest)
	Execute()
	
	AddPlan("budget")
	Walk(:From = "warehouse", :To = "destination")
	Using(:cheapest)
	Execute()
	
	# Auto-rank all executed plans
	? @@NL( RankPlansBy("cost") )
	#--> [
	#      [ "ultra_fast", 15.30 ],
	#      [ "budget", 31 ]
	#    ]
}

pf()
# Executed in 0.03 second(s) in Ring 1.25

#=====================================#
#  SECTION 19: HISTORICAL COMPARISON  #
#=====================================#
