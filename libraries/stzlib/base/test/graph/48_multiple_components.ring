# Narrative
# --------
# Multiple components
#
# Extracted from stzgraphtest.ring, block #48.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("TwoComponents")
oGraph {
	AddNode(:a)
	AddNode(:b)
	AddNode(:c)
	AddNode(:d)

	Connect(:a, :b)
	Connect(:c, :d)

	? IsConnected()
	#--> FALSE

	? @@NL( ConnectedComponents() )
	#--> [ ["a", "b"], ["c", "d"] ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
