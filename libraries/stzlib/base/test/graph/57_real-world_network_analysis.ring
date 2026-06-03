# Narrative
# --------
# Real-world network analysis
#
# Extracted from stzgraphtest.ring, block #57.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("SocialNetwork")
oGraph {
	AddNode(:alice)
	AddNode(:bob)
	AddNode(:charlie)
	AddNode(:diana)
	AddNode(:eve)
	
	Connect(:alice, :bob)
	Connect(:bob, :charlie)
	Connect(:charlie, :diana)
	Connect(:diana, :eve)
	Connect(:bob, :diana)  # Shortcut
	
	# Network Analysis

	? Diameter()
	#--> 3

	? AveragePathLength()
	#--> 1.60

	? IsConnected() + NL
	#--> TRUE

	# Node Importance

	? BetweennessCentrality(:bob)
	#--> 0.25

	? ClosenessCentrality(:charlie)
	#--> 0.67

	# Critical Nodes

	? @@( ArticulationPoints() )
	#--> [ "bob", "charlie", "diana" ]

	View()

}

pf()
# Executed in 0.02 second(s) in Ring 1.24
