# Narrative
# --------
# Batch Edge Updates Using Anonymous Functions
#
# Extracted from stzgraphtest.ring, block #42.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("BatchEdgeTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	AddEdgeXTT("a", "b", "link1", [:cost = 10])
	AddEdgeXTT("b", "c", "link2", [:cost = 20])
	
	UpdateEdgesF(func(aEdge) {
		if HasKey(aEdge["properties"], "cost")
			aEdge["properties"]["cost"] *= 2
		ok
	})
	
	? EdgeProperty("a", "b", "cost") #--> 20
	? EdgeProperty("b", "c", "cost") #--> 40
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

#============================================#
#  SECTION 15: YAML EXPORT
#============================================#
