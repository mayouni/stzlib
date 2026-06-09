# Narrative
# --------
# Filter with equals
#
# Extracted from stzgraphquerytest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:salary = 50000])
	AddNodeXTT("bob", "Employee", [:salary = 60000])
	AddNodeXTT("carol", "Employee", [:salary = 50000])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:nodes, :labeled = "Employee"]).
	WhereQ([:salary, "=", 50000]).
	Select("*")

? len(aResults)
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.25
