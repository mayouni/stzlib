# Narrative
# --------
# Example 16.1: Complete Warehouse Robot Planning
#
# Extracted from stzgraphplannertest.ring, block #30.

load "../../stzBase.ring"

`
  CONCEPT: Putting it all together
  
  Compare multiple strategies for warehouse robot navigation
  and choose based on the situation.
`

pr()

oGraph = new stzGraph("warehouse_complete")
oGraph {
	AddNodeXTT("receiving", "Receiving Bay", [:x = 0, :y = 0])
	AddNodeXTT("aisle_main", "Main Aisle", [:x = 20, :y = 0])
	AddNodeXTT("aisle_side", "Side Aisle", [:x = 10, :y = 10])
	AddNodeXTT("storage", "Cold Storage", [:x = 30, :y = 10])
	AddNodeXTT("shelf_42", "Target Shelf", [:x = 40, :y = 10])
	
	# Main route: fast but congested
	AddEdgeXTT("receiving", "aisle_main", "path", [
		:distance = 20,
		:time = 5,
		:energy = 10,
		:congestion = 8
	])
	AddEdgeXTT("aisle_main", "storage", "path", [
		:distance = 15,
		:time = 4,
		:energy = 8,
		:congestion = 7
	])
	
	# Alternative: longer but clear
	AddEdgeXTT("receiving", "aisle_side", "path", [
		:distance = 15,
		:time = 8,
		:energy = 12,
		:congestion = 2
	])
	AddEdgeXTT("aisle_side", "storage", "path", [
		:distance = 25,
		:time = 10,
		:energy = 15,
		:congestion = 1
	])
	
	# Final leg to shelf
	AddEdgeXTT("storage", "shelf_42", "path", [
		:distance = 10,
		:time = 3,
		:energy = 5,
		:congestion = 3
	])

	# You can get a visual diagram using View()
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Scenario 1: Rush order
	AddPlan("urgent")
	Walk(:From = "receiving", :To = "shelf_42")
	Using(:fastest)
	Execute()
	
	# Scenario 2: Battery low
	AddPlan("energy_saving")
	Walk(:From = "receiving", :To = "shelf_42")
	Using(:efficient)
	Execute()
	
	# Scenario 3: Balanced approach
	AddPlan("normal")
	Walk(:From = "receiving", :To = "shelf_42")
	Using(:balanced)
	Execute()
	
	# Analyze urgent plan
	SetCurrentPlan("urgent")
	? @@( Route() )
	#--> [ "receiving", "aisle_main", "storage", "shelf_42" ]
	
	? Cost()
	#--> 21.90
	
	? @@NL( ExplainEfficiency() ) + NL
	#--> [
	# 	[ "plan", "urgent" ],
	# 	[ "nodes_explored", 4 ],
	# 	[ "path_length", 4 ],
	# 	[ "ratio", 1 ],
	# 	[ "assessment", "very efficient" ]
	# ]
	
	# Analyze energy-saving plan
	SetCurrentPlan("energy_saving")
	? @@( Route() )
	#--> [ "receiving", "aisle_main", "storage", "shelf_42" ]
	
	? Cost()
	#--> 18.60
	
	# Analyze normal plan
	SetCurrentPlan("normal")
	? @@( Route() )
	#--> [ "receiving", "aisle_main", "storage", "shelf_42" ]
	
	? Cost() + NL
	#--> 19.20
	
	# Compare strategies
	SetCurrentPlan("urgent")
	? @@NL( TradeoffsAgainst("energy_saving") )
	#--> [
	# 	[ "plan1", "urgent" ],
	# 	[ "plan2", "energy_saving" ],
	# 	[ "cost_winner", "energy_saving" ],
	# 	[ "cost_savings", 3.30 ],
	# 	[ "length_winner", "tie" ],
	# 	[ "length_difference", 0 ],
	# 	[
	# 		"recommendation",
	# 		"Choose energy_saving for cost optimization"
	# 	]
	# ]
}

pf()
# Executed in 0.05 second(s) in Ring 1.25

#====================================#
#  SECTION 17: EDUCATIONAL USE CASE  #
#====================================#
