# Narrative
# --------
# Neighbors and Incoming
#
# Extracted from stzgraphtest.ring, block #7.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("ConnectionsTest")
oGraph {
	AddNode("hub")
	AddNode("n1")
	AddNode("n2")
	AddNode("n3")
	
	Connect("n1", "hub")
	Connect("n2", "hub")
	Connect("hub", "n3")
	
	? @@( Neighbors("hub") )    #--> [ "n3" ]
	? @@( Incoming("hub") )     #--> [ "n1", "n2" ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
