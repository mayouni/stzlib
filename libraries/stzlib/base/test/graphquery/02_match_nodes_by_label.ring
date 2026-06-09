# Narrative
# --------
# Match nodes by label
#
# Extracted from stzgraphquerytest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("social")
oGraph {
	AddNodeXT("alice", "Person")
	AddNodeXT("bob", "Person")
	AddNodeXT("company_x", "Company")
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:nodes, :labeled = "Person"]).
	Select("*")

? len(aResults)
#--> 2

? @@( aResults[1]["node"][:id] )
#--> "alice"

pf()
# Executed in almost 0 second(s) in Ring 1.25
