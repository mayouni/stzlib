# Narrative
# --------
# Find Node Paths
#
# Extracted from stzgraphtest.ring, block #36.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("FindTest")
oGraph {
	AddNodes([ "start", "mid1", "mid2", "target" ])
	
	Connect("start", :to = "mid1")
	Connect("mid1", :to = "target")
	Connect("start", :to = "mid2")
	Connect("mid2", :to = "target")
	
	? @@NL( PathsTo(:Node = "target") ) # Or FindPath("target")
	#--> [
	#   ["start", "mid1", "target"],
	#   ["start", "mid2", "target"]
	# ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
