# Narrative
# --------
# Reachability
#
# Extracted from stzgraphtest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("ReachTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	AddNode("d")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("a", "d")
	
	? @@( ReachableFrom("a") )
	#--> [ "a", "b", "d", "c" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
