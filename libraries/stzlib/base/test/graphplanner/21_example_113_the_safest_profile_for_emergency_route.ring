# Narrative
# --------
# Example 11.3: The :safest Profile for Emergency Routes
#
# Extracted from stzgraphplannertest.ring, block #21.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

`
  CONCEPT: Safety-critical applications need risk minimization
  
  The :safest profile prioritizes:
  - danger (weight 0.8)
  - risk (weight 0.2)
  
  Perfect for ambulance routing through dangerous areas.
`

pr()

oGraph = new stzGraph("city_emergency")
oGraph {
	AddNode("hospital")
	AddNode("downtown")
	AddNode("industrial")
	AddNode("emergency_site")
	
	# Fast but dangerous route through downtown
	AddEdgeXTT("hospital", "downtown", "main_road", [
		:time = 5,
		:danger = 8,  # High crime area
		:risk = 7
	])
	AddEdgeXTT("downtown", "emergency_site", "street", [
		:time = 4,
		:danger = 9,
		:risk = 8
	])
	
	# Slower but safer route through industrial
	AddEdgeXTT("hospital", "industrial", "route", [
		:time = 8,
		:danger = 2,  # Safe area
		:risk = 1
	])
	AddEdgeXTT("industrial", "emergency_site", "route", [
		:time = 7,
		:danger = 3,
		:risk = 2
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("safe_response")
	Walk(:From = "hospital", :To = "emergency_site")
	Using(:safest)  # Prioritize crew safety
	Execute()

	# Route chosen
	? @@( Route() )
	#--> [ "hospital", "industrial", "emergency_site" ]
	# Avoided dangerous downtown route
	
	? Cost()
	#--> 4.60 (Lower danger cost)
}

pf()
# Executed in 0.04 second(s) in Ring 1.25
