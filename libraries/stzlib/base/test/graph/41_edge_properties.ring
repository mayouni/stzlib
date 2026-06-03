# Narrative
# --------
# Edge Properties
#
# Extracted from stzgraphtest.ring, block #41.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("EdgePropsTest")
oGraph {
	AddNode("a")
	AddNode("b")
	
	AddEdgeXTT("a", "b", "link", [:weight = 10])
	? EdgeExists("a", "b") # Or HasEdge("a", "b")

	? EdgeProperty("a", "b", "weight") #--> 10
	
	SetEdgeProperty("a", "b", "status", "active")
	
	? EdgeProperty("a", "b", "status")
	#--> "active"
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

#============================================#
#  SECTION 14: BATCH OPERATIONS
#============================================#
