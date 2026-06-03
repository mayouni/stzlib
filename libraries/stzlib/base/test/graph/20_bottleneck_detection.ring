# Narrative
# --------
# Bottleneck Detection
#
# Extracted from stzgraphtest.ring, block #20.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("BottleneckTest")
oGraph {
	AddNode("hub")
	AddNode("n1")
	AddNode("n2")
	AddNode("n3")
	
	Connect("n1", "hub")
	Connect("n2", "hub")
	Connect("n3", "hub")
	Connect("hub", "n1")
	
	? @@( BottleneckNodes() ) #--> ["hub"]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
