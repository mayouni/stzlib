# Narrative
# --------
# Filter with contains
#
# Extracted from stzgraphquerytest.ring, block #8.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice_smith", "Person", [:name = "Alice Smith"])
	AddNodeXTT("bob_jones", "Person", [:name = "Bob Jones"])
	AddNodeXTT("alice_brown", "Person", [:name = "Alice Brown"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:name, :contains, "Alice"]).
	Select("*")

? len(aResults)
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.25
