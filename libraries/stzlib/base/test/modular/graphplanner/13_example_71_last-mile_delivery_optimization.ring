# Narrative
# --------
# Example 7.1: Last-Mile Delivery Optimization
#
# Extracted from stzgraphplannertest.ring, block #13.

load "../../../stzBase.ring"

`
  CONCEPT: Real-world routing considers multiple factors
  
  Like Amazon delivery routing: find fastest path from
  warehouse to customer considering traffic conditions.
  
  Route A: warehouse -> suburb_a -> downtown (heavy traffic on suburb_a->downtown)
  Route B: warehouse -> suburb_b -> downtown (medium traffic, slightly longer distance)
  
  When minimizing time, planner weighs trade-offs automatically.
`
pr()

oGraph = new stzGraph("delivery")
oGraph {
	AddNodeXTT("warehouse", "Fulfillment Center", [
		:packages = 100,
		:x = 0,
		:y = 0
	])
	
	AddNodeXTT("suburb_a", "Suburb A", [
		:packages = 0,
		:x = 10,
		:y = 5
	])
	
	AddNodeXTT("suburb_b", "Suburb B", [
		:packages = 0,
		:x = 15,
		:y = 10
	])
	
	AddNodeXTT("downtown", "Downtown Hub", [
		:packages = 0,
		:x = 20,
		:y = 15
	])
	
	AddNodeXTT("customer", "Customer Address", [
		:packages = 0,
		:x = 25,
		:y = 20
	])
	
	# Route through suburb_a (shorter but may have traffic)
	AddEdgeXTT("warehouse", "suburb_a", "highway", [
		:distance = 12,
		:traffic = "light",
		:time = 12  # distance * 1
	])
	
	AddEdgeXTT("suburb_a", "downtown", "road", [
		:distance = 15,
		:traffic = "heavy",
		:time = 30  # distance * 2
	])
	
	# Route through suburb_b (longer but better traffic)
	AddEdgeXTT("warehouse", "suburb_b", "highway", [
		:distance = 18,
		:traffic = "light",
		:time = 18  # distance * 1
	])
	
	AddEdgeXTT("suburb_b", "downtown", "road", [
		:distance = 10,
		:traffic = "medium",
		:time = 15  # distance * 1.5
	])
	
	# Final leg to customer
	AddEdgeXTT("downtown", "customer", "local", [
		:distance = 8,
		:traffic = "light",
		:time = 8  # distance * 1
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("delivery_plan")
	Walk(:From = "warehouse", :To = "customer")
	Minimizing("time")
	Execute()

	? Cost()
	#--> 41

	? @@( Route() )
	#--> [ "warehouse", "suburb_b", "downtown", "customer" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
