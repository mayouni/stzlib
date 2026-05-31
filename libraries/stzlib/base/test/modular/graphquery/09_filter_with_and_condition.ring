# Narrative
# --------
# Filter with AND condition
#
# Extracted from stzgraphquerytest.ring, block #9.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:age = 30, :dept = "Engineering"])
	AddNodeXTT("bob", "Employee", [:age = 25, :dept = "Engineering"])
	AddNodeXTT("carol", "Employee", [:age = 30, :dept = "Sales"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:age, "=", 30, :and, :dept, "=", "Engineering"]).
	Select("*")

? len(aResults)
#--> 1

? @@( aResults[1]["node"][:id] )
#--> "alice"

pf()
# Executed in 0.01 second(s) in Ring 1.25
