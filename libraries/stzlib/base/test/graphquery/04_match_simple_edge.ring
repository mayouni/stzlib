# Narrative
# --------
# Match simple edge
#
# Extracted from stzgraphquerytest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	
	ConnectXT("alice", "bob", "KNOWS")
	ConnectXT("bob", "carol", "KNOWS")
}

aResults = StzGraphQueryQ(oGraph).
	MatchEdgeQ([:from = "a", :to = "b", :labeled = "KNOWS"]).
	Select(["a", "b"])

? len(aResults)
#--> 2

? @@( aResults[1]["a"][:id] )
#--> "alice"

? @@( aResults[1]["b"][:id] )
#--> "bob"

pf()
# Executed in almost 0 second(s) in Ring 1.25
