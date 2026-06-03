# Narrative
# --------
# Example 3.2: Multi-Stop Delivery
#
# Extracted from stzgraphplannertest.ring, block #8.

load "../../stzBase.ring"


`
  CONCEPT: Simple goal = just reach exit optimally
  
  Note: This doesn't enforce visiting ALL zones, just
  finding the fastest route to exit. For true multi-stop
  optimization (traveling salesman problem), you'd need a
  different approach or chain multiple plans.
`

pr()

oGraph = new stzGraph("delivery_route")
oGraph {
	AddNode("dock")
	AddNode("zone_a")
	AddNode("zone_b")
	AddNode("zone_c")
	AddNode("exit")
	
	# Sequential path through all zones
	AddEdgeXTT("dock", "zone_a", "route", [:time = 5])
	AddEdgeXTT("zone_a", "zone_b", "route", [:time = 3])
	AddEdgeXTT("zone_b", "zone_c", "route", [:time = 4])
	AddEdgeXTT("zone_c", "exit", "route", [:time = 6])
	
	# Alternative shortcuts
	AddEdgeXTT("dock", "zone_b", "route", [:time = 7])  # Skip zone_a
	AddEdgeXTT("zone_a", "zone_c", "route", [:time = 10])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("multi_stop")
	Walk(:FromNode = "dock", :ToNode = "exit")
	Minimizing("time")
	Execute()

	? Cost()
	#--> 17 (skipped zone_a!)

	? @@( Route() )
	#--> [ "dock", "zone_b", "zone_c", "exit" ]
	# Took shortcut directly to zone_b
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 4: MANUFACTURING WORKFLOW         #
#============================================#
