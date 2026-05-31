# Narrative
# --------
# Filter with OR condition
#
# Extracted from stzgraphquerytest.ring, block #10.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:dept = "Engineering"])
	AddNodeXTT("bob", "Employee", [:dept = "Sales"])
	AddNodeXTT("carol", "Employee", [:dept = "Engineering"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:dept, "=", "Sales", :or, :dept, "=", "Engineering"]).
	Select("*")

? len(aResults)
#--> 3

pf()
# Executed in 0.01 second(s) in Ring 1.25
