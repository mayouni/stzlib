# Narrative
# --------
# Filter with comparison
#
# Extracted from stzgraphquerytest.ring, block #7.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:salary = 50000])
	AddNodeXTT("bob", "Employee", [:salary = 60000])
	AddNodeXTT("carol", "Employee", [:salary = 70000])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:salary, ">", 55000]).
	Select("*")

? len(aResults)
#--> 2

? @@( aResults[1]["node"][:id] )
#--> "bob"

pf()
# Executed in 0.01 second(s) in Ring 1.25
