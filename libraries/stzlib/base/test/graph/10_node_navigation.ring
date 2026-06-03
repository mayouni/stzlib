# Narrative
# --------
# Node Navigation
#
# Extracted from stzgraphtest.ring, block #10.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("NavTest")
oGraph {
	AddNode("first")
	AddNode("second")
	AddNode("third")
	
	? FirstNode()["label"]   #--> "First"
	? LastNode()["label"]    #--> "Third"
	? NodeAt(2)["label"]     #--> "Second"
	? NodePosition("second") #--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
