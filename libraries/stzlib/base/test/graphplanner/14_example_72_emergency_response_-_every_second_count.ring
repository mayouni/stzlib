# Narrative
# --------
# Example 7.2: Emergency Response - Every Second Counts
#
# Extracted from stzgraphplannertest.ring, block #14.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


`
  CONCEPT: Critical routing where optimization matters most
  
  Fire truck needs fastest route to emergency. Main street
  has a congested bridge (8 minutes), but back road through
  hospital is faster overall.
  
  Route A: station -> main_st -> bridge -> emergency (3 + 8 + 5 = 16)
  Route B: station -> back_road -> hospital -> emergency (5 + 4 + 3 = 12) ✓
  
  4 minutes saved can mean saving lives!
`

pr()

oGraph = new stzGraph("emergency")
oGraph {
	AddNodeXTT("station", "Fire Station", [
		:emergency = TRUE,
		:priority = 10
	])
	
	AddNodeXTT("main_st", "Main Street", [
		:congestion = 5
	])
	
	AddNodeXTT("bridge", "River Bridge", [
		:congestion = 8
	])
	
	AddNodeXTT("back_road", "Back Road", [
		:congestion = 2
	])
	
	AddNodeXTT("hospital", "City Hospital", [
		:congestion = 6
	])
	
	AddNodeXTT("emergency_site", "Emergency Location", [
		:emergency = TRUE,
		:priority = 10
	])
	
	# Main street route (congested bridge bottleneck)
	AddEdgeXTT("station", "main_st", "route", [
		:time = 3,
		:sirens = TRUE
	])
	
	AddEdgeXTT("main_st", "bridge", "route", [
		:time = 8,  # Slow due to traffic
		:sirens = TRUE
	])
	
	# Back road route (less congested)
	AddEdgeXTT("station", "back_road", "route", [
		:time = 5,
		:sirens = TRUE
	])
	
	AddEdgeXTT("back_road", "hospital", "route", [
		:time = 4,
		:sirens = TRUE
	])
	
	# Final legs to emergency site
	AddEdgeXTT("bridge", "emergency_site", "route", [
		:time = 5,
		:sirens = TRUE
	])
	
	AddEdgeXTT("hospital", "emergency_site", "route", [
		:time = 3,
		:sirens = TRUE
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("emergency_response")
	Walk(:From = "station", :To = "emergency_site")
	Minimizing("time")
	Execute()

	? Cost()
	#--> 12 (back road route saves 4 minutes!)

	? @@( Route() )
	#--> [ "station", "back_road", "hospital", "emergency_site" ]
	# Avoided congested bridge, potentially saving lives
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 8: ADVANCED FEATURES              #
#============================================#
