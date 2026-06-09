# Narrative
# --------
# Basic Self-Loop Operations
#
# Extracted from stzgraphtest.ring, block #59.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("SelfLoopTest")
oGraph {
	AddNode("node")
	Connect("node", :to = "node")  # Self-loop

	? EdgeExists(:from = "node", :to = "node")
	#--> TRUE

	SetEdgeProperty(:from = "node", :to = "node", "type", "recursive")
	? EdgeProperty(:from = "node", :to = "node", "type")
	#--> "recursive"

	RemoveEdge(:from = "node", :to = "node")
	? EdgeExists(:from = "node", :to = "node")
	#--> FALSE
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
