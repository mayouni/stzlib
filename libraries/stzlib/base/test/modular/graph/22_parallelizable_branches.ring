# Narrative
# --------
# Parallelizable Branches
#
# Extracted from stzgraphtest.ring, block #22.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("ParallelTest")
oGraph {
	AddNode("start")
	AddNode("pathA")
	AddNode("pathB")
	AddNode("endA")
	AddNode("endB")
	
	Connect("start", "pathA")
	Connect("start", "pathB")
	Connect("pathA", "endA")
	Connect("pathB", "endB")
	
	? @@( ParallelizableBranches() ) # Or ParaBranches()
	#--> [["pathA", "pathB"]]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
