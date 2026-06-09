# Narrative
# --------
# Connected graph
#
# Extracted from stzgraphtest.ring, block #47.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Connected")
oGraph {
	AddNode(:a)
	AddNode(:b)
	AddNode(:c)

	Connect(:a, :b)
	Connect(:b, :c)

	? IsConnected()
	#--> TRUE

	? @@NL( ConnectedComponents() )
	#--> [ [ "a", "b", "c" ] ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
