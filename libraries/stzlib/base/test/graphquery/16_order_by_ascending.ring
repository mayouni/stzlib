# Narrative
# --------
# Order by ascending
#
# Extracted from stzgraphquerytest.ring, block #16.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:age = 30])
	AddNodeXTT("bob", "Employee", [:age = 25])
	AddNodeXTT("carol", "Employee", [:age = 35])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	OrderByQ("n.age", "ASC").
	Select("n")

? @@( aResults[1]["n"][:id] )
#--> "alice"

? @@( aResults[3]["n"][:id] )
#--> "carol"

pf()
# Executed in 0.02 second(s) in Ring 1.26
