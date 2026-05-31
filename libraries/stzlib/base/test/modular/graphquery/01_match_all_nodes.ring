# Narrative
# --------
# Match all nodes
#
# Extracted from stzgraphquerytest.ring, block #1.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("social")
oGraph {
	AddNodeXT("alice", "Person")
	AddNodeXT("bob", "Person")
	AddNodeXT("company_x", "Company")
	
	SetNodeProperty("alice", "age", 30)
	SetNodeProperty("bob", "age", 25)
}

# Query: Match all nodes
aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	Select("*")

? len(aResults)
#--> 3

? @@( aResults[1]["node"][:id] )
#--> "alice"

pf()
# Executed in almost 0 second(s) in Ring 1.25
