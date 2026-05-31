# Narrative
# --------
# Insert Nodes
#
# Extracted from stzgraphtest.ring, block #15.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("InsertTest")
oGraph {
	AddNode("n1")
	AddNode("n3")
	Connect("n1", "n3")
	
	InsertNodeBefore("n3", "n2")
	? EdgeExists("n1", "n2") #--> TRUE
	? EdgeExists("n2", "n3") #--> TRUE
	
	InsertNodeAfter("n3", "n4")
	? EdgeExists("n3", "n4") #--> TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
