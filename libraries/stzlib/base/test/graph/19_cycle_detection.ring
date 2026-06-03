# Narrative
# --------
# Cycle Detection
#
# Extracted from stzgraphtest.ring, block #19.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("CycleTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("c", "a")
	
	? HasCyclicDependencies() #--> TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
